---
title: MemoryStoreService Patterns - Queues, SortedMaps, HashMaps
type: raw-source
source_url: https://devforum.roblox.com/t/memory-store-service-tutorial/1731594
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: live-ops
subcategory: api
tags: [memorystore, queue, sortedmap, hashmap, cross-server, matchmaking]
---

# MemoryStoreService Patterns — Queues, SortedMaps, HashMaps

MemoryStoreService is a top-level singleton used for data that changes
rapidly and needs to be visible across servers — global leaderboards,
matchmaking queues, auction houses, rate limiters, live event state.

Unlike DataStoreService, MemoryStore is:
- **Low-latency** (millisecond reads/writes)
- **Ephemeral** — every item has a required TTL (max 45 days)
- **Cross-server** — data is visible from any server of the same universe
- **Rate-limited** per-key and per-universe — plan for quota errors

## Core data structures

| Structure | Shape | Use case |
|-----------|-------|----------|
| Queue | FIFO, priority optional | Event bus, work items, matchmaking tickets |
| SortedMap | key → value, sorted by string key | Leaderboards, paginated listings |
| HashMap | key → value, fast lookup | Rate-limit buckets, session cache |

## Code

### Queue — cross-server click logger

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local clicksQueue = MemoryStoreService:GetQueue("Clicks")

local function logClick(player: Player)
    local ok, err = pcall(function()
        local value = string.format("%s clicked", player.Name)
        -- AddAsync(value, expiration, priority)
        clicksQueue:AddAsync(value, 30, 0)
    end)
    if not ok then warn("Queue add failed:", err) end
end
```

### Queue — reader loop

```lua
local function readQueue()
    local ok, items = pcall(function()
        -- ReadAsync(count, allOrNothing, waitTimeout)
        return clicksQueue:ReadAsync(20, false, 0)
    end)
    if ok and typeof(items) == "table" then
        for _, data in ipairs(items) do
            print(data)
        end
    end
end

while true do
    readQueue()
    task.wait(0.1)
end
```

### SortedMap — player join log, visible cross-server

```lua
local Players = game:GetService("Players")
local MemoryStoreService = game:GetService("MemoryStoreService")
local joinsMap = MemoryStoreService:GetSortedMap("Joins")

Players.PlayerAdded:Connect(function(player)
    pcall(function()
        joinsMap:SetAsync(
            tostring(player.UserId),
            string.format("%s joined", player.Name),
            30  -- TTL seconds
        )
    end)
end)
```

### SortedMap — range read with cleanup

```lua
local function fetchAll()
    local ok, data = pcall(function()
        return joinsMap:GetRangeAsync(Enum.SortDirection.Ascending, 200)
    end)
    if ok and typeof(data) == "table" then
        for _, entry in ipairs(data) do
            -- entry.key, entry.value
            joinsMap:RemoveAsync(entry.key)
        end
    end
end
```

### HashMap — idempotent rate limiter

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local rateLimit = MemoryStoreService:GetHashMap("RateLimitBuckets")

local function consumeToken(userId: number, bucket: string, max: number): boolean
    local key = userId .. ":" .. bucket
    local allowed = false
    pcall(function()
        rateLimit:UpdateAsync(key, function(old)
            old = old or 0
            if old >= max then
                allowed = false
                return nil  -- reject the write, no change
            end
            allowed = true
            return old + 1
        end, 60)  -- 60 second window
    end)
    return allowed
end
```

## Concrete limits to know

- **TTL required on every write** — no permanent data in MemoryStore.
- **Maximum TTL ~ 45 days** (3,888,000 seconds).
- **Per-key QPS limits** — batches help; hot-keying a single sorted map
  key will trip 429s under load.
- **No change events** — you must poll. Tutorial uses `task.wait(0.1)`;
  production systems should batch and back-off.
- Values must be JSON-serializable.

## Use cases table

| Pattern | Structure | Notes |
|---------|-----------|-------|
| Global live leaderboard | SortedMap | Key = score (padded string), value = player data |
| Matchmaking ticket queue | Queue | Priority = skill bracket |
| Cross-server chat relay | Queue or MessagingService | MessagingService is lower overhead for fire-and-forget pub/sub |
| Rate limit bucket | HashMap + UpdateAsync | Token bucket above |
| Boss HP across servers | HashMap | UpdateAsync with atomic damage application |
| Auction house listing | SortedMap | Sort by price, paginate with GetRangeAsync |

## Source

Original URL: https://devforum.roblox.com/t/memory-store-service-tutorial/1731594
Related: https://create.roblox.com/docs/cloud-services/memory-stores
Related: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud-services/memory-stores/best-practices.md
Captured: 2026-04-16
