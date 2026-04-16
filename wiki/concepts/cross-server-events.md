---
title: cross-server-events
type: concept
category: concepts
subcategory: live-ops
owner: live-ops-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/messagingservice-in-game-patterns.md
  - wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md
related:
  - "[[MessagingService]]"
  - "[[MemoryStoreService]]"
tags: [concept, live-ops]
---

# Cross-Server Events

**Status: stub**

## Summary

Patterns for coordinating state and events across many server instances of the same experience. Two primitives:

- **MessagingService** — pub/sub, best-effort delivery, low latency, 50 + 5 × player_count messages/min
- **MemoryStoreService** — shared state store (SortedMap, HashMap, Queue), 45-day max TTL, partition-aware sharding

## TODO

- When to use MessagingService vs MemoryStoreService
- Global announcements pattern
- Cross-server matchmaking queue pattern
- Shared leaderboards pattern
- Rate limits and sharding
- Best-effort vs durable semantics

## Related

- [[MessagingService]]
- [[MemoryStoreService]]

## Sources

- [wiki/raw/community/monetization/live-ops/messagingservice-in-game-patterns.md](../raw/community/monetization/live-ops/messagingservice-in-game-patterns.md)
- [wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md](../raw/community/monetization/live-ops/memorystore-cross-server-patterns.md)
