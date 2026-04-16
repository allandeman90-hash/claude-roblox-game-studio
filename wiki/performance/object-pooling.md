---
title: Object Pooling
type: performance
category: performance
subcategory: patterns
owner: performance-analyst
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/patterns/object-pooling.md
  - wiki/raw/community/performance/rendering/optimization-guide-draw-calls.md
related:
  - "[[draw-call-optimization]]"
  - "[[heartbeat-budget]]"
  - "[[connection-leaks]]"
  - "[[bulk-move-to]]"
tags: [performance, patterns, pooling, gc]
---

# Object Pooling

## Summary

Object pooling reuses Instances (Parts, Sounds, particle emitters, UI elements) instead of creating and destroying them. This eliminates allocation cost, GC pressure, network replication of new instances, physics simulation setup, and ancestor tree mutation. Any scenario requiring frequent instance creation/destruction benefits.

## Measurements / Budgets

Pooling is a qualitative optimization -- the savings depend on creation frequency:

| Cost Eliminated | Notes |
|----------------|-------|
| Memory allocation | No new allocation per reuse; eliminates GC pressure |
| Network replication | Server-side Instance.new replicates to all clients; pooled instances do not |
| Physics setup | New parts must enter the physics simulation; pooled parts are already registered |
| Property initialization | Avoided on reuse (but reset on acquire is still needed) |
| Ancestor tree mutation | Reparenting triggers internal bookkeeping; pooled parts skip this |

Source: [object-pooling.md](../raw/community/performance/patterns/object-pooling.md)

## How to Measure

- **Developer Console (F9)** > Memory tab: watch LuauHeap and Instances categories. A sawtooth pattern (allocate/GC/allocate) indicates heavy churn that pooling can smooth out.
- **MicroProfiler**: look for `gc` or `GC` labels consuming significant frame time.
- **InstanceCount**: track `game:GetService("Stats").InstanceCount` over time. A steadily growing count signals leaked instances, not a pooling candidate.

## Common Issues

### Without Pooling

- **Bullet hell games** creating thousands of projectile parts per second cause GC spikes every few seconds.
- **Tower defense** damage numbers: each `TextLabel` clone/destroy cycle chews through memory.
- **Rain/snow** particle systems using individual parts (instead of ParticleEmitters) allocate and destroy at unsustainable rates.

### With Pooling (Done Wrong)

- **Forgetting to reset state** on acquire leads to bugs (old color, velocity, CFrame leaking into the next use).
- **Unbounded pool growth** where released objects accumulate without a max cap wastes memory.
- **Double-release** where the same object is returned to the pool twice causes corruption.

Source: [object-pooling.md](../raw/community/performance/patterns/object-pooling.md)

## Optimization Patterns

### Basic Pool

```lua
local SIZE = 1000
local Template = script.Bullet
local Pool = table.create(SIZE)

-- Prewarm
for i = 1, SIZE do
    Pool[i] = Template:Clone()
end

local function acquire(): Part
    local obj = table.remove(Pool)
    if not obj then
        obj = Template:Clone() -- pool exhausted, create new
    end
    return obj
end

local function release(obj: Part)
    obj.Parent = nil
    table.insert(Pool, obj)
end
```

### PartCache Technique (Higher Performance)

Instead of setting `Parent = nil` on release, keep all parts parented to a container and move released parts far underground. This avoids reparenting overhead:

```lua
local UNDERGROUND = CFrame.new(0, -5000, 0)
local Container = Instance.new("Folder")
Container.Name = "BulletPool"
Container.Parent = workspace

local function release(obj: Part)
    obj.CFrame = UNDERGROUND
    -- stays parented to Container; physics skips based on position
    table.insert(Pool, obj)
end

local function acquire(): Part
    local obj = table.remove(Pool)
    if not obj then
        obj = Template:Clone()
        obj.Parent = Container
    end
    return obj
end
```

Source: [object-pooling.md](../raw/community/performance/patterns/object-pooling.md)

### When to Pool

| Scenario | Pool? |
|----------|-------|
| Projectiles (bullets, arrows) | Yes |
| Damage numbers / floating text | Yes |
| Reusable UI rows (scroll list) | Yes |
| Short-lived SFX Sounds | Yes (or use SoundGroup) |
| ParticleEmitter bursts | Yes (disable/enable, not destroy) |
| Singleton NPCs | No -- just respawn |
| Static map geometry | No -- never destroyed |

### Best Practices

1. **Pre-allocate** with `table.create(N)` to avoid table resizing.
2. **Reset on acquire**: clear CFrame, velocity, color, and any modified properties.
3. **Set a max pool size** to prevent unbounded growth.
4. **One pool per type**: different templates need different pools.
5. **Handle exhaustion**: either create a new instance or drop the request.

## Pitfalls

- **Pooling trivial objects** (empty tables, small value types) where the overhead of pool management exceeds the savings is counterproductive.
- **Holding pooled objects in multiple collections** (e.g., active list AND pool simultaneously) is the pool equivalent of a double-free.
- **Not pooling on the server** is a missed opportunity. Server-side `Instance.new` + `:Destroy()` cycles replicate to every client.
- **`.Touched` listeners on pooled parts** persist across reuses. Disconnect or use a single persistent connection that checks state.

## Related

- [[draw-call-optimization]]
- [[heartbeat-budget]]
- [[connection-leaks]]
- [[bulk-move-to]]

## Sources

- [object-pooling.md](../raw/community/performance/patterns/object-pooling.md)
- [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)
