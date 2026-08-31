# Quête Minute — Prompts d'assets (Gemini / générateur d'images, planches multi-sprites)

**Date : 2026-08-31**

Génère les sprites en **planches multi-sprites** (grille) plutôt qu'un par un.
Aligné sur le style de `style.yaml` (pixel art 16-bit, fond magenta `#FF00FF`, contour épais,
palette limitée) pour rester cohérent avec `postprocess.py`.

---

## Les 3 règles d'or (pour que le découpage automatique marche)

1. **Fond magenta pur `#FF00FF`**, parfaitement plat — aucun dégradé, texture, vignette, bruit,
   ni lumière sur le fond. (C'est la couleur que `postprocess.py` détoure, tolérance 60.)
2. **Gouttières magenta réelles entre les cases.** Chaque sprite entouré d'au moins 20 % de vide
   magenta sur les 4 côtés. **Rien ne touche rien** (ni un autre sprite, ni le bord de case, ni
   le bord d'image).
3. **Grille régulière** — une créature par case, toutes à la **même échelle**, pieds sur une
   ligne commune (≈ 80 % de la hauteur de case).

Si ces 3 règles sont tenues, je détecte la grille tout seul via les gouttières, quelle que soit
la taille de sortie. Sinon je dois estimer les boîtes à la main (imprécis).

**Aucune ombre.** Pas d'ombre portée, pas d'ombre de contact, pas de sol, pas de plancher.
**Aucun texte, cadre, numéro, bordure, ligne de grille.**

---

## Notes de compatibilité générateur (Gemini / Imagen "16-bit pixel art")

Le générateur sait faire : sprite sheets sur grille stricte, fond transparent, vue 3/4 perso,
cohérence palette **dans une planche**. Ajustements à imposer :

1. **Résolution native : ~96px de haut par perso** (pas 32/48 — sinon rendu "8-bit chunky" à
   l'affichage en 512-1024).
2. **Palette plate ~20-24 couleurs, dithering minimal ou nul, cel-shading plat.** Éviter la
   référence "Chrono Trigger" (trop dithered). Référence : "flat modern indie pixel art".
3. **Fond** : transparent OK **si vrai PNG RGBA à alpha propre**. Sinon `#FF00FF` magenta plat.
   `postprocess.py` gère les deux — tester une planche, vérifier l'alpha.
4. **Cohérence entre planches non garantie** → image de référence + mêmes palette keywords à
   chaque planche + grosses planches (8 sujets d'un coup, pas 8×1).
5. On ne demande **aucune animation, aucun tileset, aucune VFX, aucune UI, aucune icône** — juste
   une pose statique par créature.

## Bloc STYLE — à coller mot pour mot dans chaque prompt

```
Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution
(NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no smooth gradients.
Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited
flat palette of about 20-24 colors, minimal or no dithering, high contrast, flat cel
shading, a single light source from the upper-left. Thick dark 1px outline on the
outer silhouette. Grim dark-fantasy tone but not gory: no blood, fully clothed, no
bare skin, modest, family-friendly. Flat front-facing three-quarter view, camera at
eye level, subject facing the viewer and angled slightly to its left. One static
neutral standing pose, weight centered, both arms visible, feet flat and apart. No
motion lines, no glow, no particles, no visual effects, no animation frames.
```

## Bloc PLANCHE — à coller, ajuster COLS / ROWS / N

```
Layout: one single image. Subjects arranged in a strict, evenly-spaced grid of {COLS}
columns by {ROWS} rows, {N} subjects total. Background: 100% flat solid magenta
#FF00FF over the entire image — absolutely no gradient, texture, vignette, pattern,
noise, or lighting on the background. Each subject sits alone in its grid cell,
horizontally centered, feet resting on a line 80% down the cell. Keep an empty magenta
margin of at least 20% of the cell size on all four sides of every subject. No subject
touches another subject, a cell edge, or the image border. No shadow of any kind: no
drop shadow, no ground shadow, no contact shadow, no ground plane, no floor. No color
bleed onto the magenta. Do not draw any grid lines, boxes, frames, panels, labels,
text, numbers, captions, or borders. Every subject at the exact same scale.
```

## Bloc NÉGATIF — si le générateur accepte un negative prompt

```
blurry, anti-aliased, soft edges, smooth shading, gradient, bloom, glow, 3d render,
photorealistic, realistic lighting, depth of field, text, caption, label, numbers,
signature, watermark, frame, border, panel lines, grid lines, drop shadow, ground
shadow, cast shadow, floor, ground plane, multiple poses, turnaround, side view, back
view, held weapon raised, weapon pointing away, floating objects, extra limbs,
cropped, cut off, bare skin, cleavage
```

## Verrou de cohérence entre planches

1. Génère d'abord la **planche héros**. Choisis la meilleure.
2. Pour **toutes** les planches suivantes : joins la planche héros comme **image de référence** et
   mets en tête du prompt :
   `Match exactly the art style, palette, outline weight, pixel density, and lighting of the attached reference image.`
3. Garde le même seed si ton outil le permet.

## Taille de sortie

Le **ratio** compte (il doit coller à la grille), pas le nombre de pixels exact — Gemini ignore
souvent les dimensions précises.

| Grille | Ratio à demander | Idéal |
|---|---|---|
| 4×2 | 2:1 paysage | 2048×1024 |
| 2×2 ou 1 sujet | 1:1 carré | 1024×1024 (ou 1536) |
| 2×1 (héros) | 2:1 paysage | 1024×512 |
| Fond de couche | 16:9 | 1920×1080 |

---

# Les 7 prompts de test (un par type)

## 1 — HÉROS (2 sprites) · grille 2×1 · ratio 2:1

```
{BLOC STYLE}

{BLOC PLANCHE — COLS=2, ROWS=1, N=2}

Subjects, left to right:
1. WARRIOR hero — a young human adventurer in worn steel plate over chainmail, a short
   sword sheathed at the hip (not drawn, not raised), a small round shield on the back,
   brown hair, determined face. Earth-tone palette: steel grey, leather brown, deep
   red cloth. Standing at rest.
2. MAGE hero — the SAME young human, same height and build, in a hooded deep-blue robe
   with simple silver trim, holding a plain wooden staff vertically beside the body
   with its base on the ground (not pointed, not casting). Face in hood shadow.
   Blue-and-silver palette. Standing at rest.
Both heroes EXACTLY the same height. This height is the reference scale for every
other sprite in the game.
```
→ `hero_warrior.png`, `hero_mage.png` · canvas final 512×512 · échelle référence ×1,0.

## 2 — PETITS MONSTRES · Couche 1 (Plaine de l'Aube) · 8 sprites · grille 4×2 · ratio 2:1

```
{BLOC STYLE}

{BLOC PLANCHE — COLS=4, ROWS=2, N=8}

Theme: Couche 1 "Plaine de l'Aube" — a crumbling sunlit grassland at the edge of a
collapsing world. Weak creatures. Each MUST be clearly SMALLER than a human, between
40% and 70% of a human's height. Muted green, tan, bone, dull brown palette.
Subjects, left to right, top row then bottom row:
1. a scrawny grey field rat, hunched
2. a small green goblin runt, a rusty dagger sheathed at its belt (not held)
3. a hopping carrion crow with ragged feathers
4. a knee-high mud sprite, lumpy and earthen
5. a fat brown tick-beast the size of a small dog, low to the ground
6. a small skeleton of a child-sized creature, no weapon, arms at its sides
7. a wild piglet with cracked tusks
8. a floating will-o-wisp: a small pale flame with a faint face (hovering just above
   the cell feet line)
Consistent scale across all 8.
```
→ `enemies_zone1/` slugs : `mob_rat`, `mob_goblin_runt`, `mob_crow`, `mob_mudsprite`,
`mob_tick`, `mob_skeleton_small`, `mob_piglet`, `mob_wisp` · canvas 512×512 · échelle ~×0,5.

## 3 — MONSTRES NORMAUX · Couche 1 · 8 sprites · grille 4×2 · ratio 2:1

```
{BLOC STYLE}

{BLOC PLANCHE — COLS=4, ROWS=2, N=8}

Theme: Couche 1 "Plaine de l'Aube". Standard threats, roughly the SAME height as a
human (80% to 120%). Muted green, tan, bone, dull brown palette.
Subjects, left to right, top then bottom:
1. an adult grey wolf, standing, head low
2. a green goblin warrior in scrap armor, a short spear sheathed across the back
3. a human skeleton soldier, a cracked round shield on the arm, no raised weapon
4. a bandit in a patched cloak and hood, arms crossed
5. a walking scarecrow animated by straw and crows
6. a bristled boar the size of a large dog
7. a plague zombie — a farmer in rotting clothes, arms hanging
8. a stone-scaled lizard the height of a man, on two legs
Consistent scale across all 8, all roughly human height.
```
→ slugs : `mob_wolf`, `mob_goblin_warrior`, `mob_skeleton_soldier`, `mob_bandit`,
`mob_scarecrow`, `mob_boar`, `mob_zombie_farmer`, `mob_lizard` · canvas 512×512 · échelle ~×1,0.

## 4 — GROS MONSTRES · Couche 1 · 4 sprites · grille 2×2 · ratio 1:1

```
{BLOC STYLE}

{BLOC PLANCHE — COLS=2, ROWS=2, N=4}

Theme: Couche 1 "Plaine de l'Aube". Elite brutes, clearly BIGGER than a human, between
130% and 220% of a human's height, bulky. Muted earth palette.
Subjects, left to right, top then bottom:
1. a hulking ogre, a wooden club resting head-down on the ground beside it
2. a moss-covered stone golem, squat and wide, fists at its sides
3. a huge dire-boar, shaggy, tusks like sabres
4. a towering plague-troll, gaunt and long-limbed, hunched
Consistent scale across all 4.
```
→ slugs : `mob_ogre`, `mob_golem_minor`, `mob_direboar`, `mob_troll` · canvas 1024×1024 ·
échelle ~×1,6.

## 5 — BOSS NOMMÉ · Roi Gobelin (boss Couche 1) · 1 sprite · ratio 1:1

```
{BLOC STYLE}

Layout: ONE single subject, centered, on a 100% flat solid magenta #FF00FF background
(no gradient, texture, or lighting on the background). The subject fills about 75% of
the image height, feet on a line near the bottom, empty magenta margin on all sides.
No shadow of any kind, no ground, no floor. No text, frame, or border.

Subject: THE GOBLIN KING — boss of Couche 1. A massive war-goblin, about 2.5× the
height of a normal goblin, broad and muscular, wearing a crooked iron crown and
mismatched plundered plate armor. A huge notched cleaver sheathed across his back
(NOT held, NOT raised). Scarred green face, one tusk broken, sneering. Torn red
king's cape. Bone and gold trophies on his belt. Standing tall, fists clenched,
menacing but static. Grim, not gory. Fully armored, no bare skin.
```
→ `boss_roi_gobelin.png` · canvas 1024×1024 · échelle ~×2,6.

## 6 — BIG BOSS / RAID · Roi Gobelin colossal (tous les 100 km) · 1 sprite · ratio 1:1

```
{BLOC STYLE}

Layout: ONE single subject, FULL BODY, entirely inside the frame, centered, on a 100%
flat solid magenta #FF00FF background. Feet on a line near the bottom, the top of the
head with a small magenta margin above it — the whole creature fits in the square. No
shadow, no ground, no floor, no text, no border.
(The "colossal / overflowing the screen" feeling is done later in the game engine by
zooming the sprite frame — deliver the whole body here.)

Subject: THE GOBLIN WARLORD-TITAN — the raid form of the Goblin King. A colossal
war-goblin, mountainous muscle, cracked obsidian-plated armor bolted onto its skin, a
shattered iron crown fused to its skull, faint glowing runes in the armor seams. Two
enormous notched blades sheathed on its back (NOT held). Trophy chains of broken
shields. Standing planted, arms slightly out, overwhelming presence. Grim dark
fantasy, fully armored, not gory. Drawn much bulkier and taller-proportioned than the
normal Goblin King boss.
```
→ `bigboss_roi_gobelin.png` · canvas 1024×1024 · le débordement/zoom est fait dans le moteur.

## 7 — FOND DE COUCHE · Plaine de l'Aube · 1 image · ratio 16:9 · PAS de magenta

Si le rendu déçoit sur une couche → repli sur un dégradé procédural (le jeu tourne bien sans
vrai décor).

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no
repeating pattern, no grid. 16-bit, crisp hard pixels, no anti-aliasing, limited
palette (~20 colors), flat parallax layers. No characters, no creatures, no text.

Scene: "Plaine de l'Aube" — a wide crumbling sunlit grassland at the edge of a
collapsing world. Pale gold dawn sky with a low sun and scattered clouds. Rolling
grass hills in the mid-ground, a few dead trees, broken stone fence posts, a distant
ruined watchtower on the horizon. The ground plane runs straight across the lower
third (characters will stand there). Muted warm palette: gold, sage green, tan, soft
grey. Gentle, melancholic, quiet. Fully opaque, no transparent areas. Keep an empty
readable band across the center where the fight happens.
```
→ `bg_zone1.png` · canvas final 1920×1080.

---

## Les 12 thèmes de couche (pour décliner les prompts 2-7 sur les autres couches)

| # | Couche | Ambiance | Boss | Palette |
|---|---|---|---|---|
| 1 | Plaine de l'Aube | la surface qui s'effrite, aube dorée | Roi Gobelin | or, vert sauge, tan |
| 2 | Carrière des Runes | pierre gravée, la roche se souvient | Golem de Pierre | gris pierre, ocre, bleu rune |
| 3 | Bois des Murmures | forêt tordue, rien n'y pousse droit | Sorcière des Bois | vert sombre, violet, brun |
| 4 | Champs de Cendres | le feu ne s'est jamais éteint | Colosse des Cendres | noir, orange braise, gris |
| 5 | Toundra des Âmes | le froid qui retient | Liche Glaciale | blanc bleuté, cyan, gris |
| 6 | Côte des Naufrages | sous la ligne de flottaison, épaves | Tyran des Abysses | bleu profond, vert-de-gris, bois |
| 7 | Ruines d'Aethel | la cité qui a trop su | Archimage Déchu | marbre blanc, or terni, violet |
| 8 | Terres Brisées | la géométrie lâche | Béhémoth | pourpre, noir, éclats blancs |
| 9 | Landes du Deuil | l'écho de tout ce qui est tombé | Spectre Hurlant | gris, blanc spectral, bleu pâle |
| 10 | Forge de Fer | la machine qui creuse | Dragon de Fer | fer, rouille, rouge chaud |
| 11 | Faille du Vide | là où la lumière s'arrête | Œil du Vide | noir, violet néon, cyan |
| 12 | Fin de Toute Chose | le fond | Avatar de la Fin | absence de couleur, blanc, noir |

---

## Après génération — ce que je fais

1. Tu déposes chaque planche dans `tools/assetgen/out_raw/` et tu me dis : **nom de fichier**,
   **type (1-7)**, **slugs dans l'ordre de lecture**.
2. Je lance un découpage (`slice_sheet.py`, dérivé de `postprocess.py`) :
   détection de grille par gouttières magenta → key `#FF00FF` (tolérance 60) → recadrage serré →
   alignement des pieds sur une baseline commune → redimensionnement au canvas du type → PNG
   nommé par slug.
3. Je vérifie chaque sprite (fond bien transparent, aucun reste magenta, silhouette nette).
4. En fin de lot : repack en 3-4 atlas 1024×1024 + génération de `AssetMap.luau`
   (slug → `ImageRectOffset` + `ImageRectSize`). Tu uploades ~4 images au lieu de 90.
