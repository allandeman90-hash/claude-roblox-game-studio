--==============================================================
-- MissionsService  (ModuleScript - ServerScriptService)
--
-- 10 daily missions (missions-gdd.md): 7 easy / 2 hard / 1 very hard, reset
-- at UTC midnight (GameConfig.Missions.dayKey - a day INDEX, not a rolling
-- cooldown like Daily Reward). Every objective is sized to the player's
-- CURRENT state at generation time (level/position/gold), so a mission is
-- never generated already-impossible (GDD SS2.2 "selon la progression").
--
-- Objective types cover only systems that are actually live today (kills,
-- km, level, gold) - see GameConfig.Missions header for why abilities/forge/
-- donjon/codex objectives are deferred rather than half-implemented.
--
-- Rewards land on the live combat state (`st.statPoints` / `st.gold`), same
-- pattern CombatServer already uses everywhere else; the caller is expected
-- to markProfileDirty afterwards (mirrors DailyRewardService/CombatServer).
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local MissionsService = {}

local function missionsOf(profile)
    if type(profile.missions) ~= "table" then
        profile.missions = { dayKey = 0, list = {}, changeUsedToday = false, bonusApplied = false }
    end
    return profile.missions
end

--===== Objective templates =====
-- Each returns (type, target, label). `st` is the live per-player combat
-- state (CombatServer's `states[player]`); templates size the target off it.
local EASY = {
    function(st)
        local n = math.random(6, 12)
        return "kill_mobs", n, string.format("Tuer %d monstres", n)
    end,
    function(st)
        local delta = math.random(2, 4)
        local target = math.floor(((st.pos or 0) + delta) * 10 + 0.5) / 10
        return "reach_km", target, string.format("Avancer jusqu'a km %.1f", target)
    end,
    function(st)
        local n = math.random(80, 220)
        return "earn_gold", n, string.format("Gagner %d or", n)
    end,
}
local HARD = {
    function(st)
        return "kill_boss", 1, "Battre 1 boss"
    end,
    function(st)
        local target = math.max(2, (st.playerLevel or 1) + math.random(2, 4))
        return "reach_level", target, string.format("Atteindre le niveau %d", target)
    end,
}
local VERY_HARD = {
    function(st)
        local delta = math.random(8, 15)
        local target = math.floor(((st.pos or 0) + delta) * 10 + 0.5) / 10
        return "reach_km", target, string.format("Avancer jusqu'a km %.1f", target)
    end,
    function(st)
        local n = math.random(20, 35)
        return "kill_mobs", n, string.format("Tuer %d monstres", n)
    end,
}

local function rollOne(pool, difficulty, st, id)
    local fn = pool[math.random(1, #pool)]
    local kind, target, label = fn(st)
    return {
        id = id, type = kind, difficulty = difficulty,
        target = target, current = 0, completed = false, label = label,
    }
end

local function generateList(st)
    local M = GameConfig.Missions
    local list, id = {}, 1
    for _ = 1, M.easyCount do
        list[id] = rollOne(EASY, "easy", st, id); id += 1
    end
    for _ = 1, M.hardCount do
        list[id] = rollOne(HARD, "hard", st, id); id += 1
    end
    for _ = 1, M.veryHardCount do
        list[id] = rollOne(VERY_HARD, "veryHard", st, id); id += 1
    end
    return list
end

-- Regenerate the 10 missions if the UTC day rolled over since the last read.
-- Safe to call every join / state request; no-op most of the time.
function MissionsService.ensureFresh(profile, st)
    local m = missionsOf(profile)
    local today = GameConfig.Missions.dayKey()
    if m.dayKey ~= today then
        m.dayKey = today
        m.list = generateList(st or {})
        m.changeUsedToday = false
        m.bonusApplied = false
        return true
    end
    return false
end

-- Client-facing snapshot.
function MissionsService.state(profile)
    local m = missionsOf(profile)
    local M = GameConfig.Missions
    local completedCount = 0
    for _, mission in ipairs(m.list) do
        if mission.completed then completedCount += 1 end
    end
    return {
        list = m.list,
        completedCount = completedCount,
        total = #m.list,
        changeAvailable = not m.changeUsedToday,
        bonusApplied = m.bonusApplied,
        bonusPoints = M.bonusForAllCompleted,
    }
end

-- Grant a mission's reward onto the live combat state + track the all-10 bonus.
local function grantReward(profile, st, difficulty)
    local M = GameConfig.Missions
    st.statPoints = (st.statPoints or 0) + (M.skillPointRewards[difficulty] or 0)
    st.gold = (st.gold or 0) + (M.orRewards[difficulty] or 0)
end

local function checkAllCompletedBonus(profile, st)
    local m = missionsOf(profile)
    if m.bonusApplied then return end
    for _, mission in ipairs(m.list) do
        if not mission.completed then return end
    end
    m.bonusApplied = true
    st.statPoints = (st.statPoints or 0) + GameConfig.Missions.bonusForAllCompleted
end

--[[
    Report progress toward every un-completed mission of `kind`. `mode`:
      "add"       -> current = min(target, current + amount)   (kills, gold)
      "watermark" -> current = min(target, max(current, amount)) (km, level)
    Returns a list of {id, label, reward} for missions that just completed
    (so the caller can push a "missionCompleted" toast), or {} if none.
]]
function MissionsService.onEvent(profile, st, kind: string, amount: number, mode: string?)
    if type(amount) ~= "number" or amount <= 0 then
        return {}
    end
    local m = missionsOf(profile)
    local justCompleted = {}
    for _, mission in ipairs(m.list) do
        if mission.type == kind and not mission.completed then
            if mode == "watermark" then
                mission.current = math.min(mission.target, math.max(mission.current, amount))
            else
                mission.current = math.min(mission.target, mission.current + amount)
            end
            if mission.current >= mission.target then
                mission.completed = true
                grantReward(profile, st, mission.difficulty)
                justCompleted[#justCompleted + 1] = {
                    id = mission.id, label = mission.label,
                    reward = GameConfig.Missions.skillPointRewards[mission.difficulty],
                }
            end
        end
    end
    if #justCompleted > 0 then
        checkAllCompletedBonus(profile, st)
    end
    return justCompleted
end

-- Free re-roll, once per UTC day (missions-gdd SS2.4). Keeps the same
-- difficulty slot, rolls a new objective from that tier's pool.
function MissionsService.changeMission(profile, st, missionId: any): (boolean, string?)
    if type(missionId) ~= "number" or missionId ~= math.floor(missionId) then
        return false, "invalid_id"
    end
    local m = missionsOf(profile)
    if m.changeUsedToday then
        return false, "already_used"
    end
    local mission = m.list[missionId]
    if not mission then
        return false, "invalid_id"
    end
    if mission.completed then
        return false, "already_completed"
    end
    local pool = (mission.difficulty == "easy" and EASY)
        or (mission.difficulty == "hard" and HARD)
        or VERY_HARD
    m.list[missionId] = rollOne(pool, mission.difficulty, st, missionId)
    m.changeUsedToday = true
    return true, nil
end

return MissionsService
