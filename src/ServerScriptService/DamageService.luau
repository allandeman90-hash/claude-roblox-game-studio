--==============================================================
-- DamageService  (ModuleScript - ServerScriptService)
--
-- Per-hit damage resolution. Server-only, stateless: operates on a
-- combat state table (`st`) passed in.
--
-- Etape 3 - validated model (D1 / D2 option 1 / D3 3a):
--   Player -> Enemy : raw offensive value (st.playerAtk, set by StatsService
--                     = physical or magic per the equipped weapon's voie),
--                     x2 on crit (rate LUK/10000). NO enemy mitigation --
--                     enemies have no DEF/RES.
--   Enemy  -> Player : enemyAtk * 100 / (100 + playerDef)   (physical; normal
--                     mobs). Magic bosses = a later etape.
--
-- The crit roll is the ONLY random element of the V1 damage calculation.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local DamageService = {}

-- The player hits the current enemy. Returns (damage: number, isCrit: boolean).
function DamageService.playerHitEnemy(st)
    local dmg = st.playerAtk or 0
    local isCrit = false
    if math.random() < (st.playerCritRate or 0) then
        dmg = dmg * GameConfig.Combat.critMultiplier
        isCrit = true
    end
    return math.floor(dmg), isCrit
end

-- The current enemy hits the player. Normal enemies are physical; a boss may be
-- magic (st.enemyDamageType == "magic", GAME_SPEC.md 6.2) - then the player's RES
-- reduces it, not DEF. Returns damage >= 0.
function DamageService.enemyHitPlayer(st)
    local mult
    if st.enemyDamageType == "magic" then
        mult = GameConfig.Combat.magicMitigation(st.playerRes or 0)
    else
        mult = GameConfig.Combat.physicalMitigation(st.playerDef or 0)
    end
    local raw = (st.enemyAtk or 0) * mult
    return math.max(0, math.floor(raw))
end

return DamageService
