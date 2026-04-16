---
title: TextLabel
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/TextLabel
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TextLabel.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui
tags: [roblox-class, gui, text, display]
---

# TextLabel

A 2D user interface element that displays non-interactive text.

## Description

A `Class.TextLabel` renders a rectangle, like a `Class.Frame`, with styled
text. The rectangle can be used to define text boundaries, text scaling
(`Class.TextLabel.TextScaled|TextScaled`), wrapping
(`Class.TextLabel.TextWrapped|TextWrapped`), and alignment
(`Class.TextLabel.TextXAlignment|TextXAlignment` and/or
`Class.TextLabel.TextYAlignment|TextYAlignment`).

This class contains properties that control the display of the text, such as
`Class.TextLabel.Font|Font` and `Class.TextLabel.TextColor3|TextColor3`. To
display only text and hide the background rectangle, set
`Class.TextLabel.BackgroundTransparency|BackgroundTransparency` to `1`.

A `Class.UITextSizeConstraint` object can be used to constrain the size of
text with `Class.TextLabel.TextScaled|TextScaled` enabled. It is recommended
that the size of text is no lower than `9`, otherwise it may not be visible to
many users.

## Inheritance

Inherits from: `GuiLabel`

Memory category: `Gui`

## Properties

### `TextLabel.ContentText`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

A copy of `Class.TextLabel.Text` that contains exactly what is being
rendered by the `Class.TextLabel`.

This property provides a copy of `Class.TextLabel.Text|Text` that contains
exactly what is being rendered by the `Class.TextLabel`. This is useful
for eliminating style tags used for [rich text](../../../ui/rich-text.md)
markup; for example, when `Class.TextLabel.RichText|RichText` is enabled,
the `Class.TextLabel.ContentText|ContentText` property shows the text as
it appears to the user.

<table>
    <thead>
        <tr>
            <th>RichText</th>
            <th>Text</th>
            <th>ContentText</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><code>false</code></td>
            <td>&lt;b&gt;Hello,&lt;br/&gt; world!&lt;/b&gt;</td>
            <td>&lt;b&gt;Hello,&lt;br/&gt; world!&lt;/b&gt;</td>
        </tr>
        <tr>
            <td><code>true</code></td>
            <td>&lt;b&gt;Hello,&lt;br/&gt; world!&lt;/b&gt;</td>
            <td>Hello,<br/> world!</td>
        </tr>
    </tbody>
  </table>

### `TextLabel.Font`

- **Type:** `Enum.Font`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `UI`

Determines the font used to render text.

This property selects one of several pre-defined fonts with which the
`Class.TextLabel` will render its text. Some fonts have bold, italic
and/or light variants.

With the exception of the `Enum.Font.Legacy` font, each font will render
text with the line height equal to the `Class.TextLabel.TextSize|TextSize`
property.

The `Enum.Font.Code` font is the only monospace font. It has the unique
property that each character has the exact same width and height ratio of
1:2, where the width of each character is approximately half the
`Class.TextLabel.TextSize|TextSize` property.

This property is kept in sync with the `Class.TextLabel.FontFace|FontFace`
property.

### `TextLabel.FontFace`

- **Type:** `Datatype.Font`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the font used to render text.

This property is similar to the `Class.TextLabel.Font|Font` property but
allows setting fonts that don't exist in `Enum.Font`.

This property is kept in sync with the `Class.TextLabel.Font|Font`
property, such that when setting `Class.TextLabel.FontFace|FontFace`, the
font is set to the corresponding `Enum.Font` value or to
`Enum.Font.Unknown` if there are no matches.

### `TextLabel.FontSize`

- **Type:** `FontSize`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `Deprecated`
- **Capabilities:** `UI`
- **Deprecated:** This property is deprecated in favor of `Class.TextLabel|TextSize` which
is an integer and not an enum and thus offers far more options for sizes.

Determines the font size to be used.

This property determines the font size to be used.

### `TextLabel.LineHeight`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Scales the spacing between lines of text in the `Class.TextLabel`.

Controls the height of lines as a multiple of the font's `em` square size
by scaling the spacing between lines of text in the `Class.TextLabel`.
Valid values range from `1.0` to `3.0`, defaulting to `1.0`.

### `TextLabel.LocalizedText`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Sets whether a `Class.TextLabel` should be `Class.GuiBase2d.Localize` or
not.

This property sets whether a `Class.TextLabel` should regard
`Class.GuiBase2d.Localize` or not.

### `TextLabel.MaxVisibleGraphemes`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

The maximum number of graphemes the `Class.TextLabel` can show.

This property controls the maximum number of graphemes (or units of text)
that are shown on the `Class.TextLabel`. It is primarily provided as an
easy way to create a
[typewriter effect](../../../ui/animation.md#typewriter-effect) where the
characters appear one at a time.

Changing the property does not change the position or size of the visible
graphemes; the layout will be calculated as if all graphemes are visible.

Setting the property to `-1` disables the limit and shows the entirety of
the `Class.TextLabel.Text|Text`.

### `TextLabel.OpenTypeFeatures`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

### `TextLabel.OpenTypeFeaturesError`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

### `TextLabel.RichText`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines whether the `Class.TextLabel` renders its text using rich text
formatting.

This property determines whether the `Class.TextLabel` renders its text
using [rich text](../../../ui/rich-text.md) markup to style sections of
the string in bold, italics, specific colors, and more.

To use rich text, simply include rich text formatting tags in the
`Class.TextLabel.Text|Text` string.

### `TextLabel.Text`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the string rendered by the `Class.TextLabel`.

This property determines the text content rendered by the
`Class.TextLabel`. The visual properties of the string rendered to the
screen is determined by `Class.TextLabel.TextColor3|TextColor3`,
`Class.TextLabel.TextTransparency|TextTransparency`,
`Class.TextLabel.TextSize|TextSize`, `Class.TextLabel.Font|Font`,
`Class.TextLabel.TextScaled|TextScaled`,
`Class.TextLabel.TextWrapped|TextWrapped`,
`Class.TextLabel.TextXAlignment|TextXAlignment` and
`Class.TextLabel.TextYAlignment|TextYAlignment`.

It is possible to render emoji such as 🔒 and other symbols which aren't
affected by the `Class.TextLabel.TextColor3|TextColor3` property. These
can be pasted into `Class.Script` and `Class.LocalScript` objects, as well
as the field within the [Properties](../../../studio/properties.md)
window.

This property may contain newline characters. Similarly, this property may
contain a tab character, but it will render as a space instead.

### `TextLabel.TextBounds`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Read-only property which reflects the absolute size of rendered text in
offsets.

This read-only property reflects the absolute size of rendered text in
offsets, meaning that if you try to fit text into a rectangle, this
property would reflect the minimum dimensions of the rectangle you'd need
in order to fit the text.

Using `Class.TextService:GetTextSize()`, you can predict what
`Class.TextLabel.TextBounds|TextBounds` will be given a string,
`Class.TextLabel.Font|Font`, `Class.TextLabel.TextSize|TextSize`, and
frame size.

### `TextLabel.TextColor`

- **Type:** `BrickColor`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`, `Deprecated`
- **Capabilities:** `UI`
- **Deprecated:** This item has been superseded by `Class.TextLabel.TextColor3` which should
be used in all new work.

Determines the color of text.

This property determines the color of text.

### `TextLabel.TextColor3`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the color of rendered text.

This property determines the color of all the text rendered by the
`Class.TextLabel` element.

### `TextLabel.TextDirection`

- **Type:** `TextDirection`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Direction in which the text is rendered.

`Enum.TextDirection` in which the text is rendered.

### `TextLabel.TextFits`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

A boolean representation of whether the label's text fits within the size
of it.

### `TextLabel.TextScaled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Changes whether text is resized to fit within the `Class.TextLabel`.

This property determines whether text is scaled so that it fills the
label's entire space. When enabled, `Class.TextLabel.TextSize|TextSize` is
ignored and `Class.TextLabel.TextWrapped|TextWrapped` is automatically
enabled. This property is useful for rendering text elements within
`Class.BillboardGui|BillboardGuis`. When this property is used for
[on-screen UI](../../../ui/on-screen-containers.md), it may be helpful to
use a `Class.UITextSizeConstraint` to restrict the range of possible text
sizes.

##### Automatic Sizing

It's recommended that you avoid usage of
`Class.TextLabel.TextScaled|TextScaled` and adjust UI to take advantage of
the `Class.GuiObject.AutomaticSize|AutomaticSize` property instead. Here
are the core differences between the two properties:

- `Class.TextLabel.TextScaled|TextScaled` scales the content (text) to
  accommodate the UI. Without careful consideration, some text may become
  unreadable if scaled too small.

- `Class.GuiObject.AutomaticSize|AutomaticSize` resizes the UI to
  accommodate content while maintaining a consistent font size. For more
  information, see [here](../../../ui/size-modifiers.md#automatic-sizing).

Additionally, it's recommended that you avoid applying both
`Class.GuiObject.AutomaticSize|AutomaticSize` and
`Class.TextLabel.TextScaled|TextScaled` and to the same `Class.TextLabel`.
`Class.GuiObject.AutomaticSize|AutomaticSize` determines the maximum
amount of available space that a `Class.GuiObject` can use (in this case,
text), while `Class.TextLabel.TextScaled|TextScaled` uses the available
space determined by `Class.GuiObject.AutomaticSize|AutomaticSize` to scale
the font size up to the maximum font size (100) if there are no size
constraints.

### `TextLabel.TextSize`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the line height of text in offsets.

This property determines the height of one line of rendered text. The unit
is in offsets, not points (which is used in most document editing
programs). The `Enum.Font.Legacy` font does not hold this property.

### `TextLabel.TextStrokeColor3`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the color of the text stroke (outline).

This property sets the color of the stroke, or outline, of rendered text.
Along with
`Class.TextLabel.TextStrokeTransparency|TextStrokeTransparency`, it
determines the final visual appearance of the text stroke.

As a powerful alternative which supports color gradients, see
`Class.UIStroke`.

### `TextLabel.TextStrokeTransparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the transparency of the text stroke (outline).

This property sets the transparency of the stroke, or outline, of rendered
text. Along with `Class.TextLabel.TextStrokeColor3|TextStrokeColor3`, it
determines the final visual appearance of the text stroke.

Note that text stroke is multiple renderings of the same transparency, so
this property is essentially multiplicative on itself four times over.
Therefore, it's recommended to set
`Class.TextLabel.TextStrokeTransparency|TextStrokeTransparency` to a value
in the range of `0.75` to `1` for more a more subtle effect.

As a powerful alternative which supports color gradients, see
`Class.UIStroke`.

### `TextLabel.TextTransparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the transparency of rendered text.

This property determines the transparency of all the text rendered by the
`Class.TextLabel`.

### `TextLabel.TextTruncate`

- **Type:** `TextTruncate`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Controls the truncation of the text displayed in the `Class.TextLabel`.

### `TextLabel.TextWrap`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `Deprecated`
- **Capabilities:** `UI`
- **Deprecated:** This property is simply an alias for `Class.TextLabel|TextWrapped`. Use
the past-tense version instead.

Determines whether or not text should wrap at the edges of the
`Class.TextLabel` element's space.

This property determines whether or not text should wrap at the edges of
the `Class.TextLabel` element's space.

### `TextLabel.TextWrapped`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines if text wraps to multiple lines within the `Class.TextLabel`
element's space, truncating excess text.

When enabled, this property will render text on multiple lines within a
`Class.TextLabel` element's space so that
`Class.TextLabel.TextBounds|TextBounds` will never exceed the
`Class.GuiBase2d.AbsoluteSize` of the element. This is achieved by
breaking long lines of text into multiple lines.

Line breaks will prefer whitespace; should a long unbroken word exceed the
width of the element, that word will be broken into multiple lines.

If further line breaks would cause the vertical height of the text (the
**Y** component of `Class.TextLabel.TextBounds|TextBounds`) to exceed the
vertical height of the element (the **Y** component of
`Class.GuiBase2d.AbsoluteSize`), then that line will not be rendered at
all.

### `TextLabel.TextXAlignment`

- **Type:** `TextXAlignment`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the horizontal alignment of rendered text.

This property determines the horizontal alignment of text rendered within
the object's space. It is used in conjunction with
`Class.TextLabel.TextYAlignment|TextYAlignment` to fully determine text
alignment on both axes.

Note that this property won't affect the read-only properties
`Class.TextLabel.TextBounds|TextBounds` and
`Class.TextLabel.TextFits|TextFits`.

### `TextLabel.TextYAlignment`

- **Type:** `TextYAlignment`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the vertical alignment of rendered text.

This property determines the vertical alignment of text rendered within
the object's space. It is used in conjunction with
`Class.TextLabel.TextXAlignment|TextXAlignment` to fully determine text
alignment on both axes.

Note that this property won't affect the read-only properties
`Class.TextLabel.TextBounds|TextBounds` and
`Class.TextLabel.TextFits|TextFits`.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Deprecated property `TextLabel.FontSize`: This property is deprecated in favor of `Class.TextLabel|TextSize` which
is an integer and not an enum and thus offers far more options for sizes.
- Deprecated property `TextLabel.TextColor`: This item has been superseded by `Class.TextLabel.TextColor3` which should
be used in all new work.
- Deprecated property `TextLabel.TextWrap`: This property is simply an alias for `Class.TextLabel|TextWrapped`. Use
the past-tense version instead.
- Property `TextLabel.ContentText` security: `read=None, write=None`
- Property `TextLabel.Font` security: `read=None, write=None`
- Property `TextLabel.FontFace` security: `read=None, write=None`
- Property `TextLabel.FontSize` security: `read=None, write=None`
- Property `TextLabel.LineHeight` security: `read=None, write=None`
- Property `TextLabel.LocalizedText` security: `read=None, write=None`
- Property `TextLabel.MaxVisibleGraphemes` security: `read=None, write=None`
- Property `TextLabel.OpenTypeFeatures` security: `read=None, write=None`
- Property `TextLabel.OpenTypeFeaturesError` security: `read=None, write=None`
- Property `TextLabel.RichText` security: `read=None, write=None`
- Property `TextLabel.Text` security: `read=None, write=None`
- Property `TextLabel.TextBounds` security: `read=None, write=None`
- Property `TextLabel.TextColor` security: `read=None, write=None`
- Property `TextLabel.TextColor3` security: `read=None, write=None`
- Property `TextLabel.TextDirection` security: `read=None, write=None`
- Property `TextLabel.TextFits` security: `read=None, write=None`
- Property `TextLabel.TextScaled` security: `read=None, write=None`
- Property `TextLabel.TextSize` security: `read=None, write=None`
- Property `TextLabel.TextStrokeColor3` security: `read=None, write=None`
- Property `TextLabel.TextStrokeTransparency` security: `read=None, write=None`
- Property `TextLabel.TextTransparency` security: `read=None, write=None`
- Property `TextLabel.TextTruncate` security: `read=None, write=None`
- Property `TextLabel.TextWrap` security: `read=None, write=None`
- Property `TextLabel.TextWrapped` security: `read=None, write=None`
- Property `TextLabel.TextXAlignment` security: `read=None, write=None`
- Property `TextLabel.TextYAlignment` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- TextLabel.Font: Show-All-Fonts
- TextLabel.Text: Fading-Banner
- TextLabel.Text: Emoji-in-Text
- TextLabel.TextColor3: Countdown-Text

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/TextLabel
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TextLabel.yaml
- Captured: 2026-04-16
