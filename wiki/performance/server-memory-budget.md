---
title: Server Memory Budget
type: performance
category: performance
subcategory: budgets
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/memory/server-memory-limits.md
  - wiki/raw/community/performance/memory/garbage-collection-guide.md
  - wiki/raw/community/performance/memory/connection-memory-leaks.md
  - wiki/raw/community/performance/profiling/official-identify-performance.md
  - wiki/raw/community/performance/profiling/improving-game-performance-guide.md
related:
  - "[[heartbeat-budget]]"
  - "[[connection-leaks]]"
  - "[[texture-memory]]"
  - "[[microprofiler]]"
tags: [performance, budgets, memory, server]
---

# Server Memory Budget

## Summary

Roblox allocates server memory using a formula based on the maximum connected player count. The base cap is **6.4 GB**, scaling upward with players. Server memory is consumed by the instance tree, script heap, physics state, replication queues, and asset caches. Exceeding the budget causes server crashes.

## Measurements / Budgets

### Server Memory Formula

| Budget | Value | Source |
|--------|-------|--------|
| Official formula | **6.25 GiB + (100 MiB x max_players)** | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |
| Base server cap | **6.4 GB** | [server-memory-limits.md](../raw/community/performance/memory/server-memory-limits.md) |
| 30-player server | ~9.18 GiB total | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |
| 700-player server (2024) | **6.5 GB** (reduced from 12.5 GB) | [server-memory-limits.md](../raw/community/performance/memory/server-memory-limits.md) |
| Historical cap (older) | ~3.5 GB | [server-memory-limits.md](../raw/community/performance/memory/server-memory-limits.md) |
| Official target | **< 50% of capacity** | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |

### Client Memory Budgets

| Budget | Value | Source |
|--------|-------|--------|
| Mobile practical target | **400-600 MB** | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| Baseline 2025 | 900-1,200 MB typical; 1,500 MB common | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| iPhone 8 (2 GB RAM) ceiling | 700-800 MB | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| Galaxy S9 (4 GB RAM) | 300-400 MB | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| Cumulative texture memory (mobile) | ~200 MB | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| Client crash alarm | > 2-3% crash rate | [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md) |

### What Consumes Server Memory

- Instance tree (parts, meshes, models)
- Script code and runtime state (LuauHeap)
- Tables, closures, strings (script heap)
- Loaded textures and meshes
- Physics simulation state
- Asset streaming cache
- Replication queues

Source: [server-memory-limits.md](../raw/community/performance/memory/server-memory-limits.md)

## How to Measure

| Tool | Access | What It Shows |
|------|--------|---------------|
| Creator Hub dashboard | Web | P50/P90 server memory over time |
| Developer Console (F9) | Memory tab | Per-category breakdown (LuauHeap, Instances, Signals, etc.) |
| `Stats:GetTotalMemoryUsageMb()` | Script | Programmatic total memory reading |
| MicroProfiler X-Ray | `Ctrl+Alt+F6` then `X` | Per-frame allocation intensity |

A steadily growing memory line in the Creator Hub dashboard is a **leak red flag**.

Source: [server-memory-limits.md](../raw/community/performance/memory/server-memory-limits.md)

## Common Issues

### Connection Memory Leaks

The most common leak source. Event connections hold closures that reference instances, creating cycles the garbage collector cannot break:

```lua
-- LEAK: closure references part, part holds connection list
local part = Instance.new("Part")
part.Touched:Connect(function()
    print(part.Name) -- captures 'part' as upvalue
end)
-- 'part' can never be GC'd
```

Fix: call `:Destroy()` on the parent instance (auto-disconnects all connections) or explicitly store and `:Disconnect()` each connection. See [[connection-leaks]].

Source: [connection-memory-leaks.md](../raw/community/performance/memory/connection-memory-leaks.md)

### Closure Leaks

Functions referencing external variables hold strong references that persist until the function itself is collected:

```lua
-- LEAK: closure keeps 'bigTable' alive forever
local bigTable = buildHugeTable()
local fn = function() return bigTable[1] end
```

Source: [garbage-collection-guide.md](../raw/community/performance/memory/garbage-collection-guide.md)

### Never-Ending Threads

Coroutines that yield indefinitely via `coroutine.yield()` retain all referenced data for the lifetime of the thread.

### Unbounded Caches

Tables used as caches that grow without eviction eventually consume all available memory. Use weak-value tables for caches that should not prevent collection:

```lua
local cache = setmetatable({}, { __mode = "v" })
```

Source: [garbage-collection-guide.md](../raw/community/performance/memory/garbage-collection-guide.md)

## Optimization Patterns

### Reduction Strategies

1. Move maps from `ReplicatedStorage` to `ServerStorage` (reduces client memory, not server, but reduces replication overhead)
2. Enable `StreamingEnabled` for large worlds
3. Clean up unused instances with `:Destroy()`
4. Disconnect event connections properly or use Maid/Trove
5. Use `buffer` type instead of large tables for binary data
6. Compress DataStore entries

Source: [server-memory-limits.md](../raw/community/performance/memory/server-memory-limits.md)

### Weak Reference Testing for Leaks

Programmatically test whether an object leaks:

```lua
local weakRef = setmetatable({}, { __mode = "v" })
weakRef.target = suspectedLeakyObject
suspectedLeakyObject = nil
task.wait(1) -- let GC run
if weakRef.target == nil then
    print("No leak")
else
    print("LEAK: still referenced")
end
```

Source: [garbage-collection-guide.md](../raw/community/performance/memory/garbage-collection-guide.md)

## Pitfalls

- **`collectgarbage("collect")` errors in Roblox.** You cannot force a GC cycle. Timing is automatic and unpredictable.
- **700-player server caps were reduced** from 12.5 GB to 6.5 GB in a 2024 policy update. Do not assume historical caps still apply.
- **Client memory varies wildly by device.** A Galaxy S9 may report 300 MB while the same game uses 1,200 MB on PC. Test on real target hardware.
- **Numbers and string literals** have special GC rules. They may not be collected even when no strong reference exists.

## Related

- [[heartbeat-budget]]
- [[connection-leaks]]
- [[texture-memory]]
- [[microprofiler]]

## Sources

- [server-memory-limits.md](../raw/community/performance/memory/server-memory-limits.md)
- [garbage-collection-guide.md](../raw/community/performance/memory/garbage-collection-guide.md)
- [connection-memory-leaks.md](../raw/community/performance/memory/connection-memory-leaks.md)
- [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md)
- [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md)
