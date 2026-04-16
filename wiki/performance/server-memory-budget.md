---
title: server-memory-budget
type: performance
category: performance
subcategory: budgets
owner: performance-analyst
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/memory/server-memory-limits.md
related:
  - "[[heartbeat-budget]]"
  - "[[memory-leak]]"
tags: [performance, budgets, memory]
---

# Server Memory Budget

**Status:** stub

## Summary

Roblox server memory formula (official): **6.25 GiB + (100 MiB × max_players)**. Base cap: ~6.4 GB. A 50-player server has ~11 GB budget; a 700-player server has ~6.5 GB (reduced from 12.5 GB in policy update).

Practical targets:
- Typical game: < 2 GB (well within budget)
- Hard cap: ~6.4 GB base
- Leak red-flag: steadily growing memory over session

## TODO

- Memory profiler in Developer Console
- LuauHeap stats
- InstanceCount tracking
- Common leak sources (connections, instances, closures)
- Weak references
- Per-player memory accounting

## Related

- [[heartbeat-budget]]
- [[memory-leak]]

## Sources

- [wiki/raw/community/performance/memory/server-memory-limits.md](../raw/community/performance/memory/server-memory-limits.md)
