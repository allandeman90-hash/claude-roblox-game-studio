---
title: module-lazy-loading
type: concept
category: concepts
subcategory: architecture
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[client-server-split]]"
  - "[[service-pattern]]"
tags: [concept, architecture]
---

# Module Lazy Loading

**Status: stub**

## Summary

Pattern for deferring the `require` of a heavy module until it's actually needed. Avoids upfront initialization cost and breaks circular dependencies that would otherwise fail at load time.

## TODO

- Lazy-require wrapper function pattern
- When to use (heavy modules, optional features, circular deps)
- Pitfalls (first-access latency, hidden dependencies)
- Comparison with eager require

## Related

- [[client-server-split]]
- [[service-pattern]]

## Sources

- [.claude/agents/luau-systems-programmer.md](../../.claude/agents/luau-systems-programmer.md)
