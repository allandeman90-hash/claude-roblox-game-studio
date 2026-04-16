---
title: jecs — Stupidly Fast Entity Component System for Luau
type: raw-source
source_url: https://github.com/Ukendio/jecs
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: framework
author: Ukendio
tags: [ecs, jecs, performance, luau, archetype]
---

# jecs — Stupidly Fast Entity Component System for Luau

**Author:** Ukendio
**Source:** GitHub — `Ukendio/jecs`
**License:** MIT

## What it is

jecs is a high-performance Entity Component System library for Luau, designed to be the fastest pure-Luau ECS available. It positions itself alongside Matter in the ECS space but explicitly targets raw throughput as its headline feature.

## Core features (from the README)

- **Zero-dependency Luau.** jecs is a single, pure-Luau library with no external dependencies — no roblox-ts, no Wally transitive baggage.
- **Type-safe Luau API.** The entire API is written and published with strict Luau type annotations, so autocomplete and type errors flow through to client code.
- **Entity relationships as first-class citizens.** Unlike most ECS libraries where relationships between entities are modeled indirectly (via parent-id fields in components), jecs supports pairs like `(ChildOf, parentId)` at the storage level. This is modeled after Flecs in C.
- **Archetype / SoA storage.** Entities with the same component set are stored column-major, making queries cache-friendly.
- **Rigorously unit tested.** The repo runs a comprehensive test suite.

## Performance claim

The README advertises "800,000 entities at 60 frames per second" based on bench runs in the `bench/` directory. The bench is reproducible and pitted against both naive table-based ECS implementations and Matter.

The key performance levers:
1. **Archetype storage** — queries hit contiguous memory
2. **Minimal abstraction overhead** — no component metatables or lazy wrappers
3. **Relationship pairs** — parent/child traversal does not require manual component lookups
4. **Column iteration** — the query iterator yields raw column pointers rather than constructing component tables per entity

## Entity relationships

The relationship feature is the most distinctive. In most ECS libraries, to model "this entity is owned by that entity" you add a `Owner = { id = otherEntity }` component and hand-traverse. In jecs you model it as a pair:

```lua
local ChildOf = world:component()

-- Parent entity
local parent = world:entity()
local child = world:entity()

world:add(child, pair(ChildOf, parent))

-- Query all children of `parent`
for child in world:query(pair(ChildOf, parent)) do
    -- ...
end
```

Pairs can carry data too (`pair(Likes, fruit)` with a score), and they participate in queries just like components. Under the hood, a pair is a stable 64-bit ID that indexes into the same archetype machinery as regular components.

This is genuinely novel on Roblox — no other community ECS exposes relationships at the storage level.

## Getting started resources

From the repo:

- **`how_to/`** — step-by-step walkthrough that explains the design rationale (why archetypes, why pairs, why no system scheduler).
- **`modules/`** — pre-built utilities (scheduler, observers) that some users want but are kept out of core for leanness.
- **`examples/`** — real-world use-case demos (particle systems, AI group behavior).

Documentation ships both as the GitHub repo and as an importable Roblox Studio model file for developers who prefer Studio-native workflows.

## Why it's called "jecs"

A nod to Flecs (the C ECS library by Sander Mertens that pioneered the archetype + relationships pattern). The "j" is a tip of the hat to Luau — "Just ECS" in the Luau world.

## Philosophy: no scheduler, no hooks

Unlike Matter, jecs core has no built-in Loop/scheduler and no topological hook state (`useEvent`, `useThrottle`). The README explicitly keeps the core small so teams can bring their own scheduling. If you want that functionality, the `modules/` directory has opt-in pieces, or you can integrate with the Roblox `RunService` yourself.

This is a deliberate trade-off: Matter is "batteries included," jecs is "a very fast core plus optional modules."

## When to pick jecs over Matter

- **Simulation-heavy games** (thousands of bullets, particles, enemies) where every nanosecond counts
- **Games that need entity relationships** (inventory trees, ownership graphs)
- **Teams that want smaller core** and will write their own scheduling

Matter is still the easier choice if you want:
- A built-in visual debugger out of the box
- Topological hooks that read like React
- A slightly friendlier learning curve

## Source

Original URL: https://github.com/Ukendio/jecs
Captured: 2026-04-15
