---
title: ProcessReceipt Idempotency Pattern (DevProduct)
type: raw-source
source_url: https://devforum.roblox.com/t/best-way-to-use-processreceipt/282882
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: monetization
subcategory: devproduct
tags: [processreceipt, marketplaceservice, datastore, idempotency, devproduct, purchase]
---

# ProcessReceipt Idempotency Pattern (DevProduct)

ProcessReceipt is the callback MarketplaceService fires when a player buys a
Developer Product. It is the only reliable place to grant rewards — but it can
fire multiple times for the same purchase (e.g. the server shut down before
the callback returned PurchaseGranted, the player re-joined, etc.). Failing
to make this callback idempotent results in duplicate grants (+100, +200,
+300 on a single transaction) or, worse, free infinite currency.

The industry-standard pattern is to use a separate `PurchaseHistory` DataStore
keyed by `UserId:PurchaseId` to record which receipts have been fulfilled.

## Concrete Numbers / Examples

- Key format: `UserId .. ":" .. PurchaseId` (the PurchaseId is unique per
  transaction and stable across retries).
- Return values are from `Enum.ProductPurchaseDecision`:
  - `PurchaseGranted` — reward delivered and persisted. Roblox will NOT call
    ProcessReceipt again for this receipt.
  - `NotProcessedYet` — Roblox will retry later (same server session or a
    future server). Use this on ANY failure (player missing, DataStore error,
    handler pcall failure).

## Code

### Canonical ProcessReceipt with DataStore idempotency

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService   = game:GetService("DataStoreService")
local Players            = game:GetService("Players")

local PurchaseHistory = DataStoreService:GetDataStore("PurchaseHistory")

-- Direct table lookup by ProductId avoids O(n) loops and guards unknown IDs.
local Products = {
    [123456789] = function(receipt, player)
        -- Grant 100 coins
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then return false end
        leaderstats.Coins.Value += 100
        return true
    end,
}

function MarketplaceService.ProcessReceipt(receiptInfo)
    local key = receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId

    -- 1. Idempotency check — already processed?
    local alreadyProcessed
    local ok = pcall(function()
        alreadyProcessed = PurchaseHistory:GetAsync(key)
    end)
    if not ok then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    if alreadyProcessed then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    -- 2. Player must be present to receive the reward.
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- 3. Look up handler by exact ProductId. Unknown products -> retry.
    local handler = Products[receiptInfo.ProductId]
    if not handler then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- 4. Execute the reward logic under pcall.
    local success, result = pcall(handler, receiptInfo, player)
    if not success or not result then
        warn("ProcessReceipt handler failed:", receiptInfo.ProductId, result)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- 5. Persist BEFORE granting. If this fails, we'll retry on a future
    --    ProcessReceipt call and the player is not yet marked as rewarded.
    local saveOk = pcall(function()
        PurchaseHistory:SetAsync(key, true)
    end)
    if not saveOk then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

### Why this ordering matters

1. **Idempotency check first** — stops double-grants from retries.
2. **Player presence second** — you cannot mutate `leaderstats` on a user
   who already left. Return `NotProcessedYet` and Roblox retries later.
3. **Handler dispatch by direct index** — avoids accidentally granting
   rewards for products your game does not know about.
4. **Grant under pcall** — a script error must NOT cause the player to get
   rewarded without being debited.
5. **Persist record, THEN return PurchaseGranted** — if the SetAsync fails,
   do NOT return PurchaseGranted, because Roblox will stop retrying and the
   player will lose their purchase on rejoin.

### Common pitfalls

- **Adding currency via `MarketplaceService.PromptProductPurchaseFinished`**
  is wrong. That event is client-side UX, not the authoritative grant path.
  Always use ProcessReceipt for rewards.
- **Storing the purchase in your main player data DataStore** is fine as
  long as you use the same `UserId:PurchaseId` key pattern and the write
  is atomic. Many games use a dedicated `PurchaseHistory` store to keep
  purchase state independent of profile saves.
- **Returning `PurchaseGranted` unconditionally** to stop retries is
  catastrophic. If the grant silently failed, the player has paid Robux for
  nothing and Roblox will never retry.

## Source

Original URL: https://devforum.roblox.com/t/best-way-to-use-processreceipt/282882
Related: https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#ProcessReceipt
Captured: 2026-04-16
