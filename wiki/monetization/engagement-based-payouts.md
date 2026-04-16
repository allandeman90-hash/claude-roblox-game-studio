---
title: engagement-based-payouts
type: monetization
category: monetization
subcategory: premium
owner: monetization-lead
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/premium-payouts/engagement-based-payouts-and-creator-rewards.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/engagement-based-payouts.md
  - wiki/raw/roblox-creator-docs/best-practices/monetization/roblox-plus.md
related:
  - "[[premium-benefits]]"
  - "[[developer-exchange]]"
  - "[[ethical-monetization]]"
tags: [monetization, premium, payouts]
---

# Engagement-Based Payouts (EBP) and Creator Rewards

> Revenue earned from platform subscriber engagement. EBP (deprecated July 2025) paid based on Premium playtime share; Creator Rewards pays per Active Spender session and for audience expansion.

## Summary

Engagement-Based Payouts was Roblox's system for distributing Robux to developers based on their share of Premium subscriber playtime. It was deprecated on **July 24, 2025** and replaced by **Creator Rewards**, which broadens the eligible audience beyond Premium subscribers and introduces clearer payout mechanics.

## EBP (Historical Reference)

EBP earned developers Robux proportional to the share of time Premium members spent in their experience relative to all experiences. The system had no public formula or fixed per-session rate.

### Dashboard metrics (now read-only)

| Metric | Meaning |
|--------|---------|
| Premium Playtime Robux Earned | Projected earnings based on aggregated 28-day Premium subscriber behavior. Not a direct daily calculation. |
| Premium Playtime Score | Amount of time Premium subscribers engage per day. Used as immediate feedback for game changes. |
| Premium Visits | Count of visits from Premium members. |

### Key characteristics

- **28-day payout delay** -- Roblox calculated engagement across the full month of a Premium subscription before finalizing payouts.
- Projected earnings (dotted line in dashboard) became solid once finalized and added to Pending Robux.
- No public formula or percentage. The only optimization lever was changing gameplay and observing the Playtime Score.

## Creator Rewards (Current Program)

Launched July 24, 2025. Two components:

### 1. Daily Engagement Rewards

Developers earn **5 Robux** when an **Active Spender** plays their experience for **10+ minutes in a day**, provided the experience is among that user's **first three visited experiences** that day.

**Active Spender** definition: a user who has spent at least **$9.99** in real money on Roblox within the past **60 days**. This greatly broadens the eligible audience beyond Premium-only subscribers.

### 2. Audience Expansion Rewards

Developers receive a **35% commission on the first $100** spent by new or returning users who came to Roblox through their experience. Attribution sources include:

- In-game referral links
- SEO / organic discovery of the experience
- Platform prominence and algorithmic recommendations

This replaces the former Creator Affiliate program.

## Concrete Numbers

| Item | Value |
|------|-------|
| EBP payout delay | 28 days |
| Creator Rewards daily engagement per qualifying session | **5 Robux** |
| Minimum session length for daily engagement | **10 minutes** |
| Maximum qualifying experiences per user per day | **3** |
| Active Spender threshold | **$9.99 spent in past 60 days** |
| Audience Expansion commission | **35% on first $100** |
| Program replacement date | July 24, 2025 |
| DevEx value of 5 R$ at new rate | $0.019 |

## Roblox Plus Creator Earnings (April 2026+)

Roblox Plus introduces additional creator earning paths beyond Creator Rewards:

- **In-experience purchases**: Plus subscriber discounts (10-20%) are subsidized by Roblox. Creator earnings unchanged at 70% of listed price.
- **Plus sign-up referral**: **250 Robux/month for 3 months** (up to 750 R$) per subscriber acquired via `PromptRobloxSubscriptionPurchase`. 60-day hold period.
- **Paid private server time**: Up to **100 Robux per subscriber per server** when subscriber spends 60+ cumulative minutes over 30 days. Top 5 servers qualify.

## Strategic Implications

### EBP optimization playbook is dead

Games tuned to maximize Premium session length should re-audit. The new system rewards any Active Spender session, not just Premium subscribers.

### First 3 experiences per day is the new scarcity

Retention to be among the first 3 games a player launches daily is more valuable than long sessions past the 10-minute threshold. This favors:

- Strong daily login hooks (daily rewards, daily quests)
- Fast FTUE (get players into the core loop within 5 minutes)
- Push notifications / friend join mechanics that bring players back early in their session

### Session length only matters to the 10-minute floor

Once a player has played 10+ minutes, additional time in that session yields no extra Creator Rewards payout. (It may still drive in-game purchases, of course.)

### Onboarding funnels matter more

Audience Expansion pays 35% on the first $100 a new spender contributes. The key is converting new visitors into spenders quickly:

- Compelling initial offer at accessible price (25-99 R$)
- Clear value proposition in the first minutes
- Low-friction purchase prompts after the player demonstrates engagement

### DevEx math

At the new DevEx rate of $0.0038/Robux, 5 Robux per qualifying session is worth ~$0.019. Those small amounts scale only with high DAU of Active Spenders. For perspective:

| Active Spender DAU | Daily R$ from engagement | Monthly R$ | Monthly USD (DevEx) |
|-------------------:|-------------------------:|-----------:|--------------------:|
| 100 | 500 | 15,000 | ~$57 |
| 1,000 | 5,000 | 150,000 | ~$570 |
| 10,000 | 50,000 | 1,500,000 | ~$5,700 |
| 100,000 | 500,000 | 15,000,000 | ~$57,000 |

These numbers assume all Active Spenders play 10+ minutes and the experience is in their first 3 daily, which is optimistic. Real conversion is lower.

## Accessing Payout Data

1. Navigate to [Creations](https://create.roblox.com/dashboard/creations) and select the experience.
2. Go to **Monetization > Engagement Payouts**.
3. Review charts for Premium Playtime Robux Earned, Playtime Score, and Premium Visits (historical EBP data).

Creator Rewards data appears in the separate **Creator Rewards** section of the dashboard.

## Ethical Check

- Do not artificially inflate session times with mechanics designed to waste player time (AFK farming, artificial wait gates).
- Time-based engagement should come from genuine fun, not friction.
- Idle detection and AFK-kick are appropriate to avoid gaming the system.
- See [[ethical-monetization]] for full principles.

## Pitfalls

- Optimizing for session length beyond 10 minutes solely for Creator Rewards. Diminishing returns after the threshold.
- Assuming all Premium subscribers are Active Spenders. The $9.99-in-60-days threshold is separate from Premium status.
- Ignoring the "first 3 experiences" constraint. Late-in-day play sessions yield zero engagement rewards if the player already played 3 other games.
- Not tracking Audience Expansion attribution. Use Roblox's referral links and monitor the analytics dashboard.

## Related

- [[premium-benefits]]
- [[developer-exchange]]
- [[ethical-monetization]]

## Sources

- [Engagement-Based Payouts and Creator Rewards](../raw/community/monetization/premium-payouts/engagement-based-payouts-and-creator-rewards.md) -- community synthesis with strategic analysis
- [Engagement-Based Payouts (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/engagement-based-payouts.md) -- official documentation with code examples
- [Roblox Plus (Roblox Creator Docs)](../raw/roblox-creator-docs/best-practices/monetization/roblox-plus.md) -- Plus subscriber creator earnings
