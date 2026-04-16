---
title: Configs and Experiments - Roblox Remote Config and A/B Testing
type: raw-source
source_url: https://devforum.roblox.com/t/live-now-use-configs-and-experiments-to-grow-your-game-faster/4051385
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-10
category: live-ops
subcategory: feature-flags
tags: [configs, experiments, ab-testing, remote-config, feature-flags, live-ops]
---

# Configs and Experiments — Roblox Remote Config and A/B Testing

Roblox Configs and Experiments is Roblox's first-party remote-config and
A/B testing system, built into Creator Hub. Before this existed, every
studio rolled its own via DataStore or MessagingService.

## Configs (remote config / feature flags)

Configs let you launch features or update in-game values in real time
**without restarting servers**.

### How to author a config

1. Open Creator Hub or Studio → File menu → Configs.
2. Create a config entry: key, type (string / number / boolean / JSON),
   default value.
3. Test value in Studio.
4. Publish. Changes are **staged first**, so you can test before pushing.
5. Deployment: changes propagate within **~5 minutes**; optional
   **15-minute gradual rollout** window.

### Read from Luau

Configs are read via the ServerScriptService configs API. The pattern is
to delay reading the config until the value is actually needed so that
players aren't enrolled into experiments before the feature is exercised.

### Hard limits

| Limit | Value |
|-------|-------|
| Active configs per universe | 1,000 |
| Concurrent in-experience experiments | 10 |
| Concurrent matchmaking experiments | 1 |
| Supported types | string, number, boolean, JSON |

### Example use cases

- Turn a new onboarding flow on/off without a patch.
- Adjust weapon damage for live balance.
- Change daily login reward amounts for a seasonal push.
- Kill-switch a broken minigame.
- Flip a starter pack on for 24 hours.

## Experiments (A/B testing)

Experiments sit on top of configs. Each experiment ships 2–8 groups, each
with its own config value, and Roblox routes a percentage of players to
each group.

### Setup

1. Create a config first (the thing being tested).
2. Creator Hub → Experiments → New.
3. Choose type: **in-experience** or **matchmaking**.
4. Define groups: control + up to 7 variants.
5. Distribution percentages must sum to 100%.
6. Start the experiment.

### Results

- Enrollment count shown under **Details**.
- Statistically significant results populate **Results** in 24–48 hours.
- Once stable, you can ramp a winning variant to 100%.

### Statistical guidance

- Watch the **Minimum Detectable Effect (MDE)**:
  - Very high MDE (±100%) → no statistical power, wait or redesign
  - Very low MDE (< 0.01%) → you can conclude faster
- **Do not make decisions before the full duration expires.** Early swings
  are novelty effects.
- Treat non-significant results as **no change**. Don't cherry-pick.
- Run **one change per experiment** where possible — overlapping changes
  produce interaction effects.
- Document every experiment: hypothesis, variant design, result, decision.

### Example experiment

- **Hypothesis**: a 50% reduction in crafting timer increases D1 retention.
- **Config**: `craftTimerMultiplier` (number, default 1.0).
- **Groups**:
  - Control: `1.0` (50% traffic)
  - Variant A: `0.5` (50% traffic)
- **Primary metric**: D1 retention.
- **Secondary metrics**: session time, coin purchases.
- **Duration**: 14 days (or until MDE < 5%).

## Concrete Numbers / Examples

- Config propagation: **5 minutes** (or 15-minute gradual rollout)
- Max active configs: **1,000 per universe**
- Max concurrent experiments: **10 in-game + 1 matchmaking**
- Minimum results wait: **24–48 hours**
- Group cap: **8 per experiment**
- Data types: **string, number, boolean, JSON** (table auto-decoded)

## Source

Original URL: https://devforum.roblox.com/t/live-now-use-configs-and-experiments-to-grow-your-game-faster/4051385
Related: https://create.roblox.com/docs/production/experiments
Captured: 2026-04-16
