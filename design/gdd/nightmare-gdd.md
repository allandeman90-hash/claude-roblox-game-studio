# Mode Cauchemar (ladder par couche, infini) — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** game-designer / economy-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Modèle chiffré (FIGÉ) :** `GameConfig.Nightmare` (D2, validé 2026-08-31),
`D6-playthrough-balance.md`
**Code de référence :** `src/ReplicatedStorage/GameConfig.luau` (`.Nightmare` — tout présent :
`hpMult` / `atkMult` / `rewardMult` / `enrageSeconds` / `killsForTierOne` / `killsPerExtraTier`
/ `globalGateBossCouche` / `earnedPointsPerNewTier`), `src/ServerScriptService/RewardService.luau`
(`multiplier(player, cat, st)` lit déjà `st.nightmareTier` → 0 aujourd'hui — followup #4),
`CombatServer.server.luau` (boucles de combat, `resolvePlayerHit`), `EnemyService.luau`,
`ZoneService.luau` (`markBossDefeated`)

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** Un ladder de difficulté **infini** attaché à **chaque couche
individuellement** : Cauchemar I → II → III → … (Q41). Il **remplace définitivement**
l'ancienne « Ascension » (Q42). Un run de Cauchemar = **rejouer une seule couche** (ses 10 km,
de l'entrée jusqu'à son Gardien) au palier `k`, avec des ennemis massivement renforcés et des
récompenses massivement gonflées. Porte globale : **avoir battu le boss de la Couche 6 une
fois** (Q39).

**Pourquoi il existe ?** C'est le **puits de dépense end-game** et le **rééquilibreur** de
tout le reste : c'est parce que le Cauchemar monte à l'infini au même rythme que le joueur
qu'il n'y a **pas de plafond de points de compétence** (Q30) et que les multiplicateurs
confort peuvent être plafonnés à ×3 sans casser le jeu (`monetization.md` §1). C'est aussi le
faucet principal d'**or**, de **points de compétence**, et de **familiers** une fois la
Descente « résolue ». Et le seul classement de skill pur avec le Donjon du Jour (Q81).

**Où dans la boucle ?**
- **Session (après la porte C6) :** 1-2 runs de Cauchemar depuis un feu de camp (~4-8 min
  chacun).
- **Méta :** faire monter le palier de chaque couche, viser le classement, farmer un set
  précis en volume.

---

## 2. Core Mechanics

### 2.1 Périmètre d'un run (N-1 / N-2 validés)

- Un run de Cauchemar = **une couche, ses 10 km, de l'entrée à son Gardien**. Ce **n'est pas**
  la Descente continue.
- Lancé depuis **n'importe quel feu de camp** (panneau Cauchemar). Le héros est placé à
  l'entrée de la couche choisie ; la distance/Descente normale n'est pas touchée.
- **Le héros avance tout seul, pleine vitesse** (Q43, N-8) — aucune entrée de marche.
  **Fuite désactivée** (gauntlet — on s'engage).
- **Mort en Cauchemar** → retour à **l'entrée de la couche** (pas de re-marche de 50 km, pas
  de perte). Le palier débloqué est conservé. Le run est simplement raté.
- **Clear** = tuer le Gardien de la couche au palier `k`. Incrémente le compteur de kills du
  palier (déblocage du suivant) et, si c'est un **premier** clear de ce palier sur cette
  couche, crédite `+1` point de compétence.
- Le **Rebirth est impossible en Cauchemar** (feu de camp requis, N6) : il faut sortir d'abord.

### 2.2 Porte globale + déblocage par couche (Q39, N-3 validé)

- **Porte globale** : `nightmareGlobalGate` posé `true` quand le joueur bat le boss de la
  **Couche 6** (`GameConfig.Nightmare.globalGateBossCouche = 6`). **Avant ça : aucun Cauchemar
  sur aucune couche**, même avec 100 kills accumulés.
- **Cauchemar I d'une couche** : `~100` kills de son Gardien **en mode normal**
  (`killsForTierOne = 100`). Compteur `nightmareBossKills[couche]`.
- **Palier `k+1`** : `+25` kills du Gardien de cette couche **au palier `k`**
  (`killsPerExtraTier = 25`). Les kills en mode normal ne comptent que pour le palier I.
- Le sélecteur de palier autorise `tier ≤ nightmareMaxTier[couche] + 1` (on peut toujours
  tenter le palier suivant, jamais sauter).

### 2.3 Effet par palier `k` (D2 — FIGÉ, `GameConfig.Nightmare`)

```
ennemis HP    × hpMultPerTier ^ k          (1,55^k)   -- séparé
ennemis ATK   × atkMultPerTier ^ k         (1,35^k)   -- séparé
récompenses   × rewardMultPerTier ^ k      (1,80^k)   -- or, XP, faucet de points, TAUX de drop familier
cotes de rareté d'objet : INCHANGÉES (Q40)
enrage boss   : max(30, 95 − 5k) s, puis +25 % ATK / 5 s non capé   (boss-mechanics-gdd.md)
```

- HP et ATK sont **des multiplicateurs séparés** : ils se composent dans la course sans fuite
  (`combat-gdd.md` : `PV × DPS`), donc chacun reste modeste sur la base à niveau.
- **Difficulté ≈ produit `~2,09^k`** vs **récompenses `1,80^k`** → l'écart se creuse de
  ~16 %/palier → **plafond réel** (D2). Le joueur monte les paliers jusqu'à ce que son build
  du moment cale, puis progresse (Rebirth, gear, talents) et repousse.
- **Pas de pénalité d'écart de niveau** (N-7) : on rejoue une couche basse, `niveau mob =
  round(km × 3,5)` est faible, le joueur est au cap → il sur-niveau la couche → la difficulté
  vient **uniquement** des mults + de l'enrage. Le ladder est auto-contenu.

### 2.4 Récompenses (N-4 / N-5 validés)

- **Or** : `enemyGold × RewardService.multiplier(gold) × Nightmare.rewardMult(k)`. Faucet
  principal de l'end-game (`economy-gdd.md`).
- **Points de compétence** : `+1` au **premier** clear d'un nouveau palier sur une couche
  (`earnedPointsPerNewTier = 1`, `earnedSourceLog["nm:<couche>:<tier>"]`). Permanents. C'est
  ce qui fait que « pas de plafond de points » (Q30) est cohérent : tout le monde les gagne au
  même rythme (le Cauchemar).
- **XP** : `× rewardMult(k)` **mais plafonnée par le niveau max** — utile surtout **juste
  après un Rebirth** (re-level rapide). Hors de cette fenêtre, l'XP du Cauchemar est
  quasi-perdue → **le Cauchemar est un faucet or / points / familiers, pas XP.**
- **Familiers** : le **taux de drop** est `× rewardMult(k)` (jusqu'au `dropRateCap 0,95`) —
  le Cauchemar est le meilleur endroit pour compléter le codex des familiers d'une couche.
- **Butin d'équipement** : cotes de rareté **inchangées** (Q40), zone du drop **cappée à la
  couche jouée** (`LootService` : `min(zone, maxZoneReached)`). Le Cauchemar de la couche 3
  droppe du gear de puissance couche 3 — c'est du **volume**, pas du tier. Pour farmer le set
  de la couche 10, il faut débloquer le Cauchemar de la couche 10 (100 kills du Gardien C10).

### 2.5 Permanence

- `nightmareBossKills`, `nightmareMaxTier`, `nightmareGlobalGate` **survivent au Rebirth**
  (master §5.7).
- Le `xpMult(rebirths)` et l'absence de bonus Rebirth sur l'or (T-R2) s'appliquent : en
  Cauchemar, `gold = base × min(3, confort) × rewardMult(k)` (pas de `× rebirthBonus`),
  `xp = base × min(3, confort) × rewardMult(k) × xpMult(rebirths)` (catégories gagnées qui se
  multiplient, `monetization.md` §2).

### State Diagram

```
[boss C6 battu] → nightmareGlobalGate = true

[feu de camp] → panneau Cauchemar → choisir couche (débloquée) + palier (≤ maxTier+1)
      │
      ▼
[Entrée couche, avance auto, fuite OFF] → mobs ×1,55^k HP / ×1,35^k ATK → ... → [Gardien + enrage]
      │                                                                              │
   mort → retour entrée couche (palier conservé)              clear → +kills palier ; 1er clear → +1 point
      │                                                                              │
      └──────────────────────── sortie → [feu de camp] ◄──────────────────────────────┘
```

---

## 3. Data Schema

### Clés DataStore (profil — `PROFILE_VERSION 2`)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `nightmareGlobalGate` | bool | `false` | posé `true` à la 1ʳᵉ victoire sur le boss de la Couche 6 |
| `nightmareBossKills` | `{[number]: number}` | `{}` | kills du Gardien par couche (mode normal + par palier — clé composite `"<couche>:<tier>"` en interne, ou 2 tables) |
| `nightmareMaxTier` | `{[number]: number}` | `{}` | plus haut palier **clear** par couche |
| `earnedSourceLog` | `{[string]: true}` | partagé `progression-gdd.md` | `"nm:<couche>:<tier>"` = point de compétence déjà crédité |

### Migration v1 → v2

Additif : `migrate()` backfill `nightmareGlobalGate = false`, `nightmareBossKills = {}`,
`nightmareMaxTier = {}`. Un profil `rebirths > 0` peut avoir déjà battu C6 — on peut
pré-poser `nightmareGlobalGate = true if checkpointMax >= 60` (bénin s'il ne l'a pas fait,
il a de toute façon 0 kill).

### Runtime (`states[player]`)

| Champ | Type | Description |
|---|---|---|
| `nightmareTier` | number | `0` hors Cauchemar ; `k ≥ 1` en run — **lu par `RewardService.multiplier`** |
| `nightmareCouche` | number? | couche jouée |
| `nightmareRun` | bool | un run est en cours (avance auto, fuite OFF, pas de Rebirth) |
| `enrageAtSec` / `enraged` | number / bool | `boss-mechanics-gdd.md` |

---

## 4. Client-Server Split

### Le serveur possède
- La porte globale, les compteurs de kills, le calcul du palier max, le sélecteur borné.
- L'application de `hpMult` / `atkMult` dans les boucles de combat, `rewardMult` via
  `RewardService.multiplier` (poser `st.nightmareTier` — followup #4).
- Le minuteur d'enrage (Cauchemar uniquement), le faucet de points (`earnedSourceLog`).
- Le placement à l'entrée de la couche, l'avance auto, le verrou de fuite / de Rebirth.
- Le retour à l'entrée sur mort, la sortie vers le feu de camp.

### Le client possède
- Le panneau Cauchemar (liste des couches débloquées, sélecteur de palier, aperçu des mults).
- Le HUD de run : « Couche N — Cauchemar `k` », timer d'enrage, compteur de kills restants
  pour le palier suivant. Pas de piste de marche (avance auto).

### Jamais sur le client
- Le palier réel, les compteurs de kills, la décision « ce palier est débloqué »,
  les multiplicateurs appliqués.

---

## 5. RemoteEvents / Functions

`CombatEvent` (dispatch par `data.type`). Aucun RemoteFunction C→S.

| `data.type` | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|
| `enterNightmare` | C→S | `{couche, tier}` | `nightmareGlobalGate == true` ; `couche` a `nightmareMaxTier ≥ 1` (ou 100 kills normaux si tier 1) ; `tier` clampé `[1, nightmareMaxTier[couche] + 1]` ; `st.atCampfire` ; `not combatActive` | 2/s |
| `exitNightmare` | C→S | `{}` | `nightmareRun == true` ; ramène au feu de camp d'origine | 2/s |
| `nightmareUpdate` | S→C | `{couche, tier, killsToNextTier, enrageAt, mults}` | n/a | à chaque changement |
| `nightmareUnlock` | S→C | `{couche, tier}` | n/a (toast « Cauchemar `k` débloqué — Couche N ») | 1/déblocage |

### Règles de validation
- `type(data) == "table"` ; `couche` / `tier` entiers, bornés.
- `enterNightmare` sans la porte C6 → refusé (`{type="nightmareDenied", reason="gate"}`).
- `tier` crafté au-delà de `maxTier + 1` → **clampé**, pas rejeté.
- Cap à ajouter `GameConfig.Security.remotePerType` : `enterNightmare = 2`, `exitNightmare = 2`.

---

## 6. Player-Facing UI

**Panneau Cauchemar dans le menu du feu de camp — dette Track F.**

- **Panneau :** grille des 12 couches (verrouillées tant que la porte C6 n'est pas passée, ou
  tant que < 100 kills du Gardien). Pour une couche débloquée : palier max atteint, sélecteur
  `I … maxTier+1`, aperçu chiffré des mults (HP ×, ATK ×, récompenses ×), enrage `X s`, bouton
  **ENTRER**. Un compteur « `n / 25` kills vers Cauchemar `k+1` ».
- **En run :** bandeau haut « Couche N — Cauchemar `k` » ; **timer d'enrage** visible sur le
  Gardien (compte à rebours + « ENRAGE » à 0) ; pas de boutons de marche ; bouton **Abandonner**
  (retour feu de camp).
- Accessibilité : mults en toutes lettres, timer d'enrage = chiffre + son (pas que la couleur).

---

## 7. Edge Cases & Error States

1. **`enterNightmare` sans la porte C6** — refusé (`reason="gate"`).
2. **`tier` crafté au-delà de `maxTier + 1`** — clampé.
3. **Mort en Cauchemar** — retour à l'entrée de la couche, palier et compteurs conservés,
   aucune perte de progression normale.
4. **Rebirth demandé en Cauchemar** — refusé (feu de camp requis, N6) ; il faut `exitNightmare`.
5. **Grands nombres `1,55^k` / `1,35^k`** — stats ennemi clampées à `statHardMax = 1e15` ;
   affichage en suffixes K/M/Md/T/… (Q112).
6. **Déconnexion en plein run** — aucun état de run sauvé ; à la reconnexion, le joueur
   réapparaît **au feu de camp** (pas dans le Cauchemar), palier intact.
7. **Point de compétence déjà crédité pour ce palier/couche** — `earnedSourceLog["nm:…"]`
   bloque le re-crédit ; les runs suivants du même palier ne donnent que le faucet or/familier.
8. **Couche non développée** (`ZoneConfig` roster vide) — `EnemyService` retombe sur le boss
   générique ; le run ne casse jamais.
9. **DataStore indisponible** (Q109) — les paliers vivent en mémoire ; un **nouveau
   déblocage** n'est pas persisté tant que le DataStore ne revient pas (bandeau « non
   sauvegardé ») ; on peut quand même jouer les paliers déjà en mémoire.
10. **Enrage + interruption réussie** — l'enrage continue (l'interruption ne remet pas le
    minuteur, `boss-mechanics-gdd.md`).
11. **Cauchemar sur la couche 12 puis cyclage** (couches 13+) — `ZoneConfig.bossTheme(index)`
    recycle les identités ; le Cauchemar suit l'index de couche réel.
12. **Joueur sous le niveau max en Cauchemar** (Rebirth récent, pas re-levelé) — la couche
    basse reste facile en niveau ; les mults `×1,55^k` font le travail ; possible que ce soit
    plus dur que prévu → `/balance-check`.

---

## 8. Balancing Parameters

**TOUT vient de `GameConfig.Nightmare` (D2, validé). Aucune valeur nouvelle.**

| Paramètre | Valeur | Rôle |
|---|---|---|
| `hpMultPerTier` | `1,55` | HP ennemi ^ palier |
| `atkMultPerTier` | `1,35` | ATK ennemi ^ palier |
| `rewardMultPerTier` | `1,80` | or / XP / faucet points / taux drop familier ^ palier |
| `killsForTierOne` | `100` | kills du Gardien (mode normal) → Cauchemar I |
| `killsPerExtraTier` | `25` | kills du Gardien au palier k → palier k+1 |
| `globalGateBossCouche` | `6` | porte globale |
| `earnedPointsPerNewTier` | `1` | 1ᵉʳ clear d'un nouveau palier / couche |
| `enrageBaseSeconds` / `enrageStepSeconds` / `enrageFloorSeconds` | `95` / `5` / `30` | `enrage(k) = max(30, 95 − 5k)` |

### Formules

```
difficulté(k) ≈ hpMultPerTier^k × atkMultPerTier^k  ≈ 2,09^k
récompense(k) = rewardMultPerTier^k                  = 1,80^k
→ l'écart difficulté/récompense croît de ~16 %/palier → plafond réel
gold en Cauchemar = enemyGold × min(3, mult_confort) × 1,80^k          (pas de bonus Rebirth, T-R2)
xp   en Cauchemar = enemyExp  × min(3, mult_confort) × 1,80^k × xpMult(rebirths)   (plafonné par niveauMax)
enrage(k)        = max(30, 95 − 5k)  puis  ATK boss × (1 + 0,25 × floor((t − enrage(k))/5))
```

### Cibles `/balance-check` (K3, en jeu)
- Un build **optimal à un instant T** cale vers le **palier 8-12** (pas 3, pas 30).
- Chaque Rebirth repousse le palier accessible de ~2-4.
- Le faucet d'or du Cauchemar ne doit **pas** permettre d'enchaîner 2 Rebirths (Q64) : le
  `rewardMult(k)` sur l'or est compensé par le fait qu'on farme une couche basse (`enemyGold`
  bas) et par `costScaling 2,2`.

---

## 9. Integration Points

### Dépend de
- **`boss-mechanics-gdd.md`** — l'enrage (Cauchemar uniquement), les phases du Gardien.
- **`combat-gdd.md`** — `hpMult` / `atkMult` sur les boucles, la course `PV × DPS`.
- **`progression-gdd.md`** — le faucet de points de compétence, le plafond d'XP, l'absence de
  plafond de points (justifiée par le Cauchemar, Q30).
- **`rebirth-gdd.md`** — permanence des paliers, `xpMult`, pas de bonus Rebirth sur l'or.
- **`RewardService`** — `multiplier(player, cat, st)` lit `st.nightmareTier` (followup #4).
- **D2 / D6**.

### Est utilisé par
- **`economy-gdd.md`** — faucet d'or end-game.
- **`leaderboards-gdd.md`** — **classement « palier de Cauchemar » = plus haut palier atteint
  toutes couches confondues** (un seul nombre, N-9), all-time (Q81).
- **`pets-gdd.md` / `codex-gdd.md`** — taux de drop familier `× 1,80^k` → farm de codex.
- **`missions-gdd.md`** — objectifs « clear un Cauchemar palier N ».
- **Analytics** — palier atteint par couche, `wall_hit` sur un palier, taux d'abandon de run.

### Données partagées
- `GameConfig.Nightmare` (tout), `GameConfig.Rewards` (resolver).
- `Types.luau` — `PlayerData` (`nightmareGlobalGate`, `nightmareBossKills`, `nightmareMaxTier`).

---

## Critères d'acceptation

- [ ] Aucun Cauchemar accessible avant la 1ʳᵉ victoire sur le boss de la Couche 6.
- [ ] 100 kills du Gardien d'une couche (mode normal) débloquent Cauchemar I ; +25 au palier k
      débloquent k+1.
- [ ] Un run = une couche, entrée → Gardien ; mort = retour entrée, aucune perte.
- [ ] En Cauchemar : avance auto pleine vitesse, fuite désactivée, Rebirth impossible.
- [ ] Ennemis `×1,55^k` HP / `×1,35^k` ATK ; récompenses `×1,80^k` ; cotes de rareté inchangées.
- [ ] `+1` point de compétence au 1ᵉʳ clear d'un nouveau palier / couche, une seule fois.
- [ ] Enrage actif uniquement en Cauchemar.
- [ ] Butin cappé à la couche jouée (volume, pas tier).
- [ ] Paliers et compteurs survivent au Rebirth.
- [ ] `RewardService.multiplier` applique `Nightmare.rewardMult(st.nightmareTier)`.
- [ ] Exploits testés : `enterNightmare` sans la porte, `tier` hors plage, Rebirth en run,
      farm de kills sans clear, spam `enterNightmare`.

---

## Questions ouvertes

- [ ] Le plafond effectif tombe-t-il bien palier 8-12 pour un build optimal ? → `/balance-check` K3.
- [ ] Faut-il un léger malus si le joueur est **sous le niveau max** en Cauchemar (Rebirth
      récent), ou l'accepte-t-on tel quel ? → K3.
- [ ] `nightmareBossKills` : une table à clé composite `"<couche>:<tier>"` ou deux tables
      (`killsNormal[couche]` + `killsAtTier[couche][tier]`) ? → G9 (implémentation).
- [ ] Pré-poser `nightmareGlobalGate` en migration pour les profils `checkpointMax ≥ 60` ? → G9.
