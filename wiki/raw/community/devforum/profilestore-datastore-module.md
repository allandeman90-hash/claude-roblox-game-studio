---
title: ProfileStore - Save your player data easy (DataStore Module)
type: raw-source
source_url: https://devforum.roblox.com/t/profilestore-save-your-player-data-easy-datastore-module/3190543
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: loleris
post_date: 2024-10-11
tags: [datastore, session-locking, profilestore, community-resource, data-persistence, messagingservice]
---

# ProfileStore - Save your player data easy (DataStore Module)

**Author:** loleris
**Posted:** October 11, 2024

## Core Purpose

ProfileStore is a Roblox DataStore wrapper enabling streamlined auto-saving, session locking, and player data management through a single ModuleScript. It is the successor to ProfileService.

## Key Resources

- **Documentation:** https://madstudioroblox.github.io/ProfileStore
- **Module:** https://create.roblox.com/store/asset/109379033046155/ProfileStore
- **GitHub:** https://github.com/MadStudioRoblox/ProfileStore

## Session Locking & Implementation

ProfileStore prevents multi-server data conflicts by:

> "keeping track of which game server is currently caching data and gracefully switches ownership from one server to the other without failing new session requests"

The system uses MessagingService alongside DataStore UpdateAsync calls to resolve session conflicts faster than the predecessor module.

## Major Changes from ProfileService

| Feature | Change |
|---------|--------|
| Auto-save Period | 30 seconds → **300 seconds** (10x fewer calls) |
| Conflict Resolution | MessagingService integration for faster response |
| DataStore Queue | Replaced 7-second queue with per-key operation sequencing |
| MetaTags | Removed; replaced with `Profile.LastSavedData` (server-side cache only) |
| GlobalUpdates | Replaced with simpler `ProfileStore:MessageAsync()` |

## Essential Code Example

```lua
local ProfileStore = require(game.ServerScriptService.ProfileStore)

local PROFILE_TEMPLATE = {
   Cash = 0,
   Items = {},
}

local PlayerStore = ProfileStore.New("PlayerStore", PROFILE_TEMPLATE)
local Profiles = {}

local function PlayerAdded(player)
   local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
      Cancel = function()
         return player.Parent ~= Players
      end,
   })

   if profile ~= nil then
      profile:AddUserId(player.UserId)
      profile:Reconcile()

      profile.OnSessionEnd:Connect(function()
         Profiles[player] = nil
         player:Kick("Profile session end - Please rejoin")
      end)

      if player.Parent == Players then
         Profiles[player] = profile
         profile.Data.Cash += 100
      else
         profile:EndSession()
      end
   else
      player:Kick("Profile load fail - Please rejoin")
   end
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
   local profile = Profiles[player]
   if profile ~= nil then
      profile:EndSession()
   end
end)
```

## Backward Compatibility

ProfileService profiles load in ProfileStore using identical keys; however, older ProfileService modules may encounter issues if `ProfileStore:MessageAsync()` is used afterward. Studio testing recommended before production deployment.

## Usage Statistics

Notable games adopting ProfileStore:
- **Grow a Garden:** 30B+ visits
- **Dead Rails:** 5B+ visits

## Source

Original URL: https://devforum.roblox.com/t/profilestore-save-your-player-data-easy-datastore-module/3190543
Captured: 2026-04-16
