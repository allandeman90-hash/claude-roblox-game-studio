# Progression (niveau, stats auto, points gagnés, mur de niveau) — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** game-designer / systems-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Modèle chiffré (FIGÉ, ne pas recontredire) :** `design/economy/D1-stat-growth.md`,
`design/economy/D6-playthrough-balance.md`
**Code de référence :** `src/ServerScriptService/StatsService.luau`,
`src/ServerScriptService/CombatServer.server.luau` (`resolvePlayerHit`, `applyProfileToState`,
`captureProfile`, handler `allocateStat`), `src/ServerScriptService/PlayerDataService.luau` ;
`src/ReplicatedStorage/GameConfig.luau` (`.Level`, `.Player`, `.ClassGrowth`, `.Combat.levelGap`,
`.Enemy`) ; `src/ServerScriptService/EnemyService.luau` (`combatBaseForLevel`, `levelFromKm`)

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** Le niveau du héros, ses 5 stats qui **montent automatiquement**
à chaque niveau selon un tableau **classe × sous-classe**, le pool de **points de compétence
gagnés** (permanents, alloués à la main), et surtout **le mur de niveau `100 + 20 × rebirths`**
qui gèle la puissance du héros pendant que les monstres continuent de scaler. Ce GDD possède la
courbe d'XP, la montée de niveau, la dérivation des stats, les sources et l'allocation des
points gagnés, et la **pénalité d'écart de niveau** qui fait mordre le mur.

**Pourquoi il existe ?** C'est le moteur de la boucle 5 minutes (« monter de niveau sur un
kill, les stats montent seules ») et le **déclencheur de la boucle méta** : le mur EST la
raison de faire un Rebirth (`rebirth-gdd.md`). Le modèle sépare volontairement trois choses :
la **courbe** (portée par l'auto, ~85 % des points à L100), l'**edge** (le gear), et la
**récompense de l'assiduité** (les points gagnés — l'AFK-farmeur n'a que l'auto et reste sous
la courbe ennemie).

**Où dans la boucle ?**
- **30 s / 5 min :** chaque kill crédite l'XP ; un niveau gagné répartit `4` points auto + (au
  passage d'un multiple de 5) `1` point libre.
- **Session :** au feu de camp, allocation des points gagnés accumulés, respec éventuel.
- **Méta (jour 2-3) :** le 1er mur de niveau tombe vers **km 30-37**, avec un pitch de Rebirth
  bruyant à ce moment (master §5.1, D6).

---

## 2. Core Mechanics

### 2.1 XP et montée de niveau

- Courbe **A « Douce »** (validée D2) : `xpForNextLevel(n) = round(6 + 0,5 × n^1,10)`.
  `n1→2 = 7 · n10→11 = 12 · n25 = 24 · n50 = 45 · n99 = 89` ; **Σ jusqu'à L100 ≈ 4331**
  (vérifié Studio). Le `0,5` est le bouton de calage fin de D6 (`0,5 → 0,6` repousse le mur
  de +3-4 km).
- La géométrique ×1,35 du GDD maître (Q27) est **impossible** (Σ ~3e13) → la courbe A la
  remplace. Divergence assumée, cf. master Annexe C et `combat-gdd.md` §8.
- Montée traitée dans `resolvePlayerHit` sur un kill :
  ```
  playerExp += xpGain
  while playerExp >= playerExpToNext do
      playerExp     -= playerExpToNext
      playerLevel   += 1                         (bloqué à niveauMax, voir §2.5)
      autoPool      += Level.autoPointsPerLevel   (4)
      if playerLevel % Level.freePointEveryLevels == 0 then freePool += 1 end   (1 tous les 5)
      talentPoints   = floor(playerLevel / 5)     (voir talents-gdd.md)
      playerExpToNext = xpForNextLevel(playerLevel)
  end
  ```
- `xpGain = floor(enemyExp × RewardService.multiplier(player, "xp", st))` — le multiplicateur
  inclut `xpMult(rebirths) = 1 + 0,25 × rebirths` (`rebirth-gdd.md`).
- **Au cap :** l'XP au-delà du mur est **perdue** (pas stockée en négatif, pas de "banque").
  `playerExp` est clampé à `< xpForNextLevel(niveauMax)` et n'incrémente plus le niveau.

### 2.2 Stats auto — tableau classe × sous-classe (D1)

- **5 stats :** Force (POW → dégâts physiques), Magie (INT → dégâts magiques), Vie (VIT →
  `PV max = VIT × 5`), Vitesse (SPD → cadence d'attaque), Chance (LUK → taux de critique).
- **`4` points auto / niveau** (`GameConfig.Level.autoPointsPerLevel`), répartis en % par
  `GameConfig.ClassGrowth[classKey]` (6 tables, chaque ligne somme à 1.0, part SPD plafonnée
  à 0,22). Les 6 tables et leur justification sont **dans D1 §1** — ce GDD n'en re-liste pas
  les valeurs.
  - `warrior` / `mage` : tables neutres, utilisées avant le Rebirth 5.
  - `berserker` / `guardian` (Guerrier R5), `destroyer` / `sage` (Mage R5) : `subclass-gdd.md`.
- Dérivation : `ClassGrowth.statsAtLevel(classKey, level)` renvoie
  `startingStats + split × (autoPointsPerLevel × (level − 1))`. Accumulation en flottant,
  **affichage arrondi vers le bas**. `startingStats = { pow 2, int 2, vit 6, spd 1, luk 1 }` —
  une stat « morte » (INT d'un Guerrier) reste à sa valeur de départ.
- Le changement de sous-classe est **rétroactif** : on recalcule toute la courbe auto au
  niveau courant avec la nouvelle table.

### 2.3 Point libre (1 tous les 5 niveaux)

- `1` point au passage de chaque multiple de 5 (donc en même temps que le point de talent).
  À L100 : **20 points libres**.
- Alloué **1:1 à plat**, n'importe quelle stat, **SPD ≤ 200** (`spdMax`). Le point libre pour
  SPD coûte **1** (contrairement au point gagné, cf. §2.4).
- **Reset au Rebirth** (le niveau retombe à 1 → les points libres se re-gagnent en re-levelant).

### 2.4 Points de compétence gagnés (permanents)

- **Jamais donnés au niveau.** Gagnés uniquement par du jeu actif, **toujours via un
  événement serveur vérifié** (jamais un « j'ai fini X » du client) :

  | Source | Points | Anti-double-crédit |
  |---|---|---|
  | Mission complétée | +1 | par mission/jour |
  | Donjon du Jour (run validé) | +2 | par jour |
  | Nouveau monstre découvert (codex) | +1 | `earnedSourceLog["mob:<slug>"]` |
  | 1ᵉʳ kill d'un boss de couche | +3 | `earnedSourceLog["boss:<idx>"]` |
  | Atteindre une nouvelle couche | +2 | `earnedSourceLog["couche:<id>"]` |
  | Bonus de complétion des 10 missions du jour | +3 | par jour |
  | Top 100 d'un étage de Donjon du Jour | +1 | par étage/semaine |
  | 1ᵉʳ palier Cauchemar atteint sur une couche | +1 | `earnedSourceLog["nm:<couche>:<tier>"]` |

- **Allocation** à la main dans les 5 stats. Coût : **1 point** par stat, **sauf SPD = 2
  points** (`GameConfig.Combat.spdCostPerPoint` — SPD 200 ≈ 400 points investis). Cap dur
  SPD 200.
- **Permanents — pool ET allocation survivent au Rebirth.** C'est la seule progression de
  stat qui traverse le Rebirth (avec le gear). Multipliée par `skillMult(rebirths)` comme les
  points libres (§2.6).
- **Pas de plafond global** (Q30) : le Cauchemar monte en difficulté au même rythme.
- **Respec** (§2.7) : un seul pool d'allocation (libres + gagnés), remis d'un coup, coûte de
  l'or au feu de camp.

### 2.5 Le mur de niveau

- **`niveauMax = 100 + 20 × rebirths`.** Les monstres continuent de scaler :
  `niveau mob = round(km × levelPerKm)` avec `levelPerKm = 3,5` → niveau 100 vers **km ~28,6**
  (D1/D6, `EnemyService.levelFromKm`). Boss de couche : `round(km × 3,5)` (km 10 → L35,
  km 30 → L105).
- Sans pénalité d'écart, un joueur équipé dépasse le cap et continue jusqu'à ~km 95 (gear
  géométrique ×1,30/zone bat mob linéaire) — le nombre `100 + 20×rebirths` ne barrerait rien
  (D6 §2). D'où :

### 2.6 Pénalité d'écart de niveau (D6 §3 — CE QUI FAIT MORDRE LE MUR)

- Valeurs **figées** dans `GameConfig.Combat.levelGap` (commitées côté code 2026-09-01) :
  ```
  threshold  = 5       -- grâce : pas de pénalité tant que l'écart <= 5 niveaux
  dealtStep  = 0.035   -- -3,5 % de dégâts INFLIGÉS par niveau d'écart au-delà de la grâce
  dealtFloor = 0.12    -- le joueur inflige toujours >= 12 %
  takenStep  = 0.022   -- +2,2 % de dégâts SUBIS par niveau d'écart
  takenCap   = 3.0     -- dégâts subis jamais > x3
  ```
- Appliquée **dans les deux sens** par `DamageService` (multiplicateur sur le coup héros→ennemi
  et sur le coup ennemi→héros), en plus de la mitigation `combat-gdd.md` §2.4.
  ```
  gap        = max(0, mobLevel - playerLevel - threshold)
  dmgOut ×= max(dealtFloor, 1 - dealtStep × gap)
  dmgIn  ×= min(takenCap,   1 + takenStep × gap)
  ```
- Effet (Guerrier L100 équipé RARE, D6 §3 recalé à `dealtStep 0.035`) : **mur combat ressenti
  km ~30-37**, cible Q26 (25-35) tenue. Sous-équipé : km ~28-33. Équipé ÉPIQUE : km ~38-40.
- La pénalité **disparaît** dès qu'un Rebirth remonte le cap (le joueur re-level, l'écart se
  referme) → « le Rebirth garde toujours l'avance » (Q64).

### 2.7 Respec des stats

- **Un seul pool d'allocation** = points libres + points gagnés confondus. Un bouton
  « Répartir à nouveau » au feu de camp remet **toute l'allocation** au pool (le pool gagné
  n'est jamais perdu, seule la répartition change).
- Coûte de l'or, montant **fixé par l'économie** (`economy-gdd.md` / C4) — proposition de
  travail `250 × (points alloués)`, à caler `/economy-audit`. Peut aussi être payé en Robux
  (Q31) via un Developer Product (Track I).
- **Hors feu de camp : refusé.**
- Ne touche pas les talents (respec talents = gratuit, séparé, `talents-gdd.md`).

### 2.8 Mort et checkpoints (rappel — possédé par `core-gameplay-gdd.md` §2.8)

- **Checkpoint auto** à chaque marque de 10 km et à chaque feu de camp (50 km).
- **À la mort : aucune perte de progression** — niveau, XP, points (libres, gagnés, talents),
  or, objets : tout est conservé. On **re-marche** depuis le dernier feu de camp franchi, les
  monstres réapparaissent (N2). C'est la seule punition.
- La mort ≠ le Rebirth.

### State Diagram

```
[Kill] → [+XP] → playerExp >= toNext ? ──non──► [Marche]
                        │ oui
                        ▼
              [niveau++ (si < niveauMax)]
               +4 auto (split classe)  +1 libre si niveau %5==0  talentPoints=floor/5
                        │
              niveau == niveauMax ? ──oui──► [MUR : XP au-delà perdue, pénalité d'écart s'installe km+]
                        │ non                                        │
                        └──────────────► [Marche] ◄── Rebirth remonte le cap ─┘
```

---

## 3. Data Schema

### Clés DataStore (profil — `PROFILE_VERSION` bumpé à **2** ; migration `if version < 2` en `migrate()`)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `version` | number | `2` | bump porté par C2 + implémenté G1 (followup #6) |
| `niveau` | number | `1` | niveau courant, `≤ 100 + 20×rebirths` |
| `xp` | number | `0` | XP vers le niveau suivant, clampée `< xpForNextLevel(niveauMax)` au cap |
| `xpToNext` | number? | `nil` | recalculé au chargement depuis la courbe |
| `earnedPoints` | table | `{ pool = 0, alloc = { pow=0, int=0, vit=0, spd=0, luk=0 } }` | points gagnés — **permanents, survivent au Rebirth** |
| `freePoints` | table | `{ pool = 0, alloc = { pow=0, int=0, vit=0, spd=0, luk=0 } }` | 1/5 niveaux — **reset au Rebirth** |
| `earnedSourceLog` | `{[string]: true}` | `{}` | anti-double-crédit (1ᵉʳ boss, nouvelle couche, monstre codex, palier NM) |
| `subclass` | table | `{}` | `subclass-gdd.md` |
| ~~`stats`~~ | — | **supprimé du save** | les stats sont **dérivées** (niveau × table + alloc × skillMult), plus stockées (G1) |
| ~~`pointsNonAlloues`~~ | — | **remplacé par `freePoints.pool` + `earnedPoints.pool`** | le champ v1 est migré : tout va dans `earnedPoints.pool` |

### Migration v1 → v2 (`PlayerDataService.migrate`)

```
if profile.version < 2 then
    profile.earnedPoints = { pool = profile.pointsNonAlloues or 0, alloc = {pow=0,int=0,vit=0,spd=0,luk=0} }
    profile.freePoints   = { pool = 0, alloc = {pow=0,int=0,vit=0,spd=0,luk=0} }
    -- les stats v1 (profile.stats) au-delà de startingStats sont converties en allocation
    -- earned pour ne rien perdre : alloc.<stat> = max(0, profile.stats.<stat> - startingStats.<stat>)
    -- (SPD : /spdCostPerPoint). pointsNonAlloues, stats -> supprimés.
    profile.earnedSourceLog = {}
    profile.version = 2
end
```

### État runtime (`states[player]`, non persisté)

| Champ | Type | Description |
|---|---|---|
| `playerLevel` / `playerExp` / `playerExpToNext` | number | Progression courante |
| `autoStats` | `{pow,int,vit,spd,luk}` | Dérivé de `statsAtLevel(classKey, playerLevel)` |
| `earnedPool` / `earnedAlloc` | number / table | Miroir de `earnedPoints` |
| `freePool` / `freeAlloc` | number / table | Miroir de `freePoints` |
| `talentPoints` | number | `floor(playerLevel / 5)` (voir `talents-gdd.md`) |
| `statPow / statInt / statVit / statSpd / statLuk` | number | **Stat totale effective** = `autoStats + (freeAlloc + earnedAlloc) × skillMult(rebirths)` — consommée par `StatsService.recalc` |

---

## 4. Client-Server Split

### Le serveur possède
- La courbe d'XP, la montée de niveau, le clamp au `niveauMax`.
- La dérivation complète des stats (`StatsService.recalc` : auto + alloc × skillMult + gear + pets).
- Le crédit des points gagnés (chaque source est un événement serveur vérifié) et l'`earnedSourceLog`.
- L'allocation (débit du bon pool, coût SPD), le respec (débit d'or), la pénalité d'écart de niveau.

### Le client possède
- L'écran d'allocation (barres, `+`/`−`, aperçu du delta ATK/PV/cadence/crit), l'affichage
  « STAT n (+m gear) », l'alerte « mur de niveau atteint ».
- La demande d'allocation / de respec (le serveur tranche).

### Jamais sur le client
- La valeur finale d'une stat, le nombre de points, la décision « le joueur a découvert un
  nouveau monstre / battu un 1ᵉʳ boss » (source serveur uniquement).

---

## 5. RemoteEvents / Functions

`CombatEvent` (RemoteEvent unique, dispatch par `data.type`). Aucun RemoteFunction C→S.

| `data.type` | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|
| `allocateStat` | C→S | `{stat, pool}` | `stat ∈ {POW,INT,VIT,SPD,LUK}` ; `pool ∈ {"earned","free"}` (défaut `earned`) ; pool > 0 (coût SPD 2 si `earned`, 1 si `free`) ; `SPD < spdMax` | 8/s (`GameConfig.Security`) |
| `respecStats` | C→S | `{}` | `st.atCampfire` requis ; `gold ≥ coût` ; sinon `{type="respecDenied", cost}` | 2/s |
| `update` | S→C | pools, alloc, stats effectives, `niveauMax`, `wallHit` bool | n/a | ~10/s |
| `earnedPoint` | S→C | `{amount, source, total}` | n/a (toast « +N point de compétence — <source> ») | 1/source |

### Règles de validation
- `type(data) == "table"` en garde ; `stat` / `pool` type-checkés ; rejet silencieux au-delà
  du rate limit.
- `allocateStat` ignoré si le pool visé est vide, si `stat` inconnue, si SPD au cap, si le
  coût dépasse le pool.
- Aucune source de point gagné ne passe par un remote C→S : elles sont déclenchées par
  `MissionService`, `DungeonService`, `CodexService`, `ZoneService`, `CombatServer` (1ᵉʳ boss),
  `NightmareService` — toutes serveur.

---

## 6. Player-Facing UI

**Maquettes : `docs/plan/02-maquettes.md` #03 (colonne gauche combat), #06 (plein écran).
Écran d'allocation dédié = dette Track F (T-X2).**

- **Colonne gauche du combat :** `LV n · R r` · les 5 stats (valeur + `(+m)` gear en plus
  petit) · pastille « points à répartir : N » qui pulse si N > 0 · bouton **Talents**.
- **Écran d'allocation (feu de camp / plein écran) :** 5 lignes stat avec `−` / valeur / `+`,
  deux compteurs de pool (**Libres** / **Gagnés**), aperçu live du delta (ATK, PV, cadence,
  crit), bouton **Répartir à nouveau** (coût en or affiché, grisé hors feu de camp), note
  « SPD : 2 points gagnés / point · max 200 ».
- **Alerte mur :** quand `playerLevel == niveauMax`, bandeau non-bloquant « Niveau maximum
  atteint (n). Les ennemis continuent de monter — un **Rebirth** au prochain feu de camp
  relèvera le plafond. ▸ ».
- Accessibilité (Q104/Q105) : valeurs chiffrées toujours visibles (pas que des barres),
  texte redimensionnable.

---

## 7. Edge Cases & Error States

1. **Pool vide** — `+` grisé côté client, `allocateStat` ignoré serveur.
2. **SPD au cap 200** — `+` SPD grisé ; un `allocateStat SPD` est ignoré ; la part SPD de
   l'auto est déjà clampée dans `statsAtLevel`.
3. **Multi-niveau sur un seul kill** (boss, `expMult 6`) — la boucle `while` gère N niveaux ;
   chaque niveau crédite `4` auto + (si `%5`) `1` libre ; clampé au `niveauMax` (le surplus
   d'XP est perdu).
4. **Source de point déjà créditée** (re-kill d'un 1ᵉʳ boss, retour dans une couche connue) —
   `earnedSourceLog` bloque le re-crédit. Les missions/donjon sont bornés « par jour ».
5. **Respec sans or** — `{type="respecDenied", cost}` ; aucune modification.
6. **Respec hors feu de camp** — refusé (`st.atCampfire` nil).
7. **`stat` / `pool` malveillant** (`"HP"`, table, `pool="admin"`) — rejeté, aucun effet.
8. **XP gagnée au cap** — `playerLevel` ne bouge plus ; `playerExp` clampé
   `< xpForNextLevel(niveauMax)` ; pas de valeur négative, pas de « banque » d'XP.
9. **Grands nombres** — toute stat générée clampée à `statHardMax = 1e15` ; affichage en
   suffixes K/M/Md/T/… (Q112, master Annexe B #9).
10. **Rebirth pendant qu'un `allocateStat` est en vol** — le handler `rebirth` remet
    `playerLevel=1`, `freePoints` à zéro, recalcule ; un `allocateStat` traité juste après
    trouve les pools cohérents (earned conservé, free vidé). Ordre garanti par le
    mono-threading du handler `OnServerEvent`.
11. **DataStore indisponible** (Q109) — points et allocation vivent en mémoire ; bandeau
    « progression non sauvegardée » ; le respec payant et le Rebirth sont bloqués tant que
    ça ne persiste pas.
12. **Migration v1 → v2 sur un profil très avancé** — les stats v1 au-delà du départ sont
    converties en allocation `earned` (rien perdu) ; testé en K2.
13. **Sous-classe changée** (`subclass-gdd.md`) — `classKey` bascule, toute la courbe auto est
    recalculée au niveau courant ; l'allocation (libre + gagnée) est inchangée.

---

## 8. Balancing Parameters

**Toutes les valeurs de croissance viennent de `D1-stat-growth.md` et `D6-playthrough-balance.md`.
Ce GDD n'introduit aucune valeur nouvelle.** Les leviers :

| Paramètre | Source | Valeur | Rôle |
|---|---|---|---|
| `Level.autoPointsPerLevel` | D1 | `4` | points auto / niveau |
| `Level.freePointEveryLevels` | D1 | `5` | cadence du point libre |
| `Level.xpForNextLevel` coef | D2/D6 | `0,5` (dial `0,5→0,6`) | Σ→L100 ≈ 4331 ; +0,1 repousse le mur +3-4 km |
| `ClassGrowth` (6 tables) | D1 §1 | figées | identité classe/sous-classe, bande PV×DPS 0,62–0,87 |
| `Combat.spdCostPerPoint` | master §5.3 | `2` | frein sur la cadence via points **gagnés** (libre = 1) |
| `Combat.spdMax` | combat-gdd | `200` | cap dur cadence (plancher 0,5 s) |
| `Enemy.levelPerKm` | D1/D6 §0 | `3,5` | niveau mob = `round(km × 3,5)` |
| `Enemy.refPointsPerLevel` | D1 §5 | `4,7` (dial 4,2–5,0) | pente de l'ennemi de réf. (mob même niveau sur-cote un nu de ~18 %) |
| `Combat.levelGap.threshold` | D6 §3 | `5` | grâce avant pénalité d'écart |
| `Combat.levelGap.dealtStep` | **D6 §3 — validé proprio 2026-09-01** | **`0,035`** | −3,5 %/niveau d'écart sur les dégâts infligés → mur ressenti **km ~30-37** |
| `Combat.levelGap.dealtFloor` | D6 §3 | `0,12` | plancher dégâts infligés |
| `Combat.levelGap.takenStep` | D6 §3 | `0,022` | +2,2 %/niveau d'écart sur les dégâts subis |
| `Combat.levelGap.takenCap` | D6 §3 | `3,0` | cap dégâts subis |

### Formules

```
xpForNextLevel(n)   = round(6 + 0,5 × n^1,10)
niveauMax           = 100 + 20 × rebirths
autoStat(stat, L)   = startingStats[stat] + ClassGrowth[classKey][stat] × (4 × (L − 1))
                        (SPD clampé à spdMax)
statEffective(stat) = autoStat(stat, L)
                    + (freeAlloc[stat] + earnedAlloc[stat]) × skillMult(rebirths)
skillMult(n)        = 1 + 0,10n + 0,01·n·(n−1)          (rebirth-gdd.md ; R1 ×1,10 … R5 ×1,70)
mob niveau          = round(km × 3,5)
écart               = max(0, mobLevel − playerLevel − 5)
dégâts héros ×      = max(0,12 ; 1 − 0,035 × écart)
dégâts subis ×      = min(3,0 ; 1 + 0,022 × écart)
```

### Poids relatif des sources de stat à L100 (D1 §6, rappel)

| Source | ~% de la puissance de stat | Public visé |
|---|---|---|
| Auto (4/niveau) | ~85 % | tout le monde — porte la courbe |
| Points libres (20 à L100) | ~4 % | orientation légère du build |
| Points gagnés (~30-45 vers jour 2-3) | ~8 % | **l'assidu** (pas l'AFK-farmeur) |
| Équipement (kit boutique à jour) | ×1,5–2,0 sur DPS/PV | le vrai edge — le farm |

---

## 9. Integration Points

### Dépend de
- **`combat-gdd.md`** — `StatsService.recalc` consomme les stats effectives ; `DamageService`
  applique la pénalité d'écart de niveau.
- **`D1-stat-growth.md` / `D6-playthrough-balance.md`** — tables, courbe, `levelGap`, mob `×3,5`.
- **`rebirth-gdd.md`** — `skillMult(rebirths)`, `xpMult(rebirths)`, `niveauMax`, reset des
  points libres.
- **`subclass-gdd.md`** — le `classKey` qui pilote la table auto.

### Est utilisé par
- **`talents-gdd.md`** — `talentPoints = floor(niveau / 5)`.
- **`nightmare-gdd.md`** — source de points gagnés (1ᵉʳ palier/couche) ; le Cauchemar justifie
  l'absence de plafond de points (Q30).
- **`missions-gdd.md` / `daily-dungeon-gdd.md` / `codex-gdd.md`** — sources de points gagnés
  (événements serveur vérifiés).
- **`economy-gdd.md`** — coût du respec en or (à caler C4).
- **`leaderboards-gdd.md`** — niveau atteint (indirect via distance).
- **Analytics** — `wall_hit` (bloqué > N min sur le même km), niveau au churn.

### Données partagées
- `GameConfig.Level` / `.Player` / `.ClassGrowth` / `.Combat.levelGap` / `.Enemy`.
- `Types.luau` — `PlayerData` étendu (`earnedPoints`, `freePoints`, `earnedSourceLog`,
  `subclass` ; `stats` retiré).

---

## Critères d'acceptation

- [ ] Sur un kill, l'XP crédite et la montée de niveau distribue `4` auto (split classe) + `1`
      libre tous les 5 niveaux + `talentPoints = floor(niveau/5)`.
- [ ] Les stats affichées = `autoStat + (libre + gagné) × skillMult(rebirths)`, jamais les
      stats de départ multipliées.
- [ ] Le niveau est clampé à `100 + 20×rebirths` ; l'XP au-delà est perdue, pas bancarisée.
- [ ] Un point gagné pour SPD coûte 2 ; un point libre pour SPD coûte 1 ; SPD ≤ 200.
- [ ] Chaque source de point gagné crédite le bon nombre **une seule fois** (earnedSourceLog /
      borne journalière) et jamais depuis le client.
- [ ] Le respec remet toute l'allocation au pool contre de l'or, uniquement au feu de camp.
- [ ] La pénalité d'écart (`dealtStep 0,035`) fait tomber le mur combat vers km ~30-37 pour un
      Guerrier L100 équipé RARE (`/balance-check`).
- [ ] Migration v1 → v2 : aucun point ni aucune stat perdue sur un profil avancé.
- [ ] Exploits testés : `stat`/`pool` invalides, `allocateStat` pool vide, `respecStats` hors
      feu de camp / sans or, spam `allocateStat`.

---

## Questions ouvertes

- [ ] Montant exact du respec en or → `economy-designer` (C4), cible `/economy-audit`.
- [ ] La courbe A tient-elle le « 1er mur jour 2-3 » en jeu réel (facteur de re-marche ×1,4–2,3) ?
      → `/balance-check` K3.
- [ ] Valve de sécurité `skillMult` (scinder auto / earned) : à activer seulement si K3 montre
      > 15 min de contenu trivial post-rebirth (D6 §6) → `rebirth-gdd.md`.
