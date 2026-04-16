---
title: BindableFunction
type: service
category: services
subcategory: networking
owner: luau-systems-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/BindableFunction.md
related:
  - "[[BindableEvent]]"
  - "[[RemoteFunction]]"
tags: [roblox-class, events]
---

# BindableFunction

**Status:** stub

## Summary

Two-way same-side communication (server-to-server or client-to-client). The caller invokes `:Invoke(...)` and yields until the handler returns a value. Like [[BindableEvent]] but with a return value.

For cross-boundary request-response, use [[RemoteFunction]] (server → client only).

## Related

- [[BindableEvent]] — one-way same-side variant
- [[RemoteFunction]] — cross-boundary variant

## Sources

- [wiki/raw/roblox-creator-docs/services/BindableFunction.md](../raw/roblox-creator-docs/services/BindableFunction.md)
