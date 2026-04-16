---
title: RunService
type: service
category: services
subcategory: runtime
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/RunService.md
related:
  - "[[task-library]]"
  - "[[heartbeat-budget]]"
tags: [roblox-class, runtime]
---

# RunService

**Status:** stub

Exposes frame-loop events: `Heartbeat` (after physics), `Stepped` (before physics), `RenderStepped` (before render; client-only). Also `PreRender`, `PreSimulation`, `PostSimulation`.

Use `Heartbeat` for server-side frame loops. Use `RenderStepped` only when you need to run before rendering (camera updates, UI animations). Throttle expensive work.

## Related

- [[task-library]]
- [[heartbeat-budget]]

## Sources

- [wiki/raw/roblox-creator-docs/services/RunService.md](../raw/roblox-creator-docs/services/RunService.md)
