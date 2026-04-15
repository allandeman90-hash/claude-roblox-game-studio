# DataStore Schema: [Schema Name]

**Version**: 1
**Last Updated**: YYYY-MM-DD
**Author**: datastore-architect

---

## Purpose

What data this schema persists and why.

---

## DataStore Key Format

```
PlayerData_v1 → "Player_" .. player.UserId
```

- **Store name**: `PlayerData_v1` (version in name so you can migrate by creating v2 alongside v1)
- **Key pattern**: `Player_<UserId>`
- **Scope**: default (no scope)

---

## Value Schema

```lua
export type PlayerData = {
    version: number,                          -- schema version (currently 1)
    savedAt: number,                           -- os.time() of last save
    profile: {
        createdAt: number,                     -- os.time() of first login
        lastLogin: number,                     -- os.time() of last login
        totalPlayTime: number,                 -- seconds across all sessions
    },
    stats: {
        level: number,                         -- 1 to MAX_LEVEL
        xp: number,                            -- current XP toward next level
        gold: number,                          -- soft currency
        gems: number,                          -- premium currency
    },
    inventory: {
        equipped: {
            weapon: string?,                   -- weapon ID
            armor: string?,                    -- armor ID
        },
        items: {[string]: number},             -- itemId -> quantity
        maxSlots: number,                      -- inventory capacity
    },
    progression: {
        unlockedAreas: {[string]: boolean},    -- set of unlocked area IDs
        completedQuests: {[string]: boolean},  -- set of completed quest IDs
        activeQuests: {[string]: QuestState},  -- active quest state
    },
    settings: {
        musicVolume: number,                   -- 0-1
        sfxVolume: number,                     -- 0-1
        reducedMotion: boolean,
    },
}

export type QuestState = {
    progress: number,                          -- 0 to objective target
    startedAt: number,
}
```

---

## Defaults

When a new player joins, they get:

```lua
{
    version = 1,
    savedAt = os.time(),
    profile = {
        createdAt = os.time(),
        lastLogin = os.time(),
        totalPlayTime = 0,
    },
    stats = {
        level = 1,
        xp = 0,
        gold = 100,       -- starter gold
        gems = 0,
    },
    inventory = {
        equipped = {
            weapon = "sword_wooden",
            armor = nil,
        },
        items = {
            ["sword_wooden"] = 1,
        },
        maxSlots = 20,
    },
    progression = {
        unlockedAreas = { ["starter_town"] = true },
        completedQuests = {},
        activeQuests = {},
    },
    settings = {
        musicVolume = 0.5,
        sfxVolume = 0.8,
        reducedMotion = false,
    },
}
```

---

## Size Estimation

Maximum expected size per player:
- Stats: ~50 bytes
- Inventory (500 items): ~20 KB
- Progression (100 quests): ~5 KB
- Settings: ~200 bytes
- **Total**: ~25 KB (well within 4 MB limit)

---

## Migration Plan

### V1 → V2 (hypothetical future)
If we add `guildId`:

```lua
local function migrateV1toV2(data: {[string]: any}): {[string]: any}
    data.version = 2
    data.guildId = nil    -- default no guild
    return data
end
```

### V2 → V3 (hypothetical future)
If we restructure settings:

```lua
local function migrateV2toV3(data: {[string]: any}): {[string]: any}
    data.version = 3
    data.settings.graphicsQuality = "auto"
    return data
end
```

Migration runs on load. Chain migrations execute in order (v1 → v2 → v3).

---

## Budget Estimation

### GetAsync
- 1 per player join
- Estimated: 60 joins/min in a 60-player server
- Budget: 60 + 60 × 10 = 660/min
- Headroom: ~11x

### SetAsync
- 1 per player save (auto-save every 5 min)
- Estimated: 60 players × 0.2/min = 12/min
- Plus saves on purchase, level up (~5/min extra)
- Budget: 60 + 60 × 10 = 660/min
- Headroom: ~40x

---

## Session Locking

Uses a separate `SessionLocks` DataStore:
- Key: `Lock_<UserId>`
- Value: `{ jobId = <serverId>, time = <os.time()> }`
- Lock TTL: 60 seconds (auto-refreshed)
- Acquired on PlayerAdded, released on PlayerRemoving

---

## Save Triggers

- **Auto-save**: Every 5 minutes per player
- **On critical event**: Purchase, level-up, major reward
- **On PlayerRemoving**: Final save before disconnect
- **On BindToClose**: Save all players with 25-second timeout

---

## Retry Strategy

```lua
local MAX_RETRIES = 5
for attempt = 1, MAX_RETRIES do
    local ok, err = pcall(save)
    if ok then break end
    task.wait(2 ^ attempt)  -- exponential backoff: 2, 4, 8, 16, 32 seconds
end
```

---

## Backup Strategy

- **Primary store**: `PlayerData_v1`
- **Backup store**: `PlayerData_v1_backup`
- Backup on significant milestones (every 10 saves?)
- Retain for 30 days

---

## Recovery Procedure

If a player reports data loss:
1. Check primary store for current data
2. If missing/corrupted, check backup store
3. If both missing, check older backup versions via Roblox version history
4. Restore best available version
5. Document incident in `production/incidents/`
