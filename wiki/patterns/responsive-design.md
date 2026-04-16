---
title: Responsive Design
type: pattern
category: patterns
subcategory: ui
owner: ui-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/ui-frameworks/responsive-gui-all-devices-devforum.md
  - wiki/raw/community/articles/ui-frameworks/udim2-anchorpoint-positioning-devforum.md
  - wiki/raw/community/articles/ui-frameworks/accessibility-settings-devforum.md
related:
  - "[[ui-framework-comparison]]"
tags: [ui, responsive, mobile, UDim2, AnchorPoint, UIAspectRatioConstraint, accessibility]
---

# Responsive Design

> Techniques for building Roblox UIs that adapt to mobile phones, tablets, desktops, consoles, and VR headsets without per-device layouts.

## What It Is

Responsive design ensures UI elements scale, reposition, and remain usable across Roblox's supported platforms. Since Roblox runs on devices from 4-inch phones to 27-inch monitors, UI must be resolution-independent by default.

## When to Use It

Every Roblox project. There is no scenario where ignoring responsive design is acceptable -- Roblox's player base is majority mobile.

## Core Principles

### 1. Scale Over Offset

UDim2 has two components per axis: Scale (0-1, proportional) and Offset (pixels, fixed).

```lua
-- GOOD: Responsive
frame.Size = UDim2.fromScale(0.3, 0.1)
frame.Position = UDim2.fromScale(0.5, 0.9)

-- BAD: Fixed pixels, breaks on different screens
frame.Size = UDim2.fromOffset(400, 60)
frame.Position = UDim2.fromOffset(960, 1000)
```

**Rule**: Use Scale for positioning and sizing. Use Offset only for small fixed padding (e.g., 8px gaps between elements).

### 2. AnchorPoint Alignment

AnchorPoint determines which point within an element serves as the positioning reference.

| Placement | AnchorPoint | Position (Scale) |
|-----------|-------------|------------------|
| Top-Left | (0, 0) | (0, 0) |
| Center | (0.5, 0.5) | (0.5, 0.5) |
| Bottom-Center | (0.5, 1) | (0.5, 1) |
| Bottom-Right | (1, 1) | (1, 1) |

**Rule**: AnchorPoint and Scale values should be 0, 0.5, or 1. If they are anything else (e.g., 0.449), the layout is likely fragile.

### 3. UIAspectRatioConstraint

Prevents elements from distorting when parent dimensions change disproportionately.

```lua
local constraint = Instance.new("UIAspectRatioConstraint")
constraint.AspectRatio = 2  -- Width:Height = 2:1
constraint.Parent = frame
```

Use on: icons, buttons, cards, and any element with a fixed visual ratio.

### 4. Layout Objects

Roblox provides automatic layout instances:

- **UIListLayout**: Arranges children in a row or column with configurable padding, alignment, and sort order.
- **UIGridLayout**: Arranges children in a grid with configurable cell size.
- **UIPageLayout**: Arranges children as swipeable pages.
- **UITableLayout**: Table-like arrangement.

```lua
local list = Instance.new("UIListLayout")
list.FillDirection = Enum.FillDirection.Vertical
list.Padding = UDim.new(0, 8)  -- 8px gap between items
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Parent = scrollFrame
```

### 5. Device Detection and Adaptive Layout

```lua
local UserInputService = game:GetService("UserInputService")

local function getDeviceType(): string
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.GamepadEnabled then
        return "Console"
    else
        return "Desktop"
    end
end
```

Adapt UI based on device:
- **Mobile**: Larger touch targets (minimum 44x44 pixels / ~UDim2.fromScale(0.12, 0.06)), bottom-aligned action buttons, simplified layouts.
- **Console**: D-pad navigation support, larger text, focus indicators.
- **Desktop**: Hover states, keyboard shortcuts, denser layouts.

### 6. Safe Zones (Inset)

Modern devices have notches, rounded corners, and system UI overlays. Use `GuiService:GetGuiInset()` to account for the top bar:

```lua
local GuiService = game:GetService("GuiService")
local topInset, bottomInset = GuiService:GetGuiInset()
```

Position critical UI elements away from screen edges on mobile.

## Accessibility Integration

Roblox exposes accessibility preferences via `GuiService`:

```lua
local GuiService = game:GetService("GuiService")

-- Respect user's transparency preference
local transparency = GuiService.PreferredTransparency
frame.BackgroundTransparency = 0.3 * transparency

-- Respect reduced motion preference
if GuiService.ReducedMotionEnabled then
    -- Use instant transitions instead of tweens
    frame.Position = targetPosition
else
    TweenService:Create(frame, tweenInfo, {Position = targetPosition}):Play()
end
```

Monitor changes:
```lua
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()
    -- Update animation behavior
end)
```

### Accessibility Checklist
- [ ] Text contrast ratio >= 4.5:1 against background
- [ ] Touch targets >= 44x44 pixels with >= 6px spacing
- [ ] Respect `ReducedMotionEnabled` for animations
- [ ] Respect `PreferredTransparency` for backgrounds
- [ ] Provide keyboard navigation for interactive elements
- [ ] Do not convey information through color alone

## Pitfalls

- Using Offset for sizes creates pixel-perfect desktop UI that is unusable on mobile.
- Automatic scale plugins produce imprecise values (e.g., 0.449) that break on unexpected resolutions.
- Forgetting UIAspectRatioConstraint on icons and buttons causes visual distortion on wide/tall screens.
- Testing only on the Studio default resolution misses mobile and ultra-wide edge cases.
- Ignoring `GuiService:GetGuiInset()` places UI under the Roblox top bar.

## Related

- [[ui-framework-comparison]]

## Sources

- [Responsive GUI for All Devices](wiki/raw/community/articles/ui-frameworks/responsive-gui-all-devices-devforum.md)
- [UDim2 & AnchorPoint Positioning Guide](wiki/raw/community/articles/ui-frameworks/udim2-anchorpoint-positioning-devforum.md)
- [Roblox Accessibility Settings](wiki/raw/community/articles/ui-frameworks/accessibility-settings-devforum.md)
