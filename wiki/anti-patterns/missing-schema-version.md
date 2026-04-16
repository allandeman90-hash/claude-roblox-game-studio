---
title: missing-schema-version
type: anti-pattern
category: anti-patterns
subcategory: persistence
owner: datastore-architect
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: medium
sources:
  - .claude/docs/roblox-architecture-guide.md
  - .claude/docs/coding-standards.md
related:
  - "[[schema-versioning]]"
  - "[[DataStoreService]]"
  - "[[player-name-as-key]]"
tags: [anti-pattern, persistence]
---

# Missing Schema Version

> Persisting player data without a `version` field. Makes future data migration impossible without risking corruption or data loss.

**Severity:** Medium

## What It Looks Like

```lua
-- No version field in the data structure
local function getDefaultData()
    return {
        gold = 0,
        level = 1,
        inventory = {},
    }
end

-- Later, the developer adds a new field...
local function getDefaultData()
    return {
        gold = 0,
        level = 1,
        inventory = {},
        gems = 0,        -- new currency added
        settings = {},    -- new settings table added
    }
end

-- Old players load data without gems or settings.
-- No migration runs. The code crashes on data.settings.volume or
-- silently treats missing gems as nil instead of 0.
```

## Why It's Bad

1. **No migration path**: without a version number, the code cannot distinguish between "old format data" and "new format data with missing fields." It cannot run targeted migration logic.
2. **Silent nil errors**: Luau does not error on accessing a missing table key; it returns `nil`. Code that expects `data.gems` to be a number will break silently when it encounters `nil` in arithmetic: `data.gems + 10` produces an error, but `data.gems == nil` passes type checks designed for `number`.
3. **Cumulative tech debt**: every schema change compounds the problem. After 5 unversioned changes, there are 2^5 possible combinations of present/missing fields. Testing all combinations is impractical.
4. **Data corruption on save**: if the code loads old data, fails to recognize its format, and then saves it back with partial new-format assumptions, the stored data becomes a hybrid that neither the old nor new code handles correctly.
5. **No rollback**: if a schema change introduces a bug, unversioned data cannot be reverted to a known-good format because there is no record of which transformations have been applied.

## How to Fix It

Wrap all persistent data in a versioned envelope and maintain an explicit migration chain:

```lua
local CURRENT_VERSION = 3

local function getDefaultData(): PlayerData
    return {
        version = CURRENT_VERSION,
        gold = 0,
        gems = 0,
        level = 1,
        inventory = {},
        settings = {
            volume = 1.0,
            notifications = true,
        },
    }
end

-- Migration chain: each function transforms from version N to N+1
local migrations = {
    [1] = function(data)
        -- v1 -> v2: add gems field
        data.gems = data.gems or 0
        data.version = 2
        return data
    end,
    [2] = function(data)
        -- v2 -> v3: add settings table
        data.settings = data.settings or {
            volume = 1.0,
            notifications = true,
        }
        data.version = 3
        return data
    end,
}

local function migrateData(data: any): PlayerData
    if data == nil then
        return getDefaultData()
    end

    -- Legacy data without version field: treat as v1
    if data.version == nil then
        data.version = 1
    end

    -- Run migrations sequentially
    while data.version < CURRENT_VERSION do
        local migrator = migrations[data.version]
        if not migrator then
            warn("No migration for version", data.version)
            return getDefaultData()  -- fallback to defaults
        end
        data = migrator(data)
    end

    return data
end
```

Usage on load:

```lua
Players.PlayerAdded:Connect(function(player)
    local success, rawData = pcall(function()
        return DataStore:GetAsync("Player_" .. player.UserId)
    end)

    local data
    if success then
        data = migrateData(rawData)
    else
        data = getDefaultData()
    end

    playerCache[player] = data
end)
```

Key principles:
- **Version field is mandatory** in the root of every persistent data structure.
- **Migrations are pure functions**: input is version N data, output is version N+1 data.
- **Migrations run on load**, never on save. The saved format is always CURRENT_VERSION.
- **Default data always uses CURRENT_VERSION**.
- **Test every migration** with fixture data from each prior version.

## Detection

```
getDefaultData
SetAsync.*{
UpdateAsync.*{
```

Check whether the returned/saved data table includes a `version` field. If any DataStore write does not include `version` at the top level, the code is vulnerable.

## Related

- [[schema-versioning]]
- [[DataStoreService]]
- [[player-name-as-key]]

## Sources

- [Architecture Guide: Schema Versioning](../../.claude/docs/roblox-architecture-guide.md) -- Section 3: DataStore Architecture
- [Coding Standards](../../.claude/docs/coding-standards.md)
