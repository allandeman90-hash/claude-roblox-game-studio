---
title: Ability System
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/ability-cooldown-buff-systems.md
  - wiki/raw/community/articles/game-mechanics/combat-melee-parry.md
related:
  - "[[combat-system]]"
  - "[[damage-formulas]]"
  - "[[state-machine-pattern]]"
  - "[[projectile-system]]"
tags: [pattern, ability, cooldown, buff, debuff, status-effect, skills]
---

# Ability System

> A server-authoritative framework for managing player abilities with cooldown tracking, buff/debuff stacking, status effects with duration, and ability slot assignment.

## Summary

An ability system governs what actions a player can perform beyond basic attacks: fireballs, healing spells, speed boosts, stuns, shields. Every ability follows the same lifecycle: **validate** (cooldown ready, resources available, not stunned) -> **execute** (apply effect, start cooldown) -> **feedback** (animations, VFX, sounds). The server owns all state: cooldowns, active buffs, status effects, and resource pools. The client sends ability activation requests and receives feedback events.

The system has three sub-modules: a **Cooldown Manager** that tracks per-player ability timers, a **Modifier Stack** that applies and resolves overlapping stat changes (buffs, debuffs, equipment bonuses), and a **Status Effect Controller** that manages timed effects (burn, freeze, stun) with configurable stacking behavior.

## Implementation

### Ability Config (Shared)

```lua
-- ReplicatedStorage/Shared/Config/AbilityConfig.lua
export type AbilityDef = {
    id: string,
    name: string,
    cooldown: number,          -- seconds
    manaCost: number,
    range: number,
    damageType: string,        -- "fire" | "ice" | "physical" | "lightning" | "heal"
    baseDamage: number,        -- 0 for non-damage abilities
    duration: number?,         -- for lasting effects
    aoeRadius: number?,        -- nil = single target
    statusEffect: string?,     -- status to apply on hit
    statusDuration: number?,   -- how long the status lasts
}

local AbilityConfig = {}

AbilityConfig.ABILITIES: {[string]: AbilityDef} = {
    fireball = {
        id = "fireball",
        name = "Fireball",
        cooldown = 5,
        manaCost = 20,
        range = 60,
        damageType = "fire",
        baseDamage = 35,
        aoeRadius = 8,
        statusEffect = "burn",
        statusDuration = 4,
    },
    ice_lance = {
        id = "ice_lance",
        name = "Ice Lance",
        cooldown = 3,
        manaCost = 15,
        range = 50,
        damageType = "ice",
        baseDamage = 25,
        statusEffect = "slow",
        statusDuration = 3,
    },
    heal = {
        id = "heal",
        name = "Healing Light",
        cooldown = 8,
        manaCost = 30,
        range = 0,  -- self-cast
        damageType = "heal",
        baseDamage = -40,  -- negative = heal
    },
    shield = {
        id = "shield",
        name = "Arcane Shield",
        cooldown = 12,
        manaCost = 25,
        range = 0,
        damageType = "heal",
        baseDamage = 0,
        duration = 5,
        statusEffect = "shielded",
        statusDuration = 5,
    },
    lightning_storm = {
        id = "lightning_storm",
        name = "Lightning Storm",
        cooldown = 15,
        manaCost = 50,
        range = 40,
        damageType = "lightning",
        baseDamage = 20,
        aoeRadius = 12,
        duration = 3,       -- ticks over duration
        statusEffect = "electrified",
        statusDuration = 2,
    },
}

-- Ability slots: which abilities a player can equip
AbilityConfig.MAX_SLOTS = 4

return AbilityConfig
```

### Cooldown Manager (Server)

```lua
-- ServerStorage/Abilities/CooldownManager.lua
local CooldownManager = {}
CooldownManager.__index = CooldownManager

-- { [Player]: { [abilityId]: expiryTime } }
local cooldowns: {[Player]: {[string]: number}} = {}

function CooldownManager.init(player: Player)
    cooldowns[player] = {}
end

function CooldownManager.cleanup(player: Player)
    cooldowns[player] = nil
end

--[[
    Returns true if the ability is off cooldown.
    Second return is remaining seconds (0 if ready).
]]
function CooldownManager.isReady(player: Player, abilityId: string): (boolean, number)
    local playerCDs = cooldowns[player]
    if not playerCDs then return false, 0 end

    local expiry = playerCDs[abilityId]
    if not expiry then return true, 0 end

    local now = os.clock()
    if now >= expiry then
        playerCDs[abilityId] = nil
        return true, 0
    end

    return false, expiry - now
end

--[[
    Starts a cooldown for the given ability.
    cooldownReduction is a 0-1 multiplier from buffs (0.2 = 20% CDR).
]]
function CooldownManager.startCooldown(
    player: Player,
    abilityId: string,
    baseCooldown: number,
    cooldownReduction: number?
)
    local playerCDs = cooldowns[player]
    if not playerCDs then return end

    local cdr = math.clamp(cooldownReduction or 0, 0, 0.5)  -- cap at 50% CDR
    local actualCooldown = baseCooldown * (1 - cdr)
    playerCDs[abilityId] = os.clock() + actualCooldown
end

--[[
    Reduces remaining cooldown by a flat amount (e.g., on-hit CDR talent).
]]
function CooldownManager.reduceCooldown(player: Player, abilityId: string, amount: number)
    local playerCDs = cooldowns[player]
    if not playerCDs or not playerCDs[abilityId] then return end

    playerCDs[abilityId] = playerCDs[abilityId] - amount
end

--[[
    Resets a specific cooldown immediately.
]]
function CooldownManager.resetCooldown(player: Player, abilityId: string)
    local playerCDs = cooldowns[player]
    if not playerCDs then return end
    playerCDs[abilityId] = nil
end

--[[
    Returns a snapshot of all cooldown remaining times (for UI sync).
]]
function CooldownManager.getSnapshot(player: Player): {[string]: number}
    local playerCDs = cooldowns[player]
    if not playerCDs then return {} end

    local now = os.clock()
    local snapshot: {[string]: number} = {}
    for id, expiry in playerCDs do
        local remaining = expiry - now
        if remaining > 0 then
            snapshot[id] = remaining
        end
    end
    return snapshot
end

return CooldownManager
```

### Modifier Stack (Server)

```lua
-- ServerStorage/Abilities/ModifierStack.lua

--[[
    Manages stat modifiers (buffs/debuffs) with stacking rules.
    Calculation order: Base -> Additive -> Multiplicative -> Clamp
]]

export type Modifier = {
    id: string,           -- unique identifier
    source: string,        -- what applied it (ability, item, etc.)
    stat: string,          -- "attack", "defense", "speed", "cdr", etc.
    modType: "additive" | "multiplicative",
    value: number,
    expiry: number?,       -- os.clock() time; nil = permanent
    stackRule: "stack" | "replace" | "highest" | "refresh",
    tag: string?,          -- for bulk removal ("debuff", "equipment", etc.)
}

local ModifierStack = {}
ModifierStack.__index = ModifierStack

-- { [Player]: { [stat]: {Modifier} } }
local stacks: {[Player]: {[string]: {Modifier}}} = {}

function ModifierStack.init(player: Player)
    stacks[player] = {}
end

function ModifierStack.cleanup(player: Player)
    stacks[player] = nil
end

function ModifierStack.addModifier(player: Player, modifier: Modifier)
    local playerStacks = stacks[player]
    if not playerStacks then return end

    if not playerStacks[modifier.stat] then
        playerStacks[modifier.stat] = {}
    end

    local statMods = playerStacks[modifier.stat]

    -- Apply stacking rule
    if modifier.stackRule == "replace" then
        -- Remove existing from same source
        for i = #statMods, 1, -1 do
            if statMods[i].source == modifier.source then
                table.remove(statMods, i)
            end
        end
    elseif modifier.stackRule == "highest" then
        -- Keep only the highest value from same source
        for i = #statMods, 1, -1 do
            if statMods[i].source == modifier.source then
                if statMods[i].value >= modifier.value then
                    return  -- existing is higher, skip
                end
                table.remove(statMods, i)
            end
        end
    elseif modifier.stackRule == "refresh" then
        -- Update duration of existing, update value
        for _, existing in statMods do
            if existing.source == modifier.source then
                existing.expiry = modifier.expiry
                existing.value = modifier.value
                return
            end
        end
    end
    -- "stack" or no existing found: just add it

    table.insert(statMods, modifier)
end

function ModifierStack.removeBySource(player: Player, source: string)
    local playerStacks = stacks[player]
    if not playerStacks then return end

    for stat, mods in playerStacks do
        for i = #mods, 1, -1 do
            if mods[i].source == source then
                table.remove(mods, i)
            end
        end
    end
end

function ModifierStack.removeByTag(player: Player, tag: string)
    local playerStacks = stacks[player]
    if not playerStacks then return end

    for stat, mods in playerStacks do
        for i = #mods, 1, -1 do
            if mods[i].tag == tag then
                table.remove(mods, i)
            end
        end
    end
end

--[[
    Resolves the final stat value after all modifiers.
    Prunes expired modifiers during resolution.
]]
function ModifierStack.resolve(player: Player, stat: string, baseValue: number): number
    local playerStacks = stacks[player]
    if not playerStacks or not playerStacks[stat] then
        return baseValue
    end

    local mods = playerStacks[stat]
    local now = os.clock()

    -- Prune expired modifiers
    for i = #mods, 1, -1 do
        if mods[i].expiry and now >= mods[i].expiry then
            table.remove(mods, i)
        end
    end

    -- Phase 1: Additive
    local additiveSum = 0
    for _, mod in mods do
        if mod.modType == "additive" then
            additiveSum += mod.value
        end
    end

    -- Phase 2: Multiplicative
    local multiplicativeProduct = 1
    for _, mod in mods do
        if mod.modType == "multiplicative" then
            multiplicativeProduct *= mod.value
        end
    end

    return (baseValue + additiveSum) * multiplicativeProduct
end

return ModifierStack
```

### Status Effect Controller (Server)

```lua
-- ServerStorage/Abilities/StatusEffectController.lua
local RunService = game:GetService("RunService")
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

export type StatusInstance = {
    effectType: string,
    source: Player?,
    target: Player,
    startTime: number,
    duration: number,
    tickInterval: number?,   -- nil = no tick, just duration
    lastTickTime: number,
    tickDamage: number?,
    stackCount: number,
    onApply: ((target: Player) -> ())?,
    onTick: ((target: Player, stackCount: number) -> ())?,
    onRemove: ((target: Player) -> ())?,
}

local STATUS_DEFS = {
    burn = {
        tickInterval = 1,
        tickDamage = 5,
        maxStacks = 3,
        stackBehavior = "stack",  -- each stack adds more tick damage
    },
    slow = {
        tickInterval = nil,       -- no tick, just stat modifier
        maxStacks = 1,
        stackBehavior = "refresh", -- reapplying refreshes duration
        speedMultiplier = 0.5,
    },
    stun = {
        tickInterval = nil,
        maxStacks = 1,
        stackBehavior = "refresh",
    },
    electrified = {
        tickInterval = 0.5,
        tickDamage = 3,
        maxStacks = 2,
        stackBehavior = "stack",
    },
    shielded = {
        tickInterval = nil,
        maxStacks = 1,
        stackBehavior = "refresh",
        damageReduction = 0.4,
    },
}

-- { [Player]: { [effectType]: StatusInstance } }
local activeEffects: {[Player]: {[string]: StatusInstance}} = {}

local StatusEffectController = {}

function StatusEffectController.init(player: Player)
    activeEffects[player] = {}
end

function StatusEffectController.cleanup(player: Player)
    -- Run onRemove for all active effects
    local effects = activeEffects[player]
    if effects then
        for effectType, instance in effects do
            if instance.onRemove then
                instance.onRemove(player)
            end
        end
    end
    activeEffects[player] = nil
end

function StatusEffectController.apply(
    target: Player,
    effectType: string,
    duration: number,
    source: Player?
)
    local def = STATUS_DEFS[effectType]
    if not def then
        warn("Unknown status effect:", effectType)
        return
    end

    local effects = activeEffects[target]
    if not effects then return end

    local existing = effects[effectType]
    local now = os.clock()

    if existing then
        if def.stackBehavior == "refresh" then
            existing.duration = duration
            existing.startTime = now
        elseif def.stackBehavior == "stack" then
            if existing.stackCount < def.maxStacks then
                existing.stackCount += 1
                existing.startTime = now  -- refresh duration too
                existing.duration = duration
            end
        end
    else
        effects[effectType] = {
            effectType = effectType,
            source = source,
            target = target,
            startTime = now,
            duration = duration,
            tickInterval = def.tickInterval,
            lastTickTime = now,
            tickDamage = def.tickDamage,
            stackCount = 1,
        }
    end

    -- Notify client for VFX
    Remotes.StatusEffectApplied:FireClient(target, effectType, duration)
end

function StatusEffectController.remove(target: Player, effectType: string)
    local effects = activeEffects[target]
    if not effects or not effects[effectType] then return end

    effects[effectType] = nil
    Remotes.StatusEffectRemoved:FireClient(target, effectType)
end

function StatusEffectController.isAffected(target: Player, effectType: string): boolean
    local effects = activeEffects[target]
    return effects ~= nil and effects[effectType] ~= nil
end

function StatusEffectController.getStackCount(target: Player, effectType: string): number
    local effects = activeEffects[target]
    if not effects or not effects[effectType] then return 0 end
    return effects[effectType].stackCount
end

--[[
    Called every Heartbeat to tick active effects and expire finished ones.
]]
function StatusEffectController.update()
    local now = os.clock()

    for player, effects in activeEffects do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        for effectType, instance in effects do
            -- Check expiry
            if now >= instance.startTime + instance.duration then
                StatusEffectController.remove(player, effectType)
                continue
            end

            -- Tick damage
            if instance.tickInterval and instance.tickDamage then
                if now >= instance.lastTickTime + instance.tickInterval then
                    instance.lastTickTime = now
                    if humanoid and humanoid.Health > 0 then
                        local damage = instance.tickDamage * instance.stackCount
                        humanoid:TakeDamage(damage)
                    end
                end
            end
        end
    end
end

return StatusEffectController
```

### Ability Service (Server Orchestrator)

```lua
-- ServerScriptService/Abilities/AbilityService.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AbilityConfig = require(game.ReplicatedStorage.Shared.Config.AbilityConfig)
local CooldownManager = require(game.ServerStorage.Abilities.CooldownManager)
local ModifierStack = require(game.ServerStorage.Abilities.ModifierStack)
local StatusEffectController = require(game.ServerStorage.Abilities.StatusEffectController)
local DamageFormulas = require(game.ServerStorage.Combat.DamageFormulas)
local HitDetection = require(game.ServerStorage.Combat.HitDetection)
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

-- { [Player]: { [slotIndex]: abilityId } }
local equippedAbilities: {[Player]: {[number]: string}} = {}

-- { [Player]: { mana: number, maxMana: number } }
local manaPool: {[Player]: {mana: number, maxMana: number}} = {}

local MANA_REGEN_RATE = 2  -- mana per second

local AbilityService = {}

function AbilityService.init()
    Players.PlayerAdded:Connect(function(player)
        CooldownManager.init(player)
        ModifierStack.init(player)
        StatusEffectController.init(player)
        equippedAbilities[player] = {}
        manaPool[player] = { mana = 100, maxMana = 100 }
    end)

    Players.PlayerRemoving:Connect(function(player)
        CooldownManager.cleanup(player)
        ModifierStack.cleanup(player)
        StatusEffectController.cleanup(player)
        equippedAbilities[player] = nil
        manaPool[player] = nil
    end)

    -- Ability activation remote
    Remotes.UseAbility.OnServerEvent:Connect(function(player, slotIndex)
        if typeof(slotIndex) ~= "number" then return end
        slotIndex = math.clamp(math.floor(slotIndex), 1, AbilityConfig.MAX_SLOTS)

        AbilityService.activateAbility(player, slotIndex)
    end)

    -- Heartbeat: tick status effects + mana regen
    RunService.Heartbeat:Connect(function(dt)
        StatusEffectController.update()

        -- Mana regen
        for player, pool in manaPool do
            if pool.mana < pool.maxMana then
                local regenRate = ModifierStack.resolve(player, "manaRegen", MANA_REGEN_RATE)
                pool.mana = math.min(pool.maxMana, pool.mana + regenRate * dt)
            end
        end
    end)
end

function AbilityService.equipAbility(player: Player, slotIndex: number, abilityId: string)
    local def = AbilityConfig.ABILITIES[abilityId]
    if not def then return false end
    if slotIndex < 1 or slotIndex > AbilityConfig.MAX_SLOTS then return false end

    equippedAbilities[player] = equippedAbilities[player] or {}
    equippedAbilities[player][slotIndex] = abilityId
    return true
end

function AbilityService.activateAbility(player: Player, slotIndex: number)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    -- Stunned check
    if StatusEffectController.isAffected(player, "stun") then return end

    -- Get equipped ability
    local slots = equippedAbilities[player]
    if not slots then return end
    local abilityId = slots[slotIndex]
    if not abilityId then return end

    local def = AbilityConfig.ABILITIES[abilityId]
    if not def then return end

    -- Cooldown check
    local cdr = ModifierStack.resolve(player, "cdr", 0)
    local ready, remaining = CooldownManager.isReady(player, abilityId)
    if not ready then
        Remotes.AbilityCooldown:FireClient(player, abilityId, remaining)
        return
    end

    -- Mana check
    local pool = manaPool[player]
    if not pool or pool.mana < def.manaCost then
        Remotes.AbilityFailed:FireClient(player, abilityId, "NO_MANA")
        return
    end

    -- Commit: consume mana, start cooldown
    pool.mana -= def.manaCost
    CooldownManager.startCooldown(player, abilityId, def.cooldown, cdr)

    -- Execute ability effect
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if def.baseDamage < 0 then
        -- Heal (self-cast)
        humanoid.Health = math.min(
            humanoid.MaxHealth,
            humanoid.Health + math.abs(def.baseDamage)
        )
    elseif def.aoeRadius then
        -- AoE damage
        local targets = HitDetection.radialAoE(
            rootPart.Position + rootPart.CFrame.LookVector * def.range,
            def.aoeRadius,
            {character}
        )
        for _, targetChar in targets do
            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
            if targetHum and targetHum.Health > 0 then
                local damage = DamageFormulas.calculate({
                    baseDamage = def.baseDamage,
                    attackerLevel = player:GetAttribute("Level") or 1,
                    defenderDefense = 0,  -- lookup from target
                    damageType = def.damageType,
                })
                targetHum:TakeDamage(damage)

                -- Apply status effect
                if def.statusEffect and def.statusDuration then
                    local targetPlayer = game.Players:GetPlayerFromCharacter(targetChar)
                    if targetPlayer then
                        StatusEffectController.apply(
                            targetPlayer, def.statusEffect, def.statusDuration, player
                        )
                    end
                end
            end
        end
    end

    -- Apply self-buffs (e.g., shield)
    if def.statusEffect and def.range == 0 then
        StatusEffectController.apply(player, def.statusEffect, def.statusDuration or 5, player)
    end

    -- Feedback
    Remotes.AbilityActivated:FireAllClients(player, abilityId)
end

return AbilityService
```

## Variants

| Variant | Description | Use Case |
|---------|-------------|----------|
| **Simple cooldown** | Single timer per ability, no resources | Casual games, prototypes |
| **Resource + cooldown** | Mana/energy/stamina cost + timer | RPGs, MOBAs |
| **Charge system** | Abilities have multiple charges that refill | Overwatch-style, mobile RPGs |
| **Combo abilities** | Activating in sequence unlocks stronger versions | Action RPGs, fighting games |
| **Passive abilities** | Always-on stat modifiers or proc effects | RPG talent trees |

## Pitfalls

- **Client-side cooldown enforcement.** If the client alone tracks cooldowns, exploiters can bypass them. The server must be the source of truth. Send cooldown snapshots to the client for UI display only.
- **Uncapped CDR.** Without a maximum cooldown reduction (typically 40-50%), stacking CDR items and buffs can produce zero-cooldown abilities, breaking game balance.
- **Modifier resolution order.** Additive before multiplicative is the standard. If the order is ambiguous or inconsistent, buffs that "increase attack by 10" and "increase attack by 20%" produce different results depending on evaluation order. Document and enforce the order.
- **Status effect stacking abuse.** Without stack limits, players can stack dozens of burn effects on a target for instant kills. Every status effect needs a `maxStacks` cap.
- **Orphaned effects.** If a player disconnects or their character dies while effects are active, clean up all their applied effects. Use `Players.PlayerRemoving` and `Humanoid.Died` to trigger cleanup.
- **Floating-point cooldown drift.** Using `os.clock()` accumulates floating-point error over long sessions. For cooldowns under 30 seconds this is negligible; for longer timers, consider `tick()` or integer-based counters.

## Related

- [[combat-system]] -- abilities trigger combat actions and hit detection
- [[damage-formulas]] -- ability damage runs through the same formula pipeline
- [[state-machine-pattern]] -- ability states (casting, channeling, cooldown)
- [[projectile-system]] -- projectile-type abilities use the projectile system

## Sources

- [Cooldowns Module](wiki/raw/community/articles/game-mechanics/ability-cooldown-buff-systems.md)
- [ModifierManager](wiki/raw/community/articles/game-mechanics/ability-cooldown-buff-systems.md)
- [Effectify Status Effects](wiki/raw/community/articles/game-mechanics/ability-cooldown-buff-systems.md)
- [Melee Combat and Parry Systems](wiki/raw/community/articles/game-mechanics/combat-melee-parry.md)
