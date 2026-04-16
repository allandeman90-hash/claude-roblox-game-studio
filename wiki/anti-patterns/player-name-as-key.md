---
title: player-name-as-key
type: anti-pattern
category: anti-patterns
subcategory: persistence
owner: datastore-architect
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: high
related:
  - "[[DataStoreService]]"
  - "[[session-locking]]"
tags: [anti-pattern, persistence]
---

# Player Name as DataStore Key

**Severity:** High
**Status:** stub

Using `player.Name` instead of `player.UserId` as the DataStore key. Players can change their names — which means after a rename, their data is orphaned and they start fresh.

## Fix

```lua
-- ❌
store:SetAsync(player.Name, data)

-- ✅
store:SetAsync("Player_" .. player.UserId, data)
```

## Related

- [[DataStoreService]]
- [[session-locking]]
