#!/usr/bin/env bash
# validate-push.sh — Warns on pushes to protected branches (main, production).
# This is a POST hook; it warns but doesn't block (block is enforced via deny rules).

set -e

cmd="${CLAUDE_TOOL_INPUT_command:-}"
case "$cmd" in
    *"git push"*) ;;
    *) exit 0 ;;
esac

# Get current branch
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

case "$branch" in
    main|master|production|prod)
        echo "WARN: push to protected branch '$branch' detected." >&2
        echo "      Ensure this is intentional and reviewed." >&2
        ;;
esac

# Check for force push
case "$cmd" in
    *"--force"*|*" -f "*|*" -f")
        case "$branch" in
            main|master|production|prod)
                echo "CRITICAL: force push to protected branch '$branch'!" >&2
                echo "          If this was not intentional, coordinate with the team immediately." >&2
                ;;
        esac
        ;;
esac

exit 0
