---
title: Heartbeat Budget
type: performance
category: performance
subcategory: budgets
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/profiling/improving-game-performance-guide.md
  - wiki/raw/community/performance/profiling/official-identify-performance.md
  - wiki/raw/community/performance/patterns/task-scheduler-microprofiler.md
related:
  - "[[microprofiler]]"
  - "[[draw-call-optimization]]"
  - "[[server-memory-budget]]"
  - "[[physics-budget]]"
  - "[[parallel-luau]]"
tags: [performance, budgets, frame-rate, heartbeat]
---

# Heartbeat Budget

## Summary

Roblox runs a server heartbeat capped at **60 Hz** and a client frame loop also targeting **60 FPS** by default (up to 240 FPS on Windows). Every frame must complete all work -- scripts, physics, rendering, networking -- within **16.67 ms**. Exceeding this budget causes frame drops, rubber-banding, and input lag.

## Measurements / Budgets

| Budget | Value | Source |
|--------|-------|--------|
| Default client FPS | **60 FPS** | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |
| Max frame time at 60 FPS | **16.67 ms** | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |
| Server heartbeat cap | **60 Hz** | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |
| Windows max FPS | **240 FPS** | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |
| CPU target (mobile) | **15-20 ms** | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| GPU target (mobile) | **15-20 ms** | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| Server heartbeat target (minimum) | **< 33 ms** (30 FPS) | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |
| Server heartbeat target (ideal) | **< 16 ms** (60 FPS) | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |

### Frame Phase Breakdown

Each frame executes these phases in order. All must fit within the frame budget:

| Phase | Purpose | MicroProfiler Label |
|-------|---------|---------------------|
| PreAnimation | Initial frame preparation | PreAnimation |
| PreSimulation | Gameplay logic affecting physics | RunService.PreSimulation |
| Physics | Simulation step (60/120/240 Hz adaptive) | physicsStepped |
| PostSimulation | Reactions to physics results | RunService.PostSimulation |
| Heartbeat | Main game logic, `task.wait()` resumption | RunService.Heartbeat |
| PreRender | Final visual-only updates (client only) | RunService.PreRender |
| Render | GPU draw submission (client only) | Render |

Source: [task-scheduler-microprofiler.md](../raw/community/performance/patterns/task-scheduler-microprofiler.md)

## How to Measure

| Tool | Shortcut | What It Shows |
|------|----------|---------------|
| Performance Stats bar | **Ctrl+Alt+F7** | Live FPS, frame time, memory |
| MicroProfiler | **Ctrl+Alt+F6** | Per-frame flame graph of all phases |
| Developer Console | **F9** | Server/client stats, memory, network |
| Debug Stats | **Shift+Ctrl+F1-F5** | Individual stat categories |
| Performance Dashboard | Creator Dashboard (web) | Historical P50/P90 server metrics |

Source: [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md)

### Testing Configuration

- Set Graphics Mode to **Manual** and Graphics Quality to **10** for stress tests.
- Test on real devices, not emulators. Studio adds overhead that masks actual performance.
- Test on identical maps and servers across devices.

Source: [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md)

## Common Issues

### Heartbeat Overruns

The most frequent causes of exceeding the frame budget:

1. **Too many `task.wait()` loops** -- hundreds of tiny yields queue up in the scheduler and compete for time on each Heartbeat step.
2. **Heavy per-frame scripts** -- AI updates, spatial queries, or raycasts running every frame without throttling.
3. **Physics overload** -- too many unanchored parts with collisions enabled. See [[physics-budget]].
4. **Draw call spikes** -- GPU work (client) blocks the render phase. See [[draw-call-optimization]].
5. **Server-side tweening/animation** -- visual work that belongs on the client consuming server Heartbeat time.

### Scheduler Overload Symptoms

The task scheduler becomes overloaded when:
- Custom character rigs or input schemes replace engine defaults
- Parts are manually animated instead of using `Animator`
- Hundreds of scripts each run tight `task.wait()` loops

Source: [task-scheduler-microprofiler.md](../raw/community/performance/patterns/task-scheduler-microprofiler.md)

## Optimization Patterns

### Manager Pattern (Replace Many Waits)

Instead of many scripts each calling `task.wait()`, use a single update loop:

```lua
-- BAD: many scripts each with their own loop
while true do
    task.wait(0.1)
    doWork()
end

-- GOOD: single manager drives all workers
local workers = {}
RunService.Heartbeat:Connect(function(dt)
    for _, fn in workers do
        fn(dt)
    end
end)
```

Source: [task-scheduler-microprofiler.md](../raw/community/performance/patterns/task-scheduler-microprofiler.md)

### Phase Selection

Choose the correct RunService event for each task type:

| Task | Phase |
|------|-------|
| Gameplay logic affecting physics | `PreSimulation` |
| Reactions to physics | `PostSimulation` |
| Motor6D transforms | `PreSimulation` (Animator overwrites otherwise) |
| Camera movement | `BindToRenderStep` (high priority) |
| UI updates | `Heartbeat` or `PreRender` |
| Visual-only updates | `PreRender` |

### Throttle Heavy Work

For operations that don't need to run every frame, spread them across frames:

```lua
local BUDGET_MS = 2 -- spend at most 2 ms per frame on this
RunService.Heartbeat:Connect(function()
    local start = os.clock()
    while #queue > 0 and (os.clock() - start) * 1000 < BUDGET_MS do
        processNext(table.remove(queue))
    end
end)
```

### Offload to Parallel Luau

For bursty compute-heavy work (pathfinding, terrain gen), offload to Actors via [[parallel-luau]] to avoid blocking the main Heartbeat.

## Pitfalls

- **Profiling in Studio** adds overhead noise. Always confirm findings in a live game client.
- **Averaging frame time** hides spikes. Look at P99 or max frame time, not just the mean.
- **Client FPS != server FPS**. A client can run at 60 FPS while the server struggles at 20 Hz. Profile both independently.
- **`wait()` (deprecated) is not `task.wait()`**. Legacy `wait()` can add up to 30 ms of throttling per call. Always use `task.wait()`.

## Related

- [[microprofiler]]
- [[draw-call-optimization]]
- [[server-memory-budget]]
- [[physics-budget]]
- [[parallel-luau]]

## Sources

- [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md)
- [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md)
- [task-scheduler-microprofiler.md](../raw/community/performance/patterns/task-scheduler-microprofiler.md)
