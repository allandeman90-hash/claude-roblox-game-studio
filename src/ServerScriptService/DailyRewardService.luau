--==============================================================
-- DailyRewardService  (ModuleScript - ServerScriptService)
--
-- 7-day escalating login-reward chain (daily-reward-gdd.md). Server-authoritative:
-- the day is derived from `profile.dailyReward.lastClaimTime` via
-- GameConfig.DailyReward.evaluate (24 h cooldown, 48 h grace, reset to J1 past that).
--
-- Rewards applied here:
--   boost  -> profile.boosts[cat] = { mult, expiresAt }  (RewardService reads it)
--   pet    -> a random pet into the bag (rare)
--   armor  -> N Epic armor pieces of the player's voie, zone below their record
--   weapon -> 1 Epic weapon of the player's voie, at their current zone
--
-- The chain is PRESERVED across a Rebirth (edge case 11) - nothing here touches it
-- on reset.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local EquipmentConfig = require(ReplicatedStorage:WaitForChild("EquipmentConfig"))
local ZoneConfig = require(ReplicatedStorage:WaitForChild("ZoneConfig"))
local PlayerDataService = require(ServerScriptService:WaitForChild("PlayerDataService"))

local DailyRewardService = {}

local function invService()
    return require(ServerScriptService:WaitForChild("InventoryService"))
end

local function dr(profile)
    if type(profile.dailyReward) ~= "table" then
        profile.dailyReward = { currentDay = 1, lastClaimTime = 0 }
    end
    return profile.dailyReward
end

-- Read-only snapshot for the client (popup + 7-day grid).
function DailyRewardService.state(profile)
    local d = dr(profile)
    local ev = GameConfig.DailyReward.evaluate(d.lastClaimTime, d.currentDay)
    local D = GameConfig.DailyReward
    return {
        day          = ev.day,
        canClaim     = ev.canClaim,
        chainReset   = ev.chainReset,
        nextResetAt  = ev.nextResetAt,
        chainLength  = D.chainLength,
        claimedDay   = d.currentDay,           -- last day actually claimed
        lastClaimTime = d.lastClaimTime,
        labels       = (function()
            local out = {}
            for i = 1, D.chainLength do out[i] = D.days[i] and D.days[i].label or "?" end
            return out
        end)(),
    }
end

--===== Grant helpers =====
local function applyBoost(profile, cats: { string }, hours: number)
    profile.boosts = profile.boosts or {}
    local now = os.time()
    local mult = GameConfig.DailyReward.boostMult
    for _, cat in ipairs(cats) do
        local cur = profile.boosts[cat]
        local base = (cur and (cur.expiresAt or 0) > now) and cur.expiresAt or now
        profile.boosts[cat] = {
            mult = math.max((cur and cur.mult) or 1, mult),
            expiresAt = base + hours * 3600,
        }
    end
end

local function randomPetId(): string
    local ids = {}
    for id in pairs(EquipmentConfig.Pets) do ids[#ids + 1] = id end
    return ids[math.random(1, #ids)] or "pingouin"
end

local function grantPet(player, profile)
    local zone = math.max(1, ZoneConfig.zoneIdFromKm(math.max(profile.checkpointMax or 0, profile.distance or 0)))
    pcall(invService().addItem, player, {
        id = randomPetId(), rarete = "rare", zone = zone,
        -- daily-reward-gdd SS2.5: +20% vs a looted pet of the same tier.
        -- TODO: no per-instance power bonus field yet; `rare` already lifts it.
    })
end

local function grantArmor(player, profile, pieces: number)
    local voie = profile.voie == "mage" and "mage" or "guerrier"
    local recordKm = math.max(profile.bestKm or 0, profile.checkpointMax or 0)
    -- "zone just below the record" (daily-reward-gdd SS2.6)
    local zone = math.max(1, ZoneConfig.zoneIdFromKm(recordKm) - 1)
    local set = EquipmentConfig.bossSetItems(zone)
    local given = 0
    for _, a in ipairs(set.armor) do
        if given >= pieces then break end
        if a.voie == voie then
            local ok, kept = pcall(invService().addItem, player, {
                id = a.id, rarete = "epique", zone = zone,
            })
            if ok and kept then given += 1 end
        end
    end
    -- Fallback to the toile set if the boss set ids don't resolve (early content).
    if given == 0 then
        local suffix = (voie == "guerrier") and "_g" or "_m"
        for _, slot in ipairs({ "casque", "plastron", "jambieres", "bottes" }) do
            if given >= pieces then break end
            pcall(invService().addItem, player, { id = slot .. "_toile" .. suffix, rarete = "epique", zone = 1 })
            given += 1
        end
    end
end

local function grantWeapon(player, profile)
    local voie = profile.voie == "mage" and "mage" or "guerrier"
    local zone = math.clamp(ZoneConfig.zoneIdFromKm(math.max(profile.checkpointMax or 0, profile.distance or 0)), 1, 12)
    local id = string.format(voie == "mage" and "baguette_z%02d" or "epee_z%02d", zone)
    if not EquipmentConfig.getItem(id) then
        id = (voie == "mage") and "baguette_simple" or "epee_courte"
    end
    pcall(invService().addItem, player, {
        id = id, rarete = "epique", zone = zone,
        -- daily-reward-gdd SS2.7: +30% vs a normal weapon of the zone.
        -- TODO: represented by the Epique rarity multiplier for now.
    })
end

--===== Claim =====
-- Returns { ok, reason?, day?, label?, nextDay?, boostCats? }.
function DailyRewardService.claim(player: Player, profile, _st)
    local d = dr(profile)
    local ev = GameConfig.DailyReward.evaluate(d.lastClaimTime, d.currentDay)
    if not ev.canClaim then
        return { ok = false, reason = "cooldown" }
    end

    local dayDef = GameConfig.DailyReward.days[ev.day]
    if not dayDef then
        return { ok = false, reason = "config" }
    end

    local boostCats = nil
    for _, g in ipairs(dayDef.grants) do
        if g.kind == "boost" then
            applyBoost(profile, g.cats, g.hours)
            boostCats = g.cats
        elseif g.kind == "pet" then
            grantPet(player, profile)
        elseif g.kind == "armor" then
            grantArmor(player, profile, g.pieces or 4)
        elseif g.kind == "weapon" then
            grantWeapon(player, profile)
        end
    end

    d.currentDay = ev.day
    d.lastClaimTime = os.time()
    PlayerDataService.markDirty(player, profile)

    local nextDay = (ev.day % GameConfig.DailyReward.chainLength) + 1
    return {
        ok = true,
        day = ev.day,
        label = dayDef.label,
        nextDay = nextDay,
        nextLabel = GameConfig.DailyReward.days[nextDay] and GameConfig.DailyReward.days[nextDay].label or nil,
        boostCats = boostCats,
    }
end

return DailyRewardService
