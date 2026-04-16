---
title: ProfileStore
type: library
category: libraries
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/profilestore-readme.md
  - wiki/raw/community/devforum/profilestore-datastore-module.md
related: [[[ProfileService]], [[session-locking]], [[DataStoreService]]]
tags: [library, datastore, session-locking, persistence]
---

# ProfileStore

> The recommended successor to ProfileService. Same session-locking model with 10x fewer DataStore calls, MessagingService-driven handoff, and better observability.

## Summary

ProfileStore is a Roblox DataStore wrapper by loleris (MadStudioRoblox) that streamlines auto-saving, session locking, and cross-server messaging. It is the actively maintained successor to [[ProfileService]]. The core mental model is unchanged: load a player's data once per server into `Profile.Data`, work with it locally, and let the module handle persistence and crash recovery. The key improvements are a 300-second default auto-save interval (down from 30 s), MessagingService-driven session handoff, exponential backoff retries, and a cleaner API surface.

**Maintainer:** loleris (MadStudioRoblox)
**Status:** Active; the recommended DataStore library for new Roblox projects.

## Installation

### Wally

```toml
[dependencies]
ProfileStore = "madstudioroblox/profilestore@latest"
```

### Roblox Creator Store

Available as a model: https://create.roblox.com/store/asset/109379033046155/ProfileStore

## Quick Start

```lua
local ProfileStore = require(game.ServerScriptService.ProfileStore)

local PLAYER_STORE = ProfileStore.New("PlayerData", {
    Cash = 0,
    Items = {},
})

local function onPlayerAdded(player)
    local profile = PLAYER_STORE:StartSessionAsync("Player_" .. player.UserId, {
        Cancel = function()
            return player.Parent ~= game:GetService("Players")
        end,
    })

    if profile ~= nil then
        profile:AddUserId(player.UserId)
        profile:Reconcile()

        profile.OnSessionEnd:Connect(function()
            player:Kick("Session ended")
        end)

        if player.Parent == game:GetService("Players") then
            -- profile.Data is ready
        else
            profile:EndSession()
        end
    else
        player:Kick("Data load failed")
    end
end
```

## Key API

| Symbol | Description |
|--------|-------------|
| `ProfileStore.New(name, template)` | Creates a store handle (replaces `GetProfileStore`). |
| `store:StartSessionAsync(key, options)` | Loads a profile with session locking. Accepts a `Cancel` callback. Replaces `LoadProfileAsync`. |
| `profile.Data` | Mutable data table. Same as ProfileService. |
| `profile:Reconcile()` | Fills missing template fields. Same behavior. |
| `profile:EndSession()` | Saves and releases the lock. Replaces `Release`. |
| `profile.OnSessionEnd` | Signal that fires when the session is taken by another server. Replaces `ListenToRelease`. |
| `profile.LastSavedData` | Read-only snapshot of the last durably persisted data. Compare with `Data` to know what is in RAM only. |
| `profile.OnSave` / `OnLastSave` / `OnAfterSave` | Signals for observing persistence events. |
| `store:MessageAsync(key, message)` | Send a message to a profile (active or offline). Replaces GlobalUpdates. |
| `profile.OnNewMessage` | Signal that fires when a message arrives via `MessageAsync`. |

## Key Changes vs. ProfileService

| Aspect | ProfileService | ProfileStore |
|--------|---------------|--------------|
| Auto-save interval | 30 s | 300 s (10x fewer DataStore calls) |
| Session handoff | DataStore heartbeat polling | MessagingService (near-instant) |
| Messaging API | GlobalUpdates (queue-based) | `MessageAsync` / `OnNewMessage` (direct) |
| Observability | MetaTags | `LastSavedData`, `OnSave`, `OnAfterSave` |
| Retry/backoff | Basic | Exponential backoff with cancel conditions |
| API vocabulary | Load/Release | StartSession/EndSession |

## When to Use / When Not to Use

**Use when:**
- Starting any new Roblox project that needs persistent player data
- Migrating from ProfileService for lower DataStore call volume and faster handoff
- You need `LastSavedData` to verify durable persistence before confirming purchases

**Do not use when:**
- Building leaderboards or global state (use MemoryStoreService or OrderedDataStore)
- The data is ephemeral session-only (use MemoryStoreService)

## Migration from ProfileService

ProfileStore is backward compatible with ProfileService's on-disk format. Migration steps:

1. Add ProfileStore alongside ProfileService
2. Replace `ProfileService.GetProfileStore` with `ProfileStore.New`
3. Rename `LoadProfileAsync` to `StartSessionAsync`, `Release` to `EndSession`, `ListenToRelease` to `OnSessionEnd`
4. Replace `GlobalUpdates` with `MessageAsync` / `OnNewMessage`
5. Test rapid rejoin between two servers
6. Deploy -- rollback is safe since on-disk format is compatible

## Alternatives

| Library | Trade-off |
|---------|-----------|
| [[ProfileService]] | Predecessor. Stable but no longer maintained. Higher DataStore call volume. |
| Suphis DataStore Module | Different API, alternative approach to session locking. |
| Raw DataStore | No abstraction; all retry, throttling, and session locking is manual. |

## Related

- [[ProfileService]] -- predecessor library
- [[session-locking]] -- the concept this library implements
- [[DataStoreService]] -- underlying Roblox service

## Sources

- [ProfileStore README](wiki/raw/community/articles/library-readmes/profilestore-readme.md)
- [DevForum: ProfileStore - Save your player data easy](wiki/raw/community/devforum/profilestore-datastore-module.md)
- GitHub: https://github.com/MadStudioRoblox/ProfileStore
- Docs: https://madstudioroblox.github.io/ProfileStore/
