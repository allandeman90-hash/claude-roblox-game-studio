---
title: magic-numbers
type: anti-pattern
category: anti-patterns
subcategory: code-quality
owner: lead-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
severity: low
sources:
  - .claude/docs/luau-style-guide.md
  - .claude/docs/coding-standards.md
related:
  - "[[client-server-split]]"
tags: [anti-pattern, code-quality]
---

# Magic Numbers

> Hardcoded numeric literals in gameplay code with no name or context.

**Severity:** Low

## What It Looks Like

```lua
-- Damage calculation with unexplained constants
humanoid:TakeDamage(50)

-- Economy check with hardcoded price
if player.Gold >= 100 then
    player.Gold -= 100
    giveItem(player, "Sword")
end

-- Movement tuning buried in logic
humanoid.WalkSpeed = 24
character.HumanoidRootPart.Velocity = Vector3.new(0, 75, 0)

-- Timing with unexplained intervals
task.wait(0.3)
cooldowns[player] = 2.5
```

## Why It's Bad

1. **Untunable**: changing a value requires reading code to find it, understanding context, and hoping there are no other occurrences. Designers cannot adjust balance without programmer intervention.
2. **Duplicate risk**: the same conceptual constant (e.g., "sword damage") appears in multiple places. Changing one and missing another causes inconsistencies.
3. **Unreadable**: `humanoid:TakeDamage(50)` does not communicate whether 50 is base damage, crit damage, or an arbitrary placeholder. `humanoid:TakeDamage(Config.SWORD_BASE_DAMAGE)` is self-documenting.
4. **Review friction**: code reviewers cannot tell if a number is correct without knowing the design intent. Named constants make intent explicit.
5. **Security implication**: when validation thresholds are magic numbers, they often drift out of sync between server and client code or between validation and the actual game rule.

## How to Fix It

Extract all tunable values into config modules:

```lua
-- ReplicatedStorage/Shared/Config/CombatConfig.lua
local CombatConfig = {
    SWORD_BASE_DAMAGE = 50,
    SWORD_CRIT_MULTIPLIER = 2.0,
    ATTACK_COOLDOWN = 2.5,       -- seconds
    ATTACK_RANGE = 8,            -- studs
    MAX_WALK_SPEED = 24,         -- studs/sec
    JUMP_FORCE = 75,             -- vertical impulse
}
return CombatConfig
```

```lua
-- Usage in gameplay code
local CombatConfig = require(ReplicatedStorage.Shared.Config.CombatConfig)

humanoid:TakeDamage(CombatConfig.SWORD_BASE_DAMAGE)
humanoid.WalkSpeed = CombatConfig.MAX_WALK_SPEED
```

For values that are truly constant and universal (like math thresholds), use `UPPER_SNAKE_CASE` locals at the top of the module:

```lua
local MAX_RETRIES = 5
local EPSILON = 0.001
```

## Detection

Look for bare numeric literals in gameplay logic (not in config modules or test files):

```
:TakeDamage(%d
WalkSpeed = %d
JumpPower = %d
>= %d+ then
<= %d+ then
wait(%d
```

The pattern to watch for: numeric literals inside `if` conditions, function arguments, or property assignments in files under `ServerScriptService/` or `StarterPlayer/`.

## Related

- [Coding Standards -- Config-Driven Design](../../.claude/docs/coding-standards.md)
- [Luau Style Guide -- Section 9](../../.claude/docs/luau-style-guide.md)

## Sources

- [Luau Style Guide](../../.claude/docs/luau-style-guide.md) -- Section 9: Magic Numbers
- [Coding Standards](../../.claude/docs/coding-standards.md) -- Section 5: Config-Driven Design
