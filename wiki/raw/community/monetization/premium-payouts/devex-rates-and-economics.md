---
title: DevEx Rates, Earned Robux, and Cash-Out Economics
type: raw-source
source_url: https://en.help.roblox.com/hc/en-us/articles/27984458742676-Earned-Robux-Earned-Robux-Balance-and-DevEx-Rates
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: monetization
subcategory: premium-payouts
tags: [devex, robux, cash-out, earnings, tipalti, revenue]
---

# DevEx Rates, Earned Robux, and Cash-Out Economics

The Developer Exchange (DevEx) is how creators convert Earned Robux into
real currency. Understanding the rate tables, the platform cut, and the
regional uplifts is essential for revenue modeling.

## DevEx rate table (as of 2026-04)

| Period | Rate per Earned Robux | 10,000 Robux | 100,000 Robux |
|--------|-----------------------:|--------------:|---------------:|
| Before 2025-09-05 10:00 PT ("Old Rate") | $0.00350 | $35.00 | $350.00 |
| From 2025-09-05 10:00 PT ("New Rate") | $0.00380 | $38.00 | $380.00 |

The rate is applied on a **per-cohort** basis: Robux earned under the old
rate stays at $0.0035, Robux earned under the new rate cashes out at
$0.0038. Roblox tracks which bucket your balance is in.

## Cash-out minimum

- **30,000 Earned Robux minimum** per cash-out request.
- At new rate: 30,000 × $0.0038 = **$114 USD**.
- At old rate: 30,000 × $0.0035 = **$105 USD**.
- No maximum — one request can cash out the full balance.
- Must be **13+ years old** to DevEx.
- Payouts are processed by **Tipalti** to bank, PayPal, or regional methods.

## The 30% platform cut

When a player spends 100 Robux in your game on a GamePass or DevProduct,
Roblox keeps approximately 30% and you keep 70% (i.e. 70 Robux Earned).

**Effective USD math at the new rate:**

- Player pays: 100 R$ (~$1.25 USD at Robux retail)
- Roblox keeps: ~30 R$
- Creator earns: ~70 R$
- At DevEx new rate: 70 × $0.0038 = **$0.266 USD**
- Effective share of original purchase: ~21%

### Example revenue ladder

| Sale price (R$) | Earned (R$) | USD net at new rate | USD net at old rate |
|-----------------:|-------------:|---------------------:|---------------------:|
|              49 |         ~34 |                $0.13 |                $0.12 |
|              99 |         ~69 |                $0.26 |                $0.24 |
|             199 |        ~139 |                $0.53 |                $0.49 |
|             499 |        ~349 |                $1.33 |                $1.22 |
|             999 |        ~699 |                $2.66 |                $2.45 |
|            4999 |       ~3499 |               $13.30 |               $12.25 |

## Earned Robux vs Pending Robux

- **Pending Robux**: revenue that has landed but is in a 3-day holding
  period while Roblox screens for fraud / reversals.
- **Earned Robux**: Pending that has matured. Only Earned is DevEx-able.
- Transaction fraud reversals come out of **Pending** only.

## Regional pricing uplift (2025 launch)

Roblox launched Regional Pricing in April 2025, adjusting Robux purchase
prices based on user geography. Early published uplift results:

| Region | Conversion lift |
|--------|----------------:|
| Mexico | +17% |
| Brazil | +26% |
| Philippines | +52% |

Regional pricing does not change the Robux → USD rate that developers
see; it changes the local-currency price players pay. The downstream
effect is higher overall Robux velocity from price-elastic markets.

## Paid Access (real-money tiers)

For experiences sold via Paid Access (one-time real-money unlock),
revenue shares are substantially better than standard Robux DevEx:

| Paid access tier | Creator share |
|------------------|--------------:|
|           $29.99 |           60% |
|           $49.99 |           70% |

Compare to standard Robux → DevEx flow, which effectively nets ~21%.

## Concrete Numbers / Examples

- DevEx rate: **$0.0035** (old) / **$0.0038** (new) per Earned Robux
- Cash-out minimum: **30,000 R$** ≈ **$114 USD** (new rate)
- Platform cut: **~30%** on GamePass / DevProduct sales
- Creator effective share of retail dollar: **~21%** on Robux flow
- Paid Access $49.99: **70% creator share** (direct)
- 3-day Pending → Earned holding period for fraud screening
- DevEx payouts processed by **Tipalti**, age-gated to 13+

## Source

Original URL: https://en.help.roblox.com/hc/en-us/articles/27984458742676-Earned-Robux-Earned-Robux-Balance-and-DevEx-Rates
Related: https://en.help.roblox.com/hc/en-us/articles/203314100
Captured: 2026-04-16
