---
title: Play Character Animations
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/animation/play-character-animations
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, animation, humanoid, animator, animationtrack, debounce, touched, localscript]
difficulty: intermediate
---

# Play Character Animations

**Playing character animations** is an important part of what makes avatars and non-playable characters (NPCs) expressive, realistic, and engaging to your audience. In addition to providing immersive visuals, character animations provide players feedback from their actions, guidance on how to navigate the environment, and vital information about their character and others.

This tutorial shows you how to play character animations using two different techniques:
- Swapping default character animation asset IDs with your own custom animations.
- Triggering animations in response to character actions within the 3D space.

## Steps

### Change default animations

Every character with a default `Humanoid` object, whether it's a player-controlled avatar or a non-player character (NPC), includes a set of **default animations** that play whenever the character performs specific in-experience actions, such as running, climbing, and jumping.

If these default animations don't meet the design requirements for your world, you can swap them out with custom animations that apply to every player that joins your experience.

### Create script

Every character's `Humanoid` object includes a child `Animator` object that stores all of the character's default animations. To override these default values, create a script in `ServerScriptService`.

1. Hover over **ServerScriptService** and click the ⊕ button.
2. Insert a **Script**.
3. In the new script:

```lua
local Players = game:GetService("Players")

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    print("Animator found!")
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

### Replace asset ID

The following table contains all of the default character animations you can call and replace within the `Animator` object.

| Character Action | Animate Script Reference |
|---|---|
| **Run** | `animateScript.run.RunAnim.AnimationId` |
| **Walk** | `animateScript.walk.WalkAnim.AnimationId` |
| **Jump** | `animateScript.jump.JumpAnim.AnimationId` |
| **Idle** | `animateScript.idle.Animation1.AnimationId`, `animateScript.idle.Animation2.AnimationId` |
| **Fall** | `animateScript.fall.FallAnim.AnimationId` |
| **Swim** | `animateScript.swim.Swim.AnimationId` |
| **Swim (Idle)** | `animateScript.swimidle.SwimIdle.AnimationId` |
| **Climb** | `animateScript.climb.ClimbAnim.AnimationId` |

To replace the default walk animation asset ID:

```lua
local Players = game:GetService("Players")

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

    local animateScript = character:WaitForChild("Animate")
    animateScript.walk.WalkAnim.AnimationId = "rbxassetid://122652394532816"
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

### Trigger animations

While the previous technique focuses on swapping out default animations that automatically play, you can programmatically trigger animations to play in response to **any** character action within the 3D space, such as picking up an item or taking damage from a hazard.

### Insert volume

One of the most common ways to trigger unique gameplay behavior is to use **volumes**, or invisible regions within the 3D space, to detect when characters or objects interact with specific areas of the environment.

1. Add a new block part.
2. Position and resize it to cover the trigger area.
3. In Properties:
   - Set **Name** to **AnimationDetector**.
   - Set **Transparency** to `1` to make the block invisible.

### Create trigger script

Use a `LocalScript` instead of a `Script` to provide players immediate feedback. If the server were to listen for the collision and play the animation, there could be a delay due to replication time.

1. Insert a `LocalScript` into **StarterCharacterScripts** and rename it **TriggerAnimation**.
2. Add the code:

```lua
local Workspace = game:GetService("Workspace")

local animation = script:WaitForChild("Animation")
local humanoid = script.Parent:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local animationTrack = animator:LoadAnimation(animation)
local animationDetector = Workspace:WaitForChild("AnimationDetector")

local localCharacter = script.Parent
local debounce = false

animationDetector.Touched:Connect(function(hit)
    if debounce then 
        return
    end
    
    local hitCharacter = hit:FindFirstAncestorWhichIsA("Model")
    if hitCharacter ~= localCharacter then
        return
    end

    debounce = true
    animationTrack:Play()
    animationTrack.Ended:Wait()
    debounce = false
end)
```

### Add animation

1. Hover over **TriggerAnimation** LocalScript and click the ⊕ button.
2. Insert an **Animation** object.
3. Select the new animation object, then in **Properties** set **AnimationID** to your asset ID (e.g., `rbxassetid://3716468774`).

## Key Concepts

- **Humanoid.Animator**: Container for character animations
- **Animate script**: Default script on player characters controlling idle/walk/run/jump/etc
- **Asset IDs**: Replace via `animateScript.walk.WalkAnim.AnimationId = "rbxassetid://..."`
- **AnimationTrack**: Result of `animator:LoadAnimation(animation)`
- **`:Play()` / `:Stop()`**: Animation track methods
- **`.Ended:Wait()`**: Yields until animation completes
- **StarterCharacterScripts**: LocalScripts here are parented into each character on spawn
- **Debounce**: Essential to prevent repeat triggers during continuous collision
- **FindFirstAncestorWhichIsA("Model")**: Walks up parent chain

## Code Snippets

### Server-side default animation override

```lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local animateScript = character:WaitForChild("Animate")
        animateScript.walk.WalkAnim.AnimationId = "rbxassetid://YOUR_ID"
    end)
end)
```

### Client-side trigger animation

```lua
local animationTrack = animator:LoadAnimation(animation)

trigger.Touched:Connect(function(hit)
    if debounce then return end
    if hit:FindFirstAncestorWhichIsA("Model") ~= localCharacter then return end
    debounce = true
    animationTrack:Play()
    animationTrack.Ended:Wait()
    debounce = false
end)
```

## Notes

- Client-side local scripts give faster response than server-side for local player animations
- Always debounce Touched-based triggers
- Use `StarterCharacterScripts` for code tied to character lifecycle
- `Animator:LoadAnimation()` is the modern API; avoid `Humanoid:LoadAnimation()`
- Idle animations have two slots for variety (Animation1, Animation2)

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/animation/play-character-animations
Captured: 2026-04-16
