---
title: Equipment System
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/datastore-inventory-saving.md
  - wiki/raw/community/articles/game-mechanics/weighted-rarity-system.md
  - wiki/raw/community/articles/game-mechanics/stat-system-design.md
related:
  - "[[rpg-progression]]"
  - "[[skill-tree]]"
  - "[[crafting-system]]"
  - "[[shop-system]]"
  - "[[inventory-pattern]]"
  - "[[trading-system]]"
  - "[[DataStoreService]]"
tags: [pattern, equipment, gear, rarity, upgrade, inventory, rpg]
---

# Equipment System

> Slot-based gear with rarity tiers, stat bonuses, set effects, and upgrade paths -- the primary horizontal progression axis alongside vertical leveling.

## Summary

An equipment system assigns stat-modifying items to named body slots (Weapon, Helmet, Chest, Legs, Boots, Accessory). Each item has a rarity tier that determines its base stat range, and an upgrade level (+0 through +10) that scales those stats further. Set bonuses reward collecting matching items. All equip/unequip operations are server-authoritative: the client sends an intent ("equip item X to slot Y"), the server validates ownership and slot compatibility, then updates the player's computed stats. Items persist in DataStore using GUID-based keys so each instance is unique and tradeable.

## Implementation

### Gear Slot Registry

```lua
-- ReplicatedStorage/Shared/Config/EquipmentConfig.lua
local EquipmentConfig = {}

EquipmentConfig.Slots = {
    "Weapon",
    "Helmet",
    "Chest",
    "Legs",
    "Boots",
    "Accessory1",
    "Accessory2",
}

EquipmentConfig.SlotCompatibility = {
    Weapon    = {"Sword", "Staff", "Bow", "Dagger"},
    Helmet    = {"Helmet"},
    Chest     = {"Chestplate", "Robe"},
    Legs      = {"Leggings"},
    Boots     = {"Boots"},
    Accessory1 = {"Ring", "Amulet", "Cape"},
    Accessory2 = {"Ring", "Amulet", "Cape"},
}

return EquipmentConfig
```

### Rarity Tiers

```lua
-- Rarity definitions with stat multipliers and drop weights
EquipmentConfig.Rarities = {
    Common    = { multiplier = 1.0,  color = Color3.fromRGB(180, 180, 180), weight = 45 },
    Uncommon  = { multiplier = 1.25, color = Color3.fromRGB(30, 200, 30),   weight = 30 },
    Rare      = { multiplier = 1.6,  color = Color3.fromRGB(30, 100, 255),  weight = 15 },
    Epic      = { multiplier = 2.0,  color = Color3.fromRGB(160, 50, 255),  weight = 8  },
    Legendary = { multiplier = 2.8,  color = Color3.fromRGB(255, 170, 0),   weight = 1.8},
    Mythic    = { multiplier = 4.0,  color = Color3.fromRGB(255, 50, 50),   weight = 0.2},
}
```

### Weighted Rarity Roll

```lua
-- ServerStorage/Services/LootService.lua
local LootService = {}

function LootService.rollRarity(): string
    local totalWeight = 0
    for _, data in pairs(EquipmentConfig.Rarities) do
        totalWeight += data.weight
    end

    local roll = math.random() * totalWeight
    local cumulative = 0

    for rarityName, data in pairs(EquipmentConfig.Rarities) do
        cumulative += data.weight
        if roll <= cumulative then
            return rarityName
        end
    end
    return "Common"  -- fallback
end
```

### Item Template and Instance Generation

```lua
-- Item templates define base stats (before rarity multiplier)
EquipmentConfig.ItemTemplates = {
    IronSword = {
        name = "Iron Sword",
        type = "Sword",
        slot = "Weapon",
        setId = "IronSet",
        baseStats = { attack = 15, speed = 2 },
        levelRequirement = 5,
    },
    IronHelmet = {
        name = "Iron Helmet",
        type = "Helmet",
        slot = "Helmet",
        setId = "IronSet",
        baseStats = { defense = 10, maxHP = 20 },
        levelRequirement = 5,
    },
}

-- Generate a unique item instance from a template
function LootService.generateItem(templateId: string, rarity: string?): table
    local template = EquipmentConfig.ItemTemplates[templateId]
    if not template then return nil end

    local HttpService = game:GetService("HttpService")
    local chosenRarity = rarity or LootService.rollRarity()
    local rarityData = EquipmentConfig.Rarities[chosenRarity]

    local stats = {}
    for stat, baseValue in pairs(template.baseStats) do
        -- Apply rarity multiplier with +/- 10% random variance
        local variance = 0.9 + math.random() * 0.2
        stats[stat] = math.floor(baseValue * rarityData.multiplier * variance)
    end

    return {
        id = HttpService:GenerateGUID(false),
        templateId = templateId,
        name = template.name,
        type = template.type,
        slot = template.slot,
        setId = template.setId,
        rarity = chosenRarity,
        stats = stats,
        upgradeLevel = 0,
        levelRequirement = template.levelRequirement,
    }
end
```

### Equip / Unequip (Server-Authoritative)

```lua
-- ServerStorage/Services/EquipmentService.lua
local EquipmentService = {}

function EquipmentService.equip(playerData, itemId: string, slotName: string): (boolean, string?)
    -- Validate slot exists
    if not table.find(EquipmentConfig.Slots, slotName) then
        return false, "Invalid slot"
    end

    -- Find item in inventory
    local item = playerData.inventory[itemId]
    if not item then
        return false, "Item not owned"
    end

    -- Validate slot compatibility
    local compatible = EquipmentConfig.SlotCompatibility[slotName]
    if not table.find(compatible, item.type) then
        return false, "Item type incompatible with slot"
    end

    -- Validate level requirement
    if playerData.progression.level < item.levelRequirement then
        return false, "Level too low"
    end

    -- Unequip current item in that slot (if any)
    local currentItemId = playerData.equipped[slotName]
    if currentItemId then
        playerData.equipped[slotName] = nil
    end

    -- Equip new item
    playerData.equipped[slotName] = itemId

    -- Recalculate derived stats
    EquipmentService.recalculateStats(playerData)

    return true, nil
end

function EquipmentService.recalculateStats(playerData)
    -- Start from base stats (level-derived)
    local base = playerData.baseStats
    local computed = table.clone(base)

    -- Add equipment bonuses
    for slotName, itemId in pairs(playerData.equipped) do
        local item = playerData.inventory[itemId]
        if item then
            local upgradeMultiplier = 1 + (item.upgradeLevel * 0.08)
            for stat, value in pairs(item.stats) do
                computed[stat] = (computed[stat] or 0)
                    + math.floor(value * upgradeMultiplier)
            end
        end
    end

    -- Apply set bonuses
    EquipmentService.applySetBonuses(playerData, computed)

    playerData.stats = computed
end
```

### Set Bonuses

```lua
EquipmentConfig.SetBonuses = {
    IronSet = {
        [2] = { defense = 15 },                           -- 2-piece bonus
        [4] = { defense = 30, maxHP = 50 },               -- 4-piece bonus
        [6] = { defense = 50, maxHP = 100, attack = 10 }, -- full set
    },
}

function EquipmentService.applySetBonuses(playerData, computed)
    -- Count equipped items per set
    local setCounts: {[string]: number} = {}
    for _, itemId in pairs(playerData.equipped) do
        local item = playerData.inventory[itemId]
        if item and item.setId then
            setCounts[item.setId] = (setCounts[item.setId] or 0) + 1
        end
    end

    -- Apply bonuses at thresholds
    for setId, count in pairs(setCounts) do
        local bonuses = EquipmentConfig.SetBonuses[setId]
        if bonuses then
            for threshold, bonusStats in pairs(bonuses) do
                if count >= threshold then
                    for stat, value in pairs(bonusStats) do
                        computed[stat] = (computed[stat] or 0) + value
                    end
                end
            end
        end
    end
end
```

### Upgrade System (+1 through +10)

```lua
EquipmentConfig.UpgradeRates = {
    [1]  = { successRate = 1.00, costMultiplier = 1.0 },  -- guaranteed
    [2]  = { successRate = 0.95, costMultiplier = 1.2 },
    [3]  = { successRate = 0.90, costMultiplier = 1.5 },
    [4]  = { successRate = 0.80, costMultiplier = 2.0 },
    [5]  = { successRate = 0.70, costMultiplier = 2.5 },
    [6]  = { successRate = 0.55, costMultiplier = 3.5 },
    [7]  = { successRate = 0.40, costMultiplier = 5.0 },
    [8]  = { successRate = 0.25, costMultiplier = 7.0 },
    [9]  = { successRate = 0.15, costMultiplier = 10.0 },
    [10] = { successRate = 0.08, costMultiplier = 15.0 },
}

-- Stat multiplier per upgrade level: 1 + (level * 0.08)
-- +0: 1.0x, +5: 1.4x, +10: 1.8x

function EquipmentService.upgrade(playerData, itemId: string): (boolean, string?)
    local item = playerData.inventory[itemId]
    if not item then return false, "Item not owned" end
    if item.upgradeLevel >= 10 then return false, "Max upgrade reached" end

    local nextLevel = item.upgradeLevel + 1
    local rateData = EquipmentConfig.UpgradeRates[nextLevel]
    local cost = math.floor(100 * rateData.costMultiplier)  -- base cost 100 gold

    if playerData.currency.gold < cost then
        return false, "Insufficient gold"
    end

    -- Deduct cost (always, even on failure)
    playerData.currency.gold -= cost

    -- Roll for success
    local roll = math.random()
    if roll <= rateData.successRate then
        item.upgradeLevel = nextLevel
        EquipmentService.recalculateStats(playerData)
        return true, nil
    else
        -- Failure: item stays at current level (no downgrade)
        return false, "Upgrade failed"
    end
end
```

### Equipment Comparison UI (Client)

```lua
-- Client-side comparison helper (display only, no authority)
local function compareItems(current, candidate): {[string]: {current: number, new: number, diff: number}}
    local comparison = {}
    local allStats = {}

    -- Collect all stat keys
    if current then
        for stat in pairs(current.stats) do allStats[stat] = true end
    end
    for stat in pairs(candidate.stats) do allStats[stat] = true end

    for stat in pairs(allStats) do
        local currentVal = current and (current.stats[stat] or 0) or 0
        local newVal = candidate.stats[stat] or 0
        comparison[stat] = {
            current = currentVal,
            new = newVal,
            diff = newVal - currentVal,
        }
    end
    return comparison
end
```

## Data Schema

What persists in DataStore per player:

```lua
{
    inventory = {
        ["guid-1234"] = {
            templateId = "IronSword",
            name = "Iron Sword",
            type = "Sword",
            slot = "Weapon",
            setId = "IronSet",
            rarity = "Rare",
            stats = { attack = 25, speed = 3 },
            upgradeLevel = 3,
            levelRequirement = 5,
        },
        -- ... more items keyed by GUID
    },
    equipped = {
        Weapon = "guid-1234",
        Helmet = "guid-5678",
        Chest = nil,
        Legs = nil,
        Boots = nil,
        Accessory1 = nil,
        Accessory2 = nil,
    },
    version = 1,
}
```

GUID-based keys allow unique item instances, support trading, and differentiate two swords with different rolled stats.

## Formulas

| Rarity | Stat Multiplier | Drop Weight | Effective Rate |
|--------|----------------|-------------|----------------|
| Common | 1.0x | 45 | 45% |
| Uncommon | 1.25x | 30 | 30% |
| Rare | 1.6x | 15 | 15% |
| Epic | 2.0x | 8 | 8% |
| Legendary | 2.8x | 1.8 | 1.8% |
| Mythic | 4.0x | 0.2 | 0.2% |

**Upgrade stat scaling:** `finalStat = baseStat * (1 + upgradeLevel * 0.08)`

**Upgrade cost:** `cost = 100 * costMultiplier` (gold)

**Expected gold to +10 one item:** approximately 8500 gold (accounting for failure rates and retries at each level).

## Pitfalls

- **Client-side equip without validation.** The client sends "equip item X to slot Y" via RemoteEvent. The server validates ownership, slot compatibility, and level requirement before applying. Never let the client modify `equipped` directly.
- **Storing items by name instead of GUID.** Name-based keys cannot distinguish two "Iron Swords" with different rarity or stats. GUID keys are required for unique instances, trading, and upgrade tracking.
- **Stat recalculation on every frame.** Recalculate only when equipment changes (equip, unequip, upgrade). Cache the computed stats table and reuse it.
- **Upgrade downgrade on failure.** Downgrading items on failed upgrades is frustrating in short Roblox sessions. The standard pattern is: cost consumed, item stays at current level. Optional: add a "pity counter" that guarantees success after N consecutive failures.
- **DataStore size with large inventories.** Each item is roughly 200-400 bytes serialized. A 200-item inventory is approximately 60KB, well within the 4MB DataStore limit. Add an inventory cap (200-500 items) and warn approaching it.
- **Set bonus double-counting.** If the bonus table has thresholds [2, 4, 6], a player with 4 pieces should get both the 2-piece AND the 4-piece bonus. The code iterates all thresholds <= count, not just the highest.

## Related

- [[rpg-progression]] -- level requirements gate equipment tiers
- [[skill-tree]] -- passive skills may modify equipment stats
- [[crafting-system]] -- crafting produces equipment items
- [[shop-system]] -- equipment sold in shops
- [[inventory-pattern]] -- underlying inventory storage
- [[trading-system]] -- GUID-based items enable player trading
- [[DataStoreService]] -- persistence layer

## Sources

- [DataStore Inventory Saving](../raw/community/articles/game-mechanics/datastore-inventory-saving.md) -- GUID-based item storage, AddItem pattern, save-on-leave
- [Weighted Rarity System](../raw/community/articles/game-mechanics/weighted-rarity-system.md) -- cumulative weight rolling, rarity tier definitions
- [Stat System Design](../raw/community/articles/game-mechanics/stat-system-design.md) -- module-based stat storage, single DataStore table pattern
