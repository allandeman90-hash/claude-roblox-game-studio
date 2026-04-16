---
title: deprecated-delay
type: anti-pattern
category: anti-patterns
subcategory: deprecated-api
owner: lead-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
severity: medium
sources:
  - .claude/docs/luau-style-guide.md
  - .claude/rules/server-scripts.md
  - .claude/rules/client-scripts.md
related:
  - "[[deprecated-wait]]"
  - "[[deprecated-spawn]]"
  - "[[task-library]]"
tags: [anti-pattern, deprecated]
---

# Deprecated `delay()`

> Using the legacy `delay()` global instead of `task.delay()`. Inaccurate timing, throttled, and deprecated.

**Severity:** Medium

## What It Looks Like

```lua
-- Scheduling a callback after N seconds with legacy API
delay(5, function()
    grantReward(player)
end)

-- Common pattern: cooldown reset
delay(COOLDOWN, function()
    canAttack[player] = true
end)
```

## Why It's Bad

1. **Inaccurate timing**: `delay(n, f)` uses the legacy task scheduler, which introduces up to ~30ms of additional latency per resumption cycle. A `delay(1, f)` call may fire at 1.03s or later. `task.delay(1, f)` fires much closer to the requested time.
2. **Throttled under load**: when the server is under heavy script pressure, legacy `delay()` callbacks pile up and execute in unpredictable batches. `task.delay()` schedules against the engine's physics heartbeat, giving more consistent timing.
3. **No cancellation**: `delay()` does not return a handle. Once scheduled, the callback cannot be cancelled. `task.delay()` returns a thread that can be cancelled with `task.cancel()`.
4. **Deprecated**: Roblox deprecated `delay`, `spawn`, and `wait`. All official documentation uses `task.delay()`.
5. **Silent error swallowing**: like `spawn()`, errors inside legacy `delay()` callbacks may not surface cleanly to the output log.

## How to Fix It

```lua
-- Before (deprecated)
delay(5, function()
    grantReward(player)
end)

-- After (correct)
task.delay(5, function()
    grantReward(player)
end)

-- With cancellation
local thread = task.delay(COOLDOWN, function()
    canAttack[player] = true
end)
-- Cancel if player leaves before cooldown expires
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        task.cancel(thread)
    end
end)
```

## Detection

Grep patterns:

```
[^.]delay(
[^k]delay(%d
```

Exclude `task.delay` matches. Selene flags `delay()` with the `deprecated` diagnostic.

## Related

- [[deprecated-wait]]
- [[deprecated-spawn]]
- [[task-library]]

## Sources

- [Luau Style Guide](../../.claude/docs/luau-style-guide.md) -- Section 5: No Deprecated APIs
- [Roblox task library documentation](https://create.roblox.com/docs/reference/engine/libraries/task)
