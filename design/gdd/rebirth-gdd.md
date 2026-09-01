# Rebirth (infini, jalons /5, mur de niveau) — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** game-designer / systems-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Modèle chiffré (FIGÉ) :** `design/economy/D2` (via `GameConfig.Rebirth`),
`D6-playthrough-balance.md` (§4 les 4 cibles `/balance-check`, §6 risque faceroll R5)
**Code de référence :** `src/ReplicatedStorage/GameConfig.luau` (`.Rebirth` : `cost`,
`skillMult`, `xpMult` — tout déjà présent), `src/ServerScriptService/CombatServer.server.luau`
(handler `rebirth` existant lignes ~873-897, `restartRun`, `flushProfileNow`),
`src/ServerScriptService/PlayerDataService.luau` (`grantPurchase` / `flush` force)

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** Un reset volontaire **infini** de la vie du héros. On **garde**
l'équipement, les familiers, les points de compétence gagnés (pool + allocation), le codex, la
ou les sous-classes, les checkpoints, `bestKm`, et — au choix — les talents. On **remet à zéro**
le niveau, les stats auto, les points libres, l'or, la distance. En échange : un **bonus
d'efficacité croissant** sur chaque point investi (`skillMult`), un **bonus d'XP** (`xpMult`),
et l'accès aux **jalons `/5`** (sous-classe, 4ᵉ familier, branche avancée…).

**Pourquoi il existe ?** C'est le pilier 2 (« la mort fait avancer ») à l'échelle méta. Le
**mur de niveau `100 + 20 × rebirths`** (`progression-gdd.md`) gèle la puissance du héros
pendant que les ennemis montent — le Rebirth est la seule façon de relever le plafond. Q64 :
l'or explose avec la progression mais **le coût du Rebirth garde toujours l'avance** → il y a
toujours un Rebirth à viser, jamais de quoi en enchaîner plusieurs.

**Où dans la boucle ?**
- **Méta (jours / semaines) :** taper le mur (km ~30-37 au R0) → farmer le coût → Rebirth au
  feu de camp → repartir plus fort, plus loin.
- **Session :** un Rebirth se décide au feu de camp, jamais en combat (N6).
- **Jalons temps (master §5) :** 1ᵉʳ Rebirth jour 2-4 (~1,3 h modèle D6) ; R5 semaine 2-4.

---

## 2. Core Mechanics

### 2.1 Coût et condition

- Coût en or : `GameConfig.Rebirth.cost(n) = round(10 000 × 2,2^(n-1))` où `n` = le Rebirth
  **acheté** (1-indexé). R1 = 10 000 · R2 = 22 000 · R5 ≈ 234 256 · R10 ≈ 5,6 M.
- Le joueur doit **détenir** `cost(n)` ; après le Rebirth, **or = 0** (Q35). Le surplus est
  perdu (pas de report).
- **Aucun autre gate** (T-R4 validé) : pas de niveau minimum, pas d'obligation d'avoir atteint
  le mur. Rebirth à L40 est autorisé (suboptimal, mais c'est le choix du joueur).
- **Lieu :** n'importe quel feu de camp (N3 — le château = feu de camp du km 0). **Impossible
  en combat** (N6) : `st.atCampfire` doit être posé.
- **DataStore doit persister** : si `PlayerDataService.isPersisting(player) == false`, le
  Rebirth est **refusé** (Q109, master Annexe B #4) — on ne perd pas une vie sans sauvegarde.

### 2.2 Ce qui est gardé / remis à zéro

| Gardé (survit au Rebirth) | Remis à zéro |
|---|---|
| Équipement (6 slots + inventaire + verrous + filtres) | `niveau → 1`, `xp → 0` |
| Familiers (équipe + inventaire) | Stats **auto** (redérivées de L1) |
| `earnedPoints` — **pool ET allocation** | `freePoints` — pool et allocation (re-gagnés en re-levelant) |
| Codex (cartes, familles, bonus) | `or_ → 0` |
| `subclass` / `subclass2` / `subclassChangesAt` | `distance → selectedCheckpoint` |
| `checkpointMax`, `bestKm`, `selectedCheckpoint` | État de run (HP, ennemi, milestones) |
| Talents **si choix « Garder »** (sinon vidés → Écho) | — |
| `advancedBranchUnlocked` (R15) — toujours | — |
| `bigBossesBeaten`, `fastMode`, `deaths` | — |
| Palier de Cauchemar débloqué par couche (`nightmare-gdd.md`) | — |
| `talentEchoes`, `rebirths` (+1) | — |

### 2.3 Bonus de Rebirth (T-R2 validé — stats + XP uniquement)

- **`skillMult(n)` — efficacité des points investis (Q38, croissant) :**
  ```
  skillMult(n) = 1 + 0,10n + 0,01·n·(n−1)
    R0 ×1,00 · R1 ×1,10 · R2 ×1,22 · R3 ×1,36 · R5 ×1,70 · R10 ×2,90
  ```
  S'applique à **(points libres + points gagnés) alloués**, **jamais aux stats de départ ni à
  la part auto** : `effStat = autoStat(L) + (freeAlloc + earnedAlloc) × skillMult(n)`
  (`StatsService.recalc`, déjà codé — le nom `skillEffectPerRebirth 0,10` en config est
  `[DEPRECATED]`, seule `skillMult()` compte).
- **`xpMult(n)` — gain d'XP (Q38) :** `xpMult(n) = 1 + 0,25 × n` (additif). Passe par
  `RewardService.multiplier(player, "xp", st)` comme catégorie « gagnée » (se multiplie
  volontairement par-dessus les pass, cf. `monetization.md` §2).
- **Aucun bonus Rebirth sur or / loot / petLoot** (T-R2 — résout followup #8). `GameConfig
  .Rewards.rebirthBonus` ne porte que `xp`. Justification : l'or « explose » déjà via le
  scaling ennemi au km (Q64) ; ajouter un bonus multiplicatif casserait « le Rebirth garde
  l'avance ».
- **Valve de sécurité (D6 §6, T-R1 — documentée, INACTIVE) :** si K3 montre > 15 min de
  contenu trivial post-Rebirth, scinder :
  - `skillMult(n)` (courbe actuelle) → **points libres + gagnés uniquement** ;
  - `autoStatMult(n) = 1 + 0,05n` → **part auto** (R5 ×1,25 au lieu de ×1,70).
  Implémentation = G1 (StatsService sépare déjà auto / alloué). **Ne pas coder tant que K3 ne
  le demande pas.**

### 2.4 Point de départ post-Rebirth

- Après le Rebirth, la distance repart au `selectedCheckpoint` (choisi via `setCheckpoint`,
  `core-gameplay-gdd.md`).
- **Double contrainte, la plus stricte gagne :**
  - `selectedCheckpoint ≤ checkpointMax` (feu de camp débloqué, arrondi ×10) ;
  - `selectedCheckpoint ≤ bestKm / 2` (Q36 — on ne saute jamais plus de la moitié de son
    record).
- Effet voulu (D6 §6) : un joueur R5 record ~km 60 redémarre au plus km 30 → il saute les
  km triviaux mais re-traverse quand même ~50 % → faceroll borné à ~10-15 min, et il **veut**
  ce coup de boost (pilier 2).
- Les monstres réapparaissent (comme après une mort, N2).

### 2.5 Choix des talents (Q32 — prompt à la confirmation)

- Au moment où le joueur confirme le Rebirth, une modale demande **Garder** ou **Échanger**
  (détail complet : `talents-gdd.md` §2.5) :
  - **Garder** : l'arbre de talents reste intact ; le joueur regagne des points en re-levelant.
  - **Échanger** : les 3 branches de base sont vidées ; le joueur choisit **1 Écho** parmi 3
    (`+5 % dégâts` / `+8 % PV` / `−8 % cooldown`), `+1 cran` si l'Écho est déjà pris.
- **Défaut si non répondu** (T-R5) : **Garder**. La branche avancée R15 n'est jamais perdue,
  quel que soit le choix.

### 2.6 Jalons `/5`

| Jalon | Contenu | GDD porteur | Statut |
|---|---|---|---|
| **R5** | Sous-classe (Berserker/Gardien, Destructeur/Sage) | `subclass-gdd.md` | lancement |
| **R10** | 4ᵉ slot de familier | `pets-gdd.md` | lancement |
| **R15** | Branche de talents « Descente » (persiste à travers les Rebirths) | `talents-gdd.md` | lancement |
| **R20** | Donjon dimensionnel = le **donjon-raid solo** (N4), boss exclusifs | `raid-gdd.md` | lancement |
| **R25** | Double spécialisation (2 sous-classes, split moyen) | `subclass-gdd.md` | lancement |
| **R30** | Système de maîtrise (armes / sous-classes / styles se maîtrisent à l'usage) | **stub** | **post-lancement (T-R3)** — pas de spec au lancement, ~mois de jeu avant d'y arriver |

- Le passage d'un jalon déclenche un **toast** (« Rebirth 5 — choisis ta voie au feu de camp »)
  et pose un flag (`rebirthMilestonesSeen[n] = true`) pour ne pas re-notifier.
- Le contenu du jalon se débloque **au Rebirth** ; l'action associée (choisir la sous-classe,
  équiper un 4ᵉ familier) se fait ensuite au feu de camp.

### 2.7 Le mur de niveau — pourquoi le Rebirth est nécessaire

- `niveauMax = 100 + 20 × rebirths`. Les mobs suivent `round(km × 3,5)` sans plafond.
- La **pénalité d'écart de niveau** (`GameConfig.Combat.levelGap`, `dealtStep = 0,035` —
  validé proprio 2026-09-01, `progression-gdd.md` §2.6) fait tomber le mur combat vers
  **km ~30-37** au R0.
- Un Rebirth remonte le cap de 20 → le joueur re-level, l'écart se referme, la pénalité
  disparaît, il pousse plus loin. D6 : mur repoussé à km ~36-42 après R1, etc.

### State Diagram

```
[Mur atteint] → [farm du coût] → [feu de camp] ── or >= cost(n) & persisting & pas en combat ?
                                                    │ non → rebirthDenied {cost, reason}
                                                    │ oui
                                                    ▼
                                         [prompt talents : Garder / Échanger(+Écho)]
                                                    │
                                                    ▼
     rebirths++ · or=0 · niveau=1 · stats auto reset · freePoints reset · restartRun(selectedCheckpoint clampé)
     · earnedPoints/gear/pets/codex/subclass conservés · skillMult & xpMult montent
                                                    │
                                          jalon /5 franchi ? → toast + déblocage
                                                    │
                                                    ▼
                                         flushProfileNow (write garanti)  →  [Marche @ checkpoint]
```

---

## 3. Data Schema

### Clés DataStore (profil — `PROFILE_VERSION 2`)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `rebirths` | number | `0` | nombre de Rebirths — pilote `skillMult`, `xpMult`, `niveauMax`, les jalons |
| `rebirthMilestonesSeen` | `{[number]: true}` | `{}` | jalons `/5` déjà notifiés (pas de re-toast) |
| `selectedCheckpoint` | number | `0` | point de départ du prochain run, clampé `min(checkpointMax, floor(bestKm/2 /10)*10)` |
| `bestKm` | number | `0` | record absolu — **jamais** remis à zéro (classements, J6/J7, clamp du checkpoint) |
| `checkpointMax` | number | `0` | plus haute marque de 10 km — survit au Rebirth |
| `talentRebirthChoice` | string? | `nil` | `talents-gdd.md` |
| `talentEchoes` | `{[echoId]: number}` | `{}` | `talents-gdd.md` |

> Le Rebirth ne stocke **aucun** état de run. `restartRun` remet HP/ennemi/milestones.

### Runtime (`states[player]`)

Le handler `rebirth` remet : `rebirths++`, `gold=0`, `exp=0`, `playerLevel=1`, `playerExp=0`,
`playerExpToNext=xpNeeded(1)`, `freePool=0` + `freeAlloc` vidé, stats auto redérivées.
**Conserve** : `earnedPool`, `earnedAlloc`, `checkpointMaxKm`, `bestKm`, `selectedCheckpoint`,
équipement, familiers, `subclass`, talents (selon choix), `nightmareTier` débloqué.

---

## 4. Client-Server Split

### Le serveur possède
- La validation (or ≥ coût, feu de camp, pas en combat, DataStore persistant).
- L'application du reset, le calcul de `skillMult` / `xpMult`, le clamp du checkpoint
  (`min(checkpointMax, bestKm/2)`).
- Le prompt talents et l'application de l'Écho.
- Le déblocage des jalons `/5` + les toasts.
- Le **write garanti** (`flushProfileNow` → `PlayerDataService.flush(force=true)`).

### Le client possède
- L'écran Rebirth (coût vs or détenu, tableau Garde/Perd, `skillMult` avant→après,
  `xpMult` avant→après, sélecteur de feu de camp de départ + explication du clamp), la modale
  talents, l'animation de Rebirth (effet d'écran — `J3`).

### Jamais sur le client
- La décision « le joueur peut Rebirth » (feu de camp, or, persistance = serveur).
- Le montant d'or, le niveau, les stats après reset.
- Le clamp du checkpoint.

---

## 5. RemoteEvents / Functions

`CombatEvent` (dispatch par `data.type`). Aucun RemoteFunction C→S.

| `data.type` | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|
| `rebirth` | C→S | `{talentChoice?, echoId?, checkpointKm?}` | `st.atCampfire` ; `not combatActive` ; `gold ≥ cost(rebirths+1)` ; `PlayerDataService.isPersisting` ; `talentChoice ∈ {keep,echo}` (défaut `keep`) ; `echoId` valide si `echo` ; `checkpointKm` clampé `[0, min(checkpointMax, bestKm/2)]` | **1/s** (`GameConfig.Security`) |
| `rebirthDenied` | S→C | `{cost, reason}` | `reason ∈ {gold, campfire, combat, datastore}` | 1/tentative |
| `rebirthDone` | S→C | `{rebirths, skillPct, xpBonusPct, milestone?}` | n/a | 1/rebirth |
| `rebirthTalentPrompt` | S→C | `{currentEchoes}` | déclenche la modale avant l'application | 1/rebirth |

### Règles de validation
- `type(data) == "table"` en garde.
- Le handler existant (`CombatServer` ~L873) est **étendu** : ajouter les checks
  `st.atCampfire`, `not combatActive`, `isPersisting`, le clamp `bestKm/2`, le prompt talents,
  le hook jalons `/5`. Il fait déjà : `cost`, `gold` check, reset des stats/level/gold,
  `restartRun(selectedCheckpoint)`, `flushProfileNow`.
- `checkpointKm` crafté au-delà du max → **clampé**, pas rejeté (master Annexe B #6).

---

## 6. Player-Facing UI

**Encart Rebirth dans le menu du feu de camp — maquettes 07 / 12, encart précis = dette Track F
(T-X2). Ce GDD décrit la fonction.**

- **Bloc central :** « REBIRTH  n → n+1 ».
- **Coût :** `cost(n+1)` en or, avec l'or détenu (rouge si insuffisant).
- **Tableau Garde / Perd** (§2.2, version courte).
- **Bonus avant → après :** `skillMult` (`×1,36 → ×1,70`), `xpMult` (`+75 % → +100 %`).
- **Sélecteur de départ :** liste des feux de camp débloqués (`checkpointMax`), option grisée
  au-delà de `bestKm/2` avec la mention « limité à la moitié de ton record (km X) ».
- **Jalon :** si `n+1` est un multiple de 5, encart « Ce Rebirth débloque : <contenu du jalon> ».
- **Confirmation → modale talents** (Garder / Échanger + 3 Échos avec leur cran actuel).
- Accessibilité : montants chiffrés, pas de dépendance couleur (icône + libellé pour
  « gardé »/« perdu »).

---

## 7. Edge Cases & Error States

1. **Or insuffisant** — `rebirthDenied {cost, reason="gold"}` ; rien n'est modifié.
2. **Rebirth demandé en combat** — `reason="combat"` (N6).
3. **Rebirth hors feu de camp** — `reason="campfire"`.
4. **DataStore indisponible** — `reason="datastore"` (Q109) — pas de vie perdue sans save.
5. **`checkpointKm` > `bestKm/2`** — clampé (master Annexe B #6) ; l'UI l'explique déjà.
6. **`checkpointKm` > `checkpointMax`** — clampé à `checkpointMax` (la contrainte la plus
   stricte des deux gagne, `core-gameplay-gdd.md` Edge Case 5).
7. **Double-clic `rebirth`** — cap 1/s + le handler est mono-thread ; le 2ᵉ message voit
   `gold = 0` → `reason="gold"`. `flushProfileNow` est idempotent sur l'état résultant.
8. **`talentChoice` absent / invalide** — défaut **Garder** (T-R5) ; aucun Écho.
9. **Rebirth au niveau 12** (T-R4) — autorisé ; le joueur perd peu (niveau bas) mais gagne
   `skillMult` sur ses points investis — suboptimal, jamais bloqué.
10. **Jalon `/5` franchi mais joueur pas au feu de camp au moment du toast** — impossible
    (le Rebirth se fait AU feu de camp) ; l'action du jalon (choisir la sous-classe) se fait
    ensuite, au même feu de camp ou plus tard.
11. **Coût qui dépasse 2^53** (Rebirth très profond, `2,2^n`) — clampé / affiché en suffixes
    K/M/Md/T/… (Q112, master Annexe B #9). Le farm de l'or plafonne bien avant (le joueur ne
    peut pas détenir un nombre non représentable).
12. **Déconnexion pendant le `flushProfileNow`** — `PlayerDataService.flush(force)` fait un
    `UpdateAsync` avec retry ; soit le Rebirth complet est persisté, soit rien (le lock protège).
    Pas de « demi-Rebirth ».
13. **`skillMult(5) = ×1,70` faceroll** (D6 §6) — borné par le checkpoint `≤ bestKm/2` +
    valve de sécurité documentée (§2.3), décision reportée à K3.
14. **Migration v1 → v2 avec `rebirths > 0`** — `rebirthMilestonesSeen` backfill à `{}` : le
    joueur pourrait re-voir un toast de jalon déjà passé (bénin) ; on peut pré-remplir en
    migration (`for i=5,rebirths,5 do seen[i]=true end`).

---

## 8. Balancing Parameters

**Toutes les valeurs viennent de `GameConfig.Rebirth` (D2) et sont cadrées par D6.**

| Paramètre | Source | Valeur | Rôle |
|---|---|---|---|
| `Rebirth.baseCost` | D2 | `10 000` | coût R1 |
| `Rebirth.costScaling` | D2 / Q64 | `2,2` | vs or/climb ~×2,0/rebirth → le Rebirth garde l'avance |
| `Rebirth.skillMult(n)` | D2 / Q38 | `1 + 0,10n + 0,01·n·(n−1)` | efficacité croissante des points investis |
| `Rebirth.xpMult(n)` | D2 / Q38 | `1 + 0,25n` | gain d'XP |
| `niveauMax` | master §5.1 / Q26 | `100 + 20n` | le mur |
| Checkpoint post-rebirth | Q36 | `≤ min(checkpointMax, bestKm/2)` | borne le faceroll, garde la re-traversée |
| `Combat.levelGap.dealtStep` | D6 §3 (validé proprio) | `0,035` | mur combat km ~30-37 |
| `Enemy.goldPerLevel` | D2 | `1,026` | or/climb ~×2,0/rebirth |
| Valve `autoStatMult(n)` | D6 §6 | `1 + 0,05n` **INACTIVE** | à activer si K3 montre > 15 min trivial |

### Formules (Annexe A master — rappel)

```
cost(n)        = round(10 000 × 2,2^(n-1))
skillMult(n)   = 1 + 0,10n + 0,01·n·(n−1)
xpMult(n)      = 1 + 0,25n
niveauMax      = 100 + 20n
checkpoint_max_post_rebirth = min( checkpointMax , floor(bestKm/2 / 10) × 10 )
effStat        = autoStat(L) + (freeAlloc + earnedAlloc) × skillMult(n)
```

### Les 4 cibles `/balance-check` (D6 §4 — à re-valider en jeu K3)

| # | Cible | Modèle D6 | Verdict |
|---|---|---|---|
| 1 | f2p bat boss C3 + 1 Rebirth ≤ 1,5 h | ~1,3 h | ✅ (si `levelGap` en place — c'est le cas) |
| 2 | 1er mur km 25-35 | mur niveau km ~27 ; mur ressenti km ~30-37 avec `dealtStep 0,035` | ✅ |
| 3 | arme boutique ≤ 60 % arme de boss même zone | 40 % à rareté égale | ✅ |
| 4 | re-traversée post-rebirth ~20 % du temps | ~17 % | ✅ |

---

## 9. Integration Points

### Dépend de
- **`progression-gdd.md`** — `niveauMax`, la séparation auto / alloué, `skillMult` sur
  l'alloué, `earnedPoints` conservés, `freePoints` reset.
- **`core-gameplay-gdd.md`** — `selectedCheckpoint`, `checkpointMax`, `bestKm`, `restartRun`,
  respawn des monstres, le fait que le feu de camp est physique (N3/N6).
- **`economy-gdd.md`** — le Rebirth est le **sink d'or principal** ; la courbe `goldPerLevel
  1,026` vs `costScaling 2,2` (Q64).
- **D2 / D6** — toutes les valeurs.

### Est utilisé par
- **`subclass-gdd.md`** — R5 (choix), R10/R15/R25 (jalons), `subclassChangesAt`,
  le bornage faceroll.
- **`talents-gdd.md`** — le prompt Garder/Échanger, les Échos, le déblocage R15.
- **`pets-gdd.md`** — R10 (4ᵉ slot).
- **`raid-gdd.md`** — R20 (donjon dimensionnel = raid solo).
- **`nightmare-gdd.md`** — le palier de Cauchemar est permanent (survit au Rebirth) ;
  `xpMult` se multiplie par-dessus `Nightmare.rewardMult` (catégories gagnées).
- **`leaderboards-gdd.md`** — `rebirths` est un classement all-time (Q81).
- **`monetization.md`** — jamais vendu en Robux (master §6) ; le respec des points, oui.
- **Analytics** — `1er Rebirth` (master §8), Rebirth par jour, choix talents, jalon atteint.

### Données partagées
- `GameConfig.Rebirth` (`cost`, `skillMult`, `xpMult`), `GameConfig.Rewards.rebirthBonus.xp`.
- `Types.luau` — `PlayerData` (`rebirths`, `rebirthMilestonesSeen`, `talentEchoes`, …).

---

## Critères d'acceptation

- [ ] Rebirth refusé (avec la bonne `reason`) si : or < coût, en combat, hors feu de camp,
      DataStore non persistant.
- [ ] Après Rebirth : `rebirths+1`, or 0, niveau 1, stats auto redérivées, `freePoints` vidés ;
      `earnedPoints` (pool + alloc), gear, pets, codex, sous-classe **conservés**.
- [ ] `skillMult` et `xpMult` montent selon les formules ; l'effet est visible immédiatement.
- [ ] Le point de départ est clampé à `min(checkpointMax, bestKm/2)` ; un `checkpointKm` crafté
      est clampé, pas rejeté.
- [ ] Prompt talents à la confirmation ; défaut = Garder ; Échanger donne l'Écho (+1 cran si
      déjà pris) et vide les 3 branches de base (pas la branche avancée).
- [ ] Les jalons R5/R10/R15/R20/R25 se débloquent au bon Rebirth avec un toast unique.
- [ ] `flushProfileNow` : write garanti ; une déconnexion pendant l'opération ne laisse pas de
      demi-Rebirth (`/datastore-review` G8).
- [ ] `/balance-check` : les 4 cibles D6 tiennent en jeu (K3).
- [ ] Exploits testés : `rebirth` sans `gameOver` requis (non — Rebirth ≠ mort), spam
      `rebirth`, `checkpointKm` hors plage, `talentChoice` invalide, Rebirth en combat.

---

## Questions ouvertes

- [ ] Spec de R30 (système de maîtrise) → post-lancement (T-R3), stub jusque-là.
- [ ] Faut-il pré-remplir `rebirthMilestonesSeen` en migration pour les profils `rebirths > 0` ?
      (proposé : oui, `for i=5,rebirths,5`) → G8.
- [ ] Valve `autoStatMult` : à activer seulement si K3 montre > 15 min de trivial post-Rebirth
      (D6 §6).
- [ ] Contenu du donjon dimensionnel R20 → `raid-gdd.md` (C6).
