---
title: Knit — Lightweight Game Framework for Roblox
type: raw-source
source_url: https://github.com/Sleitnick/Knit
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: framework
author: Stephen Leitnick (Sleitnick)
tags: [framework, services, controllers, networking, archived]
---

# Knit — Lightweight Game Framework for Roblox

**Author:** Stephen Leitnick (Sleitnick)
**Source:** GitHub — `Sleitnick/Knit`
**Status:** Archived — no longer maintained (still in wide community use)

## What it is

Knit is a lightweight framework for Roblox that simplifies communication between the core parts of a game and seamlessly bridges the gap between the server and the client. It has been battle-tested in the Roblox ecosystem and works at scale. Its primary conceptual contribution is to organize game logic around **Services** on the server and **Controllers** on the client, with a built-in networking layer that makes the server/client boundary nearly invisible.

> **Status:** The repo is archived. Sleitnick has moved away from maintaining it, but it remains one of the most-used community frameworks and is fully functional. The successor pattern in his work is the smaller "Util" modules in RbxUtil.

## Why Knit

Without a framework, Roblox developers manually create `RemoteEvent`/`RemoteFunction` instances in the DataModel, require their own bootstrap modules in a specific order, and hand-roll cross-module communication. Knit replaces all of that with two simple ideas:

- **Services** are singletons living on the server. They own domain logic (e.g., a MoneyService, an InventoryService, a QuestService).
- **Controllers** are singletons living on the client. They consume services and drive UI/input.

A service's `.Client` table is its public network API — any method on `.Client` is automatically exposed to clients as a callable remote. No manual RemoteEvent creation, no folder nesting. You literally write a server method and call it from the client.

## Installation

**Roblox Studio workflow:**
1. Get Knit from the Roblox library.
2. Place Knit directly inside `ReplicatedStorage`.

**Rojo + Wally workflow:**
1. Add to `wally.toml`:
   ```toml
   [dependencies]
   Knit = "sleitnick/knit@^1"
   ```
2. Use Rojo to sync the Wally `Packages` folder into `ReplicatedStorage.Packages`.

## Boot pattern

The boot script is identical in shape on both sides:

```lua
-- Server
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Load all service modules inside ServerScriptService/Services
for _, module in ipairs(game.ServerScriptService.Services:GetChildren()) do
    if module:IsA("ModuleScript") then
        require(module)
    end
end

Knit.Start():catch(warn):await()
```

```lua
-- Client
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

for _, module in ipairs(game.StarterPlayer.StarterPlayerScripts.Controllers:GetChildren()) do
    if module:IsA("ModuleScript") then
        require(module)
    end
end

Knit.Start():catch(warn):await()
```

`Knit.Start()` returns a Promise. Using `:catch(warn):await()` is the canonical idiom — catch surfaces any boot error, and `await` yields the calling script until the framework is fully ready.

## Services

```lua
-- MoneyService.lua
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local MoneyService = Knit.CreateService {
    Name = "MoneyService",
    Client = {},  -- Anything here is exposed to clients
}

function MoneyService:GetMoney(player)
    return self._moneyByUser[player.UserId] or 0
end

function MoneyService:GiveMoney(player, amount)
    self._moneyByUser[player.UserId] = (self._moneyByUser[player.UserId] or 0) + amount
end

-- Client-exposed method: note the colon on Client, and the `player` first arg
function MoneyService.Client:GetMoney(player)
    return self.Server:GetMoney(player)  -- Delegate to server method
end

function MoneyService:KnitInit()
    self._moneyByUser = {}
end

function MoneyService:KnitStart()
    -- Called after all services have init'd
end

return MoneyService
```

Two lifecycle hooks:
- `KnitInit` — runs on every service before any `KnitStart` runs. Use for internal setup that other services may depend on.
- `KnitStart` — runs after all `KnitInit` finishes. Safe to call into other services here.

This two-phase boot is how Knit guarantees services can reference each other without caring about load order.

## Controllers

```lua
-- MoneyController.lua
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local MoneyController = Knit.CreateController {
    Name = "MoneyController",
}

function MoneyController:KnitInit() end

function MoneyController:KnitStart()
    local MoneyService = Knit.GetService("MoneyService")
    MoneyService:GetMoney():andThen(function(money)
        print("You have", money)
    end)
end

return MoneyController
```

`Knit.GetService("MoneyService")` on the client returns a **proxy object** where every `.Client` method on the server is callable as a Promise-returning method. You never see a RemoteEvent, never see `:InvokeServer`, never see `.OnClientEvent`. Knit generates all of that under the hood.

## Why it mattered

Before Knit (and its predecessor Aero), every Roblox team invented their own bootstrap system. Knit standardized one good-enough pattern: two-phase init, singleton services, and automatic remote generation. Even though the repo is archived, most of the post-2021 community frameworks (Flamework, WindShake, etc.) trace their vocabulary back to Knit.

## When not to use Knit

- **New TypeScript projects**: Flamework (roblox-ts native) is the de-facto successor and offers stronger typing, decorators, and DI.
- **Pure ECS games**: Matter or Jecs fit better than services/controllers.
- **Extreme perf networking**: Knit's remote layer is fine for 99% of games, but buffer-based libs like ByteNet can cut bandwidth dramatically for things like projectile replication.

## Source

Original URL: https://github.com/Sleitnick/Knit
Documentation: https://sleitnick.github.io/Knit/
Captured: 2026-04-15
