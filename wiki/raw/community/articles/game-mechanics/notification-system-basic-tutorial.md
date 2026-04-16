---
title: "How to Make a Notification System"
source_url: "https://devforum.roblox.com/t/how-to-make-a-notification-system/1702064"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: notification-system
---

# Basic Notification System Tutorial

## ScreenGui Setup

- ScreenGui named "Notification" in StarterGui
- Frame named "Notifications" as the container
- TextLabel for displaying messages
- LocalScript for client-side handling

## Client-Side Listener

```lua
local Event = game.ReplicatedStorage.Events.Notification

Event.OnClientEvent:Connect(function(val)
    if val == true then
        ErrorSound:Play()
        script.Parent.Visible = true
        script.Parent.Text = "Your text here"
        wait(3)
        script.Parent.Visible = false
        script.Parent.Text = ""
    end
end)
```

## Server-Side Trigger

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
local Notification = EventsFolder:FindFirstChild("Notification")

Notification:FireClient(player, true)
```

## Multiple Notification Types

Change `if val == true` to `if val == "identifier"` and pass string identifiers instead of boolean values to support multiple notification types.

## Community Recommendation

Clone the label template rather than reusing one element, with UIListLayout for stacking multiple notifications simultaneously.
