---
title: deprecated-spawn
type: anti-pattern
category: anti-patterns
subcategory: deprecated-api
owner: lead-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: medium
related:
  - "[[deprecated-wait]]"
  - "[[deprecated-delay]]"
  - "[[task-library]]"
tags: [anti-pattern, deprecated]
---

# Deprecated `spawn()`

**Severity:** Medium
**Status:** stub

Use `task.spawn()` instead of the legacy `spawn()` global. The legacy version is throttled by Roblox's task scheduler and may not start immediately. Same story as [[deprecated-wait]].

## Fix

```lua
-- ❌
spawn(function() doThing() end)
-- ✅
task.spawn(function() doThing() end)
```

## Related

- [[task-library]]
- [[deprecated-wait]]
- [[deprecated-delay]]
