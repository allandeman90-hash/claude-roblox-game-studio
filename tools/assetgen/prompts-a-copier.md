# Quête Minute — Prompts d'assets prêts à copier-coller

**Date : 2026-08-31** · Générateur cible : Gemini / Imagen (« 16-bit pixel art », planches multi-sprites).

Chaque prompt est **entièrement développé** dans son bloc ```` ``` ````. Tu copies un bloc, tu le colles, tu règles le ratio indiqué, tu génères. Aucun placeholder à remplir.

**49 prompts** : 1 héros · 12 planches de monstres (couches 1-12) · 12 boss nommés · 12 big boss / boss de raid · 12 fonds de couche.

---

## Les 3 règles d'or du découpage

1. **Fond magenta pur `#FF00FF`, parfaitement plat.** Aucun dégradé, texture, vignette, bruit ni lumière sur le fond. C'est la couleur que le découpage détoure (tolérance 60).
2. **Grosses gouttières magenta entre les sujets. Rien ne touche rien** — ni un autre sujet, ni un bord de case, ni le bord de l'image. Le vrai critère validé sur la planche héros réelle : *sujets nettement séparés*. Dans le doute, plus d'espace, pas moins.
3. **Grille régulière** — une créature par case, pieds sur une ligne commune (~80 % de la hauteur de case). L'instruction de grille `COLS × ROWS` reste dans chaque prompt : elle aide le découpage même si la grille n'est pas parfaite.

Aucune ombre (portée, de contact, de sol). Aucun texte, cadre, numéro, bordure, ligne de grille. Le watermark éventuel du générateur (coin bas-droit) est géré au découpage — ne pas s'en occuper.

---

## La méthode (à suivre dans l'ordre)

1. **Génère la planche HÉROS en premier** (prompt 1). Sélectionne la meilleure sortie. Sa hauteur de perso = l'échelle de référence de tout le jeu.
2. **Pour TOUS les autres prompts** (monstres, boss, big boss) : joins la planche héros validée comme **image de référence**. Chaque bloc non-héros commence déjà par la phrase `Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes).`
3. Garde le même seed si l'outil le permet.
4. Les **fonds de couche** ne prennent pas la référence héros (ce sont des décors, pas des sprites) — mais garde la même palette par couche.
5. Dépose chaque planche dans `tools/assetgen/out_raw/`, indique le nom de fichier + le type + les slugs dans l'ordre de lecture. Le découpage produit un PNG par slug, puis repack en atlas + `AssetMap.luau`.

### Réglage du ratio selon le type

| Type de prompt | Grille | Ratio à régler | Idéal |
|---|---|---|---|
| Héros | 2×1 | **2:1** paysage | 1024×512 |
| Monstres (par couche) | 3×2 | **3:2** paysage | 1536×1024 |
| Boss nommé | 1 sujet | **1:1** carré | 1024×1024 |
| Big boss / raid | 1 sujet | **1:1** carré | 1024×1024 |
| Fond de couche | — | **16:9** paysage | 1920×1080 |

---

## Récap des slugs

### Héros (2)
`hero_warrior` · `hero_mage`

### Monstres — 72 slugs (6 par couche, ordre = lecture de la planche : haut G→D puis bas G→D)

| Couche | Slugs (1 → 6) |
|---|---|
| 1 — Plaine de l'Aube | `mob_c01_rat` · `mob_c01_larve_poussiere` · `mob_c01_gobelin_maraudeur` · `mob_c01_loup_efflanque` · `mob_c01_epouvantail` · `mob_c01_ogre_sentier` |
| 2 — Carrière des Runes | `mob_c02_eclat_runique` · `mob_c02_rampant_carriere` · `mob_c02_tailleur_maudit` · `mob_c02_chien_gravats` · `mob_c02_sentinelle_gravee` · `mob_c02_colosse_carriere` |
| 3 — Bois des Murmures | `mob_c03_feu_follet` · `mob_c03_champignon_rodeur` · `mob_c03_sylphe_ronce` · `mob_c03_loup_sylvestre` · `mob_c03_pendu_branches` · `mob_c03_treant_tordu` |
| 4 — Champs de Cendres | `mob_c04_braise_vive` · `mob_c04_cendreux` · `mob_c04_fantassin_calcine` · `mob_c04_molosse_suie` · `mob_c04_porte_torche` · `mob_c04_colosse_braise` |
| 5 — Toundra des Âmes | `mob_c05_eclat_ame` · `mob_c05_givreux` · `mob_c05_marcheur_gele` · `mob_c05_loup_givre` · `mob_c05_pleureuse_voilee` · `mob_c05_titan_glace` |
| 6 — Côte des Naufrages | `mob_c06_crabe_epave` · `mob_c06_feu_brume` · `mob_c06_marin_noye` · `mob_c06_murene_dressee` · `mob_c06_garde_corallien` · `mob_c06_leviathan_echoue` |
| 7 — Ruines d'Aethel | `mob_c07_glyphe_flottant` · `mob_c07_automate_brise` · `mob_c07_erudit_spectral` · `mob_c07_chien_albatre` · `mob_c07_gardien_marbre` · `mob_c07_sphinx_dechu` |
| 8 — Terres Brisées | `mob_c08_fragment_vif` · `mob_c08_rampe_angles` · `mob_c08_errant_defait` · `mob_c08_chien_non_euclidien` · `mob_c08_veilleur_fracture` · `mob_c08_masse_aberrante` |
| 9 — Landes du Deuil | `mob_c09_lueur_deuil` · `mob_c09_poupee_suaire` · `mob_c09_spectre_linceul` · `mob_c09_chien_cendre_os` · `mob_c09_porte_etendard` · `mob_c09_golgoth_deuil` |
| 10 — Forge de Fer | `mob_c10_rivet_vivant` · `mob_c10_foreuse_naine` · `mob_c10_ouvrier_fonte` · `mob_c10_molosse_vapeur` · `mob_c10_contremaitre_blinde` · `mob_c10_marteleur_forge` |
| 11 — Faille du Vide | `mob_c11_etincelle_vide` · `mob_c11_rampant_ombre` · `mob_c11_porteur_neant` · `mob_c11_limier_vide` · `mob_c11_veilleur_yeux` · `mob_c11_gueule_beante` |
| 12 — Fin de Toute Chose | `mob_c12_poussiere_finale` · `mob_c12_reliquat` · `mob_c12_temoin_silencieux` · `mob_c12_ombre_portee` · `mob_c12_gardien_seuil` · `mob_c12_effondrement` |

### Boss nommés (12)
`boss_roi_gobelin` · `boss_golem_pierre` · `boss_sorciere_bois` · `boss_colosse_cendres` · `boss_liche_glaciale` · `boss_tyran_abysses` · `boss_archimage_dechu` · `boss_behemoth` · `boss_spectre_hurlant` · `boss_dragon_fer` · `boss_oeil_vide` · `boss_avatar_fin`

### Big boss / raid (12)
`bigboss_roi_gobelin` · `bigboss_golem_pierre` · `bigboss_sorciere_bois` · `bigboss_colosse_cendres` · `bigboss_liche_glaciale` · `bigboss_tyran_abysses` · `bigboss_archimage_dechu` · `bigboss_behemoth` · `bigboss_spectre_hurlant` · `bigboss_dragon_fer` · `bigboss_oeil_vide` · `bigboss_avatar_fin`

### Fonds de couche (12)
`bg_zone1` · `bg_zone2` · `bg_zone3` · `bg_zone4` · `bg_zone5` · `bg_zone6` · `bg_zone7` · `bg_zone8` · `bg_zone9` · `bg_zone10` · `bg_zone11` · `bg_zone12`

---
---

# 1 · HÉROS

**Usage :** les 2 héros jouables, à générer EN PREMIER — leur hauteur = l'échelle de référence de tout le jeu. · **Ratio générateur :** 2:1 paysage (idéal 1024×512). · **Slugs (gauche → droite) :** `hero_warrior`, `hero_mage`.

```
Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 2 columns by 1 row, 2 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject at the exact same scale and the exact same height.

Subjects, left to right:
1. WARRIOR HERO - a young human adventurer in worn steel plate armor over chainmail, a leather belt, a short sword sheathed at the left hip (not drawn, not raised), a small round shield stowed flat on the back, short brown hair, calm determined face, empty hands resting at the sides. Earth-tone palette: steel grey, leather brown, deep red cloth trim. No exposed flesh apart from the face, fully armored, no bare skin, no cleavage, modest, not sexualized.
2. MAGE HERO - the SAME young human, identical height and build, in a hooded deep-blue robe with simple silver trim over a high-necked tunic, holding a plain wooden staff vertically beside the body with its base on the ground (not raised, not casting), face partly in hood shadow, free hand at the side. Blue and silver palette. Fully covered, no bare skin, no cleavage, modest, not sexualized.
Both heroes EXACTLY the same height and the same eye level. This shared height is the reference scale for every other sprite in the game.
```

---
---

# 2 · MONSTRES PAR COUCHE (12 planches)

Chaque planche : grille 3×2, 6 monstres, ratio **3:2**. Joindre la planche héros en référence. Ordre de lecture : haut gauche → haut droite, puis bas gauche → bas droite. Chaque créature est dessinée à sa **taille relative réelle** (% de la hauteur humaine), toutes au même niveau de détail et de densité de pixels.

## 2.1 — Couche 1 · Plaine de l'Aube

**Usage :** les 6 monstres de la Couche 1. · **Ratio :** 3:2 paysage (idéal 1536×1024). · **Référence à joindre :** planche héros validée. · **Slugs (lecture haut G→D, puis bas G→D) :** `mob_c01_rat`, `mob_c01_larve_poussiere`, `mob_c01_gobelin_maraudeur`, `mob_c01_loup_efflanque`, `mob_c01_epouvantail`, `mob_c01_ogre_sentier`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 1 "Plaine de l'Aube" - a crumbling sunlit grassland at the edge of a collapsing world, golden dawn light. Palette limited to gold, sage green, tan, bone, dull brown. All six are early-game low threats. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. RAT DES RUINES - a scrawny mangy grey field rat, hunched low on all fours, chewed ears, long bald tail, dull fur only. Height about 45% of a human.
2. LARVE DE POUSSIERE - a lumpy earthen dust-grub, a body of packed dry soil and small pebbles, two dim glowing eyes, no real limbs, sitting low to the ground. Height about 55% of a human.
3. GOBELIN MARAUDEUR - a wiry green goblin in mismatched scrap-leather armor and a dented pot helm, a rusty dagger sheathed at the belt (not held), pointed ears, a snarl, fully clothed. Height about 95% of a human.
4. LOUP EFFLANQUE - a gaunt grey wolf, matted fur over a thin frame, fur only with no exposed flesh, head low, hackles up, standing on all fours. Head reaches about 80% of a human's height.
5. EPOUVANTAIL ANIME - a farm scarecrow come alive: a burlap-sack head with stitched eyes, a ragged coat stuffed with straw, crooked wooden-pole arms, straw bursting from the cuffs, fully clothed. Height about 110% of a human.
6. OGRE DE SENTIER - a heavy hunched ogre in filthy layered rags and a thick leather apron, fully clothed with no bare skin, a big wooden club resting head-down on the ground beside one hand, small mean eyes, an underbite. Height about 170% of a human and much bulkier than the others.
```

## 2.2 — Couche 2 · Carrière des Runes

**Usage :** les 6 monstres de la Couche 2. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c02_eclat_runique`, `mob_c02_rampant_carriere`, `mob_c02_tailleur_maudit`, `mob_c02_chien_gravats`, `mob_c02_sentinelle_gravee`, `mob_c02_colosse_carriere`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 2 "Carriere des Runes" - a vast quarry of carved, rune-etched stone that remembers, dust haze, low ochre light. Palette limited to stone grey, ochre, rune blue. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. ECLAT RUNIQUE - a small floating shard of grey stone etched with glowing blue runes, slowly rotating, no face, hovering just above the cell feet line. Height about 40% of a human.
2. RAMPANT DE CARRIERE - a low armored crawler the size of a large dog, plated in overlapping slabs of rune-marked grey stone, stubby legs, a blunt eyeless head. Height about 60% of a human.
3. TAILLEUR MAUDIT - a cursed quarry worker entirely wrapped head to toe in dusty grey work-cloth and rope, no exposed flesh and no face, only wrappings, a stone mallet sheathed at the hip. Height about 95% of a human.
4. CHIEN DE GRAVATS - a hound-shaped construct of loose rubble and gravel held together by thin blue rune-light, glowing seams, four legs, blocky muzzle. Head reaches about 80% of a human's height.
5. SENTINELLE GRAVEE - a humanoid stone sentinel statue, square-shouldered, covered in carved runes, a blocky helm-like head with a single horizontal rune slit for eyes, arms at its sides, fully stone with no skin. Height about 115% of a human.
6. COLOSSE DE CARRIERE - a squat wide golem of stacked quarry blocks, moss in the cracks, glowing blue rune-fractures across its chest, huge blunt fists at its sides, fully rock with no skin and no readable face. Height about 190% of a human and much bulkier than the others.
```

## 2.3 — Couche 3 · Bois des Murmures

**Usage :** les 6 monstres de la Couche 3. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c03_feu_follet`, `mob_c03_champignon_rodeur`, `mob_c03_sylphe_ronce`, `mob_c03_loup_sylvestre`, `mob_c03_pendu_branches`, `mob_c03_treant_tordu`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 3 "Bois des Murmures" - a twisted lightless forest where nothing grows straight, crooked trunks, violet gloom. Palette limited to dark green, violet, brown. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. FEU FOLLET VERT - a small pale-green hovering flame with a faint sad face, thin wisps trailing upward, floating just above the cell feet line. Height about 45% of a human.
2. CHAMPIGNON RODEUR - a walking mushroom creature, a spotted deep-violet cap, stubby root legs, a small angry face under the cap, a mossy body. Height about 55% of a human.
3. SYLPHE RONCE - a slender humanoid woven from thorny bark and brambles, cloaked entirely in overlapping leaves and moss with no bare skin and no face, only foliage, long twiggy fingers, arms at its sides. Height about 90% of a human.
4. LOUP SYLVESTRE CORROMPU - a dark wolf with bark-like plates growing over its fur, fur and bark only with no exposed flesh, small violet fungus caps along its spine, head low, on all fours. Head reaches about 85% of a human's height.
5. PENDU DE BRANCHES - a life-size figure bound together from lashed twigs, hanging moss and grave-linen, a hollow empty hood where a face would be, arms hanging, fully covered. Height about 105% of a human.
6. TREANT TORDU - a towering walking tree, its trunk bent at a wrong angle, gnarled root feet, long branch arms, a knot-hole face, violet lichen, no skin. Height about 200% of a human and much bulkier than the others.
```

## 2.4 — Couche 4 · Champs de Cendres

**Usage :** les 6 monstres de la Couche 4. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c04_braise_vive`, `mob_c04_cendreux`, `mob_c04_fantassin_calcine`, `mob_c04_molosse_suie`, `mob_c04_porte_torche`, `mob_c04_colosse_braise`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 4 "Champs de Cendres" - a burnt plain where the fire never went out, drifting ash, ember glow under a black sky. Palette limited to black, ember orange, grey. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. BRAISE VIVE - a small floating fire elemental, a compact swirling flame body around a bright ember core, no limbs, hovering just above the cell feet line. Height about 45% of a human.
2. CENDREUX - a small heaped ash-creature, a cracked crust glowing orange in the seams, two ember eyes, low and lumpy. Height about 65% of a human.
3. FANTASSIN CALCINE - a charred soldier fully sealed in blackened heat-warped plate armor and a closed visored helm, no exposed flesh and no skin, all armor, a scorched sword sheathed at the hip. Height about 95% of a human.
4. MOLOSSE DE SUIE - a hound of packed soot and ember, cracks glowing orange, thin smoke curling off its back, four legs, head low. Head reaches about 85% of a human's height.
5. PORTE-TORCHE DAMNE - a robed figure entirely wound in scorched grey bandages under a heavy ashen cloak, no bare skin and no face, an unlit iron brand sheathed across the back, head bowed. Height about 110% of a human.
6. COLOSSE DE BRAISE - a giant of cracked black obsidian, molten orange light in every fracture, blunt heavy limbs, a featureless faceted head, fully rock with no skin and no readable face. Height about 180% of a human and much bulkier than the others.
```

## 2.5 — Couche 5 · Toundra des Âmes

**Usage :** les 6 monstres de la Couche 5. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c05_eclat_ame`, `mob_c05_givreux`, `mob_c05_marcheur_gele`, `mob_c05_loup_givre`, `mob_c05_pleureuse_voilee`, `mob_c05_titan_glace`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 5 "Toundra des Ames" - a frozen waste where the cold holds souls in place, still air, cyan light, thin snow. Palette limited to pale blue-white, cyan, grey. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. ECLAT D'AME - a small hovering pale-blue soul-flame with a faint hollow face inside it, drifting slowly just above the cell feet line. Height about 40% of a human.
2. GIVREUX - a small jagged ice elemental, a body of pale-blue angular crystal shards, frost mist at its base, two cyan glints for eyes. Height about 60% of a human.
3. MARCHEUR GELE - a warrior fully encased in rimed frost-locked plate armor and a frozen cloak, ice crusting every joint, a closed helm, no exposed flesh and no skin, a frost-covered sword sheathed at the hip. Height about 95% of a human.
4. LOUP DE GIVRE - a white-and-pale-blue wolf, its coat rimed with frost, jagged ice crystals along its back and shoulders, fur and ice only with no exposed flesh, head low, on all fours. Head reaches about 90% of a human's height.
5. PLEUREUSE VOILEE - a mourning figure entirely shrouded in long frozen veils and grave-linen from head to floor, no bare skin and no face, only frost-stiff cloth, hands clasped, head bowed. Height about 105% of a human.
6. TITAN DE GLACE - a towering figure carved from solid faceted blue ice, broad and blunt, a smooth featureless head, thick ice limbs, a faint inner glow, no skin and no readable face. Height about 190% of a human and much bulkier than the others.
```

## 2.6 — Couche 6 · Côte des Naufrages

**Usage :** les 6 monstres de la Couche 6. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c06_crabe_epave`, `mob_c06_feu_brume`, `mob_c06_marin_noye`, `mob_c06_murene_dressee`, `mob_c06_garde_corallien`, `mob_c06_leviathan_echoue`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 6 "Cote des Naufrages" - a drowned shore of shipwrecks below the waterline, murky blue-green light, hanging seaweed. Palette limited to deep blue, verdigris green, driftwood brown. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. CRABE D'EPAVE - a barnacle-crusted crab the size of a stool, mismatched claws, its shell studded with old nails and coral, scuttling low. Height about 50% of a human.
2. FEU DE BRUME NOYE - a small drowned green witch-light, a dim waterlogged flame trailing tiny bubbles, hovering just above the cell feet line. Height about 45% of a human.
3. MARIN NOYE - a drowned sailor entirely wrapped in tangled seaweed, a tattered oilskin coat and rope, a diving-hood over the head, no exposed flesh and no face and no bare skin, a rusted cutlass sheathed at the hip. Height about 95% of a human.
4. MURENE DRESSEE - an upright eel-beast standing on a coiled tail, a long finned body, slick verdigris hide, a wide jaw, small eyes, stubby fin arms. Height about 100% of a human.
5. GARDE CORALLIEN - a humanoid guardian plated head to toe in interlocking coral, shell and barnacle armor, no skin and all shell, a blunt coral helm, arms at its sides. Height about 120% of a human.
6. LEVIATHAN ECHOUE - a beached deep-sea beast, a long armored non-humanoid body plated with barnacles and verdigris scutes, stubby crawling limbs, a blunt eyeless head, dragging itself forward. Height about 210% of a human and much bulkier than the others.
```

## 2.7 — Couche 7 · Ruines d'Aethel

**Usage :** les 6 monstres de la Couche 7. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c07_glyphe_flottant`, `mob_c07_automate_brise`, `mob_c07_erudit_spectral`, `mob_c07_chien_albatre`, `mob_c07_gardien_marbre`, `mob_c07_sphinx_dechu`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 7 "Ruines d'Aethel" - the ruined halls of a white-marble city that learned too much, broken columns, violet dusk, floating dust. Palette limited to white marble, tarnished gold, violet. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. GLYPHE FLOTTANT - a small floating construct of interlocking violet glyph-plates and tarnished gold rings, rotating slowly, no face, hovering just above the cell feet line. Height about 40% of a human.
2. AUTOMATE BRISE - a small broken marble automaton crawling on three working limbs, one arm missing, a faint violet light in its cracked chest. Height about 65% of a human.
3. ERUDIT SPECTRAL - a translucent robed scholar, fully hooded and gowned in scholar's robes, no bare skin, the face lost in hood shadow, a closed book held against the chest, hovering a hand's width off the ground. Height about 95% of a human.
4. CHIEN D'ALBATRE - a hound sculpted from cracked white marble with tarnished gold seams, four legs, a smooth blank muzzle, a faint violet glow in the cracks. Head reaches about 80% of a human's height.
5. GARDIEN DE MARBRE - a tall humanoid guardian of white marble with gold trim and a laurel-carved helm, a blade sheathed at the hip, arms at its sides, fully stone with no skin. Height about 115% of a human.
6. SPHINX DECHU - a large weathered stone sphinx-beast, a lion-like marble body, folded stone wings, a worn blank carved head with the features eroded away and no readable face, crouched on all fours. Height about 175% of a human and much bulkier than the others.
```

## 2.8 — Couche 8 · Terres Brisées

**Usage :** les 6 monstres de la Couche 8. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c08_fragment_vif`, `mob_c08_rampe_angles`, `mob_c08_errant_defait`, `mob_c08_chien_non_euclidien`, `mob_c08_veilleur_fracture`, `mob_c08_masse_aberrante`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 8 "Terres Brisees" - a place where geometry lets go, floating rock fragments, impossible angles, purple-black void between. Palette limited to purple, black, white shards. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. FRAGMENT VIF - a small hovering cluster of black-and-white geometric shards orbiting a tiny purple core, sharp edges, no face, floating just above the cell feet line. Height about 40% of a human.
2. RAMPE-ANGLES - a low crawling creature made of folded impossible planes, black and white facets, purple seams, moving as if inside-out, no clear head. Height about 60% of a human.
3. ERRANT DEFAIT - a life-size figure entirely wrapped in shifting dark cloth whose edges glitch into wrong angles, no bare skin and no face, only cloth, arms at its sides, faint purple light at the seams. Height about 100% of a human.
4. CHIEN NON-EUCLIDIEN - a hound whose body forks and repeats at wrong angles, too many legs meeting in impossible joints, black hide with white fracture lines, low stance. Head reaches about 85% of a human's height.
5. VEILLEUR FRACTURE - a tall armored sentinel whose black-and-purple plate armor is splitting apart into floating white prisms held in place around the body, a closed helm, fully armored with no skin. Height about 115% of a human.
6. MASSE ABERRANTE - a large non-humanoid mass of fused stone and dark matter folded at impossible angles, jagged basalt plates and white shard growths, glowing purple fissures, no limbs of any normal count, no face and no skin. Height about 200% of a human and much bulkier than the others.
```

## 2.9 — Couche 9 · Landes du Deuil

**Usage :** les 6 monstres de la Couche 9. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c09_lueur_deuil`, `mob_c09_poupee_suaire`, `mob_c09_spectre_linceul`, `mob_c09_chien_cendre_os`, `mob_c09_porte_etendard`, `mob_c09_golgoth_deuil`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 9 "Landes du Deuil" - bleak moors that echo everything that has fallen, low mist, colourless heather, pale sky. Palette limited to grey, spectral white, pale blue. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. LUEUR DE DEUIL - a small pale mourning wisp, a soft grey-white glow with a faint weeping face, drifting low just above the cell feet line. Height about 40% of a human.
2. POUPEE DE SUAIRE - a small figure of bound grave-linen and twine, roughly doll-shaped, a blank stitched head with no face, standing stiffly. Height about 65% of a human.
3. SPECTRE EN LINCEUL - a winged wraith entirely wrapped in a long tattered burial shroud, ragged shroud-wings instead of arms, a hollow empty hood where a face would be, no bare skin and no flesh, only cloth, hovering just off the ground. Height about 100% of a human.
4. CHIEN CENDRE-D'OS - a skeletal hound of pale bone wreathed in thin grey mist, four legs, empty eye sockets with a faint blue glow, standing low. Head reaches about 85% of a human's height.
5. PORTE-ETENDARD TOMBE - a fallen standard-bearer in dull translucent ghost-plate armor and a closed helm, no skin and all armor, holding a broken cloth-shredded banner pole upright beside the body, head bowed. Height about 110% of a human.
6. GOLGOTH DU DEUIL - a towering cairn-giant built of stacked grey gravestones, bones and rope, a lantern-lit hollow where a heart would be, blunt slab limbs, no skin and no readable face. Height about 185% of a human and much bulkier than the others.
```

## 2.10 — Couche 10 · Forge de Fer

**Usage :** les 6 monstres de la Couche 10. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c10_rivet_vivant`, `mob_c10_foreuse_naine`, `mob_c10_ouvrier_fonte`, `mob_c10_molosse_vapeur`, `mob_c10_contremaitre_blinde`, `mob_c10_marteleur_forge`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 10 "Forge de Fer" - the machine that digs, a vast underground foundry, rust, furnace-red glow, hanging chains. Palette limited to iron grey, rust, hot red. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. RIVET VIVANT - a small skittering critter assembled from bolts, gears and a rivet body, a glowing red seam, six wire legs, low to the ground. Height about 45% of a human.
2. FOREUSE NAINE - a small squat automaton with a conical drill-head, tank treads for feet, a single red lens eye, venting a little steam. Height about 65% of a human.
3. OUVRIER DE FONTE - a foundry worker fully sealed in riveted iron plate and a bolted slit-visored work-helm, no exposed flesh and no skin, all iron, a heavy pick sheathed across the back, thick gloves. Height about 100% of a human.
4. MOLOSSE A VAPEUR - an iron hound of riveted plates venting steam from its joints, a glowing red furnace mouth, four piston legs, head low. Head reaches about 90% of a human's height.
5. CONTREMAITRE BLINDE - a broad foreman-construct in heavy iron plate with a glowing furnace set in its chest, a blunt rivet-studded head with a red lens visor, arms at its sides, fully armored with no skin. Height about 120% of a human.
6. MARTELEUR DE FORGE - a huge non-humanoid iron construct built around two massive piston-driven hammer arms, a squat treaded base, exhaust stacks, red-hot vents, no face. Height about 195% of a human and much bulkier than the others.
```

## 2.11 — Couche 11 · Faille du Vide

**Usage :** les 6 monstres de la Couche 11. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c11_etincelle_vide`, `mob_c11_rampant_ombre`, `mob_c11_porteur_neant`, `mob_c11_limier_vide`, `mob_c11_veilleur_yeux`, `mob_c11_gueule_beante`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 11 "Faille du Vide" - the rift where light stops, a starless dark, neon-violet cracks in the air, cyan afterglow. Palette limited to black, neon violet, cyan. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. ETINCELLE DU VIDE - a small floating void-spark, a black mote ringed by a thin neon-violet halo with a single cyan eye-slit, hovering just above the cell feet line. Height about 40% of a human.
2. RAMPANT D'OMBRE - a low coiling creature of solid dark smoke, its body constantly folding, two glowing violet eye-slits, no fixed shape, close to the ground. Height about 55% of a human.
3. PORTEUR DE NEANT - a life-size figure fully wrapped in black void-cloth flecked with tiny cyan stars, a smooth blank hood, no bare skin and no face, only cloth, arms at its sides, neon-violet light bleeding from the seams. Height about 100% of a human.
4. LIMIER DU VIDE - a hound cut from solid darkness, its edges outlined in neon violet, no visible features except two cyan eye-slits, four legs, low stance. Head reaches about 90% of a human's height.
5. VEILLEUR AUX YEUX - a tall cloaked sentinel in a heavy dark robe studded all over with dozens of closed eyes, a deep empty hood, hands hidden in the sleeves, fully robed with no skin. Height about 115% of a human.
6. GUEULE BEANTE - a large non-humanoid construct, a floating vertical maw ringed with jagged teeth and small cyan eyes, trailing dark tendrils, a neon-violet event-horizon glow at its center, no body and no face. Height about 185% of a human and much bulkier than the others.
```

## 2.12 — Couche 12 · Fin de Toute Chose

**Usage :** les 6 monstres de la Couche 12. · **Ratio :** 3:2 paysage. · **Référence à joindre :** planche héros validée. · **Slugs :** `mob_c12_poussiere_finale`, `mob_c12_reliquat`, `mob_c12_temoin_silencieux`, `mob_c12_ombre_portee`, `mob_c12_gardien_seuil`, `mob_c12_effondrement`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native character resolution so this sheet composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, subjects in a strict evenly-spaced grid of 3 columns by 2 rows, 6 subjects total. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. Each subject alone in its cell, horizontally centered, feet on a line 80% down the cell, with an empty magenta margin of at least 20% of the cell size on every side. Wide empty magenta gutters between every subject; when in doubt, add more spacing rather than less. No subject touches another subject, a cell edge, or the image border. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. Every subject rendered at the same pixel density and detail level, but each subject drawn at its true relative size, all sharing one consistent scale - they do NOT all fill their cells equally.

Theme: layer 12 "Fin de Toute Chose" - the bottom of everything, a featureless white-and-black void, no horizon, no colour. Palette limited to white, black, absence of colour. Every subject: no exposed flesh, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized.

Subjects, read left to right, top row first then bottom row:
1. POUSSIERE FINALE - a tiny fading white mote with a barely-there face, half dissolved into specks, hovering just above the cell feet line. Height about 40% of a human.
2. RELIQUAT - a small crawling husk of colourless flickering static, roughly crab-shaped, its edges breaking into noise, low to the ground. Height about 60% of a human.
3. TEMOIN SILENCIEUX - a life-size figure entirely wrapped in featureless smooth white cloth from head to foot, no face and no seams and no bare skin, arms straight at its sides, perfectly still. Height about 100% of a human.
4. OMBRE PORTEE - a walking flat solid-black humanoid silhouette, no depth, no features, no face, standing upright, arms slightly out. Height about 95% of a human.
5. GARDIEN DU SEUIL - a tall knight in colourless white-and-black plate armor and a smooth closed greathelm, no skin and all armor, a greatsword sheathed across the back, arms at its sides. Height about 120% of a human.
6. EFFONDREMENT - a large non-humanoid collapsing mass, one half blank white and one half solid black meeting in a jagged seam, chunks breaking off and fading, no limbs of normal count, no face and no skin. Height about 195% of a human and much bulkier than the others.
```

---
---

# 3 · BOSS NOMMÉS (12)

1 sujet par prompt, corps entier dans un carré, remplit ~75 % de la hauteur. Ratio **1:1**. Joindre la planche héros en référence.

## 3.1 — Roi Gobelin (Couche 1)

**Usage :** boss nommé de la Couche 1. · **Ratio :** 1:1 carré (idéal 1024×1024). · **Référence à joindre :** planche héros validée. · **Slug :** `boss_roi_gobelin`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LE ROI GOBELIN - boss of layer 1 "Plaine de l'Aube". A massive war-goblin about 2.5 times the height and four times the bulk of a common goblin, broad-shouldered and heavy under his gear, fully armored with no bare skin. He wears a crooked oversized iron crown and a patchwork of plundered plate armor in mismatched metals, a torn deep-red king's cape, and a belt hung with dull gold coins and carved bone trophies. A huge notched two-handed cleaver is sheathed across his back (NOT held, NOT raised). Scarred green face, one tusk snapped short, a heavy brow, a contemptuous sneer, fists loosely clenched at his sides. Palette: dull gold, rust, deep red, bone, muted green. Grim and imposing but completely static, not gory. No exposed flesh apart from the face, no bare skin, no cleavage, modest, not sexualized.
```

## 3.2 — Golem de Pierre (Couche 2)

**Usage :** boss nommé de la Couche 2. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_golem_pierre`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LE GOLEM DE PIERRE - boss of layer 2 "Carriere des Runes". A massive humanoid golem of fitted grey quarry stone, roughly 2.5 times human height, moss and ochre lichen in the seams, deep glowing blue rune-fractures running across the chest, shoulders and forearms, a blocky featureless head with a single horizontal rune-slit, enormous blunt fists hanging at its sides, slabs of carved stone stacked over it like armor plates. Fully rock, no skin, no readable face. Palette: stone grey, ochre, rune blue. Grim and heavy but completely static, not gory. No exposed flesh, no bare skin, modest, not sexualized.
```

## 3.3 — Sorcière des Bois (Couche 3)

**Usage :** boss nommé de la Couche 3. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_sorciere_bois`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LA SORCIERE DES BOIS - boss of layer 3 "Bois des Murmures". A tall gaunt forest witch fully cloaked from head to floor in layered dark leaves, moss and bark, no bare skin and no exposed flesh, the face hidden deep inside a leafy hood as a black void. Long twig-fingers. A twisted branch staff held upright beside the body with its base on the ground (not raised, not casting). A single crow perched still on one shoulder. A faint green hex-glow around the hem. Palette: dark green, violet, brown. Eerie and still, not gory. No bare skin, no cleavage, modest, not sexualized.
```

## 3.4 — Colosse des Cendres (Couche 4)

**Usage :** boss nommé de la Couche 4. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_colosse_cendres`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LE COLOSSE DES CENDRES - boss of layer 4 "Champs de Cendres". A towering giant of cracked black obsidian, about 3 times human height, molten orange light pouring from every fracture, heavy blunt limbs, a featureless faceted head, a jagged ashen crust over the shoulders, a few ember flecks drifting off (kept minimal, no particle spray). Fully rock, no skin, no readable face. Palette: black, ember orange, grey. Menacing and heavy but completely static, not gory. No exposed flesh, no bare skin, modest, not sexualized.
```

## 3.5 — Liche Glaciale (Couche 5)

**Usage :** boss nommé de la Couche 5. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_liche_glaciale`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LA LICHE GLACIALE - boss of layer 5 "Toundra des Ames". A skeletal lich fully armored and robed in frost-locked plate and a long rimed burial gown, no bare skin, only bone, ice and cloth showing. A jagged frozen crown. Hollow eye sockets lit with pale blue soul-fire. A few static shards of ice hanging near the shoulders. Both bony hands folded over a frost-covered staff planted upright on the ground. Palette: pale blue-white, cyan, grey. Cold and regal, not gory. No exposed flesh beyond bone, no bare skin, modest, not sexualized.
```

## 3.6 — Tyran des Abysses (Couche 6)

**Usage :** boss nommé de la Couche 6. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_tyran_abysses`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LE TYRAN DES ABYSSES - boss of layer 6 "Cote des Naufrages". A huge armored deep-sea beast standing upright on a thick coiled finned tail, about 2.5 times human height, its hide plated with barnacles, verdigris scutes and old ship-iron, a blunt anglerfish-like head with small dead eyes and a heavy jaw, a rusted trident sheathed on its back (not held), strands of seaweed hanging off the plates. No bare skin, all shell and armor. Palette: deep blue, verdigris green, driftwood brown. Looming and still, not gory. No exposed flesh, no bare skin, modest, not sexualized.
```

## 3.7 — Archimage Déchu (Couche 7)

**Usage :** boss nommé de la Couche 7. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_archimage_dechu`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: L'ARCHIMAGE DECHU - boss of layer 7 "Ruines d'Aethel". A tall figure in ornate tarnished-gold and white-marble ceremonial robes, fully gowned and hooded, no bare skin, the face lost in shadow beneath a broken halo of floating marble shards. A violet arcane glow in the chest. Several closed spellbooks held in a slow static orbit at waist height. A long scepter held upright beside the body with its base on the ground. Palette: white marble, tarnished gold, violet. Solemn and still, not gory. No exposed flesh, no bare skin, modest, not sexualized.
```

## 3.8 — Béhémoth (Couche 8)

**Usage :** boss nommé de la Couche 8 — **redessiné** en bête colossale non-humanoïde de pierre et d'os (l'ancien sprite a été signalé). Aucune silhouette humanoïde, aucun visage lisible, zéro peau. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_behemoth`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LE BEHEMOTH - boss of layer 8 "Terres Brisees". A colossal purely monstrous non-humanoid beast of fused stone and fossil-bone, about 3.5 times the bulk of a human, a low broad four-legged body with extra limbs bending at impossible wrong angles. Thick basalt hide plates and jutting white crystalline shard-growths cover it. A cluster of curved basalt horns. A blunt broad skull with NO readable face and NO eyes. Glowing purple fissures run between the plates. Absolutely NOT a humanoid silhouette, no upright torso, no arms, no legs like a person, no face, no bare skin, no flesh, no sexualized features - it is pure rock and bone, a beast. Palette: purple, black, white shards. Heavy, alien and still, not gory.
```

## 3.9 — Spectre Hurlant (Couche 9)

**Usage :** boss nommé de la Couche 9 — spectre ailé en linceul (remplace l'idée de harpie). · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_spectre_hurlant`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LE SPECTRE HURLANT - boss of layer 9 "Landes du Deuil". A large winged wraith entirely wrapped in a vast tattered burial shroud, ragged shroud-wings spread wide but held still, a deep hollow hood with only a faint pale glow and a wide silent open maw of shadow where a face would be. No flesh, no skin, only cloth and dark. Spectral chains hang loose from the wrists. Hovering just off the ground. Palette: grey, spectral white, pale blue. Mournful and eerie, not gory. No bare skin, no cleavage, fully shrouded, modest, not sexualized.
```

## 3.10 — Dragon de Fer (Couche 10)

**Usage :** boss nommé de la Couche 10. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_dragon_fer`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: LE DRAGON DE FER - boss of layer 10 "Forge de Fer". A massive four-legged iron dragon plated in riveted rust-streaked metal scales, about 3 times human height at the shoulder, folded mechanical wings of sheet metal and cable, steam venting from seams along the neck (kept as thin haze, not particle spray), a blunt reinforced head with a glowing red furnace throat, heavy claws planted, a low static stance. No exposed flesh, all metal. Palette: iron grey, rust, hot red. Industrial and menacing, not gory. No bare skin, modest, not sexualized.
```

## 3.11 — Œil du Vide (Couche 11)

**Usage :** boss nommé de la Couche 11 — entité flottante non-humanoïde (pas un lanceur de sorts encapuchonné). · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_oeil_vide`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer. One static neutral floating pose. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, its lowest tendrils ending on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above it. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: L'OEIL DU VIDE - boss of layer 11 "Faille du Vide". A large floating non-humanoid entity: one enormous central black eye ringed by a corona of smaller cyan eyes and jagged neon-violet plates, a nest of dark writhing tendrils trailing below it held static, a deep violet event-horizon glow at the pupil. NO body, NO limbs, NO humanoid shape, NO hood, NO face beyond the eyes. Palette: black, neon violet, cyan. Alien and unblinking, not gory. No bare skin, not sexualized.
```

## 3.12 — Avatar de la Fin (Couche 12)

**Usage :** boss nommé de la Couche 12. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `boss_avatar_fin`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, full body, feet on a line about 88% down the image, the subject filling about 75% of the image height with an even empty magenta margin on the sides and a small magenta margin above the head. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders.

Subject: L'AVATAR DE LA FIN - boss of layer 12 "Fin de Toute Chose". A tall silent cloaked figure fully draped head to floor in a colourless robe whose inside is a star-filled black void, no bare skin, no exposed flesh, only an empty white-lit hood where a face would be. Two thin void-blades sheathed crossed on the back (not held). The lower edges of the robe dissolve into drifting specks. Palette: white, black, absence of colour. Final and calm, not gory. No bare skin, no cleavage, modest, not sexualized.
```

---
---

# 4 · BIG BOSS / BOSS DE RAID (12)

1 sujet, **corps entier dans le carré** (pieds visibles, petite marge au-dessus de la tête). Le débordement « colossal » est fait dans le moteur par zoom du cadre — livrer le corps entier. Ratio **1:1**. Joindre la planche héros en référence. Version massive/titanesque du boss de la même couche.

## 4.1 — Roi Gobelin colossal

**Usage :** big boss / raid de la Couche 1. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_roi_gobelin`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - feet on a line about 92% down the image and the very top of the head about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: LE ROI GOBELIN TITANESQUE - raid form of the Goblin King, layer 1. A colossal war-goblin of mountainous muscle sealed under cracked obsidian-plated armor bolted over his old gear, a shattered iron crown fused to his skull, faint glowing runes in the armor seams, two enormous notched blades sheathed crossed on the back (not held), heavy trophy chains of broken shields across the chest. Fully armored, no bare skin apart from the scarred green face. Drawn far bulkier and taller-proportioned than the normal Goblin King boss. Palette: dull gold, rust, deep red, bone, muted green. Overwhelming and static, not gory. No bare skin, no cleavage, modest, not sexualized.
```

## 4.2 — Golem de Pierre colossal

**Usage :** big boss / raid de la Couche 2. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_golem_pierre`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - feet on a line about 92% down the image and the very top of the head about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: LE TITAN DE CARRIERE - raid form of the Stone Golem, layer 2. A mountain-scaled golem built of stacked megalith blocks, an entire cliff-face for a back, blazing blue rune-canyons splitting its chest and shoulders, arms like fallen towers, moss and rockslide debris in the seams, a blank monolith head with a single rune-slit. Fully rock, no skin, no readable face. Drawn far more massive and broader than the normal Stone Golem boss. Palette: stone grey, ochre, rune blue. Immense and static, not gory. No exposed flesh, no bare skin, modest, not sexualized.
```

## 4.3 — Sorcière des Bois colossale

**Usage :** big boss / raid de la Couche 3. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_sorciere_bois`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - feet on a line about 92% down the image and the very top of the head about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: LA MATRIARCHE CREUSE - raid form of the Wood Witch, layer 3. A towering forest-witch grown into a walking thicket: her robe replaced by a cathedral of woven trunks, brambles and hanging moss, no bare skin and no exposed flesh, only a black leafy void inside the vast hood. Branch-arms spreading into a canopy. A huge gnarled staff-tree beside her with its base rooted to the ground. A flock of still crows perched in the branches. Drawn far larger and wider than the normal Wood Witch boss. Palette: dark green, violet, brown. Vast and eerie, not gory. No bare skin, no cleavage, fully covered, modest, not sexualized.
```

## 4.4 — Colosse des Cendres colossal

**Usage :** big boss / raid de la Couche 4. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_colosse_cendres`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - feet on a line about 92% down the image and the very top of the head about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: LE COLOSSE-BUCHER - raid form of the Ash Colossus, layer 4. A volcano-scaled obsidian giant, its whole body a network of molten orange canyons, shoulders crowned with a jagged slag ridge, fists like burning boulders, a faceless magma-lit head. Fully rock, no skin, no readable face. Drawn far more massive and taller than the normal Ash Colossus boss. Palette: black, ember orange, grey. Cataclysmic and static, not gory. No exposed flesh, no bare skin, modest, not sexualized.
```

## 4.5 — Liche Glaciale colossale

**Usage :** big boss / raid de la Couche 5. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_liche_glaciale`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - feet on a line about 92% down the image and the very top of the head about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: LA LICHE-GLACIER - raid form of the Frost Lich, layer 5. A titanic skeletal lich fused into a moving iceberg: robe and plate replaced by cliffs of blue ice over ancient bone, a vast jagged ice-crown, pale blue soul-fire pouring from the eye sockets, both hands folded over a frozen staff the size of a ship's mast planted on the ground. No bare skin, only bone, ice and cloth. Drawn far more massive than the normal Frost Lich boss. Palette: pale blue-white, cyan, grey. Glacial and regal, not gory. No exposed flesh beyond bone, no bare skin, modest, not sexualized.
```

## 4.6 — Tyran des Abysses colossal

**Usage :** big boss / raid de la Couche 6. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_tyran_abysses`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - feet on a line about 92% down the image and the very top of the head about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: LE LEVIATHAN-ROI NOYE - raid form of the Abyssal Tyrant, layer 6. A colossal deep-sea beast reared upright on a huge coiled tail, hull-plates and anchor-chains embedded in its barnacled hide, a cavernous jaw, an entire small shipwreck lodged on its back, a giant rusted trident sheathed behind it (not held). No bare skin, all shell and iron. Drawn far more massive than the normal Abyssal Tyrant boss. Palette: deep blue, verdigris green, driftwood brown. Titanic and looming, not gory. No exposed flesh, no bare skin, modest, not sexualized.
```

## 4.7 — Archimage Déchu colossal

**Usage :** big boss / raid de la Couche 7. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_archimage_dechu`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - feet on a line about 92% down the image and the very top of the head about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: L'ARCHIMAGE SCINDE - raid form of the Fallen Archmage, layer 7. A giant robed figure held together by a slow storm of floating marble ruins and tarnished-gold rings, a vast broken halo overhead, a violet singularity glowing in the open chest cavity, a library of huge spellbooks orbiting slowly at waist height, a great scepter upright beside the body. Fully gowned and hooded, no bare skin, no exposed flesh, the face lost in shadow. Drawn far larger than the normal Fallen Archmage boss. Palette: white marble, tarnished gold, violet. Vast and solemn, not gory. No bare skin, modest, not sexualized.
```

## 4.8 — Béhémoth colossal

**Usage :** big boss / raid de la Couche 8 — bête colossale non-humanoïde de pierre et d'os, aucune silhouette humanoïde, aucun visage, zéro peau. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_behemoth`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - lowest limbs on a line about 92% down the image and the top of the horns about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: LE BEHEMOTH DU MONDE-PLAIE - raid form of the Behemoth, layer 8. A mountain-scaled purely monstrous non-humanoid beast of fused stone and fossil-bone: a low sprawling body with far too many limbs bending at impossible wrong angles, anchoring it to broken ground. Enormous basalt hide plates and forests of white crystalline shard-growths. A ridge of huge curved basalt horns. A blunt eyeless skull with NO readable face. Glowing purple fissures between the plates. Absolutely NOT a humanoid silhouette, no upright torso, no arms or legs like a person, no face, no bare skin, no flesh, no sexualized features - pure colossal beast of rock and bone. Drawn far more massive than the normal Behemoth boss. Palette: purple, black, white shards. Alien and still, not gory.
```

## 4.9 — Spectre Hurlant colossal

**Usage :** big boss / raid de la Couche 9 — spectre ailé géant en linceul. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_spectre_hurlant`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - lowest trailing shroud on a line about 92% down the image and the top of the spread wings about 6% from the top edge, so the whole figure fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire figure here.

Subject: LE DEUIL QUI HURLE - raid form of the Screaming Wraith, layer 9. A sky-filling winged wraith made of one endless tattered burial shroud, wings like torn sails spread wide but held still, a vast hood that opens into a huge silent maw of darkness where a face would be. No flesh, no skin, only cloth and shadow. Long spectral chains hanging from the wrists. Hovering just above the ground. Drawn far larger and wider than the normal Screaming Wraith boss. Palette: grey, spectral white, pale blue. Immense and mournful, not gory. No bare skin, no cleavage, fully shrouded, modest, not sexualized.
```

## 4.10 — Dragon de Fer colossal

**Usage :** big boss / raid de la Couche 10. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_dragon_fer`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - claws on a line about 92% down the image and the top of the head or spine about 6% from the top edge, so the whole creature fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire body here.

Subject: LE DRAGON FOREUSE - raid form of the Iron Dragon, layer 10. A colossal iron dragon the size of a digging machine, riveted rust-streaked hull-plates, drill-bit claws, exhaust towers running along the spine, sheet-metal wings on cable rigging, a furnace-red maw, steam blasting from every seam kept as thick haze not particle spray, planted low over torn earth. No exposed flesh, all metal. Drawn far more massive than the normal Iron Dragon boss. Palette: iron grey, rust, hot red. Industrial and overwhelming, not gory. No bare skin, modest, not sexualized.
```

## 4.11 — Œil du Vide colossal

**Usage :** big boss / raid de la Couche 11 — œil flottant géant, non-humanoïde. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_oeil_vide`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer. One static neutral floating pose. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL SHAPE entirely inside the frame - lowest tendrils on a line about 92% down the image and the top of the outer eye-corona about 6% from the top edge, so the whole entity fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire entity here.

Subject: L'ABYSSE QUI REGARDE - raid form of the Void Eye, layer 11. A planet-scale floating non-humanoid entity: one enormous central black eye whose pupil is a full event horizon, a crown of hundreds of smaller cyan eyes, huge neon-violet plates, and a wide curtain of vast dark tendrils trailing below it held static. NO body, NO limbs, NO humanoid shape, NO hood, NO face beyond the eyes. Drawn far larger than the normal Void Eye boss. Palette: black, neon violet, cyan. Vast, alien and unblinking, not gory. No bare skin, not sexualized.
```

## 4.12 — Avatar de la Fin colossal

**Usage :** big boss / raid de la Couche 12. · **Ratio :** 1:1 carré. · **Référence à joindre :** planche héros validée. · **Slug :** `bigboss_avatar_fin`.

```
Match exactly the art style, palette family, outline weight, pixel density, and lighting of the attached reference image (the two heroes). Keep the same native pixel resolution so this boss composites correctly with the heroes in-game.

Art style: 16-bit pixel-art game sprite, about 96px tall native character resolution (NOT 32 or 48), crisp hard pixels, no anti-aliasing, no blur, no gradients. Flat modern indie pixel-art look, NOT Chrono Trigger, NOT heavy dithering. Limited flat palette of about 20-24 colors, minimal or no dithering, flat cel shading, single light source from the upper-left. Thick dark 1px outline on the outer silhouette. Grim dark-fantasy tone but NOT gory: no blood, no exposed flesh, no wounds, fully clothed or fully armored, no bare skin, no cleavage, modest, not sexualized, family-friendly. Flat front-facing three-quarter view, camera at eye level, subject facing the viewer and angled slightly to its left. One static neutral standing pose, both arms visible, feet flat and apart. No motion lines, no glow, no particles, no effects, no animation frames.

Layout: one single image, ONE single subject, horizontally centered, FULL BODY entirely inside the frame - the dissolving hem on a line about 92% down the image and the top of the hood about 6% from the top edge, so the whole figure fits inside the square with a small even magenta margin all around. Background: 100% flat solid magenta #FF00FF over the entire image, absolutely no gradient/texture/vignette/pattern/noise/lighting on the background. No shadow of any kind, no ground, no floor. No color bleed onto the magenta. No grid lines, boxes, frames, panels, labels, text, numbers, or borders. The colossal "overflows the screen" feeling is added later in the game engine by zooming the frame - deliver the entire figure here.

Subject: LA FIN ELLE-MEME - raid form of the Avatar of the End, layer 12. A colossal silent cloaked figure whose robe is a bottomless starfield-black void, an empty white-lit hood taller than a tower where a face would be, no bare skin and no exposed flesh anywhere. Two enormous void-blades sheathed crossed on the back (not held). The whole outer silhouette frays into drifting specks against nothing. Drawn far larger than the normal Avatar of the End boss. Palette: white, black, absence of colour. Immense, final and calm, not gory. No bare skin, no cleavage, modest, not sexualized.
```

---
---

# 5 · FONDS DE COUCHE (12)

Une seule illustration large de décor parallax, PAS un tileset, aucun motif répété. Ratio **16:9**. Image **opaque** (aucun magenta, aucune zone transparente). Sol dans le tiers inférieur. Bande centrale vide où se déroule le combat. Aucun personnage, aucune créature, aucun texte. Pas besoin de joindre la référence héros — garder seulement la palette de la couche.

## 5.1 — Plaine de l'Aube

**Usage :** décor de combat de la Couche 1. · **Ratio :** 16:9 paysage (idéal 1920×1080). · **Slug :** `bg_zone1`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far sky and horizon, mid-ground silhouettes, near foreground edge. The ground plane runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Calm, readable, slightly melancholic composition.

Scene: "Plaine de l'Aube" - a wide crumbling sunlit grassland at the edge of a collapsing world. Far layer: a pale gold dawn sky, a low sun, a few scattered soft clouds. Mid layer: rolling sage-green grass hills, a handful of bare dead trees, broken stone fence posts, a distant ruined watchtower on the horizon. Near layer: a worn dirt path and tufts of dry grass along the bottom edge. Palette: gold, sage green, tan, soft grey. Quiet, still, gentle.
```

## 5.2 — Carrière des Runes

**Usage :** décor de combat de la Couche 2. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone2`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far sky and horizon, mid-ground silhouettes, near foreground edge. The ground plane runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Calm, readable, slightly melancholic composition.

Scene: "Carriere des Runes" - a vast open quarry of cut grey stone terraces. Far layer: an ochre hazy sky, dust in the air, distant sheer quarry walls. Mid layer: rune-etched rock faces with faint blue glowing carvings, abandoned wooden stone-cutting scaffolds, a few half-carved monolith figures. Near layer: rubble, scattered chisels and a low rune-marked slab along the bottom edge. Palette: stone grey, ochre, rune blue. Silent, watchful, still.
```

## 5.3 — Bois des Murmures

**Usage :** décor de combat de la Couche 3. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone3`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far sky and horizon, mid-ground silhouettes, near foreground edge. The ground plane runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Calm, readable, slightly melancholic composition.

Scene: "Bois des Murmures" - a twisted lightless forest at violet dusk. Far layer: a faint pale sky barely showing between crooked canopies. Mid layer: bent black tree trunks growing at wrong angles, hanging moss, clusters of glowing violet mushrooms, a lost overgrown stone shrine. Near layer: gnarled roots and low fog pooling along the bottom edge. Palette: dark green, violet, brown. Uneasy, hushed, still.
```

## 5.4 — Champs de Cendres

**Usage :** décor de combat de la Couche 4. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone4`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far sky and horizon, mid-ground silhouettes, near foreground edge. The ground plane runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Calm, readable, slightly melancholic composition.

Scene: "Champs de Cendres" - a burnt black plain where the fire never went out. Far layer: a starless smoke-choked sky with a dull orange glow along the horizon. Mid layer: charred tree skeletons, smouldering ruined farmhouses, drifting ash, low ember-lit cracks in the ground. Near layer: cracked scorched earth and a few glowing embers along the bottom edge. Palette: black, ember orange, grey. Desolate, smouldering, still.
```

## 5.5 — Toundra des Âmes

**Usage :** décor de combat de la Couche 5. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone5`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far sky and horizon, mid-ground silhouettes, near foreground edge. The ground plane runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Calm, readable, slightly melancholic composition.

Scene: "Toundra des Ames" - a frozen white waste where the cold holds. Far layer: a pale cyan sky with a faint aurora. Mid layer: wind-carved snow dunes, black frozen standing stones, a half-buried ruined chapel, thin drifting snow. Near layer: rimed rocks and cracked ice along the bottom edge. Palette: pale blue-white, cyan, grey. Still, cold, lonely.
```

## 5.6 — Côte des Naufrages

**Usage :** décor de combat de la Couche 6. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone6`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far water and dim light above, mid-ground silhouettes, near foreground edge. The seabed runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Calm, readable, slightly melancholic composition.

Scene: "Cote des Naufrages" - a drowned shore seen underwater. Far layer: murky deep-blue water with dim light rays filtering down from above. Mid layer: broken ship hulls half-buried in silt, leaning masts, kelp forests, a sunken lighthouse. Near layer: coral, anchor chains and swaying seaweed along the bottom edge. Palette: deep blue, verdigris green, driftwood brown. Muffled, heavy, slow.
```

## 5.7 — Ruines d'Aethel

**Usage :** décor de combat de la Couche 7. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone7`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far sky and horizon, mid-ground silhouettes, near foreground edge. The ground plane runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Calm, readable, slightly melancholic composition.

Scene: "Ruines d'Aethel" - the ruined halls of a white-marble city at violet twilight. Far layer: a violet twilight sky, faint stars, a distant broken skyline of towers. Mid layer: toppled fluted columns, a cracked domed rotunda, chunks of masonry floating in faint violet light, tarnished-gold statues. Near layer: a shattered mosaic floor and drifting dust along the bottom edge. Palette: white marble, tarnished gold, violet. Grand, haunted, quiet.
```

## 5.8 — Terres Brisées

**Usage :** décor de combat de la Couche 8. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone8`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far void, mid-ground floating masses, near foreground edge. Despite the surrounding chaos there is a roughly straight and level standing area across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Readable composition.

Scene: "Terres Brisees" - a place where geometry has failed. Far layer: a purple-black void with no true horizon, a distant collapsing ring of white light. Mid layer: islands of fractured rock floating at impossible angles, staircases leading nowhere, white shard-clusters, an inverted broken tower. Near layer: a cracked slab of ground at a slight wrong tilt along the bottom edge. Palette: purple, black, white shards. Disorienting, wrong, silent.
```

## 5.9 — Landes du Deuil

**Usage :** décor de combat de la Couche 9. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone9`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single soft light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far sky and horizon, mid-ground silhouettes, near foreground edge. The ground plane runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Calm, readable, slightly melancholic composition.

Scene: "Landes du Deuil" - bleak grey moors that echo everything that has fallen. Far layer: a flat pale sky, low mist everywhere, a distant ruined abbey. Mid layer: rows of leaning gravestones, a broken lychgate, bare wind-bent trees, tattered banners on crooked poles. Near layer: colourless heather and a muddy path along the bottom edge. Palette: grey, spectral white, pale blue. Mournful, quiet, still.
```

## 5.10 — Forge de Fer

**Usage :** décor de combat de la Couche 10. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone10`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single warm light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far foundry hall, mid-ground machinery silhouettes, near foreground edge. The steel floor runs straight and level across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Readable composition.

Scene: "Forge de Fer" - a vast underground foundry, the machine that digs. Far layer: a cavernous hall lit furnace-red, towering blast furnaces, a great boring-machine head in the distance. Mid layer: iron gantries, hanging chains, cauldrons of molten metal, conveyor rigs. Near layer: riveted metal floor plates, pipes and a glowing slag channel along the bottom edge. Palette: iron grey, rust, hot red. Oppressive, hot, heavy.
```

## 5.11 — Faille du Vide

**Usage :** décor de combat de la Couche 11. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone11`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, limited flat palette of about 20 colors, minimal dithering, flat parallax layers, single cool light source. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far void, mid-ground floating shapes, near foreground edge. There is a level standing platform across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Readable composition.

Scene: "Faille du Vide" - a starless black rift where light stops. Far layer: pure black split by jagged neon-violet cracks, a distant collapsing ring of violet light. Mid layer: floating slabs of shadow, broken cyan-lit archways drifting. Near layer: a fractured dark platform with a cyan edge-glow along the bottom edge. Palette: black, neon violet, cyan. Airless, cold, humming.
```

## 5.12 — Fin de Toute Chose

**Usage :** décor de combat de la Couche 12. · **Ratio :** 16:9 paysage. · **Slug :** `bg_zone12`.

```
Art style: a SINGLE WIDE pixel-art parallax background illustration, NOT a tileset, no repeating pattern, no seamless tiling, no grid. 16-bit, crisp hard pixels, no anti-aliasing, no blur, very limited flat palette of about 10 colors, minimal dithering, flat parallax layers, flat even light. Fully opaque image, no transparent areas, NO magenta anywhere. No characters, no creatures, no people, no text, no UI, no icons, no frame or border.

Layout: one wide 16:9 landscape illustration with three flat parallax depth layers - far field, mid-ground fading fragments, near foreground edge. There is a level standing area across the lower third of the image, where characters will stand. Keep the whole central horizontal band open and uncluttered, nothing busy or important there - this is where the fight plays out. Very sparse, readable composition.

Scene: "Fin de Toute Chose" - the bottom of everything. Far layer: a featureless field of white above meeting solid black below at a single hairline seam, no horizon detail, no sun. Mid layer: a few last fragments of broken world dissolving into specks, a single dead tree losing its outline. Near layer: bare ground fading between white and black along the bottom edge. Palette: white, black, absence of colour. Empty, final, silent.
```
