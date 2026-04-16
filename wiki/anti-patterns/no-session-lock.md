---
title: no-session-lock
type: anti-pattern
category: anti-patterns
subcategory: persistence
owner: datastore-architect
status: draft
created: 2026-04-16
updated: 2026-04-16
severity: critical
sources:
  - wiki/raw/community/devforum/session-locking-explained-datastore.md
  - wiki/raw/roblox-creator-docs/best-practices/security/client-server-boundary.md
  - .claude/docs/roblox-architecture-guide.md
related:
  - "[[session-locking]]"
  - "[[item-duplication]]"
  - "[[DataStoreService]]"
  - "[[session-hijack]]"
tags: [anti-pattern, persistence, critical]
---

# Missing Session Lock

> Loading player data from DataStoreService without acquiring a session lock. Enables cross-server item duplication and data regression.

**Severity:** Critical

## What It Looks Like

```lua
-- Naive data loading: no lock, no ownership check
local DataStore = DataStoreService:GetDataStore("PlayerData")

Players.PlayerAdded:Connect(function(player)
    local success, data = pcall(function()
        return DataStore:GetAsync("Player_" .. player.UserId)
    end)
    if success then
        playerCache[player] = data or getDefaultData()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local data = playerCache[player]
    if data then
        pcall(function()
            DataStore:SetAsync("Player_" .. player.UserId, data)
        end)
    end
    playerCache[player] = nil
end)
```

The problem: if the player joins Server B before Server A finishes saving, Server B reads stale data. Both servers now hold copies. When both save, the last writer wins and the other server's changes are lost. Items held only in the losing server's copy are duplicated or destroyed.

## Why It's Bad

1. **Item duplication**: the most exploited vector in Roblox economy games. A player initiates a trade on Server A, teleports to Server B before Server A saves. Server B loads pre-trade data. The player now has the traded items on both servers. This is described in the Roblox Creator Docs as a known race condition pattern.
2. **Data regression**: even without malicious intent, legitimate rapid server-hopping (teleport, rejoin) can cause saves to overwrite each other. The player loses progress from whichever server saves last.
3. **Undetectable by the player**: data regression is silent. The player sees their items, plays for an hour, then discovers on next login that the session was overwritten by the older server's save.
4. **Cannot be fixed retroactively**: once data is corrupted by a race condition, there is no reliable way to determine which version is "correct."

## How to Fix It

Use `UpdateAsync` with an atomic check-and-set pattern to acquire a lock before loading:

```lua
local LOCK_TIMEOUT = 1800  -- 30 minutes lease

local function acquireLock(key: string): (boolean, any)
    local success, result = pcall(function()
        return DataStore:UpdateAsync(key, function(existing)
            existing = existing or { data = getDefaultData(), lockId = nil, lockTime = 0 }

            local now = os.time()
            local lockExpired = (now - (existing.lockTime or 0)) > LOCK_TIMEOUT

            if existing.lockId == nil or existing.lockId == game.JobId or lockExpired then
                -- Acquire the lock
                existing.lockId = game.JobId
                existing.lockTime = now
                return existing
            else
                -- Another server holds the lock; abort
                return nil  -- returning nil cancels the UpdateAsync
            end
        end)
    end)
    return success, result
end

local function releaseLock(key: string, data: any)
    pcall(function()
        DataStore:UpdateAsync(key, function(existing)
            if existing and existing.lockId == game.JobId then
                existing.data = data
                existing.lockId = nil
                existing.lockTime = 0
                return existing
            end
            return nil  -- another server took over; do not overwrite
        end)
    end)
end
```

For production, use [ProfileService](https://devforum.roblox.com/t/profileservice/667805) or [ProfileStore](https://devforum.roblox.com/t/profilestore-full-fledged-datastore-api/2674577), which handle session locking, retry logic, lock stealing with lease expiry, and `BindToClose` cleanup out of the box.

Key implementation requirements:
- **Use `UpdateAsync` only** -- `GetAsync` + `SetAsync` is not atomic and creates a TOCTOU window.
- **Lease expiry** -- locks must expire after a timeout (typically 30 minutes) so crashed servers do not permanently lock data.
- **`BindToClose` release** -- release all held locks during server shutdown within the 30-second window.
- **Reject stale loads** -- if the lock cannot be acquired, kick the player with a message like "Your data is loading on another server."

## Detection

Grep for DataStore load patterns without lock logic:

```
:GetAsync(.*Player
:GetAsync(.*UserId
PlayerAdded.*GetAsync
```

If `GetAsync` is used for player data loading instead of `UpdateAsync` with a lock check, the code is vulnerable.

## Related

- [[session-locking]]
- [[item-duplication]]
- [[session-hijack]]
- [[DataStoreService]]

## Sources

- [DevForum: Session Locking Explained (Datastore)](../raw/community/devforum/session-locking-explained-datastore.md)
- [Roblox Creator Docs: Data store manipulation](../raw/roblox-creator-docs/best-practices/security/client-server-boundary.md) -- "Data store manipulation" section
- [Architecture Guide: DataStore Architecture](../../.claude/docs/roblox-architecture-guide.md)
