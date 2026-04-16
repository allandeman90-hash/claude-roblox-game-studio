---
title: "How to Make a Raycasting Gun"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/how-to-make-a-raycasting-gun/723716
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [raycast, hitscan, gun, damage, server-validation]
---

# How to Make a Raycasting Gun

Tutorial covering modern workspace:Raycast API for hitscan weapon systems.

## Core Raycast

```lua
local origin = shoot_part.Position
local direction = (position - origin).Unit * 300
local result = Workspace:Raycast(origin, direction)
```

## Hit Position Fallback

```lua
local intersection = result and result.Position or origin + direction * 300
```

## Bullet Visualization

```lua
local distance = (origin - intersection).Magnitude
local bullet_clone = ServerStorage.Bullet:Clone()
bullet_clone.Size = Vector3.new(0.1, 0.1, distance)
bullet_clone.CFrame = CFrame.new(origin, intersection) * CFrame.new(0, 0, -distance/2)
```

## Damage Application

```lua
if result then
    local part = result.Instance
    local humanoid = part.Parent:FindFirstChild("Humanoid")
        or part.Parent.Parent:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:TakeDamage(10)
    end
end
```

## Self-Damage Prevention (RaycastParams)

```lua
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances = { player.Character }
local result = Workspace:Raycast(origin, direction, params)
```

## Architecture

- LocalScript captures mouse input via tool.Activated
- Fires RemoteEvent with target position to server Script
- Server performs the raycast and applies damage (server authority)
