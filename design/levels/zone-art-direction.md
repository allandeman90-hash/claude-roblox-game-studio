# Direction artistique des zones — Quête minute

> **Règle fondatrice :** le décor de chaque zone est **entièrement dérivé de son boss de fin de zone**.
> Le boss est la référence artistique : environnement, palette, ambiance, météo, végétation,
> rochers, structures, atmosphère. Le joueur doit avoir l'impression de **traverser le
> territoire du boss et de se rapprocher de son domaine**.
>
> Le décor s'inspire du boss — il ne montre **jamais** le boss lui-même dans le fond.

**Maille :** 1 zone = 10 km = 1 boss nommé. Zones 1-12 → les 12 `ZoneConfig.BossThemes`.
Au-delà de la zone 12, la liste des boss recycle (les décors aussi).

**Statut de définition :**
- Zone 1 : nommée et développée (roster ennemi, décor couleur actuel).
- Zone 2 : enregistrée, placeholder (palette rouge/cendre, pas de roster).
- Zones 3-12 : **seuls les boss sont définis** (`BossThemes` + art des sprites). Noms et
  thèmes ci-dessous = **proposition validée**, à écrire dans `ZoneConfig.Zones[3..12]`.

---

## Les 12 zones

### Zone 1 — Plaine de l'Aube · **Roi Gobelin** (physique)

- **Palette :** verts mousse, terre, indigo → ambre à l'horizon, or (couronne), rouge sang (bannières).
- **FAR — ciel :** pré-aube, bleu profond dégradé vers une lueur ambre basse ; étoiles qui s'éteignent ; fines colonnes de fumée de camps gobelins.
- **MID — relief :** collines vertes basses ; silhouettes de palissades et tours de guet grossières ; bannières en lambeaux.
- **NEAR — sol :** herbe piétinée, souches de pins, ossements épars, totems gobelins (crâne sur pieu), feux de cuisine, charrette brisée.
- **Météo :** calme, brume matinale dans les creux.
- **Atmosphère :** le calme avant — terrain de rassemblement d'une bande de guerre.

### Zone 2 — Carrière des Runes · **Golem de Pierre** (physique)

- **Palette :** gris granite, mousse, glow rune turquoise, ciel blanc couvert.
- **FAR :** ciel pâle bouché, nuages accrochés aux mesas, monolithes lointains.
- **MID :** falaises taillées, plateaux de blocs empilés, arches mégalithiques brisées, terrasses de carrière.
- **NEAR :** dalles fissurées, blocs moussus aux veines runiques luminescentes, marques de burin, statue effondrée, gravier.
- **Météo :** air immobile, fine poussière.
- **Atmosphère :** ruine à l'échelle des géants, puissance dormante dans la pierre.

### Zone 3 — Bois des Murmures · **Sorcière des Bois** (magique)

- **Palette :** verts forêt sombres, écorce noire, glow hex vert maladif, brume gris-violet, rouges/violets de champignons.
- **FAR :** ciel à peine visible sous la canopée, pénombre verdâtre, rais de lumière pâle, corbeaux.
- **MID :** troncs noueux massifs, arches de branches tordues, mousse pendante, hutte biscornue au loin.
- **NEAR :** fougères, champignons géants tachetés, feux follets verts, charmes d'os pendus aux branches, racines tordues, cercle hexé gravé dans la terre.
- **Météo :** brouillard bas épais, spores à la dérive.
- **Atmosphère :** forêt hostile qui observe — maudite.

### Zone 4 — Champs de Cendres · **Colosse des Cendres** (physique)

- **Palette :** obsidienne noire, charbon, lave orange/rouge, cendre blanche, ciel rouge-noir.
- **FAR :** ciel rouge-noir sombre, nuages de cendre, volcan lointain à lueur de lave, aucune étoile.
- **MID :** crêtes calcinées déchiquetées, colonnes de basalte, rivières de lave dans les crevasses, panaches de fumée.
- **NEAR :** terre craquelée aux fissures rougeoyantes, éclats d'obsidienne, arbres carbonisés, congères de cendre, mare de lave bouillonnante en bord de scène.
- **Météo :** chute de cendres, braises volantes, ondulation de chaleur.
- **Atmosphère :** chaleur oppressante, tout est brûlé, le sol lui-même luit.

### Zone 5 — Toundra des Âmes · **Liche Glaciale** (magique)

- **Palette :** bleu glace pâle, blanc, cyan givre, feu d'âme bleu spectral, fer sombre, crépuscule violet-gris.
- **FAR :** crépuscule froid, aurore bleu pâle d'âmes, lune gelée, neige qui tombe.
- **MID :** murs de glacier, montagnes prises dans la glace, flèches de fer noir et d'os jaillissant de la glace, tombeaux gelés.
- **NEAR :** banquise fissurée, congères, pierres tombales éclatées par le gel, braseros à flamme-fantôme bleue, squelettes à demi gelés, grappes de stalactites.
- **Météo :** rafales de blizzard, particules de glace flottantes.
- **Atmosphère :** silence, froid mordant — les morts ne reposent pas ici.

### Zone 6 — Côte des Naufrages · **Tyran des Abysses** (physique)

- **Palette :** teal sombre, bleu ardoise, gris-vert d'orage, beige bernacle, coraux orangés/roses, écume blanche.
- **FAR :** ciel d'orage violent, nuages noirs bas, éclairs, rideaux de pluie, mer déchaînée à l'horizon.
- **MID :** falaises marines, aiguilles rocheuses, phare brisé, coques de navires à demi coulées, vagues qui s'écrasent.
- **NEAR :** roche noire humide et flaques de marée, débris couverts de bernacles, filets et cordages emmêlés, coraux, membrures d'épave échouée, varech, ancre rouillée.
- **Météo :** pluie battante, embruns, vent.
- **Atmosphère :** froid et noyé — la marée monte.

### Zone 7 — Ruines d'Aethel · **Archimage Déchu** (magique)

- **Palette :** marbre blanc délavé, feuille d'or, violet profond, glow arcane magenta, cassures noir-néant, ciel lilas crépusculaire.
- **FAR :** crépuscule violet contre-nature, ciel fracturé de fissures-néant, îlots de gravats flottants à la dérive, lune brisée.
- **MID :** colonnades de marbre éclatées, demi-tour suspendue en l'air, escaliers vers nulle part, glyphes runiques lumineux.
- **NEAR :** mosaïque fissurée, colonnes tombées, grimoires figés en lévitation, orreries brisées, éclats de cristal arcane, cercle magique qui tourne encore.
- **Météo :** anomalies de gravité (débris en suspens), éclairs violets, poussière de glyphes.
- **Atmosphère :** réalité mince et rompue — l'orgueil puni.

### Zone 8 — Terres Brisées · **Behemoth** (physique)

- **Palette :** rouille orange, ocre, brun sec, blanc d'os, canyon rouge poussière, ciel brun-or voilé.
- **FAR :** ciel poussiéreux immense, brume brun-or, soleil bas et dur, mesas lointaines, tourbillons de poussière.
- **MID :** parois de canyon érodées, arches de cages thoraciques de titans morts, plateau craquelé, énorme crâne cornu à l'horizon.
- **NEAR :** sol dur fendu de crevasses profondes (le piétinement), os géants à demi enterrés, blocs, broussailles mortes clairsemées, empreintes énormes.
- **Météo :** brume de poussière, tremblements, chaleur.
- **Atmosphère :** échelle écrasante, ancien et brutal — le sol se souvient du piétinement.

### Zone 9 — Landes du Deuil · **Spectre Hurlant** (magique)

- **Palette :** gris-vert désaturé, gris d'os, cyan spectral froid, silhouettes noires d'arbres morts, brouillard blafard — quasi monochrome.
- **FAR :** brouillard quasi blanc aveuglant, pas de ciel, disque de lune faible, silhouettes à peine lisibles, linceuls à la dérive.
- **MID :** arbres squelettiques morts, abbaye en ruine à clocher brisé, pierres tombales penchées, gibet, chaînes pendantes.
- **NEAR :** eau de tourbière noire et boue, touffes d'herbe morte, cercueils brisés, chaînes rouillées lovées au sol, volutes de lumière cyan spectrale, corbeaux.
- **Météo :** brouillard épais qui avale tout, immobilité froide, gémissements lointains *(audio ultérieur)*.
- **Atmosphère :** le deuil rendu physique, sourd — tout se lamente.

### Zone 10 — Forge de Fer · **Dragon de Fer** (physique)

- **Palette :** gris fer sombre, brun rouille, acier riveté, orange en fusion, noir charbon, laiton, ciel brun-orange enfumé.
- **FAR :** ciel de smog noir éclairé d'orange par en-dessous, cheminées géantes qui crachent, lueur de haut-fourneau sur les nuages, aucune étoile.
- **MID :** engrenages et machinerie colossaux, tours de haut-fourneau, chaînes et grues, passerelles, tuyaux qui crachent la vapeur.
- **NEAR :** sol de plaques rivetées, canaux de forge rougeoyants, enclumes, rouages, chaînes, tas de charbon, coulée de métal en fusion, jets de vapeur.
- **Météo :** jets de vapeur, retombée de suie, scintillement de forge.
- **Atmosphère :** industrie assourdissante, chaleur et fer — une machine qui dévore.

### Zone 11 — Faille du Vide · **Œil du Vide** (magique)

- **Palette :** noir spatial, violet néant, magenta d'horizon des événements, reflets d'huile irisés, verts maladifs, obscurité sans étoiles.
- **FAR :** un trou dans le ciel — horizon des événements violet qui avale les étoiles ; champ stellaire tordu autour ; pas d'horizon au sol (l'espace déborde).
- **MID :** fragments de terre flottants en orbite lente, géométrie impossible, escaliers qui se replient sur eux-mêmes, yeux qui observent au loin.
- **NEAR :** sol d'obsidienne fracturé dont les bords s'effacent dans le vide, roches en lévitation, excroissances de cristal violet, tentacules sortant des fissures, motif d'œil gravé partout.
- **Météo :** gravité inversée, débris à la dérive, statique de réalité.
- **Atmosphère :** faux, observé — le monde s'arrête ici.

### Zone 12 — Fin de Toute Chose · **Avatar de la Fin** (physique)

- **Palette :** noir absolu, bleu-violet cosmique, champ stellaire blanc, contre-jour argent froid, nébuleuse rose/teal ténue, un seul éclat blanc pur.
- **FAR :** vide constellé complet, galaxies lointaines, soleil blanc mourant, pas d'atmosphère, silence infini.
- **MID :** trône colossal en ruine / arche-monde brisée se détachant sur les étoiles, fragments de planète, pont de lumière qui s'évanouit dans le noir.
- **NEAR :** sentier étroit de pierre-étoile flottant dans le vide, bords qui se dissolvent en poussière de galaxie, monolithes gravés de la fin, entailles de lames jumelles dans le sol, motes de lumière stellaire qui montent.
- **Météo :** aucune — calme mortel, poussière d'étoiles, gravité optionnelle.
- **Atmosphère :** le terminus, beau et final — rien après.

---

## Architecture visuelle — 3 couches

Chaque zone = **3 Decals** : `decor_zone<N>_far`, `decor_zone<N>_mid`, `decor_zone<N>_near`.

| Couche | Dimensions cibles | Fond | Rendu | Parallaxe (× vitesse monde) | Emplacement dans `CombatZone` |
|---|---|---|---|---|---|
| **FAR — ciel** | ~960×540 (ou bande tuilable 512×288) | **opaque** | `ScaleType = Tile` ou 1 image large scrollée | **×0.08** (quasi fixe) | `FarLayer` (plein cadre) |
| **MID — collines / arrière-plan** | ~960×300 | **transparent** au-dessus de la silhouette | tuilé horizontalement | **×0.35** | `MidLayer`, ~55 % bas |
| **NEAR — sol / premier plan** | ~960×360 | **transparent** au-dessus du terrain | tuilé horizontalement | **×0.9** (proche du héros) | `NearLayer`, ~28 % bas |

**Contrainte de calage :** la ligne de sol des combattants (`CombatClient.SCENE_Y = 0.62`)
doit tomber **pile** sur la ligne de sol dessinée dans le NEAR. Toutes les images NEAR
ont donc leur « surface de sol » à un **Y constant** dans l'image.

### Direction artistique (transversale)

- pixel art fantasy 16-bit, très détaillé et soigné
- palette cohérente **par zone** (voir tableaux ci-dessus)
- silhouettes lisibles, profondeur et parallaxe
- **aucun** emoji, placeholder, `Frame` coloré comme décor, texte dans l'image
- pas de photoréalisme, pas de rendu 3D

---

## Modifications de code nécessaires (présentation uniquement — zéro gameplay)

1. **`src/StarterGui/RpgGui.gui.json`** — remplacer les `Frame` recolorés
   (`FarLayer/MidLayer/NearLayer` → `Tile0/Tile1` + enfants `Star1-10`, `Hill0-2`,
   `Tree0-3`, `Rock`) par des `ImageLabel`. Conserver le motif double-tuile `Tile0/Tile1`
   pour le scroll, ou passer à `ScaleType = Tile`.
2. **`src/StarterPlayer/StarterPlayerScripts/CombatClient.client.luau`** —
   - `applyZoneDecor(zoneId)` : `ImageLabel.Image = AssetMap["decor_zone"..zoneId.."_far"]`
     (+ `_mid`, `_near`), fallback zone 1 si la zone n'a pas de décor.
   - réintroduire un scroll parallaxe dans `RenderStepped`, piloté par `data.pos` (km),
     un facteur par couche.
   - supprimer `paintLayer` et toute la logique de couleurs `d.star/d.hill/d.tree/d.rock`.
3. **`src/ReplicatedStorage/ZoneConfig.luau`** *(données décor, pas de logique)* —
   - ajouter `Zones[3..12]` : `{ id, name, developed = false, boss = <N>,
     decor = { far = "decor_zone<N>_far", mid = ..., near = ... } }`.
   - `Zones[1..2].decor` : la table de `Color3` devient une table de slugs d'assets.
4. **`MilestoneDecor`** (feu de camp / boss / boutique — encore en `Frame`) → **phase 2** :
   reskin avec sprites props (`campfire`, `shop_tent`, `boss_gate` déjà prévus au
   `manifest.yaml`).

---

## Points ouverts / à noter

- **Le combat ne montre pas encore « boss N en zone N ».** `EnemyService.rollBoss`
  déclenche un boss **intermédiaire générique** tous les 10 km et un **BIG boss nommé**
  tous les **100 km** — divergence avec `GAME_SPEC 6.2` (« un boss tous les 10 km »).
  Le **décor** suit la maille 10 km / boss N ; aligner le **combat** dessus est une
  décision gameplay séparée, non traitée ici.
- **Production des 36 fonds :** PixelLab est épuisé (0 crédit). Les fonds passeront par
  **ComfyUI / SDXL** (mieux adapté aux décors ; la catégorie `decor` existe déjà dans
  `manifest.yaml`). Le tuilage horizontal sans couture depuis SDXL demandera de
  l'edge-blending manuel dans un post-traitement dédié.
- **Zones 3-12 :** aucun roster ennemi défini — inchangé, `EnemyService` gère le
  fallback (base scalée brute).
