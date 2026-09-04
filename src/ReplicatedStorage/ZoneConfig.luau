--==============================================================
-- ZoneConfig  (ModuleScript - ReplicatedStorage)
-- Pure data for the zone system. Shared by server (enemy / boss
-- selection) and client (decor). Contains NO combat / XP / stat
-- logic - it only describes decor and the enemy roster per zone.
--
-- 1 zone = 1 "couche" = 10 km (KM_PER_ZONE), 10 steps of 1 km.
-- The 12 couches of "La Descente" (see design/narrative/la-descente.md)
-- are all defined here with their 6-monster roster and decor palette.
--
-- Progression milestones (paliers) are distance-based and
-- independent from the decor zones:
--   * every 50 km  -> REST  (campfire regen + shop, one combined stop)
--   * every 10 km  -> BOSS  (dynamic level, see ZoneService) - a named
--                     Gardien closes each couche
-- Priority when marks coincide: boss > rest.
--
-- Enemy `id` / boss `id` / boss `bigId` = sprite slug in AssetMap
-- (client-side art only; enters NO combat math).
--==============================================================

local ZoneConfig = {}

ZoneConfig.KM_PER_ZONE = 10

-- Milestone spacing (km). Marks land exactly on these multiples.
ZoneConfig.REST_EVERY_KM = 50   -- campfire (regen) + shop, same stop
ZoneConfig.BOSS_EVERY_KM = 10   -- one Gardien per couche

--============ Enemy role multipliers (D3 - validated 2026-08-31) ============
-- Applied by EnemyService on top of the level-driven base stats
-- (hp / atk / exp / gold). Tune here, not per-monster. Calibrated so the
-- 6-role AVERAGE HP*ATK product = ~1.01 => "a mob of level L ~= a player of
-- level L" (with refPointsPerLevel 4.7); the player's edge is first-strike +
-- gear + pets + regen + earned points.
local R = {
	chaff   = { hpMul = 0.60, atkMul = 0.75, expMul = 0.60, goldMul = 1.15 },  -- product 0.45
	swift   = { hpMul = 0.72, atkMul = 1.35, expMul = 0.95, goldMul = 0.90 },  -- product 0.97
	bruiser = { hpMul = 1.00, atkMul = 1.05, expMul = 1.10, goldMul = 1.05 },  -- product 1.05
	tank    = { hpMul = 1.85, atkMul = 0.65, expMul = 1.40, goldMul = 1.20 },  -- product 1.20
	caster  = { hpMul = 0.68, atkMul = 1.42, expMul = 1.15, goldMul = 1.05 },  -- product 0.97 (magic)
	elite   = { hpMul = 1.30, atkMul = 1.10, expMul = 1.70, goldMul = 1.55 },  -- product 1.43
}

-- mk("Nom affiché", "mob_slug", "role", "Famille", "petRole") -> flat enemy def.
--   Famille (codex, Q57): Bête / Mort-vivant / Élémentaire / Humanoïde / Construct.
--   petRole (Q54): Heal / DPS / Tank - the familiar's signature role.
--   casters get magic = true (dormant data; EnemyService.rollEnemy + CombatServer
--   wire it later so player RES matters - Track G3).
local function mk(name, id, role, famille, petRole)
	local m = R[role] or R.bruiser
	return {
		name = name, id = id, role = role,
		famille = famille, petRole = petRole,
		magic = (role == "caster") or nil,
		hpMul = m.hpMul, atkMul = m.atkMul, expMul = m.expMul, goldMul = m.goldMul,
	}
end

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

ZoneConfig.Zones = {
	--===================== COUCHE 1 - Plaine de l'Aube =====================
	[1] = {
		id = 1, name = "Plaine de l'Aube", developed = true,
		decor = {
			farSky = rgb(20, 26, 54), star = rgb(205, 205, 225), midSky = rgb(30, 40, 60),
			hill = rgb(34, 50, 40), ground = rgb(46, 74, 40), tree = rgb(24, 54, 24), rock = rgb(64, 62, 58),
		},
		enemies = {
			mk("Rat", "mob_c01_rat", "chaff", "Bête", "Heal"),
			mk("Larve de Poussière", "mob_c01_larve_poussiere", "chaff", "Bête", "Heal"),
			mk("Gobelin Maraudeur", "mob_c01_gobelin_maraudeur", "swift", "Humanoïde", "DPS"),
			mk("Loup Efflanqué", "mob_c01_loup_efflanque", "bruiser", "Bête", "Tank"),
			mk("Épouvantail", "mob_c01_epouvantail", "caster", "Construct", "Heal"),
			mk("Ogre du Sentier", "mob_c01_ogre_sentier", "tank", "Humanoïde", "Tank"),
		},
	},

	--===================== COUCHE 2 - Carrière des Runes =====================
	[2] = {
		id = 2, name = "Carrière des Runes", developed = true,
		decor = {
			farSky = rgb(60, 64, 70), star = rgb(90, 180, 180), midSky = rgb(78, 82, 88),
			hill = rgb(74, 76, 80), ground = rgb(92, 88, 82), tree = rgb(60, 80, 70), rock = rgb(112, 108, 104),
		},
		enemies = {
			mk("Chien de Gravats", "mob_c02_chien_gravats", "chaff", "Construct", "Heal"),
			mk("Rampant de la Carrière", "mob_c02_rampant_carriere", "swift", "Bête", "DPS"),
			mk("Éclat Runique", "mob_c02_eclat_runique", "caster", "Élémentaire", "Heal"),
			mk("Tailleur Maudit", "mob_c02_tailleur_maudit", "bruiser", "Humanoïde", "Tank"),
			mk("Sentinelle Gravée", "mob_c02_sentinelle_gravee", "elite", "Construct", "DPS"),
			mk("Colosse de la Carrière", "mob_c02_colosse_carriere", "tank", "Construct", "Tank"),
		},
	},

	--===================== COUCHE 3 - Bois des Murmures =====================
	[3] = {
		id = 3, name = "Bois des Murmures", developed = true,
		decor = {
			farSky = rgb(18, 24, 22), star = rgb(120, 200, 140), midSky = rgb(26, 34, 30),
			hill = rgb(24, 32, 28), ground = rgb(30, 36, 28), tree = rgb(16, 30, 16), rock = rgb(44, 42, 48),
		},
		enemies = {
			mk("Feu Follet", "mob_c03_feu_follet", "chaff", "Élémentaire", "Heal"),
			mk("Sylphe des Ronces", "mob_c03_sylphe_ronce", "swift", "Élémentaire", "DPS"),
			mk("Loup Sylvestre", "mob_c03_loup_sylvestre", "bruiser", "Bête", "Tank"),
			mk("Pendu des Branches", "mob_c03_pendu_branches", "caster", "Mort-vivant", "Heal"),
			mk("Champignon Rôdeur", "mob_c03_champignon_rodeur", "tank", "Bête", "Tank"),
			mk("Tréant Tordu", "mob_c03_treant_tordu", "elite", "Bête", "DPS"),
		},
	},

	--===================== COUCHE 4 - Champs de Cendres =====================
	[4] = {
		id = 4, name = "Champs de Cendres", developed = true,
		decor = {
			farSky = rgb(30, 14, 12), star = rgb(255, 140, 60), midSky = rgb(40, 18, 16),
			hill = rgb(36, 22, 20), ground = rgb(28, 22, 20), tree = rgb(40, 20, 16), rock = rgb(32, 30, 32),
		},
		enemies = {
			mk("Braise Vive", "mob_c04_braise_vive", "chaff", "Élémentaire", "Heal"),
			mk("Molosse de Suie", "mob_c04_molosse_suie", "swift", "Bête", "DPS"),
			mk("Cendreux", "mob_c04_cendreux", "bruiser", "Élémentaire", "Tank"),
			mk("Porte-Torche", "mob_c04_porte_torche", "caster", "Humanoïde", "Heal"),
			mk("Fantassin Calciné", "mob_c04_fantassin_calcine", "elite", "Mort-vivant", "DPS"),
			mk("Colosse de Braise", "mob_c04_colosse_braise", "tank", "Élémentaire", "Tank"),
		},
	},

	--===================== COUCHE 5 - Toundra des Âmes =====================
	[5] = {
		id = 5, name = "Toundra des Âmes", developed = true,
		decor = {
			farSky = rgb(150, 180, 205), star = rgb(200, 240, 255), midSky = rgb(170, 195, 215),
			hill = rgb(180, 200, 215), ground = rgb(200, 215, 225), tree = rgb(140, 170, 190), rock = rgb(155, 178, 198),
		},
		enemies = {
			mk("Éclat d'Âme", "mob_c05_eclat_ame", "chaff", "Mort-vivant", "Heal"),
			mk("Givreux", "mob_c05_givreux", "swift", "Élémentaire", "DPS"),
			mk("Loup de Givre", "mob_c05_loup_givre", "bruiser", "Bête", "Tank"),
			mk("Pleureuse Voilée", "mob_c05_pleureuse_voilee", "caster", "Mort-vivant", "Heal"),
			mk("Marcheur Gelé", "mob_c05_marcheur_gele", "tank", "Mort-vivant", "Tank"),
			mk("Titan de Glace", "mob_c05_titan_glace", "elite", "Élémentaire", "DPS"),
		},
	},

	--===================== COUCHE 6 - Côte des Naufrages =====================
	[6] = {
		id = 6, name = "Côte des Naufrages", developed = true,
		decor = {
			farSky = rgb(20, 40, 45), star = rgb(200, 220, 225), midSky = rgb(30, 52, 56),
			hill = rgb(34, 54, 52), ground = rgb(40, 58, 55), tree = rgb(30, 50, 45), rock = rgb(55, 60, 62),
		},
		enemies = {
			mk("Feu de Brume", "mob_c06_feu_brume", "chaff", "Élémentaire", "Heal"),
			mk("Marin Noyé", "mob_c06_marin_noye", "swift", "Mort-vivant", "DPS"),
			mk("Crabe d'Épave", "mob_c06_crabe_epave", "bruiser", "Bête", "Tank"),
			mk("Murène Dressée", "mob_c06_murene_dressee", "caster", "Bête", "Heal"),
			mk("Garde Corallien", "mob_c06_garde_corallien", "tank", "Construct", "Tank"),
			mk("Léviathan Échoué", "mob_c06_leviathan_echoue", "elite", "Bête", "DPS"),
		},
	},

	--===================== COUCHE 7 - Ruines d'Aethel =====================
	[7] = {
		id = 7, name = "Ruines d'Aethel", developed = true,
		decor = {
			farSky = rgb(40, 30, 55), star = rgb(220, 120, 230), midSky = rgb(55, 42, 72),
			hill = rgb(70, 60, 90), ground = rgb(120, 110, 100), tree = rgb(90, 80, 110), rock = rgb(200, 195, 185),
		},
		enemies = {
			mk("Glyphe Flottant", "mob_c07_glyphe_flottant", "chaff", "Élémentaire", "Heal"),
			mk("Chien d'Albâtre", "mob_c07_chien_albatre", "swift", "Construct", "DPS"),
			mk("Automate Brisé", "mob_c07_automate_brise", "bruiser", "Construct", "Tank"),
			mk("Érudit Spectral", "mob_c07_erudit_spectral", "caster", "Mort-vivant", "Heal"),
			mk("Gardien de Marbre", "mob_c07_gardien_marbre", "tank", "Construct", "Tank"),
			mk("Sphinx Déchu", "mob_c07_sphinx_dechu", "elite", "Bête", "DPS"),
		},
	},

	--===================== COUCHE 8 - Terres Brisées =====================
	[8] = {
		id = 8, name = "Terres Brisées", developed = true,
		decor = {
			farSky = rgb(70, 50, 35), star = rgb(230, 200, 160), midSky = rgb(90, 66, 44),
			hill = rgb(100, 74, 50), ground = rgb(110, 80, 55), tree = rgb(90, 64, 40), rock = rgb(150, 120, 90),
		},
		enemies = {
			mk("Fragment Vif", "mob_c08_fragment_vif", "chaff", "Élémentaire", "Heal"),
			mk("Rampe des Angles", "mob_c08_rampe_angles", "swift", "Construct", "DPS"),
			mk("Errant Défait", "mob_c08_errant_defait", "bruiser", "Mort-vivant", "Tank"),
			mk("Veilleur Fracturé", "mob_c08_veilleur_fracture", "caster", "Construct", "Heal"),
			mk("Chien Non-Euclidien", "mob_c08_chien_non_euclidien", "elite", "Bête", "DPS"),
			mk("Masse Aberrante", "mob_c08_masse_aberrante", "tank", "Élémentaire", "Tank"),
		},
	},

	--===================== COUCHE 9 - Landes du Deuil =====================
	[9] = {
		id = 9, name = "Landes du Deuil", developed = true,
		decor = {
			farSky = rgb(55, 62, 60), star = rgb(160, 210, 210), midSky = rgb(62, 70, 68),
			hill = rgb(60, 68, 66), ground = rgb(66, 72, 68), tree = rgb(50, 58, 54), rock = rgb(90, 94, 92),
		},
		enemies = {
			mk("Lueur du Deuil", "mob_c09_lueur_deuil", "chaff", "Mort-vivant", "Heal"),
			mk("Chien de Cendre et d'Os", "mob_c09_chien_cendre_os", "swift", "Mort-vivant", "DPS"),
			mk("Porte-Étendard", "mob_c09_porte_etendard", "bruiser", "Humanoïde", "Tank"),
			mk("Poupée-Suaire", "mob_c09_poupee_suaire", "caster", "Construct", "Heal"),
			mk("Spectre de Linceul", "mob_c09_spectre_linceul", "elite", "Mort-vivant", "DPS"),
			mk("Golgoth du Deuil", "mob_c09_golgoth_deuil", "tank", "Construct", "Tank"),
		},
	},

	--===================== COUCHE 10 - Forge de Fer =====================
	[10] = {
		id = 10, name = "Forge de Fer", developed = true,
		decor = {
			farSky = rgb(35, 32, 34), star = rgb(255, 150, 70), midSky = rgb(48, 44, 44),
			hill = rgb(55, 48, 44), ground = rgb(50, 45, 42), tree = rgb(60, 50, 40), rock = rgb(80, 76, 74),
		},
		enemies = {
			mk("Rivet Vivant", "mob_c10_rivet_vivant", "chaff", "Construct", "Heal"),
			mk("Molosse à Vapeur", "mob_c10_molosse_vapeur", "swift", "Construct", "DPS"),
			mk("Ouvrier de Fonte", "mob_c10_ouvrier_fonte", "bruiser", "Humanoïde", "Tank"),
			mk("Foreuse Naine", "mob_c10_foreuse_naine", "caster", "Humanoïde", "Heal"),
			mk("Contremaître Blindé", "mob_c10_contremaitre_blinde", "tank", "Humanoïde", "Tank"),
			mk("Marteleur de Forge", "mob_c10_marteleur_forge", "elite", "Construct", "DPS"),
		},
	},

	--===================== COUCHE 11 - Faille du Vide =====================
	[11] = {
		id = 11, name = "Faille du Vide", developed = true,
		decor = {
			farSky = rgb(10, 6, 18), star = rgb(200, 80, 220), midSky = rgb(18, 10, 30),
			hill = rgb(22, 14, 36), ground = rgb(16, 12, 24), tree = rgb(30, 18, 44), rock = rgb(36, 30, 48),
		},
		enemies = {
			mk("Étincelle du Vide", "mob_c11_etincelle_vide", "chaff", "Élémentaire", "Heal"),
			mk("Limier du Vide", "mob_c11_limier_vide", "swift", "Bête", "DPS"),
			mk("Rampant d'Ombre", "mob_c11_rampant_ombre", "bruiser", "Élémentaire", "Tank"),
			mk("Porteur du Néant", "mob_c11_porteur_neant", "caster", "Humanoïde", "Heal"),
			mk("Veilleur aux Yeux", "mob_c11_veilleur_yeux", "elite", "Élémentaire", "DPS"),
			mk("Gueule Béante", "mob_c11_gueule_beante", "tank", "Bête", "Tank"),
		},
	},

	--===================== COUCHE 12 - Fin de Toute Chose =====================
	[12] = {
		id = 12, name = "Fin de Toute Chose", developed = true,
		decor = {
			farSky = rgb(6, 6, 14), star = rgb(255, 255, 255), midSky = rgb(12, 12, 24),
			hill = rgb(16, 16, 30), ground = rgb(10, 10, 18), tree = rgb(20, 18, 34), rock = rgb(26, 24, 40),
		},
		enemies = {
			mk("Poussière Finale", "mob_c12_poussiere_finale", "chaff", "Élémentaire", "Heal"),
			mk("Ombre Portée", "mob_c12_ombre_portee", "swift", "Élémentaire", "DPS"),
			mk("Reliquat", "mob_c12_reliquat", "bruiser", "Mort-vivant", "Tank"),
			mk("Témoin Silencieux", "mob_c12_temoin_silencieux", "caster", "Construct", "Heal"),
			mk("Effondrement", "mob_c12_effondrement", "elite", "Élémentaire", "DPS"),
			mk("Gardien du Seuil", "mob_c12_gardien_seuil", "tank", "Construct", "Tank"),
		},
	},
}

--============ Intermediate bosses (unused at 10 km spacing; kept for tuning) ============
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

--============ Les 12 Gardiens (one per couche, every 10 km) ============
-- `id`    = boss sprite slug (the Gardien, met at km = index * 10)
-- `bigId` = big-boss sprite slug (the "Gueule" / forme de domaine, every 100 km)
-- `magic` = deals magic damage (player RES matters); `atkSplit` = ATK/INT ratio shown.
-- `famille` = Codex grouping (codex-gdd.md SS2.4). Thematic call, not
-- mechanical: e.g. "Dragon de Fer" reads Construct (an iron-forge automaton,
-- zone 10 theme) rather than Bête. Easy to re-tag later; only affects which
-- Codex family the boss counts toward.
ZoneConfig.BossThemes = {
	{ name = "Roi Gobelin",         id = "boss_roi_gobelin",     bigId = "bigboss_roi_gobelin",     magic = false, atkSplit = 0.75, famille = "Humanoïde" },   -- km 10
	{ name = "Golem de Pierre",     id = "boss_golem_pierre",    bigId = "bigboss_golem_pierre",    magic = false, atkSplit = 0.90, famille = "Construct" },   -- km 20
	{ name = "Sorciere des Bois",   id = "boss_sorciere_bois",   bigId = "bigboss_sorciere_bois",   magic = true,  atkSplit = 0.35, famille = "Humanoïde" },   -- km 30
	{ name = "Colosse des Cendres", id = "boss_colosse_cendres", bigId = "bigboss_colosse_cendres", magic = false, atkSplit = 0.80, famille = "Élémentaire" }, -- km 40
	{ name = "Liche Glaciale",      id = "boss_liche_glaciale",  bigId = "bigboss_liche_glaciale",  magic = true,  atkSplit = 0.25, famille = "Mort-vivant" }, -- km 50
	{ name = "Tyran des Abysses",   id = "boss_tyran_abysses",   bigId = "bigboss_tyran_abysses",   magic = false, atkSplit = 0.70, famille = "Bête" },        -- km 60
	{ name = "Archimage Dechu",     id = "boss_archimage_dechu", bigId = "bigboss_archimage_dechu", magic = true,  atkSplit = 0.20, famille = "Humanoïde" },   -- km 70
	{ name = "Behemoth",            id = "boss_behemoth",        bigId = "bigboss_behemoth",        magic = false, atkSplit = 0.85, famille = "Bête" },        -- km 80
	{ name = "Spectre Hurlant",     id = "boss_spectre_hurlant", bigId = "bigboss_spectre_hurlant", magic = true,  atkSplit = 0.40, famille = "Mort-vivant" }, -- km 90
	{ name = "Dragon de Fer",       id = "boss_dragon_fer",      bigId = "bigboss_dragon_fer",      magic = false, atkSplit = 0.80, famille = "Construct" },   -- km 100
	{ name = "Oeil du Vide",        id = "boss_oeil_vide",       bigId = "bigboss_oeil_vide",       magic = true,  atkSplit = 0.15, famille = "Élémentaire" }, -- km 110
	{ name = "Avatar de la Fin",    id = "boss_avatar_fin",      bigId = "bigboss_avatar_fin",      magic = false, atkSplit = 0.60, famille = "Élémentaire" }, -- km 120
}

-- Cycles the theme list past boss 12 (deeper couches reuse identities, stats keep scaling).
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
