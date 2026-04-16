---
title: schema-versioning
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
  - "[[bind-to-close]]"
  - "[[missing-schema-version]]"
tags: [concept, persistence, required]
---

# Schema Versioning

> The pattern that lets you evolve your player data shape over time without breaking existing players.

## What It Is

Schema versioning embeds a `version` field in every piece of persistent data. Whenever you load data, you check the version and run any needed migration functions to bring it up to the current schema. When you save data, you save it with the latest version.

Without versioning:
- Adding a new field to player data means old players' loaded data is missing the field
- Renaming a field means all existing values are at the old key
- Removing a field silently loses data you may need later
- Any shape change risks crashes from `data.oldField` being nil

With versioning, migrations are explicit, testable, and reversible.

## When to Use It

**Always**. Every DataStore value should be a table shaped like `{ version = N, data = {...} }`. From day one. Retrofitting versioning after launch is painful — you have to guess which values were written by which version.

## Implementation

### Schema With Version Field

```lua
-- Canonical shape
export type PlayerDataWrapper = {
    version: number,
    data: PlayerData,
}

export type PlayerData = {
    gold: number,
    level: number,
    inventory: {[string]: number},
    settings: PlayerSettings,
}

export type PlayerSettings = {
    musicVolume: number,
    reducedMotion: boolean,
}
```

### Current Schema Constant

```lua
local CURRENT_SCHEMA_VERSION = 3  -- bump this when you add a migration
```

### Migration Chain

```lua
local function migrateV1toV2(data)
    -- v1 had no gems; add default
    data.gems = 0
    return data
end

local function migrateV2toV3(data)
    -- v2 had a flat settings; v3 nests under settings
    data.settings = {
        musicVolume = data.musicVolume or 0.5,
        sfxVolume = data.sfxVolume or 0.8,
        reducedMotion = false,
    }
    data.musicVolume = nil
    data.sfxVolume = nil
    return data
end

local migrations = {
    [1] = migrateV1toV2,
    [2] = migrateV2toV3,
}

local function migrate(wrapper)
    if not wrapper then return wrapper end
    local version = wrapper.version or 1
    local data = wrapper.data or wrapper  -- tolerate un-wrapped legacy data

    while version < CURRENT_SCHEMA_VERSION do
        local mig = migrations[version]
        if not mig then
            error("No migration from v" .. version .. " to v" .. (version + 1))
        end
        data = mig(data)
        version += 1
    end

    return { version = CURRENT_SCHEMA_VERSION, data = data }
end
```

### Integration with Load/Save

```lua
local function loadPlayer(userId)
    local ok, raw = pcall(function()
        return store:GetAsync("Player_" .. userId)
    end)
    if not ok or not raw then
        return { version = CURRENT_SCHEMA_VERSION, data = getDefaultData() }
    end
    return migrate(raw)
end

local function savePlayer(userId, wrapper)
    assert(wrapper.version == CURRENT_SCHEMA_VERSION, "Must save at current version")
    pcall(function()
        store:SetAsync("Player_" .. userId, wrapper)
    end)
end
```

### Default Data

Always maintain a `getDefaultData()` function for brand-new players:

```lua
local function getDefaultData(): PlayerData
    return {
        gold = 100,
        gems = 0,
        level = 1,
        inventory = { ["sword_wooden"] = 1 },
        settings = {
            musicVolume = 0.5,
            sfxVolume = 0.8,
            reducedMotion = false,
        },
    }
end
```

Brand-new players return a wrapper at `CURRENT_SCHEMA_VERSION` — they never need migration.

## Variants

- **Per-field versioning** (complex, rare): track version per field rather than per value. Overkill for most games.
- **Schema migrations as a list**: the chain pattern shown above, most common.
- **Up-migrations only**: no rollback support. The default for Roblox (DataStore has built-in version history if you need rollback).
- **Lazy migration**: run migrations on read, not on write. Prefer this — you only pay cost for players who actually load.

## Pitfalls

- **No version field**: impossible to migrate without breaking live data. See [[missing-schema-version]].
- **Bumping version without a migration**: loading breaks for old data.
- **Migration that yields**: can cause timing issues. Keep migrations synchronous.
- **Tolerating un-wrapped legacy data**: useful short-term, but clean up after a couple of versions.
- **Losing fields without migration**: data silently disappears. Always migrate explicitly.
- **Schema version in the wrong place**: some codebases put version inside `data`, others wrap the whole thing. Pick one and be consistent.
- **Not testing migrations**: write unit tests per migration step.

## Related

- [[DataStoreService]] — the store that holds versioned data
- [[session-locking]] — pairs with versioning for full data safety
- [[bind-to-close]] — save path that respects versioning
- [[missing-schema-version]] — anti-pattern: skipping this
- [DataStore Rules](../../.claude/rules/datastores.md)

## Sources

- [.claude/agents/datastore-architect.md](../../.claude/agents/datastore-architect.md)
- [.claude/rules/datastores.md](../../.claude/rules/datastores.md)
