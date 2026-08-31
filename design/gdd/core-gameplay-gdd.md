# Cœur de jeu (marche + rencontres + butin) — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-08-31
**Auteur :** game-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Code de référence :** `src/ServerScriptService/CombatServer.server.luau` (boucles de
mouvement / rencontre / persistance), `EnemyService.luau` (slots), `ZoneService.luau`,
`LootService.luau` ; `src/ReplicatedStorage/GameConfig.luau` (`.World`, `.Progression`,
`.Enemy`) ; `src/StarterPlayer/StarterPlayerScripts/CombatClient.client.luau`

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** La boucle de 30 secondes : le joueur **tient ◀ / ▶** pour
faire marcher le héros le long de « La Descente », atteint un slot de rencontre, le combat
se déclenche seul (`combat-gdd.md`), le monstre meurt, **un butin est tiré et sa rareté
annoncée fort**, puis le héros repart. Ce GDD possède la **traversée du monde**, le
**déclenchement des rencontres**, le **moment de récompense** (XP / or / butin / niveau),
la **proximité des feux de camp**, et le **flux mort → écran de mort → redémarrage**.

**Pourquoi il existe ?** C'est le pilier 1 (« 100 % GUI, instant, faible-input, paysage »)
et le pilier 3 (« le drop est la dopamine »). Un joueur mobile doit obtenir une
gratification — un kill, un drop, un niveau — dans les premières secondes de chaque
session, sans plus d'input que tenir un bouton.

**Où dans la boucle ?**
- **30 s :** marcher → rencontre → combat → butin annoncé → marcher.
- **5 min :** traverser une étape de 1 km (~2 mobs) → monter de niveau → tous les 10 km,
  boss nommé → couche suivante (carte plein écran 5 s).
- **Session :** reprendre au dernier feu de camp, avancer, tuer un ou deux boss, se poser
  au feu de camp tous les 50 km.

---

## 2. Core Mechanics

### 2.1 Déplacement (entrée maintenue)

- Le héros a une **position en km** (`st.pos`) et marche gauche / droite selon l'entrée
  **maintenue** (`moveDir ∈ "left" | "right" | nil`). Toutes les entrées coexistent
  (Q14) : clavier **A/D + flèches**, tactile **2 boutons ◀ ▶**, **stick** de manette.
- Vitesse : `moveSpeedKmPerSec = 0.11` (≈ 9 s pour parcourir 1 km) — il y a un vrai espace
  entre les mobs.
- **Auto-marche gratuite à ½ vitesse (Q3)** : quand aucune entrée n'est tenue, le héros
  avance tout seul vers l'objectif à `0.5 × moveSpeedKmPerSec`. Le Pass Vitesse remplace
  ça par une auto-marche pleine vitesse + sélecteur ×1/×2/×3 (voir `season-pass` / `monetization.md`).
  ⚠️ **Écart code :** l'auto-marche ½ vitesse n'est pas implémentée (`walking = moveDir ~=
  nil`). À livrer en Track G. Constante `autoWalkMult = 0.5` `[À CALER — confirmer 0.5]`.
- En **mode Cauchemar**, le héros avance tout seul à **pleine** vitesse (Q43,
  `nightmare-gdd.md`).
- `GameConfig.World.speedMult(pos, fastMode, bigBossesBeaten)` : ×1 par défaut, ×1.5 au-delà
  de `fastZoneKm = 100`, ×2 en `fastMode` (débloqué à `fastModeUnlockBigBosses = 4` big boss).
  Le Pass Vitesse plafonne à ×3, le Donjon du Jour force ×1 (Q46).

### 2.2 Modèle de traversée (slots fixes)

- Chaque couche = `kmPerZone = 10 km`, découpée en `stepsPerZone = 10` **étapes** de 1 km.
- Chaque étape a `mobsPerStep = 2` slots de rencontre à des fractions fixes
  (`stepFractions = {0.5, 0.95}`). Le **2ᵉ slot de la 10ᵉ étape = le boss de couche**
  (à `km = couche × 10`).
- Positions **déterministes** (`EnemyService.encountersForZone`) → quand le joueur revient
  farmer, les slots sont au même endroit.
- **Portée d'engagement** `encounterRangeKm = 0.06` : le héros doit être quasiment ON the
  mob (pas de dash de loin).
- **Respawn :** un slot nettoyé (`st.cleared[pos] = true`) réapparaît une fois le héros à
  plus de `RESPAWN_DIST = 0.9 km` du kill (distance, pas plancher — un boss pile sur une
  frontière de couche ne se dé-nettoie pas au moment où on l'engage).
- Un slot de mob normal n'est engageable que s'il appartient à **l'étape courante**
  (`stepForKm`) ; un slot boss est engageable depuis la frontière partagée.

### 2.3 Preview de rencontre

Avant le combat, `previewEncounter` tire **et met en cache** le descripteur complet de
l'ennemi du slot (nom, niveau, PV, ATK, sprite, type de dégâts). Ce cache sert :
1. au label lu en marchant, 2. à la teinte de danger, 3. au combat réel — les trois
utilisent des stats **identiques**.

### 2.4 Feux de camp (proximité)

- Marque tous les `campfireEveryKm = 50`. Le **km 0 = le Château** (N3).
- Le hub est accessible dans `campfireRangeKm = 1.2` d'une marque de 50 km.
- Entrer dans la zone : `st.atCampfire = mark`, `ShopService.openShop`, sauvegarde du
  profil, `milestone = "campfire"`. En sortir : `ShopService.closeShop`.
- Regen renforcée au feu de camp à l'arrêt (voir §2.7).
- Contenu du hub : `campfire-gdd.md`.

### 2.5 Décor de couche

`ZoneService.updateDistance(player, pos)` renvoie l'ID de couche courant ; le client
charge le fond `bg_zone1..12` (fond fixe, la scène est la colonne centrale). Carte de
transition plein écran entre deux couches (nom + phrase d'ambiance, **5 s max, passe
automatiquement**, Q100) — contenu : `narrative-gdd.md` + `design/narrative/layer-cards.md`.

### 2.6 Moment de récompense (sur un kill)

Traité par `combat-gdd.md` §2.1 étape 6, mais **possédé ici** pour la mise en scène :
1. `xpGain = floor(enemyExp × rebirthXpMult)`, `goldGain = enemyGold` → crédités.
2. `LootService.rollDrop` (équipement) + `rollPetDrop` (familier) → `EquipmentService.addItem`.
3. Événement `{type="loot", item, fromBoss, kept, reason}` → le client affiche un **texte
   flottant coloré par rareté + son** (pilier 3 : un Mythique est un événement).
4. Montée de niveau : `while playerExp ≥ playerExpToNext do niveau++ ; statPoints +=
   statPointsPerLevel (5) end` — les stats montent seules (`progression-gdd.md`).
5. Si sac plein au drop d'un boss → fenêtre « garder (vends un objet) ou jeter le neuf ? »
   (`inventory-gdd.md`, master Annexe B #1).

### 2.7 Regen hors combat

```
si playerHp < playerMaxHp et pas en combat :
  pct = outOfCombatRegenPct (0.02)
  si atCampfire et moveDir == nil : pct += 0.01 + campfireRegenBonusPct (pet heal)
  playerHp = min(playerMaxHp, playerHp + playerMaxHp × pct × MOB_TICK)
```

Reculer pour se soigner puis re-engager est **la compétence de base** d'un auto-battler
(un joueur prudent récupère, un gourmand meurt).

### 2.8 Checkpoints et mort

- **Checkpoint auto** à chaque marque de 10 km franchie (`checkpointMaxKm`), et à chaque
  feu de camp (50 km) — N1. `bestKm` = record absolu (jamais reset).
- **À la mort** (`playerHp ≤ 0`) : `gameOver = true`, `deaths++`, sauvegarde, événement
  `{type="gameOver", distance}`. On garde **TOUT** (niveau, or, XP, objets).
- **Écran de mort** (maquette #13) : « TU ES TOMBÉ », distance + record, « XP conservée »,
  fermable quand on veut (Q97). Deux boutons **de même taille** (Q98) : « Recommencer »
  (au checkpoint sélectionné) et « Réapparaître ici » (pas de revive payante au
  lancement — le bouton n'apparaît que si le joueur possède une potion de revive gagnée).
- **Redémarrage** (`restart`) : `restartRun(checkpointKm)` remet la distance au checkpoint
  choisi (`≤ checkpointMaxKm`, défaut = dernier), **les monstres réapparaissent** (N2 —
  worst case ≈ 50 km à retraverser, c'est la punition).
- La mort ≠ le Rebirth (`rebirth-gdd.md`).

### State Diagram

```
[Marche] ──atteint slot non nettoyé──► [Combat] ──kill──► [Butin + XP + niveau] ──► [Marche]
   │                                      │
   │ franchit 10/50 km → checkpoint       │ playerHp ≤ 0
   │ franchit frontière couche → carte 5s ▼
   │ entre dans ±1.2 km d'un x50 → [Feu de camp]      [Game Over] ──restart──► [Marche @ checkpoint]
```

---

## 3. Data Schema

### Clés DataStore (profil — `captureProfile` / `applyProfileToState`)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `distance` | number | `0` | Position km au dernier save (informatif) |
| `bestKm` | number | `0` | Record absolu de distance (classements, J6/J7, checkpoint post-rebirth) |
| `checkpointMax` | number | `0` | Plus haute marque de 10 km atteinte (arrondi ×10) |
| `selectedCheckpoint` | number | `0` | Point de départ choisi pour le prochain run (`≤ checkpointMax`) |
| `deaths` | number | `0` | Morts cumulées |
| `niveau` / `xp` | number | `1` / `0` | Progression (détail `progression-gdd.md`) |
| `or_` | number | `0` | Or (détail `economy-gdd.md`) |
| `bigBossesBeaten` | number | `0` | Débloque `fastMode` à 4 |
| `fastMode` | bool | `false` | Bascule ×2 (si débloquée) |

### État runtime (`states[player]`, non persisté)

| Champ | Type | Description |
|---|---|---|
| `pos` | number | Position km courante |
| `moveDir` | `"left"｜"right"｜nil` | Entrée maintenue |
| `zone` | number | Couche courante (`ZoneService`) |
| `isMoving` | bool | Marche visible (faux au feu de camp) |
| `cleared` | `{[posKm]: true}` | Slots tués cette visite (respawn à `RESPAWN_DIST`) |
| `encPreview` | `{[posKm]: descripteur}` | Cache de preview stable |
| `currentEncounterPos` | number? | Slot en cours de combat |
| `atCampfire` | number? | Km du feu de camp où l'on se repose, ou nil |
| `milestone` | `"campfire"｜"boss"｜nil` | Pour le HUD |
| `gameOver` | bool | Mort en cours |

### Schema Version
Suit `PlayerDataService` (bump coordonné Track B3). Champ nouveau potentiel : néant (tout
existe déjà).

---

## 4. Client-Server Split

### Le serveur possède
- L'intégration de la position (`pos += MOVE_SPEED × mult × tick × dir`), autoritaire.
- Le déclenchement des rencontres, le respawn, le high-water mark des checkpoints, `bestKm`.
- La proximité feu de camp, l'ouverture/fermeture de boutique, les sauvegardes.
- Tous les crédits (XP, or, butin, points de stat).
- Le rate-limiting de `move` (Track B2).

### Le client possède
- La capture d'entrée (maintien ◀ ▶ / A D / stick) → `move`.
- Le rendu du défilement (`progress = pos × 10` unités de scroll), la piste de couche, la
  ligne « → prochain objectif », le décor, la carte de transition.
- Le pool de textes flottants (dégâts, butin, rareté) — **aucune instance GUI créée par
  frame**.
- L'écran de mort (affichage), la vignette bas-PV.

### Jamais sur le client
- La position autoritaire, la distance record, les checkpoints.
- Le butin, l'XP, l'or, les points de stat.
- La décision « le joueur est au feu de camp » (donc peut rebirth).

---

## 5. RemoteEvents / Functions

`CombatEvent` (RemoteEvent unique, dispatch par `data.type`). Aucun RemoteFunction C→S.

| `data.type` | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|
| `move` | C→S | `{dir}` | `dir` ∈ `left/right/stop` (coercé, autre → stop) ; ignoré si `gameOver` | 10/s |
| `restart` | C→S | `{checkpointKm?}` | seulement si `gameOver` ; clampé `[0, checkpointMax]` | 1/s |
| `setCheckpoint` | C→S | `{km}` | `km` arrondi ×10, `0 ≤ km ≤ checkpointMax` | 4/s |
| `setFastMode` | C→S | `{on: bool}` | ignoré si `bigBossesBeaten < 4` | 2/s |
| `update` | S→C | table d'état (§3 + combat) | n/a | ~10/s |
| `loot` | S→C | `{item, fromBoss, kept, reason}` | n/a | 1/drop |
| `gameOver` | S→C | `{distance, productId, revivePrice}` | n/a | 1/mort |

### Règles de validation
- `type(data) == "table"` en garde. Type/range/sanity par argument.
- `setCheckpoint` au-delà de `checkpointMax` → **clampé**, pas rejeté (master Annexe B #6).
- Rejet silencieux au-delà du rate limit (Track B2).

---

## 6. Player-Facing UI

**Maquettes : `docs/plan/02-maquettes.md` #03 (combat/traversée), #13 (mort), #14 (les 12 couches).**

- **Piste de couche** pleine largeur en bas : `Couche N — <Nom> · Étape k/10 · prochain :
  <MOB|BOSS|FEU DE CAMP> ▸` + barre de progression (10 ticks, séparateur étape 9-10 net —
  bug B6c).
- **Ligne « → prochain objectif »** dans la scène (boss / feu de camp / nouvelle couche +
  distance restante).
- **Bascule ◀ AVANT / arrière ▶** (posture — `combat-gdd.md`).
- **Annonce de rareté** au drop : texte flottant coloré (gris/bleu/violet/orange/rouge) +
  mot (accessibilité Q104) + son.
- **Carte de transition de couche** : plein écran, nom + 1 phrase, 5 s, auto.
- **Écran de mort** : bloc centré rouge, 2 boutons de taille égale.
- **HeroTimeBox** (xp/min, or/min) : à agrandir (bug B6b).

---

## 7. Edge Cases & Error States

1. **Farm AFK d'un mob sur place** — le respawn exige de s'éloigner de `RESPAWN_DIST =
   0.9 km` ; kill-rate plafonné serveur (Track B) ; les points de compétence **ne se
   farment pas** ainsi (missions à variété, codex, donjon — `progression-gdd.md`). Master
   Annexe B #12.
2. **Marcher devant un feu de camp sans s'arrêter** — `atCampfire` est posé/retiré par
   proximité ; si le joueur traverse sans `moveDir == nil`, la regen renforcée ne
   s'applique pas mais le checkpoint 50 km est quand même enregistré.
3. **Déconnexion en pleine marche** — `pos` non persisté ; à la reconnexion, `restartRun`
   au `selectedCheckpoint`. Le joueur perd la distance non-checkpointée depuis la dernière
   marque de 10 km (perte max ~10 km — acceptable, N2 assume déjà la retraversée).
4. **`pos` exactement sur une frontière de couche** (`km = couche × 10`) — le boss du slot
   est crédité à la couche qu'il **ferme** ; le respawn distance-based évite qu'il se
   dé-nettoie à l'engagement (piège « boss qui respawn en boucle »).
5. **`setCheckpoint` au-delà de la moitié du record après Rebirth** — clampé à
   `bestKm / 2` par `rebirth-gdd.md` (Q36) ; ici, clampé à `checkpointMax` (les deux
   contraintes s'appliquent, la plus stricte gagne).
6. **Spam de `move` / `setCheckpoint`** — rejet silencieux au-delà du rate limit ; le
   Heartbeat ne se dégrade pas.
7. **`dir` malveillant** (table, nombre, `"up"`) — coercé en `stop`.
8. **DataStore indisponible** — jeu jouable, gros bandeau « progression non sauvegardée » ;
   les checkpoints/distance vivent en mémoire ; achats et Rebirth bloqués (Q109, master
   Annexe B #4).
9. **Mort avec 0 checkpoint** — `restart` repart au km 0 (le Château).
10. **Carte de transition manquée** (couche sans phrase dans `design/narrative/`) —
    fallback : afficher juste « Couche N — <Nom> » 5 s.
11. **Grands nombres > 2^53** (distance en Cauchemar profond, or) — capés
    (`statHardMax = 1e15`), affichage en suffixes K/M/Md/T/… (Q112).

---

## 8. Balancing Parameters

Valeurs dans `GameConfig.World`, `GameConfig.Progression`, `GameConfig.Enemy`.

### Formules

**Déplacement**
```
pos += moveSpeedKmPerSec × speedMult(pos, fastMode, bigBossesBeaten) × dir × MOB_TICK
  moveSpeedKmPerSec = 0.11 · MOB_TICK = 0.1 s
auto-marche (aucune entrée) : × autoWalkMult   [À CALER — 0.5 proposé]
speedMult : 1.0 → 1.5 (pos ≥ fastZoneKm 100) → 2.0 (fastMode & bigBossesBeaten ≥ 4)
  Pass Vitesse : plafond ×3 · Donjon du Jour : forcé ×1
```

**Structure de couche**
```
kmPerZone = 10 · stepsPerZone = 10 · mobsPerStep = 2 · stepFractions = {0.5, 0.95}
slot boss = étape 10, slot 2, à km = couche × 10
encounterRangeKm = 0.06 · RESPAWN_DIST = 0.9 km
campfireEveryKm = 50 · campfireRangeKm = 1.2 · checkpoint auto tous les 10 km
```

**Récompense sur un kill** (détail `progression-gdd.md`, `economy-gdd.md`, roster Track D3)
```
xpGain   = floor( enemyExp × (1 + xpBonusPerRebirth × rebirths) )   xpBonusPerRebirth = 0.25
goldGain = enemyGold
enemyExp  = base.exp (10)  × expPerLevel (1.02) ^ min(level-1, scaleExpCap 90)
enemyGold = base.gold (5)  × goldPerLevel (1.03) ^ min(level-1, scaleExpCap 90)
statPoints += statPointsPerLevel (5) par niveau gagné
```

**Regen hors combat**
```
pct/s = outOfCombatRegenPct (0.02)  [+ 0.01 + petHealPct  si atCampfire & arrêté]
playerHp += playerMaxHp × pct × MOB_TICK   (clampé à playerMaxHp)
```

### Valeurs ajustables

| Paramètre | Min | Max | Défaut | Notes |
|---|---|---|---|---|
| `moveSpeedKmPerSec` | 0.05 | 0.20 | `0.11` | rythme de marche tenu |
| `autoWalkMult` | 0.3 | 0.7 | `[À CALER]` 0.5 | auto-marche gratuite (Q3) |
| `RESPAWN_DIST` | 0.5 | 1.5 | `0.9` | anti-farm sur place |
| `encounterRangeKm` | 0.03 | 0.10 | `0.06` | portée d'engagement |
| `campfireEveryKm` | 25 | 100 | `50` | espacement des hubs / checkpoints majeurs |
| `campfireRangeKm` | 0.8 | 2.0 | `1.2` | rayon d'accès au hub |
| `outOfCombatRegenPct` | 0.01 | 0.04 | `0.02` | soin passif hors combat |
| `mobsPerStep` | 1 | 3 | `2` | densité de rencontres |
| Kill-rate max serveur | — | — | `[À CALER — Track B]` | plafond anti-bot |

> **Divergences vs GAME_SPEC / master**
> - GAME_SPEC §6.1 « niveau mob = km × 10 » : conservé mais **indicatif** (`levelFromKm`
>   n'entre dans aucun calcul). Les stats mob suivent `combatBaseForLevel` (master Annexe C).
> - GAME_SPEC §7.1 courbe ×1.35 par zone : les ennemis suivent le **niveau** ; l'or/XP
>   suivent le niveau ; l'équipement garde une courbe de zone (×1.30). Master Annexe C.
> - Auto-marche ½ vitesse (Q3) : décidée, **pas encore codée** → Track G.

---

## 9. Integration Points

### Dépend de
- **`combat-gdd.md`** — la résolution de l'affrontement une fois `startEncounter` appelé.
- **`progression-gdd.md`** — courbe d'XP, montée de niveau, stats auto, points gagnés.
- **`economy-gdd.md`** — l'or du kill, l'or dépensé en boutique de proximité.
- **`inventory-gdd.md` / Loot** — `rollDrop` / `rollPetDrop`, fenêtre sac plein.
- **`campfire-gdd.md`** — ce qui se passe une fois `atCampfire` posé.
- **`narrative-gdd.md`** — cartes de transition de couche, noms de couche, décor.
- **`rebirth-gdd.md`** — `selectedCheckpoint` post-rebirth ≤ `bestKm / 2` ; reset distance.
- **`nightmare-gdd.md`** — avance auto pleine vitesse, multiplicateurs de récompense.

### Est utilisé par
- **`missions-gdd.md`** — objectifs « atteindre le km N », « tuer N mobs dans la couche X ».
- **`leaderboards-gdd.md`** — `bestKm` alimente le classement distance + le podium serveur.
- **`daily-dungeon-gdd.md` / `raid-gdd.md`** — boucle séparée, mais réutilise le moteur de
  rencontre + le pool de VFX.
- **`onboarding-gdd.md`** — les 3 premiers coach-marks portent sur la marche et le combat auto.
- **Analytics** — `wall_hit` (bloqué > N min sur le même km), lieux de mort, durée de session.

### Données partagées
- `GameConfig.World` / `.Progression` / `.Enemy` (reward curve).
- `ZoneConfig` — noms de couche, `KM_PER_ZONE`, rosters (Track D3).
- `EnemyService.encountersForZone` — layout des slots (client + serveur).

---

## Critères d'acceptation

- [ ] Tenir ◀ / ▶ fait marcher le héros ; relâcher → auto-marche ½ vitesse vers l'objectif.
- [ ] Les 3 familles d'entrée (clavier, tactile, manette) fonctionnent simultanément.
- [ ] Un slot tué réapparaît après `RESPAWN_DIST` parcouru, pas avant.
- [ ] Checkpoint auto enregistré à chaque marque de 10 km et à chaque feu de camp.
- [ ] La carte de transition de couche s'affiche 5 s et se ferme seule.
- [ ] Écran de mort : 2 boutons de taille égale, XP conservée affichée.
- [ ] `restart` repart au checkpoint choisi, monstres réapparus.
- [ ] `setCheckpoint` au-delà du max est clampé, pas rejeté.
- [ ] Aucune instance GUI créée par frame (pool de textes flottants).
- [ ] Exploits : `move` en boucle, `dir` non-string, `setCheckpoint` hors plage,
      `restart` sans `gameOver`.

---

## Questions ouvertes

- [ ] Valeur exacte de `autoWalkMult` (Q3 dit « 2× plus lente », donc 0.5) — confirmer et
      câbler → Track G, systems-designer.
- [ ] Plafond de kill-rate serveur anti-bot → lead-programmer / exploit-security (Track B) +
      risk-register.
- [ ] La retraversée post-mort (jusqu'à 50 km) est-elle trop punitive pour un joueur
      mobile ? → à valider en `/balance-check` (Track D6) et playtest (Track K3).
