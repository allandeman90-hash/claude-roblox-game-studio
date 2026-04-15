#!/usr/bin/env bash
# session-stop.sh — Runs at session stop. Saves session state and logs accomplishments.

set -e

STATE_DIR="production/session-state"
mkdir -p "$STATE_DIR" 2>/dev/null || true

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u)

# Append to session log
{
    echo "=== Session ended at $timestamp ==="
    if command -v git >/dev/null 2>&1 && [ -d ".git" ]; then
        echo "Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
        commits_this_session=$(git log --since="6 hours ago" --oneline 2>/dev/null | wc -l | tr -d ' ')
        if [ "$commits_this_session" -gt 0 ]; then
            echo "Commits this session: $commits_this_session"
            git log --since="6 hours ago" --oneline 2>/dev/null | head -10
        fi
    fi
    echo ""
} >> "$STATE_DIR/session-log.txt" 2>/dev/null || true

# Save a brief summary as last-session.txt
{
    echo "Ended: $timestamp"
    if command -v git >/dev/null 2>&1 && [ -d ".git" ]; then
        echo "Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
        echo "HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo none)"
    fi
} > "$STATE_DIR/last-session.txt" 2>/dev/null || true

echo "session-stop: state saved to $STATE_DIR/"
exit 0
