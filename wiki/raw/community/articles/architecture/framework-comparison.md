---
title: Roblox Framework Comparison — Knit, Flamework, Matter, Jecs, Nevermore
type: raw-source
source_url: https://github.com/Sleitnick/Knit
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: architecture
tags: [framework, knit, flamework, matter, jecs, nevermore, comparison]
---

# Roblox Framework Comparison — Knit, Flamework, Matter, Jecs, Nevermore

**Context:** Decision guide for picking a Roblox framework in 2026

## The five real options

Every serious Roblox project in 2026 is built on one of these five foundations (or on stock Roblox with no framework at all, which is a fine choice for small projects):

| Framework | Paradigm | Language | Status | Core idea |
|---|---|---|---|---|
| **Knit** | Services/Controllers | Luau | Archived but widely used | Singletons with auto-networking |
| **Flamework** | DI / Services / Components | TypeScript | Active | Decorated classes, compile-time DI |
| **Matter** | ECS | Luau | Active | Entities, components, systems with topological state |
| **Jecs** | ECS | Luau | Active | Archetype storage, relationships, max speed |
| **Nevermore** | Library pool | Luau | Active | 270 small modules + loader |

And at the "no framework" level:

- **Stock Roblox + Rojo + Wally** — fine for small games, no prescribed structure
- **Fusion** — reactive UI; pairs with any of the above, doesn't replace them

## Paradigm split: services/controllers vs ECS vs library-pool

The biggest choice is the paradigm:

### Services / Controllers (Knit, Flamework)

"Your game is a collection of singletons that each own some concern, and they talk to each other and to the client via automatic remote layers." Natural fit for games that are mostly UI, state, and events — shops, progression, social features, multiplayer matches.

Pros:
- Reads like a "normal" backend service
- Auto-networking removes RemoteEvent boilerplate
- Easy to reason about
- Familiar to web developers

Cons:
- Doesn't scale as well to games with thousands of entities
- Singleton access can become a dependency tangle without discipline

### ECS (Matter, Jecs)

"Your game is a world of entities, each just a number; components are data; systems are functions that process components." Natural fit for games with lots of similar things — bullets, enemies, particles, simulation-heavy games.

Pros:
- Very fast at scale (archetype storage is cache-friendly)
- Debuggable (Matter's visual debugger is excellent)
- Systems are pure functions, which makes testing easier
- Separates data from behavior cleanly

Cons:
- Mental model is unfamiliar for beginners
- UI and player state often don't fit naturally
- More boilerplate for "occasional behavior" like shop purchases

### Library pool (Nevermore)

"Your game is whatever structure you want, and here are 270 well-built modules you can use as you see fit." Maximally flexible, maximally un-prescriptive.

Pros:
- No framework contract to fight
- Pick only what you need
- Gradually adoptable in existing code

Cons:
- You have to build your own structure
- Less community tutorial coverage than Knit/Flamework

## The decision tree

```
Are you writing TypeScript (roblox-ts)?
├── Yes → Flamework
└── No → 
    Is your game entity-heavy (bullets, enemies, simulation)?
    ├── Yes → Matter (easier) or Jecs (faster)
    └── No →
        Do you want a prescribed framework?
        ├── Yes → Knit (still a good starting point)
        └── No → Nevermore (or no framework)
```

## Combining frameworks

You can combine a framework with a separate UI library:

- **Knit + Fusion** — very common. Knit handles game logic, Fusion handles UI state.
- **Flamework + Fusion** — same idea, TypeScript-flavored.
- **Matter + Fusion** — Matter for simulation, Fusion for HUD/menu.
- **Knit + Matter** — Knit for player/service logic, Matter for entity simulation.

Mixing two "frameworks" in the sense of two service/controller systems is usually a bad idea — Knit and Flamework would step on each other. But an ECS + service-style is a legitimate pattern: ECS owns the simulation world, services own the player-facing concerns.

## The Knit-is-archived question

Knit's repo is marked "archived — no longer maintained." Does this mean you shouldn't use it?

**Arguments for using Knit anyway:**
- It's fully functional and battle-tested
- Community resources are abundant
- The API surface is small enough that "maintenance" is not a frequent need
- Many shipped games are built on it

**Arguments against:**
- No security fixes coming
- No compatibility updates if Roblox APIs change
- Future Luau improvements won't be leveraged
- Community momentum has shifted to Flamework for TS projects and to Matter for ECS

**Practical verdict:** Knit is still a reasonable pick for Luau-only projects that want a service/controller framework and don't need TypeScript. For new TS projects, Flamework is better. For new Luau projects without strong existing commitments, the community is shifting toward Matter as the default ECS or Nevermore as the default library pool.

## The roblox-ts question

If you're writing TypeScript for Roblox via roblox-ts, your framework is almost certainly Flamework. The benefits are:

- Real DI (not string-keyed lookups)
- Decorator-based registration
- Type-safe networking at compile time
- Compile-time metadata via transformer

Flamework is so well-integrated with roblox-ts that picking anything else means giving up significant ergonomics. For Luau-only projects, Flamework is unavailable — you need TypeScript to use it.

## What about custom frameworks?

Every studio of more than ~3 people eventually writes its own internal framework. This is fine when:
- You have very specific needs no community framework addresses
- You have enough engineering effort to maintain it
- You're prepared to onboard new hires to your specific patterns

It's usually a bad idea when:
- The project is small
- You're solo
- You're reinventing Knit badly

The modern ecosystem is rich enough that most custom frameworks are just Knit with different naming.

## Sources

- https://github.com/Sleitnick/Knit
- https://github.com/rbxts-flamework/core
- https://github.com/matter-ecs/matter
- https://github.com/Ukendio/jecs
- https://github.com/Quenty/NevermoreEngine
Captured: 2026-04-15
