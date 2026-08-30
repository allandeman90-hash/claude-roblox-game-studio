#!/usr/bin/env python3
"""
place_pixellab.py -- out_raw/pixellab/<id>.png  ->  assets/images/<category>/

The PixelLab PNGs are already clean: transparent, hard-edged, pixel-art, correct
size (64 heroes/pets/mobs, 96 bosses). They do NOT need postprocess.py's SDXL
pipeline (magenta key / rembg / downscale). This script just:

  1. routes each file to a category folder by its id prefix
  2. writes a horizontal mirror  <id>_flip.png  next to it (every combatant +
     pet, so CombatClient can face the sprite toward the hero from either side)

Category by prefix:
  hero_*  -> hero/      pet_*  -> pets/
  boss_*  -> bosses/    mob_*  -> monsters/

Nothing else is touched. Re-runnable (overwrites).

Usage:
    python place_pixellab.py            # place everything
    python place_pixellab.py --no-flip  # skip the mirror copies
    python place_pixellab.py --dry-run
"""
from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
SRC = HERE / "out_raw" / "pixellab"
ASSETS = HERE.parent.parent / "assets" / "images"

PREFIX_DIR = {
    "hero_": "hero",
    "pet_": "pets",
    "boss_": "bosses",
    "mob_": "monsters",
}


def category_for(stem: str) -> str | None:
    for prefix, folder in PREFIX_DIR.items():
        if stem.startswith(prefix):
            return folder
    return None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--no-flip", action="store_true", help="do not write <id>_flip.png mirrors")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    if not SRC.is_dir():
        print(f"missing source dir: {SRC}", file=sys.stderr)
        return 1

    pngs = sorted(p for p in SRC.glob("*.png") if not p.stem.endswith("_flip"))
    if not pngs:
        print(f"no PNGs in {SRC}", file=sys.stderr)
        return 1

    placed = flipped = skipped = 0
    for src in pngs:
        stem = src.stem
        folder = category_for(stem)
        if folder is None:
            print(f"? {stem}  -- unknown prefix, skipped", file=sys.stderr)
            skipped += 1
            continue

        dest_dir = ASSETS / folder
        dest = dest_dir / f"{stem}.png"
        flip_dest = dest_dir / f"{stem}_flip.png"

        if args.dry_run:
            print(f"would place {folder}/{stem}.png" + ("" if args.no_flip else f"  (+ {stem}_flip.png)"))
            continue

        dest_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        placed += 1

        if not args.no_flip:
            im = Image.open(src).convert("RGBA").transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            im.save(flip_dest)
            flipped += 1

        print(f"+ {folder}/{stem}.png" + ("" if args.no_flip else f"  + {stem}_flip.png"))

    print(f"\ndone. placed={placed} flipped={flipped} skipped={skipped} -> {ASSETS}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
