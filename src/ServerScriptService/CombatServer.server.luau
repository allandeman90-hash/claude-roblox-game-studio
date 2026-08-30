--==============================================================
-- CombatServer  (Server Script)
-- All combat logic is server-authoritative.
-- The client only receives display data via RemoteEvent.
--==============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- Zone system (decor + enemy roster) and progression milestones
-- (rest = campfire + shop every 50 km ; boss every 100 km).
local ZoneService = require(script.Parent:WaitForChild("ZoneService"))
local ShopService = require(script.Parent:WaitForChild("ShopService"))

-- Equipment system (data + 6 slots). Read-only from CombatServer's point
-- of view: it only drives the lifecycle and reads HUD strings. It does
-- NOT feed combat stats yet - that is a later lot.
local EquipmentService = require(script.Parent:WaitForChild("EquipmentService"))

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
local AUTOSAVE_INTERVAL = 120                                     -- seconds between profile autosaves

--===== Progression constants =====
-- Legacy linear XP rate. This is NOT the player's XP curve (see xpNeeded /
-- GameConfig.Level.xpForNextLevel). It only feeds ZoneService's boss-level
-- heuristic below, kept unchanged. Removed when bosses are reworked.
local XP_PER_LEVEL          = 30
local STAT_POINTS_PER_LEVEL = GameConfig.Level.statPointsPerLevel        -- 5
local KM_PER_STEP          = GameConfig.Progression.kmPerStep            -- 0.1 (client scroll unit)
local STEPS_PER_ZONE       = GameConfig.Progression.stepsPerZone        -- 100 (client scroll unit)
local MOVE_SPEED           = GameConfig.World.moveSpeedKmPerSec         -- km / s
local ENCOUNTER_RANGE      = GameConfig.World.encounterRangeKm
local CAMPFIRE_EVERY       = GameConfig.World.campfireEveryKm
local CAMPFIRE_RANGE       = GameConfig.World.campfireRangeKm
local MOB_TICK             = 0.1
local REVIVE_PRODUCT_ID    = 0     -- non-GDD (monetization); slated for removal

-- ⚠️ DEV ONLY — REMOVE BEFORE RELEASE. Enables the "devReset" remote (+ the
-- client's RESET button) that wipes a player's progression for balance testing.
local DEV_MODE = true
local REVIVE_PRICE_ROBUX   = 50

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
        if enc.kind == "boss" then
            local b = EnemyService.rollBoss(enc.pos)
            pv = { name = b.name, level = b.level }
        else
            local e = EnemyService.rollEnemy(enc.pos)
            pv = { name = e.name, level = e.level }
        end
        s.encPreview[enc.pos] = pv
    end
    return pv
end

local function sendUpdate(player, s)
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
        gameOver        = s.gameOver or false,
        statPow         = s.statPow,
        statInt         = s.statInt,
        statVit         = s.statVit,
        statSpd         = s.statSpd,
        statLuk         = s.statLuk,
        spdNextCost     = spdNextCost,
        spdAtMax        = spdAtMax,
        spdMax          = GameConfig.Combat.spdMax,
        equipWeapon     = EquipmentService.describeSlot(player, "arme"),
        equipArmor      = EquipmentService.describeArmorSummary(player),
        equipPet        = EquipmentService.describeSlot(player, "pet"),
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
        selectedCheckpoint = s.selectedCheckpoint or 0,
        rebirthSkillPct = math.floor(GameConfig.Rebirth.skillEffectPerRebirth * (s.rebirths or 0) * 100),
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
    profile.checkpointMax      = s.checkpointMaxKm or 0
    profile.selectedCheckpoint = s.selectedCheckpoint or 0
    profile.rebirths           = s.rebirths or 0
    profile.bigBossesBeaten    = s.bigBossesBeaten or 0
    profile.fastMode           = s.fastMode == true
    profile.deaths             = s.deaths or 0
    profile.pointsNonAlloues   = s.statPoints
    profile.stats = { pow = s.statPow, int = s.statInt, vit = s.statVit, spd = s.statSpd, luk = s.statLuk }
    local eq = EquipmentService.serialize(player)
    profile.equipe      = eq.equipe
    profile.inventaire  = eq.inventory
    profile.verrouilles = eq.locked
    profile.filtres     = eq.filters
    profile.owned       = nil   -- legacy field, superseded by inventaire
    return profile
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

    local xpGain   = math.floor(st.enemyExp * GameConfig.Rebirth.xpMult(st.rebirths))
    local goldGain = st.enemyGold
    st.exp  = st.exp + xpGain
    st.gold = st.gold + goldGain

    local bossIdx = st.enemyIsBigBoss and math.max(1, math.floor((st.pos or 0) / 100 + 0.5)) or nil
    local drop = LootService.rollDrop(player, { zone = st.zone, isBoss = st.isBoss, isBigBoss = st.enemyIsBigBoss, bossIndex = bossIdx })
    if drop then
        local kept, reason = EquipmentService.addItem(player, drop, "loot")
        combatEvent:FireClient(player, {
            type = "loot",
            item = { id = drop.id, nom = drop.nom, slot = drop.slot, voie = drop.voie, rarete = drop.rarete, zone = drop.zone },
            fromBoss = drop.isBoss or false, kept = kept, reason = reason,
        })
    end
    local petDrop = LootService.rollPetDrop(player, { zone = st.zone, isBoss = st.isBoss, isBigBoss = st.enemyIsBigBoss })
    if petDrop then
        local kept, reason = EquipmentService.addItem(player, petDrop, "loot")
        combatEvent:FireClient(player, {
            type = "loot",
            item = { id = petDrop.id, nom = petDrop.nom, slot = "pet", role = petDrop.role, rarete = petDrop.rarete, zone = petDrop.zone },
            fromBoss = petDrop.isBoss or false, kept = kept, reason = reason,
        })
    end

    st.playerExp = st.playerExp + xpGain
    while st.playerExp >= st.playerExpToNext do
        st.playerExp       = st.playerExp - st.playerExpToNext
        st.playerLevel     = st.playerLevel + 1
        st.statPoints      = st.statPoints + STAT_POINTS_PER_LEVEL
        st.playerExpToNext = xpNeeded(st.playerLevel)
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
    sendUpdate(player, st)
end

-- Begin a fixed-slot encounter (world-traversal model). `enc` = { pos, kind }.
local function startEncounter(player, st, enc)
    st.combatActive = true
    st.currentEncounterPos = enc.pos
    st.isMoving = false
    if enc.kind == "boss" then
        local boss = EnemyService.rollBoss(enc.pos)
        st.isBoss = true
        st.milestone = "boss"
        st.enemyName = boss.name ; st.enemyLevel = boss.level ; st.enemyMaxHp = boss.maxHp
        st.enemyAtk = boss.atk ; st.enemyExp = boss.exp ; st.enemyGold = boss.gold
        st.enemyHp = boss.maxHp ; st.enemyDamageType = boss.damageType
        st.enemyAtkSplit = boss.atkSplit ; st.enemyIsBigBoss = boss.isBigBoss or false
    else
        local e = EnemyService.rollEnemy(enc.pos)
        st.encPreview = st.encPreview or {}
        local pv = st.encPreview[enc.pos]
        if pv then
            e.name, e.level = pv.name, pv.level
        else
            st.encPreview[enc.pos] = { name = e.name, level = e.level }
        end
        st.isBoss = false ; st.milestone = nil
        st.enemyName = e.name ; st.enemyLevel = e.level ; st.enemyMaxHp = e.maxHp
        st.enemyAtk = e.atk ; st.enemyExp = e.exp ; st.enemyGold = e.gold
        st.enemyHp = e.maxHp ; st.enemyDamageType = nil ; st.enemyAtkSplit = nil
        st.enemyIsBigBoss = nil
    end

    -- The HERO always strikes first; both attack timers start counting AFTER it.
    st.atkCharge = 0
    st.enemyCharge = 0
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
        selectedCheckpoint = 0,
        enemyName      = firstEnemy.name,
        enemyLevel     = firstEnemy.level,
        enemyHp        = firstEnemy.maxHp,
        enemyMaxHp     = firstEnemy.maxHp,
        enemyAtk       = firstEnemy.atk,
        enemyExp       = firstEnemy.exp,
        enemyGold      = firstEnemy.gold,
        combatActive   = false,
    }
    states[player] = s

    -- Durable profile (GAME_SPEC.md 11). PlayerDataService.load always returns a
    -- usable profile (a fresh default if DataStore is off / this is a new player).
    local profile = PlayerDataService.load(player)
    applyProfileToState(profile, s)
    EquipmentService.restore(player, {
        equipe = profile.equipe,
        inventory = profile.inventaire,
        owned = profile.owned,          -- legacy fallback (old saves)
        locked = profile.verrouilles,
        filters = profile.filtres,
    })
    LootService.noteZoneReached(player, math.floor((s.checkpointMaxKm or 0) / 10) + 1)

    -- Start this run at the selected checkpoint (default 0). restartRun does the
    -- zone reset, StatsService.recalc, first-enemy roll and spawns at full HP.
    restartRun(player, s, s.selectedCheckpoint or 0)

    -- Periodic autosave for the life of this session.
    task.spawn(function()
        while states[player] == s do
            task.wait(AUTOSAVE_INTERVAL)
            if states[player] == s then
                PlayerDataService.save(player, captureProfile(player, s))
            end
        end
    end)

    -- Initial sync
    sendUpdate(player, s)

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

    -- Enemy attack loop. Charge-based + reset by startEncounter, so its first swing
    -- lands ENEMY_INTERVAL after the fight begins (never before the hero's opener).
    task.spawn(function()
        while states[player] do
            task.wait(MOB_TICK)
            local st = states[player]
            if not st then break end
            if not (st.combatActive and st.enemyHp > 0 and st.playerHp > 0) then
                st.enemyCharge = 0
            else
                st.enemyCharge = (st.enemyCharge or 0) + MOB_TICK
                if st.enemyCharge >= ENEMY_INTERVAL then
                    st.enemyCharge = st.enemyCharge - ENEMY_INTERVAL
                    local dmg = DamageService.enemyHitPlayer(st)
                    st.playerHp = st.playerHp - dmg
                    sendDamage(player, "player", dmg, false)
                    if st.playerHp <= 0 then
                        st.playerHp = 0
                        st.combatActive = false
                        st.isMoving = false
                        st.gameOver = true
                        st.moveDir = nil
                        st.deaths = (st.deaths or 0) + 1
                        PlayerDataService.save(player, captureProfile(player, st))
                        combatEvent:FireClient(player, {
                            type       = "gameOver",
                            distance   = st.pos or 0,
                            productId  = REVIVE_PRODUCT_ID,
                            revivePrice = REVIVE_PRICE_ROBUX,
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

            -- Decor zone + checkpoint high-water mark.
            st.zone = ZoneService.updateDistance(player, st.pos)
            LootService.noteZoneReached(player, st.zone)
            local cpKm = math.floor(st.pos / 10) * 10
            if cpKm > (st.checkpointMaxKm or 0) then st.checkpointMaxKm = cpKm end

            -- Respawn: a killed encounter comes back only once the player has LEFT
            -- its 1 km step (walked forward to the next step, or back past the
            -- boundary). No more ping-ponging 20 cm to re-farm the same 2 mobs.
            local curStepFloor = math.floor(st.pos)
            for p in pairs(st.cleared) do
                if math.floor(p) ~= curStepFloor then
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
                        PlayerDataService.save(player, captureProfile(player, st))
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

                -- Encounter: nearest uncleared slot in this zone (or the boss of
                -- the previous zone, which sits on the shared boundary).
                if not st.atCampfire then
                    local zones = { st.zone }
                    if st.zone > 1 then zones[2] = st.zone - 1 end
                    for _, z in ipairs(zones) do
                        for _, enc in ipairs(EnemyService.encountersForZone(z)) do
                            if not st.cleared[enc.pos] and math.abs(st.pos - enc.pos) <= ENCOUNTER_RANGE then
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
    StatsService.recalc(player, st)
    st.playerHp        = st.playerMaxHp
    st.isMoving        = false
    st.isBoss          = false
    st.milestone       = nil
    st.combatActive    = false
    st.gameOver        = false
    st.enemyDamageType = nil
    st.enemyAtkSplit   = nil
    st.enemyIsBigBoss  = nil
    -- a placeholder enemy so the HUD has something until the first encounter
    local e = EnemyService.rollEnemy(startKm)
    st.enemyName = e.name ; st.enemyLevel = e.level ; st.enemyMaxHp = e.maxHp
    st.enemyAtk = e.atk ; st.enemyExp = e.exp ; st.enemyGold = e.gold ; st.enemyHp = e.maxHp
end

--===== Client request handler (stat allocation, restart, rebirth) =====
combatEvent.OnServerEvent:Connect(function(player, data)
    if not data or not data.type then return end
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
            PlayerDataService.save(player, captureProfile(player, st))
            sendUpdate(player, st)
        end

    elseif data.type == "campfireContinue" then
        -- Legacy: the player now just walks away from the campfire. No-op kept
        -- so old clients don't error.
        return

    elseif data.type == "devReset" then
        -- ⚠️ DEV ONLY — REMOVE BEFORE RELEASE. Full progression wipe for testing.
        if not DEV_MODE then return end
        local start = GameConfig.Player.startingStats
        st.playerLevel       = 1
        st.playerExp         = 0
        st.playerExpToNext   = xpNeeded(1)
        st.statPoints        = 0
        st.gold              = 0
        st.exp               = 0
        st.statPow, st.statInt, st.statVit, st.statSpd, st.statLuk =
            start.pow, start.int, start.vit, start.spd, start.luk
        st.rebirths          = 0
        st.bigBossesBeaten   = 0
        st.fastMode          = false
        st.deaths            = 0
        st.checkpointMaxKm   = 0
        st.selectedCheckpoint = 0
        st.encPreview        = {}
        EquipmentService.restore(player, {})
        PlayerDataService.wipe(player)
        restartRun(player, st, 0)
        sendUpdate(player, st)
        combatEvent:FireClient(player, { type = "inventory", slots = {},
            summary = EquipmentService.getInventorySummary(player),
            filters = EquipmentService.getFilters(player) })
        return

    elseif data.type == "restart" then
        if not st.gameOver then return end
        -- KEEP everything; RESET distance to the chosen checkpoint (default 0).
        local cp = tonumber(data.checkpointKm) or st.selectedCheckpoint or 0
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
        local slots = data.slot and { data.slot } or { "arme", "casque", "plastron", "jambieres", "bottes", "pet" }
        local byslot = {}
        for _, sl in ipairs(slots) do
            byslot[sl] = EquipmentService.listInventoryForSlot(player, sl)
        end
        combatEvent:FireClient(player, {
            type = "inventory", slots = byslot,
            summary = EquipmentService.getInventorySummary(player),
            filters = EquipmentService.getFilters(player),
        })

    elseif data.type == "fuseItem" then
        -- GAME_SPEC.md 5.2
        local ok, err, newRarete = EquipmentService.fuse(player, data.id, data.rarete, data.zone)
        if ok then
            StatsService.recalc(player, st)
            PlayerDataService.save(player, captureProfile(player, st))
            combatEvent:FireClient(player, { type = "fuseResult", ok = true, newRarete = newRarete })
        else
            combatEvent:FireClient(player, { type = "fuseResult", ok = false, reason = err })
        end
        combatEvent:FireClient(player, { type = "inventory",
            slots = { [data.slot] = EquipmentService.listInventoryForSlot(player, data.slot) },
            summary = EquipmentService.getInventorySummary(player) })
        sendUpdate(player, st)

    elseif data.type == "setFilters" then
        EquipmentService.setFilters(player, {
            rareteMin = data.rareteMin, guerrier = data.guerrier, mage = data.mage,
        })
        PlayerDataService.save(player, captureProfile(player, st))
        combatEvent:FireClient(player, { type = "inventory", filters = EquipmentService.getFilters(player), slots = {} })

    elseif data.type == "toggleLock" then
        EquipmentService.toggleLock(player, data.id, data.rarete, data.zone)
        combatEvent:FireClient(player, { type = "inventory",
            slots = { [data.slot] = EquipmentService.listInventoryForSlot(player, data.slot) } })

    elseif data.type == "equipItem" then
        -- Equip an OWNED item (GAME_SPEC.md 1.1 selectors / 1.2 inventory).
        local slot = data.slot
        local ok, err = EquipmentService.equip(player, slot, data.id, data.rarete, data.zone)
        if ok then
            StatsService.recalc(player, st)
            PlayerDataService.save(player, captureProfile(player, st))
        else
            combatEvent:FireClient(player, { type = "equipError", reason = err })
        end
        combatEvent:FireClient(player, { type = "inventory",
            slots = { [slot] = EquipmentService.listInventoryForSlot(player, slot) },
            summary = EquipmentService.getInventorySummary(player) })
        sendUpdate(player, st)

    elseif data.type == "unequipItem" then
        local ok = EquipmentService.unequip(player, data.slot)
        if ok then
            StatsService.recalc(player, st)
            PlayerDataService.save(player, captureProfile(player, st))
        end
        combatEvent:FireClient(player, { type = "inventory",
            slots = { [data.slot] = EquipmentService.listInventoryForSlot(player, data.slot) },
            summary = EquipmentService.getInventorySummary(player) })
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
        PlayerDataService.save(player, captureProfile(player, st))
        combatEvent:FireClient(player, { type = "rebirthDone", rebirths = st.rebirths })
        sendUpdate(player, st)
    end
end)

--===== Developer Product: Revive purchase handler =====
MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if receiptInfo.ProductId == REVIVE_PRODUCT_ID then
        local st = states[player]
        if st and st.gameOver then
            st.gameOver     = false
            st.playerHp     = st.playerMaxHp
            st.enemyHp      = st.enemyMaxHp
            st.combatActive = true
            st.isMoving     = false
            sendUpdate(player, st)
        end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

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
    ZoneService.release(player)
    EquipmentService.release(player)
    ShopService.release(player)
    LootService.release(player)
end)

game:BindToClose(function()
    for player, st in pairs(states) do
        task.spawn(function()
            PlayerDataService.release(player, captureProfile(player, st))
        end)
    end
    task.wait(3)
end)

-- Handle players already in game
for _, player in Players:GetPlayers() do
    startCombat(player)
end
