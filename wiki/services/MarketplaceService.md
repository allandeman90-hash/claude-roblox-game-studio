---
title: MarketplaceService
type: service
category: services
subcategory: monetization
owner: monetization-lead
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/MarketplaceService.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/player-data-purchasing.md
  - .claude/agents/monetization-lead.md
related:
  - "[[game-pass]]"
  - "[[dev-product]]"
  - "[[process-receipt-idempotency]]"
  - "[[robux-price-tiers]]"
  - "[[premium-benefits]]"
  - "[[ethical-monetization]]"
  - "[[transaction-replay]]"
  - "[[DataStoreService]]"
tags: [roblox-class, monetization]
---

# MarketplaceService

> The API for all Robux-based transactions: GamePass purchases, DevProduct purchases, subscriptions, and Premium detection.

## Summary

`MarketplaceService` is the single integration point for monetization on Roblox. It handles three main transaction types:

1. **GamePasses** — permanent one-time purchases (VIP, double inventory, etc.)
2. **DevProducts** — consumable purchases (currency packs, revives, boosts)
3. **Subscriptions** — recurring purchases (beta feature on some experiences)

It also exposes Premium subscription detection via `Players.MembershipType`.

Correct use of `MarketplaceService` — especially the `ProcessReceipt` callback for DevProducts — is **mission-critical**. Bugs here cause lost Robux, double-grants, or player complaints. See [[process-receipt-idempotency]] for the required pattern.

## API Surface

### Purchase Prompts (Client-side)
- `:PromptGamePassPurchase(player: Player, gamePassId: number)` — Open the GamePass purchase UI.
- `:PromptProductPurchase(player: Player, productId: number)` — Open the DevProduct purchase UI.
- `:PromptSubscriptionPurchase(player: Player, subscriptionId: string)` — Open the Subscription purchase UI.
- `:PromptBundlePurchase(player: Player, bundleId: number)` — For avatar bundles.

### Queries
- `:UserOwnsGamePassAsync(userId: number, gamePassId: number) -> boolean` — Check if a user owns a specific GamePass. Yields. Cache results when possible.
- `:PlayerOwnsAsset(player: Player, assetId: number) -> boolean` — Check if a player owns a catalog asset.
- `:GetProductInfo(assetId: number, infoType: Enum.InfoType) -> {...}` — Fetch pricing and metadata for an asset/product.
- `:GetDeveloperProductsAsync() -> Pages` — Enumerate all DevProducts for this universe.

### Events
- `.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased) end)` — Fires when a GamePass purchase prompt closes (success or cancel).
- `.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased) end)` — Fires when a DevProduct prompt closes.
- `.PromptSubscriptionPurchaseFinished` — Subscription prompt closed.

### Critical Callback: `ProcessReceipt`
- `MarketplaceService.ProcessReceipt = function(receiptInfo) -> Enum.ProductPurchaseDecision` — **Required** for any experience that sells DevProducts. Called by Roblox when a DevProduct purchase completes. **Must be idempotent**. See [[process-receipt-idempotency]].

## `ProcessReceipt` — The Most Important Callback

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local receiptHistory = DataStoreService:GetDataStore("PurchaseHistory")

MarketplaceService.ProcessReceipt = function(receiptInfo)
    local userId = receiptInfo.PlayerId
    local productId = receiptInfo.ProductId
    local purchaseId = receiptInfo.PurchaseId

    local player = game.Players:GetPlayerByUserId(userId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Idempotency: check if we've already granted this specific purchase
    local historyKey = "purchase_" .. purchaseId
    local alreadyProcessed = false
    local ok = pcall(function()
        alreadyProcessed = receiptHistory:GetAsync(historyKey) == true
    end)
    if not ok then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    if alreadyProcessed then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    -- Grant the item
    local granted = grantProductToPlayer(player, productId)
    if not granted then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Mark as processed
    local marked = pcall(function()
        receiptHistory:SetAsync(historyKey, true)
    end)
    if not marked then
        -- We granted but couldn't mark — risk of double-grant next time.
        -- Best effort: return PurchaseGranted so Roblox doesn't keep calling us.
        warn("Failed to mark purchaseId " .. purchaseId .. " as processed.")
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

**Critical rules:**
- Return `PurchaseGranted` only after the item is actually granted OR the purchase is already recorded.
- Return `NotProcessedYet` if anything goes wrong (player offline, DataStore failure, can't grant) — Roblox will retry.
- **Idempotency via `purchaseId`** — Roblox may call `ProcessReceipt` multiple times for the same `purchaseId`. You must not double-grant.
- Store processed `PurchaseId` in a DataStore, not in memory (server restarts lose memory state).

See [[process-receipt-idempotency]] for the full deep-dive.

## GamePass Purchase Flow

```lua
-- Client initiates
MarketplaceService:PromptGamePassPurchase(player, VIP_GAMEPASS_ID)

-- Server listens for completion
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    if not wasPurchased then return end
    if gamePassId == VIP_GAMEPASS_ID then
        VipService.grantBenefits(player)
    end
end)

-- And on join, check existing ownership
game.Players.PlayerAdded:Connect(function(player)
    local ok, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID)
    end)
    if ok and owns then
        VipService.grantBenefits(player)
    end
end)
```

## Pitfalls

- **Missing or non-idempotent `ProcessReceipt`**: double-grants, lost Robux. See [[process-receipt-idempotency]].
- **Memory-only purchase history**: server restart → repeated grants for in-flight receipts.
- **Granting before marking processed**: granted but the mark failed → double-grant next time. Mitigation: best-effort warn.
- **No `pcall` on queries**: `UserOwnsGamePassAsync` and `GetProductInfo` can throw. Wrap them.
- **Polling `UserOwnsGamePassAsync` in a hot loop**: it's a server-side query with rate limits. Cache per player per session.
- **Trusting client-side "I own this"**: check server-side on join, not via client claim.
- **No pay-to-win check in monetization design**: see [[ethical-monetization]].

## Related

- [[game-pass]] — conceptual overview of GamePasses as a monetization vehicle
- [[dev-product]] — conceptual overview of DevProducts
- [[process-receipt-idempotency]] — the mission-critical pattern
- [[robux-price-tiers]] — how to price for common Robux purchase amounts
- [[premium-benefits]] — Roblox Premium detection and perks
- [[ethical-monetization]] — rules for child-friendly monetization
- [[transaction-replay]] — exploit class that idempotency defends against
- [[DataStoreService]] — where purchase history is stored
- [Monetization Rules](../../.claude/rules/config-data.md)

## Sources

- [Roblox Creator Docs — MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)
- [wiki/raw/roblox-creator-docs/services/MarketplaceService.md](../raw/roblox-creator-docs/services/MarketplaceService.md)
- [wiki/raw/roblox-creator-docs/best-practices/monetization/player-data-purchasing.md](../raw/roblox-creator-docs/best-practices/monetization/player-data-purchasing.md)
- [.claude/agents/monetization-lead.md](../../.claude/agents/monetization-lead.md)
