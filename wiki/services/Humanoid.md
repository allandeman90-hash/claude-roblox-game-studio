---
title: Humanoid
type: service
category: services
subcategory: character
owner: luau-gameplay-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources: []
related:
  - "[[Player]]"
  - "[[speed-hack]]"
tags: [roblox-class, character]
---

# Humanoid

> Component controlling character movement, health, and animation states. [[Player]]

## Summary

Humanoid is the component within a player's Character model that controls movement, health, jumping, animation states, and death. Every player character has a Humanoid instance, and it is the primary interface for gameplay mechanics like damage, movement speed modification, and state detection.

The Humanoid is created automatically when a character spawns and is a child of the Character model alongside HumanoidRootPart, Head, and body parts. It manages the character's physical behavior in the world -- walking, jumping, climbing, swimming, falling -- and exposes properties to control these behaviors.

**Note**: No raw source file was available for Humanoid in the captured documentation set. The information below is derived from the existing stub and common Roblox knowledge. This page should be updated when a raw source is captured.

## API Surface

### Properties (key subset)

- `Health: number` -- Current health. Setting to 0 kills the character. Triggers `HealthChanged` and `Died`.
- `MaxHealth: number` -- Maximum health. Default 100.
- `WalkSpeed: number` -- Movement speed in studs/sec. Default 16.
- `JumpPower: number` -- Upward force when jumping (used when `UseJumpPower` is true). Default 50.
- `JumpHeight: number` -- Jump height in studs (used when `UseJumpPower` is false).
- `UseJumpPower: boolean` -- Whether to use JumpPower or JumpHeight for jumping.
- `HipHeight: float` -- Height of the character's root above the ground.
- `AutoRotate: boolean` -- Whether the character automatically faces the movement direction.
- `DisplayDistanceType: Enum.HumanoidDisplayDistanceType` -- Controls name/health display behavior.

### Methods (key subset)

- `:TakeDamage(amount: number) -> ()` -- Reduces Health by amount, respecting ForceField protection.
- `:MoveTo(location: Vector3, part: BasePart?) -> ()` -- Makes the character walk toward a position.
- `:ChangeState(state: Enum.HumanoidStateType) -> ()` -- Forces a state change (e.g., Jumping, Ragdoll).
- `:GetState() -> Enum.HumanoidStateType` -- Returns the current state.
- `:SetStateEnabled(state: Enum.HumanoidStateType, enabled: boolean) -> ()` -- Enables or disables a state.
- `:GetAppliedDescription() -> HumanoidDescription` -- Returns the currently applied avatar description.
- `:ApplyDescription(description: HumanoidDescription) -> ()` -- Applies an avatar description.
- `:AddAccessory(accessory: Accessory) -> ()` -- Attaches an accessory to the character.

### Events

- `.Died:Connect(fn())` -- Fires when Health reaches 0.
- `.HealthChanged:Connect(fn(health: number))` -- Fires when Health changes.
- `.StateChanged:Connect(fn(oldState: Enum.HumanoidStateType, newState: Enum.HumanoidStateType))` -- Fires on state transitions.
- `.MoveToFinished:Connect(fn(reached: boolean))` -- Fires when MoveTo completes or times out (8 seconds).
- `.Running:Connect(fn(speed: number))` -- Fires each frame the character is running. Speed 0 = idle.
- `.Jumping:Connect(fn(isActive: boolean))` -- Fires when the character jumps.
- `.Touched:Connect(fn(touchedPart: BasePart, humanoidPart: BasePart))` -- Fires when a limb touches another part.

## Budgets and Limits

- **MoveTo timeout**: MoveTo walks toward the target for a maximum of 8 seconds. If the character cannot reach it, `MoveToFinished` fires with `false`. Chain multiple MoveTo calls for longer paths.
- **Health**: Clamped between 0 and MaxHealth. Negative damage values heal.

## Common Patterns

### Server-side damage

```lua
-- ServerScriptService/Combat.server.lua
local function dealDamage(targetCharacter: Model, amount: number)
    local humanoid = targetCharacter:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:TakeDamage(amount)
    end
end
```

### Detecting death

```lua
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        print(player.Name, "died")
    end)
end)
```

## Pitfalls

- **Server-side damage only**: Never trust client-reported health or damage. Apply damage on the server.
- **WalkSpeed exploits**: Clients can modify WalkSpeed locally. The server should validate movement speed. See [[speed-hack]].
- **MoveTo 8-second timeout**: MoveTo does not pathfind. It walks in a straight line and times out after 8 seconds. Use PathfindingService for complex navigation.
- **ForceField blocks TakeDamage**: If a ForceField is active on the character, `TakeDamage` has no effect. Use `humanoid.Health -= amount` to bypass (but consider whether that is intentional).
- **State management**: Disabling states (e.g., `SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)`) affects gameplay. Be deliberate about which states you disable.

## Related

- [[Player]] -- the Player object that owns the character
- [[speed-hack]] -- exploit where clients modify WalkSpeed

## Sources

_No raw source file available. This page was drafted from the existing stub and common Roblox API knowledge. Update when `wiki/raw/roblox-creator-docs/services/Humanoid.md` is captured._
