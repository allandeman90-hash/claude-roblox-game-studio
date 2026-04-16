---
title: TextChatService
type: service
category: services
subcategory: chat
owner: ui-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/TextChatService.md
related:
  - "[[Player]]"
tags: [roblox-class, chat]
---

# TextChatService

> Modern in-experience text chat service, handling channels, commands, filtering, and UI customization. [[Player]]

## Summary

TextChatService is the current-generation text chat system for Roblox experiences, replacing the legacy Chat service. It manages `TextChannel` instances for organizing chat into channels, `TextChatCommand` for slash commands, automatic text filtering, message decoration, and supports both classic chat windows and bubble chat.

The service includes singleton children for UI configuration: `ChatWindowConfiguration`, `ChatInputBarConfiguration`, `BubbleChatConfiguration`, and `ChannelTabsConfiguration`. These allow customizing appearance (colors, fonts, sizes, positions) without writing code. For fully custom chat UIs, developers can build their own frontend and wire it to TextChatService's backend.

All player-sent text is automatically filtered by Roblox. For dynamic text displayed in the world (e.g., signs, name tags), use `TextService:FilterStringAsync()` separately. Chat translation is built in -- when enabled, received messages are translated to the reader's preferred language.

## API Surface

### Properties

- `CreateDefaultTextChannels: boolean` -- Whether default channels (RBXGeneral, RBXSystem, RBXTeam, RBXWhisper) are created automatically.
- `CreateDefaultCommands: boolean` -- Whether default slash commands (/mute, /unmute, /version, etc.) are created.
- `ChatTranslationEnabled: boolean` -- Whether received messages are auto-translated (read-only, user-controlled).

### Methods

- `:DisplayBubble(partOrCharacter: Instance, message: string) -> ()` -- Shows a chat bubble above the specified part or character model.

### Events

- `.MessageReceived:Connect(fn(textChatMessage: TextChatMessage))` -- Fires on the client when a message is received in any channel. Use for custom UI rendering.
- `.SendingMessage:Connect(fn(textChatMessage: TextChatMessage))` -- Fires on the client when the local player sends a message, before it is delivered.
- `.OnIncomingMessage: (textChatMessage: TextChatMessage) -> TextChatMessageProperties?` -- Callback to modify how incoming messages appear (prefix, color, font).

### Key Child Classes

- `TextChannel` -- Represents a chat channel. Use `:SendAsync(message)` to send, `.MessageReceived` to receive.
- `TextChatCommand` -- Custom slash commands with a trigger string and callback.
- `ChatWindowConfiguration` -- Customize the default chat window appearance.
- `BubbleChatConfiguration` -- Customize bubble chat appearance.

## Budgets and Limits

- All text is filtered server-side. There is no way to bypass filtering.
- Message rate limits are enforced per player (typically ~7 messages per 15 seconds).
- Slash command names must be unique and start with `/`.

## Common Patterns

### Custom slash command

```lua
-- ServerScriptService or LocalScript
local TextChatService = game:GetService("TextChatService")

local command = Instance.new("TextChatCommand")
command.Name = "CoinFlipCommand"
command.PrimaryAlias = "/coinflip"
command.SecondaryAlias = "/flip"
command.Triggered:Connect(function(originTextSource, unfilteredText)
    local result = math.random(2) == 1 and "Heads" or "Tails"
    -- Display result to the channel
end)
command.Parent = TextChatService
```

## Pitfalls

- **Legacy chat deprecated**: `ChatVersion` property exists but TextChatService is the only allowed system in new experiences.
- **Filtering is mandatory**: All text goes through Roblox's filter. You cannot send unfiltered text to players.
- **OnIncomingMessage is a callback, not an event**: Assign a function to it, do not use `:Connect()`.
- **TextChannel:SendAsync requires client**: Messages must be sent from client-side code (TextChannel:SendAsync). The server can add system messages via `TextChannel:DisplaySystemMessage()`.

## Related

- [[Player]] -- the Chatted event still fires for legacy compatibility

## Sources

- [wiki/raw/roblox-creator-docs/services/TextChatService.md](../raw/roblox-creator-docs/services/TextChatService.md)
