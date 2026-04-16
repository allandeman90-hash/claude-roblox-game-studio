---
title: BindableEvent
type: service
category: services
subcategory: networking
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/BindableEvent.md
related:
  - "[[RemoteEvent]]"
  - "[[signal-pattern]]"
tags: [roblox-class, events]
---

# BindableEvent

**Status:** stub

Non-network pub/sub — fires within the same side (server or client). `:Fire(...)` triggers connected handlers. Use for same-side decoupling; prefer a Signal library (GoodSignal, FastSignal) for complex cases since BindableEvent has quirky parameter-passing semantics (tables passed by value-like copy).

## Related

- [[RemoteEvent]] — network variant
- [[signal-pattern]] — more flexible alternative

## Sources

- [wiki/raw/roblox-creator-docs/services/BindableEvent.md](../raw/roblox-creator-docs/services/BindableEvent.md)
