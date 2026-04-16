---
title: leaderboard-pattern
type: pattern
category: patterns
subcategory: progression
owner: luau-gameplay-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[OrderedDataStore]]"
  - "[[MemoryStoreService]]"
tags: [pattern, progression]
---

# Leaderboard Pattern

**Status:** stub

Use `OrderedDataStore:GetSortedAsync` for persistent top-N queries. Use `MemoryStoreService.SortedMap` for real-time cross-server leaderboards with short TTL (event leaderboards). Paginate results with `DataStorePages:AdvanceToNextPageAsync()`.

## Related

- [[OrderedDataStore]]
- [[MemoryStoreService]]

## Sources

- [wiki/raw/community/articles/datastore/memorystore-leaderboards.md](../raw/community/articles/datastore/memorystore-leaderboards.md)
