---
title: quest-system
type: pattern
category: patterns
subcategory: progression
owner: game-designer
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[core-loop]]"
  - "[[DataStoreService]]"
tags: [pattern, progression]
---

# Quest System

**Status:** stub

Quest progress stored in player data (server-authoritative). Server-only `QuestService:AdvanceObjective(player, questId, objectiveId, amount)`. Client listens for quest updates via RemoteEvent for UI. Validate all progression server-side.

## Related

- [[core-loop]]
- [[DataStoreService]]
