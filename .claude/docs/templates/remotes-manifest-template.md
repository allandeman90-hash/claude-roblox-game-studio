# Remotes Manifest

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Owner**: remotes-networking-specialist

---

## Overview

This document lists EVERY RemoteEvent, RemoteFunction, and UnreliableRemoteEvent in the game with their contracts. It is the source of truth for client-server communication.

---

## Remotes Location

All remotes are created centrally in `src/ReplicatedStorage/Shared/Remotes.lua`.

---

## Client → Server Remotes

### `PurchaseItem`
- **Type**: RemoteEvent
- **Direction**: Client → Server
- **Arguments**: `(itemId: string)`
- **Validation**:
  - `typeof(itemId) == "string"`
  - `#itemId <= 50`
  - Item exists in `ShopConfig`
  - Player can afford the item
- **Rate limit**: 5/sec per player
- **Bandwidth**: ~100 bytes/call
- **Handler**: `src/ServerScriptService/ShopService.lua`

### `StartAttack`
- **Type**: RemoteEvent
- **Direction**: Client → Server
- **Arguments**: `()`
- **Validation**:
  - Player is alive
  - Player is not stunned
  - Attack cooldown has elapsed
- **Rate limit**: 10/sec per player
- **Bandwidth**: ~50 bytes/call
- **Handler**: `src/ServerScriptService/Combat/AttackHandler.lua`

### `UseAbility`
- **Type**: RemoteEvent
- **Direction**: Client → Server
- **Arguments**: `(abilityId: string)`
- **Validation**:
  - `typeof(abilityId) == "string"`
  - Ability exists in `AbilityConfig`
  - Player has ability unlocked
  - Cooldown has elapsed
- **Rate limit**: 5/sec per player
- **Bandwidth**: ~100 bytes/call
- **Handler**: `src/ServerScriptService/Combat/AbilityHandler.lua`

### `SpendSkillPoint`
- **Type**: RemoteEvent
- **Direction**: Client → Server
- **Arguments**: `(skillId: string)`
- **Validation**:
  - Skill exists
  - Prerequisites met
  - Player has points available
- **Rate limit**: 2/sec
- **Bandwidth**: ~100 bytes/call
- **Handler**: `src/ServerScriptService/ProgressionService.lua`

---

## Server → Client Remotes

### `PlayerDataUpdated`
- **Type**: RemoteEvent
- **Direction**: Server → Client
- **Arguments**: `(partialData: PlayerData)`
- **Purpose**: Notify client of data changes (stat changes, level up, inventory updates)
- **Bandwidth**: ~500 bytes/call
- **Frequency**: On state changes (not periodic)

### `AttackResult`
- **Type**: RemoteEvent
- **Direction**: Server → Client
- **Arguments**: `(attackerId, targetId, damage, didCrit)`
- **Purpose**: Broadcast attack results for VFX and damage number display
- **Bandwidth**: ~80 bytes/call
- **Frequency**: Per attack, to affected clients

### `NotifyMessage`
- **Type**: RemoteEvent
- **Direction**: Server → Client
- **Arguments**: `(messageKey: string, params: {[string]: any})`
- **Purpose**: Show a localized notification to the player
- **Bandwidth**: ~200 bytes/call
- **Frequency**: On events (purchase, achievement, etc.)

---

## Server → Client RemoteFunctions

### `GetInitialData`
- **Type**: RemoteFunction
- **Direction**: Server → Client (server invokes on join)
- **Arguments**: `()`
- **Returns**: `(initialState: PlayerData)`
- **Purpose**: Give client full initial state on join
- **Bandwidth**: ~5 KB one-time

---

## Unreliable Remotes (Cosmetic / High-frequency)

### `CharacterEmote`
- **Type**: UnreliableRemoteEvent
- **Direction**: Client → Server → All Clients
- **Arguments**: `(emoteId: string)`
- **Purpose**: Broadcast emote for visual display (not gameplay affecting)
- **Validation**: Type check only
- **Rate limit**: 1/2 sec
- **Bandwidth**: ~50 bytes/call

### `ParticleBurst`
- **Type**: UnreliableRemoteEvent
- **Direction**: Server → All Clients
- **Arguments**: `(position: Vector3, effectType: string)`
- **Purpose**: Spawn a visual effect at a location (client-side only)
- **Bandwidth**: ~100 bytes/call
- **Frequency**: High (per particle effect)

---

## Bandwidth Budget Summary

Target: < 50 KB/s per player outgoing

| Remote | Frequency | Bytes/call | KB/s per player |
|--------|-----------|------------|-----------------|
| PurchaseItem | occasional | 100 | ~0.01 |
| StartAttack | 10/sec max | 50 | 0.5 |
| UseAbility | 5/sec max | 100 | 0.5 |
| PlayerDataUpdated | 0.5/sec | 500 | 0.25 |
| AttackResult | 10/sec | 80 | 0.8 |
| NotifyMessage | occasional | 200 | 0.02 |
| CharacterEmote | 0.5/sec max | 50 | 0.025 |
| ParticleBurst | 5/sec | 100 | 0.5 |
| **Total** | | | **~2.6 KB/s** (well under budget) |

---

## Security Summary

Every Client → Server remote has:
- ✅ Type validation
- ✅ Sanity validation
- ✅ Rate limiting
- ✅ Server-side authority

No RemoteFunctions from Client → Server (prevents server hang).

---

## Audit Log

| Date | Change | Author |
|------|--------|--------|
| YYYY-MM-DD | Initial manifest | remotes-networking-specialist |
| YYYY-MM-DD | Added UseAbility remote | luau-gameplay-programmer |
