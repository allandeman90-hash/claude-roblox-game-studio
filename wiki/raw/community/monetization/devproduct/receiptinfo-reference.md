---
title: ReceiptInfo Data Model - ProcessReceipt Fields Reference
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#ProcessReceipt
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: monetization
subcategory: devproduct
tags: [receiptinfo, processreceipt, marketplaceservice, reference, data-model]
---

# ReceiptInfo Data Model — ProcessReceipt Fields Reference

When MarketplaceService fires your `ProcessReceipt` callback, it
passes a `receiptInfo` table. Knowing the fields on this table matters
for analytics, debugging, and multi-place universes.

## Field reference

| Field | Type | Description |
|-------|------|-------------|
| `PurchaseId` | string | **Unique identifier** for the specific purchase transaction. Use as the idempotency key. Stable across retries. |
| `PlayerId` | number | `UserId` of the user who made the purchase. |
| `ProductId` | number | The dev product id. Match against your product handler table. |
| `PlaceIdWherePurchased` | number | The **PlaceId** where the purchase happened. Important for multi-place universes — the callback can fire on a different place than the one where the prompt was shown. |
| `CurrencySpent` | number | Amount of currency spent in the transaction. |
| `CurrencyType` | `Enum.CurrencyType` | Always `Enum.CurrencyType.Robux` (Roblox does not currently support other currencies). |

## The return value — `Enum.ProductPurchaseDecision`

Your callback must return one of:

- `Enum.ProductPurchaseDecision.PurchaseGranted` — reward delivered
  AND persisted. Roblox will NOT fire the callback again for this
  receipt. Return **only** after your DataStore write succeeds.
- `Enum.ProductPurchaseDecision.NotProcessedYet` — something failed.
  Roblox will retry later (current server, future server, next time
  the player joins). Use on ANY error.

**There is no "purchase denied" return value.** You cannot refund a
purchase from ProcessReceipt — once the player paid, you must grant
the reward or keep retrying forever.

## Multi-place universe gotcha

The `PlaceIdWherePurchased` field is important if your game has
multiple places. A player can buy a DevProduct in Place A, then get
teleported to Place B before the callback finishes. ProcessReceipt
may fire in Place B even though the purchase happened in Place A.

Your `ProcessReceipt` handler must be **place-agnostic** — it should
fire for any product in any place, checking product-id → handler.
Don't gate grants on `game.PlaceId == whateverPlaceId`.

## Example: collecting analytics from receiptInfo

```lua
local AnalyticsService = game:GetService("AnalyticsService")

local function logPurchase(receiptInfo, player)
    AnalyticsService:LogCustomEvent(
        player,
        "Purchase",
        receiptInfo.CurrencySpent,
        {
            ProductId = tostring(receiptInfo.ProductId),
            PlaceId   = tostring(receiptInfo.PlaceIdWherePurchased),
            Currency  = tostring(receiptInfo.CurrencyType.Name),
        }
    )
end
```

## Example: de-duplication using PurchaseId

The `UserId:PurchaseId` composite is the canonical idempotency key.
Both halves are necessary — multiple users could theoretically get
the same PurchaseId on different transactions (Roblox promises
uniqueness per user, not globally).

```lua
local function receiptKey(receiptInfo)
    return receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId
end
```

## Observed retry cadence

Roblox retries `ProcessReceipt` at irregular intervals:

- **Same server**: if the grant logic errored and returned
  `NotProcessedYet`, Roblox may retry within seconds.
- **Different server / later session**: if the player disconnected,
  Roblox will fire the callback again the next time they join ANY
  place in the universe.
- **Long-tail**: receipts have been observed to re-fire days or even
  weeks later for long-dormant players.

This is why `PurchaseGranted` must be **idempotent and persistent**:
re-firing happens, your DataStore check stops the second grant.

## Concrete Numbers / Examples

- Key pattern: **`UserId:PurchaseId`**
- Currency type: always **`Enum.CurrencyType.Robux`**
- Return values: **`PurchaseGranted`** / **`NotProcessedYet`** only
- **Multi-place**: ProcessReceipt can fire in any place of the universe
- Retries: **at-least-once delivery**, unpredictable latency
- No refund path via callback — **once paid, you owe the grant**

## Source

Original URL: https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#ProcessReceipt
Related: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MarketplaceService.yaml
Captured: 2026-04-16
