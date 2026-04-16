---
title: FPS Weapon System
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/fps-framework-2020.md
  - wiki/raw/community/articles/game-mechanics/raycasting-gun-tutorial.md
  - wiki/raw/community/articles/game-mechanics/fastcast-projectile-system.md
  - wiki/raw/community/articles/game-mechanics/gun-sway-recoil-systems.md
  - wiki/raw/community/articles/game-mechanics/ads-aim-down-sights.md
  - wiki/raw/community/articles/game-mechanics/weapon-switching-system.md
related:
  - "[[first-person-framework]]"
  - "[[viewmodel-system]]"
  - "[[combat-system]]"
  - "[[state-machine-pattern]]"
  - "[[inventory-pattern]]"
tags: [pattern, fps, weapon, gun, hitscan, raycast, fastcast, projectile, recoil, spread, reload, ammo, fire-rate]
---

# FPS Weapon System

> The full lifecycle of an FPS weapon: configuration, equip/unequip, fire (hitscan or projectile), server validation, damage application, reload state machine, ammo tracking, recoil, spread, and headshot multipliers.

## Summary

An FPS weapon system connects the [[viewmodel-system]] visuals to server-authoritative combat logic. The client handles input detection (fire, reload, ADS, switch) and immediate visual feedback (muzzle flash, recoil shake, casing ejection). The server validates every action against authoritative state (ammo count, cooldown timers, player alive status) before performing hit detection and applying damage.

Two hit detection strategies dominate: **hitscan** (instant `workspace:Raycast`) for weapons like rifles and pistols, and **projectile** (FastCast or custom Heartbeat-stepped raycasts) for weapons with visible bullet travel like snipers, rockets, or bows. The choice is per-weapon configuration, not architectural.

## Implementation

### Weapon Configuration

Every weapon is defined by a data table stored in a shared ModuleScript:

```lua
-- ReplicatedStorage/Shared/Config/WeaponConfigs.lua
local WeaponConfigs = {}

export type WeaponConfig = {
    -- Identity
    name: string,
    weaponType: "hitscan" | "projectile",

    -- Damage
    baseDamage: number,
    headshotMultiplier: number,    -- typically 1.5 to 2.0
    limbMultiplier: number,        -- typically 0.7
    range: number,                 -- studs (hitscan max distance)

    -- Fire
    fireMode: "auto" | "semi" | "burst",
    rpm: number,                   -- rounds per minute
    burstCount: number?,           -- for burst mode

    -- Ammo
    magSize: number,
    reserveMax: number,
    reloadTime: number,            -- seconds

    -- Spread (cone angle in degrees)
    hipSpreadMin: number,          -- base spread at rest
    hipSpreadMax: number,          -- spread after sustained fire
    adsSpreadMin: number,
    adsSpreadMax: number,
    spreadIncreasePerShot: number,
    spreadRecoveryRate: number,    -- degrees per second

    -- Recoil (camera offset per shot, degrees)
    recoilVertical: NumberRange,   -- min-max vertical kick
    recoilHorizontal: NumberRange, -- min-max horizontal kick
    recoilRecoverySpeed: number,   -- degrees per second

    -- Projectile (only for weaponType == "projectile")
    bulletSpeed: number?,          -- studs per second
    bulletDrop: number?,           -- gravity multiplier
    bulletModel: string?,          -- ReplicatedStorage path

    -- Viewmodel offsets (see viewmodel-system)
    hipOffset: CFrame,
    aimOffset: CFrame,
    jointOffset: CFrame,

    -- Animations
    idleAnim: Animation,
    fireAnim: Animation,
    reloadAnim: Animation,
    equipAnim: Animation,
}

WeaponConfigs.M4A1 = {
    name = "M4A1",
    weaponType = "hitscan",
    baseDamage = 28,
    headshotMultiplier = 1.8,
    limbMultiplier = 0.75,
    range = 300,
    fireMode = "auto",
    rpm = 700,
    magSize = 30,
    reserveMax = 120,
    reloadTime = 2.2,
    hipSpreadMin = 1.5,
    hipSpreadMax = 6.0,
    adsSpreadMin = 0.3,
    adsSpreadMax = 2.5,
    spreadIncreasePerShot = 0.4,
    spreadRecoveryRate = 8,
    recoilVertical = NumberRange.new(0.8, 1.5),
    recoilHorizontal = NumberRange.new(-0.3, 0.3),
    recoilRecoverySpeed = 5,
    -- ... offsets, anims
} :: WeaponConfig

return WeaponConfigs
```

### Weapon State Machine

Each weapon cycles through a state machine managed on the server:

```
         equip()           fire()
  IDLE ---------> READY ----------> FIRING
   ^                |                  |
   |                | reload()         | mag empty / release trigger
   |                v                  v
   |             RELOADING <-------- COOLDOWN
   |                |                  |
   |                | timer done       | rpm timer done
   |                v                  v
   +------------- READY <------------ READY
         unequip()
         UNEQUIPPING -> IDLE
```

```lua
-- ServerStorage/Weapons/WeaponState.lua
export type WeaponState = {
    currentAmmo: number,
    reserveAmmo: number,
    state: "idle" | "equipping" | "ready" | "firing" | "cooldown" | "reloading" | "unequipping",
    lastFireTime: number,
    currentSpread: number,
    equippedWeaponName: string?,
}
```

### Equip / Unequip Flow

```lua
-- Server: handle equip request
Remotes.EquipWeapon.OnServerEvent:Connect(function(player: Player, weaponName: string)
    if typeof(weaponName) ~= "string" then return end
    local config = WeaponConfigs[weaponName]
    if not config then return end

    local state = playerWeaponStates[player]
    if state.state ~= "idle" and state.state ~= "ready" then return end

    -- Unequip current weapon first
    if state.equippedWeaponName then
        state.state = "unequipping"
        task.wait(0.3) -- unequip animation duration
    end

    -- Equip new weapon
    state.equippedWeaponName = weaponName
    state.currentAmmo = config.magSize
    state.reserveAmmo = config.reserveMax
    state.state = "equipping"

    -- Notify client to play equip animation
    Remotes.WeaponEquipped:FireClient(player, weaponName)

    task.wait(0.5) -- equip animation duration
    state.state = "ready"
end)
```

### Fire: Hitscan Path

```lua
-- Server: handle fire request (hitscan)
local function fireHitscan(player: Player, origin: Vector3, direction: Vector3)
    local state = playerWeaponStates[player]
    local config = WeaponConfigs[state.equippedWeaponName]

    -- Validation
    if state.state ~= "ready" and state.state ~= "firing" then return end
    if state.currentAmmo <= 0 then return end

    local now = tick()
    local fireCooldown = 60 / config.rpm
    if now - state.lastFireTime < fireCooldown * 0.9 then return end -- 10% tolerance

    -- Validate origin is near player's head
    local head = player.Character and player.Character:FindFirstChild("Head")
    if not head then return end
    if (origin - head.Position).Magnitude > 5 then return end

    -- Apply server-side spread
    local spread = state.currentSpread
    local spreadRad = math.rad(spread)
    local randomAngle = math.random() * math.pi * 2
    local randomSpread = math.random() * spreadRad
    local spreadOffset = CFrame.Angles(
        math.cos(randomAngle) * randomSpread,
        math.sin(randomAngle) * randomSpread,
        0
    )
    local finalDirection = (CFrame.new(Vector3.zero, direction) * spreadOffset).LookVector

    -- Raycast
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { player.Character }

    local result = workspace:Raycast(origin, finalDirection * config.range, params)

    -- Update state
    state.currentAmmo -= 1
    state.lastFireTime = now
    state.currentSpread = math.min(
        config.hipSpreadMax,
        state.currentSpread + config.spreadIncreasePerShot
    )
    state.state = "cooldown"

    -- Schedule cooldown end
    task.delay(fireCooldown, function()
        if state.state == "cooldown" then
            state.state = "ready"
        end
    end)

    -- Apply damage
    if result then
        local hitPart = result.Instance
        local hitChar = hitPart.Parent
        local humanoid = hitChar and hitChar:FindFirstChild("Humanoid")
        if not humanoid then
            hitChar = hitPart.Parent and hitPart.Parent.Parent
            humanoid = hitChar and hitChar:FindFirstChild("Humanoid")
        end

        if humanoid and humanoid.Health > 0 then
            local damage = config.baseDamage
            -- Headshot detection
            if hitPart.Name == "Head" then
                damage *= config.headshotMultiplier
            elseif hitPart.Name:match("Hand") or hitPart.Name:match("Foot") then
                damage *= config.limbMultiplier
            end
            humanoid:TakeDamage(damage)
        end
    end

    -- Replicate fire effect to other players
    local intersection = result and result.Position or origin + finalDirection * config.range
    Remotes.WeaponFired:FireAllClients(player, origin, intersection)
end
```

### Fire: Projectile Path (FastCast)

```lua
-- Server: handle fire request (projectile)
local FastCast = require(game.ServerStorage.Libraries.FastCast)
local caster = FastCast.new()
caster.Gravity = config.bulletDrop or 0

local function fireProjectile(player: Player, origin: Vector3, direction: Vector3)
    -- Same validation as hitscan...

    local finalDirection = applySpread(direction, state.currentSpread)
    caster:Fire(origin, finalDirection, config.bulletSpeed)

    state.currentAmmo -= 1
    state.lastFireTime = tick()
end

-- FastCast hit callback
caster.RayHit:Connect(function(hitPart, hitPoint, normal, material)
    if not hitPart then return end
    local humanoid = hitPart.Parent:FindFirstChild("Humanoid")
        or hitPart.Parent.Parent:FindFirstChild("Humanoid")
    if humanoid then
        local damage = config.baseDamage
        if hitPart.Name == "Head" then
            damage *= config.headshotMultiplier
        end
        humanoid:TakeDamage(damage)
    end
end)

-- FastCast visual update (client-side, via replicated event)
caster.LengthChanged:Connect(function(origin, segStart, direction, length)
    -- Update bullet tracer part position
    bulletPart.CFrame = CFrame.new(segStart, segStart + direction)
        * CFrame.new(0, 0, -length / 2)
    bulletPart.Size = Vector3.new(0.1, 0.1, length)
end)
```

### Reload State Machine

```lua
-- Server: handle reload request
Remotes.Reload.OnServerEvent:Connect(function(player: Player)
    local state = playerWeaponStates[player]
    local config = WeaponConfigs[state.equippedWeaponName]
    if not config then return end

    if state.state ~= "ready" then return end
    if state.currentAmmo >= config.magSize then return end
    if state.reserveAmmo <= 0 then return end

    state.state = "reloading"
    Remotes.ReloadStarted:FireClient(player)

    task.delay(config.reloadTime, function()
        if state.state ~= "reloading" then return end -- cancelled

        local needed = config.magSize - state.currentAmmo
        local available = math.min(needed, state.reserveAmmo)
        state.currentAmmo += available
        state.reserveAmmo -= available
        state.state = "ready"

        Remotes.ReloadFinished:FireClient(player, state.currentAmmo, state.reserveAmmo)
    end)
end)
```

### Client-Side Recoil

Recoil is a visual camera offset applied per shot, with a recovery spring pulling the camera back:

```lua
-- Client: ViewmodelController
local recoilSpring = Spring.new(Vector3.zero)
recoilSpring.Speed = 15
recoilSpring.Damping = 0.7

local function applyRecoil(config: WeaponConfig)
    local vertKick = math.random()
        * (config.recoilVertical.Max - config.recoilVertical.Min)
        + config.recoilVertical.Min
    local horizKick = math.random()
        * (config.recoilHorizontal.Max - config.recoilHorizontal.Min)
        + config.recoilHorizontal.Min

    recoilSpring:Impulse(Vector3.new(
        math.rad(-vertKick),   -- negative = kick up
        math.rad(horizKick),
        0
    ))
end

-- In RenderStepped:
local recoilAngles = recoilSpring:Update(dt)
camera.CFrame = camera.CFrame * CFrame.Angles(recoilAngles.X, recoilAngles.Y, recoilAngles.Z)
```

### Spread Cone

Spread defines a cone within which the bullet direction is randomized:

```lua
local function applySpread(direction: Vector3, spreadDegrees: number): Vector3
    local spreadRad = math.rad(spreadDegrees)
    local randomAngle = math.random() * math.pi * 2
    local randomRadius = math.random() * spreadRad
    local offset = CFrame.Angles(
        math.cos(randomAngle) * randomRadius,
        math.sin(randomAngle) * randomRadius,
        0
    )
    return (CFrame.new(Vector3.zero, direction) * offset).LookVector
end
```

Spread increases per shot and recovers over time:

```lua
-- Each frame (server or client for prediction):
state.currentSpread = math.max(
    config.hipSpreadMin,
    state.currentSpread - config.spreadRecoveryRate * dt
)
```

### Weapon Switching

```lua
-- Client: keybind-driven weapon switching
local equipped = { primary = nil, secondary = nil }
local activeSlot = nil

CAS:BindAction("Primary", function(_, state)
    if state == Enum.UserInputState.Begin and activeSlot ~= "primary" then
        activeSlot = "primary"
        Remotes.EquipWeapon:FireServer(equipped.primary)
    end
end, false, Enum.KeyCode.One)

CAS:BindAction("Secondary", function(_, state)
    if state == Enum.UserInputState.Begin and activeSlot ~= "secondary" then
        activeSlot = "secondary"
        Remotes.EquipWeapon:FireServer(equipped.secondary)
    end
end, false, Enum.KeyCode.Two)
```

## Server vs Client Split

| Component | Side | Notes |
|---|---|---|
| Fire intent (origin, direction) | Client -> Server | Client provides aim data; server validates |
| Ammo count | Server | Authoritative; client shows predicted HUD |
| Cooldown / fire rate | Server | Prevents rapid-fire exploits |
| Raycast / FastCast hit detection | Server | Server-authoritative damage |
| Damage application | Server | `Humanoid:TakeDamage()` on server only |
| Recoil visual | Client | Camera CFrame offset via spring |
| Muzzle flash, casing ejection | Client | Cosmetic particles |
| Spread calculation | Server (authoritative), Client (prediction) | Server applies final spread; client predicts for crosshair |
| Weapon equip state | Server | Prevents equip exploits |
| Reload timer | Server | Cannot be skipped by client |

## Performance Notes

- **Hitscan is cheaper than projectile**: One `workspace:Raycast` per shot vs. a Heartbeat-stepped loop per active bullet. Use hitscan for automatic weapons with high fire rates.
- **FastCast PartCache**: Use PartCache to recycle bullet parts instead of creating/destroying each shot. Pre-allocate 50-100 bullet parts.
- **RaycastParams reuse**: Create one RaycastParams per player and update `FilterDescendantsInstances` only when the character changes. Do not create new RaycastParams per shot.
- **Replicate fire to others**: Use `FireAllClients` (not per-player) for the visual fire event. Each client draws its own tracer/muzzle flash from the replicated data.

## Pitfalls

1. **Client-authoritative damage** -- Never let the client tell the server "I hit player X for Y damage." The client sends origin + direction; the server performs the raycast.
2. **Not clamping origin** -- Validate that the fire origin is within a reasonable distance of the player's head position. A spoofed origin allows shooting through walls.
3. **Reload cancellation** -- If the player dies or switches weapons during reload, the delayed `task.delay` callback must check state before applying ammo.
4. **Ammo desync** -- The client predicts ammo for HUD display, but the server is authoritative. Sync ammo on reload completion, weapon switch, and periodically.
5. **Spread stacking on server** -- If the server and client both track spread, they can desync. Let the server be authoritative; send spread info to the client for crosshair display.

## Related

- [[first-person-framework]] -- overall FP architecture
- [[viewmodel-system]] -- visual weapon rendering
- [[combat-system]] -- server-authoritative combat patterns
- [[state-machine-pattern]] -- state machines for weapon states
- [[inventory-pattern]] -- inventory management for weapons

## Sources

- [Writing an FPS Framework (2020, DevForum)](https://devforum.roblox.com/t/writing-an-fps-framework-2020/503318)
- [How to Make a Raycasting Gun (DevForum)](https://devforum.roblox.com/t/how-to-make-a-raycasting-gun/723716)
- [FastCast: Ranged Weapons Module (EtiTheSpirit, DevForum)](https://devforum.roblox.com/t/making-a-combat-game-with-ranged-weapons-fastcast-may-be-the-module-for-you/133474)
- [FastCast API Documentation](https://etithespir.it/FastCastAPIDocs/)
- [Gun Sway and Recoil Discussion (DevForum)](https://devforum.roblox.com/t/how-does-gun-sway-work-how-would-recoil-work-any-tips-ideas-or-suggestions/641434)
- [Recoil Using Springs (DevForum)](https://devforum.roblox.com/t/recoil-using-springs/1495471)
- [FPS Weapon Switching System (DevForum)](https://devforum.roblox.com/t/fps-weapon-switching-system/3225625)
- [ADS Implementations (DevForum)](https://devforum.roblox.com/t/how-to-make-a-weapon-ads-aim-down-sights-without-a-viewmodel/2815102)
