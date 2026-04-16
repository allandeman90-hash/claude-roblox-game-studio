---
title: Shop System
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/shop-gui-currency-purchases.md
  - wiki/raw/community/articles/game-mechanics/fullshop-currency-shop.md
related:
  - "[[rpg-progression]]"
  - "[[equipment-system]]"
  - "[[crafting-system]]"
  - "[[inventory-pattern]]"
  - "[[DataStoreService]]"
  - "[[daily-rewards]]"
tags: [pattern, shop, currency, purchasing, catalog, rotating-items, rpg, economy]
---

# Shop System

> In-game currency shop where players buy items from a server-validated catalog -- distinct from the Robux/GamePass shop managed by MarketplaceService.

## Summary

An in-game shop lets players spend earned currency (Gold, Coins, Gems) on items, equipment, consumables, and cosmetics. The item catalog is config-driven: add a new item by editing a table, not by writing new scripts. All purchases are server-authoritative -- the client renders the shop UI and fires a purchase request, the server validates currency balance, item availability, and purchase limits before deducting currency and granting the item. Advanced features include dynamic pricing (supply/demand or time-limited sales), a featured/rotating section that refreshes on a timer, and a clear separation from the Robux GamePass shop (which uses MarketplaceService and ProcessReceipt, not this system).

## Implementation

### Item Catalog (Config-Driven)

```lua
-- ReplicatedStorage/Shared/Config/ShopConfig.lua
local ShopConfig = {}

ShopConfig.Currency = {
    Gold = { icon = "rbxassetid://123456", displayName = "Gold" },
    Gems = { icon = "rbxassetid://789012", displayName = "Gems" },
}

ShopConfig.Categories = {
    "Weapons",
    "Armor",
    "Consumables",
    "Materials",
    "Cosmetics",
}

ShopConfig.Items = {
    -- Permanent catalog items
    WoodenSword = {
        name = "Wooden Sword",
        description = "A basic training sword.",
        category = "Weapons",
        price = { currency = "Gold", amount = 100 },
        templateId = "WoodenSword",         -- references item template
        stock = -1,                         -- -1 = unlimited
        maxPerPlayer = 1,                   -- purchase limit (nil = no limit)
        levelRequirement = 1,
        icon = "rbxassetid://111111",
    },
    HealthPotion = {
        name = "Health Potion",
        description = "Restores 50 HP.",
        category = "Consumables",
        price = { currency = "Gold", amount = 25 },
        templateId = "HealthPotion",
        stock = -1,
        maxPerPlayer = nil,                 -- unlimited purchases
        levelRequirement = 1,
        icon = "rbxassetid://222222",
    },
    IronChestplate = {
        name = "Iron Chestplate",
        description = "Sturdy iron armor. +15 Defense.",
        category = "Armor",
        price = { currency = "Gold", amount = 500 },
        templateId = "IronChestplate",
        stock = -1,
        maxPerPlayer = 1,
        levelRequirement = 10,
        icon = "rbxassetid://333333",
    },
    XPBooster = {
        name = "XP Booster (1hr)",
        description = "Double XP for 1 hour.",
        category = "Consumables",
        price = { currency = "Gems", amount = 50 },
        templateId = "XPBooster",
        stock = -1,
        maxPerPlayer = nil,
        levelRequirement = 1,
        icon = "rbxassetid://444444",
    },
}

return ShopConfig
```

### Purchase Validation (Server-Authoritative)

```lua
-- ServerStorage/Services/ShopService.lua
local ShopService = {}

local Config = require(game.ReplicatedStorage.Shared.Config.ShopConfig)

function ShopService.purchase(playerData, shopItemId: string): (boolean, string?)
    local shopItem = Config.Items[shopItemId]
    if not shopItem then
        return false, "Item does not exist in shop"
    end

    -- Check level requirement
    if playerData.progression.level < shopItem.levelRequirement then
        return false, "Level too low"
    end

    -- Check purchase limit
    if shopItem.maxPerPlayer then
        local purchased = playerData.shop.purchaseCounts[shopItemId] or 0
        if purchased >= shopItem.maxPerPlayer then
            return false, "Purchase limit reached"
        end
    end

    -- Check stock (for limited items)
    if shopItem.stock > 0 then
        -- Global stock tracked in MemoryStoreService or server state
        local remaining = ShopService.getGlobalStock(shopItemId)
        if remaining <= 0 then
            return false, "Out of stock"
        end
    end

    -- Determine effective price (apply discounts)
    local effectivePrice = ShopService.getEffectivePrice(playerData, shopItemId)

    -- Check currency balance
    local currencyType = shopItem.price.currency
    if (playerData.currency[currencyType] or 0) < effectivePrice then
        return false, "Insufficient " .. currencyType
    end

    -- === All checks passed: execute purchase ===

    -- Deduct currency
    playerData.currency[currencyType] -= effectivePrice

    -- Grant item
    InventoryService.addItem(playerData, shopItem.templateId, 1)

    -- Track purchase count
    playerData.shop.purchaseCounts[shopItemId] =
        (playerData.shop.purchaseCounts[shopItemId] or 0) + 1

    -- Decrement global stock if limited
    if shopItem.stock > 0 then
        ShopService.decrementGlobalStock(shopItemId)
    end

    return true, nil
end
```

### Dynamic Pricing

```lua
-- Price modifiers: sales, bulk discounts, VIP tiers
function ShopService.getEffectivePrice(playerData, shopItemId: string): number
    local shopItem = Config.Items[shopItemId]
    local basePrice = shopItem.price.amount

    -- Check active sales
    local sale = ShopService.getActiveSale(shopItemId)
    if sale then
        basePrice = math.floor(basePrice * (1 - sale.discountPercent))
    end

    -- VIP discount (e.g., GamePass owners get 10% off)
    if playerData.vip then
        basePrice = math.floor(basePrice * 0.9)
    end

    -- Minimum price floor (never free)
    return math.max(1, basePrice)
end

-- Sale data (stored in server memory or config)
ShopService.ActiveSales = {
    -- { itemId = "HealthPotion", discountPercent = 0.5, endsAt = os.time() + 86400 }
}

function ShopService.getActiveSale(shopItemId: string)
    for _, sale in ipairs(ShopService.ActiveSales) do
        if sale.itemId == shopItemId and os.time() < sale.endsAt then
            return sale
        end
    end
    return nil
end
```

### Featured / Rotating Items

```lua
-- Rotating shop refreshes every 24 hours with a curated selection
ShopConfig.RotatingShop = {
    refreshIntervalSeconds = 86400,  -- 24 hours
    slotCount = 4,                   -- 4 featured items

    -- Pool of items eligible for rotation
    pool = {
        { itemId = "RareHelmet",     weight = 10 },
        { itemId = "EnchantedBow",   weight = 5 },
        { itemId = "GoldenArmor",    weight = 3 },
        { itemId = "MysticStaff",    weight = 5 },
        { itemId = "SpeedBoots",     weight = 8 },
        { itemId = "CritRing",       weight = 7 },
    },
}

function ShopService.getRotatingItems(): {string}
    -- Seed random with day number for deterministic rotation
    -- All players see the same featured items on the same day
    local dayNumber = math.floor(os.time() / 86400)
    local rng = Random.new(dayNumber * 31337)

    local pool = table.clone(ShopConfig.RotatingShop.pool)
    local selected = {}

    for _ = 1, ShopConfig.RotatingShop.slotCount do
        if #pool == 0 then break end

        local totalWeight = 0
        for _, entry in ipairs(pool) do
            totalWeight += entry.weight
        end

        local roll = rng:NextNumber() * totalWeight
        local cumulative = 0

        for i, entry in ipairs(pool) do
            cumulative += entry.weight
            if roll <= cumulative then
                table.insert(selected, entry.itemId)
                table.remove(pool, i)
                break
            end
        end
    end

    return selected
end
```

### Remote Event Handler

```lua
-- Server remote handler
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

Remotes.PurchaseItem.OnServerEvent:Connect(function(player, shopItemId)
    -- Type validation
    if typeof(shopItemId) ~= "string" then return end

    local data = PlayerDataService.getData(player)
    if not data then return end

    local ok, err = ShopService.purchase(data, shopItemId)

    Remotes.PurchaseResult:FireClient(player, {
        success = ok,
        itemId = shopItemId,
        error = err,
        newBalance = data.currency,
    })
end)

-- Client requests current rotating shop
Remotes.GetRotatingShop.OnServerInvoke = function(player)
    return {
        items = ShopService.getRotatingItems(),
        refreshesAt = ShopService.getNextRefreshTime(),
    }
end
```

### Comparison with GamePass Shop

| Aspect | In-Game Currency Shop | GamePass/DevProduct Shop |
|--------|----------------------|--------------------------|
| **Currency** | Gold, Gems (earned in-game) | Robux (real money) |
| **API** | Custom RemoteEvents | MarketplaceService |
| **Receipt** | Server deducts from player data | ProcessReceipt callback |
| **Refund risk** | None (virtual currency) | Roblox can reverse charges |
| **Idempotency** | Track purchase counts | ProcessReceipt must be idempotent |
| **Catalog** | Config module in ReplicatedStorage | Creator Dashboard product IDs |
| **Regulation** | No real-money concerns | Subject to platform TOS |

## Data Schema

What persists in DataStore per player:

```lua
{
    currency = {
        Gold = 2500,
        Gems = 30,
    },
    shop = {
        purchaseCounts = {
            WoodenSword = 1,     -- bought once (limit 1)
            HealthPotion = 12,   -- bought 12 times (no limit)
        },
        lastRotatingRefresh = 1713100800,  -- timestamp of last seen rotation
    },
    vip = false,  -- GamePass VIP status (synced from MarketplaceService)
    version = 1,
}
```

## Formulas

**Dynamic price:** `effectivePrice = max(1, floor(basePrice * (1 - saleDiscount) * vipMultiplier))`

**Rotating shop seed:** `dayNumber = floor(os.time() / 86400)`, seeded into `Random.new(dayNumber * 31337)`. All servers produce the same selection for the same UTC day.

**Economy sink rate:** Track gold earned vs gold spent per session. If `spentRatio < 0.3` (players spending less than 30% of earnings), prices are too high or items are not desirable. If `spentRatio > 0.8`, the economy is draining too fast and players will run out of gold.

## Pitfalls

- **Client-side currency deduction.** "If you handled the money deduction on the Client, an exploiter could simply delete the line that subtracts money, getting everything for free." All currency changes happen server-side only.
- **No purchase limit tracking.** Without `maxPerPlayer` enforcement, a player can buy 100 Wooden Swords and flood their inventory or resell them. Track purchase counts per item per player.
- **Rotating shop desync.** If the rotation seed is based on `os.time()`, all servers must use the same time source (they do -- Roblox servers use UTC). Do not use `tick()` or `os.clock()` which differ per server.
- **Stock race condition.** For limited-stock items across multiple servers, use MemoryStoreService sorted maps or counters. A simple server-local counter will oversell because each server tracks independently.
- **Missing price floor.** Stacked discounts (50% sale + 10% VIP) can reduce prices to 0. Always enforce `max(1, price)`.
- **Shop UI shows stale prices.** If a sale starts while a player has the shop open, they see old prices. Refresh the shop UI on open, not on join. Or push sale updates to connected clients via RemoteEvent.
- **Mixing in-game and Robux shops.** Keep them in separate UI tabs with clear labeling. Players must understand which items cost earned currency vs real money. Regulatory and Roblox TOS implications apply to Robux-priced items.

## Related

- [[rpg-progression]] -- level gates on shop items
- [[equipment-system]] -- shop sells equipment
- [[crafting-system]] -- shop sells crafting materials
- [[inventory-pattern]] -- purchased items go into inventory
- [[daily-rewards]] -- shop discount coupons as daily rewards
- [[DataStoreService]] -- currency and purchase counts persisted

## Sources

- [Shop GUI Part 2: Currency, Items, Purchases](../raw/community/articles/game-mechanics/shop-gui-currency-purchases.md) -- leaderstats currency, RemoteEvent purchase flow, server-side validation, ProcessReceipt for Robux
- [FullShop: In-game Currency Shop](../raw/community/articles/game-mechanics/fullshop-currency-shop.md) -- ObjectModule catalog pattern, viewport previews, inventory persistence
