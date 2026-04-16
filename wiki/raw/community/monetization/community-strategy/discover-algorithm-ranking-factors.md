---
title: Roblox Discover Algorithm - Ranking Factors and Visibility
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/discovery.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: live-ops
subcategory: strategy
tags: [discovery, algorithm, ranking, recommendation, qPTR, retention]
---

# Roblox Discover Algorithm — Ranking Factors and Visibility

Roblox's "Recommended for You" ranking is the primary distribution
mechanism for organic discovery. Understanding its inputs is the single
largest lever for free user acquisition.

## Two-stage model

1. **Retrieval** — reduce the ~millions of experiences to a candidate
   shortlist for each user based on signals like engagement, retention,
   monetization, and friend activity.
2. **Ranking** — select the specific experiences a given user will see.

## Eight core metrics (7-day windows)

The algorithm evaluates these signals for users acquired from
Recommended for You traffic:

1. **Qualified Play-Through Rate (qPTR)** — conversion from impression
   to intentional engagement. Think of it as click-through on steroids:
   the player has to actually launch and start playing.
2. **Deep Play-Through Rate** — did users stick around past the intro?
3. **7-Day Playtime Per User** — total minutes played, **capped at
   60 minutes per day** to prevent outlier whales from dominating.
4. **7-Day Play Days Per User** — how many distinct days the user
   returned.
5. **7-Day Spend Days Per User** — on how many distinct days did the
   user spend Robux.
6. **7-Day Robux Spent Per User** — monetization frequency.
7. **7-Day Intentional Co-Play Days** — friend-with-friend sessions.
8. **7-Day Qualified Play Sessions** — session count.

## Critical: the algorithm only counts organic traffic

Roblox **explicitly excludes** engagement that came from:
- Ads / sponsored placements
- Today's Picks curation
- Search results
- Social referrals (Discord, TikTok, YouTube)
- Friend invites / notifications

Only engagement from the Recommended for You surface itself feeds back
into the ranking signal. This means:

- Ads are purely a cold-start accelerator; they do NOT bootstrap
  algorithmic ranking.
- A TikTok viral moment does NOT directly move the algorithm.
- Organic retention of Recommended-acquired users is the ONLY lever
  that compounds.

## Metadata rules (what gets deranked)

- **Irrelevant keywords in titles/descriptions** (keyword stuffing)
- **Mismatched thumbnails vs actual gameplay** (clickbait)
- **Leading with monetary rewards in metadata** ("FREE 1000 ROBUX")
- **Non-unique titles / assets / descriptions** that resemble other
  experiences. Clones and reskins are deranked.
- **Copy-paste trend chasing** without a unique twist.

## Positive signals

- Unique, original thumbnails.
- Clear value proposition in the first 10 seconds of play.
- High Deep-PTR (players stay past the tutorial).
- Friend co-play rate (the algorithm weights social retention heavily).

## Actionable playbook

1. **First 60 seconds matter most.** That's where qPTR and Deep-PTR are
   decided. A player who bounces in 30 seconds hurts your rank.
2. **Day-over-day return beats session length.** The 60-minute cap means
   you can't outrun competitors on playtime — you have to win on D1/D7.
3. **Spend days > spend amount.** A player who spends 5 R$ on 5 days
   outscores a player who spends 25 R$ on one day.
4. **Co-play bonus.** Features that pull friends in (private servers,
   party matchmaking, invites) compound algorithmic reach.
5. **Don't ad your way to discovery.** Ads can cold-start you but can't
   substitute for retention — the algorithm won't count ad traffic.

## Other discovery surfaces

| Surface | Mechanic |
|---------|----------|
| Sponsored ads | Paid, no algorithmic flow-through |
| Today's Picks | Manual / curated |
| Charts (trending, top) | Playcount-based, short window |
| Search | Query match, metadata relevance |
| Notifications | Retention-driven, owner's audience only |
| Friend activity | Social graph push |

## Concrete Numbers / Examples

- Playtime **cap: 60 min/day** per user for the algorithm
- Metric windows: **7-day rolling**
- Stages: **retrieval → ranking**
- 8 input signals, organic-only attribution
- Key lever for cold games: **qPTR + Deep-PTR** (onboarding quality)
- Key lever for mature games: **7-day Play Days** (retention)

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/discovery.md
Related: https://devforum.roblox.com/t/my-research-on-the-roblox-algorithm-discovery-for-experiencesgames/2707618
Captured: 2026-04-16
