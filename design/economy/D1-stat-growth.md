# D1 — Table de croissance des stats (tableur de travail)

**Statut :** validé 2026-08-31 (proprio). Référence pour D3 (rosters) et D6 (playthrough).
**Sources :** master-gdd §5.1-5.2, Annexe A · reponses-consolidees Q26/Q28/Q29/Q117/Q119 ·
décisions de session (4 auto + 1 libre/5, mob niv = round(km×3.5), crit = min(1, LUK/2500)).

---

## 0. Modèle

- **4 points auto / niveau**, répartis en % par une table **classe × sous-classe** (`GameConfig.ClassGrowth`).
- **+1 point libre tous les 5 niveaux** (joueur, 1:1, n'importe quelle stat, SPD ≤ 200).
- **+ points de compétence gagnés** (Q29 : mission 1 · Donjon 2 · nouveau monstre 1 · 1er boss zone 3 ·
  nouvelle zone 2 · bonus complétion) — permanents, s'ajoutent par-dessus, alloués à la main.
- **DEF / RES** : équipement uniquement, jamais des stats.
- Niveau max = `100 + 20 × rebirths`. Les mobs continuent de scaler → **le mur EST la raison du Rebirth**.
- Mob niveau `L = round(km × 3.5)` → niveau 100 vers **km 28.6**.

Formules (Annexe A) :
```
physATK = (baseAtk 10 + POW × atkPerPow 2)          [+ equip, ×(1+weaponPct)]
magATK  = (baseMagicAtk 10 + INT × magicPerInt 2)   [+ equip, ×(1+weaponPct)]
PV max  = VIT × 5
cadence = 2.2 / (1 + (SPD − 1) × 0.0171)   plancher 0.5 s (SPD 200)
crit    = min(1, LUK / 2500)   [Destructeur : min(1, LUK/1800 + 0.0012 × niveau)]
DPS     = physATK × (1 + crit) / cadence
Issue   = on gagne ssi (PV_héros × DPS_héros) > (PV_ennemi × DPS_ennemi)   (héros frappe en 1er)
Ennemi  = combatBaseForLevel(L) : joueur-réf (L − 1) niv. plus bas, refPointsPerLevel 4.7,
          50 % VIT / 42 % POW, × enemyPowerScale 1.0
```

---

## 1. Table A — répartition des 4 points auto / niveau

| Table | POW | INT | VIT | SPD | LUK | Points/niveau | Identité |
|---|---|---|---|---|---|---|---|
| **Guerrier base** | 45 % | — | 40 % | 10 % | 5 % | POW +1.80 · VIT +1.60 · SPD +0.40 · LUK +0.20 | Équilibré. Référence 1.00. |
| **Mage base** | — | 31 % | 49 % | 10 % | 10 % | INT +1.24 · VIT +1.96 · SPD +0.40 · LUK +0.40 | −30 % dégâts bruts vs Guerrier (même cadence), +22 % PV. Le kit fait le reste. |
| **Berserker** (Guer. R5) | 42 % | — | 28 % | 22 % | 8 % | POW +1.68 · VIT +1.12 · SPD +0.88 · LUK +0.32 | Glass cannon, cadence très rapide, PV bas. |
| **Gardien** (Guer. R5) | 35 % | — | 55 % | 5 % | 5 % | POW +1.40 · VIT +2.20 · SPD +0.20 · LUK +0.20 | Mur de PV, gagne l'usure → tueur de boss. Clears lents. |
| **Destructeur** (Mage R5) | — | 40 % | 30 % | 8 % | 22 % | INT +1.60 · VIT +1.20 · SPD +0.32 · LUK +0.88 | Crit caster. Crit dédié (~17 % à L100 nu, scale gear/talents). |
| **Sage** (Mage R5) | — | 34 % | 52 % | 7 % | 7 % | INT +1.36 · VIT +2.08 · SPD +0.28 · LUK +0.28 | Sustain, PV élevés, synergie soin. |

- Part **SPD plafonnée à 22 %** (bonus Berserker assumé).
- Accumulation en flottant, affichage arrondi vers le bas.
- Avant R5 : table « de base » (neutre).
- `startingStats = { pow 2, int 2, vit 6, spd 1, luk 1 }` — la stat morte reste à sa valeur de départ.

---

## 2. Table B — Guerrier base, R0, **sans équipement**, vs ennemi de même niveau

`km = niveau / 3.5`. Ratio brut = `(PV×DPS)_héros / (PV×DPS)_ennemi`.
Ratio « + 1ère frappe » ≈ ratio_brut ÷ (1 − physATK/PV_ennemi) (le héros retire ~30 % des PV ennemi gratis).

| Niv | km | ATK | PV | cad. | DPS | PV×DPS héros | PV×DPS ennemi | ratio brut | + 1ère frappe |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.3 | 14 | 30 | 2.20 | 6 | 191 | 210 | 0.91 | 1.05 |
| 5 | 1.4 | 28 | 62 | 2.14 | 13 | 823 | 1 232 | 0.67 | 0.86 |
| 10 | 2.9 | 46 | 102 | 2.07 | 22 | 2 290 | 3 690 | 0.62 | 0.83 |
| 15 | 4.3 | 64 | 142 | 2.01 | 32 | 4 560 | 7 460 | 0.61 | 0.83 |
| 20 | 5.7 | 82 | 182 | 1.95 | 42 | 7 730 | 12 550 | 0.62 | 0.84 |
| 25 | 7.1 | 100 | 222 | 1.89 | 53 | 11 840 | 18 940 | 0.63 | 0.85 |
| 30 | 8.6 | 118 | 262 | 1.84 | 65 | 16 980 | 26 650 | 0.64 | 0.87 |
| 35 | 10.0 | 136 | 302 | 1.79 | 77 | 23 210 | 35 670 | 0.65 | 0.89 |
| 40 | 11.4 | 154 | 342 | 1.74 | 89 | 30 600 | 46 010 | 0.67 | 0.91 |
| 45 | 12.9 | 172 | 382 | 1.69 | 103 | 39 210 | 57 650 | 0.68 | 0.93 |
| 50 | 14.3 | 190 | 422 | 1.65 | 116 | 49 130 | 70 610 | 0.70 | 0.96 |
| 55 | 15.7 | 208 | 462 | 1.61 | 131 | 60 430 | 84 880 | 0.71 | 0.98 |
| 60 | 17.1 | 226 | 502 | 1.57 | 146 | 73 160 | 100 480 | 0.73 | 1.01 |
| 65 | 18.6 | 244 | 542 | 1.53 | 161 | 87 430 | 117 360 | 0.75 | 1.03 |
| 70 | 20.0 | 262 | 582 | 1.50 | 177 | 103 270 | 135 570 | 0.76 | 1.06 |
| 75 | 21.4 | 280 | 622 | 1.46 | 194 | 120 790 | 155 090 | 0.78 | 1.08 |
| 80 | 22.9 | 298 | 662 | 1.43 | 211 | 140 000 | 175 930 | 0.80 | 1.11 |
| 85 | 24.3 | 316 | 702 | 1.40 | 229 | 161 070 | 198 070 | 0.81 | 1.13 |
| 90 | 25.7 | 334 | 742 | 1.37 | 248 | 184 000 | 221 550 | 0.83 | 1.16 |
| 95 | 27.1 | 352 | 782 | 1.34 | 267 | 208 900 | 246 300 | 0.85 | 1.18 |
| 100 | 28.6 | 370 | 822 | 1.31 | 287 | 235 800 | 272 370 | **0.87** | **1.23** |

**Lecture :** début brutal (ratio ~0.61 vers L10-20 : un Guerrier nu perd la course frontale, survit
par 1ère frappe + recul/regen 2 %/s + achat marchand km 5). La cadence SPD se compresse (2.20→1.31 s)
pendant que l'ennemi reste à 2.0 s → à L100 le Guerrier nu **gagne** ses combats de mob. Puis le mur.

---

## 3. Table C — les 6 tables à L100 (R0, sans équipement)

| Table | stat dmg | ATK | PV | cadence | crit | DPS | PV×DPS | vs ennemi 272k | Comportement |
|---|---|---|---|---|---|---|---|---|---|
| Guerrier | POW 180 | 370 phys | 822 | 1.31 s | 0.8 % | 287 | 236 k | 0.87 | référence |
| Mage | INT 125 | 259 mag | 1 000 | 1.31 s | 1.6 % | 201 | 201 k | 0.74 | −30 % DPS, +22 % PV |
| Berserker | POW 168 | 347 phys | 584 | 0.88 s | 1.3 % | 397 | 232 k | 0.85 | +38 % DPS / −29 % PV |
| Gardien | POW 141 | 291 phys | 1 119 | 1.64 s | 0.8 % | 179 | 200 k | 0.73 | −38 % DPS / +36 % PV |
| Destructeur | INT 160 | 331 mag | 624 | 1.43 s | 16.9 % | 271 | 169 k | 0.62 | glass cannon, crit scale |
| Sage | INT 137 | 283 mag | 1 060 | 1.49 s | 1.2 % | 192 | 204 k | 0.75 | tanky mage sustain |

Bande `PV×DPS` = 0.62–0.87 : aucune table n'est « la meilleure » — chacune déplace le curseur
DPS↔PV. `skillMult` de rebirth et l'équipement s'appliquent identiquement par-dessus les 6.

---

## 4. Le mur — au-delà du cap L100 (R0)

Joueur gelé à L100, ennemi continue de scaler avec le km.

| km | niv. ennemi | PV×DPS ennemi | Guerrier nu gelé (236 k) | Guerrier + kit boutique zone (~×1.8 → 425 k) |
|---|---|---|---|---|
| 28.6 | 100 | 272 k | 0.87 | 1.56 |
| 32 | 112 | 340 k | 0.69 | 1.25 |
| 35 | 123 | 409 k | 0.58 | 1.04 |
| 40 | 140 | 528 k | 0.45 | 0.80 |
| 45 | 158 | 671 k | 0.35 | 0.63 |

→ **Mur R0 : km ~28-30 sans gear, km ~35-40 avec kit boutique à jour.** Cible Q26 = km 25-35.
Leviers de resserrage (D6) : `Enemy.refPointsPerLevel` (4.2 même … 5.0 brutal), portée du marchand
ambulant. Après R1 (cap 120, `skillMult` 1.10) : mur repoussé à km ~36-42, etc. — « le Rebirth garde
toujours l'avance » (Q64).

---

## 5. Boutons de difficulté (playtest — Q119)

| Bouton | Effet | Valeur validée |
|---|---|---|
| `Enemy.refPointsPerLevel` | pente de stats de l'ennemi de réf. | **4.7** (mob de même niv. sur-cote un joueur nu de ~18 %) |
| `Enemy.enemyPowerScale` | mult. global HP/ATK ennemi | 1.00 |
| `Combat.enemyAttackInterval` | mobs frappent 10 % + vite que le joueur nu | **2.0 s** (early brutal assumé) |
| `Enemy.levelLead` | niveaux d'avance de l'ennemi de réf. | 1 |

---

## 6. Poids relatif des sources de stats à L100

| Source | Points | % |
|---|---|---|
| Auto (4/niveau) | 396 | ~85 % |
| Points libres (1/5 niveaux) | 20 | ~4 % |
| Points gagnés (joueur actif, ~jour 2-3) | 30–45 | ~8 % |
| Équipement (kit boutique à jour) | ×1.5–2.0 sur DPS et PV | dominant |

L'auto porte la courbe ; le gear est le vrai edge ; les points gagnés récompensent l'assidu
(l'AFK-farmeur n'a que l'auto → reste sous la courbe ennemie → meurt).

---

## 7. Implémentation

- `GameConfig.Level.autoPointsPerLevel = 4`, `Level.freePointEveryLevels = 5`
- `GameConfig.ClassGrowth` (6 tables) + `ClassGrowth.statsAtLevel(classKey, level)`
- `GameConfig.Enemy.refPointsPerLevel = 4.7` (découplé de `Level`)
- `GameConfig.Combat.critRate` → `min(1, LUK/2500)` ; `Combat.critRateDestroyer(luk, level)`
- `EnemyService.combatBaseForLevel` : `pts = max(0, L − levelLead) × Enemy.refPointsPerLevel`
- Câblage auto des stats (StatsService) + point libre + points gagnés : **Track G1 / G2**
- `progression-gdd.md` : Table A à intégrer — **fichier absent, à créer en Track C2**
- `combat-gdd.md` : mettre à jour `critRate = LUK/10000` → `min(1, LUK/2500)` — Track C1
