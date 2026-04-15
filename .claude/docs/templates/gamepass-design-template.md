# GamePass / DevProduct Design: [Item Name]

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: monetization-lead
**Status**: [Draft / Approved / Implemented / Live]

---

## 1. Identity

- **Name**: [Player-facing name]
- **Type**: GamePass (one-time purchase) / DevProduct (consumable / repeatable)
- **Price**: [X] Robux
- **Tier**: Entry (25-99 R$) / Standard (100-499 R$) / Premium (500-1999 R$) / Elite (2000+ R$)

---

## 2. Description (Player-Facing)

One-sentence description shown in the shop:

> "[Short compelling description]"

Full description shown in the item detail modal:

> [2-3 sentences explaining the benefit, value, and who it's for]

---

## 3. Mechanics

### What It Grants
- [Benefit 1 — specific, measurable]
- [Benefit 2]
- [Benefit 3]

### How It's Applied
- **Server-side**: [validation and state change]
- **Client-side**: [UI indicator, visual effect]

### Persistence
- **GamePass**: Permanent; checked via `MarketplaceService:UserOwnsGamePassAsync`
- **DevProduct**: Consumed per use; processed via `ProcessReceipt` callback with idempotency

---

## 4. Target Player

- **Engagement Level**: [New / Regular / Engaged / Whale]
- **Bartle Type**: [Achiever / Explorer / Socializer / Killer]
- **Player State**: [What level? What gameplay state? What need?]
- **Purchase Intent Signal**: [When does a player realize they want this?]

---

## 5. Purchase Funnel

### Discovery Touchpoints
1. **First**: [Where player first hears about it]
2. **Second**: [Context clue in gameplay that makes them want it]
3. **Third**: [Shop browse]
4. **Fourth**: [Decision / purchase]

### Conversion Optimization
- **Show, don't tell**: [How gameplay hints at the benefit]
- **Clear value**: [What the player saves or gains]
- **No FOMO**: [Not time-limited or pressure-based]

---

## 6. Pricing Justification

### Comparable Items
| Game | Similar Item | Price |
|------|--------------|-------|
| [Game A] | [Item] | [Price] |
| [Game B] | [Item] | [Price] |
| [Game C] | [Item] | [Price] |

**Our price**: [X] — [above / at / below] average, because [rationale]

### Robux Tier Alignment
- Does this fit in a common Robux purchase tier? (80 / 400 / 800 / 1700 / 4500 / 10000)
- Example: 499 R$ fits well after a 400 R$ purchase (player has 80 R$ leftover)

---

## 7. Revenue Projection

- **Expected conversion rate**: [X]% of target player segment
- **Estimated purchases**: [X]/day at [DAU] target
- **Revenue per day**: [X Robux] → [$X USD] (at Dev Exchange rate)
- **Lifetime revenue** (first 3 months): [$X USD]

---

## 8. Pay-to-Win Check (NON-NEGOTIABLE)

- [ ] Does this give a measurable advantage in competitive/PvP scenarios? → If yes, explain mitigation
- [ ] Does this gate content from free players? → Must be No
- [ ] Does this create an "unfair" feeling for free players? → Must be No
- [ ] Is the free experience still complete without this? → Must be Yes

**Verdict**: [Pass / Borderline / Fail — if borderline or fail, redesign]

---

## 9. Ethical Constraints

- [ ] No loot box / gacha mechanic (Roblox ToS)
- [ ] No artificial scarcity
- [ ] No FOMO targeting young players
- [ ] No misleading value claims
- [ ] Clear what the player gets
- [ ] Purchase is final and clearly communicated

---

## 10. Implementation

### Server-Side Code
```lua
-- For GamePass
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
    if passId == GAMEPASS_IDS.VIP and wasPurchased then
        VipService.grantBenefits(player)
    end
end)

-- For DevProduct
MarketplaceService.ProcessReceipt = function(receiptInfo)
    local productId = receiptInfo.ProductId
    local userId = receiptInfo.PlayerId
    local player = Players:GetPlayerByUserId(userId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Idempotency check
    if hasProcessedReceipt(receiptInfo.PurchaseId) then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    -- Grant item
    Inventory.addItem(player, "gem_pack", 1000)
    markReceiptProcessed(receiptInfo.PurchaseId)

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

### Client-Side Code
```lua
-- Open purchase prompt
MarketplaceService:PromptGamePassPurchase(player, passId)

-- Or for DevProduct
MarketplaceService:PromptProductPurchase(player, productId)
```

---

## 11. Analytics Events

Track:
- `purchase_prompt_shown` (productId, context)
- `purchase_completed` (productId, robuxAmount)
- `purchase_abandoned` (productId, stage)

---

## 12. A/B Test Opportunities

- Different price points (e.g., 399 vs 499 vs 599)
- Different descriptions
- Different placement in shop
- Different discovery touchpoints

---

## 13. Approval

- [ ] monetization-lead approved
- [ ] creative-director ethical review passed
- [ ] economy-designer verified no economy break
- [ ] lead-programmer implementation ready
- [ ] user: final approval

---

## Launch Checklist

- [ ] GamePass/DevProduct created on Creator Dashboard
- [ ] Server code deployed
- [ ] Client UI deployed
- [ ] Analytics events tested
- [ ] Server-side validation tested
- [ ] Idempotency verified (DevProducts)
- [ ] Announced in patch notes / social
