---
title: Projectile System
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/fastcast-projectiles.md
  - wiki/raw/community/articles/game-mechanics/server-authority-combat.md
  - wiki/raw/community/articles/game-mechanics/spatial-queries-overlap.md
related:
  - "[[combat-system]]"
  - "[[damage-formulas]]"
  - "[[ability-system]]"
tags: [pattern, projectile, hitscan, fastcast, bullet-drop, physics, pooling, server-authority]
---

# Projectile System

> Handles ranged weapon projectiles from muzzle to impact using hitscan raycasts, physics-based simulation (FastCast pattern), or Roblox Server Authority with bullet drop, penetration, server reconciliation, and object pooling.

## Summary

Projectile systems fall into two categories: **hitscan** (instant raycast from muzzle to target, no travel time) and **physics-based** (simulated projectile with velocity, gravity, and travel time). Hitscan is simpler and cheaper; physics-based creates more realistic combat with bullet drop and leading targets.

Both approaches must be **server-authoritative**: the server determines what was hit. The client sends shoot intent (origin, direction, timestamp); the server validates and runs its own hit detection. Visual projectiles on the client are cosmetic only -- they never determine hits.

The FastCast pattern (segmented raycasting) is the Roblox community standard for physics-based projectiles. It splits a projectile's path into small raycast segments each frame, applying gravity between segments, producing realistic arcs without using Roblox physics (which are unreliable for fast, small objects).

## Implementation

### Hitscan (Instant Raycast)

```lua
-- ServerStorage/Combat/HitscanWeapon.lua
local DamageFormulas = require(game.ServerStorage.Combat.DamageFormulas)
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

local HitscanWeapon = {}

export type HitscanConfig = {
    maxRange: number,         -- studs
    baseDamage: number,
    headshotMultiplier: number,
    falloffMinRange: number,  -- full damage within this range
    falloffMaxRange: number,  -- minimum damage beyond this range
    falloffMinMult: number,   -- minimum damage multiplier at max range
    penetrationCount: number, -- 0 = no penetration, 1+ = pierce through N targets
    fireRate: number,         -- shots per second
    spreadAngle: number,      -- degrees of spread (0 = perfect accuracy)
}

--[[
    Server-side hitscan shot.
    Client sends origin + direction; server validates and raycasts.
]]
function HitscanWeapon.fire(
    player: Player,
    origin: Vector3,
    direction: Vector3,
    config: HitscanConfig
): ()
    local character = player.Character
    if not character then return end

    -- Validate origin is near the player's actual position
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local distanceFromPlayer = (origin - rootPart.Position).Magnitude
    if distanceFromPlayer > 10 then
        -- Origin too far from player — possible exploit
        warn("Rejected shot: origin too far from player", player.Name)
        return
    end

    -- Normalize direction and apply spread
    direction = direction.Unit
    if config.spreadAngle > 0 then
        local spread = math.rad(config.spreadAngle)
        local rx = (math.random() - 0.5) * spread
        local ry = (math.random() - 0.5) * spread
        direction = (CFrame.new(Vector3.zero, direction)
            * CFrame.Angles(rx, ry, 0)).LookVector
    end

    -- Raycast setup
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local remaining = config.penetrationCount + 1  -- +1 for initial hit
    local currentOrigin = origin
    local hitResults: {{target: Model, position: Vector3, distance: number, isHeadshot: boolean}} = {}

    -- Fire ray (with penetration)
    while remaining > 0 do
        local result = workspace:Raycast(
            currentOrigin,
            direction * config.maxRange,
            raycastParams
        )

        if not result then break end

        local hitPart = result.Instance
        local hitChar = hitPart and hitPart.Parent
        local humanoid = hitChar and hitChar:FindFirstChildOfClass("Humanoid")

        if humanoid and humanoid.Health > 0 then
            local distance = (result.Position - origin).Magnitude
            local isHeadshot = hitPart.Name == "Head"

            table.insert(hitResults, {
                target = hitChar,
                position = result.Position,
                distance = distance,
                isHeadshot = isHeadshot,
            })

            -- Add hit character to filter for penetration
            raycastParams.FilterDescendantsInstances = {
                character,
                unpack(
                    (function()
                        local list = {}
                        for _, h in hitResults do
                            table.insert(list, h.target)
                        end
                        return list
                    end)()
                )
            }

            remaining -= 1
            currentOrigin = result.Position + direction * 0.1  -- step past hit
        else
            -- Hit non-character (wall, terrain) — stop
            break
        end
    end

    -- Apply damage to each hit target
    for _, hit in hitResults do
        local targetPlayer = game.Players:GetPlayerFromCharacter(hit.target)
        local targetHumanoid = hit.target:FindFirstChildOfClass("Humanoid")
        if not targetHumanoid then continue end

        -- Distance falloff
        local falloffMult = DamageFormulas.distanceFalloff(
            hit.distance,
            config.falloffMinRange,
            config.falloffMaxRange,
            config.falloffMinMult
        )

        -- Headshot multiplier
        local headshotMult = if hit.isHeadshot then config.headshotMultiplier else 1.0

        local result = DamageFormulas.calculate({
            baseDamage = config.baseDamage * falloffMult * headshotMult,
            attackerLevel = player:GetAttribute("Level") or 1,
            defenderDefense = (targetPlayer and targetPlayer:GetAttribute("Defense")) or 0,
            damageType = "physical",
        })

        targetHumanoid:TakeDamage(result.finalDamage)

        -- Notify target
        if targetPlayer then
            Remotes.HitFeedback:FireClient(targetPlayer, result.finalDamage)
        end
    end

    -- Visual feedback: tell all clients to render the tracer
    Remotes.ShotFired:FireAllClients(player, origin, direction, config.maxRange)
end

return HitscanWeapon
```

### Physics-Based Projectile (FastCast Pattern)

```lua
-- ServerStorage/Combat/ProjectileSimulator.lua

--[[
    FastCast-style segmented raycast projectile.
    Each frame, advance the projectile by velocity * dt, apply gravity,
    and raycast the segment to check for collisions.

    This runs on the server for authoritative hit detection.
    Clients run a parallel cosmetic simulation for visuals.
]]

local RunService = game:GetService("RunService")
local DamageFormulas = require(game.ServerStorage.Combat.DamageFormulas)
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

export type ProjectileConfig = {
    speed: number,            -- studs per second
    gravity: number,          -- studs/s^2 (workspace.Gravity = 196.2)
    maxDistance: number,       -- max travel distance before despawn
    maxLifetime: number,      -- max seconds alive
    baseDamage: number,
    damageType: string,
    aoeRadius: number?,       -- nil = direct hit only
    penetrationCount: number, -- 0 = stop on first hit
    bounciness: number?,      -- 0 = no bounce, 0-1 = bounce factor
}

export type ActiveProjectile = {
    owner: Player,
    config: ProjectileConfig,
    position: Vector3,
    velocity: Vector3,
    distanceTraveled: number,
    startTime: number,
    hitTargets: {[Model]: boolean},
    alive: boolean,
}

local activeProjectiles: {ActiveProjectile} = {}

local ProjectileSimulator = {}

function ProjectileSimulator.spawn(
    owner: Player,
    origin: Vector3,
    direction: Vector3,
    config: ProjectileConfig
)
    local projectile: ActiveProjectile = {
        owner = owner,
        config = config,
        position = origin,
        velocity = direction.Unit * config.speed,
        distanceTraveled = 0,
        startTime = os.clock(),
        hitTargets = {},
        alive = true,
    }

    table.insert(activeProjectiles, projectile)

    -- Notify clients to spawn cosmetic projectile
    Remotes.ProjectileSpawned:FireAllClients(
        owner,
        origin,
        direction.Unit,
        config.speed,
        config.gravity
    )
end

--[[
    Called every Heartbeat. Simulates all active projectiles.
]]
function ProjectileSimulator.update(dt: number)
    local ownerCharacter: {[Player]: Model} = {}

    for i = #activeProjectiles, 1, -1 do
        local proj = activeProjectiles[i]
        if not proj.alive then
            table.remove(activeProjectiles, i)
            continue
        end

        -- Apply gravity
        proj.velocity = proj.velocity + Vector3.new(0, -proj.config.gravity * dt, 0)

        -- Calculate segment
        local segmentVector = proj.velocity * dt
        local segmentLength = segmentVector.Magnitude
        proj.distanceTraveled += segmentLength

        -- Lifetime / distance checks
        if proj.distanceTraveled > proj.config.maxDistance then
            proj.alive = false
            table.remove(activeProjectiles, i)
            continue
        end

        if os.clock() - proj.startTime > proj.config.maxLifetime then
            proj.alive = false
            table.remove(activeProjectiles, i)
            continue
        end

        -- Raycast the segment
        local character = ownerCharacter[proj.owner]
            or proj.owner.Character
        ownerCharacter[proj.owner] = character

        local raycastParams = RaycastParams.new()
        local filterList: {Instance} = {}
        if character then table.insert(filterList, character) end
        for model, _ in proj.hitTargets do
            table.insert(filterList, model)
        end
        raycastParams.FilterDescendantsInstances = filterList
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local result = workspace:Raycast(
            proj.position,
            segmentVector,
            raycastParams
        )

        if result then
            local hitPart = result.Instance
            local hitChar = hitPart and hitPart.Parent
            local humanoid = hitChar and hitChar:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 and not proj.hitTargets[hitChar] then
                -- Hit a character
                proj.hitTargets[hitChar] = true

                -- AoE or direct hit damage
                if proj.config.aoeRadius then
                    ProjectileSimulator.applyAoE(
                        proj, result.Position
                    )
                else
                    ProjectileSimulator.applyDirectHit(
                        proj, hitChar, result.Position
                    )
                end

                -- Check penetration
                if proj.config.penetrationCount <= 0 then
                    proj.alive = false
                else
                    proj.config.penetrationCount -= 1
                end
            else
                -- Hit terrain/wall
                if proj.config.bounciness and proj.config.bounciness > 0 then
                    -- Bounce
                    local normal = result.Normal
                    proj.velocity = (proj.velocity - 2 * proj.velocity:Dot(normal) * normal)
                        * proj.config.bounciness
                    proj.position = result.Position + normal * 0.1
                elseif proj.config.aoeRadius then
                    -- Explode on wall impact
                    ProjectileSimulator.applyAoE(proj, result.Position)
                    proj.alive = false
                else
                    proj.alive = false
                end
            end
        else
            -- No hit: advance position
            proj.position = proj.position + segmentVector
        end

        if not proj.alive then
            table.remove(activeProjectiles, i)
        end
    end
end

function ProjectileSimulator.applyDirectHit(
    proj: ActiveProjectile,
    targetChar: Model,
    hitPosition: Vector3
)
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return end

    local distance = (hitPosition - proj.position).Magnitude + proj.distanceTraveled
    local falloff = DamageFormulas.distanceFalloff(distance, 30, proj.config.maxDistance, 0.5)

    local dmgResult = DamageFormulas.calculate({
        baseDamage = proj.config.baseDamage * falloff,
        attackerLevel = proj.owner:GetAttribute("Level") or 1,
        damageType = proj.config.damageType,
    })

    targetHumanoid:TakeDamage(dmgResult.finalDamage)

    local targetPlayer = game.Players:GetPlayerFromCharacter(targetChar)
    if targetPlayer then
        Remotes.HitFeedback:FireClient(targetPlayer, dmgResult.finalDamage)
    end
end

function ProjectileSimulator.applyAoE(
    proj: ActiveProjectile,
    center: Vector3
)
    local HitDetection = require(game.ServerStorage.Combat.HitDetection)
    local character = proj.owner.Character

    local targets = HitDetection.radialAoE(
        center,
        proj.config.aoeRadius,
        {character}
    )

    for _, targetChar in targets do
        if proj.hitTargets[targetChar] then continue end
        proj.hitTargets[targetChar] = true

        ProjectileSimulator.applyDirectHit(proj, targetChar, center)
    end

    -- Notify explosion VFX
    Remotes.ProjectileExploded:FireAllClients(center, proj.config.aoeRadius)
end

function ProjectileSimulator.init()
    RunService.Heartbeat:Connect(function(dt)
        ProjectileSimulator.update(dt)
    end)
end

return ProjectileSimulator
```

### Object Pool for Cosmetic Projectiles (Client)

```lua
-- StarterPlayer/StarterPlayerScripts/ProjectilePool.client.lua

--[[
    Client-side object pool for cosmetic projectile visuals.
    Avoids Instance.new() per shot, which causes GC spikes.
]]

local POOL_SIZE = 50
local TEMPLATE_NAME = "BulletTemplate"

local template = game.ReplicatedStorage.Assets:FindFirstChild(TEMPLATE_NAME)

local ProjectilePool = {}
ProjectilePool.__index = ProjectilePool

local pool: {BasePart} = {}
local activeCount = 0

function ProjectilePool.init()
    for i = 1, POOL_SIZE do
        local bullet = template:Clone()
        bullet.Anchored = true
        bullet.CanCollide = false
        bullet.CanQuery = false
        bullet.CanTouch = false
        bullet.Transparency = 1  -- hidden until acquired
        bullet.Parent = workspace.ProjectileContainer
        pool[i] = bullet
    end
end

--[[
    Acquires a bullet from the pool. Returns nil if pool is exhausted.
]]
function ProjectilePool.acquire(): BasePart?
    if activeCount >= POOL_SIZE then
        return nil  -- pool exhausted; skip visual rather than lag
    end

    activeCount += 1
    local bullet = pool[activeCount]
    bullet.Transparency = 0
    return bullet
end

--[[
    Returns a bullet to the pool.
]]
function ProjectilePool.release(bullet: BasePart)
    bullet.Transparency = 1
    bullet.Position = Vector3.new(0, -1000, 0)  -- move off-screen

    -- Swap with last active
    local idx = table.find(pool, bullet)
    if idx and idx <= activeCount then
        pool[idx], pool[activeCount] = pool[activeCount], pool[idx]
        activeCount -= 1
    end
end

return ProjectilePool
```

### Server Reconciliation Pattern

```lua
-- When the client sends a shot request with a timestamp:
Remotes.ShootRequest.OnServerEvent:Connect(function(player, origin, direction, clientTimestamp)
    -- Type validation
    if typeof(origin) ~= "Vector3" then return end
    if typeof(direction) ~= "Vector3" then return end
    if typeof(clientTimestamp) ~= "number" then return end

    -- Validate origin is near the player
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if (origin - rootPart.Position).Magnitude > 10 then return end

    -- Validate direction is unit-ish (prevent zero or huge vectors)
    if direction.Magnitude < 0.9 or direction.Magnitude > 1.1 then return end

    -- Rate limiting
    local lastShot = player:GetAttribute("_lastShotTime") or 0
    local now = os.clock()
    local minInterval = 1 / weaponConfig.fireRate
    if now - lastShot < minInterval * 0.9 then return end  -- 10% tolerance
    player:SetAttribute("_lastShotTime", now)

    -- Fire the weapon
    HitscanWeapon.fire(player, origin, direction.Unit, weaponConfig)
end)
```

## Hitscan vs Physics-Based Comparison

| Aspect | Hitscan | Physics-Based (FastCast) |
|--------|---------|--------------------------|
| Travel time | Instant | Simulated (bullet travel) |
| Bullet drop | None | Configurable gravity |
| Leading targets | Not needed | Required at range |
| Server cost | Single raycast | Raycast per frame per projectile |
| Client visuals | Tracer line | Moving bullet part |
| Accuracy at range | Perfect | Requires aim adjustment |
| Dodge potential | Cannot dodge | Can dodge slow projectiles |
| Best for | Rifles, lasers, rail guns | Bows, rockets, grenades |

## Variants

| Variant | Description | Use Case |
|---------|-------------|----------|
| **Pure hitscan** | Single raycast, instant hit | Rifles, pistols, laser weapons |
| **Thick hitscan** | `workspace:Blockcast` or `Spherecast` | Shotgun spread, energy beams |
| **FastCast** | Segmented raycast with gravity | Arrows, thrown objects |
| **Bouncing projectile** | Reflects off surfaces | Grenades, trick shots |
| **Penetrating** | Passes through N targets | Sniper rifles, rail guns |
| **Seeking projectile** | Curves toward target each frame | Homing missiles, magic bolts |
| **AoE on impact** | Explodes at hit point | Rockets, bombs, fireballs |

## Pitfalls

- **Client-authoritative hit detection.** The client cosmetic simulation must not determine hits. Exploiters can warp projectile trajectories or report false hits. The server simulates its own projectile independently.
- **Missing origin validation.** If the server does not verify the claimed shot origin is near the player's actual position, exploiters can shoot from arbitrary locations (e.g., behind walls).
- **No rate limiting.** Without server-side fire rate enforcement, auto-fire macros can spam shots at inhuman speed. Enforce `minInterval = 1 / fireRate` with a small tolerance for network jitter.
- **Physics-based collision.** Using actual Roblox BasePart physics for bullets is unreliable -- small fast parts tunnel through walls, physics simulation is expensive, and replication adds latency. Use raycasts (FastCast pattern) instead.
- **Object pool exhaustion.** If the pool runs out of cosmetic bullets, either skip the visual (acceptable) or expand the pool. Never fall back to `Instance.new()` in a hot path -- it causes GC spikes.
- **Gravity mismatch.** If client and server use different gravity values or frame rates, cosmetic projectiles will visually diverge from server-authoritative paths. Sync the gravity constant from a shared config.
- **Large dt spikes.** If `dt` is large (lag spike), a single segment can be very long, tunneling through objects. Cap segment length: `segmentLength = math.min(velocity * dt, MAX_SEGMENT_LENGTH)`.

## Related

- [[combat-system]] -- projectiles are one weapon type in the combat framework
- [[damage-formulas]] -- projectile damage goes through the damage pipeline
- [[ability-system]] -- projectile-type abilities (fireball, ice lance) use this system

## Sources

- [FastCast & FastCast2](wiki/raw/community/articles/game-mechanics/fastcast-projectiles.md)
- [Server Authority](wiki/raw/community/articles/game-mechanics/server-authority-combat.md)
- [Spatial Queries and OverlapParams](wiki/raw/community/articles/game-mechanics/spatial-queries-overlap.md)
