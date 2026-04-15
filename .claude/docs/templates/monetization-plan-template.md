# Monetization Plan: [Game Name]

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: monetization-lead
**Status**: [Draft / Approved / Live]

---

## 1. Philosophy

How we approach monetization:
- Ethical first — no pay-to-win, no FOMO targeting kids
- Free players get a complete experience
- Paid options add convenience, cosmetics, and permanence
- Clean pricing tiers aligned with Robux purchase amounts

---

## 2. Revenue Goals

- **Initial goal**: $1000 USD first month
- **3-month goal**: $5000 USD/month
- **6-month goal**: $15000 USD/month

Factored in Developer Exchange rate: 1 Robux → $0.0035 USD.

---

## 3. GamePass Catalog

### VIP Membership
- **Price**: 499 R$
- **Benefit**: Chat color, VIP room access, +10% gold earnings, daily VIP reward
- **Target Player**: Engaged regular player (level 10+)
- **Expected Conversion**: 5% of returning players
- **Pay-to-win?**: No (cosmetic + small multiplier, not competitive)

### Double Inventory
- **Price**: 299 R$
- **Benefit**: 2x inventory slots (20 → 40)
- **Target Player**: Mid-game players hitting inventory limit
- **Expected Conversion**: 8% of level 10+ players
- **Pay-to-win?**: No (convenience)

### 2x Gold
- **Price**: 799 R$
- **Benefit**: Permanent 2x gold earnings
- **Target Player**: Players hitting the grind wall
- **Expected Conversion**: 3% of level 15+ players
- **Pay-to-win?**: Borderline (progresses faster, but doesn't unlock exclusive content)

### Auto-Collect
- **Price**: 399 R$
- **Benefit**: Automatically picks up dropped items in radius
- **Target Player**: Casual players
- **Expected Conversion**: 4%
- **Pay-to-win?**: No (convenience)

---

## 4. DevProduct Catalog

### 100 Gems
- **Price**: 49 R$
- **Grants**: 100 premium currency
- **Frequency**: Variable (as needed)
- **Conversion**: ~10% of players buy at least once

### 1000 Gems
- **Price**: 399 R$ (best value, highlighted)
- **Grants**: 1000 premium currency
- **Frequency**: Variable
- **Conversion**: ~3% of players

### Revive Token
- **Price**: 25 R$
- **Grants**: Instant revive at death
- **Frequency**: Per-death
- **Conversion**: ~2% of deaths

### 1-Hour XP Boost
- **Price**: 99 R$
- **Grants**: 2x XP for 60 minutes
- **Frequency**: Occasional
- **Conversion**: ~1% per session

---

## 5. Premium Benefits

For Roblox Premium subscribers:
- Exclusive chat color
- +5% gold earnings
- Premium-only cosmetic every month
- Access to Premium-only events

These are non-monetized (Roblox Premium is a Roblox subscription, not ours) but they drive the Premium Payout metric, which pays us based on Premium subscriber playtime.

---

## 6. Revenue Projection

### Assumptions
- 1000 DAU at launch, growing to 5000 by month 3
- 3% conversion rate
- Average purchase: 300 R$
- Dev Exchange rate: $0.0035/R$

### Projection

| Month | DAU | Paying Users (3%) | Avg Purchase | Revenue (R$) | Revenue (USD) |
|-------|-----|-------------------|--------------|--------------|---------------|
| 1 | 1000 | 30 | 300 | 9000 | $31.50 |
| 2 | 2000 | 60 | 300 | 18000 | $63 |
| 3 | 5000 | 150 | 300 | 45000 | $157.50 |
| 6 | 10000 | 300 | 300 | 90000 | $315 |

Note: This is conservative. Successful Roblox games achieve much higher, but modeling optimistically is risky.

---

## 7. Purchase Funnel Design

### Touchpoints
1. **Discovery**: Shop icon on HUD (always visible, subtle)
2. **Consideration**: Shop page with clear category tabs (GamePass, DevProducts, Cosmetics)
3. **Interest**: Item detail modal with clear benefit description, price, preview
4. **Decision**: Confirmation prompt with Robux balance shown
5. **Purchase**: Roblox native purchase UI
6. **Post-purchase**: Immediate reward, confirmation notification, thank you message

### A/B Test Opportunities
- Shop icon placement
- Shop button label (💰 "Shop" vs. "Store" vs. "Upgrades")
- Item featured rotation (spotlight different items)
- Pricing tests (is 499 R$ VIP better than 399 R$ or 599 R$?)

---

## 8. Ethical Constraints (NON-NEGOTIABLE)

- [ ] No loot boxes with real-money purchase
- [ ] No pay-to-win mechanics
- [ ] No artificial scarcity targeting young players
- [ ] No misleading pricing or hidden costs
- [ ] Clear value communication for every purchase
- [ ] Free players have a complete, enjoyable experience
- [ ] Purchases are final and clearly communicated

---

## 9. Implementation Requirements

### Server Side
- `ProcessReceipt` callback for DevProducts — idempotent
- GamePass checks via `UserOwnsGamePassAsync`
- Purchase history in DataStore
- Robux value tracking for analytics

### Client Side
- Shop UI with categories
- Item detail modals
- Purchase flow integration
- Post-purchase confirmation

### Analytics
- Track every purchase prompt shown
- Track every purchase completed
- Track every purchase abandoned
- Compute ARPDAU daily

---

## 10. Review Schedule

- Monthly review of metrics (conversion, ARPDAU, top items)
- Quarterly pricing review
- Per-feature review when adding new items
