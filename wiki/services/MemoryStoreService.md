---
title: MemoryStoreService
type: service
category: services
subcategory: persistence
owner: live-ops-specialist
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/MemoryStoreService.md
related:
  - "[[DataStoreService]]"
  - "[[MessagingService]]"
  - "[[cross-server-events]]"
tags: [roblox-class, persistence, live-ops]
---

# MemoryStoreService

> Cross-server in-memory storage with sorted maps, hash maps, and queues. [[DataStoreService]]

## Summary

MemoryStoreService provides shared in-memory data structures accessible across all servers in an experience. It offers three primitives: **HashMap** (key-value lookup), **SortedMap** (ordered key-value with range queries), and **Queue** (FIFO with invisibility timeout). All data has a maximum TTL of 45 days and is ephemeral -- it is not meant for permanent storage.

Use MemoryStoreService for data that changes rapidly and can be restored by other servers: global leaderboards, matchmaking queues, auction house state, cross-server event counters, rate limiting, and session coordination. For permanent persistence, use [[DataStoreService]] instead. For real-time notifications, pair with [[MessagingService]].

The service name is global within a game -- any place that uses the same map/queue name accesses the same data structure. This makes it ideal for cross-place communication within a single experience.

## API Surface

### Properties

_No public properties._

### Methods

- `:GetHashMap(name: string) -> MemoryStoreHashMap` -- Returns a hash map instance. Global within the game by name. Supports `SetAsync`, `GetAsync`, `RemoveAsync`, `UpdateAsync`, `GetRangeAsync`.
- `:GetSortedMap(name: string) -> MemoryStoreSortedMap` -- Returns a sorted map instance. Global within the game by name. Supports sorted range queries.
- `:GetQueue(name: string, invisibilityTimeout: number?) -> MemoryStoreQueue` -- Returns a queue instance. Default invisibility timeout is 30 seconds. Supports `AddAsync`, `ReadAsync`, `RemoveAsync`.

### Events

_No public events._

## Budgets and Limits

- **Request budget**: 1,000 + (numPlayers x 100) requests per minute per server instance
- **Max TTL**: 45 days for any stored value
- **Max item size**: 32 KB per value
- **Max key size**: 128 bytes
- **Max sorted map page size**: 200 items
- **Queue invisibility timeout**: Default 30 seconds; configurable per queue instance

## Common Patterns

### Cross-server matchmaking queue

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local matchQueue = MemoryStoreService:GetQueue("Matchmaking")

-- Server adds a player to the queue
local success, err = pcall(function()
    matchQueue:AddAsync({ userId = player.UserId, rank = 1500 }, 300) -- 5 min TTL
end)

-- Matchmaker server reads from the queue
local success, items, id = pcall(function()
    return matchQueue:ReadAsync(2, false, 10) -- read 2 items, wait up to 10s
end)
```

### Global leaderboard with sorted map

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local leaderboard = MemoryStoreService:GetSortedMap("GlobalKills")

-- Update a player's score
pcall(function()
    leaderboard:SetAsync(tostring(player.UserId), kills, 3600) -- 1 hour TTL
end)

-- Get top 10
local success, entries = pcall(function()
    return leaderboard:GetRangeAsync(Enum.SortDirection.Descending, 10)
end)
```

## Pitfalls

- **Ephemeral storage**: Data expires after the TTL. Never use MemoryStoreService as the sole persistence layer for important data.
- **Best-effort**: Operations can fail under load. Always pcall and handle failures.
- **Partition-aware sharding**: At scale, a single sorted map or hash map can become a bottleneck. Shard by prefix or partition key.
- **Invisibility timeout on queues**: After `ReadAsync`, items become invisible to other readers for the timeout period. If the reader crashes without calling `RemoveAsync`, items reappear -- design for idempotent processing.
- **Cross-place scope**: Map/queue names are global to the entire game (all places), not per-place.

## Related

- [[DataStoreService]] -- long-term persistent storage
- [[MessagingService]] -- cross-server pub/sub notifications
- [[cross-server-events]] -- patterns for cross-server coordination

## Sources

- [wiki/raw/roblox-creator-docs/services/MemoryStoreService.md](../raw/roblox-creator-docs/services/MemoryStoreService.md)
