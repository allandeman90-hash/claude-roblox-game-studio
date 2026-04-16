---
title: Matter — Modern ECS Library for Roblox
type: raw-source
source_url: https://github.com/matter-ecs/matter
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: framework
author: evaera (original); matter-ecs organization (current)
tags: [ecs, entity-component-system, matter, debugger, topological]
---

# Matter — Modern ECS Library for Roblox

**Authors:** originally @evaera, now maintained by the matter-ecs GitHub organization
**Source:** GitHub — `matter-ecs/matter`
**License:** MIT

## What it is

Matter is a modern Entity-Component-System library for Roblox. It is described by its authors as featuring:

- A standard, no-frills ECS implementation
- Fast, archetypical entity storage
- Automatic system scheduling
- A slick API featuring topologically-aware state

Matter empowers developers to build games that are extensible, performant, and easy to debug. It ships with a visual debugger that lets you inspect entities, component state, and system timing at runtime.

## Installation

Add to `wally.toml`:

```toml
[dependencies]
Matter = "matter-ecs/matter@0.8.4"
```

**Migration note from the README:** Users who previously depended on `evaera/matter` can update to `matter-ecs/matter` with a simple namespace change — no API change.

## Core concepts

### Entity

An entity represents something in your game — it might be a player character, an enemy, or a tree. Conceptually there is "generally one entity per thing you want to represent." Technically, an entity is just a number — a unique ID. All the data associated with an entity lives in components attached to it.

### Component

Components are pieces of data attached to entities. Because entities are just numbers, *all* information about an entity is stored in its components. Components in Matter are defined with `Matter.component("Name")`:

```lua
local Matter = require(ReplicatedStorage.Packages.Matter)

local Health = Matter.component("Health", { current = 0, max = 100 })
local Position = Matter.component("Position", { x = 0, y = 0, z = 0 })
local Velocity = Matter.component("Velocity", { x = 0, y = 0, z = 0 })
```

The second argument is a default table — any field you do not provide when constructing the component inherits the default.

### World

The World is the central container for all entities and components. Typically only one World exists per game. Its key methods:

- `world:spawn(...)` — create a new entity with a set of starting components
- `world:insert(id, component)` — attach or replace a component on an entity
- `world:remove(id, Component)` — strip a component from an entity
- `world:despawn(id)` — destroy an entity and all its components
- `world:get(id, Component)` — look up a single component
- `world:query(C1, C2, ...)` — iterate all entities that have all listed components

### System

A system is just a function that runs every frame in a specific order alongside your other systems, typically doing one job using a specific set of components. Example:

```lua
local function moveSystem(world)
    for id, position, velocity in world:query(Position, Velocity) do
        world:insert(id, Position({
            x = position.x + velocity.x,
            y = position.y + velocity.y,
            z = position.z + velocity.z,
        }))
    end
end

return moveSystem
```

Note: components in Matter are **immutable**. To change a value you construct a new component instance and `world:insert` it back, which is both more cache-friendly and makes change tracking trivial.

### Loop and system scheduling

The `Loop` object schedules systems. You add systems to a loop and tell it which RunService events to fire from (`Heartbeat`, `Stepped`, `RenderStepped`). The loop automatically handles ordering, error isolation, and performance tracking for each system:

```lua
local Loop = Matter.Loop.new(world)
Loop:scheduleSystems({moveSystem, healthSystem, renderSystem})
Loop:begin({
    default = RunService.Heartbeat,
    render = RunService.RenderStepped,
})
```

System order can be configured with `priority` and `after` fields on the system table, so dependencies are declarative, not positional.

### Topologically-aware state (`useHookState`)

Matter's most unusual feature is React-style hooks that store state indexed by call location (file + line number). Examples:

- `Matter.useEvent(id, event)` — collects fired events within a system without manually connecting and disconnecting
- `Matter.useThrottle(seconds)` — returns true once per interval at the call site
- `Matter.useDeltaTime()` — time since this system last ran

Because state is keyed by call location, you can call these from inside a query loop and each entity/call gets its own independent state without passing around keys. This is the trick that makes Matter systems read like plain imperative code even when they're highly stateful.

## Debugger

Matter ships with a built-in visual debugger (enabled with `Matter.Debugger.new()`) that can:

- List all systems and their frame times
- Show all entities and their components live
- Let you toggle systems off/on
- Highlight query results graphically

This is invaluable for finding systems that are silently blowing frame budgets or entities with unexpected component combinations.

## Why archetype storage matters

Matter uses archetypical / SoA (struct-of-arrays) storage — entities that share the same component set are stored together contiguously. This means `world:query(A, B)` iterates a tight cache-friendly range of memory rather than chasing pointers. For games with hundreds of entities this is a significant perf difference versus naive per-entity hash-map storage.

## Good fit vs. not a fit

Matter shines when:
- You have many entities of similar structure (bullets, enemies, particles)
- You want system-level testability
- You need a live debugger
- You want gradual adoption (Matter can coexist with Instance-based code)

Matter is less obvious when:
- Your game is essentially UI + a few singletons (Knit/Fusion is simpler)
- You need every last nanosecond (Jecs is faster still)

## Source

Original URL: https://github.com/matter-ecs/matter
Documentation: https://matter-ecs.github.io/matter/docs/intro/
Core concepts: https://matter-ecs.github.io/matter/docs/Concepts/
Captured: 2026-04-15
