---
title: "PathfindingService + OOP Implementation"
source_url: "https://devforum.roblox.com/t/how-to-use-pathfindingservice-implementing-it-as-oop/3671750"
source_type: devforum-tutorial
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# PathfindingService as OOP Module

Wrapping PathfindingService in a reusable OOP module.

## Module Structure
```lua
local PathService = game:GetService("PathfindingService")

local module = {}
module.__index = module

function module.new(NPC: Model)
    local newThing = setmetatable({}, module)
    newThing.Character = NPC
    newThing.Visualize = false
    newThing.PathFolder = nil
    newThing.CurrentPath = nil
    return newThing
end

return module
```

## SetPath Method
```lua
function module:SetPath(StartPos, EndPos, PathSetting: {})
    local Path = PathService:CreatePath(PathSetting)
    Path:ComputeAsync(StartPos, EndPos)
    self.CurrentPath = Path
    return Path
end
```

## ClearPath Method
```lua
function module:ClearPath()
    if self.StepsFolder then
        self.StepsFolder:Destroy()
    end
    if self.CurrentPath then
        self.CurrentPath:Destroy()
    end
end
```

## FollowPath Method
```lua
function module:FollowPath()
    local Path = self.CurrentPath
    if Path and Path.Status == Enum.PathStatus.Success then
        local Humanoid = self.Character.Humanoid
        local Waypoints = Path:GetWaypoints()
        Waypoints[1] = nil  -- skip starting position

        for i, PathPoint in Waypoints do
            if PathPoint.Action == Enum.PathWaypointAction.Jump then
                Humanoid.Jump = true
            end
            Humanoid:MoveTo(PathPoint.Position)
            if not Humanoid.MoveToFinished:Wait() then
                warn(self.Character.Name, "got stuck somewhere")
                break
            end
        end
        self:ClearPath()
    end
end
```

## Usage
```lua
local AiModule = require(game:GetService("ServerScriptService").AiModule)
local NPC = script.Parent

local AiNPC = AiModule.new(NPC)
AiNPC:SetPath(NPC.HumanoidRootPart.Position, workspace.EndPart.Position)
AiNPC:FollowPath()
```

## Key Features
- Error handling with timeout detection (8s per waypoint)
- Jump automation via waypoint actions
- Memory management (destroys paths and visualization folders)
- Optional debug visualization showing waypoint paths
