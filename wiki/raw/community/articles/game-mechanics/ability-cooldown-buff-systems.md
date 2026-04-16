# Ability, Cooldown, and Buff/Debuff Systems

**Sources:**
- https://devforum.roblox.com/t/cooldowns-the-ultimate-cooldowndebounce-management-module-system/3885782
- https://devforum.roblox.com/t/modifiermanager-a-stat-modifier-system-with-type-safety-stacking-rules-and-client-sync/4338060
- https://devforum.roblox.com/t/effectify-v131-a-customizable-status-effect-implementation/3635681
**Captured:** 2026-04-15

## Cooldowns Module

Heartbeat-driven cooldown/debounce management with frame accuracy.

### API

- `Cooldowns.new(name?)` - Creates instance
- `:Set(key, duration, callback?, ...)` - Forces new cooldown
- `:Add(key, duration, callback?, ...)` - Sets only if nonexistent
- `:Check(key, scaled?)` - Returns (ready: boolean, remaining: number)
- `:Remove(key)` / `:Reset()` - Clear cooldowns
- `:Pause(key)` / `:Resume(key)` - Freeze/unfreeze
- `:SetTimeScale(scale)` - Speed multiplier (0.5 = slow-mo)
- `:AdjustDuration(key, amount)` - Modify single cooldown
- `:AdjustAllDurations(amount, predicate?)` - Bulk CDR with filter

### Example

```lua
local abilities = Cooldowns.new(player.Name)
local ready, remaining = abilities:Check("Fireball")
if ready then
    abilities:Add("Fireball", 5, function()
        print("Fireball ready again!")
    end)
    castFireball()
end
```

## ModifierManager — Stat Modifiers

Type-safe system for buffs/debuffs with stacking rules and client sync.

### Modifier Types

- Additive: Direct numerical increases
- Multiplicative: Percentage-based scaling
- Override: Highest-priority, supersedes others

### Calculation Order

Base value -> Additive -> Multiplicative -> Override (if present) -> Clamping

### Stacking Rules

- Stack: Multiple modifiers accumulate
- Replace: New removes old
- Highest: Only strongest applies
- Refresh: Resets duration, updates value

### API

```lua
local playerStats = ModifierManager.PlayerManager.new()
playerStats:SetBase(player, "Combat.Health", 100)
playerStats:AddModifier({
    player = player,
    path = "Movement.Speed",
    value = 1.5,
    type = "Multiplicative",
    source = "SpeedBoost",
    duration = 10,
})
playerStats:RemoveAllByTag(player, "debuff")
```

## Effectify — Status Effects

OOP module for temporary status effects with configurable stacking and particle support.

### Stack Types

- Overwrite: New replaces previous
- Yield: Queues until previous completes
- Overlap: Multiple instances simultaneously

### MaxStackBehavior

- DropOldest: Removes earliest stack entry
- RejectNew: Prevents new at max capacity
- ResetAll: Clears stack, starts fresh

### Signals

- ActivatedSignal, DeactivatedSignal, TickSignal, StackedSignal, YieldedSignal, TimeLeftSignal

### Example

```lua
local StatusEffect = Effectify.new({
    Owner = character,
    Creator = part,
    Duration = 3,
    EffectType = "Fire",
    StackType = "Overwrite"
})
StatusEffect:Activate()
```
