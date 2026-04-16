---
title: Suphi's DataStore Module
type: raw-source
source_url: https://devforum.roblox.com/t/suphis-datastore-module/2425597
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: 5uphi
post_date: 2023-06-15
tags: [datastore, session-locking, memorystore, module, community-resource]
---

# Suphi's DataStore Module

**Author:** 5uphi
**Posted:** June 15, 2023

## Overview

An event-based DataStore wrapper for Roblox with session locking implemented via MemoryStore (instead of timestamp-based approaches used by ProfileService).

## Session Locking Implementation

The module prevents concurrent access to the same datastore key using MemoryStore rather than timestamps. Key properties control this:

- **LockInterval** (default: 60 seconds): How often the MemoryStore refreshes the session lock
- **LockAttempts** (default: 5): Failed attempts before session closes
- **AttemptsRemaining**: Read-only counter tracking remaining lock attempts

Critical usage rule:

> "only use DataStoreModule.new() inside PlayerAdded and nowhere else" to avoid lock conflicts during teleports.

## API Overview

**Constructor Methods:**
- `new(name, scope, key)` / `new(name, key)` — Returns existing or creates new session
- `hidden(name, scope, key)` — Creates unlisted session
- `find(name, scope, key)` — Returns existing session or nil

**Key Methods:**
- `Open(template)` — Initiates session with optional data reconciliation
- `Save()` — Force saves cached data
- `Close()` / `Destroy()` — Closes or destroys session
- `Queue(value, expiration, priority)` — Cross-server messaging via MemoryStoreQueue
- `Reconcile(template)` — Fills missing values from template

**Properties:**
- `Value` — Direct datastore access (never modified by module)
- `State` — nil (destroyed), false (closed), true (open)
- `SaveInterval` — Auto-save frequency in seconds (0 disables)
- `SaveOnClose` — Boolean for persistence on session end

## Code Example: Player Data

```lua
local DataStoreModule = require(11671168253)

local template = {
    Level = 0,
    Coins = 0,
    Inventory = {},
}

game.Players.PlayerAdded:Connect(function(player)
    local dataStore = DataStoreModule.new("Player", player.UserId)
    dataStore:Open(template)
end)

game.Players.PlayerRemoving:Connect(function(player)
    local dataStore = DataStoreModule.find("Player", player.UserId)
    if dataStore then dataStore:Destroy() end
end)
```

## Key Differentiators

- Uses MemoryStore for session locking (vs. ProfileService's `os.time` timestamps)
- Caching-based with configurable save intervals
- 100% event-driven (no RunService loops)
- "Direct value access—module never tampers with data"

## Source

Original URL: https://devforum.roblox.com/t/suphis-datastore-module/2425597
Captured: 2026-04-16
