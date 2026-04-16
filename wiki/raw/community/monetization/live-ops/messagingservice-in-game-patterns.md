---
title: MessagingService (In-Game) - Pub/Sub Patterns
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud-services/cross-server-messaging.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: live-ops
subcategory: api
tags: [messagingservice, pub-sub, cross-server, topics, live-ops]
---

# MessagingService (In-Game) — Pub/Sub Patterns

MessagingService is the engine-side publish/subscribe system. Any server
of the same universe can publish to a named topic and any server that
has subscribed will receive the payload within ~1 second.

Use it for fire-and-forget cross-server coordination: global announcements,
boss spawns, remote admin actions, cross-server chat. For durable shared
state use MemoryStoreService or DataStore.

## Concrete limits

- **Topic name**: 1–80 characters
- **Max message size**: 1,024 characters / 1 KiB
- **Delivery latency**: < 1 second typical
- **Delivery semantics**: at-most-once, not guaranteed
- **Rate limit**: server-side `50 + 5 × player_count` requests / min
  (matches Open Cloud limit)

## Code

### Subscribe on player join

```lua
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local TOPIC = "FriendServerEvent"

Players.PlayerAdded:Connect(function(player)
    local ok, connection = pcall(function()
        return MessagingService:SubscribeAsync(TOPIC, function(message)
            -- message.Data  : payload (string, number, table, etc.)
            -- message.Sent  : unix timestamp when published
            print(message.Data)
        end)
    end)

    if ok and connection then
        player.AncestryChanged:Connect(function()
            if not player:IsDescendantOf(game) then
                connection:Disconnect()
            end
        end)
    end
end)
```

### Publish to a topic

```lua
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local TOPIC = "FriendServerEvent"

Players.PlayerAdded:Connect(function(player)
    local ok, err = pcall(function()
        local payload = player.Name .. " joined server " .. game.JobId
        MessagingService:PublishAsync(TOPIC, payload)
    end)
    if not ok then warn("publish failed:", err) end
end)
```

### Structured payloads — JSON table

```lua
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")

local function publish(topic, tbl)
    local payload = HttpService:JSONEncode(tbl)
    return pcall(function()
        MessagingService:PublishAsync(topic, payload)
    end)
end

MessagingService:SubscribeAsync("events", function(message)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(message.Data)
    end)
    if ok and data.type == "boss_spawn" then
        print("Spawning", data.bossId, "at", data.positionName)
    end
end)

publish("events", { type = "boss_spawn", bossId = "drake", positionName = "north" })
```

### Back-off and retry

Messages that exceed size or rate limits raise errors; `PublishAsync` is
yielding so wrap it in a retry with exponential back-off.

```lua
local function publishWithRetry(topic, payload, maxAttempts)
    for attempt = 1, maxAttempts do
        local ok, err = pcall(function()
            MessagingService:PublishAsync(topic, payload)
        end)
        if ok then return true end
        if tostring(err):find("exhausted") or tostring(err):find("429") then
            task.wait(2 ^ attempt)
        else
            return false, err
        end
    end
    return false, "max attempts"
end
```

## Patterns

- **Announcements** — one server publishes, all subscribed servers display.
- **Cross-server shout / /global chat**. Topic = `chat:global`.
- **Feature flag toggle broadcast** — publish new config, subscribers
  update their in-memory flag table.
- **Live boss / event fan-out** — publish boss spawn event; each server
  spawns a local copy or redirects players via TeleportService.
- **Moderation broadcast** — publish "ban userId 1234" on a moderation
  topic; every server kicks that user the next time they join.

## Don't use it for

- **Durable state** — at-most-once delivery, no replay. Use DataStore /
  MemoryStore for anything you can't afford to lose.
- **High-volume firehose** — the rate limit scales with player count,
  not topic count. A 1-player test server only has ~55 msgs/min.
- **Large payloads** — 1 KiB max. Serialize into MemoryStore/DataStore
  and publish the key reference instead.

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud-services/cross-server-messaging.md
Related: https://create.roblox.com/docs/cloud-services/cross-server-messaging
Captured: 2026-04-16
