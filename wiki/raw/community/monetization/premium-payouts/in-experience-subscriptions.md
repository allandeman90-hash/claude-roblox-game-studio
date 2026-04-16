---
title: In-Experience Subscriptions (Recurring Robux / Local Currency)
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/subscriptions.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: monetization
subcategory: premium-payouts
tags: [subscriptions, recurring, robux, marketplaceservice, revenue-share]
---

# In-Experience Subscriptions

Subscriptions are the third pillar of Roblox monetization alongside
GamePasses and Developer Products. Unlike passes (permanent one-time
unlocks) or dev products (consumables), subscriptions grant **monthly
recurring benefits** that depend on continuous payment.

Launched for local currency first, and at RDC 2025 expanded to also
support **Robux payment**.

## Revenue share (KEY NUMBERS)

### Local currency subscriptions (App Store, Google Play, Web)

- **70%** creator share in **month 1**
- **100%** creator share from **month 2** onward

This is dramatically better than GamePass/DevProduct, where the 30%
platform cut applies to every sale. Roblox absorbs the app store cut
in month 1 (hence the 70%) and gives you the full renewal afterwards.

### Robux subscriptions

- **70%** creator share **every month**, including month 1

Robux subscriptions are available **everywhere Roblox ships**, uniform
pricing worldwide; regional pricing **enabled by default**.

### Example

A $5 local-currency subscription:
- Month 1: $5 × 70% = ~350 R$ net to creator
- Month 2+: $5 × 100% ≈ 500 R$ net to creator

A 199 R$ Robux subscription:
- Every month: 199 × 70% ≈ 139 R$ net to creator

## Pricing and limits

### Local currency tiers

5 fixed tiers: $2.99, $4.99, $7.99, $9.99, $14.99.

### Robux price

Minimum **49 R$**. Standard charm-price ladder applies (49, 99, 199,
299, 499, 999).

### Price changes

- Prices can be adjusted every **60 days**.
- Price **increases** require **30 days advance notice** to existing
  subscribers.

### Max subscriptions

**50 subscription products** per experience.

## Product types (enum)

- **Durable** — long-lived benefits (VIP access, cosmetic unlocks)
- **Consumable** — monthly drip rewards
- **Currency** — monthly Robux-in-game-currency drops

## API

### Check if a user is subscribed

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local SUBSCRIPTION_ID = "EXP-11111111"

local function isSubscribed(player)
    local ok, status = pcall(function()
        return MarketplaceService:GetUserSubscriptionStatusAsync(
            player, SUBSCRIPTION_ID
        )
    end)
    if not ok then return false end
    return status and status.IsSubscribed == true
end
```

The returned status object contains (approximate shape):
- `IsSubscribed` — boolean
- `IsRenewing` — boolean (still paying) vs "cancelled but still
  within the billing cycle"
- `SubscriptionState` — enum

### Prompt purchase

```lua
-- From a LocalScript
MarketplaceService:PromptSubscriptionPurchase(player, SUBSCRIPTION_ID)
```

### Get product info

```lua
local ok, info = pcall(function()
    return MarketplaceService:GetSubscriptionProductInfoAsync(SUBSCRIPTION_ID)
end)
-- info has Name, Description, DisplayPrice, DisplayDescription, ...
```

### Payment history

```lua
local ok, history = pcall(function()
    return MarketplaceService:GetUserSubscriptionPaymentHistoryAsync(
        player, SUBSCRIPTION_ID
    )
end)
-- Check for recent payments to anti-abuse grant rewards based on
-- number of months subscribed.
```

## Granting benefits pattern

Because subscriptions are recurring, you need to check **on every
player join** and re-check periodically during the session (in case
a cancellation or renewal happens while they play):

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local SUBSCRIPTION_IDS = {
    VIP       = "EXP-11111111",
    DoubleXP  = "EXP-22222222",
}

local activeSubs = {}  -- [player] = { [id] = true }

local function checkAndGrant(player, subId)
    local ok, status = pcall(function()
        return MarketplaceService:GetUserSubscriptionStatusAsync(player, subId)
    end)
    if not ok or not status or not status.IsSubscribed then
        return false
    end
    activeSubs[player] = activeSubs[player] or {}
    activeSubs[player][subId] = true
    -- grant the actual perk
    if subId == SUBSCRIPTION_IDS.VIP then
        player:SetAttribute("VIP", true)
    elseif subId == SUBSCRIPTION_IDS.DoubleXP then
        player:SetAttribute("XPMultiplier", 2)
    end
    return true
end

Players.PlayerAdded:Connect(function(player)
    for name, subId in pairs(SUBSCRIPTION_IDS) do
        checkAndGrant(player, subId)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    activeSubs[player] = nil
end)
```

Consider also re-checking every 60 minutes during the session in
case a player cancels or a renewal just landed.

## Creation requirements

- **Unique name** within the experience
- **Description** of the benefits
- **Cover image**
- **Product type** (Durable / Consumable / Currency)
- **Price** — local currency tier or minimum 49 R$

## Compliance rules

- Benefits must be **consistent across platforms** (Robux subs and
  local-currency subs for the same benefit must match)
- **No post-payment task gating** — if they paid, they get it; you
  cannot require additional grinds to unlock subscriber content
- **Clear pricing and renewal disclosure** required by law in many
  jurisdictions, enforced by Roblox's moderation
- Roblox sub cannot be the only way to experience core gameplay
  (no pay-walled progression)

## Concrete Numbers / Examples

- Month-1 local-currency share: **70%**
- Month-2+ local-currency share: **100%**
- Robux share every month: **70%**
- Robux minimum: **49 R$**
- Local tiers: **$2.99 / $4.99 / $7.99 / $9.99 / $14.99**
- Price change cadence: **every 60 days**
- Price increase notice: **30 days advance**
- Max subscription products: **50 per experience**
- API: `GetUserSubscriptionStatusAsync`, `PromptSubscriptionPurchase`,
  `GetSubscriptionProductInfoAsync`,
  `GetUserSubscriptionPaymentHistoryAsync`

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/subscriptions.md
Related: https://devforum.roblox.com/t/let-your-players-pay-for-subscriptions-within-experiences-in-robux/4552995
Captured: 2026-04-16
