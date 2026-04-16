---
title: Parallel Luau
type: performance
category: performance
subcategory: patterns
owner: performance-analyst
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/patterns/parallel-luau-actors.md
related:
  - "[[heartbeat-budget]]"
  - "[[native-codegen]]"
  - "[[microprofiler]]"
tags: [performance, parallel, actors, multithreading]
---

# Parallel Luau

## Summary

Parallel Luau (V2) enables multithreaded script execution via Actors. Scripts descended from an Actor can run in parallel during specific engine phases, distributing compute-heavy work across multiple CPU cores. Communication between Actors uses message passing or SharedTable. The client is limited to **3 parallel threads**; the server scales with player count.

## Measurements / Budgets

| Metric | Value | Source |
|--------|-------|--------|
| Client thread limit | **3 threads** | [parallel-luau-actors.md](../raw/community/performance/patterns/parallel-luau-actors.md) |
| Server thread limit | Scales with player count | [parallel-luau-actors.md](../raw/community/performance/patterns/parallel-luau-actors.md) |
| SharedTable key types | string, non-negative integer only | [parallel-luau-actors.md](../raw/community/performance/patterns/parallel-luau-actors.md) |

## How to Measure

- **MicroProfiler**: parallel work appears in separate thread lanes. Look for `Actor` or `Parallel` labels.
- **ScriptProfiler**: the "Parallel execution phases" category shows time spent in parallel scripts.
- Compare total Heartbeat time with and without parallel offloading to confirm net improvement.

## Common Issues

### Communication Overhead Eliminating Gains

Passing data back from an actor VM to the original VM via a BindableEvent causes significant bottlenecks, often resulting in **slower performance than serial execution** due to deferred signal behavior.

**Key insight**: Actor communication overhead can eliminate parallel gains if messages cross VMs frequently. Design for coarse-grained work batches, not fine-grained.

Source: [parallel-luau-actors.md](../raw/community/performance/patterns/parallel-luau-actors.md)

### SharedTable Limitations

SharedTable supports only string and non-negative integer keys. Attempting to use other key types (negative numbers, mixed keys, Instance references) causes errors.

### 3-Thread Client Limit

The client is limited to 3 parallel threads. Work that naturally divides into 2-3 chunks benefits; work requiring more threads will not parallelize further on clients.

## Optimization Patterns

### Actor Messaging

Asynchronous message passing between scripts and Actors using topics:

```lua
-- Sender (any script)
workerActor:SendMessage("ComputeChunk", chunkData)

-- Receiver (must be descendant of an Actor)
local actor = script:GetActor()
actor:BindToMessageParallel("ComputeChunk", function(chunkData)
    -- runs in parallel
    local result = processChunk(chunkData)
    -- return result via SharedTable or BindableEvent
end)
```

### SharedTable for Cross-Actor Data

```lua
local st = SharedTable.new()
st.results = SharedTable.new()

-- Share via registry
SharedTableRegistry:SetSharedTable("WorkResults", st)

-- In Actor scripts
local results = SharedTableRegistry:GetSharedTable("WorkResults")
results[actorId] = computedValue
```

SharedTable cloning is inexpensive due to structural sharing.

### Parallel Event Connections

Use `ConnectParallel` to run event handlers in parallel:

```lua
RunService.PreSimulation:ConnectParallel(function(dt)
    -- runs in parallel during PreSimulation phase
    doExpensiveWork(dt)
end)
```

Use `task.synchronize()` to re-enter the serial context when you need to modify shared state:

```lua
RunService.PreSimulation:ConnectParallel(function(dt)
    local result = computeInParallel(dt)
    task.synchronize()
    applyResult(result) -- safe to modify shared state
end)
```

### When to Use

| Scenario | Parallel? | Reason |
|----------|-----------|--------|
| Large chunk-based terrain generation | Yes | Independent, compute-heavy |
| Per-Actor AI simulation | Yes | Each AI is independent |
| Physics solver distribution | Yes | Divide by spatial region |
| Independent math-heavy tasks | Yes | No shared state needed |
| Tasks requiring frequent cross-actor communication | No | Overhead eliminates gains |
| UI work | No | Always main thread |
| Code relying on shared mutable state | No | Race conditions |

Source: [parallel-luau-actors.md](../raw/community/performance/patterns/parallel-luau-actors.md)

## Pitfalls

- **`task.synchronize()` and `task.desynchronize()` are restricted** to scripts that are descendants of an Actor. Calling from a non-Actor script errors.
- **`debug.profilebegin` may error in parallel contexts**. Test profiling labels in Actor scripts before shipping.
- **Deferred signal behavior** changes with parallel execution. `task.defer()`, `task.delay()`, and `task.wait()` maintain calling context (serial/parallel), which can cause unexpected behavior if not accounted for.
- **Over-splitting work** into many tiny Actor messages is worse than serial. The message-passing overhead dominates. Prefer large, independent batches.

## Related

- [[heartbeat-budget]]
- [[native-codegen]]
- [[microprofiler]]

## Sources

- [parallel-luau-actors.md](../raw/community/performance/patterns/parallel-luau-actors.md)
