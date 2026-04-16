---
title: "Pet Follow System Approaches"
captured_by: mechanics-genres
source: https://devforum.roblox.com/t/how-do-i-make-pet-follow-system/3308281
captured_date: 2026-04-15
type: devforum-discussion
---

# Pet Follow System

## Approaches

### CFrame Lerping
- PetMesh.CFrame:Lerp() with 0.15 alpha
- Server-side causes jittering; must run on client

### MoveTo with Humanoid
- Custom rig with Humanoid component
- humanoid:MoveTo() for pathfinding
- Teleport pet if too far away
- 8 second timeout limit on MoveTo

### Positioning Relative to Player
- HumanoidRootPart.CFrame:PointToWorldSpace(PetPosition)
- Multiple pets: Vector3.new(2,0,10) and Vector3.new(-2,0,10)

## Key Consensus
"Lerp/tween on the server is just straight laggy."
Run movement on client via LocalScript, replicate visually to other players.
