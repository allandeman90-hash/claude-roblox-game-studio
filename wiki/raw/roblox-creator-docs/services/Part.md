---
title: Part
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Part
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Part.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: world
tags: [roblox-class, parts, 3d, building]
---

# Part

A common type of `Class.BasePart` that comes in different primitive shapes.

## Description

The Part object is a type of `Class.BasePart`. It comes in five different
primitive shapes: Ball, Block, Cylinder, Wedge, and CornerWedge.

## Inheritance

Inherits from: `FormFactorPart`

Memory category: `BaseParts`

## Properties

### `Part.Shape`

- **Type:** `PartType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

Sets the overall shape of the object.

The Shape property sets the overall shape of the object to one of a
predetermined list of built-in shapes.

The `Enum.PartType` enum controls the shape value, and has five possible
shapes:

| Shape/Value | Description                             |
| ----------- | --------------------------------------- |
| Ball        | A spherical shape.                      |
| Block       | A block shape.                          |
| Cylinder    | A cylinder shape.                       |
| Wedge       | A wedge shape with a slope on one side. |
| CornerWedge | A wedge shape with slopes on two sides. |

`Class.MeshPart` and [solid modeling](../../../parts/solid-modeling.md)
can be used to obtain completely custom part shapes.

Collisions between balls, blocks, and wedges, and corner wedges are exact,
whereas collisions between terrain, cylinders, TriangleMeshes, and other
geometry types are approximations. This means that the ball shape can be
useful to create stable colliders for car wheels.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `Part.Shape` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `using-a-script-to-create-a-part` --- https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/Part
- Part.Shape: using-a-script-to-create-a-part

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Part
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Part.yaml
- Captured: 2026-04-16
