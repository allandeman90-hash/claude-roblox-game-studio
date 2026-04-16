---
title: Part
type: service
category: services
subcategory: world
owner: luau-gameplay-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources: [wiki/raw/roblox-creator-docs/services/Part.md]
related:
  - "[[BasePart]]"
  - "[[MeshPart]]"
  - "[[Model]]"
  - "[[Instance]]"
tags: [roblox-class, parts, 3d, building]
---

# Part

> The most common BasePart subclass, providing five primitive shapes: Ball, Block, Cylinder, Wedge, and CornerWedge. [[BasePart]]

## Summary

Part is the default building block in Roblox. It is a concrete implementation of BasePart that renders as one of five primitive shapes controlled by the Shape property. Part inherits all of BasePart's physics, collision, appearance, and positioning API.

For simple geometry -- walls, floors, platforms, projectiles, hitboxes -- Part is the standard choice. For custom-shaped objects, use MeshPart instead. Part has the advantage of exact collision geometry for Ball, Block, and Wedge shapes, whereas MeshPart uses approximate collision hulls.

Part is created with `Instance.new("Part")` and placed in workspace. It is the most frequently created instance in most Roblox games.

## API Surface

### Properties
- `Shape: Enum.PartType` -- Ball, Block (default), Cylinder, Wedge, CornerWedge

All other properties (Anchored, CFrame, Size, Color, Material, Transparency, CanCollide, etc.) are inherited from [[BasePart]].

### Methods

No methods unique to Part. All methods are inherited from [[BasePart]] and [[Instance]].

### Events

No events unique to Part. Touched, TouchEnded are inherited from [[BasePart]].

## Budgets and Limits

- **Collision precision**: Ball, Block, Wedge, and CornerWedge have exact collision. Cylinder collisions are approximated.
- **Part count**: Keep visible part count reasonable for target platform. See [[BasePart]] budgets.

## Common Patterns

### Creating a part via script

```lua
local part = Instance.new("Part")
part.Shape = Enum.PartType.Block
part.Size = Vector3.new(4, 1, 4)
part.Position = Vector3.new(0, 10, 0)
part.Anchored = true
part.Parent = workspace
```

### Spherical projectile

```lua
local projectile = Instance.new("Part")
projectile.Shape = Enum.PartType.Ball
projectile.Size = Vector3.new(1, 1, 1)
projectile.CFrame = spawnCFrame
projectile.Anchored = false
projectile.CanCollide = true
projectile.Parent = workspace

-- Apply velocity
projectile.AssemblyLinearVelocity = direction * speed
```

## Pitfalls

- **Cylinder collision is approximate**: Unlike Ball and Block, Cylinder uses a convex hull approximation. For precise cylindrical collision, consider alternative approaches.
- **Shape changes reset size**: Changing Shape can alter how the Size property maps to visual dimensions (e.g., Ball uses all three axes equally as diameter).
- **Prefer MeshPart for complex shapes**: Part only supports 5 primitives. Do not try to approximate complex shapes by combining many Parts when a single MeshPart would work.

## Related

- [[BasePart]] -- parent class providing all physics and spatial properties
- [[MeshPart]] -- alternative for custom mesh geometry
- [[Model]] -- container for grouping multiple parts
- [[Instance]] -- root of the class hierarchy

## Sources

- [Roblox Creator Docs](wiki/raw/roblox-creator-docs/services/Part.md)
