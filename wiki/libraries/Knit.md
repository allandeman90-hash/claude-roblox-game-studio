---
title: Knit
type: library
category: libraries
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/knit-readme.md
  - wiki/raw/community/devforum/knit-game-framework-template.md
  - wiki/raw/community/articles/architecture/framework-comparison.md
related: [[[Flamework]], [[Promise]], [[framework-comparison]]]
tags: [library, framework, services, controllers, networking]
---

# Knit

> Lightweight service/controller framework for Roblox that organizes game logic into server-side Services and client-side Controllers with automatic remote generation.

## Summary

Knit is a framework by Stephen Leitnick (Sleitnick) that simplifies communication between game components and bridges the server/client boundary. It organizes server code into **Services** (singletons with domain logic) and client code into **Controllers** (singletons that consume services and drive UI). Any method placed on a Service's `.Client` table is automatically exposed as a callable remote -- no manual RemoteEvent or RemoteFunction creation required.

**Maintainer:** Sleitnick
**Status:** Archived (no longer maintained). Still fully functional and widely used. The successor pattern is the smaller "Util" modules in RbxUtil.
**License:** MIT

## Installation

### Wally

```toml
[dependencies]
Knit = "sleitnick/knit@^1"
```

Sync the Wally `Packages` folder into `ReplicatedStorage.Packages` via Rojo.

### Roblox Library

Get Knit from the Roblox library and place it in `ReplicatedStorage`.

## Quick Start

**Server boot script:**

```lua
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

for _, module in ipairs(game.ServerScriptService.Services:GetChildren()) do
    if module:IsA("ModuleScript") then require(module) end
end

Knit.Start():catch(warn):await()
```

**A service:**

```lua
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local MoneyService = Knit.CreateService {
    Name = "MoneyService",
    Client = {},
}

function MoneyService:KnitInit()
    self._moneyByUser = {}
end

function MoneyService.Client:GetMoney(player)
    return self.Server:GetMoney(player)
end

function MoneyService:GetMoney(player)
    return self._moneyByUser[player.UserId] or 0
end

return MoneyService
```

**Client controller calling the service:**

```lua
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local MoneyController = Knit.CreateController { Name = "MoneyController" }

function MoneyController:KnitStart()
    local MoneyService = Knit.GetService("MoneyService")
    MoneyService:GetMoney():andThen(function(money)
        print("You have", money)
    end)
end

return MoneyController
```

## Key API

| Symbol | Description |
|--------|-------------|
| `Knit.CreateService({ Name, Client })` | Registers a server singleton. Methods on `.Client` become remotes. |
| `Knit.CreateController({ Name })` | Registers a client singleton. |
| `Knit.Start()` | Boots the framework. Returns a [[Promise]]. |
| `Knit.GetService("Name")` | Client-side: returns a proxy where every `.Client` method is callable as a Promise-returning function. |
| `KnitInit()` | Lifecycle hook: runs before any `KnitStart`. Use for internal setup. |
| `KnitStart()` | Lifecycle hook: runs after all `KnitInit` finishes. Safe to cross-reference services. |

## When to Use / When Not to Use

**Use when:**
- Luau-only project that wants a prescribed service/controller structure
- The game is primarily UI, state, and event-driven (shops, progression, social)
- You want abundant community tutorials and examples

**Do not use when:**
- Writing TypeScript (use [[Flamework]] instead)
- Building a simulation-heavy game with thousands of entities (use [[Matter]] or [[Jecs]])
- You need extreme networking performance (consider ByteNet for buffer-based bandwidth optimization)
- You need active maintenance and security patches

## Alternatives

| Library | Trade-off |
|---------|-----------|
| [[Flamework]] | TypeScript-native successor with real DI, decorators, and type-safe networking. Requires roblox-ts. |
| [[Matter]] / [[Jecs]] | ECS paradigm. Better for entity-heavy games, worse for service-oriented ones. |
| [[Nevermore]] | Library pool, not a framework. More flexible, less prescriptive. |
| Stock Roblox + Rojo | No framework overhead, but all remote plumbing and boot ordering is manual. |

## Related

- [[Flamework]] -- TypeScript successor
- [[Promise]] -- used by Knit's client API
- [[framework-comparison]] -- full decision guide

## Sources

- [Knit README](wiki/raw/community/articles/library-readmes/knit-readme.md)
- [DevForum: You need to use the Knit Game Framework](wiki/raw/community/devforum/knit-game-framework-template.md)
- [Framework Comparison](wiki/raw/community/articles/architecture/framework-comparison.md)
- GitHub: https://github.com/Sleitnick/Knit
- Docs: https://sleitnick.github.io/Knit/
