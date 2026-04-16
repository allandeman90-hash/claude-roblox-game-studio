---
title: deprecated-spawn
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
  - "[[deprecated-delay]]"
  - "[[task-library]]"
tags: [anti-pattern, deprecated]
---

# Deprecated `spawn()`

> Using the legacy `spawn()` global instead of `task.spawn()`. Throttled, unpredictable, and deprecated.

**Severity:** Medium

## What It Looks Like

```lua
-- Spawning a new thread with legacy API
spawn(function()
    doExpensiveWork()
end)

-- Common pattern: fire-and-forget inside a loop
for _, player in ipairs(Players:GetPlayers()) do
    spawn(function()
        savePlayerData(player)
    end)
end
```

## Why It's Bad

1. **Throttled start**: `spawn()` does not resume the new thread immediately. It defers execution to the next resumption cycle of Roblox's legacy task scheduler, adding at least one frame of latency (~33ms at 30 FPS). In contrast, `task.spawn()` resumes the thread within the same resumption cycle.
2. **No error propagation**: errors inside a `spawn()` callback are silently swallowed by default, making debugging harder. `task.spawn()` surfaces errors to the output.
3. **Deprecated**: Roblox deprecated `spawn`, `delay`, and `wait` in favor of the `task` library. New documentation and official examples use `task.spawn()` exclusively.
4. **Inconsistent scheduling**: under heavy server load, `spawn()` threads can be delayed significantly beyond one frame, leading to unpredictable ordering of operations.
5. **No return handle**: `task.spawn()` returns the thread object, allowing cancellation via `task.cancel()`. The legacy `spawn()` does not.

## How to Fix It

```lua
-- Before (deprecated)
spawn(function()
    doExpensiveWork()
end)

-- After (correct)
task.spawn(function()
    doExpensiveWork()
end)

-- With cancellation support
local thread = task.spawn(function()
    while true do
        task.wait(1)
        poll()
    end
end)
-- Later...
task.cancel(thread)
```

For fire-and-forget with a delay, combine with `task.delay()` instead of nesting `spawn` + `wait`:

```lua
-- Before
spawn(function()
    wait(5)
    doThing()
end)

-- After
task.delay(5, doThing)
```

## Detection

Grep patterns to find this anti-pattern in a codebase:

```
spawn(function
spawn(func
[^.]spawn(
```

Exclude `task.spawn` matches. The Selene linter flags `spawn()` usage with the `deprecated` diagnostic.

## Related

- [[deprecated-wait]]
- [[deprecated-delay]]
- [[task-library]]

## Sources

- [Luau Style Guide](../../.claude/docs/luau-style-guide.md) -- Section 5: No Deprecated APIs
- [Roblox task library documentation](https://create.roblox.com/docs/reference/engine/libraries/task)
