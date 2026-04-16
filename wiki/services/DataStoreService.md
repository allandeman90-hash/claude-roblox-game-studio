---
title: DataStoreService
type: service
category: services
subcategory: persistence
owner: datastore-architect
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/DataStoreService.md
  - .claude/agents/datastore-architect.md
  - .claude/rules/datastores.md
related:
  - "[[GlobalDataStore]]"
  - "[[OrderedDataStore]]"
  - "[[MemoryStoreService]]"
  - "[[session-locking]]"
  - "[[bind-to-close]]"
  - "[[schema-versioning]]"
  - "[[no-session-lock]]"
tags: [roblox-class, persistence, server-only]
---

# DataStoreService

> Roblox's persistent key-value store for player data and other long-lived state. Server-only.

## Summary

`DataStoreService` is how a Roblox experience persists data between sessions and across servers. It's a key-value store keyed by a `name` (store) and a string key within that store. Values are JSON-serializable tables up to **4 MB per key**.

DataStores are the primary persistence mechanism for player data. Designing the schema, access patterns, and failure handling correctly is one of the highest-stakes decisions in any Roblox project — mistakes can cause player-visible data loss or duplication exploits.

See [[session-locking]] for the required safety pattern, [[schema-versioning]] for migration, and [[bind-to-close]] for shutdown-time saves.

## API Surface

### Methods

- `:GetDataStore(name: string, scope: string?) -> GlobalDataStore` — Returns a reference to a named data store. The returned [[GlobalDataStore]] is the handle you use for actual reads/writes.
- `:GetOrderedDataStore(name: string, scope: string?) -> OrderedDataStore` — Variant optimized for sorted numeric values (leaderboards, ranking queries).
- `:GetRequestBudgetForRequestType(requestType: Enum.DataStoreRequestType) -> number` — Returns current remaining budget for a request type. Check this before burst operations to avoid throttling.
- `:ListDataStoresAsync(prefix, pageSize, cursor) -> DataStorePages` — Enumerate data stores (rarely used at runtime).

### Request Types (`Enum.DataStoreRequestType`)
- `GetAsync` / `GetVersionAsync`
- `SetIncrementAsync` / `SetIncrementSortedAsync`
- `UpdateAsync`
- `GetSortedAsync`
- `RemoveAsync`

Each type has its own budget. Use `:GetRequestBudgetForRequestType` to check remaining quota before issuing a batch.

## Budgets and Limits

| Limit | Value |
|---|---|
| Value size | 4 MB (4,194,304 bytes) per key |
| Key length | 50 characters max |
| Scope length | 50 characters max |
| Name length | 50 characters max |
| Write cooldown per key | 6 seconds |
| `GetAsync` budget | 60 + numPlayers × 10 per minute |
| `SetAsync` budget | 60 + numPlayers × 10 per minute |
| `UpdateAsync` budget | 60 + numPlayers × 10 per minute |

**Request throttling**: when you exceed budget, calls are queued; prolonged abuse causes request rejection. Design schemas and save cadence to stay comfortably under budget.

## Common Patterns

### Safe Save with pcall and Retry

```lua
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("PlayerData_v1")

local function saveData(userId: number, data: {[string]: any}): boolean
    for attempt = 1, 5 do
        local ok, err = pcall(function()
            store:SetAsync("Player_" .. userId, {
                version = 1,
                data = data,
                savedAt = os.time(),
            })
        end)
        if ok then return true end
        warn(("DataStore save attempt %d failed: %s"):format(attempt, tostring(err)))
        task.wait(2 ^ attempt)  -- exponential backoff
    end
    return false
end
```

### Load with Default Fallback

```lua
local function loadData(userId: number): {[string]: any}
    local ok, result = pcall(function()
        return store:GetAsync("Player_" .. userId)
    end)
    if ok and result then
        return migrate(result)  -- see [[schema-versioning]]
    end
    return getDefaultData()
end
```

### UpdateAsync for Conditional Writes

`UpdateAsync` is the atomic read-modify-write primitive — use it for [[session-locking]] and any time you need to make a decision based on the current value.

```lua
local ok, result = pcall(function()
    return store:UpdateAsync("Player_" .. userId, function(oldValue)
        if not oldValue then return getDefaultData() end
        oldValue.gold += 100
        return oldValue
    end)
end)
```

The callback inside `UpdateAsync` **must not yield** — Roblox will error if it does. Do all yielding work before or after the callback.

## Pitfalls

- **No `pcall` → unhandled error**: DataStore calls WILL fail sometimes. Always wrap in `pcall`.
- **Player data keyed by `player.Name`**: Names can change. Always use `player.UserId`. See [[player-name-as-key]].
- **No [[session-locking]]**: Two servers holding the same player → item duplication exploit. Required in every production game.
- **No [[bind-to-close]] handler**: Data loss when a server restarts. Required.
- **Saving on every change**: Burns budget. Debounce with a dirty flag; save every 5 minutes or on critical events.
- **Yielding inside `UpdateAsync` callback**: Errors. Do yielding work outside.
- **Storing Instance references or functions**: DataStore serializes tables only. Store string IDs, UserIds, etc.
- **Ignoring schema versioning**: Next update to your data shape leaves old players stuck. Always include a `version` field. See [[schema-versioning]].

## Related

- [[GlobalDataStore]] — the handle type returned by `:GetDataStore`
- [[OrderedDataStore]] — variant for leaderboards
- [[MemoryStoreService]] — short-lived cross-server state
- [[session-locking]] — required safety pattern
- [[schema-versioning]] — migration strategy
- [[bind-to-close]] — shutdown-time save pattern
- [[no-session-lock]] — anti-pattern: forgetting session locks
- [[player-name-as-key]] — anti-pattern: using Name instead of UserId
- [[item-duplication]] — exploit class that session locking defends against
- [DataStore Rules](../../.claude/rules/datastores.md) — prescriptive rules

## Sources

- [Roblox Creator Docs — DataStoreService](https://create.roblox.com/docs/reference/engine/classes/DataStoreService)
- [wiki/raw/roblox-creator-docs/services/DataStoreService.md](../raw/roblox-creator-docs/services/DataStoreService.md)
- [.claude/agents/datastore-architect.md](../../.claude/agents/datastore-architect.md)
- [.claude/rules/datastores.md](../../.claude/rules/datastores.md)
