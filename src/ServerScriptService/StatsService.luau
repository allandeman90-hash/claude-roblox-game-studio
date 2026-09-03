--==============================================================
-- StatsService  (ModuleScript - ServerScriptService)
--
-- Computes the player's DERIVED stats from the 5 allocatable stats
-- (POW / INT / VIT / SPD / LUK) and GameConfig constants.
-- Server-only. Stateless: operates in place on a state table passed in.
--
-- Stat semantics (GAME_SPEC.md 3.1):
--   POW -> physical ATK  (baseAtk + POW * atkPerPow + equipAtk)             [WIRED]
--   INT -> magic power   (baseMagicAtk + INT * magicPerInt + equipMagicAtk) [WIRED - etape 3]
--   VIT -> Max HP        (VIT * 5 + equipped-armor HP)                      [WIRED]
--   LUK -> crit rate     (LUK / 10000, GameConfig.Combat.critRate)          [WIRED - etape 3]
--   SPD -> attack cadence (base / (1 + SPD * spdCadenceCoef), floored)       [WIRED - etape 3.7]
--
-- StatsService produces the DERIVED values on `st`; DamageService rolls the
-- crit and applies the enemy->player mitigation. Equipment bonuses come from
-- EquipmentService.getStatBonuses: { atk, magicAtk, def, res, hp }.
-- `.res` is unused until magic bosses (later etape).
--
-- The old prototype effects (INT -> +XP, SPD -> +move speed, LUK -> +gold)
-- were removed from CombatServer in etape 2.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local EquipmentService = require(script.Parent:WaitForChild("EquipmentService"))

local StatsService = {}

-- Recompute derived stats in place. Expects st.statPow / statInt / statVit /
-- statSpd / statLuk. Sets st.playerMaxHp, st.playerPhysAtk, st.playerMagAtk,
-- st.playerAtk (effective), st.playerDamageType, st.playerDef, st.playerCritRate,
-- st.attackInterval, and clamps st.playerHp to the new maximum.
function StatsService.recalc(player, st)
    local P = GameConfig.Player
    local C = GameConfig.Combat
    local EQ = GameConfig.Equipment
    local S = P.startingStats
    -- { weaponPct, damageType, armorDef, armorRes, armorPieces }  (etape 4.0)
    local bonus = EquipmentService.getStatBonuses(player)

    -- Rebirth (GAME_SPEC.md 8.1 - reworked): every ALLOCATED skill point is
    -- (1 + 0.10 * rebirths) more effective. The tiny starting stats are NOT
    -- multiplied - only what the player chose to spend.
    local equipped = EquipmentService.getEquipped(player)
    local weapon = equipped and equipped.arme
    local classKey = (weapon and weapon.voie == "mage") and "mage" or "warrior"
    local auto = GameConfig.ClassGrowth.statsAtLevel(classKey, st.playerLevel)
    local sm = GameConfig.Rebirth.skillMult(st.rebirths or 0)
    local function eff(cur, start, autoValue)
        local earned = math.max(0, autoValue - start) + math.max(0, (cur or start) - start)
        return start + earned * sm
    end
    local effPow = eff(st.statPow, S.pow, auto.pow)
    local effInt = eff(st.statInt, S.int, auto.int)
    local effVit = eff(st.statVit, S.vit, auto.vit)
    local effSpd = eff(st.statSpd, S.spd, auto.spd)
    local effLuk = eff(st.statLuk, S.luk, auto.luk)
    st.effectiveStatPow, st.effectiveStatInt = effPow, effInt
    st.effectiveStatVit, st.effectiveStatSpd, st.effectiveStatLuk = effVit, effSpd, effLuk

    -- VIT -> Max HP. Etape 4.0: each equipped armor piece adds hpPctPerPiece of
    -- the VIT-derived pool (multiplicative, NOT zone-scaled - VIT stays the driver).
    st.playerMaxHp = (effVit * P.hpPerVit) * (1 + bonus.armorPieces * EQ.hpPctPerPiece)

    -- Stat-only offensive bases.
    local basePhys = P.baseAtk      + effPow * P.atkPerPow
    local baseMag  = P.baseMagicAtk + effInt * P.magicPerInt

    -- Etape 4.0: the equipped weapon is a MULTIPLIER on the matching base, and its
    -- voie picks the effective damage type (GAME_SPEC.md 3.3). No weapon -> physical,
    -- weaponPct 0. A mage weapon boosts magic only (and vice-versa).
    if weapon and weapon.voie == "mage" then
        st.playerMagAtk     = baseMag * (1 + bonus.weaponPct)
        st.playerPhysAtk    = basePhys
        st.playerAtk        = st.playerMagAtk
        st.playerDamageType = "magic"
    else
        st.playerPhysAtk    = basePhys * (1 + bonus.weaponPct)
        st.playerMagAtk     = baseMag
        st.playerAtk        = st.playerPhysAtk
        st.playerDamageType = "physical"
    end

    -- Armor set bonus (GAME_SPEC.md 5.1): damage % on the effective ATK,
    -- HP % on MaxHP, speed % on cadence (applied below). Only fires with
    -- >= 2 pieces of the same set AND voie.
    if bonus.setDamagePct > 0 then
        st.playerAtk = st.playerAtk * (1 + bonus.setDamagePct)
    end
    if bonus.setHpPct > 0 then
        st.playerMaxHp = st.playerMaxHp * (1 + bonus.setHpPct)
    end
    st.setPieces = bonus.setPieces
    st.setName   = bonus.setName

    -- Consumed by DamageService. RES stored for the magic-boss etape.
    st.playerDef      = bonus.armorDef
    st.playerRes      = bonus.armorRes
    st.playerCritRate = C.critRate(effLuk)

    -- Etape 4.2: equipped pet - PASSIVE only. dps -> +% effective damage,
    -- tank -> +% MaxHP and +flat DEF, heal -> campfire regen bonus (read by
    -- CombatServer's campfire loop, not applied here).
    local pet = EquipmentService.getPetEffect(player)
    st.campfireRegenBonusPct = 0
    if pet then
        if pet.dpsPct then
            st.playerAtk = st.playerAtk * (1 + pet.dpsPct)
        end
        if pet.hpPct then
            st.playerMaxHp = st.playerMaxHp * (1 + pet.hpPct)
        end
        if pet.defFlat then
            st.playerDef = st.playerDef + pet.defFlat
        end
        if pet.healPct then
            st.campfireRegenBonusPct = pet.healPct
        end
    end

    -- SPD -> attack cadence (etape 3.7). Faster attacks with diminishing returns,
    -- floored so extreme SPD cannot break the attack loop. The 4-piece set speed
    -- bonus (GAME_SPEC.md 5.1) stacks multiplicatively on top, then re-floored.
    st.attackInterval = C.playerAttackInterval / (1 + math.max(0, effSpd - S.spd) * C.spdCadenceCoef)
    if bonus.setSpeedPct > 0 then
        st.attackInterval = st.attackInterval / (1 + bonus.setSpeedPct)
    end
    st.attackInterval = math.max(C.minAttackInterval, st.attackInterval)

    -- Equipment contribution as equivalent skill points, for the HUD "STAT: n (+m)"
    -- readout: weapon %ATK + set %dmg -> equiv POW (or INT for a mage build) ;
    -- armor HP% + set HP% -> equiv VIT.
    do
        local atkBase  = (st.playerDamageType == "magic") and baseMag or basePhys
        local perPoint = (st.playerDamageType == "magic") and P.magicPerInt or P.atkPerPow
        local weaponGain = atkBase * (bonus.weaponPct or 0)
        local setDmgGain = 0
        if (bonus.setDamagePct or 0) > 0 then
            setDmgGain = (st.playerAtk or 0) - (st.playerAtk or 0) / (1 + bonus.setDamagePct)
        end
        st.gearAtkPoints = math.floor((weaponGain + setDmgGain) / perPoint + 0.5)
        local hpPool = effVit * P.hpPerVit
        local hpGain = hpPool * (bonus.armorPieces * EQ.hpPctPerPiece + (bonus.setHpPct or 0))
        st.gearHpPoints = math.floor(hpGain / P.hpPerVit + 0.5)
        st.gearIsMagic  = (st.playerDamageType == "magic")
    end

    if st.playerHp and st.playerHp > st.playerMaxHp then
        st.playerHp = st.playerMaxHp
    end
end

return StatsService
