---
title: DataStore2 — Cached, Safer, Non-Session-Locked Alternative to Raw DataStores
type: raw-source
source_url: https://kampfkarren.github.io/Roblox/
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: datastore
author: Kampfkarren
tags: [datastore, datastore2, caching, backup, persistence]
---

# DataStore2 — Cached, Safer, Non-Session-Locked Alternative to Raw DataStores

**Author:** Kampfkarren
**Source:** https://github.com/Kampfkarren/Roblox (DataStore2 module)
**Docs:** https://kampfkarren.github.io/Roblox/

## What it is

DataStore2 is a simple-to-use data store system that caches, leading to significantly faster performance over traditional data stores. It is a second-generation approach that layers atop Roblox's native DataStore API to fix the two biggest problems with the raw API:

1. **Every read is a network roundtrip** — DataStore2 reads once, then keeps data in memory.
2. **A crashed save during shutdown can lose data** — DataStore2 uses an ordered-data-store history layer so even a failed save keeps older versions recoverable.

It's been used in games with hundreds of millions of visits and remains in production for many shipped titles.

## How DataStore2 differs from ProfileService/ProfileStore

DataStore2 and ProfileService solve overlapping but distinct problems:

| Concern | DataStore2 | ProfileService / ProfileStore |
|---|---|---|
| Caching | Yes (in-memory) | Yes (Profile.Data) |
| Session locking | **No** | Yes |
| Backup/versioning | Yes (ordered history) | No built-in |
| Global messaging | Separate module | Built-in (GlobalUpdates / MessageAsync) |
| Recommended for new projects | Still used, but less common | **Yes (ProfileStore)** |

The key trade-off: DataStore2 has no session locking, which means two servers can theoretically load and save the same key concurrently. In a game with trading or player-to-player transfer, this is a dupe risk. For games without such features (most solo-progression games), DataStore2's simpler model works fine.

## Core API

### Constructor

```lua
local DataStore2 = require(ServerScriptService.DataStore2)

local coinsStore = DataStore2("coins", player)
```

The signature is `DataStore2(dataStoreName, player)`. Internally, each player's coins are stored under a key derived from their UserId. `dataStoreName` is a logical name — you can have multiple stores per player (`"coins"`, `"level"`, `"inventory"`).

### `:Get(defaultValue, dontAttemptGet)`

> Will return the value cached in the data store, if it exists. If it does not exist, will then attempt to get the value from Roblox data stores.

`coinsStore:Get(0)` returns the cached value or, on first call, fetches from DataStore. If the player is new, it returns the default. The return value is a *deep copy* for tables — mutating it does not mutate the store.

### `:Set(newValue)`

Updates the cached value without making a network call. Actual persistence happens on `:Save()` or on `BindToClose`. This is the killer feature: successive `:Set` calls are basically free.

### `:Update(callback)`

```lua
coinsStore:Update(function(current)
    return current + 10
end)
```

Reads the current cached value, applies the callback, writes back. This is safer than `:Get` + `:Set` because it atomically composes the read and the write — you don't risk dropping an intermediate update.

### `:Increment(add, defaultValue)`

Shorthand for numeric increment:

```lua
coinsStore:Increment(10)
```

### `:OnUpdate(callback)`

Registers a callback that fires whenever the cached data changes (via `:Set`, `:Update`, `:Increment`). Useful for keeping UI in sync — when coins change, update the HUD.

### `:Save()`

Persists cached data to Roblox data stores. This is what actually hits the network. DataStore2 automatically calls this on `BindToClose` (game shutdown) and at reasonable intervals, but you can call it explicitly for checkpoints.

### `:GetTable(defaults)`

Specifically for table-shaped data. Gets the current table and merges in default fields from the provided `defaults` table. This is the DataStore2 equivalent of ProfileService's `:Reconcile()` — adds new fields without wiping existing ones.

## Backup mode (the data-loss safety net)

From the docs: DataStore2 in the end always uses Roblox's data stores and servers, and those services occasionally experience downtime.

### `:SetBackup(retries, alternativeDefaultValue)`

```lua
coinsStore:SetBackup(5)
```

Configures: "Try to get the data five times before giving up. If all attempts fail, enter backup mode."

### What backup mode does

When the store enters backup mode after exhausting retries, two things happen:

1. It returns an empty/default value (treating the player as having no data), so the game can still run.
2. **It will never save.** This is the critical safety property — DataStore2 won't overwrite a potentially-still-recoverable player's data with zeros just because the DataStore happened to be down when they joined.

### `:IsBackup()` and `:ClearBackup()`

Use `coinsStore:IsBackup()` to check if the store is in backup mode. Use this to display a warning to the player ("Data temporarily unavailable") or to disable expensive actions that would normally persist.

`:ClearBackup()` lets you retry fetching without manually reconfiguring retry counts — useful if you want periodic recovery attempts when services come back.

### Why this design matters

The traditional DataStore anti-pattern:

```lua
-- DON'T do this
local data = DataStoreService:GetDataStore("PlayerData"):GetAsync("Player_" .. userId)
if not data then
    data = {coins = 0}
end

-- ... later ...
DataStoreService:GetDataStore("PlayerData"):SetAsync("Player_" .. userId, data)
```

If the `GetAsync` fails (throttled or outage), `data` is `nil`, the fallback `{coins = 0}` runs, and then on save you *overwrite the real data* with zeros. The player loses everything they had.

DataStore2's backup mode is explicitly designed to prevent this by refusing to save when it knows its read failed. You get temporary unavailability instead of permanent loss.

## Combining stores (`Combined`)

DataStore2 has a `Combined` helper that lets you bundle multiple logical stores into a single underlying key, reducing DataStore request count. Instead of one request per store, one request for everything:

```lua
DataStore2.Combine("MainDataStore", "coins", "level", "inventory")

-- Now each of these still looks like a separate store to your code,
-- but they share one underlying DataStore key and one save cycle.
local coinsStore = DataStore2("coins", player)
local levelStore = DataStore2("level", player)
```

This is important because Roblox DataStore budget scales per-key, not per-byte. Combining ten small stores into one reduces your budget consumption by 10x without changing your code structure.

## When to pick DataStore2 vs. ProfileStore

Choose **DataStore2** when:
- Your game is single-player / solo-progression (no trading)
- You want the simpler model and don't need session locking
- You specifically want DataStore2's backup retry semantics
- You're maintaining an existing DataStore2 codebase

Choose **ProfileStore** when:
- You have trading, gifts, or cross-player item transfer
- You want canonical session locking against dupe exploits
- You want `MessageAsync` for cross-server messaging
- You're starting a new project in 2026

Both are production-quality, used in shipped games, and vastly better than raw DataStores.

## Source

Original URL: https://github.com/Kampfkarren/Roblox (DataStore2 subdirectory)
Docs: https://kampfkarren.github.io/Roblox/
API reference: https://kampfkarren.github.io/Roblox/api/
Backups: https://kampfkarren.github.io/Roblox/advanced/backups/
Captured: 2026-04-15
