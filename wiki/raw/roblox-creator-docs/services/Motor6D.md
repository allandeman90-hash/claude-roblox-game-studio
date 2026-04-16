---
title: Motor6D
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Motor6D
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Motor6D.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: physics
tags: [roblox-class, motor, joints, animation, rigging]
---

# Motor6D

Creates an animatable joint between two `Class.BasePart|BaseParts`.

## Description

**Motor6D** joins two `Class.BasePart|BaseParts`
(`Class.JointInstance.Part0|Part0` and `Class.JointInstance.Part1|Part1`)
together in an animatable way. The `Class.Motor6D.Transform|Transform`
property determines the offset between these parts. This can be set manually
using `Class.RunService.PreSimulation` or through an `Class.Animator`.

Models whose parts are joined by `Class.Motor6D` are usually referred to as
**rigs**, typically for `Class.Humanoid|Humanoids`.

## Inheritance

Inherits from: `Motor`

Memory category: `BaseParts`

## Properties

### `Motor6D.ChildName`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `NotScriptable`
- **Capabilities:** `Physics`

### `Motor6D.ParentName`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `NotScriptable`
- **Capabilities:** `Physics`

### `Motor6D.Transform`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `Physics`

Describes the current animation offset of the `Class.Motor6D` joint.

The internal `Datatype.CFrame` that is manipulated when a `Class.Motor6D`
is being animated. It is recommended to use this property for custom
animations rather than `Class.JointInstance.C0` and
`Class.JointInstance.C1`.

##### Timing

`Class.Motor6D` transforms are not applied immediately, unlike updating
`Class.JointInstance.C0|C0` and `Class.JointInstance.C1|C1`, but rather as
a batch in a parallel job after `Class.RunService.PreSimulation`,
immediately before physics steps. The deferred batch update is much more
efficient than many immediate updates.

If the `Class.Motor6D` is part of an animated model with an
`Class.Animator`, then `Class.Motor6D.Transform` will usually be
overwritten every frame by the `Class.Animator` after
`Class.RunService.PreAnimation` and before
`Class.RunService.PreSimulation`.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `Motor6D.ChildName` security: `read=None, write=None`
- Property `Motor6D.ParentName` security: `read=None, write=None`
- Property `Motor6D.Transform` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Motor6D
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Motor6D.yaml
- Captured: 2026-04-16
