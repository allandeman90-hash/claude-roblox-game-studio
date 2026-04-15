# Economy System GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: economy-designer
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

Describe the economy: what currencies exist and what they buy.

---

## 2. Currencies

| Currency | Type | How Earned | How Spent |
|----------|------|------------|-----------|
| Gold | Soft | Quests, drops, daily | Shop, upgrades, repair |
| Gems | Premium | Rare drops, purchases | Premium shop, revives |
| Event Tokens | Seasonal | Event activities | Event shop (temp) |

---

## 3. Faucets (Income Sources)

| Source | Amount | Frequency | Rate/Hour |
|--------|--------|-----------|-----------|
| Quest rewards | 50-500 Gold | 1/10 min | ~1500 |
| Enemy drops | 5-30 Gold | 1/30s | ~3600 |
| Daily login | 500 Gold | 1/day | ~21/hr avg |
| Level-up bonus | 100 Gold × level | Per level | variable |

---

## 4. Sinks (Drain Sources)

| Sink | Cost | Frequency | Drain/Hour |
|------|------|-----------|-----------|
| Shop items | 50-10000 | Variable | ~500 |
| Gear upgrades | 100-50000 | Slow | ~300 |
| Repair | 20-100 | Frequent | ~200 |
| Prestige reset | 1,000,000 | Rare | variable |

---

## 5. Net Flow

- **Early game (level 1-10)**: Net +500 Gold/hour — players feel wealth
- **Mid game (level 10-30)**: Net +100 Gold/hour — balanced
- **Late game (level 30+)**: Net -300 Gold/hour — gear upgrades absorb income
- **Prestige**: Massive sink (hard reset option)

---

## 6. Time-to-Earn Targets

| Item | Price | New Player Time | Mid-Game Time |
|------|-------|-----------------|---------------|
| Basic sword | 100 | 5 min | 1 min |
| Rare sword | 1000 | 45 min | 8 min |
| Legendary sword | 10000 | 5 hours | 1 hour |
| Mythic set | 500000 | 100+ hours | 30 hours |

---

## 7. GamePass Integration

See `monetization-plan-template.md` for GamePass details.

Any GamePass affecting economy:
- **2x Gold**: Permanent 2x multiplier on Gold earnings
- **Coin Magnet**: Auto-collect dropped gold
- **VIP**: +10% to all earnings

Balance check: Does the game work without these? (Must be YES.)

---

## 8. Trading System (if applicable)

- **Tax**: 10% on trades (gold sink)
- **Limits**: 5 trades/day per player
- **Restrictions**: Account age > 7 days, verified email

---

## 9. Inflation Controls

- **Hard sinks**: Prestige reset, high-tier gear, cosmetics
- **Price scaling**: Shop prices scale with player level
- **Expiring items**: Event items disappear, preventing hoarding
- **Seasonal resets**: Event currencies wipe

---

## 10. Projections

### 30-Day Player Wealth Model

| Day | Player A (1h/day) | Player B (3h/day) | Player C (paying) |
|-----|-------------------|-------------------|-------------------|
| 1   | 500 G             | 1500 G            | 10000 G           |
| 7   | 4000 G            | 12000 G           | 50000 G           |
| 30  | 20000 G           | 60000 G           | 250000 G          |

Target: Player A can afford the "epic" tier item by day 30. Player C can buy earlier but still feels progression.
