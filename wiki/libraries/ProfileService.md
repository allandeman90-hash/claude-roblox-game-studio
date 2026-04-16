---
title: ProfileService
type: library
category: libraries
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/profileservice-readme.md
  - wiki/raw/community/devforum/profileservice-datastore-module.md
related: [[[ProfileStore]], [[session-locking]], [[DataStoreService]]]
tags: [library, datastore, session-locking, persistence]
---

# ProfileService

> Session-locked DataStore wrapper that loads player data once per server, works with it locally, and handles auto-saving, crash recovery, and ownership handoff automatically.

## Summary

ProfileService is a standalone ModuleScript by loleris (MadStudioRoblox) that manages loading and auto-saving DataStore profiles for Roblox games. A "profile" is a set of data loaded once per server, read/written locally, auto-saved periodically, and saved immediately on release. The library's core feature is **session locking** -- it tracks which server owns a profile and gracefully transfers ownership when a player moves between servers, preventing the data duplication bugs that plague raw DataStore usage.

**Maintainer:** loleris (MadStudioRoblox)
**Status:** No longer actively maintained. Stable for existing projects, but [[ProfileStore]] is the recommended successor for new work.
**License:** Apache-2.0

## Installation

### Wally

```toml
[dependencies]
ProfileService = "madstudioroblox/profileservice@latest"
```

### Manual

Download the ModuleScript from the GitHub releases and place it in `ServerScriptService`.

## Quick Start

```lua
local Players = game:GetService("Players")
local ProfileService = require(game.ServerScriptService.ProfileService)

local ProfileTemplate = {
    Cash = 0,
    Items = {},
    LogInTimes = 0,
}

local PlayerProfileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)
local Profiles = {}

local function onPlayerAdded(player)
    local profile = PlayerProfileStore:LoadProfileAsync(
        "Player_" .. player.UserId,
        "ForceLoad"
    )
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
        player:Kick()
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    local profile = Profiles[player]
    if profile ~= nil then
        profile:Release()
    end
end)
```

## Key API

| Symbol | Description |
|--------|-------------|
| `ProfileService.GetProfileStore(name, template)` | Returns a ProfileStore handle for the given DataStore name and default template. |
| `store:LoadProfileAsync(key, mode)` | Loads a profile with session locking. `"ForceLoad"` steals stale locks. Blocks until lock acquired. |
| `profile.Data` | The mutable data table. Changes here persist on the next auto-save or final save. |
| `profile:Reconcile()` | Fills missing fields from the template into `Data`. Zero-downtime schema migration. |
| `profile:Release()` | Ends the session, saves immediately, and releases the lock. |
| `profile:ListenToRelease(fn)` | Fires when another server steals the session. Convention: kick the player. |
| `profile:AddUserId(userId)` | Tags the profile with a UserId for GDPR compliance. |
| `profile.GlobalUpdates` | Out-of-session messaging system for cross-server gifts, admin mail, trade completions. |
| `profile.MetaData.MetaTags` | Side-channel metadata persisted alongside `Data` but logically separate. |

## When to Use / When Not to Use

**Use when:**
- Existing projects already built on ProfileService that are stable and shipping
- The project does not need the faster MessagingService-based handoff or lower DataStore call volume of ProfileStore

**Do not use when:**
- Starting a new project (use [[ProfileStore]] instead)
- Building leaderboards or global state (use MemoryStoreService or OrderedDataStore)
- You need the `LastSavedData` observability or `MessageAsync` API that only ProfileStore provides

## Alternatives

| Library | Trade-off |
|---------|-----------|
| [[ProfileStore]] | Recommended successor. 10x fewer DataStore calls, MessagingService handoff, `LastSavedData` observability. |
| Suphis DataStore Module | Alternative DataStore wrapper with a different API shape. |
| Raw DataStore | No abstraction overhead, but session locking, retry, and throttling become your problem. |

## Related

- [[ProfileStore]] -- successor library
- [[session-locking]] -- the concept ProfileService implements
- [[DataStoreService]] -- underlying Roblox service

## Sources

- [ProfileService README](wiki/raw/community/articles/library-readmes/profileservice-readme.md)
- [DevForum: Save your player data with ProfileService](wiki/raw/community/devforum/profileservice-datastore-module.md)
- GitHub: https://github.com/MadStudioRoblox/ProfileService
- Docs: https://madstudioroblox.github.io/ProfileService/
