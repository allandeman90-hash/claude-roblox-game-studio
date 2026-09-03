# Handoff — 2026-09-03 (soir) — post /simplify + revert HUD

**Pour :** session Claude Code après `/clear`. Suite de `10-handoff-2026-09-03.md`.

---

## État du repo

- `master` = **`68e6175`**, working tree **propre**, **poussé** sur origin.
- Commits de cette session (tous poussés) :
  - `197d439` + `092488f` — 2 passes `/simplify` (refactor, pas de changement de
    comportement). Serveur + inventaire + FTUE nettoyés.
  - `13d2ec7` — **revert de `CombatClient.client.luau` à l'état `d6cfa2a`** (à la
    demande d'Allan : « je veux le HUD tel quel avant /simplify »). Annule
    UNIQUEMENT ce fichier ; le reste de `092488f` reste en place.
  - `68e6175` — fond du HUD en noir pur `0,0,0` (matcher les overlays).

### ⚠️ Rojo — process zombie

Un `rojo serve` lancé plus tôt dans la session était **mort mais le port restait
pris** (snapshot périmé → les commits ne syncaient pas dans Studio). Fix : `taskkill`
le PID, relancer `~/.rojo/bin/rojo.exe serve serve.project.json` en tâche de fond,
puis **Reconnecter le plugin Rojo dans Studio en mode Edit** (pas Play — sinon
erreur « Http requests can only be executed by game server »).
Serveur actuel : PID vérifiable via `netstat -ano | grep 34872`.

### ⚠️ Toujours vrai

- HUD 100 % runtime : bloc `do` (~L119) de `CombatClient.client.luau`. `RpgGui`
  dans le `.rbxl`, pas synchro Rojo.
- Piège sync Rojo : éditer → stop Play → `script_grep` un marqueur → puis Play.
- DataStore : cette session `isPersisting` a parfois renvoyé `false` (mode UNSAVED)
  ET parfois le profil niv.14 est revenu → **incohérent**. En UNSAVED, Stop→Play =
  profil neuf niv.1.

---

## ⚠️ NON VÉRIFIÉ cette session

Toute la session est partie sur des soucis Rojo + désaccord sur le HUD. **Rien n'a
été play-testé pour de bon.** À valider en jouant :

1. **Flux FTUE bout-à-bout** (jamais vu tourner cette session) : Stop→Play pour un
   profil neuf → marche → 1er kill (épée) → équipe l'épée → **écran choix 3 œufs**
   (🟢 vert Soin / 🔴 rouge DPS / 🔵 bleu Tank) → **éclosion animée** → carte
   familier → message final « 4 façons ». Le `092488f` a touché `FtueService`
   (helper `grantPet`), `FtueClient` (hover pet = 1 seul tween), `InventoryService`
   (`grantStarterPet` idempotence via `category=="pet" and def.isStarter`) — **à
   surveiller** que le pet est bien accordé + équipé.
2. **Soin du familier** : `092488f` a **fusionné la boucle de soin dans la boucle
   d'attaque ennemie** de `CombatServer` (`tickHealPet(st)` appelé chaque tick).
   Vérifier : soin toutes les 6 s, +5 % au feu de camp, revive mythique.
3. **Rattrapage niveau pet** : `092488f` — `GameConfig.Pets.petLevelCatchUpFrac`
   (0.15) + `markProfileDirty` ajouté. Vérifier que `petLevel` monte au level-up.
4. **Inventaire** : label rôle « Soin » (via `EquipmentConfig.RoleLabels`, nouveau).

---

## ⭐ EN PREMIER — XP du familier visible (demandé par Allan, toujours pas fait)

Repris tel quel de `10-handoff` §⭐ :

Le modèle actuel : `petLevel` **rattrape** le niveau du joueur d'un coup à chaque
level-up (`CombatServer` ~L437, `EquipmentService.getEquipped(player).pet.petLevel`).
Allan veut une **vraie progression XP visible** :
1. Le familier gagne de l'**XP sur les kills** tant qu'il est équipé
   (`petXp` + `petXpToNext(petLevel)` sur l'`ItemInstance`, nouveaux champs +
   migration `PROFILE_VERSION` 3→4). Level-up quand plein. Garder le plancher
   `sourceLevel * GameConfig.Pets.sourceFloorFrac`.
2. **Carte « Pets » du HUD** (`CombatClient`, `artifactHeroPetCard`, texte via
   `data.equipPet`) : afficher `Pets  <nom> · Niv. X · XP a/b`.
3. **Panneau détail inventaire** (`InventoryScreen.luau` ~L114 `itemStatLines`,
   déjà « Rôle / Niveau / Palier » — ajouter la ligne XP).
4. **Serveur** : envoyer `petLevel` / `petXp` / `petXpToNext` dans `sendUpdate`
   (`CombatServer`), pour que le client affiche.

---

## HUD — état actuel & options

Le HUD est **exactement `d6cfa2a`** + fond noir `0,0,0`. Allan n'en est pas
satisfait (« vraiment pas beau »). Diagnostic (comparé à `Réference/mon ui final.png`,
extrait via `git show c476db0:"Réference/mon ui final.png"`) :

- **texte trop petit** : `card()` size 14, top bar 17/14, xpText 11, progress 12.
  Le mockup et l'ancien HUD `8e4ae0b` étaient à **16**.
- **bordures invisibles** : bloc `do` utilise un local `LINE = 70,71,77` alors que
  les overlays (et `StyleConstants.Border`) sont à `96,96,101`. Les cartes ne se
  détachent pas du fond → « bloc noir ».
- **colonne droite quasi vide** en exploration (`artifactEnemyPvCard.Visible =
  false`, `artifactEnemyAtkCard.Visible = false`).
- gros vide vertical colonne gauche entre la carte stats (y≈0.5) et TALENTS (y≈0.9)
  — mais le mockup a le même vide, OK.

Un essai de tuning (LINE→96,96,101, tailles→16, PV_H→20, hpBar plus épais) a été
fait puis **jeté par le revert**. Si Allan valide « détacher les cartes » : refaire
ce tuning dans le bloc `do` (~L120-250). **Ne PAS** re-toucher `updateScene` /
RenderStepped / les constantes de scène (le combat lui plaît : coup d'arme, flinch,
pas de dash).

**Alternative discutée mais NON choisie** : revert complet au HUD `8e4ae0b`
(glow jaune `255,220,70` + bordures claires) → perd le panneau TALENTS + l'anim de
combat. Allan a préféré garder `d6cfa2a`.

---

## Reste du brief `09` (jamais fait)

Écrans encore en ancien style (fond `0,0,0` pur, à retinter) :
`ShopOverlay` · `ChateauOverlay` · `GameOverWindow` · `AccessibilityScreen` ·
`BagFullPrompt`. Même méthode : screenshot avant → retint → OK Allan → commit.

Nettoyage différé (voir `10-handoff` §Nettoyage) :
- Étape 4 brief `09` : purger les nœuds morts de `RpgGui` + re-dump `RpgGui.gui.json`.
- Bloc `equipOverlay` mort dans `CombatClient` (~L1560).
- En-tête périmé de `FtueService.luau` (parle encore de « Fée » / 4 beats, pas du
  choix d'œufs).

---

## Hors-scope (rappel)

**Ne pas lancer `upload.py`** (écrase `AssetMap` ; compte Roblox banni pour les
uploads — mémoire `roblox-account-ban-2026-08-30`). Pas de sprites uploadés.
`assets/images/ftue/pet_egg.png` généré, jamais uploadé.

---

## Références

- `Réference/mon ui final.png` — cible visuelle HUD
- `docs/plan/09-ui-refonte-brief.md` · `docs/plan/10-handoff-2026-09-03.md`
- `src/ReplicatedStorage/Shared/StyleConstants.luau` · `design/gdd/ui-ux-gdd.md`
- Mémoire : `minutrpg-build-progress`, `minutrpg-combat-art-direction`,
  `studio-place-out-of-sync`, `roblox-account-ban-2026-08-30`
