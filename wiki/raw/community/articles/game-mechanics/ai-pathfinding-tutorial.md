---
title: "How You Can Use AI Pathfinding"
source_url: "https://devforum.roblox.com/t/how-you-can-use-ai-pathfinding/570721"
source_type: devforum-tutorial
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# AI Pathfinding Tutorial

Core pathfinding tutorial covering PathfindingService basics.

## Setup
```lua
local pathfindingService = game:GetService("PathfindingService")
local NPC = script.Parent
local humanoid = NPC.Humanoid
local HumanoidRootPart = NPC.HumanoidRootPart
local NPCpath = pathfindingService:CreatePath()
```

## Computing path
```lua
NPCpath:ComputeAsync(HumanoidRootPart.Position, game.Workspace.EndingPart.Position)
```

## Following waypoints with state handling
```lua
local wayPoints = path:GetWaypoints()

for i, wayPoint in pairs(wayPoints) do
   if wayPoint.Action == Enum.PathWaypointAction.Jump then
      humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
   end
   if wayPoint.Action == Enum.PathWaypointAction.Walk then
      humanoid:ChangeState(Enum.HumanoidStateType.Walk)
   end
   humanoid:MoveTo(wayPoint.Position)
   humanoid.MoveToFinished:Wait()
end
```

Key point: PathfindingService functions as "a brain for an NPC" enabling navigation around obstacles.
