# Economy Model: [Game Name]

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: economy-designer
**Status**: [Draft / Approved / Live]

---

## Overview

Brief description of the economy design intent.

---

## Currencies

| Currency | Symbol | Type | Purpose |
|----------|--------|------|---------|
| Gold | 💰 | Soft | Main transaction currency |
| Gems | 💎 | Premium | Rare purchases, revives, boosts |
| Tokens | 🎫 | Seasonal | Event rewards |

---

## Faucets (Where Currency Comes From)

| Source | Currency | Amount | Frequency | Rate/Hour |
|--------|----------|--------|-----------|-----------|
| Quest reward | Gold | 50-500 | Per quest | ~1500 |
| Enemy drop | Gold | 5-30 | Per kill | ~3600 |
| Daily login | Gold | 500 | 1/day | 21/hr avg |
| Level up | Gold | 100 × level | Per level | variable |
| Achievement | Gems | 10-100 | Per achievement | rare |
| Event | Tokens | variable | Event only | event-specific |

---

## Sinks (Where Currency Goes)

| Sink | Currency | Amount | Frequency | Drain/Hour |
|------|----------|--------|-----------|-----------|
| Shop items | Gold | 50-10000 | Variable | ~500 |
| Gear upgrade | Gold | 100-50000 | Slow | ~300 |
| Repair | Gold | 20-100 | Frequent | ~200 |
| Prestige | Gold | 1M | Rare | variable |
| Revive | Gems | 10 | Per death | ~5/hr avg |
| Event shop | Tokens | 100-1000 | Event | event-specific |

---

## Currency Flow Diagram

```
 ┌──────┐         ┌──────┐        ┌──────┐
 │Quests│─────────►│     │        │      │
 └──────┘          │     │        │ Shop │
 ┌──────┐          │     │◄───────│      │
 │Drops │──────────► Gold│        └──────┘
 └──────┘          │     │        ┌──────┐
 ┌──────┐          │     │◄───────│Upgrades│
 │Daily │──────────►│    │        └──────┘
 └──────┘          └──┬──┘
                      │
                      ▼
                  ┌──────┐
                  │Repair│  (small continuous sink)
                  └──────┘
```

---

## Time-to-Earn Targets

| Item | Price | New Player | Mid-Game | Notes |
|------|-------|------------|----------|-------|
| Basic sword | 100 G | 5 min | 1 min | Tutorial reward |
| Good gear | 1000 G | 30 min | 10 min | First major goal |
| Rare set | 10000 G | 5 hrs | 1 hr | Mid-game goal |
| Epic gear | 100000 G | 50 hrs | 10 hrs | Late-game |
| Legendary | 1M G | 500+ hrs | 100 hrs | Prestige goal |

---

## Net Flow by Player Archetype

### Player A: Casual (1 hr/day)
- Earns ~2000 Gold/hr
- Spends ~1500 Gold/hr
- Net: +500 Gold/hr → 15000 Gold/month
- Can afford: mid-game gear by day 14

### Player B: Engaged (3 hrs/day)
- Earns ~2500 Gold/hr (better grinding routes)
- Spends ~2000 Gold/hr (upgrading faster)
- Net: +500 Gold/hr → 45000 Gold/month
- Can afford: Epic gear by day 14

### Player C: Whale (pays for 2x Gold GamePass + buys gems)
- Earns ~5000 Gold/hr (2x multiplier)
- Spends ~4000 Gold/hr (upgrading faster, more gem items)
- Net: +1000 Gold/hr
- Additional Gems purchased: ~1000/month
- Can afford: Epic gear by day 7, Legendary by day 60

---

## Inflation Management

Current inflation risk: [Low / Medium / High]

Controls in place:
- [Control 1 — e.g., "Shop prices scale with player level"]
- [Control 2 — e.g., "Prestige reset consumes 1M Gold"]
- [Control 3 — e.g., "Event items provide high-cost luxury goods"]

---

## GamePass Economy Impact

| GamePass | Effect | Balance Impact |
|----------|--------|----------------|
| 2x Gold | Doubles gold earnings | +100% income |
| Auto-collect | Free drop collection | +10% effective income |
| VIP | +10% rewards, chat | +10% income, soft cosmetic |

These are bonuses, not requirements. Free players reach all content; paid players reach it faster.

---

## Projections

### 30-Day Player Wealth Model

| Day | Player A | Player B | Player C |
|-----|----------|----------|----------|
| 1   | 500 G    | 1500 G   | 10000 G  |
| 7   | 3500 G   | 10500 G  | 50000 G  |
| 14  | 7000 G   | 21000 G  | 100000 G |
| 30  | 15000 G  | 45000 G  | 250000 G |

Verify: Each archetype is making meaningful progress and feeling the right pace.

---

## Simulation Notes

- [Key assumption 1]
- [Key assumption 2]
- [Data source or playtest]

---

## Open Questions

- [ ] [Question about the model]
- [ ] [Question about the model]
