# Systems Index

**Last Updated**: YYYY-MM-DD
**Owner**: game-designer

---

## Summary

| Status | Count |
|--------|-------|
| Not Started | X |
| In Design | X |
| In Implementation | X |
| Implemented | X |
| Polished | X |
| Live | X |
| **Total** | X |

---

## Systems

### Core Gameplay
- **Status**: [Not Started / In Design / In Implementation / Implemented / Polished / Live]
- **Priority**: P0 / P1 / P2 / P3
- **Value**: 1-5 (player impact)
- **Effort**: 1-5 (dev effort)
- **Risk**: Low / Medium / High
- **GDD**: `design/gdd/core-gameplay-gdd.md`
- **Depends On**: (none — foundational)
- **Depended On By**: Combat, Progression, Economy
- **Notes**: [Context]

### Combat
- **Status**: ...
- **Priority**: P0
- **Value**: 5
- **Effort**: 4
- **Risk**: Medium
- **GDD**: `design/gdd/combat-gdd.md`
- **Depends On**: Core Gameplay, Inventory
- **Depended On By**: Quests, Progression
- **Notes**:

### Inventory
- **Status**: ...
- **Priority**: P0
- **Value**: 4
- **Effort**: 3
- **Risk**: Low
- **GDD**: `design/gdd/inventory-gdd.md`
- **Depends On**: Player Data
- **Depended On By**: Combat, Shop, Trading
- **Notes**:

### Progression
- **Status**: ...
- **Priority**: P0
- **Value**: 4
- **Effort**: 3
- **Risk**: Low
- **GDD**: `design/gdd/progression-gdd.md`
- **Depends On**: Combat, Player Data
- **Depended On By**: Content Gating, UI
- **Notes**:

### Economy
- **Status**: ...
- **Priority**: P1
- **Value**: 4
- **Effort**: 3
- **Risk**: Medium (balance risk)
- **GDD**: `design/gdd/economy-gdd.md`
- **Depends On**: Inventory, Player Data
- **Depended On By**: Shop, Monetization, Trading
- **Notes**:

### Quests
- **Status**: ...
- **Priority**: P1
- **Value**: 3
- **Effort**: 3
- **Risk**: Low
- **GDD**: `design/gdd/quests-gdd.md`
- **Depends On**: Core Gameplay, Combat, Player Data
- **Depended On By**: Progression, Narrative
- **Notes**:

### Shop
- **Status**: ...
- **Priority**: P1
- **Value**: 3
- **Effort**: 2
- **Risk**: Low
- **GDD**: `design/gdd/shop-gdd.md`
- **Depends On**: Economy, Inventory, UI
- **Depended On By**: Monetization
- **Notes**:

### Social
- **Status**: ...
- **Priority**: P2
- **Value**: 4 (retention driver)
- **Effort**: 4
- **Risk**: Medium
- **GDD**: `design/gdd/social-gdd.md`
- **Depends On**: Player Data, UI
- **Depended On By**: Party System, Trading
- **Notes**:

### UI / UX
- **Status**: ...
- **Priority**: P0
- **Value**: 5 (every system uses it)
- **Effort**: 5
- **Risk**: Medium
- **GDD**: `design/gdd/ui-ux-gdd.md`
- **Depends On**: (foundational)
- **Depended On By**: Every system
- **Notes**:

### Onboarding / FTUE
- **Status**: ...
- **Priority**: P0 (retention critical)
- **Value**: 5
- **Effort**: 2
- **Risk**: High (hard to iterate without metrics)
- **GDD**: `design/gdd/onboarding-gdd.md`
- **Depends On**: Core Gameplay, UI
- **Depended On By**: Retention
- **Notes**:

### Monetization
- **Status**: ...
- **Priority**: P1
- **Value**: 3 (revenue, not gameplay)
- **Effort**: 3
- **Risk**: Medium (ethical concerns)
- **GDD**: `design/gdd/monetization-gdd.md`
- **Depends On**: Shop, Economy, Player Data
- **Depended On By**: (none — terminal)
- **Notes**:

### Analytics
- **Status**: ...
- **Priority**: P1
- **Value**: 4 (improvement data)
- **Effort**: 2
- **Risk**: Low
- **GDD**: `design/gdd/analytics-gdd.md`
- **Depends On**: (foundational — listens to all events)
- **Depended On By**: (none — terminal)
- **Notes**:

---

## Dependency Graph

```
Player Data ────┐
                ├──► Inventory ────► Shop ────► Monetization
                ├──► Progression ◄──┤
                └──► Core Gameplay
                      │
                      ├──► Combat ────► Quests
                      └──► Social ────► Party

UI ─── (foundational) ───► all systems
Onboarding ────► FTUE flow
Analytics ────► (listens to all)
```

---

## Recommended Build Order

1. **Foundation** (P0): Core Gameplay, Player Data, UI, Inventory
2. **Gameplay** (P0): Combat, Progression
3. **Content** (P1): Quests, Shop, Economy
4. **Retention** (P0 for retention): Onboarding, Social
5. **Revenue** (P1): Monetization
6. **Data** (P1): Analytics
7. **Polish** (P2): Additional content, events, refinements

---

## Priority Level Definitions

- **P0**: Blocks launch. Cannot ship without these.
- **P1**: High value. Ship soon after P0.
- **P2**: Desirable. Add within first 3 months post-launch.
- **P3**: Nice to have. Add if resources permit.

---

## Risk Register

| System | Risk | Mitigation |
|--------|------|------------|
| Economy | Inflation / pay-to-win imbalance | Economy modeling, playtest feedback |
| Onboarding | Hard to iterate without metrics | A/B test frameworks ready at launch |
| Social | Moderation burden | Chat filter, reporting, moderators |
| Monetization | Ethical concerns | Creative director review, ethical constraints |
