---
title: UIListLayout
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/UIListLayout
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UIListLayout.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui-layout
tags: [roblox-class, gui, layout, list]
---

# UIListLayout

Positions sibling UI elements in rows or columns within the parent UI
container.

## Description

A `Class.UIListLayout` positions sibling UI elements in rows or columns within
the parent UI container, based on the
`Class.UIListLayout.FillDirection|FillDirection`. The
`Class.GuiObject.Position|Position` and `Class.GuiObject.Rotation|Rotation`
properties of each sibling `Class.GuiObject` are either ignored or overridden
by the list layout, while each sibling retains its defined
`Class.GuiObject.Size|Size` unless the layout is configured to utilize a flex
layout. See [List and Flex Layouts](../../../ui/list-flex-layouts.md) for
further information.

<img src="../../../assets/engine-api/classes/UIListLayout/FillDirection.png"
width="720" alt="UIListLayouts illustrating FillDirection of either horizontal
or vertical." />

To control the layout order of siblings, set
`Class.UIListLayout.SortOrder|SortOrder` to either `Enum.SortOrder.Name` or
`Enum.SortOrder.LayoutOrder`, then rename siblings in alphanumerical order or
set their `Class.GuiObject.LayoutOrder|LayoutOrder` value, respectively.
`Class.UIListLayout` will automatically re‑layout elements when elements are
added/removed, or if a sibling's `Class.Instance.Name|Name` or
`Class.GuiObject.LayoutOrder|LayoutOrder` changes.

<img src="../../../assets/engine-api/classes/UIListLayout/SortOrder.png"
width="720" alt="List layout examples illustrating numerical LayoutOrder
sorting or alphanumerical Name sorting." />

Padding between siblings is controlled through the
`Class.UIListLayout.Padding|Padding` property, and wrapping within the parent
container's bounds through the `Class.UIListLayout.Wraps|Wraps` boolean.
Alignment of siblings within the parent container is controlled through
`Class.UIListLayout.HorizontalAlignment|HorizontalAlignment` and
`Class.UIListLayout.VerticalAlignment|VerticalAlignment` unless the layout is
configured to utilize a
[flex layout](../../../ui/list-flex-layouts.md#flex-layouts).

Note that there are performance implications of using a
[flex‑enabled](../../../ui/list-flex-layouts.md#flex-layouts) list layout,
since extra calculations are needed to calculate flex basis sizes, flexed
sizes, and line wrapping. Flex is enabled on a `Class.UIListLayout` when the
following properties are set, or if any `Class.GuiObject` sibling has a
`Class.UIFlexItem` parented to it:

- `Class.UIListLayout.HorizontalFlex|HorizontalFlex` and/or
  `Class.UIListLayout.VerticalFlex|VerticalFlex` are **not** set to
  `Enum.UIFlexAlignment.None`.
- `Class.UIListLayout.ItemLineAlignment|ItemLineAlignment` is **not** set to
  `Enum.ItemLineAlignment.Automatic`.
- `Class.UIListLayout.Wraps|Wraps` is `true`.

## Inheritance

Inherits from: `UIGridStyleLayout`

Memory category: `Instances`

## Properties

### `UIListLayout.HorizontalFlex`

- **Type:** `UIFlexAlignment`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Controls how to distribute extra horizontal space.

When the list layout's `Class.UIListLayout.FillDirection|FillDirection` is
set to `Enum.FillDirection.Horizontal`, the
`Class.UIListLayout.HorizontalFlex|HorizontalFlex` property specifies how
to distribute extra horizontal space in the parent container.

<table size="small">
  <thead>
    <tr>
      <th>Setting</th>
      <th>Sibling Behavior</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>Enum.UIFlexAlignment.None|None</code></td>
      <td>No flex behavior; siblings maintain their defined width.</td>
    </tr>
    <tr>
      <td><code>Enum.UIFlexAlignment.Fill|Fill</code></td>
      <td>Siblings resize horizontally to fill the entire parent container, overriding their defined width. The number of siblings in a row remain unchanged; for example, if three siblings fit horizontally within the container's width under the <code>Enum.UIFlexAlignment.None|None</code> setting, those three siblings will resize to fill the entire width.</td>
    </tr>
    <tr>
      <td><code>Enum.UIFlexAlignment.SpaceAround|SpaceAround</code></td>
      <td>Siblings maintain their defined width. Equal spacing is added on both sides of each sibling.</td>
    </tr>
    <tr>
      <td><code>Enum.UIFlexAlignment.SpaceBetween|SpaceBetween</code></td>
      <td>Siblings maintain their defined width. Equal spacing is added <b>between</b> siblings, but no additional space is added <b>around</b> siblings.</td>
    </tr>
    <tr>
      <td><code>Enum.UIFlexAlignment.SpaceEvenly|SpaceEvenly</code></td>
      <td>Siblings maintain their defined width. Equal spacing is added both <b>between</b> and <b>around</b> siblings.</td>
    </tr>
  </tbody>
</table>

<img src="../../../assets/engine-api/classes/UIListLayout/HorizontalFlex-Options.png" width="800" alt="UIListLayout examples showing how each HorizontalFlex option affects the size and spacing of sibling UI objects." />

##### Cross-Direction Behavior

In **vertical** list layouts
(`Class.UIListLayout.FillDirection|FillDirection` set to
`Enum.FillDirection.Vertical`), the
`Class.UIListLayout.HorizontalFlex|HorizontalFlex` property specifies how
to distribute the siblings across the **horizontal cross‑direction**. In
such layouts, a setting of `Enum.UIFlexAlignment.Fill` makes the siblings
fill the entire horizontal space while vertical spacing adheres to
`Class.UIListLayout.VerticalFlex|VerticalFlex`.

<img src="../../../assets/engine-api/classes/UIListLayout/HorizontalFlex-Cross-Direction.png" width="720" alt="Diagram showing how HorizontalFlex affects the horizontal size of sibling UI objects when the UIListLayout fill direction is set to vertical." />

##### AutomaticSize Interaction

If `Class.GuiObject.AutomaticSize` is enabled for a child of the
`Class.UIListLayout` in the
`Class.UIListLayout.FillDirection|FillDirection`, it is interpreted as
"automatic flex basis" and it defines the size of the `Class.GuiObject`
from which it can grow or shrink.

If `Class.GuiObject.AutomaticSize` is enabled for a child of the
`Class.UIListLayout` in the **cross‑direction**, it is interpreted as
"automatic cross size" and it defines the minimum size needed to contain
all the child's content in the cross‑direction.

### `UIListLayout.ItemLineAlignment`

- **Type:** `ItemLineAlignment`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

In a flex layout, defines the **cross-directional** alignment of siblings
within a line.

In a [flex layout](../../../ui/list-flex-layouts.md#flex-layouts), defines
the **cross-directional** alignment of siblings within a line. See
`Enum.ItemLineAlignment` for visual examples.

<table size="small">
  <thead>
    <tr>
      <th>Setting</th>
      <th>Sibling Behavior</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>Enum.ItemLineAlignment.Automatic|Automatic</code></td>
      <td>Aligns the layout's siblings or the specific <code>Class.UIFlexItem</code> parent to the layout's <code>Class.UIListLayout.HorizontalAlignment|HorizontalAlignment</code> or <code>Class.UIListLayout.VerticalAlignment|VerticalAlignment</code>, depending on its <code>Class.UIListLayout.FillDirection|FillDirection</code>.</td>
    </tr>
    <tr>
      <td><code>Enum.ItemLineAlignment.Start|Start</code></td>
      <td>Aligns the layout's siblings or the specific <code>Class.UIFlexItem</code> parent to the line's <b>top</b> in a horizontal fill or the line's <b>left</b> in a vertical fill.</td>
    </tr>
    <tr>
      <td><code>Enum.ItemLineAlignment.Center|Center</code></td>
      <td>Aligns the layout's siblings or the specific <code>Class.UIFlexItem</code> parent to the line's <b>center</b> in either a horizontal or vertical fill.</td>
    </tr>
    <tr>
      <td><code>Enum.ItemLineAlignment.End|End</code></td>
      <td>Aligns the layout's siblings or the specific <code>Class.UIFlexItem</code> parent to the line's <b>bottom</b> in a horizontal fill or the line's <b>right</b> in a vertical fill.</td>
    </tr>
    <tr>
      <td><code>Enum.ItemLineAlignment.Stretch|Stretch</code></td>
      <td>Stretches the layout's siblings or the specific <code>Class.UIFlexItem</code> parent to fill the entire cross‑direction of the line in either a horizontal or vertical fill.</td>
    </tr>
  </tbody>
</table>

<img src="../../../assets/engine-api/classes/UIListLayout/ItemLineAlignment.png" width="720" alt="Examples of options for ItemLineAlignment in a horizontal fill direction." />

### `UIListLayout.Padding`

- **Type:** `UDim`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Amount of free space between each element.

Determines the amount of free space between each element, set to either a
scale (percentage of the parent's size in the current direction) or an
offset (static spacing value similar to pixel size).

### `UIListLayout.VerticalFlex`

- **Type:** `UIFlexAlignment`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Controls how to distribute extra vertical space.

When the list layout's `Class.UIListLayout.FillDirection|FillDirection` is
set to `Enum.FillDirection.Vertical`, the
`Class.UIListLayout.VerticalFlex|VerticalFlex` property specifies how to
distribute extra vertical space in the parent container.

<table size="small">
  <thead>
    <tr>
      <th>Setting</th>
      <th>Sibling Behavior</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>Enum.UIFlexAlignment.None|None</code></td>
      <td>No flex behavior; siblings maintain their defined height.</td>
    </tr>
    <tr>
      <td><code>Enum.UIFlexAlignment.Fill|Fill</code></td>
      <td>Siblings resize vertically to fill the entire parent container, overriding their defined height. The number of siblings in a column remain unchanged; for example, if three siblings fit vertically within the container's height under the <code>Enum.UIFlexAlignment.None|None</code> setting, those three siblings will resize to fill the entire height.</td>
    </tr>
    <tr>
      <td><code>Enum.UIFlexAlignment.SpaceAround|SpaceAround</code></td>
      <td>Siblings maintain their defined height. Equal spacing is added on both sides of each sibling.</td>
    </tr>
    <tr>
      <td><code>Enum.UIFlexAlignment.SpaceBetween|SpaceBetween</code></td>
      <td>Siblings maintain their defined height. Equal spacing is added <b>between</b> siblings, but no additional space is added <b>around</b> siblings.</td>
    </tr>
    <tr>
      <td><code>Enum.UIFlexAlignment.SpaceEvenly|SpaceEvenly</code></td>
      <td>Siblings maintain their defined height. Equal spacing is added both <b>between</b> and <b>around</b> siblings.</td>
    </tr>
  </tbody>
</table>

<img src="../../../assets/engine-api/classes/UIListLayout/VerticalFlex-Options.png" width="800" alt="UIListLayout examples showing how each VerticalFlex option affects the size and spacing of sibling UI objects." />

##### Cross-Direction Behavior

In **horizontal** list layouts
(`Class.UIListLayout.FillDirection|FillDirection` set to
`Enum.FillDirection.Horizontal`), the
`Class.UIListLayout.VerticalFlex|VerticalFlex` property specifies how to
distribute the siblings across the **vertical cross direction**. In such
layouts, a setting of `Enum.UIFlexAlignment.Fill` makes the siblings fill
the entire vertical space while horizontal spacing adheres to
`Class.UIListLayout.HorizontalFlex|HorizontalFlex`.

<img src="../../../assets/engine-api/classes/UIListLayout/VerticalFlex-Cross-Direction.png" width="720" alt="Diagram showing how VerticalFlex affects the vertical size of sibling UI objects when the UIListLayout fill direction is set to horizontal." />

##### AutomaticSize Interaction

If `Class.GuiObject.AutomaticSize` is enabled for a child of the
`Class.UIListLayout` in the
`Class.UIListLayout.FillDirection|FillDirection`, it is interpreted as
"automatic flex basis" and it defines the size of the `Class.GuiObject`
from which it can grow or shrink.

If `Class.GuiObject.AutomaticSize` is enabled for a child of the
`Class.UIListLayout` in the **cross‑direction**, it is interpreted as
"automatic cross size" and it defines the minimum size needed to contain
all the child's content in the cross‑direction.

### `UIListLayout.Wraps`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Controls whether siblings within the parent container wrap.

Controls whether siblings within the parent container wrap to another line
when their default size exceeds the width/height of the container's
bounds.

<img src="../../../assets/engine-api/classes/UIListLayout/Wraps.png" width="800" alt="Diagram showing how Wraps affects how siblings are distributed within the parent container's bounds." />

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `UIListLayout.HorizontalFlex` security: `read=None, write=None`
- Property `UIListLayout.ItemLineAlignment` security: `read=None, write=None`
- Property `UIListLayout.Padding` security: `read=None, write=None`
- Property `UIListLayout.VerticalFlex` security: `read=None, write=None`
- Property `UIListLayout.Wraps` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/UIListLayout
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UIListLayout.yaml
- Captured: 2026-04-16
