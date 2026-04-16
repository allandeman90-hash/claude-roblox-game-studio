---
title: Create Custom Chat Channels with TextChatService
type: raw-source
source_url: https://devforum.roblox.com/t/create-custom-chat-channels-with-textchatservice/3041140
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: httpDerpyy
post_date: 2024-06-26
tags: [textchatservice, chat, channels, team-chat, whisper]
---

# Create Custom Chat Channels with TextChatService

**Author:** httpDerpyy
**Posted:** June 26, 2024

## Overview

This tutorial demonstrates how to implement custom chat channels using Roblox's TextChatService API, addressing a gap in the official documentation.

## Key Setup Steps

1. **Create folder structure** within TextChatService:
   - CustomChannels folder
   - CustomCommands folder

2. **Channel creation**: Add TextChannel instances to CustomChannels folder with optional Color3 attributes for styling

3. **Command assignment**: Create TextChatCommand instances in CustomCommands, matching channel names and setting PrimaryAlias/SecondaryAlias properties with custom prefixes

## Implementation Requirements

**Remote Event:** "ChatReplicate" in ReplicatedStorage

**Server Script** ("ChatServer" in ServerScriptService):
- Monitors command triggers
- Manages user addition/removal from channels via `AddUserAsync()`
- Directs client focus using remote events

**Local Script** (StarterPlayerScripts):
- Receives channel redirection signals
- Updates `ChatBar.TargetTextChannel`
- Implements custom formatting with `OnIncomingMessage` to add "channel tags" and colors to messages

## Notable Limitations

The author notes:

> "I could not implement the same behaviour as Team or Whisper Chat, whereas if you press Backspace it returns to Default Chat."

Users must re-run commands to exit channels rather than using keyboard shortcuts.

## Source

Original URL: https://devforum.roblox.com/t/create-custom-chat-channels-with-textchatservice/3041140
Captured: 2026-04-16
