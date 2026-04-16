---
title: coroutines
type: luau-feature
category: luau
subcategory: concurrency
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/coroutine-library.md
related:
  - "[[task-library]]"
tags: [luau, concurrency]
---

# Coroutines

**Status:** stub

Lua's cooperative thread primitive. Create via `coroutine.create(fn)`, start with `coroutine.resume(co, ...)`, yield with `coroutine.yield(...)`, check with `coroutine.status(co)`.

For most Roblox code, use [[task-library]] instead — it's optimized for Roblox's scheduler. Use raw `coroutine` when you need true cooperative scheduling with manual yield/resume.

## Related

- [[task-library]]

## Sources

- [wiki/raw/roblox-creator-docs/luau/coroutine-library.md](../raw/roblox-creator-docs/luau/coroutine-library.md)
