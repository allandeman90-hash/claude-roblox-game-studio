--==============================================================
-- ZoneService  (ModuleScript - ServerScriptService)
-- The zone system's server-side logic.
--
-- Responsibilities (and ONLY these):
--   * track which decor zone each player is in (1 zone = 10 km)
--   * drive the progression MILESTONES (paliers):
--       every  50 km -> rest (campfire regen + shop, one combined stop)
--       every 100 km -> boss (dynamic level)
--   * "prepare" the next decor zone / hook points
--
-- It does NOT compute distance, damage, HP, XP, gold, level ups
-- or touch the scrolling / UI. CombatServer owns all of that;
-- this module only reads the distance CombatServer calculates and
-- returns enemy / boss / milestone descriptors.
--==============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZoneConfig = require(ReplicatedStorage:WaitForChild("ZoneConfig"))

local ZoneService = {}

local REST = ZoneConfig.REST_EVERY_KM
local BOSS = ZoneConfig.BOSS_EVERY_KM

-- XP economy snapshot, injected once by CombatServer so the boss
-- level can be derived without duplicating (or touching) the real
-- XP / level-up constants. Safe defaults match the shipped values.
local economy = { xpPerLevel = 30, xpPerEnemy = 10, kmPerEnemy = 1 }
function ZoneService.configureEconomy(e)
	if type(e) ~= "table" then return end
	economy.xpPerLevel = tonumber(e.xpPerLevel) or economy.xpPerLevel
	economy.xpPerEnemy = tonumber(e.xpPerEnemy) or economy.xpPerEnemy
	economy.kmPerEnemy = tonumber(e.kmPerEnemy) or economy.kmPerEnemy
end

-- [player] = { zoneId, prepared = {...}, nextMilestoneKm, lastMilestoneKm, bossesDefeated = {} }
local track = {}

-- Next milestone km strictly greater than fromKm (union of the rest + boss grids).
function ZoneService.nextMilestoneKm(fromKm)
	local r = math.floor(fromKm / REST) * REST + REST
	local b = math.floor(fromKm / BOSS) * BOSS + BOSS
	return math.min(r, b)
end

-- Kind of milestone that sits exactly on `markKm` (priority boss > rest).
-- With BOSS = 10 every zone ends on a boss; the 50 km rest km is ALSO a boss km,
-- so the campfire is opened by CombatServer AFTER that boss is defeated
-- (see ZoneService.isRestMilestone).
function ZoneService.milestoneKind(markKm)
	if markKm % BOSS == 0 then return "boss" end
	if markKm % REST == 0 then return "campfire" end
	return nil
end

-- True when `markKm` is a rest stop (campfire + shop). Checked by CombatServer
-- when a boss on that km is cleared.
function ZoneService.isRestMilestone(markKm)
	return markKm > 0 and markKm % REST == 0
end

function ZoneService.init(player)
	track[player] = {
		zoneId = 1,
		prepared = { [1] = true },
		nextMilestoneKm = ZoneService.nextMilestoneKm(0),
		lastMilestoneKm = 0,
		bossesDefeated = {},
	}
end

function ZoneService.release(player)
	track[player] = nil
end

-- Reset a player's zone/milestone tracking to an arbitrary start km (checkpoint
-- restart or rebirth). Milestones already behind `km` never fire.
function ZoneService.resetTo(player, km)
	km = math.max(0, km or 0)
	track[player] = {
		zoneId = ZoneConfig.zoneIdFromKm(km),
		prepared = { [1] = true },
		nextMilestoneKm = ZoneService.nextMilestoneKm(km),
		lastMilestoneKm = math.floor(km / REST) * REST,
		bossesDefeated = {},
	}
end

function ZoneService.getZoneId(player)
	local t = track[player]
	return t and t.zoneId or 1
end

-- Mark a zone as registered / prepared. A prepared zone may still
-- be undeveloped (no roster / boss) - that is expected for Zone 2
-- in the prototype.
function ZoneService.prepareZone(player, zoneId)
	local t = track[player]
	if not t or t.prepared[zoneId] then return end
	t.prepared[zoneId] = true
	local cfg = ZoneConfig.getZone(zoneId)
	if cfg and not cfg.developed then
		warn(("[ZoneService] Zone %d (%s) preparee mais pas encore developpee."):format(zoneId, cfg.name))
	elseif not cfg then
		warn(("[ZoneService] Zone %d preparee (aucune config)."):format(zoneId))
	end
end

-- Called every progression tick with the current server distance
-- (km). Returns the (possibly updated) decor zone id. Decor only -
-- it is not gated by milestones.
function ZoneService.updateDistance(player, km)
	local t = track[player]
	if not t then return 1 end

	local target = ZoneConfig.zoneIdFromKm(km)
	if target ~= t.zoneId then
		t.zoneId = target
		ZoneService.prepareZone(player, target + 1)
	end
	return t.zoneId
end

-- Progression milestone check. Pass the current server distance (km).
-- Returns "campfire" (rest + shop) | "boss" | nil. When it returns a kind,
-- the internal cursor advances so the same mark never fires twice.
function ZoneService.consumeMilestone(player, km)
	local t = track[player]
	if not t or km < t.nextMilestoneKm then return nil end

	local mark = t.nextMilestoneKm
	local kind = ZoneService.milestoneKind(mark)
	t.lastMilestoneKm = mark
	t.nextMilestoneKm = ZoneService.nextMilestoneKm(mark)
	return kind, mark
end

-- Call when a boss has just been defeated.
function ZoneService.markBossDefeated(player)
	local t = track[player]
	if not t then return end
	t.bossesDefeated[t.lastMilestoneKm] = true
end

-- Level a player is *expected* to have reached at a given distance,
-- derived from the existing XP economy (read-only, never modified):
--   ~1 enemy per kmPerEnemy km, each worth ~xpPerEnemy XP;
--   level L needs cumulative xpPerLevel * L*(L-1)/2 XP.
function ZoneService.expectedLevelForKm(km)
	local totalXp = (km / economy.kmPerEnemy) * economy.xpPerEnemy
	local L = (1 + math.sqrt(1 + 8 * totalXp / economy.xpPerLevel)) / 2
	return math.max(1, math.floor(L))
end

local function scale(base, mul, floorMin)
	return math.max(floorMin, math.floor(base * (mul or 1)))
end

-- (Regular-enemy rolling moved to EnemyService in the enemy-scaling etape.
-- ZoneService still owns boss rolling below - `scale` is shared.)

-- Boss descriptor for the 100 km milestone at `km`.
--   * level: dynamic - max(player level, expected level for the distance).
--            Never a fixed value.
--   * stats: "beaucoup plus important" - the roster multipliers scale
--            with the boss level, well above a normal enemy.
-- `baseStats` is still the game's existing per-area base, so the
-- underlying combat / XP / gold economy is untouched.
function ZoneService.rollBoss(km, playerLevel, baseStats)
	local index = math.max(1, math.floor(km / BOSS + 0.5))
	local theme = ZoneConfig.bossTheme(index)

	local expected = ZoneService.expectedLevelForKm(km)
	local level = math.max(playerLevel or 1, expected)

	-- "Beaucoup plus important" : well above a normal enemy of this area,
	-- scaled further by the boss level. Tune bases in ZoneConfig.BossThemes.
	local hpMul   = (theme.hpMul   or 12) + level
	local atkMul  = (theme.atkMul  or 3)  + level * 0.25
	local expMul  = (theme.expMul  or 8)  + level
	local goldMul = (theme.goldMul or 12) + level

	return {
		name  = string.format("%s  (Boss %d - %d km)", theme.name, index, index * BOSS),
		level = level,
		maxHp = scale(baseStats.maxHp, hpMul, 1),
		atk   = scale(baseStats.atk, atkMul, 1),
		exp   = scale(baseStats.exp, expMul, 1),
		gold  = scale(baseStats.gold, goldMul, 0),
		isBoss = true,
	}
end

-- exposed for debugging / tests only
ZoneService._track = track

return ZoneService
