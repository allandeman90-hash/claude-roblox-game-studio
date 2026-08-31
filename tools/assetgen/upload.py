#!/usr/bin/env python3
"""
upload.py -- assets/images/**/*.png  ->  Roblox (Open Cloud)  ->  AssetMap.luau

For every PNG under assets/images/ that is not already uploaded (sha1 cache),
create a Decal via the Open Cloud Assets API, wait for moderation, and record
its asset id. Then (re)write src/ReplicatedStorage/AssetMap.luau.

Env vars (never stored on disk, never committed):
    ROBLOX_API_KEY       Creator API key with asset:read + asset:write
    ROBLOX_CREATOR_ID    your user id  (or a group id)
    ROBLOX_CREATOR_TYPE  "User" (default) or "Group"

Usage:
    python upload.py                # upload new/changed, rewrite AssetMap
    python upload.py --only ui      # restrict to a category folder
    python upload.py --map-only     # skip uploading, just rebuild AssetMap from cache
    python upload.py --dry-run
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import time
from pathlib import Path

import requests

HERE = Path(__file__).resolve().parent
ASSETS = HERE.parent.parent / "assets" / "images"
ASSET_MAP = HERE.parent.parent / "src" / "ReplicatedStorage" / "AssetMap.luau"
CACHE_DIR = HERE / ".cache"
# v2 cache: the pre-ban run used uploads.json with a now-defunct naming scheme
# and dead asset ids. Start clean, keep the old file for reference.
CACHE_FILE = CACHE_DIR / "uploads-v2.json"

# Only these dirs are uploaded (relative to assets/images/). Everything else
# under assets/images/ -- notably assets2/ (source sheets) -- is ignored.
SCAN_DIRS = [
    "hero/final", "hero/flip",
    "monsters/final", "monsters/flip",
    "bosses/final", "bosses/flip",
    "backgrounds",
]
EXTS = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg"}

API_ASSETS = "https://apis.roblox.com/assets/v1/assets"
API_OP = "https://apis.roblox.com/assets/v1/operations/{}"


CREDS_FILE = Path.home() / ".roblox" / "open-cloud.env"


def load_creds_file() -> None:
    """If ROBLOX_API_KEY is not already in the env, source ~/.roblox/open-cloud.env
    (KEY=VALUE lines). That file lives outside the repo and outside OneDrive and
    is never committed."""
    if os.environ.get("ROBLOX_API_KEY") or not CREDS_FILE.exists():
        return
    for line in CREDS_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        os.environ.setdefault(k.strip(), v.strip())
    print(f"loaded credentials from {CREDS_FILE}")


def load_cache() -> dict:
    if CACHE_FILE.exists():
        return json.loads(CACHE_FILE.read_text(encoding="utf-8"))
    return {}


def save_cache(cache: dict) -> None:
    CACHE_DIR.mkdir(exist_ok=True)
    CACHE_FILE.write_text(json.dumps(cache, indent=2, sort_keys=True), encoding="utf-8")


def sha1_of(path: Path) -> str:
    return hashlib.sha1(path.read_bytes()).hexdigest()


def creator_block() -> dict:
    cid = os.environ.get("ROBLOX_CREATOR_ID", "").strip()
    ctype = os.environ.get("ROBLOX_CREATOR_TYPE", "User").strip().lower()
    if not cid:
        raise SystemExit("ROBLOX_CREATOR_ID is not set.")
    return {"groupId": cid} if ctype == "group" else {"userId": cid}


def upload_one(session: requests.Session, path: Path, asset_id_slug: str,
               poll: float = 2.0, timeout: float = 180.0) -> str:
    request_json = {
        "assetType": "Decal",
        "displayName": f"qm_{asset_id_slug}"[:50],
        "description": "Quete minute — generated pixel-art asset (assetgen)",
        "creationContext": {"creator": creator_block()},
    }
    mime = EXTS.get(path.suffix.lower(), "image/png")
    files = {
        "request": (None, json.dumps(request_json), "application/json"),
        "fileContent": (path.name, path.read_bytes(), mime),
    }
    r = session.post(API_ASSETS, files=files, timeout=60)
    if r.status_code == 429:
        time.sleep(10)
        r = session.post(API_ASSETS, files=files, timeout=60)
    r.raise_for_status()
    op_id = r.json().get("operationId") or r.json().get("path", "").split("/")[-1]
    if not op_id:
        raise RuntimeError(f"no operationId in response: {r.text[:300]}")

    deadline = time.time() + timeout
    while time.time() < deadline:
        time.sleep(poll)
        o = session.get(API_OP.format(op_id), timeout=30)
        o.raise_for_status()
        body = o.json()
        if body.get("done"):
            resp = body.get("response", {})
            aid = resp.get("assetId") or resp.get("id")
            if not aid:
                raise RuntimeError(f"operation done but no assetId: {body}")
            return str(aid)
    raise TimeoutError(f"operation {op_id} timed out")


# NOTE (Decal vs Image id): Open Cloud uploads images as **Decal** assets. An
# ImageLabel.Image needs the underlying **Image (Texture)** id, not the Decal id.
# After this script runs, resolve the ids once in Studio (Server, Play mode):
#
#   local IS = game:GetService("InsertService")
#   local AM = require(game.ReplicatedStorage.AssetMap)
#   local out = {}
#   for slug, ref in pairs(AM) do
#       local m = IS:LoadAsset(tonumber(ref:match("%d+")))
#       local d = m:FindFirstChildWhichIsA("Decal", true)
#       out[slug] = d and d.Texture ; m:Destroy()
#   end
#   -- print `out` and paste the resolved ids back into AssetMap.luau
def write_asset_map(entries: dict[str, str]) -> None:
    lines = [
        "--==============================================================",
        "-- AssetMap  (ModuleScript - ReplicatedStorage)",
        "--",
        "-- GENERATED by tools/assetgen/upload.py -- DO NOT EDIT BY HAND.",
        "-- Maps an asset slug to its uploaded Roblox content id.",
        "-- NOTE: these are Decal ids; resolve to Image (Texture) ids in Studio",
        "-- (see the resolver snippet in upload.py) before using in ImageLabel.Image.",
        "--==============================================================",
        "",
        "local AssetMap = {",
    ]
    for slug in sorted(entries):
        lines.append(f'\t{_lua_key(slug)} = "rbxassetid://{entries[slug]}",')
    lines += ["}", "", "return AssetMap", ""]
    ASSET_MAP.parent.mkdir(parents=True, exist_ok=True)
    ASSET_MAP.write_text("\n".join(lines), encoding="utf-8")


def _lua_key(slug: str) -> str:
    if slug.isidentifier():
        return slug
    return f'["{slug}"]'


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--only", nargs="*", metavar="CATEGORY")
    ap.add_argument("--map-only", action="store_true", help="rebuild AssetMap from cache, upload nothing")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    load_creds_file()
    cache = load_cache()  # sha1 -> {assetId, slug, category}

    if args.map_only:
        entries = {v["slug"]: v["assetId"] for v in cache.values() if v.get("assetId")}
        write_asset_map(entries)
        print(f"AssetMap rebuilt from cache: {len(entries)} entries -> {ASSET_MAP}")
        return 0

    key = os.environ.get("ROBLOX_API_KEY", "").strip()
    if not key and not args.dry_run:
        raise SystemExit("ROBLOX_API_KEY is not set. See README.md section 5.")

    scan = [d for d in SCAN_DIRS if not args.only or d.split("/")[0] in set(args.only)]
    imgs: list[Path] = []
    for rel in scan:
        d = ASSETS / rel
        if not d.is_dir():
            print(f"  !! {rel}/ absent, ignore", file=sys.stderr)
            continue
        for p in sorted(d.iterdir()):
            if p.suffix.lower() in EXTS:
                imgs.append(p)
    if not imgs:
        print("no images in the scanned dirs (run generate/slice + make_flips.py first).", file=sys.stderr)
        return 1
    print(f"{len(imgs)} images to consider across {len(scan)} dir(s).")

    session = requests.Session()
    session.headers["x-api-key"] = key

    uploaded = skipped = failed = 0
    for png in imgs:
        slug = png.stem
        digest = sha1_of(png)
        if digest in cache and cache[digest].get("assetId"):
            skipped += 1
            continue
        if args.dry_run:
            print(f"would upload {png.parent.name}/{slug}")
            continue
        try:
            aid = upload_one(session, png, slug)
            cache[digest] = {"assetId": aid, "slug": slug, "category": png.parent.name}
            save_cache(cache)
            uploaded += 1
            print(f"+ {png.parent.name}/{slug} -> {aid}")
        except Exception as exc:  # noqa: BLE001
            failed += 1
            print(f"! {slug} FAILED: {exc}", file=sys.stderr)

    if not args.dry_run:
        entries = {v["slug"]: v["assetId"] for v in cache.values() if v.get("assetId")}
        write_asset_map(entries)
        print(f"\ndone. uploaded={uploaded} cached={skipped} failed={failed}")
        print(f"AssetMap: {len(entries)} entries -> {ASSET_MAP}")
    return 0 if failed == 0 else 3


if __name__ == "__main__":
    raise SystemExit(main())
