---
title: BulkMoveTo
type: performance
category: performance
subcategory: patterns
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/patterns/bulkmoveto-performance.md
  - wiki/raw/community/performance/rendering/optimization-guide-draw-calls.md
related:
  - "[[heartbeat-budget]]"
  - "[[object-pooling]]"
  - "[[physics-budget]]"
tags: [performance, patterns, cframe, movement]
---

# BulkMoveTo

## Summary

`Workspace:BulkMoveTo()` batches multiple part CFrame updates into a single native C++ call, bypassing per-call Lua-to-C++ boundary overhead. It becomes faster than individual CFrame assignments at approximately **30 parts** and the advantage grows with part count.

## Measurements / Budgets

| Metric | Value | Source |
|--------|-------|--------|
| **Threshold for BulkMoveTo win** | **~30 parts** | [bulkmoveto-performance.md](../raw/community/performance/patterns/bulkmoveto-performance.md) |
| Gain at 50 parts | ~9% faster | [bulkmoveto-performance.md](../raw/community/performance/patterns/bulkmoveto-performance.md) |
| Time per 50 parts (BulkMoveTo) | 0.0000058 s | [bulkmoveto-performance.md](../raw/community/performance/patterns/bulkmoveto-performance.md) |
| Time per 50 parts (individual) | 0.0000064 s | [bulkmoveto-performance.md](../raw/community/performance/patterns/bulkmoveto-performance.md) |

### When to Use

| Part Count | Recommendation |
|------------|----------------|
| 1-29 parts | Individual CFrame assignments |
| 30+ parts | BulkMoveTo |
| 100+ parts | BulkMoveTo strongly recommended |
| 1000+ parts | BulkMoveTo essential |

Source: [bulkmoveto-performance.md](../raw/community/performance/patterns/bulkmoveto-performance.md)

## How to Measure

- Benchmark with `os.clock()` before and after the move operation.
- Use **MicroProfiler** custom labels to compare frame time with individual CFrame vs BulkMoveTo.
- The crossover point may vary between 30-50 parts depending on the specific workload. Test with your actual part count.

## Common Issues

### Using Individual CFrame for Large Sets

Setting `part.CFrame = newCFrame` in a loop for hundreds of parts incurs Lua-to-C++ boundary overhead on every iteration. This is the primary performance sink that BulkMoveTo eliminates.

### Using FireAllEvents Mode Unnecessarily

`Enum.BulkMoveMode.FireAllEvents` fires all property change events for each moved part, which is significantly slower than `FireCFrameChanged`. Only use `FireAllEvents` when listeners depend on property events other than CFrame.

## Optimization Patterns

### Basic Usage

```lua
local parts: {BasePart} = collectParts()
local cframes: {CFrame} = computeNewPositions()

workspace:BulkMoveTo(
    parts,
    cframes,
    Enum.BulkMoveMode.FireCFrameChanged
)
```

### BulkMoveMode Selection

| Mode | Behavior | Performance |
|------|----------|-------------|
| `FireCFrameChanged` | Fires only CFrame-related events | Faster |
| `FireAllEvents` | Fires all property change events | Slower |

Use `FireCFrameChanged` unless your code specifically listens for non-CFrame property changes triggered by movement.

Source: [bulkmoveto-performance.md](../raw/community/performance/patterns/bulkmoveto-performance.md)

### Real-World Use Cases

- **Custom skeletal animation**: capes, tails, or non-Humanoid rigs with 30+ bones
- **Rain/snow simulation**: many parts moving each frame
- **Tile-based terrain updates**: chunk loading that repositions tiles
- **Debris fields**: projectile impacts scattering parts
- **Custom physics**: spring/cloth systems updating many constraint-driven parts

Source: [bulkmoveto-performance.md](../raw/community/performance/patterns/bulkmoveto-performance.md)

### Combined with Object Pooling

BulkMoveTo pairs well with [[object-pooling]]. Pool parts for reuse, then batch-move the active set each frame:

```lua
local activeParts = {}
local activeCFrames = {}

for i, bullet in activeBullets do
    activeParts[i] = bullet.part
    activeCFrames[i] = bullet.cframe + bullet.velocity * dt
end

workspace:BulkMoveTo(activeParts, activeCFrames, Enum.BulkMoveMode.FireCFrameChanged)
```

## Pitfalls

- **Below 30 parts, individual CFrame is competitive.** The overhead of building two arrays and calling BulkMoveTo may exceed the per-call savings.
- **No BulkPivotTo exists yet.** For Model-level movement (PivotTo semantics), BulkMoveTo does not apply. This is a requested extension.
- **No BulkTransformTo for Motor6D/Bone.** Custom skeletal systems that modify `Transform` properties cannot use BulkMoveTo directly.
- **Array sizes must match.** The `parts` and `cframes` arrays must have the same length or the call errors.

## Related

- [[heartbeat-budget]]
- [[object-pooling]]
- [[physics-budget]]

## Sources

- [bulkmoveto-performance.md](../raw/community/performance/patterns/bulkmoveto-performance.md)
- [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)
