"""Convert Roblox creator-docs YAML into raw-source markdown files.

Reads YAML files from /tmp/roblox-yaml and writes one .md per class
into the services/ directory. Preserves text verbatim.
"""
from __future__ import annotations

import os
import sys
import re
import yaml
from pathlib import Path

SRC = Path("C:/Users/talme/.tmp/roblox-yaml")
OUT = Path("C:/Users/talme/claude-code-rbx-studios/FoG-Roblox-Studio-Command/wiki/raw/roblox-creator-docs/services")

# Category + tag hints keyed by class name.
CATEGORIES = {
    # persistence
    "DataStoreService": ("persistence", ["data-stores", "persistence"]),
    "GlobalDataStore": ("persistence", ["data-stores", "persistence"]),
    "OrderedDataStore": ("persistence", ["data-stores", "persistence", "leaderboards"]),
    "DataStoreKeyInfo": ("persistence", ["data-stores", "persistence"]),
    "DataStore": ("persistence", ["data-stores", "persistence"]),
    # memory store
    "MemoryStoreService": ("memory-store", ["memory-store", "persistence"]),
    "MemoryStoreSortedMap": ("memory-store", ["memory-store"]),
    "MemoryStoreHashMap": ("memory-store", ["memory-store"]),
    "MemoryStoreQueue": ("memory-store", ["memory-store"]),
    # networking
    "RemoteEvent": ("networking", ["networking", "events"]),
    "RemoteFunction": ("networking", ["networking", "rpc"]),
    "UnreliableRemoteEvent": ("networking", ["networking", "events", "unreliable"]),
    "BindableEvent": ("events", ["events", "in-context"]),
    "BindableFunction": ("events", ["events", "rpc", "in-context"]),
    # economy
    "MarketplaceService": ("economy", ["economy", "monetization", "purchases"]),
    # players
    "Players": ("players", ["players", "service"]),
    "Player": ("players", ["players", "instance"]),
    "PlayerGui": ("gui", ["gui", "players"]),
    # starter containers
    "StarterGui": ("gui", ["gui", "starter"]),
    "StarterPlayer": ("players", ["starter", "players"]),
    "StarterPlayerScripts": ("players", ["starter", "players", "scripts"]),
    "StarterCharacterScripts": ("players", ["starter", "characters", "scripts"]),
    # workspace / containers
    "ReplicatedStorage": ("containers", ["containers", "replication"]),
    "ServerStorage": ("containers", ["containers", "server"]),
    "ServerScriptService": ("containers", ["containers", "scripts", "server"]),
    "ReplicatedFirst": ("containers", ["containers", "replication", "load"]),
    "Workspace": ("world", ["workspace", "world", "service"]),
    # runtime
    "RunService": ("runtime", ["runtime", "lifecycle", "service"]),
    # visuals / audio
    "Lighting": ("environment", ["lighting", "environment", "service"]),
    "SoundService": ("audio", ["audio", "service"]),
    "Sound": ("audio", ["audio", "instance"]),
    "SoundGroup": ("audio", ["audio", "mixing"]),
    # tweening
    "TweenService": ("animation", ["tweens", "animation", "service"]),
    "Tween": ("animation", ["tweens", "animation"]),
    # teleport / http / chat / messaging
    "TeleportService": ("networking", ["teleport", "service"]),
    "HttpService": ("networking", ["http", "service", "web"]),
    "TextChatService": ("chat", ["chat", "text", "service"]),
    "MessagingService": ("networking", ["messaging", "cross-server", "service"]),
    # collection / input
    "CollectionService": ("world", ["tags", "collection", "service"]),
    "ContextActionService": ("input", ["input", "actions", "service"]),
    "UserInputService": ("input", ["input", "service"]),
    "GuiService": ("gui", ["gui", "service"]),
    # interaction
    "ProximityPrompt": ("interaction", ["interaction", "prompt"]),
    "ClickDetector": ("interaction", ["interaction", "click"]),
}


def render_md(cls_name: str, data: dict) -> str:
    category, tags = CATEGORIES.get(cls_name, ("class", ["roblox-class"]))
    tags = ["roblox-class", *tags]

    lines: list[str] = []
    lines.append("---")
    lines.append(f"title: {cls_name}")
    lines.append("type: raw-source")
    lines.append(f"source_url: https://create.roblox.com/docs/reference/engine/classes/{cls_name}")
    lines.append("source_type: official-roblox-docs")
    lines.append("source_repo: https://github.com/Roblox/creator-docs")
    lines.append(
        f"source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/{cls_name}.yaml"
    )
    lines.append("captured_at: 2026-04-16")
    lines.append("captured_by: research-agent-1")
    lines.append(f"category: {category}")
    lines.append("tags: [" + ", ".join(tags) + "]")
    lines.append("---")
    lines.append("")
    lines.append(f"# {cls_name}")
    lines.append("")

    # Summary + description
    summary = (data.get("summary") or "").strip()
    description = (data.get("description") or "").strip()
    if summary:
        lines.append(summary)
        lines.append("")
    if description and description != summary:
        lines.append("## Description")
        lines.append("")
        lines.append(description)
        lines.append("")

    # Inheritance
    inherits = data.get("inherits") or []
    tags_list = data.get("tags") or []
    memory_category = data.get("memory_category")
    deprecation_message = (data.get("deprecation_message") or "").strip()
    lines.append("## Inheritance")
    lines.append("")
    if inherits:
        lines.append("Inherits from: " + ", ".join(f"`{p}`" for p in inherits))
    else:
        lines.append("Inherits from: (none listed)")
    if tags_list:
        lines.append("")
        lines.append("Class tags: " + ", ".join(f"`{t}`" for t in tags_list))
    if memory_category:
        lines.append("")
        lines.append(f"Memory category: `{memory_category}`")
    if deprecation_message:
        lines.append("")
        lines.append(f"**Deprecation message:** {deprecation_message}")
    lines.append("")

    # Properties
    props = data.get("properties") or []
    lines.append("## Properties")
    lines.append("")
    if not props:
        lines.append("_No public properties documented._")
        lines.append("")
    else:
        for p in props:
            pname = p.get("name", "")
            ptype = p.get("type", "")
            psum = (p.get("summary") or "").strip()
            pdesc = (p.get("description") or "").strip()
            psec = p.get("security")
            pthread = p.get("thread_safety")
            ptags = p.get("tags") or []
            pdep = (p.get("deprecation_message") or "").strip()
            pdefault = p.get("default")
            pcaps = p.get("capabilities") or []

            lines.append(f"### `{pname}`")
            lines.append("")
            lines.append(f"- **Type:** `{ptype}`")
            if pdefault not in (None, ""):
                lines.append(f"- **Default:** `{pdefault}`")
            if psec:
                lines.append(f"- **Security:** `{format_security(psec)}`")
            if pthread:
                lines.append(f"- **Thread safety:** `{pthread}`")
            if ptags:
                lines.append(f"- **Tags:** {', '.join(f'`{t}`' for t in ptags)}")
            if pcaps:
                lines.append(f"- **Capabilities:** {', '.join(f'`{c}`' for c in pcaps)}")
            if pdep:
                lines.append(f"- **Deprecated:** {pdep}")
            lines.append("")
            if psum:
                lines.append(psum)
                lines.append("")
            if pdesc and pdesc != psum:
                lines.append(pdesc)
                lines.append("")

    # Methods
    methods = data.get("methods") or []
    lines.append("## Methods")
    lines.append("")
    if not methods:
        lines.append("_No public methods documented._")
        lines.append("")
    else:
        for m in methods:
            mname = m.get("name", "")
            mparams = m.get("parameters") or []
            mreturns = m.get("returns") or []
            msum = (m.get("summary") or "").strip()
            mdesc = (m.get("description") or "").strip()
            msec = m.get("security")
            mthread = m.get("thread_safety")
            mtags = m.get("tags") or []
            mdep = (m.get("deprecation_message") or "").strip()
            mcaps = m.get("capabilities") or []

            sig_params = []
            for pp in mparams:
                pn = pp.get("name", "")
                pt = pp.get("type", "")
                pd = pp.get("default")
                if pd not in (None, ""):
                    sig_params.append(f"{pn}: {pt} = {pd}")
                else:
                    sig_params.append(f"{pn}: {pt}")
            ret_types = ", ".join(r.get("type", "") for r in mreturns) if mreturns else "void"
            short_name = mname.split(":")[-1] if ":" in mname else mname

            lines.append(f"### `{mname}`")
            lines.append("")
            lines.append("```")
            lines.append(f"{short_name}({', '.join(sig_params)}) -> {ret_types}")
            lines.append("```")
            lines.append("")
            if msec or mthread or mtags or mcaps or mdep:
                meta_bits = []
                if msec:
                    meta_bits.append(f"security=`{format_security(msec)}`")
                if mthread:
                    meta_bits.append(f"thread-safety=`{mthread}`")
                if mtags:
                    meta_bits.append("tags=" + ", ".join(f"`{t}`" for t in mtags))
                if mcaps:
                    meta_bits.append("capabilities=" + ", ".join(f"`{c}`" for c in mcaps))
                if mdep:
                    meta_bits.append(f"**Deprecated:** {mdep}")
                lines.append("- " + " ; ".join(meta_bits))
                lines.append("")
            if msum:
                lines.append(msum)
                lines.append("")
            if mdesc and mdesc != msum:
                lines.append(mdesc)
                lines.append("")
            if mparams:
                lines.append("**Parameters:**")
                lines.append("")
                for pp in mparams:
                    pn = pp.get("name", "")
                    pt = pp.get("type", "")
                    ps = (pp.get("summary") or "").strip().replace("\n", " ")
                    pd = pp.get("default")
                    default_txt = f" (default `{pd}`)" if pd not in (None, "") else ""
                    lines.append(f"- `{pn}` : `{pt}`{default_txt} — {ps}")
                lines.append("")
            if mreturns:
                lines.append("**Returns:**")
                lines.append("")
                for r in mreturns:
                    rt = r.get("type", "")
                    rs = (r.get("summary") or "").strip().replace("\n", " ")
                    lines.append(f"- `{rt}` — {rs}")
                lines.append("")

    # Events
    events = data.get("events") or []
    lines.append("## Events")
    lines.append("")
    if not events:
        lines.append("_No public events documented._")
        lines.append("")
    else:
        for e in events:
            en = e.get("name", "")
            ep = e.get("parameters") or []
            esum = (e.get("summary") or "").strip()
            edesc = (e.get("description") or "").strip()
            esec = e.get("security")
            ethread = e.get("thread_safety")
            etags = e.get("tags") or []
            edep = (e.get("deprecation_message") or "").strip()
            ecaps = e.get("capabilities") or []

            sig_params = []
            for pp in ep:
                pn = pp.get("name", "")
                pt = pp.get("type", "")
                sig_params.append(f"{pn}: {pt}")
            short_name = en.split(".")[-1] if "." in en else en

            lines.append(f"### `{en}`")
            lines.append("")
            lines.append("```")
            lines.append(f"{short_name}({', '.join(sig_params)})")
            lines.append("```")
            lines.append("")
            meta_bits = []
            if esec:
                meta_bits.append(f"security=`{format_security(esec)}`")
            if ethread:
                meta_bits.append(f"thread-safety=`{ethread}`")
            if etags:
                meta_bits.append("tags=" + ", ".join(f"`{t}`" for t in etags))
            if ecaps:
                meta_bits.append("capabilities=" + ", ".join(f"`{c}`" for c in ecaps))
            if edep:
                meta_bits.append(f"**Deprecated:** {edep}")
            if meta_bits:
                lines.append("- " + " ; ".join(meta_bits))
                lines.append("")
            if esum:
                lines.append(esum)
                lines.append("")
            if edesc and edesc != esum:
                lines.append(edesc)
                lines.append("")
            if ep:
                lines.append("**Parameters:**")
                lines.append("")
                for pp in ep:
                    pn = pp.get("name", "")
                    pt = pp.get("type", "")
                    ps = (pp.get("summary") or "").strip().replace("\n", " ")
                    lines.append(f"- `{pn}` : `{pt}` — {ps}")
                lines.append("")

    # Notes / deprecations (derived from collected markers)
    notes_lines = []
    # Deprecation class-level
    if deprecation_message:
        notes_lines.append(f"- Class deprecation: {deprecation_message}")
    # Deprecated members
    for label, items in (("Property", props), ("Method", methods), ("Event", events)):
        for it in items:
            dep = (it.get("deprecation_message") or "").strip()
            if dep:
                notes_lines.append(f"- Deprecated {label.lower()} `{it.get('name')}`: {dep}")
    # Security non-None markers
    for label, items in (("method", methods), ("property", props), ("event", events)):
        for it in items:
            sec = it.get("security")
            if sec and format_security(sec) not in ("None", "", None):
                notes_lines.append(f"- {label.capitalize()} `{it.get('name')}` security: `{format_security(sec)}`")
    # Yield markers
    for it in methods:
        for t in (it.get("tags") or []):
            if "Yields" in t:
                notes_lines.append(f"- Method `{it.get('name')}` yields (tag `{t}`).")

    lines.append("## Notes / Deprecations")
    lines.append("")
    if notes_lines:
        lines.extend(notes_lines)
        lines.append("")
    else:
        lines.append("_None flagged in source YAML._")
        lines.append("")

    # Code samples (referenced by name; full snippet lives elsewhere in the repo)
    samples = data.get("code_samples") or []
    # Also collect per-method samples
    extra_samples = []
    for it in methods + props + events:
        for s in it.get("code_samples") or []:
            extra_samples.append(f"{it.get('name')}: {s}")

    lines.append("## Examples")
    lines.append("")
    if samples or extra_samples:
        lines.append("Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):")
        lines.append("")
        for s in samples:
            lines.append(f"- `{s}` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/{cls_name}")
        for s in extra_samples:
            lines.append(f"- {s}")
        lines.append("")
        lines.append("Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.")
        lines.append("")
    else:
        lines.append("_No code samples referenced in source YAML._")
        lines.append("")

    # Source
    lines.append("## Source")
    lines.append("")
    lines.append(f"- Official docs page: https://create.roblox.com/docs/reference/engine/classes/{cls_name}")
    lines.append(
        f"- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/{cls_name}.yaml"
    )
    lines.append("- Captured: 2026-04-16")
    lines.append("")

    return "\n".join(lines)


def format_security(sec):
    if isinstance(sec, dict):
        parts = [f"{k}={v}" for k, v in sec.items()]
        return ", ".join(parts)
    return str(sec)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    yaml_files = sorted(SRC.glob("*.yaml"))
    if not yaml_files:
        print("no yaml files found in", SRC)
        sys.exit(1)

    produced = []
    for yf in yaml_files:
        try:
            with open(yf, "r", encoding="utf-8") as fh:
                data = yaml.safe_load(fh)
        except Exception as exc:
            print(f"FAIL parse {yf.name}: {exc}")
            continue
        if not isinstance(data, dict):
            print(f"SKIP {yf.name}: root is not a mapping")
            continue
        cls_name = data.get("name") or yf.stem
        md = render_md(cls_name, data)
        out_path = OUT / f"{cls_name}.md"
        out_path.write_text(md, encoding="utf-8")
        produced.append(cls_name)
        print(f"wrote {out_path.name}")

    print(f"\n{len(produced)} files written")


if __name__ == "__main__":
    main()
