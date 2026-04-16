---
title: ImageLabel
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ImageLabel
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ImageLabel.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui
tags: [roblox-class, gui, image, display]
---

# ImageLabel

A 2D user interface element that displays a single non-interactive image.

## Description

An `Class.ImageLabel` renders a rectangle, like a `Class.Frame` does, with an
image asset. The display of the image can be manipulated through the
`Class.ImageLabel.ImageColor3|ImageColor3` and
`Class.ImageLabel.ImageTransparency|ImageTransparency` properties. To display
only the image and hide the rectangle, set
`Class.GuiObject.BackgroundTransparency` to `1`.

Advanced `Class.ImageLabel` usage includes:

- Tiled images can be created by setting
  `Class.ImageLabel.ScaleType|ScaleType` to `Enum.ScaleType.Tile`, then
  `Class.ImageLabel.TileSize|TileSize` to the size of rendered tiles.

- 9-slice images can be created by setting
  `Class.ImageLabel.ScaleType|ScaleType` to `Enum.ScaleType.Slice`, then
  `Class.ImageLabel.SliceCenter|SliceCenter` to the center area of the 9‑slice
  image.

- Sprite sheets can be implemented through the use of
  `Class.ImageLabel.ImageRectOffset|ImageRectOffset` and
  `Class.ImageLabel.ImageRectSize|ImageRectSize`. Packing multiple images into
  one and using this property can make your experience's image assets load
  much quicker, especially if you use many small icons in your GUIs.

## Inheritance

Inherits from: `GuiLabel`

Memory category: `Gui`

## Properties

### `ImageLabel.Image`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The image content displayed by the UI element. Reads and writes to
`Class.ImageLabel.ImageContent|ImageContent`.

This property is a content-type property that should hold the asset ID of
a decal or image uploaded to Roblox. It functions identically to
`Class.Decal.Texture` with regards to loading the image from Roblox. The
rendered image can be modified using
`Class.ImageLabel.ImageColor3|ImageColor3` and
`Class.ImageLabel.ImageTransparency|ImageTransparency`.

### `ImageLabel.ImageColor3`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines how a rendered image will be colorized.

This property determines how an image is colorized. When set to white, no
colorization occurs. This property is very useful for reusing image
assets; if the source image is completely white with transparency, you can
set the entire color of the image at once with this property.

### `ImageLabel.ImageContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The image content displayed by the UI element. Supports
[asset URIs](../../../projects/assets/index.md#asset-uris) and
`Class.EditableImage` objects.

This property should hold an
[asset URI](../../../projects/assets/index.md#asset-uris) or a reference
to an `Class.EditableImage` object.

The asset URI can reference a decal or image uploaded to Roblox. It
functions identically to `Class.Decal.Texture` with regards to loading the
image.

The rendered image will be colorized using
`Class.ImageButton.ImageColor3`. It is possible to make the image render
as tiled, scaled to fit, or 9-sliced, by adjusting the
`Class.ImageButton.ScaleType` property.

### `ImageLabel.ImageRectOffset`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The offset in pixels of the sub-area of an image to be displayed.

Allows the partial display of an image in conjunction with
`Class.ImageLabel.ImageRectSize|ImageRectSize`. This property determines
the pixel offset (from the top-left) of the image area to be displayed.

### `ImageLabel.ImageRectSize`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the size in pixels of the sub-area of an image to be displayed.

Allows the partial display of an image in conjunction with
`Class.ImageLabel.ImageRectOffset|ImageRectOffset`. This property
determines the pixel size of the image area to be displayed. If either
dimension is set to `0`, the entire image is displayed instead.

### `ImageLabel.ImageTransparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the transparency of the rendered image.

This property determines the alpha of a UI element's rendered image. A
value of `0` is completely opaque and a value of `1` is completely
transparent (invisible).

### `ImageLabel.IsLoaded`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Indicates whether the image has finished loading from Roblox.

This property indicates if the `Class.ImageLabel.Image` property has
finished loading from Roblox. Images declined by moderation will never
load.

### `ImageLabel.ResampleMode`

- **Type:** `ResamplerMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Selects the image resampling mode for the label.

Determines how the image looks when it is scaled. By default, the image
smooths out texturing when displayed on the screen larger or smaller than
its size in texture memory. When set to
`Enum.ResamplerMode.Pixelated|Enum.ResamplerMode.Pixelated`, the image
preserves the sharp edges of pixels.

### `ImageLabel.ScaleType`

- **Type:** `ScaleType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines how an image will scale if displayed in a UI element whose size
differs from the source image.

This property determines in what way an `Class.ImageLabel.Image` is
rendered when the UI element's absolute size differs from the source
image's size.

By default, this property is `Enum.ScaleType.Stretch` which will simply
stretch/compact the image dimensions so it fits the UI element's space
exactly. Since transparent pixels are set to black when uploading to
Roblox, transparent images should apply alpha blending to avoid a blackish
outline around scaled images.

For `Enum.ScaleType.Slice`, the `Class.ImageLabel.SliceCenter|SliceCenter`
property will be revealed in the
[Properties](../../../studio/properties.md) window. This is for nine-slice
UI: when scaling up, the corners will remain the source image size. The
edges of the image will stretch to the width/height of the image. Finally,
the center of the image will stretch to fill the center area of the image.

Finally, for `Enum.ScaleType.Tile`, the
`Class.ImageLabel.TileSize|TileSize` property will be revealed in the
[Properties](../../../studio/properties.md) window. This is for tiled
images, where the size of each image tile is determined by the
`Class.ImageLabel.TileSize|TileSize` property.

### `ImageLabel.SliceCenter`

- **Type:** `Rect`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Sets the slice boundaries of a 9-sliced image.

This property sets the slice boundaries of a 9-sliced image when
`Class.ImageLabel.ScaleType|ScaleType` is set to
`Enum.ScaleType.Slice|Enum.ScaleType.Slice`. Please note that this
property is only visible in the
[Properties](../../../studio/properties.md) window under this condition.

To learn more about 9-slice images, see
[UI 9 Slice Design](../../../ui/9-slice.md).

### `ImageLabel.SliceScale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Scales the 9-slice edges by the specified ratio.

Scales the 9-slice edges by the specified ratio. This means that the edges
around the 9-slice will grow as if you'd uploaded a new version of the
texture upscaled. Defaults to `1.0`.

See also `Class.ImageLabel.ScaleType|ScaleType`,
`Class.ImageLabel.SliceCenter|SliceCenter`, and
`Class.ImageLabel.SliceScale|SliceScale`.

### `ImageLabel.TileSize`

- **Type:** `UDim2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Sets the tiling size of the `Class.ImageLabel`.

This property sets the tiling size of the `Class.ImageLabel` with a
default of
<Typography noWrap>`Datatype.UDim2.new(1, 0, 1, 0)`</Typography>. Tiling
starts at the top-left corner of the image. This property is only active
if the `Class.ImageLabel.ScaleType|ScaleType` for the `Class.ImageLabel`
is set to `Enum.ScaleType.Tile`.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `ImageLabel.Image` security: `read=None, write=None`
- Property `ImageLabel.ImageColor3` security: `read=None, write=None`
- Property `ImageLabel.ImageContent` security: `read=None, write=None`
- Property `ImageLabel.ImageRectOffset` security: `read=None, write=None`
- Property `ImageLabel.ImageRectSize` security: `read=None, write=None`
- Property `ImageLabel.ImageTransparency` security: `read=None, write=None`
- Property `ImageLabel.IsLoaded` security: `read=None, write=None`
- Property `ImageLabel.ResampleMode` security: `read=None, write=None`
- Property `ImageLabel.ScaleType` security: `read=None, write=None`
- Property `ImageLabel.SliceCenter` security: `read=None, write=None`
- Property `ImageLabel.SliceScale` security: `read=None, write=None`
- Property `ImageLabel.TileSize` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- ImageLabel.ImageTransparency: Oscillate-ImageTransparency
- ImageLabel.IsLoaded: Image-Load-Time
- ImageLabel.TileSize: Image-ScaleType-Demo

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ImageLabel
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ImageLabel.yaml
- Captured: 2026-04-16
