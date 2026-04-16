---
title: Promo Code Redemption System (DataStore-backed)
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-create-a-one-time-use-redeemable-code-using-module-scripts-and-datastores/2812138
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: live-ops
subcategory: events
tags: [promo-codes, redemption, datastore, live-ops, events, content-rotation]
---

# Promo Code Redemption System

Promo codes are a cheap, effective live-ops tool: reward social media
followers, thank the community for a milestone, push players to watch
a trailer, or onboard a new feature. The redemption system must handle:

1. Per-code validity (is this a real code?)
2. Per-player uniqueness (has this player used this code already?)
3. Optional global cap (first N redemptions only)
4. Optional expiration date
5. Optional rewards table lookup

## Architecture

Use **two** DataStores:

- `PromoCodes` — keyed by code string. Value is the reward metadata and
  active flag. Authored by the developer; rarely written.
- `PromoRedemptions` — keyed by `UserId:Code`. Value is `true`. Written
  once per player+code.

This separation keeps the per-code definitions independent of
per-player redemption history.

## Code

### Module — code list

```lua
-- ReplicatedStorage/PromoCodes (ModuleScript)
return {
    SUMMER2026 = {
        reward = { coins = 500, pet = "SunDragon" },
        expiresAt = 1728000000,       -- unix seconds
        globalCap = nil,              -- unlimited
        active = true,
    },
    LAUNCH = {
        reward = { coins = 1000 },
        expiresAt = nil,
        globalCap = 10000,
        active = true,
    },
}
```

### Server — redemption handler

```lua
local Players              = game:GetService("Players")
local DataStoreService     = game:GetService("DataStoreService")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local MarketplaceService   = game:GetService("MarketplaceService") -- unused, left for analogy

local PromoCodes       = require(ReplicatedStorage:WaitForChild("PromoCodes"))
local RedemptionStore  = DataStoreService:GetDataStore("PromoRedemptions")
local GlobalCapStore   = DataStoreService:GetDataStore("PromoGlobalCap")

local Remote = ReplicatedStorage:WaitForChild("RedeemCode")

local function normalize(code: string): string
    return string.upper((string.gsub(code or "", "%s", "")))
end

local function grant(player: Player, reward)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Coins") and reward.coins then
        leaderstats.Coins.Value += reward.coins
    end
    -- Grant pets, items, etc. via your inventory service.
end

Remote.OnServerEvent:Connect(function(player, rawCode)
    local code = normalize(rawCode)
    local entry = PromoCodes[code]

    if not entry or not entry.active then
        Remote:FireClient(player, { ok = false, reason = "invalid" })
        return
    end

    if entry.expiresAt and os.time() > entry.expiresAt then
        Remote:FireClient(player, { ok = false, reason = "expired" })
        return
    end

    -- Per-player uniqueness via UpdateAsync (atomic).
    local key = player.UserId .. ":" .. code
    local alreadyUsed
    local ok = pcall(function()
        RedemptionStore:UpdateAsync(key, function(old)
            if old then
                alreadyUsed = true
                return nil      -- no-op
            end
            return true
        end)
    end)

    if not ok then
        Remote:FireClient(player, { ok = false, reason = "retry" })
        return
    end
    if alreadyUsed then
        Remote:FireClient(player, { ok = false, reason = "used" })
        return
    end

    -- Optional global cap using IncrementAsync.
    if entry.globalCap then
        local remaining
        local capOk = pcall(function()
            GlobalCapStore:UpdateAsync(code, function(count)
                count = count or 0
                if count >= entry.globalCap then
                    remaining = 0
                    return nil
                end
                remaining = entry.globalCap - count - 1
                return count + 1
            end)
        end)
        if not capOk or remaining == 0 then
            -- Roll back per-player flag so they can try again if cap lifts.
            pcall(function()
                RedemptionStore:RemoveAsync(key)
            end)
            Remote:FireClient(player, { ok = false, reason = "cap" })
            return
        end
    end

    grant(player, entry.reward)
    Remote:FireClient(player, { ok = true, reward = entry.reward })
end)
```

### Why UpdateAsync and not SetAsync

`UpdateAsync` gives you the previous value inside the transform so you
can check for prior redemption atomically. With `SetAsync` you'd
read-then-write, which is a classic race condition.

## Concrete Numbers / Examples

- Two DataStores: `PromoCodes` (definition), `PromoRedemptions` (history).
- Third optional store `PromoGlobalCap` if you want first-N semantics.
- Key format: `UserId:Code` mirrors the ProcessReceipt idempotency pattern.
- Throttle hints: DataStore key budgets apply, so during a launch spike
  spread codes across multiple keys to avoid hot-keying.

## Source

Original URL: https://devforum.roblox.com/t/how-to-create-a-one-time-use-redeemable-code-using-module-scripts-and-datastores/2812138
Captured: 2026-04-16
