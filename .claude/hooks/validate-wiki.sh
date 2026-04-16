#!/usr/bin/env bash
# validate-wiki.sh — Validates wiki page edits.
# Runs on Write/Edit of files under wiki/ (not wiki/raw/).
# Checks: frontmatter has required fields, H1 matches title, wikilinks parseable.

set -e

file="${CLAUDE_TOOL_INPUT_file_path:-}"

# Only check files under wiki/ but NOT wiki/raw/
case "$file" in
    *"/wiki/raw/"*|*/wiki/raw/*|wiki/raw/*)
        exit 0  # raw sources are immutable from this hook's perspective
        ;;
    *"/wiki/"*|wiki/*)
        ;;  # proceed
    *)
        exit 0  # not a wiki file
        ;;
esac

if [ -z "$file" ] || [ ! -f "$file" ]; then
    exit 0
fi

# Skip non-markdown files
case "$file" in
    *.md) ;;
    *) exit 0 ;;
esac

# Skip wiki root meta files that don't use the page schema
basename=$(basename "$file")
case "$basename" in
    README.md|SCHEMA.md|log.md|index.md)
        # These have their own simpler schemas; only check they have frontmatter
        if ! head -1 "$file" 2>/dev/null | grep -q "^---$"; then
            echo "WARN: $file: missing frontmatter" >&2
        fi
        exit 0
        ;;
esac

warn() {
    echo "WARN: $file: $*" >&2
}

err() {
    echo "ERROR: $file: $*" >&2
    fail=1
}

fail=0

# Extract frontmatter block
if ! head -1 "$file" 2>/dev/null | grep -q "^---$"; then
    err "missing frontmatter block"
    exit 1
fi

# Read frontmatter lines (between first and second ---)
frontmatter=$(awk '/^---$/{f++; next} f==1' "$file" 2>/dev/null || true)

if [ -z "$frontmatter" ]; then
    err "empty frontmatter"
    exit 1
fi

# Required fields
for field in title type category owner status created updated; do
    if ! echo "$frontmatter" | grep -qE "^${field}:[[:space:]]*[^[:space:]]"; then
        err "frontmatter missing required field: $field"
    fi
done

# type must be valid enum
type_val=$(echo "$frontmatter" | grep -E "^type:" | head -1 | sed -E 's/^type:[[:space:]]*//' | tr -d ' ')
case "$type_val" in
    service|concept|luau-feature|anti-pattern|exploit|performance|monetization|studio|pattern|schema|raw-sources-index|raw-source)
        ;;
    "")
        # already warned
        ;;
    *)
        warn "frontmatter 'type: $type_val' is not a recognized page type"
        ;;
esac

# status must be valid enum
status_val=$(echo "$frontmatter" | grep -E "^status:" | head -1 | sed -E 's/^status:[[:space:]]*//' | tr -d ' ')
case "$status_val" in
    stub|draft|complete|needs-review|superseded|"")
        ;;
    *)
        warn "frontmatter 'status: $status_val' is not a recognized status"
        ;;
esac

# dates must be YYYY-MM-DD
for datefield in created updated; do
    dateval=$(echo "$frontmatter" | grep -E "^${datefield}:" | head -1 | sed -E 's/^[a-z]+:[[:space:]]*//' | tr -d ' ')
    if [ -n "$dateval" ] && ! echo "$dateval" | grep -qE "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"; then
        warn "$datefield '$dateval' is not YYYY-MM-DD format"
    fi
done

# Title field must match H1
title_val=$(echo "$frontmatter" | grep -E "^title:" | head -1 | sed -E 's/^title:[[:space:]]*//' | sed 's/^"//;s/"$//')
h1=$(grep -m1 "^# " "$file" 2>/dev/null | sed -E 's/^#[[:space:]]*//' | sed 's/[[:space:]]*$//')
if [ -n "$title_val" ] && [ -n "$h1" ]; then
    # Normalize both (lowercase, strip punctuation) for loose compare
    t_norm=$(echo "$title_val" | tr '[:upper:]' '[:lower:]' | tr -d '.,;:!?')
    h_norm=$(echo "$h1" | tr '[:upper:]' '[:lower:]' | tr -d '.,;:!?')
    if [ "$t_norm" != "$h_norm" ]; then
        warn "H1 '$h1' does not match title '$title_val'"
    fi
fi

# Owner must reference a real agent (or be wiki-curator)
owner_val=$(echo "$frontmatter" | grep -E "^owner:" | head -1 | sed -E 's/^owner:[[:space:]]*//' | tr -d ' ')
if [ -n "$owner_val" ]; then
    if [ ! -f ".claude/agents/${owner_val}.md" ]; then
        warn "owner '$owner_val' does not match any agent in .claude/agents/"
    fi
fi

# Check for obviously broken wikilinks ([[something]] where something looks malformed)
broken_links=$(grep -oE '\[\[[^]]*\]\]' "$file" 2>/dev/null | grep -cE '\[\[[[:space:]]*\]\]|\[\[[^|]*\|[[:space:]]*\]\]' || true)
if [ "${broken_links:-0}" -gt 0 ]; then
    warn "$broken_links malformed wikilink(s) detected (empty or malformed [[...]] )"
fi

# Report
if [ "$fail" -eq 1 ]; then
    exit 1
fi

exit 0
