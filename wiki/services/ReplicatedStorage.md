---
title: ReplicatedStorage
type: service
category: services
subcategory: architecture
owner: technical-director
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/ReplicatedStorage.md
related:
  - "[[ServerStorage]]"
  - "[[client-server-split]]"
  - "[[RemoteEvent]]"
tags: [roblox-class, architecture]
---

# ReplicatedStorage

> A container service for objects that are replicated to all clients. [[ServerStorage]]

## Summary

ReplicatedStorage is a general container for objects that need to be accessible by both the server and all connected clients. It is the standard location for shared `ModuleScript` code (types, utilities, configs), `RemoteEvent`/`RemoteFunction` instances, and any data that both sides of the client-server boundary need to read.

Objects parented here are fully replicated to clients. Normal replication rules apply: client-side changes persist locally but are not replicated back to the server, and server changes can overwrite client modifications. Moving objects from Workspace to ReplicatedStorage on the client can cause desynchronization issues (e.g., physics updates stop replicating).

**Security warning**: Clients can read everything in ReplicatedStorage. Never place secrets, admin lists, server-side configuration, or sensitive data here. Use [[ServerStorage]] for server-only content.

## API Surface

### Properties

_No public properties._

### Methods

_No public methods._

### Events

_No public events._

## Budgets and Limits

No explicit rate limits. However, large numbers of objects in ReplicatedStorage increase initial load time since everything is replicated to connecting clients.

## Common Patterns

### Shared module and remote organization

```
ReplicatedStorage/
  Shared/
    Types.lua          -- Shared type definitions
    Config.lua         -- Game configuration (non-secret)
    Utility.lua        -- Shared utility functions
  Remotes/
    PurchaseItem       -- RemoteEvent
    RequestData        -- RemoteFunction
```

### Accessing from both server and client

```lua
-- Works in both ServerScripts and LocalScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)
local purchaseRemote = ReplicatedStorage.Remotes:WaitForChild("PurchaseItem")
```

## Pitfalls

- **No secrets**: Clients can read all content. Never store API keys, admin lists, or server-only configs here.
- **Scripts do not run**: LocalScripts and Scripts parented directly to ReplicatedStorage do not execute. Use `StarterPlayerScripts`, `StarterGui`, or `ServerScriptService` for active scripts.
- **ModuleScripts do run when required**: A ModuleScript here runs normally when `require()`-d by another script.
- **Client changes are local-only**: Modifications on the client are not replicated to the server and can be overwritten by server-side changes.

## Related

- [[ServerStorage]] -- server-only alternative (not replicated)
- [[client-server-split]] -- architectural pattern for data placement
- [[RemoteEvent]] -- commonly stored in ReplicatedStorage

## Sources

- [wiki/raw/roblox-creator-docs/services/ReplicatedStorage.md](../raw/roblox-creator-docs/services/ReplicatedStorage.md)
