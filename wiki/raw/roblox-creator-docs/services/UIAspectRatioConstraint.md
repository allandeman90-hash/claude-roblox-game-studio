---
title: UIAspectRatioConstraint
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/UIAspectRatioConstraint
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UIAspectRatioConstraint.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui-layout
tags: [roblox-class, gui, layout, aspect-ratio]
---

# UIAspectRatioConstraint

Ensures the parent UI element maintains a particular aspect ratio.

## Description

The `Class.UIAspectRatioConstraint` enforces a **width‑to‑height** aspect
ratio on a `Class.GuiObject` regardless of its core size, even if that size is
set as a percentage of its parent. For example, inserting this constraint as a
child of a `Class.Frame` and setting the constraint's
`Class.UIAspectRatioConstraint.AspectRatio|AspectRatio` property to `2`
(`2:1`) keeps the frame's width at twice that of its height. Similarly,
setting this constraint's
`Class.UIAspectRatioConstraint.AspectRatio|AspectRatio` property to `0.5`
(`0.5:1`) keeps the frame's width at half that of its height.

Setting this constraint's
`Class.UIAspectRatioConstraint.AspectRatio|AspectRatio` to the default of `1`
(`1:1`) is a convenient way to prevent non‑proportional scaling/stretching of
an `Class.ImageLabel` with a square image asset.

Note that when a UI object is under control of both a layout structure such as
`Class.UIListLayout` and a `Class.UIAspectRatioConstraint`, the constraint
will **override** the layout and control the object's size.

## Inheritance

Inherits from: `UIConstraint`

Memory category: `Instances`

## Properties

### `UIAspectRatioConstraint.AspectRatio`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the width-to-height ratio to maintain.

This property determines the width‑to‑height ratio to maintain. To flip
the ratio to height‑to‑width, take the inverse (divide `1` by the number
or raise to the -1st power). This value must be greater than `0`.

### `UIAspectRatioConstraint.AspectType`

- **Type:** `AspectType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines how the maximum size of the object is limited.

This property determines how the maximum size of the object is limited.

- When set to `Enum.AspectType.FitWithinMaxSize|FitWithinMaxSize`, the
  object will be the maximum size possible within its own
  `Class.GuiBase2d.AbsoluteSize|AbsoluteSize`.

- When set to `Enum.AspectType.ScaleWithParentSize|ScaleWithParentSize`,
  the object's maximum size will be the size of the parent while still
  maintaining the aspect ratio.

### `UIAspectRatioConstraint.DominantAxis`

- **Type:** `DominantAxis`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the axis to use when setting the new size of the object.

This property determines which axis to use when setting the new size of
the object, assuming it would otherwise exceed the size of the parent.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `UIAspectRatioConstraint.AspectRatio` security: `read=None, write=None`
- Property `UIAspectRatioConstraint.AspectType` security: `read=None, write=None`
- Property `UIAspectRatioConstraint.DominantAxis` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/UIAspectRatioConstraint
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UIAspectRatioConstraint.yaml
- Captured: 2026-04-16
