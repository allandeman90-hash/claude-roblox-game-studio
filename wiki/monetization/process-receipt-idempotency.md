---
title: process-receipt-idempotency
type: monetization
category: monetization
subcategory: dev-products
owner: monetization-lead
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/best-practices/monetization/player-data-purchasing.md
  - .claude/agents/monetization-lead.md
related:
  - "[[MarketplaceService]]"
  - "[[dev-product]]"
  - "[[transaction-replay]]"
  - "[[DataStoreService]]"
tags: [monetization, required, critical]
---

# ProcessReceipt Idempotency

> The required pattern for handling DevProduct purchases safely. Must grant items exactly once even if Roblox calls your callback multiple times.

## What It Is

`MarketplaceService.ProcessReceipt` is a callback Roblox invokes when a player completes a DevProduct purchase. It has three possible return values:

- `Enum.ProductPurchaseDecision.PurchaseGranted` — the item has been granted, stop calling
- `Enum.ProductPurchaseDecision.NotProcessedYet` — not ready yet, Roblox should retry later
- (returning nothing) — Roblox treats as `NotProcessedYet`

**The critical property**: Roblox may call `ProcessReceipt` multiple times for the same `PurchaseId`. This happens legitimately when:
- Server restarts between the "prompt shown" and "item granted" events
- Network issues cause Roblox to retry
- The first call returned `NotProcessedYet` and Roblox is retrying
- Multiple servers receive the notification simultaneously (rare but possible)

If your callback grants the item every time it's called, the player gets the item multiple times per one actual purchase. If it never grants, the player pays Robux and gets nothing. Both are bad.

**Idempotency** means: calling the function N times has the same effect as calling it once. Your `ProcessReceipt` must be idempotent.

## Why It Matters

Without idempotency:
- **Double-grants**: player buys 100 gems, receives 200 or 300. Your economy inflates; other players complain about unfairness.
- **No-grants**: player buys 100 gems, never receives them. Roblox charged their Robux. Player files a complaint. You have to refund manually or face a dispute.
- **Partial grants**: items go to one data store but not another. Inconsistent state.
- **Lost revenue**: if you return `PurchaseGranted` but didn't actually grant, Roblox stops trying and you never retry. Player paid, got nothing.

All of these are avoidable with a correct pattern.

## Implementation

### The canonical pattern

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local PRODUCT_HISTORY = DataStoreService:GetDataStore("PurchaseHistory_v1")

-- Map of productId -> function that grants the item
local productHandlers: {[number]: (player: Player) -> boolean} = {
    [12345] = function(player)
        local data = PlayerData.get(player)
        if not data then return false end
        data.gems += 100
        return true
    end,
    [12346] = function(player)
        local data = PlayerData.get(player)
        if not data then return false end
        data.gems += 500
        return true
    end,
    [12347] = function(player)
        -- Revive
        if not player.Character then return false end
        player:LoadCharacter()
        return true
    end,
}

MarketplaceService.ProcessReceipt = function(receiptInfo: {
    PurchaseId: string,
    PlayerId: number,
    ProductId: number,
    CurrencySpent: number,
    CurrencyType: Enum.CurrencyType,
    PlaceIdWherePurchased: number,
}): Enum.ProductPurchaseDecision
    local purchaseId = receiptInfo.PurchaseId
    local userId = receiptInfo.PlayerId
    local productId = receiptInfo.ProductId

    -- Player must be online to grant
    local player = Players:GetPlayerByUserId(userId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Step 1: check history — have we already processed this purchaseId?
    local historyKey = "purchase_" .. purchaseId
    local alreadyProcessed
    local historyOk, historyErr = pcall(function()
        alreadyProcessed = PRODUCT_HISTORY:GetAsync(historyKey) == true
    end)

    if not historyOk then
        warn("ProcessReceipt history GetAsync failed: " .. tostring(historyErr))
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if alreadyProcessed then
        -- Idempotent case: already granted, just acknowledge
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    -- Step 2: find the handler for this product
    local handler = productHandlers[productId]
    if not handler then
        warn("Unknown ProductId: " .. tostring(productId))
        -- Unknown product — still return PurchaseGranted or Roblox will retry forever
        -- Log it for manual review
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    -- Step 3: grant the item
    local grantOk, granted = pcall(handler, player)
    if not grantOk or granted ~= true then
        warn("Grant failed for product " .. productId .. ": " .. tostring(granted))
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Step 4: mark as processed in the history store
    local markOk, markErr = pcall(function()
        PRODUCT_HISTORY:SetAsync(historyKey, true)
    end)

    if not markOk then
        -- Granted but couldn't mark. Risk: next call will re-grant.
        -- Best effort: log and return PurchaseGranted to stop Roblox retries.
        warn("Failed to mark " .. purchaseId .. " as processed: " .. tostring(markErr))
        -- Decide: do you want Roblox to retry (risk player complaint) or grant again (risk double-grant)?
        -- Convention: return PurchaseGranted and log for manual reconciliation.
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

### Key properties

1. **History check first**: if we've seen this `PurchaseId`, return `PurchaseGranted` without re-granting.
2. **Player online check**: can't grant to offline player; `NotProcessedYet` and retry later.
3. **History retrieval fails gracefully**: if we can't check history, assume we haven't processed and try again later.
4. **Grant-then-mark order**: grant the item FIRST, then mark as processed. If mark fails, we've granted but may re-grant; log it. The alternative (mark-then-grant) is worse: if grant fails, we've already marked it processed and Roblox won't retry.
5. **Unknown product fallback**: return `PurchaseGranted` to prevent infinite retry, log for manual review.

### Where to store the history

Use a dedicated DataStore (`PurchaseHistory_v1`), not the player's regular data store. Reasons:
- Different retention policies (history is forever, player data migrates over versions)
- Lookup is by `purchaseId`, not `UserId`
- Don't bloat player data with every purchase

### What `PurchaseId` looks like

`PurchaseId` is a string, unique per purchase. Roblox generates it. Do not trust any value on `receiptInfo` other than using it as opaque identifiers.

## Pitfalls

- **No history check**: grants every time Roblox calls — double/triple grants.
- **No `pcall` around DataStore calls**: errors crash the callback, item never granted.
- **Returning `PurchaseGranted` before granting**: if grant then fails, Roblox doesn't retry and player never gets item.
- **Memory-only history**: server restart loses state, grants repeat on next callback.
- **Player assumed online without check**: crash on offline player.
- **Not handling unknown product IDs**: Roblox retries forever, spamming your callback.
- **Trusting client-side "I bought X"**: irrelevant — use `ProcessReceipt` only, never a custom client-side trigger.
- **Granting before marking + not logging failed marks**: silent double-grants.

## Related

- [[MarketplaceService]] — the service this uses
- [[dev-product]] — the transaction type this handles
- [[transaction-replay]] — the exploit this defends against
- [[DataStoreService]] — where history is stored
- [Monetization Rules](../../.claude/rules/config-data.md)

## Sources

- [wiki/raw/roblox-creator-docs/best-practices/monetization/player-data-purchasing.md](../raw/roblox-creator-docs/best-practices/monetization/player-data-purchasing.md)
- [.claude/agents/monetization-lead.md](../../.claude/agents/monetization-lead.md)
- [Roblox docs: Player Data and Purchasing](https://create.roblox.com/docs/production/monetization/player-data-purchasing)
