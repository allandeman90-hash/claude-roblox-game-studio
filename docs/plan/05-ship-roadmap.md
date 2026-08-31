# Quête Minute — Road to Launch (ship roadmap)

> Le chemin ordonné de « le core de combat tourne » à « un jeu qu'un inconnu installe, garde,
> et paie ». 8 phases, ~28 jours de travail focalisé.
> Artifact : `claude.ai/code/artifact/c3744d9e-0553-41b7-859d-63cac46bcdab`
>
> **Fondu dans [`00-plan-complet.md`](00-plan-complet.md)** (qui ajoute la vision, le cadre, les
> skills et les prompts). Conservé ici pour la vue « phases + portes + effort ».

Le core de l'auto-battler tourne déjà : combat serveur-autoritaire, traversée sur la ligne des
km, 12 boss nommés, équipement, loot, fusion, rebirth, checkpoints, boutiques, sauvegarde. Ce
qui manque, c'est *tout ce qui entoure la boucle*.

- **Départ :** 2026-08-31 · **Effort :** ~28 jours focalisés · **Fenêtre cible :** début–mi oct. 2026
- **Dépendance dure :** débannissement du compte Roblox (bloque seulement l'upload d'assets et la publication ; P0–P6 = local).

---

## Systems check

| État | Système |
|------|---------|
| ✅ | Combat loop · traversée · stats & dégâts · loot & fusion · rebirth · checkpoints & boutiques |
| ◐ | Contenu ennemi (1/12 zones) · équipement/sets (moteur ok, ~4 armes & 1 set) · persistance (DataStore custom, pas ProfileStore) · UI inventaire (liste + filtres, pas de grille 100) |
| ✗ | Menu titre · création de personnage · onboarding/FTUE · monétisation (stub revive désactivé) · systèmes de rétention · son & musique · décor de zone · config de publication |

---

## Les 8 phases

Effort : **S** ≤½j · **M** 1–2j · **L** 3–5j.

### P0 — Débloquer & stabiliser · Jour 1

Le build tourne propre, sauvegarde sûr, sans backdoor dev ni bug connu.

- Commiter le travail de combat en attente (5 fichiers → ~3 commits). **S**
- Strip des IDs d'assets modérés → fallback texte dans `AssetMap.luau`. **S**
- Retirer `DEV_MODE` + le chemin `devReset`. **S**
- Les 4 bugs : (a) dégâts sur le mauvais ennemi · (b) ligne xp/min illisible · (c) séparateur ZoneTrack 9-10 · (d) loot des boss de couche. **M**
- Décider la couche de sauvegarde : ProfileStore ou custom durci (version + migration + test BindToClose). **M**
- **UI shell — landscape lock + Roblox-HUD safe zone :** verrou paysage ; `TopbarInset` ; désactiver `PlayerList`/`Backpack` ; coin haut-gauche libre partout ; la grille 3 colonnes s'étire de phone-wide à 16:9. **S**
- Consolider le GDD maître (`design/gdd/master-gdd.md`) + `decision-log` + `risk-register`. **S**

**Porte :** playtest Studio start → boss → zone 2 sans erreur Lua, aucun remote dev, save/reload
vérifié, les 4 bugs corrigés, travail commité et poussé.

### P1 — Remplir le monde · Jours 2–6

12 zones réelles, une économie d'objets complète, des boss qui lâchent leur set.

- Rosters de zones 2–12 (3–4 ennemis chacun, multiplicateurs tunés). **L**
- 50 armes (25 Guerrier / 25 Mage ; boss à ×2.5 de la boutique). **M**
- 96 pièces d'armure + 12 sets (symétriques, taggés une identité). **L**
- 40 pets (rôle fixe, réparti sur les raretés). **M**
- Système de décor de zone (`applyZoneDecor` procédural, aucun upload). **M**
- Audit d'affichage des grands nombres (tout par `formatNumber`). **S**

**Porte :** un run km 0 → 120 sans « Zone N — Inconnu », chaque boss lâche une pièce de set de sa
zone en ~15 kills, le stock de boutique scale, aucun débordement de nombre.

### P2 — Première session · Jours 7–11

Un nouveau joueur est accueilli, fait un choix, apprend la boucle, veut un 2ᵉ run.

- Écran de chargement (`ReplicatedFirst`). **S**
- Menu titre (logo à gauche, actions à droite, jamais dans le coin réservé). **M**
- Création du héros (voie Guerrier/Mage + teinte + nom). **M**
- FTUE — 5 coach-marks du run 1 uniquement. **M**
- Menu réglages (volumes, mouvement réduit, contraste, taille des nombres). **S**
- Inventaire à la spec (GAME_SPEC §1.2 : grille 100, tri/filtre, compare, verrou, vente, fusion, ramassage auto en première page). **L**
- Écran château + échelle de déblocage tous les 5 rebirths. **M**

**Porte :** compte neuf → chargement → menu → création → run guidée → mort → restart → 2ᵉ run,
sans cul-de-sac ; l'inventaire fait chaque action de la spec ; un joueur qui revient tombe sur le menu.

### P3 — Raisons de revenir · Jours 12–15

Un hook quotidien, des objectifs visibles, une raison de battre son score d'hier.

- Récompense quotidienne (cycle 7 jours, streak, 48 h de grâce). **M**
- Missions (3 dailies d'un pool, reroll). **M**
- Codes (`/redeem`, table serveur, une fois par joueur). **S**
- Classements (meilleur km + rebirths via `OrderedDataStore`). **S**
- Ligne « prochain objectif » du HUD. **S**
- Couche d'analytics (`AnalyticsService` → events custom Roblox Analytics). **M**

**Porte :** un login jour 2 montre une récompense réclamable + des missions fraîches ; un code
donne de l'or une fois ; le classement se met à jour après un run ; les events analytics landent
dans le dashboard.

### P4 — Monétisation · Jours 16–19

Des options d'achat qui accélèrent ou élargissent — jamais bloquer.

- Note de design monétisation (`design/economy/monetization.md` : la règle). **S**
- Game passes (×2 Or, ×2 XP, Avance auto, +50 slots, VIP). **M**
- Dev products (packs d'or, Revive, Respec, Jeton de rebirth, Œuf/coffre à probas affichées). **M**
- `ProcessReceipt` durci (idempotent, `pcall`, accorde-persiste-enregistre). **M**
- Hooks `UserOwnsGamePassAsync` (StatsService, EquipmentService, CombatServer). **S**
- UI boutique + prompts contextuels (revive à la mort, +slots inventaire plein…). **M**
- Avantages Roblox Premium (+10 % or + daily exclusif). **S**

**Porte :** chaque pass et produit achetable via le flux de test, les octrois s'appliquent et
persistent au rejoin, `ProcessReceipt` survit à un double-fire, un playthrough gratuit passe le
boss de la zone 3.

### P5 — Feel & polish · Jours 20–23

Chaque action a du poids ; le look noir-et-mono est délibéré.

- Son : `SoundService` + SoundGroups branchés sur les sliders ; un lit musical par biome ; SFX sur chaque action. **M**
- VFX : hit-flash, screen-shake boss, burst de level-up, halo de rareté, wipe de rebirth. **M**
- Pool d'objets pour les nombres de dégâts (GAME_SPEC §12). **S**
- Carte d'intro boss + bannière de victoire + flash « NOUVEAU RECORD ». **S**
- Passe de motion/easing ; `prefers-reduced-motion` respecté. **S**
- QA mobile : locked landscape, safe-areas iOS (île sur le bord court), cibles ≥ 44 px, la grille 3 colonnes s'étire, texte qui scale. **M**

**Porte :** une session aveugle de 10 min « ressemble » à un jeu ; 60 fps sur un téléphone
milieu de gamme dans l'émulateur ; le mouvement réduit enlève shake/wipe.

### P6 — Durcir & QA · Jours 24–26

Ça survit aux exploiteurs, aux pannes DataStore, et à un playthrough complet.

- Audit de sécurité (`/exploit-check` : validation + rate-limit de chaque remote, aucune autorité client, ProcessReceipt idempotent). **M**
- Data : verrou de session, `version` + migration, `BindToClose` sous charge, chemin « DataStore down » jouable. **M**
- Performance : heartbeat < 33 ms à 8 joueurs, client < 800 Mo / > 30 fps mobile. **M**
- Tests (`tests/`, TestEZ) : math de combat, odds de loot, recettes de fusion, courbe de rebirth, formatage des nombres. **M**
- Passe de balance : zones 1–12 + une boucle de rebirth ; cible ~20 % de retraversée (GAME_SPEC §8.1), monétisation optionnelle partout. **L**
- Cas limites : inventaire plein, déco en plein boss, rebirth à km 0, DataStore froid. **M**

**Porte :** exploit-check propre, tests verts en CI, un playthrough documenté avec timings,
aucun bug S0/S1 ouvert.

### P7 — Publier · Jours 27–28 + · *bloqué jusqu'au débannissement*

Un place configuré, classé, découvrable, monétisation en ligne.

- Config du place : nom, description, genre RPG, icône 512², 3–5 miniatures, ~8 joueurs max.
- Questionnaire de maturité → « Légère » (violence dessin animé / fantasy).
- Creator Dashboard : créer les vrais IDs game pass + dev product → config ; badges (1er boss, km 25/50/100, 1er rebirth).
- Liens sociaux, un Discord, un groupe.
- CI/CD publish via Open Cloud (job dans `.github/workflows/ci.yml`) — **bloqué jusqu'au débannissement**.
- Soft launch : non-listé / amis, 2–3 jours de surveillance analytics + erreurs, hotfix.
- Lancement public : lister, poster, budget pub optionnel petit, outreach créateurs.

**Porte :** le place est public ; un inconnu peut join → jouer → acheter → rejoin avec ses
achats ; taux d'erreur < 1 % ; rétention D1 et funnel visibles dans les analytics.

---

## Contingence — le bannissement du compte

Deux images de boss générées (Béhémoth + son miroir, asset IDs `110357827868763`,
`121173451424136`) actionnées pour « contenu sexuel », appel rejeté. Studio coupé.

- **Bloque :** l'upload de tout nouvel asset, et la publication du place.
- **Ne bloque pas :** toutes les phases P0–P6 — travail local Studio + code, hors ligne.
- **Si ban à durée fixe :** ce calendrier tient — la date de lancement glisse à la date de débannissement.
- **Si ça escalade :** un compte neuf possède le place et refait les uploads avec un set d'art pré-relu (regens entièrement habillés). Le code et le design se reportent tels quels.
- **Chaque futur upload** reçoit un garde de prompt explicite : *« entièrement blindé, aucune peau nue, aucun décolleté, modeste »*, et une revue humaine avant de monter.

---

## Definition of « 100 % shippable »

- [ ] Zones 1–12 entièrement jouables — rosters réels, décor, scaling.
- [ ] 50 armes · 96 armures · 12 sets symétriques · 40 pets, tout droppable.
- [ ] Chargement → menu → création → run guidée, sans cul-de-sac.
- [ ] L'inventaire fait chaque action de GAME_SPEC §1.2, ramassage auto en première page.
- [ ] La boucle de rebirth tient la cible ~20 % de retraversée + un déblocage qualitatif tous les 5.
- [ ] Récompense quotidienne, 3 missions, codes, 2 classements en ligne.
- [ ] 5 game passes + ~10 dev products ; un joueur gratuit passe tout ; probas affichées.
- [ ] `ProcessReceipt` idempotent ; les octrois persistent au rejoin.
- [ ] Musique et SFX sur chaque action, branchés sur les réglages de volume.
- [ ] Exploit-check propre ; aucune autorité client ; chaque remote rate-limité.
- [ ] Couche de sauvegarde à verrou de session, version de schéma, BindToClose qui tient sous charge.
- [ ] > 30 fps et lisible sur un téléphone milieu de gamme, locked landscape.
- [ ] Plus de `DEV_MODE`, plus de remotes dev, plus d'assets modérés, tests verts en CI.
- [ ] Place configuré, classé, avec icône, miniatures, badges, Discord.

---

## Premiers 14 jours live

1. **Rétention D1 & D7** — le seul chiffre qui décide s'il faut continuer d'investir. Viser D1 > 12 %, D7 > 4 % pour un petit RPG neuf, puis grimper.
2. **Funnel** — join → 1er combat → 1er boss → 1er rebirth → 1er achat. La marche qui saigne le plus = tout le focus du sprint suivant.
3. **Durée de session médiane** et runs-par-session — la boucle tient-elle l'attention.
4. **ARPPU et taux de payeurs** — quel produit convertit, lequel est ignoré, quoi est mal prixé.
5. **Taux d'erreur / crash** (analytics + Developer Console) — au-dessus de 1 % = un hotfix, pas un backlog.
6. **Cadence de contenu** — sortir les zones 13–15 et un nouveau set de boss dans les 2 premières semaines.
