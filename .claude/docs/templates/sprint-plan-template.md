# Sprint [N] Plan

**Sprint Number**: [N]
**Duration**: [Start date] to [End date] (2 weeks standard)
**Theme**: [One phrase describing the sprint's focus]
**Status**: [Planning / Active / Review / Complete]

---

## Sprint Goal

One or two sentences. What does the team/solo-dev want to accomplish this sprint?

---

## Context

What's happening in the project right now? Any relevant context from last sprint?

- Previous sprint outcome: [brief]
- Carryover items: [any]
- External factors: [deadlines, events]

---

## Committed Tasks

| ID | Task | Category | Estimate | Owner | Status |
|----|------|----------|----------|-------|--------|
| 1 | Design combat parry mechanic | Design | 6h | game-designer | To Do |
| 2 | Implement parry system | Code | 16h | luau-gameplay-programmer | To Do |
| 3 | Add parry VFX | Art | 4h | technical-artist | To Do |
| 4 | Parry sound effects | Audio | 2h | sound-designer | To Do |
| 5 | Test parry edge cases | QA | 4h | qa-tester | To Do |

**Total Committed**: [X hours]

---

## Stretch Goals

(Nice to have, pull in if time permits)

| ID | Task | Estimate |
|----|------|----------|
| S1 | Polish parry camera feedback | 2h |
| S2 | Add parry combo chains | 4h |

---

## Dependencies

- Task 2 blocked by Task 1 (design must finish first)
- Task 3 needs final design approval
- Parry remote requires remotes-networking-specialist review

---

## Risks

1. **Parry timing feels off**: Mitigation — extensive playtest, tunable timing
2. **Mobile FPS impact**: Mitigation — profile early, reserve 2h for optimization
3. **Exploit potential**: Mitigation — mandatory security review before merge

---

## Definition of Done

For this sprint to be considered complete:
- All committed tasks moved to Done
- All code passes `/code-review`
- All new features pass `/exploit-check`
- All new GDDs pass `/design-review`
- No S0/S1 bugs introduced
- Sprint demo-able to user

---

## Review Cadence

- Mid-sprint check: [date]
- End-of-sprint review: [date]
- Retrospective: [date]

---

## Sprint Retrospective

(Fill in at end of sprint)

### What Went Well
- [...]

### What Didn't Go Well
- [...]

### What to Try Next Sprint
- [...]

### Action Items
- [ ] [Action item with owner]
