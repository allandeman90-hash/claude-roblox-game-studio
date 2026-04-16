---
title: deprecated-wait
type: anti-pattern
category: anti-patterns
subcategory: deprecated-api
owner: lead-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: medium
sources:
  - .claude/rules/server-scripts.md
  - .claude/rules/client-scripts.md
  - .claude/docs/luau-style-guide.md
related:
  - "[[task-library]]"
  - "[[deprecated-spawn]]"
  - "[[deprecated-delay]]"
tags: [anti-pattern, deprecated]
---

# Deprecated `wait()`

> Using `wait()` instead of `task.wait()`. Deprecated, slower, and less predictable.

**Severity:** Medium

## What It Looks Like

```lua
-- ❌ Bad
wait(1)
wait()

while true do
    wait(0.1)
    doThing()
end
```

## Why It's Bad

The global `wait()` function is a legacy Lua construct that Roblox has superseded with the `task` library. Problems:

1. **Throttled**: `wait()` is **throttled** by Roblox's task scheduler. Calling `wait()` with a small number like `0.01` does NOT yield for 10ms — it yields for **at least ~30ms** in most cases. This is a silent performance tax you pay for using the old API.
2. **Inaccurate**: because of throttling, `wait(1)` may actually yield for 1.03s or more. `task.wait(1)` is much closer to 1.0s.
3. **Deprecated**: Roblox has marked `wait`, `spawn`, and `delay` as deprecated. They may eventually be removed.
4. **Documentation rot**: new Roblox docs use `task.wait` universally. Code with `wait()` looks stale.

## How to Fix It

Replace every `wait()` with `task.wait()`:

```lua
-- ✅ Good
task.wait(1)
task.wait()  -- same signature; yields for one frame

while true do
    task.wait(0.1)
    doThing()
end
```

`task.wait()` is a drop-in replacement. Same signature, same return value (the actual elapsed time), no gotchas.

## Detection

Grep for uses of `wait()` that aren't `task.wait` or `:Wait` (the `:Wait` method on `RBXScriptSignal` and `RBXScriptConnection`):

```bash
grep -rnE '[^.]wait\(' src/ | grep -v "task\.wait\|:Wait"
```

The `validate-commit.sh` hook catches this automatically in staged files.

## Related

- [[task-library]] — the modern replacement
- [[deprecated-spawn]] — same story for `spawn()`
- [[deprecated-delay]] — same story for `delay()`
- [Server Scripts Rules](../../.claude/rules/server-scripts.md)
- [Luau Style Guide](../../.claude/docs/luau-style-guide.md)

## Sources

- [.claude/rules/server-scripts.md](../../.claude/rules/server-scripts.md)
- [.claude/rules/client-scripts.md](../../.claude/rules/client-scripts.md)
- [.claude/docs/luau-style-guide.md](../../.claude/docs/luau-style-guide.md)
