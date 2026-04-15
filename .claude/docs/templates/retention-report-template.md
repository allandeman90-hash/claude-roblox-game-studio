# Retention Report: [Period]

**Date**: YYYY-MM-DD
**Author**: analytics-retention-specialist
**Period analyzed**: [start date] to [end date]
**Data Source**: [Roblox Analytics / custom telemetry / PlayFab / etc.]

---

## Executive Summary

1-3 sentences on overall player health. Is retention growing, stable, or declining? What's the main takeaway?

---

## Metric Snapshot

| Metric | Target | Current | Delta (vs prev) | Status |
|--------|--------|---------|-----------------|--------|
| D1 Retention | > 25% | 23% | +1% | 🟡 |
| D7 Retention | > 12% | 10% | -0.5% | 🔴 |
| D30 Retention | > 5% | 4% | 0% | 🔴 |
| Avg Session Length | > 15 min | 18 min | +2 min | 🟢 |
| Sessions/Day/Player | > 1.5 | 1.3 | -0.1 | 🟡 |
| New Players/Day | n/a | 500 | +50 | info |
| CCU Peak | n/a | 150 | +20 | info |
| Conversion Rate | > 3% | 2.5% | -0.2% | 🟡 |
| ARPDAU | > $0.05 | $0.04 | +$0.005 | 🟡 |

---

## Primary Concern

**[Metric name]** is [X%] below target. [1-2 sentences on why this matters.]

---

## Funnel Analysis

### New Player Funnel
```
Step 1: Joined game              1000 (100%)
Step 2: Past loading screen       980 (98%)   [-2%]
Step 3: Completed tutorial        820 (82%)   [-16%]  ← Biggest drop
Step 4: Earned first reward       780 (78%)   [-5%]
Step 5: Reached level 5           500 (50%)   [-36%]  ← Big drop
Step 6: Made first purchase        35 (3.5%)  [-93%]
Step 7: Returned day 2            230 (23%)
```

**Observations**:
- Tutorial has a 16% drop — investigate for friction
- Level 5 wall — content may be too grindy, or no clear next goal
- Conversion is only 3.5% — price/value or discoverability issue

---

## Platform Breakdown

| Platform | Players | D1 Retention | Session Length | Notes |
|----------|---------|--------------|----------------|-------|
| Mobile iOS | 40% | 22% | 15 min | — |
| Mobile Android | 30% | 20% | 14 min | Higher crash rate |
| PC (Windows) | 20% | 30% | 25 min | Most engaged |
| Console Xbox | 7% | 25% | 20 min | — |
| Tablet | 3% | 23% | 18 min | — |

---

## Hypotheses for Weak Metrics

### Why is D7 low?
- **H1**: No strong reason to return after day 1 (daily reward not compelling enough)
- **H2**: Mobile performance drives players away mid-session
- **H3**: Content runs out for new players by day 3

### Why is conversion low?
- **H1**: GamePass prices too high for target audience
- **H2**: Purchases not discoverable (buried in menu)
- **H3**: Free experience too complete, no push to buy

---

## Recommended Experiments

### Experiment A: Enhanced Daily Reward
- **Hypothesis**: Escalating rewards (day 1: 100 gold, day 7: 2000 gold) improve D7
- **Measure**: D7 retention over 14 days
- **Change**: Increase reward values; add "day X streak" UI
- **Sample**: 500 players per variant
- **Duration**: 14 days
- **Success Criterion**: +20% D7 retention

### Experiment B: Shop Placement
- **Hypothesis**: Adding shop button to HUD (vs. deep menu) improves conversion
- **Measure**: Conversion rate
- **Change**: Add always-visible shop icon
- **Sample**: 500 players per variant
- **Duration**: 7 days
- **Success Criterion**: +30% conversion

### Experiment C: Tutorial Skip Fix
- **Hypothesis**: Tutorial is the biggest drop-off; shortening it helps D1
- **Measure**: Funnel step 3 completion rate
- **Change**: Trim tutorial from 5 min → 2 min
- **Sample**: All new players (no A/B)
- **Duration**: 7 days
- **Success Criterion**: +10% step 3 completion

---

## Device-Specific Issues

### Android crashes
High crash rate on low-end Android devices (~5% of sessions). Recommend:
- Profile on budget Android devices
- Reduce particle rate / post-processing on low graphics setting
- Add "Performance Mode" toggle in settings

---

## Action Items

- [ ] Implement Experiment A (daily reward tuning) — target: this sprint
- [ ] Implement Experiment C (tutorial shortening) — target: this sprint
- [ ] Profile Android low-end devices — target: next sprint
- [ ] Run Experiment B (shop placement) after A completes — target: +2 weeks
- [ ] Re-review metrics in 14 days

---

## Next Review

YYYY-MM-DD (14 days from today)
