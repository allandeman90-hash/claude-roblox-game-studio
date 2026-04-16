---
title: ProfileStore — Periodic DataStore Saving with Session Locking
type: raw-source
source_url: https://github.com/MadStudioRoblox/ProfileStore
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: library
author: loleris (MadStudioRoblox)
tags: [datastore, session-locking, profile, persistence, player-data, successor]
---

# ProfileStore — Periodic DataStore Saving with Session Locking

**Author:** loleris (MadStudioRoblox)
**Source:** GitHub README — `MadStudioRoblox/ProfileStore`
**Status:** Active; recommended successor to ProfileService

## What it is

ProfileStore is a Roblox DataStore wrapper that streamlines auto-saving, session locking, and a handful of other features for game developers. It is the successor module to ProfileService and is the module loleris actively recommends for new projects.

The headline concept is unchanged from ProfileService: load a player's data once per server into `Profile.Data`, work with it locally, and let the module handle auto-save, crash recovery, and session ownership.

## What changed vs. ProfileService

### 1. Default auto-save period: 30 s → 300 s

The default auto-save interval was increased by 10x. The rationale: Roblox DataStore has global per-key and per-game budgets; ProfileStore found 300 s is safe even for 100+ CCU servers because crash recovery is orthogonal to the auto-save cadence. The net effect is nearly 10× fewer DataStore calls and materially lower server resource usage.

### 2. MessagingService-driven session handoff

ProfileService's session handoff relied primarily on the DataStore itself (reading the lock heartbeat every load). ProfileStore upgrades this to use `MessagingService` for faster cross-server signals — when a new server claims a profile, it pings the old owner via `MessagingService` and asks it to release. This reduces the handoff wait from "up to auto-save period" to near-instant.

### 3. Robust retry/backoff primitives

The module incorporates exponential backoff, timeouts, and cancel conditions. This minimizes strain on Roblox services during DataStore outages or rate-limit events, and avoids the "thundering herd" problem when a server comes back online.

### 4. Replaced APIs

| ProfileService | ProfileStore |
|---|---|
| `Profile.MetaData.MetaTags` | `Profile.LastSavedData` (diff against this to know what was durable) |
| `GlobalUpdates` | `ProfileStore:MessageAsync(profileKey, message)` |
| `:ListenToRelease()` | `Profile.OnSessionEnd` |
| implicit auto-save | `Profile.OnSave`, `Profile.OnLastSave`, `Profile.OnAfterSave` signals |

The new `Profile.LastSavedData` is a significant DX win: you can compare the current `Data` against `LastSavedData` to know exactly what has been durably persisted versus what is still in RAM and could be lost on crash. This enables patterns like "do not show a confirmation until `LastSavedData.Purchase == currentPurchase`."

### 5. Simpler MessageAsync

Instead of configuring GlobalUpdates queues, ProfileStore gives you a direct message-passing API: `ProfileStore:MessageAsync(profileKey, messageTable)`. If the profile is active somewhere, it receives the message via `Profile.OnNewMessage`. If not, the message is queued in storage until a session picks it up. This is much less boilerplate for things like cross-server trades, admin mail, gifting, etc.

## Core API sketch

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

Note the renames: `LoadProfileAsync` → `StartSessionAsync`, `Release` → `EndSession`, `ListenToRelease` → `OnSessionEnd`. This is a deliberate "session" vocabulary to match the session-locking mental model.

## What it is not designed for

The documentation is explicit: "ProfileStore is not designed (and never will be) for in-game leaderboards or any kind of global state."

ProfileStore optimizes for per-player, per-key, session-locked workloads. For global state you should use `MemoryStoreService` (ordered sorted maps for live leaderboards, hash maps for shared counters) or a separate DataStore with a different access pattern. Shoehorning leaderboards into a ProfileStore would defeat its session-locking design — you would have thousands of servers contending for a single lock.

## Migration from ProfileService

ProfileStore is backward compatible with ProfileService data formats in most cases — both use the same underlying DataStore layout. The recommended migration:

1. Add ProfileStore to your project, keeping ProfileService installed.
2. In a test place, switch one PlayerService-style boot script from `ProfileService.GetProfileStore` to `ProfileStore.New`.
3. Rename all `LoadProfileAsync`/`Release`/`ListenToRelease` calls to the new session-vocabulary equivalents.
4. Replace `GlobalUpdates` code with `MessageAsync` / `OnNewMessage`.
5. Test session handoff by rejoining rapidly between two servers.
6. Deploy.

Because ProfileStore's on-disk format is compatible, you can roll back if needed.

## Why ProfileStore became the default

The community moved to ProfileStore for a few reasons that the README implicitly addresses:

- **10× fewer DataStore calls.** At 100+ CCU the savings in `DataStore/Budget/Get` and `Set` budgets are substantial, directly reducing throttling incidents.
- **Faster rejoin handoff.** Players who rapidly join/leave no longer wait 30 s for the session to free up.
- **Better observability.** `LastSavedData`, `OnSave`, `OnLastSave`, and `OnAfterSave` let you instrument and alert on persistence events.
- **Active maintenance.** ProfileService is marked unsupported; ProfileStore is the one still getting fixes.

## Source

Original URL: https://github.com/MadStudioRoblox/ProfileStore
Documentation: https://madstudioroblox.github.io/ProfileStore/
Captured: 2026-04-15
