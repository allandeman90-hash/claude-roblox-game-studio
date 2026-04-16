---
title: Model
type: service
category: services
subcategory: world
owner: luau-gameplay-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources: [wiki/raw/roblox-creator-docs/services/Model.md]
related:
  - "[[Instance]]"
  - "[[BasePart]]"
  - "[[Part]]"
  - "[[Humanoid]]"
  - "[[Motor6D]]"
tags: [roblox-class, model, grouping, hierarchy]
---

# Model

> Container for geometric groupings of BaseParts, used for characters, vehicles, NPCs, and structural objects. [[BasePart]] [[Humanoid]]

## Summary

Model is a container that groups BaseParts and other objects together as a logical unit. It is intended for geometric groupings -- objects that have a physical presence in the world. For non-geometric groupings (collections of scripts, values), use Folder instead.

Models are central to Roblox development: every player Character is a Model containing a Humanoid, HumanoidRootPart, Head, and body parts joined by Motor6D constraints. NPCs, vehicles, destructible objects, and interactive props are all typically Models.

When a Model contains physics-joined parts (via WeldConstraint or Motor6D), setting PrimaryPart ensures the Model's pivot follows the correct part during physics simulation. Static models that never move do not need a PrimaryPart.

## API Surface

### Properties
- `PrimaryPart: BasePart?` -- The part that the model's pivot follows during physics. Must be a descendant of the model
- `ModelStreamingMode: Enum.ModelStreamingMode` -- Controls streaming behavior when StreamingEnabled is true (Default, Atomic, Persistent, PersistentPerPlayer, Nonatomic)
- `LevelOfDetail: Enum.ModelLevelOfDetail` -- Controls LOD rendering for streamed models (Disabled, Automatic, StreamingMesh, SLIM)
- `WorldPivot: CFrame` -- The world-space pivot of the model (used by PivotTo)

### Methods
- `:PivotTo(cframe: CFrame) -> ()` -- Moves the entire model so its pivot matches the given CFrame. Preferred over SetPrimaryPartCFrame (deprecated)
- `:GetPivot() -> CFrame` -- Returns the current pivot CFrame
- `:GetBoundingBox() -> (CFrame, Vector3)` -- Returns the oriented bounding box (center CFrame and size)
- `:GetExtentsSize() -> Vector3` -- Returns the axis-aligned bounding box size
- `:ScaleTo(scale: number) -> ()` -- Scales the model and its descendants
- `:GetScale() -> number` -- Returns the current scale factor
- `:MoveTo(position: Vector3) -> ()` -- Moves the model to a position, placing it on top of any object at that location
- `:AddPersistentPlayer(player: Player) -> ()` -- Makes the model persistent for a specific player (streaming)
- `:RemovePersistentPlayer(player: Player) -> ()` -- Removes per-player persistence

### Events

No events unique to Model. Inherited from [[Instance]] (ChildAdded, DescendantAdded, etc.).

## Budgets and Limits

- **Streaming atomicity**: With ModelStreamingMode = Atomic, the entire model and all descendants are guaranteed to be present if the model itself is on the client. This can increase memory usage for large models.
- **PrimaryPart must be a descendant**: Setting PrimaryPart to a BasePart outside the model tree will auto-reset to nil on the next simulation step.
- **FallenPartsDestroyHeight**: If the last part in a Model falls below this Y threshold, the entire Model is destroyed.

## Common Patterns

### Moving a model with PivotTo

```lua
-- Move an NPC model to a new position
local npcModel = workspace.NPCModel
npcModel:PivotTo(CFrame.new(10, 5, 20))
```

### Character model structure

```
Character (Model)
  HumanoidRootPart (Part) -- PrimaryPart
  Head (Part)
  Humanoid (Humanoid)
  UpperTorso, LowerTorso, etc.
  Motor6D joints connecting all parts
```

### Streaming-safe model access

```lua
-- With StreamingEnabled, model contents may not be loaded on client
local model = workspace:WaitForChild("ImportantModel")
-- If ModelStreamingMode is not Atomic, individual children may be missing
local core = model:WaitForChild("CorePart", 10)
```

## Pitfalls

- **SetPrimaryPartCFrame is deprecated**: Use `PivotTo()` instead. SetPrimaryPartCFrame is slower and has known issues with welded assemblies.
- **PrimaryPart not set by default**: New Models do not have PrimaryPart set. Physics-joined models that move need it set manually.
- **Streaming and atomicity**: Without Atomic streaming mode, a Model may exist on the client while some of its children do not. Always use WaitForChild on the client or set Atomic mode for critical models.
- **MoveTo places on top of geometry**: MoveTo does a raycast downward and places the model on top of whatever is there. It is not a simple teleport -- use PivotTo for precise placement.
- **Name-based character detection**: Roblox displays a name/health GUI when a Model contains both a Humanoid and a Part named "Head". This is an implicit behavior that can trigger unexpectedly on NPC models.

## Related

- [[Instance]] -- base class
- [[BasePart]] -- the parts that Models contain
- [[Part]] -- most common part type inside Models
- [[Humanoid]] -- the character controller inside player/NPC Models
- [[Motor6D]] -- joint type that connects character limbs

## Sources

- [Roblox Creator Docs](wiki/raw/roblox-creator-docs/services/Model.md)
