---
title: "Introducing Accessibility Settings (Roblox Official)"
source_type: devforum-announcement
url: https://devforum.roblox.com/t/introducing-accessibility-settings/2723187
captured: 2026-04-15
tags: [accessibility, reduced-motion, transparency, keyboard-navigation, GuiService]
---

# Roblox Accessibility Settings Announcement

## New Features (2024)

Roblox introduced three accessibility settings available in both in-experience and app settings menus:

1. **Reduced Motion**: Allows users to disable animations and motion-heavy effects
2. **Background Transparency**: Users can adjust UI opacity preferences
3. **Keyboard Navigation**: Players can enable or disable keyboard-based UI shortcuts

## Developer API Access

Two new properties on `GuiService`:

- `GuiService.PreferredTransparency`: Returns the user's transparency preference (number)
- `GuiService.ReducedMotionEnabled`: Indicates if motion reduction is active (boolean)

Developers can monitor changes using `GetPropertyChangedSignal()` to update experiences in real-time:

```lua
local GuiService = game:GetService("GuiService")

GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()
    if GuiService.ReducedMotionEnabled then
        -- Pause or simplify animations
    end
end)
```

## Implementation Guidance

- Pause animations when reduced motion is enabled rather than removing them entirely
- Use fade transitions instead of sliding animations for UI elements
- Multiply default transparency values by the user's preference setting

## Community Feedback Requests

- Colorblindness simulation modes for testing
- Expanded graphical quality settings
- Developer ability to add custom settings to the official menu
- Photosensitivity/flashing light protections
- Touch screen sensitivity customization
