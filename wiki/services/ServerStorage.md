---
title: ServerStorage
type: service
category: services
subcategory: architecture
owner: technical-director
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/ServerStorage.md
related:
  - "[[ReplicatedStorage]]"
  - "[[ServerScriptService]]"
  - "[[client-server-split]]"
tags: [roblox-class, architecture, server-only]
---

# ServerStorage

**Status:** stub

Container for server-only data and inactive modules. Not replicated to clients — safe for secrets, admin lists, enemy templates, server-side config. Modules here are `require()`-able from `ServerScriptService`.

## Related

- [[ReplicatedStorage]]
- [[ServerScriptService]]
- [[client-server-split]]

## Sources

- [wiki/raw/roblox-creator-docs/services/ServerStorage.md](../raw/roblox-creator-docs/services/ServerStorage.md)
