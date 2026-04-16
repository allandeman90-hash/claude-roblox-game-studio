---
title: Accessibility Patterns
type: pattern
category: patterns
subcategory: ui
owner: accessibility-specialist
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/ui-frameworks/accessibility-settings-devforum.md
related:
  - "[[responsive-design]]"
  - "[[ui-framework-comparison]]"
tags: [accessibility, reduced-motion, transparency, keyboard-navigation, color-contrast, touch-targets]
---

# Accessibility Patterns

> Roblox provides platform-level accessibility settings that developers can query and respect. Building accessible experiences is both ethical and practical -- it expands the player base.

## What It Is

Patterns for making Roblox experiences usable by players with visual, motor, cognitive, or auditory needs. Roblox exposes accessibility preferences via `GuiService` properties that developers should honor.

## When to Use It

Every project. Accessibility is not optional -- Roblox's audience includes players with disabilities, and the platform increasingly enforces accessibility standards.

## Implementation

### Respecting Reduced Motion

```lua
local GuiService = game:GetService("GuiService")

local function animateUI(element, targetProps, duration)
    if GuiService.ReducedMotionEnabled then
        -- Instant transition, no animation
        for prop, value in pairs(targetProps) do
            element[prop] = value
        end
    else
        local tween = TweenService:Create(element,
            TweenInfo.new(duration, Enum.EasingStyle.Quad),
            targetProps)
        tween:Play()
    end
end

-- Monitor preference changes
GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()
    -- Re-evaluate any ongoing animations
end)
```

**Guidelines:**
- Pause or simplify animations, do not remove them entirely
- Use fade transitions instead of sliding/bouncing
- Disable particle effects that flash or pulse rapidly

### Respecting Background Transparency

```lua
local function applyTransparency(element, baseTransparency)
    element.BackgroundTransparency = baseTransparency * GuiService.PreferredTransparency
end

GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
    -- Reapply transparency to all UI elements
end)
```

### Color Contrast

Aim for WCAG 2.1 AA standard:
- **Normal text**: 4.5:1 contrast ratio minimum
- **Large text** (18pt+ or 14pt bold): 3:1 contrast ratio minimum
- **Non-text elements** (icons, borders): 3:1 contrast ratio minimum

```lua
-- Do not convey information through color alone
-- BAD: Red text means error, green means success
-- GOOD: Icon + text label + color together indicate state
```

### Touch Targets

Minimum sizes for mobile:
- **Interactive elements**: 44x44 pixels minimum (~UDim2.fromScale(0.12, 0.06) on typical phones)
- **Spacing between targets**: 6+ pixels of inactive space
- **Bottom-of-screen placement**: Easier thumb reach on phones

### Keyboard Navigation

Support for players who cannot use mouse/touch:
- Tab-order through interactive elements
- Visual focus indicators on the currently selected element
- Enter/Space to activate buttons
- Escape to close modals

## Pitfalls

- Ignoring `ReducedMotionEnabled` can trigger photosensitive reactions in some players.
- Setting `BackgroundTransparency` without multiplying by `PreferredTransparency` overrides user preference.
- Color-only indicators (red = bad, green = good) are invisible to colorblind players. Always pair color with icon or text.
- Small touch targets on mobile cause accidental taps and frustration.

## Related

- [[responsive-design]]
- [[ui-framework-comparison]]

## Sources

- [Roblox Accessibility Settings Announcement](wiki/raw/community/articles/ui-frameworks/accessibility-settings-devforum.md)
