--==============================================================
-- EquipmentService  (ModuleScript - ServerScriptService)
-- Per-player EQUIP SLOTS only (the 6 `equipe` slots) + the pure stat-bonus /
-- pet-effect read helpers. Bag storage/mutation moved to InventoryService
-- (Inventory Sprint Day 1, design/specs/inventory-implementation-spec.md §9:
-- "EquipmentService's role narrows... it becomes the definitions/config
-- lookup layer plus the pure stat-bonus calculator; InventoryService becomes
-- the sole owner of slot mutation and persistence").
--
-- The per-player state is exactly the `equipe` sub-table from
-- GAME_SPEC.md section 11, so a future ProfileStore layer can persist
-- it without reshaping.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipmentConfig = require(ReplicatedStorage:WaitForChild("EquipmentConfig"))
local GameConfig      = require(ReplicatedStorage:WaitForChild("GameConfig"))

-- One-directional dependency (sprint risk register #2): InventoryService
-- never requires EquipmentService. equip()/unequip() are the only functions
-- here that call into it, to move an item between the bag and a slot.
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))

local EquipmentService = {}

-- [player] = {
--   equipe = { arme, casque, plastron, jambieres, bottes, pet },  -- equipped instances
-- }
-- Slot instance shape (Inventory Sprint Day 3 fix - see wiki/concepts +
-- production/bugs for the "itemKey/forgeLevel lost on equip" report): each
-- populated slot holds the FULL Types.ItemInstance that was equipped (id,
-- itemType, rarity, voie, baseStats, forgeLevel, droppedAtKm, droppedAtTime,
-- setId, locked, equippedSlot), PLUS an `itemKey` field so callers can still
-- identify which bag key it came from. This replaced the older lossy
-- { id, voie|role, rarete, zone, itemKey? } shape, which reset forgeLevel/
-- setId/locked to their defaults every time an item passed through a slot.
-- `EquipmentService.restore` still accepts the old shape for saves written
-- before this fix (detected by the absence of a `rarity` field) and
-- degrades it gracefully - see the restore()-only legacy conversion below.
local track = {}

local SLOT_SET = {}
for _, s in ipairs(EquipmentConfig.SLOTS) do
    SLOT_SET[s] = true
end

local ROLE_LABELS = { dps = "DPS", tank = "Tank", heal = "Heal" }

local function emptyLoadout()
    return {
        arme = nil,
        casque = nil,
        plastron = nil,
        jambieres = nil,
        bottes = nil,
        pet = nil,
    }
end

local function rarityLabel(id)
    local r = EquipmentConfig.getRarity(id)
    return r and r.label or tostring(id)
end

--===== Lifecycle =====
function EquipmentService.init(player)
    track[player] = {
        equipe = emptyLoadout(),
    }
end

function EquipmentService.release(player)
    track[player] = nil
end

--===== Slot access (read-only) =====
-- Read-only view of the 6 slots (entries may be nil).
function EquipmentService.getEquipped(player)
    local t = track[player]
    return t and t.equipe or nil
end

-- Best-effort ItemInstance reconstruction from a LEGACY `equipe` slot entry
-- ({ id, voie|role, rarete, zone, itemKey? }), for EquipmentService.restore
-- upgrading a save written before the Day 3 full-ItemInstance fix. Lossy:
-- the legacy shape never retained forgeLevel/setId/locked, so those default.
-- Not used by equip()/unequip() any more - both now carry the real
-- ItemInstance through, so nothing is lost on freshly-written saves.
local function instanceFromLegacyEquipeEntry(slot, inst)
    local slotDef = (slot ~= "pet") and EquipmentConfig.getItem(inst.id)
    return {
        id = inst.id,
        itemType = (slot == "pet") and "pet" or (slotDef and slotDef.slot) or slot,
        rarity = inst.rarete,
        voie = inst.voie,
        baseStats = {},
        forgeLevel = 0,
        droppedAtKm = inst.zone or 1,
        droppedAtTime = os.time(),
        setId = nil,
        locked = false,
        equippedSlot = (slot ~= "pet") and slot or nil,
        itemKey = inst.itemKey,
    }
end

-- Equip `itemKey` (an InventoryService-owned bag item) into `slot`. The item
-- is looked up + removed from the bag via InventoryService; EquipmentService
-- only owns the 6-slot `equipe` state and the pure stat-bonus math below.
-- Weapon changes are refused mid-combat via player:GetAttribute("InCombat")
-- - NOTE: nothing currently sets this attribute (CombatServer's combat state
-- is a private per-player table, not yet exposed as an attribute), so this
-- gate is structurally present but inert until that wiring lands. Flagging
-- rather than silently pretending it's live.
-- Returns (ok: boolean, err: string?).
function EquipmentService.equip(player: Player, slot: string, itemKey: string): (boolean, string?)
    local t = track[player]
    if not t then
        return false, "no loadout"
    end
    if type(slot) ~= "string" or not SLOT_SET[slot] then
        return false, "invalid slot"
    end
    if type(itemKey) ~= "string" then
        return false, "invalid itemKey"
    end
    if slot == "arme" and player:GetAttribute("InCombat") == true then
        return false, "in_combat"
    end

    -- Fetch the live inventory ONCE, up front. This (a) hands us the new
    -- item's full ItemInstance BEFORE it is removed from the bag (bug fix:
    -- the old code removed the item first, then re-fetched it - which
    -- worked for the new item, but the OLD equipped item's re-add used a
    -- separately-reconstructed lossy draft), and (b) lets us pre-check bag
    -- capacity for the swap-out below, since `itemKey` is still counted in
    -- `inventory.items` at this point - the same count
    -- InventoryService.equipItem's own "displaced" guard would see.
    local listOk, inventory = pcall(InventoryService.getInventory, player)
    if not listOk or not inventory then
        return false, "inventory unavailable"
    end
    local newInstance = inventory.items and inventory.items[itemKey]
    if not newInstance then
        return false, "item_not_found"
    end

    -- Bag-full pre-check. Mirrors InventoryService.equipItem's "displaced"
    -- guard - duplicated here because InventoryService.equipItem's pet
    -- branch calls straight into EquipmentService.equip WITHOUT going
    -- through that guard, and this function is the one that actually
    -- performs the bag swap. If the target slot is occupied and the bag has
    -- no free slot for the item being swapped out, reject up front instead
    -- of removing the new item and then silently dropping the old one when
    -- InventoryService.addItem fails below (the bug this fixes).
    local current = t.equipe[slot]
    if current then
        local capacity = inventory.capacity or GameConfig.Inventory.baseCapacity
        local count = 0
        for _ in pairs(inventory.items) do
            count += 1
        end
        if count >= capacity then
            return false, "bag_full"
        end
    end

    -- Pull the new item out of the bag now that the swap is known to fit.
    local removeOk, removed, removeErr = pcall(InventoryService.removeItem, player, itemKey)
    if not removeOk or not removed then
        return false, removeOk and removeErr or "inventory unavailable"
    end

    if current then
        -- `current` is already a full ItemInstance (forgeLevel/baseStats/
        -- setId/locked included, per the Day 3 schema fix) - hand it back to
        -- the bag as-is instead of reconstructing a lossy draft.
        current.equippedSlot = nil
        local addOk, added, addErr = pcall(InventoryService.addItem, player, current, true)
        if not addOk or not added then
            -- Should not happen after the capacity pre-check above, but if
            -- it does, put the new item back so the player loses neither.
            -- newInstance is also a previously-owned bag item (it may already
            -- carry a nonzero forgeLevel from Forge), not a new drop, so it
            -- gets the same isFromEquipSlot flag.
            pcall(InventoryService.addItem, player, newInstance, true)
            return false, addOk and addErr or "inventory unavailable"
        end
    end

    newInstance.equippedSlot = (slot ~= "pet") and slot or nil
    newInstance.itemKey = itemKey
    t.equipe[slot] = newInstance
    return true
end

-- Empty a slot; the item returns to the bag via InventoryService.addItem.
-- Returns (ok, err?).
function EquipmentService.unequip(player: Player, slot: string): (boolean, string?)
    local t = track[player]
    if not t then return false, "no loadout" end
    if type(slot) ~= "string" or not SLOT_SET[slot] then return false, "invalid slot" end
    local current = t.equipe[slot]
    if not current then
        return true  -- no-op: nothing equipped
    end

    -- `current` already holds the full ItemInstance (forgeLevel/baseStats/
    -- setId/locked intact) - hand it straight back to the bag instead of
    -- reconstructing a lossy draft. InventoryService.addItem mints a fresh
    -- itemKey, same as before this fix.
    current.equippedSlot = nil
    local addOk, added, addErr = pcall(InventoryService.addItem, player, current, true)
    if not addOk or not added then
        current.equippedSlot = (slot ~= "pet") and slot or nil  -- restore on failure
        return false, addOk and addErr or "inventory unavailable"
    end
    t.equipe[slot] = nil
    return true
end

--===== Pure read helpers (unchanged - source is `equipe`, not the bag) =====
-- Etape 4.0 validated model. Returns:
--   weaponPct   : multiplicative ATK bonus (0.08 = +8%), 0 if no weapon
--   damageType  : "physical" | "magic" - the equipped weapon's voie
--   armorDef    : flat DEF summed over equipped guerrier armor pieces
--   armorRes    : flat RES summed over equipped mage armor pieces
--   armorPieces : number of equipped armor pieces (drives the +HP% bonus)
-- All item power is DERIVED from (zone, rarity) via GameConfig.Equipment.
-- Consumed by StatsService.recalc.
function EquipmentService.getStatBonuses(player)
    local totals = {
        weaponPct = 0, damageType = "physical",
        armorDef = 0, armorRes = 0, armorPieces = 0,
        setDamagePct = 0, setHpPct = 0, setSpeedPct = 0, setPieces = 0, setName = nil,
    }
    local t = track[player]
    if not t then
        return totals
    end
    local EQ = GameConfig.Equipment

    local arme = t.equipe.arme
    if arme then
        local wdef = EquipmentConfig.getItem(arme.id)
        local r = EquipmentConfig.getRarity(arme.rarity)
        if wdef and r and r.active then
            totals.weaponPct  = EQ.weaponPct(arme.droppedAtKm or 1, r.mult) * EquipmentConfig.weaponPowerMult(arme.id)
            totals.damageType = (wdef.voie == "mage") and "magic" or "physical"
        end
    end

    local setCounts = {}   -- ["<set>|<voie>"] = count, for the set-bonus check
    for _, slot in ipairs(EquipmentConfig.ARMOR_SLOTS) do
        local inst = t.equipe[slot]
        if inst then
            local adef = EquipmentConfig.getItem(inst.id)
            local r = EquipmentConfig.getRarity(inst.rarity)
            if adef and r and r.active then
                totals.armorPieces += 1
                local val = EQ.armorStat(inst.droppedAtKm or 1, r.mult)
                if adef.voie == "mage" then
                    totals.armorRes += val
                else
                    totals.armorDef += val
                end
                if adef.set then
                    local key = adef.set .. "|" .. tostring(adef.voie)
                    setCounts[key] = (setCounts[key] or 0) + 1
                end
            end
        end
    end

    -- Best matching set (same set + same voie). GAME_SPEC.md 5.1: a 2+2 split
    -- triggers nothing, so the bonus group must be a STRICT plurality - a tie
    -- for the top count means no bonus.
    local bestKey, bestCount, tie = nil, 0, false
    for key, c in pairs(setCounts) do
        if c > bestCount then
            bestKey, bestCount, tie = key, c, false
        elseif c == bestCount then
            tie = true
        end
    end
    local bestSetId = bestKey and bestKey:match("^(.-)|") or nil
    local sb = (not tie) and EquipmentConfig.getSetBonus(bestCount, bestSetId) or nil
    if sb then
        totals.setDamagePct = sb.damage
        totals.setHpPct     = sb.hp
        totals.setSpeedPct   = sb.speed
        totals.setPieces    = bestCount
        totals.setName      = bestKey and bestKey:match("^(.-)|") or nil
    end

    return totals
end

-- Etape 4.2 pet effect. Returns nil (no pet) or a PASSIVE effect table:
--   { role, dpsPct? , hpPct? , defFlat? , healPct? }
-- Magnitude = GameConfig.Pets base * zoneScaling^(zone-1) * rarityMult.
-- Consumed by StatsService.recalc (dps / tank) and CombatServer's campfire
-- regen loop (heal). Passive only - never spawns an attacker or a timer.
function EquipmentService.getPetEffect(player)
    local t = track[player]
    if not t or not t.equipe.pet then
        return nil
    end
    local inst = t.equipe.pet
    local r = EquipmentConfig.getRarity(inst.rarity)
    if not r or not r.active then
        return nil
    end
    -- Pets carry no `role` field on the ItemInstance itself (Types.luau) -
    -- it is a property of the pet DEFINITION, looked up by id.
    local def = EquipmentConfig.getItem(inst.id)
    local role = def and def.role
    local eff = GameConfig.Pets.effect(role, inst.sourceLevel or 1, inst.petLevel or 1, inst.rarity, r.mult)
    -- FTUE starter pets are deliberately weak: half a looted pet of the same
    -- tier. Only the scalable magnitude keys are touched (never healTickSec etc).
    if def and def.isStarter then
        local m = EquipmentConfig.StarterPetPowerMult or 1
        for k in pairs(GameConfig.Pets.SCALABLE_KEYS) do
            if type(eff[k]) == "number" then
                eff[k] = eff[k] * m
            end
        end
    end
    eff.role = role
    return eff
end

-- Pure read: the equipped pet's role ("dps" | "tank" | "heal") or nil when no
-- pet is equipped. Used ONLY to pick the pet sprite client-side - enters no
-- effect / stat / gameplay math (unlike getPetEffect, it ignores rarity.active).
function EquipmentService.getPetSpriteRole(player: Player): string?
    local t = track[player]
    local inst = t and t.equipe and t.equipe.pet
    if not inst then
        return nil
    end
    local def = EquipmentConfig.getItem(inst.id)
    return def and def.role or nil
end

--===== HUD description strings =====
-- "<nom> · <rarete>" for arme, "<nom> · <role> · <rarete>" for pet, "-" empty.
function EquipmentService.describeSlot(player, slot)
    local t = track[player]
    if not t then
        return "—"
    end
    local inst = t.equipe[slot]
    if not inst then
        return "—"
    end
    local def = EquipmentConfig.getItem(inst.id)
    local nom = (def and def.nom) or inst.id
    if slot == "pet" then
        local role = def and def.role
        local roleLabel = ROLE_LABELS[role] or tostring(role)
        return string.format("%s · %s · %s", nom, roleLabel, rarityLabel(inst.rarity))
    end
    return string.format("%s · %s", nom, rarityLabel(inst.rarity))
end

-- Section 1.1: "nom du set dominant, ou Mixte", + active set-bonus tier.
function EquipmentService.describeArmorSummary(player)
    local t = track[player]
    if not t then
        return "—"
    end
    local total = 0
    for _, slot in ipairs(EquipmentConfig.ARMOR_SLOTS) do
        if t.equipe[slot] then total = total + 1 end
    end
    if total == 0 then
        return "—"
    end

    -- The mechanically-active set + voie (strict plurality), from getStatBonuses.
    local b = EquipmentService.getStatBonuses(player)
    if b.setPieces >= 2 and b.setName then
        local setNom = (EquipmentConfig.Sets[b.setName] and EquipmentConfig.Sets[b.setName].nom) or b.setName
        return string.format("%s %d/4 (+%d%% dgt)", setNom, b.setPieces, math.floor(b.setDamagePct * 100))
    end

    -- No active bonus: name the dominant set (set only), or "Mixte".
    local counts, distinct, domId, domCount = {}, 0, nil, 0
    for _, slot in ipairs(EquipmentConfig.ARMOR_SLOTS) do
        local inst = t.equipe[slot]
        if inst then
            local def = EquipmentConfig.getItem(inst.id)
            local setId = (def and def.set) or "?"
            if not counts[setId] then distinct += 1 end
            counts[setId] = (counts[setId] or 0) + 1
            if counts[setId] > domCount then domId, domCount = setId, counts[setId] end
        end
    end
    if distinct > 1 then
        return string.format("Mixte %d/4", total)
    end
    local setNom = (EquipmentConfig.Sets[domId] and EquipmentConfig.Sets[domId].nom) or tostring(domId)
    return string.format("%s %d/4", setNom, domCount)
end

--===== Persistence (GAME_SPEC.md 11) - equipe only, bag lives in profile.inventory =====
function EquipmentService.serialize(player)
    local t = track[player]
    if not t then
        return { equipe = {} }
    end
    local equipe = {}
    for slot, inst in pairs(t.equipe) do
        equipe[slot] = inst
    end
    return { equipe = equipe }
end

function EquipmentService.restore(player, data)
    EquipmentService.init(player)
    if type(data) ~= "table" then return end
    local t = track[player]
    if type(data.equipe) ~= "table" then return end
    for _, slot in ipairs(EquipmentConfig.SLOTS) do
        local inst = data.equipe[slot]
        if type(inst) == "table" and type(inst.id) == "string" then
            if inst.rarity ~= nil then
                -- Day 3+ schema: already a full ItemInstance (+ itemKey) -
                -- PlayerDataService.migrateInventoryV1toV2 deliberately never
                -- touches `profile.equipe`, so no separate migration step is
                -- needed here beyond this shape check.
                t.equipe[slot] = inst
            else
                -- Legacy save (pre-Day-3 lossy shape: { id, voie|role,
                -- rarete, zone, itemKey? }) - upgrade in place. forgeLevel/
                -- setId/locked were never recorded by the old shape, so they
                -- default; that is the best this data can offer.
                t.equipe[slot] = instanceFromLegacyEquipeEntry(slot, inst)
            end
        end
    end
end

-- exposed for tests / debugging only
EquipmentService._track = track

return EquipmentService
