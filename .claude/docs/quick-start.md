# Quick Start Guide

Get up and running with FoG Roblox Studio Command in 5 minutes.

## 1. Install Prerequisites

- **Claude Code** (latest) — [Install](https://docs.claude.com/en/docs/claude-code/overview)
- **Git**
- **Rojo** (primary), **Argon** (compatible), or **Manual Studio** (supported) — for Roblox Studio sync
- **Bash** (Git Bash on Windows, native on Mac/Linux)

## 2. Clone the Template

```bash
git clone https://github.com/fog-studios/FoG-Roblox-Studio-Command.git my-roblox-game
cd my-roblox-game

# Fresh git history for your project
rm -rf .git
git init

# Make hooks executable
chmod +x .claude/hooks/*.sh

git add .
git commit -m "feat: initial FoG Roblox Studio Command setup"
```

## 3. Install Toolchain & Packages

```bash
# Install toolchain (Rojo, Selene, StyLua, Wally) via Aftman
aftman install

# Install Luau packages via Wally
wally install

# Verify installations
rojo --version
selene --version
stylua --version
```

## 4. Open Claude Code

```bash
claude
```

Claude Code will read `CLAUDE.md` automatically.

## 5. Run `/start`

Type in Claude Code:

```
/start
```

The onboarding flow will ask:

1. **Where are you?** — no idea / vague concept / clear design / existing code
2. **Sync tool** — Rojo (primary), Argon (compatible), Manual Studio (supported)
3. **UI framework** — Native / Roact / Fusion
4. **Review mode** — full / lean / solo

## 6. Your First Task

Based on your starting point:

### If starting from scratch
1. `/brainstorm` — explore game ideas
2. `/gdd` — write the master GDD
3. `/map-systems` — catalog planned systems
4. `/sprint-plan` — plan the first sprint

### If you have existing code
1. `/reverse-document` — extract design from code
2. `/project-stage-detect` — assess current stage
3. `/tech-debt` — inventory technical debt
4. `/sprint-plan` — plan what's next

### If you have design docs
1. `/design-review` — verify GDD quality
2. `/map-systems` — create systems index
3. `/sprint-plan` — plan implementation

## 7. Everyday Workflow

### Creating a Feature
1. `/design-system` — write the spec
2. `/team-combat` or `/team-ui` or `/team-economy` — orchestrate implementation
3. `/code-review` — review the code
4. `/exploit-check` or `/datastore-review` — security pass

### Preparing a Release
1. `/publish-review` — pre-publish checklist
2. `/changelog` — generate technical changelog
3. `/patch-notes` — draft player-facing notes
4. `/team-release` — orchestrate the publish

### Incident Response
1. `/hotfix` — emergency fix workflow

## 8. Getting Help

- `/onboard` — full contributor onboarding
- `CLAUDE.md` — session config (always loaded)
- `.claude/docs/` — architecture guides, style guide, coordination rules
- `.claude/agents/` — list of all available agents
- `.claude/skills/` — list of all slash commands

## 9. Customization

Every file in `.claude/` is plain text. Edit to match your studio's conventions.
Your customizations survive template updates (see `UPGRADING.md`).

## Next Steps

- Read [`roblox-architecture-guide.md`](./roblox-architecture-guide.md) to understand the Roblox-specific architecture
- Read [`luau-style-guide.md`](./luau-style-guide.md) for the Luau coding style
- Read [`agent-roster.md`](./agent-roster.md) to see all available agents
- Read [`coordination-rules.md`](./coordination-rules.md) to understand how agents work together
