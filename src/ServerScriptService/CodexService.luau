--==============================================================
-- CodexService  (ModuleScript - ServerScriptService)
--
-- Monster/boss collection (codex-gdd.md). The entry list is NOT a separate
-- content table: it's built once at require-time straight from ZoneConfig
-- (every roster mob already carries a `famille`; boss themes now do too,
-- see ZoneConfig.BossThemes) - so a new zone/boss is Codex-tracked for free,
-- no second list to keep in sync.
--
-- A monster unlocks at GameConfig.Codex.killsToUnlockMonster kills; a boss
-- unlocks on its 1st kill (both boss forms - regular and "big" - share the
-- same entry id, see EnemyService.rollBoss). A family is complete once every
-- entry tagged with that famille is unlocked; completion grants a permanent
-- Or/XP multiplier (RewardService reads it as an "earned" bonus, alongside
-- rebirth - see GameConfig.Codex header for why it's Or/XP only, not stats).
--
-- The "Objets" tab (GDD SS2.6, purely cosmetic per the GDD itself) is
-- deferred - same TODO pattern as DailyRewardService's dungeon key.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local ZoneConfig = require(ReplicatedStorage:WaitForChild("ZoneConfig"))

local CodexService = {}

--===== Build the entry index once (id -> {name, famille, isBoss}) =====
local ENTRIES = {}   -- [enemyId] = { name, famille, isBoss }
local FAMILY_IDS = {}  -- [famille] = { enemyId, enemyId, ... } (stable order)

local function register(id: string?, name: string, famille: string?, isBoss: boolean)
    if not id or ENTRIES[id] then return end   -- skip unnamed / duplicate defs
    famille = famille or "Autre"
    ENTRIES[id] = { name = name, famille = famille, isBoss = isBoss }
    FAMILY_IDS[famille] = FAMILY_IDS[famille] or {}
    table.insert(FAMILY_IDS[famille], id)
end

for _, zone in pairs(ZoneConfig.Zones) do
    for _, def in ipairs(zone.enemies or {}) do
        register(def.id, def.name, def.famille, false)
    end
end
for _, theme in ipairs(ZoneConfig.BossThemes) do
    register(theme.id, theme.name, theme.famille, true)
end

local TOTAL_ENTRIES = 0
for _ in pairs(ENTRIES) do TOTAL_ENTRIES += 1 end

--===== Profile helpers =====
local function codexOf(profile)
    if type(profile.codex) ~= "table" then
        profile.codex = { monsters = {}, families = {} }
    end
    profile.codex.monsters = profile.codex.monsters or {}
    profile.codex.families = profile.codex.families or {}
    return profile.codex
end

-- true if `famille` just BECAME fully unlocked (was not complete before).
local function tryCompleteFamily(codex, famille): boolean
    local fam = codex.families[famille]
    if fam and fam.isComplete then
        return false
    end
    local ids = FAMILY_IDS[famille]
    if not ids then return false end
    for _, id in ipairs(ids) do
        local m = codex.monsters[id]
        if not m or not m.unlocked then
            return false
        end
    end
    codex.families[famille] = {
        isComplete = true,
        completionTime = os.time(),
        bonusApplied = true,
    }
    return true
end

--[[
    Report a kill. Mutates profile.codex in place. Returns
    { unlockedId: string?, familyCompleted: string? } - either field may be
    nil. Caller (CombatServer) is expected to markProfileDirty afterwards,
    same pattern as MissionsService/DailyRewardService.
]]
function CodexService.onKill(profile, enemyId: string?, isBoss: boolean?): { unlockedId: string?, familyCompleted: string? }
    local entry = enemyId and ENTRIES[enemyId]
    if not entry then
        return {}   -- undeveloped-zone filler mob (no id) or unknown id: not Codex-tracked
    end
    local codex = codexOf(profile)
    local m = codex.monsters[enemyId]
    if not m then
        m = { kills = 0, unlocked = false, firstKillTime = nil }
        codex.monsters[enemyId] = m
    end
    if m.unlocked then
        m.kills += 1   -- keep counting past the unlock threshold (GDD SS7.6, stats only)
        return {}
    end
    m.kills += 1
    local threshold = isBoss and 1 or GameConfig.Codex.killsToUnlockMonster
    if m.kills < threshold then
        return {}
    end
    m.unlocked = true
    m.firstKillTime = os.time()
    local completed = tryCompleteFamily(codex, entry.famille)
    return { unlockedId = enemyId, familyCompleted = completed and entry.famille or nil }
end

-- Cumulative Or/XP multiplier from completed families (1 = no bonus).
-- Called by RewardService as an "earned" source, same tier as rebirth.
function CodexService.rewardMult(profile, category: string): number
    if not profile or type(profile.codex) ~= "table" then
        return 1
    end
    local families = profile.codex.families
    if type(families) ~= "table" then
        return 1
    end
    local C = GameConfig.Codex
    -- Rank completed families by their fixed order so "later family on the
    -- same category is bigger" (bonusGrowthPerFamily) is deterministic.
    local nthOnCategory = 0
    local mult = 1
    for _, famille in ipairs(C.familyOrder) do
        if C.familyCategory[famille] == category and families[famille] and families[famille].isComplete then
            nthOnCategory += 1
            mult *= (1 + C.bonusPerFamilyBase * (1 + C.bonusGrowthPerFamily * (nthOnCategory - 1)))
        end
    end
    return mult
end

-- Client-facing snapshot: per-family summary + full per-monster list (small
-- enough to push whole - ~85 entries across every zone combined).
function CodexService.state(profile)
    local codex = codexOf(profile)
    local C = GameConfig.Codex
    local families = {}
    local totalUnlocked, totalKills = 0, 0
    for _, famille in ipairs(C.familyOrder) do
        local ids = FAMILY_IDS[famille] or {}
        local monsters = {}
        local unlockedCount = 0
        for _, id in ipairs(ids) do
            local m = codex.monsters[id]
            local kills = (m and m.kills) or 0
            local unlocked = (m and m.unlocked) or false
            if unlocked then unlockedCount += 1 end
            totalUnlocked += unlocked and 1 or 0
            totalKills += kills
            local entry = ENTRIES[id]
            monsters[#monsters + 1] = {
                id = id,
                name = unlocked and entry.name or "???",
                isBoss = entry.isBoss,
                kills = kills,
                target = entry.isBoss and 1 or C.killsToUnlockMonster,
                unlocked = unlocked,
            }
        end
        local famState = codex.families[famille]
        families[#families + 1] = {
            name = famille,
            monsters = monsters,
            total = #ids,
            unlockedCount = unlockedCount,
            isComplete = famState ~= nil and famState.isComplete or false,
            category = C.familyCategory[famille],
            bonusPct = math.floor((CodexService.rewardMultForFamily(famille) - 1) * 1000 + 0.5) / 10,
        }
    end
    return {
        families = families,
        totalEntries = TOTAL_ENTRIES,
        totalUnlocked = totalUnlocked,
        totalKills = totalKills,
    }
end

-- The % bonus a single completed family contributes on its own category,
-- for display ("Bête complète : +5% Or"). Not cumulative like rewardMult.
function CodexService.rewardMultForFamily(famille: string): number
    local C = GameConfig.Codex
    local category = C.familyCategory[famille]
    if not category then return 1 end
    local nth = 0
    for _, f in ipairs(C.familyOrder) do
        if C.familyCategory[f] == category then
            nth += 1
            if f == famille then
                return 1 + C.bonusPerFamilyBase * (1 + C.bonusGrowthPerFamily * (nth - 1))
            end
        end
    end
    return 1
end

return CodexService
