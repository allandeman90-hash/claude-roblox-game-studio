# Context Management

How to manage Claude Code's context window in FoG Roblox Studio Command.

## Why Context Management Matters

Claude Code has a large context window but it's not infinite. Effective context management lets you:

- Work on large projects without hitting context limits
- Preserve session state across Claude Code sessions
- Keep the most relevant information loaded
- Avoid redundant re-reading of the same files

## Strategies

### 1. Use Subagents for Research

When you need to explore the codebase or research a question, use a subagent rather than reading files yourself. Subagents work in isolation and return a condensed summary, protecting your main context.

Use cases:
- "Find every place combat damage is calculated"
- "What files reference the DataStore?"
- "What's the current structure of the UI code?"

The subagent does the work; your main context sees only the answer.

### 2. Keep Design Docs as Source of Truth

Design docs in `design/gdd/` should be the authoritative source for "what we're building." When asking about a system, read the GDD first — it's a condensed spec that's much smaller than the implementation.

### 3. Session State

`production/session-state/` preserves cross-session context:

- `current-sprint.txt` — which sprint we're in
- `last-session.txt` — where we left off
- `session-log.txt` — append-only log of session events
- `agent-log.txt` — every agent invocation logged
- `pre-compact-snapshot.md` — state saved before context compression

The session-start hook loads this at session open, so you don't have to re-establish context.

### 4. Pre-Compact Hook

When Claude Code's context is about to be compressed, the `pre-compact.sh` hook runs. It saves critical state (git status, review mode, current sprint) to `production/session-state/pre-compact-snapshot.md` so nothing important is lost in compression.

### 5. Skill Invocation for Workflow Continuity

Slash commands encapsulate workflows. Instead of re-explaining "how do we do design reviews" every time, just run `/design-review` — the skill file has the complete instructions.

### 6. Structured Delegation

When delegating to an agent, give them a focused task with explicit scope. Don't dump your entire conversation on them.

Bad:
> "Here's everything we've discussed, now look at the combat code and tell me if it's OK."

Good:
> "Review `src/ServerScriptService/Combat.lua` for these specific issues: rate limiting on the AttackRemote, server-side damage validation, and cleanup of the hit history table. Focus on security implications."

### 7. CLAUDE.md is Always Loaded

`CLAUDE.md` loads every session. Keep it concise. It references other docs via `@filepath` which are loaded on demand.

## Anti-Patterns

- ❌ Re-reading the entire codebase every session (use subagents + design docs)
- ❌ Pasting long code dumps in the chat (reference file paths instead)
- ❌ Keeping stale conversation about resolved issues (use decision log for persistence)
- ❌ Asking the same question multiple times (check decision log)
- ❌ Dumping all of `src/` into context to find one thing (grep or subagent)

## Session Lifecycle

### Session Start
- `session-start.sh` runs: loads last-session.txt, shows git status, displays review mode
- `detect-gaps.sh` runs: suggests `/start` if no GDD, or other gap-filling commands
- `CLAUDE.md` loads automatically
- User sees previous session context, starts fresh work

### During Session
- Agent invocations logged via `log-agent.sh`
- Major decisions logged to `production/decision-log.md`
- Work artifacts saved to appropriate directories (GDDs, sprint plans, reports)

### Context Compression (if triggered)
- `pre-compact.sh` saves snapshot
- Claude Code compresses older messages
- Critical info preserved in session-state

### Session End
- `session-stop.sh` runs: updates session-log, writes last-session.txt
- Next session can pick up where this one left off
