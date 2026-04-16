---
title: Frame
type: service
category: services
subcategory: gui
owner: ui-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources: [wiki/raw/roblox-creator-docs/services/Frame.md]
related:
  - "[[Instance]]"
  - "[[TextLabel]]"
  - "[[TextButton]]"
  - "[[UIListLayout]]"
  - "[[UICorner]]"
  - "[[UIStroke]]"
tags: [roblox-class, gui, container, ui-layout]
---

# Frame

> A GuiObject that renders as a plain rectangle, primarily used as a container for other GUI elements. [[TextLabel]] [[UIListLayout]]

## Summary

Frame is the fundamental container for 2D user interface layout in Roblox. It renders as a colored rectangle and is used to group, position, and clip child GUI objects. Frames can be placed in ScreenGui (on-screen UI) or SurfaceGui (in-world UI).

Frames are the backbone of responsive layouts. Combined with UIListLayout or UIGridLayout, a Frame automatically arranges its children. Combined with UICorner, UIStroke, and UIPadding, Frames become styled containers with rounded corners, borders, and internal spacing.

Frame inherits all GuiObject properties including Size, Position, AnchorPoint, BackgroundColor3, BackgroundTransparency, BorderSizePixel, and ClipsDescendants. Setting BackgroundTransparency to 1 makes the frame invisible, useful when it serves purely as a layout container.

## API Surface

### Properties

Frame itself adds no properties beyond what GuiObject provides. Key inherited properties:

- `Size: UDim2` -- Width and height using scale (relative) and offset (pixel) components
- `Position: UDim2` -- Position relative to parent
- `AnchorPoint: Vector2` -- Pivot point for positioning (0-1 range for each axis)
- `BackgroundColor3: Color3` -- Fill color
- `BackgroundTransparency: number` -- 0 = opaque, 1 = invisible
- `BorderSizePixel: number` -- Border thickness (0 to hide)
- `ClipsDescendants: boolean` -- If true, children are clipped to the frame bounds
- `Visible: boolean` -- Whether the frame and its children render
- `ZIndex: number` -- Rendering order among siblings (higher = on top)
- `LayoutOrder: number` -- Sort order when inside a UIListLayout or UIGridLayout
- `AutomaticSize: Enum.AutomaticSize` -- None, X, Y, or XY auto-sizing based on content

### Methods

No methods unique to Frame. Inherited from GuiObject and Instance.

### Events

No events unique to Frame. Key inherited events from GuiObject:

- `.InputBegan:Connect(fn(input: InputObject))` -- Fires when mouse/touch enters
- `.InputEnded:Connect(fn(input: InputObject))` -- Fires when mouse/touch leaves
- `.MouseEnter:Connect(fn(x: number, y: number))` -- Mouse hover begin
- `.MouseLeave:Connect(fn(x: number, y: number))` -- Mouse hover end

## Common Patterns

### Basic container with layout

```lua
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 0, 300)  -- full width, 300px tall
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.Padding = UDim.new(0, 8)
layout.Parent = frame
```

### Invisible container (layout-only)

```lua
local container = Instance.new("Frame")
container.BackgroundTransparency = 1
container.Size = UDim2.fromScale(1, 1)
container.Parent = screenGui
```

### Scrollable list container

```lua
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.fromScale(0.4, 0.8)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
```

## Pitfalls

- **Default background is visible**: New Frames have a white background. Set BackgroundTransparency = 1 for invisible containers.
- **ClipsDescendants off by default**: Children can render outside the frame bounds. Enable ClipsDescendants for scroll-like behavior or overflow hiding.
- **ZIndex stacking**: ZIndex only affects siblings (objects with the same parent). Use consistent ZIndex strategies across the UI tree.
- **Scale vs Offset**: UDim2 has both scale (0-1 fraction of parent) and offset (pixels). Mix them carefully -- pure scale for responsive layouts, offset for fixed-size elements.

## Related

- [[Instance]] -- base class
- [[TextLabel]] -- text display element, often a child of Frame
- [[TextButton]] -- interactive text element
- [[UIListLayout]] -- auto-arranges Frame children in a list
- [[UICorner]] -- rounds Frame corners
- [[UIStroke]] -- adds border/outline to Frame

## Sources

- [Roblox Creator Docs](wiki/raw/roblox-creator-docs/services/Frame.md)
