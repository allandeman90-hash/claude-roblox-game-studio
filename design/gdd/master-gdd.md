# Quête Minute — Game Design Document maître

**Version :** 1.0
**Dernière mise à jour :** 2026-08-31
**Auteur :** game-designer (synthèse des décisions Q1–Q119 + N1–N6)
**Statut :** Draft — à relire par le proprio

Source de vérité unique. Rassemble : `GAME_SPEC.md` (équipement, gardé), `docs/plan/`
(vision Director's Cut), `design/reponses-consolidees.md` (119 réponses + N1–N6),
`design/economy/monetization.md`. En cas de conflit avec un fichier plus ancien, **ce GDD gagne**.

Les GDD par système (combat, progression, économie, familiers, donjon…) détaillent chaque
point ; ils sont listés en §4. Les valeurs chiffrées non figées sont marquées `[À CALER — P1.9]`.

---

## 1. Vue d'ensemble

**Concept :** un RPG auto-battler 2D, **100 % interface** (aucun monde 3D, aucun personnage
Roblox, aucune caméra), joué **en paysage**. Le héros descend « La Descente » — 12 couches
souterraines —, se bat tout seul, meurt, recommence plus fort. La mort est une progression.

**Genre :** RPG / idle / auto-battler / roguelite.

**Plateforme :** Roblox — mobile (Android/iOS), PC, tablette. Orientation **paysage verrouillée**.

**Public :**
- Primaire : 10–16 ans, amateurs de jeux de progression et d'idle (Anime Fighters, Pet Sim style
  de boucle, mais RPG).
- Secondaire : joueurs plus âgés qui veulent un jeu « posable » à faible input.
- Type Bartle dominant : **Achievers** (progression, records) ; secondaire Explorers (codex, sets).

**Durée de session cible :** 15–20 min. **Sessions/jour cible :** ~1,9.

**Serveur :** solo (pas de co-op au lancement) ; taille d'instance faible, le social vient en v1.1.

---

## 2. Piliers créatifs

1. **100 % GUI, instant, faible-input, paysage.** Presque tous les jeux Roblox sont des mondes
   3D lourds — un très bon jeu d'interface est un différenciateur. On tient un bouton pour
   marcher, le reste se joue au clic ou en automatique.
2. **La mort fait avancer.** On garde tout (niveau, or, XP, objets) ; on recule juste au dernier
   feu de camp. Un run finit toujours sur « la prochaine fois j'irai plus loin », jamais sur une
   punition sèche.
3. **Le drop est la dopamine.** Rareté annoncée fort au kill (texte flottant coloré). Un Mythique
   est un événement.
4. **Une couche de décisions actives.** Le combat est automatique, mais 3 pouvoirs, la posture de
   fuite face aux mobs, la préparation avant boss, le choix continuer/s'arrêter au donjon, et le
   moment du Rebirth donnent au joueur des choix qui comptent.
5. **Une raison d'ouvrir demain.** Récompense sur 7 jours à valeur croissante, 10 missions/jour,
   Donjon du Jour, pass de saison.
6. **Le coin haut-gauche reste libre.** Le HUD imposé de Roblox (☰ menu + 💬 chat) n'est jamais
   masqué ni recouvert d'élément important, sur aucun appareil.

---

## 3. Boucle de jeu

### Boucle 30 secondes
Marcher (tenir ◀ / ▶) → toucher un monstre → le combat démarre seul, le héros frappe en premier
→ échange de coups (pouvoirs en auto) → monstre mort → **tirage de butin + rareté annoncée** →
monstre suivant. Contre un mob normal : possible de reculer pour se soigner (2 %/s hors combat).

### Boucle 5 minutes
Traverser une étape de 1 km → tuer ~2 mobs par étape → monter de niveau (stats montent
automatiquement) → tous les 10 km : **combat de boss nommé** (2–4 phases, grosse attaque à
interrompre) → butin de set → couche suivante (carte plein écran 5 s) → nouveau décor, nouveaux
monstres.

### Boucle session (15–20 min)
Ouvrir → **menu d'accueil** (JOUER + récompense du jour + pass) → réclamer la récompense →
reprendre au dernier feu de camp → avancer, tuer un ou deux boss → au feu de camp (tous les
50 km) : soin, récupérer le coffre horaire, gérer familiers/talents, faire quelques missions du
jour → 1 run de Donjon du Jour (~4 min, 1 clé) → éventuellement un Rebirth au feu de camp →
fermer.

### Boucle méta (jours / semaines)
Monter le mur de niveau (`100 + 20×rebirths`) → **Rebirth** (garde gear/familiers/checkpoints,
remet niveau/or/distance) → jalons R5 (sous-classe), R10 (4ᵉ familier), R15/R20/R25/R30 →
compléter le **codex** → farmer les **sets** → débloquer le **mode Cauchemar** (après le boss
Couche 6) et le faire monter à l'infini → **pass de saison** (8 semaines) → grimper les
**classements** all-time.

---

## 4. Systèmes

| Système | Rôle | GDD détaillé |
|---|---|---|
| Cœur de jeu | Marche + combat auto + butin | `core-gameplay-gdd.md` |
| Combat | Résolution coup par coup, cadence, DEF/RES, fuite | `combat-gdd.md` |
| Pouvoirs actifs | 3 pouvoirs, auto ou manuel, cooldown, débloqués par talents | `abilities-gdd.md` |
| Mécaniques de boss | Phases, grosse attaque à interrompre, adds, enrage (Cauchemar) | `boss-mechanics-gdd.md` |
| Progression | Niveau, stats auto par classe/sous-classe, points de compétence gagnés | `progression-gdd.md` |
| Talents | 3 branches, 1 pt / 5 niveaux, respec gratuit au feu, débloquent les pouvoirs | `talents-gdd.md` |
| Sous-classes | Choix au R5 : Berserker/Gardien, Destructeur/Sage | `subclass-gdd.md` |
| Rebirth | Infini, jalons /5, bonus croissant, mur de niveau | `rebirth-gdd.md` |
| Mode Cauchemar | Ladder de difficulté par couche, infini, monstres ×3 / récompenses ×2,5 par palier | `nightmare-gdd.md` |
| Équipement | **De GAME_SPEC, inchangé** : 6 slots, 5 raretés = multiplicateurs, sets, fusion stricte | `equipment-gdd.md` (= GAME_SPEC §4-5) |
| Inventaire | 100 slots, filtres de ramassage auto sur la page, tri par emplacement | `inventory-gdd.md` |
| Familiers | Mini-versions des monstres, drop 0,5 %/0,1 %, rôle par famille, équipe de 3 (4 au R10) | `pets-gdd.md` |
| Codex | Carte par monstre (10 kills), bonus permanent quand une famille est complète | `codex-gdd.md` |
| Économie | Or (sink = Rebirth, courbe qui garde l'avance), gemmes (premium cosmétique) | `economy-gdd.md` |
| Feu de camp | Hub complet (tous les 50 km ; le km 0 = « le Château »), coffre horaire gratuit | `campfire-gdd.md` |
| Missions | Chaîne de 10/jour (7 faciles, 2 dures, 1 très dure), bonus de complétion en points | `missions-gdd.md` |
| Donjon du Jour | Par étages, difficulté croissante, 1 clé/jour, mort = clé perdue, classement par étage | `daily-dungeon-gdd.md` |
| Donjon-raid solo | Version « raid » light au lancement (donjon plus dur, boss dédiés). Co-op → v1.1 | `raid-gdd.md` |
| Récompense quotidienne | Cycle 7 jours à valeur croissante (J6 set Épique, J7 arme +30 %) | `daily-reward-gdd.md` |
| Pass de saison | 8 semaines, ~50 paliers, piste gratuite + premium (confort + cosmétiques) | `season-pass-gdd.md` |
| Classements | All-time : distance, rebirths, palier Cauchemar. Podium serveur au feu de camp | `leaderboards-gdd.md` |
| Monétisation | 8 Game Pass + Premium Saison + ~7 Developer Products. Plafonds ×3. | `design/economy/monetization.md` |
| FTUE | 5 coach-marks, cadeau de fin = 1ᵉʳ familier | `onboarding-gdd.md` |
| UI / UX | Un seul ScreenGui paysage, zone HUD Roblox réservée, accessibilité | `ui-ux-gdd.md` |
| La Descente (narratif) | 12 boss-personnages, dialogues 1ʳᵉ + 2ᵉ rencontre, cartes de transition | `narrative-gdd.md` |

---

## 5. Progression joueur

### 5.1 Niveau et stats

- 5 stats : **Force** (dégâts physiques, voie Guerrier), **Magie** (dégâts magiques, voie Mage),
  **Vie** (`PV max = Vie × 5`), **Vitesse** (cadence d'attaque), **Chance** (taux de critique).
- **Les stats montent automatiquement à chaque niveau**, selon un **tableau de croissance
  classe × sous-classe** `[À CALER — Q117, base : 5 points/niveau répartis en %]`.
- **1 point sur 5 reste libre** (le joueur oriente un peu son build).
- **DEF / RES** proviennent **uniquement de l'équipement**, jamais des stats. Guerrier = surtout
  DEF, Mage = surtout RES.
- Courbe d'XP : **géométrique ×1,35** — `xp_pour_niveau(n+1) = xp_pour_niveau(n) × 1,35`
  (code actuel : n1→n2 = 44, à recalibrer sur ×1,35).
- **Niveau maximum par vie = `100 + 20 × rebirths`.** Les ennemis continuent de scaler au-delà →
  ce mur EST la raison de faire un Rebirth. Le **1er mur doit tomber vers km 25-35 / jour 2-3**,
  après l'accroche.

### 5.2 Classe et sous-classe

- **Classe** = pilotée par l'arme équipée (épée → Guerrier, baguette → Mage). Changement de
  **type** d'arme **uniquement au feu de camp**.
- **Sous-classe** : choisie au **Rebirth 5** (1ᵉʳ jalon /5). Re-choix possible aux jalons /5
  suivants.
  - Guerrier → **Berserker** (Force + Vitesse) · **Gardien** (Vie + Force)
  - Mage → **Destructeur** (Magie + Chance) · **Sage** (Magie + Vie)
- Une sous-classe change le **tableau de stats**, donne **un pouvoir** en plus, et **un look
  différent** du héros.
- Avant R5 : tableau « Guerrier de base » / « Mage de base », neutre.

### 5.3 Points de compétence gagnés (permanents)

- **Jamais donnés au niveau.** Gagnés uniquement par du jeu actif :
  mission = 1 · Donjon du Jour = 2 · nouveau monstre découvert = 1 · 1ᵉʳ kill d'un boss de
  couche = 3 · atteindre une nouvelle couche = 2 · bonus de complétion des 10 missions du jour =
  `[quelques points]` · top 100 d'un étage de donjon = 1.
- Alloués à la main dans les 5 stats, **1:1 à plat** (Vitesse incluse, cap dur Vitesse 200).
- **Permanents — survivent au Rebirth.** Respec : coûte de l'or (ou Robux).
- **Pas de plafond global.** Justification : le Cauchemar monte en difficulté au même rythme.
- C'est ce qui fait que deux joueurs même classe/niveau ne sont pas identiques, et qui
  **récompense l'assidu, pas l'AFK-farmeur** (l'auto-farm ne progresse ni le codex, ni les
  missions à variété, ni le donjon).

### 5.4 Talents

- 3 branches (Fureur burst/crit · Gardien survie · Tactique pouvoirs+familiers).
- **1 point tous les 5 niveaux.** **~10+ talents par branche** `[Q116]`.
- Certains nœuds débloquent les **3 pouvoirs actifs** (choisis dans une liste plus grande).
- **Respec gratuit au feu de camp.**
- Par vie : au Rebirth, l'arbre se vide ; le joueur **choisit** de le garder OU de l'échanger
  contre un bonus.

### 5.5 Rebirth

- **Infini.** Coût en or : `10 000 × 2,2^(n-1)`.
- **Garde :** équipement, familiers, points de départ débloqués, points de compétence gagnés,
  codex, sous-classe. **Perd :** niveau, stats du niveau, or, distance.
- Après un Rebirth : point de départ au choix parmi les feux de camp débloqués, **plafonné à la
  moitié du record**.
- Bonus d'efficacité **croissant** : +10 % au R1, +12 % au R2, +14 % au R3, … (`+2 % de plus
  chaque rebirth`). +25 % XP par Rebirth conservé.
- Jalons `/5` : **R5** sous-classe · **R10** 4ᵉ slot de familier · **R15** branche de talents
  avancée (persiste à la mort) · **R20** donjon dimensionnel (mode de jeu, boss exclusifs) ·
  **R25** double spécialisation (2 sous-classes) · **R30** système de maîtrise.
- **Impossible pendant un combat** (le feu de camp est un lieu physique).

### 5.6 Checkpoints et mort

- **Checkpoint = automatique à chaque feu de camp** (tous les 50 km).
- **À la mort :** on garde TOUT ; on **re-marche** depuis le dernier feu de camp franchi, et
  **les monstres réapparaissent** (c'est la punition — au pire ~50 km à retraverser).
- Écran de mort : résumé (distance, record), fermé quand on veut. Boutons « Recommencer » et
  « Revivre » de même taille (pas de revive payante au lancement).

### 5.7 Mode Cauchemar

- Chaque couche a son ladder **Cauchemar I → II → III → …**, **infini**.
- **Porte globale :** battre le boss de la **Couche 6** une fois.
- **Déblocage par couche :** ~100 kills du boss d'une couche → Cauchemar I ; ~25 kills de plus
  par palier suivant. `[À CALER — P1.9]`
- **Par palier :** monstres **×3** (Vie + dégâts), récompenses (or, XP, points, drop familier)
  **×2,5**, cotes de rareté d'objet **inchangées**. `[À CALER]`
- Minuteur d'enrage sur les boss **uniquement en Cauchemar**.
- En Cauchemar, le héros **avance tout seul** (pleine vitesse).
- Permanent (survit au Rebirth). Remplace l'ancienne idée « Ascension ».

### Jalons temps → contenu

| Jalon | Cible | Heures jouées |
|---|---|---|
| Tuto fini + 1ᵉʳ familier | 1ʳᵉ session | 0,2 |
| 1ᵉʳ boss battu (Roi Gobelin, km 10) | 1ʳᵉ session | 0,5 |
| 1ᵉʳ mur de niveau (km 25-35) | Jour 2-3 | 1–2 |
| 1ᵉʳ Rebirth | Jour 2-4 | 2–4 |
| Sous-classe (R5) | Semaine 2-4 | 15–30 |
| Mode Cauchemar débloqué (boss C6) | Semaine 2-4 | 15–35 |
| Fin de la Descente (boss C12) | Semaine 4+ | 30+ |

---

## 6. Monétisation

Résumé — détail complet dans **`design/economy/monetization.md`**.

**Règle d'or :** on vend **la vitesse à laquelle on parcourt le tapis roulant** (XP, or, vitesse,
taux de drop, sac, auto-marche). On ne vend **jamais la position du curseur** (points de
compétence, rebirths, stats d'équipement, paliers de Cauchemar). **Un joueur gratuit finit tout
le contenu.**

**Game Pass permanents :** Pack de Départ 99 · ×2 XP 249 · ×2 Or 349 · Grand Sac 149 (→ 200
slots) · Pass Vitesse 499 (sélecteur ×1/×2/×3 + auto-marche) · VIP 699 · Collectionneur 999
(cosmétique évolutif) · Bundle Ultimate 1799.

**Saisonnier :** Premium Saison 499 R$ / 8 semaines, rétroactif.

**Developer Products :** sacs de gemmes (80/400/800/1700), Coffre Cosmétique (99 / 449, odds +
pitié + achat direct), Boost Week-end ×2 48 h (79), Jetons de Fusion ×5 (49), Renommage (99),
Palier de Pass (39/149), Supporter Pack saisonnier (400).

**Plafonds durs :** XP / Or / drop / drop-familier **×3** · Vitesse **×3** (donjon forcé ×1) ·
Sac **200** · `max(pass permanent, pass premium)`, jamais empilé.

**Jamais vendu :** points de compétence, rebirths, stats/DEF/RES/rareté/armes de boss, paliers
de Cauchemar en Robux, effet de familier, récompense J6/J7.

**Classement « Robux dépensés » → remplacé par des paliers de Soutien** (Bronze/Argent/Or), non
chiffrés, non classés.

---

## 7. Social

**Au lancement :**
- Solo. Aucun co-op, aucun échange, aucune guilde.
- **Classements all-time** : meilleure distance, nombre de Rebirths, palier de Cauchemar
  (serveur valide tout, ignore l'impossible).
- **Classement Donjon du Jour par étage** (le vrai ladder compétitif, forcé en vitesse ×1).
- **Podium à 3 statues** au feu de camp = top 3 distance **du serveur courant** (pas global),
  mis à jour automatiquement.
- Chat : `TextChatService` avec filtre (natif Roblox).

**Différé v1.1 – v1.2 :** feux de camp partagés (voir d'autres joueurs, chat de camp), échange
(fenêtre + confirmation + taxe), **raids co-op** (le « raid » du lancement est un donjon solo
plus dur), guildes / crews.

---

## 8. Métriques cibles

| Métrique | Plancher | Cible | Fort |
|---|---|---|---|
| D1 | 20 % | 27 % | 35 % |
| D7 | 6 % | 10 % | 14 % |
| D30 | 2,5 % | 4 % | 6 % |
| Durée de session | 10 min | 16 min | 25 min |
| Sessions / jour / DAU | 1,4 | 1,9 | 2,6 |
| Conversion payeur | 1,5 % | 3,5 % | 6 % |
| ARPPU | — | 500–700 R$ | — |
| Prise du Pack de Départ (des retenus J7) | 15 % | 30 % | 45 % |
| Attache Pass de saison (du MAU) | 3 % | 7 % | 12 % |

Ne pas lire conversion / ARPDAU avant **500 payeurs ou 14 jours**.

Analytics (`AnalyticsService`) : arrivée, FTUE fini, 1ᵉʳ boss, 1ᵉʳ Rebirth, 1ᵉʳ achat, lieux de
mort, usage pouvoirs/familiers/objets, durée de session, jour de churn, funnel d'achat,
`wall_hit` (bloqué > N min sur le même km). Pas d'A/B testing au lancement.

---

## 9. Plan de contenu

### Contenu de lancement
- **La Descente** : 12 couches nommées, décor + palette par couche, carte de transition 5 s.
- **12 boss-personnages** + **12 big boss** (tous les 100 km, façon boss de raid) + dialogues
  1ʳᵉ et 2ᵉ rencontre écrits pour les 12.
- **~72 monstres** (6 par couche). *(Assets générés — voir `assets/images/ASSETS-STATUS.md`.)*
- **50 armes · 96 armures** (12 boss × 4 pièces × 2 voies) · **~84 familiers** (mini-monstres +
  boss dorés).
- **Compétences actives** (liste + 3 slots) · **arbre de talents** (3 branches × ~10+) ·
  **sous-classes** (2 par classe).
- **Mode Cauchemar** (infini) · **codex** (familles + bonus) · **bonus de collection**.
- **Donjon du Jour** (par étages, 7 thèmes fixes de la semaine) · **donjon-raid solo**.
- **Récompense quotidienne 7 jours** · **10 missions/jour** (pool ~50) · **pass de saison** S1.
- **Boutique cosmétique** (~30-40 items) + **Coffre Cosmétique** · **passes de confort** ·
  **classements** + podium serveur.
- **FTUE** (5 coach-marks) · **accessibilité** (grosses écritures, une main, moins de
  clignotements, mot/symbole en plus de la couleur).
- **Boucle infinie** après la Couche 12.

### Post-lancement
- **Mois 1 :** couches 13-15. Correctifs de balance d'après les analytics.
- **Récurrent :** ~1 couche + 1 set de raid toutes les 2 semaines (le moteur de dépense
  end-game). Nouvelle saison de pass toutes les 8 semaines.
- **v1.1 :** feux de camp partagés, échange, raids co-op. Mode « formes » d'accessibilité.
  Éventuellement : revive payante (si les données montrent un rage-quit net).
- **v1.2 :** guildes / crews.

### Événements
Aucun au lancement. Cadence à définir après le soft launch.

---

## 10. Technique

### Architecture
- **Serveur autoritaire pour TOUT état** : or, XP, loot, stats, talents, points, achats,
  progression, position, cadence, vitesse, clés de donjon, étages, drop de familier.
- Chaque `RemoteEvent` client→serveur : validation type + plage + cohérence, **rate-limité**.
  Aucun `RemoteFunction` client→serveur.
- **`ProcessReceipt` idempotent** + registre des `PurchaseId` en DataStore.
- Sync : Rojo / Argon (aucun actif actuellement → push via Studio MCP).
- UI : **un seul `ScreenGui`** natif, `UDim2` Scale + `UIAspectRatioConstraint` + `TextScaled` +
  `UITextSizeConstraint`. Grille 3 colonnes paysage qui s'étire de ~19,5:9 (téléphone) à 16:9
  (PC). `ScreenGui.ScreenInsets = CoreUISafeInsets`.
- **Zone HUD Roblox réservée** : lire `GuiService.TopbarInset` + `GetGuiInset()` ; rien
  d'important dans le coin haut-gauche (☰ + chat). `SetCoreGuiEnabled(PlayerList/Backpack,
  false)` → coin haut-droit libre.

### Contraintes clés
- DataStore : max 4 MB/clé, `60 + joueurs×10` requêtes/min, cooldown 6 s/clé.
- **Persistance : ProfileStore** (session locking, `BindToClose` 25 s, retry backoff).
  Sauvegardes découplées des remotes (flag `dirty`, ≤ 1 écriture / 30-60 s).
- Perf : Heartbeat serveur < 33 ms · client > 30 fps mobile · **aucune instance GUI créée par
  frame** (pool pour les dégâts flottants).
- Sons : bibliothèque Roblox uniquement au lancement.
- Grands nombres : suffixes K / M / Md / T / … (ajouter des lettres au-delà de T).

### Résilience
- DataStore en panne : on laisse jouer avec un gros message « progression non sauvegardée ».
- Déconnexion en plein boss : réapparition **juste avant le boss, pleine vie, boss pleine vie**
  (pas de sauvegarde d'état de combat).
- Quitter à PV bas en combat : la mort est comptée dans le profil sauvegardé.

---

## Annexe A — Formules

```
PV max                 = Vie × 5
Cadence d'attaque       = playerAttackInterval(2,2) / (1 + max(0, Vitesse-1) × spdCadenceCoef(0,0171))
                          plancher 0,5 s (atteint à Vitesse 200)
Critique                = ×2 dégâts, taux ≈ Chance / 10000
Mitigation physique     = max(0,10 ; 100 / (100 + DEF))
Mitigation magique      = max(0,10 ; 100 / (100 + RES))
Regen hors combat       = 2 % PV max / seconde
Issue d'un combat       = on gagne ssi (PV_héros × DPS_héros) > (PV_ennemi × DPS_ennemi)
                          [pas de fuite pour les boss ; HP et ATK se composent]
XP niveau n+1           = XP niveau n × 1,35
Niveau max              = 100 + 20 × rebirths
Coût Rebirth n          = 10 000 × 2,2^(n-1)
Bonus efficacité Rebirth= +10 % + 2 % × (n-1)   [additif]
Stats ennemi            = combatBaseForLevel(niveau) où niveau ≈ km × 10 ; boss ×(hp 2,5 / atk 1,3)
Cauchemar palier k      = ennemis ×3^k (hp+atk) ; récompenses ×2,5^k   [À CALER — P1.9]
Multiplicateur d'achat  = max(pass_permanent, pass_premium_actif) ; plafond ×3 par catégorie
                          puis × cauchemar × bonus_rebirth (catégories gagnées, se multiplient)
```

## Annexe B — Edge cases (≥ 8, cf. `rules/design-docs.md`)

1. **Sac plein + drop de boss** → fenêtre « garder (vends un objet) ou jeter le neuf ? ».
2. **0 familier équipé** → le combat marche, sans les bonus.
3. **Déconnexion en plein boss** → réapparition avant le boss, tout à pleine vie.
4. **DataStore indisponible** → jeu jouable, gros bandeau « non sauvegardé », achats/Rebirth
   bloqués tant que ça ne sauve pas.
5. **Rebirth / changement de classe demandé pendant un combat** → refusé (feu de camp requis).
6. **Checkpoint sélectionné au-delà de la moitié du record après Rebirth** → clampé.
7. **Quitter à PV bas pendant un combat** → mort comptée à la sauvegarde.
8. **Crit rate > 100 %** (Chance très haute) → capé à 100 %.
9. **Grands nombres > 2^53** → capés (`statHardMax = 1e15`) ; affichage en suffixes.
10. **Changement de type d'arme mid-run** → interdit hors feu de camp (talents seraient de la
    mauvaise voie).
11. **Achat de Developer Product rejoué par Roblox** → `ProcessReceipt` idempotent, pas de
    double crédit.
12. **Farm AFK d'un mob sur place** → le respawn exige de s'éloigner de ~0,9 km ; kill-rate
    plafonné serveur ; les points de compétence ne se farment pas comme ça.

## Annexe C — Divergences assumées vs `GAME_SPEC.md`

| GAME_SPEC | GDD |
|---|---|
| §1 orientation portrait | **Paysage verrouillé uniquement** |
| §2 le tap accélère la cadence | **Auto-attaque seule** (tap retiré), le héros frappe en 1ᵉʳ |
| §3.1 5 points alloués librement au niveau | **Stats auto par classe/sous-classe** + pool de points *gagnés activement* |
| §6.1 niveau mob = km × 10 (courbe ×1,35/zone) | Stats mob **pilotées par le niveau** (`combatBaseForLevel`), pas la zone |
| §7.1 ×1,35 uniforme | Ennemis suivent le niveau ; équipement garde une courbe de zone ; or/XP suivent le niveau. Coût du Rebirth **garde l'avance** sur les gains d'or (Q64) |
| §8.1 « déblocage qualitatif /5 à définir » | **Défini** : R5 sous-classe, R10 4ᵉ familier, R15/R20/R25/R30 |
| §12 12 zones numérotées | **« La Descente »** : 12 couches nommées, boss-personnages récurrents |
| §13 monétisation exclue au lancement | **Incluse** (Director's Cut) — pass de saison, boutique cosmétique, passes de confort |
| §9 1 slot pet, 40 pets fixes à rôle attaché | **Équipe de 3** (4 au R10) ; familiers = mini-monstres, rôle Heal/DPS/Tank au drop, la famille détermine le rôle le plus fort |

## Annexe D — Direction visuelle & assets

- **Pixel art 16-bit**, vue 3/4 de face, pose statique unique (le moteur anime par tween).
  Palette plate ~20-24 couleurs, contour épais.
- **110 sprites/fonds générés et prêts** : 2 héros · 72 monstres · 12 boss (768²) · 12 big boss
  (1024²) · 12 fonds de couche (1920×1080). Voir `assets/images/ASSETS-STATUS.md`.
- Béhémoth (Couche 8) redessiné en **bête non-humanoïde** de pierre/os (l'ancien sprite avait
  été modéré). Voir mémoire projet.
- Familiers à générer par réduction des sprites monstres.
- Prochaines étapes assets : atlas 1024² → upload Open Cloud → `AssetMap.luau`.
- Cosmétiques : Frames / dégradés / halos procéduraux (pas d'upload par item).

---

*Fin du GDD maître v1.0. Les valeurs `[À CALER — P1.9]` passent par `/balance-check` sur tableur
avant tout code. Le jeu doit être **dur — pas impossible, pas facile**.*
