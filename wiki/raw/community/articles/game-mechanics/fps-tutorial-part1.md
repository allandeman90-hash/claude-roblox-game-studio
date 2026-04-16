---
title: "FPS Tutorial Part 1"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/fps-tutorial-part-1/1013047
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [fps, tutorial, viewmodel, weapon-config, camera-attachment]
---

# FPS Tutorial Part 1

Basic FPS tutorial covering viewmodel setup and camera attachment.

## Setup Code

```lua
repeat wait() until game:IsLoaded()

local plr = game.Players.LocalPlayer
local char = plr.Character
local mouse = plr:GetMouse()
local cam = workspace.CurrentCamera
local runs = game:GetService("RunService")
local rs = game.ReplicatedStorage
local gunmodels = rs:WaitForChild("models")
local gunmodules = rs:WaitForChild("modules")

local primary = "m4"
local currentweapon
local maincf = CFrame.new()
```

## Weapon Setup

```lua
function setup(weapon)
    weaponmodule = require(gunmodules:WaitForChild(primary))
    maincf = weaponmodule.maincf
    currentweapon = gunmodels:WaitForChild(primary):Clone()
    currentweapon.Parent = cam
end
```

## Camera Sync

```lua
runs.RenderStepped:Connect(function()
    if currentweapon then
        currentweapon:SetPrimaryPartCFrame(cam.CFrame * maincf)
    end
end)
```

## Weapon Module Config

```lua
local settings = {}
settings.maincf = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
return settings
```

## Notes

- Weapons parented to workspace.Camera
- Module script stores per-weapon offsets
- Frame-rate independent via RenderStepped
