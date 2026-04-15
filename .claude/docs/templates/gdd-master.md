# [Game Name] — Master Game Design Document

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Status**: Draft

---

## 1. Game Overview

**Concept**: One sentence elevator pitch.

**Genre**: [Adventure / RPG / Simulator / Fighting / Tycoon / Obby / etc.]

**Platform**: Roblox (Mobile, PC, Console, VR)

**Target Audience**:
- Primary: [age range, interests]
- Secondary: [age range, interests]
- Bartle Type: [Achievers / Explorers / Socializers / Killers]

**Session Length Target**: 15-30 minutes

**Max Players per Server**: [e.g., 20]

---

## 2. Creative Pillars

Three to five core ideas that guide every decision. Each pillar should fit in one phrase.

1. **[Pillar 1]** — [2-sentence explanation]
2. **[Pillar 2]** — [2-sentence explanation]
3. **[Pillar 3]** — [2-sentence explanation]

---

## 3. Core Loop

### 30-Second Loop
What the player does every 30 seconds.
- Example: Spot enemy → attack → get loot → repeat

### 5-Minute Loop
What the player does over a typical 5-minute chunk.
- Example: Explore area → defeat enemies → level up → upgrade weapon

### Session Loop (15-30 minutes)
What a complete session looks like.
- Example: Log in → daily reward → 3 quests → boss fight → save progress → log out

### Meta Loop (days/weeks)
Long-term progression and goals.
- Example: Level up → unlock new area → find rare items → prestige reset

---

## 4. Systems Overview

List every major system with a one-sentence description. Details live in per-system GDDs.

| System | Purpose | Status | GDD |
|--------|---------|--------|-----|
| Core Gameplay | The primary action loop | — | `core-gameplay-gdd.md` |
| Combat | Damage, abilities, enemies | — | `combat-gdd.md` |
| Progression | XP, levels, skills | — | `progression-gdd.md` |
| Economy | Currency, shop, trading | — | `economy-gdd.md` |
| Inventory | Items, equipment | — | `inventory-gdd.md` |
| Quests | Missions and rewards | — | `quests-gdd.md` |
| Social | Friends, parties, chat | — | `social-gdd.md` |
| Onboarding | FTUE and tutorial | — | `onboarding-gdd.md` |
| UI | Menus, HUD, notifications | — | `ui-ux-gdd.md` |
| Monetization | GamePasses, DevProducts | — | `monetization-gdd.md` |

---

## 5. Player Progression

How do players grow over time?

- **Level Progression**: XP curve, time-to-level
- **Skill Progression**: Unlockable abilities, skill trees
- **Gear Progression**: Item power levels, rarity tiers
- **Content Progression**: Unlockable areas, quests, boss fights
- **Meta Progression**: Prestige, collections, achievements

### Time-to-Content Milestones
| Milestone | Target Time | Hours Played |
|-----------|-------------|--------------|
| Tutorial complete | First session | 0.25 |
| First goal reached | First session | 0.5 |
| Unlock core system | Session 2 | 1.5 |
| Reach mid-game | Week 1 | 5 |
| Reach late-game | Week 2-3 | 15 |
| Complete main content | Month 1 | 30+ |

---

## 6. Monetization Strategy

### GamePasses (Permanent Purchases)
| Name | Price (R$) | Benefit | Target Player |
|------|------------|---------|---------------|
| VIP | 499 | Chat color, VIP room, +5% rewards | Engaged |
| Double Inventory | 299 | 2x inventory slots | Mid-game |

### DevProducts (Consumable Purchases)
| Name | Price (R$) | Benefit | Frequency |
|------|------------|---------|-----------|
| 1000 Gems | 99 | 1000 premium currency | Variable |
| Revive | 25 | Revive at death | Per-death |

### Premium Benefits (for Roblox Premium subscribers)
- [Benefit 1]
- [Benefit 2]

### Ethical Constraints
- No loot boxes with real-money purchase
- No pay-to-win that breaks competitive balance
- No FOMO targeting young players
- Free players have a complete, enjoyable experience

---

## 7. Social Features

- **Multiplayer**: [Solo / Co-op / PvP / PvPvE]
- **Chat**: TextChatService with filter
- **Friends**: Add / invite / party
- **Guilds**: [Yes/No, if yes: max size, benefits]
- **Trading**: [Yes/No, if yes: tax rate, restrictions]
- **Social Spaces**: [Lobby, hub, housing, etc.]

---

## 8. Target Metrics

| Metric | Target |
|--------|--------|
| D1 Retention | > 25% |
| D7 Retention | > 12% |
| D30 Retention | > 5% |
| Average Session Length | > 15 min |
| Sessions/Day/Player | > 1.5 |
| Conversion Rate | > 3% |
| ARPDAU | > $0.05 |

---

## 9. Content Plan

### Launch Content
- [List of systems/content that must ship at launch]

### Post-Launch Roadmap
- Month 1: [Content update]
- Month 2: [Content update]
- Month 3: [Content update]

### Seasonal Content
- [Event 1]: [When, what]
- [Event 2]: [When, what]

---

## 10. Technical Overview

### Architecture
- **Client-Server Split**: Server authoritative for all game state
- **Sync Tool**: [Rojo / Argon / Manual Studio]
- **UI Framework**: [Native / Roact / Fusion]
- **Packages**: [List Wally packages used]

### Key Constraints
- Max 4MB DataStore key size
- 60 + playerCount × 10 DataStore requests/min
- Target 30 FPS on low-end mobile
- Server memory < 2GB

### Dependencies
- [External services used]
- [Third-party modules]

---

## Appendices

- A. Reference games (inspirations)
- B. Mood board / visual references
- C. Competitive analysis
- D. Risk register
