---
title: microprofiler
type: performance
category: performance
subcategory: profiling
owner: performance-analyst
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/profiling/microprofiler-memory-flame-graphs.md
  - wiki/raw/community/performance/profiling/official-identify-performance.md
related:
  - "[[heartbeat-budget]]"
  - "[[server-memory-budget]]"
tags: [performance, profiling, tools]
---

# MicroProfiler

**Status:** stub

## Summary

Roblox's built-in per-frame profiler. `Ctrl+F6` (server) or `Ctrl+Alt+F6` (client). Shows script, physics, and render time per frame as a flame graph. Flame graph mode, memory view, X-ray diff mode. Can profile mobile devices over IP.

## TODO

- Full keyboard shortcuts
- Flame graph navigation
- Diff mode for before/after comparisons
- X-ray mode
- Tag interpretation (`Heartbeat`, `RunService::Heartbeat`, etc.)
- `debug.profilebegin` / `debug.profileend` custom labels
- Mobile profiling workflow
- Common spike shapes

## Related

- [[heartbeat-budget]]
- [[server-memory-budget]]

## Sources

- [wiki/raw/community/performance/profiling/microprofiler-memory-flame-graphs.md](../raw/community/performance/profiling/microprofiler-memory-flame-graphs.md)
