--==============================================================
-- EnemyService  (ModuleScript - ServerScriptService)
--
-- Regular-enemy stat generation. Server-only, stateless.
--
-- Zone power curve (GAME_SPEC.md 7.1): HP / ATK / gold scale x1.35 per
-- 10 km zone, applied uniformly and rounded to an integer. XP is NOT in
-- the 7.1 list -> it grows linearly (base.exp + (zone-1) * expPerZone).
--
-- Enemy level (GAME_SPEC.md 6.1, purely indicative - enters NO combat / XP /
-- gold calculation): a mob rolls a RANDOM level inside its zone's band, so a
-- zone shows a spread of levels. Band for zone Z = (Z-1)*10 .. Z*10, floored
-- at 1:  Z1 -> 1..10 | Z2 -> 10..20 | Z3 -> 20..30 | ... | Z10 -> 90..100.
--
-- Roster multipliers (ZoneConfig, zone 1) apply on TOP of the scaled base;
-- undeveloped zones use the raw scaled base as a fallback.
--
-- The BOSS still uses the old linear base (legacyBossBase) until the boss
-- etape reworks ZoneService.rollBoss + its multipliers.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ZoneConfig = require(ReplicatedStorage:WaitForChild("ZoneConfig"))

local EnemyService = {}

local E = GameConfig.Enemy
local BASE = E.base                 -- { maxHp = 50, atk = 5, exp = 10, gold = 5 }
local SCALING = E.zoneScaling       -- 1.35
local SCALE_CAP = E.scaleExpCap     -- 90
local EXP_SCALING = E.expScaling    -- 1.22 (geometric XP growth per zone)
local STAT_MAX = E.statHardMax or 1e15

-- Every generated enemy/boss stat passes through this: no negatives, no int64
-- overflow from the compounding 1.35 curve x boss multipliers.
local function clampStat(v)
    return math.round(math.clamp(v, 0, STAT_MAX))
end

-- x1.35 multiplier for a zone (1-indexed). Deterministic; exponent clamped.
local function zoneMult(zone)
    local e = math.clamp((zone or 1) - 1, 0, SCALE_CAP)
    return SCALING ^ e
end

-- Roster multiplier applied on top of the scaled base.
local function scale(base, mul, floorMin)
    return math.max(floorMin, math.floor(base * (mul or 1)))
end

-- Indicative level band [lo, hi] for a zone (1-indexed).
local function levelBandForZone(zone)
    zone = math.max(1, zone or 1)
    return math.max(1, (zone - 1) * 10), zone * 10
end

-- Mid-band level for a zone (used only as a coarse fallback).
function EnemyService.levelForZone(zone)
    local lo, hi = levelBandForZone(zone)
    return math.floor((lo + hi) / 2)
end

-- Enemy level for a server distance (km). GAME_SPEC.md 6.1 - indicative only
-- (enters NO combat / XP / gold math). NOT random: it ramps smoothly across the
-- zone, from lo+1 at the zone start to the boss level (zone*10) at the zone end,
-- so the player feels a steady climb toward each end-of-zone boss.
function EnemyService.levelForKm(km)
    local kmPerZone = ZoneConfig.KM_PER_ZONE
    local zone = ZoneConfig.zoneIdFromKm(km)
    local lo = (zone - 1) * 10
    local frac = math.clamp((km - (zone - 1) * kmPerZone) / kmPerZone, 0, 1)
    -- mobs cap one level below the boss (zone*10); boss keeps the round number.
    return math.clamp(math.floor(lo + 1 + frac * 8.5), lo + 1, zone * 10 - 1)
end

-- Zone base stats BEFORE roster / boss multipliers.
--   maxHp / atk / gold : round(base * 1.35^(zone-1))
--   exp                : base.exp + (zone-1) * expPerZone   (linear)
function EnemyService.baseStatsForZone(zone)
    local m = zoneMult(zone)
    local e = math.clamp((zone or 1) - 1, 0, SCALE_CAP)
    return {
        maxHp = clampStat(BASE.maxHp * m),
        atk   = clampStat(BASE.atk * m),
        gold  = clampStat(BASE.gold * m),
        exp   = clampStat(BASE.exp * EXP_SCALING ^ e),
    }
end

-- TEMP: linear per-zone base kept ONLY for ZoneService.rollBoss, so the boss
-- stays exactly as it is until the boss etape. Do not use for regular enemies.
-- Roll the boss for a boss milestone (GAME_SPEC.md 6.2).
--   * every 10 km  -> INTERMEDIATE boss (zone gate, moderate spike)
--   * every 100 km -> BIG boss (a wall + an event; one of the 12 named bosses)
-- Stats = the zone base (same x1.35 curve as regular enemies) x tier multipliers.
-- Magic bosses deal magic damage -> the player's RES matters, not DEF.
function EnemyService.rollBoss(km)
    -- The boss sits on a zone boundary (km = Z*10). Credit it to the zone it
    -- CLOSES (Z), not the one it opens - so its level/stats are the peak of that
    -- zone's curve, right above its toughest mob.
    local zone = ZoneConfig.zoneIdFromKm(km)
    if km % ZoneConfig.KM_PER_ZONE == 0 then zone = math.max(1, zone - 1) end
    local b = EnemyService.baseStatsForZone(zone)
    local B = GameConfig.Enemy.Boss
    local isBig = (km % B.bigEveryKm == 0)

    local theme, hpM, atkM, expM, goldM, index
    if isBig then
        index = math.max(1, math.floor(km / B.bigEveryKm + 0.5))
        theme = ZoneConfig.bossTheme(index)
        hpM, atkM, expM, goldM = B.bigHpMult, B.bigAtkMult, B.bigExpMult, B.bigGoldMult
    else
        index = math.max(1, math.floor(km / B.everyKm + 0.5))
        theme = ZoneConfig.intermediateBoss(index)
        hpM, atkM, expM, goldM = B.hpMult, B.atkMult, B.expMult, B.goldMult
    end

    -- BIG-boss ATK grows on a damped exponent (HP/EXP/gold keep the full curve),
    -- so the fight is a war of attrition the player can gear/farm for.
    local atkBase = b.atk
    if isBig and B.atkZoneDamping and B.atkZoneDamping < 1 then
        local e = math.clamp((zone or 1) - 1, 0, SCALE_CAP)
        atkBase = BASE.atk * (SCALING ^ (e * B.atkZoneDamping))
    end

    local magic = theme.magic == true
    return {
        name       = isBig
            and string.format(">> %s <<  (BIG BOSS %d)", theme.name, index)
            or  string.format("%s  (Boss %d)", theme.name, index),
        level      = zone * 10,
        maxHp      = clampStat(b.maxHp * hpM),
        atk        = clampStat(atkBase * atkM),
        exp        = clampStat(b.exp * expM),
        gold       = clampStat(b.gold * goldM),
        isBoss     = true,
        isBigBoss  = isBig,
        damageType = magic and "magic" or "physical",
        atkSplit   = theme.atkSplit or (magic and 0.30 or 0.80),
    }
end

-- Fixed encounter slots for a zone (world-traversal model).
--   `stepsPerZone` steps (1 km each), `mobsPerStep` mobs per step.
--   The LAST step: slot 1 = a normal mob, slot 2 = the ZONE BOSS (at the zone end).
-- Deterministic positions -> stable respawn when the player walks back to farm.
--   zone 1, 10 steps x 2: mobs at 0.33, 0.67, 1.33, 1.67, ... 9.33, and boss at 10.
function EnemyService.encountersForZone(zone)
    zone = math.max(1, math.floor(zone or 1))
    local base = (zone - 1) * GameConfig.Progression.kmPerZone
    local steps = GameConfig.World.stepsPerZone
    local perStep = GameConfig.World.mobsPerStep
    local stepLen = GameConfig.Progression.kmPerZone / steps
    local list = {}
    local fracs = GameConfig.World.stepFractions
    for s = 1, steps do
        local stepBase = base + (s - 1) * stepLen
        for m = 1, perStep do
            local isBoss = (s == steps) and (m == perStep)
            local frac = isBoss and 1.0 or (fracs[m] or (m / (perStep + 1)))
            list[#list + 1] = {
                pos  = stepBase + frac * stepLen,
                kind = isBoss and "boss" or "mob",
                step = s,
                slot = m,
            }
        end
    end
    return list
end

-- The step (1..stepsPerZone) a km position falls in, within its zone.
function EnemyService.stepForKm(km)
    local zone = ZoneConfig.zoneIdFromKm(km)
    local base = (zone - 1) * GameConfig.Progression.kmPerZone
    local stepLen = GameConfig.Progression.kmPerZone / GameConfig.World.stepsPerZone
    return math.clamp(math.floor((km - base) / stepLen) + 1, 1, GameConfig.World.stepsPerZone)
end

-- Roll a regular enemy for the given server distance (km).
-- Returns { name, level, maxHp, atk, exp, gold, isBoss = false }.
function EnemyService.rollEnemy(km)
    local zone = ZoneConfig.zoneIdFromKm(km)
    local b = EnemyService.baseStatsForZone(zone)
    local level = EnemyService.levelForKm(km)

    local cfg = ZoneConfig.getZone(zone)
    local roster = cfg and cfg.enemies

    if not roster or #roster == 0 then
        -- Undeveloped zone: raw scaled base, so combat never breaks.
        return {
            name  = ((cfg and cfg.name) or ("Zone " .. zone)) .. " - Inconnu",
            level = level,
            maxHp = b.maxHp,
            atk   = b.atk,
            exp   = b.exp,
            gold  = b.gold,
            isBoss = false,
        }
    end

    local def = roster[math.random(1, #roster)]
    return {
        name  = def.name,
        level = level,
        maxHp = scale(b.maxHp, def.hpMul, 1),
        atk   = scale(b.atk, def.atkMul, 1),
        exp   = scale(b.exp, def.expMul, 1),
        gold  = scale(b.gold, def.goldMul, 0),
        isBoss = false,
    }
end

return EnemyService
