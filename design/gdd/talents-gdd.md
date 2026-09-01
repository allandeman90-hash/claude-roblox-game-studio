# Talents (3 branches, respec gratuit, déblocage des pouvoirs) — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** game-designer / systems-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Modèle chiffré :** `design/economy/D1-stat-growth.md`, `D6-playthrough-balance.md` (les
keystones ne doivent pas casser les cibles D6)
**Code de référence :** `src/ServerScriptService/StatsService.luau` (hooks d'effets),
`src/ServerScriptService/CombatServer.server.luau` (handler à ajouter, `resolvePlayerHit`) ;
`src/ReplicatedStorage/GameConfig.luau` (`.Talents` — nouveau bloc)

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** Un arbre de spécialisation à **3 branches** (Fureur, Gardien,
Tactique). Le joueur gagne **1 point tous les 5 niveaux**, l'investit dans des nœuds à rangs
multiples, et peut **respec gratuitement au feu de camp**. Trois nœuds (un par branche)
**débloquent les 3 slots de pouvoir actif** et ouvrent le choix parmi la liste de
`abilities-gdd.md`. Au Rebirth, le joueur **garde l'arbre** ou l'**échange contre un Écho**
permanent (Q32).

**Pourquoi il existe ?** C'est la « couche de décisions actives » du pilier 4 : le combat est
automatique, mais le build (talents + pouvoirs choisis + familiers) est la vraie expression du
joueur. Les talents sont aussi le **seul vecteur de kit** qui rend les boss magiques
franchissables pour un Guerrier à 0 RES (nœuds défensifs + pouvoirs, cf. `boss-mechanics-gdd.md`).

**Où dans la boucle ?**
- **5 min :** un point tombe tous les 5 niveaux ; on l'investit à la volée ou on attend.
- **Session :** au feu de camp, respec pour adapter le build à la couche / au boss à venir.
- **Méta :** au Rebirth, choix Garder / Échanger ; à **R15**, une 4ᵉ branche « Descente »
  s'ouvre et **persiste à travers les Rebirths**.

---

## 2. Core Mechanics

### 2.1 Points de talent

- `talentPoints = floor(niveau / 5)`. À L100 : **20 points**. À L120 (R1) : 24. Le total monte
  avec le `niveauMax` (`100 + 20×rebirths`) → un joueur plus avancé remplit plus d'arbre.
- Gagné **en même temps** que le point libre de stat (multiples de 5).
- 20 points à L100 pour ~33 nœuds (3 branches × 11) ≈ **60 % d'une répartition** → les choix
  comptent, et le respec gratuit encourage à expérimenter.

### 2.2 Structure des branches (~11 nœuds chacune)

Chaque nœud a un **rang** (1 à 3 selon le nœud) ; investir 1 point = +1 rang. Un nœud tier 2
exige `X` points cumulés dans sa branche ; les keystones exigent `Y` points cumulés. `X`, `Y`
et tous les `%` sont **`[À CALER — systems-designer G4 + /balance-check]`** ; ce GDD fixe la
**forme**, pas les nombres.

#### Branche **Fureur** — burst, critique, exécution

| # | Nœud | Rangs | Effet (à caler) |
|---|---|---|---|
| 1 | Tranchant | 3 | `+% dégâts` (physiques et magiques) |
| 2 | Œil du prédateur | 3 | `+% taux de critique` |
| 3 | Curée | 2 | `+% dégâts` contre un ennemi sous 30 % PV |
| 4 | Élan | 2 | après un kill, `+% cadence` pendant 4 s |
| 5 | Frappe d'ouverture | 2 | le coup gratuit d'ouverture inflige `+%` |
| 6 | Surcharge | 2 | un critique réduit le cooldown du prochain pouvoir de `X s` |
| 7 | **[NŒUD POUVOIR A]** | 1 | débloque le **slot pouvoir 1** + ouvre le choix (liste offensive) |
| 8 | Sang pour sang *(keystone)* | 1 | `+% dégâts`, `−% PV max` |
| 9 | Fureur croissante | 2 | `+% dégâts` par palier de 10 % PV **manquant** au héros |
| 10 | Mise à mort | 2 | un kill rend `% PV max` |
| 11 | Frénésie *(keystone)* | 1 | chaque coup porté `+1 % cadence` (max `X %`), remis à zéro hors combat |

#### Branche **Gardien** — survie, mitigation, attrition (kit anti-boss magique)

| # | Nœud | Rangs | Effet (à caler) |
|---|---|---|---|
| 1 | Cuirasse | 3 | `+%` DEF **et** RES d'équipement (le levier RES d'un Guerrier à 0 RES stat) |
| 2 | Ténacité | 3 | `+% PV max` |
| 3 | Seconde peau | 2 | `+%` regen hors combat |
| 4 | Absorption | 2 | ignore les `X` premiers % d'un coup (au-dessus du plancher de mitigation 0,10) |
| 5 | Riposte | 2 | quand touché, renvoie `% des dégâts subis` |
| 6 | **[NŒUD POUVOIR B]** | 1 | débloque le **slot pouvoir 2** + ouvre le choix (liste défensive) |
| 7 | Inébranlable | 1 | immunise contre le coup d'adieu de fuite ; `−%` dégâts subis des adds de boss |
| 8 | Vétéran | 2 | sous 30 % PV, `−%` dégâts subis |
| 9 | Endurance | 2 | `+%` durée des boucliers de pouvoir |
| 10 | Dernier rempart *(keystone)* | 1 | 1×/combat : survit à un coup létal à 1 PV, puis `+% mitigation` 3 s |
| 11 | Gardien des reliques *(keystone)* | 1 | `+%` effet des familiers Tank et Heal |

#### Branche **Tactique** — pouvoirs, familiers, utilité, interruption

| # | Nœud | Rangs | Effet (à caler) |
|---|---|---|---|
| 1 | Célérité arcanique | 3 | `−%` cooldown de tous les pouvoirs |
| 2 | Meute | 3 | `+%` effet de tous les familiers |
| 3 | Coordination | 2 | lancer un pouvoir → le familier DPS frappe immédiatement |
| 4 | **[NŒUD POUVOIR C]** | 1 | débloque le **slot pouvoir 3** + ouvre le choix (liste utilité/contrôle) |
| 5 | Lecture | 2 | la fenêtre d'interruption de la grosse attaque de boss est `+% plus longue` |
| 6 | Réserve | 1 | `+1 charge` sur un pouvoir au choix |
| 7 | Efficacité | 2 | les pouvoirs en auto se lancent 0,5 s plus tôt |
| 8 | Lien vital | 2 | le familier Heal soigne aussi **hors feu de camp** pendant les combats de boss |
| 9 | Butin tactique | 2 | `+%` chance de drop familier (respecte le `dropRateCap 0,95`) |
| 10 | Grand stratège *(keystone)* | 1 | les 3 pouvoirs partagent un pool : lancer l'un réduit le cooldown des autres de `X %` |
| 11 | Prévoyance *(keystone)* | 1 | entrer en combat avec un pouvoir au choix déjà chargé |

### 2.3 Nœuds pouvoir A / B / C

- Positionnés **tier 1-2** de leur branche. Les prendre :
  1. débloque le slot de pouvoir correspondant (1, 2, 3) ;
  2. ouvre un **choix** parmi la sous-liste de pouvoirs de ce rôle (`abilities-gdd.md` fournit
     la liste complète et les stats).
- **Étalement forcé (T-T1 validé)** : avoir les 3 slots exige 1 point dans **chacune** des 3
  branches. Un joueur qui étale 3 points a ses 3 pouvoirs vers L15.
- Re-choix du pouvoir d'un slot : gratuit, au feu de camp (comme un respec partiel).

### 2.4 Respec

- **Gratuit, instantané, au feu de camp uniquement.** Remet **tous** les points de talent au
  pool (branches + nœuds pouvoir ; les slots redeviennent vides tant qu'on n'a pas repris le
  nœud pouvoir).
- La branche avancée R15 (§2.6) se respec aussi gratuitement mais **ne peut pas être perdue**
  (elle reste débloquée).
- Aucun anti-abus : le respec gratuit est un pilier de confort (Q116).

### 2.5 Rebirth — Garder ou Échanger (Q32)

- À la **confirmation du Rebirth** (`rebirth-gdd.md`), prompt :
  - **Garder** : l'arbre reste tel quel. Les points ne sont pas perdus (le `niveauMax` monte,
    on regagne les points en re-levelant, mais les nœuds déjà pris **restent alloués**).
    ⚠️ précision : « Garder » signifie que l'allocation actuelle est **conservée intacte** ;
    le joueur continue de gagner des points en re-levelant au-delà.
  - **Échanger** : l'arbre est **vidé** (tous les points retournent au pool, à re-dépenser en
    re-levelant) et le joueur gagne un **Écho** permanent.
- **Écho (T-T2 validé)** : 1 passif permanent, **au choix parmi 3** à chaque échange :
  - `echo_puissance` : `+5 % dégâts`
  - `echo_vie` : `+8 % PV max`
  - `echo_celerite` : `−8 % cooldown de tous les pouvoirs`
- **Progression de l'Écho** : `talentEchoes[echoId] = level`. Chaque Rebirth où le joueur
  **ré-échange** ajoute **+1 cran** à l'Écho choisi (cumulable, on peut monter plusieurs Échos
  différents au fil des Rebirths). Effet = `valeur_de_base × level` (ex. `echo_puissance`
  niveau 3 = `+15 % dégâts`).
- Choix par défaut si le prompt n'est pas répondu : **Garder** (T-R5).

### 2.6 Branche avancée « Descente » (R15)

- Se débloque au **Rebirth 15** (`rebirth-gdd.md`). ~8 nœuds orientés end-game (synergies
  Cauchemar, pénalité d'écart de niveau réduite, gros keystone de build).
- **Persiste à travers tous les Rebirths**, quel que soit le choix Garder/Échanger : la
  branche avancée n'est jamais vidée, seulement respécable.
- Ses points viennent du **même pool** `talentPoints` (pas de pool séparé) — au-delà de R15,
  les points supplémentaires du `niveauMax` plus haut couvrent la branche.
- Contenu détaillé : `[À SPÉCIFIER — systems-designer, après C3/D2, avant G4]`. Contrainte :
  ne pas annuler la pénalité d'écart de niveau (au plus la réduire d'un tiers), ne pas casser
  le plafond de Cauchemar (D6).

### State Diagram

```
[niveau %5 == 0] → [+1 talentPoint] → [allocateTalent branch/node] → effets recalc

[feu de camp] → [respecTalents] → pool restauré (branche avancée reste débloquée)

[confirmation Rebirth] → prompt ── Garder ──► arbre conservé, on regagne des points au-delà
                                └─ Échanger ─► arbre vidé + choix d'Écho (+1 cran si déjà pris)
```

---

## 3. Data Schema

### Clés DataStore (profil — schéma `PROFILE_VERSION 2`, cf. `progression-gdd.md`)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `talents` | table | `{ fureur={}, gardien={}, tactique={}, avancee={} }` | `[nodeId] = rang` par branche |
| `abilitySlots` | `{string?, string?, string?}` | `{}` | pouvoir choisi pour chaque slot (nil = slot non débloqué) |
| `talentRebirthChoice` | `"keep"｜"echo"｜nil` | `nil` | dernier choix fait (informatif / analytics) |
| `talentEchoes` | `{[echoId]: number}` | `{}` | `echo_puissance` / `echo_vie` / `echo_celerite` → niveau (cran) |
| `advancedBranchUnlocked` | bool | `false` | posé `true` au Rebirth 15, jamais remis à `false` |

### Migration v1 → v2

Champs additifs : `migrate()` backfill `talents` / `abilitySlots` / `talentEchoes` /
`advancedBranchUnlocked` avec leurs défauts (aucun joueur v1 n'a de talent).

### État runtime (`states[player]`)

| Champ | Type | Description |
|---|---|---|
| `talentPoints` | number | `floor(playerLevel / 5)` moins les points dépensés |
| `talentSpent` | table | miroir de `profile.talents` |
| `talentEffects` | table | résolu à chaque `recalc` : `{ dmgPct, critPct, hpPct, cdrPct, mitigationPct, interruptWindowPct, petEffectPct, … }` |
| `abilitySlots` | table | miroir |

---

## 4. Client-Server Split

### Le serveur possède
- L'arbre canonique (prérequis, rangs max, coûts en points cumulés par branche).
- La validation de chaque `allocateTalent` / `respecTalents` / `chooseAbility`.
- Le calcul de `talentEffects` (consommé par `StatsService.recalc` et les hooks combat :
  cadence, mitigation, cooldowns, fenêtre d'interruption, effets de familier).
- Le prompt Rebirth et l'application de l'Écho.
- Le déblocage de la branche avancée à R15.

### Le client possède
- Le rendu de l'arbre (nœuds, lignes de prérequis, rangs, points restants), la preview d'un
  nœud au survol, le bouton Respec (grisé hors feu de camp), l'écran de choix de pouvoir,
  le prompt Garder/Échanger + le choix d'Écho.

### Jamais sur le client
- L'effet réel d'un talent (le serveur envoie `talentEffects` résolus).
- La décision « ce nœud est débloquable » (le serveur revalide).
- Le contenu de `abilitySlots` avant validation serveur.

---

## 5. RemoteEvents / Functions

`CombatEvent` (dispatch par `data.type`). Aucun RemoteFunction C→S.

| `data.type` | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|
| `allocateTalent` | C→S | `{branch, nodeId}` | `branch ∈ {fureur,gardien,tactique,avancee}` (`avancee` seulement si `advancedBranchUnlocked`) ; `nodeId` connu ; rang < max ; `talentPoints > 0` ; prérequis de branche satisfaits | 8/s |
| `respecTalents` | C→S | `{}` | `st.atCampfire` requis ; branche avancée reste débloquée | 2/s |
| `chooseAbility` | C→S | `{slot, abilityId}` | `slot ∈ {1,2,3}` ; le nœud pouvoir du slot est pris ; `abilityId` appartient à la sous-liste du slot (`abilities-gdd.md`) ; `st.atCampfire` requis pour un **re-choix** | 4/s |
| `setTalentRebirthChoice` | C→S | `{choice, echoId?}` | pendant le prompt de Rebirth uniquement ; `choice ∈ {keep,echo}` ; si `echo` : `echoId ∈ {echo_puissance,echo_vie,echo_celerite}` | 2/s |
| `talentUpdate` | S→C | `{talents, points, slots, effects, echoes}` | n/a | à chaque changement |
| `rebirthTalentPrompt` | S→C | `{currentEchoes}` | n/a (déclenche le prompt) | 1/rebirth |

### Règles de validation
- `type(data) == "table"` en garde ; `branch` / `nodeId` / `slot` / `abilityId` type-checkés.
- `allocateTalent` sur `avancee` ignoré si `advancedBranchUnlocked == false`.
- `respecTalents` hors feu de camp : ignoré.
- `setTalentRebirthChoice` hors fenêtre de prompt : ignoré (le Rebirth applique `keep` par défaut).

Nouveaux caps à ajouter dans `GameConfig.Security.remotePerType` :
`allocateTalent = 8`, `respecTalents = 2`, `chooseAbility = 4`, `setTalentRebirthChoice = 2`.

---

## 6. Player-Facing UI

**Écran Talents plein écran = dette Track F (T-X2). Ce GDD décrit la fonction, pas l'arbre
d'instances.**

- **Accès :** bouton **Talents** dans la colonne gauche du combat + entrée du menu feu de camp.
- **Écran Talents :** 3 colonnes (Fureur / Gardien / Tactique) + une 4ᵉ (Descente) grisée
  jusqu'à R15. Chaque nœud : icône, nom, rang courant / max, tooltip avec l'effet résolu au
  rang suivant. Lignes de prérequis visibles. Compteur « Points : N » en haut. Bouton
  **Respec** en bas (grisé hors feu de camp, avec la mention « gratuit »).
- **Encart pouvoirs :** 3 emplacements ; un emplacement verrouillé montre « débloque via le
  nœud <A/B/C> » ; un emplacement débloqué montre le pouvoir choisi + bouton « changer » (feu
  de camp).
- **Prompt Rebirth :** modale « Garder ton arbre ou l'échanger contre un Écho ? » avec les 3
  Échos (et leur cran actuel si déjà pris), + un rappel de ce que l'arbre vaut actuellement.
- Accessibilité : effets en toutes lettres + chiffres, pas de dépendance à la couleur pour
  distinguer les branches (icône + libellé).

---

## 7. Edge Cases & Error States

1. **`talentPoints == 0`** — `allocateTalent` ignoré ; nœuds `+` grisés client.
2. **Nœud sans prérequis satisfait** (keystone à 2 points de branche) — refusé serveur.
3. **Respec hors feu de camp** — refusé.
4. **`nodeId` / `branch` inconnu** — rejeté, aucun effet.
5. **`chooseAbility` sans le nœud pouvoir** — refusé (slot non débloqué).
6. **Keystone déjà au rang max** — `allocateTalent` ignoré.
7. **`allocateTalent branch="avancee"` avant R15** — ignoré (`advancedBranchUnlocked` false).
8. **Prompt Rebirth non répondu** — le Rebirth applique **Garder** (défaut, T-R5) ; aucun Écho.
9. **Échange répété du même Écho sur plusieurs Rebirths** — `talentEchoes[echoId]` monte de
   +1 par échange ; pas de cap dur (comme les points de compétence, Q30 — le Cauchemar suit).
   `/balance-check` surveille que `echo_celerite` niveau élevé n'annule pas les cooldowns
   (plancher de cooldown à définir en `abilities-gdd.md`).
10. **Branche avancée + Échange** — la branche avancée n'est **pas** vidée (seuls les 3
    branches de base le sont) ; ses points retournent quand même au pool commun, à
    re-dépenser (mais le déblocage reste).
11. **Spam `allocateTalent`** — rejet silencieux au-delà de 8/s ; l'ordre mono-thread du
    handler garantit la cohérence pool/allocation.
12. **DataStore indisponible** (Q109) — talents en mémoire ; bandeau « non sauvegardé » ;
    le Rebirth (et donc le choix d'Écho) est bloqué tant que ça ne persiste pas.
13. **Sous-classe change** (`subclass-gdd.md`) — les talents ne sont **pas** touchés (branche
    ≠ sous-classe) ; seuls les `talentEffects` sont recalculés si un nœud scale sur une stat.

---

## 8. Balancing Parameters

**Toutes les valeurs `%` et tous les seuils de branche sont `[À CALER — G4 + /balance-check]`.**
Ce GDD fixe la structure et les garde-fous.

| Paramètre | Valeur | Rôle / garde-fou |
|---|---|---|
| `talentPoints` | `floor(niveau / 5)` | 20 à L100, monte avec `niveauMax` |
| Nœuds par branche | ~11 (× 3) + ~8 (avancée) | Q116 « 10+ » |
| Rangs par nœud | 1 à 3 | keystones = 1 rang |
| Écho — valeurs de base | `+5 % dmg` / `+8 % PV` / `−8 % CDR` par cran | T-T2 validé ; effet = base × cran |
| Écho — progression | +1 cran par Rebirth **ré-échangé** | pas de cap (Q30) ; `/balance-check` surveille `echo_celerite` |
| Keystone **Frénésie** | `+1 %/coup`, cap `X %`, reset hors combat | cap dur pour ne pas casser D6 (glass cannon runaway) |
| Keystone **Dernier rempart** | 1×/combat | pas de spam de survie |
| Keystone **Grand stratège** | `−X %` cooldown croisé | plancher de cooldown respecté (`abilities-gdd.md`) |
| Branche avancée — réduction d'écart | ≤ 1/3 de la pénalité `levelGap` | ne pas neutraliser le mur (D6 §3) |

### Formule (effets résolus)

```
talentEffects.dmgPct  = Σ (rang × dmgPctParRang) des nœuds offensifs pris
                        + Σ talentEchoes.echo_puissance × 0,05
talentEffects.hpPct   = ... + talentEchoes.echo_vie × 0,08
talentEffects.cdrPct  = ... + talentEchoes.echo_celerite × 0,08
-- appliqués dans StatsService.recalc (dmg, hp) et dans le moteur de pouvoirs (cdr).
```

### Interaction avec le combat (hooks)

- `dmgPct` / `critPct` / `hpPct` : multiplicateurs dans `StatsService.recalc`, **après** gear
  et set, **avant** pets (ou à préciser en G4 — l'ordre est un point de calage).
- `mitigationPct` (Cuirasse, Vétéran, Absorption) : appliqué dans `DamageService` sur le coup
  ennemi→héros, **après** la mitigation d'équipement, **jamais** en dessous d'un plancher
  absolu (à définir, ~0,05 combiné avec `mitigationFloor 0,10`).
- `interruptWindowPct` (Lecture) : allonge la fenêtre de la tuile d'interruption
  (`boss-mechanics-gdd.md`).
- `cdrPct` : réduit les cooldowns dans le moteur de pouvoirs, plancher de cooldown non
  franchissable (`abilities-gdd.md`).

---

## 9. Integration Points

### Dépend de
- **`progression-gdd.md`** — `talentPoints = floor(niveau / 5)`, `niveauMax`, `skillMult`
  (les Échos ne passent PAS par skillMult — ce sont des % plats).
- **`abilities-gdd.md` (C3)** — la liste complète des pouvoirs et les sous-listes par slot ;
  les nœuds A/B/C ne font que débloquer + ouvrir le choix.
- **`rebirth-gdd.md`** — le prompt Garder/Échanger à la confirmation, le déblocage R15.
- **D1 / D6** — garde-fous des keystones.

### Est utilisé par
- **`combat-gdd.md`** — `talentEffects` dans `recalc` et `DamageService`.
- **`boss-mechanics-gdd.md`** — `interruptWindowPct`, `Inébranlable` (adds), le kit qui rend
  les boss magiques franchissables pour un Guerrier 0 RES (**Cuirasse** est le levier RES).
- **`pets-gdd.md`** — `Meute`, `Gardien des reliques`, `Lien vital`, `Coordination`.
- **`subclass-gdd.md`** — indépendant, mais les builds se combinent.
- **Analytics** — répartition des branches, taux de respec, choix Garder/Échanger, Écho pris.

### Données partagées
- `GameConfig.Talents` (nouveau bloc : définition des nœuds, prérequis, valeurs par rang).
- `Types.luau` — `PlayerData` (`talents`, `abilitySlots`, `talentEchoes`, `advancedBranchUnlocked`).

---

## Critères d'acceptation

- [ ] Un point de talent tombe à chaque multiple de 5 niveaux ; le total suit le `niveauMax`.
- [ ] Investir un point augmente le rang du nœud et l'effet résolu envoyé au client.
- [ ] Les 3 slots de pouvoir exigent 1 point dans chacune des 3 branches (étalement forcé).
- [ ] Respec : gratuit, instantané, feu de camp uniquement, restaure tout le pool ; la branche
      avancée reste débloquée.
- [ ] Au Rebirth : prompt Garder/Échanger ; Échanger vide les 3 branches et donne l'Écho
      choisi (+1 cran si déjà pris) ; défaut = Garder.
- [ ] La branche avancée n'apparaît qu'à R15 et n'est jamais reverrouillée.
- [ ] Aucun effet de talent calculé côté client.
- [ ] `/balance-check` : aucun keystone / Écho ne casse les 4 cibles D6 (notamment le mur).
- [ ] Exploits testés : `branch`/`nodeId` invalides, `allocateTalent` sans point, `avancee`
      avant R15, `respecTalents` hors feu de camp, `chooseAbility` sans le nœud, spam.

---

## Questions ouvertes

- [ ] Valeurs `%` de tous les nœuds + seuils de branche + plancher de cooldown → G4 +
      `/balance-check`.
- [ ] Contenu détaillé des ~8 nœuds de la branche avancée « Descente » (R15) → systems-designer
      après C3/D2.
- [ ] Ordre exact d'application des multiplicateurs (talents vs set vs pets) dans `recalc` → G4.
- [ ] `echo_celerite` à cran élevé : plancher de cooldown suffisant ? → `abilities-gdd.md` + K3.
