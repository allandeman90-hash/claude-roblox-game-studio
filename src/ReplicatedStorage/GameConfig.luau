--==============================================================
-- GameConfig  (ModuleScript - ReplicatedStorage)
--
-- Single source of truth for game-wide tuning constants and formulas.
-- Pure data + pure helper functions. NO state, NO service calls, NO
-- gameplay logic. Shared by client and server (mirrors ZoneConfig).
--
-- Entry tags:
--   [ACTIVE]      the running code reads this value today.
--   [GDD TARGET]  the value GAME_SPEC.md (or a validated decision) calls
--                 for, kept here but NOT yet wired into the code. A later
--                 etape flips the consumer, not the number.
--
-- Etape 1 (creation): the ONLY behaviour change vs the previous build is
-- Level.xpForNextLevel (validated decision 1). Every other [ACTIVE] value
-- equals the constant it replaced in CombatServer.
--==============================================================

local GameConfig = {}

--========================================================
-- LEVEL & XP
--========================================================
GameConfig.Level = {
    -- [ACTIVE] GAME_SPEC.md 3.1 - unchanged.
    statPointsPerLevel = 5,
}

-- [ACTIVE] validated (etape 1 + etape 2.5 offset). XP required to advance
-- FROM level N to level N+1: 2*N*(N+1) + 40. The +40 offset stops the first
-- few levels being earned in 1-2 kills (~10 XP each) without changing the
-- mid / late curve.
--   N=1 -> 44 | N=2 -> 52 | N=5 -> 100 | N=10 -> 260 | N=25 -> 1340 | N=50 -> 5140
function GameConfig.Level.xpForNextLevel(n)
    return 2 * n * (n + 1) + 40
end

--========================================================
-- PLAYER STATS
--========================================================
GameConfig.Player = {
    -- [ACTIVE] validated etape 2 / etape 3.
    hpPerVit  = 5,       -- Max HP = VIT * 5 (no base HP)          (GAME_SPEC.md 3.1)

    -- Offensive: additive model (D2 option 1), magic symmetric with physical (D3 3a).
    --   physATK = baseAtk      + POW * atkPerPow   + equipAtk
    --   magATK  = baseMagicAtk + INT * magicPerInt + equipMagicAtk
    baseAtk      = 10,
    atkPerPow    = 2,
    baseMagicAtk = 10,
    magicPerInt  = 2,

    -- A fresh player's 5 allocatable stats. The damage stat (POW for a warrior,
    -- INT for a mage) starts at 2; everything else at 1 except VIT at 6.
    --   -> physATK = baseAtk + POW*atkPerPow = 10 + 4 = 14
    --   -> MaxHP   = VIT * hpPerVit          = 6 * 5  = 30
    startingStats = { pow = 2, int = 2, vit = 6, spd = 1, luk = 1 },

    -- Out-of-combat HP regen (fraction of MaxHP per second). High enough that
    -- "back off, let it tick, then re-engage" is the core skill of an auto-battler:
    -- ~2%/s = a careful player recovers between fights, a greedy one dies. The
    -- bigger campfire regen stacks on top.
    outOfCombatRegenPct = 0.02,
}

-- Etape 2 removed GameConfig.StatBonus (INT->XP, SPD->move, LUK->gold). Those
-- prototype effects contradicted GAME_SPEC.md 3.1. The correct effects are now:
-- INT = magic power (etape 3), LUK = crit rate (etape 3). SPD = attack cadence
-- remains a SEAM (formula pending).

--========================================================
-- COMBAT
--========================================================
GameConfig.Combat = {
    -- [ACTIVE]
    -- Combat is AUTO-ATTACK ONLY (no tapping). Base cadence: 1 hit / 2.2 s; the
    -- player lowers it only by investing SPD.
    playerAttackInterval = 2.2,
    enemyAttackInterval  = 2,          -- seconds between enemy attacks

    -- SPD -> attack cadence, ON TOP of the 2.2 s base. Uses (effSPD - startingSPD)
    -- so an un-invested player sits at exactly the 2.2 s base:
    --   interval = max(minAttackInterval,
    --                  playerAttackInterval / (1 + (effSPD - startSPD) * spdCadenceCoef))
    -- SPD 1 -> 2.20 s | 25 -> 1.54 | 50 -> 1.20 | 100 -> 0.82 | 150 -> 0.63 | 200 -> 0.50
    spdCadenceCoef    = 0.0171,
    minAttackInterval = 0.5,    -- HARD cap on attack speed (2 atk/s) - reached at SPD 200.
    spdMax            = 200,     -- SPD cannot be raised past this
    spdCostPerPoint   = 2,       -- each SPD point costs 2 skill points (other stats: 1)
                                --   -> SPD 200 = ~400 skill points total.

    -- [ACTIVE - etape 3] GAME_SPEC.md 3.1 : critical hit = x2 damage.
    critMultiplier = 2,
}

-- [ACTIVE - etape 3] Critical chance = LUK / 10000. The crit roll is the ONLY
-- random element of the V1 damage calculation.
function GameConfig.Combat.critRate(luk)
    return luk / 10000
end

-- [ACTIVE - etape 3 / etape 4.0] Multiplicative mitigation, never `ATK - DEF`.
-- Applied ONLY to enemy -> player damage (enemies have no DEF/RES):
--   physical hit taken = enemyAtk      * physicalMitigation(playerDEF)
--   magic    hit taken = enemyMagicAtk * magicMitigation(playerRES)   (magic bosses: later)
-- Etape 4.0: floored at mitigationFloor so a heavily-armored player still takes
-- a real fraction of every hit (prevents late-game invincibility). Validated.
GameConfig.Combat.mitigationFloor = 0.10   -- min fraction of damage that always lands
                                           -- (low, so stacking DEF/RES is a real
                                           --  counter to late bosses - rewards farming)

function GameConfig.Combat.physicalMitigation(def)
    return math.max(GameConfig.Combat.mitigationFloor, 100 / (100 + math.max(0, def)))
end

function GameConfig.Combat.magicMitigation(res)
    return math.max(GameConfig.Combat.mitigationFloor, 100 / (100 + math.max(0, res)))
end

--========================================================
-- EQUIPMENT / ECONOMY  (etape 4.0 - validated design)
--========================================================
-- Item power is DERIVED from the zone the item belongs to + its rarity.
-- The item definitions in EquipmentConfig carry no per-item stat numbers for
-- this model - only slot / voie / name. Rarity multipliers live in
-- EquipmentConfig.Rarities (single source: label + chance + active + mult).
--
--   weaponPct  = weaponBase   * zoneScaling^(zone-1) * rarityMult / 100
--                -> physATK = (baseAtk + POW*atkPerPow) * (1 + weaponPct)   (or magic)
--   armorStat  = round(armorStatBase * zoneScaling^(zone-1) * rarityMult)   per piece
--                -> DEF (guerrier armor) or RES (mage armor), summed over 4 slots
--   armor HP   = +hpPctPerPiece of (VIT*hpPerVit) per equipped armor piece, NOT zone-scaled
--   price      = round(priceBase * priceScaling^(zone-1))   (gold)
GameConfig.Equipment = {
    zoneScaling   = 1.30,   -- item power growth per zone. Enemies grow 1.35, so gear
                            -- still falls slowly behind (punitive) but NOT infinitely -
                            -- farming + rebirth close the residual ~4%/zone gap.
    priceScaling  = 1.35,   -- gold price growth per zone

    weaponBase    = 8,      -- zone-1 weapon power  (-> weaponPct = power / 100)
    armorStatBase = 6,      -- zone-1 DEF or RES, PER armor piece
    hpPctPerPiece = 0.10,   -- each equipped armor piece: +10% of the VIT-derived MaxHP

    weaponPriceBase = 250,  -- gold, zone-1 weapon
    armorPriceBase  = 120,  -- gold, zone-1 armor piece (full 4-piece set = 4x)
}

local function zoneExp(zone)
    return math.max(1, zone or 1) - 1
end

-- weaponPct: multiplicative ATK bonus (0.08 = +8%). rarityMult from EquipmentConfig.
function GameConfig.Equipment.weaponPct(zone, rarityMult)
    local E = GameConfig.Equipment
    return E.weaponBase * E.zoneScaling ^ zoneExp(zone) * (rarityMult or 1) / 100
end

-- armorStat: flat DEF or RES contributed by ONE armor piece.
function GameConfig.Equipment.armorStat(zone, rarityMult)
    local E = GameConfig.Equipment
    return math.round(E.armorStatBase * E.zoneScaling ^ zoneExp(zone) * (rarityMult or 1))
end

function GameConfig.Equipment.weaponPrice(zone)
    local E = GameConfig.Equipment
    return math.round(E.weaponPriceBase * E.priceScaling ^ zoneExp(zone))
end

function GameConfig.Equipment.armorPiecePrice(zone)
    local E = GameConfig.Equipment
    return math.round(E.armorPriceBase * E.priceScaling ^ zoneExp(zone))
end

--========================================================
-- PETS  (etape 4.2 - validated: PASSIVE only, one slot, same rarity table,
--        same x1.25 zone scaling as equipment)
--========================================================
-- Effect magnitude = base * zoneScaling^(zone-1) * rarityMult.
--   dps  : +dpsPct of the player's effective damage        (passive, always on)
--   tank : +hpPct of MaxHP  AND  +defFlat flat DEF          (passive, always on)
--   heal : +healPct of MaxHP per second, CAMPFIRE ONLY      (on top of the base 1%/s)
GameConfig.Pets = {
    zoneScaling   = 1.25,   -- same as equipment
    dpsPctBase    = 3.0,    -- % of damage  (-> /100)
    tankHpPctBase = 2.0,    -- % of MaxHP
    tankDefBase   = 4.0,    -- flat DEF (armorStat pattern)
    healPctBase   = 0.5,    -- % of MaxHP per second, campfire only
}

local function petZoneMul(zone, rarityMult)
    return GameConfig.Pets.zoneScaling ^ zoneExp(zone) * (rarityMult or 1)
end

-- Passive effect for a pet role. Keys present depend on the role; missing = 0.
function GameConfig.Pets.effect(role, zone, rarityMult)
    local P = GameConfig.Pets
    local m = petZoneMul(zone, rarityMult)
    if role == "dps" then
        return { dpsPct = P.dpsPctBase * m / 100 }
    elseif role == "tank" then
        return { hpPct = P.tankHpPctBase * m / 100, defFlat = math.round(P.tankDefBase * m) }
    elseif role == "heal" then
        return { healPct = P.healPctBase * m / 100 }
    end
    return {}
end

--========================================================
-- REBIRTH  (GAME_SPEC.md 8.1)
--========================================================
-- Voluntary infinite reset. KEEPS equipment / pets / checkpoints / rebirth
-- count. RESETS level, stat points, gold, distance. Cost is gold: the player
-- must hold >= cost(n) and ends the rebirth with 0 gold.
--   cost(n)  = baseCost * costScaling^(n-1)   (n = the rebirth being bought, 1-indexed)
--   bonus    = +damageBonusPerRebirth dmg, +xpBonusPerRebirth XP, ADDITIVE per rebirth
GameConfig.Rebirth = {
    baseCost              = 10000,
    costScaling           = 2.2,
    -- Each rebirth makes every ALLOCATED skill point +10% more effective
    -- (compounds with re-levelling). Rebirth 0: 1 pt POW -> +2 ATK ;
    -- rebirth 3: 1 pt POW -> +2.6 ATK. Applies to POW/INT/VIT/SPD/LUK.
    skillEffectPerRebirth = 0.10,
    xpBonusPerRebirth     = 0.25,   -- +25% XP per rebirth (additive)
}

-- Gold cost of the n-th rebirth (n >= 1). R1 = 10000, R2 = 22000, R5 = 234256...
function GameConfig.Rebirth.cost(n)
    n = math.max(1, math.floor(n or 1))
    return math.round(GameConfig.Rebirth.baseCost * GameConfig.Rebirth.costScaling ^ (n - 1))
end

-- Effectiveness multiplier applied to ALLOCATED skill points (the small
-- starting stats are never multiplied). 1.0 at rebirth 0, +0.10 per rebirth.
function GameConfig.Rebirth.skillMult(rebirths)
    return 1 + GameConfig.Rebirth.skillEffectPerRebirth * math.max(0, rebirths or 0)
end

function GameConfig.Rebirth.xpMult(rebirths)
    return 1 + GameConfig.Rebirth.xpBonusPerRebirth * math.max(0, rebirths or 0)
end

--========================================================
-- ENEMIES
--========================================================
GameConfig.Enemy = {
    -- [ACTIVE - etape EnemyService]
    defaultName  = "Slime",
    defaultLevel = 1,

    -- Zone-1 baseline. maxHp / atk here are LEGACY (unused - HP/ATK are
    -- level-driven). exp / gold ARE still read as the level-0 anchor for the
    -- per-level reward curve below.
    base       = { maxHp = 50, atk = 6, exp = 10, gold = 5 },
    zoneScaling  = 1.35,   -- LEGACY: was enemy HP/ATK/gold per zone. Now unused by
                           -- EnemyService (kept for shop weapon/armor power refs).

    -- [ACTIVE - enemy-rebalance] EVERYTHING (HP / ATK / EXP / gold) is driven by
    -- the mob's LEVEL - EnemyService.combatBaseForLevel - not the old 1.35^zone.
    --   HP / ATK : matched to a REFERENCE curve-player `levelLead` levels below
    --     the mob; that player spent max(0, L - levelLead) * statPointsPerLevel
    --     points, refVitShare -> VIT, refPowShare -> POW ; result x enemyPowerScale.
    --   EXP / gold : base.exp / base.gold x (expPerLevel / goldPerLevel)^(L-1),
    --     exponent capped at scaleExpCap. Calibrated so the total ~matches the old
    --     per-zone curve at the boundaries, but tracks the exact mob level.
    levelLead       = 1,
    refVitShare     = 0.50,   -- reference build: half the earned points into VIT ...
    refPowShare     = 0.42,   -- ... most of the rest into the damage stat (POW)
    enemyPowerScale = 1.0,    -- global HP/ATK dial (>1 harder, <1 easier). 1.0 =
                              -- a same-level fight is ~even; the player's edge is
                              -- their +levelLead, gear, pet and smarter play.
    expPerLevel     = 1.02,   -- EXP  x this per mob level  (1.02^10 ~= 1.22 / zone, unchanged total)
    goldPerLevel    = 1.03,   -- gold x this per mob level  (1.03^10 ~= 1.35 / zone, unchanged total)
    scaleExpCap  = 90,     -- clamp the per-level exponent. Past ~level 900 the numbers
                           -- stop being meaningful and (x boss mults, rounded) would
                           -- overflow int64.
    statHardMax  = 1e15,   -- absolute clamp on any generated enemy/boss stat (anti-overflow).
    expScaling   = 1.22,   -- LEGACY (old per-zone XP curve). Unused.
    expPerZone   = 5,      -- LEGACY (linear model). Unused.

    -- Two boss tiers (GAME_SPEC.md 6.2 + design directive):
    --   * NAMED boss at every zone end (10 km) - the zone gate, a real fight.
    --   * BIG boss every 10 zones (100 km) - a wall and an event; same 12 names
    --     with tougher multipliers (ZoneConfig.BossThemes; the list cycles past 12).
    -- Stats = combatBaseForLevel(zone*10) x the tier multipliers (all four stats).
    bossCount   = 12,
    Boss = {
        everyKm    = 10,
        -- Combat is a fight to the DEATH (no flee) - HP x ATK multipliers COMPOUND
        -- into the win/lose race, so keep them modest on the level-matched base.
        -- hpMult 2.5 => ~2.5x fight length ; atkMult 1.3 => a real damage spike
        -- that punishes an under-levelled / under-geared player without 2-shotting.
        hpMult     = 2.5,
        atkMult    = 1.3,
        expMult    = 6.0,
        goldMult   = 5.0,

        bigEveryKm  = 100,
        bigHpMult   = 14.0,  -- big boss: a wall (long attrition fight), needs the zone's set + drops
        bigAtkMult  = 2.5,   -- lower: paired with bigBossAtkDamp so the fight is survivable
        bigBossAtkDamp = 0.6,   -- BIG-boss ATK is damped by this flat factor (on top of
                                -- bigAtkMult) so it is a war of attrition, not a first-hit
                                -- coin flip. HP / EXP / gold keep their full multipliers.
        atkZoneDamping = 0.55,  -- DEPRECATED (old 1.35^-exponent damping). Unused.
        bigExpMult  = 40.0,  -- clearing a big boss ~= several levels
        bigGoldMult = 30.0,
    },
}

-- [ACTIVE - etape EnemyService] GAME_SPEC.md 6.1 : monster level = km x 10.
-- Purely indicative (4.1) - enters no combat calculation.
function GameConfig.Enemy.levelFromKm(km)
    return math.max(1, math.floor(km * 10))
end

--========================================================
-- PROGRESSION / MOVEMENT  (world-traversal model)
--========================================================
-- The player has a POSITION in km and walks left / right (held input). Each zone
-- has a fixed set of encounter slots; leaving a zone RESPAWNS its encounters so
-- the player can walk back and farm. No monotonic auto-run.
GameConfig.Progression = {
    kmPerStep = 0.1,             -- kept: client scroll works in "steps" (pos * 10)
    kmPerZone = 10,
    -- legacy fields kept so nothing that still reads them breaks:
    baseProgressSpeed = 5, spdProgressMultiplier = 1, stepsPerEnemy = 10, stepsPerZone = 100,
}

GameConfig.World = {
    moveSpeedKmPerSec = 0.11,    -- deliberate walking pace (~9 s per 1 km step), so
                                -- there is real space between mobs.
    stepsPerZone      = 10,      -- 10 steps per zone (1 km each)
    mobsPerStep       = 2,       -- 2 mobs per step; the LAST step's 2nd slot is the BOSS
    stepFractions     = { 0.5, 0.95 },   -- where the 2 encounters sit within a step (0..1):
                                         -- mob 1 dead-centre, mob 2 mirrors the hero's start gap
                                         -- from the right edge. Boss keeps its own frac (1.0).
    encounterRangeKm  = 0.06,    -- the hero must be right ON the mob to engage (no dash from afar)
    respawnBufferKm   = 0.55,    -- DEPRECATED: respawn is now step-based (leave the 1 km step)
    campfireEveryKm   = 50,
    campfireRangeKm   = 1.2,     -- rest + shop available within this of a 50 km mark

    fastZoneKm   = 100,          -- from here the world moves 1.5x
    fastZoneMult = 1.5,
    fastModeMult = 2.0,          -- optional toggle, needs N big bosses beaten
    fastModeUnlockBigBosses = 4, -- big boss at km 400
}

-- Global speed multiplier applied to walking (and, later, to a paid auto-advance).
function GameConfig.World.speedMult(pos, fastMode, bigBossesBeaten)
    local W = GameConfig.World
    if fastMode and (bigBossesBeaten or 0) >= W.fastModeUnlockBigBosses then
        return W.fastModeMult
    end
    if (pos or 0) >= W.fastZoneKm then
        return W.fastZoneMult
    end
    return 1.0
end

return GameConfig
