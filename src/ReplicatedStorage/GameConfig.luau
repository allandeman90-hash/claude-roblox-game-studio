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
-- DEV / STAFF
--========================================================
-- Roblox UserIds that get dev conveniences (free revive, future test tools).
-- Never grant gameplay advantage that a normal player can't earn - this is
-- for testing only.
GameConfig.DevUserIds = {
    7860387011,   -- Allan (allancorp99)
}

function GameConfig.isDev(userId: number?): boolean
    if type(userId) ~= "number" then return false end
    return table.find(GameConfig.DevUserIds, userId) ~= nil
end

--========================================================
-- DAILY REWARD  (daily-reward-gdd.md)
--========================================================
-- 7-day escalating chain. A "day" = 24 real hours since the last claim; a
-- 48 h grace window lets a player resume mid-chain, past that it resets to J1.
-- Rewards (client renders the teaser strings; the server applies `grants`):
--   boost  -> profile.boosts[cat] = { mult, expiresAt } (RewardService reads it)
--   pet    -> a rolled pet from the player's current zone (+ note the GDD bonus)
--   armor  -> N Epic armor pieces from the zone just below the player's record
--   weapon -> 1 Epic weapon of the player's voie, +weaponBonus stats
-- TODO: J2/J4 also grant Donjon keys in the GDD - the Daily Dungeon does not
-- exist yet, so the key grant is omitted (see missions/daily-dungeon tracks).
GameConfig.DailyReward = {
    chainLength      = 7,
    cooldownHours    = 24,
    graceHours       = 48,
    boostMult        = 2.0,
    weaponBonusJ7    = 1.30,
    setPiecesJ6      = 5,   -- casque/plastron/jambieres/bottes/gants
    familiarBonusJ3  = 1.20,   -- +20% vs a normally-looted pet of the same tier

    -- One entry per day. `label` is shown in the popup; `grants` is applied server-side.
    days = {
        [1] = { label = "Boost Or + XP x2 - 4 h",
            grants = { { kind = "boost", cats = { "gold", "xp" }, hours = 4 } } },
        [2] = { label = "Boost Or + XP x2 - 6 h",
            grants = { { kind = "boost", cats = { "gold", "xp" }, hours = 6 } } },
        [3] = { label = "Familier de ta couche (+20 %) + boost 6 h",
            grants = {
                { kind = "boost", cats = { "gold", "xp" }, hours = 6 },
                { kind = "pet" },
            } },
        [4] = { label = "Boost Or + XP x2 - 6 h",
            grants = { { kind = "boost", cats = { "gold", "xp" }, hours = 6 } } },
        [5] = { label = "Gros boost Or + XP + Butin x2 - 8 h",
            grants = { { kind = "boost", cats = { "gold", "xp", "loot" }, hours = 8 } } },
        [6] = { label = "Set d'armure Epique complet",
            grants = {
                { kind = "boost", cats = { "gold", "xp" }, hours = 6 },
                { kind = "armor", pieces = 5 },
            } },
        [7] = { label = "Arme d'exception (+30 %)",
            grants = {
                { kind = "boost", cats = { "gold", "xp", "loot" }, hours = 8 },
                { kind = "weapon" },
            } },
    },
}

-- Given `lastClaimTime` (0 = never) and `currentDay` (1..7), return
--   day       : the day to claim NOW (1..7)
--   canClaim  : true if the 24 h cooldown has elapsed (or never claimed)
--   chainReset: true if the chain broke (past the grace window) -> back to J1
--   nextResetAt : unix time the current progress is lost if not claimed
function GameConfig.DailyReward.evaluate(lastClaimTime: number?, currentDay: number?)
    local D = GameConfig.DailyReward
    local now = os.time()
    local last = tonumber(lastClaimTime) or 0
    local day = math.clamp(math.floor(tonumber(currentDay) or 1), 1, D.chainLength)
    local elapsedH = (now - last) / 3600

    if last == 0 then
        return { day = 1, canClaim = true, chainReset = true, nextResetAt = now + D.graceHours * 3600 }
    end
    if elapsedH < D.cooldownHours then
        -- already claimed today; the chain is safe until grace runs out
        return { day = day, canClaim = false, chainReset = false,
            nextResetAt = last + D.graceHours * 3600 }
    end
    if elapsedH >= D.graceHours then
        return { day = 1, canClaim = true, chainReset = true, nextResetAt = now + D.graceHours * 3600 }
    end
    -- inside the window: advance one day (wrap 7 -> 1)
    local nextDay = (day % D.chainLength) + 1
    return { day = nextDay, canClaim = true, chainReset = false, nextResetAt = now + D.graceHours * 3600 }
end

--========================================================
-- MISSIONS  (missions-gdd.md)
--========================================================
-- 10/day (7 easy / 2 hard / 1 very hard), reset at UTC midnight (a day index,
-- not a rolling cooldown like Daily Reward - missions-gdd SS2.3 is explicit
-- about "minuit serveur"). Every objective type maps to a system that is
-- ACTUALLY LIVE today (kills, km, level, gold) on purpose: the GDD lists
-- pouvoirs / forge / donjon / codex too, but none of those exist yet, and a
-- mission for a system that cannot be interacted with is a mission that can
-- never be "impossible" (SS2.7 grays it out) - it is *permanently* impossible,
-- which is worse. TODO: fold those objective types in once Track G (abilities)
-- / the Daily Dungeon / the Codex land.
GameConfig.Missions = {
    missionsPerDay = 10,
    easyCount = 7,
    hardCount = 2,
    veryHardCount = 1,
    skillPointRewards = { easy = 1, hard = 2, veryHard = 3 },
    bonusForAllCompleted = 2,
    orRewards = { easy = 60, hard = 140, veryHard = 220 },
    changeFreePerDay = 1,
}

-- Current UTC day index. Missions regenerate whenever this changes vs the
-- stored dayKey - a real "reset at midnight", unlike Daily Reward's grace window.
function GameConfig.Missions.dayKey(t: number?)
    return math.floor((t or os.time()) / 86400)
end

--========================================================
-- HERO CREATION  (02-maquettes SS02, master-gdd SS5.2)
--========================================================
GameConfig.Hero = {
    -- The choice that matters: voie sets the tier-1 weapon the FTUE grants on
    -- the first kill (-> class, per master-gdd SS5.2 "classe pilotee par l'arme").
    starterWeaponByVoie = {
        guerrier = "epee_courte",     -- "Epee en bois"
        mage     = "baguette_simple", -- "Badine felee"
    },
    -- 4 free cosmetic tints (others in the shop later). Applied as an ImageColor3
    -- on the hero sprite. `acier` = neutral default.
    tints = {
        acier   = Color3.fromRGB(210, 214, 222),
        sang    = Color3.fromRGB(196, 88, 78),
        foret   = Color3.fromRGB(104, 156, 96),
        nuit    = Color3.fromRGB(108, 116, 168),
    },
    tintOrder = { "acier", "sang", "foret", "nuit" },
    nameMinLen = 3,
    nameMaxLen = 16,
}

function GameConfig.Hero.isValidVoie(v: any): boolean
    return v == "guerrier" or v == "mage"
end

function GameConfig.Hero.isValidTint(t: any): boolean
    return type(t) == "string" and GameConfig.Hero.tints[t] ~= nil
end

--========================================================
-- LEVEL & XP
--========================================================
GameConfig.Level = {
    -- [D1 - validated 2026-08-31] Stats rise AUTOMATICALLY on level-up: this many
    -- points/level, split by GameConfig.ClassGrowth (class x subclass).
    autoPointsPerLevel   = 4,
    -- Plus ONE free player-allocated point every N levels (1:1, any stat, SPD <= 200).
    freePointEveryLevels = 5,
    -- [DEPRECATED alias] the interim MANUAL-allocation code (CombatServer line 114,
    -- StatsService) reads this until Track G1 flips it to the auto model. Kept equal
    -- to autoPointsPerLevel so the interim hand-out already matches D1 (5 -> 4).
    statPointsPerLevel   = 4,

    -- [ACTIVE - Classic-style progression] Enemy XP rises at every level, while
    -- the target kills per level rises more quickly. The additive level term
    -- guarantees strict growth even when the exponential rounds to the same int.
    enemyXpBase          = 8,
    enemyXpGrowth        = 1.085,
    killsPerLevelBase    = 8,
    killsPerLevelGrowth  = 1.02,
}

-- Base XP from a standard enemy of level N. Strictly increasing for every N.
function GameConfig.Level.xpForEnemyLevel(n)
    local level = math.max(1, math.floor(n or 1))
    local exponent = level - 1
    return math.round(GameConfig.Level.enemyXpBase * GameConfig.Level.enemyXpGrowth ^ exponent) + exponent
end

-- XP required to advance FROM level N to N+1. At equal level this targets
-- 8 kills at L1, ~13 at L25, ~21 at L50 and ~57 at L100 before role modifiers.
function GameConfig.Level.xpForNextLevel(n)
    local level = math.max(1, math.floor(n or 1))
    local exponent = level - 1
    local targetKills = GameConfig.Level.killsPerLevelBase * GameConfig.Level.killsPerLevelGrowth ^ exponent
    return math.round(GameConfig.Level.xpForEnemyLevel(level) * targetKills)
end

-- Level-colour reward curve. Harder enemies pay slightly more, but old/grey
-- enemies keep their full base XP: revisiting earlier kilometres must remain a
-- valid source of XP, gold and equipment instead of becoming dead content.
function GameConfig.Level.killXpLevelMultiplier(playerLevel, enemyLevel)
    local gap = math.floor(enemyLevel or 1) - math.floor(playerLevel or 1)
    if gap >= 5 then return 1.20 end
    if gap >= 0 then return 1 + gap * 0.05 end
    return 1
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

    -- [D6 - validated 2026-09-01] Level-gap penalty. Gear scales geometrically
    -- (x1.30/zone) but mobs scale linearly, so a geared player would blow past
    -- the level cap and the Rebirth pitch goes soft. When a mob out-levels the
    -- player by more than `threshold`, the player deals less and takes more,
    -- proportional to the excess gap. This is what makes the level wall bite
    -- (felt wall ~km 33-42; raise dealtStep to ~0.035 to tighten to km 30-37).
    -- Applied in DamageService (both directions).
    -- [C2 - 2026-09-01] dealtStep 0.028 -> 0.035 : felt wall ~km 30-37, closer to
    -- the Q26 target (25-35). Tune down in the K3 playtest if the wall bites early.
    levelGap = {
        threshold  = 5,      -- free grace before the penalty starts
        dealtStep  = 0.035,  -- -3.5% player damage dealt per level of excess gap
        dealtFloor = 0.12,   -- player always deals at least 12%
        takenStep  = 0.022,  -- +2.2% damage taken per level of excess gap
        takenCap   = 3.0,    -- damage taken never more than x3
    },
}

-- [ACTIVE - D1 validated 2026-08-31] Critical chance = min(1, LUK / 2500).
-- (Was LUK / 10000 - too weak to ever matter.) Capped at 1.0 (Edge Case: crit > 100%).
function GameConfig.Combat.critRate(luk)
    return math.min(1, math.max(0, luk or 0) / 2500)
end

-- [D1] Destroyer subclass ONLY: dedicated crit scaling (~17% at level 100, no gear;
-- scales hard with LUK gear + talents). Base / other classes use critRate above.
function GameConfig.Combat.critRateDestroyer(luk, level)
    return math.min(1, math.max(0, luk or 0) / 1800 + 0.0012 * math.max(1, level or 1))
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
-- CLASS GROWTH  (D1 - validated 2026-08-31)
--========================================================
-- The 4 auto points/level (Level.autoPointsPerLevel) are split across the 5 stats
-- by these per-class / per-subclass percentages (each row sums to 1.0). SPD share
-- is design-capped at 0.22. "warrior" / "mage" = the neutral tables used before
-- Rebirth 5; berserker/guardian (warrior R5), destroyer/sage (mage R5).
-- Free points + earned skill points (Q29) are added ON TOP by StatsService.
GameConfig.ClassGrowth = {
    warrior   = { pow = 0.45, int = 0.00, vit = 0.40, spd = 0.10, luk = 0.05 },
    mage      = { pow = 0.00, int = 0.31, vit = 0.49, spd = 0.10, luk = 0.10 },
    berserker = { pow = 0.42, int = 0.00, vit = 0.28, spd = 0.22, luk = 0.08 },
    guardian  = { pow = 0.35, int = 0.00, vit = 0.55, spd = 0.05, luk = 0.05 },
    destroyer = { pow = 0.00, int = 0.40, vit = 0.30, spd = 0.08, luk = 0.22 },
    sage      = { pow = 0.00, int = 0.34, vit = 0.52, spd = 0.07, luk = 0.07 },
}

-- Auto-derived stats at `level` for a class key (startingStats + the auto pool
-- split by the class %). Does NOT include free points or earned skill points.
--   warrior L100 -> pow ~180, vit ~164 (HP 820), spd ~41, luk ~21
function GameConfig.ClassGrowth.statsAtLevel(classKey, level)
    local split = GameConfig.ClassGrowth[classKey] or GameConfig.ClassGrowth.warrior
    local S = GameConfig.Player.startingStats
    local L = math.max(1, math.floor(level or 1))
    local pool = GameConfig.Level.autoPointsPerLevel * (L - 1)
    return {
        pow = S.pow + split.pow * pool,
        int = S.int + split.int * pool,
        vit = S.vit + split.vit * pool,
        spd = math.min(GameConfig.Combat.spdMax, S.spd + split.spd * pool),
        luk = S.luk + split.luk * pool,
    }
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

    weaponBase    = 100,    -- [D4] zone-1 weapon power. A zone-appropriate shop weapon
                            -- ~doubles ATK (weaponPct = 100/100 = +100%). Was 8 (+8%).
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
-- INVENTORY  (Inventory Sprint Day 1 - design/specs/inventory-implementation-spec.md §11)
--========================================================
-- Unique-instance bag: every dropped/purchased item is its own itemKey (never
-- stacks). Capacity is base + an optional purchasable bonus pack, hard-capped
-- at maxCapacity. Rate limits here are consumed by InventoryService's remote
-- handlers (Day 2) - separate from the generic GameConfig.Security.remotePerType
-- sliding window CombatServer already enforces on the multiplexed dispatcher.
GameConfig.Inventory = {
    baseCapacity                 = 100,
    bonusCapacity                = 100,
    maxCapacity                  = 200,
    bagFullTimeoutSeconds        = 30,
    weaponChangeRateLimitPerSec  = 2,
    removeItemRateLimitPerSec    = 2,
    equipItemRateLimitPerSec     = 2,
    listInventoryRateLimitPerSec = 5,
}

--========================================================
-- UI  (design/gdd/ui-ux-gdd.md §8 - design language shared by every screen)
--========================================================
-- Pure presentation tuning: touch targets, contrast floor, spacing unit,
-- animation timings, grid columns, accessibility bounds. Consumed by
-- StyleConstants.luau (ReplicatedStorage/Shared) and every UI screen module -
-- never read directly by gameplay/server code.
GameConfig.Ui = {
    minTouchTargetPx        = 44,     -- WCAG / mobile minimum tap target
    minContrastRatio        = 4.5,    -- WCAG AA text contrast floor
    baseSpacingPx           = 4,      -- spacing unit; scale = 4/8/12/16/24/32
    buttonPressTweenSeconds = 0.10,   -- ui-ux-gdd 2.8: 0.08-0.12s button feedback
    modalTweenSeconds       = 0.22,   -- ui-ux-gdd 2.8: 0.20-0.25s modal open
    maxFlashHz              = 3,      -- epilepsy-safety cap on any flashing effect
    fontScaleMin            = 0.85,
    fontScaleMax            = 1.5,
    fontScaleDefault        = 1.0,
    gridColumnsStandard     = 7,      -- ui-ux-gdd 2.6: standard item grid width
    gridColumnsMinNarrow    = 5,      -- narrow-screen fallback (ui-ux-gdd 7.1)
    setPrefsRateLimitPerSec = 1,      -- Ui_SetPrefs remote budget (not yet wired - see wiki gap)
}

--========================================================
-- PETS  (etape 4.2 revised - scaling by LEVEL, not by Couche)
--========================================================
-- A pet has two levels:
--   sourceLevel : the level of the enemy/boss it dropped from. FIXED. Sets the
--                 BASE floor - a pet from a lvl-500 boss starts stronger than one
--                 from a lvl-100 boss even at petLevel 1.
--   petLevel    : starts at 1, climbs toward the player's level while the pet is
--                 EQUIPPED (like a Pokémon). No hard cap from the source.
-- Effect magnitude = base * effectMul(effLevel) * rarityMult, where
--   effLevel  = max(petLevel, floor(sourceLevel * sourceFloorFrac))
--   effectMul = 1 + (effLevel - 1) * petLevelStep   (clamped to petLevelCap)
--   dps  : +dpsPct of the player's effective damage        (passive, always on)
--   tank : +hpPct of MaxHP  AND  +defFlat flat DEF          (passive, always on)
--   heal : +healPct of MaxHP every healTickSeconds (combat AND exploration);
--          at a campfire the tick also adds healCampfireBasePct.
GameConfig.Pets = {
    dpsPctBase    = 2.0,    -- % of damage at effLevel 1  (-> /100)
    tankHpPctBase = 1.5,    -- % of MaxHP at effLevel 1
    tankDefBase   = 3.0,    -- flat DEF at effLevel 1

    petLevelStep       = 0.02, -- +2% effect per effective pet level
    petLevelCap        = 40,   -- effectMul hard cap (x)
    sourceFloorFrac    = 0.25, -- a fresh drop starts at 25% of its source-level tier
    -- Pet leveling: the equipped pet earns the same XP the hero earns per kill
    -- (GameConfig.Pets.petXpToNext curve) and is hard-capped at the hero's level.
    -- See EquipmentService.grantPetXp.

    -- HEAL role. healPctByRarity is the % of MaxHP restored per tick at effLevel 1;
    -- it scales by effectMul like the other roles.
    healTickSeconds       = 6,
    healPctByRarity       = { commun = 0.015, rare = 0.025, epique = 0.04, legendaire = 0.06, mythique = 0.09 },
    healCampfireBasePct   = 0.05,   -- +5% of MaxHP per tick while resting at a campfire (FLAT, unscaled)
    healCleanseDebuffRank = 3,      -- epique+ : removes one debuff / malus each tick
    healCleanseStunRank   = 4,      -- legendaire+ : also removes stun / etourdissement
    healReviveRank        = 5,      -- mythique : revives the hero once per run
    healReviveHpPct       = 0.30,
}

local PET_RARITY_RANK = { commun = 1, rare = 2, epique = 3, legendaire = 4, mythique = 5 }

-- Which numeric effect keys the isStarter x0.5 nerf is allowed to touch.
GameConfig.Pets.SCALABLE_KEYS = { dpsPct = true, hpPct = true, defFlat = true, healPct = true }

local function petEffLevel(sourceLevel, petLevel)
    local floor = math.floor(math.max(1, sourceLevel or 1) * GameConfig.Pets.sourceFloorFrac)
    return math.max(1, math.floor(petLevel or 1), floor)
end

function GameConfig.Pets.effectMul(sourceLevel, petLevel)
    local P = GameConfig.Pets
    local eff = petEffLevel(sourceLevel, petLevel)
    return math.min(P.petLevelCap, 1 + (eff - 1) * P.petLevelStep)
end

-- Passive/periodic effect for a pet role.
--   sourceLevel : enemy level it dropped from (1 for the FTUE starter)
--   petLevel    : the pet's current level (>= 1)
--   rarityId    : "commun" ... "mythique" ; rarityMult its power multiplier
function GameConfig.Pets.effect(role, sourceLevel, petLevel, rarityId, rarityMult)
    local P = GameConfig.Pets
    local mul = P.effectMul(sourceLevel, petLevel)
    local rar = rarityMult or 1
    if role == "dps" then
        return { dpsPct = P.dpsPctBase / 100 * mul * rar }
    elseif role == "tank" then
        return { hpPct = P.tankHpPctBase / 100 * mul * rar, defFlat = math.round(P.tankDefBase * mul * rar) }
    elseif role == "heal" then
        local rank = PET_RARITY_RANK[rarityId] or 1
        return {
            healRole      = true,
            healTickSec   = P.healTickSeconds,
            healPct       = (P.healPctByRarity[rarityId] or P.healPctByRarity.commun) * mul,
            campfirePct   = P.healCampfireBasePct,
            cleanseDebuff = rank >= P.healCleanseDebuffRank,
            cleanseStun   = rank >= P.healCleanseStunRank,
            revives       = rank >= P.healReviveRank,
            reviveHpPct   = P.healReviveHpPct,
        }
    end
    return {}
end

-- XP the equipped pet needs to go from `petLevel` to `petLevel + 1`. Reuses the
-- hero curve on purpose: the pet earns the same XP the hero earns per kill, so a
-- pet that is behind the hero (cheaper early curve) catches up fast, then tracks
-- the hero once it reaches the same level (petLevel is hard-capped at the hero's
-- level in EquipmentService.grantPetXp).
function GameConfig.Pets.petXpToNext(petLevel)
    return GameConfig.Level.xpForNextLevel(math.max(1, math.floor(petLevel or 1)))
end

--========================================================
-- FTUE  (onboarding-gdd.md)
--========================================================
-- Short tutorial: move -> first kill (grants the Épée en bois) -> equip it ->
-- choose one of three eggs -> the starter pet hatches -> "the game is hard"
-- warning. Coach-marks never block. Starter pet id per role lives in
-- EquipmentConfig.StarterPetByRole.
GameConfig.Ftue = {
    schemaVersion               = 1,
    coachMarkAutoDismissSeconds = 8,    -- a coach-mark left alone auto-acks after this
    coachMarkMinDisplaySeconds  = 2,    -- ...but never before this
    suppressMonetizationUntilComplete = true,
}

--========================================================
-- REBIRTH  (GAME_SPEC.md 8.1)
--========================================================
-- Voluntary infinite reset. KEEPS equipment / pets / checkpoints / rebirth
-- count. RESETS level, stat points, gold, distance. Cost is gold: the player
-- must hold >= cost(n) and ends the rebirth with 0 gold.
--   cost(n)  = baseCost * costScaling^(n-1)   (n = the rebirth being bought, 1-indexed)
--   bonus    = crescent skillMult on earned points + additive xpBonusPerRebirth XP
GameConfig.Rebirth = {
    baseCost              = 10000,
    costScaling           = 2.2,
    -- [D2 - validated 2026-08-31] Rebirth makes every EARNED stat point (auto +
    -- free + earned, NEVER the starting stats) more effective on a CRESCENT curve
    -- (Q38: +10% R1, +12% R2, +14% R3 ...). Cumulative:
    --   skillMult(n) = 1 + 0.10n + 0.01*n*(n-1)   (R1 x1.10, R5 x1.70, R10 x2.90)
    -- D6 check: if the first ~50 post-rebirth levels feel trivial, split into a
    -- softer auto-stat mult (1 + 0.06n) + this curve for earned/free only.
    skillEffectPerRebirth = 0.10,   -- [DEPRECATED] display-only; real bonus = skillMult()
    xpBonusPerRebirth     = 0.25,   -- +25% XP per rebirth (additive)
}

-- Gold cost of the n-th rebirth (n >= 1). R1 = 10000, R2 = 22000, R5 = 234256...
function GameConfig.Rebirth.cost(n)
    n = math.max(1, math.floor(n or 1))
    return math.round(GameConfig.Rebirth.baseCost * GameConfig.Rebirth.costScaling ^ (n - 1))
end

-- Crescent effectiveness multiplier on EARNED stat points (Q38). Starting stats
-- are never multiplied. R0 x1.00, R1 x1.10, R2 x1.22, R3 x1.36, R5 x1.70, R10 x2.90.
function GameConfig.Rebirth.skillMult(rebirths)
    local n = math.max(0, math.floor(rebirths or 0))
    return 1 + 0.10 * n + 0.01 * n * (n - 1)
end

function GameConfig.Rebirth.xpMult(rebirths)
    return 1 + GameConfig.Rebirth.xpBonusPerRebirth * math.max(0, rebirths or 0)
end

--========================================================
-- NIGHTMARE  (Mode Cauchemar - D2 validated 2026-08-31)
--========================================================
-- Per-couche infinite difficulty ladder. Global gate: beat the Couche 6 boss.
-- Unlock Cauchemar I at ~killsForTierOne boss kills of a couche, +killsPerExtraTier
-- per tier after. Per tier k (1-indexed): enemies get SEPARATE hp / atk mults (they
-- compound in the no-flee death race, keep each modest), rewards (gold / XP /
-- earned-point faucet / pet-drop RATE) a flat mult, rarity odds UNCHANGED. Enrage
-- timer on bosses ONLY in Nightmare. Hero auto-advances full speed. Permanent.
-- Difficulty (~2.09^k product) outpaces rewards (1.80^k) ~16%/tier => real ceiling.
GameConfig.Nightmare = {
    hpMultPerTier          = 1.55,
    atkMultPerTier         = 1.35,
    rewardMultPerTier      = 1.80,
    enrageBaseSeconds      = 95,    -- enrage(k) = max(floor, base - step*k)
    enrageStepSeconds      = 5,
    enrageFloorSeconds     = 30,
    killsForTierOne        = 100,   -- couche boss kills to unlock Cauchemar I
    killsPerExtraTier      = 25,
    globalGateBossCouche   = 6,
    earnedPointsPerNewTier = 1,     -- permanent, first clear of a new tier per couche only
}

function GameConfig.Nightmare.hpMult(tier)
    return GameConfig.Nightmare.hpMultPerTier ^ math.max(0, tier or 0)
end

function GameConfig.Nightmare.atkMult(tier)
    return GameConfig.Nightmare.atkMultPerTier ^ math.max(0, tier or 0)
end

function GameConfig.Nightmare.rewardMult(tier)
    return GameConfig.Nightmare.rewardMultPerTier ^ math.max(0, tier or 0)
end

function GameConfig.Nightmare.enrageSeconds(tier)
    local N = GameConfig.Nightmare
    return math.max(N.enrageFloorSeconds, N.enrageBaseSeconds - N.enrageStepSeconds * math.max(1, tier or 1))
end

--========================================================
-- SEASON PASS  (S1 - D2 validated 2026-08-31, recalibrated)
--========================================================
-- 8 weeks, 50 tiers, flat xpPerTier. Daily quests alone do NOT finish the pass:
-- a quests-only day = ~550 XP (~55% of a tier) -> quests-only player lands ~tier
-- 33. Completing needs Descente / dungeon / 100 km segments. The 100 km segment
-- award is the one-shot "ENORME" of Q85. Nothing past the last tier (Q88).
GameConfig.SeasonPass = {
    xpPerTier   = 1000,
    tiers       = 50,
    seasonWeeks = 8,
    XpSources = {
        mobCurrentCouche    = 1,      -- mob in the player's current couche
        mobOldCouche        = 0,      -- couche <= record - 2 : anti-AFK
        coucheBoss          = 25,     -- first kill / day / couche
        bigBoss             = 120,    -- first / day
        dungeonFloorCleared = 8,
        dungeonFloorBoss    = 30,
        soloRaidCleared     = 150,
        dailyQuest          = 40,     -- each of the 10  (was 70)
        dailyQuestAllBonus  = 150,    -- all 10 done (was 250) -> quests-only day = 40*10+150 = 550
        segment100kmFirst   = 3000,   -- first time this season, per 100 km segment
        dailyRewardDay7     = 200,
    },
}

--========================================================
-- REWARDS  (multiplier resolver - B5, monetization.md 2 / Tension 5)
--========================================================
-- One resolver (RewardService.multiplier) is the ONLY place reward multipliers
-- are computed. Comfort sources (paid) use max(), NEVER a product, and are hard-
-- capped. Earned sources (Nightmare tier, rebirth bonus) deliberately multiply.
--   multiplier(cat) = min(cap, max(perm pass, premium season, temp boost, Roblox Premium))
--                     * Nightmare.rewardMult(tier) * rebirthBonus[cat](rebirths)
-- Track I fills the real game-pass ids (0 = product not created yet -> inactive).
GameConfig.Rewards = {
    categoryCap = 3,        -- hard cap on the COMFORT multiplier, per category
    dropRateCap = 0.95,     -- a drop chance never exceeds this after the loot multiplier

    permanentPasses = {
        doubleXp   = { id = 0, mult = { xp = 2 } },
        doubleGold = { id = 0, mult = { gold = 2 } },
        vip        = { id = 0, mult = { gold = 1.1 } },   -- +10% gold, folds into the cap
    },

    -- Premium Season pass: retroactive x3 on all four while profile.premiumSeason is set.
    premiumSeason = { mult = { xp = 3, gold = 3, loot = 3, petLoot = 3 } },

    -- Roblox Premium membership (I5): +10% gold, also folded into the cap.
    premiumMembership = { gold = 1.1 },

    -- Rebirth bonus per category (EARNED - deliberately multiplies). Missing
    -- category -> 1.0. xp reuses the existing rebirth XP curve.
    rebirthBonus = {
        xp = function(n) return GameConfig.Rebirth.xpMult(n) end,
    },
}

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
    base       = { maxHp = 50, atk = 6, exp = 10, gold = 8 },   -- [D2] gold anchor 5 -> 8
    zoneScaling  = 1.35,   -- LEGACY: was enemy HP/ATK/gold per zone. Now unused by
                           -- EnemyService (kept for shop weapon/armor power refs).

    -- [ACTIVE - enemy-rebalance] EVERYTHING (HP / ATK / EXP / gold) is driven by
    -- the mob's LEVEL - EnemyService.combatBaseForLevel - not the old 1.35^zone.
    --   HP / ATK : matched to a REFERENCE curve-player `levelLead` levels below
    --     the mob; that player spent max(0, L - levelLead) * refPointsPerLevel
    --     points, refVitShare -> VIT, refPowShare -> POW; HP and ATK then use
    --     separate scales so durability can be punitive without making every hit lethal.
    --   EXP / gold : base.exp / base.gold x (expPerLevel / goldPerLevel)^(L-1),
    --     exponent capped at scaleExpCap. Calibrated so the total ~matches the old
    --     per-zone curve at the boundaries, but tracks the exact mob level.
    levelLead       = 1,
    -- [D1 - validated 2026-08-31] reference enemy's points/level, DECOUPLED from the
    -- player's Level.autoPointsPerLevel (4). 4.7 => a same-level mob out-points a
    -- naked player by ~18% - that gap IS the level-wall pressure (gear/pets/earned
    -- points/first-strike/regen close it). Master difficulty dial (Q119): 4.2 .. 5.0.
    refPointsPerLevel = 4.7,
    refVitShare     = 0.50,   -- reference build: half the earned points into VIT ...
    refPowShare     = 0.42,   -- ... most of the rest into the damage stat (POW)
    enemyHpScale    = 1.80,   -- naked equal-level targets take several hits; gear matters
    enemyAtkScale   = 0.55,   -- dangerous attrition without unavoidable early one-shots
    expPerLevel     = 1.02,   -- EXP  x this per mob level  (1.02^10 ~= 1.22 / zone, unchanged total)
    goldPerLevel    = 1.026,  -- [D2] gold x this per mob level. Flattened 1.03 -> 1.026 so
                              -- gold/climb grows ~x2.0/rebirth vs cost x2.2 (Q64: rebirth keeps the lead).
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

-- monster level = round(km * levelPerKm), for km >= KM_PER_ZONE (couche 1 uses
-- its own gentle km+1 ramp, capped at 9). 1.15 keeps this CONTINUOUS with the
-- couche-1 tutorial: km 10 -> ~12 (couche-1 boss is 10), km 50 -> ~58,
-- km 100 -> ~115. The old 3.5 made km 10 = level 35 -> a 26-level cliff at the
-- couche 1->2 boundary (a lvl-9 player faced lvl-35 mobs, forced couche-1 farm).
-- The real difficulty wall is meant to come from the levelGap penalty + the
-- level cap (100 + 20*rebirths), not from this ramp - see D6 §2/§3.
-- TODO: D6-playthrough-balance.md table (assumes 3.5 + an old XP curve) is stale.
GameConfig.Enemy.levelPerKm = 1.15
function GameConfig.Enemy.levelFromKm(km)
    return math.max(1, math.round((km or 0) * GameConfig.Enemy.levelPerKm))
end

--========================================================
-- SECURITY  (remote rate limiting)
--========================================================
-- Per-player sliding-window caps on CombatEvent. The server rejects (silently)
-- any client message that exceeds either the global cap or its per-type cap
-- within `remoteWindowSec`. No sensitive data here: the client may read these
-- numbers, it just cannot bypass the server-side enforcement.
GameConfig.Security = {
    remoteWindowSec        = 1,     -- sliding window width (seconds)
    remoteGlobalPerWindow  = 20,    -- all types combined / player / window
    remoteDefaultPerWindow = 4,     -- cap for any type not listed below
    remotePerType = {
        move             = 10,   -- held-input, sent on direction change
        allocateStat     = 8,    -- fast clicks to spend earned points (each costs a point)
        requestInventory = 2,    -- UI open / refresh
        buyEquipment     = 4,
        equipItem        = 4,
        unequipItem      = 4,
        -- Mirrors GameConfig.Inventory.*RateLimitPerSec (the Inventory
        -- Sprint's own budget, kept there for InventoryService's Day 2 remote
        -- handlers) - duplicated here too since CombatServer's multiplexed
        -- dispatcher enforces THIS table, not GameConfig.Inventory directly.
        removeItem           = GameConfig.Inventory.removeItemRateLimitPerSec,
        confirmFullBagAction = GameConfig.Inventory.equipItemRateLimitPerSec,
        fuseItem         = 4,
        setFilters       = 4,
        toggleLock       = 4,
        setCheckpoint    = 4,
        ftueAck          = 4,    -- at most 2 acks in the whole tutorial (move, warning)
        restart          = 2,
        setFastMode      = 2,
        campfireContinue = 2,    -- no-op legacy, bounded anyway
        rebirth          = 1,
    },
    -- Anti-abuse log: one warn when a player racks up sustained rejects.
    remoteAbuseRejectThreshold = 40,   -- cumulative rejects before a warn
    remoteAbuseWarnCooldownSec = 30,   -- at most one warn / this many seconds / player
}

--========================================================
-- PERSISTENCE  (save throttling + session lock timing)
--========================================================
-- One throttled writer per server persists every dirty session. Handlers only
-- flag `dirty`; guaranteed writes happen on PlayerRemoving / BindToClose / the
-- rebirth milestone. The session lock is heartbeat-refreshed well inside its
-- stale window so another server never steals a live session. No secrets here.
GameConfig.Persistence = {
    saveTickSec            = 10,   -- throttled-writer loop cadence
    saveMinIntervalSec     = 45,   -- >= 1 write / this many seconds / player (dirty only)
    lockHeartbeatSec       = 30,   -- refresh the lock ts this often (must be < lockStaleSec)
    lockStaleSec           = 90,   -- a lock older than this is assumed abandoned
    bindToCloseDeadlineSec = 25,   -- BindToClose waits up to this for saves to finish
    maxRetries             = 5,    -- DataStore call retries (exponential backoff)
    loadLockRetries        = 3,    -- retries when the stored lock is held by a live session
    loadLockRetryWaitSec   = 2,
}

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
