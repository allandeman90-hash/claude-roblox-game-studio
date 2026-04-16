---
title: Key Analytics Metrics - ARPDAU, Conversion Rate, Retention
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/analytics/monetization.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: analytics
subcategory: telemetry
tags: [arpdau, arppu, conversion-rate, retention, dau, mau, analytics]
---

# Key Analytics Metrics — ARPDAU, Conversion Rate, Retention

The Roblox Creator Hub surfaces a set of analytics metrics on every
experience. Understanding them is fundamental to running live-ops.

## Core metric definitions

### Engagement metrics

- **DAU (Daily Active Users)** — unique users who played your experience
  in a 24-hour window.
- **MAU (Monthly Active Users)** — unique users in a 30-day window.
- **Session length** — average minutes per session (capped for
  algorithm purposes at 60 min/day per user).
- **DAU/MAU ratio** — "stickiness". A value of 0.20 means 20% of your
  monthly audience shows up on a typical day. Platform-wide average for
  Roblox itself is approximately 20.9% (2024).

### Retention metrics

- **D1 retention** — % of new users who return the day after their
  first visit.
- **D7 retention** — % who return 8 days after first visit.
- **D30 retention** — % who return 31 days after first visit.
- Reported by **cohort** (grouped by first-play date) and viewable by
  **acquisition source** (as of Oct 2025).

### Monetization metrics

- **Paying users** — DAU who spent Robux on IAP in the window.
- **Conversion rate** — `paying_users / DAU`. What % of playing users
  convert to payers.
- **ARPPU (Average Revenue Per Paying User)** — mean Robux spent by
  payers only.
- **ARPDAU (Average Revenue Per Daily Active User)** —
  `daily_revenue / DAU`. Combines conversion and ARPPU.
- **Revenue** split by DevProduct, GamePass, and commissions
  (pending commission from Premium / Creator Rewards).

**Formula:**
```
ARPDAU = conversion_rate × ARPPU
```

## Concrete Numbers / Examples

### ARPDAU benchmarks (Robux)

| Tier | ARPDAU (Robux) | Notes |
|------|----------------:|-------|
| Entry / new game | 0.1 – 0.5 | Typical for a first release |
| Decent mid-tier | 1.0 – 2.0 | Profitable with enough DAU |
| Strong | 2.0 – 5.0 | Well-tuned shop, good retention |
| Top 1% | 5.0 – 8.0+ | "Top games all have ARPDAUs of far higher than 2, even as far up as 8" |

At DevEx new rate ($0.0038/R$), ARPDAU of 2.0 R$ = ~$0.53 USD/day/user
creator revenue (~$0.76 gross, minus the 30% platform cut).

### Conversion rate

- Typical games: **1–3%** conversion
- Strong: **3–5%**
- Exceptional: **5%+**

### Retention curves (rule-of-thumb for sim / casual genres)

| Retention | Entry | Decent | Strong |
|-----------|-----:|-------:|-------:|
| D1        |   25% |    35% |    45%+ |
| D7        |    8% |    15% |    25%+ |
| D30       |    3% |     7% |    12%+ |

### Platform-wide stats (2025, from Statista)

- DAU: ~111.8 million
- MAU: ~380 million
- DAU/MAU: ~20.9% (2024)

## Metric optimization playbook

### To improve conversion rate

- **Identify barriers**: items too expensive, shop hidden, no onboarding.
- **Welcome discounts** for first-time buyers (see ethical-monetization/).
- **Audit purchase funnel** — at what step do players drop?
- **Entry-level products** (25–99 R$) for accessible first conversion.
  Once a player spends once, they're dramatically more likely to spend
  again.

### To improve ARPPU

- **Tiered purchase options** (49 → 199 → 499 → 999).
- **Consumables and repeatables** (not just one-time passes).
- **Seasonal variety** — rotate catalog, run events.
- **Anchoring** — show expensive tier first.

### To improve ARPDAU

- Trick is "varied price points and strong retention."
- **High ARPPU + low ARPDAU** = revenue from a narrow whale base.
  Risky — one churned whale drops revenue visibly.
- **Wide engagement > deep engagement** for algorithmic reach (the
  Discover algorithm prefers spend-days across a broad base).

### To improve retention

- First 5 minutes of play: "get to the fun" — see onboarding best
  practices.
- Daily login rewards (7–14 day cycles).
- Live events every 2–4 weeks.
- Social features: guilds, parties, friend invites.
- Variety of goals: short, medium, long term.

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/analytics/monetization.md
Related: https://devforum.roblox.com/t/is-it-possible-to-get-very-high-arpdaus/2950843
Related: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/analytics/retention.md
Captured: 2026-04-16
