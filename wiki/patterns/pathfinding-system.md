---
title: Pathfinding System
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/pathfinding-service-2.md
  - wiki/raw/community/articles/game-mechanics/ai-pathfinding-tutorial.md
  - wiki/raw/community/articles/game-mechanics/simplepath-module.md
  - wiki/raw/community/articles/game-mechanics/pathfinding-oop-module.md
  - wiki/raw/community/articles/game-mechanics/simple-pathfinding-ai.md
related:
  - "[[npc-ai-system]]"
  - "[[behavior-trees]]"
  - "[[boss-patterns]]"
  - "[[state-machine-pattern]]"
tags:
  - pathfinding
  - npc
  - navigation
  - simplepath
---

# Pathfinding System

> PathfindingService-based navigation for NPCs: path creation, agent parameters, waypoint following, blocked-path recovery, and the SimplePath library.

## Summary

PathfindingService is the built-in Roblox service that computes navigation paths through the 3D world. It creates a navigation mesh from the game geometry and returns a series of waypoints an NPC can follow via `Humanoid:MoveTo()`. The core workflow is: create a path with agent parameters, call `ComputeAsync` between two points, iterate waypoints, handle jumps, and react to blocked paths. The SimplePath open-source module wraps this into a higher-level API with automatic recomputation and stuck detection.

## Implementation

### Basic PathfindingService Usage

```lua
local PathfindingService = game:GetService("PathfindingService")

local npc = script.Parent
local humanoid: Humanoid = npc.Humanoid
local rootPart: BasePart = npc.HumanoidRootPart

-- Agent parameters describe the NPC's physical dimensions
local AGENT_PARAMS = {
    AgentRadius = 2,          -- half-width in studs (default 2)
    AgentHeight = 5,          -- height in studs (default 5)
    AgentCanJump = true,      -- allow jump waypoints
    AgentCanClimb = false,    -- allow truss climbing
    WaypointSpacing = 4,      -- min spacing between waypoints in studs
    Costs = {},               -- material/label cost overrides
}

local path = PathfindingService:CreatePath(AGENT_PARAMS)
```

### Computing and Following a Path

```lua
local MAX_RETRIES = 5
local RETRY_COOLDOWN = 2

local reachedConnection: RBXScriptConnection? = nil
local blockedConnection: RBXScriptConnection? = nil

local function walkTo(targetPosition: Vector3)
    -- Retry loop for transient failures
    local success, errorMessage
    for attempt = 1, MAX_RETRIES do
        success, errorMessage = pcall(path.ComputeAsync, path,
            rootPart.Position, targetPosition)
        if success then break end
        warn("Path compute error (attempt " .. attempt .. "): " .. errorMessage)
        task.wait(RETRY_COOLDOWN)
    end

    if not success then
        warn("Path computation failed after retries: " .. tostring(errorMessage))
        return
    end

    if path.Status ~= Enum.PathStatus.Success then
        return -- no valid path exists
    end

    local waypoints = path:GetWaypoints()
    -- Index 1 is the starting position; begin at index 2
    local currentIndex = 2

    -- Clean up previous connections
    if reachedConnection then reachedConnection:Disconnect() end
    if blockedConnection then blockedConnection:Disconnect() end

    -- Handle reaching each waypoint
    reachedConnection = humanoid.MoveToFinished:Connect(function(reached: boolean)
        if reached and currentIndex < #waypoints then
            currentIndex += 1
            humanoid:MoveTo(waypoints[currentIndex].Position)

            if waypoints[currentIndex].Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
        else
            -- Reached destination or got stuck
            if reachedConnection then reachedConnection:Disconnect() end
            if blockedConnection then blockedConnection:Disconnect() end
            reachedConnection = nil
            blockedConnection = nil
        end
    end)

    -- Handle path becoming blocked mid-traversal
    blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex: number)
        if blockedWaypointIndex > currentIndex then
            -- Blocked waypoint is ahead; recompute
            if reachedConnection then reachedConnection:Disconnect() end
            if blockedConnection then blockedConnection:Disconnect() end
            reachedConnection = nil
            blockedConnection = nil
            walkTo(targetPosition)
        end
    end)

    -- Start moving
    humanoid:MoveTo(waypoints[currentIndex].Position)
    if waypoints[currentIndex].Action == Enum.PathWaypointAction.Jump then
        humanoid.Jump = true
    end
end
```

### Agent Parameter Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `AgentRadius` | number | 2 | Half-width of the agent. Path avoids gaps narrower than `AgentRadius * 2`. Separation from walls = `AgentRadius - 2`. |
| `AgentHeight` | number | 5 | Agent height in studs. Path avoids tunnels shorter than this. |
| `AgentCanJump` | boolean | true | Whether the path may include jump waypoints. |
| `AgentCanClimb` | boolean | false | Whether the path may include truss-climbing segments. |
| `WaypointSpacing` | number | 4 | Minimum distance between consecutive waypoints. |
| `Costs` | dictionary | {} | Material or label cost overrides. Values < 1 attract; > 1 repel; `math.huge` blocks. |

### Cost System

Costs weight how expensive a surface or labeled region is to traverse. PathfindingService multiplies the path length through a region by its cost.

```lua
local AGENT_PARAMS = {
    Costs = {
        Grass = 10,            -- strongly avoid grass
        Metal = 0.1,           -- prefer metal walkways
        Water = math.huge,     -- never path through water
        DangerZone = 50,       -- avoid labeled danger zones
    }
}
```

A 30-stud path with cost 10 = 300 effective distance, while a 100-stud path with cost 2 = 200 effective distance. The pathfinder picks the lower effective cost, so it routes through the longer but cheaper path.

### PathfindingModifier

Attach a `PathfindingModifier` to a transparent, non-collidable part to define a named region with a custom cost. Critical requirement: set `CanQuery = true` on the part (undocumented but necessary).

```
Part (CanCollide=false, Transparency=1, CanQuery=true)
  └── PathfindingModifier (Label = "DangerZone")
```

Then reference the label in Costs:

```lua
Costs = { DangerZone = math.huge }
```

### PathfindingLink

For special traversal like jumping gaps or opening doors, use PathfindingLink:

1. Create two Attachments in the parts on either side of the gap
2. Add a PathfindingLink instance
3. Set its `Label` property (e.g., "JumpGap")
4. Connect `Attachment0` and `Attachment1`
5. Set `IsBidirectional = true` if the link works both ways

Handle the labeled waypoint in code:

```lua
local SPECIAL_WAYPOINTS = {
    JumpGap = function(model: Model, waypoints, currentIndex: number)
        local humanoid = model:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.Jump = true
            -- Move to the waypoint AFTER the link
            humanoid:MoveTo(waypoints[currentIndex + 1].Position)
        end
    end,
}

-- In the waypoint loop:
local label = waypoints[currentIndex].Label
if SPECIAL_WAYPOINTS[label] then
    SPECIAL_WAYPOINTS[label](npc, waypoints, currentIndex)
else
    humanoid:MoveTo(waypoints[currentIndex].Position)
end
```

## Variants

### SimplePath Module

SimplePath wraps PathfindingService into a higher-level API with automatic recomputation and error handling.

**Installation**: Roblox Library ID `6744337775` or GitHub `grayzcale/simplepath`.

```lua
local SimplePath = require(game.ServerStorage.SimplePath)

local npcPath = SimplePath.new(npc, {
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = true,
})

-- Optional: visualize waypoints during development
npcPath.Visualize = true

-- Run pathfinding (auto-recomputes on each call)
npcPath:Run(targetPart)

-- Events
npcPath.Reached:Connect(function(agent, finalWaypoint)
    -- Arrived at destination
end)

npcPath.WaypointReached:Connect(function(agent, lastWaypoint, nextWaypoint)
    -- Progress callback; useful for non-humanoid movement
end)

npcPath.Blocked:Connect(function(agent, blockedWaypoint)
    -- Path obstructed; SimplePath auto-recomputes
end)

npcPath.Error:Connect(function(errorType)
    if errorType == SimplePath.ErrorType.TargetUnreachable then
        -- Destination is not reachable
    elseif errorType == SimplePath.ErrorType.AgentStuck then
        -- NPC is stuck (JUMP_WHEN_STUCK setting may help)
    end
end)

-- Stop and cleanup
npcPath:Stop()
npcPath:Destroy()
```

**SimplePath Settings**:
- `TIME_VARIANCE`: 0.07s minimum between `Run()` calls
- `COMPARISON_CHECKS`: 1 consecutive stationary check before avoidance
- `JUMP_WHEN_STUCK`: true (attempts jump when stuck; humanoid only)

**Static utility**:
```lua
local nearest: Model? = SimplePath.GetNearestCharacter(npc.HumanoidRootPart.Position)
```

### OOP Wrapper Module

Encapsulate PathfindingService in a reusable class for cleaner multi-NPC management.

```lua
local PathService = game:GetService("PathfindingService")

local AiModule = {}
AiModule.__index = AiModule

function AiModule.new(npc: Model)
    return setmetatable({
        Character = npc,
        Visualize = false,
        CurrentPath = nil,
    }, AiModule)
end

function AiModule:SetPath(startPos: Vector3, endPos: Vector3, params: {}?)
    local path = PathService:CreatePath(params or {})
    path:ComputeAsync(startPos, endPos)
    self.CurrentPath = path
    return path
end

function AiModule:FollowPath()
    local path = self.CurrentPath
    if not path or path.Status ~= Enum.PathStatus.Success then return end

    local humanoid: Humanoid = self.Character.Humanoid
    local waypoints = path:GetWaypoints()

    for i = 2, #waypoints do
        if waypoints[i].Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid:MoveTo(waypoints[i].Position)
        if not humanoid.MoveToFinished:Wait() then
            warn(self.Character.Name .. " got stuck")
            break
        end
    end
end

function AiModule:ClearPath()
    if self.CurrentPath then
        self.CurrentPath:Destroy()
        self.CurrentPath = nil
    end
end

return AiModule
```

### Patrol System

Cycle through a set of waypoint parts in the workspace.

```lua
local waypointParts = workspace.PatrolWaypoints:GetChildren()

local function patrol(brain)
    local currentWaypointIndex = 1

    while brain.state == "patrol" do
        local target = waypointParts[currentWaypointIndex]
        walkTo(target.Position)

        -- Wait until arrival or state change
        humanoid.MoveToFinished:Wait()

        currentWaypointIndex = (currentWaypointIndex % #waypointParts) + 1
        task.wait(1) -- pause at each waypoint
    end
end
```

## Pitfalls

1. **Starting at waypoint index 1**: The first waypoint returned by `GetWaypoints()` is the starting position, not the first destination. Always begin iteration at index 2.

2. **Using for-loops for waypoint traversal**: A for-loop with `MoveToFinished:Wait()` blocks the entire thread and cannot respond to path changes or target movement. Use event connections (`MoveToFinished:Connect`) with an index counter for responsive pathfinding.

3. **No pcall around ComputeAsync**: `ComputeAsync` can throw on invalid geometry or server load. Always wrap in `pcall` with retry logic.

4. **Forgetting to disconnect events**: Stale `MoveToFinished` and `path.Blocked` connections cause memory leaks and ghost behavior. Disconnect and nil every connection when pathfinding ends.

5. **Heartbeat-driven path calls**: Calling `ComputeAsync` every frame overloads the pathfinding budget. Recompute at most every 0.1-0.5 seconds.

6. **Ignoring PathStatus**: After `ComputeAsync`, check `path.Status == Enum.PathStatus.Success`. A `NoPath` status means the destination is unreachable with the given agent parameters.

7. **CanQuery not set on modifier parts**: PathfindingModifier parts require `CanQuery = true` to function. This is an undocumented but critical requirement.

8. **Wall-hugging**: If `AgentRadius` is too small, the NPC hugs walls. Increase `AgentRadius` to push paths further from obstacles.

## Related

- [[npc-ai-system]] -- Full NPC brain using pathfinding
- [[behavior-trees]] -- Complex AI decision-making
- [[boss-patterns]] -- Boss movement and phase transitions
- [[state-machine-pattern]] -- FSM driving pathfinding decisions

## Sources

- [PathfindingService 2.0 Tutorial](wiki/raw/community/articles/game-mechanics/pathfinding-service-2.md)
- [AI Pathfinding Tutorial](wiki/raw/community/articles/game-mechanics/ai-pathfinding-tutorial.md)
- [SimplePath Module](wiki/raw/community/articles/game-mechanics/simplepath-module.md)
- [PathfindingService OOP Module](wiki/raw/community/articles/game-mechanics/pathfinding-oop-module.md)
- [Simple Pathfinding AI](wiki/raw/community/articles/game-mechanics/simple-pathfinding-ai.md)
- [DevForum: PathfindingService 2.0](https://devforum.roblox.com/t/how-to-use-roblox-pathfinding-service-20/1857779)
- [DevForum: SimplePath Module](https://devforum.roblox.com/t/simplepath-pathfinding-module/1196762)
- [SimplePath Docs](https://grayzcale.github.io/simplepath/)
- [SimplePath GitHub](https://github.com/grayzcale/simplepath)
