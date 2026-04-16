---
title: Object Pooling Pattern
type: raw-source
source_url: https://devforum.roblox.com/t/part-pooling-increase-performance-with-many-parts/518433
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: patterns
tags: [object-pooling, part-pooling, memory, gc, pattern]
---

# Object Pooling Pattern

## Core Concept

Object pooling is a performance optimization technique where objects (Parts, GUIs, particles, etc.) are created once and reused rather than destroyed and recreated.

"Parts aren't actually removed in a pooling system, they are put back in the 'queue' until the next time they need to be used."

## Why It Matters

Creating and destroying instances in Roblox is relatively expensive:
- Memory allocation (GC pressure)
- Network replication (if server-side)
- Physics simulation setup
- Property initialization
- Ancestor tree mutation

Pooling eliminates all of this for subsequent reuses.

## Primary Use Cases

- **Bullet hell games**: high-quantity projectiles
- **Real-time terrain systems**: dynamic parts
- **Particle systems**: many short-lived effects
- **Tower Defense**: damage numbers, projectiles
- **UI lists**: scrolling lists with reusable row templates

Any scenario requiring frequent instance creation/destruction.

## Basic Pattern

```lua
local SIZE = 1000
local Template = script.Bullet
local Pool = table.create(SIZE)

-- Prewarm the pool
for i = 1, SIZE do
    Pool[i] = Template:Clone()
end

-- Acquire an object
local function acquire()
    local obj = table.remove(Pool)
    if not obj then
        obj = Template:Clone()
    end
    return obj
end

-- Release an object
local function release(obj)
    obj.Parent = nil
    table.insert(Pool, obj)
end
```

## PartCache Technique

An alternative technique reported to outperform parent-based pooling:
- Keep all parts parented to the pool container
- Move released parts far underground (e.g., Y = -5000)
- Move acquired parts to their actual position via CFrame
- Avoids re-parenting overhead and lets physics pipeline skip parts based on position

## Performance Benefits

"Games that use pooling can use many objects because they do not suffer from performance loss created from instancing or destroying."

## Best Practices

1. **Size appropriately**: Use `table.create(N)` to pre-allocate the pool array
2. **Reset on acquire**: Clear previous state (CFrame, velocity, color, etc.)
3. **Parent: nil pattern** or **CFrame underground pattern** for "released" objects
4. **Handle pool exhaustion**: Create new instances when pool is empty, or drop the request
5. **Consider a max size**: Don't let the pool grow unbounded
6. **Pool per-type**: Different templates need different pools

## Anti-patterns

- Pooling without resetting state (leads to bugs)
- Pooling tiny objects (blank tables) where the overhead exceeds the savings
- Holding pooled objects in multiple places (double-free equivalent)

## Source

Original URL: https://devforum.roblox.com/t/part-pooling-increase-performance-with-many-parts/518433
Captured: 2026-04-16
