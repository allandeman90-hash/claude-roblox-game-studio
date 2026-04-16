---
title: BindToClose Deployment Pattern - Safe Shutdown Data Save
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-use-bindtoclose-for-saving-data/1276728
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: publishing
subcategory: deployment
tags: [bindtoclose, deployment, datastore, shutdown, session-lock, profilestore]
---

# BindToClose Deployment Pattern

`game:BindToClose(callback)` fires when the server is being shut down —
either by a publish, a rolling deploy, a planned restart, or because it
ran out of players. This is the **last chance** to persist player data
before the server is killed.

## The 30-second rule

BindToClose callbacks are given a **hard 30-second budget**. If the
callback is still running at 30s, the server is killed anyway. This
means you MUST save all players **in parallel**, not serially.

## Basic pattern — save in parallel

```lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetDataStore("PlayerData")

local function saveOne(player)
    xpcall(function()
        DataStore:UpdateAsync(player.UserId, function(_)
            return buildDataForPlayer(player)
        end)
    end, warn)
end

if not RunService:IsStudio() then
    game:BindToClose(function()
        -- Fire saves in parallel so all players finish within 30s.
        local threads = {}
        for _, player in ipairs(Players:GetPlayers()) do
            table.insert(threads, task.spawn(saveOne, player))
        end
        -- Give them time to finish.
        task.wait(10)
    end)
end
```

## The RunService.IsStudio check

Play-solo in Studio also triggers BindToClose, and DataStore writes in
Studio can block indefinitely or fail silently. Gate BindToClose body
with `RunService:IsStudio()` to keep dev loops fast.

## Production pattern — session-locked saves

If you use ProfileStore / ProfileService / similar, the library already
handles BindToClose for you by calling `profile:EndSession()` (or
`Release()` for ProfileService). You should still call EndSession from
**both** `PlayerRemoving` and BindToClose — the library de-duplicates.

```lua
local Players = game:GetService("Players")
local ProfileStore = require(game.ServerScriptService.ProfileStore)
local profileStore = ProfileStore.New("PlayerData", { coins = 0 })

local Profiles = {} -- [player] = profile

Players.PlayerAdded:Connect(function(player)
    local profile = profileStore:StartSessionAsync(tostring(player.UserId))
    if profile then
        profile:Reconcile()
        profile:AddUserId(player.UserId)
        Profiles[player] = profile
    else
        player:Kick("Data load failed")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local profile = Profiles[player]
    if profile then
        profile:EndSession()
        Profiles[player] = nil
    end
end)

game:BindToClose(function()
    -- Fast parallel flush for players still connected.
    for player, profile in pairs(Profiles) do
        task.spawn(function()
            profile:EndSession()
        end)
    end
    -- Block until the library reports all sessions have exited.
    while next(Profiles) do task.wait(0.1) end
end)
```

## Rollout impact

- When you publish to the universe, Roblox **rolling-restarts servers**
  as old-version sessions drain. Every running server runs BindToClose.
- A flaky BindToClose is where most "publish lost my data" bug reports
  come from — the save failed silently at the 30-second mark.
- The fix is always: **parallel saves + short explicit timeout + retry in
  the library**. Do not trust a single SetAsync to land.

## Concrete Numbers / Examples

- **30 seconds** — absolute BindToClose budget.
- **~10 seconds** — recommended `task.wait` buffer after spawning saves,
  to give in-flight DataStore requests time to land.
- **Both events** — call `EndSession()` in PlayerRemoving AND BindToClose.
- **Studio gate** — `if not RunService:IsStudio() then ... end`

## Source

Original URL: https://devforum.roblox.com/t/how-to-use-bindtoclose-for-saving-data/1276728
Related: https://kitsblox.com/blog/roblox-save-system-profilestore
Captured: 2026-04-16
