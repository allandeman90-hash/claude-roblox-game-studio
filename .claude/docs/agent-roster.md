# Agent Roster

Full table of all 33 agents with their tier, model, domain, and key files they own.

## Tier 1 — Directors (opus)

| Agent | Domain | Key Files |
|-------|--------|-----------|
| `creative-director` | Vision, player experience, creative pillars | `design/gdd/master-gdd.md`, creative decisions |
| `technical-director` | Architecture, security, perf, tech debt | `docs/architecture/*`, ADRs |
| `producer` | Production flow, sprints, milestones | `production/sprints/*`, `production/milestones/*` |

## Tier 2 — Department Leads (sonnet)

| Agent | Domain | Key Files |
|-------|--------|-----------|
| `game-designer` | GDDs, system design, balance | `design/gdd/*` |
| `lead-programmer` | All Luau implementation | `src/**` |
| `art-director` | Visual style, asset standards | `assets/images/`, `assets/models/` |
| `audio-director` | Audio design, SoundService | `assets/audio/` |
| `narrative-director` | Story, lore, dialogue | `design/narrative/*` |
| `qa-lead` | Testing strategy, bug triage | `tests/*`, `production/bugs/*` |
| `release-manager` | Publishing pipeline | `production/releases/*` |
| `monetization-lead` | GamePass / DevProduct / Premium | `design/monetization-plan.md` |

## Tier 3 — Specialists (sonnet / haiku)

### Programming

| Agent | Model | Domain | Key Files |
|-------|-------|--------|-----------|
| `luau-gameplay-programmer` | sonnet | Combat, abilities, inventory, interactions | `src/ServerScriptService/**`, `src/ServerStorage/**` |
| `luau-systems-programmer` | sonnet | Framework code, modules, signals, state | `src/ReplicatedStorage/Shared/**` |
| `datastore-architect` | sonnet | DataStore patterns, session locking | `**/DataStore/**`, `**/PlayerData/**` |
| `remotes-networking-specialist` | sonnet | RemoteEvent/Function architecture | `**/Remotes/**`, `design/remotes-manifest.md` |
| `ui-programmer` | sonnet | UI implementation (Roact / Fusion / native) | `src/StarterGui/**` |

### Design

| Agent | Model | Domain | Key Files |
|-------|-------|--------|-----------|
| `systems-designer` | sonnet | Detailed system specs | `design/gdd/<system>-gdd.md` |
| `level-designer` | sonnet | Maps, spawn systems, level flow | `design/levels/*` |
| `economy-designer` | sonnet | Currency, sinks/faucets, trading | `design/economy/*` |
| `ux-designer` | sonnet | Player flows, wireframes | `design/gdd/ui-ux-gdd.md` |

### Art & Audio

| Agent | Model | Domain | Key Files |
|-------|-------|--------|-----------|
| `technical-artist` | sonnet | VFX, mesh optimization, shaders | `assets/models/`, VFX code |
| `sound-designer` | haiku | SoundService, spatial audio, pooling | `assets/audio/`, sound code |

### Narrative

| Agent | Model | Domain | Key Files |
|-------|-------|--------|-----------|
| `writer` | sonnet | Quest text, dialogue, UI copy | `design/narrative/text/*` |
| `world-builder` | sonnet | Lore, factions, geography | `design/narrative/world-bible.md` |

### Security & Quality

| Agent | Model | Domain | Key Files |
|-------|-------|--------|-----------|
| `exploit-security-specialist` | sonnet | Anti-exploit, security audits | `production/security/*`, exploit reports |
| `qa-tester` | haiku | Test plans, test execution | `tests/*`, `production/bugs/*` |
| `performance-analyst` | sonnet | Profiling, optimization | `production/perf-reports/*` |
| `accessibility-specialist` | haiku | Contrast, sizing, screen reader | accessibility reviews |

### Live Ops

| Agent | Model | Domain | Key Files |
|-------|-------|--------|-----------|
| `analytics-retention-specialist` | sonnet | Metrics, retention, funnels | `production/analytics/*` |
| `live-ops-specialist` | sonnet | Events, feature flags, content cal | `production/live-ops/*` |
| `community-manager` | haiku | Discord, social, player feedback | `production/community/*` |

### Infrastructure

| Agent | Model | Domain | Key Files |
|-------|-------|--------|-----------|
| `devops-engineer` | sonnet | Rojo, CI/CD, Open Cloud API | `.github/workflows/*`, `default.project.json` |
| `roblox-studio-specialist` | sonnet | Studio API, plugins, Attributes | Studio-specific code |

## Model Selection Rationale

- **opus**: Strategic decisions, cross-cutting concerns, high-level architecture. Directors get opus because they need deep reasoning.
- **sonnet**: Most specialists. Good at domain-specific work with moderate complexity.
- **haiku**: Fast, focused tasks. Used for specialists whose work is routine (sound effects, accessibility checks, community messages, QA test execution).

## Delegation Quick Reference

Common questions → agent:

- "How should we design X?" → `game-designer` or `systems-designer`
- "How should we build X?" → `lead-programmer`
- "Is this secure?" → `exploit-security-specialist`
- "Does this handle data correctly?" → `datastore-architect`
- "Is this a good remote design?" → `remotes-networking-specialist`
- "Is this UI good?" → `ui-programmer` or `ux-designer`
- "Will this affect balance?" → `game-designer` or `economy-designer`
- "How should we monetize X?" → `monetization-lead`
- "Is this fast enough?" → `performance-analyst`
- "Is this accessible?" → `accessibility-specialist`
- "How should we test this?" → `qa-lead` or `qa-tester`
- "How do we publish?" → `release-manager`
- "What's our content strategy?" → `live-ops-specialist`
- "How do we handle feedback?" → `community-manager`
