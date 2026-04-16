---
title: Jecs
type: library
category: libraries
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/jecs-readme.md
  - wiki/raw/community/devforum/jecs-ecs-library.md
  - wiki/raw/community/articles/architecture/framework-comparison.md
related: [[[Matter]], [[framework-comparison]]]
tags: [library, framework, ecs, performance, archetype]
---

# Jecs

> High-performance ECS for Luau with archetype/SoA storage, first-class entity relationships, and 800,000-entity throughput at 60 FPS.

## Summary

Jecs is a pure-Luau Entity Component System library by Ukendio, designed for maximum raw throughput. Named as a nod to Flecs (the C ECS library by Sander Mertens), jecs brings the archetype + relationships pattern to the Roblox ecosystem. Its distinguishing feature is **first-class entity relationships** -- pairs like `(ChildOf, parentId)` stored at the archetype level, eliminating the need for manual parent-ID components and hand-traversal.

**Maintainer:** Ukendio
**Status:** Active
**License:** MIT

## Installation

### Wally

```toml
[dependencies]
Jecs = "ukendio/jecs@latest"
```

Also available as an importable Roblox Studio model file from GitHub releases.

## Quick Start

```lua
local jecs = require(ReplicatedStorage.Packages.jecs)
local world = jecs.World.new()

-- Define components
local Position = world:component() :: jecs.Id<Vector3>
local Velocity = world:component() :: jecs.Id<Vector3>
local ChildOf = world:component()

-- Spawn entities
local parent = world:entity()
world:set(parent, Position, Vector3.new(0, 10, 0))

local child = world:entity()
world:set(child, Position, Vector3.new(0, 0, 0))
world:set(child, Velocity, Vector3.new(1, 0, 0))
world:add(child, jecs.pair(ChildOf, parent))

-- Query with relationships
for entity in world:query(jecs.pair(ChildOf, parent)) do
    -- iterate all children of parent
end

-- Standard movement query
for id, pos, vel in world:query(Position, Velocity) do
    world:set(id, Position, pos + vel)
end
```

## Key API

| Symbol | Description |
|--------|-------------|
| `jecs.World.new()` | Creates the entity/component world. |
| `world:component()` | Defines a new component type. Returns a component ID. |
| `world:entity()` | Creates a new entity. Returns entity ID. |
| `world:set(id, Component, value)` | Sets a component value on an entity. |
| `world:get(id, Component)` | Reads a component value from an entity. |
| `world:add(id, Component)` | Adds a tag component (no data) to an entity. |
| `world:remove(id, Component)` | Strips a component from an entity. |
| `world:delete(id)` | Destroys an entity. |
| `world:query(C1, C2, ...)` | Iterates entities with all listed components. Column-major iteration for cache efficiency. |
| `jecs.pair(Relation, Target)` | Creates a relationship pair. Participates in queries like regular components. |

## Entity Relationships

The relationship system is jecs's most distinctive feature. In most ECS libraries, modeling "entity A is owned by entity B" requires adding an `Owner = { id = B }` component and hand-traversing. In jecs, relationships are first-class:

```lua
local ChildOf = world:component()
local Likes = world:component()

-- Structural relationship
world:add(child, jecs.pair(ChildOf, parent))

-- Data-carrying relationship
world:set(entity, jecs.pair(Likes, apple), 10) -- score of 10

-- Query all children of a specific parent
for child in world:query(jecs.pair(ChildOf, parent)) do
    -- ...
end
```

Under the hood, a pair is a stable 64-bit ID indexing into the same archetype machinery as regular components. No other community ECS on Roblox exposes relationships at the storage level.

## When to Use / When Not to Use

**Use when:**
- Simulation-heavy games with thousands of entities (bullets, particles, enemies)
- Entity relationships matter (inventory trees, ownership graphs, scene hierarchies)
- Maximum throughput is critical
- You want a small core and will build your own scheduling

**Do not use when:**
- You want batteries-included features like a visual debugger and topological hooks (use [[Matter]])
- The game is mostly UI and singletons (use [[Knit]] or [[Flamework]])
- The team is new to ECS concepts

## Alternatives

| Library | Trade-off |
|---------|-----------|
| [[Matter]] | Friendlier API, built-in debugger and hooks, but slower raw throughput and no relationship pairs. |
| [[Knit]] / [[Flamework]] | Service/controller paradigm. Simpler for non-entity games. |

## Related

- [[Matter]] -- friendlier ECS with debugger
- [[framework-comparison]] -- decision guide

## Sources

- [Jecs README](wiki/raw/community/articles/library-readmes/jecs-readme.md)
- [DevForum: Jecs - Optimizing declarative scene graphs with ECS](wiki/raw/community/devforum/jecs-ecs-library.md)
- [Framework Comparison](wiki/raw/community/articles/architecture/framework-comparison.md)
- GitHub: https://github.com/Ukendio/jecs
