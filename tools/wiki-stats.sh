#!/usr/bin/env bash
# wiki-stats.sh — Print wiki statistics: page counts, status breakdown, orphan candidates.

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$REPO_ROOT/wiki"

if [ ! -d "$WIKI" ]; then
    echo "No wiki directory at $WIKI"
    exit 1
fi

echo "============================================"
echo "Wiki Statistics — $(date +%Y-%m-%d)"
echo "============================================"

# Page counts by category
echo ""
echo "## Pages by category"
echo ""
for dir in services concepts luau anti-patterns exploits performance monetization studio patterns; do
    if [ -d "$WIKI/$dir" ]; then
        count=$(find "$WIKI/$dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        printf "  %-16s %s\n" "$dir" "$count"
    fi
done

# Status breakdown
echo ""
echo "## Status breakdown"
echo ""
for status in stub draft complete needs-review superseded; do
    count=$(grep -rlE "^status:[[:space:]]*${status}" "$WIKI" --include="*.md" 2>/dev/null | grep -v "/raw/" | wc -l | tr -d ' ')
    printf "  %-14s %s\n" "$status" "$count"
done

# Raw source counts
echo ""
echo "## Raw sources"
echo ""
for dir in roblox-creator-docs luau-spec community/devforum community/reddit community/articles community/performance community/monetization; do
    if [ -d "$WIKI/raw/$dir" ]; then
        count=$(find "$WIKI/raw/$dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        printf "  %-32s %s\n" "$dir" "$count"
    fi
done

total_raw=$(find "$WIKI/raw" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "  Total raw files: $total_raw"

# Total curated pages
total_curated=$(find "$WIKI" -name "*.md" -type f -not -path "$WIKI/raw/*" 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "## Total curated wiki pages: $total_curated"

# Wikilinks
wikilink_count=$(grep -rohE '\[\[[^]]+\]\]' "$WIKI" --include="*.md" 2>/dev/null | grep -v "/raw/" | wc -l | tr -d ' ')
echo ""
echo "## Total wikilinks: $wikilink_count"

# Log entries
if [ -f "$WIKI/log.md" ]; then
    log_count=$(grep -cE "^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\]" "$WIKI/log.md" 2>/dev/null || echo 0)
    echo ""
    echo "## Log entries: $log_count"

    echo ""
    echo "## Recent log entries"
    echo ""
    grep -E "^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\]" "$WIKI/log.md" 2>/dev/null | tail -5 | sed 's/^/  /'
fi

# Orphan candidates (pages with no inbound wikilinks)
echo ""
echo "## Orphan candidates (no inbound wikilinks)"
echo ""

while IFS= read -r page; do
    [ -z "$page" ] && continue
    basename=$(basename "$page" .md)
    # Skip meta pages
    case "$basename" in
        README|SCHEMA|log|index) continue ;;
    esac
    # Check if any other page wikilinks to it
    if ! grep -rq "\[\[${basename}" "$WIKI" --include="*.md" --exclude-dir=raw 2>/dev/null; then
        # Double check it's not linked by title (title may differ from filename)
        title=$(head -20 "$page" 2>/dev/null | grep -E "^title:" | head -1 | sed -E 's/^title:[[:space:]]*//' | tr -d '"' | sed 's/[[:space:]]*$//')
        if [ -n "$title" ]; then
            if ! grep -rq "\[\[${title}" "$WIKI" --include="*.md" --exclude-dir=raw 2>/dev/null; then
                echo "  $page"
            fi
        else
            echo "  $page"
        fi
    fi
done < <(find "$WIKI" -name "*.md" -type f -not -path "$WIKI/raw/*" 2>/dev/null)

echo ""
echo "============================================"
echo "Run /wiki-lint for a full health check."
