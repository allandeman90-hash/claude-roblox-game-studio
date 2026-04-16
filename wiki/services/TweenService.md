---
title: TweenService
type: service
category: services
subcategory: animation
owner: ui-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/TweenService.md
related:
  - "[[Tween]]"
tags: [roblox-class, animation]
---

# TweenService

> Creates Tweens that smoothly interpolate instance properties over time. [[Tween]]

## Summary

TweenService is used to create `Tween` objects that interpolate (tween) properties of instances between their current values and target values. Tweens work on any object with compatible property types: number, boolean, CFrame, Color3, UDim2, Vector3, Vector2, Rect, UDim, Vector2int16, and EnumItem.

The primary method is `TweenService:Create()`, which takes a target instance, a `TweenInfo` specification, and a dictionary of goal property values. The returned Tween can then be played, paused, or cancelled. A single Tween can interpolate multiple properties simultaneously, but two Tweens cannot target the same property on the same instance -- the newer one will cancel the older.

TweenInfo controls duration, easing style (Linear, Quad, Cubic, etc.), easing direction (In, Out, InOut), delay before start, repeat count, and whether the tween reverses. This makes TweenService the standard tool for UI animations, camera transitions, color changes, and smooth object movement.

## API Surface

### Properties

_No public properties._

### Methods

- `:Create(instance: Instance, tweenInfo: TweenInfo, propertyTable: {[string]: any}) -> Tween` -- Creates a Tween that will interpolate the specified properties on the instance to the given goal values according to the TweenInfo. Does not start automatically.
- `:GetValue(alpha: number, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection) -> number` -- Returns the eased value for a given alpha (0-1). Useful for manual interpolation without creating a Tween object.

### Events

_No public events._

### TweenInfo Constructor

```lua
TweenInfo.new(
    time: number,            -- Duration in seconds (default 1)
    easingStyle: Enum.EasingStyle,  -- Default: Quad
    easingDirection: Enum.EasingDirection, -- Default: Out
    repeatCount: number,     -- 0 = no repeat, -1 = infinite
    reverses: boolean,       -- Whether to reverse after completing
    delayTime: number        -- Delay before starting (seconds)
)
```

### Tween Object Methods

- `:Play() -> ()` -- Starts or resumes the tween.
- `:Pause() -> ()` -- Pauses the tween at current progress.
- `:Cancel() -> ()` -- Stops the tween and resets it.
- `.Completed:Connect(fn(playbackState: Enum.PlaybackState))` -- Fires when the tween finishes or is cancelled.

## Budgets and Limits

No explicit rate limits on Tween creation. However, creating many simultaneous Tweens (hundreds+) can degrade performance, especially on lower-end devices.

## Common Patterns

### Smooth UI fade-in

```lua
local TweenService = game:GetService("TweenService")

local frame = script.Parent
frame.BackgroundTransparency = 1

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(frame, tweenInfo, {
    BackgroundTransparency = 0,
})
tween:Play()
```

### Smooth door opening

```lua
local TweenService = game:GetService("TweenService")
local door = workspace.Door

local openInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local openTween = TweenService:Create(door, openInfo, {
    CFrame = door.CFrame * CFrame.new(0, 5, 0), -- slide up
})
openTween:Play()
openTween.Completed:Wait()
```

## Pitfalls

- **Tween:Play() is required**: Creating a Tween does not start it. You must call `:Play()`.
- **Property conflicts**: Two Tweens on the same property cancel each other. The most recent one wins.
- **Tween is instance-specific**: A Tween created for one instance cannot be reused for another. Create a new Tween for each target.
- **Server vs client**: Tweens created on the server replicate their property changes. Tweens on the client are local-only. For visual-only animations, prefer client-side Tweens.
- **Non-tweenable types**: Properties that are not in the supported type list (e.g., string, Instance references) cannot be tweened.

## Related

- [[Tween]] -- the Tween object returned by TweenService:Create

## Sources

- [wiki/raw/roblox-creator-docs/services/TweenService.md](../raw/roblox-creator-docs/services/TweenService.md)
