---
title: TextLabel
type: service
category: services
subcategory: gui
owner: ui-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources: [wiki/raw/roblox-creator-docs/services/TextLabel.md]
related:
  - "[[Instance]]"
  - "[[Frame]]"
  - "[[TextButton]]"
  - "[[UIStroke]]"
tags: [roblox-class, gui, text, display]
---

# TextLabel

> A 2D GUI element that displays non-interactive styled text. [[Frame]] [[TextButton]]

## Summary

TextLabel renders a rectangle with styled text. It is the standard element for displaying text in Roblox UI -- health displays, titles, descriptions, notification messages, scoreboards, and any static text content.

TextLabel inherits from GuiObject, so it has all the positioning, sizing, and appearance properties of a Frame, plus text-specific properties for font, color, size, alignment, scaling, wrapping, and rich text formatting.

The key distinction from TextButton is that TextLabel is non-interactive -- it does not respond to clicks. Use TextButton when the text element needs to be clickable.

## API Surface

### Properties (key subset)
- `Text: string` -- The displayed text content
- `TextColor3: Color3` -- Text color
- `TextSize: number` -- Font size in pixels
- `TextScaled: boolean` -- If true, text auto-scales to fill the element (use with UITextSizeConstraint)
- `TextWrapped: boolean` -- Whether text wraps to multiple lines
- `TextXAlignment: Enum.TextXAlignment` -- Horizontal alignment (Left, Center, Right)
- `TextYAlignment: Enum.TextYAlignment` -- Vertical alignment (Top, Center, Bottom)
- `Font: Enum.Font` -- The font face (legacy; prefer FontFace)
- `FontFace: Font` -- Modern font specification with family, weight, style
- `RichText: boolean` -- Enables HTML-like markup tags for bold, italic, color, etc.
- `TextTruncate: Enum.TextTruncate` -- How to truncate overflow text (None, AtEnd)
- `TextFits: boolean` -- Read-only. Whether the text fits within the element bounds
- `ContentText: string` -- Read-only. The rendered text after rich text tags are processed
- `MaxVisibleGraphemes: number` -- Controls how many characters are visible (useful for typewriter effects). -1 = all
- `LineHeight: number` -- Line spacing multiplier. Default 1

All GuiObject properties are also available (Size, Position, BackgroundColor3, BackgroundTransparency, etc.).

### Methods

No methods unique to TextLabel.

### Events

No events unique to TextLabel. Inherited GuiObject events (InputBegan, MouseEnter, etc.) are available but TextLabel is not designed for interaction.

## Common Patterns

### Basic text display

```lua
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 200, 0, 50)
label.Position = UDim2.new(0.5, -100, 0, 10)
label.BackgroundTransparency = 1
label.Text = "Health: 100"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 24
label.Font = Enum.Font.GothamBold
label.Parent = screenGui
```

### Rich text formatting

```lua
local label = Instance.new("TextLabel")
label.RichText = true
label.Text = '<b>Bold</b>, <i>italic</i>, <font color="#ff0000">red</font>'
label.Parent = screenGui
```

### Typewriter effect with MaxVisibleGraphemes

```lua
local label = screenGui.TypewriterLabel
label.MaxVisibleGraphemes = 0

local fullText = "Welcome to the adventure..."
label.Text = fullText

for i = 1, utf8.len(fullText) do
    label.MaxVisibleGraphemes = i
    task.wait(0.03)
end
```

### Auto-scaling text with constraints

```lua
local label = Instance.new("TextLabel")
label.TextScaled = true
label.Parent = frame

-- Prevent text from getting too small or too large
local constraint = Instance.new("UITextSizeConstraint")
constraint.MinTextSize = 12
constraint.MaxTextSize = 48
constraint.Parent = label
```

## Pitfalls

- **TextScaled without constraints**: TextScaled alone can shrink text to unreadable sizes on small screens. Always pair with UITextSizeConstraint (minimum size 9-12).
- **Default background visible**: New TextLabels have a visible background. Set BackgroundTransparency = 1 for text-only display.
- **RichText XSS-like concerns**: If displaying user-generated content with RichText enabled, users could inject formatting tags. Sanitize or disable RichText for UGC.
- **TextFits is read-only**: Cannot be set; it is a diagnostic property. Use TextScaled or adjust Size to ensure text fits.
- **Font vs FontFace**: Font is the legacy enum. FontFace provides finer control (weight, style). Prefer FontFace for new code.

## Related

- [[Instance]] -- base class
- [[Frame]] -- container element, often the parent of TextLabel
- [[TextButton]] -- interactive version of TextLabel
- [[UIStroke]] -- can add text outline/border effects

## Sources

- [Roblox Creator Docs](wiki/raw/roblox-creator-docs/services/TextLabel.md)
