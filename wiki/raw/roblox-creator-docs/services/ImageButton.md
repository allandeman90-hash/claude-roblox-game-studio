---
title: ImageButton
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ImageButton
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ImageButton.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui
tags: [roblox-class, gui, image, input, button]
---

# ImageButton

A 2D user interface element that displays an interactive image.

## Description

An `Class.ImageButton` behaves similarly to an `Class.ImageLabel` in regards
to rendering, with the additional behaviors of a `Class.GuiButton`.

## Inheritance

Inherits from: `GuiButton`

Memory category: `Gui`

## Properties

### `ImageButton.HoverImage`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

A texture ID that will be used when the `Class.ImageButton` is being
hovered.

### `ImageButton.HoverImageContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The image content that will be used when the `Class.ImageButton` is being
hovered. Only supports asset URIs.

An image-type Content that can be set as an `Class.ImageButton` property.
When the button is hovered, it will render this image. Only asset URIs are
supported for this property.

### `ImageButton.Image`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The image content displayed by the `Class.ImageButton` element. Reads and
writes to `Class.ImageButton.ImageContent|ImageContent`.

This property is a content-type property that should hold the asset ID of
a decal or image uploaded to Roblox. It functions identically to
`Class.Decal.Texture` with regards to loading the image from Roblox. The
rendered image will be colorized using
`Class.ImageButton.ImageColor3|ImageColor3`.

Note that it is possible to make the image render as tiled, scaled to fit,
or 9-sliced by adjusting the `Class.ImageButton.ScaleType|ScaleType`
property.

### `ImageButton.ImageColor3`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines how a rendered image will be colorized.

This property determines how an image is colorized. When set to white, no
colorization occurs. This property is very useful for reusing image
assets: If the source image is completely white with transparency, you can
set the entire color of the image at once with this property.

### `ImageButton.ImageContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The image content displayed by the UI element. Supports asset URIs and
`Class.EditableImage` objects.

This property should hold an
[asset URI](../../../projects/assets/index.md#asset-uris) or a reference
to an `Class.EditableImage` object. The asset URI can reference a decal or
image uploaded to Roblox. It functions identically to
`Class.Decal.Texture` with regards to loading the image.

The rendered image will be colorized using
`Class.ImageButton.ImageColor3|ImageColor3`. It is possible to make the
image render as tiled, scaled to fit, or 9‑sliced by adjusting the
`Class.ImageButton.ScaleType|ScaleType` property.

### `ImageButton.ImageRectOffset`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The offset in pixels of the sub-area of an image to be displayed.

This property determines the pixel offset (from the top-left) of the image
area to be displayed, allowing for the partial display of an image in
conjunction with `Class.ImageButton.ImageRectSize|ImageRectSize`.

### `ImageButton.ImageRectSize`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the size in pixels of the sub-area of an image to be displayed.

This property determines the pixel size of the image area to be displayed,
allowing for the partial display of an image in conjunction with
`Class.ImageButton.ImageRectOffset|ImageRectOffset`. If either dimension
is set to `0`, the entire image is displayed instead.

### `ImageButton.ImageTransparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the transparency of the rendered image.

This property determines the alpha of the element's rendered image. A
value of `0` is completely opaque and a value of `1` is completely
transparent (invisible). This property behaves similarly to
`Class.GuiObject.BackgroundTransparency` or `Class.BasePart.Transparency`.

If you disable image rendering by setting
`Class.ImageButton.ImageTransparency|ImageTransparency` to `1`, it will
result in a plain rectangle that can be used as a button. However, it may
be better to use a blank `Class.TextButton` instead.

### `ImageButton.IsLoaded`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Indicates whether the Image has finished loading from the Roblox website.

This property indicates if the `Class.ImageButton.Image|Image` property
has finished loading from Roblox. Images declined by moderation will never
load.

### `ImageButton.PressedImage`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

A texture ID that will be used when an `Class.ImageButton` is being
pressed.

A texture ID that can be set as an `Class.ImageButton` property. When the
button is pressed, it will render this image.

### `ImageButton.PressedImageContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The image content that will be used when an `Class.ImageButton` is being
pressed. Only supports asset URIs.

An image-type Content that can be set as an `Class.ImageButton` property.
When the button is pressed, it will render this image. Only asset URIs are
supported for this property.

### `ImageButton.ResampleMode`

- **Type:** `ResamplerMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Selects the image resampling mode for the button.

Determines how the image looks when it is scaled. By default, the image
smooths out the texture when displayed either larger or smaller than its
size in texture memory. In contrast,
`Enum.ResamplerMode.Pixelated|Enum.ResamplerMode.Pixelated` preserves the
sharp edges of the image pixels.

### `ImageButton.ScaleType`

- **Type:** `ScaleType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines how an image will scale if displayed in a UI element whose size
differs from the source image.

This property determines in what way the `Class.ImageButton.Image|Image`
property is rendered when the UI element's absolute size differs from the
source image's size.

By default, this property is
`Enum.ScaleType.Stretch|Enum.ScaleType.Stretch` which will simply
stretch/compact the image dimensions so it fits the UI element's space
exactly. Since transparent pixels are set to black when uploading to
Roblox, transparent images should apply alpha blending to avoid a blackish
outline around scaled images.

For `Enum.ScaleType.Slice`, when scaling up, the corners will remain the
source image size. The edges of the image will stretch to the width/height
of the image. Finally, the center of the image will stretch to fill the
center area of the image. To learn more about 9‑sliced images, see
[UI 9‑Slice Design](../../../ui/9-slice.md).

For `Enum.ScaleType.Tile`, the size of each image tile is determined by
the `Class.ImageButton.TileSize|TileSize` property.

### `ImageButton.SliceCenter`

- **Type:** `Rect`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Sets the slice boundaries of a 9-sliced image.

This property sets the slice boundaries of a 9-sliced image when
`Class.ImageButton.ScaleType|ScaleType` is set to
`Enum.ScaleType.Slice|Enum.ScaleType.Slice`.

To learn more about 9‑sliced images, see
[UI 9‑Slice Design](../../../ui/9-slice.md).

### `ImageButton.SliceScale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Scales the 9-slice edges by the specified ratio.

Scales the 9-slice edges by the specified ratio. This means that the edges
around the 9‑slice will grow as if you'd uploaded a new version of the
texture upscaled. Defaults to `1.0`.

As a multiplier for the borders of a 9-slice, it is useful for reusing one
rounded corner image for multiple radii.

See also `Class.ImageButton.ScaleType|ScaleType` which determines how an
image will scale if displayed in a UI element whose size differs from the
source image.

### `ImageButton.TileSize`

- **Type:** `UDim2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Sets the tiling scale of the ImageButton.

Sets the tiling size of the `Class.ImageButton` starting at the upper-left
corner of the image. The default `Datatype.UDim2` values are <Typography
noWrap>`1, 0, 1, 0`</Typography>; the scale components of the
`Datatype.UDim2` will scale the tile based on the size of the
`Class.ImageButton` while the offset components are in raw pixels. For
example, a scale of `0.5` means the tile will be half the size of the
`Class.ImageButton` in the corresponding axis.

This property is only active if the
`Class.ImageButton.ScaleType|ScaleType` property is set to
`Enum.ScaleType.Tile`.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `ImageButton.HoverImage` security: `read=None, write=None`
- Property `ImageButton.HoverImageContent` security: `read=None, write=None`
- Property `ImageButton.Image` security: `read=None, write=None`
- Property `ImageButton.ImageColor3` security: `read=None, write=None`
- Property `ImageButton.ImageContent` security: `read=None, write=None`
- Property `ImageButton.ImageRectOffset` security: `read=None, write=None`
- Property `ImageButton.ImageRectSize` security: `read=None, write=None`
- Property `ImageButton.ImageTransparency` security: `read=None, write=None`
- Property `ImageButton.IsLoaded` security: `read=None, write=None`
- Property `ImageButton.PressedImage` security: `read=None, write=None`
- Property `ImageButton.PressedImageContent` security: `read=None, write=None`
- Property `ImageButton.ResampleMode` security: `read=None, write=None`
- Property `ImageButton.ScaleType` security: `read=None, write=None`
- Property `ImageButton.SliceCenter` security: `read=None, write=None`
- Property `ImageButton.SliceScale` security: `read=None, write=None`
- Property `ImageButton.TileSize` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- ImageButton.Image: Image-Hover-Lock
- ImageButton.ImageColor3: Image-Hover-Lock
- ImageButton.ImageRectOffset: Image-Animation-using-Spritesheet
- ImageButton.ImageRectSize: Image-Animation-using-Spritesheet
- ImageButton.IsLoaded: Image-Load-Time

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ImageButton
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ImageButton.yaml
- Captured: 2026-04-16
