--==============================================================
-- EquipmentConfig  (ModuleScript - ReplicatedStorage)
-- Pure data for the equipment system. Shared by client and server.
-- Contains NO logic and NO combat math - it only describes items,
-- rarities and slots. Mirrors the ZoneConfig pattern.
--
-- Owned / equipped instance shape (matches GAME_SPEC.md section 11
-- `equipe`, so a future ProfileStore layer can serialize it unchanged):
--   arme / casque / plastron / jambieres / bottes = { id, voie, rarete }
--   pet                                           = { id, role, rarete }
--
-- Lv is indicative only (section 4.1): stored as `lvIndicatif` on the
-- definition, never on the instance, never used in any calculation.
--==============================================================

local EquipmentConfig = {}

-- The 6 equipment slots (section 4.2).
EquipmentConfig.SLOTS = { "arme", "casque", "plastron", "jambieres", "bottes", "pet" }

-- The 4 armor slots, in display order (used for the HUD set summary).
EquipmentConfig.ARMOR_SLOTS = { "casque", "plastron", "jambieres", "bottes" }

--===== Rarity table (section 4.3) =====
-- Ordered weakest -> strongest. `mult` scales an item's DERIVED power
-- (GameConfig.Equipment.weaponPct / armorStat take this as rarityMult).
-- `chance` is the drop weight (for the future loot system).
-- `divin` is defined for a future update but inactive: equip() and any
-- future loot roll must skip rarities whose `active` is false.
-- D4 (validated 2026-09-01): WIDE band restored (reverts the "Etape 4.0" tightening).
-- Rarity is a PURE power multiplier. A Mythique is an event (GDD pillar 3): it stays
-- ahead ~6 zones (6.0 / 1.30^6 = 1.24). Applies to weapons (weaponPct) AND armor (armorStat).
EquipmentConfig.Rarities = {
    { id = "commun",     label = "Commun",     mult = 1.0, chance = 0.60,   active = true },
    { id = "rare",       label = "Rare",       mult = 1.5, chance = 0.25,   active = true },
    { id = "epique",     label = "Épique",     mult = 2.2, chance = 0.10,   active = true },
    { id = "legendaire", label = "Légendaire", mult = 3.5, chance = 0.04,   active = true },
    { id = "mythique",   label = "Mythique",   mult = 6.0, chance = 0.01,   active = true },
    { id = "divin",      label = "Divin",      mult = 9.0, chance = 0.0005, active = false },
}

function EquipmentConfig.getRarity(id)
    for _, r in ipairs(EquipmentConfig.Rarities) do
        if r.id == id then
            return r
        end
    end
    return nil
end

--===== Weapons (D4: 50 total = 2 starter + 24 shop + 24 boss) =====
-- Power is DERIVED from (zone, rarity); defs carry identity + zone only.
EquipmentConfig.Weapons = {
    --=== Starter weapons (given at hero creation - FTUE "arme de tier 1"). Zone 1,
    --=== deliberately weak (isStarter -> x0.5 power) so the first shop weapon / drop
    --=== is a real upgrade. ===--
    epee_courte = {
        nom = "Épée ébréchée", slot = "arme", voie = "guerrier",
        zone = 1, lvIndicatif = 1, isStarter = true,
    },
    baguette_simple = {
        nom = "Badine fêlée", slot = "arme", voie = "mage",
        zone = 1, lvIndicatif = 1, isStarter = true,
    },
}

--===== Shop / progression weapons (D4 - validated 2026-09-01) =====
-- 24 weapons: 1 epee (guerrier) + 1 baguette (mage) per couche (zone 1..12). Power is
-- DERIVED from (zone, rarity) via GameConfig.Equipment.weaponPct - these defs carry
-- identity + zone only. lvIndicatif = round(35*zone - 17.5) (mid-couche mob level on
-- the round(km*3.5) scale), indicative, never gates.
local SHOP_WEAPON_DEFS = {
    { zone = 1,  epee = "Lame de l'Aube",      baguette = "Badine de l'Aube" },
    { zone = 2,  epee = "Tailloir Runique",    baguette = "Éclat Runique" },
    { zone = 3,  epee = "Serpe des Murmures",  baguette = "Rameau Chuchotant" },
    { zone = 4,  epee = "Braisière",           baguette = "Tison Ardent" },
    { zone = 5,  epee = "Croc de Givre",       baguette = "Stalactite Spirituelle" },
    { zone = 6,  epee = "Sabre d'Épave",       baguette = "Trident Corallien" },
    { zone = 7,  epee = "Glaive d'Albâtre",    baguette = "Sceptre d'Aethel" },
    { zone = 8,  epee = "Éclat Non-Euclidien", baguette = "Angle Impossible" },
    { zone = 9,  epee = "Fauchon du Deuil",    baguette = "Crosse de Linceul" },
    { zone = 10, epee = "Marteau de Fonte",    baguette = "Chalumeau Runique" },
    { zone = 11, epee = "Entaille du Vide",    baguette = "Doigt du Néant" },
    { zone = 12, epee = "Dernier Tranchant",   baguette = "Verbe Final" },
}

for _, def in ipairs(SHOP_WEAPON_DEFS) do
    local lv = math.round(35 * def.zone - 17.5)
    EquipmentConfig.Weapons[string.format("epee_z%02d", def.zone)] = {
        nom = def.epee, slot = "arme", voie = "guerrier", zone = def.zone, lvIndicatif = lv,
    }
    EquipmentConfig.Weapons[string.format("baguette_z%02d", def.zone)] = {
        nom = def.baguette, slot = "arme", voie = "mage", zone = def.zone, lvIndicatif = lv,
    }
end

--===== Sets + set bonuses (GAME_SPEC.md 5.1) =====
-- A set bonus applies ONLY when N equipped armor pieces share the SAME set AND
-- the SAME voie (a 2 guerrier + 2 mage mix triggers nothing). Symmetric across
-- voies: the "damage" % scales the player's EFFECTIVE ATK (physical or magic per
-- the equipped weapon), "hp" scales MaxHP, "speed" scales attack cadence.
-- Base bonus per matched-piece count. A set's `identity` reshapes these.
EquipmentConfig.SetBonusTiers = {
    [2] = { damage = 0.15, hp = 0.00, speed = 0.00 },
    [3] = { damage = 0.30, hp = 0.20, speed = 0.00 },
    [4] = { damage = 0.50, hp = 0.40, speed = 0.15 },
}

-- Set identities (GAME_SPEC.md 5.1: "chaque set doit avoir une identite propre").
-- Multipliers applied to the base tier bonus.
EquipmentConfig.SetIdentities = {
    offensif  = { damage = 1.35, hp = 0.60, speed = 0.50 },
    defensif  = { damage = 0.60, hp = 1.55, speed = 0.50 },
    rapide    = { damage = 0.80, hp = 0.70, speed = 2.00 },
    equilibre = { damage = 1.00, hp = 1.00, speed = 1.00 },
}

EquipmentConfig.Sets = {
    toile = { nom = "Toile", identity = "equilibre" },  -- starter set
}

-- Bonus for `count` matching pieces of set `setId` (same voie). nil below 2.
function EquipmentConfig.getSetBonus(count, setId)
    local tier = EquipmentConfig.SetBonusTiers[math.clamp(math.floor(count or 0), 0, 4)]
    if not tier then return nil end
    local set = setId and EquipmentConfig.Sets[setId]
    local idn = set and EquipmentConfig.SetIdentities[set.identity or "equilibre"]
        or EquipmentConfig.SetIdentities.equilibre
    return {
        damage = tier.damage * idn.damage,
        hp     = tier.hp     * idn.hp,
        speed  = tier.speed  * idn.speed,
    }
end

--===== Armor (sample: Roi Gobelin set, 4 pieces x 2 voies) =====
-- Guerrier armor -> mostly DEF, Mage armor -> mostly RES (section 3.2).
EquipmentConfig.Armor = {
    casque_gobelin_g    = { nom = "Casque du Roi Gobelin",    slot = "casque",    voie = "guerrier", set = "roi_gobelin", lvIndicatif = 100, base = { def = 40, hp = 200 } },
    plastron_gobelin_g  = { nom = "Plastron du Roi Gobelin",  slot = "plastron",  voie = "guerrier", set = "roi_gobelin", lvIndicatif = 100, base = { def = 60, hp = 300 } },
    jambieres_gobelin_g = { nom = "Jambières du Roi Gobelin", slot = "jambieres", voie = "guerrier", set = "roi_gobelin", lvIndicatif = 100, base = { def = 45, hp = 220 } },
    bottes_gobelin_g    = { nom = "Bottes du Roi Gobelin",    slot = "bottes",    voie = "guerrier", set = "roi_gobelin", lvIndicatif = 100, base = { def = 30, hp = 150 } },

    casque_gobelin_m    = { nom = "Casque du Roi Gobelin",    slot = "casque",    voie = "mage", set = "roi_gobelin", lvIndicatif = 100, base = { res = 40, hp = 200 } },
    plastron_gobelin_m  = { nom = "Plastron du Roi Gobelin",  slot = "plastron",  voie = "mage", set = "roi_gobelin", lvIndicatif = 100, base = { res = 60, hp = 300 } },
    jambieres_gobelin_m = { nom = "Jambières du Roi Gobelin", slot = "jambieres", voie = "mage", set = "roi_gobelin", lvIndicatif = 100, base = { res = 45, hp = 220 } },
    bottes_gobelin_m    = { nom = "Bottes du Roi Gobelin",    slot = "bottes",    voie = "mage", set = "roi_gobelin", lvIndicatif = 100, base = { res = 30, hp = 150 } },

    --=== Low-tier test set "Toile" (early game). DEF/RES + small HP. ===--
    casque_toile_g    = { nom = "Coiffe de toile",   slot = "casque",    voie = "guerrier", set = "toile", lvIndicatif = 1, base = { def = 3, hp = 10 } },
    plastron_toile_g  = { nom = "Tunique de toile",  slot = "plastron",  voie = "guerrier", set = "toile", lvIndicatif = 1, base = { def = 5, hp = 15 } },
    jambieres_toile_g = { nom = "Chausses de toile", slot = "jambieres", voie = "guerrier", set = "toile", lvIndicatif = 1, base = { def = 4, hp = 12 } },
    bottes_toile_g    = { nom = "Bottes de toile",   slot = "bottes",    voie = "guerrier", set = "toile", lvIndicatif = 1, base = { def = 2, hp = 8 } },

    casque_toile_m    = { nom = "Coiffe de toile",   slot = "casque",    voie = "mage", set = "toile", lvIndicatif = 1, base = { res = 3, hp = 10 } },
    plastron_toile_m  = { nom = "Tunique de toile",  slot = "plastron",  voie = "mage", set = "toile", lvIndicatif = 1, base = { res = 5, hp = 15 } },
    jambieres_toile_m = { nom = "Chausses de toile", slot = "jambieres", voie = "mage", set = "toile", lvIndicatif = 1, base = { res = 4, hp = 12 } },
    bottes_toile_m    = { nom = "Bottes de toile",   slot = "bottes",    voie = "mage", set = "toile", lvIndicatif = 1, base = { res = 2, hp = 8 } },
}

--===== Pets (sample: one per role - section 4.4 lists 40 at launch) =====
-- `role` is fixed on the pet (section 9). Tank / Heal effects are
-- percentages; DPS is a flat extra attacker.
EquipmentConfig.Pets = {
    pingouin = { nom = "Pingouin", role = "dps",  base = { dps = 25 } },
    tortue   = { nom = "Tortue",   role = "tank", base = { mitigationPct = 0.10 } },
    luciole  = { nom = "Luciole",  role = "heal", base = { regenPctPerSec = 0.02 } },
}

--===== Loot / shop item pool (etape 4.1) =====
-- The slots that can drop, with the concrete item id per voie. Item POWER is
-- derived from (zone, rarity) - these ids are only templates. Mirrors the
-- ShopService stock (kept in sync by hand until real content lands).
EquipmentConfig.LootPool = {
    { slot = "arme",      guerrier = "epee_courte",       mage = "baguette_simple" },
    { slot = "casque",    guerrier = "casque_toile_g",    mage = "casque_toile_m" },
    { slot = "plastron",  guerrier = "plastron_toile_g",  mage = "plastron_toile_m" },
    { slot = "jambieres", guerrier = "jambieres_toile_g", mage = "jambieres_toile_m" },
    { slot = "bottes",    guerrier = "bottes_toile_g",    mage = "bottes_toile_m" },
}

--===== Boss set + boss weapon content (GAME_SPEC.md 4.4 / 5.1 / 7.2) =====
-- 12 big-boss sets, one per ZoneConfig.BossThemes entry. Each = 4 armor pieces
-- x 2 voies (guerrier -> DEF, mage -> RES) + a boss weapon x 2 voies. Item power
-- is DERIVED from (zone, rarity); these defs carry identity only (name / set /
-- voie). Big bosses drop their own set (see LootService).
EquipmentConfig.BossWeaponPowerMult = 2.5   -- GAME_SPEC.md 7.2

local BOSS_SET_DEFS = {
    { id = "roi_gobelin",  nom = "Roi Gobelin",        identity = "equilibre" },
    { id = "golem_pierre", nom = "Golem de Pierre",    identity = "defensif" },
    { id = "sorciere",     nom = "Sorciere des Bois",  identity = "offensif" },
    { id = "colosse",      nom = "Colosse des Cendres", identity = "defensif" },
    { id = "liche",        nom = "Liche Glaciale",     identity = "offensif" },
    { id = "tyran",        nom = "Tyran des Abysses",  identity = "equilibre" },
    { id = "archimage",    nom = "Archimage Dechu",    identity = "offensif" },
    { id = "behemoth",     nom = "Behemoth",           identity = "defensif" },
    { id = "spectre",      nom = "Spectre Hurlant",    identity = "rapide" },
    { id = "dragon_fer",   nom = "Dragon de Fer",      identity = "equilibre" },
    { id = "oeil_vide",    nom = "Oeil du Vide",       identity = "offensif" },
    { id = "avatar_fin",   nom = "Avatar de la Fin",   identity = "rapide" },
}

local ARMOR_PIECES = {
    { slot = "casque",    label = "Casque" },
    { slot = "plastron",  label = "Plastron" },
    { slot = "jambieres", label = "Jambieres" },
    { slot = "bottes",    label = "Bottes" },
}

EquipmentConfig.BossSetIds = {}
for bossIndex, s in ipairs(BOSS_SET_DEFS) do
    EquipmentConfig.Sets[s.id] = { nom = s.nom, identity = s.identity, bossIndex = bossIndex }
    EquipmentConfig.BossSetIds[bossIndex] = s.id
    for _, voie in ipairs({ "guerrier", "mage" }) do
        local suffix = (voie == "guerrier") and "_g" or "_m"
        for _, piece in ipairs(ARMOR_PIECES) do
            EquipmentConfig.Armor[piece.slot .. "_" .. s.id .. suffix] = {
                nom  = piece.label .. " " .. s.nom,
                slot = piece.slot, voie = voie, set = s.id,
            }
        end
        EquipmentConfig.Weapons["arme_" .. s.id .. suffix] = {
            nom = ((voie == "guerrier") and "Lame de " or "Sceptre de ") .. s.nom,
            slot = "arme", voie = voie, set = s.id, isBossWeapon = true,
            zone = bossIndex, lvIndicatif = 35 * bossIndex,   -- [D4] boss weapon = x2.5 shop weapon of the same zone
        }
    end
end

EquipmentConfig.StarterWeaponPowerMult = 0.5   -- D4: creation-gift weapons are deliberately weak

-- Multiplier on a weapon's derived power. Boss weapons hit harder (x2.5, GAME_SPEC 7.2),
-- starter weapons are halved so the first real weapon is an upgrade.
function EquipmentConfig.weaponPowerMult(id)
    local w = EquipmentConfig.Weapons[id]
    if not w then return 1 end
    if w.isBossWeapon then return EquipmentConfig.BossWeaponPowerMult end
    if w.isStarter then return EquipmentConfig.StarterWeaponPowerMult end
    return 1
end

-- The 4 armor ids + 2 weapon ids of a boss set (by 1-based big-boss index).
function EquipmentConfig.bossSetItems(bossIndex)
    local setId = EquipmentConfig.BossSetIds[((bossIndex - 1) % #BOSS_SET_DEFS) + 1]
    local out = { setId = setId, armor = {}, weapons = {} }
    for _, voie in ipairs({ "guerrier", "mage" }) do
        local suffix = (voie == "guerrier") and "_g" or "_m"
        for _, piece in ipairs(ARMOR_PIECES) do
            out.armor[#out.armor + 1] = { id = piece.slot .. "_" .. setId .. suffix, slot = piece.slot, voie = voie }
        end
        out.weapons[#out.weapons + 1] = { id = "arme_" .. setId .. suffix, slot = "arme", voie = voie }
    end
    return out
end

--===== More pets (GAME_SPEC.md 4.4 lists 40; a starter dozen) =====
do
    local PET_DEFS = {
        { id = "pingouin",  nom = "Pingouin",   role = "dps" },
        { id = "renard",    nom = "Renard",     role = "dps" },
        { id = "faucon",    nom = "Faucon",     role = "dps" },
        { id = "panthere",  nom = "Panthere",   role = "dps" },
        { id = "tortue",    nom = "Tortue",     role = "tank" },
        { id = "blaireau",  nom = "Blaireau",   role = "tank" },
        { id = "rhino",     nom = "Rhinoceros", role = "tank" },
        { id = "ours",      nom = "Ours",       role = "tank" },
        { id = "luciole",   nom = "Luciole",    role = "heal" },
        { id = "meduse",    nom = "Meduse",     role = "heal" },
        { id = "licorne",   nom = "Licorne",    role = "heal" },
        { id = "phenix",    nom = "Phenix",     role = "heal" },
    }
    EquipmentConfig.Pets = {}
    for _, p in ipairs(PET_DEFS) do
        EquipmentConfig.Pets[p.id] = { nom = p.nom, role = p.role }
    end
end

--===== Unified lookup =====
-- Returns (definition, category) where category is "weapon" | "armor" | "pet".
function EquipmentConfig.getItem(id)
    if EquipmentConfig.Weapons[id] then
        return EquipmentConfig.Weapons[id], "weapon"
    end
    if EquipmentConfig.Armor[id] then
        return EquipmentConfig.Armor[id], "armor"
    end
    if EquipmentConfig.Pets[id] then
        return EquipmentConfig.Pets[id], "pet"
    end
    return nil, nil
end

return EquipmentConfig
