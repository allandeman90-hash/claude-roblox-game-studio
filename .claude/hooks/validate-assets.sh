#!/usr/bin/env bash
# validate-assets.sh — Runs on file writes/edits to assets/. Validates naming, JSON, and file sizes.

set -e

# Figure out which file is being written
file="${CLAUDE_TOOL_INPUT_file_path:-}"

# Only check files in assets/
case "$file" in
    *"/assets/"*) ;;
    assets/*) ;;
    *) exit 0 ;;
esac

if [ -z "$file" ]; then
    exit 0
fi

violations=0
warn() {
    echo "WARN: $*" >&2
    violations=$((violations + 1))
}

# Naming convention: lowercase-kebab-case
basename=$(basename "$file")
name_only="${basename%.*}"

# Allow ONLY lowercase letters, digits, and hyphens in name portion
if ! echo "$name_only" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
    warn "$file: violates naming convention. Use lowercase-kebab-case.ext"
fi

# If it's a JSON file in assets/data/, validate syntax
case "$file" in
    *"/assets/data/"*.json|assets/data/*.json)
        if command -v jq >/dev/null 2>&1 && [ -f "$file" ]; then
            if ! jq empty "$file" >/dev/null 2>&1; then
                echo "ERROR: $file is not valid JSON" >&2
                exit 1
            fi
        fi
        ;;
esac

# File size warning for images
case "$file" in
    *"/assets/images/"*|assets/images/*)
        if [ -f "$file" ]; then
            size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
            if [ "$size" -gt 5242880 ]; then  # 5MB
                warn "$file: exceeds 5MB ($size bytes). Consider optimizing."
            elif [ "$size" -gt 1048576 ]; then  # 1MB
                warn "$file: over 1MB ($size bytes). Verify it's needed at this size."
            fi
        fi
        ;;
esac

# Audio size warning
case "$file" in
    *"/assets/audio/"*|assets/audio/*)
        if [ -f "$file" ]; then
            size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
            if [ "$size" -gt 10485760 ]; then  # 10MB
                warn "$file: exceeds 10MB. Music files OK; short SFX should be < 1MB."
            fi
        fi
        ;;
esac

# Model size warning
case "$file" in
    *"/assets/models/"*|assets/models/*)
        if [ -f "$file" ]; then
            size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
            if [ "$size" -gt 20971520 ]; then  # 20MB
                warn "$file: exceeds 20MB. Consider triangle reduction."
            fi
        fi
        ;;
esac

if [ $violations -gt 0 ]; then
    echo "validate-assets: $violations warning(s) for $file" >&2
fi

exit 0
