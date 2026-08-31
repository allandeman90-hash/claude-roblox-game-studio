# État des assets générés

**Date : 2026-08-31** · **Compte Roblox débanni → upload possible.**

Assets générés par le proprio (Gemini) d'après `tools/assetgen/prompts-a-copier.md`,
identifiés / renommés / découpés avec `tools/assetgen/slice_sheet.py`.

## Dossiers (✅ tout est prêt)

| Dossier | Contenu | Compte |
|---|---|---|
| `hero/final/` | `hero_warrior.png`, `hero_mage.png` (512², détourés) | 2 / 2 |
| `monsters/final/` | `mob_c01_*` … `mob_c12_*` (512², détourés, 6 par couche) | **72 / 72** |
| `bosses/final/` | 12 `boss_*.png` (768²) + 12 `bigboss_*.png` (1024²), détourés | 24 / 24 |
| `backgrounds/` | `bg_zone1.jpg` … `bg_zone12.jpg` (1920×1080, opaques) | 12 / 12 |
| `assets2/` | les 49 planches sources renommées (JPG, sauf 6 en PNG) | — |

**Total : 110 sprites/fonds prêts.**

## Prochaines étapes

1. **Repack en atlas** — 3-4 images de 1024×1024 (monstres × zone / boss / héros) pour
   limiter le nombre d'uploads. `slice_sheet.py` a la logique de placement ; ajouter
   `pack_atlas.py`.
2. **Upload** via Open Cloud API (`tools/assetgen/upload.py`) — le compte est débanni.
3. **Générer `AssetMap.luau`** : slug → `rbxassetid` (ou `ImageRectOffset` + `ImageRectSize`
   si atlas).
4. **Familiers** : mini-versions des 72 monstres + 12 boss → réduction depuis les sprites
   monstres (pas de nouvelle génération).

## Notes qualité

- **Corrigé 2026-08-31** : 5 monstres larges (loup C1, colosse C2, leviathan C6, sphinx C7,
  marteleur C10) étaient coupés G/D — `--relative` mettait à l'échelle sur la hauteur.
  `place()` a maintenant un garde-fou "jamais > canvas" + échelle relative sur `max(w,h)`.
  **Vérifié : 0 sprite clippé.** Les créatures très larges remplissent le canvas (OK).
- **Corrigé** : `mob_c08_fragment_vif` re-découpé (garde l'amas complet, pas un éclat).
- Détourage magenta : `ERODE_FRINGE=2`, `MAGENTA_TOL=85`. Liseré résiduel très léger sur
  1-2 sprites, invisible en jeu (posé pieds-au-sol).
- Le générateur a incrusté les **noms des créatures en texte** sur les planches — exclus
  au découpage.
- Boss C3 (Sorcière des Bois) = personnage encapuchonné · Big boss C3 = arbre géant.
  Décalage visuel assumé (validé).
- Béhémoth (C8) boss + big boss = bête non-humanoïde de pierre/os → aucun risque modération.

## Correspondance planche source → contenu

`assets2/sheet_hero.png` → héros · `assets2/sheet_c01_monsters.jpg` … `sheet_c12_monsters.jpg` → 6 monstres/couche · `assets2/boss_<slug>.jpg` → boss nommé · `assets2/bigboss_<slug>.jpg` → big boss · `assets2/bg_zone1.jpg` … `bg_zone12.jpg` → fonds.

## 2026-08-31 — nettoyage pour le commit

- Sauvegardes `assets2/_originaux/` supprimées (redondantes, noms d'origine).
- Planches sources issues de JPG → re-compressées en `.jpg` (assets2/ : 125M → 17M).
- Fonds de couche → `.jpg` (opaques, pas d'alpha) : `backgrounds/bg_zone*.jpg`.
- Sprites (héros/monstres/boss) quantifiés ~200 couleurs + `optimize`, alpha d'origine conservé.
- Total `assets/images/` : ~29 Mo.
