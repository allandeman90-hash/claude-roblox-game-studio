# Agent Coordination Map

Visual delegation map showing who delegates to whom and escalation paths.

## Delegation Tree

```
USER
  │
  ├── creative-director (Opus)
  │     ├── game-designer
  │     │     ├── systems-designer
  │     │     ├── level-designer
  │     │     └── economy-designer
  │     ├── art-director
  │     │     └── technical-artist
  │     ├── audio-director
  │     │     └── sound-designer
  │     ├── narrative-director
  │     │     ├── writer
  │     │     └── world-builder
  │     └── monetization-lead ──► economy-designer
  │
  ├── technical-director (Opus)
  │     ├── lead-programmer
  │     │     ├── luau-gameplay-programmer
  │     │     ├── luau-systems-programmer
  │     │     ├── datastore-architect
  │     │     ├── remotes-networking-specialist
  │     │     ├── ui-programmer
  │     │     └── exploit-security-specialist
  │     ├── performance-analyst
  │     ├── devops-engineer
  │     └── roblox-studio-specialist
  │
  └── producer (Opus)
        ├── qa-lead
        │     ├── qa-tester
        │     ├── exploit-security-specialist (shared with lead-programmer)
        │     └── performance-analyst (shared with tech-director)
        ├── release-manager
        │     └── devops-engineer (shared with tech-director)
        ├── analytics-retention-specialist
        ├── live-ops-specialist
        ├── community-manager
        ├── accessibility-specialist
        └── ux-designer (shared with game-designer)
```

## Escalation Paths

When an agent can't make a decision alone, they escalate:

```
Specialist → Lead → Director → User
```

### Specific Escalations

| From | Escalate To | When |
|------|-------------|------|
| luau-gameplay-programmer | lead-programmer | Implementation questions outside established patterns |
| lead-programmer | technical-director | Architecture changes |
| technical-director | User | Fundamental tech stack decisions |
| systems-designer | game-designer | Design intent unclear |
| game-designer | creative-director | Conflicts with creative pillars |
| creative-director | User | Creative pillar changes |
| exploit-security-specialist | technical-director | Architecture-level security issues |
| datastore-architect | technical-director | Schema or migration decisions |
| monetization-lead | creative-director | Ethical concerns |
| producer | User | Scope cuts, deadline slips |
| release-manager | producer | Publishing blockers |

## Horizontal Consultation

Same-tier agents can consult but don't make binding decisions:

- `luau-gameplay-programmer` ⟷ `ui-programmer`: coordinate HUD updates for a gameplay feature
- `game-designer` ⟷ `art-director`: ensure visuals match gameplay intent
- `analytics-retention-specialist` ⟷ `live-ops-specialist`: plan content based on metrics
- `datastore-architect` ⟷ `remotes-networking-specialist`: coordinate on data that crosses the wire

## Cross-Department Change Coordination

When a change affects multiple departments, `producer` coordinates:

```
              producer
             /   |   \
       design  tech  art
          |    |    |
      game-  lead- art-
      designer programmer director
          |    |    |
       systems luau technical
       designer gameplay artist
```

The producer ensures:
- Design, code, and art are all aligned on the change
- Schedule and sprint plan are updated
- Risk register reflects any new risks
- Decision log captures the rationale

## Team Orchestration Skills

Some features touch so many agents that a dedicated skill orchestrates them:

- `/team-combat` — combat features across design, code, VFX, audio
- `/team-ui` — UI features across UX, code, art, accessibility
- `/team-economy` — economy across design, data, remotes, security
- `/team-release` — releases across QA, security, perf, comms
- `/team-polish` — polish passes across visual, audio, feel, flow

## Common Workflows

### New Feature (full review mode)
1. `creative-director` → frames feature
2. `game-designer` → high-level design
3. `systems-designer` → detailed spec
4. `technical-director` → architecture review
5. `lead-programmer` → implementation plan
6. Specialists → implement
7. `qa-lead` + `qa-tester` → test
8. `exploit-security-specialist` → security pass
9. `performance-analyst` → perf pass
10. `producer` → sprint plan update
11. User approval → commit

### Bug Fix
1. `qa-tester` → repro and report
2. `qa-lead` → severity triage
3. Relevant specialist → investigate and fix
4. `lead-programmer` → review
5. Re-test
6. Commit

### Release
1. `producer` → trigger `/team-release`
2. `qa-lead` → final test pass
3. `exploit-security-specialist` → security pass
4. `performance-analyst` → perf pass
5. `release-manager` → `/publish-review`
6. `release-manager` → generate changelog
7. `community-manager` → draft patch notes / social posts
8. User go/no-go
9. `release-manager` → publish
10. `analytics-retention-specialist` → monitor
