---
title: heartbeat-budget
type: performance
category: performance
subcategory: budgets
owner: performance-analyst
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/profiling/improving-game-performance-guide.md
related:
  - "[[microprofiler]]"
  - "[[RunService]]"
tags: [performance, budgets]
---

# Heartbeat Budget

**Status:** stub

## Summary

Roblox runs at 60 Hz by default → **16.67 ms per frame**. Server-side script work (RunService.Heartbeat and Stepped) must fit within this budget along with physics, networking, and internal engine work.

Targets:
- Server heartbeat: **< 33 ms** (30 FPS minimum) for playability, **< 16 ms** (60 FPS target) for smoothness
- Client frame: **< 16 ms** on PC, **< 33 ms** acceptable on low-end mobile

## TODO

- Frame budget breakdown (render/sim/scripts/physics)
- How to measure (MicroProfiler, Performance Stats Ctrl+Alt+F7)
- Common causes of Heartbeat overruns
- Throttle patterns for heavy work
- Parallel Luau offload for bursty work

## Related

- [[microprofiler]]
- [[RunService]]

## Sources

- [wiki/raw/community/performance/profiling/improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md)
