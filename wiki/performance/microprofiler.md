---
title: MicroProfiler
type: performance
category: performance
subcategory: profiling
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/profiling/microprofiler-memory-flame-graphs.md
  - wiki/raw/community/performance/profiling/official-identify-performance.md
  - wiki/raw/community/performance/profiling/debug-profile-api.md
  - wiki/raw/community/performance/profiling/script-profiler.md
related:
  - "[[heartbeat-budget]]"
  - "[[server-memory-budget]]"
  - "[[draw-call-optimization]]"
tags: [performance, profiling, tools, microprofiler]
---

# MicroProfiler

## Summary

The MicroProfiler is Roblox's built-in per-frame profiler. It displays script, physics, and render time as a flame graph timeline, supports memory profiling via X-ray mode, and can diff two dumps for before/after comparison. It is the primary tool for diagnosing frame budget violations.

## Measurements / Budgets

| Setting | Value | Source |
|---------|-------|--------|
| Keyboard shortcut | **Ctrl+Alt+F6** (client), **Ctrl+F6** (server/settings) | [microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md) |
| Dump frame range | **32-512 frames** | [microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md) |
| Mobile default port | **1338** | [microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md) |
| X-ray sensitivity range | **0-99** | [microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md) |
| Dump diff compatibility | July 2024+ | [microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md) |
| ScriptProfiler sampling rate | **1000 Hz (1 kHz)** | [script-profiler.md](../raw/community/performance/profiling/script-profiler.md) |

## How to Measure

### Enabling

- **Menu**: Main Menu > Settings > Micro Profiler > On
- **Shortcut**: `Ctrl+Alt+F6` toggles the real-time overlay
- **Modes**: Real-time overlay or browser dump (32-512 frames)

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+Alt+F6` | Toggle MicroProfiler overlay |
| `X` | Toggle X-Ray (memory) mode |
| `C` | Toggle X-Ray display: allocation count vs. total bytes |
| `Ctrl+F` / `Cmd+F` | Search by scope name |
| `F3` / `Cmd+G` | Find next instance |
| Left/Right arrows | Navigate between instances within thread |
| `Esc` | Close search box |
| Shift + scroll wheel | Adjust X-Ray sensitivity |

### Frame Color Codes

| Color | Meaning | Action |
|-------|---------|--------|
| **Orange** | CPU-heavy frame | Optimize scripts, physics, object count |
| **Red** | GPU-heavy frame | Reduce texture size, visual effects, render complexity |
| **Blue** | Render-heavy frame | Check object movement, light changes, draw call count |

Source: [microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md)

### Tooltip Metrics

When hovering on a frame bar, the tooltip shows:
- Render Wall Time
- GPU Wait Time
- Jobs Wall Time
- GPU time (mp and dev variants)

### X-Ray Mode (Memory Profiling)

Press `X` to activate. Shows a gray overlay indicating memory allocation intensity:
- **Upper bar**: overall frame allocation intensity
- **Lower bar**: allocation intensity within specific frame sections
- Toggle `C` to switch between allocation count and total bytes
- Adjust sensitivity with Shift + scroll wheel or X-Ray > Thresholds (0-99)

### Flame Graphs

Access via Export > CPU Flamegraph or Memory Flamegraph:
- Aggregates all call stacks across threads and frames
- Top Down / Bottom Up view toggle
- Displays total CPU time, percentage of root, average time per entry
- Memory flamegraph shows allocation count or total size in bytes, with "Per 1 frame" averaging

### Diff FlameGraphs (Before/After Comparison)

Compare two dumps via drag-and-drop or Export > Diff/Combine:
- **Green**: first dump uses more resources
- **Blue**: second dump uses more resources
- **Brightness**: indicates magnitude of difference
- Modes: Relative (percentage) or Absolute (ms for CPU, bytes for memory)
- **Combo feature**: combine multiple dumps from same side for averaged metrics

### Mobile Profiling

Access a mobile device's profiler via browser at `IP:port` (e.g., `192.168.1.1:1338`). Specify frame count with `IP:port/number_of_frames` (e.g., `192.168.1.1:1338/64`). Device must be on the same network.

Source: [microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md)

## Common Issues

### Identifying Spikes

Pause the MicroProfiler on a performance peak to identify the bottleneck task. Common spike shapes:
- **Single tall bar in Heartbeat** -- one script dominating the frame
- **Wide physics bar** -- too many unanchored or colliding parts
- **Render bar exceeding budget** -- draw call or overdraw issue

### Script Profiler vs. MicroProfiler

| Tool | Best For |
|------|----------|
| MicroProfiler | Per-frame timeline, physics/render/script breakdown, memory X-ray |
| ScriptProfiler | Identifying which specific script/function consumes the most CPU across a session |

The ScriptProfiler (F9 > ScriptProfiler tab) samples at **1 kHz** and attributes CPU time to individual functions. Use it to find the hot function, then use MicroProfiler to see where it falls in the frame.

Source: [script-profiler.md](../raw/community/performance/profiling/script-profiler.md)

## Optimization Patterns

### Custom Profile Labels

Use `debug.profilebegin()` / `debug.profileend()` to tag custom code sections:

```lua
RunService.Heartbeat:Connect(function(dt)
    debug.profilebegin("AI.Update")
    AI:Update(dt)
    debug.profileend()

    debug.profilebegin("Physics.Custom")
    PhysicsSystem:Update(dt)
    debug.profileend()
end)
```

Labels appear in both MicroProfiler and ScriptProfiler. Overhead is negligible when the profiler is inactive -- safe to leave in production.

Source: [debug-profile-api.md](../raw/community/performance/profiling/debug-profile-api.md)

### Best Practices for Labels

1. Use meaningful names: `"Combat.DealDamage"` not `"step1"`
2. Use namespace dots for hierarchy: `"AI.Pathfinding.Compute"`
3. Always pair `begin` / `end`. Wrap risky code in pcall to guarantee `end` is called:

```lua
debug.profilebegin("RiskyOperation")
local ok, err = pcall(doRiskyThing)
debug.profileend()
if not ok then error(err) end
```

4. Only wrap top-level entries of hot paths. Profiling millions of inner-loop iterations adds overhead even at nanoseconds per call.

Source: [debug-profile-api.md](../raw/community/performance/profiling/debug-profile-api.md)

## Pitfalls

- **Studio adds overhead**. Always confirm findings in a live game client, not just Studio.
- **Save dumps for investigation**. Don't rely on memory alone -- save browser dumps and share them with the team.
- **Diff mode requires July 2024+ dumps**. Older dumps are incompatible.
- **`debug.profilebegin` may error in parallel Actor contexts**. Check Actor-specific documentation before using in parallel scripts.
- **ScriptProfiler sampling noise** affects functions with minimal CPU contribution. Don't chase functions that appear due to sampling jitter.

## Related

- [[heartbeat-budget]]
- [[server-memory-budget]]
- [[draw-call-optimization]]

## Sources

- [microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md)
- [official-identify-performance.md](../raw/community/performance/profiling/official-identify-performance.md)
- [debug-profile-api.md](../raw/community/performance/profiling/debug-profile-api.md)
- [script-profiler.md](../raw/community/performance/profiling/script-profiler.md)
