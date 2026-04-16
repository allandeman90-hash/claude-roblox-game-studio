---
title: GlobalDataStore
type: service
category: services
subcategory: persistence
owner: datastore-architect
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/GlobalDataStore.md
related:
  - "[[DataStoreService]]"
  - "[[OrderedDataStore]]"
  - "[[session-locking]]"
tags: [roblox-class, persistence]
---

# GlobalDataStore

> The handle object for saving and loading data from a single data store. [[DataStoreService]]

## Summary

GlobalDataStore is the object returned by `DataStoreService:GetDataStore(name, scope)`. It exposes the core methods for reading, writing, and deleting key-value data in Roblox's persistent storage system. Every data persistence operation in a standard Roblox game flows through this API.

Values in GlobalDataStores are **versioned** -- each write creates a new version. Previous versions can be retrieved via `DataStore:GetVersionAsync()` and `DataStore:ListVersionsAsync()`. Removed objects are permanently deleted after 30 days. Keys are cached locally for 4 seconds after the first read; subsequent `GetAsync` calls within that window return cached values.

For ordered numeric data (leaderboards), use [[OrderedDataStore]] instead. Note that OrderedDataStore does not support versioning or metadata -- `DataStoreKeyInfo` is always nil for ordered keys. See [[DataStoreService]] for the full usage pattern including [[session-locking]] and BindToClose.

## API Surface

### Properties

_No public properties._

### Methods

- `:GetAsync(key: string, options: DataStoreGetOptions?) -> (any, DataStoreKeyInfo?)` -- Returns the latest value and key info. Returns nil, nil if the key does not exist or was deleted. Yields. Cached for 4 seconds.
- `:SetAsync(key: string, value: any, userIds: {number}?, options: DataStoreSetOptions?) -> string` -- Sets the value for a key. Returns the version identifier. Yields. Counts against write limit only.
- `:UpdateAsync(key: string, transformFunction: (any, DataStoreKeyInfo) -> (any, {number}?, {[string]: any}?)) -> (any, DataStoreKeyInfo)` -- Reads then writes atomically. The transform function must not yield. Retries automatically on conflict. Counts against both read and write limits. Yields.
- `:RemoveAsync(key: string) -> (any, DataStoreKeyInfo?)` -- Marks the key as deleted (tombstone). Returns the previous value. Yields. Permanently deleted after 30 days.
- `:IncrementAsync(key: string, delta: number?, userIds: {number}?, options: DataStoreIncrementOptions?) -> any` -- Atomically increments an integer value. Yields.

### Events

_No public events. `OnUpdate` is deprecated._

## Budgets and Limits

- **GetAsync budget**: 60 + (numPlayers x 10) requests per minute
- **SetAsync/UpdateAsync budget**: 60 + (numPlayers x 10) requests per minute
- **Per-key write cooldown**: 6 seconds between writes to the same key
- **Max value size**: 4 MB per key
- **Max key length**: 50 characters
- **Local cache**: 4-second TTL after first read; SetAsync/UpdateAsync reset the cache immediately
- **Strings**: Must be valid UTF-8

## Common Patterns

### Safe read with pcall

```lua
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("PlayerData")

local success, value = pcall(function()
    return store:GetAsync("Player_12345")
end)

if success then
    if value then
        print("Loaded:", value)
    else
        print("No data for this key")
    end
else
    warn("DataStore read failed:", value)
end
```

### UpdateAsync for safe concurrent writes

```lua
store:UpdateAsync("Player_12345", function(currentValue, keyInfo)
    currentValue = currentValue or { gold = 0 }
    currentValue.gold += 100
    return currentValue, keyInfo:GetUserIds(), keyInfo:GetMetadata()
end)
```

## Pitfalls

- **SetAsync vs UpdateAsync**: SetAsync is faster (write-only) but can cause data loss if two servers write the same key simultaneously. UpdateAsync reads first, retries on conflict, but counts against both read and write budgets.
- **Transform function must not yield**: The callback passed to UpdateAsync cannot call `task.wait()` or any yielding function.
- **OnUpdate is deprecated**: Use [[MessagingService]] for cross-server change notifications instead.
- **UTF-8 requirement**: Non-UTF-8 strings will cause SetAsync/UpdateAsync to fail.
- **Always pcall**: Every DataStore call can fail due to throttling or service outages. Wrap in pcall with retry logic.

## Related

- [[DataStoreService]] -- parent service, budget management, BindToClose
- [[OrderedDataStore]] -- sorted numeric variant (no versioning)
- [[session-locking]] -- prevents data duplication across servers

## Sources

- [wiki/raw/roblox-creator-docs/services/GlobalDataStore.md](../raw/roblox-creator-docs/services/GlobalDataStore.md)
