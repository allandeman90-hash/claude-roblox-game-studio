# Atlas des sprites de combat

`pack_atlas.py` recadre et repacke les 62 sprites de combat en **4 atlas
1024x1024** (+ 4 miroirs avec `--flip`). Les 12 fonds `backgrounds/*.jpg`
ne sont pas concernes (opaques, uploades tels quels).

## Relancer

    cd tools/assetgen
    python pack_atlas.py --flip

| Fichier | Contenu |
|---|---|
| `atlas_0.png` | `hero_warrior`, `hero_mage` + 36 monstres couches C01-C06 |
| `atlas_1.png` | 36 monstres couches C07-C12 |
| `atlas_2.png` | 12 `boss_*` (mini-boss, sources 768) |
| `atlas_3.png` | 12 `bigboss_*` (big boss, sources 1024) |
| `atlas_0_flip.png` .. `atlas_3_flip.png` | miroir horizontal -> variantes `<slug>_flip` |
| `atlas-manifest.json` | position de chaque sprite |
| `_atlas_preview.png` | planche de controle (grille verte des decoupes) |

Options : `--out <dir>`, `--no-preview`, sans `--flip` = 4 atlas de base seulement.

## Format du manifest

    {
      "mob_c03_loup_sylvestre":      { "atlas": "atlas_0.png",      "x": 512, "y": 40, "w": 150, "h": 176 },
      "mob_c03_loup_sylvestre_flip": { "atlas": "atlas_0_flip.png", "x": 362, "y": 40, "w": 150, "h": 176 }
    }

`x,y` = coin haut-gauche du sprite dans l'atlas. `w,h` = taille du sprite
(recadre serre sur l'alpha, ratio non carre).

## Traduction Luau (ImageLabel sur atlas)

    local entry = AtlasManifest[slug]                 -- { atlas=, x=, y=, w=, h= }
    img.Image = AtlasIds[entry.atlas]                 -- rbxassetid de l'atlas
    img.ImageRectOffset = Vector2.new(entry.x, entry.y)
    img.ImageRectSize   = Vector2.new(entry.w, entry.h)

Pour garder l'ancrage pieds-au-sol (`AnchorPoint = Vector2.new(0.5, 1)`),
contraindre le ratio du label au ratio du sprite plutot que compter sur
`ScaleType.Fit` :

    local ratio = img:FindFirstChildOfClass("UIAspectRatioConstraint")
        or Instance.new("UIAspectRatioConstraint", img)
    ratio.AspectRatio = entry.w / entry.h

Le retournement se fait en echangeant le slug : `AtlasManifest[slug .. "_flip"]`
(Roblox n'a pas de flip horizontal natif sur `ImageLabel` ; `CombatClient`
utilise deja cette convention `_flip`).

## Downscale applique

Sources reduites pour tenir : plafond ~224 px (heros), ~176 px (monstres),
~270 px (mini-boss), ~260 px (big boss) sur le plus grand cote. Le jeu les
affiche petits (`CombatClient` : slot mob ~55-165 px, boss x1.5) -> perte
invisible. Le facteur exact est affiche par le script et ecrit dans l'en-tete
de chaque panneau du preview.

## A uploader (Track A2)

**8 atlas** (`atlas_0..3` + `atlas_0..3_flip`) **+ 12 fonds**
(`backgrounds/bg_zone1..12.jpg`) = **20 assets**.

`AssetMap.luau` n'est PAS genere ici : c'est le job d'`upload.py` (Track A2),
qui uploade les 8 atlas + 12 fonds et ecrit la table slug -> rbxassetid.
