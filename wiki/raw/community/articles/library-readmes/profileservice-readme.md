---
title: ProfileService — Universal Session-Locked Savable Table API
type: raw-source
source_url: https://github.com/MadStudioRoblox/ProfileService
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: library
author: loleris (MadStudioRoblox)
tags: [datastore, session-locking, profile, persistence, player-data]
---

# ProfileService — Universal Session-Locked Savable Table API

**Author:** loleris (MadStudioRoblox)
**Source:** GitHub README — `MadStudioRoblox/ProfileService`
**License:** Apache-2.0

## What it is

ProfileService is a stand-alone ModuleScript that specializes in loading and auto-saving DataStore profiles for Roblox games. It defines a "profile" as a set of data that is meant to be loaded up only once inside a Roblox server, then written to and read from locally on that server while being periodically auto-saved — and saved immediately once the server finishes working with it.

> **Project status:** "FOR NEW PROJECTS — USE ProfileStore. This project is no longer supported — it's been stable for a long while." ProfileService remains stable for existing code, but `ProfileStore` is the recommended successor for new projects.

## Why ProfileService

The README advertises these core advantages:

- **Easy to learn, and eventually forget.** ProfileService imposes no getter/setter functions on the developer. You work directly with `Profile.Data`, a plain Lua table.
- **Built for massive scalability.** Low resource footprint, no excessive type checking. Designed to handle 100+ player servers without stress.
- **Session-locking.** A universal solution to the race condition between DataStore `GetAsync` and `SetAsync` calls. Without session locking, a player who joins a new server faster than their old session can save risks item loss or duplication. ProfileService tracks which server currently "owns" a profile and gracefully switches ownership when a new session request arrives.
- **Future-proof.** Features like MetaTags and GlobalUpdates let you add new metadata and send cross-server messages to a profile without restructuring storage.
- **Profile object abstraction detached from Player.** You can create profiles for non-player entities — group-owned houses, savable multiplayer game instances, guilds, etc. Nothing forces a 1:1 mapping to `Player`.
- **Automatic DataStore throttling.** ProfileService spreads DataStore API calls evenly within the auto-save loop timeframe, preventing spikes that would get throttled by the Roblox DataStore rate limits.

## Core concepts

### ProfileStore (the wrapper object)

You first create a `ProfileStore` — a handle to a specific DataStore name plus a template for new profiles:

```lua
local ProfileService = require(game.ServerScriptService.ProfileService)

local ProfileTemplate = {
    Cash = 0,
    Items = {},
    LogInTimes = 0,
}

local PlayerProfileStore = ProfileService.GetProfileStore(
    "PlayerData",
    ProfileTemplate
)
```

### Profile (the per-key session)

To load a profile for a specific key (usually `"Player_" .. userId`), you call `:LoadProfileAsync`. This returns a `Profile` object representing an active session:

```lua
local profile = PlayerProfileStore:LoadProfileAsync("Player_" .. userId, "ForceLoad")

if profile ~= nil then
    profile:AddUserId(player.UserId)   -- GDPR compliance
    profile:Reconcile()                 -- fill missing template fields
    profile:ListenToRelease(function()
        Profiles[player] = nil
        player:Kick()
    end)

    if player:IsDescendantOf(Players) then
        Profiles[player] = profile
        -- Data ready to use: profile.Data.Cash, etc.
    else
        profile:Release()
    end
end
```

Key session-lifecycle behaviors:

- `LoadProfileAsync` blocks until a session lock is acquired (or is gracefully stolen from a crashed/ghost server).
- `Profile.Data` is the mutable table — any change here will be persisted on the next auto-save or final save.
- `profile:Reconcile()` fills in fields that exist in the template but are missing from the stored data, which makes schema migrations trivial.
- `profile:Release()` ends the session, forcing an immediate save and releasing the lock.
- `profile:ListenToRelease(...)` fires when another server "steals" the session (for example, when the player joins a new server). The convention is to Kick the player so the new server can load their fresh data.

### Session-locking (the core feature)

The README explains why this matters: without session locking, if a player rejoins into a second server before the first server finishes its save, the second server may read stale data, then overwrite the first server's newer save with that stale data when it saves later. In trading games this causes item dupes.

ProfileService's algorithm (summarized from the public API docs):

1. On `LoadProfileAsync`, the current session lock is read from the DataStore.
2. If no lock exists or the previous lock is from a dead server (as determined by a heartbeat `LastUpdate` timestamp), the new server claims the lock and loads the data.
3. If a lock exists and the previous server is alive, the new server either waits or, in `"ForceLoad"` mode, requests the old server to release the session via `GlobalUpdates`/MessagingService. The old server then kicks the player and releases the lock.
4. Once the new server holds the lock, reads/writes happen locally against `Profile.Data` until `Release` or server shutdown.

This is the reason ProfileService is often cited as the canonical solution to Roblox data persistence: it encapsulates the entire race-condition handling so game code never has to think about it.

### Reconcile — schema migration pattern

```lua
-- In the template:
local ProfileTemplate = {
    Cash = 0,
    Items = {},
    Settings = {
        MusicVolume = 1,
        GraphicsQuality = "High",
    },
}

-- After :LoadProfileAsync returns a profile:
profile:Reconcile()
-- Any missing keys (e.g. a new Settings.GraphicsQuality field added later)
-- are populated with the template values.
```

This is one of the most-loved features: adding a new field to the template and calling `Reconcile()` on load is effectively a free, zero-downtime migration.

### GlobalUpdates — out-of-session messaging

GlobalUpdates let other servers (or offline flows like a web dashboard) deliver messages to a profile even when that profile's owning server is not currently online. Typical uses: gifting items, admin mail, cross-server trade completions.

Two categories:

- **Pending updates** — delivered to storage; not yet seen by the active session.
- **Active updates** — the live session has received the update and can act on it, then lock or clear it.

```lua
profile.GlobalUpdates:ListenToNewActiveUpdate(function(updateId, updateData)
    -- e.g. grant an item, then clear the update
    profile.GlobalUpdates:ClearActiveUpdate(updateId)
end)

profile.GlobalUpdates:ListenToNewLockedUpdate(function(updateId, updateData)
    -- Final confirmation step if you used locked updates
    profile.GlobalUpdates:ClearLockedUpdate(updateId)
end)
```

### MetaTags — side-channel metadata

`Profile.MetaData.MetaTags` is a separate small table for data that is not part of the main `Data` payload — things like "has completed tutorial v2" or "last rewarded daily bonus at" — that you want to persist but logically keep separate from player-visible state. MetaTags are saved alongside Data.

## Recommended bootstrapping pattern

The README's canonical PlayerService-style setup:

```lua
local Players = game:GetService("Players")

local ProfileService = require(game.ServerScriptService.ProfileService)
local ProfileTemplate = require(game.ServerScriptService.ProfileTemplate)

local PlayerProfileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)
local Profiles = {}

local function PlayerAdded(player)
    local profile = PlayerProfileStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")
    if profile ~= nil then
        profile:AddUserId(player.UserId)
        profile:Reconcile()
        profile:ListenToRelease(function()
            Profiles[player] = nil
            player:Kick()
        end)
        if player:IsDescendantOf(Players) then
            Profiles[player] = profile
        else
            profile:Release()
        end
    else
        -- Data issue — safest to kick and retry
        player:Kick()
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(PlayerAdded, player)
end
Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    local profile = Profiles[player]
    if profile ~= nil then
        profile:Release()
    end
end)
```

## Why developers use it instead of raw DataStore

ProfileService collapses several hard problems into a single module:

| Problem | Raw DataStore | ProfileService |
|---|---|---|
| Rate limits | Hand-rolled queue | Auto-spread inside auto-save loop |
| Crash during save | Possible rollback | Session lock handoff recovers |
| Dupe exploits via rejoin | Possible | Session lock prevents |
| Schema migration | Manual | `:Reconcile()` + template |
| Cross-server gifting | Custom messaging code | `GlobalUpdates` |
| Error handling and retries | Custom pcall loops | Built-in |

## Source

Original URL: https://github.com/MadStudioRoblox/ProfileService
Documentation: https://madstudioroblox.github.io/ProfileService/
Captured: 2026-04-15
