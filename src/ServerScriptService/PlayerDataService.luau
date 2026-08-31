--==============================================================
-- PlayerDataService  (ModuleScript - ServerScriptService)
--
-- Durable per-player save (GAME_SPEC.md 11). DataStore-backed with a
-- session lock (heartbeat-refreshed), retry + backoff, and GRACEFUL
-- DEGRADATION: if DataStore is unavailable (Studio API access off, outage),
-- the game still runs - the player plays an unsaved session and a warning
-- is logged. The moment API access is enabled, saves start working with no
-- code change.
--
-- Not ProfileStore (can't vendor it here). The lock is a stored
-- { owner, ts } stamp: a load refuses a lock younger than lockStaleSec held
-- by another JobId, otherwise it takes over.
--
-- SAVE MODEL (B3): handlers never write. They call markDirty(); one throttled
-- writer per server persists dirty sessions at most once every
-- saveMinIntervalSec. Guaranteed writes: PlayerRemoving / BindToClose (release)
-- and the rebirth milestone (flush force). The same loop heartbeats the lock.
--==============================================================

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local PlayerDataService = {}

PlayerDataService.PROFILE_VERSION = 1

local STORE_NAME = "FoG_PlayerData_v1"
local JOB_ID = game.JobId ~= "" and game.JobId or ("studio_" .. tostring(os.time()))
local PERSIST = GameConfig.Persistence

local store = DataStoreService:GetDataStore(STORE_NAME)

-- [player] = { profile, dirty, dsAvailable, lastWrite, lastLockBeat }
--   lastWrite / lastLockBeat are os.clock() timestamps.
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
        bestKm = 0,
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
    for attempt = 1, PERSIST.maxRetries do
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

-- True when `lock` is a live lock owned by a DIFFERENT server.
local function isForeignLiveLock(lock)
    return lock ~= nil
        and lock.owner ~= JOB_ID
        and (os.time() - (lock.ts or 0)) < PERSIST.lockStaleSec
end

--===== Load =====
-- Returns (profile, status) where status is:
--   "ok"       - profile loaded, session persisting
--   "degraded" - DataStore unavailable, unsaved session on a default profile
--   "locked"   - a live session on another server holds the lock; caller kicks
function PlayerDataService.load(player)
    if not probeDataStore() then
        local prof = PlayerDataService.defaultProfile()
        sessions[player] = { profile = prof, dirty = false, dsAvailable = false }
        return prof, "degraded"
    end

    local key = keyFor(player)
    local contended = false

    for attempt = 1, PERSIST.loadLockRetries + 1 do
        local ok, stored = retry(function()
            return store:UpdateAsync(key, function(old)
                old = migrate(old or PlayerDataService.defaultProfile())
                if isForeignLiveLock(old._lock) then
                    return nil  -- another live session holds the lock: don't steal it
                end
                old._lock = { owner = JOB_ID, ts = os.time() }
                return old
            end)
        end)

        if ok and type(stored) == "table" then
            local now = os.clock()
            sessions[player] = {
                profile = stored, dirty = false, dsAvailable = true,
                lastWrite = now, lastLockBeat = now,
            }
            return stored, "ok"
        elseif ok then
            -- UpdateAsync transform returned nil -> contended lock.
            contended = true
            if attempt <= PERSIST.loadLockRetries then
                task.wait(PERSIST.loadLockRetryWaitSec)
            end
        else
            -- hard DataStore failure - stop retrying the lock
            break
        end
    end

    if contended then
        warn(("[PlayerDataService] %s (%d): profile still locked by a live session - kicking")
            :format(player.Name, player.UserId))
        return nil, "locked"
    end

    warn(("[PlayerDataService] load failed for %s (%d) - UNSAVED session")
        :format(player.Name, player.UserId))
    local prof = PlayerDataService.defaultProfile()
    sessions[player] = { profile = prof, dirty = false, dsAvailable = false }
    return prof, "degraded"
end

--===== Dirty flag (handlers call this; they never write) =====
function PlayerDataService.markDirty(player, profile)
    local sess = sessions[player]
    if not sess then return end
    if profile then sess.profile = profile end
    sess.dirty = true
end

--===== Flush (throttled writer; `force` bypasses the interval + dirty gate) =====
function PlayerDataService.flush(player, profile, force)
    local sess = sessions[player]
    if not sess then return false end
    if profile then sess.profile = profile end
    profile = sess.profile

    if not sess.dsAvailable or dsUsable == false then
        sess.dirty = false
        return false
    end
    if not force then
        if not sess.dirty then return false end
        if os.clock() - (sess.lastWrite or 0) < PERSIST.saveMinIntervalSec then
            return false  -- throttled: stays dirty, picked up next tick
        end
    end

    local key = keyFor(player)
    local ok, err = retry(function()
        return store:UpdateAsync(key, function(old)
            old = old or {}
            if isForeignLiveLock(old._lock) then
                return nil  -- we lost the lock; abort the write
            end
            profile.version = PlayerDataService.PROFILE_VERSION
            profile._savedAt = os.time()
            profile._lock = { owner = JOB_ID, ts = os.time() }
            return profile
        end)
    end)

    if ok then
        local now = os.clock()
        sess.dirty = false
        sess.lastWrite = now
        sess.lastLockBeat = now
    else
        warn(("[PlayerDataService] save failed for %s: %s"):format(player.Name, tostring(err)))
    end
    return ok
end

-- Back-compat alias: an immediate, guaranteed write.
function PlayerDataService.save(player, profile)
    return PlayerDataService.flush(player, profile, true)
end

--===== Lock heartbeat (light write: only bumps _lock.ts) =====
local function heartbeatLock(player)
    local sess = sessions[player]
    if not sess or not sess.dsAvailable or dsUsable == false then return end
    local key = keyFor(player)
    local ok = retry(function()
        return store:UpdateAsync(key, function(old)
            if type(old) ~= "table" or type(old._lock) ~= "table" then return nil end
            if old._lock.owner ~= JOB_ID then return nil end
            old._lock.ts = os.time()
            return old
        end)
    end)
    if ok then
        sess.lastLockBeat = os.clock()
    else
        warn(("[PlayerDataService] lock heartbeat failed for %s"):format(player.Name))
    end
end

--===== Release (guaranteed write, clears the lock) =====
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

function PlayerDataService.isPersisting(player)
    local sess = sessions[player]
    return sess ~= nil and sess.dsAvailable == true
end

--===== Single throttled writer + lock heartbeat, for the life of the server =====
task.spawn(function()
    while true do
        task.wait(PERSIST.saveTickSec)
        for _, player in Players:GetPlayers() do
            local sess = sessions[player]
            if sess and sess.dsAvailable and dsUsable ~= false then
                local now = os.clock()
                if sess.dirty and now - (sess.lastWrite or 0) >= PERSIST.saveMinIntervalSec then
                    PlayerDataService.flush(player)
                elseif now - (sess.lastLockBeat or 0) >= PERSIST.lockHeartbeatSec then
                    heartbeatLock(player)
                end
            end
        end
    end
end)

return PlayerDataService
