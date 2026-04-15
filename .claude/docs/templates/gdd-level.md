# Level / Map GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: level-designer
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

Name of the level/map and its role in the game.

**Type**: [Lobby / Hub / Combat zone / Obby / Boss room / Dungeon / Open world]

**Target player level**: [e.g., 1-5 for tutorial area]

**Session duration in this map**: [e.g., 5-10 min for a combat zone]

---

## 2. Layout

### Overview Diagram
```
┌─────────────────────────────────────┐
│                                     │
│    [Boss Arena]                     │
│        │                            │
│    [Gate]                           │
│        │                            │
│    [Enemy Zone 2]                   │
│        │                            │
│    [Checkpoint]                     │
│        │                            │
│    [Enemy Zone 1]                   │
│        │                            │
│    [Spawn]                          │
│                                     │
└─────────────────────────────────────┘
```

### Zones
1. **Spawn** — Where players enter
2. **Enemy Zone 1** — Tutorial enemies
3. **Checkpoint** — First save point
4. **Enemy Zone 2** — Harder enemies
5. **Gate** — Level gate (requires key)
6. **Boss Arena** — Boss encounter

---

## 3. Visual Theme

- **Biome**: [forest / desert / city / underwater / space / etc.]
- **Lighting**: [bright / shadowy / colorful / muted / etc.]
- **Palette**: [dominant colors]
- **Weather / atmosphere**: [clear / fog / rain / snow / none]

---

## 4. Technical Setup

### Streaming
- **StreamingEnabled**: [Yes / No]
- **StreamingMinRadius**: [N studs]
- **StreamingTargetRadius**: [N studs]

### Performance Budget
- **Target triangles**: [e.g., 500K total in view]
- **Target draw calls**: [e.g., 500 max]
- **Target lights**: [e.g., 8 dynamic lights max]

### Lighting
- `Lighting.Brightness`: [value]
- `Lighting.ClockTime`: [value]
- `Lighting.FogEnd`: [value]
- Uses: [Atmosphere / Sky / Bloom / ColorCorrection]

---

## 5. Gameplay Elements

### Enemies
- [Enemy type 1]: [count, spawn locations]
- [Enemy type 2]: [count, spawn locations]

### Interactives
- **Chests**: [locations, loot tier]
- **Doors/Gates**: [locations, unlock conditions]
- **NPCs**: [locations, roles]
- **Proximity prompts**: [locations, actions]

### Checkpoints
- [Location 1]: Triggers save, respawns here on death
- [Location 2]: ...

---

## 6. Spawn Logic

- **Initial spawn**: Spawn location at `[coords]`
- **Respawn on death**: At last checkpoint
- **Team spawn**: If team-based, each team has own spawn

---

## 7. Audio

- **Ambient track**: [sound ID, volume, loop]
- **Area-specific sounds**: [e.g., waterfall sound near water]
- **Combat music trigger**: Fires when player enters combat zone

---

## 8. Flow

### Happy Path
Player enters → explores Zone 1 → defeats enemies → reaches checkpoint → continues to Zone 2 → finds key → opens gate → boss fight → victory → leaves level.

### Optional Paths
- **Hidden area**: Behind waterfall, contains rare loot
- **Shortcut**: Unlocked after defeating boss, allows faster re-runs

---

## 9. Edge Cases

- **Player falls off world**: Teleport to last safe position
- **Player gets stuck**: `/unstuck` command teleports to checkpoint
- **Too many enemies**: Cap per zone to avoid performance issues
- **Player at end with no gate key**: Provide fallback path or hint

---

## 10. Integration Points

### Depends On
- Combat system (enemies are combat entities)
- Quest system (level-tied quests)
- Checkpoint system (respawn)

### Depended On By
- Progression (unlock via level gating)
- Achievement system (area-specific badges)

---

## Acceptance Criteria

- [ ] Layout builds out
- [ ] Streaming works correctly (if enabled)
- [ ] Performance targets met
- [ ] Lighting finalized
- [ ] Enemies spawn correctly
- [ ] Checkpoints save and respawn
- [ ] Audio matches atmosphere
- [ ] No stuck spots
- [ ] Mobile tested at 30+ FPS
