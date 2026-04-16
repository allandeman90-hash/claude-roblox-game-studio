---
title: Engagement-Based Payouts (Deprecated) and Creator Rewards
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/engagement-based-payouts.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: monetization
subcategory: premium-payouts
tags: [ebp, creator-rewards, premium, payouts, audience-expansion, engagement]
---

# Engagement-Based Payouts and Creator Rewards

## Status

**Engagement-Based Payouts (EBP) was deprecated on July 24, 2025** and
replaced by the **Creator Rewards** program.

## EBP (historical reference)

EBP earned developers Robux based on the share of time Roblox Premium
members engaged in their experience. Key fields the dashboard surfaced:

- **Premium Playtime Robux Earned** — projected earnings based on
  aggregated 28-day Premium subscriber behavior (NOT a direct daily
  calculation)
- **Premium Playtime Score** — amount of time Premium subscribers engage
  with the experience per day; used as immediate feedback for changes
- **Premium Visits** — count of visits from Premium members
- **28-day delay** — payouts have a 28-day delay so Roblox can calculate
  engagement across the full month of a Premium subscription
- A "projected earnings" dotted line became a solid bar once the payout
  was finalized and added to Pending Robux

EBP produced no public formula or percentage. The only tool for optimization
was changing gameplay, observing Premium Playtime Score, and comparing.

## Creator Rewards (current, launched July 24, 2025)

The new program has **two components**:

### 1. Daily Engagement Rewards

Developers earn **5 Robux** when an "Active Spender" plays their game for
10+ minutes in a day, provided the game is among that user's first three
visited experiences that day.

**Active Spender** = a user who has spent at least **$9.99** in real money
on Roblox within the past **60 days**. This greatly broadens the eligible
audience beyond Premium subscribers.

### 2. Audience Expansion Rewards

Developers receive **35% commission on the first $100** spent by new or
returning users who came to Roblox through their experience. Attribution
sources include:
- In-game referral links
- SEO / organic discovery of the experience
- Platform prominence and algorithmic recommendations

This replaces the Creator Affiliate program.

## Concrete Numbers / Examples

| Item | Value |
|------|-------|
| EBP payout delay | 28 days |
| Creator Rewards Daily Engagement per session | 5 Robux |
| Daily Engagement minimum session | 10 minutes |
| Daily Engagement scope | First 3 experiences of the day |
| Active Spender threshold | $9.99 in past 60 days |
| Audience Expansion commission | 35% on first $100 |
| Program replacement date | July 24, 2025 |

## Strategic implications

- **EBP optimization playbook is dead.** Games that were tuned to maximize
  Premium session length should re-audit. The new system rewards any
  spender session, not just Premium.
- **First 3 experiences a day** is the new scarcity mechanic. Retention
  to be "in the first 3 games played" is more valuable than long sessions
  past the 10-minute threshold.
- **Onboarding funnels matter more** because Audience Expansion pays 35%
  on the first $100 — the key is getting new spenders in the door.
- **DevEx math** — at $0.0035/Robux, 5 Robux per qualifying session is
  worth $0.0175. Those nickels scale only if your DAU of active spenders
  is high.

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/production/monetization/engagement-based-payouts.md
Additional: https://www.spaceport.xyz/blog/roblox-developer-rewards-changes
Captured: 2026-04-16
