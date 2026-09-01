# Sous-classes (R5 : Berserker / Gardien / Destructeur / Sage) — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** game-designer / systems-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Modèle chiffré (FIGÉ) :** `design/economy/D1-stat-growth.md` §1 (Table A) et §3 (les 6 tables
à L100), `D6-playthrough-balance.md` §6 (risque faceroll R5)
**Code de référence :** `src/ReplicatedStorage/GameConfig.luau` (`.ClassGrowth` — 6 tables déjà
présentes, `.Combat.critRateDestroyer`), `src/ServerScriptService/StatsService.luau`,
`src/ServerScriptService/CombatServer.server.luau` (handler `chooseSubclass` à ajouter, le
handler `rebirth` existant)

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** Au **Rebirth 5**, le joueur choisit une **sous-classe** liée à
sa voie d'arme :

| Voie | Sous-classes |
|---|---|
| Guerrier (arme physique) | **Berserker** (glass cannon, cadence) · **Gardien** (mur de PV, tueur de boss) |
| Mage (arme magique) | **Destructeur** (crit caster) · **Sage** (sustain, PV élevés) |

Une sous-classe change **le tableau de croissance des stats** (D1), donne **un pouvoir
signature** (4ᵉ pouvoir, hors des 3 slots de talents), et **un look** (teinte + aura FX +
titre — pas de sprite dédié au lancement, T-S2). Re-choix possible à chaque jalon `/5` suivant.
Avant R5 : table neutre `warrior` / `mage`.

**Pourquoi il existe ?** C'est le **premier grand jalon de Rebirth** (R5, semaine 2-4). Il
transforme un « Guerrier générique » en une identité forte et déplace le curseur DPS↔PV sans
qu'aucune sous-classe soit « la meilleure » (bande `PV×DPS` D1 §3 = 0,62–0,87). Il donne une
raison bruyante d'enchaîner les 5 premiers Rebirths.

**Où dans la boucle ?**
- **Méta :** débloqué au 5ᵉ Rebirth ; choisi à un feu de camp.
- **Session :** au feu de camp, si on vient de franchir un jalon `/5`, on peut re-choisir.
- **Combat :** le pouvoir signature tourne dans chaque affrontement.

---

## 2. Core Mechanics

### 2.1 Déblocage et choix

- Condition : `rebirths >= 5`. Le choix se fait **à un feu de camp** (N6), via l'écran « Voie »
  du menu.
- Avant R5 : `classKey` = `warrior` ou `mage` (tables neutres D1 §1). L'écran « Voie » montre
  les 2 cartes de la voie **verrouillées** avec « débloqué au Rebirth 5 » + un compteur.
- Au premier choix : `classKey` bascule vers la sous-classe ; **recalcul rétroactif** de toute
  la courbe auto au niveau courant (`ClassGrowth.statsAtLevel(nouvelleClé, niveau)`).

### 2.2 Effet sur les stats (D1 — FIGÉ)

- Les 6 tables `GameConfig.ClassGrowth` (une ligne = 4 points auto/niveau répartis en %, somme
  1.0, part SPD ≤ 0,22) sont **déjà en config et validées D1**. Ce GDD ne les re-liste pas.
  Résumé d'identité (D1 §1 / §3) :

  | Table | Identité (D1) | Comportement à L100 (D1 §3) |
  |---|---|---|
  | Berserker | POW 42 % / VIT 28 % / SPD 22 % / LUK 8 % | +38 % DPS, −29 % PV vs Guerrier |
  | Gardien | POW 35 % / VIT 55 % / SPD 5 % / LUK 5 % | −38 % DPS, +36 % PV — gagne l'usure, tueur de boss |
  | Destructeur | INT 40 % / VIT 30 % / SPD 8 % / LUK 22 % | glass cannon, crit ~17 % nu (scale gear/talents) |
  | Sage | INT 34 % / VIT 52 % / SPD 7 % / LUK 7 % | tanky mage, sustain, synergie soin |

- **Crit du Destructeur** : `GameConfig.Combat.critRateDestroyer(luk, level) = min(1, LUK/1800
  + 0,0012 × niveau)` (déjà en config). Les autres classes/sous-classes : `critRate(luk) =
  min(1, LUK/2500)`. `StatsService.recalc` choisit la bonne formule selon `classKey`.
- L'allocation (points libres + gagnés) est **inchangée** par un changement de sous-classe —
  seule la part auto est recalculée.

### 2.3 Pouvoir signature (4ᵉ pouvoir, hors slots — T-S1 validé)

- Chaque sous-classe accorde **un pouvoir signature**, toujours actif (auto par défaut +
  reprise en main, comme les 3 autres — `abilities-gdd.md`), qui **n'occupe pas** un des 3
  slots de talents. Le héros a donc **4 pouvoirs** dès qu'il a une sous-classe.
- Propositions (stats + cooldowns détaillés en **C3 / `abilities-gdd.md`**) :

  | Sous-classe | Pouvoir signature | Rôle |
  |---|---|---|
  | Berserker | **Décharge sanglante** — burst physique court ; se recharge en partie à chaque kill | pression DPS, snowball |
  | Gardien | **Muraille** — bouclier = `% PV max` pendant `X s` + force les adds à cibler le héros | anti-boss, anti-adds |
  | Destructeur | **Détonation arcanique** — dégâts de zone ; crit **garanti** sur les cibles < 30 % PV | exécution, clear |
  | Sage | **Résurgence** — soin sur la durée + **annule le télégraphe d'un add** (ou d'une petite attaque) | sustain, kit anti-magie |

- Le pouvoir signature change automatiquement quand on change de sous-classe. Il **ne se
  re-choisit pas** (il est l'identité de la sous-classe).
- **Note kit anti-boss magique (cross-RES) :** un Guerrier a **0 RES stat** (décision proprio).
  Contre les boss magiques (`ZoneConfig.BossThemes` : Sorcière C3, Liche C5, Archimage C7, Œil
  du Vide C11…), la survie vient du kit : **Muraille** (Gardien), les nœuds **Cuirasse** /
  **Absorption** / **Dernier rempart** (`talents-gdd.md`), et les familiers Tank/Heal — jamais
  d'une stat. À refléter dans `boss-mechanics-gdd.md`.

### 2.4 Look (T-S2 validé — lancement)

- Pas de sprite de héros dédié au lancement. Le « look différent » (Q33) =
  - **Teinte** : une couleur d'accent propre à la sous-classe appliquée par-dessus la teinte
    cosmétique choisie par le joueur (Berserker rouge sombre, Gardien acier, Destructeur
    violet, Sage or pâle) `[couleurs exactes → art-director]`.
  - **Aura FX** : un halo / particules procédurales discrètes autour du sprite (pas d'upload —
    Frames/dégradés, cf. master Annexe D).
  - **Titre** : « le/la <Sous-classe> » affiché sous le nom du héros.
- **Post-lancement** : sprites de héros dédiés par sous-classe (4 sprites) → backlog art.

### 2.5 Re-choix aux jalons `/5`

- À chaque Rebirth multiple de 5 **au-delà de R5** (R10, R15, R20, R25, R30…), le joueur peut
  re-choisir **gratuitement** la sous-classe de sa voie, à un feu de camp.
- Hors d'un jalon fraîchement franchi : le choix est verrouillé (`subclassChangesAt` marque
  les jalons déjà « consommés » pour éviter un re-choix permanent).
- Un re-choix recalcule la courbe auto et bascule le pouvoir signature ; l'allocation et les
  talents sont conservés.

### 2.6 Sous-classe par voie d'arme (T-S4 validé)

- La sous-classe est **stockée par voie** : `subclass = { warrior = "berserker"｜nil,
  mage = "sage"｜nil }`.
- Changer de **type** d'arme au feu de camp (Guerrier ↔ Mage, Q6/Q50) bascule sur la
  sous-classe **de l'autre voie** :
  - si elle a déjà été choisie → elle s'applique ;
  - sinon → table neutre `warrior` / `mage` (même si `rebirths >= 5` : le joueur devra
    choisir la sous-classe de la nouvelle voie au prochain jalon `/5`, ou immédiatement si un
    jalon est encore « libre »).
- Le pouvoir signature suit la voie active.

### 2.7 Double spécialisation (R25 — T-S3 validé)

- Au **Rebirth 25** (`rebirth-gdd.md`), le joueur peut activer **une seconde sous-classe** de
  sa voie (`subclass2`). Les deux tables sont alors combinées :
  - **le split % auto = la moyenne des deux splits** (`(splitA[stat] + splitB[stat]) / 2` pour
    chaque stat). Reste normalisé (deux lignes qui somment à 1.0 → moyenne somme à 1.0). SPD
    reste ≤ 0,22 (les deux tables respectent déjà le cap).
- Les **deux pouvoirs signature** sont actifs (le héros a alors 5 pouvoirs).
- Le look combine les deux teintes (dégradé) `[art-director]`.
- Un seul re-choix par jalon `/5` s'applique aux **deux** slots (`subclass` et `subclass2`).

### State Diagram

```
[rebirths < 5] → table neutre (warrior/mage), écran Voie verrouillé

[rebirths == 5, feu de camp] → chooseSubclass → classKey bascule, recalc rétroactif,
                                pouvoir signature accordé, teinte+aura+titre

[jalon /5 franchi, feu de camp] → re-choix gratuit (une fois par jalon)

[changement d'arme au feu de camp] → bascule sur subclass[nouvelle voie] (ou neutre)

[rebirths == 25] → subclass2 activable → split auto = moyenne des deux tables
```

---

## 3. Data Schema

### Clés DataStore (profil — `PROFILE_VERSION 2`)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `subclass` | `{warrior: string?, mage: string?}` | `{}` | sous-classe principale par voie |
| `subclass2` | `{warrior: string?, mage: string?}` | `{}` | seconde sous-classe (R25) |
| `subclassChangesAt` | `{[number]: true}` | `{}` | jalons `/5` déjà utilisés pour un (re-)choix |
| `subclassPowerSeen` | `{[string]: true}` | `{}` | pour ne pas re-notifier l'octroi du pouvoir signature |

Valeurs de sous-classe valides : `"berserker"`, `"guardian"` (voie warrior) ;
`"destroyer"`, `"sage"` (voie mage).

### Migration v1 → v2

Additif : `migrate()` backfill `subclass = {}`, `subclass2 = {}`, `subclassChangesAt = {}`.
Aucun joueur v1 n'a atteint R5 avec sous-classe (le système n'existait pas).

### État runtime (`states[player]`)

| Champ | Type | Description |
|---|---|---|
| `voie` | `"warrior"｜"mage"` | dérivé de l'arme équipée (`EquipmentService`) |
| `classKey` | string | `voie` si pas de sous-classe, sinon `subclass[voie]` |
| `classKey2` | string? | `subclass2[voie]` si R25 |
| `signatureAbilities` | `{string}` | 1 (ou 2 en R25) pouvoirs signature actifs |
| `subclassTint` / `subclassAura` | Color3 / string | pour le client |

`StatsService.recalc` : si `classKey2`, calcule le split moyen avant `statsAtLevel`.

---

## 4. Client-Server Split

### Le serveur possède
- La condition `rebirths >= 5`, la contrainte feu de camp, la logique de jalon `/5`
  (`subclassChangesAt`).
- Le `classKey` effectif, le recalcul rétroactif de la courbe auto, le split moyen R25.
- L'octroi / la bascule des pouvoirs signature.
- La cohérence sous-classe ↔ voie d'arme sur un changement d'arme.

### Le client possède
- L'écran « Voie » (2 ou 4 cartes, deltas de stat / DPS / PV vs table actuelle, aperçu du
  pouvoir signature, aperçu de la teinte + aura).
- L'application visuelle de la teinte / aura / titre (envoyées par le serveur).

### Jamais sur le client
- Le `classKey` effectif ni les stats dérivées (serveur).
- La décision « ce jalon `/5` est encore disponible ».
- Le pouvoir signature actif.

---

## 5. RemoteEvents / Functions

`CombatEvent` (dispatch par `data.type`). Aucun RemoteFunction C→S.

| `data.type` | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|
| `chooseSubclass` | C→S | `{subclassId, slot?}` | `subclassId` valide **pour la voie de l'arme équipée** ; `rebirths >= 5` ; `st.atCampfire` ; premier choix **ou** jalon `/5` non consommé ; `slot == 2` seulement si `rebirths >= 25` | 1/s |
| `subclassUpdate` | S→C | `{voie, subclass, subclass2, changeAvailable, tint, aura, title, signatures}` | n/a | à chaque changement |
| `subclassUnlockToast` | S→C | `{milestone, subclassId}` | n/a (« Rebirth 5 — choisis ta voie au feu de camp ») | 1/jalon |

### Règles de validation
- `type(data) == "table"` ; `subclassId` ∈ liste ; correspondance voie stricte
  (`berserker`/`guardian` ⇔ arme physique ; `destroyer`/`sage` ⇔ arme magique).
- `chooseSubclass` refusé si : `rebirths < 5`, pas au feu de camp, jalon déjà consommé,
  `slot == 2` sans R25, `subclassId` de la mauvaise voie.
- DataStore indisponible → refusé (comme le Rebirth, Q109).

Cap à ajouter dans `GameConfig.Security.remotePerType` : `chooseSubclass = 1`.

---

## 6. Player-Facing UI

**Écran « Voie » dans le menu du feu de camp — encart = dette Track F (T-X2).**

- **Avant R5 :** 2 cartes verrouillées de la voie courante, cadenas + « débloqué au Rebirth 5 »
  + « Rebirth actuel : n / 5 ».
- **À R5 et aux jalons `/5` :** 2 cartes (4 en R25) : nom, une phrase d'identité, **deltas**
  chiffrés vs la table active (ATK, PV, cadence, crit), le **pouvoir signature** (nom + une
  ligne), un aperçu de la **teinte + aura**. Bouton « Choisir » (confirmation).
- **Hors jalon :** cartes affichées mais « Choisir » grisé (« re-choix au prochain Rebirth
  multiple de 5 »).
- **Sous le héros en combat :** titre « le/la <Sous-classe> ».
- Accessibilité : deltas chiffrés, identité en toutes lettres, pas de dépendance couleur.

---

## 7. Edge Cases & Error States

1. **Choix demandé à R4** — refusé ; l'écran reste verrouillé.
2. **Re-choix entre deux jalons `/5`** — bouton grisé ; `chooseSubclass` ignoré serveur.
3. **`subclassId` de la mauvaise voie** (`destroyer` avec une épée) — rejeté.
4. **Changement d'arme mid-run** — interdit hors feu de camp (master Annexe B #10) ; au feu de
   camp, bascule sur `subclass[nouvelle voie]` ou table neutre.
5. **Voie sans sous-classe choisie alors que `rebirths >= 5`** — table neutre appliquée ; un
   jalon `/5` libre permet de choisir tout de suite, sinon au prochain.
6. **R25 avec une seule sous-classe choisie** — `subclass2` reste nil ; le split n'est pas
   moyenné (comportement identique à avant R25) tant que le 2ᵉ slot n'est pas rempli.
7. **`chooseSubclass` pendant un combat** — `st.atCampfire` nil → refusé (N6).
8. **DataStore indisponible** — choix bloqué, bandeau « non sauvegardé ».
9. **Destructeur avec LUK très haut** — `critRateDestroyer` capé à 1,0 (comme `critRate`,
   master Annexe B #8) ; le `critMultiplier` reste ×2.
10. **Double-spec R25 : deux tables qui poussent SPD** (Berserker + une autre) — la moyenne
    des splits reste ≤ 0,22 car chaque table respecte déjà le cap ; `statsAtLevel` re-clampe
    de toute façon à `spdMax`.
11. **Recalcul rétroactif sur un héros L120** — `statsAtLevel(nouvelleClé, 120)` est pur et
    déterministe ; aucun état intermédiaire à migrer.
12. **Migration v1 → v2** — `subclass = {}` ; le joueur repart avec la table neutre de sa voie.

---

## 8. Balancing Parameters

**Les 6 tables `ClassGrowth` sont FIGÉES par D1. Ce GDD n'introduit aucune valeur de stat.**

| Paramètre | Source | Valeur | Rôle |
|---|---|---|---|
| Jalon de déblocage | master §5.2 / Q34 | Rebirth **5** | 1ᵉʳ grand jalon `/5` |
| Re-choix | master §5.2 | jalons `/5` (R10, R15…), gratuit | flexibilité de build |
| `ClassGrowth.berserker/guardian/destroyer/sage` | D1 §1 | figées (SPD ≤ 0,22) | bande PV×DPS 0,62–0,87 |
| `Combat.critRateDestroyer(luk, lvl)` | D1 §0 | `min(1, LUK/1800 + 0,0012·lvl)` | crit dédié Destructeur |
| Split R25 | **T-S3 validé** | moyenne des deux splits | builds hybrides sans extrême |
| Pouvoirs signature | `abilities-gdd.md` (C3) | `[À CALER]` | cooldowns/valeurs respectent le plancher de cooldown |

### Risque faceroll post-R5 (D6 §6 — rappel, géré par `rebirth-gdd.md`)

`skillMult(5) = ×1,70` sur les points investis → un joueur R5 re-levelé L100 a ~1,67× les
stats d'un R0. **Bornage** : le checkpoint post-rebirth `≤ bestKm/2` (Q36) fait sauter les
km triviaux → faceroll effectif ~10-15 min. Valve de sécurité (scinder auto/earned mult)
documentée dans `rebirth-gdd.md`, à activer seulement si K3 le montre.

### Formule (split combiné R25)

```
split[stat] = classKey2 and ((ClassGrowth[classKey][stat] + ClassGrowth[classKey2][stat]) / 2)
              or ClassGrowth[classKey][stat]
autoStat(stat, L) = startingStats[stat] + split[stat] × (4 × (L − 1))   (SPD clampé spdMax)
```

---

## 9. Integration Points

### Dépend de
- **`rebirth-gdd.md`** — le compteur de Rebirths, les jalons R5/R10/R15/R25, le
  `subclassChangesAt`, le bornage faceroll.
- **`progression-gdd.md`** — `classKey` pilote `ClassGrowth.statsAtLevel` ; l'allocation
  (libre + gagnée) est indépendante.
- **`abilities-gdd.md` (C3)** — les 4 pouvoirs signature (stats, cooldowns, comportement).
- **`equipment-gdd.md`** — la voie de l'arme équipée détermine la voie de sous-classe active.
- **D1** — les 6 tables.

### Est utilisé par
- **`combat-gdd.md`** — `StatsService.recalc` lit `classKey` (+ `classKey2` en R25) et la
  formule de crit ; les pouvoirs signature entrent dans la résolution.
- **`boss-mechanics-gdd.md`** — **Muraille** (Gardien) et **Résurgence** (Sage) sont des
  leviers explicites pour franchir les boss magiques quand le Guerrier a 0 RES.
- **`talents-gdd.md`** — builds combinés (indépendants mais synergiques).
- **Analytics** — répartition des sous-classes, taux de re-choix, double-spec R25.

### Données partagées
- `GameConfig.ClassGrowth` (6 tables + `statsAtLevel`), `GameConfig.Combat.critRateDestroyer`.
- `Types.luau` — `PlayerData` (`subclass`, `subclass2`, `subclassChangesAt`).

---

## Critères d'acceptation

- [ ] Avant R5 : table neutre, écran Voie verrouillé avec compteur.
- [ ] À R5, au feu de camp : le choix bascule `classKey`, recalcule toute la courbe auto,
      accorde le pouvoir signature, applique teinte + aura + titre.
- [ ] Re-choix possible uniquement à un jalon `/5` fraîchement franchi, gratuit.
- [ ] La sous-classe est stockée par voie ; changer d'arme bascule proprement (ou table neutre).
- [ ] R25 : `subclass2` combine les deux tables par **moyenne des splits** ; 2 pouvoirs
      signature actifs.
- [ ] Crit du Destructeur utilise `critRateDestroyer`, capé à 1,0.
- [ ] `chooseSubclass` refusé : `rebirths < 5`, hors feu de camp, hors jalon, mauvaise voie,
      slot 2 sans R25, DataStore down.
- [ ] Aucune stat dérivée ni `classKey` calculé côté client.
- [ ] `/balance-check` : aucune des 4 sous-classes (ni la double-spec R25) ne sort de la bande
      PV×DPS 0,62–0,87.

---

## Questions ouvertes

- [ ] Stats + cooldowns des 4 pouvoirs signature → `abilities-gdd.md` (C3).
- [ ] Couleurs de teinte + style d'aura exact par sous-classe → art-director / technical-artist.
- [ ] Sprites de héros dédiés par sous-classe → backlog art post-lancement (T-S2).
- [ ] R25 : un re-choix modifie-t-il les **deux** slots d'un coup, ou un à la fois par jalon ?
      (proposé : les deux d'un coup) → à confirmer au moment de G5.
