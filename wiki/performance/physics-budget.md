---
title: Physics Budget
type: performance
category: performance
subcategory: budgets
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/physics/adaptive-timestepping.md
  - wiki/raw/community/performance/physics/cancollide-performance.md
  - wiki/raw/community/performance/rendering/optimization-guide-draw-calls.md
related:
  - "[[heartbeat-budget]]"
  - "[[draw-call-optimization]]"
  - "[[bulk-move-to]]"
tags: [performance, budgets, physics, collisions]
---

# Physics Budget

## Summary

Roblox physics simulation runs at up to **240 Hz** (4 steps per 60 FPS frame) in Fixed mode. Adaptive timestepping reduces this to **60/120/240 Hz** based on simulation intensity, saving CPU for other work. Physics cost scales with unanchored part count and collision complexity. Disabling `CanCollide` on non-interactive parts reduces physics step time by **22-30%**.

## Measurements / Budgets

| Budget | Value | Source |
|--------|-------|--------|
| Fixed physics step rate | **240 Hz** (4 steps/frame at 60 FPS) | [adaptive-timestepping.md](../raw/community/performance/physics/adaptive-timestepping.md) |
| Adaptive rates | **60 / 120 / 240 Hz** | [adaptive-timestepping.md](../raw/community/performance/physics/adaptive-timestepping.md) |
| CanCollide=false physics savings | **22-30% per step** | [cancollide-performance.md](../raw/community/performance/physics/cancollide-performance.md) |
| Test: 1,513 anchored parts, collisions on | 0.0185-0.0197 ms/step | [cancollide-performance.md](../raw/community/performance/physics/cancollide-performance.md) |
| Test: 1,513 anchored parts, collisions off | 0.0129-0.0152 ms/step | [cancollide-performance.md](../raw/community/performance/physics/cancollide-performance.md) |

### Adaptive Timestepping Visualization

| Frequency | Color in Studio | Applies To |
|-----------|----------------|------------|
| 60 Hz | Green | Static, slow-moving parts |
| 120 Hz | Yellow | Moderate activity |
| 240 Hz | Red | Fast movement, complex interactions |

Enable "Are Timesteps Shown" in Studio to see per-part frequency assignments in real time.

Source: [adaptive-timestepping.md](../raw/community/performance/physics/adaptive-timestepping.md)

## How to Measure

- **MicroProfiler**: look for `physicsStepped` or `World:stepContacts` labels. If physics consumes a large portion of the frame, this is the bottleneck.
- **Studio visualization**: enable "Are Timesteps Shown" to color-code parts by their physics stepping frequency.
- **Developer Console (F9)**: Physics category shows simulation statistics.

## Common Issues

### All Parts at 240 Hz (Fixed Mode)

With `PhysicsSteppingMethod = Fixed` (the legacy default), every unanchored part simulates at 240 Hz regardless of activity. A scene with 5,000 slow-moving parts wastes CPU simulating them 4x per frame. Switching to `Adaptive` drops idle parts to 60 Hz.

### Decorative Props Left Unanchored

Unanchored parts participate in the full physics simulation even if they never move. Anchor every static part.

### CanCollide Left On for Non-Interactive Parts

Collision detection runs for every part with `CanCollide = true`, even if no gameplay depends on it. Disabling CanCollide on decorative parts reduces physics step time by 22-30%.

Source: [cancollide-performance.md](../raw/community/performance/physics/cancollide-performance.md)

### High-Fidelity Collisions on Complex Meshes

`CollisionFidelity = Default` or `Precise` on complex meshes generates expensive collision geometry. Use `Box` for decorative objects and `Hull` for simple interactive objects.

Source: [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)

## Optimization Patterns

### 1. Enable Adaptive Timestepping

```
Workspace.PhysicsSteppingMethod = Adaptive
```

The engine automatically assigns 60/120/240 Hz based on:
- Movement speed and rotation rate
- Constraint complexity
- Interaction between high-freq and low-freq bodies (synchronizes to the higher rate)

Best results occur with "large amount of physics + low intensity simulations" -- games with many NPCs, ragdolls, or large persistent worlds.

Source: [adaptive-timestepping.md](../raw/community/performance/physics/adaptive-timestepping.md)

### 2. Anchor Static Parts

Every static prop, wall, floor, and decorative object must have `Anchored = true`. Unanchored parts enter the dynamic simulation pipeline even if they never move.

### 3. Disable CanCollide on Decorative Parts

```lua
for _, part in decorativeParts do
    part.CanCollide = false
end
```

22-30% physics step reduction for the affected parts. The benefit is strongest in interactive regions with many objects.

### 4. Reduce Collision Fidelity

| Object Type | Recommended Fidelity |
|-------------|---------------------|
| Decorative props | **Box** |
| Round interactive objects | **Hull** |
| Complex interactive objects | **Default** (only when needed) |
| Precision-critical | **Precise** (rare) |

### 5. Use BulkMoveTo for Mass Movement

When moving 30+ parts per frame, use `Workspace:BulkMoveTo()` instead of individual CFrame assignments. See [[bulk-move-to]].

## Pitfalls

- **Adaptive mode reduces physics accuracy.** Precision physics (racing sims, physics puzzles, complex constraint systems) may behave differently at 60 Hz vs 240 Hz. Test carefully.
- **Adaptive is now the default** for new Workspaces. Existing games using `Default` are on `Fixed`.
- **`.Touched` events still fire** when `CanCollide = false`. Disabling collisions does not disable touch detection -- the listener overhead remains.
- **Streaming is the correct solution for 100K+ parts**, not just CanCollide optimization. At that scale, physics budget savings from CanCollide are insufficient.

## Related

- [[heartbeat-budget]]
- [[draw-call-optimization]]
- [[bulk-move-to]]

## Sources

- [adaptive-timestepping.md](../raw/community/performance/physics/adaptive-timestepping.md)
- [cancollide-performance.md](../raw/community/performance/physics/cancollide-performance.md)
- [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)
