---
title: ServerStorage
type: service
category: services
subcategory: architecture
owner: technical-director
status: draft
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

> Server-only container for data, templates, and inactive modules. [[ServerScriptService]]

## Summary

ServerStorage is a container whose contents are only accessible on the server. Objects within are **not replicated** to clients and cannot be accessed from LocalScripts. This makes it the standard location for server-only data: enemy templates, map prefabs, secret configurations, admin lists, and any ModuleScripts that should not be visible to clients.

By storing large objects (like maps) in ServerStorage until needed, network traffic is reduced for connecting players. When clients need access to an object, server scripts must parent it elsewhere (such as Workspace) first.

Scripts (not ModuleScripts) do **not** run when parented to ServerStorage, even if they are not Disabled. Use [[ServerScriptService]] for scripts that need to execute. ModuleScripts within ServerStorage can be `require()`-d normally from server scripts.

## API Surface

### Properties

_No public properties._

### Methods

_No public methods._

### Events

_No public events._

## Budgets and Limits

No explicit rate limits. However, very large objects in ServerStorage consume server memory even when not in use. Clone and clean up intentionally.

## Common Patterns

### Map rotation system

```lua
-- ServerScriptService/MapLoader.server.lua
local ServerStorage = game:GetService("ServerStorage")

local maps = ServerStorage:WaitForChild("Maps")
local currentMap = nil

local function loadMap(mapName: string)
    if currentMap then
        currentMap:Destroy()
    end
    local template = maps:FindFirstChild(mapName)
    if template then
        currentMap = template:Clone()
        currentMap.Parent = workspace
    end
end

loadMap("Arena_Desert")
```

### Server-only configuration

```lua
-- ServerStorage/AdminList (StringValue or ModuleScript)
-- Accessible only from server scripts, invisible to clients
local admins = require(game.ServerStorage.AdminConfig)
```

## Pitfalls

- **Scripts do not run here**: Only ModuleScripts are `require()`-able. Active Scripts must go in [[ServerScriptService]].
- **Must reparent for client access**: Clients cannot see anything in ServerStorage. To show something to players, clone it to Workspace or another replicated container.
- **Memory**: Large dormant assets still consume server memory. Remove or nil-parent when no longer needed.
- **Not a backup location**: Do not use ServerStorage to "hide" replicated objects from clients. This is a design choice, not a workaround -- use proper [[client-server-split]].

## Related

- [[ReplicatedStorage]] -- shared client+server container
- [[ServerScriptService]] -- where server scripts run
- [[client-server-split]] -- architectural separation pattern

## Sources

- [wiki/raw/roblox-creator-docs/services/ServerStorage.md](../raw/roblox-creator-docs/services/ServerStorage.md)
