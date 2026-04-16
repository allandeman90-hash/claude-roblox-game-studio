#!/usr/bin/env bash
# wiki-bootstrap.sh — Bulk-clone canonical raw sources into wiki/raw/.
# Idempotent: re-running updates existing clones.

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RAW_DIR="$REPO_ROOT/wiki/raw"

echo "wiki-bootstrap: populating $RAW_DIR"
mkdir -p "$RAW_DIR"

clone_or_pull() {
    local url="$1"
    local dest="$2"
    local shallow="${3:-yes}"

    if [ -d "$dest/.git" ]; then
        echo "  updating: $dest"
        (cd "$dest" && git pull --ff-only 2>&1 | sed 's/^/    /') || true
    else
        echo "  cloning: $url -> $dest"
        if [ "$shallow" = "yes" ]; then
            git clone --depth 1 "$url" "$dest" 2>&1 | sed 's/^/    /' || {
                echo "    FAILED: $url"
                return 1
            }
        else
            git clone "$url" "$dest" 2>&1 | sed 's/^/    /' || {
                echo "    FAILED: $url"
                return 1
            }
        fi
    fi
}

echo ""
echo "Roblox Creator Docs (official)"
clone_or_pull "https://github.com/Roblox/creator-docs.git" \
    "$RAW_DIR/roblox-creator-docs/_repo"

echo ""
echo "Luau language spec"
clone_or_pull "https://github.com/luau-lang/luau.git" \
    "$RAW_DIR/luau-spec/_repo"

echo ""
echo "Roblox open source libraries"
mkdir -p "$RAW_DIR/community/library-repos"
for repo in \
    "Roblox/roact" \
    "Roblox/rodux" \
    "Roblox/testez" \
    "Sleitnick/Knit" \
    "Sleitnick/Trove" \
    "Sleitnick/RbxUtil" \
    "matter-ecs/matter" \
    "jsdotlua/jest-lua" \
    "stravant/GoodSignal" \
    "evaera/roblox-lua-promise" \
    "loleris/ProfileService" \
    "Kampfkarren/Selene" \
    "Kampfkarren/DataStore2" \
    "JohnnyMorganz/StyLua" \
    "UpliftGames/wally" \
    "rojo-rbx/rojo" \
    "LPGhatguy/aftman" \
    "Elttob/Fusion" \
    "dphfox/Fusion" \
    "rbxts-flamework/core" \
    ; do
    name=$(echo "$repo" | tr '/' '-')
    clone_or_pull "https://github.com/$repo.git" \
        "$RAW_DIR/community/library-repos/$name"
done

echo ""
echo "wiki-bootstrap: done"
echo ""
echo "Next steps:"
echo "  1. Review new content in $RAW_DIR"
echo "  2. Run /wiki-ingest to integrate into the curated wiki"
echo "  3. Run /wiki-lint to check health"
