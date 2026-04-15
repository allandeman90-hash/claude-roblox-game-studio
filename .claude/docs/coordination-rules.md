# Coordination Rules

How agents work together in FoG Roblox Studio Command.

## 1. Hierarchy

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

## 2. Vertical Delegation

Directors delegate to Leads. Leads delegate to Specialists.

Example chain:
- User: "Add a combat parry system"
- creative-director: frames the feature from player experience POV
- creative-director → game-designer: design the mechanic
- game-designer → systems-designer: detailed spec
- systems-designer → lead-programmer: implementation hand-off
- lead-programmer → luau-gameplay-programmer: code the parry
- lead-programmer → remotes-networking-specialist: design parry remote
- lead-programmer → exploit-security-specialist: review for timing exploits

## 3. Horizontal Consultation

Same-tier agents can consult each other but cannot make binding cross-domain decisions.

Example:
- luau-gameplay-programmer can ASK ui-programmer: "What's the best pattern for the parry indicator?"
- But only the lead (ui-programmer's boss) or the user decides if the pattern is adopted

## 4. Conflict Resolution

When agents disagree, escalate to the shared parent director:

- Creative vs. Technical conflict → user decides after both directors present
- Design vs. Implementation cost → producer mediates, user decides
- Artistic vision vs. performance → creative-director + technical-director + user

## 5. Domain Boundaries

Agents don't modify files outside their domain without explicit delegation.

Examples:
- `exploit-security-specialist` identifies a bug in `luau-gameplay-programmer`'s code but doesn't fix it directly — hands off with a recommendation
- `art-director` asks for a visual effect change but delegates the code change to `technical-artist`
- `producer` doesn't write code but schedules the work via `lead-programmer`

Exception: **Tier 1 Directors** (creative/technical) can make binding decisions but still need user approval to execute.

## 6. Change Propagation

Cross-department changes are coordinated by the producer.

If a change affects:
- Design + Code → producer coordinates game-designer + lead-programmer
- Art + Code → producer coordinates art-director + lead-programmer
- Monetization + Systems → producer coordinates monetization-lead + technical-director
- Release + Everything → producer + release-manager

## 7. Decision Logging

Major decisions get logged to `production/decision-log.md`:

```markdown
## 2026-04-15 — Combat Parry Mechanic

**Decision**: Add a 200ms parry window with counter-damage bonus.

**Context**: Players requested more defensive options. Currently the only defensive tool is dodging.

**Options Considered**:
1. Block button (hold to reduce damage): rejected — too passive
2. Parry window (short timing): accepted — active defense
3. Dodge-cancel (dodge during attack): rejected — too similar to dodge

**Deciders**: user, creative-director, game-designer

**Impact**: Combat system spec updated, parry remote added, QA test plan updated.
```

## 8. Agent Invocation Patterns

### Direct Invocation
User says "I need X" → Claude identifies the right agent and invokes.

### Skill-Based Invocation
User says `/command` → Skill routes to the right agent(s).

### Proactive Invocation
User says something that matches an agent's description → Claude proactively invokes.
Example: User says "let me publish this update" → `release-manager` is proactively invoked.

### Multi-Agent Invocation
For cross-cutting features, use a `/team-*` skill to orchestrate multiple agents.

## 9. Review Mode Impact

The review mode in `production/review-mode.txt` affects how many agents are involved:

- **Full**: Every change runs through the relevant specialists for review
- **Lean**: Critical changes reviewed, minor changes proceed with a single approval
- **Solo**: Minimum agent involvement; user drives decisions directly

## 10. Collaboration Protocol (the universal rule)

**Every agent follows**: Question → Options → Decision → Draft → Approval

1. **Question**: Agent gathers context and asks clarifying questions
2. **Options**: Agent presents 2-4 options with trade-offs
3. **Decision**: User makes the call
4. **Draft**: Agent produces a draft (code, doc, design)
5. **Approval**: User reviews and approves before anything is written

Agents MUST ask "May I write this to [filepath]?" before using Write/Edit.
Agents MUST show drafts for multi-file changes.
Nothing gets committed without user instruction.
