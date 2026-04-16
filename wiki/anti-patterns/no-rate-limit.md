---
title: no-rate-limit
type: anti-pattern
category: anti-patterns
subcategory: security
owner: remotes-networking-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: high
sources:
  - wiki/raw/roblox-creator-docs/best-practices/security/client-server-boundary.md
  - wiki/raw/community/devforum/how-to-secure-remoteevent-remotefunction.md
  - wiki/raw/community/articles/security/remote-event-security.md
  - .claude/rules/remotes.md
related:
  - "[[rate-limiting]]"
  - "[[RemoteEvent]]"
  - "[[remote-spam]]"
tags: [anti-pattern, security]
---

# Missing Rate Limit

> Client-to-server RemoteEvent handler without per-player rate limiting. Enables remote spam attacks, server DoS, and DataStore budget exhaustion.

**Severity:** High

## What It Looks Like

```lua
-- No rate limiting at all
remote.OnServerEvent:Connect(function(player, itemId)
    local item = Items[itemId]
    if item and playerData[player].gold >= item.price then
        playerData[player].gold -= item.price
        addToInventory(player, itemId)
        DataStore:SetAsync(key, playerData[player])  -- called per request!
    end
end)
```

An exploiter can fire this remote thousands of times per second. Each call hits the DataStore, the inventory system, and the gold balance. The server burns through its DataStore budget in seconds and the player gets thousands of items.

## Why It's Bad

1. **Server DoS**: each remote fire runs the handler function. At 1000+ fires/sec, the server heartbeat time spikes and all players experience lag or disconnection.
2. **DataStore budget exhaustion**: DataStoreService rate limits are per-server, not per-player. A single exploiter spamming a handler that calls `SetAsync` can exhaust the entire server's budget, breaking saves for all players.
3. **Race condition exploitation**: rapid-fire calls to handlers that modify shared state (inventories, trades, currency) can trigger race conditions that duplicate items or create negative balances.
4. **Remote queue exhaustion**: if the handler yields (DataStore call, HTTP call), queued events pile up. Once the queue limit is hit, Roblox throws a "remote event queue exhaustion" error that can crash the server.
5. **Computational amplification**: even if the handler is lightweight, a multiplier effect occurs when the handler triggers FireAllClients or other fan-out operations.

## How to Fix It

### Simple cooldown (per-player, per-remote)

```lua
local COOLDOWN = 0.2  -- 5 calls per second max
local lastCall: {[number]: number} = {}

remote.OnServerEvent:Connect(function(player, itemId)
    local now = time()
    local prev = lastCall[player.UserId] or 0
    if now - prev < COOLDOWN then
        return  -- rate limited; silently drop
    end
    lastCall[player.UserId] = now

    -- proceed with validation and logic
end)

Players.PlayerRemoving:Connect(function(player)
    lastCall[player.UserId] = nil  -- prevent memory leak
end)
```

### Token bucket (burst-tolerant)

For remotes that need to allow short bursts but cap sustained rate, use the token bucket algorithm from the Roblox Creator Docs:

```lua
local TokenBucket = require(ServerScriptService.TokenBucket)

-- Allow bursts of 5, refill over 10 seconds (0.5 tokens/sec)
local shopLimiter = TokenBucket.new(5, 10)

remote.OnServerEvent:Connect(function(player, itemId)
    if not shopLimiter:allow(player.UserId) then
        return  -- over rate limit
    end
    -- proceed
end)

Players.PlayerRemoving:Connect(function(player)
    shopLimiter.buckets[player.UserId] = nil
end)
```

### Guidelines for rate limit values

| Remote type | Typical limit |
|------------|---------------|
| Combat / ability use | 5-10 calls/sec |
| Shop purchase | 1-2 calls/sec |
| Chat message | 5 calls per 10 seconds |
| Trade action | 1 call per 2 seconds |
| Admin command | 1 call per 5 seconds |

## Detection

Every `OnServerEvent:Connect` handler should have a rate check near the top. Grep for handlers missing one:

```
OnServerEvent:Connect
```

Then verify each match has a timestamp check, cooldown table, or token bucket call before any game logic. Handlers that proceed directly to game state modification without rate gating are vulnerable.

## Related

- [[rate-limiting]]
- [[RemoteEvent]]
- [[remote-spam]]

## Sources

- [Roblox Creator Docs: Rate limiting](../raw/roblox-creator-docs/best-practices/security/client-server-boundary.md) -- "Rate limiting" section with token bucket example
- [DevForum: How to Secure Your RemoteEvent and RemoteFunction](../raw/community/devforum/how-to-secure-remoteevent-remotefunction.md) -- Cooldowns section
- [Community: Securing RemoteEvents -- Core Patterns](../raw/community/articles/security/remote-event-security.md) -- "Server-side rate limiting" section
- [Remotes Rules](../../.claude/rules/remotes.md)
