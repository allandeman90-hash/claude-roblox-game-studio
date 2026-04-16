# Loot Tables and Rarity Systems

**Sources:**
- https://devforum.roblox.com/t/programming-loot-tables/458236
- https://devforum.roblox.com/t/weighted-chance-system/1373953
- https://devforum.roblox.com/t/a-guide-on-rarities/3002622
- https://devforum.roblox.com/t/lootplan-random-loot-generation-made-easy/463702
- https://devforum.roblox.com/t/introducing-lootr-a-simple-percentage-and-weight-based-loot-table-module/2845803
**Captured:** 2026-04-15

## Weighted Random Selection Algorithm

Core algorithm from "Programming Loot Tables" tutorial:

```lua
local function getTotalWeightOfLootTable(lootTable)
    local weight = 0
    for _, v in ipairs(lootTable) do
        weight = weight + v.Weight
    end
    return weight
end

function ItemService:GetRandomItemFromLootTable(lootTable)
    local totalWeight = getTotalWeightOfLootTable(lootTable)
    local randomNumber = math.random(totalWeight)
    for _, entry in ipairs(lootTable) do
        if randomNumber <= entry.Weight then
            return entry.Item
        else
            randomNumber = randomNumber - entry.Weight
        end
    end
end
```

## Weight-Based Rarity System

From "A Guide on Rarities":

```lua
local LootTable = {
    {name = "Blue Marble", weight = 50},
    {name = "Yellow Marble", weight = 20},
    {name = "Green Marble", weight = 5},
}
```

Percentage = (item_weight / total_weight) * 100
- Blue: (50/75) * 100 = 66.6%
- Yellow: (20/75) * 100 = 26.7%
- Green: (5/75) * 100 = 6.7%

### Selection with Decimal Precision

```lua
function RaritySystem.TotalWeight(LootTable)
    local TotalWeight = 0
    for i, item in (LootTable) do
        TotalWeight = TotalWeight + item.weight
    end
    return TotalWeight
end
```

Uses random decimal (0-1) and subtracts each item's percentage until match. More precise than math.random(1,100) — allows decimal probabilities like 0.01%.

## Alternative Approaches

### Cumulative Probability Method (from iGottic)

```lua
-- Values represent cumulative thresholds
local rarities = {Common = 0, Rare = 0.6, Legendary = 0.91}
-- math.random() returns 0-1, select based on threshold matching
```

### Frequency Table Method (from loleris)

Expands rarities as repeated table entries, then randomly selects. Simpler but uses more memory.

## Community Libraries

- LootPlan: Lightweight, supports "single" and "multi" generation classes
- LootR: Supports both percentage and weight based tables
- Simple RNG Module: Weighted random selections based on rarity percentages

## Key Advantage of Weights Over Percentages

Weights are relative values that don't need to sum to 100. Adding or removing items doesn't require recalculating all other entries.
