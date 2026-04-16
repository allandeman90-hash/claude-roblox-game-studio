---
title: Workspace
type: service
category: services
subcategory: world
owner: level-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/Workspace.md
related:
  - "[[streaming-enabled]]"
  - "[[Lighting]]"
tags: [roblox-class, world]
---

# Workspace

> The 3D world container. All rendered and physically active objects must be descendants of Workspace. [[Lighting]]

## Summary

Workspace houses all 3D objects that are rendered and physically simulated in the experience. BaseParts, Attachments, Models, Terrain, and the CurrentCamera all live here. Objects not descending from Workspace will not render or participate in physics.

This has practical implications: objects can be removed from Workspace when not needed (e.g., swapping map Models between rounds) and stored in [[ReplicatedStorage]] or [[ServerStorage]]. Objects stored outside Workspace are inactive -- no rendering, no physics, no connections firing.

Workspace inherits from `WorldRoot`, which provides spatial query methods: `Raycast`, `GetPartBoundsInBox`, `GetPartBoundsInRadius`, `GetPartsInPart`, `Blockcast`, `Spherecast`. These are essential for line-of-sight checks, area detection, and projectile systems. Workspace can be accessed via `workspace`, `game.Workspace`, or `game:GetService("Workspace")`.

## API Surface

### Properties (key subset)

- `CurrentCamera: Camera` -- The client's active Camera object.
- `Terrain: Terrain` -- The Terrain object for voxel-based terrain.
- `Gravity: float` -- Gravitational acceleration in studs/sec^2. Default 196.2.
- `StreamingEnabled: boolean` -- Whether instance streaming is active. Allows much larger worlds by only sending nearby content to clients.
- `StreamingMinRadius: number` -- Minimum guaranteed streaming radius in studs.
- `StreamingTargetRadius: number` -- Target streaming radius the engine tries to maintain.
- `StreamingIntegrityMode: Enum.StreamingIntegrityMode` -- How to handle when required instances have not yet streamed in.
- `FallenPartsDestroyHeight: float` -- Y-coordinate below which BaseParts are automatically destroyed.
- `GlobalWind: Vector3` -- Wind direction and strength affecting terrain grass and particles.
- `AirDensity: float` -- Air density for aerodynamic force calculations.
- `DistributedGameTime: double` -- Time in seconds since the game started (read-only, synchronized across server and clients).
- `SignalBehavior: Enum.SignalBehavior` -- Controls signal execution behavior (Default or Deferred).

### Methods (key subset, inherited from WorldRoot)

- `:Raycast(origin: Vector3, direction: Vector3, params: RaycastParams?) -> RaycastResult?` -- Casts a ray and returns hit info. The primary spatial query method.
- `:GetPartBoundsInBox(cframe: CFrame, size: Vector3, overlapParams: OverlapParams?) -> {BasePart}` -- Returns all parts overlapping a box.
- `:GetPartBoundsInRadius(position: Vector3, radius: number, overlapParams: OverlapParams?) -> {BasePart}` -- Returns all parts within a sphere.
- `:GetPartsInPart(part: BasePart, overlapParams: OverlapParams?) -> {BasePart}` -- Returns all parts overlapping a given part.
- `:Blockcast(cframe: CFrame, size: Vector3, direction: Vector3, params: RaycastParams?) -> RaycastResult?` -- Casts a box-shaped ray.
- `:Spherecast(position: Vector3, radius: number, direction: Vector3, params: RaycastParams?) -> RaycastResult?` -- Casts a sphere-shaped ray.

### Events

_No commonly used public events. Use `GetPropertyChangedSignal` for specific property changes._

## Budgets and Limits

- **StreamingEnabled**: When active, clients only receive objects within the streaming radius. Instances outside the radius may not exist on the client. Use `WaitForChild` or handle nil references.
- **FallenPartsDestroyHeight**: Default is -500. Parts falling below this are auto-destroyed.
- **Gravity**: Default 196.2 studs/sec^2. Changing this affects all physics uniformly.
- **Shadow voxels**: 4x4x4 studs. Objects smaller than this produce unrealistic shadows (see [[Lighting]]).

## Common Patterns

### Raycast for line of sight

```lua
local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = { character }
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local result = workspace:Raycast(origin, direction * 100, rayParams)
if result then
    print("Hit:", result.Instance.Name, "at", result.Position)
end
```

### Storing and loading maps

```lua
local ServerStorage = game:GetService("ServerStorage")

-- Remove current map from Workspace
if currentMap then
    currentMap:Destroy()
end

-- Load new map
currentMap = ServerStorage.Maps.Arena:Clone()
currentMap.Parent = workspace
```

## Pitfalls

- **StreamingEnabled**: With streaming on, `workspace:FindFirstChild("DistantPart")` may return nil on the client. Mark critical models as Persistent or use `WaitForChild` with a timeout.
- **Workspace cannot be deleted**: It is a permanent service.
- **FallenPartsDestroyHeight**: Parts (including player characters) falling below this threshold are destroyed. Ensure your game world does not place players below this value.
- **Raycast direction is relative**: The `direction` parameter is a vector from origin, not a target position. Use `(target - origin)` for the direction.

## Related

- [[streaming-enabled]] -- details on instance streaming behavior
- [[Lighting]] -- global lighting and atmosphere

## Sources

- [wiki/raw/roblox-creator-docs/services/Workspace.md](../raw/roblox-creator-docs/services/Workspace.md)
