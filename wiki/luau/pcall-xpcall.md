---
title: pcall-xpcall
type: luau-feature
category: luau
subcategory: error-handling
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[task-library]]"
  - "[[no-pcall]]"
tags: [luau, error-handling]
---

# `pcall` / `xpcall`

**Status: stub**

## Summary

Luau's error-handling primitives. `pcall(fn, ...)` calls `fn` in protected mode, catching any errors and returning `(success: boolean, result: any)`. `xpcall(fn, handler, ...)` is similar but runs a custom error handler that can inspect the stack before unwinding.

Required for every external service call (DataStore, HttpService, MarketplaceService).

## TODO

- Full signatures
- Return value patterns (success, result/error)
- xpcall for custom error handlers / stack capture
- Retry patterns with exponential backoff
- When NOT to use pcall (internal code that should just crash)
- Luau-specific: pcall catches yields (different from Lua 5.1)

## Related

- [[task-library]]
- [[no-pcall]]

## Sources

- [.claude/docs/luau-style-guide.md](../../.claude/docs/luau-style-guide.md)
