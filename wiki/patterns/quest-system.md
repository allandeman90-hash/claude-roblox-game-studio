---
title: quest-system
type: pattern
category: patterns
subcategory: progression
owner: game-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md
  - wiki/raw/community/devforum/service-registry-design-pattern.md
related:
  - "[[core-loop]]"
  - "[[DataStoreService]]"
  - "[[signal-pattern]]"
  - "[[daily-rewards]]"
  - "[[inventory-pattern]]"
tags: [pattern, progression, quests, missions]
---

# Quest System

> Server-authoritative quest progression with objective tracking, reward granting, and client UI synchronization via RemoteEvents.

## Summary

A quest system drives player engagement by providing structured goals with rewards. Quest state (active quests, objective progress, completion status) is stored entirely server-side in the player's data profile. The server exposes a `QuestService` that advances objectives, checks completion, and grants rewards. The client listens for quest-state updates via RemoteEvent to render the quest log UI.

## When to Use It

- Any game with structured progression beyond the immediate core loop.
- Daily/weekly quest rotations to sustain [[core-loop]] engagement between content updates.
- Tutorial quests as part of [[ftue-design]] to guide new players.
- Seasonal quest passes tied to live-ops cadence.

## Implementation

### Data Schema

```lua
-- Inside player data template
quests = {
    active = {},      -- { [questId] = QuestProgress }
    completed = {},   -- { [questId] = completionTimestamp }
}

-- QuestProgress shape
-- {
--     questId = "collectGems",
--     objectives = {
--         { id = "gems", current = 3, target = 10 },
--         { id = "visitShop", current = 0, target = 1 },
--     },
--     startedAt = 1713200000,
-- }
```

### Quest Definition Config

```lua
-- ReplicatedStorage/Shared/Config/QuestConfig.lua
return {
    collectGems = {
        title = "Gem Collector",
        description = "Collect 10 gems and visit the shop.",
        objectives = {
            { id = "gems", description = "Collect gems", target = 10 },
            { id = "visitShop", description = "Visit the shop", target = 1 },
        },
        rewards = { coins = 500, xp = 100 },
        repeatable = false,
        expiresAfter = nil,  -- seconds, nil = no expiry
    },
    dailyKills = {
        title = "Daily Eliminator",
        description = "Defeat 5 enemies today.",
        objectives = {
            { id = "kills", description = "Defeat enemies", target = 5 },
        },
        rewards = { coins = 200 },
        repeatable = true,
        expiresAfter = 86400,
    },
}
```

### QuestService (Server)

```lua
-- ServerStorage/Services/QuestService.lua
local QuestService = {}

local QuestConfig = require(game.ReplicatedStorage.Shared.Config.QuestConfig)
local Signal = require(game.ReplicatedStorage.Shared.Packages.GoodSignal)

QuestService.QuestCompleted = Signal.new()  -- (player, questId, rewards)
QuestService.ObjectiveAdvanced = Signal.new()  -- (player, questId, objectiveId, current, target)

function QuestService.startQuest(player: Player, playerData, questId: string): boolean
    local config = QuestConfig[questId]
    if not config then return false end

    local quests = playerData.quests
    if quests.active[questId] then return false end  -- already active
    if quests.completed[questId] and not config.repeatable then return false end

    local objectives = {}
    for _, obj in ipairs(config.objectives) do
        table.insert(objectives, { id = obj.id, current = 0, target = obj.target })
    end

    quests.active[questId] = {
        questId = questId,
        objectives = objectives,
        startedAt = os.time(),
    }
    return true
end

function QuestService.advanceObjective(
    player: Player,
    playerData,
    questId: string,
    objectiveId: string,
    amount: number
)
    amount = math.max(0, math.floor(amount))  -- sanitize
    local quest = playerData.quests.active[questId]
    if not quest then return end

    for _, obj in ipairs(quest.objectives) do
        if obj.id == objectiveId then
            obj.current = math.min(obj.current + amount, obj.target)
            QuestService.ObjectiveAdvanced:Fire(player, questId, objectiveId, obj.current, obj.target)
            break
        end
    end

    -- Check if all objectives complete
    local allDone = true
    for _, obj in ipairs(quest.objectives) do
        if obj.current < obj.target then
            allDone = false
            break
        end
    end

    if allDone then
        QuestService.completeQuest(player, playerData, questId)
    end
end

function QuestService.completeQuest(player: Player, playerData, questId: string)
    local config = QuestConfig[questId]
    if not config then return end

    playerData.quests.active[questId] = nil
    playerData.quests.completed[questId] = os.time()

    -- Grant rewards through inventory/currency service
    -- InventoryService.grantReward(player, config.rewards)

    QuestService.QuestCompleted:Fire(player, questId, config.rewards)
end

return QuestService
```

### Client Synchronization

The server pushes quest-state snapshots to the client via RemoteEvent. The client never writes quest data.

```lua
-- Server: push updates after any quest change
QuestService.ObjectiveAdvanced:Connect(function(player, questId, objId, current, target)
    Remotes.QuestUpdate:FireClient(player, {
        type = "objective",
        questId = questId,
        objectiveId = objId,
        current = current,
        target = target,
    })
end)

QuestService.QuestCompleted:Connect(function(player, questId, rewards)
    Remotes.QuestUpdate:FireClient(player, {
        type = "completed",
        questId = questId,
        rewards = rewards,
    })
end)
```

## Variants

| Variant | Description |
|---------|-------------|
| **Daily/weekly rotations** | Server assigns N random quests at reset time; expired quests auto-remove |
| **Quest chains** | Completing quest A unlocks quest B; tracked via a `prerequisite` field in config |
| **Branching quests** | Player chooses between quest paths; store chosen branch in quest progress |
| **Season pass quests** | Quests grant season XP instead of direct rewards; ties into a separate battle-pass tracker |

## Pitfalls

- **Client-driven progress.** Never let the client call `advanceObjective` directly via a remote. Instead, the server systems that detect the relevant action (kill an enemy, collect a gem) call `QuestService.advanceObjective` internally. The remote only informs the client of the result.
- **Stale quest state.** If a player's quest data references a quest ID that no longer exists in `QuestConfig` (removed in an update), handle gracefully -- auto-remove the stale quest on load.
- **Save size growth.** The `completed` table grows unboundedly. For games with hundreds of quests, periodically prune old completions or store only the completion count.
- **Race conditions on repeatable quests.** A repeatable quest that completes and immediately restarts in the same frame can cause double-grant. Insert a cooldown or gate the restart behind the next session.

## Related

- [[core-loop]] -- quests are the 5-minute and session-length engagement loops
- [[daily-rewards]] -- complementary retention mechanic
- [[signal-pattern]] -- used for internal event coordination between services
- [[inventory-pattern]] -- reward granting flows through the inventory system
- [[DataStoreService]] -- quest progress persisted in player data

## Sources

- [wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md](../raw/community/monetization/live-ops/liveops-essentials-cadence.md) -- bi-weekly quest packs as content cadence
- [wiki/raw/community/devforum/service-registry-design-pattern.md](../raw/community/devforum/service-registry-design-pattern.md) -- service lifecycle model for QuestService
