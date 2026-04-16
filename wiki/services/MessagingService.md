---
title: MessagingService
type: service
category: services
subcategory: networking
owner: live-ops-specialist
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/MessagingService.md
related:
  - "[[MemoryStoreService]]"
  - "[[cross-server-events]]"
tags: [roblox-class, networking, live-ops]
---

# MessagingService

> Real-time pub/sub messaging between servers of the same experience. [[MemoryStoreService]]

## Summary

MessagingService allows servers of the same experience to communicate with each other in real time (less than 1 second) using **topics**. Topics are developer-defined strings (1-80 characters) that servers use to send and receive messages. A server publishes a message to a topic, and all servers subscribed to that topic receive it via a registered callback.

Delivery is **best-effort and not guaranteed**. Architects should design experiences so that delivery failures are not critical. For durable cross-server shared state, pair with [[MemoryStoreService]]. For publishing messages from outside the experience (e.g., admin tools), use the Open Cloud Messaging API.

Common use cases include global announcements, cross-server boss spawns, live event triggers, cross-server chat, and coordinating server shutdowns.

## API Surface

### Properties

_No public properties._

### Methods

- `:PublishAsync(topic: string, message: any) -> ()` -- Sends a message to all subscribers of the topic. Yields until the backend acknowledges. Message payload max 1 KB.
- `:SubscribeAsync(topic: string, callback: (message: {Data: any, Sent: number}) -> ()) -> RBXScriptConnection` -- Registers a callback for the topic. The callback receives a table with `Data` (the payload) and `Sent` (Unix timestamp). Yields until subscribed. Call `:Disconnect()` on the returned connection to unsubscribe.

### Events

_No public events._

## Budgets and Limits

- **Message size**: 1 KB maximum
- **Topic name length**: 1-80 characters
- **Messages sent per server**: 600 + 240 x (number of players in server) per minute
- **Messages received per topic**: (40 + 80 x number of servers) per minute
- **Messages received for entire game**: (400 + 200 x number of servers) per minute
- **Subscriptions per server**: 20 + 8 x (number of players in server)
- **Subscribe requests per server**: 240 per minute

## Common Patterns

### Global announcement system

```lua
-- ServerScriptService/Announcements.server.lua
local MessagingService = game:GetService("MessagingService")

-- Subscribe to announcements
local success, connection = pcall(function()
    return MessagingService:SubscribeAsync("GlobalAnnouncement", function(message)
        -- Broadcast to all players in this server
        for _, player in game.Players:GetPlayers() do
            -- Fire a RemoteEvent to show the announcement
            game.ReplicatedStorage.AnnouncementRemote:FireClient(player, message.Data)
        end
    end)
end)

-- Publish from an admin command
local function sendAnnouncement(text: string)
    pcall(function()
        MessagingService:PublishAsync("GlobalAnnouncement", text)
    end)
end
```

### Cross-server event trigger

```lua
-- Trigger a world boss across all servers
pcall(function()
    MessagingService:PublishAsync("WorldBoss", {
        bossId = "DragonKing",
        spawnTime = os.time() + 60,
    })
end)
```

## Pitfalls

- **Best-effort delivery**: Messages can be dropped under load. Never rely on MessagingService for critical state transitions without a fallback (e.g., polling MemoryStoreService).
- **Always pcall**: Both `PublishAsync` and `SubscribeAsync` can fail.
- **Payload size**: 1 KB limit means you cannot send large data blobs. Send identifiers and have the receiving server look up details.
- **Connection cleanup**: Disconnect subscriptions when no longer needed to avoid hitting the subscription limit.
- **Not cross-experience**: MessagingService only works between servers of the same experience. For cross-experience communication, use Open Cloud.

## Related

- [[MemoryStoreService]] -- durable cross-server shared state
- [[cross-server-events]] -- patterns combining MessagingService + MemoryStoreService

## Sources

- [wiki/raw/roblox-creator-docs/services/MessagingService.md](../raw/roblox-creator-docs/services/MessagingService.md)
