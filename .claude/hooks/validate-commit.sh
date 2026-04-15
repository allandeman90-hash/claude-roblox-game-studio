#!/usr/bin/env bash
# validate-commit.sh — Runs before git commit to validate the staged change.
# Exits 0 on pass, 1 on fail. Prints findings to stderr.

set -e

# Only run for git commit bash commands
if [ -z "${CLAUDE_TOOL_INPUT_command:-}" ]; then
    exit 0
fi

cmd="${CLAUDE_TOOL_INPUT_command:-}"
case "$cmd" in
    *"git commit"*) ;;
    *) exit 0 ;;
esac

violations=0
warn() {
    echo "WARN: $*" >&2
    violations=$((violations + 1))
}

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

# Only check staged files under src/
staged=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep -E '^src/.*\.(lua|luau)$' || true)

if [ -z "$staged" ]; then
    exit 0
fi

echo "validate-commit: checking $(echo "$staged" | wc -l) staged Luau file(s)"

for file in $staged; do
    if [ ! -f "$file" ]; then
        continue
    fi

    # Check for print() statements (not commented)
    if grep -nE '^[^-]*[^[:alnum:]_]print\(' "$file" 2>/dev/null | grep -v "^[[:space:]]*--" > /dev/null; then
        warn "$file: contains print() statements. Use logger instead."
    fi

    # Check for deprecated wait()
    if grep -nE '[^.]wait\(' "$file" 2>/dev/null | grep -v "task\.wait\|:Wait" | grep -v "^[[:space:]]*--" > /dev/null; then
        warn "$file: uses deprecated wait(). Use task.wait() instead."
    fi

    # Check for deprecated spawn()
    if grep -nE '[^.]spawn\(' "$file" 2>/dev/null | grep -v "task\.spawn" | grep -v "^[[:space:]]*--" > /dev/null; then
        warn "$file: uses deprecated spawn(). Use task.spawn() instead."
    fi

    # Check for deprecated delay()
    if grep -nE '[^.]delay\(' "$file" 2>/dev/null | grep -v "task\.delay" | grep -v "^[[:space:]]*--" > /dev/null; then
        warn "$file: uses deprecated delay(). Use task.delay() instead."
    fi

    # Check for TODO without issue reference
    if grep -nE 'TODO[^(]' "$file" 2>/dev/null | grep -v "TODO(#" > /dev/null; then
        warn "$file: TODO without issue reference. Use format: -- TODO(#123): description"
    fi
done

# Check JSON files in assets/data/ for validity (if jq exists)
if command -v jq >/dev/null 2>&1; then
    staged_json=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep -E '^assets/data/.*\.json$' || true)
    for f in $staged_json; do
        if [ -f "$f" ]; then
            if ! jq empty "$f" >/dev/null 2>&1; then
                fail "$f: invalid JSON"
            fi
        fi
    done
fi

# Check design docs for required sections (if they're GDD files)
staged_gdds=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep -E '^design/gdd/.*-gdd\.md$' || true)
for f in $staged_gdds; do
    if [ -f "$f" ]; then
        missing=""
        for section in "Overview" "Core Mechanics" "Data Schema" "Client-Server Split" "Edge Cases" "Balancing Parameters" "Integration Points"; do
            if ! grep -q "$section" "$f" 2>/dev/null; then
                missing="$missing $section"
            fi
        done
        if [ -n "$missing" ]; then
            warn "$f: GDD missing sections:$missing"
        fi
    fi
done

if [ $violations -gt 0 ]; then
    echo "validate-commit: $violations warning(s). Review before committing." >&2
fi

exit 0
