---
title: "SimplePath - Pathfinding Module"
source_url: "https://devforum.roblox.com/t/simplepath-pathfinding-module/1196762"
source_type: devforum-resource
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# SimplePath Pathfinding Module

Open-source pathfinding module wrapping Roblox PathfindingService.

## Overview
SimplePath gives you the ability to quickly create pathfinding scripts for humanoids and non-humanoids with just a few lines of code. Uses a "repetitive" pathfinding strategy where paths are recomputed each call for dynamic obstacle handling.

## Constructor
```lua
<Path> SimplePath.new(agent: Model, agentParameters: Dictionary?, override: Dictionary?)
```

## Methods

### Path:Run(target)
```lua
<boolean> Path:Run(target: Vector3 | BasePart)
```
Computes and begins following a path. Returns true on success. Auto-yields if called faster than TIME_VARIANCE.

### Path:Stop()
```lua
<void> Path:Stop()
```
Halts navigation. Humanoid-only. Fires Path.Stopped.

### Path:Destroy()
```lua
<void> Path:Destroy()
```
Cleans up the Path object.

## Events

### Path.Reached
```lua
Path.Reached(agent: Model, finalWaypoint: PathWaypoint)
```

### Path.WaypointReached
```lua
Path.WaypointReached(agent: Model, last: PathWaypoint, next: PathWaypoint)
```

### Path.Blocked
```lua
Path.Blocked(agent: Model, blocked: PathWaypoint)
```

### Path.Error
```lua
Path.Error(error: ErrorType)
```

### Path.Stopped
```lua
Path.Stopped(agent: Model)
```

## Properties
- Visualize: boolean (default false) - show waypoints
- Status: SimplePath.StatusType (read-only)
- LastError: SimplePath.ErrorType (read-only)

## StatusType Enum
- Idle - path inactive
- Active - path computing/navigating

## ErrorType Enum
- LimitReached - TIME_VARIANCE threshold not met
- TargetUnreachable - cannot reach destination
- ComputationError - pathfinding failed
- AgentStuck - agent is stuck due to obstruction

## Settings
- TIME_VARIANCE: 0.07s (minimum time between Run calls)
- COMPARISON_CHECKS: 1 (consecutive stationary checks before avoidance)
- JUMP_WHEN_STUCK: true (humanoid-only)

## Static Methods
```lua
<Model?> SimplePath.GetNearestCharacter(fromPosition: Vector3)
```

## Error Handling
```lua
Path.Error:Connect(function(errorType)
    if errorType == SimplePath.ErrorType.ComputationError then
        -- handle error
    end
end)
```

## Installation
- Roblox Library ID: 6744337775
- GitHub: github.com/grayzcale/simplepath
- Docs: grayzcale.github.io/simplepath
