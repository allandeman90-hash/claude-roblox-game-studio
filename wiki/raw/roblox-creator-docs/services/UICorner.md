---
title: UICorner
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/UICorner
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UICorner.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui-layout
tags: [roblox-class, gui, styling, corner-radius]
---

# UICorner

UI modifier which applies deformation to corners of its parent
`Class.GuiObject`.

## Description

`Class.UICorner` is a modifier which applies deformation to corners of its
parent `Class.GuiObject`. Input, but not descendants, will be clipped to the
round corner area. See [here](../../../ui/appearance-modifiers.md#corners) for
examples.

In order to keep the circular shape of round corners with the
`Class.UICorner.CornerRadius|CornerRadius` value (`Datatype.UDim`), the radius
is internally calculated as follows:

- The radius of the **X** axis is always the same as the radius of **Y** axis.
- `Datatype.UDim.Scale|Scale` rounding will always apply to the **minimum**
  width or height.
- Rounded rectangles will always be in a "pill" shape if
  `Class.UICorner.CornerRadius|CornerRadius` is set to a value that leads to a
  calculated result greater than half of the rectangle's minimum width or
  height.

Alternatively, rounded corners can be accomplished using **slices** which are
suitable for decorative borders that are not simply rounded. See
[9‑Slice Design](../../../ui/9-slice.md) for details.

Note that `Class.UICorner` can not be applied to a `Class.ScrollingFrame`.

## Inheritance

Inherits from: `UIComponent`

Memory category: `Instances`

## Properties

### `UICorner.CornerRadius`

- **Type:** `UDim`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the radius of the component.

A `Datatype.UDim` property that determines the radius of the
`Class.UICorner` component, internally calculated as follows:

- The radius of the **X** axis is always the same as the radius of **Y**
  axis.
- `Datatype.UDim.Scale|Scale` rounding will always apply to the
  **minimum** width or height.
- Rounded rectangles will always be in a "pill" shape if
  `Class.UICorner.CornerRadius|CornerRadius` is set to a value that leads
  to a calculated result greater than half of the rectangle's minimum
  width or height.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `UICorner.CornerRadius` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/UICorner
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UICorner.yaml
- Captured: 2026-04-16
