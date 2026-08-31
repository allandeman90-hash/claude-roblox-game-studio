#!/usr/bin/env python3
"""
slice_sheet.py - decoupe une planche multi-sprites Gemini/Imagen en PNG individuels.

Fond magenta #FF00FF -> transparent, puis detection des sprites par projection
(gouttieres magenta) + composantes connexes, recadrage serre, alignement des pieds,
redimensionnement au canvas cible.

Usage:
  python slice_sheet.py <planche.png> --slugs a,b,c,d,e,f --out <dir> [--canvas 512]
  python slice_sheet.py <planche.png> --slugs warrior,mage --out ../../assets/images/hero --canvas 512

Sans --grid, la detection est automatique (marche pour 1-12 sprites bien separes).
"""
import argparse, os, sys
import numpy as np
from PIL import Image
from scipy import ndimage

MAGENTA_TOL = 85          # distance max au magenta pur pour considerer "fond"
ALPHA_SNAP = 24           # en dessous -> 0
ERODE_FRINGE = 2          # px de frange magenta a ronger sur le bord du sprite
MIN_AREA_FRAC = 0.0008    # ignore les taches < 0.08% de la planche (bruit, watermark)


def key_magenta(rgba: np.ndarray) -> np.ndarray:
    """Retourne un masque bool True = pixel de sprite (non-fond)."""
    r, g, b = rgba[..., 0].astype(int), rgba[..., 1].astype(int), rgba[..., 2].astype(int)
    # magenta pur = (255, 0, 255). "fond" = proche de ca OU (R haut, G bas, B haut).
    dist = np.sqrt((r - 255) ** 2 + (g - 0) ** 2 + (b - 255) ** 2)
    is_bg = (dist < MAGENTA_TOL * 1.732) | ((r > 200) & (b > 200) & (g < 90))
    return ~is_bg


def components(mask: np.ndarray, total_px: int, want: int = 0, img_h: int = 0):
    """Composantes connexes triees en lecture (haut->bas, gauche->droite).
    Filtre le texte (large + plat + petit) et, si `want`>0, garde les `want` plus
    grandes puis les retrie en ordre de lecture."""
    lbl, n = ndimage.label(mask)
    raw = []
    for i in range(1, n + 1):
        ys, xs = np.where(lbl == i)
        area = len(xs)
        if area < total_px * MIN_AREA_FRAC:
            continue
        w, h = xs.max() - xs.min() + 1, ys.max() - ys.min() + 1
        if w > 2.6 * h and area < total_px * 0.006:      # bandeau de texte
            continue
        raw.append((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1, area))
    if want and len(raw) > want:
        raw = sorted(raw, key=lambda b: -b[4])[:want]
    boxes = raw
    # fusionne les boites qui se chevauchent fortement (halo detache)
    boxes.sort(key=lambda b: -b[4])
    merged = []
    for b in boxes:
        hit = False
        for j, m in enumerate(merged):
            ix0, iy0 = max(b[0], m[0]), max(b[1], m[1])
            ix1, iy1 = min(b[2], m[2]), min(b[3], m[3])
            if ix1 > ix0 and iy1 > iy0:
                merged[j] = (min(b[0], m[0]), min(b[1], m[1]),
                             max(b[2], m[2]), max(b[3], m[3]), b[4] + m[4])
                hit = True
                break
        if not hit:
            merged.append(b)
    # ordre lecture : bandes de lignes (seuil = 25% de la hauteur d'image) puis x
    thr = (img_h or 1000) * 0.25
    merged.sort(key=lambda b: (b[1] + b[3]) / 2)
    rows, cur, ref = [], [], None
    for b in merged:
        cy = (b[1] + b[3]) / 2
        if ref is None or cy - ref < thr:
            cur.append(b)
            ref = cy if ref is None else ref
        else:
            rows.append(sorted(cur, key=lambda z: z[0]))
            cur, ref = [b], cy
    if cur:
        rows.append(sorted(cur, key=lambda z: z[0]))
    return [b for row in rows for b in row]


def largest_blob(cell: np.ndarray) -> np.ndarray | None:
    """Dans une cellule keyee, garde la plus grosse composante connexe (= la creature),
    jette tout le reste (texte du label, fragments JPG, bruit)."""
    alpha = cell[..., 3] > 0
    if not alpha.any():
        return None
    lbl, n = ndimage.label(alpha)
    sizes = ndimage.sum(alpha, lbl, range(1, n + 1))
    keep = int(np.argmax(sizes)) + 1
    m = lbl == keep
    ys, xs = np.where(m)
    out = cell.copy()
    out[~m] = (0, 0, 0, 0)
    return out[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def grid_cells(rgba: np.ndarray, cols: int, rows: int):
    """Decoupe geometrique en cols x rows, ordre lecture."""
    H, W = rgba.shape[:2]
    for r in range(rows):
        for c in range(cols):
            y0, y1 = round(r * H / rows), round((r + 1) * H / rows)
            x0, x1 = round(c * W / cols), round((c + 1) * W / cols)
            yield rgba[y0:y1, x0:x1]


def clean_rgba(img: Image.Image) -> np.ndarray:
    rgba = np.array(img.convert("RGBA"))
    mask = key_magenta(rgba)
    a = np.where(mask, 255, 0).astype(np.uint8)
    if ERODE_FRINGE:
        a = (ndimage.binary_erosion(a > 0, iterations=ERODE_FRINGE) * 255).astype(np.uint8)
    rgba[..., 3] = a
    rgba[a < ALPHA_SNAP] = (0, 0, 0, 0)
    return rgba


def tight_crop(rgba: np.ndarray, box):
    x0, y0, x1, y1 = box[:4]
    sub = rgba[y0:y1, x0:x1]
    ys, xs = np.where(sub[..., 3] > 0)
    if len(xs) == 0:
        return None
    return sub[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def place(arr: np.ndarray, canvas: int, scale: float):
    im = Image.fromarray(arr, "RGBA")
    if scale != 1.0:
        im = im.resize((max(1, round(im.width * scale)),
                        max(1, round(im.height * scale))), Image.NEAREST)
    # garde-fou : jamais plus grand que le canvas (sinon clip G/D ou H/B)
    if im.width > canvas or im.height > canvas:
        f = min(canvas / im.width, canvas / im.height)
        im = im.resize((max(1, round(im.width * f)), max(1, round(im.height * f))), Image.NEAREST)
    sheet = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    x = (canvas - im.width) // 2
    y = canvas - im.height - 2
    sheet.paste(im, (x, max(0, y)), im)
    return sheet


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("sheet")
    ap.add_argument("--slugs", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--canvas", type=int, default=512)
    ap.add_argument("--prefix", default="")
    ap.add_argument("--relative", action="store_true",
                    help="conserve les tailles relatives entre sprites de la planche")
    ap.add_argument("--drop-smallest", type=int, default=0,
                    help="si N sprites en trop, retire les N plus petits (intrus/texte)")
    ap.add_argument("--grid", default="",
                    help="COLSxROWS : decoupe geometrique (garde l'ordre, vire le texte). "
                         "ex '3x2'. Recommande pour les planches de monstres.")
    ap.add_argument("--boxes", default="",
                    help="x0,y0,x1,y1;x0,y0,x1,y1;... une boite par slug (ordre roster). "
                         "Dans chaque boite : garde la plus grosse forme (vire texte/fragments).")
    args = ap.parse_args()

    slugs = [s.strip() for s in args.slugs.split(",") if s.strip()]
    img = Image.open(args.sheet).convert("RGBA")
    rgba = clean_rgba(img)

    if args.boxes:
        boxes = [tuple(int(v) for v in b.split(",")) for b in args.boxes.split(";") if b.strip()]
        assert len(boxes) == len(slugs), f"{len(boxes)} boites, {len(slugs)} slugs"
        crops = [largest_blob(rgba[y0:y1, x0:x1]) for (x0, y0, x1, y1) in boxes]
        print(f"planche {img.size}  {len(boxes)} boites")
        common = 1.0
        if args.relative:
            dmax = max(max(c.shape[0], c.shape[1]) for c in crops if c is not None)
            common = (args.canvas * 0.96) / dmax
        os.makedirs(args.out, exist_ok=True)
        for c, slug in zip(crops, slugs):
            if c is None:
                print(f"  !! {slug}: boite vide"); continue
            scale = common if args.relative else min(
                args.canvas / c.shape[1], (args.canvas * 0.94) / c.shape[0])
            place(c, args.canvas, scale).save(os.path.join(args.out, f"{args.prefix}{slug}.png"))
            print(f"  -> {slug}  crop {c.shape[1]}x{c.shape[0]}")
        return

    if args.grid:
        cols, rows = (int(x) for x in args.grid.lower().split("x"))
        crops = [largest_blob(cell) for cell in grid_cells(rgba, cols, rows)]
        crops = [c for c in crops if c is not None][:len(slugs)]
        print(f"planche {img.size}  grille {cols}x{rows}  ->  {len(crops)} creature(s), {len(slugs)} slug(s)")
        common = 1.0
        if args.relative and crops:
            dmax = max(max(c.shape[0], c.shape[1]) for c in crops)
            common = (args.canvas * 0.96) / dmax
        os.makedirs(args.out, exist_ok=True)
        for c, slug in zip(crops, slugs):
            scale = common if args.relative else min(
                args.canvas / c.shape[1], (args.canvas * 0.94) / c.shape[0])
            out = place(c, args.canvas, scale)
            p = os.path.join(args.out, f"{args.prefix}{slug}.png")
            out.save(p)
            print(f"  -> {p}  crop {c.shape[1]}x{c.shape[0]}  ->  {out.size}")
        return

    H, W = rgba.shape[:2]
    boxes = components(rgba[..., 3] > 0, H * W, want=len(slugs), img_h=H)

    print(f"planche {img.size}  ->  {len(boxes)} creature(s) retenue(s), {len(slugs)} slug(s)")
    if len(boxes) < len(slugs):
        for i, b in enumerate(boxes):
            print(f"  [{i}] {b[2]-b[0]}x{b[3]-b[1]}px  aire={b[4]}")
        print("!! pas assez de sprites -- verifie la planche")
        sys.exit(1)

    crops = [tight_crop(rgba, b) for b in boxes[:len(slugs)]]
    common = 1.0
    if args.relative:
        dmax = max(max(c.shape[0], c.shape[1]) for c in crops if c is not None)
        common = (args.canvas * 0.96) / dmax

    os.makedirs(args.out, exist_ok=True)
    for c, slug in zip(crops, slugs):
        if c is None:
            print(f"  -- {slug}: vide, ignore")
            continue
        if args.relative:
            scale = common
        else:
            scale = min(args.canvas / c.shape[1], (args.canvas * 0.94) / c.shape[0])
        out = place(c, args.canvas, scale)
        p = os.path.join(args.out, f"{args.prefix}{slug}.png")
        out.save(p)
        print(f"  -> {p}  crop {c.shape[1]}x{c.shape[0]}  ->  {out.size}")


if __name__ == "__main__":
    main()
