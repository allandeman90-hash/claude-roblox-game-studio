---
title: leaderboard-pattern
type: pattern
category: patterns
subcategory: progression
owner: luau-gameplay-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/datastore/memorystore-leaderboards.md
  - wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md
  - wiki/raw/community/monetization/live-ops/memorystore-best-practices.md
related:
  - "[[OrderedDataStore]]"
  - "[[MemoryStoreService]]"
  - "[[cross-server-events]]"
  - "[[DataStoreService]]"
tags: [pattern, progression, leaderboard, memorystore, ordered-datastore]
---

# Leaderboard Pattern

> Persistent top-N queries via `OrderedDataStore` and real-time cross-server leaderboards via `MemoryStoreService.SortedMap`.

## Summary

Roblox offers two primitives for leaderboards with different durability and latency characteristics. `OrderedDataStore` provides durable, sorted storage with `GetSortedAsync` for persistent all-time or seasonal leaderboards. `MemoryStoreService.SortedMap` provides low-latency cross-server visibility with TTL-based expiration, ideal for live event leaderboards. Production systems typically use both: DataStore for the authoritative score, MemoryStore for the live-refresh UI.

## When to Use It

| Use case | Tool |
|----------|------|
| All-time high scores | `OrderedDataStore` |
| Weekly/seasonal leaderboard | `OrderedDataStore` with date-suffixed store name |
| Live event (hours-long) | `MemoryStoreService.SortedMap` |
| Real-time cross-server race | `MemoryStoreService.SortedMap` |

## Implementation

### Pattern 1: OrderedDataStore (Persistent)

```lua
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local STORE_NAME = "HighScores_v1"
local leaderboardStore = DataStoreService:GetOrderedDataStore(STORE_NAME)

-- Write: update score when it improves
local function updateScore(userId: number, newScore: number)
    pcall(function()
        leaderboardStore:UpdateAsync(tostring(userId), function(oldScore)
            oldScore = oldScore or 0
            return math.max(oldScore, newScore)  -- only save personal best
        end)
    end)
end

-- Read: get top 100
local function getTopPlayers(count: number): {{userId: number, score: number}}
    local results = {}
    local ok, pages = pcall(function()
        return leaderboardStore:GetSortedAsync(false, count)  -- descending
    end)
    if not ok then return results end

    local data = pages:GetCurrentPage()
    for _, entry in ipairs(data) do
        table.insert(results, {
            userId = tonumber(entry.key),
            score = entry.value,
        })
    end
    return results
end

-- Pagination for full leaderboard
local function getAllPages(maxPages: number)
    local all = {}
    local ok, pages = pcall(function()
        return leaderboardStore:GetSortedAsync(false, 100)
    end)
    if not ok then return all end

    local pageCount = 0
    while true do
        pageCount += 1
        for _, entry in ipairs(pages:GetCurrentPage()) do
            table.insert(all, { userId = tonumber(entry.key), score = entry.value })
        end
        if pages.IsFinished or pageCount >= maxPages then break end
        pcall(function() pages:AdvanceToNextPageAsync() end)
    end
    return all
end
```

### Pattern 2: MemoryStore SortedMap (Live / Cross-Server)

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local leaderboard = MemoryStoreService:GetSortedMap("LiveEventScores")

local LEADERBOARD_TTL = 86400  -- 24 hours for a daily event

-- Write: update score (debounce -- only push on PB, not every kill)
local function updateLiveScore(userId: number, score: number)
    pcall(function()
        leaderboard:SetAsync(
            tostring(userId),
            score,
            LEADERBOARD_TTL,
            score  -- sortKey = score value for correct ordering
        )
    end)
end

-- Read: top 100 across all servers
local function getLiveTop100(): {{userId: number, score: number}}
    local results = {}
    local ok, data = pcall(function()
        return leaderboard:GetRangeAsync(Enum.SortDirection.Descending, 100)
    end)
    if ok and data then
        for _, entry in ipairs(data) do
            table.insert(results, {
                userId = tonumber(entry.key),
                score = entry.value,
            })
        end
    end
    return results
end
```

### Pattern 3: Hybrid (DataStore + MemoryStore)

The canonical production pattern:

1. **DataStore** holds the durable lifetime score.
2. On game start, a scheduled job seeds **MemoryStore** from DataStore for the active leaderboard window.
3. Live score changes write to both DataStore (periodically, debounced) and MemoryStore (immediately).
4. Leaderboard UI reads from MemoryStore for freshness.

```lua
-- On score change:
local function onScoreChanged(player: Player, newScore: number)
    -- MemoryStore: immediate, for live UI
    updateLiveScore(player.UserId, newScore)

    -- DataStore: debounced, for durability (via standard save loop)
    local data = PlayerDataService.getData(player)
    if data then
        data.highScore = math.max(data.highScore or 0, newScore)
    end
end
```

### Sharding for High Traffic

A single SortedMap is a single partition. Under high write load, shard by player name prefix or UserId suffix:

```lua
local NUM_SHARDS = 4
local shards = {}
for i = 1, NUM_SHARDS do
    shards[i] = MemoryStoreService:GetSortedMap("Leaderboard_" .. i)
end

local function shardFor(userId: number)
    return shards[(userId % NUM_SHARDS) + 1]
end

-- Write to shard
local function updateShardedScore(userId: number, score: number)
    pcall(function()
        shardFor(userId):SetAsync(tostring(userId), score, LEADERBOARD_TTL, score)
    end)
end

-- Read: merge from all shards, sort, take top N
local function getTopFromShards(count: number)
    local all = {}
    for _, shard in ipairs(shards) do
        local ok, data = pcall(function()
            return shard:GetRangeAsync(Enum.SortDirection.Descending, count)
        end)
        if ok and data then
            for _, entry in ipairs(data) do
                table.insert(all, { userId = tonumber(entry.key), score = entry.value })
            end
        end
    end
    table.sort(all, function(a, b) return a.score > b.score end)
    local top = {}
    for i = 1, math.min(count, #all) do
        top[i] = all[i]
    end
    return top
end
```

## Pitfalls

- **MemoryStore TTL.** All MemoryStore data expires. Max TTL is ~45 days. A persistent leaderboard must periodically refresh entries from DataStore or they disappear.
- **Write debouncing.** Writing to MemoryStore on every kill/point will hit the per-partition rate limit. Debounce writes -- only push when the score is a personal best, or batch updates every 30 seconds.
- **OrderedDataStore value type.** `OrderedDataStore` only stores **integers**. Multiply fractional scores by 1000 (or similar) and store as int.
- **Budget sharing.** MemoryStore budget is experience-wide: `1000 + 100 * CCU` request units/minute shared across all servers. A popular leaderboard can starve other MemoryStore uses. Shard as shown above.
- **Pagination cost.** `GetSortedAsync` pages are sequential. Fetching rank 901-1000 requires paging through the first 900. For "what rank am I?" queries, maintain a MemoryStore HashMap of `userId -> rank` updated periodically.

## Related

- [[OrderedDataStore]] -- durable sorted storage
- [[MemoryStoreService]] -- ephemeral cross-server storage
- [[cross-server-events]] -- broader cross-server coordination patterns
- [[DataStoreService]] -- authoritative score persistence

## Sources

- [wiki/raw/community/articles/datastore/memorystore-leaderboards.md](../raw/community/articles/datastore/memorystore-leaderboards.md)
- [wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md](../raw/community/monetization/live-ops/memorystore-cross-server-patterns.md)
- [wiki/raw/community/monetization/live-ops/memorystore-best-practices.md](../raw/community/monetization/live-ops/memorystore-best-practices.md)
