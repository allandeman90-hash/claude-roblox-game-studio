# Pouvoirs actifs (3 slots, auto + reprise en main, interruption) — GDD système

**Version :** 1.0
**Dernière mise à jour :** 2026-09-01
**Auteur :** game-designer / systems-designer
**Statut :** Draft — à relire (/design-review)
**Parent :** `design/gdd/master-gdd.md`
**Modèle chiffré :** `design/economy/D1-stat-growth.md`, `D6-playthrough-balance.md` (les CD /
valeurs ne doivent pas casser les cibles D6)
**Code de référence :** `src/ServerScriptService/CombatServer.server.luau` (boucle de combat,
`resolvePlayerHit`, handler `OnServerEvent` — slot à ajouter), `DamageService.luau`,
`StatsService.luau` ; `src/ReplicatedStorage/GameConfig.luau` (`.Abilities` — nouveau bloc) ;
`src/StarterPlayer/StarterPlayerScripts/CombatClient.client.luau` (barre de tuiles)

---

## 1. Overview & Purpose

**Qu'est-ce que ce système ?** 3 emplacements de pouvoir actif, plus **1 pouvoir signature**
lié à la sous-classe (4ᵉ ; 5ᵉ en double-spec R25). Les pouvoirs se lancent **automatiquement
dès qu'ils sont prêts** (Q17) ; le joueur peut **reprendre la main** à tout moment. Pas de
jauge de ressource — **un temps de recharge seulement** (Q19). Les 3 slots sont **débloqués
par des nœuds de talents** (Q18 : nœud Fureur A → slot 1, Gardien B → slot 2, Tactique C →
slot 3), chacun ouvrant un **choix parmi ~4 pouvoirs** de son rôle.

**Pourquoi il existe ?** C'est **la** couche de décision active du pilier 4 : le combat est
automatique, mais quel pouvoir on lance et quand, et surtout **avoir le bon pouvoir pour
interrompre la grosse attaque d'un boss** (Q20), c'est ce qui distingue un joueur d'un autre.
Les pouvoirs sont aussi le principal levier de survie d'un Guerrier à 0 RES contre les boss
magiques (`boss-mechanics-gdd.md`).

**Où dans la boucle ?**
- **30 s :** les pouvoirs tournent en auto pendant chaque affrontement.
- **5 min :** contre un boss, le joueur reprend la main pour interrompre au bon moment.
- **Session :** au feu de camp, on ajuste les 3 pouvoirs choisis selon la couche / le boss à venir.

---

## 2. Core Mechanics

### 2.1 Slots, déblocage, choix

- **3 slots**, débloqués un par un par les nœuds de talents **A / B / C** (`talents-gdd.md`
  §2.3). Prendre le nœud → le slot s'ouvre + on choisit un pouvoir dans la sous-liste du rôle.
- **Étalement forcé** : les 3 slots exigent 1 point dans chacune des 3 branches → un joueur
  qui étale a ses 3 pouvoirs vers L15.
- **Re-choix** d'un pouvoir de slot : gratuit, **au feu de camp uniquement** (comme un respec
  partiel de talent).
- **Pouvoir signature** : accordé par la sous-classe (R5+), occupe une **4ᵉ tuile** hors des
  3 slots ; ne se re-choisit pas (`subclass-gdd.md` §2.3).

### 2.2 Auto / manuel (Q16 / Q17)

- **Défaut : auto.** Un pouvoir prêt (hors CD, charge disponible) se lance seul, cible
  l'ennemi actif, dès que la boucle serveur le voit prêt.
- **Reprise en main (A4 validé)** : quand le joueur **tape une tuile**, ce pouvoir passe
  **manuel pour le reste de l'affrontement en cours** (le serveur ne le lance plus seul ; le
  joueur décide). Il **redevient auto au combat suivant**.
- **Réglage global (Options)** : `abilitySettings.mode ∈ {"auto", "manual"}`. En `manual`,
  aucun pouvoir ne se lance seul tant que le joueur ne l'a pas tapé au moins une fois dans le
  combat. Le mode par slot peut être surchargé.
- Le pouvoir signature suit le même modèle.

### 2.3 Cadence (pas de ressource — Q19)

- Chaque pouvoir : `cooldown` (8–20 s selon la puissance, A5) + `charges` (défaut **1**).
- **Talent *Réserve*** : +1 charge sur un pouvoir au choix (→ 2).
- **Réduction de CD** : talent *Célérité arcanique*, Écho `echo_celerite`, talent *Surcharge*
  (un crit réduit le CD du prochain pouvoir), keystone *Grand stratège* (les 3 pouvoirs
  partagent un pool). **Plancher dur `minCooldown ≈ 4 s`** — un pouvoir ne descend jamais
  sous 4 s, quelle que soit la pile de réductions.
- **Pas de coût, pas de mana, pas de jauge.** Le seul frein est le CD.
- Certains effets modifient le CD dynamiquement (ex. Décharge sanglante du Berserker : chaque
  kill retire `X s` de son CD — ce n'est **pas** une ressource, juste une réduction de CD).

### 2.4 Dégâts et effets

- Les pouvoirs offensifs scalent sur **`st.playerAtk` effectif** (le type de dégâts du héros —
  physique pour un Guerrier, magique pour un Mage). **Aucun dégât magique séparé** (A3
  validé) : un Guerrier ne « lance » pas de magie, ses pouvoirs sont des coups amplifiés.
- Formule type : `dmg = st.playerAtk × abilityCoef × (1 + talentDmgPct)` — `abilityCoef`
  `[À CALER — G3]` (~1,5 à 4,0 selon le pouvoir), le crit s'applique comme sur une attaque
  normale (`combat-gdd.md` §2.3).
- Les effets défensifs (bouclier, mitigation, soin) sont exprimés en **% de `playerMaxHp`**.
- **AoE** : seuls les pouvoirs marqués `aoe = true` touchent aussi les adds ; les autres sont
  mono-cible sur l'ennemi actif.

### 2.5 Interruption de la grosse attaque de boss (Q20)

- Certains pouvoirs portent `interrupt = true`. **Exactement 3** dans la liste sélectionnable
  (**Frappe sismique**, **Contre**, **Fracas**) + **Muraille** (signature Gardien) — A2 validé.
- Quand un boss télégraphie sa grosse attaque (`boss-mechanics-gdd.md`), **toute tuile équipée
  qui porte `interrupt`** se **recontextualise** visuellement en bouton **INTERROMPRE** pendant
  la fenêtre (**1,5 s**, B2 ; talent *Lecture* l'allonge).
- Taper la tuile recontextualisée pendant la fenêtre → l'attaque est **annulée**, le boss
  **chancelle** (courte fenêtre de dégâts bonus). Le pouvoir part quand même en CD.
- **Aucun pouvoir `interrupt` équipé → impossible d'interrompre → le héros encaisse
  50–80 % de ses PV** (B3 ; létal s'il est déjà entamé, **one-shot** si sous-niveau via la
  pénalité d'écart de `progression-gdd.md`). C'est le prix d'un build tout-offensif.
- Un pouvoir `interrupt` lancé **hors fenêtre** fait juste son effet normal (dégâts / bouclier).

### 2.6 Liste des pouvoirs (proposition — coefs/CD `[À CALER — G3]`)

**Slot 1 — offensif (nœud Fureur A)**

| Pouvoir | Effet | Tags |
|---|---|---|
| Exécution | gros coup unique ; `+X%` si la cible est sous 25 % PV | — |
| Salve | 3 coups rapides répartis sur 1 s | — |
| **Frappe sismique** | coup + petit AoE sur les adds | `interrupt`, `aoe` |
| Marque du chasseur | la cible subit `+X%` de tous les dégâts pendant 6 s | — |

**Slot 2 — défensif (nœud Gardien B)**

| Pouvoir | Effet | Tags |
|---|---|---|
| Rempart | bouclier = `X%` PV max pendant 4 s | — |
| **Contre** | pendant 2 s, renvoie 100 % des dégâts subis | `interrupt` |
| Regain | soin instantané = `X%` PV max | — |
| Ancrage | `−50%` dégâts subis pendant 3 s ; le héros ne peut pas reculer (fuite bloquée) | — |

**Slot 3 — utilité / contrôle (nœud Tactique C)**

| Pouvoir | Effet | Tags |
|---|---|---|
| Cri de guerre | `+X%` cadence (héros **et** familiers) pendant 5 s | — |
| **Fracas** | petit coup, CD court, conçu pour l'interruption | `interrupt` |
| Piège runique | le prochain add invoqué naît à 1 PV | — |
| Souffle vital | déclenche immédiatement le soin du familier Heal + purge un DoT | — |

**Signatures de sous-classe** (détail stats → `subclass-gdd.md` + ce GDD, G3)

| Sous-classe | Pouvoir | Effet | Tags |
|---|---|---|---|
| Berserker | Décharge sanglante | burst physique court ; chaque kill retire `X s` de son CD | — |
| Gardien | Muraille | bouclier massif (`X%` PV, `Y s`) + force les adds à cibler le héros | `interrupt` |
| Destructeur | Détonation arcanique | dégâts de zone ; crit **garanti** sur les cibles < 30 % PV | `aoe` |
| Sage | Résurgence | soin sur la durée + annule le télégraphe d'un add (petite attaque) | — |

### State Diagram (un pouvoir)

```
[Prêt] ──auto (mode auto) OU tap (mode/manuel)──► [Lancé] ──► [Recharge (cooldown, plancher 4 s)]
   ▲                                                                    │
   │                                                                    ▼
   └──────────────── charge dispo ? ────────────────────────── [Prêt] ◄─┘

[Boss télégraphe] → toute tuile `interrupt` équipée → [INTERROMPRE 1,5 s] ── tap ──► attaque annulée + boss chancelle
                                                              │ (aucune tuile interrupt) 
                                                              ▼
                                                   [Héros encaisse 50–80 % PV]
```

---

## 3. Data Schema

### Clés DataStore (profil — `PROFILE_VERSION 2`)

| Clé | Type | Défaut | Description |
|---|---|---|---|
| `abilitySlots` | `{string?, string?, string?}` | `{}` | pouvoir choisi par slot (nil = slot non débloqué), partagé avec `talents-gdd.md` |
| `abilitySettings` | `{mode: string, perSlot: {[number]: string}}` | `{ mode = "auto", perSlot = {} }` | réglage global + surcharge par slot |

Le pouvoir signature n'est **pas** stocké ici : il est dérivé de `subclass` à chaque session.

### Migration v1 → v2

Additif : `migrate()` backfill `abilitySlots = {}`, `abilitySettings = { mode = "auto",
perSlot = {} }`.

### Runtime (`states[player]`)

| Champ | Type | Description |
|---|---|---|
| `abilityCooldowns` | `{[slot]: number}` | temps restant (0 = prêt) |
| `abilityCharges` | `{[slot]: number}` | charges disponibles |
| `abilityManualThisFight` | `{[slot]: true}` | le joueur a repris la main sur ce slot ce combat |
| `interruptWindow` | `{open: bool, until: number, tiles: {slot}}` | fenêtre d'interruption active |
| `signatureSlot` | string? | pouvoir signature actif (dérivé de la sous-classe) |

---

## 4. Client-Server Split

### Le serveur possède
- Les cooldowns, les charges, le plancher de CD, la résolution des dégâts et effets.
- La décision « ce pouvoir se lance en auto maintenant ».
- La fenêtre d'interruption (ouverte par `boss-mechanics-gdd.md`), la validation d'un tap
  d'interruption (bon pouvoir `interrupt` + dans la fenêtre).
- La validation du choix de pouvoir (le nœud de talent correspondant est pris) et du re-choix
  (feu de camp).

### Le client possède
- La barre de 3 (+ 1/2) tuiles : état prêt (bordure jaune + ▶) / recharge (compte à rebours) /
  recontextualisée (« INTERROMPRE » + timer rouge).
- Le tap de reprise en main / d'interruption → `castAbility`.
- Le sous-menu de choix de pouvoir (au feu de camp), l'écran Options (mode auto/manuel).

### Jamais sur le client
- Les nombres de dégâts / la valeur des boucliers / soins (le serveur envoie le résultat).
- La décision « l'interruption a réussi ».
- L'état réel des cooldowns (le client interpole entre deux `abilityUpdate`).

---

## 5. RemoteEvents / Functions

`CombatEvent` (dispatch par `data.type`). Aucun RemoteFunction C→S.

| `data.type` | Sens | Arguments | Validation | Rate limit |
|---|---|---|---|---|
| `castAbility` | C→S | `{slot}` | `slot ∈ {1,2,3,"sig"}` ; slot débloqué ; hors CD **ou** fenêtre d'interruption ouverte pour une tuile `interrupt` ; charge dispo ; combat actif, `not gameOver` | 6/s |
| `setAbilityMode` | C→S | `{mode, slot?}` | `mode ∈ {"auto","manual"}` ; `slot` optionnel (surcharge) | 4/s |
| `chooseAbility` | C→S | `{slot, abilityId}` | slot débloqué (nœud pris) ; `abilityId` dans la sous-liste du slot ; `st.atCampfire` pour un re-choix | 4/s |
| `abilityUpdate` | S→C | `{slots, cooldowns, charges, mode, signature}` | n/a | à chaque changement |
| `interruptWindow` | S→C | `{open, until, tiles}` | n/a (recontextualise les tuiles) | ouverture/fermeture |

### Règles de validation
- `type(data) == "table"` en garde ; `slot` / `mode` / `abilityId` type-checkés.
- `castAbility` en dehors de la fenêtre d'interruption **et** en CD → ignoré silencieusement.
- `castAbility slot="sig"` refusé si pas de sous-classe.
- Rejet silencieux au-delà du rate limit.

Nouveaux caps `GameConfig.Security.remotePerType` : `castAbility = 6`, `setAbilityMode = 4`
(`chooseAbility = 4` déjà ajouté en C2 par `talents-gdd.md`).

---

## 6. Player-Facing UI

**Maquette #03 (barre de 3 compétences) / #04 (boss). Détail d'instances = dette Track F.**

- **Barre centrée en bas :** 3 tuiles + la tuile signature à côté (bordure d'une teinte
  sous-classe). État : prêt (bordure jaune pleine + ▶), recharge (anneau de compte à rebours +
  temps), manuel-ce-combat (petite icône « main »).
- **Recontextualisation :** pendant un télégraphe de boss, chaque tuile `interrupt` équipée
  vire au rouge, affiche « INTERROMPRE » et un timer de 1,5 s ; les autres tuiles se grisent.
  Si **aucune** tuile n'est `interrupt`, un bandeau « Pas de pouvoir d'interruption équipé ! »
  clignote (accessibilité : mot, pas que couleur).
- **Sous-menu de choix (feu de camp) :** 3 lignes de slots, chacune déroule ~4 pouvoirs avec
  leur effet en toutes lettres + le tag « Interruption » bien visible.
- **Options :** interrupteur « Pouvoirs : automatiques / manuels » + par slot.

---

## 7. Edge Cases & Error States

1. **Aucun pouvoir `interrupt` équipé** — pas de recontextualisation ; le héros encaisse
   50–80 % PV (B3). Le bandeau d'avertissement + la teinte de danger sont la seule aide.
2. **`castAbility` sur un slot non débloqué** — refusé (nœud A/B/C pas pris).
3. **`castAbility` pendant `gameOver`** — ignoré.
4. **Double tap (charges)** — 2 charges → 2 lancements consécutifs autorisés ; 1 charge → le
   2ᵉ tap est ignoré (en CD).
5. **`echo_celerite` + *Célérité* + *Grand stratège* empilés** — CD ne descend jamais sous
   `minCooldown` (~4 s).
6. **Pouvoir manuel jamais lancé par le joueur** — le pouvoir ne part pas du combat (assumé —
   c'est le choix du joueur, Q16).
7. **Interruption tapée hors fenêtre** — le pouvoir fait juste son effet normal (dégâts /
   bouclier) et part en CD.
8. **Reprise en main puis mort** — `abilityManualThisFight` est runtime, effacé au
   `restartRun` ; le combat suivant repart en auto.
9. **Re-choix de pouvoir hors feu de camp** — refusé.
10. **Fuite (mob normal) pendant un CD** — le CD continue de tourner pendant la marche ; à la
    prochaine rencontre le pouvoir peut être déjà prêt.
11. **Ancrage actif + tentative de fuite** — la fuite est bloquée pendant les 3 s d'Ancrage
    (le pouvoir l'annonce).
12. **DataStore indisponible** — `abilitySlots` / `abilitySettings` en mémoire ; le re-choix
    n'est pas persisté jusqu'au retour du DataStore.
13. **Sous-classe changée mid-session** — `signatureSlot` bascule ; le CD du signature est
    remis à 0 (prêt).

---

## 8. Balancing Parameters

**Valeurs dans `GameConfig.Abilities` (nouveau bloc). Coefs/CD `[À CALER — G3 + /balance-check]`.**

| Paramètre | Fourchette | Défaut | Rôle |
|---|---|---|---|
| `cooldown` (par pouvoir) | 8–20 s | `[G3]` | seul frein (Q19) |
| `charges` (par pouvoir) | 1–2 | `1` | 2 via talent *Réserve* |
| `minCooldown` | 3–5 s | `4` | plancher dur, empile-proof |
| `interruptWindowSec` | 1,0–2,0 | **`1,5`** (B2) | fenêtre d'interruption ; +% via talent *Lecture* |
| `abilityCoef` (offensif) | 1,5–4,0 × ATK | `[G3]` | dégâts d'un pouvoir |
| `shieldPct` / `healPct` | 15–45 % PV max | `[G3]` | défensifs |
| Dégâts grosse attaque non interrompue | 50–80 % PV à niveau | `[G7]` (B3) | `boss-mechanics-gdd.md` |
| Nombre de pouvoirs `interrupt` | fixe | **3** (+ Muraille) | A2 |

### Formules

```
dmg pouvoir      = st.playerAtk × abilityCoef × (1 + talentEffects.dmgPct)  [crit possible]
bouclier / soin  = playerMaxHp × pct
cooldown effectif = max(minCooldown, base × (1 − cdrPct))
                    cdrPct = talent Célérité + echo_celerite×0,08 + Grand stratège
fenêtre interrupt = interruptWindowSec × (1 + talentEffects.interruptWindowPct)
```

### Garde-fous D6
- Un build 3-slots sans `interrupt` doit **pouvoir** finir les couches à mob normal, mais
  **perdre** contre les boss magiques → `/balance-check` vérifie que le kit d'interruption
  n'est pas optionnel face aux Gardiens 3/5/7/9/11.
- `abilityCoef` × `charges` × réductions de CD ne doit pas faire d'un pouvoir la source
  principale de DPS (le combat reste une auto-attaque avec des pics) — cible ~20-35 % du DPS
  total sur un combat de boss.

---

## 9. Integration Points

### Dépend de
- **`talents-gdd.md`** — nœuds A/B/C débloquent les slots + le choix ; talents *Réserve*,
  *Célérité*, *Surcharge*, *Lecture*, *Grand stratège*, Écho `echo_celerite`.
- **`subclass-gdd.md`** — le pouvoir signature (4ᵉ tuile).
- **`combat-gdd.md`** — `st.playerAtk` effectif, le crit, la boucle serveur, la fuite (Ancrage).
- **`boss-mechanics-gdd.md`** — ouvre/ferme `interruptWindow` ; définit les dégâts de la
  grosse attaque non interrompue.

### Est utilisé par
- **`boss-mechanics-gdd.md`** — l'interruption est **la** mécanique de contre.
- **`pets-gdd.md`** — Cri de guerre (buff pets), Souffle vital (déclenche le soin), Résurgence.
- **`nightmare-gdd.md`** — les CD tournent en temps réel, l'enrage force à burst.
- **Analytics** (master §8) — usage des pouvoirs, taux d'interruption réussie / ratée, mode
  auto vs manuel.

### Données partagées
- `GameConfig.Abilities` (définitions, tags, coefs, CD).
- `Types.luau` — `PlayerData` (`abilitySlots`, `abilitySettings`).

---

## Critères d'acceptation

- [ ] 3 slots débloqués un par un par les nœuds de talents A/B/C ; re-choix au feu de camp seul.
- [ ] En mode auto, un pouvoir prêt se lance seul sur l'ennemi actif.
- [ ] Taper une tuile → ce pouvoir passe manuel pour le reste du combat, redevient auto après.
- [ ] Réglage global auto/manuel dans les Options, surcharge par slot possible.
- [ ] CD jamais sous `minCooldown` (~4 s), même toutes réductions empilées.
- [ ] Pendant un télégraphe de boss, toute tuile `interrupt` équipée se recontextualise 1,5 s ;
      la taper annule l'attaque et fait chanceler le boss.
- [ ] Zéro pouvoir `interrupt` équipé → aucune recontextualisation, le héros encaisse 50–80 % PV.
- [ ] Les pouvoirs d'un Guerrier infligent des dégâts **physiques** (pas de magie séparée).
- [ ] Aucun calcul de dégât / bouclier / soin côté client.
- [ ] Exploits testés : `castAbility` slot verrouillé, hors CD forcé, `slot` invalide, spam,
      interruption hors fenêtre, `chooseAbility` hors feu de camp.

---

## Questions ouvertes

- [ ] `abilityCoef`, `cooldown`, `shieldPct`/`healPct` de chaque pouvoir → G3 + `/balance-check`.
- [ ] Part de DPS visée pour les pouvoirs sur un combat de boss (~20-35 %) → `/balance-check`.
- [ ] Les sous-listes exactes par slot sont-elles figées à 4, ou on garde de la marge pour en
      ajouter en live-ops ? → live-ops-specialist.
- [ ] `Souffle vital` / `Résurgence` : interaction précise avec le cooldown interne du familier
      Heal → `pets-gdd.md` (C5).
