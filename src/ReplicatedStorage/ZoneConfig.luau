--==============================================================
-- ZoneConfig  (ModuleScript - ReplicatedStorage)
-- Pure data for the zone system. Shared by server (enemy / boss
-- selection) and client (decor). Contains NO combat / XP / stat
-- logic - it only describes decor and the enemy roster per zone.
--
-- 1 zone = 10 km (decor grid). Prototype ships Zone 1 fully;
-- Zone 2 is only registered ("prepared") and left undeveloped.
--
-- Progression milestones (paliers) are distance-based and
-- independent from the decor zones:
--   * every 50 km  -> REST  (campfire regen + shop, one combined stop)
--   * every 100 km -> BOSS  (dynamic level, see ZoneService)
-- Priority when marks coincide: boss > rest.
--==============================================================

local ZoneConfig = {}

ZoneConfig.KM_PER_ZONE = 10

-- Milestone spacing (km). Marks land exactly on these multiples.
ZoneConfig.REST_EVERY_KM = 50   -- campfire (regen) + shop, same stop
ZoneConfig.BOSS_EVERY_KM = 10   -- GAME_SPEC.md 6.2 : one boss per zone

ZoneConfig.Zones = {
	--========================= ZONE 1 =========================
	[1] = {
		id = 1,
		name = "Plaine de l'Aube",
		developed = true,

		-- Decor palette applied by the client to the existing
		-- ScrollBackground layers (Far / Mid / Near + their props).
		decor = {
			farSky = Color3.fromRGB(15, 20, 40),
			star   = Color3.fromRGB(200, 200, 220),
			midSky = Color3.fromRGB(25, 35, 55),
			hill   = Color3.fromRGB(30, 45, 65),
			ground = Color3.fromRGB(35, 70, 35),
			tree   = Color3.fromRGB(20, 50, 20),
			rock   = Color3.fromRGB(60, 60, 65),
		},

		-- Regular enemies: one is rolled at random on each encounter.
		-- Multipliers are applied on top of the game's existing
		-- per-zone base stats (enemyStatsForZone in CombatServer),
		-- so the combat / XP / gold systems stay untouched.
		enemies = {
			{ name = "Slime",         level = 1, hpMul = 1.0, atkMul = 1.0, expMul = 1.0, goldMul = 1.0 },
			{ name = "Gobelin",       level = 1, hpMul = 1.2, atkMul = 1.1, expMul = 1.2, goldMul = 1.1 },
			{ name = "Loup Sauvage",  level = 2, hpMul = 0.9, atkMul = 1.3, expMul = 1.1, goldMul = 1.0 },
			{ name = "Chauve-souris", level = 1, hpMul = 0.7, atkMul = 0.9, expMul = 0.8, goldMul = 1.3 },
		},

		-- (Bosses are no longer per decor-zone. See ZoneConfig.BossThemes
		-- and ZoneService.rollBoss - they now trigger every 100 km with a
		-- dynamically computed level.)
	},

	--========================= ZONE 2 =========================
	-- Registered / "prepared" only. Not developed yet: no enemy
	-- roster, no boss. Decor is defined so the transition at
	-- 10 km is visible, but nothing else about Zone 2 exists.
	[2] = {
		id = 2,
		name = "Zone 2",
		developed = false,

		decor = {
			farSky = Color3.fromRGB(40, 15, 20),
			star   = Color3.fromRGB(230, 200, 190),
			midSky = Color3.fromRGB(55, 25, 25),
			hill   = Color3.fromRGB(70, 35, 30),
			ground = Color3.fromRGB(70, 45, 30),
			tree   = Color3.fromRGB(55, 35, 20),
			rock   = Color3.fromRGB(75, 60, 55),
		},

		enemies = {}, -- TODO Zone 2
	},
}

--============ Boss themes (one per 100 km milestone) ============
-- Cosmetic only: name / optional stat multipliers. The boss LEVEL
-- is computed dynamically by ZoneService from the distance and the
-- player's own level - never a fixed value.
-- Intermediate bosses (zone gate, every 10 km). Generic elite identities; the
-- list cycles. `magic` alternates so the player meets both damage types often.
ZoneConfig.IntermediateBosses = {
	{ name = "Champion de la Zone", magic = false, atkSplit = 0.80 },
	{ name = "Sentinelle Ancienne", magic = false, atkSplit = 0.85 },
	{ name = "Adepte Corrompu",     magic = true,  atkSplit = 0.35 },
	{ name = "Brute d'Elite",       magic = false, atkSplit = 0.90 },
	{ name = "Invocateur Errant",   magic = true,  atkSplit = 0.30 },
}

function ZoneConfig.intermediateBoss(index)
	local n = #ZoneConfig.IntermediateBosses
	if index >= 1 and n > 0 then
		return ZoneConfig.IntermediateBosses[((index - 1) % n) + 1]
	end
	return { name = "Champion de la Zone", magic = false, atkSplit = 0.80 }
end

-- 12 BIG bosses at launch (GAME_SPEC.md 6.2), one every 100 km (10 zones).
-- `magic = true` -> deals magic damage (player RES matters); `atkSplit` is the
-- ATK/INT ratio shown in the info panel.
ZoneConfig.BossThemes = {
	{ name = "Roi Gobelin",         magic = false, atkSplit = 0.75 },  -- km 10
	{ name = "Golem de Pierre",     magic = false, atkSplit = 0.90 },  -- km 20
	{ name = "Sorciere des Bois",   magic = true,  atkSplit = 0.35 },  -- km 30
	{ name = "Colosse des Cendres", magic = false, atkSplit = 0.80 },  -- km 40
	{ name = "Liche Glaciale",      magic = true,  atkSplit = 0.25 },  -- km 50
	{ name = "Tyran des Abysses",   magic = false, atkSplit = 0.70 },  -- km 60
	{ name = "Archimage Dechu",     magic = true,  atkSplit = 0.20 },  -- km 70
	{ name = "Behemoth",            magic = false, atkSplit = 0.85 },  -- km 80
	{ name = "Spectre Hurlant",     magic = true,  atkSplit = 0.40 },  -- km 90
	{ name = "Dragon de Fer",       magic = false, atkSplit = 0.80 },  -- km 100
	{ name = "Oeil du Vide",        magic = true,  atkSplit = 0.15 },  -- km 110
	{ name = "Avatar de la Fin",    magic = false, atkSplit = 0.60 },  -- km 120
}

-- Cycles the theme list past boss 12 (deeper zones reuse identities, stats keep scaling).
function ZoneConfig.bossTheme(index)
	local n = #ZoneConfig.BossThemes
	if index >= 1 and n > 0 then
		return ZoneConfig.BossThemes[((index - 1) % n) + 1]
	end
	return { name = "Gardien du palier " .. tostring(index), magic = false, atkSplit = 0.75 }
end

function ZoneConfig.getZone(id)
	return ZoneConfig.Zones[id]
end

-- Zone id from a server distance in km (1 zone = KM_PER_ZONE km).
function ZoneConfig.zoneIdFromKm(km)
	return math.floor(km / ZoneConfig.KM_PER_ZONE) + 1
end

return ZoneConfig
