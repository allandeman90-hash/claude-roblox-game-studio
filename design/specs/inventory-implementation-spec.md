# Inventory Implementation Spec

**Version:** 1.1
**Last Updated:** 2026-09-02
**Author:** systems-designer
**Status:** Approved for implementation — decisions confirmed by user 2026-09-02
**Parent GDD:** `design/gdd/inventory-gdd.md`
**References:** `design/gdd/economy-gdd.md` (Forge, fusion), `GAME_SPEC.md` §4-5/§10 (equipment,
frozen except where superseded below), `src/ServerScriptService/EquipmentService.luau` (current
implementation, to be migrated)

---

## 0. Design Decisions Confirmed (2026-09-02)

Three points flagged in the v1.0 draft were resolved by the user. Recorded here for traceability;
implementers should treat these as final, not open questions.

1. **Item identity model — RESOLVED: migrate.** `inventory-gdd.md` requires one inventory slot =
   one unique item instance (`itemKey`) carrying its own `forgeLevel`, to support
   `economy-gdd.md`'s Forge infinie (+0 → +999+, per-instance). The current
   `EquipmentService.luau` stores stacked counts keyed by `id|rarete|zone` with no per-copy
   identity. **Confirmed: migrate stack → instances, Day 1 priority.** This spec targets the
   unique-instance model exclusively; `EquipmentService`'s inventory table moves from
   `{ [key] = count }` to `{ [itemKey] = ItemInstance }`. See §5.2 for the one-time profile
   migration.
2. **Capacity — RESOLVED: 200 max.** `GAME_SPEC.md` §10 states a hard 100, no purchase.
   `inventory-gdd.md` §2.1 states 100 base + 25 purchasable = 125 max. **Confirmed: 100 base +
   100 bonus pack = 200 max.** This overrides both the frozen `GAME_SPEC.md` figure and the
   `+25` figure written in `inventory-gdd.md` §2.1 — `bonusCapacity` is **100**, not 25.
   `inventory-gdd.md` §2.1/§8 should be updated by game-designer to match this number so the GDD
   and this spec don't drift; flagging that follow-up but not blocking on it here.
3. **Gants (hands) slot — RESOLVED: add as 5th armor category.** `inventory-gdd.md` §2.2 already
   listed Gants; `GAME_SPEC.md` §4.2/§4.4 only defined 4 armor slots (96 launch armors = 12 boss ×
   4 pièces × 2 voies). **Confirmed: implement Gants.** `EquipmentConfig.SLOTS` and
   `EquipmentConfig.ARMOR_SLOTS` must be extended to include `"gants"`. This raises the launch
   armor content count from 96 to **120** (12 boss × 5 pièces × 2 voies) — flagged for
   game-designer/art-director as a content-scope consequence, not a blocker for this spec.

---

## 1. Overview

The inventory is the server-authoritative container for every owned equipment instance (weapons,
armor). It is the load-bearing system for equipping, Forge, fusion, and the economy — nothing
else that touches items can function without it. This spec covers slot management, capacity,
sorting/filtering, the full-bag flow, and the remote contract. It does not cover Forge math or
fusion math (see `economy-gdd.md` §2.3/§2.5); it only covers how the inventory stores and mutates
the `forgeLevel` field those systems write to.

## 2. Player Intent

The player thinks of the inventory as "my bag of stuff I found." They expect: what I loot shows
up here; I can sort it to find the good stuff fast; I never lose an item unless I explicitly
choose to (sell/fuse/discard); equipping is instant and safe; running out of space is an annoying
but recoverable moment, never a silent loss.

## 3. Core Mechanics

1. Every dropped equipment instance is assigned a unique `itemKey` at creation time by
   `EquipmentService` (see integration §9).
2. `InventoryService.addItem` inserts the instance if `count(items) < capacity`; otherwise it
   triggers the full-bag flow (see §10.1).
3. Items never stack. Two identical weapons of the same rarity are two separate slots, two
   separate `itemKey`s, and can carry different `forgeLevel`s.
4. The server owns sort order; the client only requests a sort mode and renders what's returned.
5. Equipping a weapon is refused if `player.inCombat == true`. Equipping armor (including Gants)
   has no combat restriction.
6. Removing (selling/discarding) an item that is currently `equipped == true` is refused; the
   client must unequip first.
7. All mutations funnel through a single `mutate(player, fn)` critical section per player to
   avoid races between concurrent remotes (e.g., simultaneous `EquipItem` + `RemoveItem` for the
   same key).

## 4. State Diagram

```
                    ┌──────────────┐
   drop/purchase    │              │
  ─────────────────►│   IN_BAG     │◄────────────────────┐
                     │ (unequipped) │                     │
                     └──────┬───────┘                     │
                            │ equipItem                   │ unequipItem
                            ▼                              │
                     ┌──────────────┐                     │
                     │   EQUIPPED    ├─────────────────────┘
                     └──────┬───────┘
                            │ forgeItem (economy-gdd)
                            ▼
                     ┌──────────────┐
                     │ EQUIPPED_+N  │  (forgeLevel > 0, same itemKey)
                     └──────┬───────┘
                            │ removeItem (only from IN_BAG state)
                            ▼
                     ┌──────────────┐
                     │   DELETED    │  (fused-away materials, sold, discarded)
                     └──────────────┘
```

Full-bag sub-flow (triggered on `addItem` when `count == capacity`):

```
addItem attempt ──► BAG_FULL_PROMPT (30s timer)
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
        "keep + remove  "discard   timeout
         target"         new item"  (auto-discard)
              │              │           │
              ▼              ▼           ▼
         target removed,  new item    new item
         new item added   discarded   discarded
```

## 5. Data Model

### 5.1 DataStore schema (`PlayerProfile.inventory`)

```lua
-- ProfileStore-compatible sub-table. See PlayerDataService for the parent profile shape.
export type ItemInstance = {
    id: string,             -- item definition id, e.g. "epee_gobelin" (FK into EquipmentConfig)
    itemType: string,       -- "weapon" | "head" | "chest" | "hands" | "legs" | "feet" (open string, extensible)
    rarity: string,         -- "common" | "rare" | "epic" | "legendary" | "mythic"
    voie: "guerrier" | "mage",
    baseStats: { [string]: number },  -- attack?, defense?, hp? — copied from EquipmentConfig at drop time
    forgeLevel: number,     -- integer >= 0, default 0. Written only by EconomyService.forgeItem.
    droppedAtKm: number,    -- integer >= 0, origin zone
    droppedAtTime: number,  -- os.time() at drop
    setId: string?,         -- e.g. "set_roi_gobelin", nil for non-set items
    locked: boolean,        -- default false; blocks quick-sell, never blocks Forge
    equippedSlot: string?,  -- nil, or "arme"|"casque"|"plastron"|"gants"|"jambieres"|"bottes" when equipped
}

export type PlayerInventory = {
    version: number,        -- schema version, currently 1
    capacity: number,       -- 100 or 200 (base + bonusCapacityPack)
    items: { [string]: ItemInstance },  -- keyed by itemKey
    equipped: {             -- denormalized slot -> itemKey index, for O(1) equip lookups
        arme: string?, casque: string?, plastron: string?,
        gants: string?, jambieres: string?, bottes: string?,
    },
}
```

**`itemKey` format:** `"<itemId>_<epoch>_<seq4>"`, e.g. `"epee_gobelin_1725235123_0042"`. Assigned
once at drop/purchase time; immutable for the life of the instance (survives Rebirth, save/load,
Forge, equip/unequip).

**Constraints (server-validated on every write):**
- `count(items) <= capacity`, always.
- `itemKey` uniqueness enforced at insert (collision → bump `seq4`, retry).
- `forgeLevel >= 0`, integer.
- `equipped[slot] == itemKey` must always match `items[itemKey].equippedSlot == slot` (both
  updated atomically in the same mutation; never one without the other).

### 5.2 Migration (Day 1 priority per §0.1)

Existing saved profiles under the old `{ [id|rarete|zone] = count }` shape must be migrated on
first load post-deploy: expand each stacked count into N distinct `ItemInstance`s with
`forgeLevel = 0` and freshly minted `itemKey`s. This is a one-way, one-time migration; log a
count of migrated items per player for QA spot-checks. Because this is a Day 1 priority, it ships
in the same release as `InventoryService`, not as a follow-up patch — no player should ever see
the old stacked-count shape after this system goes live.

## 6. Server-Side: `InventoryService`

Lives at `src/ServerScriptService/InventoryService.luau` (new module; currently this logic is
partially inlined in `EquipmentService.luau` and must be extracted/rewritten per §0.1).

```lua
--[[
    Returns the full inventory table for `player`. Server-only read; the client
    never receives more than what ListInventory() (the remote) explicitly returns.
]]
function InventoryService.getInventory(player: Player): PlayerInventory?

--[[
    Adds `instance` (already fully-formed, itemKey freshly minted by the caller —
    typically EquipmentService on drop, or EconomyService on shop purchase) to
    player's inventory.

    Validation:
      - player has an initialized profile
      - instance.id resolves in EquipmentConfig
      - instance.rarity is a known, active rarity
      - instance.forgeLevel == 0 (new items never start pre-forged)
      - if count(items) >= capacity: DOES NOT insert; returns (false, "full", instance)
        so the caller can drive the bag-full prompt (§10.1). No partial mutation.

    Returns (ok: boolean, reason: string?, instance: ItemInstance?)
]]
function InventoryService.addItem(player: Player, instance: ItemInstance): (boolean, string?)

--[[
    Removes item `itemKey` from player's inventory.
    Refuses if:
      - itemKey does not exist -> (false, "not found")
      - items[itemKey].equippedSlot ~= nil -> (false, "equipped")
    Returns (ok, reason?)
]]
function InventoryService.removeItem(player: Player, itemKey: string): (boolean, string?)

--[[
    Equips itemKey into its natural slot (derived from itemType, not client-supplied).
    itemType "hands" resolves to slot "gants".
    Refuses if:
      - itemKey not found -> (false, "not found")
      - itemType == "weapon" and player.inCombat -> (false, "in combat")
      - slot already holds a different itemKey -> unequips it first (returns to bag),
        UNLESS bag is at capacity and the outgoing item has nowhere to go -> (false, "full")
    Returns (ok, reason?)
]]
function InventoryService.equipItem(player: Player, itemKey: string): (boolean, string?)

--[[
    Unequips whatever occupies `slot`. No-op (ok=true) if slot already empty.
    Refuses if bag is at capacity (nothing to swap into) -> (false, "full")
]]
function InventoryService.unequipItem(player: Player, slot: string): (boolean, string?)

--[[
    Pure predicate, no mutation. Used by addItem and by the bag-full prompt UI
    to pre-check before offering "keep new item" as an option.
]]
function InventoryService.isSlotAvailable(player: Player): boolean
```

### Validation rules (every function)

- Every argument is type-checked before use (`typeof(itemKey) == "string"`, etc.). Reject
  malformed input with `(false, "invalid argument")` — never `error()` a remote handler.
- `itemKey` existence is always re-checked at the top of the function body, never assumed from a
  prior read (client-supplied keys may be stale by the time the remote fires).
- All mutations happen inside a per-player critical section (`InventoryService._locks[player]`)
  to serialize concurrent remote calls; see `luau-style-guide.md` §7 for cleanup pattern via Trove
  on `PlayerRemoving`.
- On any successful mutation, mark the profile dirty and fire `InventoryUpdated` (§7 remote spec).

### Rate limiting

Per `.claude/rules/server-scripts.md` — every player-triggered operation is rate-limited using the
pattern in that rule file:

| Operation | Limit |
|---|---|
| `AddItem` (server-internal only, not client-callable) | n/a |
| `RemoveItem` | 2/s |
| `EquipItem` | 2/s |
| `UnequipItem` | 2/s |
| `ListInventory` | 5/s |
| `confirmFullBagAction` | 1 response per open prompt window |

## 7. Client-Server Remotes

All remotes live in `ReplicatedStorage/Shared/Remotes.lua` under an `Inventory` namespace.

```lua
Remotes.Inventory = {
    AddItem            = getOrCreate("Inv_AddItem", "RemoteEvent"),      -- S -> C notify only; item creation is server-internal
    RemoveItem         = getOrCreate("Inv_RemoveItem", "RemoteEvent"),   -- C -> S {itemKey: string}
    EquipItem          = getOrCreate("Inv_EquipItem", "RemoteEvent"),    -- C -> S {itemKey: string}
    UnequipItem        = getOrCreate("Inv_UnequipItem", "RemoteEvent"),  -- C -> S {slot: string}
    ListInventory      = getOrCreate("Inv_ListInventory", "RemoteFunction"), -- C -> S -> C, no args -> PlayerInventory
    InventoryUpdated   = getOrCreate("Inv_InventoryUpdated", "UnreliableRemoteEvent"), -- S -> C, full or partial snapshot
    BagFullPrompt      = getOrCreate("Inv_BagFullPrompt", "RemoteEvent"), -- S -> C {newItem: ItemInstance}
    ConfirmFullBagAction = getOrCreate("Inv_ConfirmFullBagAction", "RemoteEvent"), -- C -> S {choice, targetItemKey?}
}
```

**Note on `ListInventory`:** per `.claude/docs/roblox-architecture-guide.md` §4, RemoteFunctions
client→server carry a server-hang risk. `ListInventory` is acceptable here because the response is
a synchronous read with no yielding I/O (no DataStore call — the profile is already cached
in-memory), so it cannot hang. If this ever needs to await anything, replace with a RemoteEvent
request/response pair.

**Validation on every C→S handler:**
- `RemoveItem` / `EquipItem`: `itemKey` must be a string, length-bounded (≤ 64 chars, matches the
  `itemKey` format regex), and must belong to *that* player's inventory — never trust a key from
  another player's session.
- `UnequipItem`: `slot` must be one of the 6 known slot strings (`arme`, `casque`, `plastron`,
  `gants`, `jambieres`, `bottes`). Reject anything else silently (log + no-op).
- `ConfirmFullBagAction`: `choice` must be exactly `"keep"` or `"discard"`; `targetItemKey`
  required and validated only when `choice == "keep"`.
- All handlers wrapped by the rate limiter in §6; violations are silently dropped + logged, no
  error surfaced to the exploiting client (avoid giving attackers a signal).

**`InventoryUpdated` payload** (unreliable, so the client must be able to reconcile out-of-order
or dropped packets — always includes a monotonically increasing `version` counter; client ignores
any update with `version` lower than the last one applied):

```lua
{ version: number, items: {[itemKey]: ItemInstance}, equipped: {...}, capacity: number }
```

## 8. Client UI Wireframe

Per `GAME_SPEC.md` §1.2 (frozen for overall style/layout; slot list updated per §0.3):

- **Grid:** 7 columns × N rows (matches the ASCII mockup's 7-wide grid), scrollable. 200 slots at
  7 columns = 29 rows max.
- **Equip screen slot list:** the equipment panel (`GAME_SPEC.md` §1.2 left column) must add a
  **GANTS** row alongside CASQUE / PLASTRON / JAMBIÈRES / BOTTES — 5 armor rows total, plus the
  weapon slot shown on the main HUD (`E ÉPÉE`). This is a mockup update owed back to
  `GAME_SPEC.md`/`ui-ux-gdd.md`, flagged for whoever owns those docs next.
- **Item card:** icon (rarity-colored border: gray/blue/purple/orange/red), name +
  `<Rarity> +<forgeLevel>` label (large font per inventory-gdd §2.3), small "(équipé)" tag if
  `equippedSlot ~= nil`, hover reveals full stat block + origin zone + drop timestamp.
- **Actions on select:** popup with `Équiper` (if applicable) / `Fusionner` / `Verrouiller` /
  `Supprimer` (disabled + tooltip "Déséquipez d'abord" if item is equipped).
- **Modals:**
  - `EquipItem` confirmation: only shown when equipping would displace a currently-equipped item
    of meaningfully higher forgeLevel/rarity (soft warning, not a hard block).
  - `DropItem`/`RemoveItem` confirmation: simple yes/no, always shown before permanent deletion.
  - `BagFullPrompt`: full-screen modal, 30s countdown, scrollable list of current items
    (sortable, same sort as main grid) with a "supprimer celui-ci" affordance per row, plus a
    top-level "Jeter le nouvel objet" button.
- **Edge case UI:**
  - Capacity readout in HUD and inventory header: `Inventaire : 87/200`, bar turns orange at
    >90%, red at 100%.
  - "Inventaire surchargé" banner (persistent, non-dismissible until resolved) when
    `count(items) > capacity` after a capacity downgrade (§10 edge case 5).

## 9. Integration Points

- **Depends on:** `EquipmentConfig.luau` (item/rarity definitions — must add `"gants"` to
  `SLOTS` and `ARMOR_SLOTS`, see §0.3), `PlayerDataService.luau` (profile persistence,
  dirty/flush), `EconomyService` (Forge writes `forgeLevel`, fusion consumes + creates instances).
- **Feeds:** `StatsService.recalc` (reads `equipped` index, now 6 slots including `gants`, to sum
  stat bonuses — depends on `EquipmentService.getStatBonuses`-equivalent, now backed by
  `InventoryService.getInventory`), `CombatServer` (drop creation calls
  `InventoryService.addItem`), `CodexService` (item pickups register family completion —
  read-only observer of `InventoryUpdated`).
- **`EquipmentService`'s role narrows** under this spec: it becomes the definitions/config lookup
  layer (`EquipmentConfig`) plus the pure stat-bonus calculator; `InventoryService` becomes the
  sole owner of slot mutation and persistence. This is the concrete migration implied by §0.1 —
  lead-programmer to confirm the split before implementation starts.
- **Content-scope consequence (§0.3):** adding Gants raises launch armor count from 96 to 120
  (12 boss × 5 pièces × 2 voies). Flagged for game-designer/art-director; not an implementation
  blocker for `InventoryService`, but asset/data lists for `EquipmentConfig` must be updated to
  match before content is considered complete.

## 10. Edge Cases & Validation

1. **Full inventory, new drop arrives:** `addItem` returns `(false, "full")`; caller fires
   `BagFullPrompt`; 30s timeout auto-discards (per inventory-gdd §2.4). No partial state — the
   new item is never silently lost or silently kept.
2. **Equipped item deletion attempt:** `removeItem` returns `(false, "equipped")`; client shows
   "Déséquipez d'abord."
3. **Duplicate items:** confirmed via inventory-gdd §2.1 — never stack. Two copies = two slots,
   two `itemKey`s, independently forgeable.
4. **DataStore unavailable:** mutations continue in-memory (dirty flag set); `InventoryService`
   never blocks gameplay on a DataStore round-trip. On DataStore recovery, flush dirty profile.
   Player is not told the DataStore was down — that's an ops-level concern.
5. **Capacity downgrade** (e.g., bug/refund reverses the capacity pack): if
   `count(items) > new capacity`, inventory enters "overloaded" state — no new items acceptable,
   persistent banner, until player manually removes items to get under the cap.
6. **Concurrent equip/unequip spam:** rate limit (2/s) plus the per-player critical section in §6
   prevent races; a losing concurrent call is refused silently server-side, logged.
7. **Weapon change mid-combat:** refused, `weaponChangeRefused` fired to client (existing
   inventory-gdd §5 remote); armor/equip (including Gants) has no such restriction.
8. **Network lag mid-transaction:** all remote handlers are idempotent-safe at the "already in
   target state" check (e.g., re-sending `EquipItem` for an already-equipped `itemKey` returns
   `ok=true` as a no-op, not an error) — protects against client retry-on-timeout duplicating
   effects.
9. **Player disconnects mid-action (e.g., mid bag-full prompt):** server-side 30s timer is
   independent of client connection; on timeout with no response (including due to disconnect),
   auto-discard fires exactly as if the client had timed out normally. `PlayerRemoving` also
   force-flushes the dirty profile immediately, no `BindToClose` wait needed for that player.
10. **Corrupted profile on load** (`count(items) > capacity` at load time, e.g. legacy data or
    migration bug): server trims the oldest items by `droppedAtTime` until under capacity, logs
    the trim for QA, does not crash the load.
11. **Rejected: client-side inventory mutation.** The client never computes or predicts inventory
    state changes; it only renders what `ListInventory`/`InventoryUpdated` return. Any client
    module that locally mutates an inventory table before server confirmation is a bug, not a
    feature (no optimistic UI for adds/removes — the operation is fast enough server-side that
    optimistic UI isn't worth the desync risk).

## 11. Balancing Parameters

`GameConfig.Inventory` (extends the existing table referenced in inventory-gdd §8):

```lua
baseCapacity = 100
bonusCapacityPackId = "capacity_pack"
bonusCapacity = 100
maxCapacity = 200
bagFullTimeoutSeconds = 30
weaponChangeRateLimitPerSec = 2
removeItemRateLimitPerSec = 2
equipItemRateLimitPerSec = 2
listInventoryRateLimitPerSec = 5
```

## 12. Acceptance Criteria

- [ ] `InventoryService` uses the unique-instance model (`{ [itemKey] = ItemInstance }`); no
      stacked counts remain anywhere in the item-storage path.
- [ ] Capacity enforced at 100 base / 200 with pack; `count(items) <= capacity` holds after every
      mutation, verified by an automated test that hammers `addItem` past the cap.
- [ ] `EquipmentConfig.SLOTS` and `EquipmentConfig.ARMOR_SLOTS` include `"gants"`; equipping a
      Gants item routes to the `gants` slot and appears in `getStatBonuses`-equivalent totals.
- [ ] Full-bag flow never silently drops or silently keeps an item; the 30s timeout auto-discards
      exactly per §10.1.
- [ ] `removeItem` on an equipped item always refuses; `equipItem`/`unequipItem` keep the
      `equipped` index (6 slots) and each `ItemInstance.equippedSlot` in sync on every call.
- [ ] Weapon equip refused server-side while `inCombat == true`; armor equip (all 5 armor slots)
      has no such gate.
- [ ] No two items ever share an `itemKey`; collision-retry logic covered by a unit test.
- [ ] `forgeLevel` persists correctly through equip/unequip/save/load and Rebirth.
- [ ] All 5 remotes validate every argument per §7 and are individually rate-limited per §6.
- [ ] `InventoryUpdated`'s `version` counter prevents stale/out-of-order client application (test
      with simulated dropped/reordered UnreliableRemoteEvent packets).
- [ ] Legacy stacked-count profiles migrate cleanly to the unique-instance shape on first load
      post-deploy, with a per-player migrated-item-count log line for QA. Ships Day 1, not as a
      follow-up patch.
- [ ] Edge cases 1–11 in §10 each have a corresponding automated or manual QA test case.
