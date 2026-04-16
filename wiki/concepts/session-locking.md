---
title: session-locking
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
  - "[[schema-versioning]]"
  - "[[bind-to-close]]"
  - "[[item-duplication]]"
  - "[[session-hijack]]"
  - "[[no-session-lock]]"
tags: [concept, persistence, security, required]
---

# Session Locking

> The pattern that prevents player data from being loaded by two servers simultaneously, which would otherwise enable item duplication and data loss.

## What It Is

Session locking is a coordination pattern for persistent player data on Roblox. When a player joins a server, the server "acquires a lock" on that player's data before reading it. When the player leaves or the server shuts down, the server releases the lock. Any other server that tries to acquire the lock while it's held must wait (or refuse).

Without session locking, two scenarios go wrong:

1. **Item duplication exploit**: Player joins Server A, which loads their data. Player tells their friend on Server B to join via their user. Server B also loads the data (there's no lock). Player does something on Server A, saves. Player teleports to Server B, which still has the stale pre-A state. Saves over Server A's save. Any items gained on Server A are now re-grantable on Server B.
2. **Data loss on concurrent writes**: Two servers write different versions of the same data; the last write wins, and whichever server wrote earlier loses those changes.

Session locking makes data ownership serial: only one server at a time holds a player's data.

## When to Use It

**Always**. Every production Roblox game that persists player data must implement session locking. There is no exception.

Libraries like [ProfileService](https://devforum.roblox.com/t/profileservice/667805) and [ProfileStore](https://devforum.roblox.com/t/profilestore-full-fledged-datastore-api/2674577) provide this out of the box. If you roll your own DataStore layer, you must implement it yourself.

## Implementation

### Using `UpdateAsync` for atomic lock acquisition

The cleanest implementation uses `UpdateAsync`:

```lua
local DataStoreService = game:GetService("DataStoreService")
local lockStore = DataStoreService:GetDataStore("SessionLocks")

local LOCK_TTL = 60  -- seconds — if lock older than this, it's stale

-- Try to acquire a lock. Returns true on success.
local function acquireLock(userId: number): boolean
    local jobId = game.JobId  -- unique per server instance
    local ok, result = pcall(function()
        return lockStore:UpdateAsync("Lock_" .. userId, function(existing)
            if existing and existing.jobId ~= jobId then
                -- Lock is held by a different server
                if os.time() - existing.time < LOCK_TTL then
                    return nil  -- abort update, existing value stays
                end
                -- lock is stale, we can take over
            end
            return { jobId = jobId, time = os.time() }
        end)
    end)
    return ok and result ~= nil
end

local function releaseLock(userId: number)
    pcall(function()
        lockStore:UpdateAsync("Lock_" .. userId, function(existing)
            if existing and existing.jobId == game.JobId then
                return nil  -- delete the lock
            end
            return existing  -- not ours, don't touch
        end)
    end)
end
```

### Integrating with player lifecycle

```lua
local Players = game:GetService("Players")
local dataStore = DataStoreService:GetDataStore("PlayerData_v1")

local loadedData: {[Player]: any} = {}

Players.PlayerAdded:Connect(function(player)
    -- Try to acquire the lock, retrying if another server holds it
    local acquired = false
    for attempt = 1, 6 do
        if acquireLock(player.UserId) then
            acquired = true
            break
        end
        task.wait(5)  -- wait 5s before retrying
    end

    if not acquired then
        player:Kick("Could not acquire data lock. Try rejoining.")
        return
    end

    -- Now safe to load
    local ok, data = pcall(function()
        return dataStore:GetAsync("Player_" .. player.UserId)
    end)
    loadedData[player] = ok and data or getDefaultData()
end)

Players.PlayerRemoving:Connect(function(player)
    -- Save then release lock
    local data = loadedData[player]
    if data then
        pcall(function()
            dataStore:SetAsync("Player_" .. player.UserId, data)
        end)
    end
    releaseLock(player.UserId)
    loadedData[player] = nil
end)
```

### Handling `BindToClose`

When a server shuts down, `PlayerRemoving` may fire for each player but the server has **at most 30 seconds** before Roblox force-terminates. Save all players and release all locks in parallel:

```lua
game:BindToClose(function()
    local threads = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(threads, coroutine.create(function()
            local data = loadedData[player]
            if data then
                pcall(function()
                    dataStore:SetAsync("Player_" .. player.UserId, data)
                end)
            end
            releaseLock(player.UserId)
        end))
    end
    for _, t in ipairs(threads) do coroutine.resume(t) end

    local deadline = os.clock() + 25  -- leave 5s buffer
    for _, t in ipairs(threads) do
        while coroutine.status(t) ~= "dead" and os.clock() < deadline do
            task.wait(0.1)
        end
    end
end)
```

See [[bind-to-close]] for the full pattern.

## Variants

- **`UpdateAsync`-based** (shown above): cleanest; atomic read-modify-write.
- **Separate lock key + TTL**: use `SetAsync` with timestamp, poll with TTL check. More code, same result.
- **MemoryStoreService for short-lived locks**: faster but locks expire in 45 days max; fine for session use.
- **Third-party: ProfileService / ProfileStore**: production-grade implementations; prefer these over rolling your own for real projects.

## Pitfalls

- **No lock**: the #1 mistake. Enables item duplication. See [[item-duplication]].
- **Lock TTL too short**: server crash = lock stuck; players can't load until TTL expires.
- **Lock TTL too long**: stale locks from crashed servers block legitimate joins for a long time.
- **Not releasing lock on error paths**: player kicked mid-save → lock never released → player locked out.
- **Storing lock in memory only**: server restart = lost locks = duplicate loads.
- **`player.Name` in key**: use `UserId`. See [[player-name-as-key]].

## Related

- [[DataStoreService]] — the service this pattern uses
- [[schema-versioning]] — pairs with session locking for full data safety
- [[bind-to-close]] — required companion for shutdown handling
- [[item-duplication]] — the exploit this prevents
- [[session-hijack]] — related exploit
- [[no-session-lock]] — anti-pattern: forgetting this
- [DataStore Rules](../../.claude/rules/datastores.md)

## Sources

- [.claude/agents/datastore-architect.md](../../.claude/agents/datastore-architect.md)
- [.claude/rules/datastores.md](../../.claude/rules/datastores.md)
- [ProfileService by loleris](https://devforum.roblox.com/t/profileservice/667805) (reference implementation)
