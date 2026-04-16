---
title: OrderedDataStore
type: service
category: services
subcategory: persistence
owner: datastore-architect
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/OrderedDataStore.md
related:
  - "[[DataStoreService]]"
  - "[[GlobalDataStore]]"
tags: [roblox-class, persistence, leaderboards]
---

# OrderedDataStore

> A GlobalDataStore variant for sorted integer values, ideal for leaderboards and rankings. [[DataStoreService]]

## Summary

OrderedDataStore is a specialized variant of [[GlobalDataStore]] where stored values must be **integers**. Its distinguishing feature is `GetSortedAsync()`, which returns entries in sorted order via a `DataStorePages` object -- making it the standard choice for leaderboards, rankings, and any "top N" or "bottom N" query.

OrderedDataStore inherits all methods from GlobalDataStore (`GetAsync`, `SetAsync`, `UpdateAsync`, `RemoveAsync`, `IncrementAsync`) but with important restrictions: it does **not** support versioning or metadata (`DataStoreKeyInfo` is always nil), and it does not support the optional `userIds` parameter for `SetAsync` or `IncrementAsync`. Calling `RemoveAsync` permanently deletes the key (no tombstone versioning).

For storing complex data structures with versioning, use a standard [[GlobalDataStore]] instead. OrderedDataStore is best used as a secondary index -- store the full player data in a GlobalDataStore and mirror the leaderboard-relevant integer to an OrderedDataStore.

## API Surface

### Properties

_No public properties._

### Methods

_Inherits from GlobalDataStore:_
- `:GetAsync(key: string) -> any` -- Returns the integer value for the key. Yields.
- `:SetAsync(key: string, value: number) -> ()` -- Sets an integer value. No userIds support. Yields.
- `:UpdateAsync(key: string, transformFunction: Function) -> any` -- Atomic read-modify-write. Yields.
- `:RemoveAsync(key: string) -> any` -- Permanently deletes the key (no versioning). Yields.
- `:IncrementAsync(key: string, delta: number?) -> number` -- Atomically increments. No userIds support. Yields.

_OrderedDataStore-specific:_
- `:GetSortedAsync(ascending: boolean, pageSize: number, minValue: number?, maxValue: number?) -> DataStorePages` -- Returns a paginated, sorted view of entries. Page size default 50, max 100. Optional min/max value filters. Yields.

### Events

_No public events._

## Budgets and Limits

- Same request budgets as GlobalDataStore: 60 + (numPlayers x 10) per minute for reads and writes
- **Values must be integers** -- no tables, strings, or floats
- **Page size**: Default 50, max 100 per page for `GetSortedAsync`
- **No versioning**: Previous versions are not retained
- **No metadata**: `DataStoreKeyInfo` is always nil

## Common Patterns

### Leaderboard display

```lua
local DataStoreService = game:GetService("DataStoreService")
local killsStore = DataStoreService:GetOrderedDataStore("TopKills")

-- Update player's kills
pcall(function()
    killsStore:SetAsync(tostring(player.UserId), totalKills)
end)

-- Fetch top 10
local success, pages = pcall(function()
    return killsStore:GetSortedAsync(false, 10) -- descending, 10 per page
end)

if success then
    local topEntries = pages:GetCurrentPage()
    for rank, entry in ipairs(topEntries) do
        print(rank, entry.key, entry.value)
    end
end
```

## Pitfalls

- **Integers only**: Attempting to store a table, string, or float will error.
- **No versioning**: Unlike GlobalDataStore, calling `RemoveAsync` permanently deletes the data. There is no 30-day tombstone recovery.
- **No userIds/metadata**: Cannot associate UserIds or custom metadata with entries. This means GDPR tracking must be handled separately.
- **Secondary index pattern**: Do not use OrderedDataStore as primary storage. Store full data in GlobalDataStore and mirror the sortable integer here.
- **Stale leaderboards**: OrderedDataStore is eventually consistent. For real-time leaderboards, consider [[MemoryStoreService]] sorted maps instead.

## Related

- [[DataStoreService]] -- parent service
- [[GlobalDataStore]] -- full-featured data store with versioning
- [[MemoryStoreService]] -- alternative for real-time sorted data

## Sources

- [wiki/raw/roblox-creator-docs/services/OrderedDataStore.md](../raw/roblox-creator-docs/services/OrderedDataStore.md)
