---
title: bandwidth-budget
type: performance
category: performance
subcategory: budgets
owner: performance-analyst
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/network/remote-event-optimization.md
  - wiki/raw/community/performance/network/luau-buffer-type.md
related:
  - "[[RemoteEvent]]"
  - "[[UnreliableRemoteEvent]]"
  - "[[rate-limiting]]"
tags: [performance, budgets, network]
---

# Bandwidth Budget

**Status:** stub

## Summary

**Target: < 50 KB/s per player outgoing.** Higher is technically possible but hurts low-bandwidth clients and increases server cost.

- RemoteEvent max payload: ~50 MB (hard limit), keep under 1 KB per call
- UnreliableRemoteEvent max payload: 1000 bytes
- Reduction technique: `buffer` type for binary encoding, Zstd compression (up to 60x savings reported)

## TODO

- Profiling with Developer Console Network tab
- Delta compression patterns
- Batching updates
- When to use `buffer` type
- Real-world bandwidth budgets from shipped games

## Related

- [[RemoteEvent]]
- [[UnreliableRemoteEvent]]
- [[rate-limiting]]

## Sources

- [wiki/raw/community/performance/network/remote-event-optimization.md](../raw/community/performance/network/remote-event-optimization.md)
- [wiki/raw/community/performance/network/luau-buffer-type.md](../raw/community/performance/network/luau-buffer-type.md)
