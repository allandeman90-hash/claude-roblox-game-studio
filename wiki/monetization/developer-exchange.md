---
title: developer-exchange
type: monetization
category: monetization
subcategory: payouts
owner: monetization-lead
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/premium-payouts/devex-rates-and-economics.md
  - wiki/raw/community/monetization/premium-payouts/engagement-based-payouts-and-creator-rewards.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/roblox-plus.md
related:
  - "[[robux-price-tiers]]"
  - "[[game-pass]]"
  - "[[dev-product]]"
  - "[[engagement-based-payouts]]"
tags: [monetization, payouts, devex]
---

# Developer Exchange (DevEx)

> Roblox's program for converting Earned Robux to real currency. The final step in the Roblox monetization pipeline where virtual earnings become cash payouts.

## Summary

The Developer Exchange (DevEx) is how Roblox creators convert Earned Robux into real-world currency. The current rate is **$0.0038 per Earned Robux** (effective September 5, 2025). Understanding the rate tables, the platform cut, and how different revenue streams compare is essential for revenue modeling and business planning.

## DevEx Rate Table

| Period | Rate per Earned Robux | 10,000 R$ | 100,000 R$ | 1,000,000 R$ |
|--------|-----------------------:|----------:|----------:|----------:|
| Before 2025-09-05 10:00 PT ("Old Rate") | $0.00350 | $35.00 | $350.00 | $3,500.00 |
| From 2025-09-05 10:00 PT ("New Rate") | **$0.00380** | $38.00 | $380.00 | $3,800.00 |

The rate is applied on a **per-cohort basis**: Robux earned under the old rate stays at $0.0035; Robux earned under the new rate cashes out at $0.0038. Roblox tracks which bucket the balance is in.

## Cash-Out Requirements

| Requirement | Details |
|-------------|---------|
| Minimum per cash-out | **30,000 Earned Robux** |
| Minimum USD at new rate | **$114** (30,000 x $0.0038) |
| Minimum USD at old rate | $105 (30,000 x $0.0035) |
| Maximum per cash-out | No maximum -- full balance in one request |
| Age requirement | Must be **13+ years old** |
| Payment processor | **Tipalti** (bank, PayPal, regional methods) |

## The 30% Platform Cut

When a player spends Robux on a GamePass or DevProduct, Roblox keeps approximately 30%:

- Player spends 100 R$ on an item.
- Roblox keeps ~30 R$.
- Creator earns ~70 R$ (Earned Robux).
- At DevEx new rate: 70 x $0.0038 = **$0.266 USD**.
- **Effective creator share of original retail dollar: ~21%**.

### Revenue Ladder

| Sale price (R$) | Earned R$ (~70%) | USD net (new $0.0038) | USD net (old $0.0035) |
|-----------------:|-----------------:|----------------------:|----------------------:|
| 49 | ~34 | $0.13 | $0.12 |
| 99 | ~69 | $0.26 | $0.24 |
| 199 | ~139 | $0.53 | $0.49 |
| 499 | ~349 | $1.33 | $1.22 |
| 999 | ~699 | $2.66 | $2.45 |
| 4999 | ~3499 | $13.30 | $12.25 |

## Earned Robux vs Pending Robux

| State | Description |
|-------|-------------|
| **Pending Robux** | Revenue that has landed but is in a holding period. Fraud/reversal screening. |
| **Earned Robux** | Pending that has matured. Only Earned is DevEx-eligible. |

- **GamePass/DevProduct holding period**: approximately **3-5 days**.
- **Local-currency subscription holding period**: **30 days**.
- **Roblox Plus sign-up referral**: **60 days**.
- Transaction fraud reversals come out of Pending only.

## Revenue Comparison by Channel

Different monetization channels have different effective economics:

### Standard Robux flow (GamePass / DevProduct)

```
Player pays $5 USD -> buys ~400 R$ -> spends 400 R$ in-game
-> Creator earns ~280 R$ -> DevEx at $0.0038 -> ~$1.06 USD
-> Effective share: ~21%
```

### In-experience subscriptions (local currency)

```
Month 1: $5 x 70% = $3.50 worth (~350 R$)
Month 2+: $5 x 100% = $5.00 worth (~500 R$)
```

Local-currency subscriptions from month 2 onward are **dramatically** better than the ~21% effective share of the standard Robux flow.

### In-experience subscriptions (Robux)

```
Every month: 199 R$ x 70% = ~139 R$ -> DevEx ~$0.53/month
```

### Paid Access (real-money tiers)

Experiences sold via Paid Access have substantially better revenue shares:

| Paid Access price | Creator share |
|------------------:|--------------:|
| $29.99 | **60%** (~$18.00) |
| $49.99 | **70%** (~$35.00) |

Compare to the ~21% effective share of the standard Robux flow.

### Creator Rewards

```
Per qualifying Active Spender session: 5 R$ -> DevEx ~$0.019
```

At scale (e.g., 10,000 qualifying sessions/day), this yields ~$57,000/year, but it is supplementary income, not the primary monetization channel for most games.

### Roblox Plus referral

```
Per subscriber acquired: 250 R$/month x 3 months = 750 R$
-> DevEx ~$2.85 per subscriber (after 60-day hold)
```

## Revenue Modeling Example

A hypothetical experience with 50,000 DAU:

| Revenue stream | Assumptions | Monthly R$ | Monthly USD |
|---------------|-------------|----------:|----------:|
| GamePass sales | 2% conversion, avg 199 R$, 30-day window | ~199,000 | ~$530 |
| DevProduct sales | 5% of DAU buy avg 99 R$/day | ~7,425,000 | ~$19,750 |
| Creator Rewards | 10% are Active Spenders, 50% qualify | ~75,000 | ~$200 |
| Subscriptions (local $4.99) | 1% of DAU, month 2+ | ~250,000 | ~$950 |
| **Total** | | **~7,949,000** | **~$21,430** |

These are illustrative. Real numbers vary enormously by genre, quality, and audience.

## Tax Considerations

- DevEx payouts are **taxable income** in most jurisdictions.
- Roblox issues tax forms (1099 in the US) for creators who exceed reporting thresholds.
- Non-US creators may be subject to withholding.
- Consult a tax professional for your specific situation.

## Ethical Check

- DevEx economics should not drive predatory monetization design. Chasing higher per-player revenue at the expense of player experience damages long-term LTV and algorithm ranking.
- The Discover algorithm weighs 7-day retention heavily. Games with aggressive short-term monetization but poor retention get deranked.
- Sustainable revenue = broad engaged player base x fair monetization. See [[ethical-monetization]].

## Pitfalls

- Confusing Pending with Earned Robux. Only Earned can be cashed out.
- Assuming old-rate and new-rate Robux are fungible. They are tracked separately.
- Planning revenue based on retail Robux price ($5 -> 400 R$) without accounting for the 30% platform cut and DevEx rate. Effective share is ~21%, not 70%.
- Ignoring local-currency subscriptions. Month-2+ economics (100% share) are far superior to the standard Robux flow for recurring benefits.
- Robux received through Roblox Plus transfers are **not eligible** for DevEx.

## Related

- [[robux-price-tiers]]
- [[game-pass]]
- [[dev-product]]
- [[engagement-based-payouts]]

## Sources

- [DevEx Rates and Economics](../raw/community/monetization/premium-payouts/devex-rates-and-economics.md) -- rate tables, platform cut math, regional pricing uplift
- [Engagement-Based Payouts and Creator Rewards](../raw/community/monetization/premium-payouts/engagement-based-payouts-and-creator-rewards.md) -- Creator Rewards economics
- [Roblox Plus (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/roblox-plus.md) -- Plus subscriber creator earnings
