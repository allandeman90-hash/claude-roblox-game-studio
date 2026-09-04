--==============================================================
-- EnemyService  (ModuleScript - ServerScriptService)
--
-- Regular-enemy stat generation. Server-only, stateless.
--
-- Everything (HP / ATK / EXP / gold) is LEVEL-driven now - combatBaseForLevel
-- (enemy-rebalance etape). HP/ATK match a REFERENCE curve-player `levelLead`
-- levels below the mob (same 5-points-per-level slope the player earns, so a
-- same-level fight is ~even and the player's edge is level lead + gear + pet).
-- EXP follows GameConfig.Level's strict Classic-style curve; gold remains
-- geometric per level.
--
-- Enemy level (GAME_SPEC.md 6.1): ramps smoothly across a zone from lo+1 to
-- zone*10-1 (mobs); the end-of-zone boss is exactly zone*10.
--
-- Roster multipliers (ZoneConfig, zone 1) apply on TOP of the level base;
-- undeveloped zones use the raw level base as a fallback.
--
-- BOSS = combatBaseForLevel(zone*10) x Boss multipliers (all four stats).
-- One NAMED boss per zone; BIG boss every 100 km.
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
    -- Couche 1 is the complete launch/tutorial slice: regular enemies climb
    -- cleanly from level 1 to 9, then the Roi Gobelin closes it at level 10.
    -- Later couches keep the global progression curve until the full D6 pass.
    if km < ZoneConfig.KM_PER_ZONE then
        return math.clamp(math.floor(math.max(0, km)) + 1, 1, 9)
    end
    -- mob level = round(km * GameConfig.Enemy.levelPerKm) (1.15), CLAMPED to stay
    -- one below the zone's boss (zone*10, EnemyService.rollBoss) so mobs always
    -- ramp toward - never past - the boss that closes their zone. The difficulty
    -- wall comes from the level-gap penalty + the level cap, not this ramp.
    local zone = ZoneConfig.zoneIdFromKm(km)
    local ramp = math.max(1, GameConfig.Enemy.levelFromKm(km))
    return math.min(ramp, zone * 10 - 1)
end

-- DEPRECATED - nothing calls this since HP/ATK/EXP/gold all went level-driven
-- (combatBaseForLevel). Kept only so an external reader doesn't break.
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

-- Everything a mob's LEVEL drives, BEFORE roster / boss multipliers:
--   HP / ATK : matched to a REFERENCE curve-player `levelLead` levels below the
--              mob's level - that player has spent max(0, level - levelLead) *
--              refPointsPerLevel points, refVitShare into VIT (-> MaxHP =
--              VIT * hpPerVit) and refPowShare into POW (-> physATK = baseAtk +
--              POW * atkPerPow), then separate HP/ATK difficulty scales.
--   EXP / gold : geometric per LEVEL (expPerLevel / goldPerLevel), so the reward
--              tracks the exact mob level instead of stepping once per zone. The
--              exponent is capped like the old zone curve (scaleExpCap).
function EnemyService.combatBaseForLevel(level)
    local P = GameConfig.Player
    local S = P.startingStats
    local L = math.max(1, math.floor(level or 1))
    -- [D1] reference points/level is DECOUPLED from the player curve (Enemy.refPointsPerLevel).
    local pts = math.max(0, L - (E.levelLead or 1)) * (E.refPointsPerLevel or 5)
    local vit = S.vit + (E.refVitShare or 0.5) * pts
    local pow = S.pow + (E.refPowShare or 0.42) * pts
    local hpScale = E.enemyHpScale or E.enemyPowerScale or 1
    local atkScale = E.enemyAtkScale or E.enemyPowerScale or 1
    local rewardExp = math.clamp(L - 1, 0, SCALE_CAP)
    return {
        maxHp = clampStat((vit * P.hpPerVit) * hpScale),
        atk   = clampStat((P.baseAtk + pow * P.atkPerPow) * atkScale),
        exp   = clampStat(GameConfig.Level.xpForEnemyLevel(L)),
        gold  = clampStat(E.base.gold * (E.goldPerLevel or 1.03) ^ rewardExp),
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
    local cb = EnemyService.combatBaseForLevel(zone * 10)   -- boss level = zone * 10 ; drives hp/atk/exp/gold
    local B = GameConfig.Enemy.Boss
    local isBig = (km % B.bigEveryKm == 0)

    -- One NAMED boss per 10 km zone (GAME_SPEC 6.2). The list of 12 cycles for
    -- deeper zones. Every 100 km that boss also gets the tougher "BIG" multipliers.
    local index = math.max(1, math.floor(km / B.everyKm + 0.5))
    local theme = ZoneConfig.bossTheme(index)
    local hpM, atkM, expM, goldM
    if isBig then
        hpM, atkM, expM, goldM = B.bigHpMult, B.bigAtkMult, B.bigExpMult, B.bigGoldMult
    else
        hpM, atkM, expM, goldM = B.hpMult, B.atkMult, B.expMult, B.goldMult
    end

    -- BIG-boss ATK is damped by a flat factor (HP/EXP/gold keep their full mults),
    -- so the fight is a war of attrition the player can gear/farm for.
    local atkBase = cb.atk
    if isBig then
        atkBase = atkBase * (B.bigBossAtkDamp or 0.6)
    end

    local magic = theme.magic == true
    return {
        name       = theme.name,   -- clean display name, no "(Boss N)" tag
        id         = theme.id,     -- sprite slug; client art only
        level      = zone * 10,
        maxHp      = clampStat(cb.maxHp * hpM),
        atk        = clampStat(atkBase * atkM),
        exp        = clampStat(cb.exp * expM),
        gold       = clampStat(cb.gold * goldM),
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
    local level = EnemyService.levelForKm(km)
    local cb = EnemyService.combatBaseForLevel(level)     -- hp / atk / exp / gold, all level-driven

    local cfg = ZoneConfig.getZone(zone)
    local roster = cfg and cfg.enemies

    if not roster or #roster == 0 then
        -- Undeveloped zone: raw level base - combat never breaks.
        return {
            name  = ((cfg and cfg.name) or ("Zone " .. zone)) .. " - Inconnu",
            id    = nil,   -- no sprite yet for undeveloped-zone mobs
            level = level,
            maxHp = cb.maxHp,
            atk   = cb.atk,
            exp   = cb.exp,
            gold  = cb.gold,
            isBoss = false,
        }
    end

    local def
    if zone == 1 then
        -- Couche 1 is a deterministic difficulty ramp, not a roulette. The first
        -- two encounters teach movement/combat with chaff; all six silhouettes
        -- then appear before the Roi Gobelin, with tanks introduced late.
        local sequence = { 1, 2, 1, 3, 2, 4, 1, 5, 3, 4, 2, 6, 1, 3, 4, 5, 2, 6, 4 }
        local localKm = math.clamp(km, 0, ZoneConfig.KM_PER_ZONE - 0.001)
        local step = math.floor(localKm) + 1
        local slot = (localKm - math.floor(localKm) > 0.75) and 2 or 1
        local index = math.clamp((step - 1) * 2 + slot, 1, #sequence)
        def = roster[sequence[index]]
    else
        def = roster[math.random(1, #roster)]
    end
    return {
        name  = def.name,
        id    = def.id,   -- sprite slug; client art only
        level = level,
        maxHp = scale(cb.maxHp, def.hpMul, 1),
        atk   = scale(cb.atk, def.atkMul, 1),
        exp   = scale(cb.exp, def.expMul, 1),
        gold  = scale(cb.gold, def.goldMul, 0),
        isBoss = false,
    }
end

return EnemyService
