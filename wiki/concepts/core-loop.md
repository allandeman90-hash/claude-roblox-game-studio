---
title: core-loop
type: concept
category: concepts
subcategory: design
owner: game-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md
related:
  - "[[ftue-design]]"
  - "[[daily-rewards]]"
  - "[[quest-system]]"
  - "[[leaderboard-pattern]]"
tags: [concept, design, game-design, retention]
---

# Core Loop

> The repeating action sequence that forms the heart of gameplay, operating at four nested time scales: 30-second, 5-minute, session, and meta.

## What It Is

A core loop is the fundamental repeating cycle of actions a player performs. In a shooter, it is "find enemy, aim, shoot, loot." In a simulator, it is "collect, sell, upgrade." The loop must be inherently satisfying at its tightest cadence and progressively rewarding at longer cadences. Roblox design typically considers four nested loops.

## When to Use It

Every game has a core loop, whether designed intentionally or not. Explicitly designing and measuring the loop is the foundation of retention-focused game design.

## Implementation

### The Four Loop Scales

| Scale | Duration | Example (tycoon) | Design goal |
|-------|----------|-------------------|-------------|
| **Micro loop** | ~30 seconds | Click dropper, collect resource, deposit | Satisfying moment-to-moment feel |
| **Engagement loop** | ~5 minutes | Accumulate enough to buy next upgrade | Visible progress toward a clear goal |
| **Session loop** | 15-30 minutes | Unlock a new area or prestige | Reason to keep playing this session |
| **Meta loop** | Days/weeks | Complete a season pass, build a collection | Reason to return tomorrow |

### How Monetization Fits

Each loop scale has a natural monetization lever:

```
Micro (30s)     -> Skip timers, instant-complete purchases
Engagement (5m) -> Boosts, multipliers, premium tools
Session (30m)   -> Passes, starter packs, first-purchase offers
Meta (days)     -> Battle pass, daily reward premium track, exclusive collections
```

The most sustainable Roblox monetization sits at the session and meta levels. Micro-loop monetization (pay to skip) can feel exploitative and hurts retention.

### Roblox-Specific Considerations

- **Short average sessions.** Roblox sessions average 15-25 minutes, heavily mobile. The session loop must deliver a complete reward arc within that window.
- **Social multiplier.** Playing with friends extends sessions. Design the engagement loop to be more rewarding with groups (co-op bonuses, party XP, shared quests).
- **Discoverability churn.** Players constantly try new games. The [[ftue-design]] must demonstrate the core loop within 2 minutes or the player is gone.
- **Content cadence dependency.** The meta loop depends on regular content drops. See live-ops cadence: weekly cosmetics, bi-weekly quest packs, monthly events.

### Diagnosing Loop Problems

| Symptom | Likely problem | Loop scale |
|---------|---------------|------------|
| Low D1 retention (< 20%) | Core loop not reached or not compelling | Micro / FTUE |
| Good D1, bad D7 | No meta hook; nothing to return for | Meta loop |
| Long sessions but low return | Session loop is satisfying but meta is empty | Meta loop |
| Short sessions (< 5 min) | Engagement loop too slow or unclear | Engagement loop |
| High quit rate at specific point | Progression wall or broken reward pacing | Engagement/session |

### Measurement

Track these metrics per loop scale:

```lua
-- Micro loop: actions per minute
AnalyticsService:LogCustomEvent(player, "micro_action_completed")

-- Engagement loop: time to next milestone
AnalyticsService:LogCustomEvent(player, "upgrade_purchased", { upgradeId = id })

-- Session loop: session length, prestige events
AnalyticsService:LogCustomEvent(player, "prestige_completed", { level = n })

-- Meta loop: daily return, season progress
AnalyticsService:LogCustomEvent(player, "daily_login", { streak = n })
```

### Design Template

When designing a core loop, fill in this template:

```
MICRO (30s):  Player does [ACTION], gets [IMMEDIATE FEEDBACK]
ENGAGE (5m):  After N micro loops, player earns [UPGRADE/UNLOCK]
SESSION (30m): After N engage loops, player achieves [MILESTONE]
META (days):  Over N sessions, player completes [COLLECTION/RANK]
```

Example for a pet simulator:
```
MICRO (30s):  Player taps to hatch eggs, gets a pet
ENGAGE (5m):  After 10 hatches, player upgrades hatchery speed
SESSION (30m): After 5 upgrades, player unlocks new area with rarer pets
META (days):  Over 14 days, player completes the legendary pet collection
```

## Variants

| Genre | Micro | Engage | Session | Meta |
|-------|-------|--------|---------|------|
| **Tycoon** | Click/collect | Buy upgrade | Unlock area | Prestige/rebirth |
| **Simulator** | Tap/action | Level up tool | Unlock world | Season pass |
| **RPG** | Combat encounter | Level up | Complete dungeon | Gear collection |
| **Obby** | Complete stage | Complete world | Reach final boss | Speedrun leaderboard |
| **Social** | Chat/emote | Make friend | Attend event | Build reputation |

## Pitfalls

- **Loop broken at engagement scale.** If the 5-minute loop is unclear ("what should I do next?"), players leave. Every micro-loop completion should visibly advance toward the next engagement milestone. Use progress bars, counters, and percentage indicators.
- **Meta loop absent.** Many Roblox games have great micro and engagement loops but no reason to return the next day. This is the #1 cause of good D1 but terrible D7. Add daily rewards, season passes, or time-gated content.
- **Over-monetizing the micro loop.** Selling instant-skip for the 30-second loop makes the game feel pay-to-win. Monetize at session and meta scales instead.
- **Progression walls.** An abrupt spike in the cost/time to reach the next milestone causes players to quit. Smooth the progression curve; test with real players, not dev accounts with max resources.
- **Ignoring social loops.** Roblox is a social platform. The most successful games have loops that are better with friends. Add party bonuses, shared goals, and social leaderboards.

## Related

- [[ftue-design]] -- the FTUE introduces the micro and engagement loops
- [[daily-rewards]] -- the meta-loop retention mechanic
- [[quest-system]] -- quests are the structured engagement loop
- [[leaderboard-pattern]] -- leaderboards drive the meta loop

## Sources

- [wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md](../raw/community/monetization/live-ops/liveops-essentials-cadence.md) -- content cadence, retention targets, loop scales
