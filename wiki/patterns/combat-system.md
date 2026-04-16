---
title: Combat System
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/server-authority-combat.md
  - wiki/raw/community/articles/game-mechanics/raycast-hitbox-melee.md
  - wiki/raw/community/articles/game-mechanics/combat-melee-parry.md
  - wiki/raw/community/articles/game-mechanics/spatial-queries-overlap.md
related:
  - "[[ability-system]]"
  - "[[damage-formulas]]"
  - "[[projectile-system]]"
  - "[[state-machine-pattern]]"
  - "[[spawn-respawn-system]]"
tags: [pattern, combat, hit-detection, melee, parry, block, combo, server-authority, raycast]
---

# Combat System

> A server-authoritative combat framework that handles client input, server validation, hit detection, damage calculation, and visual feedback across melee and ranged weapon types.

## Summary

A combat system in Roblox follows a strict server-authoritative flow: the client sends attack intent, the server validates timing and position, the server runs hit detection, the server applies damage via [[damage-formulas]], and the server notifies clients to play feedback effects. The client never determines whether a hit landed or how much damage was dealt. All state -- health, combo index, block status, cooldowns -- lives on the server.

Three hit detection families cover all combat needs: raycasting (point-to-point, best for melee swings and hitscan), spatial queries (volume-based, best for AoE and area attacks), and physics-based projectiles (see [[projectile-system]]). The choice depends on weapon type, required precision, and performance budget.

## Implementation

### Server-Authoritative Combat Flow

```
Client                          Server                         Client (target)
  |                               |                               |
  |-- InputAction: "Attack" ----->|                               |
  |   (combo index, timestamp)    |                               |
  |                               |-- Validate:                   |
  |                               |   - Player alive?             |
  |                               |   - Cooldown expired?         |
  |                               |   - Combo index valid?        |
  |                               |   - Rate limit OK?            |
  |                               |                               |
  |                               |-- Hit Detection:              |
  |                               |   (raycast / spatial query)   |
  |                               |                               |
  |                               |-- Damage Calculation:         |
  |                               |   (see damage-formulas)       |
  |                               |                               |
  |                               |-- Apply damage to target      |
  |                               |                               |
  |<-- "AttackFeedback" ---------|----> "HitFeedback" ---------->|
  |   (play swing anim/VFX)       |      (play hit anim/SFX)     |
```

### Core Combat Module (Server)

```lua
-- ServerScriptService/Combat/CombatService.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DamageFormulas = require(game.ServerStorage.Combat.DamageFormulas)
local HitDetection = require(game.ServerStorage.Combat.HitDetection)
local ComboConfig = require(game.ReplicatedStorage.Shared.Config.ComboConfig)
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

-- Per-player combat state (server-authoritative)
local combatState: {[Player]: CombatState} = {}

export type CombatState = {
    comboIndex: number,
    lastAttackTime: number,
    isBlocking: boolean,
    isParrying: boolean,
    parryExpiry: number,
    invulnerableUntil: number,
    stunUntil: number,
}

local CombatService = {}

local function getState(player: Player): CombatState
    if not combatState[player] then
        combatState[player] = {
            comboIndex = 0,
            lastAttackTime = 0,
            isBlocking = false,
            isParrying = false,
            parryExpiry = 0,
            invulnerableUntil = 0,
            stunUntil = 0,
        }
    end
    return combatState[player]
end

function CombatService.handleAttack(player: Player, comboIndex: number)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local state = getState(player)
    local now = os.clock()

    -- Validate: not stunned
    if now < state.stunUntil then return end

    -- Validate: combo timing
    local combo = ComboConfig.COMBOS[comboIndex]
    if not combo then return end

    local elapsed = now - state.lastAttackTime
    if comboIndex > 1 and elapsed > ComboConfig.COMBO_WINDOW then
        comboIndex = 1  -- reset to first hit
        combo = ComboConfig.COMBOS[1]
    end

    -- Validate: cooldown
    if elapsed < combo.cooldown then return end

    -- Commit: update state
    state.comboIndex = comboIndex
    state.lastAttackTime = now

    -- Hit detection (server-side)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local hits = HitDetection.meleeSwing(
        rootPart.CFrame,
        combo.range,
        combo.hitboxSize,
        {character}  -- exclude self
    )

    -- Damage each hit target
    for _, target in hits do
        CombatService.applyDamage(player, target, combo)
    end

    -- Feedback: tell attacker to play swing animation
    Remotes.AttackFeedback:FireClient(player, comboIndex)

    -- Advance combo
    state.comboIndex = (comboIndex % #ComboConfig.COMBOS) + 1
end

function CombatService.applyDamage(
    attacker: Player,
    targetCharacter: Model,
    combo: ComboConfig.ComboHit
)
    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return end

    local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
    local targetState = if targetPlayer then getState(targetPlayer) else nil
    local now = os.clock()

    -- Check invulnerability (i-frames)
    if targetState and now < targetState.invulnerableUntil then return end

    -- Check parry
    if targetState and targetState.isParrying and now < targetState.parryExpiry then
        -- Parry success: stun the attacker
        local attackerState = getState(attacker)
        attackerState.stunUntil = now + ComboConfig.PARRY_STUN_DURATION
        targetState.invulnerableUntil = now + ComboConfig.PARRY_IFRAMES

        if targetPlayer then
            Remotes.ParryFeedback:FireClient(targetPlayer, true)
        end
        Remotes.StunFeedback:FireClient(attacker)
        return
    end

    -- Check block (reduce damage)
    local blockReduction = 0
    if targetState and targetState.isBlocking then
        blockReduction = ComboConfig.BLOCK_DAMAGE_REDUCTION
    end

    -- Calculate damage
    local damage = DamageFormulas.calculate({
        baseDamage = combo.damage,
        attackerLevel = attacker:GetAttribute("Level") or 1,
        defenderDefense = (targetPlayer and targetPlayer:GetAttribute("Defense")) or 0,
        blockReduction = blockReduction,
        comboMultiplier = combo.damageMultiplier,
    })

    targetHumanoid:TakeDamage(damage)

    -- Feedback to target
    if targetPlayer then
        Remotes.HitFeedback:FireClient(targetPlayer, damage)
    end
end

function CombatService.init()
    Remotes.AttackRequest.OnServerEvent:Connect(function(player, comboIndex)
        -- Validate argument types
        if typeof(comboIndex) ~= "number" then return end
        comboIndex = math.clamp(math.floor(comboIndex), 1, #ComboConfig.COMBOS)

        CombatService.handleAttack(player, comboIndex)
    end)

    Remotes.BlockRequest.OnServerEvent:Connect(function(player, isBlocking)
        if typeof(isBlocking) ~= "boolean" then return end
        local state = getState(player)
        state.isBlocking = isBlocking
        state.isParrying = false
    end)

    Remotes.ParryRequest.OnServerEvent:Connect(function(player)
        local state = getState(player)
        if state.isBlocking then return end  -- can't parry while blocking

        local now = os.clock()
        if now < state.stunUntil then return end

        state.isParrying = true
        state.parryExpiry = now + ComboConfig.PARRY_WINDOW

        -- Auto-expire parry
        task.delay(ComboConfig.PARRY_WINDOW, function()
            state.isParrying = false
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        combatState[player] = nil
    end)
end

return CombatService
```

### Hit Detection Module (Server)

```lua
-- ServerStorage/Combat/HitDetection.lua
local HitDetection = {}

--[[
    Melee swing: oriented box hitbox in front of the attacker.
    Uses GetPartBoundsInBox for region-based detection.
]]
function HitDetection.meleeSwing(
    attackerCFrame: CFrame,
    range: number,
    hitboxSize: Vector3,
    excludeList: {Instance}
): {Model}
    -- Hitbox positioned in front of attacker
    local hitboxCFrame = attackerCFrame * CFrame.new(0, 0, -range / 2)

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = excludeList
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.MaxParts = 20

    local parts = workspace:GetPartBoundsInBox(hitboxCFrame, hitboxSize, overlapParams)

    -- Deduplicate by character model
    local hitCharacters: {[Model]: boolean} = {}
    local results: {Model} = {}

    for _, part in parts do
        local character = part.Parent
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        if hitCharacters[character] then continue end

        hitCharacters[character] = true
        table.insert(results, character)
    end

    return results
end

--[[
    Raycast swing: fires rays from attachment points along a weapon.
    Use when precise per-bone hit detection is needed.
]]
function HitDetection.raycastSwing(
    attachmentPositions: {Vector3},   -- current frame positions
    previousPositions: {Vector3},      -- last frame positions
    excludeList: {Instance}
): {Model}
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = excludeList
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local hitCharacters: {[Model]: boolean} = {}
    local results: {Model} = {}

    for i, currentPos in attachmentPositions do
        local prevPos = previousPositions[i]
        if not prevPos then continue end

        local direction = currentPos - prevPos
        if direction.Magnitude < 0.01 then continue end

        local result = workspace:Raycast(prevPos, direction, raycastParams)
        if not result or not result.Instance then continue end

        local character = result.Instance.Parent
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        if hitCharacters[character] then continue end

        hitCharacters[character] = true
        table.insert(results, character)
    end

    return results
end

--[[
    Radial AoE: sphere around a point. For explosions, ground slams, etc.
]]
function HitDetection.radialAoE(
    center: Vector3,
    radius: number,
    excludeList: {Instance}
): {Model}
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = excludeList
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.MaxParts = 50

    local parts = workspace:GetPartBoundsInRadius(center, radius, overlapParams)

    local hitCharacters: {[Model]: boolean} = {}
    local results: {Model} = {}

    for _, part in parts do
        local character = part.Parent
        if not character then continue end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        if hitCharacters[character] then continue end

        hitCharacters[character] = true
        table.insert(results, character)
    end

    return results
end

return HitDetection
```

### Combo Config (Shared)

```lua
-- ReplicatedStorage/Shared/Config/ComboConfig.lua
export type ComboHit = {
    damage: number,
    damageMultiplier: number,
    range: number,
    hitboxSize: Vector3,
    cooldown: number,          -- minimum time before this hit can fire
    animationId: string,
}

local ComboConfig = {}

ComboConfig.COMBO_WINDOW = 1.0          -- seconds to input next combo hit
ComboConfig.PARRY_WINDOW = 0.25         -- seconds parry is active
ComboConfig.PARRY_STUN_DURATION = 1.0   -- seconds attacker is stunned on parry
ComboConfig.PARRY_IFRAMES = 0.3         -- seconds of invulnerability after parry
ComboConfig.BLOCK_DAMAGE_REDUCTION = 0.6 -- 60% damage reduction while blocking

ComboConfig.COMBOS: {ComboHit} = {
    {   -- Hit 1: quick jab
        damage = 10,
        damageMultiplier = 1.0,
        range = 6,
        hitboxSize = Vector3.new(4, 4, 6),
        cooldown = 0.4,
        animationId = "rbxassetid://111111",
    },
    {   -- Hit 2: cross
        damage = 12,
        damageMultiplier = 1.1,
        range = 6,
        hitboxSize = Vector3.new(5, 4, 6),
        cooldown = 0.35,
        animationId = "rbxassetid://222222",
    },
    {   -- Hit 3: heavy swing (finisher)
        damage = 18,
        damageMultiplier = 1.4,
        range = 7,
        hitboxSize = Vector3.new(6, 5, 7),
        cooldown = 0.5,
        animationId = "rbxassetid://333333",
    },
}

return ComboConfig
```

### Client Input Handler

```lua
-- StarterPlayer/StarterPlayerScripts/CombatInput.client.lua
local UserInputService = game:GetService("UserInputService")
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

local comboIndex = 1
local lastClickTime = 0
local COMBO_WINDOW = 1.0  -- mirror server config

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local now = os.clock()
        if now - lastClickTime > COMBO_WINDOW then
            comboIndex = 1  -- reset combo
        end
        lastClickTime = now
        Remotes.AttackRequest:FireServer(comboIndex)
        comboIndex = comboIndex + 1
    elseif input.KeyCode == Enum.KeyCode.F then
        Remotes.ParryRequest:FireServer()
    elseif input.KeyCode == Enum.KeyCode.Q then
        Remotes.BlockRequest:FireServer(true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        Remotes.BlockRequest:FireServer(false)
    end
end)
```

## Hit Detection Methods Comparison

| Method | Best For | Precision | Performance | Complexity |
|--------|----------|-----------|-------------|------------|
| `workspace:Raycast` | Hitscan weapons, per-bone melee | High (point) | Excellent | Low |
| `workspace:Blockcast` | Thick projectiles, wide swings | High (volume) | Good | Medium |
| `workspace:Spherecast` | Rounded projectiles | High (volume) | Good | Medium |
| `GetPartBoundsInBox` | Melee hitbox, AoE zones | Medium (AABB) | Good | Low |
| `GetPartBoundsInRadius` | Radial AoE, explosions | Medium (sphere) | Good | Low |
| `GetPartsInPart` | Irregular hitbox shapes | High (geometry) | Fair | Medium |
| `.Touched` | **Do not use** for combat | Unreliable | Poor | Low |
| Magnitude check | Quick proximity test | Low (sphere) | Excellent | Trivial |

### When to Use Each

- **Melee sword/fist**: `GetPartBoundsInBox` for the hitbox volume, or attachment-based raycasts for per-bone precision.
- **Hitscan gun**: `workspace:Raycast` from muzzle to target direction.
- **Projectile gun**: See [[projectile-system]] (FastCast / segmented raycast).
- **AoE explosion**: `GetPartBoundsInRadius` centered on detonation point.
- **Ground slam cone**: `GetPartBoundsInBox` with a wedge-shaped box or multiple raycasts in a fan pattern.

## Variants

| Variant | Description | Use Case |
|---------|-------------|----------|
| **Basic melee** | Single-hit attacks with block | Simple fighting games, prototypes |
| **Combo melee** | Multi-hit chains with finishers | Action RPGs, anime fighters |
| **Parry/counter** | Timed defensive with counter-attack | Soulslike, competitive PvP |
| **Stamina combat** | Attacks and blocks cost stamina | Dark Souls-style, survival |
| **Stance combat** | Multiple stance modes with different movesets | Fighting games |

## Pitfalls

- **Client-side hit detection.** The server must detect hits. Client-detected hits are trivially spoofed by exploiters. The client sends attack intent; the server decides what was hit.
- **Missing rate limiting.** Without attack cooldown enforcement on the server, macro tools can fire attacks at inhuman speed. Always enforce minimum cooldown server-side.
- **Touched for combat.** `.Touched` events are frame-dependent, miss fast swings, and fire unpredictably. Use raycasts or spatial queries instead.
- **Animation-driven timing.** Embedding balance-critical timing in animation events makes tuning painful. Use code-based timers with animation as visual feedback only.
- **Infinite blocking.** Block must cost something (stamina, durability) or have a guard-break mechanic, or players will turtle indefinitely.
- **Missing i-frames on dodge/parry.** Without invulnerability windows, dodge and parry become useless against fast multi-hit attacks. Keep i-frame durations in config, not hardcoded.
- **Combo desync.** If the client tracks combo index independently from the server, they can drift apart. The server is authoritative on combo state; the client mirrors it from feedback events.

## Related

- [[ability-system]] -- abilities that trigger combat actions
- [[damage-formulas]] -- how damage is calculated from stats
- [[projectile-system]] -- ranged weapon projectile handling
- [[state-machine-pattern]] -- combat states (idle, attacking, blocking, stunned)
- [[spawn-respawn-system]] -- player death and respawn after combat

## Sources

- [Server Authority: How to Begin](wiki/raw/community/articles/game-mechanics/server-authority-combat.md)
- [Raycast Hitbox 4.01](wiki/raw/community/articles/game-mechanics/raycast-hitbox-melee.md)
- [Melee Combat, Combos, and Parry](wiki/raw/community/articles/game-mechanics/combat-melee-parry.md)
- [Spatial Queries and OverlapParams](wiki/raw/community/articles/game-mechanics/spatial-queries-overlap.md)
