---
title: "Simple, Non-Invasive Third-Person Camera System"
source_type: devforum-resource
url: https://devforum.roblox.com/t/simple-non-invasive-third-person-camera-system/2743159
captured: 2026-04-15
tags: [camera, third-person, over-the-shoulder, spring-physics, CameraOffset, collision]
---

# Non-Invasive Third-Person Camera System

## Overview
An OOP camera module providing over-the-shoulder third-person view using `Humanoid.CameraOffset` combined with spring physics and vector math. Non-invasive: does not replace Roblox's default camera, works alongside it.

## Core Features

- **Non-invasive**: Uses `Humanoid.CameraOffset` instead of replacing camera system
- **Smart offset**: Vector cross and dot products determine positioning based on camera-character angle
- **Dynamic X-offset**: Horizontal offset adjusts based on vertical camera angle (centers when looking up/down)
- **Collision handling**: Camera moves closer to character when obstructed (works with invisicam)
- **Smooth motion**: Spring implementation reduces stutter and motion sickness
- **Mouse locking**: Centers mouse on-screen by default (removable)

## Setup
```lua
-- LocalScript in ReplicatedFirst
local ThirdPersonCamera = require(ReplicatedFirst.ThirdPersonCamera)

local function CharacterAdded(Character)
    local Camera = ThirdPersonCamera.new(Character)
    Character:WaitForChild("Humanoid").Died:Once(function()
        Camera:Destroy()
    end)
end

Player.CharacterAdded:Connect(CharacterAdded)
```

## API
- `:Enable()` / `:Disable()` -- Toggle on/off
- `:Destroy()` -- Clean up and reset to default

## Configuration
- `OFFSET` constant controls camera distance
- Mouse locking: remove `UserInputService.MouseBehavior` lines
- Compatible with any rig type (R6, R15, custom rigs)

## Bug Fix
When disabling, add `self.Humanoid.CameraOffset = Vector3.zero` to reset view properly.
