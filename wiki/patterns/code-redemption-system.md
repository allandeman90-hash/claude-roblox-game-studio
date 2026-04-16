---
title: code-redemption-system
type: pattern
category: patterns
subcategory: live-ops
owner: live-ops-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/promo-code-redemption.md
related:
  - "[[code-redemption]]"
  - "[[DataStoreService]]"
  - "[[rate-limiting]]"
  - "[[feature-flags]]"
tags: [pattern, live-ops, promo-codes]
---

# Code Redemption System

> Server-validated promotional code pattern using two DataStores for atomic per-player redemption tracking.

## Summary

A code redemption system lets developers distribute promotional codes via social media, trailers, or community events. Players enter a code in-game, the server validates it atomically, grants the reward, and marks it as redeemed for that player. The pattern uses two DataStores (code definitions and per-player redemption history) to separate concerns and prevent race conditions.

## When to Use It

- Marketing campaigns (YouTube codes, Twitter giveaways, milestone celebrations).
- Content-creator partnerships where each creator gets a unique code.
- Limited-time events where the first N players to redeem get exclusive items.
- Onboarding flow -- give new players a starter code to hook them in the first session.

## Implementation

### Architecture

Two (optionally three) DataStores:

| Store | Keyed by | Value | Written by |
|-------|----------|-------|------------|
| `PromoCodes` | code string | reward metadata + active flag | Developer (manual or CI/CD) |
| `PromoRedemptions` | `UserId:Code` | `true` | Server on successful redemption |
| `PromoGlobalCap` (optional) | code string | redemption count | Server via `UpdateAsync` |

### Code Definition Module

```lua
-- ReplicatedStorage/PromoCodes.lua
return {
    SUMMER2026 = {
        reward = { coins = 500, pet = "SunDragon" },
        expiresAt = 1728000000,       -- unix seconds, nil = no expiry
        globalCap = nil,              -- nil = unlimited
        active = true,
    },
    LAUNCH = {
        reward = { coins = 1000 },
        expiresAt = nil,
        globalCap = 10000,            -- first 10,000 only
        active = true,
    },
}
```

### Server Redemption Handler

```lua
local DataStoreService  = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PromoCodes      = require(ReplicatedStorage:WaitForChild("PromoCodes"))
local RedemptionStore = DataStoreService:GetDataStore("PromoRedemptions")
local GlobalCapStore  = DataStoreService:GetDataStore("PromoGlobalCap")

local Remote = ReplicatedStorage:WaitForChild("RedeemCode")

local function normalize(code: string): string
    return string.upper((string.gsub(code or "", "%s", "")))
end

Remote.OnServerEvent:Connect(function(player, rawCode)
    -- Type validation
    if typeof(rawCode) ~= "string" or #rawCode > 50 then return end

    local code = normalize(rawCode)
    local entry = PromoCodes[code]

    -- 1. Valid code?
    if not entry or not entry.active then
        Remote:FireClient(player, { ok = false, reason = "invalid" })
        return
    end

    -- 2. Expired?
    if entry.expiresAt and os.time() > entry.expiresAt then
        Remote:FireClient(player, { ok = false, reason = "expired" })
        return
    end

    -- 3. Per-player uniqueness via UpdateAsync (atomic)
    local key = player.UserId .. ":" .. code
    local alreadyUsed
    local ok = pcall(function()
        RedemptionStore:UpdateAsync(key, function(old)
            if old then
                alreadyUsed = true
                return nil  -- no-op, do not overwrite
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

    -- 4. Optional global cap
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
            -- Roll back per-player flag
            pcall(function() RedemptionStore:RemoveAsync(key) end)
            Remote:FireClient(player, { ok = false, reason = "cap" })
            return
        end
    end

    -- 5. Grant reward
    -- InventoryService.grantReward(player, entry.reward)
    Remote:FireClient(player, { ok = true, reward = entry.reward })
end)
```

### Why UpdateAsync, Not SetAsync

`UpdateAsync` receives the previous value inside the transform callback, enabling an atomic check-and-set. With `SetAsync`, a read-then-write introduces a race window where two servers could both see "not redeemed" and both grant the reward.

## Variants

| Variant | Notes |
|---------|-------|
| **Hardcoded code list** | Code table lives in a ModuleScript. Simple; requires a deploy to add codes. |
| **DataStore-backed code list** | Code definitions stored in a DataStore. Add codes via Open Cloud API without restarting servers. |
| **HttpService + external API** | Codes managed in an external database; server validates via HTTP. Most flexible, requires external infra. |
| **Time-gated codes** | `expiresAt` field; server checks `os.time()` before granting. |
| **Per-player cap** | Limit total redemptions per player (e.g., max 5 codes per account). |

## Pitfalls

- **Brute-force attacks.** Apply [[rate-limiting]] to the redemption remote -- 1-2 attempts per second per player max. Without rate limiting, an exploiter can enumerate short codes.
- **Code length.** Use 6-12 character alphanumeric codes. Shorter codes are easier for brute-force; longer codes are annoying to type on mobile.
- **Normalization.** Always normalize input (uppercase, strip whitespace) so `summer2026`, `SUMMER2026`, and ` Summer 2026 ` all resolve to the same code.
- **Hot-keying.** During a launch spike, thousands of players may redeem the same code simultaneously. The `UserId:Code` key format spreads writes across many DataStore keys, avoiding hot-key throttling.
- **Rollback on cap failure.** If the global cap check fails after the per-player flag was written, roll back the per-player entry so the player can try again.

## Related

- [[code-redemption]] -- the concept page explaining why and when to use codes
- [[DataStoreService]] -- persistence layer for redemption tracking
- [[rate-limiting]] -- prevent brute-force code enumeration
- [[feature-flags]] -- toggle codes active/inactive live

## Sources

- [wiki/raw/community/monetization/live-ops/promo-code-redemption.md](../raw/community/monetization/live-ops/promo-code-redemption.md)
