---
title: ProximityPrompt
type: service
category: services
subcategory: interaction
owner: luau-gameplay-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/ProximityPrompt.md
related:
  - "[[Player]]"
  - "[[ContextActionService]]"
tags: [roblox-class, interaction]
---

# ProximityPrompt

> Prompts players to interact with 3D objects when their character approaches. [[ContextActionService]]

## Summary

ProximityPrompt is an instance that creates a built-in interaction UI when a player's character approaches an object in the 3D world. It works when parented to a `BasePart`, `Attachment`, or `Model` (with `PrimaryPart` set) in the Workspace. The prompt shows an action button (keyboard key, gamepad button, or tap target) and optional text labels.

The prompt system handles cross-platform input automatically: keyboard key (`E` by default), gamepad button (`ButtonX`), and touch tap all work out of the box. ProximityPrompt supports hold-to-activate via `HoldDuration`, line-of-sight checks via `RequiresLineOfSight`, and distance gating via `MaxActivationDistance`. The default UI can be replaced with custom UI by setting `Style` to `Custom` and using `PromptShown`/`PromptHidden` events.

Events can be connected on the individual ProximityPrompt instance or globally through `ProximityPromptService`. The global approach prevents duplicate code when many prompts share the same behavior. ProximityPrompt is preferred over the older `ClickDetector` for interactive objects.

## API Surface

### Properties

- `ActionText: string` -- The action label shown to the player (e.g., "Open", "Pick Up"). Default: "Interact".
- `ObjectText: string` -- Optional name for the object (e.g., "Treasure Chest").
- `KeyboardKeyCode: Enum.KeyCode` -- Keyboard key to trigger. Default: `E`.
- `GamepadKeyCode: Enum.KeyCode` -- Gamepad button to trigger. Default: `ButtonX`.
- `HoldDuration: float` -- Seconds the player must hold the key. 0 = instant activation.
- `MaxActivationDistance: float` -- Maximum distance (studs) for the prompt to appear.
- `MaxIndicatorDistance: float` -- Maximum distance for the prompt indicator to show.
- `RequiresLineOfSight: boolean` -- Whether the prompt hides when occluded from the camera.
- `Enabled: boolean` -- Whether the prompt is active.
- `Exclusivity: Enum.ProximityPromptExclusivity` -- Controls which prompts can show simultaneously.
- `Style: Enum.ProximityPromptStyle` -- Default or Custom UI.
- `ClickablePrompt: boolean` -- Whether the prompt UI is clickable/tappable.
- `UIOffset: Vector2` -- Pixel offset for the prompt UI.
- `AutoLocalize: boolean` -- Whether ActionText and ObjectText are auto-localized.

### Methods

- `:InputHoldBegin() -> ()` -- For custom UI: signals that the user began pressing the prompt button.
- `:InputHoldEnd() -> ()` -- For custom UI: signals that the user stopped pressing the prompt button.

### Events

- `.Triggered:Connect(fn(playerWhoTriggered: Player))` -- Fires when the player completes the activation (key press or hold duration met).
- `.TriggerEnded:Connect(fn(playerWhoTriggered: Player))` -- Fires when the player releases the key (for hold-duration prompts).
- `.PromptShown:Connect(fn(inputType: Enum.ProximityPromptInputType))` -- Fires when the prompt becomes visible (client-side).
- `.PromptHidden:Connect(fn())` -- Fires when the prompt hides (client-side).
- `.PromptButtonHoldBegan:Connect(fn(playerWhoTriggered: Player))` -- Fires when the player starts holding (for HoldDuration > 0).
- `.PromptButtonHoldEnded:Connect(fn(playerWhoTriggered: Player))` -- Fires when the player stops holding.

## Budgets and Limits

No explicit rate limits. The prompt system is driven by proximity checks per frame, so having hundreds of prompts in a dense area can impact performance.

## Common Patterns

### Simple door interaction

```lua
-- ServerScriptService/DoorSystem.server.lua
local door = workspace:WaitForChild("Door")
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Open"
prompt.ObjectText = "Door"
prompt.MaxActivationDistance = 10
prompt.HoldDuration = 0
prompt.Parent = door

prompt.Triggered:Connect(function(player: Player)
    -- Toggle door open/close
    door.CFrame = door.CFrame * CFrame.Angles(0, math.rad(90), 0)
end)
```

### Hold-to-activate with server validation

```lua
local healStation = workspace:WaitForChild("HealStation")
local prompt = healStation:FindFirstChild("ProximityPrompt")
prompt.HoldDuration = 2
prompt.ActionText = "Heal"

prompt.Triggered:Connect(function(player: Player)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)
```

## Pitfalls

- **Server vs client events**: `Triggered` fires on both server and client. Handle game-state changes on the server only.
- **PrimaryPart required for Models**: If parented to a Model without PrimaryPart set, the prompt will not appear.
- **Line of sight**: `RequiresLineOfSight` uses a raycast from the camera. The parent Part/Model is excluded from the check, but other parts can block it.
- **Exclusivity**: By default, only one prompt shows at a time. Set `Exclusivity` to `AlwaysShow` if you need multiple simultaneous prompts.
- **Custom UI cleanup**: When using `Style = Custom`, you must handle `PromptShown`/`PromptHidden` to create and destroy your own UI. Forgetting to clean up causes memory leaks.

## Related

- [[Player]] -- the player who triggers the prompt
- [[ContextActionService]] -- alternative for input binding without proximity UI

## Sources

- [wiki/raw/roblox-creator-docs/services/ProximityPrompt.md](../raw/roblox-creator-docs/services/ProximityPrompt.md)
