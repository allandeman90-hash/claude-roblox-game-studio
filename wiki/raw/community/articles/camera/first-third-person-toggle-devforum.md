---
title: "Creating First-Person / Third-Person Toggle Camera"
source_type: devforum-thread
url: https://devforum.roblox.com/t/creating-first-person-third-person-toggle-camera/1275196
captured: 2026-04-15
tags: [camera, first-person, third-person, toggle, CameraMode, zoom]
---

# First-Person / Third-Person Toggle Camera

## Initial Setup (First-Person Default)
```lua
Player.CameraMode = Enum.CameraMode.LockFirstPerson
Player:SetAttribute("FirstPerson", true)
```

## Toggle Mechanism
```lua
UserInputService.InputBegan:Connect(function(input, GPE)
    if GPE then return end
    if input.KeyCode == Enum.KeyCode.E then
        SwapCamera()
    end
end)
```

## Third-Person Implementation
When switching to third-person:
- Change to Classic camera mode
- Lock mouse to screen center
- Track rotation angles for camera positioning
- Bind mouse/touch input for player control

## Critical Fix: Camera Distance
Lock zoom to prevent character invisibility:
```lua
Player.CameraMinZoomDistance = 8
Player.CameraMaxZoomDistance = 8
```

## Smooth Updates
Process transforms during render loop, not input events:
```lua
Render = RunService.RenderStepped:Connect(function()
    -- Calculate camera position and rotation
    -- Update character orientation based on camera direction
end)
```

## Return to First-Person
1. Disconnect render connection
2. Restore default mouse behavior
3. Re-enable `Enum.CameraMode.LockFirstPerson`

## Key Camera Properties
- `Player.CameraMode`: LockFirstPerson or Classic
- `Player.CameraMinZoomDistance` / `CameraMaxZoomDistance`: Control zoom range
- `UserInputService.MouseBehavior`: LockCenter, Default, LockCurrentPosition
- `Camera.CameraType`: Custom, Scriptable, Follow, Fixed, etc.
