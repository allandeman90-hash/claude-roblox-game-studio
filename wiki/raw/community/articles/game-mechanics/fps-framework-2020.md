---
title: "Writing an FPS Framework (2020)"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/writing-an-fps-framework-2020/503318
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [fps-framework, viewmodel, spring, recoil, sway, weapon-system]
---

# Writing an FPS Framework (2020)

Detailed 2-part tutorial covering modular FPS architecture with spring-based sway,
recoil, aiming, and viewmodel rendering.

## Architecture

- Metatable-based weapon handler: handler.new(), :equip(), :remove(), :aim(), :update()
- Viewmodel stored in ReplicatedStorage, cloned and parented to workspace.Camera
- AnimationController (not Humanoid) drives viewmodel animations
- Motor6D joints connect arms to weaponRootPart
- CFrame offsets stored in Offsets folder (idle, aim, equip, fire)

## Spring System

```lua
self.springs = {}
self.springs.walkCycle = spring.create()
self.springs.sway = spring.create()
```

Mouse input drives sway:
```lua
self.springs.sway:shove(Vector3.new(mouseDelta.x / 200, mouseDelta.y / 200))
```

Walk cycle sway:
```lua
(movementSway / 25) * deltaTime * 60 * velocity.Magnitude
```

## Aiming via NumberValue Tween

```lua
self.lerpValues.aim = Instance.new("NumberValue")
local idleOffset = self.viewmodel.offsets.idle.Value
local aimOffset = idleOffset:lerp(self.viewmodel.offsets.aim.Value, self.lerpValues.aim.Value)
```

## Firing Loop

```lua
function handler:fire(tofire)
    self.firing = tofire
    if not tofire then return end
    repeat
        self.canFire = false
        -- Play sound, animation, muzzle flash
        wait(60/self.settings.firing.rpm)
        self.canFire = true
    until not self.firing
end
```

## Recoil via Springs

```lua
local recoil = self.springs.fire:update(deltaTime)
self.camera.CFrame = self.camera.CFrame * CFrame.Angles(recoil.x, recoil.y, recoil.z)
```

## Viewmodel Positioning

```lua
self.viewmodel.rootPart.CFrame = self.camera.CFrame:ToWorldSpace(finalOffset)
```

## Critical Notes

- Multiply all movement by deltaTime for frame-rate independence
- Muzzle flash via :Emit(n) not transparency toggling
- Server security and damage not covered in this tutorial
- Recommends FastCast for projectile handling
