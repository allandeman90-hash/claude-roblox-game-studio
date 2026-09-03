# Inventory Implementation Sprint — 2026-09-02

**Status:** Ready to start
**Owner:** lead-programmer (coordination), luau-systems-programmer / ui-programmer / remotes-networking-specialist (implementation)
**Reference:** `design/gdd/inventory-gdd.md`

## Resolved decisions (confirmed by user, 2026-09-02)

All 5 blockers identified during planning are resolved:

1. **Capacity:** 200 max (100 base + 100 bonus). `inventory-gdd.md` §2.1/§8 is being
   updated to 200 by game-designer/systems-designer (was 125 in the original text) —
   this plan assumes 200 and reads the number only from `GameConfig.Inventory.maxCapacity`,
   never hardcoded, so a later correction stays a one-line change.
2. **Gants (5th armor slot):** descoped from v0.1. Tracked as a P2 fast-follow
   (96 new boss armor defs + set-bonus tier rebalance + loot table thresholds —
   see Risk 5). Not part of this sprint's Day 1-3 work.
3. **Remote architecture:** keep the existing multiplexed dispatcher pattern
   (single `combatEvent` RemoteEvent, `data.type` dispatch, per-type rate limits in
   `GameConfig.Security.remotePerType`). New inventory actions (`removeItem`,
   `confirmFullBagAction`) are added as new `data.type` cases, not new RemoteEvent
   instances. Consistent with the rest of `CombatServer.server.luau`.
4. **Fusion:** out of v0.1 scope, stubbed. `fuseItem` dispatch returns
   `{type="fuseResult", ok=false, reason="not_available"}`. Real fusion logic
   depends on `economy-gdd.md` §2.5, not yet specified for unique-instance items.
5. **Locked/filters:** both kept. `EquipmentService`'s existing `locked` (quick-sell
   protection) and `filters` (rarity/voie auto-pickup filter) migrate into
   `InventoryService` unchanged, with their existing remotes (`toggleLock`,
   `setFilters`).

With these resolved, the day-by-day plan below is go as originally scoped.

---

## Migration map — what actually breaks

**Current shape:** `EquipmentService` per-player table `{ equipe, inventory = {[key]=count}, locked, filters }`, key = `"id|rarete|zone"`. Stored via `EquipmentService.serialize()`/`.restore()`, referenced from `PlayerDataService`'s `equipe`/`inventaire` fields (currently `inventaire = {}` stub, unused).

**Target shape (per GDD §3):** `PlayerDataService` profile gets a real `inventory: {capacity, items: {[itemKey]: ItemInstance}}` table; new `InventoryService` module owns all mutation/query logic; `EquipmentService` shrinks to item definitions + stat lookups + calling `InventoryService.addItem` on drop/purchase.

**Call sites that must change (not just `EquipmentService.luau` itself):**

| File | Current call | Change needed |
|---|---|---|
| `CombatServer.server.luau:382,391` | `EquipmentService.addItem(player, drop, "loot")` | → `InventoryService.addItem`, handle "bag full → prompt" return instead of silent `"inventory full"` reason |
| `CombatServer.server.luau:833` (`fuseItem`) | `EquipmentService.fuse(...)` | Stub to `fuseResult{ok=false, reason="not_available"}` |
| `CombatServer.server.luau:847,854,861,874` (`setFilters`,`toggleLock`,`equipItem`,`unequipItem`) | direct `EquipmentService.*` calls, list rebuilt via `EquipmentService.listInventoryForSlot` | → `InventoryService.equipItem`/`unequipItem`/`setFilters`/`toggleLock`; add `inCombat` gate on weapon slot; response payload shape moves to GDD's `inventoryUpdate` |
| `ShopService.luau:152-153` | `grantOwnership` + `equip` | → `InventoryService.addItem` + `InventoryService.equipItem` |
| `LootService.luau:102` (comment only) | n/a | Update comment reference |
| `StatsService.luau:41,99-100` | reads `EquipmentService.getStatBonuses(player)` | **No change.** `equipe` (6 equip slots) and the new `InventoryService` bag are two separate stores; equip pulls an item out of the bag, unequip returns it. |

**Migration path for old profiles (old `{key=count}` stacks → unique instances):**

```
On PlayerDataService.load(player), after migrate(profile):
  if profile.inventory == nil (old schema, has profile.inventaire / profile.equipe stacks):
    new_items = {}
    for key, count in profile.inventaire (old stack table):
      id, rarete, zone = parseKey(key)   -- reuse EquipmentService's existing parser
      def, category = EquipmentConfig.getItem(id)
      if def then
        for i = 1, count:
          itemKey = id .. "_" .. os.time() .. "_" .. sequence++
          new_items[itemKey] = buildItemInstance(def, category, rarete, zone)  -- forgeLevel=0, droppedAtKm=zone, droppedAtTime=now
    -- equipped items (profile.equipe) also get converted to instances and
    -- EXCLUDED from bag count (they live in `equipe`, not `inventory.items`)
    profile.inventory = { capacity = GameConfig.Inventory.baseCapacity, items = new_items }
    profile.inventaire = nil  -- retire the stub field
  -- Clamp: if count(items) > capacity, drop oldest by droppedAtTime (GDD edge case #9), log a warn per player
```

This is schema v1→v2 territory — `PlayerDataService.PROFILE_VERSION` bumps to 2, `migrate()` gets a real branch instead of the current no-op.

---

## Day-by-day plan

### Day 1 — Migration Foundation
Owner: `luau-systems-programmer` (implementation), `lead-programmer` (architecture call + review)

- **1a.** `GameConfig.luau`: add `GameConfig.Inventory` block (`baseCapacity=100`, `bonusCapacity=100`, `maxCapacity=200`, `bagFullTimeoutSeconds=30`, rate limits). `PlayerDataService`: replace `inventaire` stub with real `inventory = {capacity, items}` field; bump `PROFILE_VERSION` to 2.
- **1b.** Write the migration function above inside `PlayerDataService.load()` (or a `migrate()` helper it calls). Extensive `warn()` logging per player on any clamp/drop. Reuse `EquipmentService`'s `parseKey`/`ownKey` logic rather than reinventing.
- **1c.** Rewrite `EquipmentService.luau`: strip `inventory`/`locked`/`filters`/`addItem`/`fuse`/`sellBelow`/`listInventoryForSlot`/`getInventorySummary` — move to `InventoryService`. Keep: `equipe` state, `equip`/`unequip` (rewritten to call `InventoryService.addItem`/`removeItem`), `getStatBonuses`, `getPetEffect`, `describeSlot`, `describeArmorSummary`, `serialize`/`restore` (equip-side only). Update the 4 external call sites (`CombatServer`, `ShopService`) in the **same PR** — cannot land half-migrated without breaking loot/shop.
- **1d.** Stub `InventoryService.luau` (new module, `ServerScriptService`) with typed function signatures only: `getInventory`, `addItem`, `removeItem`, `equipItem`, `unequipItem`, `confirmFullBagAction`, `setFilters`, `toggleLock`. No bodies yet beyond `error("not implemented")`.
- **1e.** Add `removeItem`/`confirmFullBagAction` `data.type` cases (empty handlers) + rate-limit entries to `GameConfig.Security.remotePerType`, confirming the dispatcher pattern with `remotes-networking-specialist`.
- **Checkpoint:** Server boots without errors on both a fresh profile and a hand-crafted legacy-schema profile (v1, with `inventaire` stacks) in Studio; drop/purchase flows still run end-to-end by forwarding to `InventoryService.addItem` stub returning a fixed success — nothing crashes, even though real bag logic isn't live yet.

### Day 2 — Core Inventory Logic
Owners: `luau-systems-programmer` (2a, 2c, 2d), `remotes-networking-specialist` (2b, 2c review)

- **2a.** Implement `InventoryService`: `getInventory(player)`, `addItem(player, def, category, rarete, zone, source)` (generates unique `itemKey`, checks capacity, returns `(ok, reason)` or triggers bag-full flow), `removeItem(player, itemKey)`, `equipItem(player, slot, itemKey)` (checks `inCombat` for weapon slot per §2.5), `unequipItem(player, slot)`, `setFilters`, `toggleLock` (ported from `EquipmentService` unchanged).
- **2b.** Wire dispatch: `removeItem`, `confirmFullBagAction` as new `data.type` cases on `combatEvent`. Response shape: single `inventoryUpdate` payload (full or delta bag state) per GDD §5, replacing the current ad-hoc `{[slot]=list}` shape.
- **2c.** Server validation + rate limiting: `removeItem` (2/s), `confirmFullBagAction` (1/s), weapon-change combat-state gate, added to `GameConfig.Security.remotePerType`. `exploit-security-specialist` spot-checks for duplication vectors (equip-swap race, addItem double-fire) before end of day.
- **2d.** Bag-full flow: server-side pending-offer state per player (`{item, expiresAt}`), `task.delay(30, ...)` auto-discard, `confirmFullBagAction{choice, targetRemove?}` handler, idempotent on double-resolution.
- **Checkpoint:** In-Studio manual test — kill an enemy, item lands in bag; fill bag to 200, next drop triggers `bagFullPrompt`; `keep`/`discard`/`timeout` all resolve correctly; equip/unequip round-trips an item between `equipe` and bag without loss; weapon-change is refused mid-combat.

### Day 3 — Client UI + E2E
Owner: `ui-programmer` (3a–3c), `lead-programmer` + `luau-systems-programmer` (3d–3e)

- **3a.** New `InventoryScreenGui` + `InventoryClient.client.luau` under `StarterGui`/`StarterPlayerScripts` — net-new build (no existing screen to extend). Grid by category (Armes/Casques/Corps/Jambières/Bottes — no Gants column in v0.1), rarity-colored cards, `Nom Rareté +N` format.
- **3b.** Wire UI → dispatch: item click → `equipItem`/`removeItem`, sort/filter buttons (client-side sort of server-provided list, per §6.2), capacity HUD (`87/200`, red/orange thresholds).
- **3c.** `bagFullPrompt` modal: item list, keep/discard buttons, 30s visual countdown synced to server `expiresAt`.
- **3d.** Edge-case pass against GDD §7 (12 cases) — priority: #1 (timeout discard), #4 (combat refusal), #8 (DataStore down → in-memory only, no crash), #9 (corrupted load → clamp).
- **3e.** QA checklist covering all 12 edge cases + §9 acceptance criteria.
- **Checkpoint:** Play-test in Studio — happy path (add/remove/equip/bag-full/combat-refusal) all work; no duplicated items after a rapid equip/unequip spam test.

---

## Risk register

| # | Risk | Mitigation |
|---|---|---|
| 1 | Legacy profile corruption during migration (wrong parse, dropped items) | Extensive `warn()` logging per player during migration; dry-run against a copied prod-shaped profile in Studio before touching real data; migration is additive-only (never deletes `inventaire` field until `inventory` is confirmed populated) |
| 2 | Circular dependency: `EquipmentService` (equip/creates instances) ↔ `InventoryService` (owns storage) | `InventoryService` never requires `EquipmentService`; `EquipmentService.equip/unequip` are the only functions calling into `InventoryService`, one direction only |
| 3 | Schema versioning gap — v1 (stacks) vs v2 (instances) profiles coexisting during rollout | `PlayerDataService.migrate()` handles both on every load, not just at deploy time |
| 4 | Item duplication via equip/unequip race (rapid clicks) or bag-full timeout racing a manual `confirmFullBagAction` | Rate limits (2c) + `exploit-security-specialist` review before Day 2 checkpoint; bag-full offer resolution is idempotent |
| 5 | Gants (P2 fast-follow) touches `EquipmentConfig`'s boss-set generator, `SetBonusTiers`, `BossLootTable`, and `StatsService` armor aggregation — non-trivial when it lands | Tracked separately; not started in this sprint; flagged here so the follow-on estimate isn't underscoped |

## Resource allocation

- `luau-systems-programmer` — Day 1–2 (`InventoryService`, `PlayerDataService` migration, `EquipmentService` rewrite)
- `ui-programmer` — Day 2 (review remote contract) – Day 3 (full UI build)
- `remotes-networking-specialist` — Day 1 (dispatcher confirmation) + Day 2 (contract/rate-limit review)
- `lead-programmer` — coordination + Day 1 architecture review + code review at both checkpoints
- `exploit-security-specialist` — review before Day 2 checkpoint (duplication vectors)

## Ready-to-start checklist

- [x] Capacity confirmed: 200 max
- [x] Gants descoped to P2
- [x] Remote pattern decision made: keep dispatcher
- [x] Fusion confirmed out of scope, stubbed
- [x] Locked/filters: keep both
- [ ] `inventory-gdd.md` §2.1/§8 text updated to 200 (tracked with game-designer/systems-designer, not blocking Day 1 start since this plan reads capacity from config, not the doc)
