# Hooks Reference

Documentation for each hook: what it does, when it fires, what it checks.

## Registration

All hooks are registered in `.claude/settings.json`. The registration associates a hook script with a specific event (PreToolUse, PostToolUse, SessionStart, etc.) and optionally a tool matcher.

## Hook Scripts

### `validate-commit.sh`
- **Event**: PreToolUse (matcher: Bash)
- **Fires**: Before Claude runs a `git commit` command
- **Checks**:
  - Staged Luau files don't contain `print()` (warn)
  - No deprecated APIs: `wait()`, `spawn()`, `delay()` (warn)
  - TODOs include issue reference: `-- TODO(#123): description` (warn)
  - JSON files in `assets/data/` are valid (fail — blocks commit)
  - Design docs have all required sections (warn)
- **Exit codes**: 0 = pass (with warnings), 1 = fail (blocks)
- **Dependencies**: `git`, optionally `jq` for JSON validation

### `validate-push.sh`
- **Event**: PostToolUse (matcher: Bash)
- **Fires**: After Claude runs a `git push` command
- **Checks**:
  - Pushing to protected branches (main, master, production, prod) — warn
  - Force pushes to protected branches — critical warn
- **Exit codes**: 0 (informational only; does not block)
- **Dependencies**: `git`

### `validate-assets.sh`
- **Event**: PreToolUse (matcher: Write|Edit)
- **Fires**: Before Claude writes or edits a file
- **Checks** (only for files in `assets/`):
  - Naming convention: `lowercase-kebab-case.ext` (warn)
  - JSON files in `assets/data/` are valid (fail if invalid)
  - Image size warnings: > 1MB warn, > 5MB strong warn
  - Audio size warnings: > 10MB warn
  - Model size warnings: > 20MB warn
- **Exit codes**: 0 = pass, 1 = invalid JSON (blocks)
- **Dependencies**: `stat`, optionally `jq`

### `session-start.sh`
- **Event**: SessionStart
- **Fires**: When a Claude Code session begins
- **Output** (to user):
  - Current review mode
  - Current sprint
  - Git branch
  - Uncommitted changes count
  - Last commit
  - Recent commit history
  - Last session notes
- **Exit codes**: 0 always
- **Dependencies**: `git`

### `session-stop.sh`
- **Event**: SessionStop
- **Fires**: When a Claude Code session ends
- **Action**:
  - Appends session summary to `production/session-state/session-log.txt`
  - Writes `production/session-state/last-session.txt` with end time, branch, HEAD
- **Exit codes**: 0 always
- **Dependencies**: `git`

### `detect-gaps.sh`
- **Event**: SessionStart (second hook after session-start.sh)
- **Fires**: When a Claude Code session begins
- **Action**: Analyzes project state and suggests starting commands if gaps detected:
  - No master GDD and code exists → suggest `/reverse-document`
  - No master GDD and no code → suggest `/start`
  - GDDs exist but no systems-index → suggest `/map-systems`
  - No review mode set → suggest `/start`
  - Master GDD exists but no sprints → suggest `/sprint-plan`
- **Exit codes**: 0 always

### `pre-compact.sh`
- **Event**: PreCompact
- **Fires**: Before Claude Code compresses older messages to save context
- **Action**: Writes a snapshot to `production/session-state/pre-compact-snapshot.md`:
  - Timestamp
  - Git state (branch, HEAD, staged, unstaged)
  - Review mode
  - Current sprint
- **Exit codes**: 0 always
- **Dependencies**: `git`

### `log-agent.sh`
- **Event**: SubagentStart
- **Fires**: When a subagent is spawned
- **Action**: Appends a line to `production/session-state/agent-log.txt` with:
  - Timestamp (UTC ISO 8601)
  - Agent name
  - Agent description
- **Exit codes**: 0 always

## Customizing Hooks

All hook scripts are plain bash. Edit `.claude/hooks/*.sh` to change behavior.

After editing, ensure scripts remain executable:
```bash
chmod +x .claude/hooks/*.sh
```

### Adding a New Hook

1. Create the bash script in `.claude/hooks/<name>.sh`
2. `chmod +x` it
3. Register it in `.claude/settings.json` under the appropriate event
4. Test by triggering the event
5. Document it in this file

### Disabling a Hook

Remove or comment out its entry in `.claude/settings.json`.

## Troubleshooting

### Hook not firing
- Check `.claude/settings.json` — is it registered?
- Is the script executable? `ls -la .claude/hooks/`
- Is the matcher correct for the event?

### Hook fails with permission denied
- `chmod +x .claude/hooks/*.sh`

### Hook produces unexpected output
- Test by running the hook manually: `bash .claude/hooks/session-start.sh`
- Check for missing tools (git, jq, stat)
- Check file paths (hooks run from project root)

### Hook blocks commits unintentionally
- Exit code 1 blocks the operation
- Check for `exit 1` or `fail` in the script
- Temporarily comment out the hook in settings.json if needed
