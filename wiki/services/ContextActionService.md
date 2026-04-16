---
title: ContextActionService
type: service
category: services
subcategory: input
owner: ui-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/ContextActionService.md
related:
  - "[[UserInputService]]"
tags: [roblox-class, input]
---

# ContextActionService

**Status:** stub

Bind input actions to multiple input types simultaneously — `E` key, touch, gamepad button — all under one action name. Cleaner for cross-platform input than raw `UserInputService`.

`BindAction(actionName, handler, createTouchButton, ...inputTypes)` — one call binds every input type. `UnbindAction(actionName)` to release.

## Related

- [[UserInputService]]

## Sources

- [wiki/raw/roblox-creator-docs/services/ContextActionService.md](../raw/roblox-creator-docs/services/ContextActionService.md)
