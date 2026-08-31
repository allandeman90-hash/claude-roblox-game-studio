# Quête Minute — Le Plan Complet

> Document de travail unique. Vision + cadre + catalogue des skills + ~50 prompts avec skills.
> Artifact : `claude.ai/code/artifact/4d515533-06b5-44dc-8816-2a57fefade53`

Tout en un : ce qu'on construit et pourquoi (Director's Cut), sur quel socle (100 % GUI,
paysage verrouillé, coin Roblox réservé), et l'ordre exact. Chaque tâche indique **quelles
skills du repo lancer**, porte son **intention de design**, le **prompt à coller** et le
critère de validation. Références visuelles : `02-maquettes.md`, `03-sur-tous-les-ecrans.md`.

---

## A — La vision

Garder la seule bonne partie de l'ancien GAME_SPEC — l'équipement — et transformer le reste :
d'un clone solo de 2014 en un jeu qu'on joue avec ses amis, où l'on revient chaque jour, et
dans lequel on dépense sans se sentir bloqué.

### Ce qu'on garde de GAME_SPEC — l'équipement, inchangé

- 6 slots · 5 raretés = pur multiplicateur · **niveaux d'objet indicatifs qui ne bloquent
  jamais** (parfait pour le rebirth : niveau 1 en stuff Lv.400).
- Sets Guerrier / Mage symétriques, bonus par paliers 2 / 3 / 4, même voie uniquement. DEF et
  RES viennent seulement du stuff.
- Fusion stricte du même objet exact — un filet, pas un raccourci (1 Mythique = 360 Communs).
- On l'étend seulement : l'échange et le transmog sont déjà supportés par la structure.

### Le pari

Garder l'identité **100 % GUI, instant, faible-input, paysage verrouillé** — quasi tous les
jeux Roblox sont des mondes 3D lourds, donc un bon jeu GUI est un différenciateur. Puis rendre
la GUI *profonde et sociale* au lieu de *minimale et solo*. Trois problèmes corrigés :
(1) solo → pas de boucle virale ; (2) combat 100 % passif → aucune décision ; (3) 12 zones
numérotées → rien de mémorable.

### Pourquoi ils restent

- Un run finit sur un **objectif suivant**, jamais un arrêt sec.
- **La mort est une progression** — l'XP est gardée. Le rendre lisible.
- **Le drop est la dopamine** — rareté annoncée fort au kill.
- Une raison d'ouvrir demain : récompense quotidienne + 3 missions.
- Le rebirth reste intéressant jusqu'à R20 via un déblocage tous les 5.

### Pourquoi ils paient

- Tout achat = **gain de temps, confort ou cosmétique**. Un joueur gratuit finit tout.
- Vendre dans la **friction ressentie** : revive à la mort, +50 slots inventaire plein,
  ×2 or au farm lent.
- **Pack de départ** unique, évident pour un nouveau joueur accroché.
- Passes permanents qui **récompensent les fidèles**.
- Probas affichées sur tout ce qui est aléatoire.

### Périmètre

**Sous-ensemble de LANCEMENT :** compétences actives · mécaniques de boss · équipe de 3 pets ·
« La Descente » + boss récurrents · codex · arbre de talents · bonus de collection · donjon du
jour · pass de saison · boutique cosmétique · passes de confort · passe de game-feel · classements.

**Différé v1.1–v1.2 :** feux de camp partagés · échange · Ascension · défis · raids co-op · crews.

---

## B — Le cadre technique

### Préambule — à coller au début de chaque session Claude Code

```
Projet : Quête Minute (RPG auto-battler 2D Roblox, repo local). On suit "Le Plan
Complet" — vision Director's Cut, cadre ci-dessous.

RÈGLES NON NÉGOCIABLES :
1. 100% GUI. Aucun monde 3D, aucun Humanoid, aucune caméra, aucun personnage.
2. Orientation VERROUILLÉE paysage. Le coin haut-gauche est réservé au HUD Roblox
   (bouton ☰ menu + chat) : jamais de bouton, texte lisible ou barre importante là.
   Lis GuiService.TopbarInset + GetGuiInset(). Désactive PlayerList et Backpack via
   StarterGui:SetCoreGuiEnabled. Infos de jeu centrées ou à droite, barre de PV
   joueur après le retrait.
3. Un seul ScreenGui : UDim2 Scale + UIAspectRatioConstraint + TextScaled +
   UITextSizeConstraint. La grille 3 colonnes s'étire de ~19,5:9 (téléphone) à 16:9
   (PC). Safe area iOS gérée. Entrées : tactile (tap tuiles) / clavier Q W E + A/D /
   manette — mêmes actions.
4. Serveur autoritaire pour TOUT état (or, xp, loot, stats, talents, achats,
   progression). Valide type + plage + cohérence de chaque argument de RemoteEvent.
   Rate-limit chaque action client. Aucun RemoteFunction client→serveur.
   ProcessReceipt idempotent.
5. Garde le système d'ÉQUIPEMENT de GAME_SPEC.md tel quel. Tout le reste suit le
   Director's Cut / ce plan.
6. N'uploade AUCUN asset (compte modéré). Fallback texte / Frames procéduraux.
7. Protocole : montre-moi un plan puis des extraits, demande avant Write/Edit,
   aucun commit sans mon accord explicite.
8. Style Luau : .claude/docs/luau-style-guide.md. task.wait/spawn/defer jamais
   wait/spawn/delay. pcall autour de tout appel de service externe. Services cachés
   en haut de module. Magic numbers dans GameConfig.
9. SKILLS DU REPO : utilise-les. Standard — /studio-test après chaque changement de
   code, /doctor après un changement structurel. Les /team-* orchestrent les bons
   agents pour une feature. Les audits (/exploit-check, /economy-audit,
   /datastore-review, /balance-check, /perf-profile, /remotes-audit) sont des
   portes de validation. Je précise lesquelles dans chaque prompt ; propose-en
   d'autres si pertinent. Ne servent PAS ici : /generate-asset, /asset-from-image
   (Blender/3D), /start, /onboard, /reverse-document.
10. Après chaque changement : pousse vers Roblox Studio via le MCP, /studio-test,
    lis la console, rapporte-moi toute erreur Lua.

Réponds "compris" et attends mon premier prompt.
```

### Rappels

| | |
|---|---|
| **Un ScreenGui** | Aucune version « mobile » séparée. |
| **Coin haut-gauche** | Réservé Roblox (☰ + chat). `GuiService.TopbarInset` = le rect exact. |
| **Coin haut-droit** | Libre : `PlayerList` + `Backpack` désactivés. |
| **iOS** | Île sur le bord court, barre d'accueil en bas. |
| **Serveur** | Heartbeat < 33 ms · client > 30 fps mobile · aucune instance GUI par frame. |
| **Pas d'upload** | Compte Roblox modéré. Texte / procédural jusqu'au déblocage. |

---

## C — Les skills du repo & quand les lancer

51 skills dans `.claude/skills/`, auto-chargées. Les 5 **`/team-*`** construisent une feature
de bout en bout (design → archi → implémentation → QA) ; les autres sont surtout des portes de
validation.

### Construire une feature — orchestration multi-agents

| Skill | Quand |
|---|---|
| `/team-combat` | toute feature qui touche le combat : mécaniques de boss (P1.6), équipe de 3 pets (P2.4), moteur de compétences (P2.5), donjon du jour (P3.6). |
| `/team-ui` | tout nouvel écran : menu (P2.2), création (P2.3), talents (P2.7), HUD compétences+pets (P2.8), FTUE (P2.9), réglages (P2.10), inventaire (P2.11), château (P2.12), UI donjon (P3.7), UI pass (P3.9), boutique (P4.5). Inclut l'accessibility-specialist → contraste, taille de texte, cibles ≥ 44 px. |
| `/team-economy` | tout ce qui touche l'or / les Robux : récompense quotidienne (P3.1), pass de saison (P3.8), game passes (P4.2), dev products (P4.3), cosmétiques (P4.4). Inclut la revue exploit (duplication, replay, valeur négative). |
| `/team-polish` | la passe de polish complète P5 (VFX, son, animations UI, QA feel). |
| `/team-release` | le lancement public P7.6. |

### Portes de validation — code & sécurité

| Skill | Quand |
|---|---|
| `/code-review` | après chaque module non trivial (P1.4, P1.7, P1.9, P2.6, P3.2, P3.5, P3.10, P3.11, P4.4, P4.7). |
| `/luau-lint` | P1.9, P6.4, périodiquement. |
| `/exploit-check` | P1.6, P2.5, P3.1, P3.3, P3.6, P4.2, P4.3, P4.6 — et l'audit complet en P6.1. |
| `/remotes-audit` | chaque nouveau RemoteEvent : P2.5, P3.3, P4.3 — et complet en P6.1. |
| `/datastore-review` | P0.8, P1.7, P3.1, P3.4, P3.6, P3.8, P4.3 — et complet en P6.2. |
| `/perf-profile` | P1.8, P5.5, P5.7, P5.8 — et complet en P6.3. |

### Portes de validation — design & économie

| Skill | Quand |
|---|---|
| `/design-review` | chaque écran vs sa maquette / la spec : P1.3, P2.11 (vs GAME_SPEC 1.2), P2.12. |
| `/design-system` | écrire le GDD d'un système avant de le coder : « La Descente » (P1.5), talents (P2.6), missions (P3.2). |
| `/balance-check` | P0.7, P1.1, P1.2, P1.4, P3.5 — et le playthrough complet P6.5. |
| `/economy-audit` | P1.2, P4.1, P4.2, P4.5, P4.6, P4.7 — et complet après P4. |
| `/monetization-model` | P4.1 (le workflow), P3.8 (structurer le pass), audit après P4. |
| `/retention-analysis` | P3.11 (schéma d'events + funnel), puis à chaque relevé post-lancement. |

### Planification & santé du repo

| Skill | Quand |
|---|---|
| `/gdd` | P0.10 — le GDD maître. |
| `/map-systems` | P0.10 — l'index des systèmes. |
| `/project-stage-detect` | P0.10, début de chaque phase. |
| `/doctor` | après tout changement structurel (P0.10, fin de P1, P7.4). |
| `/sprint-plan` · `/estimate` | début de chaque phase. |
| `/scope-check` | si on prend du retard. |
| `/gate-check` · `/milestone-review` | fin de chaque phase — go/no-go. |
| `/retrospective` | après chaque phase. |
| `/tech-debt` | après P2 et après P6. |
| `/prototype` | avant de coder un feeling incertain : timing d'interruption (P1.6), cadence des compétences (P2.5). |
| `/brainstorm` | optionnel — personnalités des 12 boss (P1.5). |

### Studio (MCP) — vérification en jeu

| Skill | Quand |
|---|---|
| `/studio-test` | après CHAQUE changement de code. |
| `/studio-inspect` | quand une structure d'instance semble cassée. |
| `/studio-screenshot` | vérif visuelle : P0.9, P1.8 (par couche), P2.2, P2.11, P5.7, P5.8 (par appareil). |

### Wiki Roblox/Luau

| Skill | Quand |
|---|---|
| `/wiki-query` | connaissance profonde : safe area iOS & TopbarInset (P0.9), OrderedDataStore budgets (P3.4), ProcessReceipt patterns (P4.3), MessagingService (social v1.1). |
| `/wiki-lint` | périodiquement. |
| `/wiki-ingest` · `/wiki-update` | quand une source est ajoutée dans `wiki/raw/`, ou pour corriger une page. |

### Release & live-ops

| Skill | Quand |
|---|---|
| `/publish-review` | P7.1, P7.2 — checklist pré-publication. |
| `/launch-checklist` | P7.5 — plan de soft launch + go/no-go. |
| `/release-checklist` | P7.6 — checklist complète. |
| `/changelog` · `/patch-notes` | P7.6 et à chaque mise à jour. |
| `/hotfix` | post-lancement — problème live urgent. |
| `/bug-report` | chaque bug trouvé en QA (P6.6) ou soft launch (P7.5). |

### Assets

| Skill | Quand |
|---|---|
| `/asset-audit` | P0.2, avant P7. |
| ~~`/generate-asset` · `/asset-from-image`~~ | NON — Blender / 3D. Le jeu est 100 % GUI. |
| ~~`/start` · `/onboard` · `/reverse-document`~~ | NON — projet déjà onboardé. |

---

## P0 — Débloquer & stabiliser (Jour 1)

Le build tourne propre, sauvegarde sûr, sans backdoor dev ni bug connu, et adopte le socle
paysage + zone réservée Roblox.

### P0.1 — Commiter le travail de combat en attente
**Skills :** `/studio-test`
**Pourquoi :** partir d'une base propre et poussée avant d'empiler.

```
P0.1 — 5 fichiers modifiés non commités (rebalance ennemis niveau-based, teinte de
difficulté 6 paliers, flash rouge <20% PV, retrait des portails, corrections HUD).
Relis git diff, propose ~3 commits (type(scope): description), montre-moi les
messages. Lance /studio-test pour confirmer que rien n'est cassé. Après mon OK :
commit + push sur master.
```
**✓ Fini quand :** git status propre, master poussé, /studio-test vert.

### P0.2 — Retirer les IDs d'assets modérés
**Skills :** `/asset-audit` `/studio-test`
**Pourquoi :** compte sanctionné ; aucune référence à un asset modéré/supprimé.

```
P0.2 — Dans AssetMap.luau, retire (ou fallback texte) : mob_harpie(_flip),
boss_golem_pierre(_flip), boss_behemoth(_flip), boss_colosse_cendres(_flip),
mob_zombie(_flip). Lance /asset-audit pour confirmer qu'aucune référence orpheline
ne subsiste dans src/. Vérifie que paintCombatant gère un id absent → étiquette
texte. /studio-test.
```
**✓ Fini quand :** /asset-audit propre, aucun carré noir au /studio-test, ces mobs/bosses en texte.

### P0.3 — Supprimer le mode dev
**Skills :** `/studio-test`
**Pourquoi :** le remote `devReset` laisse n'importe qui effacer sa progression — bloquant pour le ship.

```
P0.3 — Supprime définitivement DEV_MODE et "devReset" : CombatServer,
PlayerDataService, CombatClient (bouton DevReset + wiring). Grep "dev"/"DEV"/
"devReset". /studio-test pour confirmer.
```
**✓ Fini quand :** plus aucune référence, /studio-test OK, aucun reset joueur possible.

### P0.4 — Bug : dégâts sur le mauvais ennemi
**Skills :** `/studio-test`
**Pourquoi :** le 1er event "damage" arrive avant le 1er "update" → ancrage périmé.

```
P0.4 — Quand je frappe l'ennemi du milieu, le nombre de dégâts apparaît au-dessus
de l'ennemi 2. Corrige côté serveur : dans startEncounter (CombatServer), appelle
sendUpdate(player, st) AVANT resolvePlayerHit(player, st). Ne touche à rien
d'autre. /studio-test : le 1er coup sur le mob du milieu s'affiche bien au-dessus
de lui.
```
**✓ Fini quand :** /studio-test confirme le bon ancrage.

### P0.5 — Bug : ligne xp/min & or/min illisible
**Skills :** `/studio-screenshot`
**Pourquoi :** 4 lignes empilées dans une boîte prévue pour 2 → chevauchement.

```
P0.5 — HeroTimeBox empile 4 lignes dans une place pour 2. Agrandis-la (réduis un
peu HeroStatsBox) OU passe à 3 lignes : ZONE / "DIST %s (rec %s)" / "%s xp · %s or
/min". La logique de calcul du taux est correcte, ne la change pas. /studio-screenshot
pour vérifier la lisibilité.
```
**✓ Fini quand :** les 3 valeurs sont lisibles et se mettent à jour.

### P0.6 — Bug : séparateur étape 9–10
**Skills :** `/studio-screenshot`
**Pourquoi :** Tick10 mal placé par le template → étapes 9 et 10 collées.

```
P0.6 — Dans CombatClient, updateZoneTrack : positionne les 10 ticks par code —
Tick[i].Position = UDim2.new((i-1)/10, 0, 0.5, 0), garde leur Y/hauteur.
/studio-screenshot.
```
**✓ Fini quand :** 10 étapes régulièrement espacées, séparateur visible entre 9 et 10.

### P0.7 — Bug : le loot des boss de couche ne tombe pas
**Skills :** `/balance-check` `/studio-test`
**Pourquoi :** `bossIndex` n'est passé qu'aux BIG boss → les boss de couche ne lâchent jamais leur set.

```
P0.7 — Dans LootService.rollDrop, fais que CombatServer passe l'index de boss
(= couche, 1..12 cyclique) pour tout boss nommé, et que la table de set
correspondante soit tirée. GAME_SPEC 6.3 : UN seul tirage par kill. Lance
/balance-check sur les taux de drop de set. Test : tuer le boss couche 1 ~15×.
```
**✓ Fini quand :** /balance-check confirme les taux ; un set piece tombe sous ~15 kills couche 1 et 2.

### P0.8 — Couche de sauvegarde
**Skills :** `/datastore-review`
**Pourquoi :** le wrapper DataStore custom est plus risqué que ProfileStore à l'échelle ; la perte de données tue un jeu.

```
P0.8 — Lance d'abord /datastore-review sur l'existant. Puis : Option A adopter
ProfileStore (Wally, GAME_SPEC 11) ; Option B garder le custom + champ "version" +
switch de migration + test de tempête BindToClose (8 joueurs, kick simultané).
Montre-moi les 2 avec le coût, je tranche. Logue dans decision-log.md. Re-lance
/datastore-review après implémentation.
```
**✓ Fini quand :** /datastore-review propre, sauvegarde/rechargement + verrou de session testés, chemin "DataStore indispo" jouable.

### P0.9 — Socle UI : verrou paysage + zone réservée Roblox
**Skills :** `/wiki-query` `/studio-screenshot` `/studio-test`
**Pourquoi :** le HUD Roblox couvre le coin haut-gauche sur tous les appareils.

```
P0.9 — Lance /wiki-query "GuiService TopbarInset safe area iOS ScreenInsets" pour
la doc exacte. Puis mets en place le socle du préambule règle 2 : verrou paysage ;
SetCoreGuiEnabled(PlayerList/Backpack, false) ; un module client qui lit
TopbarInset + GetGuiInset() et expose un "safe rect" auquel RpgGui se cale ;
déplace au centre les infos du HUD actuellement en haut à gauche. /studio-screenshot
sur un petit écran émulé + /studio-test.
```
**✓ Fini quand :** /studio-screenshot montre le ☰ Roblox ne couvrant aucun élément important.

### P0.10 — GDD maître + registres + base
**Skills :** `/gdd` `/map-systems` `/project-stage-detect` `/doctor`
**Pourquoi :** une source de vérité unique, sinon on re-dérive les décisions à chaque session.

```
P0.10 — Lance /gdd (GDD maître : équipement de GAME_SPEC gardé tel quel + Director's
Cut + décisions de balance récentes + paysage-only + zone HUD Roblox). Puis
/map-systems pour design/gdd/systems-index.md. Remplis decision-log.md et
risk-register.md. Lance /project-stage-detect pour une base, et /doctor pour
vérifier que les compteurs README correspondent.
```
**✓ Fini quand :** le GDD couvre la V1, /doctor propre, je l'ai relu.

> **Fin de P0 :** `/gate-check` puis `/retrospective`. Avant P1 : `/sprint-plan` + `/estimate`.

---

## P1 — Remplir le monde (Jours 2–6)

12 couches réelles, une économie d'objets complète, des boss qui ont chacun une mécanique et une identité.

### P1.1 — Rosters d'ennemis, couches 2–12
**Skills :** `/balance-check` `/studio-test`
**Pourquoi :** seule la couche 1 a un roster aujourd'hui.

```
P1.1 — Dans ZoneConfig.luau, remplis Zones[2..12] : 3–4 ennemis chacun
{ name, id (slug texte ok), hpMul, atkMul, expMul, goldMul } calés pour un mélange
qui se sent (tank / canon de verre / rapide). Garde combatBaseForLevel intact.
Lance /balance-check sur le scaling résultant. /studio-test : run km 0→120.
```
**✓ Fini quand :** /balance-check OK, plus aucun "Zone N - Inconnu".

### P1.2 — 50 armes
**Skills :** `/balance-check` `/economy-audit`
**Pourquoi :** GAME_SPEC 4.4 demande 50 armes ; il y en a ~4.

```
P1.2 — EquipmentConfig.Weapons : 50 armes (25 Guerrier / 25 Mage), 2 tiers de
boutique par zone + armes de boss à ×2.5 de la puissance boutique de la même zone
(GAME_SPEC 7.2). Génère depuis une formule. Lance /balance-check (courbe de
puissance) et /economy-audit (cohérence des prix boutique).
```
**✓ Fini quand :** les deux audits passent ; boutique et drops cohérents zones 1–12.

### P1.3 — 96 pièces d'armure + 12 sets
**Skills :** `/design-review` `/balance-check`
**Pourquoi :** les sets sont le cœur de la profondeur (GAME_SPEC 5.1) ; il y en a 1.

```
P1.3 — EquipmentConfig.Armor + Sets : 12 sets × 4 slots × 2 voies = 96 pièces,
bonus Guerrier/Mage SYMÉTRIQUES, chaque set taggé une identité (offensif/defensif/
rapide/equilibre). Vérifie bossSetItems(index) et getStatBonuses (paliers 2/3/4,
même voie). Lance /design-review sur la symétrie + les identités, /balance-check
sur les valeurs.
```
**✓ Fini quand :** /design-review confirme la symétrie ; 2/3/4 pièces déclenchent les bons bonus, un mix 2G+2M rien.

### P1.4 — 40 pets + rôles
**Skills :** `/balance-check` `/code-review`
**Pourquoi :** avec l'équipe de 3 pets (P2.4), les pets deviennent la 2ᵉ moitié du build.

```
P1.4 — 40 pets, rôle FIXE par pet (DPS/Tank/Heal), répartis sur les raretés.
Effets Tank/Heal en POURCENTAGE. Vérifie rollPetDrop (~1.5% kill / 40% boss) et la
fusion. Prépare le champ pour l'équipe de 3 (P2.4). /balance-check (les %),
/code-review sur les nouveaux modules.
```
**✓ Fini quand :** des pets de chaque rôle droppent et fusionnent ; audits OK.

### P1.5 — « La Descente » : identité & boss récurrents
**Skills :** `/design-system` `/brainstorm`
**Pourquoi :** Director's Cut #10 — la ligne devient une descente dans la Faille, les boss deviennent mémorables.

```
P1.5 — Lance /design-system pour écrire design/gdd/descente-gdd.md : les 12 couches
(noms + lignes d'ambiance de la maquette #14), chaque boss = un personnage (name,
2–3 répliques de taunt, une rancune), la logique de boss récurrent (apparaît
affaibli → revient ~6 couches plus bas avec stats + mécanique complètes, répliques
en callback). Optionnel : /brainstorm pour les personnalités des 12 boss.
Data-driven dans ZoneConfig ; le combat lit juste name/dialogue/mechanic.
```
**✓ Fini quand :** le Roi Gobelin taunte couche 1 ; recroisé couche 7 plus fort, réplique qui rappelle la couche 1.

### P1.6 — Moteur de mécaniques de boss
**Skills :** `/prototype` `/team-combat` `/exploit-check` `/studio-test`
**Pourquoi :** Director's Cut #2 — une mécanique par boss transforme « regarder les chiffres » en « jouer le combat ».

```
P1.6 — 1) Lance /prototype pour tester le feeling de l'interruption (fenêtre
~1.5 s) dans prototypes/, sans standards de prod. 2) Une fois le timing bon, lance
/team-combat pour le moteur propre dans src/ : 4 primitives (frappe télégraphée /
bouclier à jauge / adds nettoyés par AoE / DoT nettoyé par pet Heal), data-driven
dans ZoneConfig, état de mécanique dans le payload, affichage client (maquette #04).
3) /exploit-check sur l'input d'interruption (rate-limit). 4) /studio-test.
```
**✓ Fini quand :** le Roi Gobelin télégraphe une frappe, l'interrompre l'annule, la rater fait très mal ; /exploit-check propre.

### P1.7 — Codex / bestiaire (backend)
**Skills :** `/code-review` `/datastore-review`
**Pourquoi :** Director's Cut #11 — transforme les kills en collection, donne un foyer au lore.

```
P1.7 — CodexService serveur : premier kill / première vue → entrée persistée. Chaque
famille (Bête/Mort-vivant/Élémentaire/Humanoïde/Construct) → +0.5% dégâts vs cette
famille, appliqué dans StatsService. Expose getCodex(player). /code-review sur le
service, /datastore-review sur la persistance.
```
**✓ Fini quand :** tuer un Loup débloque sa carte + le bonus, persiste ; audits OK.

### P1.8 — Décor de couche procédural
**Skills :** `/studio-screenshot` `/perf-profile`
**Pourquoi :** le bible d'art existe mais n'est pas implémenté ; sans upload, en Frames.

```
P1.8 — CombatClient : applyZoneDecor(couche) échange la palette des 3 couches de
parallaxe selon zone-art-direction.md, en décor 100% procédural (Frames), aucun
upload, statique, transition douce. /studio-screenshot par couche 1→5,
/perf-profile pour confirmer 60 fps.
```
**✓ Fini quand :** /studio-screenshot montre 5 ambiances distinctes, /perf-profile 60 fps.

### P1.9 — Audit d'affichage des grands nombres
**Skills :** `/luau-lint` `/code-review`
**Pourquoi :** les valeurs dépassent vite le million (GAME_SPEC 12).

```
P1.9 — Lance /luau-lint pour grep les string.format %d sur des valeurs
potentiellement > 1e6. Route tout affichage d'or/xp/stat/dégâts par formatNumber
(K/M/Md/T). tabular-nums où des chiffres s'alignent. /code-review sur les
changements. Simule un joueur riche (or ~5e9).
```
**✓ Fini quand :** aucun débordement de texte, tout reste lisible.

> **Fin de P1 :** `/doctor` (compteurs de contenu), `/gate-check`, `/retrospective`.

---

## P2 — Première session (Jours 7–11)

Un nouveau joueur est accueilli, fait un choix, apprend la boucle, veut un 2ᵉ run.

### P2.1 — Écran de chargement
**Skills :** `/studio-test`
**Pourquoi :** `ReplicatedFirst` est vide.

```
P2.1 — src/ReplicatedFirst : écran de chargement (logo + barre de progression)
pendant la réplication ; se retire sur game:IsLoaded() + délai mini. Style noir/
mono/bordure épaisse, paysage, coin haut-gauche libre. /studio-test.
```
**✓ Fini quand :** au join, chargement visible puis enchaînement propre vers le menu.

### P2.2 — Menu titre
**Skills :** `/team-ui` `/studio-screenshot`
**Pourquoi :** aucune porte d'entrée ; récompense du jour et pass visibles immédiatement.

```
P2.2 — Lance /team-ui pour le menu titre paysage (maquette #01) : logo à gauche, à
droite [▶ JOUER] + ligne stats + badge récompense du jour + barre de pass + 6
accès. HUD masqué tant que JOUER n'est pas pressé. JOUER reprend au dernier
checkpoint. Rien dans le coin haut-gauche. /studio-screenshot pour valider.
```
**✓ Fini quand :** un joueur existant voit le menu au join ; JOUER lance le run ; /studio-screenshot propre.

### P2.3 — Création du héros
**Skills :** `/team-ui`
**Pourquoi :** un seul choix qui compte (la voie) donne une identité de build dès la 1ʳᵉ minute.

```
P2.3 — Lance /team-ui pour l'écran de création (maquette #02), au tout premier join
seulement (flag seenCreation) : choix de voie (GUERRIER/MAGE), une teinte (4
gratuites), un nom filtré. "Commencer" accorde l'arme de tier 1 de la voie,
persiste, lance le tutoriel P2.9. Classe toujours pilotée par l'arme (GAME_SPEC 3.3).
```
**✓ Fini quand :** nouveau compte → création → run ; compte existant → menu direct.

### P2.4 — Équipe de 3 pets
**Skills :** `/team-combat` `/code-review` `/studio-test`
**Pourquoi :** Director's Cut #3 — les pets deviennent la moitié du build.

```
P2.4 — Lance /team-combat : passe d'1 slot pet à une ÉQUIPE de 3. equipe.pets[1..3]
persisté. StatsService additionne les 3 (DPS additifs, Tank/Heal en %). Chaque pet :
passif + compétence déclenchée (cooldown propre), data-driven. Client : 3 sprites
(Tank devant, DPS/Heal derrière). Étends la logique de rôles/dégâts, ne la change
pas. /code-review + /studio-test.
```
**✓ Fini quand :** 3 pets équipés → 3 sprites, effets appliqués, persiste.

### P2.5 — Moteur de compétences actives
**Skills :** `/prototype` `/team-combat` `/remotes-audit` `/exploit-check`
**Pourquoi :** Director's Cut #1 — le changement le plus important : « placer son burst avant le gros coup ».

```
P2.5 — 1) /prototype pour caler la cadence / le feeling des cooldowns. 2)
/team-combat pour le moteur serveur-autoritaire : 3 slots, config par voie
(Guerrier = Exécution/Rempart/Cri ; Mage = Météore/Barrière/Surcharge), RemoteEvent
"castAbility", effet calculé serveur, améliorées par les talents (P2.6). Payload
update = état des cooldowns. 3) /remotes-audit + /exploit-check sur castAbility
(rate-limit, aucun calcul client).
```
**✓ Fini quand :** les 3 compétences se lancent, cooldowns respectés, /remotes-audit + /exploit-check propres.

### P2.6 — Arbre de talents (backend)
**Skills :** `/design-system` `/code-review`
**Pourquoi :** Director's Cut #13 — une identité de build qui survit au rebirth.

```
P2.6 — Lance /design-system pour design/gdd/talents-gdd.md (2 arbres, 3 branches
Fureur/Gardien/Tactique, effets par nœud, déblocages de compétences). Puis
TalentService : 1 point tous les 5 niveaux, nœuds data-driven, respec GRATUIT au
feu de camp, persiste + SURVIT au rebirth, StatsService lit les effets, RemoteEvents
validés. /code-review.
```
**✓ Fini quand :** allouer/respec fonctionnent ; l'allocation reste après un rebirth ; /code-review OK.

### P2.7 — UI de l'arbre de talents
**Skills :** `/team-ui`
**Pourquoi :** le moment « dépenser un point » doit avoir une vraie décision (maquette #05).

```
P2.7 — Lance /team-ui pour l'UI plein écran (maquette #05) : onglets Guerrier/Mage,
3 branches côte à côte, nœuds (acquis/dispo/verrouillé), "▶" sur ceux qui
débloquent une compétence, carte de détail au tap, bouton Réinitialiser (grisé hors
feu de camp), compteur de points. Paysage, coin haut-gauche libre.
```
**✓ Fini quand :** navigable, allocation/respec via P2.6, lisible.

### P2.8 — Compétences + pets dans le HUD
**Skills :** `/team-ui` `/studio-test`
**Pourquoi :** c'est là que le combat devient un jeu (maquette #03).

```
P2.8 — Lance /team-ui : intègre au HUD (maquette #03) la barre de 3 compétences
centrée en bas (prête = bordure jaune + "▶", cooldown = compte à rebours, charge =
jauge) + indices clavier Q/W/E sur PC. Tap tuile / touche → castAbility. Bascule
Avant/Arrière conservée. /studio-test au tap et au clavier.
```
**✓ Fini quand :** je lance mes 3 compétences au tap et au clavier, cooldowns en direct.

### P2.9 — FTUE : 5 coach-marks
**Skills :** `/team-ui` `/studio-test`
**Pourquoi :** aucun onboarding aujourd'hui.

```
P2.9 — Lance /team-ui (ux-designer en tête) : tutoriel du 1er run seulement (flag
seenFtue), 5 coach-marks gatés un à la fois — (1) tiens droite, (2) le combat est
auto, (3) lis les dégâts flottants, (4) ouvre l'inventaire et équipe un drop, (5)
dépense un point de stat. Se termine au 1er feu de camp. Rien dans le coin Roblox.
/studio-test sur un nouveau compte.
```
**✓ Fini quand :** nouveau compte → 5 étapes sans blocage ; compte existant → aucun coach-mark.

### P2.10 — Menu réglages
**Skills :** `/team-ui`
**Pourquoi :** volume, mouvement réduit et lisibilité sont des attentes de base ; alimente P5.

```
P2.10 — Lance /team-ui : menu Réglages — volume Musique, volume SFX, mouvement
réduit (coupe shake + wipes), teinte de difficulté haute-visibilité, taille des
nombres de dégâts. Persisté côté client.
```
**✓ Fini quand :** chaque réglage a un effet immédiat et survit à un rejoin.

### P2.11 — Inventaire complet (GAME_SPEC §1.2)
**Skills :** `/team-ui` `/design-review` `/studio-screenshot`
**Pourquoi :** l'écran que le joueur ouvre le plus. Le backend existe dans EquipmentService.

```
P2.11 — Lance /team-ui pour l'inventaire plein écran paysage (maquette #06 +
GAME_SPEC 1.2) : 6 slots équipés à gauche (dont PET ×3) ; grille 100 cases (bordure
de rareté) ; tri rareté/puissance/set/récent ; filtre slot/set/voie ; tap objet →
comparaison (deltas vert/rouge) ; verrou ; "Vendre < [rareté] non équipé/
verrouillé" + confirmation ; fusion inline ; ramassage auto (rareté min + [ ]
Guerrier + [ ] Mage) VISIBLE sur la page ; totaux en bas. Découpe en 2–3
sous-tâches. Valide avec /design-review contre GAME_SPEC 1.2 et /studio-screenshot
sur téléphone + PC.
```
**✓ Fini quand :** /design-review confirme la conformité §1.2 ; chaque action fonctionne.

### P2.12 — Château + échelle de rebirth
**Skills :** `/team-ui` `/design-review`
**Pourquoi :** GAME_SPEC admet que le rebirth « devient monotone vers R15 ».

```
P2.12 — Lance /team-ui pour l'écran Château (maquette #12) : checkpoints 10 km,
panneau rebirth (coût, or, bonus), échelle des déblocages — R5 +1 rangée
d'inventaire, R10 débloque l'Ascension (hook), R15 garde un build de talents à
travers le reset, R20 checkpoint offert (hook). Implémente R5 et R15. /design-review
sur l'échelle.
```
**✓ Fini quand :** R5 donne la rangée ; l'écran affiche le prochain déblocage.

> **Fin de P2 :** `/tech-debt` (cataloguer la dette UI accumulée), `/gate-check`, `/retrospective`.

---

## P3 — Raisons de revenir (Jours 12–15)

Un hook quotidien, des objectifs visibles, une raison de battre son score d'hier. C'est le moteur de rétention.

### P3.1 — Récompense quotidienne
**Skills :** `/team-economy` `/datastore-review` `/exploit-check`
**Pourquoi :** la raison nº 1 d'ouvrir l'app demain.

```
P3.1 — Lance /team-economy : DailyRewardService, cycle de 7 jours croissant, streak
avec 48 h de grâce, réclamée au menu, autoritaire serveur via lastClaim (os.time
comparé au temps serveur). Badge qui pulse au menu. /datastore-review sur la
persistance, /exploit-check sur l'anti-triche horloge.
```
**✓ Fini quand :** jour 2 → réclamable une fois ; <48 h garde le streak, >48 h le remet à 1 ; audits OK.

### P3.2 — Missions quotidiennes
**Skills :** `/design-system` `/code-review`
**Pourquoi :** des objectifs concrets qui structurent la session.

```
P3.2 — /design-system pour design/gdd/missions-gdd.md (pool, récompenses, reroll).
Puis MissionService : 3 missions/jour, récompense or/xp, 1 reroll/jour, reset
serveur. Branche-toi sur les events déjà émis par CombatServer. UI simple au menu.
/code-review.
```
**✓ Fini quand :** les 3 s'affichent, progressent, se réclament, reset le lendemain.

### P3.3 — Codes promo
**Skills :** `/remotes-audit` `/exploit-check`
**Pourquoi :** un levier d'outreach créateurs bon marché.

```
P3.3 — CodeService : table serveur { code = { reward, expiry } }, une réclamation
par joueur (set persisté), RemoteEvent redeemCode. Petit panneau "Entrer un code"
au menu. /remotes-audit + /exploit-check sur redeemCode (rate-limit, replay).
```
**✓ Fini quand :** un code valide donne l'or une fois ; déjà utilisé / invalide → message clair ; audits OK.

### P3.4 — Classements
**Skills :** `/wiki-query` `/datastore-review`
**Pourquoi :** la spec les exclut ; c'est de la rétention gratuite.

```
P3.4 — /wiki-query "OrderedDataStore budget best practices". Puis LeaderboardService :
"meilleur km" et "rebirths", global, MAJ en fin de run / rebirth (pcall + budget),
affichés au menu + au feu de camp, + un classement "km cette saison" reset hebdo.
/datastore-review.
```
**✓ Fini quand :** finir un run met à jour mon entrée ; le top 10 s'affiche ; budget OK.

### P3.5 — Bonus de collection
**Skills :** `/balance-check` `/code-review`
**Pourquoi :** Director's Cut #15 — rend le farm de doublons et le stuff de voie opposée utile.

```
P3.5 — CollectionService : "4 pièces d'un set (toute rareté)" → passif permanent ;
"12 sets" → titre + cosmétique ; idem 40 pets. Appliqué dans StatsService, persiste.
S'appuie sur ownsItem/count. /balance-check sur les passifs, /code-review.
```
**✓ Fini quand :** compléter un set débloque son passif ; visible dans l'inventaire ; /balance-check OK.

### P3.6 — Donjon du jour (backend)
**Skills :** `/team-combat` `/exploit-check` `/datastore-review`
**Pourquoi :** Director's Cut #16 — un rituel quotidien court et compétitif : la meilleure primitive de rétention.

```
P3.6 — Lance /team-combat : DailyDungeonService, graine fixe/jour (date UTC), 5
salles + 1 boss, ~4 min, identiques pour tous, combat = moteur existant, chrono
serveur, butin Rare+ garanti, classement de temps du jour (OrderedDataStore), 1
tentative classée/jour. /exploit-check sur le timer/score, /datastore-review sur le
classement.
```
**✓ Fini quand :** 2 comptes lancent le même donjon ; finir enregistre un temps ; audits OK.

### P3.7 — UI du donjon du jour
**Skills :** `/team-ui`
**Pourquoi :** maquette #08.

```
P3.7 — Lance /team-ui pour l'UI (maquette #08) : chemin des 5 salles + boss (salle
courante allumée), chrono en direct vs record du jour, mini-classement, bandeau de
récompense, bouton ENTRER. Paysage, coin haut-gauche libre.
```
**✓ Fini quand :** navigable, reflète l'état de P3.6.

### P3.8 — Pass de saison (backend)
**Skills :** `/monetization-model` `/team-economy` `/datastore-review`
**Pourquoi :** Director's Cut #18 — le système à plus haut ROI de rétention *et* de revenu.

```
P3.8 — Lance /monetization-model pour structurer le pass (paliers, split gratuit/
premium, courbe d'XP). Puis /team-economy : SeasonPassService, saisons de 8
semaines, ~50 paliers, XP gagnée en jouant à tout, table de récompenses (gratuite :
or/œufs/gemmes ; premium : ~80% cosmétiques), achat premium RÉTROACTIF, persiste
progression + flag. Wiring de l'achat = P4.6. /datastore-review.
```
**✓ Fini quand :** jouer fait monter l'XP ; un palier octroie la récompense gratuite ; structure premium prête.

### P3.9 — UI du pass de saison
**Skills :** `/team-ui`
**Pourquoi :** la piste de paliers est naturellement horizontale — parfait en paysage (maquette #09).

```
P3.9 — Lance /team-ui pour l'UI (maquette #09) : piste de paliers horizontale, 2
rangées gratuite/premium, palier courant encadré (bord jaune), barre d'XP vers le
suivant, bouton [DÉBLOQUER LE PREMIUM] + note "rétroactif". Coin haut-gauche libre.
```
**✓ Fini quand :** reflète l'état de P3.8 ; le bouton premium ouvrira le prompt d'achat en P4.

### P3.10 — Ligne « prochain objectif » du HUD
**Skills :** `/code-review` `/studio-test`
**Pourquoi :** un run finit toujours sur un objectif suivant.

```
P3.10 — Dans le HUD, une ligne sous la boîte best-km/taux : le plus proche de
{ prochain checkpoint, prochain boss, prochain rebirth abordable }. Calcul serveur,
poussé dans le payload. /code-review + /studio-test.
```
**✓ Fini quand :** la ligne se met à jour en avançant et pointe le bon objectif.

### P3.11 — Couche d'analytics
**Skills :** `/retention-analysis` `/code-review`
**Pourquoi :** c'est comme ça que chaque décision post-lancement se prend.

```
P3.11 — Lance /retention-analysis pour définir le schéma d'events + le funnel qu'il
doit alimenter (join → 1er boss → 1er rebirth → 1er achat). Puis AnalyticsService :
events custom Roblox Analytics, pas de PII, un seul Analytics.log(name, props),
branché aux points clés. /code-review.
```
**✓ Fini quand :** les events apparaissent dans le tableau de bord après une session de test.

> **Fin de P3 :** `/gate-check`, `/retrospective`. Si en retard : `/scope-check`.

---

## P4 — Monétisation (Jours 16–19)

Des options d'achat qui accélèrent ou élargissent le jeu — jamais bloquer la progression. Un joueur gratuit finit tout.

### P4.1 — Note de design monétisation
**Skills :** `/monetization-model` `/economy-audit`
**Pourquoi :** la règle écrite, sinon la monétisation dérive vers le pay-to-win.

```
P4.1 — Lance /monetization-model (workflow complet : catalogue GamePass/DevProduct,
pricing, projections). Écris design/economy/monetization.md avec la règle — tout
achat = gain de temps/confort/cosmétique, aucun ne touche stat/DEF/RES/drop, joueur
gratuit finit tout. Lance /economy-audit sur le catalogue proposé. Je relis avant
P4.2.
```
**✓ Fini quand :** le doc existe, /economy-audit OK, je l'ai validé.

### P4.2 — Game passes (permanents)
**Skills :** `/team-economy` `/economy-audit` `/exploit-check`
**Pourquoi :** ils composent de la valeur plus on joue longtemps.

```
P4.2 — Lance /team-economy : ×2 Or, ×2 XP, Avance auto (dé-gate le fast-mode), +50
slots (100→150), VIP. Cache UserOwnsGamePassAsync (pcall, refresh sur
PromptGamePassPurchaseFinished). Hooks : StatsService, EquipmentService,
CombatServer. IDs en config. /economy-audit (pricing) + /exploit-check (hooks
d'ownership).
```
**✓ Fini quand :** simuler chaque pass applique l'effet et persiste ; audits OK.

### P4.3 — Dev products + ProcessReceipt
**Skills :** `/wiki-query` `/team-economy` `/remotes-audit` `/exploit-check` `/datastore-review`
**Pourquoi :** un `ProcessReceipt` non idempotent = double octroi ou perte d'achat.

```
P4.3 — /wiki-query "ProcessReceipt idempotency pattern". Puis /team-economy : packs
d'or (4 tailles), Revive (branche le stub, vrai productId), Respec, Jeton de
rebirth, Œuf/coffre (probas AFFICHÉES). ProcessReceipt : idempotent (clé purchaseId
persistée), pcall, accorde-persiste-enregistre, gère tous les productId,
PurchaseGranted seulement après sauvegarde. /remotes-audit + /exploit-check
(double-fire) + /datastore-review.
```
**✓ Fini quand :** chaque produit s'achète, l'octroi persiste, un double-fire n'accorde qu'une fois ; audits OK.

### P4.4 — Système de cosmétiques
**Skills :** `/team-economy` `/code-review`
**Pourquoi :** Director's Cut #19 — revenu cosmétique illimité et éthique.

```
P4.4 — Lance /team-economy : CosmeticService — skins de héros, auras de pet, styles
de nombres de dégâts, mobilier, plaques, effets de kill. Transmog : skiner un objet
sans changer ses stats. Inventaire cosmétique persisté, data-driven. Gacha (coffre)
ICI uniquement, table de probas exposée. Zéro impact puissance. /code-review.
```
**✓ Fini quand :** équiper un skin change l'apparence ; le style de nombres s'applique ; rien ne bouge côté stats.

### P4.5 — UI boutique + prompts contextuels
**Skills :** `/team-ui` `/economy-audit`
**Pourquoi :** vendre dans la friction ressentie convertit mieux qu'un menu statique.

```
P4.5 — Lance /team-ui pour la boutique (maquette #10) : onglets Skins/Auras/Effets/
Mobilier/Plaques + "Améliorations" (game passes), bannière Pack de départ, lien
"Voir les probabilités" sur le coffre. + Prompts contextuels via
PromptProductPurchase : Revive à la mort, "+50 slots" inventaire plein, bannière
"×2 or" au farm lent. Coin haut-gauche libre. /economy-audit sur l'ensemble.
```
**✓ Fini quand :** chaque achat via Prompt*, le prompt contextuel au bon déclencheur ; /economy-audit OK.

### P4.6 — Piste premium du pass de saison
**Skills :** `/exploit-check` `/economy-audit`
**Pourquoi :** ferme la boucle P3.8 — le premium est la piste de revenu du pass.

```
P4.6 — Branche l'achat du premium : dev product / game pass "Premium Saison N",
ProcessReceipt octroie le flag premium de la saison courante (rétroactif sur les
paliers atteints), persiste, fin de saison → flag réinitialisé. /exploit-check
(ProcessReceipt) + /economy-audit.
```
**✓ Fini quand :** acheter le premium au palier 12 débloque d'un coup les 12 récompenses premium.

### P4.7 — Avantages Roblox Premium
**Skills :** `/economy-audit` `/code-review`
**Pourquoi :** Roblox pousse le trafic Premium vers les jeux qui le récompensent.

```
P4.7 — Players:GetPremiumMembershipType + PremiumMembershipChanged : +10% d'or et
une récompense quotidienne exclusive, appliqués dans StatsService /
DailyRewardService, pcall. /economy-audit (impact) + /code-review.
```
**✓ Fini quand :** simuler un compte Premium donne le bonus d'or.

> **Fin de P4 :** `/economy-audit` passe complète + `/monetization-model` en mode audit ; `/gate-check` (un compte gratuit passe-t-il partout ?), `/retrospective`.

---

## P5 — Feel & polish (Jours 20–23)

Chaque action a du poids ; le look noir-et-mono est un choix, pas une pauvreté.

### P5.0 — Lancer la passe de polish
**Skills :** `/team-polish`
**Pourquoi :** `/team-polish` orchestre qa-tester → technical-artist → sound-designer → ui-programmer sur toute la phase. Les tâches P5.1–P5.8 sont son plan de travail.

```
P5.0 — Lance /team-polish sur tout le jeu. Le qa-tester joue et note chaque moment
qui sonne faux ; on priorise ensemble ; puis on exécute les tâches P5.1–P5.8
ci-dessous. Tout respecte le réglage "mouvement réduit" (P2.10). Aucun upload
d'asset — audio de la bibliothèque Roblox ou que tu possèdes.
```
**✓ Fini quand :** la liste priorisée est validée, P5.1–P5.8 planifiées.

### P5.1–P5.3 — Son : groupes + sliders, SFX, musique par biome
**Skills :** `/team-polish` `/wiki-query`
**Pourquoi :** `SoundService` n'est jamais touché ; un jeu muet ne « ressent » rien ; la musique par couche soutient « La Descente ».

```
P5.1–P5.3 — SoundGroups Musique + SFX branchés sur les sliders (P2.10), pool de
Sound réutilisables. SFX sur : coup, critique, kill, level-up, engagement de boss,
drop par rareté, achat, rebirth, interruption réussie (via les events serveur
existants). Un lit musical par groupe de couches + fondu enchaîné + musique de feu
de camp calme. /wiki-query "SoundGroup volume best practices" si besoin.
```
**✓ Fini quand :** les sliders agissent ; un combat de 30 s "sonne" juste ; la musique change en fondu par couche.

### P5.4–P5.7 — VFX, pool de dégâts, intro boss, game-feel GUI
**Skills :** `/team-polish` `/perf-profile` `/studio-screenshot`
**Pourquoi :** la liste §12 de GAME_SPEC est un plancher ; Director's Cut #22 va plus loin — tout GUI, tout pas cher, toute la différence.

```
P5.4–P5.7 — Effets GUI : flash de l'ennemi touché, court screen-shake sur coups de
boss, burst de level-up, halo de rareté au drop, wipe de rebirth. Pool recyclé pour
les nombres de dégâts flottants (GAME_SPEC 12). Carte d'intro boss (nom + taunt de
P1.5) + bannière de victoire + flash "NOUVEAU RECORD". Barre de vie de boss avec
pastilles de phase, flash de critique bref plein écran, faisceaux de butin par
rareté, hit-stop léger. Tout respecte "mouvement réduit". /perf-profile sur un
combat de boss chargé + /studio-screenshot.
```
**✓ Fini quand :** les coups "claquent", /perf-profile confirme pas de churn d'instances, mouvement réduit enlève shake/wipes.

### P5.8 — QA paysage / multi-appareil
**Skills :** `/studio-screenshot` `/perf-profile`
**Pourquoi :** le socle P0.9 doit tenir de ~19,5:9 à 16:9 sans rupture ni chevauchement du HUD Roblox.

```
P5.8 — /studio-screenshot dans l'émulateur d'appareils Studio : téléphone large,
iPad, PC. Vérifie : zones d'appui ≥ 44 px, coin haut-gauche jamais couvert
(TopbarInset), safe area iOS, la grille 3 colonnes s'étire sans rupture, TextScaled
lisible partout. /perf-profile sur mobile émulé (> 30 fps). Corrige ce qui casse.
```
**✓ Fini quand :** les 3 profils d'appareil sont propres et jouables ; /perf-profile OK.

> **Fin de P5 :** `/gate-check`, `/retrospective`.

---

## P6 — Durcir & QA (Jours 24–26)

Ça survit aux exploiteurs, à une panne DataStore et à un playthrough complet.

### P6.1 — Audit de sécurité complet
**Skills :** `/exploit-check` `/remotes-audit`
**Pourquoi :** tout ce qui vient du client est attaquable. Une seule faille d'autorité client ruine l'économie.

```
P6.1 — Lance /exploit-check (audit complet) puis /remotes-audit. Vérifie : chaque
RemoteEvent valide type/plage/cohérence et est rate-limité ; aucune autorité client
sur or/xp/loot/stats/talents/achats ; aucun RemoteFunction client→serveur ;
ProcessReceipt idempotent ; castAbility + input d'interruption plafonnés. Corrige
tout. Rapport dans production/security/.
```
**✓ Fini quand :** /exploit-check et /remotes-audit propres, corrections appliquées.

### P6.2 — Résilience des données
**Skills :** `/datastore-review`
**Pourquoi :** DataStore échoue régulièrement ; le jeu doit rester jouable et ne jamais dupliquer/perdre.

```
P6.2 — Lance /datastore-review (audit complet). Vérifie : verrou de session, champ
"version" + migration testée, BindToClose sauve tous les joueurs sous charge (8
joueurs, kick simultané), chemin "DataStore indispo → session non sauvegardée +
warning" jouable. Ajoute les tests manquants.
```
**✓ Fini quand :** /datastore-review propre, les 4 scénarios passent, documentés.

### P6.3 — Performance
**Skills :** `/perf-profile`
**Pourquoi :** cible 30 fps mobile ; un combat de boss + 3 pets + compétences est le pire cas.

```
P6.3 — Lance /perf-profile : heartbeat serveur < 33 ms avec 8 joueurs, client
< 800 Mo et > 30 fps sur mobile émulé, aucun churn d'instance GUI par frame.
MicroProfiler sur un combat de boss chargé. Optimise les points chauds. Rapport
dans production/perf-reports/.
```
**✓ Fini quand :** /perf-profile confirme les cibles, documenté.

### P6.4 — Tests automatisés (TestEZ)
**Skills :** `/luau-lint` `/code-review`
**Pourquoi :** la math de combat / les odds de loot / la fusion se cassent silencieusement au moindre refactor.

```
P6.4 — tests/ avec TestEZ : math de combat (mitigation, crit, cadence),
combatBaseForLevel, odds de la table de loot (statistique), recettes de fusion,
courbe de coût de rebirth, formatNumber, ProcessReceipt idempotent (mock). CI
(.github/workflows/ci.yml). /luau-lint sur les tests + /code-review sur leur
qualité (cas limites, pas juste le happy path).
```
**✓ Fini quand :** suite verte en local et en CI ; /code-review confirme la couverture des cas limites.

### P6.5 — Playthrough de balance
**Skills :** `/balance-check` `/economy-audit`
**Pourquoi :** valider la cible ~20% de retraversée post-rebirth (GAME_SPEC 8.1) et qu'un compte gratuit passe partout.

```
P6.5 — Playthrough complet couches 1→12 + une boucle de rebirth. Lance
/balance-check (courbes, murs) et /economy-audit (un compte gratuit passe le boss
couche 3 et fait un rebirth ; monétisation optionnelle du début à la fin). Note les
timings. Ajuste enemyPowerScale / mults de boss via GameConfig seulement si les
données le disent.
```
**✓ Fini quand :** les deux audits passent, playthrough documenté avec timings, pas de blocage.

### P6.6 — Cas limites
**Skills :** `/studio-test` `/bug-report`
**Pourquoi :** les bugs se cachent dans « inventaire plein », « déco en plein boss », « DataStore froid ».

```
P6.6 — Via /studio-test, teste : inventaire plein (drop refusé + message),
déconnexion en plein combat de boss, rebirth à km 0, checkpoint au-delà du max,
1ʳᵉ session avec DataStore froid, achat pendant une déconnexion. Pour chaque
anomalie, lance /bug-report (repro, attendu/observé, sévérité).
```
**✓ Fini quand :** chaque cas se comporte correctement, aucun crash / perte, bugs consignés.

> **Fin de P6 :** `/tech-debt` (catalogue final), `/gate-check` (porte polish → live), `/retrospective`.

---

## P7 — Publier (Jours 27–28 + · bloqué jusqu'au débannissement)

Un place configuré, classé, découvrable, avec monétisation en ligne.

### P7.0 — Pré-requis : débannissement
**Skills :** `/asset-audit`
**Pourquoi :** uploader d'autres assets pendant la sanction = strikes supplémentaires = risque de ban permanent.

```
P7.0 — Vérifie l'état du compte Roblox. Si toujours banni : ne rien uploader/
publier, on reste sur P0–P6. Si débanni : révoque puis régénère la clé Open Cloud
avant tout upload. Lance /asset-audit pour la liste des assets encore référencés.
Régénère au besoin les sprites à risque avec un prompt "entièrement blindé, aucune
peau nue, modeste", revue humaine avant upload.
```
**✓ Fini quand :** le compte est utilisable, la clé est neuve, /asset-audit propre.

### P7.1–P7.2 — Config du place + maturité de contenu
**Skills :** `/publish-review`
**Pourquoi :** une fiche complète + un classement « Légère » = plus de découverte et une audience plus large.

```
P7.1–P7.2 — Lance /publish-review (checklist pré-publication : DataStore, exploit,
perf, contenu, métadonnées, rollback). Configure le place : nom, description, genre
RPG, icône 512², 3–5 miniatures, ~8 joueurs max. Questionnaire de maturité →
"Légère". Guide-moi pour les étapes Creator Dashboard à faire moi-même.
```
**✓ Fini quand :** /publish-review passe, fiche complète, classification affichée.

### P7.3 — Creator Dashboard : IDs & badges
**Skills :** `/studio-test`
**Pourquoi :** les IDs de dev/pass en config ont besoin des vrais identifiants ; les badges sont des jalons partageables.

```
P7.3 — Crée les vrais game passes + dev products au Creator Dashboard, reporte
leurs IDs dans la config (P4.2/P4.3/P4.6). Crée les badges : 1er boss, km 25/50/
100, 1er rebirth, 1er donjon. Branche l'octroi serveur (pcall). /studio-test avec
les vrais IDs.
```
**✓ Fini quand :** chaque achat de test cible le vrai ID ; un badge se débloque en jeu.

### P7.4 — CI/CD de publication
**Skills :** `/doctor`
**Pourquoi :** publier à la main est source d'erreur ; ne publier que si les tests passent.

```
P7.4 — Job "publish" dans .github/workflows/ci.yml : build Rojo + publish via Open
Cloud sur push de tag, secret = nouvelle clé Open Cloud, ne publie que si les tests
P6.4 sont verts. Lance /doctor pour vérifier que tous les configs toolchain sont
valides.
```
**✓ Fini quand :** /doctor propre, un tag pousse une nouvelle version du place automatiquement.

### P7.5 — Soft launch
**Skills :** `/launch-checklist` `/retention-analysis` `/bug-report` `/hotfix`
**Pourquoi :** attraper ce qui casse en réel avant l'exposition publique.

```
P7.5 — Lance /launch-checklist (plan de soft launch, métriques, go/no-go). Place en
non-listé / amis seulement 2–3 jours. Lance /retention-analysis sur les premières
données (funnel join→1er boss→1er rebirth→1er achat). Pour chaque bug : /bug-report ;
pour un problème live urgent : /hotfix.
```
**✓ Fini quand :** 2–3 jours de données, hotfixes S0/S1 faits, go pour le public.

### P7.6 — Lancement public
**Skills :** `/team-release` `/release-checklist` `/changelog` `/patch-notes`
**Pourquoi :** le lancement n'est pas la fin — le suivi J+1/J+7 décide de la suite.

```
P7.6 — Lance /team-release pour orchestrer la sortie (vérif QA + sécu + perf, config,
publish). /release-checklist pour la checklist complète (marketing, comms,
monitoring). /changelog puis /patch-notes pour les notes de version joueur. Liste
le place, poste sur Discord/réseaux, outreach créateurs avec des codes (P3.3).
Suivi J+1/J+7 via /retention-analysis. Cadence de contenu : couches 13–15 + un set
de raid dans les 2 semaines.
```
**✓ Fini quand :** le place est public, un inconnu peut join → jouer → acheter → rejoin avec ses achats.

---

## ✓ « Jeu complet à 100 % »

- [ ] Couches 1–12 jouables de bout en bout — rosters réels, décor, scaling, boss à mécanique.
- [ ] 50 armes · 96 armures · 12 sets symétriques · 40 pets, tout droppable.
- [ ] Chargement → menu → création → 1ʳᵉ run guidée, sans cul-de-sac.
- [ ] 3 compétences actives + arbre de talents (respec au feu) + équipe de 3 pets, tous serveur-autoritaires.
- [ ] Inventaire à la spec §1.2, filtres de ramassage auto en première page.
- [ ] Rebirth qui tient la cible ~20 % de retraversée + déblocage qualitatif tous les 5.
- [ ] Récompense quotidienne, 3 missions, codes, 2 classements, donjon du jour, pass de saison (gratuite + premium).
- [ ] 5 game passes + ~10 dev products ; un joueur gratuit passe provablement partout ; probas affichées.
- [ ] `ProcessReceipt` idempotent ; les octrois persistent au rejoin.
- [ ] Musique + SFX sur chaque action ; VFX + game-feel ; mouvement réduit respecté.
- [ ] `/exploit-check` propre ; aucune autorité client ; chaque remote rate-limité ; sauvegarde à verrou + version + BindToClose.
- [ ] Paysage verrouillé ; coin HUD Roblox libre partout ; > 30 fps et lisible sur téléphone milieu de gamme.
- [ ] Plus de DEV_MODE, plus de remote dev, plus d'asset modéré, tests verts en CI, `/doctor` propre.
- [ ] Place configuré, classé, avec icône, miniatures, badges, Discord ; `/publish-review` passé.

> Après le lancement, l'ordre se pilote aux données via `/retention-analysis` : la marche du
> funnel qui saigne le plus devient le sprint suivant. Le bloc social lourd du Director's Cut
> (feux de camp partagés, échange, Ascension, défis, raids co-op, crews) se construit ici —
> `/team-economy` pour l'échange, `/team-combat` pour les raids, `/wiki-query` pour
> MessagingService — une fois qu'il y a des joueurs pour le remplir.
