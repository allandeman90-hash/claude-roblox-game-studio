# Workflow Guide

Visual guide to how skills chain together for common tasks.

---

## 1. Starting a New Project (From Scratch)

```
/start
  │
  ├── "No idea" ───► /brainstorm ───► /gdd ───► /map-systems ───► /sprint-plan
  │
  ├── "Vague concept" ───► /gdd ───► /map-systems ───► /sprint-plan
  │
  ├── "Clear design" ───► /design-review ───► /project-stage-detect ───► /sprint-plan
  │
  └── "Existing code" ───► /reverse-document ───► /tech-debt ───► /sprint-plan
```

**Expected outputs**:
- Master GDD at `design/gdd/master-gdd.md`
- Systems index at `design/gdd/systems-index.md`
- First sprint plan at `production/sprints/sprint-1-plan.md`
- Review mode set in `production/review-mode.txt`

---

## 2. Designing a New Feature

```
/brainstorm (optional, for creative exploration)
  │
  ▼
/design-system <name>
  │
  ▼
/design-review
  │
  ▼
[update /map-systems]
  │
  ▼
/sprint-plan (adds feature to sprint)
```

**Expected outputs**:
- System GDD at `design/gdd/<name>-gdd.md`
- Updated systems index
- Feature on the current or next sprint

---

## 3. Implementing a Feature

Once the design is approved, implementation follows one of the `/team-*` workflows:

### Combat Feature
```
/team-combat
  ├── game-designer: design intent
  ├── systems-designer: detailed spec
  ├── remotes-networking-specialist: remote contracts
  ├── exploit-security-specialist: security review
  ├── luau-gameplay-programmer: implementation
  ├── technical-artist: VFX
  ├── sound-designer: audio
  ├── ui-programmer: HUD updates
  ├── qa-tester: test plan + execute
  ├── performance-analyst: profile
  ├── exploit-security-specialist: final security pass
  └── producer: update sprint plan
```

### UI Feature
```
/team-ui
  ├── ux-designer: wireframe
  ├── art-director: visual style
  ├── writer: copy
  ├── ui-programmer: implementation
  ├── accessibility-specialist: accessibility review
  ├── qa-tester: device coverage
  └── performance-analyst: mobile FPS check
```

### Economy Feature
```
/team-economy
  ├── economy-designer: currency flow
  ├── monetization-lead: Robux items (if any)
  ├── systems-designer: detailed spec
  ├── datastore-architect: data model
  ├── remotes-networking-specialist: remote contracts
  ├── exploit-security-specialist: duplication / replay review
  ├── luau-gameplay-programmer: implementation
  ├── ui-programmer: shop/trade UI
  ├── economy-designer: balance tuning
  ├── analytics-retention-specialist: telemetry
  ├── qa-tester: edge cases
  └── exploit-security-specialist: final security
```

---

## 4. Fixing a Bug

```
/bug-report (if reported by user or tester)
  │
  ▼
qa-lead triage → severity classified
  │
  ▼
[delegate to relevant specialist]
  │
  ▼
Fix proposed
  │
  ▼
/code-review
  │
  ▼
Test fix
  │
  ▼
/hotfix (if S0/S1, otherwise normal release cadence)
```

---

## 5. Preparing a Release

```
[Feature freeze]
  │
  ▼
/exploit-check ───► fix critical findings
  │
  ▼
/datastore-review ───► fix critical findings
  │
  ▼
/remotes-audit ───► fix critical findings
  │
  ▼
/perf-profile ───► fix regressions
  │
  ▼
/code-review
  │
  ▼
/publish-review (gate check)
  │
  ▼
/team-release
  ├── /changelog
  ├── /patch-notes
  └── community-manager preps announcements
  │
  ▼
Publish
  │
  ▼
/retention-analysis (24-72 hours later)
  │
  ▼
/retrospective
```

---

## 6. Emergency Hotfix

```
Issue detected (user report / monitoring alert)
  │
  ▼
Triage (qa-lead) → S0 or S1?
  │
  ▼
/hotfix workflow
  ├── Diagnose
  ├── Minimal fix
  ├── Expedited review
  ├── Publish
  ├── Monitor
  └── Post-mortem → production/incidents/
```

---

## 7. Live Ops Update (Event, Balance, Content)

```
Content plan ───► /monetization-model or /design-system
  │
  ▼
Implementation
  │
  ▼
/balance-check
  │
  ▼
/economy-audit (if economy-affecting)
  │
  ▼
Feature flag toggle (via live-ops-specialist)
  │
  ▼
/patch-notes
  │
  ▼
Publish or enable flag
  │
  ▼
/retention-analysis (monitor impact)
```

---

## 8. Technical Debt Sprint

```
/tech-debt ───► inventory
  │
  ▼
Prioritize items
  │
  ▼
/scope-check (is this sprint realistic?)
  │
  ▼
Tackle items in priority order
  │
  ▼
/code-review (after each major refactor)
  │
  ▼
/perf-profile (if performance debt was addressed)
  │
  ▼
/retrospective (lessons learned)
```

---

## 9. Onboarding a Contributor

```
/onboard
  ├── Role identification
  ├── Docs tour
  ├── Agent introduction
  ├── First tasks
  └── Norms explanation
```

---

## 10. Gate Advance (Production Phase Change)

```
/project-stage-detect (current stage)
  │
  ▼
/gate-check (target stage)
  │
  ├── All criteria met ───► Advance
  │
  └── Blockers ───► Address, re-run gate check
```

---

## Common Mistake Patterns

### Skipping design
**Wrong**: Jumping into code without a GDD.
**Right**: `/design-system <name>` first, always.

### Skipping security
**Wrong**: Shipping without `/exploit-check`.
**Right**: Every release runs through security audits.

### Skipping retrospective
**Wrong**: Rushing into next sprint without learning.
**Right**: `/retrospective` after every sprint, even short ones.

### Not using teams
**Wrong**: Manually coordinating specialists one at a time.
**Right**: Use `/team-*` skills for multi-specialist features.

### Forgetting analytics
**Wrong**: Shipping features without instrumentation.
**Right**: Always add analytics events as part of implementation.

---

## Cadence Recommendations

| Activity | Frequency |
|----------|-----------|
| `/sprint-plan` | Every 2 weeks |
| `/retrospective` | End of every sprint |
| `/code-review` | Every PR |
| `/exploit-check` | Every release |
| `/datastore-review` | Every release |
| `/remotes-audit` | Every release |
| `/perf-profile` | When regression suspected |
| `/retention-analysis` | Weekly post-launch |
| `/tech-debt` | Monthly |
| `/scope-check` | Mid-sprint |
| `/gate-check` | At stage transitions |
| `/publish-review` | Every release |
| `/balance-check` | When balance changes |
