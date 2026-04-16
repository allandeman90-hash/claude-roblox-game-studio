---
title: deprecated-delay
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
  - "[[deprecated-spawn]]"
  - "[[task-library]]"
tags: [anti-pattern, deprecated]
---

# Deprecated `delay()`

**Severity:** Medium
**Status:** stub

Use `task.delay()` instead of the legacy `delay()`.

## Fix

```lua
-- ❌
delay(5, function() doThing() end)
-- ✅
task.delay(5, function() doThing() end)
```

## Related

- [[task-library]]
- [[deprecated-wait]]
- [[deprecated-spawn]]
