# Combat System GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: game-designer + systems-designer
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

Combat is [describe the combat identity — fast-paced twin-stick? slow tactical RPG? simple hack-and-slash?].

**Player Feeling**: [powerful / strategic / anxious / rewarding / skill-based / etc.]

---

## 2. Core Mechanics

### Attack Flow
1. Player presses attack input
2. Client plays animation + predictive VFX
3. Client fires `StartAttack` remote
4. Server validates (cooldown, range, target exists)
5. Server performs hit detection (raycast or region query)
6. Server computes damage
7. Server applies damage (Humanoid:TakeDamage)
8. Server fires `AttackResult` back to all relevant clients
9. Clients play final VFX (hit particles, damage numbers)

### Defense Flow
- **Block**: Hold defend input → damage reduced 70% for duration
- **Dodge**: Tap dodge input → short burst of movement + i-frames
- **Parry**: Dodge timed during enemy windup → counter attack boost

### Abilities
Each player has N ability slots. Abilities are:
- Signature (class-specific)
- Utility (movement, heal, buff)
- Ultimate (powerful, long cooldown)

---

## 3. Data Schema

| Key | Type | Default | Notes |
|-----|------|---------|-------|
| `hp` | number | 100 | Current health |
| `max_hp` | number | 100 | Max health (stats) |
| `equipped_weapon` | string | starter weapon ID |
| `ability_cooldowns` | table | `{}` | abilityId → expiry timestamp |

---

## 4. Client-Server Split

### Server
- Damage calculation and application
- Hit detection (authoritative)
- Cooldown tracking
- Status effect application
- Death/respawn

### Client
- Input capture
- Animation
- VFX (particles, trails, beams)
- Damage numbers display
- Health bar UI
- Local prediction (visual only)

---

## 5. Remotes

| Name | Type | Direction | Args | Validation | Rate Limit |
|------|------|-----------|------|------------|------------|
| StartAttack | RemoteEvent | C→S | () | player state valid | 10/sec |
| UseAbility | RemoteEvent | C→S | (abilityId: string) | abilityId ≤ 50, exists | 5/sec |
| AttackResult | RemoteEvent | S→C | (attackerId, targetId, damage, didCrit) | — | — |
| HealthChanged | RemoteEvent | S→C | (playerId, newHp, maxHp) | — | — |

---

## 6. UI

- **HP Bar**: Top-left, always visible
- **Cooldown Indicators**: Bottom-center, showing ability cooldowns
- **Damage Numbers**: Floating above targets on hit
- **Combo Counter**: Top-right when combo active
- **Enemy HP Bar**: Above targeted enemy

---

## 7. Edge Cases

1. **Attack during dodge i-frames**: Damage is ignored (i-frames active)
2. **Ability used while stunned**: Server rejects; no cooldown consumed
3. **Target dies mid-attack**: Attack still resolves; damage is applied but target was already dead (0 effect)
4. **Player disconnects mid-attack**: Attack is voided server-side
5. **Multiple simultaneous attacks on same target**: All processed in order; sum of damage applied
6. **Attack out of range**: Server rejects silently (client had stale range data)

---

## 8. Balancing

### Damage Formula
```
damage = (base_attack + weapon_power + ability_bonus)
       * (1 + crit_multiplier * is_crit)
       * (1 - defense_reduction)
       * damage_variance  -- random 0.9-1.1
```

### Cooldown Formula
```
cooldown = base_cooldown * (1 - cdr_stat)
```

### Tunable Parameters
All in `src/ReplicatedStorage/Shared/Config/CombatConfig.lua`.

- `BASE_ATTACK_DAMAGE` (min 1, max 1000, default 10)
- `CRIT_CHANCE` (min 0.0, max 1.0, default 0.05)
- `CRIT_MULTIPLIER` (min 1.0, max 5.0, default 2.0)
- `ATTACK_COOLDOWN` (min 0.1, max 5.0, default 0.5)
- `I_FRAME_DURATION` (min 0.0, max 2.0, default 0.3)

---

## 9. Integration Points

### Depends On
- Player Data (hp, stats, equipped weapon)
- Inventory (weapon modules)
- Ability System

### Depended On By
- Progression (XP from kills)
- Quest System (kill objectives)
- Analytics (combat events)

---

## Acceptance Criteria

- [ ] All damage server-calculated
- [ ] Rate limit prevents remote spam
- [ ] Crit rate measures within 0.5% of target over 10,000 attacks
- [ ] Combat runs at 60 FPS on low-end mobile
- [ ] Server heartbeat stable with 10 players in constant combat
- [ ] No client-side damage application possible
- [ ] `/exploit-check` passes
