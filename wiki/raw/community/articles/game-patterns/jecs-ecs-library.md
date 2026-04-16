---
title: "Jecs: Fast Entity Component System for Luau"
type: raw-source
source_url: https://devforum.roblox.com/t/jecs-optimizing-declarative-scene-graphs-with-ecs/3263203
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, ECS, entity-component-system, Jecs, archetype, performance]
---

# Jecs: Entity Component System for Roblox

## Overview

Jecs is a high-performance ECS library for Roblox. Iterates 800,000 entities at 60 fps. Apache 2.0 license, available via Wally.

### Key Features

- Entity Relationships as first-class citizens
- Type-safe Luau API with zero dependencies
- Column-major (archetype/SoA) storage architecture
- Cache-friendly operations optimized for bulk processing

## API Fundamentals

### Component Creation

```lua
local jecs = require("@jecs")
local world = jecs.World.new()

local Position = world:component() :: jecs.Id<Vector3>
local Velocity = world:component() :: jecs.Id<Vector3>
```

### Entity Creation

```lua
local entity = world:entity()
world:set(entity, Position, Vector3.new(1))
world:set(entity, Velocity, {x = 1, y = 2})
```

### Querying

```lua
local function move(dt)
    for e, pos, vel in world:query(Position, Velocity) do
        pos += vel * dt
        world:set(e, Position, pos)
    end
end
```

## Entity Relationships

Relationships enable hierarchical structures with ergonomic querying, enforced correctness invariants, and cache-friendly iteration.

```lua
local pair = jecs.pair
local ChildOf = world:entity()
local Name = world:component() :: jecs.Id<string>

local sun = world:entity()
world:set(sun, Name, "Sun")
world:set(sun, Position, Vector3.one)

local earth = world:entity()
world:set(earth, Name, "Earth")
world:add(earth, pair(ChildOf, sun))
world:set(earth, Position, Vector3.one * 3)

local moon = world:entity()
world:set(moon, Name, "Moon")
world:add(moon, pair(ChildOf, earth))
world:set(moon, Position, Vector3.one * 0.1)
```

### Targeted Queries

```lua
world:query(HitRequest, pair(ChildOf, $target))
```

## Performance Architecture

Linear memory access significantly outperforms random access -- nearly an order of magnitude faster. ECS benefits from:
- Tables created in bulk positioned closer together
- Contiguous pointer storage enabling efficient CPU prefetching
- Predictable iteration patterns reducing cache misses
- Reduced branching logic through bulk component matching

### Benchmarks

- Query: tested with 21,000 entities across 125 archetypes
- Insertion: 8 components inserted and updated 50 times
- 415 GitHub stars, 70 forks, 56 releases (v0.11.0)

## Design Philosophy

"When in doubt you should make entities because they are dirt cheap." This includes spatial sound effects, custom rigging systems, and accessory handling.

## Limitations

- Less efficient for complex data structures (binary trees, spatial indexing)
- Entity relationship overuse may increase query fragmentation
- Not a universal performance solution

## Source
Original URL: https://devforum.roblox.com/t/jecs-optimizing-declarative-scene-graphs-with-ecs/3263203
