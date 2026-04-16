---
title: Crafting System
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/crafting-system-minecraft-style.md
  - wiki/raw/community/articles/game-mechanics/datastore-inventory-saving.md
related:
  - "[[equipment-system]]"
  - "[[skill-tree]]"
  - "[[rpg-progression]]"
  - "[[shop-system]]"
  - "[[inventory-pattern]]"
  - "[[DataStoreService]]"
tags: [pattern, crafting, recipes, materials, stations, config-driven, rpg]
---

# Crafting System

> Config-driven recipe registry where players combine materials at crafting stations to produce equipment, consumables, or upgrades -- validated entirely server-side.

## Summary

A crafting system lets players convert collected materials into useful items. Recipes are defined in a config module, not hard-coded in scripts. Each recipe lists required materials (with quantities), an optional crafting station requirement (activated via ProximityPrompt), an optional success/failure rate, and the output item. The server validates that the player owns sufficient materials, is near the correct station, and meets any prerequisite conditions (level, recipe discovery) before consuming materials and granting the result. Two recipe models are common: "known recipes" (all recipes visible from the start) and "discovery recipes" (recipes unlock through gameplay).

## Implementation

### Recipe Registry (Config-Driven)

```lua
-- ReplicatedStorage/Shared/Config/CraftingConfig.lua
local CraftingConfig = {}

CraftingConfig.Recipes = {
    IronSword = {
        name = "Iron Sword",
        category = "Weapons",
        materials = {
            { itemId = "IronOre",  quantity = 5 },
            { itemId = "Wood",     quantity = 2 },
            { itemId = "Leather",  quantity = 1 },
        },
        output = { templateId = "IronSword", quantity = 1 },
        station = "Anvil",                 -- nil = craftable anywhere
        craftTime = 3,                     -- seconds (server-enforced)
        successRate = 1.0,                 -- 1.0 = guaranteed
        levelRequirement = 5,
        discoverable = false,              -- true = must be discovered first
    },
    HealthPotion = {
        name = "Health Potion",
        category = "Consumables",
        materials = {
            { itemId = "Herb",        quantity = 3 },
            { itemId = "EmptyBottle", quantity = 1 },
        },
        output = { templateId = "HealthPotion", quantity = 1 },
        station = "AlchemyTable",
        craftTime = 2,
        successRate = 1.0,
        levelRequirement = 1,
        discoverable = false,
    },
    EnchantedSword = {
        name = "Enchanted Sword",
        category = "Weapons",
        materials = {
            { itemId = "IronSword",    quantity = 1 },
            { itemId = "MagicCrystal", quantity = 3 },
            { itemId = "GoldDust",     quantity = 5 },
        },
        output = { templateId = "EnchantedSword", quantity = 1 },
        station = "EnchantingTable",
        craftTime = 5,
        successRate = 0.75,                -- 75% success
        failureOutput = {                  -- on failure, return partial mats
            { itemId = "GoldDust", quantity = 2 },
        },
        levelRequirement = 20,
        discoverable = true,               -- must find scroll or experiment
    },
}

-- Tag-based matching: "Oak Planks" and "Spruce Planks" both satisfy "Planks"
CraftingConfig.ItemTags = {
    OakPlanks    = {"Planks", "Wood"},
    SprucePlanks = {"Planks", "Wood"},
    IronOre      = {"Ore", "Metal"},
    GoldOre      = {"Ore", "Metal"},
}

return CraftingConfig
```

### Material Requirements Check (Server)

```lua
-- ServerStorage/Services/CraftingService.lua
local CraftingService = {}

local Config = require(game.ReplicatedStorage.Shared.Config.CraftingConfig)

function CraftingService.hasMaterials(playerData, recipeId: string): (boolean, string?)
    local recipe = Config.Recipes[recipeId]
    if not recipe then
        return false, "Recipe does not exist"
    end

    for _, requirement in ipairs(recipe.materials) do
        local owned = CraftingService.countItem(playerData, requirement.itemId)
        if owned < requirement.quantity then
            return false, "Need " .. requirement.quantity .. "x "
                .. requirement.itemId .. " (have " .. owned .. ")"
        end
    end

    return true, nil
end

function CraftingService.countItem(playerData, itemId: string): number
    local count = 0
    -- Check stackable materials
    if playerData.materials[itemId] then
        count += playerData.materials[itemId]
    end
    -- Check inventory for non-stackable items (match by templateId)
    for _, item in pairs(playerData.inventory) do
        if item.templateId == itemId then
            count += 1
        end
    end
    return count
end
```

### Crafting Stations (ProximityPrompt)

```lua
-- Server script: set up crafting station detection
local function setupCraftingStation(stationPart: BasePart, stationType: string)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Open " .. stationType
    prompt.ObjectText = stationType
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 0
    prompt.Parent = stationPart

    -- Store station type as an attribute
    stationPart:SetAttribute("StationType", stationType)

    prompt.Triggered:Connect(function(player)
        -- Notify client to open crafting UI filtered by this station type
        Remotes.OpenCraftingUI:FireClient(player, stationType)
    end)
end
```

### Craft Execution (Server-Authoritative)

```lua
function CraftingService.craft(player: Player, playerData, recipeId: string): (boolean, string?)
    local recipe = Config.Recipes[recipeId]
    if not recipe then
        return false, "Unknown recipe"
    end

    -- Check level requirement
    if playerData.progression.level < recipe.levelRequirement then
        return false, "Level too low"
    end

    -- Check discovery requirement
    if recipe.discoverable and not playerData.crafting.discoveredRecipes[recipeId] then
        return false, "Recipe not discovered"
    end

    -- Check station proximity (if required)
    if recipe.station then
        local character = player.Character
        if not character then return false, "No character" end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return false, "No root part" end

        local nearStation = false
        for _, station in ipairs(workspace.CraftingStations:GetChildren()) do
            if station:GetAttribute("StationType") == recipe.station then
                local dist = (rootPart.Position - station.Position).Magnitude
                if dist <= 15 then
                    nearStation = true
                    break
                end
            end
        end

        if not nearStation then
            return false, "Not near a " .. recipe.station
        end
    end

    -- Check materials
    local hasAll, reason = CraftingService.hasMaterials(playerData, recipeId)
    if not hasAll then
        return false, reason
    end

    -- Consume materials
    for _, requirement in ipairs(recipe.materials) do
        CraftingService.removeItem(playerData, requirement.itemId, requirement.quantity)
    end

    -- Roll for success/failure
    local roll = math.random()
    if roll <= recipe.successRate then
        -- Success: grant output
        local output = recipe.output
        InventoryService.addItem(playerData, output.templateId, output.quantity)
        return true, nil
    else
        -- Failure: grant partial materials back (if configured)
        if recipe.failureOutput then
            for _, refund in ipairs(recipe.failureOutput) do
                CraftingService.addMaterial(playerData, refund.itemId, refund.quantity)
            end
        end
        return false, "Crafting failed"
    end
end

function CraftingService.removeItem(playerData, itemId: string, quantity: number)
    -- Remove from stackable materials first
    if playerData.materials[itemId] then
        local available = playerData.materials[itemId]
        local toRemove = math.min(available, quantity)
        playerData.materials[itemId] -= toRemove
        quantity -= toRemove
        if playerData.materials[itemId] <= 0 then
            playerData.materials[itemId] = nil
        end
    end

    -- Remove non-stackable items from inventory if needed
    if quantity > 0 then
        for id, item in pairs(playerData.inventory) do
            if item.templateId == itemId then
                playerData.inventory[id] = nil
                quantity -= 1
                if quantity <= 0 then break end
            end
        end
    end
end
```

### Discovery vs Known Recipes

```lua
-- Discovery: player finds a recipe scroll or experiments at a station
function CraftingService.discoverRecipe(playerData, recipeId: string): boolean
    local recipe = Config.Recipes[recipeId]
    if not recipe then return false end
    if not recipe.discoverable then return false end  -- already known by default

    playerData.crafting.discoveredRecipes[recipeId] = true
    return true
end

-- Client UI: filter visible recipes
local function getVisibleRecipes(playerData, stationType: string?): {string}
    local visible = {}
    for recipeId, recipe in pairs(CraftingConfig.Recipes) do
        -- Filter by station if specified
        if stationType and recipe.station ~= stationType then
            continue
        end
        -- Filter by discovery
        if recipe.discoverable and not playerData.crafting.discoveredRecipes[recipeId] then
            continue
        end
        table.insert(visible, recipeId)
    end
    return visible
end
```

## Data Schema

What persists in DataStore per player:

```lua
{
    materials = {
        IronOre = 23,
        Wood = 45,
        Herb = 12,
        EmptyBottle = 5,
        MagicCrystal = 2,
        GoldDust = 8,
    },
    crafting = {
        discoveredRecipes = {
            EnchantedSword = true,
        },
        totalCrafted = 47,      -- lifetime counter for analytics
    },
    -- inventory table stores crafted items (see [[equipment-system]])
    version = 1,
}
```

Materials are stackable integers. Crafted equipment items go into the GUID-keyed `inventory` table described in [[equipment-system]].

## Formulas

**Success rate (EnchantedSword example):** 75% base. Can be modified by:
- Crafting skill passive: `+5% per skill level`
- Station quality: `+10%` at upgraded station
- Formula: `min(1.0, baseRate + skillBonus + stationBonus)`

**Expected materials to craft one EnchantedSword:**
- At 75% success: 1 / 0.75 = 1.33 attempts on average
- Expected iron sword cost: 1.33 swords, expected crystal cost: 4 crystals, expected gold dust: 1.33 * 5 - (0.33 * 2 refund) = 6 net

**Craft time:** Server enforces a minimum delay between the craft request and the result. Prevents spamming crafts faster than the UI animation. Typical: 2-5 seconds.

## Pitfalls

- **Client-side material check only.** The client shows "you can craft this" for UX, but the server must independently verify materials before consuming them. An exploiter can send a craft request without having materials.
- **Race condition on double-craft.** If a player rapidly clicks "craft" twice, both requests may pass the material check before either consumes materials. Use a per-player craft lock (a boolean flag checked before processing and cleared after).
- **Shaped vs shapeless recipes.** Grid-based systems (Minecraft-style 3x3 grids) add complexity. Most Roblox crafting systems use shapeless (list-based) recipes unless the grid is a core design feature. List-based is simpler and sufficient for most games.
- **Recipe data in ReplicatedStorage.** Recipe configs are in ReplicatedStorage so the client can render the crafting UI. This means players can see all recipes (including undiscovered ones) by reading memory. If recipe secrecy matters, send only discovered recipe IDs from the server and keep full configs in ServerStorage.
- **Forgetting failureOutput.** If a high-cost recipe fails and returns nothing, players feel cheated. Always return partial materials on failure for expensive recipes.
- **Station proximity check radius.** Too small (5 studs) and players cannot reach from common positions. Too large (50 studs) and they can craft from across the room. 10-15 studs is the standard range.

## Related

- [[equipment-system]] -- crafting produces equipment items
- [[skill-tree]] -- crafting skill passives improve success rates
- [[rpg-progression]] -- level gates on recipe access
- [[shop-system]] -- materials sold in shops, crafted items sold to NPCs
- [[inventory-pattern]] -- material and item storage
- [[DataStoreService]] -- material counts and discovery state persisted

## Sources

- [Crafting System Like Minecraft](../raw/community/articles/game-mechanics/crafting-system-minecraft-style.md) -- grid-based recipes, tag matching, CheckRecipes verification code
- [DataStore Inventory Saving](../raw/community/articles/game-mechanics/datastore-inventory-saving.md) -- GUID-based item instances, save patterns
