---
title: game-pass
type: monetization
category: monetization
subcategory: gamepass
owner: monetization-lead
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/gamepass/pricing-strategy.md
  - wiki/raw/community/monetization/gamepass/gamepass-setup-and-verification.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/passes.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/price-optimization.md
related:
  - "[[MarketplaceService]]"
  - "[[dev-product]]"
  - "[[robux-price-tiers]]"
  - "[[ethical-monetization]]"
  - "[[premium-benefits]]"
tags: [monetization, gamepass]
---

# GamePass

> Permanent one-time Robux purchases that grant persistent in-experience privileges. The primary monetization tool for VIP perks, cosmetic bundles, and convenience features.

## Summary

A GamePass (officially "Pass") is a one-time purchase that permanently unlocks a benefit for the buyer. Unlike Developer Products, a GamePass cannot be bought again once owned. Ownership is checked via `MarketplaceService:UserOwnsGamePassAsync` and benefits are granted through two mandatory code paths: on player join and on live purchase.

Roblox takes approximately 30% of every GamePass sale. The remaining 70% becomes Earned Robux, eligible for DevEx.

## Creating a GamePass

1. Go to [Creations](https://create.roblox.com/dashboard/creations) and select an experience.
2. Navigate to **Monetization > Passes**.
3. Click **Create a Pass**.
4. Upload an icon (max 512x512 px, .jpg/.png/.bmp). Content outside the circular boundary is cropped.
5. Enter a name and description.
6. Click **Create Pass**.

Set the price under the pass's **Sales** settings. Minimum price: 1 R$. Maximum price: 1,000,000,000 R$.

To use in scripts, copy the **Asset ID** from the pass's context menu in the dashboard.

## The Dual-Path Grant Pattern

Every GamePass benefit **must** be wired on both code paths:

1. **On player join** -- check `UserOwnsGamePassAsync` for each pass the game supports and apply benefits if owned.
2. **On in-session purchase** -- listen for `PromptGamePassPurchaseFinished` and apply benefits immediately so the player does not need to rejoin.

Skipping path (1) means returning players do not receive perks. Skipping path (2) forces a rejoin after purchase.

### Hard rules

- **Never use `ProcessReceipt` for GamePasses.** It only fires for Developer Products.
- **Never trust `PromptGamePassPurchaseFinished` alone.** The event can be lost if the client disconnects mid-dialog.
- **Cache ownership per session** to avoid repeated API calls on every ability check.
- **`UserOwnsGamePassAsync` is async and can throw** -- always wrap in `pcall`.

### Server module: GamePassService

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local GamePassService = {}
GamePassService.Passes = {
    VIP       = 111111111,
    DoubleXP  = 222222222,
    BigBag    = 333333333,
}

-- Cache: [player][passId] = bool
local Ownership = setmetatable({}, { __mode = "k" })

local function getOwnershipTable(player)
    Ownership[player] = Ownership[player] or {}
    return Ownership[player]
end

local function checkOwnership(userId, passId)
    local ok, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(userId, passId)
    end)
    if not ok then
        warn("UserOwnsGamePassAsync failed:", result)
        return false
    end
    return result == true
end

function GamePassService.Owns(player, passId)
    local cache = getOwnershipTable(player)
    if cache[passId] == nil then
        cache[passId] = checkOwnership(player.UserId, passId)
    end
    return cache[passId]
end

-- Apply benefits for every owned pass at join time.
function GamePassService.ApplyBenefitsOnJoin(player)
    for _, id in pairs(GamePassService.Passes) do
        if GamePassService.Owns(player, id) then
            GamePassService.Grant(player, id)
        end
    end
end

-- Grant the actual perk. Edit per game.
function GamePassService.Grant(player, passId)
    if passId == GamePassService.Passes.VIP then
        player:SetAttribute("VIP", true)
    elseif passId == GamePassService.Passes.DoubleXP then
        player:SetAttribute("XPMultiplier", 2)
    elseif passId == GamePassService.Passes.BigBag then
        player:SetAttribute("InventorySize", 100)
    end
end

-- Path 1: on join
Players.PlayerAdded:Connect(function(player)
    GamePassService.ApplyBenefitsOnJoin(player)
end)

-- Path 2: on live purchase
MarketplaceService.PromptGamePassPurchaseFinished:Connect(
    function(player, passId, wasPurchased)
        if wasPurchased then
            local cache = getOwnershipTable(player)
            cache[passId] = true
            GamePassService.Grant(player, passId)
        end
    end
)

return GamePassService
```

### Client: purchase prompt

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local VIP_PASS = 111111111
local buyButton = script.Parent

buyButton.Activated:Connect(function()
    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, VIP_PASS)
end)
```

## Dynamic Shop UI

Use `GetProductInfo` with `Enum.InfoType.GamePass` to fetch live price, name, and icon. This keeps the shop UI in sync with dashboard changes, supports price optimization, and displays correct regional pricing and Roblox Plus discounts.

```lua
local MarketplaceService = game:GetService("MarketplaceService")

local ok, info = pcall(function()
    return MarketplaceService:GetProductInfo(111111111, Enum.InfoType.GamePass)
end)

if ok and info and info.IsForSale then
    -- info.PriceInRobux, info.Name, info.Description, info.IconImageAssetId
    print(info.Name, "costs", info.PriceInRobux, "R$")
end
```

**Never hard-code prices in the UI.** Hard-coded prices break price optimization tests and display incorrect amounts for users with regional pricing or Roblox Plus discounts.

## Personalized Recommendations

Two product intelligence APIs help surface passes to the right players:

- **`RankProductsAsync`** -- takes a list of product IDs and returns a personalized ranking. Call once at join (strict rate limit).
- **`RecommendTopProductsAsync`** -- returns up to 50 items the user is most likely to buy. Requires at least one sale in the past 28 days.

Both accept mixed `Enum.InfoType.GamePass` and `Enum.InfoType.Product` identifiers.

## Promoting Passes on the Buy Robux Page

Passes can be opted in to appear on Roblox's Buy Robux page as free bonuses with Robux purchases. Requirements:

- Price between 49 and 800 R$ (or off-sale).
- Must include a thumbnail.
- Cannot grant paid random items.
- Must comply with Community Standards.

Enable under the pass's **Promotions** settings.

## Pricing Strategy

### Charm-pricing defaults

Prices ending in 9 consistently outperform round numbers. The empirically dominant price points:

| Price (R$) | Target | Net to dev (~70%) | Approx USD (DevEx $0.0038) |
|-----------:|--------|------------------:|---------------------------:|
| 49 | Impulse buy, highest conversion | ~34 | ~$0.13 |
| 99 | Low commitment entry | ~69 | ~$0.26 |
| 199 | Flagship casual tier | ~139 | ~$0.53 |
| 499 | Engaged-player tier | ~349 | ~$1.33 |
| 999 | Premium anchor | ~699 | ~$2.66 |
| 4999 | Whale / status symbol | ~3499 | ~$13.30 |

### Tier structure

Successful games ship 3+ passes:

| Tier | Price range | Target audience | Typical offer |
|------|------------|-----------------|---------------|
| Low | 49-199 R$ | Casual / impulse | QoL unlock, cosmetic, 2x walkspeed |
| Mid | 299-799 R$ | Engaged regular | 2x coins, VIP area, exclusive pet |
| High | 999-4999 R$ | Dedicated superfan | All-in-one bundle, exclusive rare |

Low-tier passes convert ~2-5% of active players. High-tier passes convert <0.5% but can be the single largest revenue driver by per-sale size.

### Anchoring

A visible 999 R$ VIP pass makes a 199 R$ multiplier feel cheap. List the most expensive pass first in the shop UI to trigger the "decoy" effect.

### Formula-based optimization

With sufficient sales data, fit a linear demand curve and find the revenue-maximizing price:

```
Revenue(price) = price * (a - b * price)
Optimal price  = a / (2b)
```

1. Record baseline (visits, sales, price) over 3-7 days.
2. Change price to a test point.
3. Record second dataset over comparable window.
4. Fit line, find parabola apex.
5. Round to nearest charm price (e.g. 205 -> 199).

For high-volume experiences (60,000+ transactions in 30 days), use Roblox's built-in **Price Optimization** tool instead. It runs automated A/B tests and provides recommendations with projected revenue impact.

## Ethical Check

- GamePasses must not grant power advantages > 20-30% above free alternatives (see [[ethical-monetization]]).
- Passes marked "limited time" should return in future seasons.
- Always display the pass's benefit clearly before purchase.
- See [[robux-price-tiers]] for aligning prices to player Robux purchase tiers.

## Analytics

Access pass analytics from **Monetization > Passes > Analytics** in Creator Hub:

- Top passes over a selected time period
- Time-series sales and net revenue
- Catalog sorted by sales/revenue
- Acquisition from Buy Robux page promotions
- Joins from promoted passes

## Pitfalls

- Calling `UserOwnsGamePassAsync` on every frame or ability use. Cache once per session.
- Expecting `ProcessReceipt` to fire for passes. It does not. Only DevProducts.
- Hard-coding prices in the UI. Breaks price optimization, regional pricing, and Roblox Plus discounts.
- Roblox does **not** record per-user pass purchase history. If you need it, store the data yourself via DataStoreService.

## Related

- [[MarketplaceService]]
- [[dev-product]]
- [[robux-price-tiers]]
- [[ethical-monetization]]
- [[premium-benefits]]

## Sources

- [GamePass Setup and Verification](../raw/community/monetization/gamepass/gamepass-setup-and-verification.md) -- DevForum community synthesis
- [Pricing Strategy](../raw/community/monetization/gamepass/pricing-strategy.md) -- creation.dev pricing playbook
- [Passes (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/passes.md) -- official documentation
- [Price Optimization (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/price-optimization.md) -- A/B pricing tool
