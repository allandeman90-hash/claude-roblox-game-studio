---
title: no-rate-limit
type: anti-pattern
category: anti-patterns
subcategory: security
owner: remotes-networking-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: high
related:
  - "[[rate-limiting]]"
  - "[[RemoteEvent]]"
  - "[[remote-spam]]"
tags: [anti-pattern, security]
---

# Missing Rate Limit

**Severity:** High
**Status:** stub

Client → Server `RemoteEvent` without per-player rate limiting. Enables [[remote-spam]] attacks. See [[rate-limiting]] for the pattern.

## Fix

Implement a sliding-window rate limiter per player, per remote, and check it at the top of every `OnServerEvent` handler.

## Related

- [[rate-limiting]]
- [[RemoteEvent]]
- [[remote-spam]]
