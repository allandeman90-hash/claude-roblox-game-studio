---
title: tower-defense-mechanics
type: pattern
category: patterns
subcategory: genre-mechanics
owner: game-designer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/tower-defense-guide.md
  - wiki/raw/community/articles/game-mechanics/tower-defense-targeting.md
related:
  - "[[round-system]]"
  - "[[lobby-system]]"
  - "[[matchmaking-queue]]"
  - "[[leaderboard-pattern]]"
  - "[[DataStoreService]]"
tags: [pattern, tower-defense, waves, targeting, pathfinding, placement, genre]
---

# Tower Defense Mechanics

> Tower placement on grid/terrain, targeting AI (first/last/strongest/closest), wave spawning with escalation, upgrade trees per tower, and enemy pathing along node-based waypoints. A high-skill genre with deep strategic depth.

## Summary

Tower defense games on Roblox (Tower Defense Simulator, All Star Tower Defense) combine strategic placement with cooperative wave survival. Players place towers along a fixed enemy path, upgrade them, and survive increasingly difficult waves. The genre demands careful performance optimization because dozens of towers may be simultaneously targeting dozens of enemies every frame. The core technical challenges are: efficient enemy pathfinding along waypoints, scalable targeting systems, and wave spawning that escalates without crashing the server.

## Core Loop

```
Players join lobby --> Vote on map --> Match starts
       |
       v
Wave Announcement (countdown)
       |
       v
Enemies spawn at path start, walk waypoints toward base
       |
       v
Players place towers (costs in-match currency)
       |
       v
Towers auto-target enemies in range --> deal damage
       |
       v
Killed enemies drop in-match currency
       |
       v
Wave complete --> intermission --> next wave (harder)
       |
       v
Boss wave (every N waves) --> special rewards
       |
       v
Base HP hits 0 = GAME OVER  |  All waves cleared = VICTORY
```

## Implementation

### Path and Waypoint System

Enemies follow a fixed path defined by numbered waypoint parts. The path is authored in Studio as small Parts inside a Folder.

```lua
-- Workspace structure:
-- Workspace/
--   Map1/
--     Path/
--       1 (Part at start)
--       2 (Part at first turn)
--       3 ...
--       N (Part at base/end)

-- ServerStorage/PathModule.lua
local PathModule = {}

function PathModule.getWaypoints(mapName: string): {Vector3}
    local pathFolder = workspace:FindFirstChild(mapName):FindFirstChild("Path")
    if not pathFolder then return {} end

    local waypoints: {Vector3} = {}
    local children = pathFolder:GetChildren()

    -- Sort by numeric name
    table.sort(children, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    for _, wp in children do
        table.insert(waypoints, wp.Position)
    end

    return waypoints
end

return PathModule
```

### Enemy Movement

Enemies move along waypoints using `Humanoid:MoveTo()` or, for better performance at scale, TweenService or CFrame Lerping.

```lua
-- ServerStorage/EnemyHandler.lua
local EnemyHandler = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local enemyTemplates = ReplicatedStorage.Enemies

export type EnemyState = {
    model: Model,
    health: number,
    maxHealth: number,
    speed: number,
    currentWaypoint: number,
    distanceAlongPath: number, -- for targeting priority
}

local activeEnemies: {EnemyState} = {}

function EnemyHandler.spawn(enemyName: string, waypoints: {Vector3}): EnemyState
    local template = enemyTemplates:FindFirstChild(enemyName)
    if not template then error("Unknown enemy: " .. enemyName) end

    local model = template:Clone()
    model:PivotTo(CFrame.new(waypoints[1]))
    model.Parent = workspace.ActiveEnemies

    local state: EnemyState = {
        model = model,
        health = model:GetAttribute("Health") or 100,
        maxHealth = model:GetAttribute("Health") or 100,
        speed = model:GetAttribute("Speed") or 12,
        currentWaypoint = 1,
        distanceAlongPath = 0,
    }

    table.insert(activeEnemies, state)
    EnemyHandler.moveAlongPath(state, waypoints)
    return state
end

function EnemyHandler.moveAlongPath(state: EnemyState, waypoints: {Vector3})
    task.spawn(function()
        for i = 2, #waypoints do
            if not state.model.Parent then return end -- destroyed

            local humanoid = state.model:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            state.currentWaypoint = i
            humanoid:MoveTo(waypoints[i])
            humanoid.MoveToFinished:Wait()

            -- Update path distance for targeting
            state.distanceAlongPath += (waypoints[i] - waypoints[i - 1]).Magnitude
        end

        -- Reached the base: deal damage
        if state.model.Parent then
            BaseHealth -= state.health -- remaining health as damage
            state.model:Destroy()
        end
    end)
end

function EnemyHandler.getActiveEnemies(): {EnemyState}
    return activeEnemies
end

function EnemyHandler.damageEnemy(state: EnemyState, damage: number)
    state.health -= damage
    if state.health <= 0 and state.model.Parent then
        state.model:Destroy()
        -- Remove from active list
        local idx = table.find(activeEnemies, state)
        if idx then table.remove(activeEnemies, idx) end
        return true -- killed
    end
    return false
end

return EnemyHandler
```

### Tower Placement System

Players select a tower from their inventory, see a ghost preview on the client, then confirm placement. The server validates position (on valid terrain, not overlapping, within budget).

```lua
-- ServerStorage/TowerPlacer.lua
local TowerPlacer = {}

local GRID_SIZE = 4 -- studs, snap placement to grid

function TowerPlacer.snapToGrid(position: Vector3): Vector3
    return Vector3.new(
        math.round(position.X / GRID_SIZE) * GRID_SIZE,
        position.Y,
        math.round(position.Z / GRID_SIZE) * GRID_SIZE
    )
end

function TowerPlacer.canPlace(position: Vector3, towerRadius: number): boolean
    -- Check if position is on valid placement area
    local rayResult = workspace:Raycast(
        position + Vector3.new(0, 10, 0),
        Vector3.new(0, -20, 0)
    )
    if not rayResult then return false end

    -- Check tag on hit surface
    local hitPart = rayResult.Instance
    if not hitPart:HasTag("PlacementZone") then return false end

    -- Check overlap with existing towers
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    overlapParams.FilterDescendantsInstances = {workspace.ActiveTowers}

    local overlapping = workspace:GetPartBoundsInRadius(position, towerRadius, overlapParams)
    return #overlapping == 0
end

function TowerPlacer.place(player: Player, towerName: string, position: Vector3): Model?
    local snapped = TowerPlacer.snapToGrid(position)
    local towerConfig = TowerConfigs[towerName]
    if not towerConfig then return nil end

    if not TowerPlacer.canPlace(snapped, towerConfig.radius) then return nil end

    -- Check currency
    local matchData = MatchDataService.getData(player)
    if not matchData or matchData.currency < towerConfig.cost then return nil end

    matchData.currency -= towerConfig.cost

    local tower = towerConfig.template:Clone()
    tower:PivotTo(CFrame.new(snapped))
    tower:SetAttribute("Owner", player.UserId)
    tower:SetAttribute("Level", 1)
    tower.Parent = workspace.ActiveTowers

    return tower
end

return TowerPlacer
```

### Targeting AI

Towers select targets based on priority mode. The most common modes are First (furthest along path), Last, Strongest (most HP), and Closest (nearest to tower).

```lua
-- ServerStorage/TargetingSystem.lua
local TargetingSystem = {}

export type TargetMode = "First" | "Last" | "Strongest" | "Closest"

function TargetingSystem.findTarget(
    towerPosition: Vector3,
    range: number,
    mode: TargetMode,
    enemies: {EnemyState}
): EnemyState?
    local best: EnemyState? = nil
    local bestScore: number = if mode == "Last" then math.huge else -math.huge

    for _, enemy in enemies do
        if not enemy.model.Parent then continue end

        local enemyPos = enemy.model:GetPivot().Position
        local distance = (enemyPos - towerPosition).Magnitude

        if distance > range then continue end -- out of range

        local score: number

        if mode == "First" then
            -- Highest distanceAlongPath = furthest along, highest priority
            score = enemy.distanceAlongPath
            if score > bestScore then
                bestScore = score
                best = enemy
            end

        elseif mode == "Last" then
            -- Lowest distanceAlongPath
            score = enemy.distanceAlongPath
            if score < bestScore then
                bestScore = score
                best = enemy
            end

        elseif mode == "Strongest" then
            -- Highest current health
            score = enemy.health
            if score > bestScore then
                bestScore = score
                best = enemy
            end

        elseif mode == "Closest" then
            -- Smallest distance to tower
            score = -distance -- negate so "closer = higher score"
            if score > bestScore then
                bestScore = score
                best = enemy
            end
        end
    end

    return best
end

return TargetingSystem
```

### Tower Attack Loop

Each tower runs an attack cycle: find target, fire, wait for cooldown.

```lua
-- ServerStorage/TowerCombat.lua
local TowerCombat = {}

function TowerCombat.startAttackLoop(tower: Model, config: TowerConfig)
    task.spawn(function()
        while tower.Parent do
            local level = tower:GetAttribute("Level") or 1
            local stats = config.levels[level]
            local enemies = EnemyHandler.getActiveEnemies()
            local mode = tower:GetAttribute("TargetMode") or "First"

            local target = TargetingSystem.findTarget(
                tower:GetPivot().Position,
                stats.range,
                mode,
                enemies
            )

            if target then
                -- Rotate tower toward target
                local lookCF = CFrame.lookAt(
                    tower:GetPivot().Position,
                    target.model:GetPivot().Position
                )
                tower:PivotTo(lookCF)

                -- Deal damage
                local killed = EnemyHandler.damageEnemy(target, stats.damage)
                if killed then
                    -- Award currency to tower owner
                    local ownerId = tower:GetAttribute("Owner")
                    awardKillCurrency(ownerId, target)
                end

                -- Fire visual event to clients
                Remotes.TowerFired:FireAllClients(tower, target.model)
            end

            task.wait(stats.cooldown)
        end
    end)
end

return TowerCombat
```

### Wave Spawning with Escalation

Waves are defined in a config table with escalating enemy counts, types, and spawn intervals.

```lua
-- ServerStorage/WaveConfig.lua
local WaveConfig = {}

WaveConfig.Waves = {
    [1]  = { { enemy = "Zombie",     count = 5,  interval = 1.5 } },
    [2]  = { { enemy = "Zombie",     count = 8,  interval = 1.2 } },
    [3]  = { { enemy = "Zombie",     count = 6,  interval = 1.0 },
             { enemy = "FastZombie", count = 3,  interval = 1.0 } },
    [5]  = { { enemy = "BossZombie", count = 1,  interval = 0 } }, -- boss wave
    [10] = { { enemy = "Zombie",     count = 20, interval = 0.5 },
             { enemy = "ArmoredZombie", count = 5, interval = 1.0 } },
}

-- Dynamic scaling for waves beyond the config
function WaveConfig.generateWave(waveNum: number): {{enemy: string, count: number, interval: number}}
    local baseCount = 5 + (waveNum * 2)
    local interval = math.max(0.3, 1.5 - (waveNum * 0.05))

    local spawns = {{ enemy = "Zombie", count = baseCount, interval = interval }}

    if waveNum % 5 == 0 then
        table.insert(spawns, { enemy = "BossZombie", count = 1, interval = 0 })
    end
    if waveNum > 5 then
        table.insert(spawns, { enemy = "FastZombie", count = math.floor(waveNum / 3), interval = interval })
    end

    return spawns
end

return WaveConfig
```

```lua
-- ServerScriptService/WaveManager.server.lua
local function runWave(waveNum: number, waypoints: {Vector3})
    local waveData = WaveConfig.Waves[waveNum] or WaveConfig.generateWave(waveNum)

    local spawnTasks = {}
    for _, group in waveData do
        table.insert(spawnTasks, task.spawn(function()
            for i = 1, group.count do
                EnemyHandler.spawn(group.enemy, waypoints)
                if group.interval > 0 then
                    task.wait(group.interval)
                end
            end
        end))
    end

    -- Wait until all enemies from this wave are dead
    repeat
        task.wait(1)
    until #EnemyHandler.getActiveEnemies() == 0

    return true -- wave complete
end
```

### Tower Upgrade Tree

```lua
local TowerConfigs = {
    Archer = {
        cost = 100,
        radius = 2,
        template = ReplicatedStorage.Towers.Archer,
        levels = {
            [1] = { damage = 10,  range = 20, cooldown = 1.0, upgradeCost = 0 },
            [2] = { damage = 18,  range = 22, cooldown = 0.9, upgradeCost = 150 },
            [3] = { damage = 30,  range = 25, cooldown = 0.7, upgradeCost = 400 },
            [4] = { damage = 50,  range = 28, cooldown = 0.5, upgradeCost = 1000 },
            [5] = { damage = 100, range = 32, cooldown = 0.3, upgradeCost = 2500 },
        },
    },
}
```

## Data Schema

```lua
-- Per-match (not persisted across matches)
export type MatchTowerData = {
    towerName: string,
    position: Vector3,
    level: number,
    targetMode: TargetMode,
    owner: number, -- UserId
}

-- Persistent player data
export type TDPlayerData = {
    currency: number,           -- lifetime earned
    towersUnlocked: {string},   -- tower names available to place
    highestWave: number,
    totalKills: number,
    matchesPlayed: number,
    matchesWon: number,
}
```

## Economy Integration

| Revenue Source | Typical GamePass / Product | Price (Robux) |
|----------------|----------------------------|---------------|
| Exclusive Tower | Premium tower with unique ability | 299-699 |
| 2x Match Currency | Earn double in-match | 199-399 |
| Extra Tower Slot | Place more towers per match | 149-299 |
| Tower Skin Pack | Cosmetic reskin | 49-149 |

## Pitfalls

- **Humanoid overhead at scale**: Each enemy with a Humanoid adds significant CPU cost. For games with 50+ simultaneous enemies, consider non-Humanoid movement (TweenService or manual CFrame Lerp with RunService.Heartbeat). The server moves enemies; clients render them.
- **Targeting N^2 problem**: If every tower scans every enemy every frame, cost is O(towers x enemies). Use spatial partitioning -- group enemies by their current waypoint segment and only check towers whose range overlaps that segment.
- **Wave difficulty spikes**: Waves that suddenly become much harder cause player churn. Escalate gradually and use boss waves as planned difficulty spikes with proportional rewards.
- **Network bandwidth**: Firing `TowerFired` events for every attack to all clients can overwhelm bandwidth. Use `UnreliableRemoteEvent` for cosmetic fire events, or batch multiple fires into a single update per frame.
- **Sell/move tower grief**: In cooperative games, allow players to only sell/move their own towers. Store the `Owner` UserId as an Attribute on the tower model.

## Related

- [[round-system]] -- wave-based round management
- [[lobby-system]] -- pre-match lobby and map voting
- [[matchmaking-queue]] -- grouping players for cooperative matches
- [[leaderboard-pattern]] -- wave-survived leaderboards
- [[DataStoreService]] -- persisting tower unlocks and stats

## Sources

- [An In-Depth Guide to a Tower Defense Game Part 1 - DevForum](https://devforum.roblox.com/t/an-in-depth-guide-to-a-tower-defense-game-part-1/3019857)
- [Open Source Tower Defense - DevForum](https://devforum.roblox.com/t/open-source-tower-defense/3181957)
- [How can I optimize a tower defense targeting system? - DevForum](https://devforum.roblox.com/t/how-can-i-optimize-a-tower-defense-game-targeting-system/905524)
- [Tower Defense Placement System - DevForum](https://devforum.roblox.com/t/tower-defense-placement-system/419003)
- [Tower Defense Enemy Movement - DevForum](https://devforum.roblox.com/t/tower-defense-enemy-movement/1930853)
- [Help on tower defense wave system - DevForum](https://devforum.roblox.com/t/help-on-tower-defense-like-wave-system/1737495)
- [Organizing Tower Defense Wave Data - DevForum](https://devforum.roblox.com/t/organizing-tower-defense-wave-data/3266290)
- [How can I make a tower defense attacking system? - DevForum](https://devforum.roblox.com/t/how-can-i-make-a-tower-defense-attacking-system/1717054)
