---
title: simulator-mechanics
type: pattern
category: patterns
subcategory: genre-mechanics
owner: game-designer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/simulator-clicker-core-loop.md
  - wiki/raw/community/articles/game-mechanics/simulator-rebirth-math.md
  - wiki/raw/community/articles/game-mechanics/multiplier-prestige-systems.md
  - wiki/raw/community/articles/game-mechanics/idle-game-mechanics.md
related:
  - "[[pet-system]]"
  - "[[tycoon-mechanics]]"
  - "[[daily-rewards]]"
  - "[[inventory-pattern]]"
  - "[[DataStoreService]]"
tags: [pattern, simulator, clicker, rebirth, prestige, multiplier, genre]
---

# Simulator Mechanics

> The Roblox simulator formula: click/collect a resource, spend it on upgrades and multipliers, rebirth for permanent bonuses, repeat at a higher power level. The dominant genre on the platform.

## Summary

Simulators are the most popular genre on Roblox, with titles like Pet Simulator 99, Bee Swarm Simulator, and Strongman Simulator routinely sitting in the top charts. The genre succeeds because it maps perfectly to Roblox's young audience: immediate feedback (click and see numbers go up), clear progression (bigger numbers, rarer pets), and social proof (visible wealth and rare items). The core loop is deceptively simple but the layered economy of multipliers, rebirths, and prestige tiers creates weeks of progression depth.

## Core Loop

```
Click/Collect Resource
       |
       v
Fill Backpack / Accumulate
       |
       v
Sell at Designated Area --> Currency
       |
       v
Buy Upgrades (click power, backpack size, auto-collect)
       |
       v
Hit Currency Threshold --> REBIRTH
       |
       v
Reset Currency + Upgrades, Gain Permanent Multiplier
       |
       v
Repeat at Higher Power Level
       |
       v
Hit Rebirth Threshold --> PRESTIGE / SUPER-REBIRTH
       |
       v
(Deeper prestige layers: Majesty, Ascension, Transcendence, etc.)
```

The loop is fractal: each prestige layer resets the layer below it and grants a permanent bonus to the layer above it.

## Implementation

### Backpack / Collection System

The backpack is a capacity-limited container. Players click or walk over collectibles to fill it, then sell at a designated NPC or zone.

```lua
-- ReplicatedStorage/Shared/Config/SimulatorConfig.lua
local SimulatorConfig = {}

SimulatorConfig.DEFAULT_BACKPACK_SIZE = 100
SimulatorConfig.DEFAULT_CLICK_POWER = 1
SimulatorConfig.SELL_ZONE_TAG = "SellZone"

SimulatorConfig.Upgrades = {
    BackpackSize = {
        [1] = { cost = 500,   value = 200 },
        [2] = { cost = 2500,  value = 500 },
        [3] = { cost = 10000, value = 1000 },
    },
    ClickPower = {
        [1] = { cost = 300,   value = 2 },
        [2] = { cost = 1500,  value = 5 },
        [3] = { cost = 8000,  value = 10 },
    },
}

return SimulatorConfig
```

### Click Handler (Server-Authoritative)

```lua
-- ServerScriptService/ClickHandler.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config.SimulatorConfig)

-- Rate limit: max 20 clicks per second per player
local CLICK_COOLDOWN = 0.05
local lastClickTime: {[Player]: number} = {}

Remotes.Click.OnServerEvent:Connect(function(player: Player)
    local now = os.clock()
    if lastClickTime[player] and (now - lastClickTime[player]) < CLICK_COOLDOWN then
        return -- rate limited
    end
    lastClickTime[player] = now

    local data = PlayerDataService.getData(player)
    if not data then return end

    local clickPower = data.clickPower * data.rebirthMultiplier
    local space = data.backpackSize - data.backpackCurrent

    if space <= 0 then return end -- backpack full

    local gained = math.min(clickPower, space)
    data.backpackCurrent += gained
end)
```

### Sell Zone

```lua
-- ServerScriptService/SellZone.server.lua
local CollectionService = game:GetService("CollectionService")

for _, zone in CollectionService:GetTagged(Config.SELL_ZONE_TAG) do
    zone.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if not player then return end

        local data = PlayerDataService.getData(player)
        if not data or data.backpackCurrent <= 0 then return end

        local sellMultiplier = data.sellMultiplier or 1
        local earned = data.backpackCurrent * sellMultiplier
        data.currency += earned
        data.backpackCurrent = 0
    end)
end
```

### Rebirth System

Rebirth resets currency and upgrades in exchange for a permanent multiplier. The cost scales exponentially.

```lua
-- ServerScriptService/RebirthHandler.lua
local RebirthHandler = {}

local BASE_REBIRTH_COST = 5_000_000

-- Cost formula: each rebirth multiplies previous cost by rebirth number
-- 1st: 5M, 2nd: 10M, 3rd: 30M, 4th: 120M ...
function RebirthHandler.getCost(currentRebirths: number): number
    local cost = BASE_REBIRTH_COST
    for i = 1, currentRebirths do
        cost = cost * i
    end
    return cost
end

function RebirthHandler.canRebirth(data: PlayerData): boolean
    local cost = RebirthHandler.getCost(data.rebirths)
    return data.currency >= cost
end

function RebirthHandler.performRebirth(data: PlayerData): boolean
    if not RebirthHandler.canRebirth(data) then
        return false
    end

    data.rebirths += 1
    data.rebirthMultiplier = 1 + (data.rebirths * 0.5) -- +50% per rebirth
    data.currency = 0
    data.backpackCurrent = 0

    -- Reset upgrades to tier 0
    data.clickPowerTier = 0
    data.clickPower = Config.DEFAULT_CLICK_POWER
    data.backpackSizeTier = 0
    data.backpackSize = Config.DEFAULT_BACKPACK_SIZE

    return true
end

return RebirthHandler
```

### Multiplier Stacking

Multipliers from different sources stack multiplicatively. Recalculate whenever any source changes.

```lua
-- ServerStorage/MultiplierService.lua
local MultiplierService = {}

function MultiplierService.calculateTotal(data: PlayerData): number
    local total = 1.0

    -- Rebirth multiplier
    total *= data.rebirthMultiplier or 1

    -- Equipped pet multiplier (sum of all equipped pet bonuses)
    local petBonus = 0
    for _, petId in data.equippedPets do
        local petData = data.petInventory[petId]
        if petData then
            petBonus += petData.multiplier
        end
    end
    total *= (1 + petBonus)

    -- GamePass multiplier (2x if owned)
    if data.owns2xGamePass then
        total *= 2
    end

    -- Event/temporary multiplier
    if data.tempMultiplier and data.tempMultiplierExpiry > os.time() then
        total *= data.tempMultiplier
    end

    return total
end

return MultiplierService
```

### Prestige Layers (Deep Progression)

Popular simulators chain multiple prestige layers. Each layer resets the one below it.

```lua
-- Config example for multi-layer prestige
local PrestigeLayers = {
    { name = "Rebirth",       resetsCurrency = true, resetsUpgrades = true },
    { name = "SuperRebirth",  resetsRebirths = true, cost = "rebirths >= 100" },
    { name = "Prestige",      resetsSuperRebirths = true, cost = "superRebirths >= 50" },
    { name = "Ascension",     resetsPrestiges = true, cost = "prestiges >= 25" },
}
```

## Data Schema

```lua
export type PlayerData = {
    -- Core currency
    currency: number,
    backpackCurrent: number,
    backpackSize: number,
    clickPower: number,

    -- Upgrade tiers
    clickPowerTier: number,
    backpackSizeTier: number,
    sellMultiplierTier: number,

    -- Rebirth / prestige
    rebirths: number,
    rebirthMultiplier: number,
    superRebirths: number,
    prestiges: number,

    -- Multipliers
    sellMultiplier: number,
    owns2xGamePass: boolean,
    tempMultiplier: number?,
    tempMultiplierExpiry: number?,

    -- Pets (cross-reference [[pet-system]])
    petInventory: {[string]: PetData},
    equippedPets: {string},

    -- Auto-farm
    autoCollectEnabled: boolean,
    autoCollectRate: number, -- items per second
}
```

## Economy Integration

| Revenue Source | Typical GamePass | Price (Robux) |
|----------------|------------------|---------------|
| 2x Multiplier | Permanent 2x all earnings | 299-499 |
| Auto-Farm | Collects while AFK | 199-399 |
| Extra Backpack | +50% capacity | 99-199 |
| Exclusive Pet Egg | Better odds | 149-299 |
| Skip Rebirth | Free rebirth (one-time) | 49-99 |

Auto-farm GamePass is the single highest-converting purchase in most simulators.

## AFK and Offline Handling

Roblox disconnects idle players after 20 minutes. Simulators handle this two ways:

1. **Anti-AFK script**: Periodic camera nudge or input prompt (keeps session alive).
2. **Offline progress on rejoin**: Calculate elapsed time via `os.time()` delta and award a fraction of what the player would have earned. Cap at a maximum (e.g., 8 hours) to prevent abuse.

```lua
-- On player join, calculate offline earnings
local function grantOfflineProgress(data: PlayerData)
    local now = os.time()
    local elapsed = now - (data.lastSaveTimestamp or now)
    local MAX_OFFLINE_SECONDS = 8 * 3600 -- 8 hours cap
    elapsed = math.min(elapsed, MAX_OFFLINE_SECONDS)

    if data.autoCollectEnabled and elapsed > 60 then
        local earningsPerSecond = data.autoCollectRate * data.sellMultiplier
            * data.rebirthMultiplier
        local offlineEarnings = earningsPerSecond * elapsed * 0.5 -- 50% efficiency
        data.currency += offlineEarnings
    end
end
```

## Why This Genre Dominates Roblox

1. **Immediate gratification**: Click once, see a number go up. Zero onboarding friction.
2. **Social comparison**: Pets, titles, and visible wealth drive aspirational spending.
3. **Infinite progression**: Prestige layers mean there is always a next goal.
4. **Egg hatching gambling**: Weighted-random pet acquisition triggers dopamine loops (see [[pet-system]]).
5. **Update cadence**: New eggs, new areas, new prestige layers keep players returning.
6. **Low development cost**: Core loop is reusable across themes (mining, fighting, clicking, running).

## Pitfalls

- **Number inflation**: Without careful scaling, currencies hit Luau's `number` precision limit (~2^53). Consider BigNum libraries or display formatting (1.5T, 2.3Qa) early.
- **Pay-to-win perception**: Selling direct multipliers too aggressively drives away free players. Balance GamePass multipliers so free players can reach the same goals with more time.
- **Server load from auto-farm**: If every player has auto-collect running, the server ticks every player's earnings every frame. Use a batched approach (calculate per second, not per heartbeat).
- **Rebirth cost curve too steep or too flat**: Too steep and players quit before their first rebirth. Too flat and rebirths feel meaningless. Playtest the first 3 rebirths extensively.
- **AFK farming abuse**: Cap offline earnings and validate auto-collect server-side. Never trust the client to report how long it was idle.

## Related

- [[pet-system]] -- egg hatching, pet equipping, pet multipliers
- [[tycoon-mechanics]] -- similar idle-progression loop with spatial building
- [[daily-rewards]] -- pairs well with simulator login streaks
- [[inventory-pattern]] -- general inventory architecture
- [[DataStoreService]] -- persisting simulator data

## Sources

- [How do clicker simulator games work? - DevForum](https://devforum.roblox.com/t/how-do-clicker-simulator-games-work/286665)
- [How To Make a Simulator Rebirth (MATH) - DevForum](https://devforum.roblox.com/t/how-to-make-a-simulator-rebirth-math/2501720)
- [Making Multipliers - DevForum](https://devforum.roblox.com/t/making-multipliers/731475)
- [Thoughts on GUI-based idle game mechanics - DevForum](https://devforum.roblox.com/t/thoughts-on-gui-based-idle-game-mechanics/1482122)
- [Multipliers - Power Simulator Wiki](https://roblox-power-simulator.fandom.com/wiki/Multipliers)
- [Prestige - Grow a Garden Guide](https://gamedevourer.com/roblox-how-the-prestige-system-works-in-grow-a-garden/)
- [Prestiges - Run to Speed Simulator Wiki](https://roblox-run-to-speed-sim.fandom.com/wiki/Prestiges)
