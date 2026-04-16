---
title: Loot Tables
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/loot-tables-rarity.md
related:
  - "[[combat-system]]"
  - "[[damage-formulas]]"
  - "[[daily-rewards]]"
  - "[[quest-system]]"
tags: [pattern, loot, rng, rarity, drop-table, pity, weighted-random, server-authority]
---

# Loot Tables

> Server-authoritative weighted random selection for item drops with rarity tiers, pity counters, guaranteed drops, and luck modifiers.

## Summary

A loot table maps a game event (monster kill, chest open, quest completion) to a set of possible rewards, each with a weight that determines drop probability. The server rolls all drops -- the client never participates in random selection. Weights are relative values (not percentages), so adding or removing entries does not require recalculating other weights.

The system includes three layers: **weighted selection** (core algorithm), **pity counters** (guarantee rare drops after a streak of bad luck), and **guaranteed drops** (deterministic rewards independent of RNG). All random seeds use the server's `Random.new()` for reproducibility and anti-exploit protection.

## Implementation

### Loot Config (Shared)

```lua
-- ReplicatedStorage/Shared/Config/LootConfig.lua
export type RarityTier = {
    name: string,
    color: Color3,        -- for UI display
    weight: number,        -- relative weight
    pityThreshold: number, -- guaranteed after this many rolls without it
}

export type LootEntry = {
    itemId: string,
    weight: number,
    rarity: string,
    minQuantity: number?,
    maxQuantity: number?,
}

export type LootTable = {
    id: string,
    entries: {LootEntry},
    guaranteedDrops: {LootEntry}?,  -- always given on top of random roll
    rollCount: number?,             -- how many random items to roll (default 1)
    noDuplicates: boolean?,         -- prevent same item twice per roll batch
}

local LootConfig = {}

-- Rarity definitions with pity thresholds
LootConfig.RARITIES: {[string]: RarityTier} = {
    common = {
        name = "Common",
        color = Color3.fromRGB(200, 200, 200),
        weight = 1000,
        pityThreshold = 0,     -- no pity needed (always drops)
    },
    uncommon = {
        name = "Uncommon",
        color = Color3.fromRGB(30, 200, 30),
        weight = 400,
        pityThreshold = 0,
    },
    rare = {
        name = "Rare",
        color = Color3.fromRGB(30, 100, 255),
        weight = 100,
        pityThreshold = 20,    -- guaranteed within 20 rolls
    },
    epic = {
        name = "Epic",
        color = Color3.fromRGB(180, 30, 255),
        weight = 20,
        pityThreshold = 50,    -- guaranteed within 50 rolls
    },
    legendary = {
        name = "Legendary",
        color = Color3.fromRGB(255, 200, 30),
        weight = 5,
        pityThreshold = 100,   -- guaranteed within 100 rolls
    },
    mythic = {
        name = "Mythic",
        color = Color3.fromRGB(255, 50, 50),
        weight = 1,
        pityThreshold = 200,   -- guaranteed within 200 rolls
    },
}

-- Expected drop rates (for reference):
-- Common:     1000/1526 = 65.5%
-- Uncommon:    400/1526 = 26.2%
-- Rare:        100/1526 =  6.6%
-- Epic:         20/1526 =  1.3%
-- Legendary:     5/1526 =  0.33%
-- Mythic:         1/1526 =  0.066%

-- Example loot tables
LootConfig.TABLES: {[string]: LootTable} = {
    goblin_drop = {
        id = "goblin_drop",
        entries = {
            { itemId = "gold_coin",    weight = 800, rarity = "common",    minQuantity = 5, maxQuantity = 15 },
            { itemId = "iron_ore",     weight = 400, rarity = "common" },
            { itemId = "health_potion", weight = 200, rarity = "uncommon" },
            { itemId = "goblin_sword", weight = 50,  rarity = "rare" },
            { itemId = "goblin_crown", weight = 5,   rarity = "legendary" },
        },
        guaranteedDrops = {
            { itemId = "goblin_ear",   weight = 0,   rarity = "common" },  -- quest item
        },
        rollCount = 2,
    },
    treasure_chest = {
        id = "treasure_chest",
        entries = {
            { itemId = "gold_coin",      weight = 500, rarity = "common",    minQuantity = 20, maxQuantity = 50 },
            { itemId = "emerald",        weight = 100, rarity = "rare" },
            { itemId = "diamond",        weight = 20,  rarity = "epic" },
            { itemId = "ancient_scroll", weight = 5,   rarity = "legendary" },
            { itemId = "phoenix_feather", weight = 1,  rarity = "mythic" },
        },
        rollCount = 3,
        noDuplicates = true,
    },
}

return LootConfig
```

### Loot Roller (Server)

```lua
-- ServerStorage/Loot/LootRoller.lua
local LootConfig = require(game.ReplicatedStorage.Shared.Config.LootConfig)

-- Dedicated RNG per roller to avoid global state pollution
local rng = Random.new()

-- Pity counters: { [Player]: { [lootTableId]: { [rarity]: rollsSinceLastDrop } } }
local pityCounters: {[Player]: {[string]: {[string]: number}}} = {}

local LootRoller = {}

function LootRoller.initPlayer(player: Player)
    pityCounters[player] = {}
end

function LootRoller.cleanupPlayer(player: Player)
    pityCounters[player] = nil
end

--[[
    Core weighted random selection.
    Returns the selected LootEntry from the list.

    Algorithm:
    1. Sum all weights
    2. Generate random number in [1, totalWeight]
    3. Walk entries, subtracting weights until threshold crossed

    Time complexity: O(n) per roll. For tables with 100+ entries,
    consider binary search on prefix sums.
]]
local function weightedSelect(
    entries: {LootConfig.LootEntry},
    luckMultiplier: number?
): LootConfig.LootEntry
    local luck = luckMultiplier or 1.0

    -- Calculate total weight with luck applied to rare items
    local totalWeight = 0
    local adjustedWeights: {number} = table.create(#entries)

    for i, entry in entries do
        local weight = entry.weight

        -- Luck boosts rare items: multiply weight of non-common items
        local rarity = LootConfig.RARITIES[entry.rarity]
        if rarity and luck > 1.0 and entry.rarity ~= "common" then
            weight = weight * luck
        end

        adjustedWeights[i] = weight
        totalWeight += weight
    end

    if totalWeight <= 0 then
        return entries[1]  -- fallback
    end

    -- Roll
    local roll = rng:NextNumber() * totalWeight

    -- Walk
    local accumulated = 0
    for i, entry in entries do
        accumulated += adjustedWeights[i]
        if roll <= accumulated then
            return entry
        end
    end

    -- Floating-point safety: return last entry
    return entries[#entries]
end

--[[
    Checks pity counters and forces a rare drop if threshold is reached.
    Returns the forced rarity tier name, or nil if no pity needed.
]]
local function checkPity(
    player: Player,
    tableId: string
): string?
    local playerPity = pityCounters[player]
    if not playerPity then return nil end

    if not playerPity[tableId] then
        playerPity[tableId] = {}
    end

    local tablePity = playerPity[tableId]

    -- Check each rarity from rarest to most common
    local rarityOrder = { "mythic", "legendary", "epic", "rare" }
    for _, rarityName in rarityOrder do
        local tier = LootConfig.RARITIES[rarityName]
        if tier and tier.pityThreshold > 0 then
            local count = tablePity[rarityName] or 0
            if count >= tier.pityThreshold then
                return rarityName
            end
        end
    end

    return nil
end

--[[
    Increments pity counters for all rarities that were NOT dropped.
    Resets the counter for the rarity that WAS dropped (and all lower rarities).
]]
local function updatePity(
    player: Player,
    tableId: string,
    droppedRarity: string
)
    local playerPity = pityCounters[player]
    if not playerPity or not playerPity[tableId] then return end

    local tablePity = playerPity[tableId]
    local rarityOrder = { "common", "uncommon", "rare", "epic", "legendary", "mythic" }
    local droppedIndex = table.find(rarityOrder, droppedRarity) or 1

    for i, rarityName in rarityOrder do
        if i <= droppedIndex then
            -- Reset this rarity and all below it
            tablePity[rarityName] = 0
        else
            -- Increment: this rarity did not drop
            tablePity[rarityName] = (tablePity[rarityName] or 0) + 1
        end
    end
end

export type DropResult = {
    itemId: string,
    rarity: string,
    quantity: number,
    wasPity: boolean,
}

--[[
    Rolls a complete loot table for a player.
    Returns a list of DropResults (guaranteed drops + random rolls).
]]
function LootRoller.roll(
    player: Player,
    tableId: string,
    luckMultiplier: number?
): {DropResult}
    local lootTable = LootConfig.TABLES[tableId]
    if not lootTable then
        warn("Unknown loot table:", tableId)
        return {}
    end

    local results: {DropResult} = {}

    -- 1. Guaranteed drops (always given)
    if lootTable.guaranteedDrops then
        for _, entry in lootTable.guaranteedDrops do
            local qty = 1
            if entry.minQuantity and entry.maxQuantity then
                qty = rng:NextInteger(entry.minQuantity, entry.maxQuantity)
            end
            table.insert(results, {
                itemId = entry.itemId,
                rarity = entry.rarity,
                quantity = qty,
                wasPity = false,
            })
        end
    end

    -- 2. Random rolls
    local rollCount = lootTable.rollCount or 1
    local rolledItems: {[string]: boolean} = {}  -- for noDuplicates

    for _ = 1, rollCount do
        local wasPity = false
        local selected: LootConfig.LootEntry

        -- Check pity first
        local pityRarity = checkPity(player, tableId)
        if pityRarity then
            -- Force a drop of this rarity
            wasPity = true
            local candidates: {LootConfig.LootEntry} = {}
            for _, entry in lootTable.entries do
                if entry.rarity == pityRarity then
                    table.insert(candidates, entry)
                end
            end
            if #candidates > 0 then
                selected = candidates[rng:NextInteger(1, #candidates)]
            else
                selected = weightedSelect(lootTable.entries, luckMultiplier)
                wasPity = false
            end
        else
            selected = weightedSelect(lootTable.entries, luckMultiplier)
        end

        -- Handle noDuplicates
        if lootTable.noDuplicates and rolledItems[selected.itemId] then
            -- Re-roll without the duplicate (up to 3 attempts)
            local filteredEntries: {LootConfig.LootEntry} = {}
            for _, entry in lootTable.entries do
                if not rolledItems[entry.itemId] then
                    table.insert(filteredEntries, entry)
                end
            end
            if #filteredEntries > 0 then
                selected = weightedSelect(filteredEntries, luckMultiplier)
            end
            -- If still a duplicate after filtering, allow it (all items already rolled)
        end

        rolledItems[selected.itemId] = true

        -- Quantity roll
        local qty = 1
        if selected.minQuantity and selected.maxQuantity then
            qty = rng:NextInteger(selected.minQuantity, selected.maxQuantity)
        end

        table.insert(results, {
            itemId = selected.itemId,
            rarity = selected.rarity,
            quantity = qty,
            wasPity = wasPity,
        })

        -- Update pity counters
        updatePity(player, tableId, selected.rarity)
    end

    return results
end

--[[
    Returns the probability of each entry in a loot table (for UI display).
    Accounts for luck multiplier.
]]
function LootRoller.getProbabilities(
    tableId: string,
    luckMultiplier: number?
): {[string]: number}
    local lootTable = LootConfig.TABLES[tableId]
    if not lootTable then return {} end

    local luck = luckMultiplier or 1.0
    local totalWeight = 0
    local weights: {[string]: number} = {}

    for _, entry in lootTable.entries do
        local weight = entry.weight
        local rarity = LootConfig.RARITIES[entry.rarity]
        if rarity and luck > 1.0 and entry.rarity ~= "common" then
            weight = weight * luck
        end
        weights[entry.itemId] = weight
        totalWeight += weight
    end

    local probabilities: {[string]: number} = {}
    for itemId, weight in weights do
        probabilities[itemId] = weight / totalWeight
    end

    return probabilities
end

return LootRoller
```

### Integration with Combat

```lua
-- In CombatService, when an enemy is killed:
local function onEnemyKilled(killer: Player, enemyType: string)
    local tableId = EnemyConfig.ENEMIES[enemyType].lootTable
    if not tableId then return end

    -- Luck from player stats/buffs
    local luck = ModifierStack.resolve(killer, "luck", 1.0)

    local drops = LootRoller.roll(killer, tableId, luck)

    for _, drop in drops do
        Inventory.addItem(killer, drop.itemId, drop.quantity)
    end

    -- Send drop notification to client
    Remotes.LootDropped:FireClient(killer, drops)
end
```

## Expected Drop Rates by Rarity

With the standard rarity weights (total = 1526):

| Rarity | Weight | Probability | ~1 in X | Pity Guarantee |
|--------|--------|-------------|---------|----------------|
| Common | 1000 | 65.53% | 1.5 | -- |
| Uncommon | 400 | 26.21% | 3.8 | -- |
| Rare | 100 | 6.55% | 15.3 | 20 rolls |
| Epic | 20 | 1.31% | 76.3 | 50 rolls |
| Legendary | 5 | 0.33% | 305.2 | 100 rolls |
| Mythic | 1 | 0.066% | 1526 | 200 rolls |

With 2x luck multiplier (non-common weights doubled, total = 2052):

| Rarity | Adj Weight | Probability | ~1 in X |
|--------|-----------|-------------|---------|
| Common | 1000 | 48.73% | 2.1 |
| Uncommon | 800 | 38.99% | 2.6 |
| Rare | 200 | 9.75% | 10.3 |
| Epic | 40 | 1.95% | 51.3 |
| Legendary | 10 | 0.49% | 205.2 |
| Mythic | 2 | 0.097% | 1026 |

## Variants

| Variant | Description | Use Case |
|---------|-------------|----------|
| **Simple weighted** | Basic weight selection, no pity | Casual games, prototype |
| **Pity system** | Guaranteed rare after X fails | Gacha, RPG progression |
| **Multi-roll** | Multiple items per table | Chest loot, boss drops |
| **Luck-modified** | Player stats affect probabilities | RPG with luck stat |
| **Tiered tables** | Roll rarity first, then item within rarity | Gacha banners, card packs |
| **Seasonal/rotating** | Different tables by date/event | Live ops, limited-time events |

## Pitfalls

- **Client-side rolls.** The client must never determine what drops. Exploiters can manipulate `math.random()` seeds or force specific outcomes. All rolls happen on the server with `Random.new()`.
- **Integer weights with math.random.** Using `math.random(1, totalWeight)` only works with integer weights and cannot represent probabilities below 1/totalWeight. Use `Random:NextNumber()` (0-1 float) for decimal-precision weights.
- **Percentage-based tables.** Requiring weights to sum to 100 (or 1.0) means adding a new item requires adjusting every other weight. Use relative weights instead -- they scale naturally.
- **Missing pity persistence.** Pity counters must be saved to DataStore, not just session memory. If a player logs out after 99 rolls toward a legendary pity, they should resume at 99 next session.
- **Luck without caps.** Uncapped luck multipliers can make rare items trivially common. Cap luck at 2-3x maximum.
- **Displaying exact probabilities.** Showing "0.066% chance" may discourage players. Consider showing "Very Rare" labels instead of exact numbers for the rarest tiers.

## Related

- [[combat-system]] -- enemy kills trigger loot rolls
- [[damage-formulas]] -- weapon stats from loot affect damage
- [[daily-rewards]] -- daily reward boxes use weighted tables
- [[quest-system]] -- quest rewards may use loot tables

## Sources

- [Programming Loot Tables](wiki/raw/community/articles/game-mechanics/loot-tables-rarity.md)
- [Weighted Chance System](wiki/raw/community/articles/game-mechanics/loot-tables-rarity.md)
- [A Guide on Rarities](wiki/raw/community/articles/game-mechanics/loot-tables-rarity.md)
