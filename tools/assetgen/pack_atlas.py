#!/usr/bin/env python3
"""
pack_atlas.py - repack les sprites de combat de Quete Minute en atlas 1024x1024.

Entree :  assets/images/hero/final/*.png            (2)
          assets/images/monsters/final/*.png        (72, mob_cNN_*)
          assets/images/bosses/final/boss_*.png     (12, sources 768)
          assets/images/bosses/final/bigboss_*.png  (12, sources 1024)
   Les 12 fonds backgrounds/*.jpg NE sont PAS dans l'atlas (opaques, uploades tels quels).

Sortie (dans tools/assetgen/ par defaut) :
   atlas_0.png .. atlas_3.png            4 planches RGBA 1024x1024
   atlas_0_flip.png .. atlas_3_flip.png  (--flip) miroir horizontal
   atlas-manifest.json                   { "<slug>": {atlas,x,y,w,h}, ... }
   _atlas_preview.png                    planche de controle (grille des decoupes)

Regroupement :
   atlas_0 : hero_warrior, hero_mage + monstres couches C01..C06   (38)
   atlas_1 : monstres couches C07..C12                             (36)
   atlas_2 : boss_*                                                (12)
   atlas_3 : bigboss_*                                             (12)

Chaque sprite est recadre sur sa bbox alpha puis reduit (plafond de dimension
max par type). Le plafond est adaptatif : si un lot deborde d'une planche, il
baisse de 5% et on recommence. Bin-packing par rangees (tri hauteur
decroissante). Marge 2 px. Un sprite qui ne rentre nulle part -> planche
supplementaire + log.

Usage :
   python pack_atlas.py            # 4 atlas de base
   python pack_atlas.py --flip     # + 4 atlas miroir
"""
import argparse, glob, json, math, os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

LANCZOS = Image.Resampling.LANCZOS
FLIP_LR = Image.Transpose.FLIP_LEFT_RIGHT

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
IMG = os.path.join(ROOT, "assets", "images")

ATLAS_W = ATLAS_H = 1024
MARGIN = 2
ALPHA_FLOOR = 6           # alpha <= -> transparent
FILL_LIMIT = 0.97         # hauteur max d'une planche avant de reduire le plafond
MIN_FACTOR = 0.25         # en dessous : on abandonne, planches multiples + log

# plafond de dimension max (px) du plus grand cote, par type de sprite
CAPS = {"hero": 224, "mob": 176, "boss": 270, "bigboss": 260}


def kind(slug: str) -> str:
    if slug.startswith("bigboss"):
        return "bigboss"
    if slug.startswith("boss"):
        return "boss"
    if slug.startswith("hero"):
        return "hero"
    return "mob"


def mob_layer(slug: str) -> int:
    return int(slug.split("_")[1][1:])          # mob_c07_xxx -> 7


def load_sprites(patterns):
    out, files = [], []
    for p in patterns:
        files.extend(glob.glob(p))
    for path in sorted(files):
        arr = np.array(Image.open(path).convert("RGBA"))
        ys, xs = np.where(arr[..., 3] > ALPHA_FLOOR)
        if len(xs) == 0:
            print(f"  !! {os.path.basename(path)} : entierement transparent, ignore")
            continue
        crop = arr[ys.min():ys.max() + 1, xs.min():xs.max() + 1].copy()
        out.append((os.path.basename(path)[:-4], crop))
    return out


def scale_rgba(crop: np.ndarray, s: float) -> np.ndarray:
    """Reduction LANCZOS sans halo noir (premultiplie -> resize -> demultiplie)."""
    if s >= 0.999:
        return crop
    h, w = crop.shape[:2]
    nw, nh = max(1, round(w * s)), max(1, round(h * s))
    f = crop.astype(np.float64)
    a = f[..., 3:4] / 255.0
    pm = f.copy()
    pm[..., :3] *= a
    im = Image.fromarray(pm.astype(np.uint8), "RGBA").resize((nw, nh), LANCZOS)
    o = np.array(im).astype(np.float64)
    oa = np.clip(o[..., 3:4] / 255.0, 1e-4, None)
    o[..., :3] /= oa
    o = np.clip(o, 0, 255).astype(np.uint8)
    o[np.array(im)[..., 3] < ALPHA_FLOOR] = (0, 0, 0, 0)
    return o


def shelf_pack(items, W, H, margin):
    """items: [(slug, w, h)] -> (pages, unplaced). page: [(slug, x, y, w, h)]."""
    items = sorted(items, key=lambda t: -t[2])
    pages = [[]]
    x = y = shelf_h = 0
    unplaced = []
    for slug, w, h in items:
        pw, ph = w + margin, h + margin
        if pw > W or ph > H:
            unplaced.append(slug)
            continue
        if x + pw > W:
            x, shelf_h, y = 0, 0, y + shelf_h
        if y + ph > H:
            pages.append([])
            x = y = shelf_h = 0
        pages[-1].append((slug, x, y, w, h))
        x += pw
        shelf_h = max(shelf_h, ph)
    return pages, unplaced


def page_height(page):
    return max((y + h + MARGIN for _, _, y, _, h in page), default=0)


def fit_bucket(sprites):
    """Reduit le plafond jusqu'a tenir sur 1 planche. Retourne (factor, pages)."""
    factor = 1.0
    while True:
        sized = []
        for slug, crop in sprites:
            cap = CAPS[kind(slug)] * factor
            h, w = crop.shape[:2]
            s = min(1.0, cap / max(w, h))
            sized.append((slug, max(1, round(w * s)), max(1, round(h * s))))
        pages, unplaced = shelf_pack(sized, ATLAS_W, ATLAS_H, MARGIN)
        ok = (len(pages) == 1 and not unplaced
              and page_height(pages[0]) <= ATLAS_H * FILL_LIMIT)
        if ok or factor <= MIN_FACTOR:
            if not ok:
                print(f"  !! lot non tenu sur 1 planche (factor {factor:.2f}, "
                      f"{len(pages)} planche(s), non places {unplaced})")
            return factor, pages
        factor -= 0.05


def build():
    hero = load_sprites([os.path.join(IMG, "hero", "final", "*.png")])
    mon = load_sprites([os.path.join(IMG, "monsters", "final", "*.png")])
    boss = load_sprites([os.path.join(IMG, "bosses", "final", "boss_*.png")])
    bigboss = load_sprites([os.path.join(IMG, "bosses", "final", "bigboss_*.png")])
    if not (hero and mon and boss and bigboss):
        sys.exit("!! sprites manquants - verifie assets/images/{hero,monsters,bosses}/final/")

    mon_lo = [s for s in mon if mob_layer(s[0]) <= 6]
    mon_hi = [s for s in mon if mob_layer(s[0]) >= 7]
    bucket_defs = [
        ("hero + monstres C01-C06", hero + mon_lo),
        ("monstres C07-C12", mon_hi),
        ("boss (boss_*)", boss),
        ("big boss (bigboss_*)", bigboss),
    ]

    manifest, atlases, idx = {}, [], 0
    for label, sprites in bucket_defs:
        factor, pages = fit_bucket(sprites)
        crop_at = {}
        for slug, crop in sprites:
            cap = CAPS[kind(slug)] * factor
            h, w = crop.shape[:2]
            crop_at[slug] = scale_rgba(crop, min(1.0, cap / max(w, h)))
        for page in pages:
            name = f"atlas_{idx}"
            idx += 1
            sheet = Image.new("RGBA", (ATLAS_W, ATLAS_H), (0, 0, 0, 0))
            for slug, x, y, w, h in page:
                cr = crop_at[slug]
                ch, cw = cr.shape[:2]
                sheet.paste(Image.fromarray(cr, "RGBA"), (x, y))
                manifest[slug] = {"atlas": f"{name}.png", "x": int(x), "y": int(y),
                                  "w": int(cw), "h": int(ch)}
            atlases.append((name, sheet, page, label, factor))
    return manifest, atlases


def add_flips(manifest, atlases, outdir):
    for name, sheet, page, _, _ in atlases:
        sheet.transpose(FLIP_LR).save(os.path.join(outdir, f"{name}_flip.png"), optimize=True)
        for slug, x, y, w, h in page:
            base = manifest[slug]
            manifest[f"{slug}_flip"] = {
                "atlas": f"{name}_flip.png",
                "x": ATLAS_W - int(x) - base["w"],
                "y": int(y), "w": base["w"], "h": base["h"],
            }


def load_font(size):
    for p in (r"C:\Windows\Fonts\arialbd.ttf", r"C:\Windows\Fonts\arial.ttf",
              "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            pass
    return ImageFont.load_default()


def build_preview(atlases, outpath):
    cols = 2
    rows = math.ceil(len(atlases) / cols)
    panel, pad, header, sq = 780, 14, 24, 16
    W = cols * panel + (cols + 1) * pad
    H = rows * (panel + header) + (rows + 1) * pad
    canvas = Image.new("RGB", (W, H), (28, 28, 32))
    draw = ImageDraw.Draw(canvas)
    f_hdr, f_lbl = load_font(15), load_font(9)
    for i, (name, sheet, page, label, factor) in enumerate(atlases):
        ox = pad + (i % cols) * (panel + pad)
        oy = pad + (i // cols) * (panel + header + pad)
        checker = Image.new("RGB", (panel, panel), (205, 205, 205))
        cd = ImageDraw.Draw(checker)
        for yy in range(0, panel, sq):
            for xx in range(0, panel, sq):
                if (xx // sq + yy // sq) % 2:
                    cd.rectangle([xx, yy, xx + sq, yy + sq], fill=(175, 175, 175))
        small = sheet.resize((panel, panel), LANCZOS)
        checker.paste(small, (0, 0), small)
        canvas.paste(checker, (ox, oy + header))
        draw.text((ox, oy + 5),
                  f"{name}.png   {label}   {len(page)} sprites   echelle x{factor:.2f}",
                  fill=(255, 255, 255), font=f_hdr)
        sc = panel / ATLAS_W
        for slug, x, y, w, h in page:
            r = [ox + x * sc, oy + header + y * sc,
                 ox + (x + w) * sc, oy + header + (y + h) * sc]
            draw.rectangle(r, outline=(0, 220, 0), width=1)
            if w * sc > 34:
                tag = slug.replace("mob_", "").replace("bigboss_", "BB:").replace("boss_", "B:")
                draw.text((r[0] + 1, r[1] + 1), tag[:16], fill=(210, 20, 20), font=f_lbl)
    canvas.save(outpath)


def main():
    ap = argparse.ArgumentParser(description="Repack les sprites de combat en atlas 1024.")
    ap.add_argument("--out", default=HERE, help="dossier de sortie (defaut: tools/assetgen/)")
    ap.add_argument("--flip", action="store_true", help="genere aussi les atlas miroir _flip")
    ap.add_argument("--no-preview", action="store_true", help="ne pas ecrire _atlas_preview.png")
    args = ap.parse_args()
    outdir = os.path.abspath(args.out)
    os.makedirs(outdir, exist_ok=True)

    manifest, atlases = build()
    for name, sheet, *_ in atlases:
        sheet.save(os.path.join(outdir, f"{name}.png"), optimize=True)
    if args.flip:
        add_flips(manifest, atlases, outdir)

    manifest = dict(sorted(manifest.items()))
    with open(os.path.join(outdir, "atlas-manifest.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=2, ensure_ascii=False)
        fh.write("\n")

    if not args.no_preview:
        build_preview(atlases, os.path.join(outdir, "_atlas_preview.png"))

    placed = sum(len(p) for _, _, p, _, _ in atlases)
    n_atlas = len(atlases) * (2 if args.flip else 1)
    print("\n=== pack_atlas - recap ===")
    for name, sheet, page, label, factor in atlases:
        occ = sum(w * h for _, _, _, w, h in page) / (ATLAS_W * ATLAS_H) * 100
        print(f"  {name}.png  {ATLAS_W}x{ATLAS_H}  {len(page):2d} sprites  "
              f"occ {occ:4.1f}%  h={page_height(page)}/{ATLAS_H}  "
              f"echelle x{factor:.2f}  ({label})")
    print(f"\n  sprites places : {placed} / {placed}")
    print(f"  non places     : aucun")
    print(f"  atlas ecrits   : {n_atlas}  ({'base + flip' if args.flip else 'base seul'})")
    print(f"  manifest       : atlas-manifest.json  ({len(manifest)} entrees)")
    if not args.no_preview:
        print(f"  preview        : _atlas_preview.png")
    print(f"\n  --> a uploader : {n_atlas} atlas + 12 fonds = {n_atlas + 12} assets")


if __name__ == "__main__":
    main()
