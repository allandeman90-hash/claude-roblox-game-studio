---
title: atomic-trading
type: concept
category: concepts
subcategory: economy
owner: economy-designer
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[DataStoreService]]"
  - "[[session-locking]]"
  - "[[item-duplication]]"
tags: [concept, economy, trading]
---

# Atomic Trading

**Status: stub**

## Summary

The pattern that ensures a trade between two players is "all-or-nothing" — either both sides receive their items OR neither does. Prevents duplication exploits and partial-trade states.

## TODO

- Full pattern: locking both players, validating, swapping, unlocking
- Rollback on failure
- Trade tax as currency sink
- Anti-abuse limits (trade count, account age, same-value warnings)
- Cross-server trading considerations
- ProfileService/ProfileStore integration

## Related

- [[DataStoreService]]
- [[session-locking]]
- [[item-duplication]]

## Sources

- [.claude/agents/economy-designer.md](../../.claude/agents/economy-designer.md)
