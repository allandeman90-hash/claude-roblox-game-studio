--==============================================================
-- EquipmentService  (ModuleScript - ServerScriptService)
-- Per-player equipment slots: data + slot management ONLY.
--
-- This lot deliberately does NOT modify combat. getStatBonuses and
-- getPetEffect are pure read helpers that nothing consumes yet - the
-- combat integration (DEF/RES, ATK bonus, pet effects) is the next lot
-- and depends on resolving the section 3 damage formula first.
--
-- The per-player state is exactly the `equipe` sub-table from
-- GAME_SPEC.md section 11, so a future ProfileStore layer can persist
-- it without reshaping.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipmentConfig = require(ReplicatedStorage:WaitForChild("EquipmentConfig"))
local GameConfig      = require(ReplicatedStorage:WaitForChild("GameConfig"))

local EquipmentService = {}

-- [player] = {
--   equipe    = { arme, casque, plastron, jambieres, bottes, pet },  -- equipped instances
--   inventory = { [key] = count },   -- GAME_SPEC.md 10: quantitied stacks (max 100 keys)
--   locked    = { [key] = true },    -- protected from quick-sell
--   filters   = { rareteMin, guerrier, mage },  -- auto-pickup filter
-- }
-- Item key = "id|rarete|zone". Instance shape { id, voie|role, rarete, zone }.
local track = {}

local INVENTORY_MAX = 100   -- distinct stacks (GAME_SPEC.md 10)

-- Fusion recipe (GAME_SPEC.md 5.2): N of a rarity -> 1 of the next.
local RARITY_ORDER = { "commun", "rare", "epique", "legendaire", "mythique" }
local RARITY_INDEX = {}
for i, id in ipairs(RARITY_ORDER) do RARITY_INDEX[id] = i end
local FUSE_COUNT = { commun = 3, rare = 4, epique = 5, legendaire = 6 }  -- mythique = top, no fuse

local function ownKey(itemId, rarete, zone)
    return itemId .. "|" .. tostring(rarete) .. "|" .. tostring(math.max(1, math.floor(tonumber(zone) or 1)))
end

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
        inventory = {},
        locked = {},
        filters = { rareteMin = "commun", guerrier = true, mage = true },
    }
end

function EquipmentService.release(player)
    track[player] = nil
end

-- Parse "id|rarete|zone" back into parts.
local function parseKey(key)
    local id, rarete, zone = key:match("^(.-)|(.-)|(.-)$")
    return id, rarete, tonumber(zone) or 1
end

local function countKeys(inv)
    local n = 0
    for _ in pairs(inv) do n += 1 end
    return n
end

--===== Inventory (GAME_SPEC.md 10) =====
function EquipmentService.getFilters(player)
    local t = track[player]
    return t and t.filters or { rareteMin = "commun", guerrier = true, mage = true }
end

function EquipmentService.setFilters(player, patch)
    local t = track[player]
    if not t or type(patch) ~= "table" then return end
    if patch.rareteMin and RARITY_INDEX[patch.rareteMin] then t.filters.rareteMin = patch.rareteMin end
    if type(patch.guerrier) == "boolean" then t.filters.guerrier = patch.guerrier end
    if type(patch.mage) == "boolean" then t.filters.mage = patch.mage end
end

-- Should an auto-picked-up loot item be kept? (shop / fusion / equip-return bypass this.)
function EquipmentService.passesFilter(player, itemId, rarete)
    local t = track[player]
    if not t then return true end
    local f = t.filters
    if (RARITY_INDEX[rarete] or 1) < (RARITY_INDEX[f.rareteMin] or 1) then
        return false
    end
    local def, category = EquipmentConfig.getItem(itemId)
    if def and category ~= "pet" then
        if def.voie == "guerrier" and not f.guerrier then return false end
        if def.voie == "mage" and not f.mage then return false end
    end
    return true
end

-- Add one item to the inventory. `source` = "loot" (filter applies) | anything else
-- (bypass filter). Returns (ok, reason):
--   "filtered"        - the auto-pickup filter rejected it
--   "inventory full"  - 100 distinct stacks and this is a new one
function EquipmentService.addItem(player, item, source)
    local t = track[player]
    if not t then return false, "no loadout" end
    local id = item.id
    local rarete = item.rarete
    local zone = item.zone
    if type(id) ~= "string" or not EquipmentConfig.getItem(id) then return false, "unknown item" end
    if not (EquipmentConfig.getRarity(rarete)) then return false, "invalid rarity" end

    if source == "loot" and not EquipmentService.passesFilter(player, id, rarete) then
        return false, "filtered"
    end
    local key = ownKey(id, rarete, zone)
    if not t.inventory[key] and countKeys(t.inventory) >= INVENTORY_MAX then
        return false, "inventory full"
    end
    t.inventory[key] = (t.inventory[key] or 0) + 1
    return true
end

local function removeItems(t, key, n)
    local have = t.inventory[key] or 0
    if have < n then return false end
    if have == n then t.inventory[key] = nil else t.inventory[key] = have - n end
    return true
end

function EquipmentService.count(player, itemId, rarete, zone)
    local t = track[player]
    return t and (t.inventory[ownKey(itemId, rarete, zone)] or 0) or 0
end

-- Backward-compatible alias used by older callers (shop, tests): puts one copy
-- in the inventory, bypassing the filter.
function EquipmentService.grantOwnership(player, itemId, rarete, zone)
    return EquipmentService.addItem(player, { id = itemId, rarete = rarete, zone = zone }, "grant")
end

function EquipmentService.ownsItem(player, itemId, rarete, zone)
    return EquipmentService.count(player, itemId, rarete, zone) > 0
end

--===== Fusion (GAME_SPEC.md 5.2) =====
-- N same-item copies of one rarity -> 1 copy of the next. Strict: exact id+zone.
-- Returns (ok, reason, newRarete).
function EquipmentService.fuse(player, itemId, rarete, zone)
    local t = track[player]
    if not t then return false, "no loadout" end
    local need = FUSE_COUNT[rarete]
    if not need then return false, "cannot fuse this rarity" end
    local key = ownKey(itemId, rarete, zone)
    if (t.inventory[key] or 0) < need then
        return false, ("need %d"):format(need)
    end
    local nextRarete = RARITY_ORDER[(RARITY_INDEX[rarete] or 1) + 1]
    if not nextRarete or not EquipmentConfig.getRarity(nextRarete) then
        return false, "no higher rarity"
    end
    removeItems(t, key, need)
    t.inventory[ownKey(itemId, nextRarete, zone)] = (t.inventory[ownKey(itemId, nextRarete, zone)] or 0) + 1
    return true, nil, nextRarete
end

--===== Lock / sell =====
function EquipmentService.toggleLock(player, itemId, rarete, zone)
    local t = track[player]
    if not t then return end
    local key = ownKey(itemId, rarete, zone)
    t.locked[key] = (not t.locked[key]) or nil
    return t.locked[key] == true
end

-- Remove every unlocked, unequipped stack strictly below `maxRarete`.
-- Returns the list of removed { id, rarete, zone, count } so the caller can pay gold.
function EquipmentService.sellBelow(player, maxRarete)
    local t = track[player]
    if not t then return {} end
    local cap = RARITY_INDEX[maxRarete] or 1
    local removed = {}
    for key, cnt in pairs(t.inventory) do
        local id, rarete, zone = parseKey(key)
        if not t.locked[key] and (RARITY_INDEX[rarete] or 1) < cap then
            removed[#removed + 1] = { id = id, rarete = rarete, zone = zone, count = cnt }
            t.inventory[key] = nil
        end
    end
    return removed
end

-- Inventory stacks that fit `slot`, strongest first. Each entry:
--   { id, nom, voie|role, rarete, rareteLabel, zone, slot, power, count,
--     equipped, locked, fuseReady }
function EquipmentService.listInventoryForSlot(player, slot)
    local t = track[player]
    if not t then return {} end
    local EQ = GameConfig.Equipment
    local equippedInst = t.equipe[slot]
    local list = {}
    for key, cnt in pairs(t.inventory) do
        local id, rarete, zone = parseKey(key)
        local def, category = EquipmentConfig.getItem(id)
        if def then
            local fits = (category == "pet" and slot == "pet")
                or (category ~= "pet" and def.slot == slot)
            local r = EquipmentConfig.getRarity(rarete)
            if fits and r and r.active then
                local power
                if category == "pet" then
                    power = 0
                elseif slot == "arme" then
                    power = math.floor(EQ.weaponPct(zone, r.mult) * EquipmentConfig.weaponPowerMult(id) * 1000)
                else
                    power = EQ.armorStat(zone, r.mult)
                end
                list[#list + 1] = {
                    id = id, nom = def.nom or id,
                    voie = def.voie, role = def.role,
                    rarete = rarete, rareteLabel = r.label,
                    zone = zone, slot = slot, power = power, count = cnt,
                    equipped = (equippedInst ~= nil and equippedInst.id == id
                        and equippedInst.rarete == rarete and (equippedInst.zone or 1) == zone),
                    locked = t.locked[key] == true,
                    fuseReady = FUSE_COUNT[rarete] ~= nil and cnt >= FUSE_COUNT[rarete],
                }
            end
        end
    end
    table.sort(list, function(a, b)
        if a.zone ~= b.zone then return a.zone > b.zone end
        return (a.power or 0) > (b.power or 0)
    end)
    return list
end

-- kept as an alias so older call sites keep working
EquipmentService.listOwnedForSlot = EquipmentService.listInventoryForSlot

function EquipmentService.getInventorySummary(player)
    local t = track[player]
    if not t then return { used = 0, max = INVENTORY_MAX } end
    return { used = countKeys(t.inventory), max = INVENTORY_MAX }
end

--===== Slot access =====
-- Read-only view of the 6 slots (entries may be nil).
function EquipmentService.getEquipped(player)
    local t = track[player]
    return t and t.equipe or nil
end

-- Equip `itemId` at rarity `rarete` (and, for weapon / armor, `zone`) into `slot`.
-- Validation (section 4.1): no Lv gate, no voie gate.
-- Etape 4.0: weapon / armor require OWNERSHIP (grantOwnership, via shop / loot).
-- Etape 4.2: pets now carry a `zone` and ALSO require ownership. One pet slot,
-- so equipping a new pet replaces the previous (still owned).
-- Returns (ok: boolean, err: string?).
function EquipmentService.equip(player, slot, itemId, rarete, zone)
    local t = track[player]
    if not t then
        return false, "no loadout"
    end
    if type(slot) ~= "string" or not SLOT_SET[slot] then
        return false, "invalid slot"
    end
    if type(itemId) ~= "string" then
        return false, "invalid itemId"
    end

    local def, category = EquipmentConfig.getItem(itemId)
    if not def then
        return false, "unknown item"
    end

    local targetSlot = (category == "pet") and "pet" or def.slot
    if targetSlot ~= slot then
        return false, "item does not fit this slot"
    end

    local r = EquipmentConfig.getRarity(rarete)
    if not r or not r.active then
        return false, "invalid rarity"
    end

    local itemZone = math.max(1, math.floor(tonumber(zone) or 1))
    local key = ownKey(itemId, rarete, itemZone)
    local current = t.equipe[slot]
    local alreadyThis = current and current.id == itemId and current.rarete == rarete
        and (current.zone or 1) == itemZone
    if not alreadyThis and (t.inventory[key] or 0) < 1 then
        return false, "not owned"
    end

    if not alreadyThis then
        removeItems(t, key, 1)
        -- the previously equipped item goes back to the inventory
        if current then
            EquipmentService.addItem(player, {
                id = current.id, rarete = current.rarete, zone = current.zone or 1,
            }, "return")
        end
    end

    if category == "pet" then
        t.equipe[slot] = { id = itemId, role = def.role, rarete = rarete, zone = itemZone }
    else
        t.equipe[slot] = { id = itemId, voie = def.voie, rarete = rarete, zone = itemZone }
    end
    return true
end

-- Empty a slot; the item returns to the inventory. Returns (ok, err).
function EquipmentService.unequip(player, slot)
    local t = track[player]
    if not t then return false, "no loadout" end
    if not SLOT_SET[slot] then return false, "invalid slot" end
    local current = t.equipe[slot]
    if current then
        EquipmentService.addItem(player, {
            id = current.id, rarete = current.rarete, zone = current.zone or 1,
        }, "return")
    end
    t.equipe[slot] = nil
    return true
end

--===== Pure read helpers =====
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
        local r = EquipmentConfig.getRarity(arme.rarete)
        if wdef and r and r.active then
            totals.weaponPct  = EQ.weaponPct(arme.zone or 1, r.mult) * EquipmentConfig.weaponPowerMult(arme.id)
            totals.damageType = (wdef.voie == "mage") and "magic" or "physical"
        end
    end

    local setCounts = {}   -- ["<set>|<voie>"] = count, for the set-bonus check
    for _, slot in ipairs(EquipmentConfig.ARMOR_SLOTS) do
        local inst = t.equipe[slot]
        if inst then
            local adef = EquipmentConfig.getItem(inst.id)
            local r = EquipmentConfig.getRarity(inst.rarete)
            if adef and r and r.active then
                totals.armorPieces += 1
                local val = EQ.armorStat(inst.zone or 1, r.mult)
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
    local r = EquipmentConfig.getRarity(inst.rarete)
    if not r or not r.active then
        return nil
    end
    local eff = GameConfig.Pets.effect(inst.role, inst.zone or 1, r.mult)
    eff.role = inst.role
    return eff
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
        local role = ROLE_LABELS[inst.role] or tostring(inst.role)
        return string.format("%s · %s · %s", nom, role, rarityLabel(inst.rarete))
    end
    return string.format("%s · %s", nom, rarityLabel(inst.rarete))
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

--===== Persistence (GAME_SPEC.md 11) =====
function EquipmentService.serialize(player)
    local t = track[player]
    if not t then
        return { equipe = {}, inventory = {}, locked = {}, filters = { rareteMin = "commun", guerrier = true, mage = true } }
    end
    local equipe = {}
    for slot, inst in pairs(t.equipe) do
        equipe[slot] = inst
    end
    local inventory = {}
    for key, cnt in pairs(t.inventory) do inventory[key] = cnt end
    local locked = {}
    for key in pairs(t.locked) do locked[#locked + 1] = key end
    return {
        equipe = equipe,
        inventory = inventory,
        locked = locked,
        filters = { rareteMin = t.filters.rareteMin, guerrier = t.filters.guerrier, mage = t.filters.mage },
    }
end

function EquipmentService.restore(player, data)
    EquipmentService.init(player)
    if type(data) ~= "table" then return end
    local t = track[player]
    -- inventory: new {key=count} shape, or legacy `owned` array (each = 1 copy)
    if type(data.inventory) == "table" then
        for key, cnt in pairs(data.inventory) do
            if type(key) == "string" and type(cnt) == "number" and cnt > 0 then
                t.inventory[key] = math.floor(cnt)
            end
        end
    elseif type(data.owned) == "table" then
        for _, key in ipairs(data.owned) do
            if type(key) == "string" then t.inventory[key] = (t.inventory[key] or 0) + 1 end
        end
    end
    if type(data.locked) == "table" then
        for _, key in ipairs(data.locked) do
            if type(key) == "string" then t.locked[key] = true end
        end
    end
    if type(data.filters) == "table" then
        EquipmentService.setFilters(player, data.filters)
    end
    if type(data.equipe) == "table" then
        for _, slot in ipairs(EquipmentConfig.SLOTS) do
            local inst = data.equipe[slot]
            if type(inst) == "table" and type(inst.id) == "string" then
                t.equipe[slot] = {
                    id = inst.id, voie = inst.voie, role = inst.role,
                    rarete = inst.rarete, zone = inst.zone,
                }
            end
        end
    end
end

-- exposed for tests / debugging only
EquipmentService._track = track

return EquipmentService
