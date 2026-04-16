---
title: "Enemy AI System with SimplePath"
source_url: "https://devforum.roblox.com/t/enemy-ai-system/1839720"
source_type: devforum-discussion
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# Enemy AI System Design with SimplePath

State machine enemy AI using SimplePath module.

## States
- Roaming: random points within designated zone
- Following: pursues detected player
- Attacking: engages when within damage range

## Detection Mechanics
- Player Detection Range: 25 studs
- Damage Range: 3 studs

```lua
(closestPlayer.PrimaryPart.Position - self.Instance.PrimaryPart.Position).Magnitude
```

## Pathfinding Setup
```lua
local pathParams = {
    ["AgentHeight"] = size.Y,
    ["AgentRadius"] = size.X / 2,
    ["AgentCanJump"] = false,
}
self.path = SimplePath.new(self.Instance, pathParams)
```

## Event-Driven State Transitions
- WaypointReached: check for players mid-journey
- Reached: evaluate player detection at destination
- Blocked: reset to roaming if path obstructed

## Limitations
- No explicit attack cooldown
- Recursive Attack() without delay can cause performance issues
