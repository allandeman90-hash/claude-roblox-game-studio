--==============================================================
-- LootService  (ModuleScript - ServerScriptService)
--
-- Equipment loot rolls (etape 4.1). Server-only, stateless except a
-- per-player max-zone high-water mark used to enforce "no drop above the
-- max zone reached".
--
-- Rules:
--   * normal kill: ~5% drop chance, random slot, STANDARD rarity
--   * boss kill (GAME_SPEC.md 6.3): ONE draw - 50% nothing (gold/XP only), else
--     a slot-weighted piece (bottes > jambieres > plastron > casque > arme),
--     STANDARD rarity (bosses are NOT rarity-biased; the difficulty curve is
--     what gates progression)
--   * the drop belongs to the CURRENT zone (clamped to max zone reached)
--   * random voie (guerrier / mage)
--   * caller grants OWNERSHIP - LootService never equips anything
--
-- Etape 4.2: pets also drop, via a SEPARATE independent roll (rollPetDrop) so
-- the equipment drop above is completely unchanged. Boss favored.
--
-- Does NOT touch combat, XP, stats, SPD, economy/prices, the shop or UI.
-- Uses EquipmentConfig (LootPool + Pets + Rarities).
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EquipmentConfig = require(ReplicatedStorage:WaitForChild("EquipmentConfig"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local LootService = {}

-- D5: drop rates + boss loot table are config-driven (EquipmentConfig.DropRates /
-- .BossLootTable). Locals kept as aliases so the rest of this module is unchanged.
local DR = EquipmentConfig.DropRates
local NORMAL_DROP_CHANCE = DR.normalGear

-- The loot / petLoot reward multiplier (RewardService, B5) scales the drop
-- CHANCE only - rarity weights are never touched. Clamped so a boss draw can
-- never become a guaranteed piece.
local function scaledChance(base: number, mult: number?): number
    return math.clamp(base * (mult or 1), 0, GameConfig.Rewards.dropRateCap)
end

-- Pet drop (etape 4.2): independent of the equipment roll. Rarer than gear.
local PET_NORMAL_CHANCE  = DR.normalPet
local PET_BOSS_CHANCE    = DR.bossPet
local PET_BIGBOSS_CHANCE = DR.bigBossPet   -- a big boss is an event

-- Boss equipment loot table (GAME_SPEC.md 6.3) - config-driven (D5).
local BOSS_SLOT_TABLE = EquipmentConfig.BossLootTable

-- Rarity draw weights (GAME_SPEC.md 4.3). Only `active` rarities count. Bosses
-- use the SAME table - no upward bias (GAME_SPEC.md 6.3).
local NORMAL_WEIGHTS = DR.rarityWeights

-- [player] = highest zone the player has actually reached (fed by CombatServer's
-- progression loop via noteZoneReached). Drops are clamped to this.
local maxZoneReached = {}

local function pickRarity(weights)
    weights = weights or NORMAL_WEIGHTS
    local total = 0
    local entries = {}
    for id, w in pairs(weights) do
        local r = EquipmentConfig.getRarity(id)
        if r and r.active then
            total += w
            entries[#entries + 1] = { id = id, w = w }
        end
    end
    if total <= 0 then
        return "commun"
    end
    local roll = math.random() * total
    local acc = 0
    for _, e in ipairs(entries) do
        acc += e.w
        if roll <= acc then
            return e.id
        end
    end
    return entries[#entries].id
end

-- Called by CombatServer whenever the progression loop advances the zone.
-- Observer only - does not affect progression.
function LootService.noteZoneReached(player, zone)
    zone = math.max(1, math.floor(zone or 1))
    if zone > (maxZoneReached[player] or 1) then
        maxZoneReached[player] = zone
    end
end

function LootService.release(player)
    maxZoneReached[player] = nil
end

-- Roll a drop for a kill.
--   context = { zone = <current zone>, isBoss = <boolean> }
-- Returns nil (no drop) or:
--   { id, slot, voie, rarete, zone, isBoss }
-- The caller is responsible for InventoryService.addItem. Never auto-equips.
function LootService.rollDrop(player, context)
    local zone = math.max(1, math.floor((context and context.zone) or 1))
    local isBoss = (context and context.isBoss) == true
    local rateMult = (context and context.dropRateMult) or 1

    -- Enforce "no drop above the max zone reached". In the CombatServer flow the
    -- current zone is always a zone actually walked to, so this only bites if a
    -- caller passes an inflated zone.
    local cap = maxZoneReached[player] or zone
    local dropZone = math.min(zone, cap)

    local isBigBoss = (context and context.isBigBoss) == true
    local slot
    if isBoss then
        -- GAME_SPEC.md 6.3 : one draw. Intermediate boss: 50% nothing.
        -- Big boss (an event): guaranteed a piece.
        local roll = math.random()
        if isBigBoss then
            roll = roll * 0.50
        end
        for _, row in ipairs(BOSS_SLOT_TABLE) do
            if roll < math.min(row.upTo * rateMult, GameConfig.Rewards.dropRateCap) then
                slot = row.slot
                break
            end
        end
        if not slot then return nil end
    else
        if math.random() >= scaledChance(NORMAL_DROP_CHANCE, rateMult) then return nil end
        slot = EquipmentConfig.LootPool[math.random(1, #EquipmentConfig.LootPool)].slot
    end

    local voie = (math.random() < 0.5) and "guerrier" or "mage"
    local id

    if context and context.bossIndex then
        -- ANY named boss (couche boss every 10 km, big boss every 100 km) drops
        -- its OWN couche set (GAME_SPEC.md 5.1 / 6.2, B6d).
        local bossIndex = math.max(1, math.floor(context.bossIndex))
        local setItems = EquipmentConfig.bossSetItems(bossIndex)
        local pool = (slot == "arme") and setItems.weapons or setItems.armor
        for _, entry in ipairs(pool) do
            if entry.slot == slot and entry.voie == voie then id = entry.id break end
        end
    end

    if not id then
        -- Generic zone gear (mobs, and bosses with no configured set).
        local slotEntry
        for _, e in ipairs(EquipmentConfig.LootPool) do
            if e.slot == slot then slotEntry = e break end
        end
        if not slotEntry then return nil end
        id = slotEntry[voie]
    end

    local def = EquipmentConfig.getItem(id)
    return {
        id     = id,
        nom    = (def and def.nom) or id,
        slot   = slot,
        voie   = voie,
        rarete = pickRarity(NORMAL_WEIGHTS),
        zone   = dropZone,
        isBoss = isBoss,
    }
end

-- Roll a PET drop for a kill. Independent of rollDrop - does not affect the
-- equipment drop. ~1.5% on a normal kill, 40% on a boss.
--   context = { zone = <current zone>, isBoss = <boolean> }
-- Returns nil or { id, slot = "pet", role, rarete, zone, isBoss }.
-- Caller grants OWNERSHIP. Never auto-equips.
function LootService.rollPetDrop(player, context)
    local zone = math.max(1, math.floor((context and context.zone) or 1))
    local isBoss = (context and context.isBoss) == true

    local cap = maxZoneReached[player] or zone
    local dropZone = math.min(zone, cap)

    local isBigBoss = (context and context.isBigBoss) == true
    local rateMult = (context and context.dropRateMult) or 1
    local chance = (isBigBoss and PET_BIGBOSS_CHANCE)
        or (isBoss and PET_BOSS_CHANCE)
        or PET_NORMAL_CHANCE
    if math.random() >= scaledChance(chance, rateMult) then
        return nil
    end

    local ids = {}
    for id in pairs(EquipmentConfig.Pets) do
        ids[#ids + 1] = id
    end
    if #ids == 0 then
        return nil
    end
    local id = ids[math.random(1, #ids)]
    local def = EquipmentConfig.Pets[id]
    local rarete = pickRarity(NORMAL_WEIGHTS)

    return {
        id     = id,
        nom    = def.nom or id,
        slot   = "pet",
        role   = def.role,
        rarete = rarete,
        zone   = dropZone,
        isBoss = isBoss,
        -- level-based scaling: the enemy level this pet dropped from
        sourceLevel = math.max(1, math.floor((context and context.enemyLevel) or 1)),
    }
end

return LootService
