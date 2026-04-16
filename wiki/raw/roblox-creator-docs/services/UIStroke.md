---
title: UIStroke
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/UIStroke
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UIStroke.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui-layout
tags: [roblox-class, gui, styling, border, outline]
---

# UIStroke

Applies an outline to text or a UI border.

## Description

`Class.UIStroke` applies an outline to text or a UI border. Some properties
may require enabling the
[Improved UIStrokes beta](https://devforum.roblox.com/t/studio-beta-uistroke-improvements-scaling-offsets-and-more/3958036).

Key features include:

- Adjust the `Class.UIStroke.Color|Color` and
  `Class.UIStroke.Thickness|Thickness` of the stroke outline.
- Change the stroke `Class.UIStroke.Transparency|Transparency` independently
  from the text or UI object.
- Choose the `Class.UIStroke.LineJoinMode|LineJoinMode` of the stroke (round,
  bevel, or miter).
- Specify the `Class.UIStroke.BorderStrokePosition|BorderStrokePosition` on
  its parent's border and/or an additional
  `Class.UIStroke.BorderOffset|BorderOffset` to the stroke's position.
- Add a gradient to the stroke via the `Class.UIGradient` instance.
- Use [rich text](../../../ui/rich-text.md) tags to add stroke to inline text
  segments.

For more details on the `Class.UIStroke` object, see
[Appearance Modifiers](../../../ui/appearance-modifiers.md).

## Inheritance

Inherits from: `UIComponent`

Memory category: `Instances`

## Properties

### `UIStroke.ApplyStrokeMode`

- **Type:** `ApplyStrokeMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines whether to apply the stroke to the object's border instead of
the text itself.

When a `Class.UIStroke` instance is applied to a text object, this
property determines whether to apply the stroke to the object's border
instead of the text itself.

<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-As-Text-Outline.png" width="376" />
<figcaption><code>ApplyStrokeMode</code> = <code>Enum.ApplyStrokeMode.Contextual|Contextual</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-Stroke-Mode-Border.png" width="376" />
<figcaption><code>ApplyStrokeMode</code> = <code>Enum.ApplyStrokeMode.Border|Border</code></figcaption>
</figure>

### `UIStroke.BorderOffset`

- **Type:** `UDim`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Specifies an additional offset to the stroke's position, relative to the
parent's minimum height or width.

This property specifies an additional offset (`Datatype.UDim`) to the
stroke's position, relative to the parent's minimum height or width.

<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-BorderOffset-Out.png" width="312" />
<figcaption><code>BorderOffset</code> = <code>(0.15, 0)</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-BorderOffset-In.png" width="312" />
<figcaption><code>BorderOffset</code> = <code>(0, -16)</code></figcaption>
</figure>

### `UIStroke.BorderStrokePosition`

- **Type:** `BorderStrokePosition`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the stroke's position on its parent's border.

This property determines the stroke's position on its parent's border as
an `Enum.BorderStrokePosition` value.

<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-BorderStrokePosition-Center.png" width="312" />
<figcaption><code>BorderStrokePosition</code> = <code>Enum.BorderStrokePosition.Center|Center</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-BorderStrokePosition-Inner.png" width="312" />
<figcaption><code>BorderStrokePosition</code> = <code>Enum.BorderStrokePosition.Inner|Inner</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-BorderStrokePosition-Outer.png" width="312" />
<figcaption><code>BorderStrokePosition</code> = <code>Enum.BorderStrokePosition.Outer|Outer</code></figcaption>
</figure>

### `UIStroke.Color`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the stroke color.

Determines the `Class.UIStroke` color. You can also insert a
`Class.UIGradient` instance as a child to create gradient strokes.

<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-Color-Solid.png" width="376" />
<figcaption><code>Color</code> = <code>(0, 95, 225)</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-Color-Gradient.png" width="376" />
<figcaption><code>UIStroke</code> with <code>Class.UIGradient</code> child</figcaption>
</figure>

### `UIStroke.Enabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines whether the stroke in visible.

This property determines whether the `Class.UIStroke` is visible. When set
to `false`, the stroke will not be rendered. Defaults to `true`.

### `UIStroke.LineJoinMode`

- **Type:** `LineJoinMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines how corners are interpreted.

This property determines how corners are interpreted. It accepts an
`Enum.LineJoinMode` value of either `Enum.LineJoinMode.Round|Round`
(default), `Enum.LineJoinMode.Bevel|Bevel`, or
`Enum.LineJoinMode.Miter|Miter`.

<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-LineJoinMode-Round.png" width="376" />
<figcaption><code>LineJoinMode</code> = <code>Enum.LineJoinMode.Round|Round</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-LineJoinMode-Bevel.png" width="376" />
<figcaption><code>LineJoinMode</code> = <code>Enum.LineJoinMode.Bevel|Bevel</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-LineJoinMode-Miter.png" width="376" />
<figcaption><code>LineJoinMode</code> = <code>Enum.LineJoinMode.Miter|Miter</code></figcaption>
</figure>

### `UIStroke.StrokeSizingMode`

- **Type:** `StrokeSizingMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines whether the stroke's `Class.UIStroke.Thickness|Thickness` will
be measured in pixels or be relative to the parent.

This property determines whether the stroke's
`Class.UIStroke.Thickness|Thickness` will be measured in pixels or be
scaled relative to the parent. See `Enum.StrokeSizingMode` for further
details.

### `UIStroke.Thickness`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the stroke's thickness.

This property determines the stroke's thickness, measured in pixels
(default) or scaled relative to the parent, depending on
`Class.UIStroke.StrokeSizingMode|StrokeSizingMode`.

<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-Thickness-4.png" width="376" />
<figcaption><code>Thickness</code> = <code>4</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-Thickness-12.png" width="376" />
<figcaption><code>Thickness</code> = <code>12</code></figcaption>
</figure>

Be mindful of [tweening](../../../ui/animation.md) this `Class.UIStroke`
property when applied to text objects. This renders and stores many glyph
sizes each frame, potentially causing performance issues or text
flickering.

### `UIStroke.Transparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Sets the stroke opacity independently of the parent object's
`Class.GuiObject.BackgroundTransparency|BackgroundTransparency` or
`Class.TextLabel.TextTransparency|TextTransparency`.

This property sets the stroke opacity independently of the parent object's
`Class.GuiObject.BackgroundTransparency|BackgroundTransparency` or
`Class.TextLabel.TextTransparency|TextTransparency`. This allows you to
render text and borders that are "hollow" (consisting of only an outline).

<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-Transparency-A.png" width="376" />
<figcaption><code>Transparency</code> = <code>0.5</code> &nbsp;&middot;&nbsp; <code>Class.TextLabel.TextTransparency</code> = <code>0</code></figcaption>
</figure>
<figure>
<img src="../../../assets/ui/ui-objects/UIStroke-Transparency-B.png" width="376" />
<figcaption><code>Transparency</code> = <code>0</code> &nbsp;&middot;&nbsp; <code>Class.TextLabel.TextTransparency</code> = <code>1</code></figcaption>
</figure>

### `UIStroke.ZIndex`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the order in which the stroke renders relative to sibling
`Class.UIStroke` instances.

This property determines the order in which the stroke renders relative to
sibling `Class.UIStroke` instances. Those with a lower `ZIndex` render
under (behind) those with a higher `ZIndex`.

Note that the rendering order for `Class.UIStroke` instances with the same
`ZIndex` is undefined. Do not apply multiple `Class.UIStroke` instances
with the same `ZIndex` if their rendering order matters.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `UIStroke.ApplyStrokeMode` security: `read=None, write=None`
- Property `UIStroke.BorderOffset` security: `read=None, write=None`
- Property `UIStroke.BorderStrokePosition` security: `read=None, write=None`
- Property `UIStroke.Color` security: `read=None, write=None`
- Property `UIStroke.Enabled` security: `read=None, write=None`
- Property `UIStroke.LineJoinMode` security: `read=None, write=None`
- Property `UIStroke.StrokeSizingMode` security: `read=None, write=None`
- Property `UIStroke.Thickness` security: `read=None, write=None`
- Property `UIStroke.Transparency` security: `read=None, write=None`
- Property `UIStroke.ZIndex` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/UIStroke
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UIStroke.yaml
- Captured: 2026-04-16
