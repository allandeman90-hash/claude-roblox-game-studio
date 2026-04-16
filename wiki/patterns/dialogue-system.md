---
title: Dialogue System
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/dialogue-kit-v25.md
  - wiki/raw/community/articles/game-mechanics/simple-dialogue-module.md
related:
  - "[[quest-system]]"
  - "[[state-machine-pattern]]"
  - "[[responsive-design]]"
tags: [pattern, dialogue, NPC, ProximityPrompt, branching-choices, typewriter, chat-filter, quest, voice-lines]
---

# Dialogue System

> NPC interaction via ProximityPrompt, a branching dialogue UI panel with up to 3 choices per node, typewriter text advancement, chat filtering for dynamic text, quest integration hooks, and voice line triggers.

## Summary

A dialogue system connects NPC interaction triggers to a UI panel that displays conversation text with branching player choices. The core architecture is a **dialogue tree** -- a directed graph of nodes, where each node contains NPC text and 0-3 player response options that lead to other nodes. The system runs client-side for responsiveness, but quest progression and reward granting fire RemoteEvents validated on the server.

Key components: **ProximityPrompt** for NPC interaction range, **dialogue tree data** defining conversation flow, **UI panel** rendering text with a typewriter effect, **choice buttons** for branching, **TextService filtering** for any player-generated or dynamic text, and **Sound triggers** for voice lines.

## Implementation

### Dialogue Tree Data Structure

Define conversations as a table of nodes. Each node has NPC text, optional choices (max 3), optional conditions, and optional callbacks.

```lua
-- ReplicatedStorage/Shared/DialogueTrees.lua
export type DialogueChoice = {
    text: string,
    nextNode: string?,         -- nil = end conversation
    condition: (() -> boolean)?, -- show choice only if true
}

export type DialogueNode = {
    speaker: string,           -- NPC name displayed in title
    text: string,              -- dialogue line (supports \n for breaks)
    choices: {DialogueChoice}?, -- max 3; nil = auto-advance or end
    sound: string?,            -- rbxassetid:// for voice line
    onEnter: (() -> ())?,      -- callback when node is displayed
    autoAdvance: number?,      -- seconds before auto-advancing (cutscene mode)
}

export type DialogueTree = {
    [string]: DialogueNode     -- node ID → node
}

local DialogueTrees = {}

DialogueTrees.Blacksmith = {
    start = {
        speaker = "Gruk the Blacksmith",
        text = "Need something forged? I can sharpen your blade or craft something new.",
        sound = "rbxassetid://12345678",
        choices = {
            {text = "Sharpen my sword", nextNode = "sharpen"},
            {text = "What can you craft?", nextNode = "craft_menu"},
            {text = "Goodbye", nextNode = nil},
        },
    },
    sharpen = {
        speaker = "Gruk the Blacksmith",
        text = "That'll be 50 gold. Want me to go ahead?",
        choices = {
            {
                text = "Yes, sharpen it",
                nextNode = "sharpen_done",
                condition = function()
                    -- Check if player has enough gold (via local cache)
                    return localPlayerData.gold >= 50
                end,
            },
            {text = "Not right now", nextNode = "farewell"},
        },
    },
    sharpen_done = {
        speaker = "Gruk the Blacksmith",
        text = "All done. Your blade cuts like new.",
        onEnter = function()
            -- Fire remote to server for the actual transaction
            game.ReplicatedStorage.Remotes.SharpenSword:FireServer()
        end,
    },
    craft_menu = {
        speaker = "Gruk the Blacksmith",
        text = "I can make shields, helmets, and gauntlets. Talk to me again when you have the materials.",
    },
    farewell = {
        speaker = "Gruk the Blacksmith",
        text = "Come back when you're ready.",
    },
}

return DialogueTrees
```

### ProximityPrompt Setup

Attach a ProximityPrompt to each NPC model. The prompt triggers dialogue on interaction.

```lua
-- ServerScriptService/NPCSetup.server.lua
local CollectionService = game:GetService("CollectionService")

-- All NPC models tagged with "DialogueNPC" in Studio
for _, npcModel in CollectionService:GetTagged("DialogueNPC") do
    local head = npcModel:FindFirstChild("Head")
    if not head then continue end

    -- Only create if not already present
    if head:FindFirstChildOfClass("ProximityPrompt") then continue end

    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText = npcModel.Name
    prompt.ActionText = "Talk"
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = true
    prompt.Parent = head
end
```

### Dialogue UI Panel

A ScreenGui with a dialogue frame, speaker name, text label, choice buttons, and a continue indicator.

```lua
-- StarterGui/DialogueUI.client.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DialogueTrees = require(game.ReplicatedStorage.Shared.DialogueTrees)

-- UI references (created in Studio or programmatically)
local screenGui = playerGui:WaitForChild("DialogueScreen")
local dialogueFrame = screenGui:WaitForChild("DialogueFrame") :: Frame
local speakerLabel = dialogueFrame:WaitForChild("SpeakerLabel") :: TextLabel
local textLabel = dialogueFrame:WaitForChild("TextLabel") :: TextLabel
local choiceContainer = dialogueFrame:WaitForChild("Choices") :: Frame
local continueIndicator = dialogueFrame:WaitForChild("ContinueIndicator") :: TextLabel

-- Choice button template
local choiceTemplate = choiceContainer:WaitForChild("ChoiceTemplate") :: TextButton
choiceTemplate.Visible = false

local TYPEWRITER_SPEED = 0.03  -- seconds per character
local isDialogueActive = false
local currentTree: DialogueTrees.DialogueTree? = nil
local skipTypewriter = false

------------------------------------------------------------
-- Typewriter Effect
------------------------------------------------------------
local function typewriterText(label: TextLabel, fullText: string)
    label.Text = ""
    skipTypewriter = false

    for i = 1, #fullText do
        if skipTypewriter then
            label.Text = fullText
            return
        end
        label.Text = string.sub(fullText, 1, i)
        task.wait(TYPEWRITER_SPEED)
    end
end

------------------------------------------------------------
-- Choice Rendering
------------------------------------------------------------
local function clearChoices()
    for _, child in choiceContainer:GetChildren() do
        if child:IsA("TextButton") and child ~= choiceTemplate then
            child:Destroy()
        end
    end
end

local function showChoices(choices: {DialogueTrees.DialogueChoice}): string?
    clearChoices()
    continueIndicator.Visible = false

    local visibleChoices: {DialogueTrees.DialogueChoice} = {}
    for _, choice in choices do
        if choice.condition == nil or choice.condition() then
            table.insert(visibleChoices, choice)
        end
    end

    -- Cap at 3 visible choices
    if #visibleChoices > 3 then
        visibleChoices = {visibleChoices[1], visibleChoices[2], visibleChoices[3]}
    end

    local selectedNode: string? = nil
    local resolved = false

    for i, choice in visibleChoices do
        local btn = choiceTemplate:Clone()
        btn.Text = choice.text
        btn.LayoutOrder = i
        btn.Visible = true
        btn.Parent = choiceContainer

        btn.Activated:Connect(function()
            if resolved then return end
            resolved = true
            selectedNode = choice.nextNode
        end)
    end

    -- Wait for selection
    while not resolved do
        task.wait()
    end

    clearChoices()
    return selectedNode
end

------------------------------------------------------------
-- Display Node
------------------------------------------------------------
local function displayNode(tree: DialogueTrees.DialogueTree, nodeId: string)
    local node = tree[nodeId]
    if not node then
        -- End of conversation
        return nil
    end

    speakerLabel.Text = node.speaker or ""

    -- Play voice line
    if node.sound then
        local sound = Instance.new("Sound")
        sound.SoundId = node.sound
        sound.Parent = workspace
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end

    -- Fire onEnter callback
    if node.onEnter then
        task.spawn(node.onEnter)
    end

    -- Typewriter
    typewriterText(textLabel, node.text)

    -- Branch: choices or continue
    if node.choices and #node.choices > 0 then
        return showChoices(node.choices)
    elseif node.autoAdvance then
        task.wait(node.autoAdvance)
        return nil -- end or caller provides next node
    else
        -- Click/tap to continue or end
        continueIndicator.Visible = true
        continueIndicator.Text = "[Click to continue]"

        local waiting = true
        local conn
        conn = UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
                or input.KeyCode == Enum.KeyCode.E then
                waiting = false
            end
        end)

        while waiting do task.wait() end
        conn:Disconnect()
        continueIndicator.Visible = false
        return nil
    end
end

------------------------------------------------------------
-- Start / Stop Dialogue
------------------------------------------------------------
local function startDialogue(treeName: string)
    local tree = DialogueTrees[treeName]
    if not tree or isDialogueActive then return end

    isDialogueActive = true
    currentTree = tree
    dialogueFrame.Visible = true

    -- Walk through nodes
    local currentNode: string? = "start"
    while currentNode do
        currentNode = displayNode(tree, currentNode)
    end

    -- Dialogue ended
    dialogueFrame.Visible = false
    isDialogueActive = false
    currentTree = nil
end

-- Skip typewriter on click during text display
UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
    if not isDialogueActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        skipTypewriter = true
    end
end)

------------------------------------------------------------
-- ProximityPrompt Connection
------------------------------------------------------------
ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, triggerPlayer: Player)
    if triggerPlayer ~= player then return end

    -- NPC model should have a StringValue "DialogueTreeName"
    local npcModel = prompt.Parent and prompt.Parent.Parent
    if not npcModel then return end

    local treeNameValue = npcModel:FindFirstChild("DialogueTreeName") :: StringValue?
    if not treeNameValue then return end

    startDialogue(treeNameValue.Value)
end)
```

### Chat Filter for Dynamic Text

Any player-generated text displayed to other players must be filtered through `TextService:FilterStringAsync`. This applies to systems where players name items, write messages, or provide custom responses displayed in dialogue bubbles.

```lua
-- ServerScriptService/TextFilter.server.lua
local TextService = game:GetService("TextService")

local filterRemote = Instance.new("RemoteFunction")
filterRemote.Name = "FilterText"
filterRemote.Parent = game.ReplicatedStorage.Remotes

filterRemote.OnServerInvoke = function(player: Player, rawText: string): string
    -- Validate input
    if typeof(rawText) ~= "string" then return "" end
    if #rawText > 200 then return "" end  -- length cap

    local success, result = pcall(function()
        local filtered = TextService:FilterStringAsync(rawText, player.UserId)
        return filtered:GetNonChatStringForBroadcastAsync()
    end)

    if success then
        return result
    else
        warn(`Text filter failed for {player.Name}: {result}`)
        return "***"
    end
end
```

**Static NPC dialogue text does not need filtering** -- it is developer-authored content, not player input. Only filter text that originates from player input.

### Quest Integration

Dialogue nodes trigger quest progression via RemoteEvents. The server validates quest state before granting rewards.

```lua
-- Server: QuestHandler checks dialogue-triggered events
local questRemote = game.ReplicatedStorage.Remotes:WaitForChild("DialogueQuestAction")

questRemote.OnServerEvent:Connect(function(player: Player, questId: string, action: string)
    -- Validate
    if typeof(questId) ~= "string" or typeof(action) ~= "string" then return end

    local playerData = PlayerDataService.getData(player)
    if not playerData then return end

    local quest = playerData.quests[questId]
    if not quest then return end

    if action == "accept" and quest.status == "available" then
        quest.status = "active"
    elseif action == "complete" and quest.status == "active" and quest.progress >= quest.goal then
        quest.status = "completed"
        RewardService.grantReward(player, quest.reward)
    end
end)
```

In the dialogue tree, the `onEnter` callback fires the remote:

```lua
onEnter = function()
    game.ReplicatedStorage.Remotes.DialogueQuestAction:FireServer("blacksmith_01", "accept")
end,
```

### Voice Lines (Sound Triggers)

Each dialogue node can specify an `rbxassetid://` for a voice line. The sound plays from the NPC's head (positional audio) or from a flat Sound object (non-positional).

```lua
-- Positional voice from NPC head
local function playVoiceLine(npcHead: BasePart, soundId: string)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.RollOffMaxDistance = 30
    sound.RollOffMinDistance = 5
    sound.Volume = 0.8
    sound.Parent = npcHead
    sound:Play()
    sound.Ended:Once(function()
        sound:Destroy()
    end)
    return sound
end
```

To sync typewriter speed with voice duration, calculate characters-per-second from the audio length:

```lua
local function syncTypewriterToVoice(sound: Sound, text: string): number
    if sound.TimeLength > 0 then
        return sound.TimeLength / #text  -- seconds per character
    end
    return TYPEWRITER_SPEED  -- fallback
end
```

## Server Validation

The dialogue UI is entirely client-side -- it never sends dialogue text to the server. The server only receives:

1. **Quest actions** (accept, complete) via RemoteEvent -- validated against quest state and eligibility.
2. **Purchase actions** (triggered from shop-dialogue) via RemoteEvent -- validated against inventory and currency.
3. **Text filtering requests** (if dynamic text is displayed) via RemoteFunction -- server filters and returns safe text.

The server never trusts which dialogue node the client claims to be on. Rewards and state changes are validated independently of dialogue flow.

## Pitfalls

1. **Forgetting text filtering.** Roblox requires all player-generated text displayed to other players to be filtered through `TextService:FilterStringAsync`. Failure to filter violates Roblox ToS. Static developer-authored NPC text does not need filtering.

2. **More than 3 choices per node.** UI space is limited, especially on mobile. Cap visible choices at 3. Use conditions to hide irrelevant options rather than showing 5+ buttons.

3. **Blocking the dialogue loop.** If a choice callback yields indefinitely (e.g., waiting for a server response that never comes), the dialogue freezes. Use `task.spawn` for callbacks and add timeouts.

4. **Not disabling ProximityPrompt during dialogue.** If the player walks away and the prompt triggers again, a second dialogue can start. Disable the prompt or gate on `isDialogueActive`.

5. **Sound cleanup.** Voice line Sounds parented to NPC heads persist if the player leaves dialogue early. Track active sounds and destroy them in the dialogue-end cleanup.

6. **Trusting client quest state.** Never let the client decide quest completion. The server must verify `quest.progress >= quest.goal` independently before granting rewards.

7. **Missing `pcall` on TextService.** `FilterStringAsync` can fail (rate limits, service outages). Always wrap in pcall and fall back to censored text (`"***"`).

## Related

- [[quest-system]] -- quest data structures, progression tracking, reward granting
- [[state-machine-pattern]] -- dialogue trees are a form of state machine
- [[responsive-design]] -- dialogue UI layout for mobile, tablet, and desktop

## Sources

- [Dialogue Kit V2.5 — Fast, Easy Interactive Dialogues and Events](https://devforum.roblox.com/t/dialogue-kit-v25-fast-easy-interactive-dialogues-and-events/3548230) (DevForum community resource)
- [SimpleDialogue — A Dialogue Module](https://devforum.roblox.com/t/simpledialogue-a-dialogue-module/3631857) (DevForum community resource)
- [NPC Dialogue System](https://devforum.roblox.com/t/npc-dialogue-system/3784395) (DevForum community resource)
- [Best way to make a Dialogue System](https://devforum.roblox.com/t/best-way-to-make-a-dialogue-system/1580503) (DevForum discussion)
- [How to make npc say something when proximity prompt click?](https://devforum.roblox.com/t/how-to-make-npc-say-something-when-proximity-prompt-click/2033805) (DevForum)
- [TextService:FilterStringAsync API Reference](https://create.roblox.com/docs/reference/engine/classes/TextService) (Roblox Creator Docs)
