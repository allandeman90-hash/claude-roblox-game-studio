--==============================================================
-- InventoryService  (ModuleScript - ServerScriptService)
--
-- Real implementation (Inventory Sprint Day 2, design/specs/
-- inventory-implementation-spec.md §6). Owns the unique-instance bag
-- (`PlayerProfile.inventory`): capacity, slot mutation, equip/unequip
-- bag-side moves, the full-bag prompt, locking, and filters.
--
-- Dependency direction (sprint risk register #2): InventoryService NEVER
-- requires EquipmentService AT MODULE TOP LEVEL. EquipmentService requires
-- InventoryService at ITS top level (one direction). equipItem/unequipItem
-- below need to call EquipmentService.equip/unequip (the only writer of the
-- per-player `equipe` table StatsService reads for stat bonuses), so they do
-- a LAZY require (function-local, memoized on first call - see
-- getEquipmentService below). By the time either function actually runs,
-- both modules have finished their initial load and the require cache
-- returns instantly; a top-level require here would instead hit a live
-- circular dependency and hand one side a half-initialized module table.
-- See wiki/concepts/module-lazy-loading.md.
--
-- Storage lives entirely on PlayerDataService's live profile table
-- (`profile.inventory`, mutated in place - never copied). Handlers here
-- never write to DataStore directly: every successful mutation calls
-- PlayerDataService.markDirty(player, profile); the throttled writer (with
-- its own pcall + exponential-backoff retry, see PlayerDataService.luau)
-- persists it. Session locking is likewise entirely PlayerDataService's
-- concern - this module never touches profile._lock.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local EquipmentConfig = require(ReplicatedStorage:WaitForChild("EquipmentConfig"))

local PlayerDataService = require(ServerScriptService:WaitForChild("PlayerDataService"))

local InventoryService = {}

--===== Constants =====

-- itemType (ItemInstance, English body-location string) -> equip slot
-- (French, matches Types.PlayerInventory.equipped's 6 keys). Independent of
-- EquipmentConfig.SLOTS/.ARMOR_SLOTS on purpose: those arrays do not
-- currently include "gants" (spec §0.3 flags this as a required follow-up
-- for whoever owns EquipmentConfig.luau - NOT done here, out of this
-- module's scope). This module's own 6-slot `equipped` index is always
-- correct; EquipmentService.equip(player, "gants", ...) will still reject
-- with "invalid slot" until that follow-up lands, since EquipmentConfig.SLOTS
-- is what EquipmentService validates against.
local ITEM_TYPE_TO_SLOT: { [string]: string } = {
    weapon = "arme",
    head = "casque",
    chest = "plastron",
    hands = "gants",
    legs = "jambieres",
    feet = "bottes",
}

-- Inverse: armor `def.slot` (French, from EquipmentConfig.Armor / the
-- LootService/ShopService draft `slot` field) -> canonical ItemInstance
-- itemType (English body location, Types.luau). Used by normalizeDraft to
-- RE-DERIVE itemType from the item definition rather than trust whatever the
-- caller passed - LootService.rollDrop and ShopService.handlePurchase both
-- hand addItem a draft whose `itemType`/`slot` field does not match the
-- canonical vocabulary (see normalizeDraft below for details).
local ARMOR_SLOT_TO_ITEM_TYPE: { [string]: string } = {
    casque = "head",
    plastron = "chest",
    gants = "hands",
    jambieres = "legs",
    bottes = "feet",
}

-- The 6 slot keys of PlayerInventory.equipped (spec §5.1). "pet" is
-- deliberately excluded - it is not part of this module's equipped index
-- (see equipItem's pet branch).
local EQUIP_SLOT_SET: { [string]: boolean } = {
    arme = true, casque = true, plastron = true,
    gants = true, jambieres = true, bottes = true,
}

local VOIE_FILTER_VALUES: { [string]: boolean } = {
    guerrier = true, mage = true, all = true, tous = true,
}

local MAX_ITEM_KEY_LEN = 64

-- Creation gift (onboarding-gdd §2.1 / EquipmentConfig starter weapons): the
-- "Épée en bois", minted into the bag and equipped on a brand-new hero's first
-- run. Deliberately weak (isStarter -> x0.5 power) so the first drop is an upgrade.
local STARTER_WEAPON_ID = "epee_courte"

-- FTUE end-of-tutorial gift (onboarding-gdd §2.1). Generic DPS pet, identical
-- for every new player. Its power is halved vs a looted pet (isStarter, see
-- EquipmentConfig.StarterPetPowerMult / EquipmentService.getPetEffect).
local STARTER_PET_ID = "fee"

--===== Private state =====

-- [player] = { instance: ItemInstance, thread: thread?, createdAt: number }
-- One open bag-full prompt per player at a time (spec §6: "1 response per
-- open prompt window"). Populated by addItem when it hits capacity; resolved
-- by confirmFullBagAction or auto-discarded after
-- GameConfig.Inventory.bagFullTimeoutSeconds.
local pendingFullBag: { [Player]: { instance: any, thread: thread?, createdAt: number } } = {}

-- Memoized lazy handle to EquipmentService (see header comment).
local equipmentServiceRef: any = nil

--===== Private helpers =====

local function getEquipmentService(): any
    if not equipmentServiceRef then
        equipmentServiceRef = require(ServerScriptService:WaitForChild("EquipmentService")) :: any
    end
    return equipmentServiceRef
end

local function isValidPlayer(player: Player): boolean
    return typeof(player) == "Instance" and player:IsA("Player")
end

local function isValidItemKey(itemKey: any): boolean
    return type(itemKey) == "string" and itemKey ~= "" and #itemKey <= MAX_ITEM_KEY_LEN
end

-- Resolves the live profile + its `inventory` sub-table for `player`.
-- Returns (nil, nil) if no session is loaded (offline / not yet loaded /
-- degraded-and-released) - callers translate that into ("no_profile").
local function getInventoryFor(player: Player): (any, Types.PlayerInventory?)
    local profile = PlayerDataService.getProfile(player)
    if not profile or type(profile.inventory) ~= "table" then
        return nil, nil
    end
    return profile, profile.inventory
end

local function countItems(inv: Types.PlayerInventory): number
    local n = 0
    for _ in pairs(inv.items) do
        n += 1
    end
    return n
end

-- itemKey format (spec §5.1): "<itemId>_<epoch>_<seq4>". Collision-retry
-- mirrors PlayerDataService's migration minting logic for consistency.
local function mintItemKey(inv: Types.PlayerInventory, id: string): string
    local epoch = os.time()
    local seq = 0
    local key
    repeat
        seq += 1
        key = string.format("%s_%d_%04d", id, epoch, seq)
    until inv.items[key] == nil
    return key
end

local function logAction(player: Player, fmt: string, ...: any)
    warn(("[InventoryService] Player %d: " .. fmt):format(player.UserId, ...))
end

-- Normalizes a loosely-typed "draft" item (as handed to addItem by
-- LootService.rollDrop { id, nom, slot, voie, rarete, zone, isBoss },
-- ShopService.handlePurchase's hand-built instance table, or
-- EquipmentService's instanceFromEquipeEntry) into a canonical
-- Types.ItemInstance, re-deriving `itemType` from EquipmentConfig rather
-- than trusting the caller's field (every current caller's `itemType`/`slot`
-- field uses inconsistent vocabulary - see the ShopService.luau comment
-- "InventoryService normalizes this (Day 2)").
-- `isFromEquipSlot` relaxes the forgeLevel gate below (see comment there) -
-- callers that are not EquipmentService returning a previously-owned item
-- must never pass true.
-- Returns (instance, nil) on success, or (nil, reason) on validation failure.
local function normalizeDraft(draft: any, isFromEquipSlot: boolean?): (Types.ItemInstance?, string?)
    if type(draft) ~= "table" then
        return nil, "invalid_argument"
    end

    local id = draft.id
    if type(id) ~= "string" or id == "" then
        return nil, "invalid_argument"
    end

    local def, category = EquipmentConfig.getItem(id)
    if not def or not category then
        return nil, "unknown_item"
    end

    local rarity = draft.rarity or draft.rarete
    if type(rarity) ~= "string" then
        return nil, "invalid_argument"
    end
    local rarityDef = EquipmentConfig.getRarity(rarity)
    if not rarityDef or not rarityDef.active then
        return nil, "invalid_rarity"
    end

    local itemType: string?
    if category == "weapon" then
        itemType = "weapon"
    elseif category == "pet" then
        itemType = "pet"
    else -- "armor"
        itemType = ARMOR_SLOT_TO_ITEM_TYPE[def.slot]
    end
    if type(itemType) ~= "string" then
        return nil, "unknown_item"
    end

    -- Brand-new items (loot/shop) never start pre-forged (spec §6) - reject
    -- rather than silently clamp, since a caller passing a nonzero forgeLevel
    -- for a NEW item is a bug and should fail loudly. The one legitimate
    -- exception is EquipmentService.equip/unequip handing back a
    -- previously-owned, possibly-forged instance that is returning to the
    -- bag from an equip slot (Forge writes forgeLevel via a direct field
    -- mutation on an already-owned instance, never through addItem, so that
    -- forgeLevel must survive the round trip instead of being stripped) -
    -- those callers pass isFromEquipSlot = true. Type is still validated
    -- either way so a malformed forgeLevel can never slip through.
    local forgeLevel = draft.forgeLevel
    if forgeLevel == nil then
        forgeLevel = 0
    elseif type(forgeLevel) ~= "number" then
        return nil, "invalid_argument"
    elseif forgeLevel ~= 0 and not isFromEquipSlot then
        return nil, "invalid_argument"
    end

    local droppedAtKm = tonumber(draft.droppedAtKm or draft.zone) or 0
    local droppedAtTime = tonumber(draft.droppedAtTime) or os.time()
    local baseStats = (type(draft.baseStats) == "table") and draft.baseStats or {}

    local instance: Types.ItemInstance = {
        id = id,
        itemType = itemType :: string,
        rarity = rarity,
        voie = draft.voie or def.voie,
        baseStats = baseStats,
        forgeLevel = forgeLevel,
        droppedAtKm = math.max(0, math.floor(droppedAtKm)),
        droppedAtTime = droppedAtTime,
        setId = draft.setId or def.set,
        locked = draft.locked == true,
        equippedSlot = nil, -- addItem always inserts into the bag, never pre-equipped
    }
    if itemType == "pet" then
        -- Pet scaling is level-based: sourceLevel (the enemy level it dropped
        -- from) is fixed; petLevel climbs toward the player's level while equipped
        -- as petXp fills (EquipmentService.grantPetXp).
        instance.sourceLevel = math.max(1, math.floor(tonumber(draft.sourceLevel) or 1))
        instance.petLevel = math.max(1, math.floor(tonumber(draft.petLevel) or 1))
        instance.petXp = math.max(0, math.floor(tonumber(draft.petXp) or 0))
    end
    return instance, nil
end

-- Starts (or extends, if a pending prompt already exists - see comment
-- below) the 30s auto-discard window for a bag-full event. Only ONE pending
-- prompt is tracked per player: if a second item fails to add while one is
-- already open, it is simply discarded (no queue) rather than disturbing the
-- first prompt's timer or overwriting it, since InventoryService has no way
-- to show a second modal on top of the first.
local function startFullBagTimer(player: Player, instance: Types.ItemInstance)
    if pendingFullBag[player] then
        -- Already an open prompt for this player - the new arrival is
        -- silently dropped, not queued (spec has no multi-prompt model).
        return
    end

    local timeoutSec = GameConfig.Inventory.bagFullTimeoutSeconds or 30
    local entry
    entry = {
        instance = instance,
        createdAt = os.time(),
        thread = nil :: thread?,
    }
    entry.thread = task.delay(timeoutSec, function()
        -- Defensive: the player may have disconnected mid-prompt (spec §10
        -- edge case 9) - PlayerRemoving releases the DataStore session but
        -- nothing currently calls InventoryService.release() to clear this
        -- table (flagged in the implementation notes), so guard on identity
        -- rather than assume the entry is still ours.
        if pendingFullBag[player] == entry then
            pendingFullBag[player] = nil
            logAction(player, "bag-full prompt timed out - auto-discarded %s", instance.id)
        end
    end)
    pendingFullBag[player] = entry
end

--===== Public API =====

--[[
    Returns the full inventory table for `player`. Server-only read; the
    client never receives more than what the ListInventory remote explicitly
    returns. Returns the LIVE table (not a copy) - callers must treat it as
    read-only, matching EquipmentService.getEquipped's convention.
]]
function InventoryService.getInventory(player: Player): Types.PlayerInventory?
    if not isValidPlayer(player) then
        return nil
    end
    local _, inv = getInventoryFor(player)
    return inv
end

--[[
    Adds `instance` (a loosely-typed draft - see normalizeDraft) to player's
    inventory, minting a fresh itemKey ("<id>_<epoch>_<seq4>"). Returns
    (ok, reason?).

    `isFromEquipSlot` must be true ONLY when EquipmentService is returning a
    previously-owned item from an equip slot back to the bag (equip's
    displaced-item swap, equip's own-item rollback, and unequip) - it allows
    `instance.forgeLevel` to be nonzero for that one trusted internal path.
    Every other caller (loot, shop, etc.) must pass nil/false so brand-new
    items are still rejected if they arrive pre-forged (spec §6).

    On capacity overflow, opens the bag-full prompt window (spec §10.1) and
    returns (false, "bag_full") without any partial mutation - the caller
    (CombatServer's loot handler, ShopService) is responsible for notifying
    the client; confirmFullBagAction resolves the prompt.
]]
function InventoryService.addItem(player: Player, instance: Types.ItemInstance, isFromEquipSlot: boolean?): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end

    local profile, inv = getInventoryFor(player)
    if not profile or not inv then
        return false, "no_profile"
    end

    local normalized, normErr = normalizeDraft(instance, isFromEquipSlot)
    if not normalized then
        return false, normErr or "invalid_argument"
    end

    local capacity = inv.capacity or GameConfig.Inventory.baseCapacity
    if countItems(inv) >= capacity then
        startFullBagTimer(player, normalized)
        logAction(player, "bag full (%d/%d) - rejected %s", capacity, capacity, normalized.id)
        return false, "bag_full"
    end

    local itemKey = mintItemKey(inv, normalized.id)
    inv.items[itemKey] = normalized

    PlayerDataService.markDirty(player, profile)
    logAction(player, "added %s (%s, %s) as %s", normalized.id, normalized.rarity, normalized.itemType, itemKey)
    return true, nil
end

--[[
    Removes item `itemKey` from player's inventory. Refuses if the item does
    not exist, is locked, or (defensively) is currently equipped. Returns
    (ok, reason?).
]]
function InventoryService.removeItem(player: Player, itemKey: string): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end
    if not isValidItemKey(itemKey) then
        return false, "invalid_argument"
    end

    local profile, inv = getInventoryFor(player)
    if not profile or not inv then
        return false, "no_profile"
    end

    local item = inv.items[itemKey]
    if not item then
        return false, "item_not_found"
    end
    if item.locked then
        return false, "item_locked"
    end
    -- Defensive only: equipped items are moved OUT of `items` entirely by
    -- equipItem (see below), so a bag entry should never have equippedSlot
    -- set. Kept as a guard in case that invariant is ever broken upstream.
    if item.equippedSlot ~= nil then
        return false, "item_equipped"
    end

    inv.items[itemKey] = nil
    PlayerDataService.markDirty(player, profile)
    logAction(player, "removed %s (%s)", itemKey, item.id)
    return true, nil
end

--[[
    Equips itemKey into its natural slot (derived from itemType, never
    client-supplied). Idempotent: re-equipping an already-equipped key is a
    successful no-op (spec §10 edge case 8). Returns (ok, reason?).
]]
function InventoryService.equipItem(player: Player, itemKey: string): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end
    if not isValidItemKey(itemKey) then
        return false, "invalid_argument"
    end

    local profile, inv = getInventoryFor(player)
    if not profile or not inv then
        return false, "no_profile"
    end

    -- Idempotent no-op: protects against client retry-on-timeout duplicating
    -- an already-applied equip (spec §10 edge case 8).
    for _, key in pairs(inv.equipped) do
        if key == itemKey then
            return true, nil
        end
    end

    local item = inv.items[itemKey]
    if not item then
        return false, "item_not_found"
    end

    local EquipmentService = getEquipmentService()

    if item.itemType == "pet" then
        -- Pets are not part of this module's 6-slot `equipped` index
        -- (Types.PlayerInventory.equipped has no `pet` key) - route straight
        -- to EquipmentService, which owns a 7th "pet" slot internally.
        local ok, err = EquipmentService.equip(player, "pet", itemKey)
        if ok then
            PlayerDataService.markDirty(player, profile)
            logAction(player, "equipped pet %s (%s)", itemKey, item.id)
        end
        return ok, err
    end

    local slot = ITEM_TYPE_TO_SLOT[item.itemType]
    if not slot then
        return false, "invalid_item_type"
    end

    -- Defensive pre-check against a known EquipmentService.equip bug: if the
    -- target slot is occupied and the bag is already full, EquipmentService
    -- would still overwrite the slot and DROP the displaced item silently
    -- (see implementation notes - flagged for EquipmentService owner, not
    -- fixed here). Refusing up front here means InventoryService never
    -- triggers that code path.
    local displaced = inv.equipped[slot]
    if displaced ~= nil and displaced ~= itemKey and countItems(inv) >= (inv.capacity or GameConfig.Inventory.baseCapacity) then
        return false, "full"
    end

    local ok, err = EquipmentService.equip(player, slot, itemKey)
    if not ok then
        return false, err
    end

    -- EquipmentService.equip already removed itemKey from inv.items (via its
    -- own call into InventoryService.removeItem) as part of the slot swap.
    -- Mirror the denormalized index (spec §5.1 constraint).
    inv.equipped[slot] = itemKey
    PlayerDataService.markDirty(player, profile)
    logAction(player, "equipped %s (%s) into %s", itemKey, item.id, slot)
    return true, nil
end

--[[
    Unequips whatever occupies `slot`. No-op (ok=true) if slot already empty.
    Refuses if the bag is at capacity (nothing to swap the item back into).
    Returns (ok, reason?).
]]
function InventoryService.unequipItem(player: Player, slot: string): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end
    if type(slot) ~= "string" or (slot ~= "pet" and not EQUIP_SLOT_SET[slot]) then
        return false, "invalid_argument"
    end

    local profile, inv = getInventoryFor(player)
    if not profile or not inv then
        return false, "no_profile"
    end

    local EquipmentService = getEquipmentService()

    -- Pets live only in EquipmentService's `equipe.pet` (there is no `pet` key in
    -- PlayerInventory.equipped - see EQUIP_SLOT_SET note). EquipmentService.unequip
    -- already knows the "pet" slot and re-adds the instance to the bag.
    if slot == "pet" then
        local equipped = EquipmentService.getEquipped(player)
        if not (equipped and equipped.pet) then
            return true, nil -- no-op: no pet equipped
        end
        local ok, err = EquipmentService.unequip(player, "pet")
        if not ok then
            return false, err
        end
        PlayerDataService.markDirty(player, profile)
        logAction(player, "unequipped pet")
        return true, nil
    end

    if inv.equipped[slot] == nil then
        return true, nil -- no-op: nothing equipped
    end

    local ok, err = EquipmentService.unequip(player, slot)
    if not ok then
        return false, err
    end

    -- EquipmentService.unequip already re-added the item to inv.items (via
    -- its own call into InventoryService.addItem, minting a NEW itemKey -
    -- see implementation notes on itemKey identity not surviving
    -- equip/unequip in the current EquipmentService bridge). Clear the
    -- denormalized index; there is nothing to clean up under the OLD key
    -- since it never existed in `items` while equipped.
    inv.equipped[slot] = nil
    PlayerDataService.markDirty(player, profile)
    logAction(player, "unequipped %s", slot)
    return true, nil
end

--[[
    Resolves a pending bag-full prompt (opened by addItem when the bag was
    full). `choice` is:
      "keep_new"  - remove `targetItemKey` from the bag, then add the new item
      "keep_old"  - discard the new item, bag untouched
      "drop_both" - remove `targetItemKey` AND discard the new item
    Returns (ok, reason?). Validates `targetItemKey` (when required) BEFORE
    closing the prompt window, so a bad target (typo, already-removed item,
    locked item) does not burn the player's one response - they can retry
    with a corrected key until the 30s timer expires.
]]
function InventoryService.confirmFullBagAction(player: Player, choice: string, targetItemKey: string?): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end
    if choice ~= "keep_new" and choice ~= "keep_old" and choice ~= "drop_both" then
        return false, "invalid_argument"
    end

    local pending = pendingFullBag[player]
    if not pending then
        return false, "no_pending_action"
    end

    local profile, inv = getInventoryFor(player)
    if not profile or not inv then
        return false, "no_profile"
    end

    local target: Types.ItemInstance? = nil
    if choice == "keep_new" or choice == "drop_both" then
        if not isValidItemKey(targetItemKey) then
            return false, "invalid_argument"
        end
        target = inv.items[targetItemKey :: string]
        if not target then
            return false, "item_not_found"
        end
        if target.locked then
            return false, "item_locked"
        end
    end

    -- Validation passed - close the prompt window (spec §6: one response per
    -- open window) and cancel the auto-discard timer.
    pendingFullBag[player] = nil
    if pending.thread then
        task.cancel(pending.thread)
    end

    local resolved: string
    if choice == "keep_old" then
        resolved = "discarded_new"
    elseif choice == "drop_both" then
        inv.items[targetItemKey :: string] = nil
        resolved = "dropped_both"
    else -- "keep_new"
        inv.items[targetItemKey :: string] = nil
        local itemKey = mintItemKey(inv, pending.instance.id)
        inv.items[itemKey] = pending.instance
        resolved = "kept_new"
    end

    -- Informal QA/logging field, not part of the declared PlayerData schema
    -- (PlayerDataService.defaultProfile does not predeclare it) - safe to
    -- attach directly since profile is a plain Lua table and DataStore
    -- serializes whatever is present. Flagged for the schema owner to
    -- formalize if this needs to be queryable long-term.
    profile.lastBagAction = {
        choice = choice,
        targetItemKey = targetItemKey,
        newItemId = pending.instance.id,
        resolved = resolved,
        at = os.time(),
    }

    PlayerDataService.markDirty(player, profile)
    logAction(player, "confirmFullBagAction choice=%s -> %s", choice, resolved)
    return true, nil
end

--[[
    Sets the inventory filter: `rarity` is a floor (EquipmentConfig.Rarities
    id, e.g. "rare", or "all" for no floor) and `voie` is "guerrier" | "mage"
    | "all" (maps onto the existing profile.filtres.{guerrier,mage} boolean
    pair). Returns (ok, reason?).
]]
function InventoryService.setFilters(player: Player, rarity: string, voie: string): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end
    if type(rarity) ~= "string" or type(voie) ~= "string" then
        return false, "invalid_argument"
    end

    local rarityOk = (rarity == "all") or (EquipmentConfig.getRarity(rarity) ~= nil)
    if not rarityOk then
        return false, "invalid_filter"
    end
    if not VOIE_FILTER_VALUES[voie] then
        return false, "invalid_filter"
    end

    local profile = PlayerDataService.getProfile(player)
    if not profile then
        return false, "no_profile"
    end

    profile.filtres = (type(profile.filtres) == "table") and profile.filtres or {}
    profile.filtres.rareteMin = (rarity == "all") and "commun" or rarity
    if voie == "guerrier" then
        profile.filtres.guerrier, profile.filtres.mage = true, false
    elseif voie == "mage" then
        profile.filtres.guerrier, profile.filtres.mage = false, true
    else -- "all" / "tous"
        profile.filtres.guerrier, profile.filtres.mage = true, true
    end

    PlayerDataService.markDirty(player, profile)
    return true, nil
end

--[[
    Toggles the quick-sell lock on `itemKey`. Returns (ok, reason?).

    Known limitation: only bag items carry a `locked` flag. An item currently
    equipped is not present in `inv.items` (see equipItem) and its lossy copy
    in EquipmentService's `equipe` table has no `locked` field at all, so
    toggling lock on a currently-equipped item's key returns "item_not_found"
    rather than flipping a flag. Fixing this needs EquipmentService's equip
    bridge to preserve the full ItemInstance (out of this module's scope -
    flagged in the implementation notes).
]]
function InventoryService.toggleLock(player: Player, itemKey: string): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end
    if not isValidItemKey(itemKey) then
        return false, "invalid_argument"
    end

    local profile, inv = getInventoryFor(player)
    if not profile or not inv then
        return false, "no_profile"
    end

    local item = inv.items[itemKey]
    if not item then
        return false, "item_not_found"
    end

    item.locked = not item.locked
    PlayerDataService.markDirty(player, profile)
    return true, nil
end

--[[
    Clears any per-player state this module owns (pending bag-full prompt +
    its timer). Not currently called by anyone - CombatServer's
    PlayerRemoving handler calls EquipmentService.release(player) but has no
    matching InventoryService.release(player) call yet. Flagged in the
    implementation notes as a small follow-up wiring gap (this module cannot
    add that call itself without editing CombatServer.server.luau, out of
    scope here). The 30s auto-discard timer is self-defensive in the
    meantime (see startFullBagTimer), so the worst case without this being
    wired up is a small per-player table entry lingering until the timer
    fires or the server restarts - not a correctness bug, just a minor
    hygiene gap.
]]
--[[
    One-time creation gift: mints the "Épée en bois" into the bag. Called by
    FtueService.onFirstKill (the tutorial hands the player their first weapon
    after the bare-handed first kill, then teaches them to equip it).

    `autoEquip` (default false): when true, also equips the weapon right away -
    kept for any non-FTUE caller that wants a ready-to-fight hero.

    Idempotent and self-guarding:
      * no-op if profile.starterKitGranted is already true
      * no-op if the bag is non-empty or a weapon is already equipped (an
        existing player who has played is never retro-granted, even though
        migrate() backfills starterKitGranted = false on their profile)
    Sets profile.starterKitGranted = true either way, so it runs at most once.
]]
function InventoryService.grantStarterKit(player: Player, autoEquip: boolean?): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end

    local profile, inv = getInventoryFor(player)
    if not profile or not inv then
        return false, "no_profile"
    end

    -- "Already owns a weapon" is judged on the WEAPON only (equipped, or
    -- sitting in the bag) - never "the bag isn't empty". The old check used
    -- countItems(inv) > 0, which silently ate the starter weapon grant the
    -- moment ANYTHING else landed in the bag first (e.g. a Daily Reward
    -- pet/armor claimed before the FTUE's first kill) - production bug:
    -- player permanently stuck with no weapon, unable to play. Non-weapon
    -- gear must never block the one grant that matters.
    local hasWeaponEquipped = inv.equipped and inv.equipped.arme ~= nil
    local hasWeaponInBag = false
    for _, item in pairs(inv.items) do
        if item.itemType == "weapon" then
            hasWeaponInBag = true
            break
        end
    end

    if profile.starterKitGranted then
        if hasWeaponEquipped or hasWeaponInBag then
            return true, nil
        end
        -- Repair path: a profile the bug above already hit (flag set, weapon
        -- never actually granted). Fall through and grant it now instead of
        -- leaving the player permanently weaponless.
    elseif hasWeaponEquipped or hasWeaponInBag then
        -- Player already owns a weapon (pre-existing save): just flag it.
        profile.starterKitGranted = true
        PlayerDataService.markDirty(player, profile)
        return true, nil
    end

    -- Tier-1 weapon type = the voie picked at hero creation (master-gdd SS5.2).
    -- Falls back to the sword for a profile with no voie (pre-v5 / creation skipped).
    local weaponId = GameConfig.Hero.starterWeaponByVoie[profile.voie or ""] or STARTER_WEAPON_ID

    local added = InventoryService.addItem(player, {
        id = weaponId, rarete = "commun", zone = 1,
    })
    if added and autoEquip then
        for key, item in pairs(inv.items) do
            if item.id == weaponId and item.equippedSlot == nil then
                InventoryService.equipItem(player, key)
                break
            end
        end
    end

    profile.starterKitGranted = true
    PlayerDataService.markDirty(player, profile)
    logAction(player, "granted starter weapon (%s, autoEquip=%s)", weaponId, tostring(autoEquip == true))
    return true, nil
end

--[[
    FTUE egg pick: mints the starter pet for `role` (dps/tank/heal ->
    EquipmentConfig.StarterPetByRole) into the bag and equips it, so the buff is
    active immediately. Idempotent: no-op if the player already owns any starter
    pet. Called by FtueService.choosePet (and its end-of-tutorial safety net).
]]
function InventoryService.grantStarterPet(player: Player, role: string?): (boolean, string?)
    if not isValidPlayer(player) then
        return false, "invalid_argument"
    end

    local petId = (type(role) == "string" and EquipmentConfig.StarterPetByRole[role]) or STARTER_PET_ID

    local profile, inv = getInventoryFor(player)
    if not profile or not inv then
        return false, "no_profile"
    end

    -- Idempotent: bail if the player already owns ANY starter pet (bag or equipped).
    for _, item in pairs(inv.items) do
        local def, category = EquipmentConfig.getItem(item.id)
        if category == "pet" and def and def.isStarter then
            return true, nil
        end
    end
    local added = InventoryService.addItem(player, {
        id = petId, rarete = "commun", zone = 1, sourceLevel = 1, petLevel = 1,
    })
    if added then
        for key, item in pairs(inv.items) do
            if item.id == petId and item.equippedSlot == nil then
                InventoryService.equipItem(player, key)  -- pet branch routes to EquipmentService "pet" slot
                break
            end
        end
    end

    PlayerDataService.markDirty(player, profile)
    logAction(player, "granted starter pet (%s)", petId)
    return true, nil
end

function InventoryService.release(player: Player)
    local pending = pendingFullBag[player]
    if pending then
        if pending.thread then
            task.cancel(pending.thread)
        end
        pendingFullBag[player] = nil
    end
end

return InventoryService
