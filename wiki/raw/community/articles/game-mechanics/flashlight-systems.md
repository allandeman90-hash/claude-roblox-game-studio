---
title: "First Person Flashlight Systems"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/advanced-flashlight-horror-game/1972508
related:
  - https://devforum.roblox.com/t/first-person-flashlight-effect/2156762
  - https://devforum.roblox.com/t/a-moving-flashlight/2521276
  - https://devforum.roblox.com/t/how-would-i-make-a-fps-flashlight-with-tweening/1928428
  - https://devforum.roblox.com/t/inverse-kinematics-flashlight-horror-game-feedback/2624202
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [flashlight, horror, SpotLight, camera-follow, Motor6D]
---

# First Person Flashlight Systems

Community approaches for first-person flashlight mechanics.

## Advanced Flashlight Module

- Runs entirely client-side (prevents all players seeing each flashlight beam)
- ContextActionService:BindAction() with F key or Button B for toggle
- Boolean state with 1-second debounce
- Humanoid.Died cleanup
- Cross-platform: mobile, console, PC, VR

## Motor6D Arm-Based Flashlight (R6)

Server script rotates Right Shoulder to follow camera Y-axis:

```lua
-- Client: send camera look direction
camera:GetPropertyChangedSignal("CFrame"):Connect(function()
    script.Parent.Event:FireServer(camera.CFrame.LookVector.Y)
end)

-- Server: rotate arm toward look direction
script.Parent.Event.OnServerEvent:Connect(function(player, axis)
    if axis > 1 or axis < -1 then player:Kick("Exploit") return end
    player.Character.Torso["Right Shoulder"].C0 =
        CFrame.new(rightShoulder.C0.Position) *
        CFrame.Angles(0, math.rad(90), math.rad(axis * 60))
end)
```

## First-Person Detection

```lua
local fp = (head.LocalTransparencyModifier == 1)
```

Head transparency modifier == 1 indicates player is in first person view.

## IK Flashlight

- Uses Inverse Kinematics to orient arm toward mouse cursor
- Point-to-mouse flashlight for horror games
- Challenge: replicating mouse movements to other players

## Key Patterns

- Client-side rendering for performance (each player only sees own flashlight)
- Motor6D manipulation for arm rotation
- RunService over while loops for smooth updates
- Anti-cheat validation on server (axis range check)
- Tweening/lerp for smooth delayed movement
