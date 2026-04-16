---
title: dev-product
type: monetization
category: monetization
subcategory: devproduct
owner: monetization-lead
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/devproduct/devproduct-setup-and-lifecycle.md
  - wiki/raw/community/monetization/devproduct/receiptinfo-reference.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/developer-products.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/player-data-purchasing.md
related:
  - "[[MarketplaceService]]"
  - "[[process-receipt-idempotency]]"
  - "[[game-pass]]"
  - "[[robux-price-tiers]]"
  - "[[ethical-monetization]]"
tags: [monetization, devproduct]
---

# Developer Product (DevProduct)

> Consumable, repeatable Robux purchases processed through the authoritative `ProcessReceipt` callback. The backbone of in-game currency packs, revives, boosts, and any item a player can buy more than once.

## Summary

A Developer Product is a purchasable item that a player can buy multiple times. Unlike GamePasses (one-time unlocks), DevProducts are consumable: each purchase triggers a `ProcessReceipt` callback that the server must handle idempotently. Roblox retries the callback until the server returns `PurchaseGranted`, making reliable grant logic critical.

Roblox takes approximately 30% of every DevProduct sale. The remaining 70% becomes Earned Robux.

## GamePass vs Developer Product

| | GamePass | Developer Product |
|---|----------|-------------------|
| Granted | Once, persistently | Every purchase |
| Detected | `UserOwnsGamePassAsync` | `ProcessReceipt` callback |
| Multiple buys | No | Yes |
| Processing | Grant on join + on prompt | `ProcessReceipt` is authoritative |

## Creating a Developer Product

1. Go to [Creations](https://create.roblox.com/dashboard/creations) and select an experience.
2. Navigate to **Monetization > Developer Products**.
3. Click **Create a Developer Product**.
4. Upload an icon (max 512x512 px, .jpg/.png/.bmp).
5. Enter a name and description.
6. Set price in Robux. **Minimum: 1 R$. Maximum: 1,000,000,000 R$.**
7. Click **Create Developer Product**.

The experience must be **published** before products can be created.

## Prompting a Purchase (Client)

```lua
-- LocalScript
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local PRODUCT_ID = 123456789

local button = script.Parent
button.Activated:Connect(function()
    MarketplaceService:PromptProductPurchase(Players.LocalPlayer, PRODUCT_ID)
end)
```

## Fetching Product Info for Dynamic Shop

```lua
local MarketplaceService = game:GetService("MarketplaceService")

local ok, info = pcall(function()
    return MarketplaceService:GetProductInfo(123456789, Enum.InfoType.Product)
end)

if ok and info then
    -- info.Name, info.Description, info.PriceInRobux,
    -- info.IconImageAssetId, info.IsForSale
end
```

**Never hard-code prices** in the UI. Use `GetProductInfo` or `GetDeveloperProductsAsync` to display live prices that respect regional pricing and Roblox Plus discounts.

## Processing Purchases (Server) -- The Critical Path

`ProcessReceipt` is the **only** authoritative grant path. **Do NOT** use `PromptProductPurchaseFinished` to process purchases -- it merely reports UI state and Roblox will not retry it.

The callback must be idempotent. See [[process-receipt-idempotency]] for the full canonical pattern.

### Minimal idempotent implementation

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService   = game:GetService("DataStoreService")
local Players            = game:GetService("Players")

local PurchaseHistory = DataStoreService:GetDataStore("PurchaseHistory")

local Products = {
    [123456789] = function(receipt, player)
        -- Grant 100 coins
        player.leaderstats.Coins.Value += 100
        return true
    end,
    [987654321] = function(receipt, player)
        -- Grant 50 gems
        player.leaderstats.Gems.Value += 50
        return true
    end,
}

function MarketplaceService.ProcessReceipt(receiptInfo)
    -- 1. Idempotency check: has this receipt already been granted?
    local key = receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId
    local alreadyGranted = pcall(function()
        return PurchaseHistory:GetAsync(key)
    end)
    if alreadyGranted then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    -- 2. Player must be in-game to grant
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- 3. Find and execute the product handler
    local handler = Products[receiptInfo.ProductId]
    if not handler then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local ok, granted = pcall(handler, receiptInfo, player)
    if not ok or not granted then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- 4. Persist the grant BEFORE returning PurchaseGranted
    local saveOk = pcall(function()
        PurchaseHistory:SetAsync(key, true)
    end)
    if not saveOk then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

### ProcessReceipt return values

| Return | Meaning |
|--------|---------|
| `PurchaseGranted` | Reward delivered AND persisted. Roblox stops retrying. Return ONLY after DataStore write succeeds. |
| `NotProcessedYet` | Something failed. Roblox retries later (same server, future server, next join). Use on ANY error. |

There is **no "purchase denied"** return. Once a player pays, you owe the grant or must keep retrying forever.

## ReceiptInfo Fields Reference

| Field | Type | Description |
|-------|------|-------------|
| `PurchaseId` | string | Unique transaction ID. The idempotency key. Stable across retries. |
| `PlayerId` | number | `UserId` of the purchasing player. |
| `ProductId` | number | The DevProduct ID. Match against your handler table. |
| `PlaceIdWherePurchased` | number | PlaceId where the purchase was prompted. Important for multi-place universes. |
| `CurrencySpent` | number | Amount of currency spent (includes the actual price if price optimization is active). |
| `CurrencyType` | Enum | Always `Enum.CurrencyType.Robux`. |

### Idempotency key

The canonical key is `PlayerId:PurchaseId`. Both halves are necessary -- Roblox guarantees PurchaseId uniqueness per user, not globally.

## Multi-Place Universe Gotcha

`PlaceIdWherePurchased` is critical in multi-place games. A player can buy in Place A, then teleport to Place B before the callback finishes. `ProcessReceipt` may fire in Place B. The handler must be **place-agnostic** -- never gate grants on `game.PlaceId`.

## Retry Behavior

Roblox retries `ProcessReceipt` at irregular intervals:

- **Same server**: if the handler errored and returned `NotProcessedYet`, retry within seconds.
- **Different server / later session**: if the player disconnected, fires next time they join ANY place in the universe.
- **Long-tail**: receipts have been observed to re-fire days or weeks later for dormant players.

This is why idempotency is non-negotiable.

## Test Mode

Roblox provides Test Mode to validate `ProcessReceipt` before public release:

1. Toggle **Test mode** on the product in the dashboard.
2. Only you and group members can see/buy the product.
3. **Test mode purchases still cost real Robux** -- use cheap test products (1-5 R$).
4. Enable test mode **before** enabling external sales.

### Test checklist

1. Create DevProduct with 1 R$ test price.
2. Add handler in Products table.
3. Enable test mode.
4. Buy from a live server with an in-group account.
5. Verify reward granted, DataStore row written, no duplicate grant.
6. Verify second buy also grants (consumable).
7. Disable test mode, set final price.
8. Optional: enable external sales.

## External Sales

Products can be sold from the **Store** tab of the experience detail page:

1. Complete Test Mode validation first.
2. Enable **External Purchases** in settings.
3. Toggle individual products for external sale.

### External sale restrictions

- **No paid random items** (lootboxes).
- **No limited-quantity** products.
- **Thumbnails required** for external visibility.

## Personalized Recommendations

Same APIs as GamePasses:

- **`RankProductsAsync`** -- personalized ranking of a product list. Call once at join.
- **`RecommendTopProductsAsync`** -- up to 50 recommended items. Requires 1+ sale in past 28 days.

## Analytics

Access from **Monetization > Developer Products > Analytics**:

- Top products over a selected period.
- Time-series sales and net revenue.
- Catalog sorted by sales/revenue.

## Ethical Check

- Consumables with diminishing returns are healthier than linear-value stacking (see [[ethical-monetization]]).
- If a DevProduct involves randomness (e.g., gacha roll), display odds before purchase.
- Cap useful spend per player where possible.

## Pitfalls

- Using `PromptProductPurchaseFinished` to grant items. It does not retry and is not authoritative.
- Returning `PurchaseGranted` before persisting the grant. If the save fails, the player loses the item permanently.
- Forgetting the multi-place case. ProcessReceipt can fire on a different server than where the purchase prompt was shown.
- Not testing with Test Mode before going live.
- Roblox does **not** record per-user DevProduct purchase history. Store it yourself.

## Related

- [[MarketplaceService]]
- [[process-receipt-idempotency]]
- [[game-pass]]
- [[robux-price-tiers]]
- [[ethical-monetization]]

## Sources

- [DevProduct Setup and Lifecycle](../raw/community/monetization/devproduct/devproduct-setup-and-lifecycle.md) -- community synthesis from official docs
- [ReceiptInfo Reference](../raw/community/monetization/devproduct/receiptinfo-reference.md) -- field-level ProcessReceipt reference
- [Developer Products (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/developer-products.md) -- official documentation
- [Player Data and Purchasing Systems](../raw/roblox-creator-docs/best-practices/monetization/player-data-purchasing.md) -- Roblox reference architecture
