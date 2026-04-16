---
title: "ADS (Aim Down Sights) Implementations"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/how-to-make-a-weapon-ads-aim-down-sights-without-a-viewmodel/2815102
related:
  - https://devforum.roblox.com/t/how-would-i-go-about-smooth-ads-aim-down-sights/1928161
  - https://devforum.roblox.com/t/help-with-ads-aim-down-sights-viewmodel/1793985
  - https://devforum.roblox.com/t/how-would-i-go-about-aiming-down-sights-based-on-an-aim-part/242540
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [ADS, aim-down-sights, viewmodel, FOV, tween, CFrame-lerp]
---

# ADS (Aim Down Sights) Implementations

Community approaches for implementing ADS in Roblox FPS games.

## Viewmodel ADS (Standard Approach)

Uses an AimPart on the weapon. The viewmodel offset is lerped so the AimPart
aligns with the camera center:

```lua
local offset = weapon.Handle.CFrame:inverse() * weapon.Aim.CFrame
local goal = aiming and joint.C0 * offset or CFrame.new()
joint.C1 = start:Lerp(goal, t/100)
```

## Non-Viewmodel ADS

For games without a separate viewmodel (e.g., Apocalypse Rising style):
- Move the camera closer to the weapon's sight part
- Use TweenService to smoothly transition camera position
- Reduce FOV during ADS for zoom effect

## Smooth ADS with NumberValue Tween

```lua
self.lerpValues.aim = Instance.new("NumberValue")
local aimOffset = idleOffset:lerp(aimCF, self.lerpValues.aim.Value)
-- TweenService tweens the NumberValue from 0 to 1
```

## FOV Transition

Common to tween Camera.FieldOfView alongside the position change:
- Hip fire: 70 FOV
- ADS: 40-50 FOV (weapon dependent)
- Scoped: 20-30 FOV

## Key Patterns

- AimPart on weapon marks where the sight aligns with camera center
- Motor6D C1 manipulation for viewmodel-based ADS
- TweenService or manual lerp for smooth transitions
- FOV tween runs in parallel with position tween
- Reduced weapon sway during ADS
- Cancellation token (aimCount) prevents overlapping transitions
