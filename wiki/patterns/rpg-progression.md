---
title: RPG Progression
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/level-systems-part1.md
  - wiki/raw/community/articles/game-mechanics/level-up-system-math.md
  - wiki/raw/community/articles/game-mechanics/prestige-rebirth-system.md
  - wiki/raw/community/articles/game-mechanics/stat-system-design.md
related:
  - "[[equipment-system]]"
  - "[[skill-tree]]"
  - "[[DataStoreService]]"
  - "[[daily-rewards]]"
  - "[[shop-system]]"
tags: [pattern, xp, leveling, prestige, rebirth, progression, rpg, stats]
---

# RPG Progression

> XP accumulation, level-up curves, stat scaling, and prestige/rebirth loops -- the backbone of long-term retention in Roblox RPG and simulator games.

## Summary

RPG progression systems give players a quantifiable sense of growth. The core loop is: earn XP from gameplay actions, accumulate enough XP to level up, receive stat increases or unlocks on level-up, and eventually hit a prestige/rebirth reset that trades progress for permanent multipliers. The XP curve formula determines pacing -- too flat and players outgrow content; too steep and mid-game feels like a wall. Roblox sessions average 15-25 minutes, so milestone spacing must deliver at least one level-up per session for casual players.

## Implementation

### XP Curve Formulas

Three standard curves, each with concrete math. All formulas take a `level` parameter and return the XP required to advance from that level to the next.

#### Linear

```lua
-- XP to next level grows by a fixed amount each level
-- Level 1: 100, Level 2: 110, Level 3: 120, ...
local BASE_XP = 100
local XP_PER_LEVEL = 10

local function getRequiredXP_Linear(level: number): number
    return BASE_XP + (level * XP_PER_LEVEL)
end
-- Level 10 requires 200 XP, Level 50 requires 600 XP
```

**When to use:** Tutorial or early-game zones where predictable pacing matters. Simple for designers to reason about.

#### Quadratic

```lua
-- XP grows proportional to level squared
-- Produces a smooth acceleration curve
local XP_SCALE = 50

local function getRequiredXP_Quadratic(level: number): number
    return XP_SCALE * (level ^ 2) + XP_SCALE * level
end

-- Inverse: calculate level from total accumulated XP (constant time)
local function getLevelFromTotalXP(totalXP: number): number
    return math.floor(
        (-XP_SCALE / 2 + math.sqrt((XP_SCALE / 2) ^ 2 + (XP_SCALE * 2) * totalXP))
        / XP_SCALE
    )
end
-- Level 1: 100 XP, Level 5: 1500 XP, Level 10: 5500 XP, Level 50: 127500 XP
```

**When to use:** Most Roblox RPGs. The curve naturally slows down at higher levels without feeling punishing early. The inverse formula handles bulk XP grants (quest rewards, XP potions) in O(1) without looping.

#### Exponential

```lua
-- XP doubles every N levels -- sharp late-game wall
local BASE_XP = 100
local GROWTH_RATE = 1.15  -- 15% increase per level

local function getRequiredXP_Exponential(level: number): number
    return math.floor(BASE_XP * (GROWTH_RATE ^ level))
end
-- Level 1: 115, Level 10: 404, Level 25: 3292, Level 50: 108366
```

**When to use:** Games with prestige/rebirth where the exponential wall is intentional -- it forces the reset. Not recommended without a prestige system because players hit a dead stop.

### Level-Up Processing (Server-Side)

```lua
-- ServerStorage/Services/ProgressionService.lua
local ProgressionService = {}

local Config = require(game.ReplicatedStorage.Shared.Config.ProgressionConfig)

-- Constant-time multi-level-up using quadratic inverse
function ProgressionService.addXP(playerData, amount: number): number
    local stats = playerData.progression
    local xpToCurrentLevel = Config.getTotalXPForLevel(stats.level)
    local totalXP = xpToCurrentLevel + stats.xp + amount

    local newLevel = math.min(
        Config.getLevelFromTotalXP(totalXP),
        Config.LEVEL_CAP
    )
    local levelsGained = newLevel - stats.level

    if levelsGained > 0 then
        local xpConsumed = Config.getTotalXPForLevel(newLevel) - xpToCurrentLevel
        stats.xp = stats.xp + amount - xpConsumed
        stats.level = newLevel

        -- Apply stat gains per level
        for _ = 1, levelsGained do
            ProgressionService.applyLevelUpStats(playerData)
        end
    else
        stats.xp += amount
    end

    return levelsGained
end

function ProgressionService.applyLevelUpStats(playerData)
    local stats = playerData.stats
    local level = playerData.progression.level
    local prestige = playerData.progression.prestige

    -- Base stat gain + prestige multiplier
    local multiplier = 1 + (prestige * Config.PRESTIGE_STAT_BONUS)
    stats.maxHP += math.floor(Config.HP_PER_LEVEL * multiplier)
    stats.attack += math.floor(Config.ATK_PER_LEVEL * multiplier)
    stats.defense += math.floor(Config.DEF_PER_LEVEL * multiplier)
end

return ProgressionService
```

### Prestige / Rebirth System

```lua
-- Prestige resets level to 1 but grants permanent multipliers
function ProgressionService.prestige(playerData): boolean
    local prog = playerData.progression
    if prog.level < Config.PRESTIGE_LEVEL_REQUIREMENT then
        return false
    end
    if prog.prestige >= Config.MAX_PRESTIGE then
        return false
    end

    -- Record prestige
    prog.prestige += 1

    -- Reset level and XP
    prog.level = 1
    prog.xp = 0

    -- Grant permanent bonuses
    -- XP multiplier: each prestige gives +25% XP gain
    prog.xpMultiplier = 1 + (prog.prestige * Config.PRESTIGE_XP_BONUS)

    -- Reset stats to base + prestige bonus
    ProgressionService.resetStatsToBase(playerData)

    return true
end
```

### Configuration Module

```lua
-- ReplicatedStorage/Shared/Config/ProgressionConfig.lua
local ProgressionConfig = {}

-- Curve tuning
ProgressionConfig.XP_SCALE = 50              -- quadratic coefficient
ProgressionConfig.LEVEL_CAP = 100            -- soft cap per prestige
ProgressionConfig.HARD_CAP = 999             -- absolute max level

-- Stat gains per level (before prestige multiplier)
ProgressionConfig.HP_PER_LEVEL = 10
ProgressionConfig.ATK_PER_LEVEL = 2
ProgressionConfig.DEF_PER_LEVEL = 1

-- Prestige
ProgressionConfig.PRESTIGE_LEVEL_REQUIREMENT = 100
ProgressionConfig.MAX_PRESTIGE = 10
ProgressionConfig.PRESTIGE_XP_BONUS = 0.25   -- +25% XP per prestige
ProgressionConfig.PRESTIGE_STAT_BONUS = 0.10  -- +10% stat gains per prestige

-- Session-friendly milestones (minutes of play -> expected level)
-- 5 min -> L3, 15 min -> L8, 30 min -> L12, 60 min -> L18
-- Tuned for 15-25 minute average Roblox session

function ProgressionConfig.getRequiredXP(level: number): number
    local s = ProgressionConfig.XP_SCALE
    return s * (level ^ 2) + s * level
end

function ProgressionConfig.getTotalXPForLevel(level: number): number
    -- Sum of all XP from level 0 to level
    -- Closed form: (s/3)*level^3 + (s/2)*level^2 + (s/6)*level
    local s = ProgressionConfig.XP_SCALE
    return math.floor((s / 3) * (level ^ 3) + (s / 2) * (level ^ 2) + (s / 6) * level)
end

function ProgressionConfig.getLevelFromTotalXP(totalXP: number): number
    local s = ProgressionConfig.XP_SCALE
    return math.floor(
        (-s / 2 + math.sqrt((s / 2) ^ 2 + (s * 2) * totalXP)) / s
    )
end

return ProgressionConfig
```

## Data Schema

What persists in DataStore per player:

```lua
-- Player data template
{
    progression = {
        level = 1,
        xp = 0,
        prestige = 0,
        xpMultiplier = 1.0,
        totalXPEarned = 0,      -- lifetime counter for analytics
    },
    stats = {
        maxHP = 100,
        attack = 10,
        defense = 5,
        speed = 16,
    },
    version = 1,  -- schema versioning for migration
}
```

## Formulas

| Curve | Formula (XP for level N) | Level 1 | Level 10 | Level 50 | Level 100 |
|-------|--------------------------|---------|----------|----------|-----------|
| Linear (base=100, scale=10) | `100 + N * 10` | 110 | 200 | 600 | 1100 |
| Quadratic (scale=50) | `50 * N^2 + 50 * N` | 100 | 5500 | 127500 | 505000 |
| Exponential (base=100, rate=1.15) | `100 * 1.15^N` | 115 | 404 | 108366 | 117,4M |

**Soft cap vs hard cap:**
- **Soft cap**: XP requirements increase sharply after a threshold (e.g., 3x multiplier after level 100). Players can still progress but slowly. Good for keeping whales engaged without breaking balance.
- **Hard cap**: Level cannot exceed a fixed number. Simpler to balance but frustrated veterans hit a wall. Use when prestige resets provide the endgame loop instead.

**Prestige XP scaling formula:**
```
xpRequired(level, prestige) = baseXP(level) * (1 + prestige * 0.5)
```
At prestige 0: normal. At prestige 5: 3.5x XP required per level. This is offset by the permanent XP multiplier (`1 + prestige * 0.25`), creating diminishing returns that still feel rewarding.

## Pitfalls

- **Recursive AddExp stack overflow.** The naive recursive approach (call AddExp with leftover XP) blows the stack on large XP grants. Use the quadratic inverse formula for O(1) multi-level processing.
- **Client-side level calculation.** If the client computes the level and tells the server, exploiters send `level = 999`. The server owns the XP counter and computes level from it.
- **XP stored as float.** Floating-point drift causes off-by-one errors at high values. Store XP as an integer and use `math.floor` on all calculations.
- **No BindToClose coverage.** XP is part of the player profile. The standard DataStore BindToClose + PlayerRemoving save path must include progression data.
- **Prestige without incentive.** If the prestige multiplier is too small, rational players never prestige because grinding at high level is more efficient. Run the math: the break-even point (where prestige + fast re-leveling outpaces staying) should be reachable within 2-3 sessions post-prestige.
- **Session pacing mismatch.** If the first level-up takes 20 minutes of grinding, casual Roblox players leave before experiencing it. Place the first level-up within 2-3 minutes of gameplay; stretch intervals after that.

## Related

- [[equipment-system]] -- gear stat bonuses stack with level-based stats
- [[skill-tree]] -- skill points awarded on level-up
- [[daily-rewards]] -- XP boosts as daily reward items
- [[DataStoreService]] -- persistence layer for progression data
- [[shop-system]] -- XP boosters sold in the shop

## Sources

- [Level Systems Part 1](../raw/community/articles/game-mechanics/level-systems-part1.md) -- linear XP formula, recursive AddExp, progress bar math
- [Level Up System Math](../raw/community/articles/game-mechanics/level-up-system-math.md) -- quadratic formula, inverse XP calculation, constant-time multi-level-up
- [Prestige vs Rebirth System](../raw/community/articles/game-mechanics/prestige-rebirth-system.md) -- prestige/rebirth terminology, XP scaling per prestige tier, community design debate
- [Stat System Design](../raw/community/articles/game-mechanics/stat-system-design.md) -- player stat storage architecture, module-based approach, DataStore consolidation
