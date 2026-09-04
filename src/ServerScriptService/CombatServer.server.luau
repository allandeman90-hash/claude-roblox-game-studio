--==============================================================
-- CombatServer  (Server Script)
-- All combat logic is server-authoritative.
-- The client only receives display data via RemoteEvent.
--==============================================================

local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Zone system (decor + enemy roster) and progression milestones
-- (rest = campfire + shop every 50 km ; boss every 100 km).
local ZoneService = require(script.Parent:WaitForChild("ZoneService"))
local ShopService = require(script.Parent:WaitForChild("ShopService"))

-- Equipment system (data + 6 slots). Read-only from CombatServer's point
-- of view: it only drives the lifecycle and reads HUD strings. It does
-- NOT feed combat stats yet - that is a later lot.
local EquipmentService = require(script.Parent:WaitForChild("EquipmentService"))

-- Bag storage/mutation (Inventory Sprint Day 1). Still a stub - every call
-- below is pcall-wrapped and degrades to a warn + no-op response instead of
-- crashing until InventoryService's real bodies land Day 2.
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))

-- Server-authoritative FTUE (onboarding-gdd.md). Coach-marks + the tutorial
-- gifts (Épée en bois on the first kill, Fée pet at the end). Never blocks.
local FtueService = require(script.Parent:WaitForChild("FtueService"))
local DailyRewardService = require(script.Parent:WaitForChild("DailyRewardService"))
local MissionsService = require(script.Parent:WaitForChild("MissionsService"))

-- Central tuning constants + formulas (pure data). Etape 1: every value
-- pulled from here equals the previous inline constant EXCEPT the XP curve
-- (validated decision 1). GDD-target values that are not wired yet also
-- live in GameConfig, clearly marked there.
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

-- Player derived-stat calculation (MaxHP, ATK). Etape 2.
local StatsService = require(script.Parent:WaitForChild("StatsService"))

-- Per-hit damage resolution (crit roll + enemy->player mitigation). Etape 3.
local DamageService = require(script.Parent:WaitForChild("DamageService"))

-- Regular-enemy stat generation (x1.35 zone scaling, level = km x 10). Etape EnemyService.
local EnemyService = require(script.Parent:WaitForChild("EnemyService"))

-- Equipment loot rolls (etape 4.1). Grants OWNERSHIP on a kill; never equips.
-- Read-only w.r.t. combat / XP / economy.
local LootService = require(script.Parent:WaitForChild("LootService"))

-- Durable per-player save (GAME_SPEC.md 11). Degrades gracefully when DataStore
-- is unavailable (Studio API access off) - the session just isn't persisted.
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

-- Single reward-multiplier resolver (B5). max() comfort sources (capped) x earned
-- sources (Nightmare tier, rebirth bonus). Applied only in resolvePlayerHit.
local RewardService = require(script.Parent:WaitForChild("RewardService"))

-- Ensure RemoteEvent exists
local combatEvent = ReplicatedStorage:FindFirstChild("CombatEvent")
if not combatEvent then
    combatEvent = Instance.new("RemoteEvent")
    combatEvent.Name = "CombatEvent"
    combatEvent.Parent = ReplicatedStorage
end

--===== Combat constants =====
-- Player attack interval is per-player (SPD -> cadence, st.attackInterval set by
-- StatsService, etape 3.7). Enemy interval is a flat constant.
local ENEMY_INTERVAL = GameConfig.Combat.enemyAttackInterval       -- 2

--===== Remote rate limiting (rules/remotes.md #3, monetization.md §2 protection #2) =====
-- Per-player sliding-window enforcement on CombatEvent. A client message that
-- exceeds the global cap OR its per-type cap within the window is dropped
-- silently. Sustained abuse logs a single throttled warn.
local SEC = GameConfig.Security

type RemoteRecord = { global: { number }, byType: { [string]: { number } } }
local remoteCalls: { [Player]: RemoteRecord } = {}
local remoteRejects: { [Player]: { count: number, lastWarn: number } } = {}

local function pruneWindow(times: { number }, now: number)
    while #times > 0 and times[1] <= now - SEC.remoteWindowSec do
        table.remove(times, 1)
    end
end

local function isRateLimited(player: Player, msgType: string): boolean
    local now = os.clock()
    local rec = remoteCalls[player]
    if not rec then
        rec = { global = {}, byType = {} }
        remoteCalls[player] = rec
    end
    pruneWindow(rec.global, now)
    local typeTimes = rec.byType[msgType]
    if not typeTimes then
        typeTimes = {}
        rec.byType[msgType] = typeTimes
    end
    pruneWindow(typeTimes, now)

    local cap = SEC.remotePerType[msgType] or SEC.remoteDefaultPerWindow
    if #rec.global >= SEC.remoteGlobalPerWindow or #typeTimes >= cap then
        local rej = remoteRejects[player] or { count = 0, lastWarn = 0 }
        remoteRejects[player] = rej
        rej.count += 1
        if rej.count >= SEC.remoteAbuseRejectThreshold
            and now - rej.lastWarn >= SEC.remoteAbuseWarnCooldownSec then
            warn(("[CombatServer] sustained rate-limit: %s (%d), %d rejects, last type=%s")
                :format(player.Name, player.UserId, rej.count, msgType))
            rej.lastWarn = now
            rej.count = 0
        end
        return true
    end

    table.insert(rec.global, now)
    table.insert(typeTimes, now)
    return false
end

--===== Progression constants =====
-- Legacy linear XP rate. This is NOT the player's XP curve (see xpNeeded /
-- GameConfig.Level.xpForNextLevel). It only feeds ZoneService's boss-level
-- heuristic below, kept unchanged. Removed when bosses are reworked.
local XP_PER_LEVEL          = 30
local KM_PER_STEP          = GameConfig.Progression.kmPerStep            -- 0.1 (client scroll unit)
local STEPS_PER_ZONE       = GameConfig.Progression.stepsPerZone        -- 100 (client scroll unit)
local MOVE_SPEED           = GameConfig.World.moveSpeedKmPerSec         -- km / s
local ENCOUNTER_RANGE      = GameConfig.World.encounterRangeKm
local RESPAWN_DIST         = 0.9    -- walk this far from a kill for it to respawn (farming)
local CAMPFIRE_EVERY       = GameConfig.World.campfireEveryKm
local CAMPFIRE_RANGE       = GameConfig.World.campfireRangeKm
local MOB_TICK             = 0.1

--===== Progression helpers =====
-- XP required to advance FROM `level` to `level + 1`.
-- Etape 1 / validated decision 1: MinuteQuest-inspired curve 2*N*(N+1),
-- replacing the old linear `level * 30`.
local function xpNeeded(level)
    return GameConfig.Level.xpForNextLevel(level)
end

local function zoneFromProgress(progress)
    return math.floor(progress / STEPS_PER_ZONE) + 1
end

-- Give the zone system a read-only view of the XP economy so it can
-- derive the boss level. Does not change any of these values.
ZoneService.configureEconomy({
    xpPerLevel = XP_PER_LEVEL,
    xpPerEnemy = GameConfig.Enemy.base.exp,
    kmPerEnemy = 1,
})

--===== State storage =====
local states = {}  -- [player] = stateTable

--===== Helpers =====
-- Stable name/level preview for an encounter slot. Cached per run so the label
-- the player reads while walking up to a mob matches the enemy they then fight
-- (regular-mob name + level are otherwise re-rolled on every startEncounter).
local function previewEncounter(s, enc)
    s.encPreview = s.encPreview or {}
    local pv = s.encPreview[enc.pos]
    if not pv then
        -- Cache the WHOLE rolled descriptor so the preview, the difficulty tint
        -- and the actual fight all use identical stats.
        pv = (enc.kind == "boss") and EnemyService.rollBoss(enc.pos)
            or EnemyService.rollEnemy(enc.pos)
        s.encPreview[enc.pos] = pv
    end
    return pv
end

local function sendUpdate(player, s)
    -- Missions: km watermark (missions-gdd.md), only when the position actually
    -- moved since the last check - sendUpdate fires many times/sec in combat.
    if (s.pos or 0) ~= s._lastMissionsPos then
        s._lastMissionsPos = s.pos or 0
        pcall(function()
            local prof = PlayerDataService.getProfile(player)
            if not prof then return end
            local done = MissionsService.onEvent(prof, s, "reach_km", s.pos or 0, "watermark")
            if #done > 0 then
                markProfileDirty(player, s)
                combatEvent:FireClient(player, { type = "missionsCompleted", missions = done })
            end
        end)
    end

    -- Current STEP's encounters (world-traversal minimap). A zone has
    -- GameConfig.World.stepsPerZone steps; each step has mobsPerStep encounters
    -- (the last step's last slot is the boss).
    local zone = s.zone or 1
    local pos = s.pos or 0
    -- SPD: flat 2 skill points per point, capped at spdMax (client shows the cost).
    local S_START = GameConfig.Player.startingStats
    local spdAtMax = (s.statSpd or S_START.spd) >= GameConfig.Combat.spdMax
    local spdNextCost = spdAtMax and 0 or (GameConfig.Combat.spdCostPerPoint or 2)
    local zoneStart = (zone - 1) * GameConfig.Progression.kmPerZone
    local stepsPerZone = GameConfig.World.stepsPerZone
    local stepLen = GameConfig.Progression.kmPerZone / stepsPerZone
    local curStep = EnemyService.stepForKm(pos)
    local stepBase = zoneStart + (curStep - 1) * stepLen
    local encs, clearedInStep = {}, 0
    for _, enc in ipairs(EnemyService.encountersForZone(zone)) do
        if enc.step == curStep then
            local isCleared = (s.cleared and s.cleared[enc.pos]) == true
            if isCleared then clearedInStep += 1 end
            local pv = previewEncounter(s, enc)
            encs[#encs + 1] = {
                rel     = (enc.pos - stepBase) / stepLen,   -- 0..1 within the step
                kind    = enc.kind,
                slot    = enc.slot,
                cleared = isCleared,
                active  = (s.currentEncounterPos == enc.pos),
                name    = pv.name,
                level   = pv.level,
                id      = pv.id,   -- sprite slug (nil -> client keeps the text label)
                hp      = pv.maxHp,   -- for the client-side difficulty tint
                atk     = pv.atk,
                magic   = pv.damageType == "magic",
            }
        end
    end

    combatEvent:FireClient(player, {
        type        = "update",
        encounters  = encs,
        stepIndex   = curStep,
        stepsPerZone = stepsPerZone,
        stepCleared = clearedInStep,
        stepTotal   = #encs,
        posRelStep  = math.clamp((pos - stepBase) / stepLen, 0, 1),
        posRelZone  = math.clamp((pos - zoneStart) / GameConfig.Progression.kmPerZone, 0, 1),
        deaths      = s.deaths or 0,
        playerHp    = s.playerHp,
        playerMaxHp = s.playerMaxHp,
        enemyHp     = s.enemyHp,
        enemyMaxHp  = s.enemyMaxHp,
        enemyName   = s.enemyName,
        enemyLevel  = s.enemyLevel,
        enemyId     = s.enemyId,                              -- active enemy sprite slug (client art only)
        petRole     = EquipmentService.getPetSpriteRole(player),  -- "dps"|"tank"|"heal"|nil, pet sprite pick
        heroTint    = (function()
            local p = PlayerDataService.getProfile(player)
            return p and p.teinte or "acier"
        end)(),
        boost       = (function()
            -- Active temp boost for the HUD chip: highest mult + soonest expiry.
            local p = PlayerDataService.getProfile(player)
            if not p or type(p.boosts) ~= "table" then return nil end
            local now = os.time()
            local mult, soonest = 1, nil
            for _, entry in pairs(p.boosts) do
                if type(entry) == "table" and (entry.expiresAt or 0) > now then
                    mult = math.max(mult, entry.mult or 1)
                    soonest = math.min(soonest or entry.expiresAt, entry.expiresAt)
                end
            end
            if not soonest then return nil end
            return { mult = mult, secondsLeft = math.max(0, soonest - now) }
        end)(),
        heroName    = (function()
            local p = PlayerDataService.getProfile(player)
            return p and p.heroName or nil
        end)(),
        exp         = s.exp,
        gold        = s.gold,
        playerLevel     = s.playerLevel,
        playerExp       = s.playerExp,
        playerExpToNext = s.playerExpToNext,
        statPoints      = s.statPoints,
        progress        = (s.pos or 0) * 10,   -- client scroll unit
        pos             = s.pos or 0,          -- km position (world traversal)
        moveDir         = s.moveDir,           -- "left" | "right" | nil
        zone            = s.zone,
        isMoving        = s.isMoving,
        milestone       = s.milestone,         -- "campfire" | "boss" | nil
        atCampfire      = s.atCampfire,        -- km of the campfire, or nil
        worldSpeed      = GameConfig.World.speedMult(s.pos, s.fastMode, s.bigBossesBeaten),
        bigBossesBeaten = s.bigBossesBeaten or 0,
        fastMode        = s.fastMode == true,
        fastModeAvailable = (s.bigBossesBeaten or 0) >= GameConfig.World.fastModeUnlockBigBosses,
        distance        = s.pos or 0,
        enemyExp        = s.enemyExp,
        enemyGold       = s.enemyGold,
        gameOver        = s.gameOver or false,
        isDev           = GameConfig.isDev(player.UserId),
        pendingRevives  = (function()
            local p = PlayerDataService.getProfile(player)
            return p and math.max(0, math.floor(p.pendingRevives or 0)) or 0
        end)(),
        statPow         = s.effectiveStatPow or s.statPow,
        statInt         = s.effectiveStatInt or s.statInt,
        statVit         = s.effectiveStatVit or s.statVit,
        statSpd         = s.effectiveStatSpd or s.statSpd,
        statLuk         = s.effectiveStatLuk or s.statLuk,
        spdNextCost     = spdNextCost,
        spdAtMax        = spdAtMax,
        spdMax          = GameConfig.Combat.spdMax,
        equipWeapon     = EquipmentService.describeSlot(player, "arme"),
        equipArmor      = EquipmentService.describeArmorSummary(player),
        equipPet        = EquipmentService.describeSlot(player, "pet"),
        pet             = EquipmentService.getPetProgress(player, s.playerLevel),  -- nil | {name,roleLabel,rarity,level,xp,xpToNext,atMax}
        enemyAtk        = s.enemyAtk,
        enemyIsBoss     = s.isBoss or false,
        enemyIsBigBoss  = s.enemyIsBigBoss or false,
        enemyDamageType = s.enemyDamageType,   -- nil (physical) | "magic"
        enemyAtkSplit   = s.enemyAtkSplit,     -- ATK/INT ratio for the info panel
        playerDef       = s.playerDef or 0,
        playerRes       = s.playerRes or 0,
        playerAtk       = s.playerAtk,
        setPieces       = s.setPieces or 0,
        rebirths        = s.rebirths or 0,
        rebirthCost     = GameConfig.Rebirth.cost((s.rebirths or 0) + 1),
        canRebirth      = (s.gold or 0) >= GameConfig.Rebirth.cost((s.rebirths or 0) + 1),
        checkpointMaxKm = s.checkpointMaxKm or 0,
        bestKm          = s.bestKm or 0,
        selectedCheckpoint = s.selectedCheckpoint or 0,
        rebirthSkillPct = math.floor((GameConfig.Rebirth.skillMult(s.rebirths or 0) - 1) * 100),
        rebirthXpBonus  = math.floor(GameConfig.Rebirth.xpBonusPerRebirth * (s.rebirths or 0) * 100),
        gearAtkPoints   = s.gearAtkPoints or 0,
        gearHpPoints    = s.gearHpPoints or 0,
        gearIsMagic     = s.gearIsMagic or false,
    })
end

local function sendDamage(player, target, amount, isCrit)
    combatEvent:FireClient(player, {
        type   = "damage",
        target = target,
        amount = amount,
        isCrit = isCrit or false,
    })
end

--===== Persistence helpers (GAME_SPEC.md 11) =====
local restartRun  -- forward declaration (real definition below)

local function applyProfileToState(profile, s)
    local start = GameConfig.Player.startingStats
    s.playerLevel        = math.max(1, math.floor(profile.niveau or 1))
    s.playerExp          = math.max(0, profile.xp or 0)
    s.playerExpToNext    = xpNeeded(s.playerLevel)
    s.gold               = math.max(0, math.floor(profile.or_ or 0))
    s.rebirths           = math.max(0, math.floor(profile.rebirths or 0))
    s.checkpointMaxKm    = math.max(0, math.floor((profile.checkpointMax or 0) / 10) * 10)
    s.bestKm             = math.max(0, tonumber(profile.bestKm) or 0)
    s.selectedCheckpoint = math.clamp(math.floor((profile.selectedCheckpoint or 0) / 10) * 10, 0, s.checkpointMaxKm)
    s.statPoints         = math.max(0, math.floor(profile.pointsNonAlloues or 0))
    s.bigBossesBeaten    = math.max(0, math.floor(profile.bigBossesBeaten or 0))
    s.fastMode           = profile.fastMode == true
    s.deaths             = math.max(0, math.floor(profile.deaths or 0))
    local ps = profile.stats or {}
    s.statPow = ps.pow or start.pow
    s.statInt = ps.int or start.int
    s.statVit = ps.vit or start.vit
    s.statSpd = math.min(ps.spd or start.spd, GameConfig.Combat.spdMax)
    s.statLuk = ps.luk or start.luk
end

local function captureProfile(player, s)
    local profile = PlayerDataService.getProfile(player) or PlayerDataService.defaultProfile()
    profile.niveau             = s.playerLevel
    profile.xp                 = s.playerExp
    profile.or_                = s.gold
    profile.distance           = s.pos or 0
    profile.bestKm             = math.max(s.bestKm or 0, tonumber(profile.bestKm) or 0)
    profile.checkpointMax      = s.checkpointMaxKm or 0
    profile.selectedCheckpoint = s.selectedCheckpoint or 0
    profile.rebirths           = s.rebirths or 0
    profile.bigBossesBeaten    = s.bigBossesBeaten or 0
    profile.fastMode           = s.fastMode == true
    profile.deaths             = s.deaths or 0
    profile.pointsNonAlloues   = s.statPoints
    profile.stats = { pow = s.statPow, int = s.statInt, vit = s.statVit, spd = s.statSpd, luk = s.statLuk }
    local eq = EquipmentService.serialize(player)
    profile.equipe = eq.equipe
    -- profile.inventory (v2 bag) is NOT touched here: InventoryService owns
    -- it directly on the live profile object (Day 2), so whatever it already
    -- wrote in place is preserved by simply not overwriting the key.
    profile.owned       = nil   -- legacy field, superseded by inventory
    profile.inventaire  = nil   -- legacy field, migrated to profile.inventory on load
    return profile
end

-- Flag the session dirty with the current state. PlayerDataService's throttled
-- writer persists it within saveMinIntervalSec. Use for every non-milestone
-- change (kills, equip, fuse, filters, fast-mode, death, campfire).
local function markProfileDirty(player, s)
    PlayerDataService.markDirty(player, captureProfile(player, s))
end

-- Guaranteed immediate write. Use only for true milestones (rebirth; later,
-- purchases). PlayerRemoving / BindToClose already flush via release().
local function flushProfileNow(player, s)
    PlayerDataService.flush(player, captureProfile(player, s), true)
end

-- One player hit on the current enemy + full on-kill handling (loot, XP, level,
-- boss clear, campfire, resume). Caller guarantees combat is active and both are
-- alive. Shared by the attack loop and the tap-attack handler.
local resolvePlayerHit
function resolvePlayerHit(player, st)
    local dmg, isCrit = DamageService.playerHitEnemy(st)
    st.enemyHp = st.enemyHp - dmg
    sendDamage(player, "enemy", dmg, isCrit)
    if st.enemyHp > 0 then
        sendUpdate(player, st)
        return
    end
    st.enemyHp = 0

    -- FTUE: the first kill hands the player the "Épée en bois" and opens the
    -- "equip" coach-mark. Idempotent server-side; the st guard just avoids the
    -- per-kill require + lookup once the tutorial is past this beat.
    if not st.ftueFirstKillDone then
        st.ftueFirstKillDone = true
        FtueService.onFirstKill(player)
    end

    -- All reward multipliers come from the one resolver (B5). `st` is the ctx:
    -- it carries .rebirths now and .nightmareTier once G9 wires Nightmare.
    local levelXpMult = GameConfig.Level.killXpLevelMultiplier(st.playerLevel, st.enemyLevel)
    local xpGain   = math.floor(st.enemyExp * levelXpMult * RewardService.multiplier(player, "xp", st))
    local goldGain = math.floor(st.enemyGold * RewardService.multiplier(player, "gold", st))
    st.exp  = st.exp + xpGain
    st.gold = st.gold + goldGain

    -- Missions: kill / boss-kill / gold-earned progress (missions-gdd.md).
    -- Never let a missions bug break combat.
    pcall(function()
        local prof = PlayerDataService.getProfile(player)
        if not prof then return end
        local done = MissionsService.onEvent(prof, st, "kill_mobs", 1)
        if st.isBoss then
            for _, c in ipairs(MissionsService.onEvent(prof, st, "kill_boss", 1)) do done[#done + 1] = c end
        end
        if goldGain > 0 then
            for _, c in ipairs(MissionsService.onEvent(prof, st, "earn_gold", goldGain)) do done[#done + 1] = c end
        end
        if #done > 0 then
            markProfileDirty(player, st)
            combatEvent:FireClient(player, { type = "missionsCompleted", missions = done })
        end
    end)

    local lootMult = RewardService.multiplier(player, "loot", st)
    local petLootMult = RewardService.multiplier(player, "petLoot", st)

    -- Boss loot index: ANY named boss drops its couche set (B6d). bossSetItems
    -- already cycles 1..12, so an index past 12 is fine.
    local bossIdx = nil
    if st.isBoss then
        local km = st.pos or 0
        bossIdx = st.enemyIsBigBoss
            and math.max(1, math.floor(km / 100 + 0.5))   -- big boss: 100/200/... -> 1/2/...
            or math.max(1, math.floor(km / 10 + 0.5))     -- couche boss: ~10/20/... -> 1/2/...
    end
    local drop = LootService.rollDrop(player, { zone = st.zone, isBoss = st.isBoss, isBigBoss = st.enemyIsBigBoss, bossIndex = bossIdx, dropRateMult = lootMult })
    if drop then
        -- InventoryService.addItem is still a Day 1 stub - pcall degrades a
        -- crash into "not kept", exactly like a real "full" bag response
        -- would look to the client, until Day 2 wires the real bag-full flow.
        local ok, kept, reason = pcall(InventoryService.addItem, player, drop)
        if not ok then
            kept, reason = false, "unavailable"
        end
        combatEvent:FireClient(player, {
            type = "loot",
            item = { id = drop.id, nom = drop.nom, slot = drop.slot, voie = drop.voie, rarete = drop.rarete, zone = drop.zone },
            fromBoss = drop.isBoss or false, kept = kept, reason = reason,
        })
    end
    local petDrop = LootService.rollPetDrop(player, { zone = st.zone, isBoss = st.isBoss, isBigBoss = st.enemyIsBigBoss, dropRateMult = petLootMult, enemyLevel = st.enemyLevel })
    if petDrop then
        local ok, kept, reason = pcall(InventoryService.addItem, player, petDrop)
        if not ok then
            kept, reason = false, "unavailable"
        end
        combatEvent:FireClient(player, {
            type = "loot",
            item = { id = petDrop.id, nom = petDrop.nom, slot = "pet", role = petDrop.role, rarete = petDrop.rarete, zone = petDrop.zone },
            fromBoss = petDrop.isBoss or false, kept = kept, reason = reason,
        })
    end

    st.playerExp = st.playerExp + xpGain
    local levelsGained = 0
    while st.playerExp >= st.playerExpToNext do
        st.playerExp       = st.playerExp - st.playerExpToNext
        st.playerLevel     = st.playerLevel + 1
        levelsGained += 1
        if st.playerLevel % GameConfig.Level.freePointEveryLevels == 0 then
            st.statPoints += 1
        end
        st.playerExpToNext = xpNeeded(st.playerLevel)
    end
    -- The equipped pet earns the same XP the hero just earned and levels toward
    -- (never past) the hero's level - a visible bar, not the old instant
    -- catch-up (onboarding-gdd, pets). Runs every kill, hero level-up or not.
    do
        local petLeveled = false
        local ok = pcall(function()
            petLeveled = EquipmentService.grantPetXp(player, xpGain, st.playerLevel)
        end)
        if ok and petLeveled then
            markProfileDirty(player, st)
            if levelsGained == 0 then
                -- A hero level-up recalcs below; a pet-only level-up needs its own.
                StatsService.recalc(player, st)
            end
        end
    end

    if levelsGained > 0 then
        local oldMaxHp = st.playerMaxHp or 0
        StatsService.recalc(player, st)
        -- A level-up grants the newly-created HP, without becoming a full heal.
        st.playerHp = math.min(st.playerMaxHp, st.playerHp + math.max(0, st.playerMaxHp - oldMaxHp))

        pcall(function()
            local prof = PlayerDataService.getProfile(player)
            if not prof then return end
            local done = MissionsService.onEvent(prof, st, "reach_level", st.playerLevel, "watermark")
            if #done > 0 then
                markProfileDirty(player, st)
                combatEvent:FireClient(player, { type = "missionsCompleted", missions = done })
            end
        end)
    end

    local wasBigBoss = false
    if st.isBoss then
        st.enemyDamageType = nil
        st.enemyAtkSplit = nil
        wasBigBoss = st.enemyIsBigBoss == true
        st.enemyIsBigBoss = nil
        ZoneService.markBossDefeated(player)
    end

    -- Mark this encounter cleared (respawns when the player leaves the zone).
    if st.currentEncounterPos then
        st.cleared[st.currentEncounterPos] = true
        st.currentEncounterPos = nil
    end
    if wasBigBoss then
        st.bigBossesBeaten = (st.bigBossesBeaten or 0) + 1
    end
    st.combatActive = false
    st.isBoss = false
    st.milestone = nil
    -- A kill changed xp / gold / (maybe) level / loot / boss counters. Flag the
    -- session; the throttled writer persists it within saveMinIntervalSec.
    markProfileDirty(player, st)
    sendUpdate(player, st)
end

-- Begin a fixed-slot encounter (world-traversal model). `enc` = { pos, kind }.
local function startEncounter(player, st, enc)
    st.combatActive = true
    st.currentEncounterPos = enc.pos
    st.isMoving = false
    -- Use the cached preview roll so the fight matches what the player saw.
    local e = previewEncounter(st, enc)
    if enc.kind == "boss" then
        st.isBoss = true
        st.milestone = "boss"
        st.enemyDamageType = e.damageType
        st.enemyAtkSplit = e.atkSplit
        st.enemyIsBigBoss = e.isBigBoss or false
    else
        st.isBoss = false ; st.milestone = nil
        st.enemyDamageType = nil ; st.enemyAtkSplit = nil ; st.enemyIsBigBoss = nil
    end
    st.enemyName = e.name ; st.enemyLevel = e.level ; st.enemyId = e.id
    st.enemyMaxHp = e.maxHp ; st.enemyHp = e.maxHp
    st.enemyAtk = e.atk ; st.enemyExp = e.exp ; st.enemyGold = e.gold

    -- The HERO always strikes first; both attack timers start counting AFTER it.
    st.atkCharge = 0
    st.enemyCharge = 0
    -- Sync the new enemy to the client BEFORE the opening hit, otherwise the
    -- damage number / HP change lands on the previous enemy's sprite (B6a).
    sendUpdate(player, st)
    resolvePlayerHit(player, st)
end

--===== Combat loops =====
local function startCombat(player)
    local firstEnemy = EnemyService.rollEnemy(0)
    local s = {
        playerHp       = 0,   -- set by StatsService.recalc below
        playerMaxHp    = 0,   -- set by StatsService.recalc below
        playerAtk      = 0,   -- set by StatsService.recalc below
        playerLevel    = 1,
        playerExp      = 0,
        playerExpToNext = xpNeeded(1),
        statPoints     = 0,
        statPow        = GameConfig.Player.startingStats.pow,   -- 10
        statInt        = GameConfig.Player.startingStats.int,   -- 10
        statVit        = GameConfig.Player.startingStats.vit,   -- 20
        statSpd        = GameConfig.Player.startingStats.spd,   -- 10
        statLuk        = GameConfig.Player.startingStats.luk,   -- 0
        gameOver       = false,
        deaths         = 0,        -- total deaths ever (persisted, never reset)
        pos            = 0,        -- position in km (world-traversal model)
        moveDir        = nil,      -- "left" | "right" | nil (held input)
        zone           = 1,
        isMoving       = false,
        isBoss         = false,
        cleared        = {},       -- [posKm] = true : encounters killed this visit
        encPreview     = {},       -- [posKm] = { name, level } : stable slot preview
        currentEncounterPos = nil,
        atCampfire     = nil,      -- km of the campfire the player is resting at, or nil
        bigBossesBeaten = 0,
        fastMode       = false,
        exp            = 0,
        gold           = 0,
        rebirths       = 0,
        checkpointMaxKm = 0,
        bestKm         = 0,
        selectedCheckpoint = 0,
        enemyName      = firstEnemy.name,
        enemyLevel     = firstEnemy.level,
        enemyId        = firstEnemy.id,
        enemyHp        = firstEnemy.maxHp,
        enemyMaxHp     = firstEnemy.maxHp,
        enemyAtk       = firstEnemy.atk,
        enemyExp       = firstEnemy.exp,
        enemyGold      = firstEnemy.gold,
        combatActive   = false,
    }
    states[player] = s

    -- Durable profile (GAME_SPEC.md 11). Returns (profile, status). "locked" means
    -- a live session on another server still holds this player's data - kick rather
    -- than run a phantom, unsaved session.
    local profile, status = PlayerDataService.load(player)
    if status == "locked" then
        states[player] = nil
        player:Kick("Ta partie est encore active sur un autre serveur. Réessaie dans une minute.")
        return
    end
    applyProfileToState(profile, s)
    EquipmentService.restore(player, { equipe = profile.equipe })
    -- profile.inventory (v2 bag, migrated by PlayerDataService.load) is read
    -- directly by InventoryService once it's implemented (Day 2) - no
    -- separate track-state restore needed for the bag side.
    LootService.noteZoneReached(player, math.floor((s.checkpointMaxKm or 0) / 10) + 1)

    -- Start this run at the selected checkpoint (default 0). restartRun does the
    -- zone reset, StatsService.recalc, first-enemy roll and spawns at full HP.
    restartRun(player, s, s.selectedCheckpoint or 0)

    -- Persistence is handled by PlayerDataService's single throttled writer:
    -- handlers only flag the session dirty (see captureAndMark below).

    -- Initial sync
    sendUpdate(player, s)

    -- Hero creation gate (02-maquettes SS02). A brand-new profile has no `voie`:
    -- the client shows the creation screen and the FTUE waits until "createHero"
    -- is received (handled below). The game world still runs underneath.
    local prof = PlayerDataService.getProfile(player)

    -- Repair: a profile hit by the "starter weapon silently swallowed by a
    -- non-empty bag" bug (fixed in InventoryService.grantStarterKit, but an
    -- already-broken save stays broken forever otherwise - the FTUE step is
    -- already past "kill" so onFirstKill never fires again). Idempotent /
    -- no-op once the player owns any weapon.
    if prof and prof.voie ~= nil and prof.ftue and not prof.ftue.completed then
        pcall(InventoryService.grantStarterKit, player, false)
    end

    if prof and prof.voie == nil and not (prof.ftue and prof.ftue.completed) then
        combatEvent:FireClient(player, { type = "needHeroCreation" })
    else
        -- FTUE: send the tutorial state + (re)issue the current coach-mark. Safe
        -- for returning players - onSpawn no-ops once ftue.completed is true.
        FtueService.onSpawn(player)
    end

    -- Daily reward: push the chain state so the menu can show the "a reclamer" band.
    if prof then
        combatEvent:FireClient(player, { type = "dailyState", state = DailyRewardService.state(prof) })
    end

    -- Missions: regenerate the 10-mission list if the UTC day rolled over,
    -- then push the current state.
    if prof then
        MissionsService.ensureFresh(prof, s)
        combatEvent:FireClient(player, { type = "missionsState", state = MissionsService.state(prof) })
    end

    -- Player attack loop. AUTO-ATTACK ONLY. Charge-based (st.atkCharge, reset by
    -- startEncounter so the opening hit is free and the timer starts after it).
    -- Cadence = st.attackInterval (SPD, StatsService), floored at minAttackInterval.
    task.spawn(function()
        while states[player] do
            task.wait(MOB_TICK)
            local st = states[player]
            if not st then break end
            if not (st.combatActive and st.enemyHp > 0 and st.playerHp > 0) then
                st.atkCharge = 0
            else
                local eff = math.max(GameConfig.Combat.minAttackInterval,
                    st.attackInterval or GameConfig.Combat.playerAttackInterval)
                st.atkCharge = (st.atkCharge or 0) + MOB_TICK
                if st.atkCharge >= eff then
                    st.atkCharge = st.atkCharge - eff
                    resolvePlayerHit(player, st)
                end
            end
        end
    end)

    -- Heal-pet tick (etape 4.2 revised). Fires every st.petHeal.tickSec and restores
    -- a % of MaxHP - in combat AND exploration. At a campfire the tick also adds
    -- st.petHeal.campfirePct. Cleanse hooks fire here too (the debuff / stun system
    -- does not exist yet - the calls are no-ops until it lands). Runs on the
    -- enemy-attack loop's tick so it does not need a coroutine of its own.
    local function tickHealPet(st)
        local ph = st.petHeal
        if not (ph and not st.gameOver and (st.playerHp or 0) > 0) then
            st.petHealCharge = 0
            return
        end
        st.petHealCharge = (st.petHealCharge or 0) + MOB_TICK
        if st.petHealCharge < ph.tickSec then
            return
        end
        st.petHealCharge = st.petHealCharge - ph.tickSec
        local resting = st.atCampfire ~= nil and st.moveDir == nil and not st.combatActive
        local pct = ph.pct + (resting and ph.campfirePct or 0)
        if st.playerHp < st.playerMaxHp and pct > 0 then
            local before = st.playerHp
            st.playerHp = math.min(st.playerMaxHp, st.playerHp + st.playerMaxHp * pct)
            local healed = math.floor(st.playerHp - before + 0.5)
            if healed > 0 then
                sendDamage(player, "heal", healed, false)
            end
        end
        -- cleanse hooks (debuff / stun system TBD)
        if ph.cleanseDebuff and st.clearOneDebuff then st.clearOneDebuff(st) end
        if ph.cleanseStun and st.clearStun then st.clearStun(st) end
        sendUpdate(player, st)
    end

    -- Enemy attack loop. Charge-based + reset by startEncounter, so its first swing
    -- lands ENEMY_INTERVAL after the fight begins (never before the hero's opener).
    task.spawn(function()
        while states[player] do
            task.wait(MOB_TICK)
            local st = states[player]
            if not st then break end
            tickHealPet(st)
            if not (st.combatActive and st.enemyHp > 0 and st.playerHp > 0) then
                st.enemyCharge = 0
            else
                st.enemyCharge = (st.enemyCharge or 0) + MOB_TICK
                if st.enemyCharge >= ENEMY_INTERVAL then
                    st.enemyCharge = st.enemyCharge - ENEMY_INTERVAL
                    local dmg = DamageService.enemyHitPlayer(st)
                    st.playerHp = st.playerHp - dmg
                    sendDamage(player, "player", dmg, false)
                    if st.playerHp <= 0 and st.petHeal and st.petHeal.revives and not st.petReviveUsed then
                        -- Mythique heal pet: one revive per run.
                        st.petReviveUsed = true
                        st.playerHp = math.max(1, math.floor(st.playerMaxHp * (st.petHeal.reviveHpPct or 0.30)))
                        sendDamage(player, "revive", st.playerHp, false)
                        combatEvent:FireClient(player, { type = "petRevive" })
                        sendUpdate(player, st)
                    elseif st.playerHp <= 0 then
                        st.playerHp = 0
                        st.combatActive = false
                        st.isMoving = false
                        st.gameOver = true
                        st.moveDir = nil
                        st.deaths = (st.deaths or 0) + 1
                        ShopService.closeShop(player)
                        markProfileDirty(player, st)
                        combatEvent:FireClient(player, {
                            type       = "gameOver",
                            distance   = st.pos or 0,
                        })
                        sendUpdate(player, st)
                    else
                        sendUpdate(player, st)
                    end
                end
            end
        end
    end)

    -- Movement loop (world traversal). The player walks left / right (held input);
    -- reaching an uncleared encounter starts a fight; walking ~3 km away from a
    -- killed encounter respawns it (farming). No monotonic auto-run.
    task.spawn(function()
        while states[player] do
            task.wait(MOB_TICK)
            local st = states[player]
            if not st then break end
            if st.gameOver then
                continue
            end

            -- Walk.
            local walking = st.moveDir ~= nil and not st.combatActive
            if walking then
                local mult = GameConfig.World.speedMult(st.pos, st.fastMode, st.bigBossesBeaten)
                local dir = (st.moveDir == "left") and -1 or 1
                st.pos = math.max(0, st.pos + MOVE_SPEED * mult * MOB_TICK * dir)
            end
            st.isMoving = walking and not st.atCampfire

            -- Decor zone + checkpoint high-water mark + all-time best distance.
            st.zone = ZoneService.updateDistance(player, st.pos)
            LootService.noteZoneReached(player, st.zone)
            local cpKm = math.floor(st.pos / 10) * 10
            if cpKm > (st.checkpointMaxKm or 0) then st.checkpointMaxKm = cpKm end
            if (st.pos or 0) > (st.bestKm or 0) then st.bestKm = st.pos end

            -- Respawn: a killed encounter comes back only once the player has walked
            -- clear of it (~a full step away). Distance-based, not floor-based, so a
            -- boss sitting exactly on a zone boundary (km = Z*10) isn't un-cleared
            -- the instant the hero engages it from just inside the previous step
            -- (which would trap him fighting an endlessly respawning boss).
            for p in pairs(st.cleared) do
                if math.abs((st.pos or 0) - p) > RESPAWN_DIST then
                    st.cleared[p] = nil
                end
            end

            if not st.combatActive then
                -- Campfire (rest + shop) proximity - the 50 km marks.
                local mark = math.floor((st.pos + CAMPFIRE_EVERY * 0.5) / CAMPFIRE_EVERY) * CAMPFIRE_EVERY
                local atCf = (mark > 0 and math.abs(st.pos - mark) <= CAMPFIRE_RANGE) and mark or nil
                if atCf ~= st.atCampfire then
                    st.atCampfire = atCf
                    st.milestone = atCf and "campfire" or st.milestone
                    if not atCf and st.milestone == "campfire" then st.milestone = nil end
                    if atCf then
                        ShopService.openShop(player, { km = atCf })
                        markProfileDirty(player, st)
                    else
                        ShopService.closeShop(player)
                    end
                end
                -- Out-of-combat HP regen: a slow universal trickle, plus the bigger
                -- campfire rate while resting (stopped at a 50 km mark).
                if st.playerHp < st.playerMaxHp then
                    local pct = GameConfig.Player.outOfCombatRegenPct or 0
                    if st.atCampfire and st.moveDir == nil then
                        pct = pct + 0.01 + (st.campfireRegenBonusPct or 0)
                    end
                    if pct > 0 then
                        st.playerHp = math.min(st.playerMaxHp, st.playerHp + st.playerMaxHp * pct * MOB_TICK)
                    end
                end

                -- Encounter: an uncleared mob of the CURRENT step, or a boss on the
                -- shared boundary. Restricting regular mobs to the current step stops
                -- the hero engaging the previous step's mob the instant he crosses
                -- (its slot sits near the boundary).
                if not st.atCampfire then
                    local curStep = EnemyService.stepForKm(st.pos)
                    local zones = { st.zone }
                    if st.zone > 1 then zones[2] = st.zone - 1 end
                    for _, z in ipairs(zones) do
                        for _, enc in ipairs(EnemyService.encountersForZone(z)) do
                            local inScope = enc.kind == "boss" or (z == st.zone and enc.step == curStep)
                            if inScope and not st.cleared[enc.pos]
                                and math.abs(st.pos - enc.pos) <= ENCOUNTER_RANGE then
                                startEncounter(player, st, enc)
                                break
                            end
                        end
                        if st.combatActive then break end
                    end
                end
            end

            sendUpdate(player, st)
        end
    end)
end

-- Reset the current run to `startKm` (a checkpoint). Keeps level / xp / stats /
-- gold / rebirths / equipment / pets; resets distance, HP, enemy, milestones.
function restartRun(player, st, startKm)
    startKm = math.max(0, math.floor((tonumber(startKm) or 0) / 10) * 10)
    if startKm > (st.checkpointMaxKm or 0) then startKm = 0 end
    ZoneService.resetTo(player, startKm)
    st.pos                = startKm
    st.moveDir            = nil
    st.zone               = ZoneService.getZoneId(player)
    st.selectedCheckpoint = startKm
    st.cleared            = {}
    st.encPreview          = {}
    st.currentEncounterPos = nil
    st.atCampfire         = nil
    -- Close any open shop session: after restarting at a checkpoint the old shop
    -- zone is stale and would sell over-tier gear (B5).
    ShopService.closeShop(player)
    StatsService.recalc(player, st)
    st.playerHp        = st.playerMaxHp
    st.isMoving        = false
    st.isBoss          = false
    st.milestone       = nil
    st.combatActive    = false
    st.gameOver        = false
    st.petReviveUsed   = false   -- mythique heal pet: one revive per run
    st.petHealCharge   = 0
    st.enemyDamageType = nil
    st.enemyAtkSplit   = nil
    st.enemyIsBigBoss  = nil
    -- a placeholder enemy so the HUD has something until the first encounter
    local e = EnemyService.rollEnemy(startKm)
    st.enemyName = e.name ; st.enemyLevel = e.level ; st.enemyMaxHp = e.maxHp ; st.enemyId = e.id
    st.enemyAtk = e.atk ; st.enemyExp = e.exp ; st.enemyGold = e.gold ; st.enemyHp = e.maxHp
end

-- Paid / dev revive: back on your feet where you fell (keeps distance, progress,
-- checkpoints), full HP, the killing encounter cleared so you don't instantly
-- re-die. Contrast with restart, which sends you back to the checkpoint.
local function reviveInPlace(player, st)
    if not st.gameOver then
        return false
    end
    StatsService.recalc(player, st)
    st.playerHp        = st.playerMaxHp
    st.gameOver        = false
    st.combatActive    = false
    st.isMoving        = false
    st.moveDir         = nil
    st.isBoss          = false
    st.milestone       = nil
    st.enemyIsBigBoss  = nil
    st.enemyDamageType = nil
    st.enemyAtkSplit   = nil
    if st.currentEncounterPos then
        st.cleared[st.currentEncounterPos] = true
        st.currentEncounterPos = nil
    end
    local e = EnemyService.rollEnemy(st.pos or 0)
    st.enemyName = e.name ; st.enemyLevel = e.level ; st.enemyMaxHp = e.maxHp ; st.enemyId = e.id
    st.enemyAtk = e.atk ; st.enemyExp = e.exp ; st.enemyGold = e.gold ; st.enemyHp = e.maxHp
    markProfileDirty(player, st)
    return true
end

--===== Client request handler (stat allocation, restart, rebirth) =====
combatEvent.OnServerEvent:Connect(function(player, data)
    if type(data) ~= "table" then return end
    local msgType = data.type
    if type(msgType) ~= "string" then return end
    if isRateLimited(player, msgType) then return end
    local st = states[player]
    if not st then return end

    if data.type == "allocateStat" then
        if st.statPoints <= 0 then return end
        local statMap = {
            POW = "statPow",
            INT = "statInt",
            VIT = "statVit",
            SPD = "statSpd",
            LUK = "statLuk",
        }
        local field = statMap[data.stat]
        if not field then return end
        if data.stat == "SPD" then
            -- SPD: hard cap at spdMax; flat spdCostPerPoint (2) skill points per point.
            local C = GameConfig.Combat
            if (st.statSpd or 0) >= C.spdMax then return end
            local cost = C.spdCostPerPoint or 2
            if st.statPoints < cost then return end
            st.statSpd = st.statSpd + 1
            st.statPoints = st.statPoints - cost
        else
            st[field] = st[field] + 1
            st.statPoints = st.statPoints - 1
        end
        StatsService.recalc(player, st)
        sendUpdate(player, st)

    elseif data.type == "buyEquipment" then
        -- Economy action (etape 4.0): spend gold at the open shop. ShopService
        -- validates + deducts gold + grants/equips; we just refresh derived stats.
        -- Mirrors the allocateStat path - no combat mechanic is touched here.
        local ok, err, receipt = ShopService.handlePurchase(player, st, data)
        if ok then
            StatsService.recalc(player, st)
        else
            combatEvent:FireClient(player, { type = "shopError", reason = err })
        end
        sendUpdate(player, st)

    elseif data.type == "move" then
        -- Held movement input (GAME_SPEC.md 2). dir = "left" | "right" | "stop".
        if st.gameOver then return end
        local dir = data.dir
        st.moveDir = (dir == "left" or dir == "right") and dir or nil

    elseif data.type == "setFastMode" then
        -- 2x world speed, unlocked after N big bosses (GAME_SPEC design directive).
        if (st.bigBossesBeaten or 0) >= GameConfig.World.fastModeUnlockBigBosses then
            st.fastMode = data.on == true
            markProfileDirty(player, st)
            sendUpdate(player, st)
        end

    elseif data.type == "campfireContinue" then
        -- Legacy: the player now just walks away from the campfire. No-op kept
        -- so old clients don't error.
        return

    elseif data.type == "devRevive" then
        -- Free revive for the dev list only (GameConfig.DevUserIds). Testing tool.
        if not st.gameOver then return end
        if not GameConfig.isDev(player.UserId) then return end
        if reviveInPlace(player, st) then
            combatEvent:FireClient(player, { type = "reviveGranted", free = true })
            sendUpdate(player, st)
        end

    elseif data.type == "claimRevive" then
        -- Spend one paid revive charge (ReceiptService credited profile.pendingRevives).
        if not st.gameOver then return end
        local profile = PlayerDataService.getProfile(player)
        if not profile or (profile.pendingRevives or 0) <= 0 then
            combatEvent:FireClient(player, { type = "reviveDenied" })
            return
        end
        profile.pendingRevives = profile.pendingRevives - 1
        if reviveInPlace(player, st) then
            combatEvent:FireClient(player, { type = "reviveGranted", free = false })
            sendUpdate(player, st)
        end

    elseif data.type == "restart" then
        if not st.gameOver then return end
        -- KEEP everything; RESET distance to the chosen checkpoint (default 0).
        -- Clamp to an unlocked 10 km checkpoint so a crafted `checkpointKm`
        -- cannot skip the run forward.
        local cp = tonumber(data.checkpointKm) or st.selectedCheckpoint or 0
        cp = math.clamp(math.floor(cp / 10) * 10, 0, st.checkpointMaxKm or 0)
        restartRun(player, st, cp)
        sendUpdate(player, st)

    elseif data.type == "setCheckpoint" then
        -- Castle screen (GAME_SPEC.md 8.2 / 1.3): pick a start point for the next run.
        local km = math.floor((tonumber(data.km) or 0) / 10) * 10
        if km >= 0 and km <= (st.checkpointMaxKm or 0) then
            st.selectedCheckpoint = km
            sendUpdate(player, st)
        end

    elseif data.type == "requestInventory" then
        -- Bag listing moves to InventoryService.getInventory (Day 2 real
        -- body). Stub-safe: on failure, send an empty inventory rather than
        -- crash the dispatcher.
        local ok, inventory = pcall(InventoryService.getInventory, player)
        local _, equipped = pcall(EquipmentService.serialize, player)
        local equippedItems = (type(equipped) == "table" and equipped.equipe) or {}
        if not ok or not inventory then
            combatEvent:FireClient(player, { type = "inventory", slots = {}, items = {}, capacity = GameConfig.Inventory.baseCapacity, equipped = equippedItems })
        else
            combatEvent:FireClient(player, { type = "inventory", items = inventory.items, capacity = inventory.capacity, equipped = equippedItems })
        end

    elseif data.type == "fuseItem" then
        -- Fusion is out of v0.1 scope per the Inventory Sprint plan (unique
        -- instances need a new fusion model against economy-gdd.md §2.5).
        combatEvent:FireClient(player, { type = "fuseResult", ok = false, reason = "not_available" })

    elseif data.type == "setFilters" then
        local ok = pcall(InventoryService.setFilters, player, data.rareteMin, data.voie)
        if ok then
            markProfileDirty(player, st)
        end
        -- No InventoryService.getFilters stub yet (Day 2) - echo the request
        -- back rather than call a function that doesn't exist.
        combatEvent:FireClient(player, { type = "inventory",
            filters = { rareteMin = data.rareteMin, guerrier = data.guerrier, mage = data.mage } })

    elseif data.type == "toggleLock" then
        pcall(InventoryService.toggleLock, player, data.itemKey)
        combatEvent:FireClient(player, { type = "inventory" })

    elseif data.type == "removeItem" then
        -- Deliberate bag discard (quick-sell / "drop"). itemKey is
        -- client-supplied but InventoryService.removeItem validates it
        -- (existence, lock state, not-equipped) before mutating anything.
        local pcallOk, removed, reason = pcall(InventoryService.removeItem, player, data.itemKey)
        combatEvent:FireClient(player, {
            type = "itemRemoved",
            ok = pcallOk and removed == true,
            reason = pcallOk and reason or "unavailable",
        })

    elseif data.type == "confirmFullBagAction" then
        -- Resolves the 30s bag-full prompt opened by InventoryService.addItem
        -- (choice = "keep_new" | "keep_old" | "drop_both"). Both choice and
        -- targetItemKey are client-supplied but validated inside
        -- InventoryService.confirmFullBagAction before anything is mutated.
        local pcallOk, confirmed, reason = pcall(
            InventoryService.confirmFullBagAction, player, data.choice, data.targetItemKey
        )
        combatEvent:FireClient(player, {
            type = "bagActionConfirmed",
            ok = pcallOk and confirmed == true,
            reason = pcallOk and reason or "unavailable",
        })

    elseif data.type == "equipItem" then
        -- Equip an OWNED item by itemKey (Inventory Sprint remote contract
        -- §7: InventoryService derives the slot from itemType, never the
        -- client-supplied slot).
        local pcallOk, equipped, reason = pcall(InventoryService.equipItem, player, data.itemKey)
        if pcallOk and equipped then
            StatsService.recalc(player, st)
            markProfileDirty(player, st)
            FtueService.onEquip(player)   -- FTUE: advances the "equip" tutorial beat
        else
            combatEvent:FireClient(player, { type = "equipError", reason = pcallOk and reason or "unavailable" })
        end
        sendUpdate(player, st)

    elseif data.type == "ftueAck" then
        -- FTUE coach-mark dismissed (or auto-dismissed) client-side. Server
        -- revalidates the stepId before advancing (FtueService.ackStep).
        FtueService.ackStep(player, data.stepId)

    elseif data.type == "ftueChoosePet" then
        -- FTUE: player picked one of the three eggs. Server grants that pet.
        FtueService.choosePet(player, data.role)

    elseif data.type == "ftueRequestState" then
        -- Client (re)connected its FTUE listener - resend state + current step.
        FtueService.onSpawn(player)

    elseif data.type == "claimDailyReward" then
        local prof = PlayerDataService.getProfile(player)
        if not prof then
            combatEvent:FireClient(player, { type = "dailyRewardClaimed", ok = false, reason = "no_profile" })
            return
        end
        local res = DailyRewardService.claim(player, prof, st)
        combatEvent:FireClient(player, {
            type = "dailyRewardClaimed",
            ok = res.ok, reason = res.reason,
            day = res.day, label = res.label, nextDay = res.nextDay, nextLabel = res.nextLabel,
        })
        if res.ok then
            -- refresh HUD (boost may now be active) + resend the chain state
            StatsService.recalc(player, st)
            sendUpdate(player, st)
            combatEvent:FireClient(player, { type = "dailyState", state = DailyRewardService.state(prof) })
        end

    elseif data.type == "requestDailyState" then
        local prof = PlayerDataService.getProfile(player)
        if prof then
            combatEvent:FireClient(player, { type = "dailyState", state = DailyRewardService.state(prof) })
        end

    elseif data.type == "requestMissionsState" then
        local prof = PlayerDataService.getProfile(player)
        if prof then
            MissionsService.ensureFresh(prof, st)
            combatEvent:FireClient(player, { type = "missionsState", state = MissionsService.state(prof) })
        end

    elseif data.type == "changeMission" then
        local prof = PlayerDataService.getProfile(player)
        if not prof then return end
        local ok, reason = MissionsService.changeMission(prof, st, tonumber(data.missionId))
        if ok then
            markProfileDirty(player, st)
        end
        combatEvent:FireClient(player, {
            type = "missionsState", state = MissionsService.state(prof),
            changeResult = { ok = ok, reason = reason },
        })

    elseif data.type == "createHero" then
        -- Hero creation (02-maquettes SS02). One-shot: only valid while the
        -- profile has no `voie`. Sets the class-defining tier-1 weapon voie,
        -- a cosmetic tint, a chat-filtered name, then releases the FTUE.
        local prof = PlayerDataService.getProfile(player)
        if not prof or prof.voie ~= nil then
            combatEvent:FireClient(player, { type = "heroCreated", ok = false, reason = "already" })
            return
        end
        if not GameConfig.Hero.isValidVoie(data.voie) then
            combatEvent:FireClient(player, { type = "heroCreated", ok = false, reason = "voie" })
            return
        end
        local tint = GameConfig.Hero.isValidTint(data.teinte) and data.teinte or "acier"

        -- Name: trim, length-check, then Roblox text filter (broadcast-safe).
        local raw = type(data.name) == "string" and data.name:gsub("^%s+", ""):gsub("%s+$", "") or ""
        local name = "Heros"
        if #raw >= GameConfig.Hero.nameMinLen then
            raw = raw:sub(1, GameConfig.Hero.nameMaxLen)
            local ok, filtered = pcall(function()
                local res = TextService:FilterStringAsync(raw, player.UserId, Enum.TextFilterContext.PublicChat)
                return res:GetNonChatStringForBroadcastAsync()
            end)
            if ok and type(filtered) == "string" and filtered ~= "" then
                name = filtered
            end
        end

        prof.voie = data.voie
        prof.teinte = tint
        prof.heroName = name
        markProfileDirty(player, st)

        -- Recalc: class-driven stat growth now knows the voie.
        StatsService.recalc(player, st)
        sendUpdate(player, st)
        combatEvent:FireClient(player, { type = "heroCreated", ok = true, voie = prof.voie, teinte = tint, name = name })
        -- Now start the tutorial.
        FtueService.onSpawn(player)

    elseif data.type == "unequipItem" then
        local ok, unequipped = pcall(InventoryService.unequipItem, player, data.slot)
        if ok and unequipped then
            StatsService.recalc(player, st)
            markProfileDirty(player, st)
        end
        sendUpdate(player, st)

    elseif data.type == "rebirth" then
        -- GAME_SPEC.md 8.1: infinite, KEEPS equipment/pets/checkpoints/rebirths,
        -- RESETS level/statPoints/gold/distance. Cost: hold >= cost(n), end at 0 gold.
        local cost = GameConfig.Rebirth.cost((st.rebirths or 0) + 1)
        if (st.gold or 0) < cost then
            combatEvent:FireClient(player, { type = "rebirthDenied", cost = cost })
            return
        end
        st.rebirths        = (st.rebirths or 0) + 1
        st.gold            = 0
        st.exp             = 0
        st.playerLevel     = 1
        st.playerExp       = 0
        st.playerExpToNext = xpNeeded(1)
        st.statPoints      = 0
        st.statPow = GameConfig.Player.startingStats.pow
        st.statInt = GameConfig.Player.startingStats.int
        st.statVit = GameConfig.Player.startingStats.vit
        st.statSpd = GameConfig.Player.startingStats.spd
        st.statLuk = GameConfig.Player.startingStats.luk
        restartRun(player, st, st.selectedCheckpoint or 0)
        flushProfileNow(player, st)
        combatEvent:FireClient(player, { type = "rebirthDone", rebirths = st.rebirths })
        sendUpdate(player, st)
    end
end)

-- Developer Product receipts are owned by ReceiptService.server.luau (B4).

--===== Player lifecycle =====
Players.PlayerAdded:Connect(function(player)
    startCombat(player)
end)

Players.PlayerRemoving:Connect(function(player)
    local st = states[player]
    if st then
        PlayerDataService.release(player, captureProfile(player, st))
    end
    states[player] = nil  -- loops detect nil and exit cleanly
    remoteCalls[player] = nil
    remoteRejects[player] = nil
    ZoneService.release(player)
    EquipmentService.release(player)
    InventoryService.release(player)
    ShopService.release(player)
    LootService.release(player)
end)

game:BindToClose(function()
    local deadline = os.clock() + GameConfig.Persistence.bindToCloseDeadlineSec
    local threads = {}
    for player, st in pairs(states) do
        threads[#threads + 1] = task.spawn(function()
            PlayerDataService.release(player, captureProfile(player, st))
        end)
    end
    -- Wait for every release (retry + backoff inside) to finish, or the deadline.
    while os.clock() < deadline do
        local anyAlive = false
        for _, co in threads do
            if coroutine.status(co) ~= "dead" then
                anyAlive = true
                break
            end
        end
        if not anyAlive then break end
        task.wait(0.2)
    end
end)

-- Handle players already in game
for _, player in Players:GetPlayers() do
    startCombat(player)
end
