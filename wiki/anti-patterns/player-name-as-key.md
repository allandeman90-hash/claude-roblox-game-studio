---
title: player-name-as-key
type: anti-pattern
category: anti-patterns
subcategory: persistence
owner: datastore-architect
status: draft
created: 2026-04-16
updated: 2026-04-16
severity: high
sources:
  - wiki/raw/community/devforum/session-locking-explained-datastore.md
  - .claude/docs/roblox-architecture-guide.md
related:
  - "[[DataStoreService]]"
  - "[[session-locking]]"
  - "[[missing-schema-version]]"
tags: [anti-pattern, persistence]
---

# Player Name as DataStore Key

> Using `player.Name` instead of `player.UserId` as the DataStore key. Display names can change; UserIds are permanent.

**Severity:** High

## What It Looks Like

```lua
-- Loading with player name
Players.PlayerAdded:Connect(function(player)
    local data = DataStore:GetAsync(player.Name)
    playerCache[player] = data or getDefaultData()
end)

-- Saving with player name
Players.PlayerRemoving:Connect(function(player)
    DataStore:SetAsync(player.Name, playerCache[player])
end)

-- Leaderboard lookup by name
local function getPlayerRank(name: string)
    return LeaderboardStore:GetAsync(name)
end
```

## Why It's Bad

1. **Data orphaning**: Roblox allows players to change their display name. After a name change, `player.Name` returns the new name. The player's data is still stored under the old name, so `GetAsync(newName)` returns `nil`. The player loses all progress and gets default data, while the old data sits permanently orphaned.
2. **Name collision**: although Roblox usernames are unique at any point in time, a released name could theoretically be reclaimed by a different user. More practically, if the code uses `DisplayName` (which is not unique), two different players can share a key and overwrite each other's data.
3. **Key length risk**: usernames can be up to 20 characters. While this fits DataStore's 50-character key limit, display names can be longer and may contain characters that cause unexpected behavior in key strings.
4. **Cross-system inconsistency**: other Roblox APIs (Ban API, MessagingService subscriptions, group rank checks) all use UserId. Mixing name-based and UserId-based keys creates confusion and makes migration harder.
5. **No recovery path**: once data is orphaned under an old name, there is no way to programmatically link the old key to the new name without external tracking.

## How to Fix It

Always use `player.UserId` (a permanent numeric identifier) as the key, with a consistent prefix:

```lua
local function getKey(player: Player): string
    return "Player_" .. player.UserId
end

Players.PlayerAdded:Connect(function(player)
    local success, data = pcall(function()
        return DataStore:GetAsync(getKey(player))
    end)
    if success then
        playerCache[player] = data or getDefaultData()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        DataStore:SetAsync(getKey(player), playerCache[player])
    end)
    playerCache[player] = nil
end)
```

For leaderboards or lookups where you need name display, store the name as a field inside the data, not as the key:

```lua
local data = {
    version = 1,
    displayName = player.DisplayName,
    gold = 0,
    level = 1,
}
DataStore:SetAsync("Player_" .. player.UserId, data)
```

### Migration from name-based keys

If an existing game uses name-based keys, add a migration step:

```lua
Players.PlayerAdded:Connect(function(player)
    local key = "Player_" .. player.UserId
    local success, data = pcall(DataStore.GetAsync, DataStore, key)

    if success and data then
        -- Already migrated
        playerCache[player] = data
    else
        -- Try loading from legacy name-based key
        local legacySuccess, legacyData = pcall(DataStore.GetAsync, DataStore, player.Name)
        if legacySuccess and legacyData then
            -- Migrate: save under UserId key
            pcall(DataStore.SetAsync, DataStore, key, legacyData)
            playerCache[player] = legacyData
        else
            playerCache[player] = getDefaultData()
        end
    end
end)
```

## Detection

```
:GetAsync(player.Name
:SetAsync(player.Name
:UpdateAsync(player.Name
:RemoveAsync(player.Name
GetAsync(.*%.Name)
SetAsync(.*%.Name)
```

Any DataStore call using `.Name` instead of `.UserId` is a violation.

## Related

- [[DataStoreService]]
- [[session-locking]]
- [[missing-schema-version]]

## Sources

- [DevForum: Session Locking Explained](../raw/community/devforum/session-locking-explained-datastore.md)
- [Architecture Guide: DataStore Architecture](../../.claude/docs/roblox-architecture-guide.md) -- Section 3
