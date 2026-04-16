---
title: Performance, Profiling, and Optimization - Index
type: index
category: performance
captured_at: 2026-04-16
captured_by: research-agent-9
---

# Performance, Profiling, and Optimization

Roblox/Luau performance knowledge base, organized by subcategory. This wiki captures concrete numbers, budgets, and actionable optimization techniques.

## Benchmarks and Budgets (Quick Reference)

### Frame Rate Targets
| Target | Value | Source |
|--------|-------|--------|
| Default client FPS | **60 FPS** | Official Roblox docs |
| Max frame time | **16.67 ms** | Official Roblox docs |
| Server heartbeat | **60 Hz (capped)** | Official Roblox docs |
| Windows max FPS | Up to 240 FPS | Official Roblox docs |
| CPU target (mobile) | 15-20 ms | Community guide |
| GPU target (mobile) | 15-20 ms | Community guide |

### Memory Budgets
| Budget | Value | Source |
|--------|-------|--------|
| **Server memory formula** | **6.25 GiB + (100 MiB * max_players)** | Official docs |
| Server memory base cap | **6.4 GB** | Server memory experiments |
| Server memory target | **<50% of capacity** | Official docs |
| 30-player server total | ~9.18 GiB | Official docs |
| 700-player server cap | 6.5 GB (down from 12.5) | DevForum 2024 |
| Older (historical) cap | ~3.5 GB | Community memory |
| Client memory (mobile practical) | 400-600 MB | Community guide |
| Client memory baseline (2025) | 900-1,200 MB typical, 1,500 MB common | Community guide |
| iPhone 8 (2GB RAM) ceiling | 700-800 MB | Community guide |
| Galaxy S9 (4GB RAM) | 300-400 MB | Community guide |
| Cumulative texture memory | ~200 MB mobile cap | Community guide |

### Network Budgets
| Budget | Value | Source |
|--------|-------|--------|
| **Throttle (send and receive)** | **50 KB/s per player** | Luau Optimizations guide |
| Max per RemoteEvent send | 50 MB | Buffer docs |
| Max UnreliableRemoteEvent payload | **1000 bytes** | Engine update 2025 |
| DataStore key max | ~4 MB | Luau Optimizations guide |
| Target ms for Data Sent/Received | <5-10 ms | Community guide |
| Buffer compression algorithm | Zstd | Buffer docs |
| Reported buffer savings | up to 60x | Community guide |

### Rendering Budgets
| Budget | Value | Source |
|--------|-------|--------|
| **Scene draw calls target** | **<500** | Community optimization guide |
| Physics step rate (Fixed) | 240 Hz = 4 steps/frame | Official docs |
| Physics step rates (Adaptive) | 60/120/240 Hz | Adaptive Timestepping |
| Mesh LOD High->Medium | **250 studs** | Mesh LOD docs |
| Mesh LOD Medium->Low | **500 studs** | Mesh LOD docs |
| LOD Medium triangle reduction | ~50% | Mesh LOD docs |
| LOD Low triangle reduction | ~75% total | Mesh LOD docs |
| Max texture upload | 1024 x 1024 | Texture optimization |
| 1024 texture memory | ~5.3 MB (w/ MIPs) | Memory formula |
| 512 texture memory | ~1.3 MB (w/ MIPs) | Memory formula |
| 1024 vs 512 cost ratio | **4x** | Official docs |
| Recommended max texture | 512 x 512 for most | Official docs |
| FastCluster alarm threshold | **4+ ms** | Official docs |

### Luau Optimization Numbers
| Optimization | Impact |
|--------------|--------|
| **`--!native` codegen speedup** | **1.5-2.5x typical, 3.2x max** |
| Native codegen single block limit | 64K instructions |
| Native codegen module limit | 1M instructions |
| `table.concat` vs `..` (1000 concats) | ~8x faster |
| Generalized iteration vs ipairs | ~8% faster |
| Metatable vs closure instantiation | 2x faster |
| Metatable vs closure memory | 2.2x less |
| CanCollide off performance gain | 22-30% physics step |
| BulkMoveTo vs individual CFrame | Wins at ~30 parts |

### Profiling Tools
| Tool | Shortcut |
|------|----------|
| Developer Console | F9 |
| MicroProfiler | Ctrl+Alt+F6 |
| Performance Stats bar | Ctrl+Alt+F7 |
| Debug Stats (individual) | Shift+Ctrl+F1-F5 |
| ScriptProfiler sampling rate | 1000 Hz (1 kHz) |
| Performance Dashboard | Creator Dashboard (web) |

### Streaming Defaults
| Setting | Default |
|---------|---------|
| StreamingMinRadius | **64 studs** |
| StreamingTargetRadius | **1024 studs** |
| Mobile-recommended TargetRadius | 512-768 studs |

---

## Profiling Tools & Methodology

Tools and methodology for identifying performance issues:

- [improving-game-performance-guide.md](profiling/improving-game-performance-guide.md) - Comprehensive guide on benchmarking, targets for memory/CPU/GPU/network across devices
- [microprofiler-memory-flame-graphs.md](profiling/microprofiler-memory-flame-graphs.md) - Memory profiling, flame graphs, diff/combine features
- [script-profiler.md](profiling/script-profiler.md) - Sampling profiler at 1 kHz for identifying script bottlenecks
- [debug-profile-api.md](profiling/debug-profile-api.md) - `debug.profilebegin`/`debug.profileend` usage patterns
- [official-identify-performance.md](profiling/official-identify-performance.md) - Official Roblox targets (60 FPS, 16.67 ms, memory formula)

## Luau Language Performance

Language-level performance characteristics and optimization:

- [native-code-generation.md](luau/native-code-generation.md) - `--!native` directive, 1.5-2.5x speedup, limitations, type annotations
- [luau-performance-internals.md](luau/luau-performance-internals.md) - How Luau makes code fast: inline cache, fastcall, vector type, namecall
- [luau-optimizations-guide.md](luau/luau-optimizations-guide.md) - Macro/micro optimizations: preallocation, pooling, batching, compression
- [oop-performance-comparison.md](luau/oop-performance-comparison.md) - Metatable vs closure vs table OOP benchmarks
- [string-concatenation-performance.md](luau/string-concatenation-performance.md) - `table.concat` vs `..` benchmarks (~8x at 1000 concats)
- [loop-iteration-performance.md](luau/loop-iteration-performance.md) - Generalized iteration vs `pairs`/`ipairs` benchmarks

## Rendering & Graphics Performance

Draw calls, meshes, lighting, transparency:

- [optimization-guide-draw-calls.md](rendering/optimization-guide-draw-calls.md) - Draw call targets, collision fidelity, bulk ops
- [mesh-lod-render-fidelity.md](rendering/mesh-lod-render-fidelity.md) - Mesh LOD at 250/500 studs, RenderFidelity trade-offs
- [lighting-modes-performance.md](rendering/lighting-modes-performance.md) - Future/ShadowMap/Voxel/Compatibility memory comparison
- [transparency-overdraw.md](rendering/transparency-overdraw.md) - Transparency cost, overdraw scaling, opaque-first rendering

## Network & Replication Performance

RemoteEvents, bandwidth, compression, streaming:

- [remote-event-optimization.md](network/remote-event-optimization.md) - Batching, enum metadata reduction, rate limiting
- [unreliable-remote-events.md](network/unreliable-remote-events.md) - UnreliableRemoteEvent (1000 bytes max), use cases, packet loss benefits
- [luau-buffer-type.md](network/luau-buffer-type.md) - `buffer` type for binary serialization, 50 MB cap, Zstd compression
- [streaming-enabled-guide.md](network/streaming-enabled-guide.md) - StreamingMin/TargetRadius defaults, Model.StreamingMode (Atomic/Persistent)

## Physics Performance

Physics stepping, collisions, constraints:

- [adaptive-timestepping.md](physics/adaptive-timestepping.md) - PhysicsSteppingMethod Adaptive (60/120/240 Hz) vs Fixed (240 Hz)
- [cancollide-performance.md](physics/cancollide-performance.md) - CanCollide=false saves 22-30% physics step time

## Memory Management

Memory budgets, leak detection, garbage collection:

- [server-memory-limits.md](memory/server-memory-limits.md) - 6.4 GB base cap, scaling formula, historical changes
- [connection-memory-leaks.md](memory/connection-memory-leaks.md) - How `:Connect` prevents GC, proper cleanup patterns
- [garbage-collection-guide.md](memory/garbage-collection-guide.md) - Weak references, GC behavior, leak prevention strategies
- [texture-memory-optimization.md](memory/texture-memory-optimization.md) - Texture memory formula (w*h*4*1.33), upload vs runtime memory

## Performance Patterns

Reusable patterns and systematic approaches:

- [official-performance-improve.md](patterns/official-performance-improve.md) - Official Roblox improvement recommendations across all categories
- [object-pooling.md](patterns/object-pooling.md) - Part/instance pooling patterns, PartCache technique
- [bulkmoveto-performance.md](patterns/bulkmoveto-performance.md) - `Workspace:BulkMoveTo` performance threshold (~30 parts)
- [parallel-luau-actors.md](patterns/parallel-luau-actors.md) - Actors, SharedTable, thread limits, communication caveats
- [task-scheduler-microprofiler.md](patterns/task-scheduler-microprofiler.md) - Frame phases (PreSim/PostSim/Heartbeat/PreRender) and task library

---

## Key Concepts to Remember

### When profiling
1. Always profile in-game, not in Studio (Studio adds overhead)
2. Use real devices, not emulators (hardware matters)
3. Save dumps for investigation; test consistently
4. Set Graphics Quality to 10 (max) for stress tests

### When optimizing
1. Profile first, optimize second. Don't chase microseconds in cold code.
2. Macro wins (pooling, batching, streaming) > micro wins (loop tweaks)
3. The biggest wins are usually: draw calls, memory leaks, network throttling
4. Measure before AND after every change

### Common wins
1. Set MeshPart RenderFidelity to Automatic
2. Enable StreamingEnabled
3. Set PhysicsSteppingMethod to Adaptive
4. Anchor static parts
5. Use buffer type for binary network data
6. Use table.concat for many concatenations
7. Pool instead of clone/destroy
8. Disconnect connections or use :Destroy()
9. Don't parent to Workspace until all properties are set
10. Use `--!native` on compute-heavy modules

---

## Source Attribution

All content captured from Roblox Developer Forum, create.roblox.com official docs, and luau.org documentation. Each source file cites its original URL.
