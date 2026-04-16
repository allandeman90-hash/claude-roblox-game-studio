---
title: MessagingService
type: service
category: services
subcategory: networking
owner: live-ops-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/MessagingService.md
related:
  - "[[MemoryStoreService]]"
  - "[[cross-server-events]]"
tags: [roblox-class, networking, live-ops]
---

# MessagingService

**Status:** stub

Pub/sub messaging between server instances of the same experience. Best-effort delivery. Rate limit: 50 + 5 × player_count messages/min per server. Topic ≤ 80 chars, payload ≤ 1 KiB.

Use for global announcements, boss spawns, cross-server event triggers. Pair with [[MemoryStoreService]] for durable shared state.

## Related

- [[MemoryStoreService]]
- [[cross-server-events]]

## Sources

- [wiki/raw/roblox-creator-docs/services/MessagingService.md](../raw/roblox-creator-docs/services/MessagingService.md)
