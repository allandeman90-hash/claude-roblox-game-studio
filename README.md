# FoG Roblox Studio Command

> Turn Claude Code into a Roblox-native game development studio — specialized agents, Luau-first workflows, and a coordination system built for Roblox publishing.

![Agents](https://img.shields.io/badge/agents-33-blue)
![Skills](https://img.shields.io/badge/skills-40-green)
![Hooks](https://img.shields.io/badge/hooks-8-orange)
![Rules](https://img.shields.io/badge/rules-11-yellow)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
![Built for Claude Code](https://img.shields.io/badge/built%20for-Claude%20Code-8A2BE2)
![Roblox](https://img.shields.io/badge/platform-Roblox-red)

---

## Why This Exists

The original Claude Code Game Studios template spreads across Godot, Unity, and Unreal — three completely different engines with different paradigms. Every session wastes context tokens on irrelevant engine knowledge.

**FoG Roblox Studio Command is laser-focused on the Roblox ecosystem.** Every agent prompt, every coding rule, every validation hook, every template is written with Roblox-specific knowledge baked in:

- Luau (and only Luau)
- Roblox Engine (client-server architecture)
- Roblox Studio → Roblox Cloud publishing
- Robux, GamePasses, DevProducts, Premium Payouts
- DataStoreService + MemoryStoreService patterns
- RemoteEvents, RemoteFunctions, UnreliableRemoteEvents
- ScreenGui, SurfaceGui, BillboardGui (Roact/Fusion optional)

No wasted tokens on C#, GDScript, or Blueprints. No generic "game engine" abstractions. Just Roblox, done right.

---

## What's Included

| Category | Count | What It Does |
|----------|-------|--------------|
| **Agents** | 33 | Specialized subagents organized by studio hierarchy (Directors → Leads → Specialists) |
| **Skills** | 40 | Slash commands for common workflows (GDD, code review, security audits, release prep) |
| **Hooks** | 8 | Validation and session management automation |
| **Rules** | 11 | Path-scoped coding standards (server, client, DataStores, remotes, UI, etc.) |
| **Templates** | 26 | Ready-to-use Markdown templates for GDDs, ADRs, reports, manifests |
| **Docs** | 10 | Roblox architecture guide, Luau style guide, coordination rules, quick start |

---

## Studio Hierarchy

```
Tier 1 — Directors (opus)
  creative-director    technical-director    producer

Tier 2 — Department Leads (sonnet)
  game-designer        lead-programmer       art-director
  audio-director       narrative-director    qa-lead
  release-manager      monetization-lead

Tier 3 — Specialists (sonnet / haiku)
  luau-gameplay-programmer       luau-systems-programmer
  datastore-architect            remotes-networking-specialist
  ui-programmer                  systems-designer
  level-designer                 economy-designer
  technical-artist               sound-designer
  writer                         world-builder
  ux-designer                    exploit-security-specialist
  analytics-retention-specialist live-ops-specialist
  qa-tester                      performance-analyst
  accessibility-specialist       devops-engineer
  community-manager              roblox-studio-specialist
```

---

## Slash Commands

### Onboarding & Project Setup
- `/start` — Guided onboarding for new projects or existing codebases
- `/onboard` — Onboard a new contributor to the project
- `/project-stage-detect` — Analyze project state (pre-production / production / polish / live)
- `/reverse-document` — Generate design docs from existing code

### Design & Documentation
- `/gdd` — Create or update a Game Design Document
- `/design-review` — Comprehensive design doc review
- `/design-system` — Per-system GDD creation
- `/map-systems` — Enumerate and categorize all game systems
- `/brainstorm` — Creative ideation and mechanic exploration

### Implementation & Code Quality
- `/code-review` — Luau code review
- `/luau-lint` — Static analysis of Luau code
- `/prototype` — Quick prototype workflow
- `/tech-debt` — Identify and catalog technical debt
- `/perf-profile` — Performance profiling guide

### Roblox-Specific Audits
- `/datastore-review` — DataStoreService audit
- `/remotes-audit` — RemoteEvent security audit
- `/exploit-check` — Comprehensive security vulnerability scan
- `/economy-audit` — In-game economy balance audit
- `/balance-check` — Game balance verification

### Production & Planning
- `/sprint-plan` — Create a sprint plan from priorities
- `/milestone-review` — Review milestone completion
- `/estimate` — Estimation workflow
- `/retrospective` — Sprint retrospective facilitation
- `/scope-check` — Evaluate scope vs. resources
- `/gate-check` — Stage gate advancement check
- `/bug-report` — Structured bug report creation

### Live Service & Publishing
- `/publish-review` — Pre-publish checklist
- `/release-checklist` — Full release checklist
- `/launch-checklist` — First launch specific checks
- `/retention-analysis` — Retention metric analysis
- `/monetization-model` — Monetization design workflow
- `/changelog` — Generate changelog from git history
- `/patch-notes` — Player-facing patch notes
- `/hotfix` — Emergency fix workflow
- `/asset-audit` — Asset review and organization

### Multi-Agent Teams
- `/team-combat` — Combat system cross-specialist coordination
- `/team-ui` — UI feature cross-specialist coordination
- `/team-economy` — Economy feature cross-specialist coordination
- `/team-release` — Release coordination
- `/team-polish` — Polish pass coordination

---

## Getting Started

### Prerequisites

- **Claude Code** (latest) — [Install instructions](https://docs.claude.com/en/docs/claude-code/overview)
- **Git** — for version control
- **Rojo** or **Argon** (optional, recommended) — for Roblox project sync
- **Bash** — for hook scripts (Git Bash on Windows, native on Mac/Linux)

### Setup

```bash
# Clone this template into your project directory
git clone https://github.com/fog-studios/FoG-Roblox-Studio-Command.git my-roblox-game
cd my-roblox-game

# Remove the origin (so you don't accidentally push to the template)
git remote remove origin

# Make hooks executable
chmod +x .claude/hooks/*.sh

# Initialize a fresh history for your project
rm -rf .git
git init
git add .
git commit -m "feat: initial FoG Roblox Studio Command setup"
```

### First Run

Open Claude Code in the project directory:

```bash
cd my-roblox-game
claude
```

Then type:

```
/start
```

The onboarding flow will guide you through:

1. Where you are with the project (no idea / vague concept / clear design / existing code)
2. Sync tool selection (Rojo / Argon / Manual Studio)
3. UI framework preference (Native / Roact / Fusion)
4. Review intensity (full / lean / solo)
5. First GDD or reverse-documentation of existing code

---

## Project Structure

```
FoG-Roblox-Studio-Command/
├── CLAUDE.md                    # Master configuration (loaded every session)
├── .claude/
│   ├── settings.json            # Hooks, permissions, safety rules
│   ├── agents/                  # 33 agent definitions
│   ├── skills/                  # 40 slash commands
│   ├── hooks/                   # 8 validation/session scripts
│   ├── rules/                   # 11 path-scoped coding standards
│   └── docs/                    # Guides + 26 templates
├── src/                         # Roblox project (Rojo/Argon mapping)
│   ├── ServerScriptService/
│   ├── ServerStorage/
│   ├── ReplicatedStorage/
│   ├── StarterGui/
│   ├── StarterPlayer/
│   └── ReplicatedFirst/
├── assets/                      # Images, audio, models, data (JSON)
├── design/                      # GDDs, economy models, narrative, level plans
├── docs/                        # Architecture docs, workflow guides
├── tests/                       # TestEZ / Jest-Lua test suites
├── tools/                       # Build/deploy scripts
├── prototypes/                  # Throwaway exploration code
└── production/                  # Sprint plans, session state, agent logs
```

---

## How It Works

### Agent Coordination

Every session starts with Claude Code reading `CLAUDE.md`, which loads the architecture guide, style guide, coordination rules, and delegation map. When you ask a question, Claude routes it to the right agent:

- **Directors** (Opus) handle strategy, architecture, and cross-cutting decisions
- **Leads** (Sonnet) translate direction into department-level plans
- **Specialists** (Sonnet/Haiku) execute focused tasks within their domain

Delegation is vertical (Directors → Leads → Specialists). Specialists don't make binding cross-domain decisions — they escalate to their Lead or Director. The Producer coordinates cross-department changes.

### Collaboration Protocol

Every agent follows: **Question → Options → Decision → Draft → Approval**

- Agents ASK for context before proposing
- Agents present 2-4 OPTIONS with Roblox-specific trade-offs
- The user DECIDES — agents don't unilaterally commit to approaches
- Agents DRAFT their work and request review
- Nothing gets written without explicit APPROVAL

### Validation Hooks

Hooks run automatically at key events:

- **SessionStart** — Loads last session state, shows git activity, detects gaps
- **PreToolUse (Bash)** — Validates commit contents before git commits
- **PreToolUse (Write/Edit)** — Validates assets and file naming
- **PostToolUse (Bash)** — Warns on pushes to protected branches
- **SubagentStart** — Logs agent invocations to `production/session-state/`
- **PreCompact** — Preserves context before compression
- **SessionStop** — Saves accomplishments and session state

---

## Roblox-Specific Features

This template bakes in deep Roblox knowledge at every level:

### 🛡️ Security-First by Default
- `exploit-security-specialist` agent with full attack-vector knowledge
- `/exploit-check` and `/remotes-audit` skills
- `server-scripts.md` and `remotes.md` rules enforce server authority
- Every agent prompt references the "never trust the client" rule

### 💾 DataStore-Aware
- `datastore-architect` agent with session locking, budget management, schema versioning expertise
- `/datastore-review` skill with 20+ anti-pattern checks
- `datastores.md` rule enforces pcall + session locking + BindToClose patterns
- Templates for documenting DataStore schemas

### 💰 Monetization-Native
- `monetization-lead` agent with GamePass / DevProduct / Premium Benefits knowledge
- `/monetization-model` and `/economy-audit` skills
- Ethical monetization standards baked in (no pay-to-win, no FOMO targeting children)
- Templates for GamePass design, economy models, revenue projections

### 📊 Live Service Ready
- `live-ops-specialist` for seasonal events and feature flags
- `analytics-retention-specialist` for D1/D7/D30 tracking
- `release-manager` for publishing pipeline
- `/hotfix`, `/patch-notes`, `/changelog` skills for rapid updates

### 🎨 Roblox Studio Knowledge
- `roblox-studio-specialist` agent for plugins, Studio API, CollectionService, Attributes
- `art-director` knows Roblox mesh limits (10K tris), texture caps (1024x1024), PBR SurfaceAppearance
- `audio-director` knows Roblox audio privacy policies and asset management
- `level-designer` knows StreamingEnabled, Terrain, lighting, spatial partitioning

---

## Design Philosophy

1. **Collaborative, not autonomous** — Every task follows Question → Options → Decision → Draft → Approval. The user makes the call.
2. **Roblox-native architecture** — Agents understand the client-server security boundary, DataStore patterns, Roblox service hierarchy, and platform constraints.
3. **Publishing-pipeline aware** — This isn't just for building games; it's for shipping them. Live ops, monetization, analytics, retention are first-class concerns.
4. **FoG Studios workflow** — Supports multi-title publishing, comprehensive GDD-first documentation, sprint-based production.
5. **ForgeLight-compatible** — Designed to serve as the organizational/orchestration layer that a Luau code generation system (like ForgeLight) plugs into.

---

## Customization

Every agent, skill, hook, rule, and template is a plain Markdown or bash file. You can edit any of them to match your studio's conventions:

- **Adjust agent delegation paths** — edit the "Delegation" section in an agent file
- **Add your own skills** — create `.claude/skills/my-skill/SKILL.md`
- **Tweak coding standards** — edit files in `.claude/rules/`
- **Add new templates** — drop them in `.claude/docs/templates/`
- **Change hook behavior** — edit the bash scripts in `.claude/hooks/`

When you upgrade to a new version of FoG Roblox Studio Command, any files you've modified will stay unless you explicitly overwrite them. See `UPGRADING.md`.

---

## ForgeLight Integration

FoG Roblox Studio Command is the **organizational layer**. For raw Luau code generation at scale, pair it with [ForgeLight](https://github.com/fog-studios/forgelight) — a Luau-specific code generator that this template can orchestrate.

Workflow:

1. FoG agents design the system (GDD, data schema, RemoteEvent contracts)
2. Lead programmer delegates implementation to ForgeLight with the design contract
3. FoG agents review ForgeLight output against the design and quality gates
4. User approves and commits

---

## License

MIT — see [LICENSE](LICENSE)

Copyright © 2026 FoG Studios (Fear of Game Studios)
