---
title: MemoryStoreService
type: service
category: services
subcategory: persistence
owner: live-ops-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/MemoryStoreService.md
related:
  - "[[DataStoreService]]"
  - "[[MessagingService]]"
  - "[[cross-server-events]]"
tags: [roblox-class, persistence, live-ops]
---

# MemoryStoreService

**Status:** stub

Short-lived cross-server state via sorted maps, hash maps, and queues. Max 45-day TTL. Good for matchmaking queues, shared leaderboards, cross-server event state.

Rate limits: 1000 + numPlayers × 100 per minute per instance. Partition-aware sharding required at scale.

## Related

- [[DataStoreService]] — long-term persistence alternative
- [[MessagingService]] — cross-server pub/sub
- [[cross-server-events]]

## Sources

- [wiki/raw/roblox-creator-docs/services/MemoryStoreService.md](../raw/roblox-creator-docs/services/MemoryStoreService.md)
- [wiki/raw/roblox-creator-docs/best-practices/open-cloud/memory-stores-best-practices.md](../raw/roblox-creator-docs/best-practices/open-cloud/memory-stores-best-practices.md)
