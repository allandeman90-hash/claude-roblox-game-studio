---
title: "General Combat NPC Tutorial"
source_url: "https://devforum.roblox.com/t/general-combat-npc-tutorial/1862031"
source_type: devforum-tutorial
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# General Combat NPC Tutorial

Covers fighting NPCs with pathfinding and attack mechanics.

## Target Detection and Selection
- Scans all players within maxDistance (100 studs default)
- Identifies closest valid target
- Checks if target is alive before engaging

```lua
if (playerRoot.Position - HRP.Position).Magnitude <= maxDistance then
    -- pursue
end
```

## Attack Range System
```lua
if (playerRoot.Position - HRP.Position).Magnitude <= attackRange then
    -- attackRange default: 5 studs
    AttackEvent:Fire()
end
```

## State Management (continuous loop)
1. Dead detection - stops pursuit if target dies
2. Attack range - fires AttackEvent when close enough
3. Chase range - computes path and moves toward target

## Attack Implementation
Uses BindableEvent pattern:
- AttackEvent:Fire() triggered by proximity
- Weapon script listens: AttackEvent.Event:Connect(Attack)

## Performance Optimization
- Single controller script managing all NPCs (not one script per NPC)
- Use SimplePath module for smoother pathfinding
- Consider client-side NPC logic for high-NPC-count scenarios
