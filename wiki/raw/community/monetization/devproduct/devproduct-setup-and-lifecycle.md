---
title: Developer Product Setup and Lifecycle
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/developer-products.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: monetization
subcategory: devproduct
tags: [devproduct, marketplaceservice, promptproduct, processreceipt, testmode]
---

# Developer Product Setup and Lifecycle

Developer Products (DevProducts) are consumables — purchasable multiple
times, not tied to a single unlock. Think Robux → in-game currency,
respawns, cosmetics-that-stack, one-use boosters.

They work fundamentally differently from GamePasses:

| | GamePass | Developer Product |
|---|----------|-------------------|
| Granted | Once, persistently | Every purchase |
| Detected | `UserOwnsGamePassAsync` | `ProcessReceipt` callback |
| Multiple buys? | No | Yes |
| Processing | Grant on join + on prompt | `ProcessReceipt` is authoritative |

## Creating a Developer Product

1. Open an experience on Creator Hub
2. **Monetization → Developer Products**
3. Click **Create a Developer Product**
4. Upload icon: **max 512×512 px**, .jpg / .png / .bmp
5. Name + description
6. Set price in Robux

### Price limits

- **Minimum price: 1 R$**
- **Maximum price: 1,000,000,000 R$** (1 billion Robux)

Experiences must be **published** before you can create products in
them.

## Prompting a purchase (client)

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

## Fetching product info for a dynamic shop

```lua
local MarketplaceService = game:GetService("MarketplaceService")

local function getProductInfo(productId)
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(
            productId,
            Enum.InfoType.Product
        )
    end)
    if ok and info then
        return {
            name  = info.Name,
            desc  = info.Description,
            price = info.PriceInRobux,
            icon  = info.IconImageAssetId,
            sale  = info.IsForSale,
        }
    end
end
```

## Processing purchases (server)

This is the authoritative grant path. See the
`processreceipt-idempotency-pattern.md` file for the full canonical
idempotent implementation. In brief:

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService   = game:GetService("DataStoreService")
local Players            = game:GetService("Players")

local PurchaseHistory = DataStoreService:GetDataStore("PurchaseHistory")

local Products = {
    [123456789] = function(receipt, player)
        player.leaderstats.Coins.Value += 100
        return true
    end,
    [987654321] = function(receipt, player)
        player.leaderstats.Gems.Value += 50
        return true
    end,
}

function MarketplaceService.ProcessReceipt(receiptInfo)
    local key = receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId
    if PurchaseHistory:GetAsync(key) then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local handler = Products[receiptInfo.ProductId]
    if not handler then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local ok, granted = pcall(handler, receiptInfo, player)
    if not ok or not granted then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local saveOk = pcall(function()
        PurchaseHistory:SetAsync(key, true)
    end)
    if not saveOk then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

**Do NOT** use `PromptProductPurchaseFinished` to process purchases.
That event merely reports the UI state; Roblox will NOT retry it if
the grant fails.

## Test mode

Roblox provides **Test Mode** for DevProducts so you can validate your
ProcessReceipt flow without releasing the product publicly:

- Toggle **Test mode** on the product in the dashboard
- In test mode, only you and members of your group can see + buy the
  product
- Test mode purchases **still cost Robux** — use cheap test products
  (1–5 R$)
- Enable test mode **before** enabling external sales

## External sales

Once ProcessReceipt is validated, you can enable **External Purchase
Settings** → individually toggle products for external sale. External
sales make products appear in the Store tab of your experience detail
page so users can buy from the website without entering the game.

### External sale restrictions

- **No paid random items** (lootboxes) on external sale
- **No limited-quantity** products on external sale
- **Thumbnails required** for external visibility

## Test mode vs production checklist

1. Create DevProduct (minimum setup, 1 R$ test price).
2. Add handler in Products table → ProcessReceipt.
3. Enable test mode on the product.
4. Buy in a live server from an in-group account.
5. Verify reward granted, DataStore row written, no duplicate grant.
6. Verify second buy also works (consumable).
7. Disable test mode, set final price.
8. Optional: enable external sales.

## Concrete Numbers / Examples

- **Min price**: 1 R$
- **Max price**: 1,000,000,000 R$
- **Icon**: max 512×512 px
- **Test mode**: purchases still cost real Robux
- **External sales**: no paid random / limited, thumbnail required
- **Purchase key pattern**: `PlayerId:PurchaseId`

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/developer-products.md
Captured: 2026-04-16
