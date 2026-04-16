---
title: "Simple Pathfinding AI"
source_url: "https://devforum.roblox.com/t/simple-pathfinding-ai/1815347"
source_type: devforum-tutorial
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# Simple Pathfinding AI

Basic pathfinding AI with player detection and chasing.

## Setup
```lua
local npc = script.Parent
local human = npc.Humanoid
local PFS = game:GetService("PathfindingService")
local RUNSERVICE = game:GetService("RunService")

npc.PrimaryPart:SetNetworkOwner(nil)
```

## Player Detection (Nearest Target)
```lua
local function findTarget()
    local players = game:GetService("Players"):GetPlayers()
    local nearesttarget
    local maxDistance = 5000

    for i, player in pairs(players) do
        if player.Character then
            local target = player.Character
            local distance = (npc.HumanoidRootPart.Position
                - target:WaitForChild("HumanoidRootPart").Position).Magnitude
            if distance < maxDistance then
                nearesttarget = target
                maxDistance = distance
            end
        end
    end
    return nearesttarget
end
```

## Pathfinding
```lua
local function getPath(destination)
    local path = PFS:CreatePath()
    path:ComputeAsync(npc.HumanoidRootPart.Position, destination)
    return path
end
```

## Waypoint Following
```lua
local function pathFindTo(destination)
    local path = getPath(destination)
    local target = findTarget()

    if target and target.Humanoid.Health > 0 then
        for i, waypoint in pairs(path:GetWaypoints()) do
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                human.Jump = true
            end
            human:MoveTo(waypoint.Position)
            human.MoveToFinished:Wait()
        end
    end
end
```

## Main Loop (corrected per community feedback)
```lua
-- Original used Heartbeat (creates thread every frame - BAD)
-- Corrected version:
while true do
    local target = findTarget()
    if target then
        pathFindTo(target:WaitForChild("HumanoidRootPart").Position
            + (target:WaitForChild("HumanoidRootPart").Velocity.Unit * 7))
    end
    task.wait(0.1)
end
```

## Key Tip
SetNetworkOwner(nil) keeps NPC movement server-authoritative.
Using while-loop instead of Heartbeat prevents thread pile-up.
