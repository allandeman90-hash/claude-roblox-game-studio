---
title: cross-server-events
type: concept
category: concepts
subcategory: live-ops
owner: live-ops-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/messagingservice-in-game-patterns.md
  - wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md
  - wiki/raw/community/monetization/live-ops/memorystore-best-practices.md
related:
  - "[[MessagingService]]"
  - "[[MemoryStoreService]]"
  - "[[feature-flags]]"
  - "[[leaderboard-pattern]]"
tags: [concept, live-ops, cross-server, pub-sub, memorystore]
---

# Cross-Server Events

> Patterns for coordinating state and events across all server instances of a Roblox experience using MessagingService (fire-and-forget pub/sub) and MemoryStoreService (shared ephemeral state).

## What It Is

A single Roblox experience can run hundreds of server instances simultaneously. Cross-server events let those instances coordinate: broadcast announcements, synchronize live event state, run global leaderboards, manage matchmaking queues, and propagate config changes.

Two engine primitives provide this:

| Primitive | Model | Delivery | Latency | Use case |
|-----------|-------|----------|---------|----------|
| **MessagingService** | Pub/sub topics | At-most-once (best-effort) | ~1 second | Announcements, flag broadcasts, moderation |
| **MemoryStoreService** | Shared state (SortedMap, HashMap, Queue) | Durable within TTL | ~5-20 ms | Leaderboards, matchmaking, rate limiters, shared counters |

## When to Use It

- **Global announcements.** One server publishes "New boss spawned!"; all servers display it.
- **Live events.** Coordinate a global boss HP bar visible on every server.
- **Feature flag propagation.** Push config changes instantly via [[feature-flags]].
- **Cross-server chat.** Topic = `chat:global`.
- **Matchmaking queues.** MemoryStore Queue with skill-bracket priority.
- **Moderation broadcasts.** Publish "ban userId 1234"; every server kicks on next check.

## Implementation

### MessagingService -- Pub/Sub

**Concrete limits:**
- Topic name: 1-80 characters
- Max message size: 1,024 characters (1 KiB)
- Delivery latency: < 1 second typical
- Delivery semantics: at-most-once, not guaranteed
- Rate limit: `50 + 5 * player_count` requests/min per server

**Subscribe and publish:**

```lua
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")

-- Subscribe to a topic
pcall(function()
    MessagingService:SubscribeAsync("global_events", function(message)
        -- message.Data : payload (string, table)
        -- message.Sent : unix timestamp
        local ok, data = pcall(function()
            return HttpService:JSONDecode(message.Data)
        end)
        if ok and data.type == "boss_spawn" then
            spawnLocalBoss(data.bossId, data.position)
        end
    end)
end)

-- Publish a structured payload
local function publishEvent(topic: string, payload: {[string]: any})
    pcall(function()
        MessagingService:PublishAsync(topic, HttpService:JSONEncode(payload))
    end)
end

publishEvent("global_events", {
    type = "boss_spawn",
    bossId = "dragon",
    position = "north",
})
```

**Retry with backoff:**

```lua
local function publishWithRetry(topic: string, payload: string, maxAttempts: number)
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

### MemoryStoreService -- Shared State

**Core data structures:**

| Structure | Shape | Best for |
|-----------|-------|----------|
| **Queue** | FIFO, optional priority | Matchmaking tickets, work items |
| **SortedMap** | Key-value, sorted by key | Leaderboards, paginated listings |
| **HashMap** | Key-value, auto-sharded | Rate limiters, session cache, per-entity state |

**Cross-server boss HP (HashMap):**

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local bossState = MemoryStoreService:GetHashMap("BossState")

-- Atomic damage application
local function dealBossDamage(bossId: string, damage: number): number?
    local newHp
    pcall(function()
        bossState:UpdateAsync(bossId .. ":hp", function(old)
            old = old or 10000
            newHp = math.max(0, old - damage)
            return newHp
        end, 3600)
    end)
    return newHp
end

-- Read current HP from any server
local function getBossHp(bossId: string): number
    local ok, hp = pcall(function()
        return bossState:GetAsync(bossId .. ":hp")
    end)
    return (ok and hp) or 0
end
```

**Matchmaking queue (Queue):**

```lua
local matchQueue = MemoryStoreService:GetQueue("Matchmaking")

-- Enqueue a player with skill-based priority
local function enqueue(player: Player, skillRating: number)
    pcall(function()
        matchQueue:AddAsync({
            userId = player.UserId,
            skill = skillRating,
            jobId = game.JobId,
        }, 300, skillRating)  -- TTL 5min, priority = skill
    end)
end

-- Dequeue up to 10 players for a match
local function dequeue(): {{userId: number, skill: number, jobId: string}}?
    local ok, items = pcall(function()
        return matchQueue:ReadAsync(10, false, 5)
    end)
    return ok and items or nil
end
```

### Sharding for High Traffic

HashMaps auto-shard by key. SortedMaps and Queues are single-partition -- shard manually:

```lua
-- 4-way SortedMap shard by UserId last digit
local NUM_SHARDS = 4
local shards = {}
for i = 1, NUM_SHARDS do
    shards[i] = MemoryStoreService:GetSortedMap("Leaderboard_" .. i)
end

local function shardFor(userId: number)
    return shards[(userId % NUM_SHARDS) + 1]
end
```

See [[leaderboard-pattern]] for full sharded leaderboard implementation.

## Variants

| Pattern | Primitive | Notes |
|---------|-----------|-------|
| Global announcement | MessagingService | One publish, all servers receive |
| Cross-server chat | MessagingService | Topic per channel |
| Feature flag broadcast | MessagingService | See [[feature-flags]] |
| Live leaderboard | MemoryStore SortedMap | Sharded for scale |
| Matchmaking queue | MemoryStore Queue | Priority = skill bracket |
| Boss HP cross-server | MemoryStore HashMap | UpdateAsync for atomic damage |
| Rate limiter | MemoryStore HashMap | Token bucket with TTL |
| Auction house | MemoryStore SortedMap | Sort by price, paginate |

## Pitfalls

- **MessagingService is not durable.** Messages can be dropped. Do not use it for state that must not be lost. Use DataStore or MemoryStore for that.
- **1 KiB message limit.** For large payloads, store the data in MemoryStore/DataStore and publish a key reference via MessagingService.
- **MemoryStore TTL is mandatory.** Every write requires a TTL. Max ~45 days. No permanent data in MemoryStore.
- **Per-partition rate limit.** SortedMaps and Queues are single-partition. A popular structure will hit the experience-wide budget (`1000 + 100 * CCU` req units/min). Shard aggressively.
- **No change events on MemoryStore.** You must poll. Batch reads and use backoff to avoid budget exhaustion.
- **Use MessagingService for fire-and-forget.** It is cheaper and has its own quota pool separate from MemoryStore. Do not use MemoryStore when MessagingService suffices.

## Related

- [[MessagingService]] -- the pub/sub primitive
- [[MemoryStoreService]] -- the shared state primitive
- [[feature-flags]] -- cross-server config propagation
- [[leaderboard-pattern]] -- specific cross-server leaderboard implementation

## Sources

- [wiki/raw/community/monetization/live-ops/messagingservice-in-game-patterns.md](../raw/community/monetization/live-ops/messagingservice-in-game-patterns.md)
- [wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md](../raw/community/monetization/live-ops/memorystore-cross-server-patterns.md)
- [wiki/raw/community/monetization/live-ops/memorystore-best-practices.md](../raw/community/monetization/live-ops/memorystore-best-practices.md)
