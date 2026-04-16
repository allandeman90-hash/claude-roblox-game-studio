---
title: "How To Use Roblox Pathfinding Service 2.0"
source_url: "https://devforum.roblox.com/t/how-to-use-roblox-pathfinding-service-20/1857779"
source_type: devforum-tutorial
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# PathfindingService 2.0 Tutorial

Comprehensive guide covering PathfindingService with error handling, agent parameters, modifiers, and costs.

## Core Setup
```lua
local PathfindingService = game:GetService("PathfindingService")
local MAX_RETRIES = 5
local RETRY_COOLDOWN = 5
local YIELDING = false

local model = script.Parent
local humanoid = model.Humanoid
local humanoidRootPart = model.HumanoidRootPart

local path = PathfindingService:CreatePath()
local reachedConnection
local pathBlockedConnection
```

## walkTo Function with Retry Logic
```lua
local function walkTo(targetPosition, yieldable)
    local RETRY_NUM = 0
    local success, errorMessage
    repeat
        RETRY_NUM += 1
        success, errorMessage = pcall(path.ComputeAsync, path,
            humanoidRootPart.Position, targetPosition)
        if not success then
            warn("Pathfind compute path error: "..errorMessage)
            task.wait(RETRY_COOLDOWN)
        end
    until success == true or RETRY_NUM > MAX_RETRIES
end
```

## Waypoint Processing
```lua
if path.Status == Enum.PathStatus.Success then
    local waypoints = path:GetWaypoints()
    local currentWaypointIndex = 2  -- index 1 is starting position
    humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
    if waypoints[currentWaypointIndex].Action == Enum.PathWaypointAction.Jump then
        humanoid.Jump = true
    end
end
```

## MoveToFinished Event Connection
```lua
reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
    if reached and currentWaypointIndex < #waypoints then
        currentWaypointIndex += 1
        humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
        if waypoints[currentWaypointIndex].Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
    else
        reachedConnection:Disconnect()
        pathBlockedConnection:Disconnect()
        reachedConnection = nil
        pathBlockedConnection = nil
        YIELDING = false
    end
end)
```

## Blocked Path Handling
```lua
pathBlockedConnection = path.Blocked:Connect(function(waypointNumber)
    if waypointNumber > currentWaypointIndex then
        reachedConnection:Disconnect()
        pathBlockedConnection:Disconnect()
        reachedConnection = nil
        pathBlockedConnection = nil
        walkTo(workspace.EndGoal.Position, true)
    end
end)
```

## Agent Parameters
```lua
local AGENT_PARAMETERS = {
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = true,
    AgentCanClimb = false,
    WaypointSpacing = 4,
    Costs = {
        Metal = 0.1  -- prefer metal surfaces (< 1 attracts)
    }
}
local path = PathfindingService:CreatePath(AGENT_PARAMETERS)
```

## Cost Multipliers
- Values under 1 attract paths to that surface/label
- Values over 1 repel paths
- math.huge means never traverse
- A 30-stud path with cost 10 = 300 total vs 100-stud path with cost 2 = 200

## PathfindingModifier
- Requires parts with CanCollide = false, transparency enabled, CanQuery = true
- CanQuery is critical but undocumented

## PathfindingLink
1. Create two Attachments in parts
2. Add PathfindingLink with Label property
3. Connect Attachment0 and Attachment1
4. Set IsBidirectional = true if needed

## Special Waypoint Handling
```lua
local SPECIAL_WAYPOINTS = {
    JumpGap = function(model, waypoints, currentWaypointIndex)
        local humanoid = model:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.Jump = true
            humanoid:MoveTo(waypoints[currentWaypointIndex + 1].Position)
        end
    end,
}
```

Key takeaways:
- Always start at waypoint index 2 (index 1 is starting position)
- Use pcall for ComputeAsync
- Always disconnect events and nil connections to prevent memory leaks
- Use event connections, not for-loops, for waypoint traversal
