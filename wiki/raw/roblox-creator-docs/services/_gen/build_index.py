"""Build INDEX.md from the captured YAMLs."""
from __future__ import annotations

import yaml
from pathlib import Path

SRC = Path("C:/Users/talme/.tmp/roblox-yaml")
OUT = Path("C:/Users/talme/claude-code-rbx-studios/FoG-Roblox-Studio-Command/wiki/raw/roblox-creator-docs/services/INDEX.md")

# Category map mirrors build_md.py
CATEGORIES = {
    "DataStoreService": "persistence",
    "GlobalDataStore": "persistence",
    "OrderedDataStore": "persistence",
    "DataStoreKeyInfo": "persistence",
    "MemoryStoreService": "memory-store",
    "MemoryStoreSortedMap": "memory-store",
    "MemoryStoreHashMap": "memory-store",
    "MemoryStoreQueue": "memory-store",
    "RemoteEvent": "networking",
    "RemoteFunction": "networking",
    "UnreliableRemoteEvent": "networking",
    "BindableEvent": "events",
    "BindableFunction": "events",
    "MarketplaceService": "economy",
    "Players": "players",
    "Player": "players",
    "PlayerGui": "gui",
    "StarterGui": "gui",
    "StarterPlayer": "players",
    "StarterPlayerScripts": "players",
    "StarterCharacterScripts": "players",
    "ReplicatedStorage": "containers",
    "ServerStorage": "containers",
    "ServerScriptService": "containers",
    "ReplicatedFirst": "containers",
    "Workspace": "world",
    "RunService": "runtime",
    "Lighting": "environment",
    "SoundService": "audio",
    "Sound": "audio",
    "SoundGroup": "audio",
    "TweenService": "animation",
    "Tween": "animation",
    "TeleportService": "networking",
    "HttpService": "networking",
    "TextChatService": "chat",
    "MessagingService": "networking",
    "CollectionService": "world",
    "ContextActionService": "input",
    "UserInputService": "input",
    "GuiService": "gui",
    "ProximityPrompt": "interaction",
    "ClickDetector": "interaction",
}

TIER1 = [
    "DataStoreService", "GlobalDataStore", "OrderedDataStore", "DataStoreKeyInfo",
    "MemoryStoreService", "MemoryStoreSortedMap", "MemoryStoreHashMap", "MemoryStoreQueue",
    "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent",
    "BindableEvent", "BindableFunction",
    "MarketplaceService",
    "Players", "Player", "PlayerGui", "StarterGui",
    "StarterPlayer", "StarterPlayerScripts", "StarterCharacterScripts",
    "ReplicatedStorage", "ServerStorage", "ServerScriptService", "ReplicatedFirst",
    "Workspace", "RunService", "Lighting",
    "SoundService", "Sound", "SoundGroup",
    "TweenService", "Tween",
    "TeleportService", "HttpService", "TextChatService", "MessagingService",
    "CollectionService", "ContextActionService", "UserInputService", "GuiService",
    "ProximityPrompt", "ClickDetector",
]


def first_line(text: str) -> str:
    t = (text or "").strip().replace("\n", " ")
    # collapse whitespace
    while "  " in t:
        t = t.replace("  ", " ")
    # trim to ~160 chars for table row
    if len(t) > 200:
        t = t[:197] + "..."
    return t


def main():
    rows = []
    failed = []
    for cls in TIER1:
        yf = SRC / f"{cls}.yaml"
        if not yf.exists():
            failed.append((cls, "YAML not found"))
            continue
        try:
            data = yaml.safe_load(yf.read_text(encoding="utf-8"))
        except Exception as exc:
            failed.append((cls, f"parse error: {exc}"))
            continue
        summary = first_line(data.get("summary") or data.get("description") or "")
        category = CATEGORIES.get(cls, "class")
        url = f"https://create.roblox.com/docs/reference/engine/classes/{cls}"
        rows.append((cls, category, url, summary))

    lines = []
    lines.append("---")
    lines.append("title: Service Reference Index")
    lines.append("type: raw-source-index")
    lines.append("captured_by: research-agent-1")
    lines.append("captured_at: 2026-04-16")
    lines.append("source_type: official-roblox-docs")
    lines.append("source_repo: https://github.com/Roblox/creator-docs")
    lines.append("---")
    lines.append("")
    lines.append("# Roblox Service Reference Index")
    lines.append("")
    lines.append(
        "Raw capture of the official Roblox Creator Documentation class reference "
        "pages for Tier 1 services. Each row links to the rendered doc; underlying "
        "text was pulled from the official `Roblox/creator-docs` GitHub repository "
        "(authoritative YAML source) on 2026-04-16."
    )
    lines.append("")
    lines.append("## Tier 1 (captured)")
    lines.append("")
    lines.append("| Class | Category | Source URL | Captured | Summary |")
    lines.append("|-------|----------|------------|----------|---------|")
    for cls, cat, url, sm in rows:
        sm_escaped = sm.replace("|", "\\|")
        lines.append(f"| [{cls}]({cls}.md) | {cat} | [{cls} docs]({url}) | 2026-04-16 | {sm_escaped} |")
    lines.append("")

    if failed:
        lines.append("## Failed / skipped")
        lines.append("")
        lines.append("| Class | Reason |")
        lines.append("|-------|--------|")
        for cls, reason in failed:
            lines.append(f"| {cls} | {reason} |")
        lines.append("")

    lines.append("## Capture methodology")
    lines.append("")
    lines.append(
        "- The public pages at `create.roblox.com/docs/reference/engine/classes/<Class>` "
        "are JavaScript-rendered and return empty bodies to standard `WebFetch`. "
        "To preserve fidelity, raw YAML sources were pulled from "
        "`https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/<Class>.yaml` — "
        "this is the exact same content the live docs site generates from."
    )
    lines.append(
        "- Each `.md` file in this directory is a direct, lossless rendering of the "
        "YAML frontmatter into Markdown with preserved `Class.*`/`Datatype.*`/`Global.*` "
        "cross-reference markers from the source. No editorializing or paraphrasing."
    )
    lines.append(
        "- Code samples in the source YAML are referenced by ID (e.g. `DataStore-Budget`); "
        "the verbatim Luau snippets live in sibling `.md` files in the Roblox repo and can "
        "be fetched on-demand by a follow-up pass if needed."
    )
    lines.append("")
    lines.append("## Related pages not captured in this pass")
    lines.append("")
    lines.append(
        "The Tier 1 YAMLs cross-reference many supporting classes and guide pages that "
        "were out of scope for this agent. Follow-up agents may want to capture:"
    )
    lines.append("")
    lines.append("- `DataStore`, `DataStoreOptions`, `DataStoreInfo`, `DataStoreVersionPages`, `DataStoreKeyPages` — raw DataStore surface types")
    lines.append("- `MemoryStoreSortedMap`, `MemoryStoreHashMap`, and `MemoryStoreQueue` item/key helper types")
    lines.append("- `ProcessReceipt` / developer product receipt callback contract (lives in `MarketplaceService`)")
    lines.append("- `TextChannel`, `TextSource`, `ChatWindowConfiguration`, `TextChatCommand`, `BubbleChatConfiguration` — TextChatService ecosystem")
    lines.append("- `InputObject`, `TouchObject`, `GamepadState` — UserInputService / ContextActionService companion types")
    lines.append("- `TweenInfo` (Datatype), `Enum.EasingStyle`, `Enum.EasingDirection`, `Enum.PlaybackState` — TweenService companions")
    lines.append("- `TeleportOptions`, `TeleportAsyncResult`, `TeleportData` — TeleportService payload types")
    lines.append("- `Lighting` child atmospheric effects: `Atmosphere`, `Sky`, `Clouds`, `BloomEffect`, `ColorCorrectionEffect`, `DepthOfFieldEffect`, `SunRaysEffect`, `BlurEffect`")
    lines.append("- Sound descendants: `EqualizerSoundEffect`, `ReverbSoundEffect`, `CompressorSoundEffect`, `DistortionSoundEffect`, `EchoSoundEffect`, `ChorusSoundEffect`, `FlangeSoundEffect`, `PitchShiftSoundEffect`, `TremoloSoundEffect`")
    lines.append("- Data store / memory store / HTTP / teleport guide pages referenced inline (links to `../../../cloud-services/*.md`)")
    lines.append("")
    lines.append("These URLs should be fed to agent-5 (or a follow-up raw-source pass) if a deeper capture is needed.")
    lines.append("")

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
