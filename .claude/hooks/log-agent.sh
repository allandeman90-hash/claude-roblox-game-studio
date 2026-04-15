#!/usr/bin/env bash
# log-agent.sh — Runs when an agent is spawned. Logs to agent-log for auditing.

set -e

STATE_DIR="production/session-state"
mkdir -p "$STATE_DIR" 2>/dev/null || true

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u)
agent_name="${CLAUDE_AGENT_NAME:-unknown}"
agent_desc="${CLAUDE_AGENT_DESCRIPTION:-}"

{
    echo "[$timestamp] agent=$agent_name desc=\"$agent_desc\""
} >> "$STATE_DIR/agent-log.txt" 2>/dev/null || true

exit 0
