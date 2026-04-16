---
title: "Camera and Character Movement for Isometric Camera Script"
source_type: devforum-thread
url: https://devforum.roblox.com/t/camera-and-character-movement-for-isometric-camera-script/1517899
captured: 2026-04-15
tags: [camera, isometric, top-down, CFrame.lookAt, OrbitalCamera]
---

# Isometric Camera Scripting

## Problem
Fixed isometric camera at 45-degree angle that follows the player, but loses ability to rotate the camera along the Y-axis. Character needs auto-orientation toward camera perspective.

## Basic Isometric Camera
```lua
local CAMERA_DEPTH = 64
local HEIGHT_OFFSET = 25

local function updateCamera()
    local character = player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local rootPosition = root.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
            local cameraPosition = rootPosition + Vector3.new(CAMERA_DEPTH, CAMERA_DEPTH, CAMERA_DEPTH)
            camera.CFrame = CFrame.lookAt(cameraPosition, rootPosition)
        end
    end
end
```

## Key Parameters
- `CAMERA_DEPTH`: Distance from character (larger = more zoomed out)
- `HEIGHT_OFFSET`: Vertical offset above character
- Camera position is offset equally on X, Y, Z for true isometric angle
- `CFrame.lookAt(from, to)` points camera from position toward target

## Solution for Rotation
Rather than manual Y-axis rotation scripting, the developer found success using Roblox's built-in **OrbitalCamera** module, customized by modifying its `Update()` function. This provides:
- Input handling across keyboard, mouse, controller, and VR
- Orbital rotation around the character
- Greater flexibility than manual implementation

## Character Movement Adaptation
When using isometric/top-down cameras, movement input must be remapped relative to camera direction rather than world axes. The camera's look vector projected onto the ground plane determines "forward" for WASD controls.
