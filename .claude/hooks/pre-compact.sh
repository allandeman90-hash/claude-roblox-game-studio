#!/usr/bin/env bash
# pre-compact.sh — Runs before context compression. Preserves critical state.

set -e

STATE_DIR="production/session-state"
mkdir -p "$STATE_DIR" 2>/dev/null || true

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u)

# Save a snapshot of current state for post-compact recovery
{
    echo "# Pre-Compact Snapshot"
    echo "Timestamp: $timestamp"
    echo ""
    echo "## Git State"
    if command -v git >/dev/null 2>&1 && [ -d ".git" ]; then
        echo "Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
        echo "HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo none)"
        echo ""
        echo "Staged changes:"
        git diff --cached --stat 2>/dev/null | sed 's/^/  /'
        echo ""
        echo "Unstaged changes:"
        git diff --stat 2>/dev/null | sed 's/^/  /'
    fi
    echo ""
    echo "## Review Mode"
    if [ -f "production/review-mode.txt" ]; then
        cat production/review-mode.txt
    fi
    echo ""
    echo "## Current Sprint"
    if [ -f "$STATE_DIR/current-sprint.txt" ]; then
        cat "$STATE_DIR/current-sprint.txt"
    fi
} > "$STATE_DIR/pre-compact-snapshot.md" 2>/dev/null || true

echo "pre-compact: snapshot saved to $STATE_DIR/pre-compact-snapshot.md"
exit 0
