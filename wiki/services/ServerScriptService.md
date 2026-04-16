---
title: ServerScriptService
type: service
category: services
subcategory: architecture
owner: technical-director
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/ServerScriptService.md
related:
  - "[[ServerStorage]]"
  - "[[ReplicatedStorage]]"
  - "[[client-server-split]]"
tags: [roblox-class, architecture, server-only]
---

# ServerScriptService

> Container for server-only scripts that run automatically. [[ServerStorage]]

## Summary

ServerScriptService is a container for `Script`, `ModuleScript`, and other scripting-related assets that are only meant for server use. Its contents are **never replicated** to player clients, providing a secure location for important game logic. Script objects placed here run automatically if they are not `Disabled`.

This is the primary location for active server-side game logic: remote event handlers, DataStore operations, combat systems, inventory management, and any code that must be authoritative. For non-scripting assets (prefab models, templates) that need to be server-only, use [[ServerStorage]] instead. For modules and assets needed by both server and client, use [[ReplicatedStorage]].

The service has one notable property: `LoadStringEnabled`, which controls whether the `loadstring` function can be used by server scripts. This defaults to `false` and should remain disabled for security reasons.

## API Surface

### Properties

- `LoadStringEnabled: boolean` -- Whether `loadstring` is available to server scripts. Default: false. Not scriptable (Studio-only). Keep disabled to prevent remote code execution vulnerabilities.

### Methods

_No public methods._

### Events

_No public events._

## Budgets and Limits

No explicit rate limits on the container itself. Scripts within are subject to normal Roblox script execution limits (33ms Heartbeat budget on server).

## Common Patterns

### Typical organization

```
ServerScriptService/
  Main.server.lua           -- Entry point, initializes systems
  PlayerData.server.lua     -- DataStore load/save lifecycle
  Combat.server.lua         -- Combat system
  Remotes.server.lua        -- Remote event handlers
  Modules/
    InventoryService.lua    -- Server-only ModuleScript
    MatchmakingService.lua
```

## Pitfalls

- **Scripts only, not data**: Non-scripting assets (models, templates) should go in [[ServerStorage]], not here.
- **LoadStringEnabled**: Leave this disabled. Enabling it opens remote code execution vectors.
- **Not replicated**: Clients have zero visibility into this service. This is by design -- it is the secure side of the [[client-server-split]].

## Related

- [[ServerStorage]] -- server-only data (not scripts)
- [[ReplicatedStorage]] -- shared client+server modules
- [[client-server-split]] -- architectural separation pattern

## Sources

- [wiki/raw/roblox-creator-docs/services/ServerScriptService.md](../raw/roblox-creator-docs/services/ServerScriptService.md)
