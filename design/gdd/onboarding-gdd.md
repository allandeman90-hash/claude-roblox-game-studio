# FTUE (tutoriel court, cadeau de fin = épée + familier) — GDD système

**Version :** 2.0  
**Dernière mise à jour :** 2026-09-03  
**Auteur :** ux-designer  
**Statut :** Implémenté (`FtueService.luau`, `FtueClient.client.luau`)  

> **v2.0 (2026-09-03) — décision du game-designer :** le tutoriel est raccourci à
> **4 temps** : marcher → tuer le 1er mob à mains nues (→ Épée en bois) → l'équiper
> → message « le jeu est dur ». Fin du tuto → **familier gratuit (Fée)**. Les
> coach-marks `power` (talents) et `campfire` de la v1.0 sont supprimés ; le
> cadeau familier est **découplé du feu de camp** (qui reste à km 50). L'épée
> n'est plus un cadeau de création : elle tombe au 1er kill.
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

### 2.1 Les 4 temps du tutoriel

Chaque temps est un **événement**, pas un timer. Un seul coach-mark visible à la fois. Aucun ne
bloque l'entrée : le joueur peut ignorer et jouer.

| # | `step` | Déclencheur (serveur) | Coach-mark | Effet à la validation |
|---|---|---|---|---|
| 1 | `move` | Spawn | « Tiens ◀ / ▶ pour avancer et reculer » | ack → `step = kill` |
| 2 | `kill` | 1ᵉʳ monstre tué (à mains nues) | *(pas de bulle : c'est l'événement)* | **Épée en bois** mintée dans le sac (non équipée) ; `step = equip` ; coach-mark `equip` affiché |
| 3 | `equip` | Une arme occupe le slot `arme` | « Ouvre ton inventaire et équipe l'Épée en bois » | `step = warning` ; coach-mark `warning` affiché |
| 4 | `warning` | — | Panneau : « Ce monde est impitoyable. Tu vas mourir, souvent et vite. C'est normal — chaque tentative te rend plus fort. » | ack → **familier Fée** minté + équipé ; `step = done`, `completed = true` ; fenêtre cadeau |

**Fin du tuto :** dès l'ack du temps 4. Le 1ᵉʳ boss (Roi Gobelin, km 10) n'a aucun coach-mark.

**Le combat auto** n'a plus de coach-mark dédié (temps `combat` de la v1.0 supprimé) : il démarre
seul à la 1ʳᵉ collision, le joueur le voit. Idem pour le ramassage auto du butin.

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
-- PlayerProfile.ftue (persisté) — voir PlayerDataService.defaultProfile()
ftue = {
    version = 1,               -- schéma FTUE
    completed = false,         -- true dès l'ack du temps "warning" ET le familier remis
    step = "move",             -- "move" | "kill" | "equip" | "warning" | "done"
    petGranted = false,        -- familier Fée remis (idempotence)
    startedAt = os.time(),
    completedAt = nil,         -- os.time() quand completed passe à true
}
```

L'épée utilise le drapeau existant `profile.starterKitGranted` (déjà au profil) pour l'idempotence,
pas un champ `ftue` dédié.

**Contraintes (validées serveur) :**
- `step` n'avance que dans l'ordre `move → kill → equip → warning → done`. Un ack hors séquence
  ou pour un step non-ackable (`kill`, `equip` sont résolus par de vrais événements serveur) est
  un **no-op silencieux**, jamais une erreur.
- `petGranted` et `starterKitGranted` ne passent à `true` qu'une fois par profil.
- Un profil qui **a déjà joué** (`bestKm > 0`, `niveau > 1`, `rebirths > 0`, ou sac non vide) au
  moment de la migration reçoit `ftue.completed = true` d'office — il ne rejoue jamais le tuto.

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

**Pas de canal dédié** : le FTUE est multiplexé sur le `CombatEvent` existant (même choix que
l'Inventory Sprint), par `data.type` :

- `{type = "ftueState", ftue = <ftue>}` — **S→C**, au spawn. Reprise / skip si `completed`.
- `{type = "ftueStep", stepId = "move"|"equip"|"warning"}` — **S→C**, quand le serveur veut
  afficher un coach-mark.
- `{type = "ftueGift", petId = "fee"}` — **S→C**, une fois, quand la Fée est en inventaire.
- `{type = "ftueAck", stepId = "move"|"warning"}` — **C→S**, sur « Compris » ou auto-dismiss.
  Le serveur revalide (`FtueService.ackStep` : `stepId` ackable ET == `ftue.step`) avant d'avancer.

**Validation C→S :** seuls `move` et `warning` sont ackables. `kill` et `equip` ne peuvent jamais
être déclenchés par un message client (résolus par le kill réel / l'équip réel). Ack hors
séquence = no-op silencieux.

**Rate-limiting :** `ftueAck` — 4 / fenêtre (`GameConfig.Security.remotePerType.ftueAck`),
2 acks max par joueur au total.

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
