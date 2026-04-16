---
title: MemoryStore Best Practices — Sharding, Sorted Maps, and Leaderboards
type: raw-source
source_url: https://create.roblox.com/docs/cloud-services/memory-stores/best-practices
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: datastore
tags: [memorystore, leaderboards, sharding, sorted-map, queue, hashmap, cross-server]
---

# MemoryStore Best Practices — Sharding, Sorted Maps, and Leaderboards

**Source:** Roblox official docs + community patterns

## Why MemoryStore, not DataStore

DataStore is for **durable per-player state** — a player's coins, inventory, level. MemoryStore is for **shared ephemeral state** — live leaderboards, matchmaking queues, shared counters, cross-server locks. The two have completely different budgets, different latency characteristics, and different consistency guarantees.

Key differences that matter for design:

| Property | DataStore | MemoryStore |
|---|---|---|
| Persistence | Durable (lives forever) | TTL-based (default 45 days max) |
| Latency | Slow (~50-200ms) | Fast (~5-20ms) |
| Budget | Per-minute, scales with CCU | Per-minute request units, scales with CCU |
| Intended use | Per-player saves | Cross-server shared state |
| Atomic operations | `UpdateAsync` | Built-in atomic ops (increment, remove, get-and-delete) |
| Sharding | One partition per key | Partitioned per-key except for Hash Maps |

## Request quota

From the docs: "1000 + 100 × [num of concurrent users]" request units per minute. The quota is applied at the experience level, not per server — so a 50-CCU game has 6000 request units/minute total, shared across all servers.

Crucially, **all requests to a single sorted map or queue key go to a single partition**, so a single popular leaderboard can starve the whole experience of its budget even if only a few servers are hitting it.

## The three structures and their trade-offs

### Sorted Map

- Stores key → value pairs with an associated numeric sort key
- Supports range queries ("top 100"), paginated reads
- Perfect for leaderboards
- **Single partition per map** — high contention on popular leaderboards

### Queue

- FIFO or priority-ordered message queue
- Supports `AddAsync` / `ReadAsync` / `RemoveAsync`
- Perfect for matchmaking, task queues, notification fanout
- **Single partition per queue** — also contention-prone

### Hash Map

- Unsorted key → value
- "Hash maps do not have individual memory or item count limits and are automatically sharded"
- Perfect for shared state where you access by key, not by range
- **Automatically partitioned**, so less contention-prone

The auto-sharding of Hash Maps is a huge design advantage over the other two. If you can express your problem as "get/set by key" rather than "get range by sort key," Hash Map is almost always the right choice.

## Sharding strategy for Sorted Maps

If you absolutely need sorted range queries (and thus must use Sorted Map), the antidote to the single-partition limit is to shard the data across multiple Sorted Maps yourself:

```lua
-- 4-way shard by first character
local MemoryStoreService = game:GetService("MemoryStoreService")

local SHARDS = {
    ["A-G"] = MemoryStoreService:GetSortedMap("Leaderboard_AG"),
    ["H-N"] = MemoryStoreService:GetSortedMap("Leaderboard_HN"),
    ["O-T"] = MemoryStoreService:GetSortedMap("Leaderboard_OT"),
    ["U-Z"] = MemoryStoreService:GetSortedMap("Leaderboard_UZ"),
}

local function shardFor(userName)
    local c = userName:sub(1, 1):upper()
    if c <= "G" then return SHARDS["A-G"] end
    if c <= "N" then return SHARDS["H-N"] end
    if c <= "T" then return SHARDS["O-T"] end
    return SHARDS["U-Z"]
end
```

This spreads operations across four partitions, giving you 4× the budget headroom. The trade-off: a top-100 query across all players now requires 4 queries (one per shard) and a manual merge of results. This is fine for periodic leaderboard refreshes but bad for "what rank is this player right now?" lookups.

An alternative sharding strategy from the docs is to **separate users into multiple maps based on the last digits of their user ID**. This gives a uniform distribution (no clustering by first name) but loses the alphabetical meaning of the shard key.

### Queue sharding (revolving queues)

For queues, the pattern is a "revolving queue" — a small set of queues that you rotate through on adds and reads:

```lua
local QUEUE_COUNT = 4
local queues = {}
for i = 1, QUEUE_COUNT do
    queues[i] = MemoryStoreService:GetQueue("MatchmakingQueue_" .. i)
end

-- Write: pick a random queue
local function enqueue(data)
    local idx = math.random(QUEUE_COUNT)
    queues[idx]:AddAsync(data, 3600)
end

-- Read: round-robin all queues
local function dequeue()
    for i = 1, QUEUE_COUNT do
        local items = queues[i]:ReadAsync(1, false, 30)
        if items and #items > 0 then
            return items[1]
        end
    end
end
```

## Leaderboard pattern

For a "top 100" leaderboard updated live across all servers:

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local leaderboard = MemoryStoreService:GetSortedMap("GlobalScores")

-- Write when score changes
local function updateScore(userId, score)
    leaderboard:SetAsync(tostring(userId), score, 86400, score)
    -- args: key, value, TTL seconds, sortKey (same as value for leaderboard)
end

-- Read the top 100
local function getTop100()
    local results = leaderboard:GetRangeAsync(
        Enum.SortDirection.Descending,
        100
    )
    return results  -- array of {key, value} pairs
end
```

Caveats:
1. **TTL is mandatory.** MemoryStore data expires — max TTL is currently 45 days. A leaderboard must be refreshed periodically (daily rescore from DataStore, for example) to keep data alive.
2. **Throttling is real.** If every active player writes to this single sorted map on every score change, you will hit the budget. Debounce writes client-side (only push a score update if it's a PB, not on every kill) or shard as above.
3. **Use `UpdateAsync` if the value is derived from the current value** (e.g., incrementing a counter) so concurrent updates don't clobber each other.

## The hash map alternative

If you don't actually need *sorted* leaderboards — just a shared "what's this player's global state?" lookup — Hash Map is dramatically simpler:

```lua
local hashMap = MemoryStoreService:GetHashMap("PlayerStates")

-- Store per-player state
hashMap:SetAsync("player_" .. userId, {score = 100, rank = "Gold"}, 3600)

-- Read per-player state
local state = hashMap:GetAsync("player_" .. userId)
```

Because Hash Maps auto-shard, there's no partition-contention problem. For "live player state visible across servers" use cases (party systems, presence indicators, chat rooms), this is the right tool. Reserve Sorted Maps for actual sort-order-dependent queries.

## What DataStore should still do

MemoryStore is ephemeral — it's not a DataStore replacement. The canonical pattern is:

1. **DataStore** holds the durable score (e.g. lifetime high score).
2. On game start, a scheduled job scans DataStore keys and seeds **MemoryStore** with current scores for the leaderboard window.
3. Live score updates write to both DataStore (periodically) and MemoryStore (live).
4. Leaderboard UI reads from MemoryStore for freshness.

This gives you the speed of MemoryStore for queries and the durability of DataStore for historical data.

## Source

Original URL: https://create.roblox.com/docs/cloud-services/memory-stores/best-practices
Community discussion: https://devforum.roblox.com/t/architecture-for-creating-a-daily-leaderboard-with-datastores-or-memory-storage/2487729
Captured: 2026-04-15
