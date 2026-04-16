---
title: UserInputService
type: service
category: services
subcategory: input
owner: ui-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/UserInputService.md
related:
  - "[[ContextActionService]]"
tags: [roblox-class, input, client-only]
---

# UserInputService

**Status:** stub

Client-side service for detecting input events (mouse, keyboard, touch, gamepad, VR). Events: `InputBegan`, `InputChanged`, `InputEnded`. Properties: `TouchEnabled`, `KeyboardEnabled`, `GamepadEnabled`, `VREnabled`.

Prefer `ContextActionService` when binding actions that need to work across input types. Use `UserInputService` directly for raw input handling.

## Related

- [[ContextActionService]]

## Sources

- [wiki/raw/roblox-creator-docs/services/UserInputService.md](../raw/roblox-creator-docs/services/UserInputService.md)
