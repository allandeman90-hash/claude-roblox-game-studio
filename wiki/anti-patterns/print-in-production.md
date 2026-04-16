---
title: print-in-production
type: anti-pattern
category: anti-patterns
subcategory: code-quality
owner: lead-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: low
related: []
tags: [anti-pattern, code-quality]
---

# `print()` in Production Code

**Severity:** Low
**Status:** stub

Using `print(...)` in gameplay code. Pollutes the output, can leak information to exploiters, and wastes CPU/memory in hot paths. Use a structured logger or remove.

## Fix

- Use a logger module with level filtering (`Logger.debug`, `Logger.warn`, `Logger.error`)
- `warn(...)` instead of `print(...)` for real warnings
- Gate debug prints behind a `DEBUG` flag
- The `validate-commit.sh` hook catches this automatically in staged files.

## Related

- [Server Scripts Rules](../../.claude/rules/server-scripts.md)
