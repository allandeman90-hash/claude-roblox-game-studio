# Directory Structure

Explanation of the full directory tree.

## Root

```
FoG-Roblox-Studio-Command/
├── CLAUDE.md          # Master config — loaded every Claude Code session
├── README.md          # GitHub README
├── UPGRADING.md       # Template version migration guide
├── LICENSE            # MIT
├── .gitignore         # Roblox file types, env files, session state
├── .claude/           # Claude Code config
├── src/               # Roblox source code (Rojo mapping, Argon compatible)
├── assets/            # Images, audio, models, data
├── design/            # Design docs (GDDs, economy, narrative, levels)
├── docs/              # Project docs (architecture, workflows)
├── tests/             # Unit and integration tests
├── tools/             # Build/deploy scripts
├── prototypes/        # Throwaway experiments
└── production/        # Sprints, milestones, session state
```

## `.claude/`

Claude Code configuration. Everything here affects how Claude Code behaves.

```
.claude/
├── settings.json      # Permissions, hooks, behavior
├── agents/            # 36 agent definitions (Markdown + YAML frontmatter)
├── skills/            # 50 slash commands (one subdirectory per skill)
├── hooks/             # 9 bash scripts for events (session-start, validate-commit, etc.)
├── rules/             # 11 path-scoped coding standards
└── docs/              # Guides + 26 templates
    └── templates/     # GDD templates, ADRs, reports, manifests
```

### `.claude/agents/`
Each file is a Markdown file with YAML frontmatter defining the agent:
- `name`: Agent name
- `description`: When to use this agent
- `model`: opus / sonnet / haiku
- `tools`: Comma-separated list of tools

The body is the system prompt for that agent.

### `.claude/skills/`
Each skill is a subdirectory containing a `SKILL.md` file:
- `name`: Skill name (`/command`)
- `description`: When to use this skill
- Body: Step-by-step workflow

### `.claude/hooks/`
Bash scripts that run on Claude Code events. Registered in `settings.json`.

### `.claude/rules/`
Path-scoped coding standards. Applied automatically when editing files matching the `paths` glob.

### `.claude/docs/`
Reference documentation (architecture guide, style guide, etc.).

### `.claude/docs/templates/`
Ready-to-use Markdown templates for GDDs, reports, and manifests.

## `src/`

Roblox project source code, organized to match the Roblox service hierarchy via Rojo (primary; Argon compatible).

```
src/
├── ServerScriptService/           # Server-only scripts (active code)
├── ServerStorage/                 # Server-only data and modules (not replicated)
├── ReplicatedStorage/             # Shared modules (client + server)
│   └── Shared/                    # Common utilities, types, configs
├── StarterGui/                    # UI that gets cloned to PlayerGui on spawn
├── StarterPlayer/
│   ├── StarterPlayerScripts/      # LocalScripts that run when player joins
│   └── StarterCharacterScripts/   # Scripts attached to player's character
└── ReplicatedFirst/               # Early client scripts (loading screen)
```

See `roblox-architecture-guide.md` for details on each service.

## `assets/`

Non-code assets, organized by type.

```
assets/
├── images/     # UI graphics, textures, decals
├── audio/      # Music, SFX, voice
├── models/     # 3D meshes (FBX, OBJ)
└── data/       # JSON config files (localization, item lists, etc.)
```

Assets are uploaded to Roblox via the Creator Dashboard or Open Cloud API — this directory is the source of truth for the project.

## `design/`

Design documentation.

```
design/
├── gdd/              # Game Design Documents
│   ├── master-gdd.md           # Top-level GDD
│   ├── systems-index.md        # Catalog of all systems
│   └── <system>-gdd.md         # Per-system GDDs
├── economy/          # Economy models, balance spreadsheets
├── narrative/        # Lore, quests, dialogue
└── levels/           # Level plans, maps
```

## `docs/`

Project-level documentation (different from `.claude/docs/` which is tool docs).

```
docs/
├── architecture/                           # Architecture Decision Records
├── COLLABORATIVE-DESIGN-PRINCIPLE.md       # Full collaboration protocol
└── WORKFLOW-GUIDE.md                        # Visual workflow guide
```

## `tests/`

Unit and integration tests.

```
tests/
├── ServerScriptService/    # Server code tests
└── ReplicatedStorage/       # Shared module tests
```

Test files follow `<Module>.spec.lua` or `<Module>.spec.luau` naming. Configure the test runner (TestEZ or Jest-Lua) via Wally.

## `tools/`

Build, lint, and tooling scripts.

```
tools/
├── setup.sh               # Install toolchain (aftman) and packages (wally)
├── build.sh               # Build the Rojo project
├── lint.sh                # Run selene + stylua
└── test.sh                # Run test suite (placeholder)
```

## `prototypes/`

Throwaway experiments. Each prototype is a subdirectory with its own README.

```
prototypes/
├── parry-mechanic/
│   ├── README.md          # Hypothesis, how to run, findings
│   └── <code>
└── trading-ui/
    ├── README.md
    └── <code>
```

**Rules** (see `rules/prototypes.md`):
- Relaxed standards
- README required
- Never import from `src/`
- Never graduate to `src/` without rewrite

## `production/`

Production artifacts — sprints, milestones, bug tracker, session state.

```
production/
├── sprints/                  # Sprint plans and retros
├── milestones/               # Milestone docs
├── bugs/                     # Bug reports
├── releases/                 # Release checklists, publish reviews
├── analytics/                # Retention analyses
├── live-ops/                 # Event plans, feature flag state
├── community/                # Discord configs, player feedback
├── incidents/                # Hotfix reports, post-mortems
├── gates/                    # Stage gate reviews
├── security/                 # Exploit reports
├── perf-reports/             # Performance profiling reports
├── decision-log.md           # Major decisions with rationale
├── risk-register.md          # Known risks with mitigation
├── review-mode.txt           # Current review mode (full/lean/solo)
└── session-state/            # Cross-session persistent context
    ├── current-sprint.txt
    ├── last-session.txt
    ├── session-log.txt
    ├── agent-log.txt
    └── pre-compact-snapshot.md
```

Most of `production/session-state/` is gitignored (personal, not shared).

## What's Gitignored

From `.gitignore`:
- Roblox binary files (`.rbxl`, `.rbxm`)
- Build artifacts (`build/`, `dist/`, `node_modules/`)
- Environment files (`.env`, `.env.local`)
- IDE folders (`.vscode/`, `.idea/`)
- OS metadata (`.DS_Store`, `Thumbs.db`)
- Session state files (personal, not shared)
- Rojo lock file
