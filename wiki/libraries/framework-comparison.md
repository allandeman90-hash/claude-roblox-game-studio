---
title: Framework Comparison
type: library
category: libraries
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/architecture/framework-comparison.md
  - wiki/raw/community/articles/library-readmes/knit-readme.md
  - wiki/raw/community/articles/library-readmes/flamework-readme.md
  - wiki/raw/community/articles/library-readmes/matter-ecs-readme.md
  - wiki/raw/community/articles/library-readmes/jecs-readme.md
  - wiki/raw/community/articles/library-readmes/nevermore-readme.md
related: [[[Knit]], [[Flamework]], [[Matter]], [[Jecs]], [[Nevermore]]]
tags: [library, framework, comparison, architecture, decision-guide]
---

# Framework Comparison

> Decision guide for choosing between Knit, Flamework, Matter, Jecs, and Nevermore in 2026.

## Overview

Every serious Roblox project picks one of five community foundations (or uses stock Roblox with no framework, which is viable for small projects). This page compares them across paradigm, language, status, and use case.

## Decision Table

| | [[Knit]] | [[Flamework]] | [[Matter]] | [[Jecs]] | [[Nevermore]] |
|---|---|---|---|---|---|
| **Paradigm** | Services / Controllers | DI Services / Components | ECS | ECS | Library pool |
| **Language** | Luau | TypeScript (roblox-ts) | Luau | Luau | Luau |
| **Status** | Archived (widely used) | Active | Active | Active | Active |
| **Package manager** | Wally | npm | Wally | Wally | npm |
| **Auto-networking** | Yes (Client table) | Yes (typed Events/Functions) | No | No | No (manual) |
| **Dependency injection** | String-keyed (`GetService`) | Constructor-injected (real DI) | N/A | N/A | `ServiceBag` optional |
| **Boot ordering** | Two-phase (KnitInit/KnitStart) | Decorator lifecycle (OnInit/OnStart) | Loop schedules systems | BYO scheduling | Loader resolves by name |
| **Visual debugger** | No | No | Yes (built-in) | No (opt-in modules) | No |
| **Entity relationships** | N/A | N/A | No | Yes (first-class pairs) | N/A |
| **Topological hooks** | No | No | Yes (useEvent, useThrottle) | No | No |
| **Type safety** | Luau annotations | Full TypeScript + compile-time | Luau annotations | Strict Luau | Luau annotations |
| **Learning curve** | Low | Medium (TS + decorators) | Medium (ECS concepts) | Medium-High (ECS + relationships) | Low (per-module) |
| **Community resources** | Abundant | Good | Good | Growing | Moderate |

## Paradigm Split

### Services / Controllers (Knit, Flamework)

The game is a collection of singletons that each own some domain concern (MoneyService, InventoryService, QuestService). They talk to each other and to clients via automatic remote layers. Natural fit for games that are mostly UI, state, and events -- shops, progression, social features, multiplayer matches.

**Strengths:** Reads like a normal backend service. Auto-networking removes boilerplate. Easy to reason about. Familiar to web developers.

**Weaknesses:** Does not scale as well to games with thousands of entities. Singleton access can become a dependency tangle without discipline.

### ECS (Matter, Jecs)

The game is a world of entities (just numbers); components are data; systems are functions that process components each frame. Natural fit for games with many similar things -- bullets, enemies, particles, simulation-heavy games.

**Strengths:** Fast at scale (archetype storage). Systems are pure functions (testable). Separates data from behavior. Matter has a live debugger.

**Weaknesses:** Unfamiliar mental model for beginners. UI and player state often do not fit naturally. More boilerplate for occasional behavior like shop purchases.

### Library Pool (Nevermore)

The game uses whatever structure the team wants, drawing from 270 well-built modules as needed. Maximally flexible, maximally un-prescriptive.

**Strengths:** No framework contract. Pick only what you need. Gradually adoptable.

**Weaknesses:** You must build your own structure. Less community tutorial coverage.

## Decision Tree

```
Are you writing TypeScript (roblox-ts)?
|-- Yes --> Flamework
|-- No -->
    Is the game entity-heavy (bullets, enemies, simulation)?
    |-- Yes --> Matter (easier) or Jecs (faster)
    |-- No -->
        Do you want a prescribed framework?
        |-- Yes --> Knit
        |-- No --> Nevermore (or no framework)
```

## Combining Frameworks

Frameworks pair with UI libraries -- these combinations are common and well-tested:

| Combination | Use case |
|-------------|----------|
| [[Knit]] + [[Fusion]] | Knit for game logic, Fusion for reactive UI. Most common pairing. |
| [[Flamework]] + [[Fusion]] | Same idea, TypeScript-flavored. |
| [[Matter]] + [[Fusion]] | Matter for simulation, Fusion for HUD/menu. |
| [[Knit]] + [[Matter]] | Knit for player/service logic, Matter for entity simulation. Legitimate hybrid. |

Mixing two service-style frameworks (Knit + Flamework) causes conflicts. But ECS + service-style is a legitimate pattern: ECS owns the simulation world, services own the player-facing concerns.

## The Knit-is-Archived Question

Knit's repo is archived and unmaintained. Practical assessment:

**Still viable:** Fully functional, battle-tested, abundant tutorials, small API surface, many shipped games.

**Risks:** No security fixes. No compatibility updates if Roblox APIs change. Future Luau improvements will not be leveraged. Community momentum has shifted.

**Verdict:** Reasonable for Luau-only projects wanting service/controller structure without TypeScript. For new TypeScript projects, Flamework is better. For new Luau projects, the community is shifting toward Matter (ECS) or Nevermore (library pool).

## The roblox-ts Question

If writing TypeScript for Roblox, the framework is almost certainly Flamework. The benefits (real DI, decorators, type-safe networking, compile-time metadata) are so well-integrated with roblox-ts that picking anything else means giving up significant ergonomics. Flamework is unavailable for Luau-only projects.

## Matter vs. Jecs

| Dimension | [[Matter]] | [[Jecs]] |
|-----------|--------|------|
| Raw throughput | Good | Excellent (800K entities at 60 FPS) |
| Entity relationships | Not supported | First-class pairs |
| Visual debugger | Built-in | Not included (opt-in modules) |
| Topological hooks | Yes (useEvent, useThrottle, useDeltaTime) | Not included |
| System scheduler | Built-in Loop | BYO (opt-in modules) |
| Learning curve | Slightly friendlier | Slightly steeper |
| Best for | General ECS with debug tooling | Max-throughput simulation with relationships |

Pick Matter for friendlier DX and a debugger. Pick Jecs for raw speed and entity relationships.

## Related

- [[Knit]]
- [[Flamework]]
- [[Matter]]
- [[Jecs]]
- [[Nevermore]]
- [[Fusion]] -- UI library that pairs with any framework

## Sources

- [Framework Comparison](wiki/raw/community/articles/architecture/framework-comparison.md)
- [Knit README](wiki/raw/community/articles/library-readmes/knit-readme.md)
- [Flamework README](wiki/raw/community/articles/library-readmes/flamework-readme.md)
- [Matter README](wiki/raw/community/articles/library-readmes/matter-ecs-readme.md)
- [Jecs README](wiki/raw/community/articles/library-readmes/jecs-readme.md)
- [Nevermore README](wiki/raw/community/articles/library-readmes/nevermore-readme.md)
