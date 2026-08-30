--==============================================================
-- PlayerDataService  (ModuleScript - ServerScriptService)
--
-- Durable per-player save (GAME_SPEC.md 11). DataStore-backed with a
-- lightweight session lock, retry + backoff, and GRACEFUL DEGRADATION:
-- if DataStore is unavailable (Studio API access off, outage), the game
-- still runs - the player just plays an unsaved session and a warning is
-- logged. The moment API access is enabled, saves start working with no
-- code change.
--
-- Not ProfileStore (can't vendor it here). The lock is a stored
-- { owner, ts } stamp: a load refuses a lock younger than LOCK_STALE_S
-- held by another JobId, otherwise it takes over.
--==============================================================

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerDataService = {}

PlayerDataService.PROFILE_VERSION = 1

local STORE_NAME      = "FoG_PlayerData_v1"
local MAX_RETRIES     = 5
local LOCK_STALE_S    = 90        -- a lock older than this is assumed abandoned
local JOB_ID          = game.JobId ~= "" and game.JobId or ("studio_" .. tostring(os.time()))

local store = DataStoreService:GetDataStore(STORE_NAME)

-- [player] = { profile = <table>, dirty = bool, dsAvailable = bool }
local sessions = {}

-- Global DataStore availability, probed once. nil = unknown, true/false after probe.
-- A "permanent" failure (Studio API access off, no network) flips this to false and
-- every call short-circuits to degraded mode with NO retry / NO blocking.
local dsUsable = nil

local function isPermanentError(err)
    err = tostring(err)
    return err:find("API access is not enabled")
        or err:find("not allowed")
        or err:find("StudioAccessToApisNotAllowed")
        or err:find("403")
        or err:find("HTTP 401")
end

local function probeDataStore()
    if dsUsable ~= nil then return dsUsable end
    local ok, err = pcall(function()
        return store:GetAsync("__probe__")
    end)
    if ok then
        dsUsable = true
    elseif isPermanentError(err) then
        dsUsable = false
        warn("[PlayerDataService] DataStore unavailable (" .. tostring(err) ..
            ") - running in UNSAVED mode. Enable Studio Access to API Services to persist.")
    else
        -- transient: assume usable, individual calls will retry
        dsUsable = true
    end
    return dsUsable
end

--===== Schema =====
function PlayerDataService.defaultProfile()
    return {
        version = PlayerDataService.PROFILE_VERSION,
        niveau = 1,
        xp = 0,
        xpToNext = nil,           -- recomputed on load from the curve
        or_ = 0,
        distance = 0,
        checkpointMax = 0,
        selectedCheckpoint = 0,
        rebirths = 0,
        bigBossesBeaten = 0,
        fastMode = false,
        deaths = 0,
        stats = { pow = nil, int = nil, vit = nil, spd = nil, luk = nil },  -- nil -> startingStats
        pointsNonAlloues = 0,
        equipe = {},
        owned = {},
        inventaire = {},          -- reserved (inventory etape)
        verrouilles = {},         -- reserved
        filtres = { rareteMin = "commun", guerrier = true, mage = true },
        _lock = nil,
        _savedAt = 0,
    }
end

-- Bring an older profile up to the current version (no-op for v1).
local function migrate(profile)
    if type(profile) ~= "table" then return PlayerDataService.defaultProfile() end
    profile.version = profile.version or 1
    -- (future: if profile.version < N then ... end)
    local d = PlayerDataService.defaultProfile()
    for k, v in pairs(d) do
        if profile[k] == nil then profile[k] = v end
    end
    if type(profile.filtres) ~= "table" then profile.filtres = d.filtres end
    profile.version = PlayerDataService.PROFILE_VERSION
    return profile
end

local function retry(fn)
    local ok, res
    for attempt = 1, MAX_RETRIES do
        ok, res = pcall(fn)
        if ok then return true, res end
        if isPermanentError(res) then
            dsUsable = false
            return false, res  -- do not retry, do not block
        end
        task.wait(math.min(4, 0.5 * 2 ^ (attempt - 1)))
    end
    return false, res
end

local function keyFor(player)
    return "u_" .. tostring(player.UserId)
end

--===== Load =====
-- Returns (profile, dsAvailable). Always returns a usable profile.
function PlayerDataService.load(player)
    if not probeDataStore() then
        local prof = PlayerDataService.defaultProfile()
        sessions[player] = { profile = prof, dirty = false, dsAvailable = false }
        return prof, false
    end
    local key = keyFor(player)
    local ok, stored = retry(function()
        return store:UpdateAsync(key, function(old)
            old = migrate(old or PlayerDataService.defaultProfile())
            local lock = old._lock
            if lock and lock.owner ~= JOB_ID and (os.time() - (lock.ts or 0)) < LOCK_STALE_S then
                -- Another live session holds the lock: don't steal it.
                return nil
            end
            old._lock = { owner = JOB_ID, ts = os.time() }
            return old
        end)
    end)

    if ok and type(stored) == "table" then
        sessions[player] = { profile = stored, dirty = false, dsAvailable = true }
        return stored, true
    end

    -- DataStore unavailable OR lock contested -> unsaved session on a default profile.
    warn(("[PlayerDataService] load failed for %s (%s) - UNSAVED session"):format(
        player.Name, tostring(stored)))
    local prof = PlayerDataService.defaultProfile()
    sessions[player] = { profile = prof, dirty = false, dsAvailable = false }
    return prof, false
end

--===== Save =====
function PlayerDataService.save(player, profile)
    local sess = sessions[player]
    if not sess then return false end
    profile = profile or sess.profile
    sess.profile = profile
    if not sess.dsAvailable or dsUsable == false then
        return false  -- degraded mode: nothing to persist to
    end
    local key = keyFor(player)
    local ok, err = retry(function()
        return store:UpdateAsync(key, function(old)
            old = old or {}
            -- Only write if we still own the lock (or it's stale / ours).
            local lock = old._lock
            if lock and lock.owner ~= JOB_ID and (os.time() - (lock.ts or 0)) < LOCK_STALE_S then
                return nil
            end
            profile.version = PlayerDataService.PROFILE_VERSION
            profile._savedAt = os.time()
            profile._lock = { owner = JOB_ID, ts = os.time() }
            return profile
        end)
    end)
    if not ok then
        warn(("[PlayerDataService] save failed for %s: %s"):format(player.Name, tostring(err)))
    end
    return ok
end

--===== Release (clears the lock) =====
function PlayerDataService.release(player, profile)
    local sess = sessions[player]
    if not sess then return end
    profile = profile or sess.profile
    if sess.dsAvailable and dsUsable ~= false then
        local key = keyFor(player)
        retry(function()
            return store:UpdateAsync(key, function(old)
                old = old or {}
                local lock = old._lock
                if lock and lock.owner ~= JOB_ID then return nil end
                profile.version = PlayerDataService.PROFILE_VERSION
                profile._savedAt = os.time()
                profile._lock = nil
                return profile
            end)
        end)
    end
    sessions[player] = nil
end

function PlayerDataService.getProfile(player)
    local sess = sessions[player]
    return sess and sess.profile or nil
end

-- ⚠️ DEV ONLY — REMOVE BEFORE RELEASE. Erase the stored profile + the in-session
-- copy so the next load / the current run starts from a fresh default.
function PlayerDataService.wipe(player)
    local sess = sessions[player]
    if sess then
        sess.profile = PlayerDataService.defaultProfile()
        sess.dirty = false
    end
    if dsUsable ~= false then
        pcall(function() store:RemoveAsync(keyFor(player)) end)
    end
end

function PlayerDataService.isPersisting(player)
    local sess = sessions[player]
    return sess ~= nil and sess.dsAvailable == true
end

return PlayerDataService
