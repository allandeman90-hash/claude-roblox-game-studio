---
title: service-pattern
type: concept
category: concepts
subcategory: architecture
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[client-server-split]]"
  - "[[module-lazy-loading]]"
tags: [concept, architecture]
---

# Service Pattern

**Status: stub** — needs full elaboration from Knit/Flamework docs.

## Summary

The "service" pattern wraps each subsystem (combat, inventory, shop) in a module that has a consistent lifecycle: `new`, `onStart`, and (optional) `onDestroy`. Services are registered in a central registry and started in dependency order at game boot.

Used by frameworks like Knit (Sleitnick), Flamework (rbxts), and Nevermore.

## TODO

- Show the minimal service module template
- Contrast with plain module scripts
- Explain dependency injection vs explicit require
- Compare Knit vs Flamework vs custom
- Discuss server-side vs client-side services

## Related

- [[client-server-split]]
- [[module-lazy-loading]]

## Sources

- [Knit by Sleitnick](https://sleitnick.github.io/Knit/)
- [Flamework for roblox-ts](https://flamework.fireboltofdeath.dev/)
