#!/usr/bin/env python3
"""
postprocess.py -- out_raw/<category>/<id>.png  ->  assets/images/<category>/<id>.png

Steps per image:
  1. background -> alpha       (magenta key by default; rembg if bg: rembg; skip if bg: keep)
  2. autocrop to the subject + square pad
  3. nearest-neighbour resize to the manifest size (32 / 64)
  4. quantise to a small palette (flat pixel-art look), alpha preserved

Reads the same manifest.yaml / style.yaml as generate.py. Pillow only
(rembg optional). Does NOT touch the game.

Usage:
    python postprocess.py                 # everything in out_raw/
    python postprocess.py --only ui pets
    python postprocess.py --id enemy_slime
    python postprocess.py --keep-size     # skip step 3 (debug)
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

import yaml
from PIL import Image

HERE = Path(__file__).resolve().parent
OUT_RAW = HERE / "out_raw"
ASSETS = HERE.parent.parent / "assets" / "images"


def load_yaml(name: str) -> dict:
    with open(HERE / name, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def manifest_index(manifest: dict) -> dict[str, dict]:
    """asset_id -> {category, size, bg}"""
    out: dict[str, dict] = {}
    root_defaults = manifest.get("defaults", {}) or {}
    for cat_name, cat in (manifest.get("categories", {}) or {}).items():
        cat_defaults = {**root_defaults, **(cat.get("defaults", {}) or {})}
        for item in cat.get("items", []) or []:
            merged = {**cat_defaults, **item}
            out[item["id"]] = {
                "category": cat_name,
                "size": int(merged.get("size", 64)),
                "bg": merged.get("bg", "magenta"),
                "isolate": bool(merged.get("isolate", True)),
            }
    return out


# ------------------------------------------------------------------ bg removal
from PIL import ImageDraw  # noqa: E402


def _border_samples(im: Image.Image, inset: int = 3):
    w, h = im.size
    i = inset
    pts = [(i, i), (w - 1 - i, i), (i, h - 1 - i), (w - 1 - i, h - 1 - i),
           (w // 2, i), (w // 2, h - 1 - i), (i, h // 2), (w - 1 - i, h // 2)]
    return [im.getpixel(p)[:3] for p in pts], pts


def detect_flat_bg(im: Image.Image):
    """Return ((r,g,b), spread) for the border colour. Low spread => flat background."""
    cols, _ = _border_samples(im)
    med = tuple(sorted(c[k] for c in cols)[len(cols) // 2] for k in range(3))
    spread = max(max(abs(c[k] - med[k]) for k in range(3)) for c in cols)
    return med, spread


def key_flat_bg(im: Image.Image, tol: int, alpha_cutoff: int) -> Image.Image:
    """Flood-fill the contiguous border region (any uniform colour) to transparent.

    Robust to the model ignoring the 'magenta background' instruction: whatever
    flat colour it used (grey, white, magenta) gets keyed, without punching holes
    in a subject that happens to share that colour.
    """
    im = im.convert("RGBA")
    rgb = im.convert("RGB")
    _, seeds = _border_samples(im)
    for seed in seeds:
        ImageDraw.floodfill(rgb, seed, (1, 2, 3), thresh=tol)  # sentinel recolour
    sent = rgb.load()
    alpha = im.getchannel("A")
    ap = alpha.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            if sent[x, y] == (1, 2, 3):
                ap[x, y] = 0
    alpha = alpha.point(lambda v: 0 if v < alpha_cutoff else v)
    im.putalpha(alpha)
    return im


# kept name for compatibility; now colour-agnostic
def key_magenta(im: Image.Image, tol: int, alpha_cutoff: int) -> Image.Image:
    return key_flat_bg(im, tol, alpha_cutoff)


_REMBG_SESSION = None


def key_rembg(im: Image.Image):
    global _REMBG_SESSION
    try:
        from rembg import remove, new_session  # type: ignore
    except ImportError:
        print("  rembg not installed -- `pip install rembg onnxruntime`. Falling back to flat-bg key.",
              file=sys.stderr)
        return None
    if _REMBG_SESSION is None:
        _REMBG_SESSION = new_session("isnet-general-use")  # crisper masks than u2net
    cut = remove(im.convert("RGBA"), session=_REMBG_SESSION, post_process_mask=True)
    # rembg leaves soft mask edges; harden them for pixel art.
    a = cut.getchannel("A").point(lambda v: 0 if v < 128 else 255)
    cut.putalpha(a)
    return cut


# --------------------------------------------------------------------- shaping
def autocrop_square(im: Image.Image, pad_ratio: float) -> Image.Image:
    bbox = im.getchannel("A").getbbox()
    if bbox:
        im = im.crop(bbox)
    w, h = im.size
    side = max(w, h)
    pad = int(round(side * pad_ratio))
    side += pad * 2
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(im, ((side - w) // 2, (side - h) // 2), im)
    return canvas


def keep_largest_blob(im: Image.Image, min_frac: float = 0.06) -> Image.Image:
    """Zero the alpha of every connected component except the largest.

    Runs on the already-downscaled image (tiny), so a plain BFS is fine. Kills
    detached islands (a floating weapon the model drew apart from the character,
    a leftover cast-shadow blob) without touching the main sprite. Components
    >= min_frac of the largest are also kept (lets a staff tip / gap survive).
    """
    w, h = im.size
    ap = im.getchannel("A").load()
    solid = [[ap[x, y] > 8 for x in range(w)] for y in range(h)]
    label = [[0] * w for _ in range(h)]
    sizes: dict[int, int] = {}
    cur = 0
    for sy in range(h):
        for sx in range(w):
            if not solid[sy][sx] or label[sy][sx]:
                continue
            cur += 1
            stack = [(sx, sy)]
            label[sy][sx] = cur
            n = 0
            while stack:
                x, y = stack.pop()
                n += 1
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and solid[ny][nx] and not label[ny][nx]:
                        label[ny][nx] = cur
                        stack.append((nx, ny))
            sizes[cur] = n
    if len(sizes) <= 1:
        return im
    biggest = max(sizes.values())
    keep = {k for k, v in sizes.items() if v >= max(1, int(biggest * min_frac))}
    alpha = im.getchannel("A")
    px = alpha.load()
    for y in range(h):
        for x in range(w):
            if label[y][x] and label[y][x] not in keep:
                px[x, y] = 0
    im.putalpha(alpha)
    return im


def quantise(im: Image.Image, colors: int) -> Image.Image:
    rgb = im.convert("RGB").quantize(colors=max(2, colors), dither=Image.Dither.NONE).convert("RGB")
    rgb.putalpha(im.getchannel("A"))
    return rgb


# ----------------------------------------------------------------------- main
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--only", nargs="*", metavar="CATEGORY")
    ap.add_argument("--id", nargs="*", metavar="ASSET_ID")
    ap.add_argument("--keep-size", action="store_true", help="do not resize (debug)")
    args = ap.parse_args()

    style = load_yaml("style.yaml")
    idx = manifest_index(load_yaml("manifest.yaml"))
    pp = style.get("postprocess", {})
    tol = int(pp.get("magenta_tolerance", 60))
    alpha_cutoff = int(pp.get("alpha_cutoff", 24))
    colors = int(pp.get("palette_colors", 24))
    pad_ratio = float(pp.get("pad", 2)) / 64.0

    raws = sorted(OUT_RAW.rglob("*.png"))
    if args.only:
        raws = [p for p in raws if p.parent.name in set(args.only)]
    if args.id:
        raws = [p for p in raws if p.stem in set(args.id)]
    if not raws:
        print("no raw PNGs matched (run generate.py first).", file=sys.stderr)
        return 1

    done = failed = 0
    for raw in raws:
        asset_id = raw.stem
        meta = idx.get(asset_id, {"category": raw.parent.name, "size": 64, "bg": "magenta", "isolate": True})
        try:
            im = Image.open(raw).convert("RGBA")
            bg = meta["bg"]

            if bg == "keep":
                pass
            elif bg == "rembg":
                cut = key_rembg(im)
                im = cut if cut is not None else key_magenta(im, tol, alpha_cutoff)
            else:
                im = key_magenta(im, tol, alpha_cutoff)

            if bg != "keep":
                im = autocrop_square(im, pad_ratio)

            if not args.keep_size:
                im = im.resize((meta["size"], meta["size"]), Image.Resampling.NEAREST)

            if bg != "keep" and meta.get("isolate", True):
                im = keep_largest_blob(im)

            im = quantise(im, colors)

            dest = ASSETS / meta["category"] / f"{asset_id}.png"
            dest.parent.mkdir(parents=True, exist_ok=True)
            im.save(dest)
            done += 1
            print(f"+ {meta['category']}/{asset_id}  {im.size[0]}px")
        except Exception as exc:  # noqa: BLE001
            failed += 1
            print(f"! {asset_id}  FAILED: {exc}", file=sys.stderr)

    print(f"\ndone. written={done} failed={failed} -> {ASSETS}")
    return 0 if failed == 0 else 3


if __name__ == "__main__":
    raise SystemExit(main())
