#!/usr/bin/env bash
# detect-gaps.sh — Runs at session start. Detects common gaps and suggests starting commands.

set -e

suggestions=()

# Check for master GDD
if [ ! -f "design/gdd/master-gdd.md" ]; then
    has_code=false
    if [ -d "src" ] && [ -n "$(find src -name '*.lua' -o -name '*.luau' 2>/dev/null | head -1)" ]; then
        has_code=true
    fi

    if [ "$has_code" = "true" ]; then
        suggestions+=("Code exists but no master GDD. Consider running /reverse-document.")
    else
        suggestions+=("No master GDD and no code. Run /start to begin a new project.")
    fi
fi

# Check for systems-index
if [ ! -f "design/gdd/systems-index.md" ]; then
    if [ -d "design/gdd" ] && [ -n "$(find design/gdd -name '*.md' 2>/dev/null | head -1)" ]; then
        suggestions+=("GDDs exist but no systems-index. Run /map-systems.")
    fi
fi

# Check for review mode
if [ ! -f "production/review-mode.txt" ]; then
    suggestions+=("Review mode not set. Run /start to configure.")
fi

# Check for missing production sprint folder if we're past the "just started" phase
if [ -d "design/gdd" ] && [ -f "design/gdd/master-gdd.md" ]; then
    if [ ! -d "production/sprints" ] || [ -z "$(ls -A production/sprints 2>/dev/null)" ]; then
        suggestions+=("Master GDD exists but no sprints. Run /sprint-plan to plan work.")
    fi
fi

# Print suggestions
if [ ${#suggestions[@]} -gt 0 ]; then
    echo "Gaps detected:"
    for s in "${suggestions[@]}"; do
        echo "  • $s"
    done
    echo ""
fi

exit 0
