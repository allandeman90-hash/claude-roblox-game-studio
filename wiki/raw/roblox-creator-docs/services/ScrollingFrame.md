---
title: ScrollingFrame
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ScrollingFrame
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ScrollingFrame.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui
tags: [roblox-class, gui, scrolling, container]
---

# ScrollingFrame

`ScrollingFrame` is a special `Class.Frame` type with built-in scrolling
interactivity and different ways to customize how the scrolling works.

## Description

`ScrollingFrame` is a special `Class.Frame` type with built-in scrolling
interactivity and different ways to customize how the scrolling works.

<img src="/assets/ui/ui-objects/ScrollingFrame-Example.jpg" width="840" alt="Example ScrollingFrame on the screen containing a tabbed category bar and a list of magical items for the player to consider purchasing." />

## Inheritance

Inherits from: `GuiObject`

Memory category: `Gui`

## Properties

### `ScrollingFrame.AbsoluteCanvasSize`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `Unsafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

The size of the area that is scrollable, in offsets.

The size of the area that is scrollable, in offsets. This property is set
to the maximum of the `Class.ScrollingFrame.CanvasSize|CanvasSize`
property and the size of the children if
`Class.ScrollingFrame.AutomaticCanvasSize|AutomaticCanvasSize` is set to
something other than `Enum.AutomaticSize.None`.

### `ScrollingFrame.AbsoluteWindowSize`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `Unsafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

The size of the frame, in offsets, without the scroll bars.

### `ScrollingFrame.AutomaticCanvasSize`

- **Type:** `AutomaticSize`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines whether `Class.ScrollingFrame.CanvasSize` is resized based on
child content.

This property is used to automatically size parent UI objects based on the
size of its descendants. You can use this property to dynamically add text
and other content to a `ScrollingFrame` at edit or run time and the size
will adjust to fit that content.

When this property is set to an `Enum.AutomaticSize` value other than
`Enum.AutomaticSize|None`,
`Class.ScrollingFrame.AbsoluteCanvasSize|AbsoluteCanvasSize` may resize
depending on its child content.

### `ScrollingFrame.BottomImage`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Image that displays on the bottom of a vertical scroll bar, or the right
of a horizontal scroll bar (rotated 90&deg; counterclockwise for a
horizontal scroll bar).

Image that displays on the bottom of a vertical scroll bar, or the right
of a horizontal scroll bar (rotated 90&deg; counterclockwise for a
horizontal scroll bar).

<img src="/assets/ui/ui-objects/ScrollingFrame-Scroll-Bar-Elements.png" width="600" alt="Diagram showing the three image asset elements which construct a scrolling frame's scroll bar." />

### `ScrollingFrame.BottomImageContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Image that displays on the bottom of a vertical scroll bar, or the right
of a horizontal scroll bar (rotated 90&deg; counterclockwise for a
horizontal scroll bar). Only supports asset URIs as textures.

Image that displays on the bottom of a vertical scroll bar, or the right
of a horizontal scroll bar (rotated 90&deg; counterclockwise for a
horizontal scroll bar).

<img src="/assets/ui/ui-objects/ScrollingFrame-Scroll-Bar-Elements.png" width="600" alt="Diagram showing the three image asset elements which construct a scrolling frame's scroll bar." />

### `ScrollingFrame.CanvasPosition`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Reflects the **current** positional offset of the canvas within the frame,
in pixels, and sets the position of scroll bars accordingly.

Reflects the **current** positional offset of the canvas within the frame,
in pixels, and sets the position of scroll bars accordingly. Note that
this property doesn't do anything if scroll bars aren't visible.

### `ScrollingFrame.CanvasSize`

- **Type:** `UDim2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the size of the scrollable area.

Determines the size of the scrollable area. For an adaptive alternative
based on the overall size of children within the `ScrollingFrame`,
consider using
`Class.ScrollingFrame.AutomaticCanvasSize|AutomaticCanvasSize`.

### `ScrollingFrame.ElasticBehavior`

- **Type:** `ElasticBehavior`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines if and when elastic scrolling is allowed on touch‑enabled
devices.

This property determines if and when elastic scrolling is allowed on
touch‑enabled devices. Defaults to `Enum.ElasticBehavior|WhenScrollable`.

### `ScrollingFrame.HorizontalScrollBarInset`

- **Type:** `ScrollBarInset`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Indicates whether `Class.ScrollingFrame.CanvasSize|CanvasSize` is inset by
`Class.ScrollingFrame.ScrollBarThickness|ScrollBarThickness` on the
horizontal axis.

### `ScrollingFrame.MidImage`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Image which spans the area between
`Class.ScrollingFrame.TopImage|TopImage` and
`Class.ScrollingFrame.BottomImage|BottomImage` (rotated 90&deg;
counterclockwise for a horizontal scroll bar).

Image which spans the area between
`Class.ScrollingFrame.TopImage|TopImage` and
`Class.ScrollingFrame.BottomImage|BottomImage` (rotated 90&deg;
counterclockwise for a horizontal scroll bar). This image automatically
scales to fill the space between the cap segments.

<img src="/assets/ui/ui-objects/ScrollingFrame-Scroll-Bar-Elements.png" width="600" alt="Diagram showing the three image asset elements which construct a scrolling frame's scroll bar." />

### `ScrollingFrame.MidImageContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Image which spans the area between
`Class.ScrollingFrame.TopImageContent|TopImageContent` and
`Class.ScrollingFrame.BottomImageContent|BottomImageContent` (rotated
90&deg; counterclockwise for a horizontal scroll bar). Only supports asset
URIs as textures.

Image which spans the area between
`Class.ScrollingFrame.TopImage|TopImage` and
`Class.ScrollingFrame.BottomImage|BottomImage` (rotated 90&deg;
counterclockwise for a horizontal scroll bar). This image automatically
scales to fill the space between the cap segments.

<img src="/assets/ui/ui-objects/ScrollingFrame-Scroll-Bar-Elements.png" width="600" alt="Diagram showing the three image asset elements which construct a scrolling frame's scroll bar." />

### `ScrollingFrame.ScrollBarImageColor3`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines how the rendered scroll bar images are colorized.

Determines how the scroll bar images
(`Class.ScrollingFrame.TopImage|TopImage`,
`Class.ScrollingFrame.MidImage|MidImage`,
`Class.ScrollingFrame.BottomImage|BottomImage`) are colorized. When set to
white, no colorization occurs. This property is useful for reusing image
assets; if the source images are completely white with transparency, you
can set the color of the entire scroll bar at once.

### `ScrollingFrame.ScrollBarImageTransparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the opacity of the scroll bar images.

Determines the opacity of the scroll bar images
(`Class.ScrollingFrame.TopImage|TopImage`,
`Class.ScrollingFrame.MidImage|MidImage`,
`Class.ScrollingFrame.BottomImage|BottomImage`). A value of `0` is
completely opaque and a value of `1` is completely transparent
(invisible).

### `ScrollingFrame.ScrollBarThickness`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Thickness of the scroll bar in pixels; applies to both horizontal and
vertical scroll bars.

Thickness of the scroll bar in pixels; applies to both horizontal and
vertical scroll bars. If set to `0`, no scroll bars are rendered.

### `ScrollingFrame.ScrollingDirection`

- **Type:** `ScrollingDirection`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the direction(s) in which scrolling is allowed.

This property determines the direction(s) in which scrolling is allowed.
If scrolling is disallowed in a direction, the associated scroll bar will
not appear. Defaults to `Enum.ScrollingDirection.XY`.

### `ScrollingFrame.ScrollingEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines whether scrolling is allowed on the frame.

Determines whether scrolling is allowed on the frame. If `false`, no
scroll bars will be rendered.

### `ScrollingFrame.TopImage`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Image which displays on the top of a vertical scroll bar, or the left of a
horizontal scroll bar (rotated 90&deg; counterclockwise for a horizontal
scroll bar).

Image which displays on the top of a vertical scroll bar, or the left of a
horizontal scroll bar (rotated 90&deg; counterclockwise for a horizontal
scroll bar).

<img src="/assets/ui/ui-objects/ScrollingFrame-Scroll-Bar-Elements.png" width="600" alt="Diagram showing the three image asset elements which construct a scrolling frame's scroll bar." />

### `ScrollingFrame.TopImageContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

### `ScrollingFrame.VerticalScrollBarInset`

- **Type:** `ScrollBarInset`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Indicates whether `Class.ScrollingFrame.CanvasSize|CanvasSize` is inset by
`Class.ScrollingFrame.ScrollBarThickness|ScrollBarThickness` on the
vertical axis.

### `ScrollingFrame.VerticalScrollBarPosition`

- **Type:** `VerticalScrollBarPosition`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Indicates whether the vertical scroll bar is positioned to the left or
right of the canvas.

Indicates whether the vertical scroll bar is positioned to the left or
right of the canvas. Defaults to `Enum.VerticalScrollBarPosition.Right`.

## Methods

### `ScrollingFrame:GetScrollVelocity`

```
GetScrollVelocity() -> Vector2
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

**Returns:**

- `Vector2` --- 

### `ScrollingFrame:ResetScrollVelocity`

```
ResetScrollVelocity() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

**Returns:**

- `()` --- 

## Events

_No public events documented._

## Notes / Deprecations

- Property `ScrollingFrame.AbsoluteCanvasSize` security: `read=None, write=None`
- Property `ScrollingFrame.AbsoluteWindowSize` security: `read=None, write=None`
- Property `ScrollingFrame.AutomaticCanvasSize` security: `read=None, write=None`
- Property `ScrollingFrame.BottomImage` security: `read=None, write=None`
- Property `ScrollingFrame.BottomImageContent` security: `read=None, write=None`
- Property `ScrollingFrame.CanvasPosition` security: `read=None, write=None`
- Property `ScrollingFrame.CanvasSize` security: `read=None, write=None`
- Property `ScrollingFrame.ElasticBehavior` security: `read=None, write=None`
- Property `ScrollingFrame.HorizontalScrollBarInset` security: `read=None, write=None`
- Property `ScrollingFrame.MidImage` security: `read=None, write=None`
- Property `ScrollingFrame.MidImageContent` security: `read=None, write=None`
- Property `ScrollingFrame.ScrollBarImageColor3` security: `read=None, write=None`
- Property `ScrollingFrame.ScrollBarImageTransparency` security: `read=None, write=None`
- Property `ScrollingFrame.ScrollBarThickness` security: `read=None, write=None`
- Property `ScrollingFrame.ScrollingDirection` security: `read=None, write=None`
- Property `ScrollingFrame.ScrollingEnabled` security: `read=None, write=None`
- Property `ScrollingFrame.TopImage` security: `read=None, write=None`
- Property `ScrollingFrame.TopImageContent` security: `read=None, write=None`
- Property `ScrollingFrame.VerticalScrollBarInset` security: `read=None, write=None`
- Property `ScrollingFrame.VerticalScrollBarPosition` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ScrollingFrame
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ScrollingFrame.yaml
- Captured: 2026-04-16
