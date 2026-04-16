---
title: "Gun Sway and Recoil Systems"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/how-does-gun-sway-work-how-would-recoil-work-any-tips-ideas-or-suggestions/641434
related:
  - https://devforum.roblox.com/t/whats-the-best-way-to-make-gun-sway/284153
  - https://devforum.roblox.com/t/recoil-using-springs/1495471
  - https://devforum.roblox.com/t/help-on-understanding-gun-sway-script-with-mathsin/2185564
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [sway, recoil, spring, sine-wave, camera-offset]
---

# Gun Sway and Recoil Systems

Community techniques for implementing weapon sway and recoil in Roblox FPS games.

## Sine Wave Sway

Most common approach -- uses camera delta to compute oscillation:

```lua
local mult = 1
function renderloop()
    local rotation = workspace.CurrentCamera.CFrame:toObjectSpace(lastCameraCF)
    local x, y, z = rotation:ToOrientation()
    swayOffset = swayOffset:Lerp(CFrame.Angles(math.sin(x)*mult, math.sin(y)*mult, 0), 0.1)
    gun.CFrame = gun.CFrame * swayOffset
    lastCameraCF = workspace.CurrentCamera.CFrame
end
```

## Dot Product Approach

- Compute dot product between camera LookVector and gun LookVector
- Lower values = greater rotational offset
- Dot product of 1 = no offset (perfectly aligned)

## Spring-Based Recoil

Springs combined with math.noise for random, realistic recoil patterns:

```lua
local recoil = self.springs.fire:update(deltaTime)
self.camera.CFrame = self.camera.CFrame * CFrame.Angles(recoil.x, recoil.y, recoil.z)
```

## Animation-Based Recoil

```lua
local travel = defaultCameraPartCF:inverse() * currentCameraPartCF
camera.CFrame = referencePointCF * travel
```

## Key Patterns

- Sine waves most commonly used for idle sway
- Spring modules for responsive, physics-based feel
- math.noise for randomized recoil patterns
- TweenService + Motor6D for smooth weapon movement
- Always multiply by deltaTime for frame-rate independence
