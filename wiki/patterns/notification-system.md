---
title: notification-system
type: pattern
category: patterns
subcategory: ui
owner: ui-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/reactive-notification-system.md
  - wiki/raw/community/articles/game-mechanics/notification-system-basic-tutorial.md
related:
  - "[[achievement-system]]"
  - "[[daily-rewards]]"
  - "[[responsive-design]]"
  - "[[quest-system]]"
tags: [pattern, ui, notifications, tween, queue]
---

# Notification System

> Queue-based notification manager that stacks, animates, and auto-dismisses popups for achievements, level-ups, purchases, and system messages.

## Summary

Most Roblox games need a centralized notification system. Without one, different systems (achievements, purchases, level-ups, chat) each create their own popups, leading to overlapping UI, inconsistent styling, and lost messages. A proper notification manager receives requests from any system, queues them by priority, positions them on screen (typically top-right), animates entry/exit with tweens, and auto-dismisses after a timer.

The pattern runs entirely on the client. The server fires a RemoteEvent with the notification payload; the client module handles display, stacking, and cleanup.

## Implementation

### Notification Types

Define a set of notification categories so each can have its own icon, color, and priority:

```lua
-- ReplicatedStorage/Shared/Config/NotificationConfig.lua
local NotificationConfig = {}

NotificationConfig.Types = {
    Achievement = { icon = "rbxassetid://111111", color = Color3.fromRGB(255, 215, 0), priority = 3 },
    LevelUp     = { icon = "rbxassetid://222222", color = Color3.fromRGB(100, 200, 255), priority = 3 },
    Purchase    = { icon = "rbxassetid://333333", color = Color3.fromRGB(100, 255, 100), priority = 2 },
    System      = { icon = "rbxassetid://444444", color = Color3.fromRGB(200, 200, 200), priority = 1 },
    Error       = { icon = "rbxassetid://555555", color = Color3.fromRGB(255, 80, 80),   priority = 4 },
}

NotificationConfig.DEFAULT_DURATION = 4        -- seconds
NotificationConfig.MAX_VISIBLE = 4             -- max stacked on screen
NotificationConfig.TWEEN_IN_TIME = 0.3         -- seconds
NotificationConfig.TWEEN_OUT_TIME = 0.25       -- seconds
NotificationConfig.STACK_PADDING = 8           -- pixels between stacked items
NotificationConfig.POSITION = "TopRight"       -- TopRight | TopLeft | BottomRight | BottomLeft

return NotificationConfig
```

### Client Module (Queue Manager)

```lua
-- StarterGui/NotificationManager (ModuleScript)
local TweenService = game:GetService("TweenService")
local Config = require(game.ReplicatedStorage.Shared.Config.NotificationConfig)

local NotificationManager = {}

local queue: { NotificationData } = {}
local activeSlots: { [number]: Frame } = {}
local nextSlotIndex = 0

export type NotificationData = {
    type: string,         -- key into Config.Types
    title: string,
    body: string?,
    duration: number?,    -- override default
    icon: string?,        -- override type icon
}

-- Template: a ScreenGui with a hidden notification Frame to clone
local screenGui = script.Parent:WaitForChild("NotificationScreenGui")
local template = screenGui:WaitForChild("NotificationTemplate")
template.Visible = false

local function getAnchorPosition(slotIndex: number): UDim2
    local pos = Config.POSITION
    local yOffset = slotIndex * (template.AbsoluteSize.Y + Config.STACK_PADDING)

    if pos == "TopRight" then
        return UDim2.new(1, -template.AbsoluteSize.X - 12, 0, 12 + yOffset)
    elseif pos == "TopLeft" then
        return UDim2.new(0, 12, 0, 12 + yOffset)
    elseif pos == "BottomRight" then
        return UDim2.new(1, -template.AbsoluteSize.X - 12, 1, -(template.AbsoluteSize.Y + 12 + yOffset))
    elseif pos == "BottomLeft" then
        return UDim2.new(0, 12, 1, -(template.AbsoluteSize.Y + 12 + yOffset))
    end
    return UDim2.new(1, -template.AbsoluteSize.X - 12, 0, 12 + yOffset)
end

local function getOffscreenPosition(slotIndex: number): UDim2
    local anchor = getAnchorPosition(slotIndex)
    -- Slide in from the right (or left) edge
    if Config.POSITION == "TopRight" or Config.POSITION == "BottomRight" then
        return UDim2.new(1, 20, anchor.Y.Scale, anchor.Y.Offset)
    else
        return UDim2.new(0, -template.AbsoluteSize.X - 20, anchor.Y.Scale, anchor.Y.Offset)
    end
end

local function showNotification(data: NotificationData)
    local slotIndex = nextSlotIndex
    if slotIndex >= Config.MAX_VISIBLE then
        -- Queue it for later
        table.insert(queue, data)
        return
    end
    nextSlotIndex += 1

    local typeConfig = Config.Types[data.type] or Config.Types.System
    local duration = data.duration or Config.DEFAULT_DURATION

    -- Clone and populate
    local frame = template:Clone()
    frame.Name = "Notification_" .. slotIndex
    frame.Position = getOffscreenPosition(slotIndex)
    frame.BackgroundColor3 = typeConfig.color

    local titleLabel = frame:FindFirstChild("TitleLabel")
    if titleLabel then titleLabel.Text = data.title end

    local bodyLabel = frame:FindFirstChild("BodyLabel")
    if bodyLabel then bodyLabel.Text = data.body or "" end

    local iconImage = frame:FindFirstChild("IconImage")
    if iconImage then iconImage.Image = data.icon or typeConfig.icon end

    frame.Visible = true
    frame.Parent = screenGui
    activeSlots[slotIndex] = frame

    -- Tween in
    local tweenIn = TweenService:Create(
        frame,
        TweenInfo.new(Config.TWEEN_IN_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = getAnchorPosition(slotIndex) }
    )
    tweenIn:Play()

    -- Auto-dismiss timer
    task.delay(duration, function()
        local tweenOut = TweenService:Create(
            frame,
            TweenInfo.new(Config.TWEEN_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = getOffscreenPosition(slotIndex) }
        )
        tweenOut:Play()
        tweenOut.Completed:Wait()

        frame:Destroy()
        activeSlots[slotIndex] = nil
        nextSlotIndex -= 1

        -- Dequeue next
        if #queue > 0 then
            local next = table.remove(queue, 1)
            showNotification(next)
        end
    end)
end

function NotificationManager.show(data: NotificationData)
    showNotification(data)
end

return NotificationManager
```

### Server-to-Client Bridge

```lua
-- Server: fire notification to a specific player
local NotifyRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Notify")

-- From any server module:
NotifyRemote:FireClient(player, {
    type = "Achievement",
    title = "Achievement Unlocked!",
    body = "First Blood -- Defeat your first enemy.",
})
```

```lua
-- Client: listen and forward to NotificationManager
local NotificationManager = require(script.Parent.NotificationManager)
local NotifyRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Notify")

NotifyRemote.OnClientEvent:Connect(function(data)
    NotificationManager.show(data)
end)
```

### Mobile-Safe Placement

Mobile screens are smaller and have the notch/safe-area inset. Use `GuiService:GetGuiInset()` to offset notifications away from the top status bar:

```lua
local GuiService = game:GetService("GuiService")
local topInset, _ = GuiService:GetGuiInset()
-- Add topInset.Y to all top-positioned notifications
```

## Data Schema

The notification payload sent over RemoteEvent:

```lua
{
    type = "Achievement",   -- string key into Config.Types
    title = "Title Text",   -- required
    body = "Body text",     -- optional
    duration = 5,           -- optional override (seconds)
    icon = "rbxassetid://...", -- optional override
}
```

No persistent storage needed; notifications are ephemeral. The system that triggers the notification (achievements, purchases) owns the persistence.

## Pitfalls

- **Stacking overflow**: Without `MAX_VISIBLE`, rapid-fire events (e.g., a kill streak) flood the screen. Always cap visible count and queue the rest.
- **Tween conflicts**: If a notification is dismissed manually while the auto-dismiss tween is pending, cancel the task with a flag or use `Trove` for cleanup.
- **Frame reuse vs. cloning**: Reusing a single Frame for all notifications causes overlap when multiple fire simultaneously. Always clone from a template.
- **UIListLayout alternative**: Instead of manual position math, use a `UIListLayout` inside a ScrollingFrame. The layout handles stacking; you only manage adding/removing children. Simpler but less control over entry animations.
- **Mobile safe area**: Notifications placed at `UDim2(1, -offset, 0, 0)` can be hidden behind the phone notch. Always account for `GuiService:GetGuiInset()`.
- **RichText injection**: If notification body comes from user-generated content, sanitize to prevent RichText abuse (e.g., massive font sizes, misleading UI).
- **Sound per type**: Play a distinct short SFX per notification type. Use `SoundService` with a `SoundGroup` so players can adjust volume.

## Related

- [[achievement-system]] -- primary consumer of the notification system
- [[daily-rewards]] -- triggers reward-claimed notifications
- [[responsive-design]] -- notification positioning adapts to screen size
- [[quest-system]] -- quest completion triggers notifications

## Sources

- [Reactive and Modern Notification System](wiki/raw/community/articles/game-mechanics/reactive-notification-system.md) -- Fusion 0.3 notification module with spring animations, progress bars, and hover-pause
- [How to Make a Notification System](wiki/raw/community/articles/game-mechanics/notification-system-basic-tutorial.md) -- DevForum basic tutorial with RemoteEvent bridge
- [DevForum: Reactive and Modern Notification System](https://devforum.roblox.com/t/reactive-and-modern-notification-system/4460923)
- [DevForum: How to Make a Notification System](https://devforum.roblox.com/t/how-to-make-a-notification-system/1702064)
- [DevForum: Notification System (Now Free)](https://devforum.roblox.com/t/notification-system-now-free/2541234)
