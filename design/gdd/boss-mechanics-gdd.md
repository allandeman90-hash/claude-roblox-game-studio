# Mécaniques de boss (phases, interruption, adds, enrage) — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** game-designer / systems-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Sources narratives :** `design/narrative/la-descente.md` (les 12 Gardiens comme personnages),
`design/narrative/boss-dialogues.md` (E2 — répliques 1ʳᵉ / 2ᵈᵉ rencontre)
**Modèle chiffré :** `GameConfig.Enemy.Boss` (multiplicateurs boss / big boss),
`GameConfig.Nightmare` (enrage), `D6-playthrough-balance.md`
**Code de référence :** `src/ServerScriptService/CombatServer.server.luau` (boucle de combat,
`resolvePlayerHit`, `st.isBoss` / `st.enemyIsBigBoss`), `EnemyService.luau` (`rollBoss`),
`ZoneService.luau` (`markBossDefeated`) ; `src/ReplicatedStorage/ZoneConfig.luau`
(`BossThemes` — les 12) ; `GameConfig.luau` (`.BossMechanics` — nouveau bloc)

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** Ce qui transforme un ennemi « à barre de vie plus longue » en
un **mur** (pilier 4). Chaque Gardien (boss nommé tous les 10 km) a :
- **2 à 4 phases** (Q21), marquées par des pastilles sur la barre de vie ;
- **une grosse attaque télégraphée** à interrompre avec **le bon pouvoir** (Q20) — sinon on
  encaisse 50–80 % de ses PV (létal si entamé, one-shot si sous-niveau) ;
- **des adds** qui le **protègent** tant qu'ils vivent, tués un par un (Q23) ;
- **un minuteur d'enrage — uniquement en mode Cauchemar** (Q22) ;
- **UNE signature mécanique** propre (les 12 ci-dessous).

La **forme de domaine / « Gueule »** (big boss, tous les 100 km) = la même identité, ses
multiplicateurs poussés à l'extrême, +1 phase, **aucune mécanique nouvelle** (B8).

**Pourquoi il existe ?** Le combat étant automatique, le boss est le seul endroit où le
**build** (pouvoirs choisis, talents, familiers, sous-classe) est vraiment testé. C'est aussi
là que se joue le **cross-RES** : un Guerrier a **0 RES** (décision proprio) — les boss
magiques ne se battent pas avec une stat, mais avec le **kit** (interruption + slot défensif +
talents *Cuirasse*/*Absorption*/*Dernier rempart* + familiers Tank/Heal + recul/regen).

**Où dans la boucle ?**
- **5 min :** un Gardien tous les 10 km, ferme la couche.
- **Session :** on se prépare au feu de camp avant un boss (ajuster pouvoirs / talents).
- **Méta :** en Cauchemar, l'enrage s'ajoute ; les Gueules (100 km) sont des événements.

---

## 2. Core Mechanics

### 2.1 Structure de phases (Q21)

- 2 à 4 phases par Gardien. Seuils de PV :
  - 2 phases → 50 %
  - 3 phases → 66 % / 33 %
  - 4 phases → 75 % / 50 % / 25 %
- **Pastilles** sur la barre de vie du boss aux seuils. Franchir un seuil : petite pause de
  télégraphe (~1 s), changement de pattern (cadence, fréquence de la grosse attaque,
  invocation d'adds, activation de la signature).
- **Dialogue (E2)** : 2-3 lignes à l'entrée (bulle au-dessus du boss), 1 ligne à la mort.
  Béhémoth = **texte narrateur**, pas de bulle (`la-descente.md`).
- **Big boss** : +1 phase par rapport au Gardien (donc 3 à 5), seuils recalculés.

### 2.2 Grosse attaque télégraphée + interruption (Q20)

- Chaque Gardien lance sa grosse attaque à intervalle (`bigAttackEverySec`, se raccourcit par
  phase). **Télégraphe** : jauge rouge qui se remplit (`telegraphSec`) + bordure d'écran + son
  (`J2/J3`).
- **Fenêtre d'interruption : 1,5 s** (`interruptWindowSec`, B2), à la fin du remplissage.
  Talent *Lecture* (`talents-gdd.md`) l'allonge.
- Le client **recontextualise** toute tuile de pouvoir équipée qui porte `interrupt`
  (`abilities-gdd.md` §2.5) en bouton **INTERROMPRE**.
- **Interrompue** → l'attaque est **annulée**, le boss **chancelle** `staggerSec` (~1,5 s de
  dégâts subis `×staggerDmgMult` ~1,5). Le pouvoir part en CD normal.
- **Non interrompue** → **coup de `50–80 % des PV max`** du héros à niveau (B3) :
  - héros proche du max → survit de justesse ;
  - héros déjà entamé → **mort** ;
  - héros **sous-niveau** (mob out-level > 5) → la pénalité d'écart (`takenStep 0,022`,
    `takenCap 3,0`) porte le coup **au-delà de 100 % → one-shot**. Voulu : le mur.
- **Aucune tuile `interrupt` équipée** → pas de recontextualisation, aucun moyen d'annuler,
  bandeau d'avertissement. C'est le prix d'un build tout-offensif (A2).

### 2.3 Adds (Q23)

- Certaines phases invoquent 1 à 3 adds (mobs de la couche ou adds thématiques).
- **Les adds protègent le boss** (B5) : tant qu'au moins un add est vivant, le boss est
  **non ciblable** — l'auto-attaque et les pouvoirs se reportent sur l'add le plus proche
  *(variante d'implémentation : boss ciblable mais `−90 % dégâts subis` ; trancher en G7,
  l'effet de design est le même — il faut nettoyer les adds)*.
- Les adds se tuent **un par un** (combat normal, pas d'AoE obligatoire ; un pouvoir `aoe`
  aide mais n'est pas requis).
- Pendant les adds, le boss **continue de frapper** (et peut lancer sa grosse attaque → il
  faut parfois interrompre en plein nettoyage d'adds).
- Leviers : talent *Inébranlable* (`−%` dégâts des adds), pouvoir *Piège runique* (le prochain
  add naît à 1 PV), *Frappe sismique* / *Détonation arcanique* (`aoe`).

### 2.4 Enrage — Cauchemar uniquement (Q22)

- **N'existe pas hors Cauchemar.** En Cauchemar palier `k` : minuteur
  `GameConfig.Nightmare.enrageSeconds(k) = max(30, 95 − 5k)` s dès le début du combat de boss.
- À l'expiration : **ATK du boss `+25 % toutes les 5 s`, non capé** (B7), jusqu'à la mort du
  boss ou le wipe. Signalé (bordure d'écran pulsée + son + timer visible).
- L'enrage transforme un combat d'usure en course : il faut un DPS suffisant **avant**
  l'expiration → c'est le plafond réel du Cauchemar (`nightmare-gdd.md`).

### 2.5 Les 12 signatures (validées en bloc B1 ; chiffres → G7)

`type` = type de dégâts (`ZoneConfig.BossThemes.magic`). Contre les magiques, un Guerrier
0 RES s'appuie sur le kit (colonne « contre »).

| # | Gardien (km) | Type | Signature | Phases | Contre (kit) |
|---|---|---|---|---|---|
| 1 | Roi Gobelin (10) | phys | **Ralliement** — vagues de gobelins ; se couvre (`−dégâts subis`) tant qu'une vague vit | 2 | nettoyer les adds vite ; *Piège runique* |
| 2 | Golem de Pierre (20) | phys | **Carapace** — alterne posture dure (quasi-invulnérable, lent) / fissurée (vulnérable) ; interrompre l'écrasement le force en posture fissurée | 3 | interrompre pour ouvrir les fenêtres de dégâts |
| 3 | Sorcière des Bois (30) | **magique** | **Malédiction** — nuke magique qui **one-shot** un Guerrier non préparé + DoT magique empilable entre les nukes | 3 | interrompre le nuke + Rempart/*Cuirasse* sur le DoT + familier Heal + recul/regen |
| 4 | Colosse des Cendres (40) | phys | **Fournaise** — le sol brûle par vagues (dégâts périodiques, évitables en reculant) ; intensité `↑` par phase | 3 | reculer entre les vagues, burst pendant les accalmies |
| 5 | Liche Glaciale (50) | **magique** | **Gel** — la grosse attaque **immobilise** (pas de fuite, pas de regen) puis frappe ; adds squelettes | 3 | **interrompre le gel** est vital ; Ancrage / familier Tank ; nettoyer les squelettes |
| 6 | Tyran des Abysses (60) | phys | **Marée** — marée haute (frappe fort/vite) / basse (fenêtre de dégâts). **Porte globale du Cauchemar** (Q39) | 4 | jouer défensif en marée haute, tout donner en marée basse |
| 7 | Archimage Déchu (70) | **magique** | **Triple sort** — 3 télégraphes d'affilée ; seul le **3ᵉ** est létal, les 2 premiers sont des leurres | 3 | garder l'interruption pour le 3ᵉ ; *Lecture* aide à lire |
| 8 | Béhémoth (80) | phys | **Piétinement** — bête non-humanoïde, **texte narrateur** ; charge à long télégraphe, **interruption seule** (B4, pas de mitigation par recul) ; adds = éclats de pierre/os | 4 | interrompre la charge ; slot défensif si ratée |
| 9 | Spectre Hurlant (90) | **magique** | **Hurlement** — AoE magique dont les dégâts **scalent avec la durée du combat** → pousse au burst ; quasi-létal en fin de combat si non interrompu | 3 | DPS max, *Exécution* / *Marque du chasseur* ; interrompre le hurlement tardif |
| 10 | Dragon de Fer (100) | phys | **Souffle** — cône télégraphé ; perd des plaques par phase (adds = plaques animées) | 4 | reculer hors du cône ou interrompre ; nettoyer les plaques |
| 11 | Œil du Vide (110) | **magique** | **Regard** — pendant le verrouillage, **toute action du joueur est retournée** (tes pouvoirs et coups te frappent) → ne rien faire, ou interrompre **avant** le verrouillage | 3 | passer en manuel, arrêter d'agir pendant le Regard ; interrompre le télégraphe initial |
| 12 | Avatar de la Fin (120) | phys | **La Fin** — rotation des mécaniques des 11 précédents, une par phase | 4 | build polyvalent : au moins 1 `interrupt` + 1 défensif + familier Heal |

- **Cyclage au-delà de la couche 12** : `ZoneConfig.bossTheme(index)` recycle les 12 identités
  (les stats continuent de scaler). La signature suit l'identité.

### 2.6 Big boss / « Gueule » (tous les 100 km — B8)

- Mêmes 12 identités, `bigId` sprite. Multiplicateurs `GameConfig.Enemy.Boss` :
  `bigHpMult 14`, `bigAtkMult 2,5 × bigBossAtkDamp 0,6`, `bigExpMult 40`, `bigGoldMult 30`.
- **+1 phase**, télégraphes plus longs (`telegraphSec × bigTelegraphMult` ~1,3) mais fenêtre
  d'interruption **identique** (1,5 s).
- **Aucune mécanique nouvelle** : c'est « le Gardien à son extrême », guerre d'usure. Le butin
  de set de la couche est requis pour tenir la durée (`equipment-gdd.md`).
- Béhémoth big boss = toujours texte narrateur.

### State Diagram (un combat de boss)

```
[Entrée + dialogue E2] → [Phase 1] ──seuil PV──► [Phase 2] ──► ... ──► [Mort + dialogue]
     │        │                    │                    ▲
     │        │ grosse attaque     │ invoque des adds   │ adds nettoyés → boss ciblable
     │        ▼                    ▼
     │  [Télégraphe] ──1,5 s──► tuile interrupt tapée ? ──oui──► attaque annulée + boss chancelle
     │                                │ non / pas de tuile interrupt
     │                                ▼
     │                    [Héros encaisse 50–80 % PV  (one-shot si sous-niveau)]
     │
     └─ (Cauchemar seulement) minuteur d'enrage → expiration → ATK +25 %/5 s non capé
```

---

## 3. Data Schema

### DataStore (profil)

Le combat de boss ne persiste **rien** de nouveau au-delà de ce qui existe :
- `bigBossesBeaten` (number) — incrémenté à la mort d'une Gueule (débloque `fastMode` à 4).
- `earnedSourceLog["boss:<idx>"]` — 1ᵉʳ kill d'un Gardien (+3 points de compétence,
  `progression-gdd.md`).
- `ZoneService.markBossDefeated` — high-water mark de couche (existant).
- `nightmareBossKills[<couche>]` — compteur pour le déblocage des paliers (`nightmare-gdd.md`).

**Décision N5 (rappel) : aucun état de combat de boss n'est sauvegardé.** Déconnexion en
plein boss → réapparition **juste avant** le boss, tout à plein PV.

### Runtime (`states[player]`)

| Champ | Type | Description |
|---|---|---|
| `bossSignature` | string | id de la signature (ex. `"ralliement"`) |
| `bossPhase` | number | phase courante (1..N) |
| `bossPhaseThresholds` | `{number}` | seuils de PV restants |
| `bigAttackChargeSec` | number | avancement du télégraphe courant |
| `interruptWindow` | `{open, until, tiles}` | partagé avec `abilities-gdd.md` |
| `bossAdds` | `{ {hp, atk, ...} }` | adds vivants (le boss est protégé tant que `#bossAdds > 0`) |
| `enrageAtSec` / `enraged` | number / bool | Cauchemar uniquement |
| `staggerUntil` | number | fenêtre de dégâts bonus après une interruption réussie |

### Schema `GameConfig.BossMechanics` (nouveau bloc)

Par signature : `phases`, `bigAttackEverySec` (par phase), `telegraphSec`,
`bigAttackHpPct` (0,50–0,80), `staggerSec`, `staggerDmgMult`, `addCount` (par phase),
`addHpMul` / `addAtkMul`, + paramètres propres (ex. Carapace : `hardPostureDR`, durée des
postures ; Marée : période ; Hurlement : `dmgPerSecond` de scaling). Tous `[À CALER — G7]`.

---

## 4. Client-Server Split

### Le serveur possède
- Les seuils de phase, les transitions, le pattern par phase.
- Le minuteur du télégraphe, l'ouverture/fermeture de `interruptWindow`, la validation d'un
  tap d'interruption (tuile `interrupt` équipée + dans la fenêtre), le stagger.
- Les dégâts de la grosse attaque (interrompue = 0 + stagger ; non interrompue = 50–80 % PV ×
  pénalité d'écart).
- L'invocation, l'état et la mort des adds ; la ciblabilité du boss.
- Le minuteur d'enrage et le ramp (Cauchemar).
- Le crédit du kill (XP/or/butin de set/points), `markBossDefeated`, `bigBossesBeaten`.

### Le client possède
- La barre de vie segmentée (pastilles), la jauge de grosse attaque, la bordure d'écran de
  télégraphe, le timer d'enrage (Cauchemar), le compteur d'adds, les bulles de dialogue.
- La recontextualisation des tuiles `interrupt`, le tap → `castAbility`.

### Jamais sur le client
- La réussite/l'échec de l'interruption, les dégâts finaux, les seuils de phase réels,
  l'état des adds (le serveur envoie `bossPhase`).

---

## 5. RemoteEvents / Functions

`CombatEvent` (dispatch par `data.type`). Aucun RemoteFunction C→S.

| `data.type` | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|
| `castAbility` | C→S | `{slot}` | réutilisé pour l'interruption : accepté si `interruptWindow.open` **et** le slot porte `interrupt` ; sinon comportement normal (`abilities-gdd.md`) | 6/s |
| `bossPhase` | S→C | `{phase, thresholds, signature, adds, enraged}` | n/a | à chaque transition |
| `bossTelegraph` | S→C | `{charge, telegraphSec, canInterrupt}` | n/a (`canInterrupt` = le joueur a au moins une tuile `interrupt`) | ~10/s pendant un télégraphe |
| `bossDialogue` | S→C | `{lines, speaker, isNarrator}` | n/a | entrée / mort / transition |
| `interruptResult` | S→C | `{success, staggered}` | n/a | 1/télégraphe |

Pas de nouveau remote **C→S** : l'interruption passe par `castAbility` (le serveur sait
qu'une fenêtre est ouverte).

---

## 6. Player-Facing UI

**Maquette #04 (boss). Détail d'instances = dette Track F.**

- **Barre de vie boss** en haut : segmentée par pastilles de phase, nom + niveau + type
  (phys / magique) avec la teinte de danger 6 paliers.
- **Jauge de grosse attaque** (rouge, se remplit) + **bordure d'écran** pulsée pendant le
  télégraphe + **flash de bord**.
- **Tuiles `interrupt`** recontextualisées (« INTERROMPRE » + timer 1,5 s) ; bandeau
  « Pas de pouvoir d'interruption équipé ! » si aucune.
- **Compteur d'adds** (« Adds : 2 » + petites barres) ; icône « boss protégé » tant que
  `#adds > 0`.
- **Timer d'enrage** visible **uniquement en Cauchemar** (compte à rebours + « ENRAGE » à 0).
- **Bulles de dialogue** au-dessus du boss (entrée / mort) ; **bandeau narrateur** en bas pour
  Béhémoth.
- Accessibilité : type de dégâts en toutes lettres, télégraphe = jauge + son (pas que la
  couleur), option « moins de clignotements » atténue la bordure.

---

## 7. Edge Cases & Error States

1. **Aucun pouvoir `interrupt` équipé** — `bossTelegraph.canInterrupt = false`, aucune
   recontextualisation, le héros encaisse 50–80 % PV (B3). Bandeau d'avertissement.
2. **Interruption tapée hors fenêtre** — le pouvoir fait son effet normal + CD ; l'attaque
   part quand même.
3. **Boss tué pendant un télégraphe** — l'attaque est annulée, `resolvePlayerHit` gère le
   on-kill une seule fois (`if enemyHp > 0` garde).
4. **Déconnexion en plein boss** (N5) — aucun état persisté ; réapparition avant le boss,
   tout à plein PV, boss frais.
5. **Adds encore vivants à la mort du boss** — nettoyés immédiatement (pas de combat orphelin).
6. **Grosse attaque + adds simultanés** — le joueur doit interrompre en plein nettoyage
   d'adds ; c'est la tension voulue (pas un bug).
7. **Enrage en Cauchemar + interruption réussie** — l'enrage **continue** (l'interruption ne
   remet pas le minuteur) ; seule la mort du boss l'arrête.
8. **`castAbility` spam pendant un télégraphe** — cap 6/s ; une seule interruption compte
   (la fenêtre se ferme au premier succès).
9. **Fuite tentée contre un boss** — ignorée (`st.isBoss`, `combat-gdd.md` §2.5).
10. **Big boss + Cauchemar palier k** — `bigHpMult 14 × Nightmare.hpMult(k)` et
    `bigAtkMult × Nightmare.atkMult(k)` se composent ; `statHardMax 1e15` cape ;
    l'enrage utilise `enrageSeconds(k)`.
11. **Boss magique + Guerrier 0 RES + zéro kit défensif** — combat perdu par design
    (`/balance-check` vérifie qu'un build *raisonnable* passe : 1 interrupt + 1 défensif +
    familier Heal).
12. **Œil du Vide : `castAbility` pendant le Regard** — les dégâts du pouvoir sont **retournés**
    sur le héros (le serveur applique l'effet à l'envers) ; c'est documenté dans la bulle.
13. **Roster de couche non développé** (`ZoneConfig` vide) — `EnemyService.rollBoss` retombe
    sur `bossTheme(index)` générique (« Gardien du palier N »), signature par défaut
    (Ralliement), le combat ne casse jamais.
14. **Transition de phase par un crit d'overkill** (2 seuils franchis d'un coup) — une seule
    transition appliquée (vers la phase correspondant aux PV restants).

---

## 8. Balancing Parameters

**Valeurs dans `GameConfig.BossMechanics` + `GameConfig.Enemy.Boss` + `GameConfig.Nightmare`.
Tout ce qui touche aux signatures est `[À CALER — G7 /prototype + /balance-check]`.**

| Paramètre | Source | Valeur | Rôle |
|---|---|---|---|
| Phases par Gardien | Q21 | 2–4 (table §2.5) | rythme du combat |
| `interruptWindowSec` | B2 | **1,5 s** | fenêtre d'interruption (+% via *Lecture*) |
| `telegraphSec` | G7 | ~2–3 s | durée du remplissage avant la fenêtre |
| `bigAttackHpPct` | **B3** | **0,50–0,80** | dégâts si non interrompue (× pénalité d'écart) |
| `staggerSec` / `staggerDmgMult` | G7 | ~1,5 s / ~1,5 | récompense d'une interruption réussie |
| `bigAttackEverySec` | G7 | phase 1 ~14 s → phase N ~7 s | fréquence croissante |
| `addCount` | Q23 | 1–3 par phase concernée | protègent le boss |
| Enrage (Cauchemar) | B7 / `Nightmare` | `max(30, 95 − 5k)` s puis **+25 % ATK / 5 s non capé** | plafond du Cauchemar |
| `bigHpMult` / `bigAtkMult` / `bigBossAtkDamp` | `Enemy.Boss` | 14 / 2,5 / 0,6 | Gueule = guerre d'usure |
| `bigTelegraphMult` | B8 / G7 | ~1,3 | télégraphes plus longs, fenêtre inchangée |
| Boss nommé | `Enemy.Boss` | `hpMult 2,5 · atkMult 1,3 · expMult 6 · goldMult 5` | vs `combatBaseForLevel(round(km×3,5))` |

### Formules

```
seuils de phase (N phases) : {100·(N-1)/N %, ..., 100·1/N %}  de PV restants
dégâts grosse attaque non interrompue = playerMaxHp × bigAttackHpPct
                                        × levelGapIn(playerLvl, bossLvl)   -- peut dépasser 100 % → one-shot
interruption réussie : attaque = 0 ; boss subit ×staggerDmgMult pendant staggerSec
enrage(k)  = max(Nightmare.enrageFloorSeconds 30, 95 − 5k)
ATK boss après enrage à t secondes = enemyAtk × (1 + 0,25 × floor((t − enrage(k)) / 5))
```

### Garde-fous D6
- Un Gardien de couche à niveau (joueur non sous-équipé) doit être **tendu mais gagnable**
  sans build parfait ; la grosse attaque non interrompue ne doit pas être *toujours* létale
  à plein PV (fourchette 50–80 %, pas 100 %).
- Les boss magiques 3/5/7/9/11 doivent être **infranchissables sans kit** pour un Guerrier
  0 RES, et **franchissables avec un kit raisonnable** (1 interrupt + 1 défensif + Heal pet) —
  `/balance-check` le vérifie explicitement.
- La signature ne doit jamais créer un DPS check impossible **hors Cauchemar** (l'enrage est
  le seul DPS check dur).

---

## 9. Integration Points

### Dépend de
- **`abilities-gdd.md`** — l'interruption (`castAbility` + `interrupt` tag), les tuiles
  recontextualisées, la fenêtre 1,5 s.
- **`combat-gdd.md`** — la boucle de résolution, `enemyDamageType` (phys/magique),
  `st.isBoss` / `st.enemyIsBigBoss`, la teinte de danger, l'absence de fuite.
- **`progression-gdd.md`** — la **pénalité d'écart de niveau** qui transforme la grosse
  attaque en one-shot pour un sous-niveau.
- **`nightmare-gdd.md`** — l'enrage (Cauchemar uniquement), les multiplicateurs `hpMult` /
  `atkMult` par palier, le compteur de kills de boss pour le déblocage.
- **`subclass-gdd.md`** — Muraille (Gardien) et Résurgence (Sage) comme leviers explicites.
- **`talents-gdd.md`** — *Cuirasse* (RES pour un Guerrier), *Absorption*, *Dernier rempart*,
  *Inébranlable*, *Lecture*.
- **`narrative-gdd.md` / E2** — les 12 identités, les répliques, Béhémoth narrateur.
- **`ZoneConfig.BossThemes`** — noms, sprites, `magic`, `atkSplit`, cyclage.

### Est utilisé par
- **`progression-gdd.md`** — +3 points au 1ᵉʳ kill d'un Gardien, +2 nouvelle couche.
- **`economy-gdd.md`** — l'or du boss (`goldMult 5` / `bigGoldMult 30`), le choix or/XP (Q65).
- **`equipment-gdd.md` / Loot** — table de butin de set de la couche (B6d).
- **`daily-dungeon-gdd.md` / `raid-gdd.md`** — boss exclusifs réutilisent le moteur.
- **`leaderboards-gdd.md`** — palier de Cauchemar atteint (via les kills de boss).
- **Analytics** — lieux de mort (boss), taux d'interruption réussie/ratée par Gardien,
  `wall_hit`.

### Données partagées
- `GameConfig.BossMechanics` (nouveau), `GameConfig.Enemy.Boss`, `GameConfig.Nightmare`.
- `ZoneConfig.BossThemes` / `bossTheme(index)`.

---

## Critères d'acceptation

- [ ] Chaque Gardien a 2 à 4 phases avec pastilles sur la barre de vie et changement de pattern.
- [ ] La grosse attaque se télégraphe (jauge + bordure + son) ; la fenêtre d'interruption dure
      1,5 s ; les tuiles `interrupt` équipées se recontextualisent.
- [ ] Interruption réussie → attaque annulée + boss chancelle ; ratée → 50–80 % PV (one-shot
      si sous-niveau).
- [ ] Zéro tuile `interrupt` → `canInterrupt = false`, aucune recontextualisation, avertissement.
- [ ] Les adds protègent le boss (non ciblable / −90 %) jusqu'à être tués un par un.
- [ ] L'enrage n'apparaît **qu'en Cauchemar** ; à l'expiration, ATK +25 %/5 s non capé.
- [ ] Les 12 signatures se comportent comme décrit (G7, jouables).
- [ ] Big boss = signature amplifiée + 1 phase, aucune mécanique nouvelle.
- [ ] Un Guerrier 0 RES bat les boss magiques avec un kit raisonnable, échoue sans kit
      (`/balance-check`).
- [ ] Déconnexion en plein boss → réapparition avant le boss, tout plein PV (N5).
- [ ] Exploits testés : `castAbility` hors fenêtre, spam pendant un télégraphe, fuite contre
      un boss, dégâts d'interruption forcés côté client.

---

## Questions ouvertes

- [ ] `telegraphSec`, `bigAttackEverySec`, `bigAttackHpPct` exact par signature, `staggerSec` →
      G7 `/prototype` (timing d'interruption ~1,5 s d'abord).
- [ ] Adds : boss **non ciblable** ou **−90 % dégâts subis** ? (effet de design identique) → G7.
- [ ] Œil du Vide « action retournée » : renvoie 100 % ou un % des dégâts du pouvoir ? → G7.
- [ ] Nombre exact de phases pour les Gueules (Gardien + 1, plafonné à 5 ?) → G7.
- [ ] Béhémoth : le télégraphe de charge est-il plus long que la moyenne (compensation de
      « interruption seule ») ? → G7.
