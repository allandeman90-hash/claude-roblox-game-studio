---
title: "The First Person Element of a First Person Shooter"
author: EgoMoose
source: https://devforum.roblox.com/t/the-first-person-element-of-a-first-person-shooter/160434
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [viewmodel, first-person, ADS, camera, replication, Motor6D]
---

# The First Person Element of a First Person Shooter

Comprehensive tutorial by EgoMoose covering the visual side of FPS games: viewmodel
setup, camera-space arms, ADS (aim down sights), and server replication of tilt.

## Key Concepts

- Viewmodel is a separate rig (arms + weapon) cloned from ReplicatedStorage
- Attached to workspace.CurrentCamera via RenderStepped
- Character body auto-hides in first person (BaseParts become invisible when fully zoomed)
- Motor6D joints connect weapon Handle to viewmodel Head
- ADS uses CFrame:Lerp between hip offset and sight offset
- Server replication of vertical tilt via RemoteEvent (fires every 0.1s, not every frame)
- Motor6D DesiredAngle/CurrentAngle for bandwidth-friendly interpolation

## Code Highlights

### Viewmodel Attachment
```lua
local viewModel = game.ReplicatedStorage:WaitForChild("viewModel"):Clone()
game:GetService("RunService").RenderStepped:Connect(function(dt)
    viewModel.Head.CFrame = camera.CFrame
end)
```

### Weapon Joint
```lua
local joint = Instance.new("Motor6D")
joint.C0 = CFrame.new(1, -1.5, -2)
joint.Part0 = viewModel.Head
joint.Part1 = weapon.Handle
joint.Parent = viewModel.Head
```

### Arm Positioning via Shoulder
```lua
local function updateArm(key)
    local shoulder = viewModel[key.."UpperArm"][key.."Shoulder"]
    local cf = weapon[key].CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.new(0, 1.5, 0)
    shoulder.C1 = cf:inverse() * shoulder.Part0.CFrame * shoulder.C0
end
```

### ADS Transition
```lua
local offset = weapon.Handle.CFrame:inverse() * weapon.Aim.CFrame
local function aimDownSights(aiming)
    local start = joint.C1
    local goal = aiming and joint.C0 * offset or CFrame.new()
    aimCount = aimCount + 1
    local current = aimCount
    for t = 0, 101, 10 do
        if current ~= aimCount then break end
        game:GetService("RunService").RenderStepped:Wait()
        joint.C1 = start:Lerp(goal, t/100)
    end
end
```

### Server Tilt Replication
```lua
-- Server
remoteEvents.tiltAt.OnServerEvent:Connect(function(player, theta)
    local neck = player.Character.Head.Neck
    local waist = player.Character.UpperTorso.Waist
    neck.C0 = neckC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0)
    waist.C0 = waistC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0)
end)
```
