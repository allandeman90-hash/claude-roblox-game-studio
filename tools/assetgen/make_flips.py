#!/usr/bin/env python3
"""
make_flips.py -- genere le miroir horizontal de chaque sprite de combat.

Roblox n'a pas de flip natif sur ImageLabel : CombatClient attend, pour chaque
slug, une variante "<slug>_flip" (art qui regarde dans l'autre sens). Ce script
lit les sprites detoures et ecrit leur miroir dans un sous-dossier `flip/`.

Entree :
    assets/images/hero/final/*.png       (2)
    assets/images/monsters/final/*.png   (72)
    assets/images/bosses/final/*.png     (24  -> boss_* et bigboss_*)

Sortie (miroir horizontal, alpha conserve) :
    assets/images/hero/flip/<slug>_flip.png
    assets/images/monsters/flip/<slug>_flip.png
    assets/images/bosses/flip/<slug>_flip.png

Les 12 fonds backgrounds/*.jpg ne sont PAS retournes (decor, pas d'orientation).

Usage :
    python make_flips.py            # (re)genere tout
    python make_flips.py --dry-run
"""
import argparse
import glob
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
IMG = os.path.join(ROOT, "assets", "images")
FLIP_LR = Image.Transpose.FLIP_LEFT_RIGHT

CATEGORIES = ["hero", "monsters", "bosses"]


def main() -> int:
    ap = argparse.ArgumentParser(description="Genere les miroirs horizontaux des sprites.")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    total = 0
    for cat in CATEGORIES:
        src_dir = os.path.join(IMG, cat, "final")
        out_dir = os.path.join(IMG, cat, "flip")
        if not os.path.isdir(src_dir):
            print(f"  !! {src_dir} absent, categorie ignoree")
            continue
        if not args.dry_run:
            os.makedirs(out_dir, exist_ok=True)
        for path in sorted(glob.glob(os.path.join(src_dir, "*.png"))):
            slug = os.path.basename(path)[:-4]
            if slug.endswith("_flip"):
                continue
            out_path = os.path.join(out_dir, f"{slug}_flip.png")
            total += 1
            if args.dry_run:
                print(f"  would write {cat}/flip/{slug}_flip.png")
                continue
            im = Image.open(path).convert("RGBA").transpose(FLIP_LR)
            im.save(out_path, optimize=True)
            print(f"  + {cat}/flip/{slug}_flip.png")

    print(f"\n{'(dry-run) ' if args.dry_run else ''}{total} miroirs "
          f"{'a generer' if args.dry_run else 'ecrits'}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
