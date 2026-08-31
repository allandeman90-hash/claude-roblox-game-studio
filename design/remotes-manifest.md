# Remotes Manifest — Quête Minute

**Owner:** lead-programmer + remotes-networking-specialist
**Updated:** 2026-08-31 (B2 — rate-limit de tous les remotes)
**Source of truth for:** every RemoteEvent/RemoteFunction, its direction, its
arguments, and its server-side rate limit.

---

## 1. Inventory

| Remote | Class | Direction | Created by | Server listener |
|---|---|---|---|---|
| `CombatEvent` | `RemoteEvent` | C↔S | `CombatServer` (`ReplicatedStorage/CombatEvent`) | `CombatEvent.OnServerEvent` — single `data.type` router |
| `ShopEvent` | `RemoteEvent` | **S→C only** | `ShopService` (`ReplicatedStorage/ShopEvent`) | none (by design — see §4) |

- **No `RemoteFunction`** anywhere (rule: no client→server RemoteFunction — server-hang risk).
- **No `UnreliableRemoteEvent`** yet (candidate later for damage-number / cosmetic bursts).
- `ReplicatedStorage/Shared/Remotes.luau` is an unused central registry. Consolidating
  `CombatEvent` + `ShopEvent` into it is a future cleanup, not required for B2.

---

## 2. Entry guard (`CombatEvent.OnServerEvent`)

Every message passes, in order:

1. `type(data) ~= "table"` → drop.
2. `type(data.type) ~= "string"` → drop.
3. `isRateLimited(player, data.type)` → drop (silent).
4. `states[player]` missing → drop.

Then the `data.type` router runs. Unknown `data.type` values fall through the
`if/elseif` chain as a silent no-op (old clients safe).

---

## 3. `CombatEvent` — client → server messages

Rate limits are a **sliding 1 s window, per player**, from
`GameConfig.Security` (`remotePerType`, default `remoteDefaultPerWindow = 4`,
global `remoteGlobalPerWindow = 20`).

| `data.type` | Payload | Server-side validation | Cap /s |
|---|---|---|---|
| `allocateStat` | `stat` | `stat` mapped through `{POW,INT,VIT,SPD,LUK}` whitelist; requires `st.statPoints > 0`; SPD path checks `spdMax` + `spdCostPerPoint` | 8 |
| `move` | `dir` | `dir` accepted only if `"left"` or `"right"`, else `nil`; ignored when `st.gameOver` | 10 |
| `buyEquipment` | `itemId`, `rarete`, `slot` | zone taken from the **server** shop session (never the client); `STOCK_BY_ID` check; `OFFER_RARITIES` check; active-rarity check; gold check; refund on equip failure | 4 |
| `equipItem` | `slot`, `id`, `rarete`, `zone` | delegated to `EquipmentService.equip` (ownership + slot). *Deep validation audit: deferred to `/exploit-check` (finding A5).* | 4 |
| `unequipItem` | `slot` | delegated to `EquipmentService.unequip` | 4 |
| `fuseItem` | `id`, `rarete`, `zone`, `slot` | delegated to `EquipmentService.fuse` | 4 |
| `requestInventory` | `slot?` | `slot` restricted to the 6-slot whitelist (`arme,casque,plastron,jambieres,bottes,pet`) when absent | 2 |
| `setFilters` | `rareteMin?`, `guerrier?`, `mage?` | passed to `EquipmentService.setFilters` (clamped there) | 4 |
| `toggleLock` | `id`, `rarete`, `zone`, `slot` | delegated to `EquipmentService.toggleLock` | 4 |
| `setCheckpoint` | `km` | `km` floored to a 10 km step, must be `0 ≤ km ≤ st.checkpointMaxKm` | 4 |
| `restart` | `checkpointKm?` | only when `st.gameOver`; `checkpointKm` floored to 10 km and **clamped `0..st.checkpointMaxKm`** (B2 fix A3 — a crafted value can no longer skip the run forward) | 2 |
| `setFastMode` | `on` | `on == true` only; gated by `st.bigBossesBeaten >= fastModeUnlockBigBosses` | 2 |
| `rebirth` | — | gold `>= GameConfig.Rebirth.cost(n+1)` else `rebirthDenied`. (In-combat refusal is added in B5/G8.) | 1 |
| `campfireContinue` | — | legacy no-op, kept so old clients don't error | 2 |
| _(any other / unknown)_ | — | silent no-op | default 4 |
| **global (all types combined)** | | | **20** |

**Abuse logging:** once a player accumulates `remoteAbuseRejectThreshold` (40)
rejected messages, a single `warn` is emitted, then throttled for
`remoteAbuseWarnCooldownSec` (30 s). Never kicks — B2 is silent-drop only.

**Cleanup:** `remoteCalls[player]` / `remoteRejects[player]` cleared on
`Players.PlayerRemoving`.

---

## 4. `CombatEvent` / `ShopEvent` — server → client messages

Display-only. The client renders them; it never trusts them for authority
(state already lives on the server).

| Remote | `type` values (non-exhaustive) |
|---|---|
| `CombatEvent` | `update`, `damage`, `inventory`, `gameOver`, `rebirthDone`, `rebirthDenied`, `fuseResult`, `equipError`, `shopError` |
| `ShopEvent` | `open`, `purchased` |

`ShopEvent` has **no `OnServerEvent` listener** (the dead legacy handler was
removed in B2). A client firing `ShopEvent` server-side hits nothing. All
purchases route through `CombatEvent { type = "buyEquipment" }`.

---

## 5. Known follow-ups

- **A5** (`/exploit-check`): deep argument validation inside `EquipmentService`
  (`equip` / `unequip` / `fuse` / `toggleLock`) — confirm ownership + bounds are
  enforced there, not just assumed.
- **B5**: `rebirth` must be refused during active combat.
- Future: centralise remote creation in `ReplicatedStorage/Shared/Remotes.luau`;
  consider `UnreliableRemoteEvent` for high-frequency damage numbers.
