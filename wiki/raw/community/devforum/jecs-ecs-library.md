---
title: Jecs - Optimizing declarative scene graphs with ECS
type: raw-source
source_url: https://devforum.roblox.com/t/jecs-optimizing-declarative-scene-graphs-with-ecs/3263203
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: Ukendio (Marcus)
post_date: 2024-11-17
tags: [ecs, jecs, performance, game-framework, archetype, community-resource]
---

# Jecs - Optimizing Declarative Scene Graphs with ECS

**Author:** Ukendio (Marcus)
**Posted:** November 17, 2024
**License:** Apache 2.0

## Overview

Jecs is a high-performance Entity Component System (ECS) implementation for Roblox, designed to optimize declarative scene graphs. According to the creator, it can "iterate 800,000 entities at 60 frames per second."

## Core Features

- **Entity Relationships:** First-class support for hierarchies, physics joints, and scene graphs
- **Type-safe Luau API** with zero dependencies
- **Column-major storage:** Archetype / Structure of Arrays (SoA) pattern
- **Cache-friendly performance:** Optimized memory access patterns
- **Unit tested:** Rigorous stability testing via CI/CD

## Quick API Example

```lua
local jecs = require("@jecs")
local world = jecs.World.new()

-- Define components
local Position = world:component() :: jecs.Id<Vector3>
local Velocity = world:component() :: jecs.Id<Vector3>

-- Create entity and set components
local entity = world:entity()
world:set(entity, Position, Vector3.new(1))
world:set(entity, Velocity, {x = 1, y = 2})

-- Query and iterate
for e, pos, vel in world:query(Position, Velocity) do
    pos += vel * dt
    world:set(e, Position, pos)
end
```

## Core ECS Concepts

An ECS architecture comprises:
- **Entities:** Unique identifiers
- **Components:** Plain data types without behavior
- **Systems:** Functions matching entities with specific component sets

## Performance Insights

The framework emphasizes that memory access patterns remain crucial even in pointer-based languages. Linear memory access significantly outperforms random access—sometimes "nearly an order of magnitude faster." Cache locality benefits arise from contiguous pointer storage, even when underlying objects remain heap-allocated.

## Key Design Philosophy

The creator notes that organizational benefits often outweigh raw performance gains. Rather than treating ECS as a universal solution, developers should profile their specific use cases and leverage ECS for bulk entity processing and dynamic component composition—not complex tree structures or spatial indexing, where specialized solutions prove superior.

## Source

Original URL: https://devforum.roblox.com/t/jecs-optimizing-declarative-scene-graphs-with-ecs/3263203
Captured: 2026-04-16
