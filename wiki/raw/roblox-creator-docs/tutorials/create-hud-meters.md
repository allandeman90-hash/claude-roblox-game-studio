---
title: Create HUD Meters
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/ui/create-hud-meters
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, ui, hud, health-meter, humanoid, tweenservice, localscript, screeninsets]
difficulty: intermediate
---

# Create HUD Meters

A **HUD** (Heads-Up Display) comprises UI elements visible during gameplay, such as score displays, health meters, and menu buttons. This tutorial demonstrates building a custom health meter to replace Roblox's default meter.

## Steps

### Screen container setup

- Create a `ScreenGui` with safe area positioning using `ScreenInsets.DeviceSafeInsets` to account for device notches and built-in Roblox controls.
- Use a `UISizeConstraint` to prevent the meter from becoming disproportionately tall on tablet screens.

### Disable default health meter

In a `LocalScript` under **StarterPlayerScripts**:

```lua
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
```

### Visual design

Create the HUD element hierarchy:
- **Parent Frame**: Outer container with background
- **Inner fill bar**: A child Frame whose width scales with health percentage
- **Icon image**: An `ImageLabel` representing the meter's subject (e.g., heart icon)

### Cross-platform testing

Use Studio's **Device Emulator** from the Test menu to verify the HUD looks correct on phones and tablets with different aspect ratios.

### Health synchronization

In a `LocalScript` under **StarterCharacterScripts**, listen for `Humanoid.HealthChanged`:

```lua
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

humanoid.HealthChanged:Connect(function(newHealth)
    local healthPercent = newHealth / humanoid.MaxHealth
    -- Update meter width here
end)
```

### Dynamic coloring

Use a five-point gradient (red→orange→yellow→lime→green) with interpolation based on health percentage. As health drops, the meter transitions smoothly through keypoints.

### Animation with TweenService

Use `TweenService` to animate transitions smoothly between the previous width and the new target width:

```lua
local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(
    0.25,  -- Duration
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

TweenService:Create(fillBar, tweenInfo, {Size = UDim2.new(healthPercent, 0, 1, 0)}):Play()
```

### Damage feedback

When damage occurs, use a `ColorCorrectionEffect` in Lighting to briefly tint the screen red, then fade back to neutral:

```lua
local Lighting = game:GetService("Lighting")
local correction = Lighting:FindFirstChild("DamageFlash")

humanoid.HealthChanged:Connect(function(newHealth)
    if newHealth < lastHealth then
        -- Take damage: flash red
        TweenService:Create(correction, TweenInfo.new(0.1), {TintColor = Color3.new(1, 0.3, 0.3)}):Play()
        task.wait(0.1)
        TweenService:Create(correction, TweenInfo.new(0.4), {TintColor = Color3.new(1, 1, 1)}):Play()
    end
    lastHealth = newHealth
end)
```

## Key Concepts

- **HUD**: Heads-up display UI overlaid on gameplay
- **StarterPlayerScripts vs StarterCharacterScripts**: Former runs once per player, latter runs each respawn
- **SetCoreGuiEnabled**: Hides built-in Roblox UI like default health
- **Humanoid.HealthChanged**: Event fired when health value changes
- **ScreenInsets**: DeviceSafeInsets avoids notches and platform chrome
- **UISizeConstraint**: Prevents scale-based sizing from going too large/small
- **TweenService**: Smooth interpolation of properties over time
- **ColorCorrectionEffect**: Lighting effect for full-screen tinting

## Notes

- Always disable the default core GUI when replacing it with custom HUDs
- Use `StarterCharacterScripts` for HUD code tied to character lifecycle
- `HealthChanged` fires on every tick — consider debouncing for performance
- Test on phone + tablet + desktop to validate scaling

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/ui/create-hud-meters
Captured: 2026-04-16
