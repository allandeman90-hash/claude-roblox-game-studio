---
title: premium-benefits
type: monetization
category: monetization
subcategory: premium
owner: monetization-lead
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/premium-payouts/engagement-based-payouts-and-creator-rewards.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/engagement-based-payouts.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/roblox-plus.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/subscriptions.md
related:
  - "[[MarketplaceService]]"
  - "[[Player]]"
  - "[[engagement-based-payouts]]"
  - "[[game-pass]]"
  - "[[ethical-monetization]]"
tags: [monetization, premium]
---

# Premium Benefits

> Perks for Roblox Premium and Roblox Plus subscribers, detected server-side via `Player.MembershipType` and `Player.HasRobloxSubscription`. Offering benefits to subscribers drives engagement-based creator revenue.

## Summary

Roblox offers two platform-level subscriptions players can hold: **Roblox Premium** and **Roblox Plus** (launching April 30, 2026). Developers can detect these memberships and offer in-experience perks to subscribers. Common benefits include exclusive cosmetics, bonus currency multipliers, VIP areas, and early access to features.

Premium subscriber playtime historically fed the Engagement-Based Payouts system (deprecated July 24, 2025). Under the current **Creator Rewards** program, engagement from "Active Spenders" (not exclusively Premium members) drives payouts. However, Premium and Plus subscribers are disproportionately likely to be Active Spenders, so catering to them remains a revenue driver.

## Detecting Membership

### Roblox Premium

```lua
local Players = game:GetService("Players")

local function isPremium(player: Player): boolean
    return player.MembershipType == Enum.MembershipType.Premium
end

-- Server: check on join
Players.PlayerAdded:Connect(function(player)
    if isPremium(player) then
        player:SetAttribute("Premium", true)
        -- Grant Premium perks
    end
end)

-- Server: detect mid-session upgrade
Players.PlayerMembershipChanged:Connect(function(player)
    if isPremium(player) then
        player:SetAttribute("Premium", true)
        -- Grant Premium perks without requiring rejoin
    end
end)
```

### Roblox Plus (April 2026+)

```lua
-- Server: check on join
Players.PlayerAdded:Connect(function(player)
    if player.HasRobloxSubscription then
        player:SetAttribute("RobloxPlus", true)
        -- Grant Plus perks
    end

    -- Detect mid-session subscription
    player:GetPropertyChangedSignal("HasRobloxSubscription"):Connect(function()
        if player.HasRobloxSubscription then
            player:SetAttribute("RobloxPlus", true)
        end
    end)
end)
```

## Premium Purchase Modal

Encourage non-Premium users to upgrade directly from within the experience using `PromptPremiumPurchase`. Players complete the purchase in-experience and immediately receive Premium status and their Robux stipend.

```lua
local MarketplaceService = game:GetService("MarketplaceService")

-- Prompt from server (e.g., when touching a Premium-only area)
local function promptPremiumUpgrade(player: Player)
    if player.MembershipType ~= Enum.MembershipType.Premium then
        MarketplaceService:PromptPremiumPurchase(player)
    end
end
```

### Best practices for Premium prompts

- **Do not** show the modal as a paywall when non-Premium members enter.
- **Do not** promise Robux or out-of-experience rewards.
- Honestly describe benefits in the experience description.
- Offer exclusive cosmetics, but avoid tactical gameplay advantages that non-Premium members cannot compete against.
- Use a debounce (e.g., 5 seconds) to avoid spamming the prompt.

## Roblox Plus -- Creator Earning Opportunities

Roblox Plus provides three ways for creators to earn:

### 1. In-experience Robux purchases (subsidized discounts)

Plus subscribers receive 10% off eligible purchases (months 1-2) and 20% off (month 3+). **Roblox covers the discount** -- creator earnings stay at 70% of the listed price regardless.

| User type | Item price | User pays | Roblox subsidy | Creator earns | Effective share |
|-----------|-----------|----------|---------------|--------------|----------------|
| Non-subscriber | 100 R$ | 100 R$ | -- | 70 R$ | 70% |
| Plus (10% discount) | 100 R$ | 90 R$ | 10 R$ | 70 R$ | 78% |
| Plus (20% discount) | 100 R$ | 80 R$ | 20 R$ | 70 R$ | 88% |

### 2. Driving Plus sign-ups

Prompt Plus subscriptions with `MarketplaceService:PromptRobloxSubscriptionPurchase(player)`. Earn **250 Robux per month for the first 3 consecutive months** (up to 750 R$ per subscriber acquired). Subject to a 60-day holding period.

### 3. Paid private server time

Plus subscribers get free access to paid private servers. Roblox compensates creators up to **100 Robux per subscriber per server** when the subscriber spends 60+ cumulative minutes in the past 30 days. Top 5 qualifying servers per subscriber.

## Common Premium/Plus Perks

| Perk | Implementation |
|------|---------------|
| Exclusive chat name color | Set `ChatColor` attribute or custom chat tag |
| +25% coin rewards | Multiply rewards by 1.25 in the server grant logic |
| Premium-only area | Check membership before teleporting/granting access |
| Exclusive cosmetics | Filter shop items by membership flag |
| Larger inventory | Increase capacity attribute |
| Reduced cooldowns | Multiply cooldown timers by 0.75 |
| Priority queue | Sort matchmaking by membership status |

## In-Experience Subscriptions (Developer-Created)

Developers can create their own monthly recurring subscriptions distinct from Roblox Premium/Plus. These offer custom benefits for a monthly fee.

### Revenue share

| Payment method | Month 1 | Month 2+ |
|---------------|---------|----------|
| Local currency ($2.99-$14.99) | 70% creator share | **100% creator share** |
| Robux (49 R$ minimum) | 70% creator share | 70% creator share |

Local currency subscriptions deliver dramatically better economics than DevProducts/GamePasses from month 2 onward.

### Key limits

- **50 subscription products** per experience.
- Price changes every **60 days** maximum.
- Price increases require **30 days advance notice** to existing subscribers.
- Local currency tiers: $2.99, $4.99, $7.99, $9.99, $14.99.
- Robux minimum: 49 R$.

### Status check

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local SUBSCRIPTION_ID = "EXP-11111111"

local function isSubscribed(player: Player): boolean
    local ok, status = pcall(function()
        return MarketplaceService:GetUserSubscriptionStatusAsync(
            player, SUBSCRIPTION_ID
        )
    end)
    if not ok then return false end
    return status and status.IsSubscribed == true
end
```

Benefits must be re-checked on every player join and revoked if the subscription lapses. Listen for `Players.UserSubscriptionStatusChanged` for mid-session changes.

### Replacing a pass with a subscription

If transitioning from a GamePass to a subscription, existing pass holders must keep their benefits permanently while new users subscribe:

1. Check `UserOwnsGamePassAsync` for the legacy pass first.
2. If owned, grant benefits and skip subscription check.
3. If not owned, check subscription status.
4. Take the old pass off sale.

## Ethical Check

- Premium membership must **not** be a requirement to enjoy the experience.
- Premium-exclusive items should be cosmetic or convenience, not power-gated.
- Do not show the Premium purchase modal as a hard paywall blocking core content.
- See [[ethical-monetization]] for full principles.

## Pitfalls

- Checking `MembershipType` only on the client. Always verify server-side before granting gameplay advantages.
- Not handling the `PlayerMembershipChanged` event. Players who upgrade mid-session deserve immediate benefits.
- Hard-coding prices in the UI. Plus subscribers see discounted prices through `GetProductInfo`, but hard-coded values will not update.
- Not revoking subscription benefits when subscriptions lapse. Check status on every join and handle cancellations.

## Related

- [[MarketplaceService]]
- [[Player]]
- [[engagement-based-payouts]]
- [[game-pass]]
- [[ethical-monetization]]

## Sources

- [Engagement-Based Payouts and Creator Rewards](../raw/community/monetization/premium-payouts/engagement-based-payouts-and-creator-rewards.md) -- community synthesis
- [Engagement-Based Payouts (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/engagement-based-payouts.md) -- official documentation
- [Roblox Plus (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/roblox-plus.md) -- Plus subscriber program
- [Subscriptions (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/subscriptions.md) -- developer subscriptions
- [In-Experience Subscriptions](../raw/community/monetization/premium-payouts/in-experience-subscriptions.md) -- community synthesis
