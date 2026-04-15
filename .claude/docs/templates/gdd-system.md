# [System Name] — System GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: [Role or Name]
**Status**: [Draft / Review / Approved / Implemented / Live]
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

**What is this system?** (2-3 sentences)

**Why does it exist?** (What player need does it serve?)

**How does it fit into the core loop?** (Where in the 30-sec / 5-min / session loop does this appear?)

---

## 2. Core Mechanics

Detailed mechanical description. Describe step-by-step what happens when the player interacts with this system.

1. [Step 1: e.g., "Player taps the Attack button"]
2. [Step 2: e.g., "Weapon swings; hit detection fires"]
3. [Step 3: e.g., "Damage is computed and applied"]
4. [Step 4: e.g., "Visual feedback and sound play"]
5. [Step 5: e.g., "Player gains XP if enemy is killed"]

### State Diagram (if applicable)
```
[Idle] → [Attacking] → [Recovery] → [Idle]
   │                      │
   ↓                      ↓
[Stunned] ←───────── [Interrupted]
```

---

## 3. Data Schema

### DataStore Keys
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `equipped_weapon` | string | `"sword_basic"` | Equipped weapon ID |
| `weapon_xp` | table | `{}` | XP per weapon ID |

### Runtime State (not persisted)
| Field | Type | Description |
|-------|------|-------------|
| `currentCombo` | number | Current attack combo count |
| `lastAttackTime` | number | os.clock timestamp of last attack |

### Schema Version
Current version: 1

---

## 4. Client-Server Split

### Server Owns
- All damage calculations
- All state mutations (HP, XP, inventory)
- Cooldown enforcement
- Rate limiting
- DataStore persistence

### Client Owns
- Visual presentation (animations, particles)
- Input capture
- Local prediction (rubber-banded to server)
- UI updates

### Never on Client
- Final damage numbers (server sends results)
- XP/gold awards
- Inventory mutations

---

## 5. RemoteEvents / Functions

| Name | Type | Direction | Arguments | Validation | Rate Limit |
|------|------|-----------|-----------|------------|------------|
| `StartAttack` | RemoteEvent | C→S | (none) | n/a | 5/sec |
| `UpdateWeapon` | RemoteEvent | S→C | (weaponId, stats) | n/a | n/a |

### Validation Rules
- Type check every argument
- Range check numerics
- Sanity check: does this action make sense given player state?

---

## 6. Player-Facing UI

### Elements
- **HUD**: Health bar, cooldown indicators, combo counter
- **Menu**: Weapon selection, stats display
- **Modal**: Level-up notification

### Wireframe
```
┌─────────────────────────────────────┐
│  [HP: ████████░░]     [Combo: 3x]   │
│                                     │
│                                     │
│         [Game Area]                 │
│                                     │
│                                     │
│             [Attack]   [Special]    │
└─────────────────────────────────────┘
```

---

## 7. Edge Cases & Error States

### Expected Edge Cases
1. **Zero damage**: Target has max defense — attack shows "Blocked!"
2. **Max HP**: Healing doesn't exceed max HP cap
3. **Rapid spam**: Rate limit kicks in; extra inputs ignored silently
4. **Disconnect mid-attack**: Server state is authoritative; on rejoin, attack is considered not-fired
5. **Full inventory on pickup**: Item auto-deposits in overflow bag (capped at N)

### Error States
1. **DataStore failure**: Retry up to 5x; if still failing, show "Connection issue" message
2. **Network lag > 500ms**: Client shows "Reconnecting..." indicator
3. **Server crash**: BindToClose saves state; new server loads last saved state

---

## 8. Balancing Parameters

All values live in `src/ReplicatedStorage/Shared/Config/[System]Config.lua`.

### Formulas

**Damage**:
```
damage = (base_attack + weapon_power)
       * (1 + crit_multiplier * is_crit)
       * (1 - defense_reduction)
       * random(0.9, 1.1)
```

**XP to Level**:
```
xp_to_next = base_xp * (growth_factor ^ (current_level - 1))
```

### Tunable Values
| Parameter | Min | Max | Default | Notes |
|-----------|-----|-----|---------|-------|
| base_attack | 1 | 500 | 10 | Per player level |
| base_xp | 100 | 1000 | 100 | XP needed for level 1 → 2 |
| growth_factor | 1.05 | 2.0 | 1.15 | Compound XP growth |
| crit_multiplier | 1.0 | 5.0 | 2.0 | Crit damage multiplier |

---

## 9. Integration Points

### Depends On
- **Inventory System**: Provides equipped weapon data
- **Player Data System**: Provides player stats, persists progress
- **Remotes System**: Provides the remote registry

### Depended On By
- **Progression System**: Listens to `ExperienceGained` event
- **Quest System**: Listens to `EnemyKilled` event
- **Analytics**: Tracks all combat events

### Shared Data
- Weapon definitions in `Config/WeaponConfig.lua`
- Player stats in `Types/PlayerData.lua`

---

## Acceptance Criteria

- [ ] Player can attack with equipped weapon
- [ ] Damage correctly computed from formula
- [ ] Crit chance fires at expected rate (measured over 1000 attacks)
- [ ] Rate limit prevents spam
- [ ] No client-side damage application
- [ ] Combat works with 10 players in one server (perf test)
- [ ] Exploits tested: negative damage, out-of-range, invalid weapon
- [ ] Analytics events fire correctly
- [ ] UI updates match server state within 100ms

---

## Open Questions

- [ ] [Question still to resolve]
- [ ] [Question still to resolve]
