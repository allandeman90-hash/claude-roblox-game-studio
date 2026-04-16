---
title: Open Cloud MessagingService API (External Publish)
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/guides/usage-messaging.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: open-cloud
subcategory: api
tags: [open-cloud, messaging-service, pub-sub, cross-server, external, webhook]
---

# Open Cloud MessagingService API

This is the externally-callable version of MessagingService: you can
publish messages to a live experience from a webhook, CI/CD pipeline,
backend server, Discord bot, etc. Running servers subscribed to the
matching topic will receive the payload within ~1 second.

The in-game side uses `MessagingService:SubscribeAsync(topic, handler)`
and is unchanged — this API only replaces `PublishAsync`.

## REST endpoint

```
POST https://apis.roblox.com/cloud/v2/universes/{universe}:publishMessage
```

Both API Key and OAuth 2.0 authentication are supported.

### Headers

| Header | API Key | OAuth 2.0 |
|--------|---------|-----------|
| x-api-key | required | — |
| Authorization | — | `Bearer <access_token>` |
| Content-Type | `application/json` | `application/json` |

### Body

```json
{
  "topic": "your-topic",
  "message": "Hello, everyone!"
}
```

Successful requests return HTTP 200 with an empty body.

## Limits

| Limit | Value |
|-------|-------|
| Rate limit | `50 + (5 × current_player_count)` requests / minute |
| Topic name | ≤ 80 characters |
| Message | ≤ 1,024 characters (1 KiB) |

The sliding-window rate limit means higher-CCU games get more headroom.
A 100-player server allows `50 + 500 = 550` messages/min.

## Code

### curl — API key

```bash
curl -L -X POST \
  "https://apis.roblox.com/cloud/v2/universes/${UNIVERSE_ID}:publishMessage" \
  -H "x-api-key: ${ROBLOX_API_KEY}" \
  -H "Content-Type: application/json" \
  --data '{"topic":"EventAnnouncement","message":"Boss spawning in 5m"}'
```

### curl — OAuth

```bash
curl -X POST \
  "https://apis.roblox.com/cloud/v2/universes/${UNIVERSE_ID}:publishMessage" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --data-raw '{"topic":"LiveOps","message":"Flip flag FeatureX off"}'
```

### Roblox Lua — subscriber

```lua
local MessagingService = game:GetService("MessagingService")

local ok, connection = pcall(function()
    return MessagingService:SubscribeAsync("LiveOps", function(message)
        -- message.Data is the string you published from the REST API
        -- message.Sent is the unix timestamp
        print("Live-ops command:", message.Data)
        -- parse "flip flag FeatureX off" -> update ServerStorage config
    end)
end)

game:BindToClose(function()
    if ok and connection then connection:Disconnect() end
end)
```

### Node.js — publish from an admin dashboard

```js
import fetch from "node-fetch";

async function publish(universeId, topic, message) {
  const res = await fetch(
    `https://apis.roblox.com/cloud/v2/universes/${universeId}:publishMessage`,
    {
      method: "POST",
      headers: {
        "x-api-key": process.env.ROBLOX_API_KEY,
        "content-type": "application/json",
      },
      body: JSON.stringify({ topic, message }),
    }
  );
  if (!res.ok) throw new Error(`publish failed: ${res.status}`);
}
```

## Live-ops patterns

- **Feature flag toggles** — publish a JSON payload on topic `liveops:flags`.
  Servers update their in-memory config and stop serving the feature
  immediately. Use for emergency off-switches when a bug hits production.
- **Remote announcements** — publish on `announcements` to run chat-wide
  messages, boss spawns, seasonal event triggers.
- **Cross-server challenges** — publish progress increments on a shared
  topic; use MemoryStoreService HashMap for the persistent counter.
- **Discord webhook → game** — let moderators publish messages from Discord
  to kick / warn / ban via topic `moderation:action`.

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/guides/usage-messaging.md
Related: https://create.roblox.com/docs/cloud/guides/usage-messaging
Captured: 2026-04-16
