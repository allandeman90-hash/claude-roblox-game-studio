---
title: MemoryStoreService Best Practices - Sharding and Throughput
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud-services/memory-stores/best-practices.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: live-ops
subcategory: api
tags: [memorystore, best-practices, sharding, hot-key, throughput, partition]
---

# MemoryStoreService Best Practices — Sharding and Throughput

MemoryStoreService quotas are **per-partition**, not per-key or
per-request. Hot-keying one SortedMap can trip the whole universe
limit. The patterns below are the Roblox-documented way to avoid
partition throttling.

## Quota model

- Memory cap per data structure type
- Item-count cap per data structure type
- **Global per-partition request limit** — this is the one that bites
- Over-limit returns throttling errors from the API

Each **Queue** and **SortedMap** lives on a **single partition**. That
partition has a fixed QPS/throughput ceiling. If you funnel everything
through one sorted-map key, that one key is the bottleneck.

**HashMaps are automatically sharded** across partitions by key hash —
as long as you use distinct keys.

## Pattern 1 — SortedMap alphabetic sharding

Instead of one `GlobalLeaderboard` SortedMap, split by key prefix:

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")

local MAPS = {
    AG = MemoryStoreService:GetSortedMap("Leaderboard_AG"),
    HN = MemoryStoreService:GetSortedMap("Leaderboard_HN"),
    OT = MemoryStoreService:GetSortedMap("Leaderboard_OT"),
    UZ = MemoryStoreService:GetSortedMap("Leaderboard_UZ"),
}

local function bucketFor(name)
    local c = string.upper(string.sub(name, 1, 1))
    if c <= "G" then return MAPS.AG
    elseif c <= "N" then return MAPS.HN
    elseif c <= "T" then return MAPS.OT
    else return MAPS.UZ end
end

local function setScore(playerName, score)
    local map = bucketFor(playerName)
    pcall(function()
        map:SetAsync(playerName, score, 3600)
    end)
end
```

Each map lives on its own partition, so writes to different letters
don't share the same rate-limit budget.

## Pattern 2 — Revolving queues

Split a high-volume queue into N queues and round-robin add/read:

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")

local NUM_QUEUES = 4
local QUEUES = {}
for i = 1, NUM_QUEUES do
    QUEUES[i] = MemoryStoreService:GetQueue("Tasks_" .. i)
end

local writeCursor = 1
local function addTask(task)
    local q = QUEUES[writeCursor]
    writeCursor = (writeCursor % NUM_QUEUES) + 1
    pcall(function()
        q:AddAsync(task, 600, 0)
    end)
end

local readCursor = 1
local function drainOne()
    local q = QUEUES[readCursor]
    readCursor = (readCursor % NUM_QUEUES) + 1
    local ok, items = pcall(function()
        return q:ReadAsync(20, false, 0)
    end)
    return ok and items or nil
end
```

## Pattern 3 — HashMap field-per-key (avoid blob storage)

Bad: one key per entity, value = JSON blob with all fields.

```lua
-- BAD: forces full rewrite per update, single-key bottleneck
hashmap:SetAsync("boss:dragon", HttpService:JSONEncode({
    hp = 5000, stage = 1, attackers = { ... }
}))
```

Good: one key per field, use UpdateAsync for atomic increments.

```lua
-- GOOD: each field sharded across partitions automatically
hashmap:UpdateAsync("boss:dragon:hp", function(old)
    return (old or 5000) - 100
end)
hashmap:SetAsync("boss:dragon:stage", 2)
```

## Pattern 4 — Hot-key avoidance

For very frequently-accessed keys (like a global counter), spread
requests across multiple keys with the same value:

```lua
local NUM_SHARDS = 10
local function incrementCounter()
    local shard = math.random(1, NUM_SHARDS)
    local key = "global_counter_" .. shard
    hashmap:UpdateAsync(key, function(old)
        return (old or 0) + 1
    end)
end

-- Reading: sum all shards
local function readCounter()
    local total = 0
    for i = 1, NUM_SHARDS do
        local ok, v = pcall(function()
            return hashmap:GetAsync("global_counter_" .. i)
        end)
        if ok and v then total += v end
    end
    return total
end
```

## TTL guidance

- Every MemoryStore write requires a TTL. **No permanent storage.**
- Typical application TTLs: **300–3600 seconds** (5 min to 1 hour).
- Official examples often use **600 seconds** as a default.
- TTL max: ~**45 days** (3,888,000 s).
- **Clean up eagerly.** Use `RemoveAsync` for processed items so the
  map doesn't hit its item-count ceiling.

## Batching reads and writes

- Use `ReadAsync(count, false, timeout)` to pull up to N items at once
  from a queue instead of one-at-a-time.
- Use `GetRangeAsync(direction, limit, [exclusiveLowerBound])` to
  read SortedMap entries in bulk.
- Batching amortizes per-request partition cost.

## Error handling

- Always pcall MemoryStore calls. Throttling surfaces as errors.
- On throttle, back off exponentially; do NOT retry in a tight loop.
- Track error rate with a `LogCustomEvent` so you can see if your
  sharding isn't keeping up.

## When to use MemoryStore vs DataStore

| Data | Use |
|------|-----|
| Live leaderboard | MemoryStore SortedMap (sharded) |
| Matchmaking queue | MemoryStore Queue |
| Long-term profile | DataStore |
| Boss health counter cross-server | MemoryStore HashMap (sharded) |
| Cross-server chat / announcements | **MessagingService** (cheaper) |
| Rate limiter | MemoryStore HashMap |
| Cached user data (minutes) | MemoryStore HashMap |

Use MessagingService over MemoryStore for **fire-and-forget** pub/sub
— it's cheaper and has its own quota pool.

## Concrete Numbers / Examples

- Example default TTL in docs: **600 seconds**
- Typical shard count for alphabetic split: **4**
- Revolving queue count: **N = 4–16** common
- Hot-key shard count: **10** is a safe default
- Max TTL: **~45 days** (3,888,000 s)

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud-services/memory-stores/best-practices.md
Related: https://devforum.roblox.com/t/memory-store-service-tutorial/1731594
Captured: 2026-04-16
