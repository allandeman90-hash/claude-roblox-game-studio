# FTUE (5 coach-marks, cadeau de fin = 1er familier) — GDD système

**Version :** 1.0  
**Dernière mise à jour :** 2026-09-02  
**Auteur :** ux-designer  
**Statut :** Prêt pour implémentation  
**Parent :** `design/gdd/master-gdd.md` (§1, §3, §5 jalons, §9)  
**Références :** `design/gdd/core-gameplay-gdd.md`, `design/gdd/campfire-gdd.md`,
`design/gdd/pets-gdd.md` §2.1, `design/gdd/talents-gdd.md` §2 (1er point de talent),
`design/gdd/abilities-gdd.md` §2.1 (déblocage des slots), `design/gdd/ui-ux-gdd.md`
(langage visuel des coach-marks, ZIndex, accessibilité)

---

## 1. Overview & Purpose

Le **FTUE** (First Time User Experience) est la couche d'apprentissage des 30 premières minutes.
Elle enseigne les 5 mécaniques fondamentales (marche, combat auto, butin, pouvoir actif, feu de
camp) via **5 coach-marks** contextuels, puis remet un **cadeau de fin : le 1er familier gratuit**
(`pets-gdd.md` §2.1).

**Rôle clé :** convertir un nouveau joueur en joueur qui comprend la boucle 30 secondes et revient
le lendemain. Ce n'est **pas** un système de jeu — c'est une couche pédagogique posée par-dessus
des systèmes qui, eux, fonctionnent identiquement avec ou sans FTUE actif.

**Principe non négociable (contrainte du mandat) :** le FTUE **n'est jamais un mur**. Le joueur
peut marcher, combattre, looter, mourir et progresser sans jamais interagir avec un coach-mark. Un
coach-mark informe ; il ne bloque rien.

**Où dans la boucle (`master-gdd.md` §3) :** le FTUE couvre le tout début de la boucle 30 secondes
et de la boucle 5 minutes — jusqu'au premier feu de camp (~km 5). Après ça, le joueur est en jeu
normal ; le 1er boss (Roi Gobelin, km 10) n'a **aucun** coach-mark dédié.

**Cibles temporelles (`master-gdd.md` §5, tableau jalons) :**

| Jalon | Cible session 1 | Temps joué |
|---|---|---|
| Tuto fini + 1ᵉʳ familier | 1ʳᵉ session | **~12 min** (0,2 h) |
| 1ᵉʳ boss battu (Roi Gobelin, km 10) | 1ʳᵉ session | **~30 min** (0,5 h) |

Ces deux chiffres sont les métriques de référence : si le FTUE prend plus de ~12 min ou empêche
d'atteindre le 1ᵉʳ boss dans les 30 min, quelque chose bloque et doit être corrigé (voir §9,
funnel).

---

## 2. Core Mechanics

### 2.1 Les 5 coach-marks

Chaque coach-mark est un **événement**, pas un timer : il se déclenche à la première occurrence
de la situation qu'il explique, jamais à l'avance ("show, don't tell", `.claude` UX standards).
Un seul coach-mark visible à la fois (voir `ui-ux-gdd.md` §2.2, `ModalStack`).

| # | ID | Déclencheur | Explique | Récompense immédiate |
|---|---|---|---|---|
| 1 | `move` | Spawn initial, avant tout déplacement | Tenir ◀ / ▶ pour marcher | — |
| 2 | `combat` | 1ʳᵉ collision héros/monstre | Le combat démarre seul ; le héros frappe en premier | — |
| 3 | `loot` | 1ᵉʳ kill | Ramassage auto ; rareté annoncée en texte flottant coloré | Le 1ᵉʳ objet lui-même |
| 4 | `power` | 1ᵉʳ point de talent disponible (niveau 5, `talents-gdd.md` §2) — **pas un km fixe** | 1ᵉʳ slot de pouvoir actif débloqué et son icône/cooldown (`abilities-gdd.md` §2.1) | Le pouvoir devient utilisable |
| 5 | `campfire` | Entrée dans la zone du 1ᵉʳ feu de camp (~km 5, `campfire-gdd.md` §2.1) | Soins, coffre horaire, menu du hub | **Cadeau de fin : 1ᵉʳ familier** |

**Pourquoi `power` n'est pas positionné par distance :** le 1ᵉʳ point de talent tombe au niveau 5
(`talents-gdd.md` §2), pas à un km fixe — le rythme de montée en niveau dépend des kills réels du
joueur. Le coach-mark `power` **peut donc apparaître avant ou après** le coach-mark `campfire`
selon le joueur. C'est voulu (contextuel, pas upfront) : voir §7 edge case 3 pour l'ordre non
garanti.

### 2.2 Skip pour joueurs de retour

- Si `profile.ftue.completed == true` au spawn : **aucun coach-mark ne s'affiche**, jamais, y
  compris sur un nouveau serveur ou un nouvel appareil (source de vérité = profil serveur, pas le
  client — voir §7 edge case 8).
- Un joueur avec un profil existant mais `ftue.completed == false` (parti en cours de route)
  **reprend exactement** au `currentStep` sauvegardé — pas de redémarrage (§7 edge case 1).

### 2.3 Structure temporelle de la 1ʳᵉ session

Standards UX du studio (`ux-designer` — 5 premières secondes / 1ʳᵉ minute / 1ʳᵉ session) appliqués
à ce jeu spécifique :

- **0–5 s :** après le premier (et unique) écran de chargement (< 3 s), le joueur voit le héros et
  le monde. Aucun menu, aucun texte de lore bloquant avant le gameplay.
- **1ʳᵉ minute :** le joueur a tenu ◀/▶ (coach-mark `move`), rencontré un monstre, vu le combat
  auto démarrer (coach-mark `combat`). C'est un choix actif minimal (où marcher) suivi d'un
  résultat visible.
- **~2–5 min :** premier kill, premier drop, premier texte de rareté (coach-mark `loot`) — la
  "dopamine du drop" (pilier créatif 3 du `master-gdd.md`) arrive tôt, pas en fin de tuto.
- **~5–12 min :** progression jusqu'au niveau 5 (coach-mark `power`, ordre variable) et jusqu'au
  1ᵉʳ feu de camp km 5 (coach-mark `campfire` + cadeau familier). **FTUE terminé ici.**
- **~12–30 min :** jeu libre, aucun coach-mark, jusqu'au 1ᵉʳ boss (km 10).

### 2.4 Ce que le FTUE ne fait PAS

- Ne bloque **aucune** entrée (déplacement, combat, menus) pendant qu'un coach-mark est affiché —
  c'est un overlay non-modal, pas une pause.
- Ne force **aucun** achat, aucune fenêtre de boutique. Les prompts de monétisation sont
  **suspendus** tant que `ftue.completed == false` (config §8 ;
  décision finale déléguée à `monetization-lead`, pas prise ici).
- Ne réapparaît jamais pour un joueur qui l'a déjà terminé, même après un Rebirth ou un reset de
  progression normal (le FTUE ne suit pas le cycle de Rebirth — c'est un flag de compte, pas de
  run).

---

## 3. Data Schema

```lua
-- PlayerProfile.ftue (persisté, ProfileStore)
export type FtueState = {
    version: number,           -- schéma FTUE, actuellement 1. Permet d'ajouter un 6e coach-mark
                                -- plus tard sans rejouer les 5 premiers (voir §7 edge case 6)
    completed: boolean,        -- true dès que "campfire" est vu ET le cadeau remis
    currentStep: number,       -- 0 = jamais commencé ; 1-5 = index du dernier coach-mark VU
    stepsSeen: {[string]: boolean}, -- clé = id ("move"|"combat"|"loot"|"power"|"campfire")
    giftClaimed: boolean,      -- 1er familier remis (idempotence, voir §7 edge case 7)
    startedAt: number,         -- os.time() au tout premier spawn
    completedAt: number?,      -- os.time() quand completed passe à true ; nil sinon
}
```

**Contraintes (validées serveur) :**
- `currentStep` ne peut qu'augmenter, jamais reculer (protège contre un client qui rejoue un ack).
- `giftClaimed` ne peut passer à `true` qu'une seule fois par profil, quel que soit le nombre
  d'acks reçus pour `campfire` (idempotence stricte).
- `stepsSeen` est purement informatif pour l'UI/analytics ; `currentStep` est la source de vérité
  pour "où en est le joueur".

---

## 4. Client-Server Split

**Serveur (autoritaire) :**
- Détermine `currentStep` / `completed` — jamais fixé par le client.
- Détecte les déclencheurs réels (1ʳᵉ collision combat, 1ᵉʳ kill, niveau 5 atteint, entrée zone
  feu de camp) puisque ce sont déjà des événements serveur-authoritatifs des autres systèmes
  (`CombatServer`, `progression-gdd.md`, `campfire-gdd.md`).
- Accorde le familier-cadeau (mutation d'inventaire réelle, via `InventoryService`/`PetService` —
  jamais initiée par le client).
- Persiste `ftue` au profil, suspend les prompts de monétisation tant que non complété.

**Client (présentation) :**
- Affiche le coach-mark correspondant quand le serveur notifie l'événement.
- Gère l'affichage (position à l'écran, ne recouvre jamais le coin HUD réservé —
  `ui-ux-gdd.md` §2.2), le timer d'auto-dismiss, le bouton "Ignorer".
- N'estime jamais localement si un step est "logiquement" atteint (ex. ne pas afficher `power`
  juste parce que le client voit un niveau 5 affiché — attend la confirmation serveur).

---

## 5. RemoteEvents / Functions

Canal C→S / S→C dédié `Ftue` dans `Remotes.lua` :

- `Ftue_State` — **S→C**, envoyé une fois au spawn : `{ftue: FtueState}`. Source de vérité pour
  l'UI cliente (reprise, skip si `completed`).
- `Ftue_StepReady` — **S→C**, envoyé quand le serveur détecte le déclencheur d'un step :
  `{stepId: string}`. Le client affiche le coach-mark correspondant.
- `Ftue_AckStep` — **C→S**, envoyé quand le joueur ferme/ignore un coach-mark ou que le timer
  d'auto-dismiss expire côté client : `{stepId: string}`. Le serveur revalide (le step doit
  correspondre au `currentStep + 1` attendu) avant de faire avancer `currentStep`.
- `Ftue_GiftGranted` — **S→C**, envoyé une seule fois quand le cadeau (1ᵉʳ familier) est
  effectivement en inventaire : `{petInstance: ItemInstance}` (forme définie par `pets-gdd.md`).

**Validation sur chaque handler C→S :**
- `Ftue_AckStep.stepId` doit être une chaîne parmi les 5 IDs connus, et doit correspondre au step
  actuellement attendu (`currentStep + 1`) — un ack pour un step déjà vu ou hors séquence est un
  no-op silencieux (`ok=true`), jamais une erreur exposée au client.

**Rate-limiting :** `Ftue_AckStep` — 2/s (largement suffisant, 5 acks max par joueur au total).

---

## 6. Player-Facing UI

Le langage visuel complet (couleurs, ZIndex, tailles tactiles) est défini dans
`ui-ux-gdd.md` — cette section couvre uniquement l'anatomie et le placement spécifiques au
coach-mark.

### 6.1 Anatomie du coach-mark

```
┌─────────────────────────────────────┐
│ [Coins: 0]                    [⚙]   │  ← coin haut-gauche RÉSERVÉ (menu/chat Roblox)
│                                     │     jamais recouvert, même par un coach-mark
│        ┌───────────────────┐       │
│        │  Tenez ◀ ou ▶     │       │  ← bulle ancrée près du contrôle concerné
│        │  pour avancer      │       │     (jamais au centre écran, sauf `loot`/`campfire`
│        │  [ Compris ]       │       │     qui n'ont pas de contrôle unique à pointer)
│        └─────────┬─────────┘       │
│                   ▼                │  ← flèche pointant l'élément réel du HUD
│         [GAME WORLD — visible]     │
│                                     │
├─────────────────────────────────────┤
│ [◀ tenir]      [combat auto]  [▶]   │  ← contrôles jamais masqués par la bulle
└─────────────────────────────────────┘
```

- **Non-modal :** le monde continue de tourner derrière ; le joueur peut agir pendant que la bulle
  est affichée.
- **Un CTA unique :** bouton "Compris" (≥ 44×44 px, `ui-ux-gdd.md` §8). Pas de bouton
  secondaire — pas de choix à faire sur un coach-mark.
- **Auto-dismiss :** disparaît seul après `coachMarkAutoDismissSeconds` (§8) si ignoré, comptabilisé
  côté client comme un ack implicite.
- **ZIndex :** couche `FTUE_OVERLAY` — au-dessus de tout sauf les bannières système critiques
  (DataStore indisponible), voir `ui-ux-gdd.md` §2.2 pour la table complète.

### 6.2 Cadeau de fin (step `campfire`)

- Petite fenêtre non-bloquante (pas un modal plein écran) : icône du familier + nom + rareté +
  texte "Votre premier familier !" + bouton "Voir mes familiers" (ouvre l'onglet Familiers du feu
  de camp) et bouton "Continuer" (ferme, comportement par défaut si ignoré).
- **Décidé (2026-09-02) :** le familier-cadeau est **fixe** (Option A retenue — meilleure
  pédagogie pour v0.1) : tous les joueurs reçoivent la **même espèce**, rareté Commune garantie.
  Espèce exacte parmi le catalogue Couche 1 (`pets-gdd.md` §2.2, ex. Rat) — à assigner par
  `game-designer` dans `PetsConfig`, pas de rôle imposé (le joueur choisit DPS/Tank/Heal
  normalement au feu de camp). Réviser ce choix (fixe → aléatoire) est explicitement hors scope
  v0.1 ; si rouvert plus tard, ce sera un item de live-ops, pas un changement FTUE.

---

## 7. Edge Cases & Error States

1. **Déconnexion en plein FTUE :** au retour, `Ftue_State` renvoie le `currentStep` sauvegardé ;
   les coach-marks déjà vus ne réapparaissent jamais. Aucun redémarrage du flow.
2. **Le joueur tue le 1ᵉʳ monstre avant que le coach-mark `combat` n'ait fini de s'afficher :**
   jamais bloquant — `loot` peut se déclencher immédiatement après `combat`, y compris en
   chevauchement rapide ; le `ModalStack` (`ui-ux-gdd.md` §2.2) les met en file, jamais en
   superposition.
3. **Ordre `power` / `campfire` non garanti :** un joueur qui atteint le niveau 5 avant km 5 voit
   `power` avant `campfire` ; l'inverse est possible aussi. Les deux ordres sont valides — le
   `currentStep` avance simplement dans l'ordre réel des déclencheurs serveur, pas un ordre figé
   de 1 à 5.
4. **Mort du héros avant le 1ᵉʳ feu de camp (donc avant la fin du FTUE) :** gérée comme une mort
   normale (`master-gdd.md` §5.6 — retour au dernier checkpoint, ici le début). Le FTUE **n'est
   pas remis à zéro** ; `currentStep`/`stepsSeen` persistent tels quels.
5. **Lag réseau empêchant l'ack d'un step d'arriver au serveur :** le client retente l'envoi de
   `Ftue_AckStep` ; le serveur est idempotent (§5) — un ack en double pour un step déjà acquitté
   ne fait rien.
6. **Un 6ᵉ coach-mark est ajouté après le lancement (bump de `ftue.version`) :** seuls les joueurs
   avec `completed == true` et un `version` inférieur à la nouvelle valeur voient **uniquement**
   le nouveau step, jamais le flow complet à nouveau.
7. **DataStore indisponible au moment de la remise du cadeau :** le familier est accordé en
   mémoire immédiatement (jouable tout de suite, cohérent avec `InventoryService`) ; `giftClaimed` s'écrit au flush suivant.
8. **Nouveau serveur / nouvel appareil :** `Ftue_State` envoyé au spawn est **toujours** la source
   de vérité serveur ; un état FTUE local (client) obsolète ou incohérent est écrasé sans
   négociation.

---

## 8. Balancing Parameters

`GameConfig.Ftue` :

```lua
coachMarkAutoDismissSeconds = 8
coachMarkMinDisplaySeconds = 2
firstCampfireKm = 5
giftRarity = "common"
giftSpeciesFixed = true
suppressMonetizationPromptsUntilComplete = true
targetTutorialCompleteMinutes = 12
targetFirstBossMinutes = 30
ftueSchemaVersion = 1
```

---

## 9. Integration Points

**Dépend de :**
- `core-gameplay-gdd.md` — déclencheurs `move`/`combat`
- `combat-gdd.md` / `CombatServer` — déclencheur `loot`
- `talents-gdd.md` §2 / `abilities-gdd.md` §2.1 — déclencheur `power`
- `campfire-gdd.md` §2.1 — déclencheur `campfire`
- `pets-gdd.md` §2.1 — cadeau familier
- `ui-ux-gdd.md` — langage visuel, ZIndex
- `PlayerDataService.luau` — persistance

### Critères d'acceptation

- [ ] Le joueur voit du gameplay réel en < 5 secondes
- [ ] Les 5 coach-marks s'affichent sans superposition
- [ ] Chaque coach-mark peut être ignoré sans bloquer gameplay
- [ ] Le cadeau (fixe) est remis automatiquement, jamais deux fois
- [ ] Joueur déconnecté reprend au `currentStep`
- [ ] Joueur avec `ftue.completed = true` ne revoit jamais le flow
- [ ] Funnel FTUE instrumenté événement par événement
