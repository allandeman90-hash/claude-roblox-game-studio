---
title: bind-to-close
type: concept
category: concepts
subcategory: persistence
owner: datastore-architect
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - .claude/agents/datastore-architect.md
  - .claude/rules/datastores.md
related:
  - "[[DataStoreService]]"
  - "[[session-locking]]"
  - "[[schema-versioning]]"
  - "[[bind-to-close-skip]]"
tags: [concept, persistence, required]
---

# BindToClose

> The Roblox lifecycle hook that runs when a server is shutting down. Last chance to save player data before the process exits.

## What It Is

`game:BindToClose(callback)` registers a function that Roblox calls when the server is about to shut down. The callback has **up to 30 seconds** to complete; after that, the server process is killed regardless.

This is the only reliable way to save data for players still in a server when a shutdown occurs. `PlayerRemoving` fires for individual players, but during a shutdown all players leave essentially simultaneously — and the usual per-player save path may not have time to finish.

## Why It Matters

Without `BindToClose`:
- Server starts, players join, data loads
- Server shuts down (update, crash, migration)
- Players are ejected; their data is written to... where? If you rely on `PlayerRemoving`, it fires, but the 30-second budget is shared across all players and all save paths
- Without BindToClose-specific coordination, some saves may not complete → data loss

With `BindToClose`:
- Shutdown signal received
- All players saved in parallel (coroutines)
- Session locks released
- Clean exit

## Implementation

### Basic Pattern

```lua
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("PlayerData_v1")

game:BindToClose(function()
    -- Spawn a coroutine per player so saves run in parallel
    local threads = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local thread = coroutine.create(function()
            local data = getPlayerData(player)  -- your in-memory cache
            if data then
                pcall(function()
                    store:SetAsync("Player_" .. player.UserId, data)
                end)
            end
            releaseSessionLock(player.UserId)  -- see [[session-locking]]
        end)
        table.insert(threads, thread)
        coroutine.resume(thread)
    end

    -- Wait up to 25 seconds for saves (leaving 5s buffer)
    local deadline = os.clock() + 25
    for _, t in ipairs(threads) do
        while coroutine.status(t) ~= "dead" and os.clock() < deadline do
            task.wait(0.1)
        end
    end
end)
```

### Why Parallel Saves

If you save sequentially (one player, then the next, then the next), with 50 players and 1-2 seconds per save you could hit the 30-second deadline with half the players still unsaved. Parallel execution is the only way to reliably save a full server in time.

### Why `pcall`

DataStore calls can fail at any time. A failure in the middle of a `BindToClose` sequence should not crash the callback or prevent other players from saving.

### The 5-Second Buffer

Roblox kills the process at 30 seconds. Aim for 25 seconds max to leave margin for:
- Unexpected latency spikes
- DataStore retries
- The `wait` loop itself

### Studio vs Production

`BindToClose` fires:
- ✅ When a server shuts down in production
- ✅ When you stop a Studio Play Solo session (F5 → Stop) — useful for testing
- ❌ On server crash (hard crash, not a clean exit)

Test your `BindToClose` handler by triggering Studio Play Solo and clicking Stop. Watch the Output window for save logs.

## Interaction with `PlayerRemoving`

`PlayerRemoving` fires during a normal player leave AND during a shutdown. If both fire for the same player, your save logic should be idempotent — saving the same data twice is harmless if your save path is deterministic.

A common pattern:
```lua
local savedThisSession: {[number]: boolean} = {}

local function saveData(player)
    if savedThisSession[player.UserId] then return end  -- debounce
    savedThisSession[player.UserId] = true
    -- ... do save ...
end

Players.PlayerRemoving:Connect(saveData)
game:BindToClose(function()
    for _, p in ipairs(Players:GetPlayers()) do
        task.spawn(saveData, p)
    end
    task.wait(25)
end)
```

The `savedThisSession` check ensures a player's data isn't re-saved if both paths fire.

## Pitfalls

- **No `BindToClose` at all**: data loss when servers restart. See [[bind-to-close-skip]].
- **Sequential saves**: can't finish 50 players in 30 seconds. Use coroutines.
- **No `pcall`**: one failed save aborts the callback.
- **Not releasing locks**: players can't rejoin until lock TTL expires.
- **Full 30 seconds used**: no safety margin. Use 25.
- **Heavy synchronous work in the callback**: use `task.wait`, not busy loops.
- **Saving data not yet modified**: wastes budget. Track dirty flags.
- **Using memory-only state**: if data never made it into your in-memory cache (e.g., player just joined), you have nothing to save.

## Related

- [[DataStoreService]] — what you're saving to
- [[session-locking]] — required companion pattern
- [[schema-versioning]] — migration safety for the data you save
- [[bind-to-close-skip]] — anti-pattern: forgetting this
- [DataStore Rules](../../.claude/rules/datastores.md)

## Sources

- [Roblox docs: BindToClose](https://create.roblox.com/docs/reference/engine/classes/DataModel#BindToClose)
- [.claude/agents/datastore-architect.md](../../.claude/agents/datastore-architect.md)
- [.claude/rules/datastores.md](../../.claude/rules/datastores.md)
