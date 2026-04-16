---
title: pet-system
type: pattern
category: patterns
subcategory: genre-mechanics
owner: game-designer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/pet-hatching-framework.md
  - wiki/raw/community/articles/game-mechanics/pet-system-2025.md
  - wiki/raw/community/articles/game-mechanics/pet-follow-system.md
related:
  - "[[simulator-mechanics]]"
  - "[[inventory-pattern]]"
  - "[[trading-system]]"
  - "[[DataStoreService]]"
tags: [pattern, pet, egg-hatching, weighted-random, follow-system, fusion, genre]
---

# Pet System

> Egg hatching with weighted random rarities, pet inventory with equip slots, follow AI via client-side CFrame positioning, pet leveling, fusion/evolution, and trading. Massively popular on Roblox -- nearly every top simulator includes a pet system.

## Summary

Pet systems are a core monetization and engagement feature across Roblox. Players hatch pets from eggs (each with weighted rarity odds), equip them for stat boosts, level them through gameplay, and optionally fuse duplicates into stronger versions. The pet follow system -- where equipped pets visually trail the player -- is almost entirely client-rendered for performance. The weighted-random egg hatching mechanic is the primary driver of both engagement (dopamine loops from rare rolls) and revenue (GamePasses for luck boosts, exclusive eggs). Pet Simulator 99 built an empire on this pattern.

## Core Loop

```
Buy Egg (currency or Robux)
       |
       v
Weighted Random Roll --> Pet (Common to Mythic)
       |
       v
Add to Inventory
       |
       v
Equip Pet (limited slots) --> Stat Boost Active
       |
       v
Pet Follows Player (client-side rendering)
       |
       v
Level Pet Through Gameplay --> Stats Increase
       |
       v
Fuse Duplicates --> Stronger Pet / Evolution
       |
       v
(Optional) Trade Pets with Other Players
```

## Implementation

### Egg Configuration

Each egg defines its available pets and their weighted chances. Weights do not need to sum to 100 -- the system normalizes them.

```lua
-- ReplicatedStorage/Shared/Config/EggConfig.lua
local EggConfig = {}

EggConfig.Eggs = {
    BasicEgg = {
        price = 500,
        currency = "Coins",
        pets = {
            { name = "Dog",       rarity = "Common",   weight = 40 },
            { name = "Cat",       rarity = "Common",   weight = 35 },
            { name = "Parrot",    rarity = "Uncommon", weight = 15 },
            { name = "Fox",       rarity = "Rare",     weight = 8 },
            { name = "Dragon",    rarity = "Legendary", weight = 1.5 },
            { name = "Phoenix",   rarity = "Mythic",   weight = 0.5 },
        },
    },
    GoldenEgg = {
        price = 5000,
        currency = "Coins",
        pets = {
            { name = "GoldenDog",    rarity = "Rare",      weight = 40 },
            { name = "GoldenFox",    rarity = "Legendary",  weight = 35 },
            { name = "GoldenDragon", rarity = "Legendary",  weight = 20 },
            { name = "Celestial",    rarity = "Mythic",     weight = 5 },
        },
    },
}

EggConfig.RarityColors = {
    Common    = Color3.fromRGB(85, 255, 127),
    Uncommon  = Color3.fromRGB(223, 201, 34),
    Rare      = Color3.fromRGB(255, 47, 47),
    Legendary = Color3.fromRGB(170, 85, 255),
    Mythic    = Color3.fromRGB(211, 79, 255),
}

EggConfig.RarityMultipliers = {
    Common    = 1.0,
    Uncommon  = 1.5,
    Rare      = 2.5,
    Legendary = 5.0,
    Mythic    = 10.0,
}

return EggConfig
```

### Weighted Random Selection (Server-Side)

The server performs all randomization to prevent client manipulation. The algorithm uses cumulative weight distribution.

```lua
-- ServerStorage/HatchingService.lua
local HatchingService = {}

local HttpService = game:GetService("HttpService")
local EggConfig = require(game.ReplicatedStorage.Shared.Config.EggConfig)

-- Weighted random selection using cumulative distribution
function HatchingService.rollPet(eggName: string, luckMultiplier: number?): (string, string)?
    local eggData = EggConfig.Eggs[eggName]
    if not eggData then return nil end

    local pets = eggData.pets
    local luck = luckMultiplier or 1

    -- Calculate total weight (apply luck to rare pets)
    local totalWeight = 0
    local adjustedWeights: {number} = {}

    for i, pet in pets do
        local weight = pet.weight
        -- Luck boosts rarer pets (lower base weight = higher luck benefit)
        if pet.rarity ~= "Common" then
            weight *= luck
        end
        adjustedWeights[i] = weight
        totalWeight += weight
    end

    -- Roll
    local roll = math.random() * totalWeight
    local cumulative = 0

    for i, pet in pets do
        cumulative += adjustedWeights[i]
        if roll <= cumulative then
            return pet.name, pet.rarity
        end
    end

    -- Fallback (should not reach here)
    return pets[1].name, pets[1].rarity
end

-- Generate a unique pet instance
function HatchingService.hatch(player: Player, eggName: string): PetInstance?
    local data = PlayerDataService.getData(player)
    if not data then return nil end

    local eggData = EggConfig.Eggs[eggName]
    if not eggData then return nil end

    -- Check currency
    if data.currency < eggData.price then return nil end

    -- Check inventory space
    local MAX_PETS = data.maxPetSlots or 100
    if #data.petInventory >= MAX_PETS then return nil end

    -- Deduct cost
    data.currency -= eggData.price

    -- Roll pet
    local luck = data.luckMultiplier or 1
    local petName, rarity = HatchingService.rollPet(eggName, luck)
    if not petName then return nil end

    -- Create pet instance with unique ID
    local pet: PetInstance = {
        id = HttpService:GenerateGUID(false),
        name = petName,
        rarity = rarity,
        level = 1,
        xp = 0,
        multiplier = EggConfig.RarityMultipliers[rarity],
        equipped = false,
        createdAt = os.time(),
    }

    table.insert(data.petInventory, pet)
    return pet
end

-- Triple hatch (common in simulators)
function HatchingService.hatchTriple(player: Player, eggName: string): {PetInstance}
    local results = {}
    for _ = 1, 3 do
        local pet = HatchingService.hatch(player, eggName)
        if pet then
            table.insert(results, pet)
        end
    end
    return results
end

return HatchingService
```

### Hatching Animation (Client-Side)

The animation is purely cosmetic and runs on the client after the server confirms the hatch result.

```lua
-- StarterGui/HatchingUI.client.lua (simplified)
local TweenService = game:GetService("TweenService")

local function playHatchAnimation(eggModel: Model, petName: string, rarity: string)
    -- 1. Lift egg
    local liftTween = TweenService:Create(eggModel.PrimaryPart, TweenInfo.new(0.5), {
        CFrame = eggModel:GetPivot() + Vector3.new(0, 5, 0),
    })
    liftTween:Play()
    liftTween.Completed:Wait()

    -- 2. Wobble (rotate back and forth with increasing speed)
    for i = 1, 5 do
        local angle = math.rad(15)
        local duration = 0.3 - (i * 0.04)

        local wobbleRight = TweenService:Create(eggModel.PrimaryPart, TweenInfo.new(duration), {
            CFrame = eggModel:GetPivot() * CFrame.Angles(0, 0, angle),
        })
        wobbleRight:Play()
        wobbleRight.Completed:Wait()

        local wobbleLeft = TweenService:Create(eggModel.PrimaryPart, TweenInfo.new(duration), {
            CFrame = eggModel:GetPivot() * CFrame.Angles(0, 0, -angle),
        })
        wobbleLeft:Play()
        wobbleLeft.Completed:Wait()
    end

    -- 3. Flash and reveal
    eggModel:Destroy()
    -- Show pet reveal UI with rarity color and name
    showRevealUI(petName, rarity, EggConfig.RarityColors[rarity])
end
```

### Pet Follow System (Client-Side Rendering)

Pet movement runs entirely on each client via `RunService.Heartbeat`. The server only tracks which pets are equipped -- all visual positioning is client-side.

```lua
-- StarterPlayerScripts/PetRenderer.client.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local FOLLOW_SPEED = 0.15     -- Lerp alpha (higher = snappier)
local PET_HEIGHT = 3           -- studs above ground
local PET_SPACING = 3          -- studs between pets
local MAX_FOLLOW_DISTANCE = 50 -- teleport if too far

-- Calculate positions for multiple pets in rows behind the player
local function getPetPositions(rootCFrame: CFrame, count: number): {CFrame}
    local positions: {CFrame} = {}
    local PETS_PER_ROW = 3
    local ROW_OFFSET = 4 -- studs behind player per row

    for i = 1, count do
        local row = math.ceil(i / PETS_PER_ROW)
        local col = ((i - 1) % PETS_PER_ROW) - math.floor(PETS_PER_ROW / 2)

        local offset = Vector3.new(
            col * PET_SPACING,
            PET_HEIGHT,
            row * ROW_OFFSET
        )

        -- Position relative to player facing direction (behind them)
        local worldPos = rootCFrame:PointToWorldSpace(offset)
        table.insert(positions, CFrame.new(worldPos))
    end

    return positions
end

-- Main render loop
RunService.Heartbeat:Connect(function()
    for _, player in Players:GetPlayers() do
        local character = player.Character
        if not character then continue end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end

        local equippedPets = getEquippedPetModels(player)
        local targetPositions = getPetPositions(rootPart.CFrame, #equippedPets)

        for i, petModel in equippedPets do
            if not petModel.PrimaryPart then continue end

            local targetCF = targetPositions[i]
            local currentCF = petModel:GetPivot()
            local distance = (targetCF.Position - currentCF.Position).Magnitude

            if distance > MAX_FOLLOW_DISTANCE then
                -- Teleport if too far
                petModel:PivotTo(targetCF)
            else
                -- Smooth lerp
                local newCF = currentCF:Lerp(targetCF, FOLLOW_SPEED)

                -- Face toward player
                local lookAt = CFrame.lookAt(
                    newCF.Position,
                    rootPart.Position * Vector3.new(1, 0, 1)
                        + Vector3.new(0, newCF.Position.Y, 0)
                )

                petModel:PivotTo(lookAt)
            end
        end
    end
end)
```

### Pet Leveling

Pets gain XP from gameplay actions (clicks, kills, collections). XP thresholds scale per level.

```lua
-- ServerStorage/PetLevelingService.lua
local PetLevelingService = {}

local MAX_LEVEL = 50
local BASE_XP = 100 -- XP needed for level 2

function PetLevelingService.getXPForLevel(level: number): number
    return math.floor(BASE_XP * (level ^ 1.5))
end

function PetLevelingService.addXP(pet: PetInstance, xp: number)
    if pet.level >= MAX_LEVEL then return end

    pet.xp += xp

    while pet.xp >= PetLevelingService.getXPForLevel(pet.level + 1) do
        pet.xp -= PetLevelingService.getXPForLevel(pet.level + 1)
        pet.level += 1

        -- Increase multiplier per level
        pet.multiplier = EggConfig.RarityMultipliers[pet.rarity] * (1 + pet.level * 0.1)

        if pet.level >= MAX_LEVEL then
            pet.xp = 0
            break
        end
    end
end

return PetLevelingService
```

### Pet Fusion / Evolution

Combine duplicate pets to create a stronger version. Typically 3 of the same pet fuse into a "golden" or "rainbow" variant.

```lua
-- ServerStorage/PetFusionService.lua
local PetFusionService = {}

local FUSION_COUNT = 3 -- pets needed to fuse

function PetFusionService.canFuse(data: PlayerData, petName: string): boolean
    local count = 0
    for _, pet in data.petInventory do
        if pet.name == petName and not pet.equipped then
            count += 1
        end
    end
    return count >= FUSION_COUNT
end

function PetFusionService.fuse(data: PlayerData, petName: string): PetInstance?
    if not PetFusionService.canFuse(data, petName) then return nil end

    -- Remove FUSION_COUNT unequipped pets of this type
    local removed = 0
    for i = #data.petInventory, 1, -1 do
        local pet = data.petInventory[i]
        if pet.name == petName and not pet.equipped then
            table.remove(data.petInventory, i)
            removed += 1
            if removed >= FUSION_COUNT then break end
        end
    end

    -- Create fused pet with "Golden" prefix and boosted stats
    local basePet = EggConfig.Eggs -- find the pet config to get rarity
    local rarity = "Legendary" -- fused pets bump up at least one rarity tier

    local fusedPet: PetInstance = {
        id = HttpService:GenerateGUID(false),
        name = "Golden " .. petName,
        rarity = rarity,
        level = 1,
        xp = 0,
        multiplier = EggConfig.RarityMultipliers[rarity] * 1.5, -- fusion bonus
        equipped = false,
        createdAt = os.time(),
        isFused = true,
    }

    table.insert(data.petInventory, fusedPet)
    return fusedPet
end

return PetFusionService
```

## Data Schema

```lua
export type PetInstance = {
    id: string,          -- unique GUID
    name: string,        -- e.g. "Dragon", "Golden Dog"
    rarity: string,      -- "Common" | "Uncommon" | "Rare" | "Legendary" | "Mythic"
    level: number,
    xp: number,
    multiplier: number,  -- current stat multiplier
    equipped: boolean,
    createdAt: number,   -- os.time()
    isFused: boolean?,   -- true if created via fusion
}

export type PetPlayerData = {
    petInventory: {PetInstance},
    equippedPets: {string},     -- list of pet GUIDs currently equipped
    maxPetSlots: number,         -- inventory capacity (expandable via GamePass)
    maxEquipSlots: number,       -- how many pets can be equipped at once
    luckMultiplier: number,      -- affects hatch odds
    totalHatched: number,        -- lifetime counter
}
```

## Economy Integration

| Revenue Source | Typical Product | Price (Robux) |
|----------------|-----------------|---------------|
| Exclusive Egg | Premium egg with higher rarity odds | 199-499 |
| Luck GamePass | Permanent 2x luck on all hatches | 299-599 |
| Triple Hatch | Hatch 3 at once (requires GamePass) | 149-299 |
| Extra Pet Slots | +50 inventory capacity | 99-199 |
| Extra Equip Slots | Equip 1 more pet simultaneously | 149-249 |
| Golden Egg | Guaranteed Legendary or above | 50-100 (DevProduct, repeatable) |

## Rarity Display

Show rarity prominently in all pet UI. The color-coded rarity system is central to the aspirational economy.

```
Common     -- green, no special effect
Uncommon   -- yellow, subtle glow
Rare       -- red, pulsing glow
Legendary  -- purple, sparkle particles
Mythic     -- pink/violet, rainbow shimmer, screen flash on hatch
```

BillboardGuis above equipped pets in the world should display the pet name and rarity color so other players can see what you have -- driving social comparison and aspiration.

## Pitfalls

- **Client-side hatching exploit**: If the client determines the pet roll, exploiters will force Mythic rolls every time. The server must perform all randomization and only send the result to the client.
- **Inventory bloat**: Without limits, players accumulate thousands of pets, bloating their DataStore entry past the 4MB limit. Enforce a cap (100-500 pets) and offer a "delete" or "release" mechanism. Serialize efficiently.
- **Follow system performance**: Rendering pets for all players on every Heartbeat is expensive with 50+ players each having 6 equipped pets. Cull pets for players far from the local camera. Only render pets within a 100-stud radius.
- **Luck GamePass too strong**: If a 2x luck pass makes Mythics trivially common, the economy collapses. Test odds extensively. A 0.5% Mythic chance with 2x luck becomes 1% -- still rare but twice as accessible.
- **Fusion deleting the wrong pets**: When fusing, always use the pet GUID to identify which specific instances to consume. Never rely on array index, which can shift between client request and server processing.
- **Trade scams**: If trading is enabled, implement a two-phase confirm system (both players confirm, 5-second countdown, confirm again). Log all trades for dispute resolution. See [[trading-system]].

## Related

- [[simulator-mechanics]] -- pet systems are a core component of simulators
- [[inventory-pattern]] -- general inventory architecture
- [[trading-system]] -- peer-to-peer pet trading
- [[DataStoreService]] -- persisting pet inventories (watch the 4MB limit)

## Sources

- [Pet Hatching Framework Part 1 - DevForum](https://devforum.roblox.com/t/pet-hatching-framework-part-1/1480291)
- [How to make a Pet System in ROBLOX 2025 - DevForum](https://devforum.roblox.com/t/new-how-to-make-a-pet-system-in-roblox-2025-high-effort-post/3792525)
- [How do I make pet follow system - DevForum](https://devforum.roblox.com/t/how-do-i-make-pet-follow-system/3308281)
- [Help on a random chance feature (Egg hatching) - DevForum](https://devforum.roblox.com/t/help-on-a-random-chance-feature-egg-hatching-system/873006)
- [Pet Follow System - DevForum](https://devforum.roblox.com/t/pet-follow-system/2176090)
- [Walking Pet / Follower - DevForum](https://devforum.roblox.com/t/walking-pet-follower/3124250)
- [Wondering how to add luck factor to egg hatching - DevForum](https://devforum.roblox.com/t/wondering-how-i-could-add-a-luck-factor-into-my-egg-hatching-system/2083602)
- [How does Pet Simulator do it? - DevForum](https://devforum.roblox.com/t/how-does-pet-simulator-do-it/2779392)
