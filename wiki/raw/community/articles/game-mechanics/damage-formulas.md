# Damage Formula Research

**Sources:**
- https://devforum.roblox.com/t/damage-calculation-for-attack-and-defense/1991737
- https://devforum.roblox.com/t/a-good-damage-formula/1620461
- https://devforum.roblox.com/t/how-to-calculate-damage-fall-off-for-weapons/2175559
- https://devforum.roblox.com/t/help-with-finding-a-balanced-damage-formula/730346
**Captured:** 2026-04-15

## Defense Factor Formula

The most commonly recommended balanced formula:

```
defenseFactor = ATK / (ATK + DEF)
damage = baseDamage * defenseFactor
```

When ATK=50, DEF=50: damage halved to 25.
When ATK=50, DEF=1000: damage drops to ~2.3.
Prevents both one-shots and total immunity.

## Simple Division Formula

```
damage = baseDamage / defenseValue
```

Simpler but breaks at high defense values (approaches 0 asymptotically).

## Naive Subtraction (Anti-pattern)

```
damage = baseDamage - defense
```

Breaks badly: high defense = zero damage, negative damage possible. Must add math.max(0, ...) cap, but still creates dead zones.

## Damage Falloff (Distance-Based)

Linear interpolation for distance-based reduction:

```lua
local MinDamage = 10
local MaxDamage = 30
local MinDistance = 20  -- full damage within this range
local MaxDistance = 40  -- minimum damage beyond this range

function GetDamage(distance: number): number
    local n = math.clamp((distance - MinDistance) / (MaxDistance - MinDistance), 0, 1)
    return n * MinDamage + (1 - n) * MaxDamage
end
```

## Damage Cap Recommendation

For level-based systems: cap maximum damage and prevent combat between players of vastly different levels to avoid one-shot scenarios.

## General Community Consensus

- Work with low base values and percentages
- Test different inputs extensively
- Use constants (config tables) for all tuning values
- All formulas fundamentally follow an ATK * DEF_FACTOR structure
