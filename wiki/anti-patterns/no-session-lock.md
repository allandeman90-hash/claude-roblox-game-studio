---
title: no-session-lock
type: anti-pattern
category: anti-patterns
subcategory: persistence
owner: datastore-architect
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: critical
related:
  - "[[session-locking]]"
  - "[[item-duplication]]"
  - "[[DataStoreService]]"
tags: [anti-pattern, persistence, critical]
---

# Missing Session Lock

**Severity:** Critical
**Status:** stub

Player data loaded without first acquiring a session lock. Enables cross-server [[item-duplication]]. See [[session-locking]] for the required pattern.

## Fix

Use [ProfileService](https://devforum.roblox.com/t/profileservice/667805) or [ProfileStore](https://devforum.roblox.com/t/profilestore-full-fledged-datastore-api/2674577) unless you have strong reasons to roll your own.

## Related

- [[session-locking]]
- [[item-duplication]]
- [[DataStoreService]]
