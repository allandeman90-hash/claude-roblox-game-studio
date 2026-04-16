---
title: "Reactive and Modern Notification System"
source_url: "https://devforum.roblox.com/t/reactive-and-modern-notification-system/4460923"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: notification-system
---

# Reactive Notification System (Fusion 0.3)

## Core Usage

```lua
local Notification = require(ReplicatedStorage.Notifications.Notification)
Notification({ Type = "String", Content = "Hello world!" })
```

## Notification Types

1. **String Type**: Text-based with RichText support (`<b>`, `<i>`, `<font color>`)
2. **Viewport Type**: Model-based with orbiting camera visualization

## Configuration Properties

| Property     | Type    | Default   | Purpose                        |
|-------------|---------|-----------|--------------------------------|
| Type        | string  | "String"  | Content mode selection         |
| Style       | string  | "Modern"  | Visual preset (Modern, Minimal, Bold, Classic) |
| Duration    | number  | 3.0       | Auto-dismiss timing in seconds |
| ShowProgress| boolean | true      | Visibility of progress bar     |
| Persistent  | boolean | false     | Disables auto-dismissal        |
| Icon        | string  | nil       | Asset ID for display image     |
| Option1/2   | table   | nil       | Interactive button config      |

## Signal System

Each notification returns a signals table:

- `OnOption1` - fires when first button is selected
- `OnOption2` - fires when second button is selected
- `OnDismissed` - fires after fade-out completes

## Position Presets

```lua
Notification.setPosition("TopRight")
-- Available: TopLeft, TopCenter, TopRight, BottomLeft, BottomCenter, BottomRight
```

## Architecture

Spring-driven entrance/exit animations, progress bar with color transition (white to red), hover-pause on PC (freezes timer on MouseEnter), automatic scope cleanup per notification instance via Fusion 0.3 state management.
