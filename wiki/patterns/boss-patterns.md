---
title: Boss Patterns
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/boss-battle-design.md
  - wiki/raw/community/articles/game-mechanics/boss-battle-basic.md
  - wiki/raw/community/articles/game-mechanics/boss-attack-system.md
  - wiki/raw/community/articles/game-mechanics/combat-npc-tutorial.md
related:
  - "[[npc-ai-system]]"
  - "[[pathfinding-system]]"
  - "[[behavior-trees]]"
  - "[[state-machine-pattern]]"
tags:
  - boss
  - combat
  - ai
  - phase
  - state-machine
---

# Boss Patterns

> Phase-based boss design: telegraph-windup-attack-recovery cycle, health-gated phase transitions, adds spawning, enrage timer, and safe zones.

## Summary

Boss encounters differ from standard NPC AI in two key ways: bosses follow scripted attack patterns rather than reactive decision-making, and their behavior changes at health thresholds (phases). The standard architecture is a server-side state machine where the boss cycles through attack selections per phase, with transitions triggered by health percentages. Each individual attack follows a telegraph-windup-attack-recovery cycle to give players readable tells and punish windows.

## Implementation

### Phase-Based State Machine

```lua
-- ServerScriptService/BossController.server.lua

export type BossPhase = "phase1" | "phase2" | "phase3" | "enraged" | "dead"

export type BossAttack = {
    name: string,
    telegraph: number,   -- seconds of warning (animation/VFX)
    windup: number,      -- seconds of charge-up
    execute: (boss: Model, targets: {Model}) -> (),
    recovery: number,    -- seconds of vulnerability after attack
    cooldown: number,    -- minimum seconds before this attack can repeat
}

local function createBoss(bossModel: Model)
    local humanoid: Humanoid = bossModel:FindFirstChildWhichIsA("Humanoid")
    local rootPart: BasePart = bossModel:FindFirstChild("HumanoidRootPart")

    return {
        model = bossModel,
        humanoid = humanoid,
        rootPart = rootPart,
        phase = "phase1" :: BossPhase,
        isAttacking = false,
        attackCooldowns = {} :: {[string]: number},
        enrageTimer = 0,
        maxEnrageTime = 300,  -- 5 minutes before enrage
    }
end
```

### Health-Gated Phase Transitions

Phases transition when health drops below defined thresholds. Transitions trigger a brief invulnerability window for cinematic effect and to prevent phase-skipping.

```lua
local PHASE_THRESHOLDS = {
    phase2 = 0.66,   -- 66% HP
    phase3 = 0.33,   -- 33% HP
}

local function checkPhaseTransition(boss)
    local healthPercent = boss.humanoid.Health / boss.humanoid.MaxHealth

    if boss.phase == "phase1" and healthPercent <= PHASE_THRESHOLDS.phase2 then
        transitionToPhase(boss, "phase2")
    elseif boss.phase == "phase2" and healthPercent <= PHASE_THRESHOLDS.phase3 then
        transitionToPhase(boss, "phase3")
    end
end

local function transitionToPhase(boss, newPhase: BossPhase)
    boss.phase = newPhase
    boss.isAttacking = false

    -- Brief invulnerability during transition
    boss.humanoid.MaxHealth = boss.humanoid.Health  -- prevent overkill
    -- Play phase transition animation/cutscene
    task.wait(2) -- transition cinematic duration
    boss.humanoid.MaxHealth = boss.humanoid.Health  -- restore

    -- Phase-specific setup
    if newPhase == "phase2" then
        boss.humanoid.WalkSpeed *= 1.2
        -- Unlock new attacks, spawn adds, change arena
    elseif newPhase == "phase3" then
        boss.humanoid.WalkSpeed *= 1.4
        -- More aggressive attack pool
    end
end
```

### Attack Pattern System

Each phase has its own pool of attacks. The boss randomly selects from available attacks respecting cooldowns.

```lua
local PHASE_ATTACKS: {[BossPhase]: {BossAttack}} = {
    phase1 = {
        {
            name = "Slam",
            telegraph = 1.0,
            windup = 0.5,
            execute = function(boss, targets)
                -- AoE damage around boss
                for _, target in targets do
                    local dist = (target.PrimaryPart.Position - boss.rootPart.Position).Magnitude
                    if dist <= 15 then
                        local hum = target:FindFirstChildWhichIsA("Humanoid")
                        if hum then hum:TakeDamage(25) end
                    end
                end
            end,
            recovery = 2.0,
            cooldown = 5.0,
        },
        {
            name = "Charge",
            telegraph = 1.5,
            windup = 0.3,
            execute = function(boss, targets)
                -- Dash toward nearest target
                local nearest = targets[1]
                if not nearest or not nearest.PrimaryPart then return end
                boss.humanoid.WalkSpeed = 48
                boss.humanoid:MoveTo(nearest.PrimaryPart.Position)
                boss.humanoid.MoveToFinished:Wait()
                boss.humanoid.WalkSpeed = 16
                -- Damage on contact handled by hitbox
            end,
            recovery = 3.0,
            cooldown = 8.0,
        },
    },
    phase2 = {
        -- Inherits phase1 attacks plus new ones
        {
            name = "SummonAdds",
            telegraph = 2.0,
            windup = 1.0,
            execute = function(boss, targets)
                -- Spawn minion NPCs
                for i = 1, 3 do
                    local add = game.ServerStorage.Minion:Clone()
                    add:PivotTo(boss.rootPart.CFrame * CFrame.new(
                        math.random(-10, 10), 0, math.random(-10, 10)))
                    add.Parent = workspace.NPCs
                end
            end,
            recovery = 1.5,
            cooldown = 20.0,
        },
        {
            name = "Shockwave",
            telegraph = 1.0,
            windup = 0.8,
            execute = function(boss, targets)
                -- Expanding ring damage
                for _, target in targets do
                    local dist = (target.PrimaryPart.Position - boss.rootPart.Position).Magnitude
                    if dist <= 30 and dist >= 5 then
                        local hum = target:FindFirstChildWhichIsA("Humanoid")
                        if hum then hum:TakeDamage(35) end
                    end
                end
            end,
            recovery = 2.5,
            cooldown = 12.0,
        },
    },
}
```

### Telegraph-Windup-Attack-Recovery Cycle

Every boss attack follows a four-beat cycle that gives players readable patterns.

```lua
local function executeAttack(boss, attack: BossAttack, targets: {Model})
    boss.isAttacking = true

    -- 1. TELEGRAPH: visual/audio warning so players can react
    -- Play warning animation, show ground indicator, play sound
    -- e.g., boss raises weapon, ground circle appears
    task.wait(attack.telegraph)

    -- 2. WINDUP: brief pause before the hit lands
    -- Player has committed to dodge or block by now
    task.wait(attack.windup)

    -- 3. EXECUTE: the actual damage/effect
    attack.execute(boss, targets)

    -- 4. RECOVERY: boss is vulnerable, players can punish
    -- Reduced movement, no new attacks
    local savedSpeed = boss.humanoid.WalkSpeed
    boss.humanoid.WalkSpeed = 0
    task.wait(attack.recovery)
    boss.humanoid.WalkSpeed = savedSpeed

    -- Set cooldown
    boss.attackCooldowns[attack.name] = tick()
    boss.isAttacking = false
end
```

### Attack Selection with Cooldowns

```lua
local function selectAttack(boss): BossAttack?
    local pool = PHASE_ATTACKS[boss.phase]
    if not pool then return nil end

    -- Filter by cooldown
    local available = {}
    local now = tick()

    for _, attack in pool do
        local lastUsed = boss.attackCooldowns[attack.name] or 0
        if (now - lastUsed) >= attack.cooldown then
            table.insert(available, attack)
        end
    end

    if #available == 0 then return nil end

    -- Weighted random selection (or pure random)
    return available[math.random(1, #available)]
end
```

### Enrage Timer

If the fight lasts too long, the boss enters an enrage state with faster attacks and more damage.

```lua
local function checkEnrage(boss, deltaTime: number)
    boss.enrageTimer += deltaTime

    if boss.enrageTimer >= boss.maxEnrageTime and boss.phase ~= "enraged" then
        boss.phase = "enraged"
        boss.humanoid.WalkSpeed *= 2

        -- All attack cooldowns halved, damage doubled
        -- This is the DPS check: kill before enrage or wipe
    end
end
```

### Safe Zones

Certain attacks require players to stand in designated safe areas. Implement as zone checks during attack execution.

```lua
local function isInSafeZone(character: Model, safeZones: {BasePart}): boolean
    local charRoot = character:FindFirstChild("HumanoidRootPart")
    if not charRoot then return false end

    for _, zone in safeZones do
        -- Simple AABB check using zone size
        local relative = zone.CFrame:PointToObjectSpace(charRoot.Position)
        local halfSize = zone.Size / 2

        if math.abs(relative.X) <= halfSize.X
            and math.abs(relative.Y) <= halfSize.Y
            and math.abs(relative.Z) <= halfSize.Z
        then
            return true
        end
    end
    return false
end

-- In a raidwide attack:
local function raidwideAttack(boss, targets, safeZones)
    for _, target in targets do
        if not isInSafeZone(target, safeZones) then
            local hum = target:FindFirstChildWhichIsA("Humanoid")
            if hum then hum:TakeDamage(80) end
        end
    end
end
```

### Main Boss Loop

```lua
local Players = game:GetService("Players")

local function getAlivePlayers(): {Model}
    local alive = {}
    for _, player in Players:GetPlayers() do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(alive, char)
            end
        end
    end
    return alive
end

local function bossLoop(boss)
    local TICK_RATE = 0.5

    while boss.humanoid.Health > 0 do
        checkEnrage(boss, TICK_RATE)
        checkPhaseTransition(boss)

        if not boss.isAttacking then
            local targets = getAlivePlayers()
            if #targets > 0 then
                -- Face nearest target
                local nearest = targets[1]
                if nearest.PrimaryPart then
                    boss.rootPart.CFrame = CFrame.new(
                        boss.rootPart.Position,
                        Vector3.new(
                            nearest.PrimaryPart.Position.X,
                            boss.rootPart.Position.Y,
                            nearest.PrimaryPart.Position.Z
                        )
                    )
                end

                local attack = selectAttack(boss)
                if attack then
                    task.spawn(executeAttack, boss, attack, targets)
                end
            end
        end

        task.wait(TICK_RATE)
    end

    boss.phase = "dead"
    -- Trigger loot, cutscene, etc.
end
```

## Variants

### Survival Boss (No Health Bar)

The boss is invincible. Players must survive N attack cycles or complete an objective.

```lua
local TOTAL_CYCLES = 3

for cycle = 1, TOTAL_CYCLES do
    local attack = selectAttack(boss)
    if attack then
        executeAttack(boss, attack, getAlivePlayers())
    end
    task.wait(2) -- breathing room between cycles
end
-- Boss retreats or phase ends
```

### Vulnerability Windows

The boss is only damageable during recovery phases or after specific attack failures.

```lua
local function executeAttackWithVulnerability(boss, attack, targets)
    boss.humanoid.MaxHealth = math.huge -- invulnerable during attack
    -- telegraph + windup + execute
    task.wait(attack.telegraph + attack.windup)
    attack.execute(boss, targets)

    -- Recovery = vulnerability window
    boss.humanoid.MaxHealth = 1000 -- restore normal max
    boss.humanoid.WalkSpeed = 0
    task.wait(attack.recovery)
    boss.humanoid.WalkSpeed = 16
end
```

### Random vs Sequential Patterns

Sequential patterns are more learnable; random patterns are more replayable. Some bosses use fixed sequences within each phase, adding one new attack per phase.

```lua
-- Sequential: cycle through attacks in order
local attackIndex = 1
local function nextAttack(boss): BossAttack
    local pool = PHASE_ATTACKS[boss.phase]
    local attack = pool[attackIndex]
    attackIndex = (attackIndex % #pool) + 1
    return attack
end
```

## Pitfalls

1. **Phase-skipping with burst damage**: Without invulnerability during transitions, high DPS can skip phase 2 entirely. Always gate transitions with a brief invulnerable window or health clamp.

2. **No telegraph**: Attacks that deal damage without visual warning feel unfair. Even a 0.5-second ground indicator or sound cue is necessary for readable combat.

3. **Recovery too short or absent**: Without recovery windows, players never get to attack the boss. Every attack cycle must have a punish window proportional to the attack's danger.

4. **Attack cooldowns not tracked**: Without cooldowns, random selection can repeat the same attack 3 times in a row. Track per-attack timestamps and filter the pool.

5. **Infinite adds**: Summoning minions without limits turns the fight into a mob survival. Cap active adds and only spawn more when existing ones die.

6. **Enrage too harsh or too lenient**: An enrage timer that is too short makes the fight a pure DPS check. Too long and it never matters. Tune based on expected group DPS and test with the minimum viable group size.

7. **Boss anchored to a spot**: Anchoring the boss `HumanoidRootPart` prevents all movement including knockback. Keep the boss unanchored and use `MoveTo` or `CFrame` manipulation for controlled movement.

8. **Recursive pcall(main)**: A common beginner pattern calls `pcall(main)` at the end of each attack function, building an ever-growing call stack. Use a proper loop with attack selection instead.

## Related

- [[npc-ai-system]] -- Standard NPC AI state machine
- [[pathfinding-system]] -- Boss movement between arena positions
- [[behavior-trees]] -- Alternative to FSM for complex multi-phase bosses
- [[state-machine-pattern]] -- General FSM architecture

## Sources

- [Making Boss Battles Correctly](wiki/raw/community/articles/game-mechanics/boss-battle-design.md)
- [How to Make a Boss Battle (Basic)](wiki/raw/community/articles/game-mechanics/boss-battle-basic.md)
- [NPC Boss Attack System](wiki/raw/community/articles/game-mechanics/boss-attack-system.md)
- [General Combat NPC Tutorial](wiki/raw/community/articles/game-mechanics/combat-npc-tutorial.md)
- [DevForum: Making Boss Battles Correctly](https://devforum.roblox.com/t/making-boss-battles-correctly/861910)
- [DevForum: How to Make a Boss Battle](https://devforum.roblox.com/t/how-to-make-a-boss-battle-basic-not-multi-staged/1546546)
- [DevForum: Boss Attack System](https://devforum.roblox.com/t/npc-boss-attack-system/1940539)
