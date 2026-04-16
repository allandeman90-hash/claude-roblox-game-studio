---
title: How to make a custom chat system using TextChatService
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-make-a-custom-chat-system-using-textchatservice/4097288
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: cleventa
post_date: 2025-11-25
tags: [textchatservice, chat, ui, moderation, filtering]
---

# How to Make a Custom Chat System Using TextChatService

**Author:** cleventa
**Posted:** November 25, 2025

## Core Concept

This tutorial demonstrates implementing a basic custom chat GUI integrated with Roblox's TextChatService, which handles filtering and moderation automatically.

## Key Benefits

- Automatic message filtering by Roblox
- Built-in chat moderation
- Automatic age verification and permission handling

## GUI Setup Steps

1. Create a ScreenGui named "CustomChat" in StarterGui
2. Add a ScrollingFrame with customized properties
3. Insert a TextLabel named "DefaultChatMessage"
4. Apply UIGridLayout with CellPadding and CellSize adjustments
5. Set DefaultChatMessage visibility to false

## Core Script Implementation

The main code pattern captures incoming messages:

```lua
local TextChatService = game:GetService("TextChatService")
local TextChannels = TextChatService:WaitForChild("TextChannels")
local RBXGeneral = TextChannels:WaitForChild("RBXGeneral")

RBXGeneral.MessageReceived:Connect(function(incomingMessage: TextChatMessage)
    local PlayerWhoSentMessage = game.Players:FindFirstChild(incomingMessage.TextSource.Name)
    local ChatMessage = incomingMessage.Text --automatically filtered

    if PlayerWhoSentMessage ~= nil then
        local MessageBoxClone = game.Players.LocalPlayer.PlayerGui.CustomChat.ScrollingFrame.DefaultChatMessage:Clone()
        MessageBoxClone.Text = PlayerWhoSentMessage.Name..": "..ChatMessage
        MessageBoxClone.Parent = game.Players.LocalPlayer.PlayerGui.CustomChat.ScrollingFrame
        MessageBoxClone.Visible = true
    end
end)
```

**Notable:** The tutorial clarifies that "custom chat input" requires `TextChannel:SendAsync` for user input handling.

## Source

Original URL: https://devforum.roblox.com/t/how-to-make-a-custom-chat-system-using-textchatservice/4097288
Captured: 2026-04-16
