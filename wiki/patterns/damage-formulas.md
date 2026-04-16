---
title: Damage Formulas
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/damage-formulas.md
  - wiki/raw/community/articles/game-mechanics/ability-cooldown-buff-systems.md
related:
  - "[[combat-system]]"
  - "[[ability-system]]"
  - "[[loot-tables]]"
tags: [pattern, damage, formula, defense, crit, level-scaling, type-effectiveness, balance]
---

# Damage Formulas

> Explicit, config-driven formulas for calculating combat damage including base damage, weapon bonuses, critical hits, defense reduction, type effectiveness, level scaling, and variance.

## Summary

A damage formula transforms raw attack intent into a final health change. Every number in the formula comes from a config table -- zero magic numbers. The canonical formula is:

```
finalDamage = (baseDamage + weaponBonus)
            * comboMultiplier
            * (1 + critMultiplier * isCrit)
            * typeEffectiveness
            * levelScaling
            * (1 - defenseReduction)
            * (1 - blockReduction)
            * variance
```

The formula is evaluated entirely on the server. The client never sees intermediate values or modifies the calculation. All tuning values live in `ReplicatedStorage/Shared/Config/DamageConfig.lua` so designers can adjust balance without touching code.

## Implementation

### Damage Config (Shared)

```lua
-- ReplicatedStorage/Shared/Config/DamageConfig.lua
local DamageConfig = {}

-- Base stats per level
DamageConfig.BASE_ATTACK_PER_LEVEL = 5
DamageConfig.BASE_DEFENSE_PER_LEVEL = 3
DamageConfig.BASE_HEALTH_PER_LEVEL = 20

-- Critical hits
DamageConfig.BASE_CRIT_CHANCE = 0.05       -- 5% base crit chance
DamageConfig.BASE_CRIT_MULTIPLIER = 1.5    -- 150% damage on crit
DamageConfig.MAX_CRIT_CHANCE = 0.50         -- cap at 50%

-- Defense formula
-- defenseFactor = ATK / (ATK + DEF * DEFENSE_SCALING)
-- At DEFENSE_SCALING = 1: equal ATK and DEF halves damage
-- Higher scaling makes defense more effective
DamageConfig.DEFENSE_SCALING = 1.0

-- Minimum damage (percent of raw damage that always gets through)
DamageConfig.MIN_DAMAGE_FACTOR = 0.05      -- 5% minimum

-- Damage variance (randomized per hit)
DamageConfig.VARIANCE_MIN = 0.95
DamageConfig.VARIANCE_MAX = 1.05

-- Level scaling: multiplier when attacker level differs from defender
-- Formula: levelMultiplier = 1 + (attackerLevel - defenderLevel) * LEVEL_SCALE_FACTOR
-- Clamped to [MIN, MAX]
DamageConfig.LEVEL_SCALE_FACTOR = 0.03     -- 3% per level difference
DamageConfig.LEVEL_SCALE_MIN = 0.5         -- minimum 50% damage
DamageConfig.LEVEL_SCALE_MAX = 2.0         -- maximum 200% damage

-- Type effectiveness matrix
-- Each entry is a multiplier: 1.0 = neutral, 1.5 = strong, 0.5 = weak, 0 = immune
DamageConfig.TYPE_EFFECTIVENESS: {[string]: {[string]: number}} = {
    --                  vs:  physical  fire    ice     lightning  nature
    physical  = { physical = 1.0, fire = 1.0, ice = 1.0, lightning = 1.0, nature = 1.0 },
    fire      = { physical = 1.0, fire = 0.5, ice = 1.5, lightning = 1.0, nature = 1.5 },
    ice       = { physical = 1.0, fire = 0.5, ice = 0.5, lightning = 1.0, nature = 1.5 },
    lightning = { physical = 1.0, fire = 1.0, ice = 1.5, lightning = 0.5, nature = 0.5 },
    nature    = { physical = 1.0, fire = 0.5, ice = 0.5, lightning = 1.5, nature = 0.5 },
}

-- Damage cap per single hit (prevents one-shot exploits at high levels)
DamageConfig.MAX_SINGLE_HIT_DAMAGE = 9999

-- Block damage reduction (0.6 = 60% reduction while blocking)
DamageConfig.BLOCK_REDUCTION = 0.6

return DamageConfig
```

### Damage Calculator (Server)

```lua
-- ServerStorage/Combat/DamageFormulas.lua
local DamageConfig = require(game.ReplicatedStorage.Shared.Config.DamageConfig)

export type DamageInput = {
    baseDamage: number,          -- from weapon or ability config
    weaponBonus: number?,        -- flat bonus from equipped weapon
    comboMultiplier: number?,    -- from combo hit config
    attackerLevel: number?,
    defenderLevel: number?,
    attackerAttack: number?,     -- total attack stat (base + buffs)
    defenderDefense: number?,    -- total defense stat (base + buffs)
    damageType: string?,         -- "fire", "ice", "physical", etc.
    defenderType: string?,       -- defender's resistance type
    critChance: number?,         -- attacker's crit chance (0-1)
    critMultiplier: number?,     -- attacker's crit multiplier
    blockReduction: number?,     -- 0 if not blocking
    isEnvironmental: boolean?,   -- skip defense for environmental damage
}

export type DamageResult = {
    finalDamage: number,
    wasCrit: boolean,
    rawDamage: number,
    defenseFactor: number,
    typeMultiplier: number,
    levelMultiplier: number,
    variance: number,
}

local DamageFormulas = {}

--[[
    Core damage calculation. All values from config, zero magic numbers.

    Pipeline:
    1. Raw damage = (base + weaponBonus) * comboMultiplier
    2. Crit roll
    3. Defense factor = ATK / (ATK + DEF * scaling)
    4. Type effectiveness lookup
    5. Level scaling
    6. Block reduction
    7. Variance
    8. Clamp to [min, max]
]]
function DamageFormulas.calculate(input: DamageInput): DamageResult
    -- Step 1: Raw damage
    local base = input.baseDamage
    local weaponBonus = input.weaponBonus or 0
    local comboMult = input.comboMultiplier or 1.0
    local rawDamage = (base + weaponBonus) * comboMult

    -- Step 2: Critical hit
    local critChance = math.clamp(
        input.critChance or DamageConfig.BASE_CRIT_CHANCE,
        0,
        DamageConfig.MAX_CRIT_CHANCE
    )
    local critMult = input.critMultiplier or DamageConfig.BASE_CRIT_MULTIPLIER
    local wasCrit = math.random() < critChance
    local critFactor = if wasCrit then critMult else 1.0

    -- Step 3: Defense reduction
    local defenseFactor = 1.0
    if not input.isEnvironmental then
        local atk = input.attackerAttack or (
            (input.attackerLevel or 1) * DamageConfig.BASE_ATTACK_PER_LEVEL
        )
        local def = input.defenderDefense or (
            (input.defenderLevel or 1) * DamageConfig.BASE_DEFENSE_PER_LEVEL
        )
        local scaledDef = def * DamageConfig.DEFENSE_SCALING

        -- ATK / (ATK + DEF) formula: approaches 1.0 at high ATK, approaches 0 at high DEF
        if atk + scaledDef > 0 then
            defenseFactor = atk / (atk + scaledDef)
        end

        -- Enforce minimum damage
        defenseFactor = math.max(defenseFactor, DamageConfig.MIN_DAMAGE_FACTOR)
    end

    -- Step 4: Type effectiveness
    local typeMultiplier = 1.0
    if input.damageType and input.defenderType then
        local attackerTypes = DamageConfig.TYPE_EFFECTIVENESS[input.damageType]
        if attackerTypes then
            typeMultiplier = attackerTypes[input.defenderType] or 1.0
        end
    end

    -- Step 5: Level scaling
    local levelMultiplier = 1.0
    if input.attackerLevel and input.defenderLevel then
        local levelDiff = input.attackerLevel - input.defenderLevel
        levelMultiplier = 1 + levelDiff * DamageConfig.LEVEL_SCALE_FACTOR
        levelMultiplier = math.clamp(
            levelMultiplier,
            DamageConfig.LEVEL_SCALE_MIN,
            DamageConfig.LEVEL_SCALE_MAX
        )
    end

    -- Step 6: Block reduction
    local blockFactor = 1.0 - (input.blockReduction or 0)

    -- Step 7: Variance
    local variance = DamageConfig.VARIANCE_MIN
        + math.random() * (DamageConfig.VARIANCE_MAX - DamageConfig.VARIANCE_MIN)

    -- Final calculation
    local finalDamage = rawDamage
        * critFactor
        * defenseFactor
        * typeMultiplier
        * levelMultiplier
        * blockFactor
        * variance

    -- Clamp
    finalDamage = math.clamp(
        math.floor(finalDamage),
        if rawDamage > 0 then 1 else 0,  -- minimum 1 damage if non-zero input
        DamageConfig.MAX_SINGLE_HIT_DAMAGE
    )

    return {
        finalDamage = finalDamage,
        wasCrit = wasCrit,
        rawDamage = rawDamage,
        defenseFactor = defenseFactor,
        typeMultiplier = typeMultiplier,
        levelMultiplier = levelMultiplier,
        variance = variance,
    }
end

--[[
    Distance-based damage falloff for ranged weapons.
    Returns a multiplier (0-1) to apply to the final damage.

    Full damage at minRange, minimum damage at maxRange, lerped between.
]]
function DamageFormulas.distanceFalloff(
    distance: number,
    minRange: number,
    maxRange: number,
    minMultiplier: number?
): number
    local floor = minMultiplier or 0.3
    if distance <= minRange then return 1.0 end
    if distance >= maxRange then return floor end

    local t = (distance - minRange) / (maxRange - minRange)
    return 1.0 - t * (1.0 - floor)
end

--[[
    Healing formula (negative damage). Separate because heals typically
    ignore defense and have different scaling.
]]
function DamageFormulas.calculateHeal(
    baseHeal: number,
    healerLevel: number?,
    healBonus: number?
): number
    local levelScale = 1.0 + ((healerLevel or 1) - 1) * 0.02  -- 2% per level
    local bonus = healBonus or 0
    return math.floor((baseHeal + bonus) * levelScale)
end

return DamageFormulas
```

### Defense Formula Deep Dive

The recommended defense formula is `ATK / (ATK + DEF)`, a hyperbolic curve with desirable properties:

```
DEF = 0:     factor = ATK / ATK = 1.0        (100% damage — no defense)
DEF = ATK:   factor = ATK / 2*ATK = 0.5      (50% damage — equal stats)
DEF = 2*ATK: factor = ATK / 3*ATK = 0.33     (33% damage — double defense)
DEF = 9*ATK: factor = ATK / 10*ATK = 0.1     (10% damage — extreme defense)
```

Properties:
- **Diminishing returns**: Each point of DEF is less effective than the last, preventing total immunity.
- **Never reaches zero**: Damage always gets through (approaches 0 asymptotically).
- **Self-balancing**: High-ATK players still deal meaningful damage to high-DEF targets.
- **Tunable**: Multiply DEF by a scaling factor to control how quickly defense ramps up.

#### Alternatives

| Formula | Pros | Cons |
|---------|------|------|
| `ATK / (ATK + DEF)` | Diminishing returns, never-zero | Requires tuning scaling factor |
| `ATK - DEF` | Simple | Negative damage possible, linear |
| `ATK * (100 / (100 + DEF))` | Percentage-based, easy to explain | Equivalent to the above with scaling |
| `ATK / DEF` | Trivial | Infinite damage at DEF=0, breaks |
| `ATK * (1 - DEF/(DEF+K))` | Explicit constant K for tuning | Same as first formula, rearranged |

### Level Scaling Curves

```lua
-- Linear: simple, predictable, used in most Roblox RPGs
local function linearScaling(attackerLevel, defenderLevel)
    local diff = attackerLevel - defenderLevel
    return math.clamp(1 + diff * 0.03, 0.5, 2.0)
end

-- Exponential: steeper penalty for large gaps
local function exponentialScaling(attackerLevel, defenderLevel)
    local diff = attackerLevel - defenderLevel
    return math.clamp(1.03 ^ diff, 0.3, 3.0)
end

-- Soft cap: significant at small gaps, diminishing at large gaps
local function softCapScaling(attackerLevel, defenderLevel)
    local diff = attackerLevel - defenderLevel
    local sign = if diff >= 0 then 1 else -1
    local absDiff = math.abs(diff)
    local scaled = 1 + sign * (1 - 1 / (1 + absDiff * 0.1))
    return math.clamp(scaled, 0.5, 2.0)
end
```

### Type Effectiveness Matrix (Expanded)

```
            vs Physical  vs Fire  vs Ice  vs Lightning  vs Nature
Physical       1.0         1.0     1.0       1.0          1.0
Fire           1.0         0.5     1.5       1.0          1.5
Ice            1.0         0.5     0.5       1.0          1.5
Lightning      1.0         1.0     1.5       0.5          0.5
Nature         1.0         0.5     0.5       1.5          0.5
```

Read as "row attacks column": Fire attacking Ice = 1.5x (super effective).

This matrix is symmetric in resistance (Fire resists Fire, Lightning resists Lightning) and creates a rock-paper-scissors cycle: Fire > Ice > Lightning > Nature > Fire, with Physical neutral against all.

## Variants

| Variant | Description | Use Case |
|---------|-------------|----------|
| **Flat formula** | No level scaling, no types | Casual PvP, equal-footing games |
| **RPG formula** | Full pipeline with levels, types, stats | Progression-based RPGs |
| **Class-based** | Damage modified by attacker/defender class | MOBAs, class shooters |
| **Distance falloff** | Damage decreases with range | FPS, ranged combat |
| **True damage** | Bypasses defense entirely | Ultimate abilities, environmental |
| **Percentage damage** | Deals % of target max HP | Anti-tank mechanics, boss fights |

## Pitfalls

- **Magic numbers in damage code.** Every number must come from DamageConfig. When a designer needs to adjust crit multiplier from 1.5 to 1.75, they should change one value in one config file, not hunt through combat scripts.
- **Client-side damage calculation.** Never. The client may display predicted damage numbers for responsiveness, but the server's calculation is authoritative. A mismatch means the client prediction was wrong, not that the server should change.
- **Subtraction-based defense.** `damage = ATK - DEF` creates a dead zone where high-DEF characters take zero damage. Use the division formula instead.
- **Uncapped crit chance.** Without a maximum (recommended 40-50%), stacking crit bonuses can produce 100% crit chance, making the crit system meaningless. Cap it.
- **Level scaling without caps.** A level 100 vs level 1 should not deal 300% damage. Cap the multiplier at 200% (or whatever the game design specifies). Similarly, cap the penalty at 50% to keep lower-level players relevant.
- **Integer vs float rounding.** Floor the final damage to avoid displaying "23.7 damage" in the UI. Always floor, never round, so players see consistent minimum damage values.
- **Missing variance.** Without damage variance (typically +/- 5%), every hit deals exactly the same number, making combat feel robotic. Small variance adds perceived depth without affecting balance.

## Related

- [[combat-system]] -- calls DamageFormulas.calculate() for every hit
- [[ability-system]] -- ability damage flows through the same pipeline
- [[loot-tables]] -- item stats (weapon damage, defense bonuses) feed into formulas

## Sources

- [Damage Calculation for Attack and Defense](wiki/raw/community/articles/game-mechanics/damage-formulas.md)
- [Ability/Cooldown/Buff Systems](wiki/raw/community/articles/game-mechanics/ability-cooldown-buff-systems.md)
