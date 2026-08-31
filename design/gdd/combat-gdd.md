# Combat — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-08-31
**Auteur :** game-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Code de référence :** `src/ServerScriptService/CombatServer.server.luau`, `DamageService.luau`,
`StatsService.luau`, `EnemyService.luau` ; `src/ReplicatedStorage/GameConfig.luau` ;
`src/StarterPlayer/StarterPlayerScripts/CombatClient.client.luau`

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** La résolution coup par coup d'un affrontement entre le
héros et un monstre. Le combat est **automatique** : le joueur ne tape pas pour frapper.
Le héros frappe **toujours en premier**, puis les deux échangent des coups à leur cadence
propre jusqu'à ce que l'un tombe à 0 PV. La seule couche de décision active pendant un
combat vient des 3 pouvoirs (`abilities-gdd.md`) et, contre un mob normal, de la fuite.

**Pourquoi il existe ?** C'est le cœur de la boucle 30 s (pilier 1 : « 100 % GUI, instant,
faible-input »). Le combat doit être lisible en un coup d'œil (barres de PV + dégâts
flottants + teinte de danger) et se terminer dans la fenêtre d'attention d'un joueur
mobile — un mob normal en ~3–6 s, un boss en 20–90 s.

**Où dans la boucle ?** Boucle 30 s : le combat démarre seul quand le héros atteint un
slot d'ennemi (`core-gameplay-gdd.md`), se résout, rend la main à la marche. Boucle 5 min :
un boss nommé tous les 10 km. Le combat ne s'arrête jamais quand un menu plein écran est
ouvert (Q9) — on peut mourir dans un menu.

---

## 2. Core Mechanics

### 2.1 Déroulé d'un affrontement

1. Le héros entre dans la portée d'engagement d'un slot non nettoyé (`encounterRangeKm =
   0.06`). `CombatServer.startEncounter` fige la marche (`isMoving = false`).
2. L'ennemi est instancié depuis le **descripteur mis en cache au preview**
   (`previewEncounter`) — les stats vues en marchant = les stats combattues.
3. **Le héros frappe en premier**, gratuitement : `startEncounter` remet `atkCharge = 0`
   et `enemyCharge = 0`, puis appelle immédiatement `resolvePlayerHit`. Les deux minuteurs
   ne comptent qu'**après** ce coup d'ouverture.
4. Boucle serveur, tick `MOB_TICK = 0.1 s`, trois `task.spawn` indépendants :
   - **Boucle d'attaque héros** : accumule `atkCharge += 0.1` ; à `atkCharge ≥
     st.attackInterval` → `resolvePlayerHit`, soustrait l'intervalle.
   - **Boucle d'attaque ennemi** : accumule `enemyCharge += 0.1` ; à `enemyCharge ≥
     enemyAttackInterval (2 s)` → `DamageService.enemyHitPlayer`.
   - **Boucle de mouvement** : gelée tant que `combatActive` (pas de marche en combat).
5. Chaque coup envoie un `{type="damage", target, amount, isCrit}` au client (texte
   flottant jaune, ou rouge + `!` sur un critique).
6. **Fin** : `enemyHp ≤ 0` → gain XP/or, `LootService.rollDrop` + `rollPetDrop`, montée
   de niveau (voir `progression-gdd.md`), marquage `cleared`, `ZoneService.markBossDefeated`
   si boss. `playerHp ≤ 0` → `gameOver` (voir `core-gameplay-gdd.md` §Mort).

### 2.2 Cadence d'attaque

- Base héros : `playerAttackInterval = 2.2 s` (auto-attaque uniquement — le tap de
  GAME_SPEC §2 est retiré, cf. master Annexe C).
- Base ennemi : `enemyAttackInterval = 2.0 s`, plat, non modifié par la VIT/DEF (les
  ennemis n'ont pas de stats défensives).
- La Vitesse (SPD) raccourcit l'intervalle héros (§8). Plancher dur `minAttackInterval =
  0.5 s` (2 attaques/s), atteint à SPD 200 (`spdMax`).

### 2.3 Critique

- Seule source d'aléatoire du calcul de dégâts V1.
- `critRate = LUK / 10000` (`GameConfig.Combat.critRate`), **capé à 1.0** (cf. Edge Case 2).
- Un critique multiplie les dégâts par `critMultiplier = 2`.
- S'applique **uniquement** aux dégâts héros → ennemi.

### 2.4 DEF / RES et mitigation

- **DEF et RES viennent uniquement de l'équipement** (master §5.1), jamais des stats.
- S'appliquent **uniquement** aux dégâts ennemi → héros (les ennemis n'ont ni DEF ni RES,
  donc le joueur ne subit jamais de mitigation sur ses propres coups).
- Mitigation **multiplicative**, jamais `ATK − DEF` :
  - physique : `physicalMitigation(DEF) = max(0.10, 100 / (100 + DEF))`
  - magique : `magicMitigation(RES) = max(0.10, 100 / (100 + RES))`
- `mitigationFloor = 0.10` : un joueur très blindé encaisse toujours ≥ 10 % de chaque
  coup (empêche l'invincibilité fin de partie ; empiler DEF/RES reste le contre aux boss
  tardifs → récompense le farm).
- Les mobs normaux sont physiques. Un boss peut être magique (`enemyDamageType == "magic"`)
  → c'est la RES du joueur qui compte, pas la DEF (`boss-mechanics-gdd.md`).

### 2.5 Fuite (mob normal uniquement)

- **Intent design (Q12, Q15) :** face à un **mob normal**, le joueur peut se désengager
  en tenant la direction opposée ~1 s ; le héros subit **un coup d'adieu** (1 attaque
  ennemie non mitigée en plus), le combat se ferme, le mob **conserve ses PV courants**
  jusqu'à son respawn (il repart à plein PV une fois `RESPAWN_DIST` parcouru).
- Face à un **boss** (`st.isBoss == true`), l'input de fuite est **ignoré** — le boss est
  un vrai mur (pilier 4).
- ⚠️ **Écart code :** la fuite n'est pas implémentée aujourd'hui — `startCombat` gèle la
  boucle de mouvement dès `combatActive`. À livrer en Track G (moteur de combat).
  Résolution : ajouter un état `st.fleeing` + fenêtre de 1 s, refusé si `st.isBoss`.

### 2.6 Teinte de danger (6 paliers)

Calculée **client** (`CombatClient.difficultyColour`) à partir des stats effectives du
joueur vs HP/ATK de l'ennemi — un ratio « temps pour le tuer / temps pour qu'il me tue » :

```
ttk = enemyHp / (myAtk / myInterval)
ttd = myMaxHp / max(0.1, enemyAtk / enemyAttackInterval * mitigation)
r   = ttk / ttd
palier =  r ≤ 0.12 → 1 gris (trivial)   |  r ≤ 0.30 → 2 vert (facile)
          r ≤ 0.70 → 3 jaune (moyen)    |  r ≤ 1.40 → 4 orange (dur)
          r ≤ 3.00 → 5 rouge (très dur) |  sinon    → 6 violet (extrême)
```

Purement cosmétique (aide à la décision de fuite / préparation). Accessibilité : un
mot/symbole double la couleur (Q104).

### 2.7 État visuel bas-PV

Sous `playerRatio ≤ 0.20` : vignette rouge plein écran uniforme (seul effet rouge
d'écran du jeu). Se coupe à la mort ou en remontant au-dessus de 20 %.

### State Diagram

```
[Marche] ──atteint slot──► [Coup d'ouverture héros] ──► [Échange]
   ▲                                                       │  │
   │                                              enemyHp≤0 │  │ playerHp≤0
   │◄──fuite (mob only, +1 coup d'adieu)──┐                │  ▼
   └────────────[Butin + XP + niveau]◄────┴────────────────┘ [Game Over]
```

---

## 3. Data Schema

### Clés DataStore (profil joueur — via `PlayerDataService` / `captureProfile`)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `deaths` | number | `0` | Morts cumulées, jamais remises à zéro (ni mort ni Rebirth) |
| `stats` | table | `{pow=2,int=2,vit=6,spd=1,luk=1}` | 5 stats — alimentent le calcul de dégâts/PV (détail : `progression-gdd.md`) |
| `rebirths` | number | `0` | Multiplicateur d'efficacité des points alloués (`skillMult`) |
| `niveau` | number | `1` | Alimente les stats auto (Track G) |

> Le combat ne persiste **aucun** état d'affrontement (PV courants, charge d'attaque,
> ennemi actif). Décision N5 : une déconnexion en plein boss réapparaît **avant** le boss,
> tout à plein PV.

### État runtime (non persisté — `states[player]`)

| Champ | Type | Description |
|---|---|---|
| `combatActive` | bool | Un affrontement est en cours |
| `playerHp` / `playerMaxHp` | number | PV courants / max (max = dérivé, `StatsService.recalc`) |
| `playerAtk` | number | Valeur offensive effective (phys **ou** magique selon l'arme) |
| `playerDamageType` | `"physical"｜"magic"` | Défini par la voie de l'arme équipée |
| `playerDef` / `playerRes` | number | Depuis l'armure (+ pet tank pour la DEF) |
| `playerCritRate` | number | `critRate(effLUK)` |
| `attackInterval` | number | Cadence effective après SPD + set + plancher |
| `atkCharge` / `enemyCharge` | number | Accumulateurs de cadence (reset par `startEncounter`) |
| `enemyHp` / `enemyMaxHp` / `enemyAtk` / `enemyExp` / `enemyGold` | number | Ennemi actif |
| `enemyDamageType` / `enemyAtkSplit` | string / number | Boss magique + ratio ATK/INT (panneau info) |
| `isBoss` / `enemyIsBigBoss` | bool | Verrous de fuite + multiplicateurs + mécaniques |
| `setPieces` / `setName` | number / string | Bonus de set actif (≥ 2 pièces même set + voie) |

### Schema Version
Version courante : suit `PlayerDataService` (bump coordonné avec Track B3). Le combat
n'ajoute pas de champ persisté nouveau au-delà de `deaths`.

---

## 4. Client-Server Split

### Le serveur possède
- Toute la résolution de dégâts (`DamageService`), le tirage de critique, la mitigation.
- Les PV du héros et de l'ennemi, les minuteurs de cadence, l'ordre « héros en premier ».
- La condition de victoire/défaite, les récompenses (XP, or, butin), la montée de niveau.
- Le déclenchement d'encounter et le verrou de fuite.
- Le rate-limiting de `move` (Track B2).

### Le client possède
- La capture d'input (déplacement, plus tard : reprise en main d'un pouvoir).
- Le rendu : barres de PV, sprites, dégâts flottants (pool — **aucune instance GUI par
  frame**), teinte de danger, vignette bas-PV, annonce de rareté.
- La prédiction visuelle d'interpolation des barres entre deux `update` serveur (~10/s).

### Jamais sur le client
- Les nombres de dégâts finaux (le serveur envoie le résultat).
- Les PV, l'XP, l'or, le butin.
- La décision « le combat est gagné / perdu ».

---

## 5. RemoteEvents / Functions

Un seul `RemoteEvent` : `CombatEvent` (ReplicatedStorage), bidirectionnel, dispatch par
`data.type`. **Aucun `RemoteFunction` client→serveur** (master §10).

| Nom (`data.type`) | Type | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|---|
| `move` | RemoteEvent | C→S | `{dir: "left"｜"right"｜"stop"}` | `dir` coercé : seuls `left`/`right` posent `moveDir`, tout le reste → `nil` ; refusé si `gameOver` | 10/s (Track B2) |
| `restart` | RemoteEvent | C→S | `{checkpointKm: number?}` | refusé si `not gameOver` ; `checkpointKm` clampé `[0, checkpointMaxKm]` | 1/s |
| `update` | RemoteEvent | S→C | table d'état complète (§3) | n/a | ~10/s (chaque tick significatif) |
| `damage` | RemoteEvent | S→C | `{target: "player"｜"enemy", amount: number, isCrit: bool}` | n/a | par coup |
| `gameOver` | RemoteEvent | S→C | `{distance, productId, revivePrice}` | n/a | 1/mort |

### Règles de validation (serveur)
- `if type(data) ~= "table" then return end` en tête de handler (Track B2).
- Type-check chaque argument, range-check chaque nombre.
- Sanity-check : `move` ignoré si `states[player]` absent ou `gameOver` ; `restart`
  seulement si `gameOver`.
- Fenêtre glissante 1 s par joueur, rejet silencieux au-delà, log si dépassement soutenu.

---

## 6. Player-Facing UI

**Maquette de référence : `docs/plan/02-maquettes.md` #03 (combat), #04 (boss), #13 (mort).**

### Éléments
- **Barre du haut :** zone HUD Roblox réservée à gauche (☰ + chat) ; `💀 morts · Couche N ·
  km` centré ; nom + niveau ennemi à droite. Barre de PV joueur qui **démarre après le
  retrait** (`GuiService.TopbarInset`) ; barre de PV ennemi dessous.
- **Colonne gauche :** `LV · R · arme · set X/4 · pets` / `ATK / DEF / RES / CRIT` /
  bouton Talents.
- **Scène centrale :** héros + 3 pets (Tank devant, DPS/Heal derrière), ennemi à droite,
  dégâts flottants (jaune `-247`, rouge `-891!` critique) ancrés sur l'ennemi actif,
  ligne `→ prochain objectif`. Bascule `◀ AVANT / arrière ▶`.
- **Barre de 3 compétences** centrée en bas (`abilities-gdd.md`).
- **Colonne droite :** PV ennemi, or, répartition ATK/INT, type de dégâts, bouton Menu.
- **Teinte de danger** sur le nom de l'ennemi (6 couleurs + mot/symbole).
- **Vignette rouge** plein écran sous 20 % PV.

### Wireframe
```
┌──────────────────────────────────────────────────────────┐
│ [☰ 💬]      💀3 · Couche 4 · 42.4 km        Loup Sauvage N9│
│         PV héros ██████░░░░        PV ennemi ███░░░░       │
│ LV10 R2                                                   │
│ Épée courte      héros  🐾🐾🐾        👹 ennemi   -247     │
│ ATK 245 DEF 120                      → Boss · 0.4 km      │
│ [TALENTS]           ◀ AVANT / arrière ▶                   │
│              [Exécution ▶][Rempart 4s][Cri ▮▮▯]           │
│ Couche 4 — Champs de Cendres · Étape 4/10 · prochain BOSS▸│
└──────────────────────────────────────────────────────────┘
```

---

## 7. Edge Cases & Error States

1. **Coup qui tuerait le héros dès le tour 1 (mob normal)** — pas de protection « premier
   tour gratuit » côté défense ; le plancher de mitigation 0.10 s'applique quand même. La
   teinte violette est l'avertissement. Contre un BIG boss, `bigBossAtkDamp = 0.6` + un
   `bigAtkMult` bas rendent le premier coup non létal (guerre d'usure voulue).
2. **`critRate > 1.0`** (LUK très haut) — la chance de critique est **capée à 1.0** ; le
   `critMultiplier` reste ×2 (pas de crit en cascade). *Écart code : `DamageService` ne
   cape pas explicitement — `math.random() < critRate` donne 100 % de fait ; ajouter
   `math.min(1, critRate)` pour la lisibilité et un futur affichage UI.*
3. **SPD à `spdMax` (200)** — `attackInterval` plancher `minAttackInterval = 0.5 s`. Le
   bonus de vitesse d'un set 4 pièces se multiplie par-dessus **puis** est re-planché : on
   ne descend jamais sous 0.5 s.
4. **Déconnexion en plein combat** — aucun état de combat persisté. À la reconnexion,
   `startCombat` → `restartRun(selectedCheckpoint)` : héros plein PV, ennemi frais. Si
   c'était un boss : réapparition **juste avant** le boss, tout à plein PV (N5). La mort
   n'est **pas** comptée… *sauf* si `playerHp` avait atteint 0 avant la déco (`gameOver`
   déjà sauvegardé). ⚠️ **Écart vs master Annexe B #7** : le master veut « quitter à PV
   bas en combat → mort comptée à la sauvegarde ». À implémenter : `PlayerRemoving`
   compte une mort si `combatActive and playerHp/playerMaxHp < seuilFuite` (`[À CALER]`,
   proposé 15 %). Résolution attendue en Track G8/K4 (voir Questions ouvertes + risk-register).
5. **`playerHp` et `enemyHp` atteignent 0 au même tick** — les deux boucles d'attaque sont
   des `task.spawn` séparés sur le même tick 0.1 s ; l'ordre d'exécution départage. **Règle
   de design (pilier « le héros frappe en premier ») :** la résolution du coup héros doit
   précéder celle du coup ennemi à chaque tick. ⚠️ **Écart code :** boucles indépendantes
   aujourd'hui → à unifier en une seule passe ordonnée (Track G, voir risk-register).
6. **Overkill sur un critique** — `enemyHp` clampé à 0, le bloc « on-kill » est gardé par
   `if st.enemyHp > 0 then … return end` puis `st.enemyHp = 0`, exécuté une seule fois.
7. **Spam de `move`** — au-delà de 10/s : rejet silencieux (Track B2). Le Heartbeat serveur
   ne doit pas se dégrader sous un test de spam.
8. **`dir` invalide / malveillant** (`{dir = {}}`, `dir = "up"`, nombre) — coercé : seul
   `"left"`/`"right"` pose `moveDir`, tout le reste → `nil` (arrêt). Déjà géré.
9. **0 familier équipé** — le combat fonctionne, sans les bonus DPS/Tank/Heal (Q111).
10. **Ennemi de zone non développée** (roster `ZoneConfig` vide) — `EnemyService.rollEnemy`
    retombe sur `combatBaseForLevel` brut, nom « Zone N - Inconnu », pas de sprite. Le
    combat ne casse jamais.
11. **Cauchemar palier k** — stats ennemi `× 3^k` (`nightmare-gdd.md`, `[À CALER — D2]`),
    la longueur du combat scale d'autant ; minuteur d'enrage actif sur les boss.
12. **Fuite tentée contre un boss** — input ignoré tant que `st.isBoss` (§2.5).
13. **DataStore indisponible** — le combat tourne normalement (bandeau « progression non
    sauvegardée ») ; les morts s'accumulent en mémoire, non persistées jusqu'au retour du
    DataStore (Q109).

---

## 8. Balancing Parameters

Toutes les valeurs vivent dans `src/ReplicatedStorage/GameConfig.luau`
(`.Combat`, `.Player`). Aucun magic number dans la logique de combat.

### Formules (alignées master-gdd Annexe A)

**PV max**
```
playerMaxHp = (effVIT × hpPerVit)
            × (1 + armorPieces × hpPctPerPiece)
            × (1 + setHpPct)
            × (1 + petHpPct)
  hpPerVit = 5 · hpPctPerPiece = 0.10 (par pièce d'armure, non scalé par zone)
```

**Valeur offensive effective**
```
basePhys = baseAtk      + effPOW × atkPerPow          (baseAtk = 10, atkPerPow = 2)
baseMag  = baseMagicAtk + effINT × magicPerInt        (baseMagicAtk = 10, magicPerInt = 2)
playerAtk = (arme "mage" ? baseMag : basePhys)
          × (1 + weaponPct)                            (multiplicateur de l'arme équipée)
          × (1 + setDamagePct)                         (set ≥ 2 pièces même voie)
          × (1 + petDpsPct)
```

**Stat effective (efficacité Rebirth)**
```
effStat = start + max(0, alloué − start) × skillMult(rebirths)
skillMult(n) = 1 + skillEffectPerRebirth × n           (skillEffectPerRebirth = 0.10, additif)
  → les stats de départ ne sont jamais multipliées, seulement les points investis
```

**Cadence d'attaque héros**
```
attackInterval = playerAttackInterval / (1 + max(0, effSPD − startSPD) × spdCadenceCoef)
attackInterval = attackInterval / (1 + setSpeedPct)
attackInterval = max(minAttackInterval, attackInterval)
  playerAttackInterval = 2.2 · spdCadenceCoef = 0.0171 · minAttackInterval = 0.5 · spdMax = 200
  SPD 1 → 2.20 s | 25 → 1.54 | 50 → 1.20 | 100 → 0.82 | 150 → 0.63 | 200 → 0.50
```

**Dégâts d'un coup**
```
héros → ennemi : dmg = floor( playerAtk × (isCrit ? critMultiplier : 1) )
  isCrit = (random() < min(1, critRate)) ; critRate = LUK / 10000 ; critMultiplier = 2
  PAS de mitigation (les ennemis n'ont ni DEF ni RES)

ennemi → héros : dmg = max(0, floor( enemyAtk × mitigation ))
  mitigation = enemyDamageType=="magic" ? magicMitigation(RES) : physicalMitigation(DEF)
  physicalMitigation(DEF) = max(0.10, 100 / (100 + DEF))
  magicMitigation(RES)    = max(0.10, 100 / (100 + RES))
```

**Regen hors combat** (géré par `core-gameplay-gdd.md`, rappel)
```
regen/s = outOfCombatRegenPct × playerMaxHp                (0.02)
  + au feu de camp à l'arrêt : + 0.01 + petHealPct
```

**Stats ennemi** (rappel — détail `EnemyService`, `progression-gdd.md`, roster Track D3)
```
combatBaseForLevel(L) : PV/ATK calés sur un joueur-référence (L − levelLead) niveaux
  sous le mob (levelLead = 1), refVitShare 0.50 → VIT, refPowShare 0.42 → POW,
  × enemyPowerScale (1.0) → un combat à niveau égal est ~équilibré.
Boss nommé : × (hpMult 2.5, atkMult 1.3, expMult 6.0, goldMult 5.0)
Big boss (100 km) : × (bigHpMult 14, bigAtkMult 2.5 × bigBossAtkDamp 0.6, bigExp 40, bigGold 30)
```

### Valeurs ajustables

| Paramètre | Min | Max | Défaut | Notes |
|---|---|---|---|---|
| `playerAttackInterval` | 1.5 | 3.0 | `2.2` | cadence de base héros |
| `enemyAttackInterval` | 1.5 | 3.0 | `2.0` | cadence ennemi, plat |
| `spdCadenceCoef` | 0.010 | 0.025 | `0.0171` | gain de cadence par point de SPD |
| `minAttackInterval` | 0.4 | 0.8 | `0.5` | plancher dur (2 atk/s) |
| `spdMax` | 100 | 300 | `200` | cap dur de SPD |
| `critMultiplier` | 1.5 | 3.0 | `2` | GAME_SPEC §3.1 |
| `mitigationFloor` | 0.05 | 0.20 | `0.10` | part minimale des dégâts qui passe toujours |
| `atkPerPow` / `magicPerInt` | 1 | 4 | `2` | ATK par point de stat de dégâts |
| `hpPerVit` | 3 | 8 | `5` | PV par point de VIT |
| Seuil de mort comptée à la déco | 0.05 | 0.25 | `[À CALER — Track D/K]` (~0.15) | Edge Case 4 |
| Fenêtre de fuite | 0.5 | 2.0 | `[À CALER — Track G]` (~1.0 s) | §2.5 |

> **Divergences vs master Annexe A**
> - « Issue d'un combat = on gagne ssi (PV_héros × DPS_héros) > (PV_ennemi × DPS_ennemi) »
>   est une **abstraction de tuning** (utilisée pour la teinte de danger et la décision de
>   fuite). Le combat réel est résolu **coup par coup en direct** (Q13) — le joueur peut
>   changer l'issue avec ses pouvoirs. Aucune contradiction : l'abstraction sert au
>   `/balance-check`, pas au moteur.
> - Courbe d'XP : le code utilise `2N(N+1)+40` ; le master vise géométrique ×1.35. Non
>   traité ici (progression) — résolution en Track D2.

---

## 9. Integration Points

### Dépend de
- **`progression-gdd.md`** — fournit niveau + 5 stats (POW/INT/VIT/SPD/LUK) et le nombre
  de rebirths qui pilotent `StatsService.recalc`.
- **`equipment-gdd.md` (= GAME_SPEC §4-5)** — `EquipmentService.getStatBonuses` :
  `weaponPct`, `damageType` (voie de l'arme), `armorDef`, `armorRes`, `armorPieces`,
  bonus de set (`setDamagePct`, `setHpPct`, `setSpeedPct`).
- **`pets-gdd.md`** — `getPetEffect` : `dpsPct`, `hpPct`, `defFlat`, `healPct`.
- **`abilities-gdd.md`** — les 3 pouvoirs modifient l'issue (dégâts burst, bouclier, soin,
  interruption de boss). Cooldowns gérés là-bas.
- **`boss-mechanics-gdd.md`** — phases, grosse attaque à interrompre, adds, enrage
  (Cauchemar), `enemyDamageType`/`atkSplit` des boss magiques.
- **`core-gameplay-gdd.md`** — déclenche `startEncounter`, gère la marche/le respawn/la
  mort/le redémarrage, la regen hors combat.
- **`nightmare-gdd.md`** — multiplicateur `× 3^k` sur les stats ennemi, avance auto du
  héros, activation de l'enrage.

### Est utilisé par
- **`progression-gdd.md`** — écoute XP gagnée / niveau atteint sur un kill.
- **`economy-gdd.md`** — l'or du kill.
- **`inventory-gdd.md` / Loot** — `LootService.rollDrop` + `rollPetDrop` sur un kill.
- **`codex-gdd.md`** — un kill incrémente le compteur de la carte du monstre.
- **`missions-gdd.md`** — objectifs « tuer N monstres / N boss ».
- **`leaderboards-gdd.md`** — indirectement (distance atteinte, palier Cauchemar).
- **Analytics** (master §8) — lieux de mort, usage pouvoirs/familiers, `wall_hit`.

### Données partagées
- `GameConfig.Combat` / `GameConfig.Player` — toutes les formules ci-dessus.
- `Types.luau` — `PlayerData` (à étendre : `deaths`, `stats`, `rebirths`).

---

## Critères d'acceptation

- [ ] Le héros porte toujours le premier coup ; les minuteurs démarrent après.
- [ ] Cadence héros conforme à la table SPD (1 → 2.20 s … 200 → 0.50 s).
- [ ] Le taux de critique mesuré sur 1000 coups ≈ `LUK/10000` (capé 100 %).
- [ ] Mitigation multiplicative, plancher 0.10 respecté même à DEF/RES très haute.
- [ ] Aucun calcul de dégâts final côté client ; aucun crédit XP/or/butin client.
- [ ] Fuite : possible sur un mob normal (1 coup d'adieu), refusée sur un boss.
- [ ] Rate limit `move` : un spam ne dégrade pas le Heartbeat serveur.
- [ ] Exploits testés : `critRate` négatif, `enemyAtk` négatif, `dir` non-string, `move`
      pendant `gameOver`, `restart` sans `gameOver`.
- [ ] Déconnexion en plein boss → réapparition avant le boss, tout plein PV (N5).
- [ ] Combat fonctionnel avec 8 joueurs sur une instance (test perf).

---

## Questions ouvertes

- [ ] Seuil exact de « mort comptée si on quitte à PV bas en combat » (Edge Case 4) →
      lead-programmer (Track B/G) + risk-register.
- [ ] Durée de la fenêtre de fuite et coût (coup d'adieu simple, ou % PV) → Track G,
      systems-designer.
- [ ] Faut-il unifier les 3 boucles `task.spawn` en une passe ordonnée unique ? (résout
      Edge Case 5, simplifie l'enrage) → lead-programmer, Track G + risk-register.
- [ ] Les pouvoirs peuvent-ils faire des dégâts magiques avec une arme physique ? →
      `abilities-gdd.md`.
