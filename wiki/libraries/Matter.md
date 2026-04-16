---
title: Matter
type: library
category: libraries
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/matter-ecs-readme.md
  - wiki/raw/community/devforum/all-about-entity-component-system.md
  - wiki/raw/community/articles/architecture/framework-comparison.md
related: [[[Jecs]], [[Knit]], [[framework-comparison]]]
tags: [library, framework, ecs, entity-component-system]
---

# Matter

> Modern ECS library for Roblox with archetypical storage, automatic system scheduling, topologically-aware hooks, and a built-in visual debugger.

## Summary

Matter is an Entity-Component-System library originally created by evaera and now maintained by the matter-ecs GitHub organization. It provides fast archetypical entity storage, declarative system scheduling via a Loop object, and React-style topological hooks (`useEvent`, `useThrottle`, `useDeltaTime`) that store state indexed by call location. Matter ships with a visual debugger for inspecting entities, component state, and system frame times at runtime.

**Maintainer:** matter-ecs organization (originally evaera)
**Status:** Active
**License:** MIT

## Installation

### Wally

```toml
[dependencies]
Matter = "matter-ecs/matter@0.8.4"
```

Migration note: users who previously depended on `evaera/matter` can update to `matter-ecs/matter` with a namespace change only -- no API change.

## Quick Start

```lua
local Matter = require(ReplicatedStorage.Packages.Matter)
local RunService = game:GetService("RunService")

-- Define components
local Health = Matter.component("Health", { current = 0, max = 100 })
local Position = Matter.component("Position", { x = 0, y = 0, z = 0 })
local Velocity = Matter.component("Velocity", { x = 0, y = 0, z = 0 })

-- Create world
local world = Matter.World.new()

-- Spawn an entity
local id = world:spawn(
    Position({ x = 0, y = 10, z = 0 }),
    Velocity({ x = 1, y = 0, z = 0 }),
    Health({ current = 100, max = 100 })
)

-- Define a system
local function moveSystem(world)
    for id, position, velocity in world:query(Position, Velocity) do
        world:insert(id, Position({
            x = position.x + velocity.x,
            y = position.y + velocity.y,
            z = position.z + velocity.z,
        }))
    end
end

-- Schedule and run
local loop = Matter.Loop.new(world)
loop:scheduleSystems({ moveSystem })
loop:begin({ default = RunService.Heartbeat })
```

## Key API

| Symbol | Description |
|--------|-------------|
| `Matter.component(name, defaults)` | Defines a component type with default values. |
| `Matter.World.new()` | Creates the central entity/component container. |
| `world:spawn(...)` | Creates an entity with initial components. Returns entity ID. |
| `world:insert(id, component)` | Attaches or replaces a component on an entity. |
| `world:remove(id, Component)` | Strips a component from an entity. |
| `world:despawn(id)` | Destroys an entity and all its components. |
| `world:get(id, Component)` | Looks up a single component on an entity. |
| `world:query(C1, C2, ...)` | Iterates all entities possessing all listed components. Cache-friendly archetype iteration. |
| `Matter.Loop.new(world)` | Creates a system scheduler. |
| `loop:scheduleSystems(systems)` | Registers systems. Order configurable with `priority` and `after`. |
| `Matter.useEvent(id, event)` | Topological hook: collects events within a system without manual connect/disconnect. |
| `Matter.useThrottle(seconds)` | Topological hook: returns true once per interval at the call site. |
| `Matter.useDeltaTime()` | Topological hook: time since this system last ran. |
| `Matter.Debugger.new()` | Enables the built-in visual debugger. |

## When to Use / When Not to Use

**Use when:**
- Many entities of similar structure (bullets, enemies, particles)
- System-level testability matters (systems are pure functions)
- You want a live visual debugger out of the box
- Gradual adoption alongside existing Instance-based code

**Do not use when:**
- The game is essentially UI + a few singletons ([[Knit]] or [[Fusion]] is simpler)
- You need maximum raw throughput and entity relationships ([[Jecs]] is faster)
- The team is unfamiliar with ECS and the project is small

## Alternatives

| Library | Trade-off |
|---------|-----------|
| [[Jecs]] | Faster raw throughput, first-class entity relationships, but no built-in debugger or hooks. |
| [[Knit]] | Service/controller paradigm. Simpler for event-driven games, worse for entity-heavy simulation. |
| [[Flamework]] | TypeScript service/controller framework. Different paradigm entirely. |

## Related

- [[Jecs]] -- faster ECS alternative
- [[Knit]] -- service/controller alternative
- [[framework-comparison]] -- decision guide

## Sources

- [Matter README](wiki/raw/community/articles/library-readmes/matter-ecs-readme.md)
- [DevForum: All about Entity Component System](wiki/raw/community/devforum/all-about-entity-component-system.md)
- [Framework Comparison](wiki/raw/community/articles/architecture/framework-comparison.md)
- GitHub: https://github.com/matter-ecs/matter
- Docs: https://matter-ecs.github.io/matter/docs/intro/
