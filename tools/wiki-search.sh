#!/usr/bin/env bash
# wiki-search.sh — Simple grep-based search over the wiki.
# Usage:
#   wiki-search.sh <query>
#   wiki-search.sh -l <query>       # list matching files only
#   wiki-search.sh -t <type> <query># filter by page type (service, concept, etc.)
#   wiki-search.sh --raw <query>    # also search raw sources

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$REPO_ROOT/wiki"

usage() {
    cat <<'EOF'
Usage:
  wiki-search.sh <query>           Search wiki page content
  wiki-search.sh -l <query>        List matching files (no context)
  wiki-search.sh -t <type> <query> Filter by type (service|concept|luau-feature|anti-pattern|exploit|performance|monetization|studio|pattern)
  wiki-search.sh --raw <query>     Include raw sources in search
  wiki-search.sh --help            Show this help
EOF
}

if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
    exit 0
fi

SEARCH_PATH="$WIKI"
FILES_ONLY=""
TYPE_FILTER=""
QUERY=""

while [ $# -gt 0 ]; do
    case "$1" in
        -l)
            FILES_ONLY="-l"
            shift
            ;;
        -t)
            TYPE_FILTER="$2"
            shift 2
            ;;
        --raw)
            SEARCH_PATH="$WIKI"  # include raw
            INCLUDE_RAW=1
            shift
            ;;
        *)
            QUERY="$1"
            shift
            ;;
    esac
done

if [ -z "$QUERY" ]; then
    usage
    exit 1
fi

# Exclude raw by default
if [ -z "${INCLUDE_RAW:-}" ]; then
    EXCLUDE="--exclude-dir=raw"
else
    EXCLUDE=""
fi

# Run grep
if [ -n "$TYPE_FILTER" ]; then
    # First filter files by frontmatter type, then grep in them
    matching_files=$(grep -rlE "^type:[[:space:]]*${TYPE_FILTER}" "$SEARCH_PATH" $EXCLUDE --include="*.md" 2>/dev/null || true)
    if [ -z "$matching_files" ]; then
        echo "No pages with type: $TYPE_FILTER"
        exit 0
    fi
    if [ -n "$FILES_ONLY" ]; then
        echo "$matching_files" | xargs grep -l "$QUERY" 2>/dev/null || true
    else
        echo "$matching_files" | xargs grep -n --color=auto "$QUERY" 2>/dev/null || true
    fi
else
    grep -rn $FILES_ONLY $EXCLUDE --include="*.md" --color=auto "$QUERY" "$SEARCH_PATH" 2>/dev/null || true
fi
