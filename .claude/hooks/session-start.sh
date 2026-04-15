#!/usr/bin/env bash
# session-start.sh — Runs at session start. Loads context, shows git status, displays review mode.

set -e

STATE_DIR="production/session-state"
mkdir -p "$STATE_DIR" 2>/dev/null || true

echo "=========================================="
echo "FoG Roblox Studio Command — Session Start"
echo "=========================================="

# Review mode
if [ -f "production/review-mode.txt" ]; then
    mode=$(cat production/review-mode.txt 2>/dev/null || echo "full")
    echo "Review mode: $mode"
else
    echo "Review mode: not set (run /start to configure)"
fi

# Current sprint
if [ -f "$STATE_DIR/current-sprint.txt" ]; then
    sprint=$(cat "$STATE_DIR/current-sprint.txt" 2>/dev/null || echo "none")
    echo "Current sprint: $sprint"
fi

# Git status
if command -v git >/dev/null 2>&1 && [ -d ".git" ]; then
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    echo "Branch: $branch"

    uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$uncommitted" -gt 0 ]; then
        echo "Uncommitted changes: $uncommitted file(s)"
    fi

    last_commit=$(git log -1 --format='%h %s' 2>/dev/null || echo "no commits")
    echo "Last commit: $last_commit"

    recent_commits=$(git log --oneline -5 2>/dev/null || true)
    if [ -n "$recent_commits" ]; then
        echo ""
        echo "Recent activity:"
        echo "$recent_commits" | sed 's/^/  /'
    fi
fi

# Last session notes
if [ -f "$STATE_DIR/last-session.txt" ]; then
    echo ""
    echo "Last session notes:"
    cat "$STATE_DIR/last-session.txt" | sed 's/^/  /'
fi

echo "=========================================="

exit 0
