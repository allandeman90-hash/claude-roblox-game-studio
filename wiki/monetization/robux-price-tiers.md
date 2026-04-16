---
title: robux-price-tiers
type: monetization
category: monetization
subcategory: pricing
owner: monetization-lead
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/gamepass/pricing-strategy.md
  - wiki/raw/community/monetization/premium-payouts/devex-rates-and-economics.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/price-optimization.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/regional-pricing.md
related:
  - "[[game-pass]]"
  - "[[dev-product]]"
  - "[[developer-exchange]]"
  - "[[ethical-monetization]]"
tags: [monetization, pricing]
---

# Robux Price Tiers

> Player Robux purchase tiers, charm pricing defaults, and the revenue math that connects item prices to developer earnings. The foundation for pricing any in-experience product.

## Summary

Players buy Robux in fixed USD tiers. Effective pricing aligns in-game item costs to these tiers so that items fit within a player's typical balance. "Charm" prices ending in 9 (49, 99, 199, 499, 999) consistently outperform round numbers in conversion studies.

## Player Robux Purchase Tiers

What a player typically has in their account after a single purchase:

| USD | Robux | Notes |
|----:|------:|-------|
| $0.99 | 80 | Smallest purchase. Impulse buyers. |
| $4.99 | 400 | Most common entry tier. |
| $9.99 | 800 | Mid-range casual. |
| $19.99 | 1,700 | Engaged player. |
| $49.99 | 4,500 | Dedicated spender. |
| $99.99 | 10,000 | Whale tier. |

Premium subscribers receive a monthly Robux stipend on top of purchases. Roblox Plus subscribers receive 10-20% discounts on in-game purchases (subsidized by Roblox).

## Charm Pricing Defaults

Design item prices to sit just below a purchase tier so the item is affordable after a single Robux buy, with a small amount left over (encouraging a follow-up purchase):

| Charm price (R$) | Fits within | Remainder | Target |
|------------------:|------------|----------:|--------|
| 49 | 80 R$ tier | 31 | Impulse buy, highest conversion |
| 99 | 400 R$ tier | 301 | Low commitment entry |
| 149 | 400 R$ tier | 251 | "Just over 99" anchor |
| 199 | 400 R$ tier | 201 | Flagship casual |
| 249 | 400 R$ tier | 151 | Mid-tier value |
| 499 | 800 R$ tier | 301 | Engaged-player |
| 999 | 1,700 R$ tier | 701 | Premium anchor |
| 1999 | 4,500 R$ tier | 2,501 | Superfan |
| 4999 | 10,000 R$ tier | 5,001 | Whale / status symbol |

A 75 R$ item is affordable after an 80 R$ purchase with 5 R$ leftover. A 99 R$ item fits comfortably in the 400 R$ tier. Avoid prices that sit just above a tier boundary (e.g., 85 R$ forces the next tier up).

## Revenue per Sale

Roblox takes approximately 30% of every GamePass or DevProduct sale:

| Sale price (R$) | Earned R$ (~70%) | USD net (DevEx $0.0038) | USD net (DevEx $0.0035 old) |
|-----------------:|------------------:|------------------------:|----------------------------:|
| 49 | ~34 | $0.13 | $0.12 |
| 99 | ~69 | $0.26 | $0.24 |
| 199 | ~139 | $0.53 | $0.49 |
| 499 | ~349 | $1.33 | $1.22 |
| 999 | ~699 | $2.66 | $2.45 |
| 1999 | ~1399 | $5.32 | $4.90 |
| 4999 | ~3499 | $13.30 | $12.25 |

The effective creator share of the original USD purchase is approximately **21%** through the standard Robux flow (player buys Robux -> spends in game -> creator DevExes).

## Conversion Benchmarks

Industry-observed ranges for Roblox experiences:

| Tier | Price range | Typical conversion rate (% of active players) |
|------|------------|-----------------------------------------------|
| Low | 49-199 R$ | 2-5% |
| Mid | 299-799 R$ | 0.5-2% |
| High | 999-4999 R$ | <0.5% |

Low-tier items drive volume; high-tier items drive per-sale revenue. Most successful games have products in all three tiers.

## Regional Pricing

Roblox adjusts prices by user geography to account for purchasing power differences. Regional Pricing is:

- **Enabled by default** for passes and Robux-priced subscriptions.
- **Opt-in** for developer products (requires dynamically scripted prices + `GetUsersPriceLevelsAsync` for trade/gift arbitrage protection).
- **Not available** for local-currency subscriptions.

Regional prices are **never discounted more than 70%** of the default price and never exceed the default.

### Early published conversion lifts from regional pricing

| Region | Conversion lift |
|--------|----------------:|
| Mexico | +17% |
| Brazil | +26% |
| Philippines | +52% |

Regional pricing does not change the Robux-to-USD DevEx rate. It changes the local-currency price players pay, increasing overall Robux velocity from price-elastic markets.

### Protecting trades and gifts

Use `MarketplaceService:GetUsersPriceLevelsAsync` to compare price levels between users before allowing transfers. Price level ranges from 1 (lowest regional price) to 1000 (full global price). Block or warn on large disparities to prevent arbitrage.

## Price Optimization Tool

Roblox offers an automated A/B testing tool for high-volume experiences (60,000+ transactions in 30 days):

1. Navigate to **Monetization > Price Optimization**.
2. Select products to test.
3. Click **Start Test**. Subsets of users see different prices for ~2 weeks.
4. Review recommendations and apply.
5. Optionally run a 4-week **Price Review** period (98% optimized / 2% original).

### Key constraints

- Only passes and developer products. **Not** subscriptions.
- Prices must be dynamically scripted (via `GetProductInfo`), not hard-coded.
- Cannot change tested product prices during the test.
- Run every ~3 months for optimal results.

### Dynamic pricing check

Use the built-in **Dynamic Price Check** tool to identify hard-coded vs. dynamically scripted prices before running a test:

```lua
-- Correct: dynamically scripted (updates for price optimization, regional pricing, Plus discounts)
local productInfo = MarketplaceService:GetProductInfo(PRODUCT_ID, Enum.InfoType.Product)
local price = productInfo.PriceInRobux

-- Wrong: hard-coded (breaks all optimization tools)
local priceInRobux = 500
```

## Subscription Pricing

In-experience subscriptions have distinct pricing:

| Payment method | Available tiers |
|---------------|----------------|
| Local currency | $2.99, $4.99, $7.99, $9.99, $14.99 |
| Robux | 49 R$ minimum, charm ladder applies (49, 99, 199, 299, 499, 999) |

Robux subscriptions support Regional Pricing by default. Price changes allowed every 60 days; increases require 30 days advance notice.

## Ethical Check

- Price entry-level items accessibly (25-99 R$) to keep onboarding affordable.
- Do not design pricing to exploit impulse control of young players.
- Cap maximum useful spend per player so excessive spending yields diminishing returns.
- See [[ethical-monetization]] for full principles.

## Pitfalls

- Pricing items just above a Robux purchase tier (e.g., 85 R$ forces the $4.99 tier for a $0.99-tier item).
- Using round numbers instead of charm prices (100 vs 99 R$).
- Hard-coding prices in the UI. Breaks price optimization, regional pricing, and Roblox Plus discounts.
- Ignoring regional pricing for developer products. Opt-in is required but the conversion lift is significant.
- Not implementing `GetUsersPriceLevelsAsync` when enabling regional pricing on DevProducts. Opens arbitrage exploits in trading/gifting.

## Related

- [[game-pass]]
- [[dev-product]]
- [[developer-exchange]]
- [[ethical-monetization]]

## Sources

- [Pricing Strategy](../raw/community/monetization/gamepass/pricing-strategy.md) -- charm pricing playbook and conversion data
- [DevEx Rates and Economics](../raw/community/monetization/premium-payouts/devex-rates-and-economics.md) -- revenue ladder and platform cut math
- [Price Optimization (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/price-optimization.md) -- automated A/B testing tool
- [Regional Pricing (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/regional-pricing.md) -- region-specific pricing and arbitrage protection
