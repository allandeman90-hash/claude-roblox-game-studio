#!/usr/bin/env python3
"""
generate.py -- manifest.yaml -> ComfyUI -> raw PNGs in out_raw/<category>/<id>.png

Does NOT touch the game. Requires a running ComfyUI (see README.md).

Usage:
    python generate.py                 # whole manifest
    python generate.py --only ui pets  # selected categories
    python generate.py --id enemy_slime boss_behemoth
    python generate.py --force         # ignore the prompt cache, re-render
    python generate.py --dry-run       # print prompts, call nothing
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
import time
import uuid
from pathlib import Path

import requests
import yaml

HERE = Path(__file__).resolve().parent
OUT_RAW = HERE / "out_raw"
CACHE_DIR = HERE / ".cache"
CACHE_FILE = CACHE_DIR / "generate.json"


# --------------------------------------------------------------------------- io
def load_yaml(name: str) -> dict:
    with open(HERE / name, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def load_cache() -> dict:
    if CACHE_FILE.exists():
        return json.loads(CACHE_FILE.read_text(encoding="utf-8"))
    return {}


def save_cache(cache: dict) -> None:
    CACHE_DIR.mkdir(exist_ok=True)
    CACHE_FILE.write_text(json.dumps(cache, indent=2, ensure_ascii=False), encoding="utf-8")


# ---------------------------------------------------------------------- prompts
def iter_assets(manifest: dict):
    """Yield (category, item_dict) for every asset in the manifest."""
    root_defaults = manifest.get("defaults", {}) or {}
    for cat_name, cat in (manifest.get("categories", {}) or {}).items():
        cat_defaults = {**root_defaults, **(cat.get("defaults", {}) or {})}
        prefix = cat.get("prompt_prefix", "") or ""
        for item in cat.get("items", []) or []:
            merged = {**cat_defaults, **item}
            merged["_category"] = cat_name
            merged["_prompt_prefix"] = prefix
            yield cat_name, merged


def seed_for(style: dict, category: str, asset_id: str) -> int:
    mode = style["style"].get("seed_mode", "per_category")
    if mode == "fixed":
        return int(style["style"].get("seed_fixed", 0))
    basis = category if mode == "per_category" else asset_id
    digest = hashlib.sha256(basis.encode("utf-8")).hexdigest()
    return int(digest[:12], 16) % 2_147_483_647


def build_prompts(style: dict, item: dict) -> tuple[str, str]:
    st = style["style"]
    bg = item.get("bg", "magenta")
    if bg == "keep":
        bg_clause = "opaque, edges wrap seamlessly"
        suffix = st.get("positive_suffix_scene", st["positive_suffix"])
    else:
        bg_clause = st["bg_rembg_clause"] if bg == "rembg" else st["bg_magenta_clause"]
        suffix = st["positive_suffix"]
    suffix = suffix.strip().replace("{bg_clause}", bg_clause)
    positive = f'{item["_prompt_prefix"]}{item["prompt"]}{"" if suffix.startswith(",") else ", "}{suffix}'
    positive = positive.replace("{v}", "").replace("  ", " ").strip()
    negative = " ".join(st["negative"].split())
    return positive, negative


def prompt_signature(positive: str, negative: str, seed: int, size: int, cfg: dict) -> str:
    blob = json.dumps([positive, negative, seed, size, cfg], sort_keys=True)
    return hashlib.sha1(blob.encode("utf-8")).hexdigest()


# ------------------------------------------------------------------- comfy graph
def prepare_graph(workflow: dict, style: dict, positive: str, negative: str,
                  seed: int, gen_size: int) -> dict:
    cfgc = style["comfyui"]
    n = cfgc["nodes"]
    g = json.loads(json.dumps(workflow))  # deep copy

    ckpt = cfgc.get("checkpoint") or ""
    lora = cfgc.get("lora") or ""

    if n["checkpoint"] in g and ckpt:
        g[n["checkpoint"]]["inputs"]["ckpt_name"] = ckpt

    if lora and n.get("lora") in g:
        g[n["lora"]]["inputs"]["lora_name"] = lora
        g[n["lora"]]["inputs"]["strength_model"] = float(cfgc.get("lora_strength", 1.0))
        g[n["lora"]]["inputs"]["strength_clip"] = float(cfgc.get("lora_strength", 1.0))
        clip_src = [n["lora"], 1]
        model_src = [n["lora"], 0]
    else:
        # No LoRA -> drop the node and wire CLIP / model straight from the checkpoint.
        g.pop(n.get("lora", ""), None)
        clip_src = [n["checkpoint"], 1]
        model_src = [n["checkpoint"], 0]

    vae = cfgc.get("vae") or ""
    vae_node = n.get("vae")
    if vae and vae_node in g:
        g[vae_node]["inputs"]["vae_name"] = vae
    elif vae_node in g:
        # No external VAE -> drop the loader, decode with the checkpoint's VAE.
        g.pop(vae_node, None)
        for node in g.values():
            if node.get("class_type") == "VAEDecode":
                node["inputs"]["vae"] = [n["checkpoint"], 2]

    g[n["positive"]]["inputs"]["text"] = positive
    g[n["positive"]]["inputs"]["clip"] = clip_src
    g[n["negative"]]["inputs"]["text"] = negative
    g[n["negative"]]["inputs"]["clip"] = clip_src

    g[n["latent"]]["inputs"]["width"] = gen_size
    g[n["latent"]]["inputs"]["height"] = gen_size

    smp = g[n["sampler"]]["inputs"]
    s = cfgc["sampler"]
    smp["seed"] = seed
    smp["steps"] = int(s["steps"])
    smp["cfg"] = float(s["cfg"])
    smp["sampler_name"] = s["sampler_name"]
    smp["scheduler"] = s["scheduler"]
    smp["model"] = model_src

    return g


def comfy_run(base: str, graph: dict, client_id: str, poll: float, timeout: float) -> bytes:
    r = requests.post(f"{base}/prompt", json={"prompt": graph, "client_id": client_id}, timeout=30)
    r.raise_for_status()
    prompt_id = r.json()["prompt_id"]

    deadline = time.time() + timeout
    while time.time() < deadline:
        time.sleep(poll)
        h = requests.get(f"{base}/history/{prompt_id}", timeout=30)
        h.raise_for_status()
        data = h.json().get(prompt_id)
        if not data:
            continue
        status = data.get("status", {})
        if status.get("status_str") == "error":
            raise RuntimeError(f"ComfyUI reported an error: {status}")
        outputs = data.get("outputs", {})
        for node_out in outputs.values():
            for img in node_out.get("images", []):
                params = {"filename": img["filename"], "subfolder": img.get("subfolder", ""),
                          "type": img.get("type", "output")}
                v = requests.get(f"{base}/view", params=params, timeout=60)
                v.raise_for_status()
                return v.content
    raise TimeoutError(f"ComfyUI job {prompt_id} timed out after {timeout}s")


# --------------------------------------------------------------------------- main
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--only", nargs="*", metavar="CATEGORY", help="restrict to these categories")
    ap.add_argument("--id", nargs="*", metavar="ASSET_ID", help="restrict to these asset ids")
    ap.add_argument("--force", action="store_true", help="ignore the cache, re-render")
    ap.add_argument("--dry-run", action="store_true", help="print prompts, call nothing")
    args = ap.parse_args()

    style = load_yaml("style.yaml")
    manifest = load_yaml("manifest.yaml")
    workflow = json.loads((HERE / style["comfyui"]["workflow"]).read_text(encoding="utf-8"))

    base = style["comfyui"]["url"].rstrip("/")
    gen_size = int(style["comfyui"]["gen_size"])
    poll = float(style["comfyui"].get("poll_interval", 1.5))
    timeout = float(style["comfyui"].get("timeout", 240))
    client_id = uuid.uuid4().hex

    cache = load_cache()
    targets = list(iter_assets(manifest))
    if args.only:
        wanted = set(args.only)
        targets = [t for t in targets if t[0] in wanted]
    if args.id:
        wanted = set(args.id)
        targets = [t for t in targets if t[1]["id"] in wanted]

    if not targets:
        print("nothing matched.", file=sys.stderr)
        return 1

    if not args.dry_run and not (style["comfyui"].get("checkpoint") or "").strip().endswith(".safetensors"):
        print("!! style.yaml -> comfyui.checkpoint is still a placeholder. Set it first.", file=sys.stderr)
        return 2

    ok = skipped = failed = 0
    for category, item in targets:
        asset_id = item["id"]
        size = int(item.get("size", 64))
        seed = int(item["seed"]) if "seed" in item else seed_for(style, category, asset_id)
        positive, negative = build_prompts(style, item)
        sig = prompt_signature(positive, negative, seed, gen_size, style["comfyui"]["sampler"])
        dest = OUT_RAW / category / f"{asset_id}.png"

        if args.dry_run:
            print(f"[{category}/{asset_id}] seed={seed} size={size}\n  + {positive}\n")
            continue

        if not args.force and cache.get(asset_id, {}).get("sig") == sig and dest.exists():
            skipped += 1
            print(f"= {category}/{asset_id} (cached)")
            continue

        try:
            graph = prepare_graph(workflow, style, positive, negative, seed, gen_size)
            png = comfy_run(base, graph, client_id, poll, timeout)
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(png)
            cache[asset_id] = {"sig": sig, "seed": seed, "category": category,
                               "size": size, "bg": item.get("bg", "magenta")}
            save_cache(cache)
            ok += 1
            print(f"+ {category}/{asset_id}  seed={seed}")
        except Exception as exc:  # noqa: BLE001 -- keep going through the batch
            failed += 1
            print(f"! {category}/{asset_id}  FAILED: {exc}", file=sys.stderr)

    print(f"\ndone. rendered={ok} cached={skipped} failed={failed}")
    return 0 if failed == 0 else 3


if __name__ == "__main__":
    raise SystemExit(main())
