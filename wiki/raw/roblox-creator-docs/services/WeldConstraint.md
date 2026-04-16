---
title: WeldConstraint
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/WeldConstraint
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/WeldConstraint.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: physics
tags: [roblox-class, weld, constraints, joining]
---

# WeldConstraint

Connects two `Class.BasePart|BaseParts` together such that their relative
position and orientation remain the same.

## Description

**WeldConstraint** connects two `Class.BasePart|BaseParts` and ensures they
stay in the same relative position/orientation to each other, meaning that if
one part moves, the other moves the same amount. Even if the two parts are not
touching, they can be welded together.

The most common way to create a weld constraint is by selecting **Weld**
through Studio's **Create** menu in the toolbar's **Model** tab.

Note that this tool behaves differently depending on how many
`Class.BasePart|BaseParts` are selected when the tool is activated:

- If no `Class.BasePart|BaseParts` are selected, the next two
  `Class.BasePart|BaseParts` clicked will be connected by a new
  `Class.WeldConstraint`. If the same `Class.BasePart` is clicked twice, no
  constraint will be created.
- If one `Class.BasePart` is already selected, the next `Class.BasePart`
  clicked will be connected to the selected one with a new
  `Class.WeldConstraint`.
- If multiple `Class.BasePart|BaseParts` are selected, those which are
  touching or overlapping will be automatically welded together by new
  `Class.WeldConstraint|WeldConstraints`.

#### Repositioning Behavior

Moving a welded `Class.BasePart` behaves differently depending on whether the
part was moved through its `Class.BasePart.Position|Position` or through its
`Datatype.CFrame`.

- If a welded part's `Class.BasePart.Position|Position` is updated, that part
  will move but none of the connected parts will move with it. The weld will
  recalculate the offset from the other parts based on the moved part's new
  position.

- If a welded part's `Datatype.CFrame` is updated, that part will move **and**
  all of the connected parts will also move, ensuring they maintain the same
  offset as when the weld was created.

## Inheritance

Inherits from: `Instance`

Memory category: `BaseParts`

## Properties

### `WeldConstraint.Active`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Physics`

Indicates if the WeldConstraint is currently active in the world.

True if the WeldConstraint is currently active in the world.

If the WeldConstraint or one of its parts is not in `Class.Workspace` the
weld will be inactive.

Rigid joints like `Class.Weld`, `Class.Snap`, `Class.WeldConstraint`,
`Class.Motor`, or `Class.Motor6D` may also be disabled due to conflicts
with other rigid joints, such as joints between the same two parts or
indirect cycles in the weld graph. Joints disabled this way may be
re-enabled later when another joint or part is added or removed.

Duplicate WeldConstraints do not conflict because WeldConstraints derive
their internal CFrames from the relative positions of their parts when
they are enabled and all update when `Class.BasePart.Position` or
`Class.BasePart.Orientation` is set on a part. The spanning tree may still
disable them if they are redundant or form a cycle.

### `WeldConstraint.Enabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Physics`

Toggles the constraint on and off.

The **Enabled** property of a `Class.WeldConstraint` sets whether the
constraint is active or not. When this property is set to true, if the
constraint's `Class.WeldConstraint.Part0` and `Class.WeldConstraint.Part1`
properties are set, then the constraint will ensure that its two connected
parts will be locked together.

### `WeldConstraint.Part0`

- **Type:** `BasePart`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Physics`

The first part connected by the constraint.

The `Part0` and `Class.WeldConstraint.Part1` properties of a
`Class.WeldConstraint` set which two `Class.BasePart` the weld connects.
As soon as both properties are set and the weld is
`Class.WeldConstraint.Enabled`, the weld will lock the two parts together.

If `Part0` or `Part1` are ever set to new parts, then the `WeldConstraint`
will instantly link the new part. The old part will no longer be
constrained.

```lua
local Workspace = game:GetService("Workspace")

local partA = Instance.new("Part")
local partB = Instance.new("Part")

partA.Position = Vector3.new(0, 10, 0)
partA.Parent = Workspace

partB.Position = Vector3.new(0, 10, 10)
partB.Parent = Workspace

local weld = Instance.new("WeldConstraint")
weld.Part0 = partA
weld.Part1 = partB
weld.Parent = partA
```

### `WeldConstraint.Part1`

- **Type:** `BasePart`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Physics`

The second part connected by the constraint.

The `Class.WeldConstraint.Part0` and `Part1` properties of a
`Class.WeldConstraint` set which two `Class.BasePart` the weld connects.
As soon as both properties are set and the weld is
`Class.WeldConstraint.Enabled`, the weld will lock the two parts together.

If `Part0` or `Part1` are ever set to new parts, then the `WeldConstraint`
will instantly link the new part. The old part will no longer be
constrained.

```lua
local Workspace = game:GetService("Workspace")

local partA = Instance.new("Part")
local partB = Instance.new("Part")

partA.Position = Vector3.new(0, 10, 0)
partA.Parent = Workspace

partB.Position = Vector3.new(0, 10, 10)
partB.Parent = Workspace

local weld = Instance.new("WeldConstraint")
weld.Part0 = partA
weld.Part1 = partB
weld.Parent = partA
```

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `WeldConstraint.Active` security: `read=None, write=None`
- Property `WeldConstraint.Enabled` security: `read=None, write=None`
- Property `WeldConstraint.Part0` security: `read=None, write=None`
- Property `WeldConstraint.Part1` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/WeldConstraint
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/WeldConstraint.yaml
- Captured: 2026-04-16
