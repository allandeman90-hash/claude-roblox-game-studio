# Quête Minute — Le Plan Complet (v2)

**Refonte : 2026-08-31**, après la phase de conception (119 décisions, GDD maître écrit,
110 assets générés, compte Roblox débanni).

Ce document remplace la v1. Il est organisé en **tracks parallèles** : plusieurs peuvent
avancer en même temps, chacun confié à un agent ou une équipe d'agents. Le graphe de
dépendances (§C) dit ce qui peut démarrer maintenant et ce qui attend.

**Sources de vérité :** `design/gdd/master-gdd.md` · `design/reponses-consolidees.md` ·
`design/economy/monetization.md` · `GAME_SPEC.md` (équipement only) · `docs/plan/02-maquettes.md`
+ `03-sur-tous-les-ecrans.md` (références visuelles).

---

## A — État des lieux (2026-08-31)

### Fait
- **Combat** : largement codé (17 modules `src/`). Rebalance ennemis niveau-based, teinte de
  difficulté 6 paliers, flash rouge < 20 % PV, sprites héros/ennemi/pet câblés (anciens).
- **Conception** : GDD maître v1.0 + `systems-index.md` + monétisation + 119 décisions.
- **Assets** : 2 héros · 72 monstres · 24 boss/big boss · 12 fonds — découpés, nommés,
  dans `assets/images/*/final/`. Pas encore uploadés ni câblés.

### À faire (résumé)
- **Assets → jeu** : atlas, upload, `AssetMap.luau`, câblage, familiers, fonds de couche.
- **Stabiliser le code** : retirer `DEV_MODE`, rate-limit remotes, `ProcessReceipt` idempotent,
  session lock, découpler les saves, resolver de multiplicateurs, 4 bugs connus.
- **23 GDD par système** (`design/gdd/systems-index.md`).
- **Modèle chiffré** : table de croissance des stats, tous les gros multiplicateurs, rosters
  c2-c12, 50 armes, 96 armures + 12 sets, playthrough de balance.
- **Narratif** : bible de La Descente, dialogues des 12 boss ×2 rencontres, cartes de couche,
  entrées de codex.
- **Socle UI paysage + HUD réservé**, puis les ~10 écrans.
- **Systèmes** : compétences, talents, sous-classes, 3-pet party, mécaniques de boss, Cauchemar.
- **Rétention** : récompense quotidienne, missions, Donjon du Jour, codex, pass de saison,
  classements, analytics.
- **Monétisation** : game passes, dev products, boutique cosmétique, prompts contextuels.
- **Polish & QA**, **Durcissement**, **Publication**.

---

## B — Le préambule (à coller au début de chaque session Claude Code)

```
Projet : Quête Minute (RPG auto-battler 2D Roblox). Source de vérité : design/gdd/master-gdd.md
+ design/reponses-consolidees.md + design/economy/monetization.md. Je te donne un prompt
d'une TRACK du plan (docs/plan/00-plan-complet.md).

RÈGLES NON NÉGOCIABLES :
1. 100 % GUI. Aucun monde 3D, aucun Humanoid, aucune caméra, aucun personnage.
2. Orientation VERROUILLÉE paysage. Coin haut-gauche réservé au HUD Roblox (☰ + chat) :
   rien d'important là. Lis GuiService.TopbarInset + GetGuiInset(). PlayerList + Backpack
   désactivés. Infos de jeu centrées ou à droite.
3. Un seul ScreenGui : UDim2 Scale + UIAspectRatioConstraint + TextScaled + UITextSizeConstraint.
   Safe area iOS (ScreenInsets = CoreUISafeInsets). Entrées tactile / clavier QWE+AD / manette.
4. Serveur autoritaire pour TOUT état. Valide type + plage + cohérence de chaque argument de
   RemoteEvent, rate-limite chaque action client. Aucun RemoteFunction client→serveur.
   ProcessReceipt idempotent + registre PurchaseId.
5. Équipement de GAME_SPEC.md gardé tel quel. Tout le reste suit le GDD maître.
6. Compte Roblox DÉBANNI — uploads possibles. Cosmétiques = Frames/dégradés procéduraux.
7. Protocole : montre un plan puis des extraits, demande avant Write/Edit, aucun commit sans
   mon accord.
8. Style Luau : .claude/docs/luau-style-guide.md. task.wait/spawn/defer. pcall autour de tout
   appel de service. Services cachés en haut de module. Magic numbers dans GameConfig.
9. Skills : /studio-test après chaque changement de code, /doctor après un changement
   structurel. Les /team-* orchestrent une feature. Les audits (/exploit-check, /economy-audit,
   /datastore-review, /balance-check, /perf-profile, /remotes-audit) sont des portes.
10. Après chaque changement : pousse vers Studio (MCP), /studio-test, lis la console, rapporte.

Réponds "compris" et attends mon prompt.
```

Le catalogue complet des 51 skills (quand lancer quoi) : voir la fin de ce fichier, §F.

---

## C — Les tracks & le graphe de dépendances

| Track | Titre | Agent / équipe | Démarre |
|---|---|---|---|
| **A** | Assets → jeu | devops-engineer + technical-artist + roblox-studio-specialist | **maintenant** |
| **B** | Stabilisation & sécurité du code | lead-programmer + exploit-security-specialist + datastore-architect + remotes-networking-specialist | **maintenant** |
| **C** | GDD par système | game-designer (coord.) + systems-designer + spécialistes | **maintenant** |
| **D** | Modèle chiffré & contenu du monde | systems-designer + economy-designer + game-designer | **maintenant** |
| **E** | Narratif — La Descente | narrative-director + writer + world-builder | **maintenant** |
| **F** | Socle UI + les écrans | ui-programmer + ux-designer + accessibility-specialist | après A + C8 |
| **G** | Systèmes de combat & progression | luau-gameplay-programmer + luau-systems-programmer + remotes-networking-specialist | après C1-C3 + D1-D2 |
| **H** | Systèmes de rétention | live-ops-specialist + game-designer + economy-designer | après C6-C7 + F4 |
| **I** | Monétisation | monetization-lead + devops-engineer + economy-designer | après B4 + H6 |
| **J** | Polish & QA | qa-lead + performance-analyst + sound-designer + `/team-polish` | après F + G |
| **K** | Durcissement | exploit-security-specialist + datastore-architect + technical-director | après tout |
| **L** | Publication | release-manager + devops-engineer + producer | après K vert |

```
MAINTENANT (parallèle) :  A ─┐   B ─┐   C ─┬─────┐   D ─┐   E
                              │       │      │     │      │
        ┌─────────────────────┴───────┴──────┘     │      │
        │ (sprites)          (code stable)   (GDDs)│(chiffres)(dialogues)
        ▼                                          ▼      ▼      ▼
  ══ GATE PHASE 1 : A+B+C+D+E verts ══════════════════════════════
        │
        ├─► F (écrans)  ◄── A, C8
        ├─► G (systèmes) ◄── C1-C3, D1-D2
        │
  ══ GATE PHASE 2 : première session jouable de bout en bout ══
        │
        ├─► H (rétention) ◄── C6-C7, F4
        ├─► I (monétisation) ◄── B4, H6
        │
  ══ GATE PHASE 4 : /economy-audit + /exploit-check payant verts ══
        │
        ├─► J (polish & QA) ◄── F, G
        ├─► K (durcissement) ◄── tout
        │
  ══ GATE : K vert ══
        │
        └─► L (publication)
```

Entre chaque gate : `/gate-check` (go/no-go) + `/retrospective` + `/sprint-plan` + `/estimate`
pour la phase suivante. Si en retard : `/scope-check`.

---

## D — Les prompts, track par track

Format : **[Agent / équipe] · Skills · Dépend de** — puis le prompt — puis `✓ Fini quand`.
Les prompts marqués **⟳ délégable** peuvent tourner en subagent de fond pendant qu'une autre
track avance.

### TRACK A — Assets → jeu

**A1 — Repack en atlas** · [devops-engineer] · `/studio-test` · dépend de rien · ⟳ délégable
```
Écris tools/assetgen/pack_atlas.py : lit assets/images/{hero,monsters,bosses,backgrounds}/final/,
repack en 3-4 atlas PNG 1024×1024 (héros+monstres ensemble, boss, big boss ; les 12 fonds
restent individuels), écrit tools/assetgen/atlas-manifest.json (slug → {atlas, x, y, w, h}).
Bin-packing simple (rangées). Marge 2 px entre sprites. Génère aussi une planche de contrôle.
```
`✓ Fini quand :` 3-4 atlas + le manifest existent, planche de contrôle relue, aucun sprite coupé.

**A2 — Upload Open Cloud + AssetMap** · [devops-engineer] · dépend de A1
```
Adapte tools/assetgen/upload.py pour uploader les atlas + les 12 fonds via l'API Open Cloud
Assets (clé Creator dans une var d'env, jamais dans un fichier). Attends la modération de
chaque asset. Génère src/ReplicatedStorage/AssetMap.luau : slug → { id = "rbxassetid://…",
rect = Vector2 offset, size = Vector2 } pour les atlas, slug → id simple pour les fonds.
Garde un fallback texte pour tout slug sans id.
```
`✓ Fini quand :` tous les assets approuvés par la modération, AssetMap.luau généré, aucune
référence orpheline.

**A3 — Câbler les sprites dans le jeu** · [technical-artist + ui-programmer] · `/studio-test` · dépend de A2
```
Dans CombatClient + RpgGui : remplace les placeholders par de vrais ImageLabel qui lisent
AssetMap (Image = atlas id, ImageRectOffset/ImageRectSize depuis le rect). Héros selon la voie,
ennemi selon enemyId, boss selon bossId. Génère les familiers : réduction (~40 %) des sprites
monstres → assets/images/pets/, upload, ajoute à AssetMap. /studio-test : les bons sprites
s'affichent, feet-on-ground, pas de carré manquant.
```
`✓ Fini quand :` /studio-test — héros, monstres des 12 couches, boss, big boss et familiers
s'affichent correctement.

**A4 — Fonds de couche + carte de transition** · [technical-artist + ui-programmer] · `/studio-screenshot` · dépend de A2
```
applyZoneDecor : charge bg_zone1..12 selon la couche courante (fond fixe, la scène est la
colonne centrale). Ajoute la carte de transition entre deux couches (Q100) : plein écran, nom
de la couche + 1 phrase d'ambiance (de design/narrative/), 5 s max, passe automatiquement.
/studio-screenshot sur 3 couches.
```
`✓ Fini quand :` /studio-screenshot — chaque couche a son décor, la carte s'affiche 5 s et se
ferme seule.

---

### TRACK B — Stabilisation & sécurité du code

**B1 — Retirer le mode dev** · [lead-programmer] · `/studio-test` · dépend de rien
```
Supprime définitivement DEV_MODE, le handler "devReset", PlayerDataService.wipe, le bouton
DevReset client + son wiring. Grep "dev"/"DEV"/"wipe"/"REVIVE_PRODUCT_ID". /studio-test.
```
`✓ Fini quand :` plus aucune référence, aucun reset joueur possible, /studio-test OK.
*(Réf. mémoire projet "dev-reset — remove before release".)*

**B2 — Rate-limit tous les remotes** · [remotes-networking-specialist + lead-programmer] · `/remotes-audit` `/studio-test` · dépend de rien · ⟳ délégable
```
Lance /remotes-audit sur CombatEvent + ShopEvent. Puis : guard `if type(data) ~= "table" then
return end` en tête du handler. Table lastCalls[player] (fenêtre glissante 1 s) : plafond
global ~20/s + par type (move 10/s, requestInventory 2/s, equip/fuse/buy 4/s, rebirth 1/s).
Rejet silencieux au-delà, log si dépassement soutenu. Supprime le handler ShopEvent mort.
Crée design/remotes-manifest.md.
```
`✓ Fini quand :` /remotes-audit propre, un test de spam ne dégrade pas le Heartbeat.

**B3 — Découpler les sauvegardes + session lock** · [datastore-architect] · `/datastore-review` · dépend de rien · ⟳ délégable
```
Lance /datastore-review sur l'existant. Puis : les handlers marquent sess.dirty = true et ne
sauvegardent jamais eux-mêmes. Un seul task de save throttlé (≤ 1 écriture / 30-60 s / joueur,
si dirty). Saves garanties : PlayerRemoving, BindToClose, jalons (rebirth, achat). BindToClose
attend jusqu'à os.clock()+25. Heartbeat du lock toutes ~30 s (< LOCK_STALE_S). wipe/RemoveAsync
respecte le lock. Prise de lock contestée = retry puis kick (pas de session fantôme).
```
`✓ Fini quand :` /datastore-review propre, save/reload + verrou de session testés, tempête
BindToClose (8 joueurs kick simultané) OK.

**B4 — ProcessReceipt idempotent** · [datastore-architect + monetization-lead] · `/datastore-review` · dépend de rien
```
Réécris ProcessReceipt : clé "receipt_"..PurchaseId dans un DataStore dédié. Si déjà présente →
PurchaseGranted (idempotent). Si joueur absent → NotProcessedYet. Applique l'effet (crédité
dans le profil pour les consommables), écris la clé (pcall + retry) APRÈS le grant, ne rends
PurchaseGranted que si l'écriture réussit. Aucun return inconditionnel. pcall partout.
```
`✓ Fini quand :` /datastore-review propre, un achat rejoué ne crédite pas deux fois (test).

**B5 — Resolver de multiplicateurs + session shop** · [technical-director + lead-programmer] · `/studio-test` · dépend de rien
```
Crée RewardService.multiplier(player, category) où category ∈ {xp, gold, loot, petLoot} :
max(pass_permanent, pass_premium_actif), plafond ×3 par catégorie ; puis × cauchemar_mult ×
rebirth_bonus (catégories gagnées qui se multiplient volontairement — formule dans
monetization.md §2). Boosts temporaires = { expiresAt } serveur, ignorés si expirés. Ownership
gamepass via UserOwnsGamePassAsync en pcall, cache serveur, invalidé sur
PromptGamePassPurchaseFinished. Appliqué en UN seul point (resolvePlayerHit + futurs points de
récompense). ShopService.closeShop(player) dans restartRun, le handler rebirth, et gameOver.
```
`✓ Fini quand :` /studio-test — pas d'empilement ×6, gear sur-tier impossible après restart.

**B6 — Les 4 bugs connus** · [luau-gameplay-programmer] · `/studio-screenshot` `/studio-test` `/balance-check` · dépend de rien · ⟳ délégable
```
(a) Dégâts sur le mauvais ennemi : dans startEncounter (CombatServer), appelle
    sendUpdate(player, st) AVANT resolvePlayerHit(player, st).
(b) Ligne xp/min & or/min illisible : HeroTimeBox empile 4 lignes dans une place pour 2 —
    agrandis-la OU passe à 3 lignes. La logique de calcul est correcte.
(c) Séparateur étape 9-10 : dans updateZoneTrack, positionne les 10 ticks par code —
    Tick[i].Position = UDim2.new((i-1)/10, 0, 0.5, 0), garde Y/hauteur.
(d) Loot des boss de couche : LootService.rollDrop reçoit l'index de boss (= couche, 1..12
    cyclique) pour TOUT boss nommé, pas seulement les big boss. /balance-check sur les taux
    de set, test : tuer le boss couche 1 ~15×.
```
`✓ Fini quand :` /studio-screenshot + /studio-test confirment les 4 ; /balance-check les taux
de set.

---

### TRACK C — GDD par système

Chaque GDD via `/gdd <système>`. Modèle : `.claude/docs/templates/gdd-system.md` (9 sections,
formules explicites, ≥ 5 edge cases). Gate global : `/design-review` sur chaque GDD.
Toutes les tâches C sont **⟳ délégables** (subagent game-designer / systems-designer).

**C1** · [systems-designer + lead-programmer]
```
/gdd core-gameplay puis /gdd combat. Marche (tenir gauche/droite, moveSpeed, respawn), combat
auto (héros frappe 1er, cadence, DEF/RES, mitigation), fuite (mobs oui / boss non), teinte de
danger 6 paliers. Reprends le code combat existant comme base, documente l'écart avec le GDD
maître.
```
`✓ Fini quand :` les 2 GDD relus (/design-review), formules alignées avec l'Annexe A du GDD maître.

**C2** · [systems-designer]
```
/gdd progression, /gdd talents, /gdd subclass, /gdd rebirth. Stats auto (classe × sous-classe,
1 pt libre / 5), points de compétence gagnés (permanents, sources + allocation), 3 branches de
talents × 10+, sous-classes (R5, Berserker/Gardien/Destructeur/Sage), mur de niveau 100+20/reb,
jalons /5, checkpoints auto, mort = re-marche.
```
`✓ Fini quand :` 4 GDD relus, la table de croissance renvoie à D1.

**C3** · [systems-designer + luau-gameplay-programmer]
```
/gdd abilities, /gdd boss-mechanics. 3 slots, auto par défaut + reprise en main, cooldowns,
débloqués par talents ; 2-4 phases par boss, grosse attaque à interrompre (tuile de pouvoir
recontextualisée — pas le bon pouvoir = pas d'interruption), adds, enrage en Cauchemar. Les
12 signatures de boss (une par personnage).
```
`✓ Fini quand :` 2 GDD relus, les 12 signatures listées.

**C4** · [economy-designer + systems-designer]
```
/gdd nightmare, /gdd economy. Ladder Cauchemar par couche (déblocage par kills, multiplicateurs
→ D2, enrage, avance auto), l'or (faucet, sink = rebirth avec la courbe Q64, gemmes premium,
puits Q61), les boutiques (5 objets, restock, marchand ambulant avant km 50).
```
`✓ Fini quand :` 2 GDD relus.

**C5** · [systems-designer]
```
/gdd pets, /gdd codex, /gdd inventory. Familiers = mini-monstres (drop 0,5 %/0,1 %, rôle
Heal/DPS/Tank au drop, famille = meilleur rôle, effet permanent, soigneur en combat, équipe
de 3→4) ; codex (10 kills/carte, familles, bonus quand une famille est complète, onglet objets
silhouette) ; inventaire (100 slots, filtres sur la page, tri par emplacement, comparaison,
fusion, vente rapide, panneau de set).
```
`✓ Fini quand :` 3 GDD relus, l'inventaire vérifié vs GAME_SPEC §1.2.

**C6** · [game-designer + live-ops-specialist]
```
/gdd campfire, /gdd daily-reward, /gdd missions, /gdd daily-dungeon, /gdd raid. Feu de camp =
hub complet (le km 0 = le château), coffre horaire ; récompense 7 jours (cycle Q77, 48 h de
grâce) ; 10 missions/jour (7/2/1, pool ~50, reroll, bonus de complétion en points permanents,
perdues à 24 h) ; Donjon du Jour par étages (1 clé/jour, mort = clé perdue, 7 thèmes fixes,
salles à défi + coffres, classement par étage, reprise à l'étage max hebdo) ; donjon-raid solo.
```
`✓ Fini quand :` 5 GDD relus.

**C7** · [live-ops-specialist + monetization-lead]
```
/gdd season-pass, /gdd leaderboards. Pass S1 (8 semaines, ~50 paliers, gratuit + premium, XP
de pass Q85) ; classements all-time (distance, rebirths, palier Cauchemar) + podium serveur +
paliers de Soutien non chiffrés + anti-triche serveur.
```
`✓ Fini quand :` 2 GDD relus, cohérents avec monetization.md.

**C8** · [ux-designer + narrative-director + ui-programmer]
```
/gdd onboarding, /gdd ui-ux, /gdd narrative. FTUE 5 coach-marks + cadeau (1er familier) ;
socle UI (un ScreenGui paysage, zone HUD réservée, safe area, entrées, accessibilité Q104/Q105,
les ~10 écrans avec leur arbre d'instances) ; La Descente (structure narrative, où placent les
dialogues, les cartes de couche).
```
`✓ Fini quand :` 3 GDD relus, l'ui-ux-gdd renvoie aux maquettes.

---

### TRACK D — Modèle chiffré & contenu du monde

Toutes **⟳ délégables** (economy-designer / systems-designer). Tableur d'abord, `/balance-check`.

**D1 — Table de croissance des stats** · [systems-designer] · `/balance-check`
```
Propose la table "5 points/niveau répartis en %" par classe ET par sous-classe (Q117), avec
justif. Guerrier/Mage de base + Berserker/Gardien + Destructeur/Sage. Calibre pour que le
1er mur de niveau (100 + 20×reb) tombe vers km 25-35 / jour 2-3 (Q26). Sur tableur : puissance
du joueur à chaque niveau vs stats ennemi (mob niveau ≈ km×10). Montre-moi le tableau, je valide.
```
`✓ Fini quand :` table validée, écrite dans progression-gdd + GameConfig.

**D2 — Les gros multiplicateurs** · [economy-designer] · `/balance-check` `/economy-audit`
```
Propose une valeur pour chacun (Q118), je valide en bloc : Cauchemar par palier (ennemis /
récompenses), XP de pass par source, bonus rebirth croissant (+10/+12/+14…), courbe XP ×1,35
recalibrée, courbe d'or vs coût rebirth (Q64 : le rebirth garde toujours l'avance). Sur tableur.
```
`✓ Fini quand :` valeurs validées, dans GameConfig, /economy-audit sur les ratios.

**D3 — Rosters des couches 2-12** · [systems-designer] · `/balance-check` · dépend de D1
```
Les 72 sprites existent (assets/images/monsters/final/). Pour chacun : HP/ATK/EXP/gold (via
combatBaseForLevel + un mult de roster), famille de codex (Bête/Mort-vivant/Élémentaire/
Humanoïde/Construct), rôle de familier le plus fort. → ZoneConfig (rosters c2..c12, aujourd'hui
vides). Respecte "un mob niveau L ≈ un joueur de même niveau".
```
`✓ Fini quand :` ZoneConfig a les 12 rosters, /balance-check confirme la courbe.

**D4 — 50 armes** · [economy-designer] · `/economy-audit` · dépend de D2
```
50 armes : nom, voie, courbe de puissance par zone (×1,30), arme de boss = ×2,5 arme de
boutique de la même zone. 5 raretés = purs multiplicateurs (×1 / ×1,5 / ×2,2 / ×3,5 / ×6).
Lv. indicatif non-bloquant. → un module de config. /economy-audit.
```
`✓ Fini quand :` 50 armes en config, /economy-audit — un Mythique reste supérieur ~6 zones.

**D5 — 96 armures + 12 sets** · [economy-designer] · `/economy-audit` · dépend de D2
```
96 armures (12 boss × 4 pièces × 2 voies). 12 sets, bonus paliers 2/3/4, versions Guerrier/Mage
symétriques, même voie uniquement. DEF majoritaire côté Guerrier, RES côté Mage. Chaque set une
identité (dégâts / survie / vitesse). → EquipmentConfig. Table de butin boss : 1 tirage/kill,
% constants (GAME_SPEC §6.3). /economy-audit.
```
`✓ Fini quand :` 96 armures + 12 sets en config, table de butin câblée (voir B6d), /economy-audit.

**D6 — Playthrough de balance** · [game-designer + economy-designer] · `/balance-check` · dépend de D1-D5 — **GATE**
```
Playthrough complet sur tableur : "un f2p bat le boss C3 + fait 1 rebirth en ≤ X h", "le
1er mur tombe km 25-35", "arme J7 ≤ 60 % d'une arme de boss de même zone", "après un rebirth,
retraversée en ~20 % du temps". Le jeu doit être DUR — pas impossible, pas facile (Q119).
Logue les paramètres dans decision-log.md.
```
`✓ Fini quand :` /balance-check vert sur les 4 cibles, decision-log à jour.

---

### TRACK E — Narratif — La Descente

Toutes **⟳ délégables** (narrative-director / writer). Écrit dans `design/narrative/`.

**E1 — Bible de La Descente** · [narrative-director + world-builder]
```
Écris design/narrative/la-descente.md : la Faille (qu'est-ce, pourquoi on descend), les 12
couches (nom, identité, ce qu'on y trouve, palette), les 12 boss comme PERSONNAGES (nom,
rancune, ce qu'ils gardent, leur arc quand ils reviennent ~6 couches plus bas). Ton : grim
dark-fantasy, mélancolique, pas gore. Public 10-16 ans, chat-filter-safe.
```
`✓ Fini quand :` bible relue, cohérente avec les sprites de boss existants.

**E2 — Dialogues des 12 boss** · [writer] · dépend de E1
```
Pour chaque boss : 1ère rencontre (2-3 lignes en arrivant + 1 ligne à la mort du boss) +
2ème rencontre (2-3 lignes qui rappellent la 1ère). 12 × ~6 lignes. Chat-filter-safe, court,
percutant. → design/narrative/boss-dialogues.md (format exploitable par le code).
```
`✓ Fini quand :` les 24 blocs de dialogue écrits et relus.

**E3 — Cartes de transition de couche** · [writer] · dépend de E1
```
12 cartes : "Couche N — <Nom>" + 1 phrase d'ambiance (< 90 caractères). Affichée 5 s entre
deux couches. → design/narrative/layer-cards.md.
```
`✓ Fini quand :` 12 cartes écrites.

**E4 — Entrées de codex** · [writer + world-builder] · dépend de E1, D3
```
Pour ~72 monstres + 12 boss : 1 ligne de lore chacun + la famille + le bonus de famille (une
phrase minuscule, +X % contre cette famille). → design/narrative/codex-entries.md.
```
`✓ Fini quand :` toutes les entrées écrites, familles alignées avec D3.

---

## ══ GATE PHASE 1 ══ — A + B + C + D + E verts
`/gate-check` · `/doctor` · `/retrospective` · puis `/sprint-plan` + `/estimate` pour la Phase 2.

---

### TRACK F — Socle UI + les écrans

Dépend de A (sprites) + C8 (ui-ux-gdd). Chaque écran via `/team-ui` (inclut
accessibility-specialist). Gate : `/design-review` vs maquette.

**F1 — Socle paysage + HUD réservé** · [ui-programmer] · `/wiki-query` `/studio-screenshot` `/studio-test`
```
/wiki-query "GuiService TopbarInset safe area iOS ScreenInsets". Puis : verrou paysage ;
SetCoreGuiEnabled(PlayerList/Backpack, false) ; un module client qui lit TopbarInset +
GetGuiInset() et expose un "safe rect" auquel RpgGui se cale ; déplace au centre les infos HUD
du coin haut-gauche. /studio-screenshot sur un petit écran émulé.
```
`✓ Fini quand :` /studio-screenshot — le coin ☰ est dégagé sur téléphone émulé, /studio-test OK.

**F2 — Chargement + menu titre** · `/team-ui` · dépend de F1
```
ReplicatedFirst : écran de chargement (logo + héros animé + barre). Menu titre : logo à gauche,
JOUER (reprend au dernier feu de camp) + bandeau récompense du jour + barre de pass + 6 accès
(Talents, Sac, Boutique, Codex, Rang, ⚙). Maquette 01.
```
`✓ Fini quand :` /design-review vs maquette 01, JOUER lance une partie.

**F3 — Création de héros** · `/team-ui` · dépend de F1
```
Barre CRÉE TON HÉROS. 3 colonnes : carte GUERRIER (sélectionnée) | aperçu héros teinté | carte
MAGE. Bas : swatches de teinte (4 gratuites) + champ nom (filtré) + COMMENCER. COMMENCER
accorde l'arme de tier 1 et lance les 5 coach-marks. Maquette 02.
```
`✓ Fini quand :` /design-review vs maquette 02.

**F4 — Le château / feu de camp** · `/team-ui` · dépend de F1, C6
```
Zone derrière l'étape 1 de la zone 1 : un château en pixel 2D où le héros entre (N3). À
l'intérieur, un menu : Rebirth · changer de classe/sous-classe · donjons & raids · boutique du
jeu · boutique Robux · tableau des missions · gérer familiers & cosmétiques · récupérer les
récompenses · coffre gratuit toutes les heures. Les autres feux de camp (tous les 50 km) ont
le même menu. Soin lent + petit bonus pour les prochains km. Maquettes 07 + 12.
```
`✓ Fini quand :` /design-review, on entre, le menu marche, rebirth impossible en combat (N6).

**F5 — HUD compétences + 3 pets** · `/team-ui` · dépend de F1, A3
```
Barre de 3 compétences centrée en bas (prête = bordure jaune + ▶, recharge = compte à rebours).
Les 3 pets dans la scène (Tank devant, DPS/Heal derrière). Teinte de danger 6 paliers sur le
nom de l'ennemi. Piste de couche pleine largeur en bas + ligne "→ prochain objectif". Maquette 03.
```
`✓ Fini quand :` /design-review vs maquette 03.

**F6 — Inventaire complet** · `/team-ui` · dépend de F1, C5, D5
```
Plein écran. Gauche : 6 slots équipés (bordure = rareté). Centre : grille 100, bordure de
rareté, tri par emplacement, filtres de ramassage auto SUR LA PAGE (rareté min + cases
Guerrier/Mage). Droite : comparaison (deltas vert/rouge). Bas : panneau de set + totaux
ATK/DEF/RES/PV. Fusion accessible ici. Vente rapide "< rareté". Maquette 06 + GAME_SPEC §1.2.
```
`✓ Fini quand :` /design-review vs maquette 06 + GAME_SPEC §1.2.

**F7 — Réglages + accessibilité** · `/team-ui` + [accessibility-specialist]
```
Volume, animations réduites, taille de texte (plusieurs crans), mode une main, moins de
clignotements (épilepsie), mot + symbole en plus de la couleur pour la rareté et le danger
(Q104/Q105).
```
`✓ Fini quand :` /design-review, chaque option a un effet visible.

**F8 — FTUE** · `/team-ui` · dépend de F2-F5
```
5 coach-marks : tenir à droite / le combat est auto / regarder les dégâts / ouvrir le sac et
équiper / mettre un point. À la fin : cadeau = 1er familier (Q5). Bouton "passer" → on perd le
cadeau (Q8). /studio-test un parcours complet.
```
`✓ Fini quand :` /studio-test — un nouveau joueur finit les 5 étapes et reçoit son familier.

---

### TRACK G — Systèmes de combat & progression

Dépend de C1-C3 + D1-D2. Features via `/team-combat`. `/studio-test` + `/exploit-check` +
`/remotes-audit` sur chaque nouveau système.

**G1 — Stats auto + points gagnés** · [luau-systems-programmer] · `/studio-test` `/balance-check` · dépend de D1
```
Refonte StatsService : stats dérivées de niveau × table (D1), plus le pool de points de
compétence GAGNÉS (permanents, alloués à la main, 1:1). Retire l'allocation manuelle au niveau
+ le coût SPD. Schéma save : stats{} devient dérivé (non stocké), nouveau earnedPoints{pool,
allocation}, subclass. Migration (bump de version, se règle avec B3).
```
`✓ Fini quand :` /studio-test — les stats montent seules, un point gagné s'alloue, /balance-check.

**G2 — Sources de points gagnés** · [luau-gameplay-programmer] · `/studio-test` · dépend de G1
```
Câble les sources (Q29) : +1 mission, +2 Donjon du Jour, +1 nouveau monstre (codex), +3 1er
kill d'un boss de couche, +2 nouvelle couche, bonus de complétion des 10 missions. TOUJOURS
via un événement serveur vérifié (jamais un "j'ai fini X" du client).
```
`✓ Fini quand :` /studio-test — chaque source crédite le bon nombre, /exploit-check.

**G3 — Moteur de compétences** · `/team-combat` · `/prototype` `/exploit-check` `/remotes-audit` · dépend de C3
```
/prototype d'abord la cadence. Puis : 3 slots, auto par défaut (se lancent dès prêts) + reprise
en main (Q17), cooldowns, pas de jauge de ressource (Q19), ciblage. Débloqués par des nœuds de
talents (G4). Réglage options auto/manuel (Q16).
```
`✓ Fini quand :` /team-combat livre, /exploit-check + /remotes-audit propres.

**G4 — Arbre de talents** · `/team-combat` · `/exploit-check` · dépend de C2
```
3 branches (Fureur/Gardien/Tactique) × ~10+ nœuds, 1 pt / 5 niveaux, respec gratuit au feu de
camp. Certains nœuds débloquent les compétences (G3). Au rebirth : le joueur choisit garder OU
échanger contre un bonus (Q32).
```
`✓ Fini quand :` /team-combat livre, respec testé, /exploit-check.

**G5 — Sous-classes** · `/team-combat` · dépend de C2, G1
```
Choix au R5 (Berserker/Gardien, Destructeur/Sage) : nouvelle table de stats (D1) + un pouvoir
+ un look de héros différent. Re-choix aux jalons /5. Avant R5 : table "de base".
```
`✓ Fini quand :` /studio-test — au R5 on choisit, la table change, le look change.

**G6 — Équipe de 3 pets** · `/team-combat` · dépend de C5
```
Équiper jusqu'à 3 (4 au R10). Rôle Heal/DPS/Tank déterminé au drop, la famille du monstre dit
quel rôle est le plus fort. Effet permanent (pas de pouvoir déclenché, Q56). Le soigneur soigne
EN combat (Q54). 0 pet = combat marche sans les bonus (Q111).
```
`✓ Fini quand :` /studio-test — 3 pets suivent le héros, chaque rôle a son effet.

**G7 — Moteur de mécaniques de boss** · `/team-combat` · `/prototype` `/exploit-check` · dépend de C3, A3
```
/prototype le timing d'interruption (~1,5 s). Puis : 2-4 phases (pastilles sur la barre de
vie), grosse attaque télégraphée à interrompre via une tuile de pouvoir recontextualisée (pas
le bon pouvoir = pas d'interruption, Q20), adds (tués un par un, Q23), enrage EN Cauchemar
seulement (Q22). Les 12 signatures (E1/C3). Dialogues (E2) à l'entrée / à la mort.
```
`✓ Fini quand :` /team-combat livre les 12 boss jouables, /exploit-check timing.

**G8 — Rebirth complet** · [luau-gameplay-programmer] · `/studio-test` `/datastore-review` · dépend de C2, D2
```
Mur de niveau 100 + 20×rebirths. Garde gear/familiers/points de départ/points gagnés/codex/
sous-classe ; perd niveau/stats/or/distance. Point de départ post-rebirth ≤ moitié du record
(Q36). Jalons R5/R10/R15/R20/R25/R30 (Q37). Bonus croissant (D2). Checkpoint auto à chaque feu
de camp (N1) ; mort = re-marche depuis le dernier feu de camp, monstres réapparus (N2).
```
`✓ Fini quand :` /studio-test un cycle complet, /datastore-review la migration.

**G9 — Mode Cauchemar** · `/team-combat` · `/balance-check` `/exploit-check` · dépend de D2, G7
```
Ladder par couche, infini. Déblocage : ~100 kills du boss d'une couche → Cauchemar I, ~25 de
plus par palier. Porte globale : boss Couche 6. Multiplicateurs (D2 : ennemis ×N, récompenses
×M). Enrage actif. En Cauchemar le héros avance tout seul (Q43). Cotes de rareté inchangées.
```
`✓ Fini quand :` /team-combat livre, /balance-check les multiplicateurs, /exploit-check
(farm-key, empilement).

---

## ══ GATE PHASE 2 ══ — première session jouable de bout en bout
Un nouveau joueur : chargement → menu → création → FTUE → combat → boss → feu de camp →
rebirth. `/gate-check` · `/tech-debt` · `/retrospective`.

---

### TRACK H — Systèmes de rétention

Dépend de C6-C7 + F4. Via `/team-economy` (inclut la revue exploit). `/datastore-review` sur
les nouveaux stores.

**H1 — Récompense quotidienne 7 jours** · `/team-economy` · `/datastore-review` · dépend de C6
```
Cycle Q77 (J1 boost → … → J6 set Épique non fusionnable de la zone sous le record → J7 arme
+30 % sur le gear de BOUTIQUE de la meilleure zone, non fusionnable). 48 h de grâce puis retour
J1. Badge qui pulse tant que non réclamé. UI : silhouette noire du J6 avant déblocage.
```
`✓ Fini quand :` /team-economy livre, /datastore-review le store de streak.

**H2 — Missions** · `/team-economy` · `/exploit-check` · dépend de C6
```
Chaîne de 10 missions/jour (7 faciles, 2 dures, 1 très dure), pool ~50. 1 reroll gratuit/jour.
Bonus de complétion des 10 = quelques points de compétence permanents. Non finies en 24 h =
récompenses + bonus perdus. Validation serveur de chaque objectif (jamais un "fini" du client).
Farm idle assumé (Q70).
```
`✓ Fini quand :` /team-economy livre, /exploit-check (auto-validation).

**H3 — Donjon du Jour** · `/team-combat` + `/team-economy` · `/exploit-check` `/datastore-review` · dépend de C6, G7
```
Par étages à difficulté croissante. 1 clé/jour (décrément atomique), mort = clé perdue (clés
sup via missions/raids/boss de donjon). 7 thèmes fixes de la semaine (lundi = A…). 5 salles +
boss, salles à défi (pas de soin, dégâts ×2), coffres optionnels risqués. Classement par étage
(OrderedDataStore), score = temps par étage, validation "temps impossible" serveur (Q84).
Reprise à l'étage max hebdo (stocké serveur). Forcé en vitesse ×1 (Q46). Top 100 = XP+or+1 pt
permanent ; top 10 = titre.
```
`✓ Fini quand :` /team-combat + /team-economy livrent, /exploit-check (bot, clés),
/datastore-review le classement.

**H4 — Donjon-raid solo** · `/team-combat` · dépend de H3
```
Version "raid" du lancement (N4) : un donjon spécial SOLO plus dur, boss de raid dédiés,
mécaniques renforcées. Source de clés de donjon + XP de pass. Le donjon dimensionnel R20 (Q37)
est ce mode.
```
`✓ Fini quand :` /studio-test — le raid solo est jouable et distinct du Donjon du Jour.

**H5 — Codex** · `/team-ui` + [game-designer] · dépend de C5, D3, E4
```
Cartes (découverte = art + nom, non découvert = silhouette). 10 kills → carte complète (Q58).
Bonus quand TOUTE une famille est complète (Q57), sans limite (Q59). Onglet Objets : tous les
objets du jeu en silhouette (Q60). Compteur de complétion global. Maquette 11.
```
`✓ Fini quand :` /design-review vs maquette 11, un kill met à jour la carte.

**H6 — Pass de saison S1** · `/team-economy` · `/monetization-model` `/datastore-review` · dépend de C7
```
8 semaines, ~50 paliers, piste gratuite (or, gemmes) + premium (rétroactif, 499 R$, confort +
cosmétiques — voir monetization.md §3.2). XP de pass (Q85 : ~rien sur mob faible, un peu boss
de zone, plus boss de donjon/raid, ÉNORME à chaque fin de 100 km une fois par saison ; le plus
rapide = les 10 quêtes du jour). Rien après le dernier palier (Q88).
```
`✓ Fini quand :` /team-economy livre, /monetization-model + /datastore-review.

**H7 — Classements + podium** · `/team-economy` · `/exploit-check` · dépend de C7
```
Classements all-time : meilleure distance, nombre de rebirths, palier de Cauchemar
(OrderedDataStore, serveur valide, ignore l'impossible). Podium à 3 statues au feu de camp =
top 3 distance DU SERVEUR courant (pas global), mis à jour auto. Paliers de Soutien
(Bronze/Argent/Or) non chiffrés, non classés, à partir des achats vérifiés (ProcessReceipt).
```
`✓ Fini quand :` /team-economy livre, /exploit-check (falsification de score).

**H8 — Ligne d'objectif + analytics** · [analytics-retention-specialist] · `/retention-analysis` · dépend de rien
```
Ligne "→ prochain objectif" dans le HUD (boss / feu de camp / nouvelle couche). AnalyticsService :
le schéma d'events (Q106 : arrivée, FTUE, 1er boss, 1er rebirth, 1er achat, lieux de mort,
usage pouvoirs/familiers/objets, durée de session, jour de churn) + funnel d'achat + wall_hit
(bloqué > N min sur le même km). Voir monetization.md §12.
```
`✓ Fini quand :` /retention-analysis valide le schéma, les events partent (test console).

---

### TRACK I — Monétisation

Dépend de B4 (ProcessReceipt) + H6 (pass). Via `/team-economy`. `/economy-audit` +
`/exploit-check` sur chaque produit.

**I1 — Game Pass (les 8)** · `/team-economy` · `/exploit-check` · dépend de B5
```
Pack de Départ 99 · ×2 XP 249 · ×2 Or 349 · Grand Sac 149 · Pass Vitesse 499 · VIP 699 ·
Collectionneur 999 · Bundle Ultimate 1799. Ownership serveur en cache (B5). Plafonds durs (×3,
sac 200, vitesse donjon ×1). Pass Vitesse = sélecteur ×1/×2/×3 côté client, serveur plafonne.
Prix scriptés via GetProductInfo. Voir monetization.md §3.1.
```
`✓ Fini quand :` /team-economy livre, /exploit-check (usurpation de pass, contournement de cap).

**I2 — Developer Products** · `/team-economy` · `/datastore-review` `/exploit-check` · dépend de B4
```
Sacs de gemmes 80/400/800/1700 · Coffre Cosmétique 99 / 449 · Boost WE ×2 48 h 79 · Jetons de
Fusion ×5 49 · Renommage 99 · Palier de Pass 39/149 · Supporter Pack 400. Tous via
ProcessReceipt idempotent (B4). Consommables crédités dans le profil. Voir monetization.md §3.3.
```
`✓ Fini quand :` /team-economy livre, un achat rejoué ne double pas, /datastore-review.

**I3 — Boutique cosmétique + coffre** · `/team-ui` + `/team-economy` · `/economy-audit` · dépend de I2
```
~30-40 cosmétiques au lancement (skins, auras de pet, styles de dégâts, mobilier de camp,
plaques) — Frames/dégradés/halos procéduraux (pas d'upload par item). Coffre : poids serveur
affichés, pitié ~20/~80, achat direct de chaque item en gemmes, PolicyService vérifié. Set
"Prestige" évolutif du Collectionneur (look indexé sur rebirths + palier Cauchemar). Maquette 10.
```
`✓ Fini quand :` /design-review vs maquette 10, /economy-audit (aucune stat), PolicyService OK.

**I4 — Prompts contextuels** · `/team-ui` · dépend de I1
```
Bannières calmes, sans minuteur : Grand Sac à 100/100 · ×2 Or après farm prolongé en zone
basse · Pass Vitesse pendant une longue auto-marche. Max 1/type/session, cooldown dur, JAMAIS
pendant un combat, JAMAIS en 1ère session (FTUE), jamais plein écran non-skippable.
```
`✓ Fini quand :` /design-review, un test montre le cooldown et l'absence de prompt en FTUE.

**I5 — Roblox Premium** · [monetization-lead] · dépend de rien
```
Détection MembershipType : +10 % or (fondu dans le cap ×3, ne le dépasse jamais) + coffre
quotidien de feu de camp d'un cran supérieur + cadre "Premium".
```
`✓ Fini quand :` /studio-test — un compte Premium reçoit les 3 avantages.

---

## ══ GATE PHASE 4 ══ — monétisation en place et éthique
`/economy-audit` complet · `/exploit-check` complet sur les systèmes payants ·
`/monetization-model` audit · `/gate-check`.

---

### TRACK J — Polish & QA

Dépend de F + G. Le gros passe par `/team-polish`.

**J1 — Passe de polish** · `/team-polish`
```
La passe complète : animations UI (tweens d'ouverture, transitions), game-feel (screen shake
léger au crit, punch sur le kill, feedback tactile), micro-interactions. Rien qui crée des
instances par frame.
```
`✓ Fini quand :` /team-polish livre, /perf-profile OK.

**J2 — Son** · [audio-director + sound-designer]
```
Bibliothèque Roblox uniquement (Q103). SoundService + SoundGroups + sliders (dans F7). SFX :
coup, crit, kill, drop (par rareté), level-up, boss (télégraphe, interruption, phase, enrage),
UI. Musique par biome (12 pistes de la bibliothèque, une par couche).
```
`✓ Fini quand :` chaque événement a son son, les groupes/sliders marchent.

**J3 — VFX** · [technical-artist]
```
Pool de dégâts flottants (jaune / rouge crit — aucune instance créée par frame). Annonce de
rareté au drop (texte flottant coloré + son). Télégraphe de boss (jauge rouge + bordure de
scène + flash de bord). Carte de transition de couche. Low-HP vignette (déjà là) + effet de
Rebirth.
```
`✓ Fini quand :` /perf-profile — 60 fps mobile avec les VFX, pool jamais dépassé.

**J4 — Perf** · [performance-analyst] · `/perf-profile`
```
/perf-profile : Heartbeat serveur < 33 ms, client > 30 fps mobile (60 cible), mémoire < 800 Mo
mobile, aucune instance GUI créée par frame, réseau < 50 KB/s/joueur. Optimise les points chauds.
```
`✓ Fini quand :` /perf-profile vert sur les 5 cibles.

**J5 — Tests TestEZ** · [qa-tester] · `/test-plan`
```
Tests unitaires sur la logique métier : StatsService (croissance, points gagnés),
LootService (tables, taux), EquipmentService (fusion, sets), RewardService.multiplier
(max() pas produit, plafonds), ProcessReceipt (idempotence). Mock DataStore/HttpService.
Edge cases (Annexe B du GDD maître).
```
`✓ Fini quand :` la suite passe en CI, couverture des 12 edge cases.

**J6 — QA multi-appareil** · [qa-lead + qa-tester] · `/qa-pass`
```
Parcours complet sur Android / iPhone / iPad / PC émulés : lisibilité, coin ☰ dégagé, safe
area, cibles ≥ 44 px, clavier QWE+AD sur PC, aucun texte tronqué. Rapporte les bugs dans
production/bugs/.
```
`✓ Fini quand :` /qa-pass — aucun bug bloquant sur les 4 familles d'appareils.

---

### TRACK K — Durcissement

Dépend de tout. Les audits complets, post-implémentation.

**K1** · [exploit-security-specialist] · `/exploit-check`
```
/exploit-check complet : tous les remotes, duplication (objets/familiers/clés/gemmes/points),
abus de multiplicateurs, bots (Donjon par étages, missions), contournement de game pass,
falsification de classement, ProcessReceipt. Les 5 protections non-négociables de l'audit de
monétisation confirmées.
```
`✓ Fini quand :` /exploit-check — 0 critique, 0 élevé non traité.

**K2** · [datastore-architect] · `/datastore-review`
```
/datastore-review complet : session locking, tempête BindToClose (8 joueurs), migration de
schéma (version + switch), chemin "DataStore indispo" jouable avec bandeau (Q109), retry
backoff, budgets. ProfileStore adopté OU custom durci — trancher, loguer.
```
`✓ Fini quand :` /datastore-review propre, tempête testée, migration testée.

**K3** · [game-designer + economy-designer] · `/balance-check`
```
/balance-check playthrough final complet, en jeu cette fois (pas que tableur) : le jeu est-il
DUR mais pas impossible ? un f2p finit-il tout ? les murs tombent-ils au bon moment ? Ajuste,
logue.
```
`✓ Fini quand :` /balance-check vert, feeling validé par le proprio en Play test.

**K4** · [qa-lead] · dépend de J5
```
Les 12 edge cases de l'Annexe B du GDD maître, testés un par un en Studio (déco en plein boss,
DataStore down, rebirth en combat refusé, 0 pet, sac plein au drop de boss, checkpoint > moitié
record, quitter à PV bas, crit > 100 %, grands nombres, swap d'arme mid-run, receipt rejoué,
farm AFK plafonné).
```
`✓ Fini quand :` les 12 se comportent comme documenté.

---

## ══ GATE ══ — K vert
`/gate-check` · `/milestone-review` · `/doctor`.

---

### TRACK L — Publication (compte débanni)

**L1 — Place & universe** · [release-manager]
```
Configure l'expérience Roblox : nom, description, icône (générée), 3 thumbnails (rendus
composites), liens sociaux, structure d'univers. Paramètre de maturité adapté (10-16 ans,
combat léger non gore, achats). Clé Open Cloud pour la publication.
```
`✓ Fini quand :` la place existe, configurée, non listée.

**L2 — CI/CD** · [devops-engineer]
```
GitHub Actions : build Rojo, lint selene + stylua, tests TestEZ. Sur push d'un tag `v*` :
publish sur la place via Open Cloud. `.github/workflows/` + `aftman.toml` à jour.
```
`✓ Fini quand :` un push de tag publie une build vérifiée.

**L3 — Checklist de publication** · `/team-release`
```
/team-release : la checklist complète (place config, IDs de produits, badges, RemoteEvents
validés, ProcessReceipt, session lock, BindToClose, pas de secret client, purchase via
ProcessReceipt, mouvement validé serveur — cf. GAME_SPEC §9 + master-gdd §10).
```
`✓ Fini quand :` /team-release — la checklist est 100 % verte.

**L4 — Soft launch** · [producer + analytics-retention-specialist]
```
Ouverture non listée / amis pendant quelques jours. Surveille : D1, funnel FTUE, lieux de
mort (wall_hit), plantages Lua, session length du segment "Pass Vitesse ×3 + auto" vs f2p.
Corrige les S0/S1.
```
`✓ Fini quand :` 3-5 jours de données propres, aucun S0/S1 ouvert.

**L5 — Public** · `/team-release` · dépend de L4
```
Passage public : badges d'accomplissement (1er boss, 1er rebirth, La Descente finie, Cauchemar
V), monitoring en place, plan de contenu post-lancement armé (couches 13-15 dans le mois, ~1
couche + 1 set de raid / 2 semaines, nouvelle saison / 8 semaines).
```
`✓ Fini quand :` le jeu est public, le monitoring tourne, le calendrier de contenu est écrit.

---

## E — Ordre de travail recommandé (parallélisation concrète)

**Vague 1 (maintenant, tout en parallèle) :**
- Moi (fil principal) : **A1 → A2 → A3 → A4** (assets dans le jeu — la valeur la plus visible).
- Subagent `lead-programmer` : **B1, B6** (dev mode + les 4 bugs — indépendants).
- Subagent `datastore-architect` : **B3, B4** (saves + ProcessReceipt).
- Subagent `remotes-networking-specialist` : **B2** (rate-limit).
- Subagent `technical-director` : **B5** (resolver).
- Subagent `game-designer` : **C1 → C8** (les 23 GDD, en série interne).
- Subagent `economy-designer` : **D1 → D6** (le modèle chiffré).
- Subagent `narrative-director` : **E1 → E4** (le narratif).

**Vague 2 (après le GATE PHASE 1) :**
- `ui-programmer` team : **F1 → F8**.
- `luau-gameplay-programmer` team : **G1 → G9**.

**Vague 3 (après le GATE PHASE 2) :**
- `live-ops-specialist` team : **H1 → H8**.
- `monetization-lead` team : **I1 → I5**.

**Vague 4 :** **J**, puis **K**, puis **L**.

Chaque subagent rapporte un plan + des extraits, le proprio valide, l'agent construit, `/studio-test`,
commit après OK. Aucun commit sans accord explicite.

---

## F — Catalogue des skills (rappel)

51 skills dans `.claude/skills/`. Les **`/team-*`** construisent une feature de bout en bout ;
les autres sont des portes de validation.

| Catégorie | Skills |
|---|---|
| Construire | `/team-combat` `/team-ui` `/team-economy` `/team-polish` `/team-release` |
| Code & sécu | `/code-review` `/luau-lint` `/exploit-check` `/remotes-audit` `/datastore-review` `/perf-profile` |
| Design & éco | `/design-review` `/design-system` `/gdd` `/map-systems` `/balance-check` `/economy-audit` `/monetization-model` `/retention-analysis` |
| Planif & santé | `/project-stage-detect` `/doctor` `/sprint-plan` `/estimate` `/scope-check` `/gate-check` `/milestone-review` `/retrospective` `/tech-debt` `/prototype` `/brainstorm` |
| Studio (MCP) | `/studio-test` (après chaque changement de code) `/studio-inspect` `/studio-screenshot` |
| Non applicables | `/generate-asset` `/asset-from-image` (Blender/3D) · `/start` `/onboard` `/reverse-document` (projet déjà onboardé + GDD écrit) |

Documents de référence : `docs/plan/01-directors-cut.md` (vision) · `02-maquettes.md` (14
wireframes) · `03-sur-tous-les-ecrans.md` (multi-appareil) · `04-playbook-prompts.md` +
`05-ship-roadmap.md` (brouillons v1, remplacés par ce fichier).
