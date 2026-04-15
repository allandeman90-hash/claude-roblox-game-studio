# Progression System GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: game-designer
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

How do players grow over time? What progression axes exist?

---

## 2. Progression Axes

### Level Progression
- XP earned from kills, quests, challenges
- Level determines stat scaling
- Max level: [e.g., 100]
- XP curve: [linear / quadratic / exponential]

### Skill Progression
- Skill points earned on level up
- Spend in skill tree
- Respec available: [free / paid / locked]

### Gear Progression
- Item rarity tiers: Common → Rare → Epic → Legendary → Mythic
- Item levels scale with player level
- Set bonuses for equipping matching gear

### Content Progression
- New areas unlock at level milestones
- New quests unlock after completing prerequisites
- Boss fights gate progression

### Meta Progression (long-term)
- Achievements
- Collections (all weapons, all enemies defeated)
- Prestige / rebirth (soft reset with permanent bonus)
- Seasonal progression (resets each season)

---

## 3. Data Schema

| Key | Type | Default |
|-----|------|---------|
| `level` | number | 1 |
| `xp` | number | 0 |
| `skill_points_available` | number | 0 |
| `skill_tree` | table | `{}` |
| `unlocked_areas` | table (set) | `{"starter_town"}` |
| `prestige_level` | number | 0 |

---

## 4. Client-Server Split

Server owns all progression state. Client displays.

---

## 5. Remotes

| Name | Type | Direction | Purpose |
|------|------|-----------|---------|
| GainXP | RemoteEvent | S→C | Notify client of XP gain |
| LevelUp | RemoteEvent | S→C | Level-up animation trigger |
| SpendSkillPoint | RemoteEvent | C→S | Player spends a skill point |

Validate: skill ID exists, player has the point, prerequisite skills unlocked.

---

## 6. UI

- **XP Bar**: Bottom of HUD, shows progress to next level
- **Level Up Notification**: Modal with stat increases
- **Skill Tree**: Menu view with nodes and connections
- **Progression Map**: Shows unlocked / locked areas

---

## 7. Edge Cases

1. **Max level player gains XP**: XP capped at max level threshold
2. **Skill point spent on locked skill**: Rejected server-side
3. **Prestige with skill points unspent**: Points are lost (document clearly to player)
4. **Level up during combat**: Notification queued until out of combat

---

## 8. Formulas

**XP to next level**:
```
xp_required = BASE_XP * (GROWTH_FACTOR ^ (level - 1))
```

**Stat per level** (e.g., HP):
```
max_hp = BASE_HP + (HP_PER_LEVEL * level) + (HP_BONUS * skill_hp_nodes)
```

**Tunable**:
- `BASE_XP` = 100
- `GROWTH_FACTOR` = 1.15
- `BASE_HP` = 100
- `HP_PER_LEVEL` = 10

---

## 9. Integration Points

### Depends On
- Combat (XP from kills)
- Quests (XP from completion)
- Player Data (persists level, XP)

### Depended On By
- Content gating (level-locked areas)
- Gear scaling (item levels match player level)
- UI (display level, XP bar)
- Monetization (XP boost GamePass)

---

## Acceptance Criteria

- [ ] XP correctly earned from all configured sources
- [ ] Level up triggers stat increase
- [ ] Skill tree allows valid allocations, rejects invalid
- [ ] Prestige resets level but preserves prestige bonus
- [ ] Progression curve tested across player archetypes
