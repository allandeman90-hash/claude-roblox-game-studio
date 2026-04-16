---
title: service-pattern
type: concept
category: concepts
subcategory: architecture
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/devforum/service-registry-design-pattern.md
  - wiki/raw/community/devforum/knit-game-framework-template.md
  - wiki/raw/community/devforum/roblox-ts-flamework-introduction.md
  - wiki/raw/community/articles/architecture/framework-comparison.md
related:
  - "[[client-server-split]]"
  - "[[module-lazy-loading]]"
  - "[[signal-pattern]]"
tags: [concept, architecture, services, framework]
---

# Service Pattern

> Wraps each game subsystem in a singleton module with a consistent lifecycle (`Init`, `Start`, `Stop`), registered in a central registry and started in dependency order at boot.

## What It Is

The service pattern organizes a Roblox game into a set of named singletons -- each owning a single concern (combat, inventory, shop, matchmaking). Services declare dependencies on each other and expose a public API for inter-service communication. A central registry initializes all services in topological order, ensuring dependencies are ready before dependents start.

This is the dominant architecture pattern for Roblox games in 2026, used by Knit, Flamework, and most custom frameworks.

## When to Use It

- Games with multiple interconnected systems (most production Roblox games).
- When you want auto-networking between client and server (Knit, Flamework).
- When you need clear lifecycle management (init before use, cleanup on stop).

Do NOT use the service pattern for entity-heavy simulations (thousands of bullets, enemies). Use an ECS (Matter, Jecs) for that. The two can coexist: services own player-facing concerns, ECS owns the simulation world.

## Implementation

### Minimal Service Module (No Framework)

```lua
-- ServerStorage/Services/CombatService.lua
local CombatService = {}

local Signal = require(game.ReplicatedStorage.Packages.GoodSignal)

-- Dependencies (resolved at init time)
local InventoryService
local PlayerDataService

-- Public events
CombatService.OnEnemyKilled = Signal.new()

function CombatService.Init()
    -- Resolve dependencies after all services are registered
    InventoryService = require(game.ServerStorage.Services.InventoryService)
    PlayerDataService = require(game.ServerStorage.Services.PlayerDataService)
end

function CombatService.Start()
    -- Connect to game events, start loops
end

function CombatService.DealDamage(attacker: Player, targetId: string, amount: number)
    -- Server-authoritative damage logic
end

return CombatService
```

### Service Registry (Custom)

```lua
-- ServerScriptService/ServiceLoader.server.lua
local ServerStorage = game:GetService("ServerStorage")

local services = {}

-- Discover all service modules
for _, module in ipairs(ServerStorage.Services:GetChildren()) do
    if module:IsA("ModuleScript") then
        local service = require(module)
        services[module.Name] = service
    end
end

-- Phase 1: Init (dependency resolution, no side effects)
for name, service in pairs(services) do
    if service.Init then
        service.Init()
    end
end

-- Phase 2: Start (connect events, begin loops)
for name, service in pairs(services) do
    if service.Start then
        task.spawn(service.Start)
    end
end
```

### Knit Service (Framework)

Knit automates remote creation and client-server wiring:

```lua
-- ServerScriptService/Services/ShopService.lua
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ShopService = Knit.CreateService({
    Name = "ShopService",
    Client = {
        -- Methods exposed to client automatically as RemoteFunctions
        PurchaseItem = function(self, player, itemId)
            -- Server validates and processes
        end,
    },
})

function ShopService:KnitInit()
    -- Called during Knit.Start(), before KnitStart
end

function ShopService:KnitStart()
    -- Called after all services are initialized
end

return ShopService
```

### Flamework Service (TypeScript)

```typescript
// src/server/services/shop-service.ts
import { Service, OnStart } from "@flamework/core";

@Service()
export class ShopService implements OnStart {
    onStart() {
        // Called after all services are initialized
    }

    purchaseItem(player: Player, itemId: string): boolean {
        // Server-authoritative logic
        return true;
    }
}
```

### Service Registry with Dependency Management

From the DevForum service-registry pattern by samjay22:

```lua
-- Full lifecycle states
-- UNINITIALIZED -> INITIALIZING -> INITIALIZED -> STARTING -> STARTED -> STOPPING -> STOPPED

-- Dependency declaration
local CombatService = {
    Name = "CombatService",
    Dependencies = { "InventoryService", "PlayerDataService" },
    Priority = 10,  -- lower = initialized first
}

-- Registry features:
-- - Circular dependency detection
-- - Priority-based initialization ordering
-- - Service state tracking (UNINITIALIZED through STOPPED)
-- - Optional vs required dependencies
-- - Tag-based service filtering
-- - Async service retrieval with timeout
```

## Variants

| Framework | Paradigm | Language | Key Feature |
|-----------|----------|----------|-------------|
| **Knit** | Services/Controllers | Luau | Auto-networking, archived but battle-tested |
| **Flamework** | DI/Services/Components | TypeScript | Compile-time DI, decorator-based |
| **Custom registry** | Varies | Luau | Full control, no external dependency |
| **Nevermore** | Library pool | Luau | 270 modules, no prescribed structure |
| **No framework** | Plain modules | Luau | Fine for small games |

### Decision Tree

```
Using TypeScript (roblox-ts)?
  Yes -> Flamework
  No ->
    Entity-heavy simulation (bullets, NPCs)?
      Yes -> Matter or Jecs (ECS)
      No ->
        Want a prescribed framework?
          Yes -> Knit (still solid for Luau)
          No -> Nevermore or plain modules
```

## Pitfalls

- **Singleton access tangles.** Without discipline, every service ends up requiring every other service. Use [[signal-pattern]] for loose coupling -- `CombatService` fires `OnEnemyKilled`, `QuestService` listens, neither requires the other.
- **Init vs Start confusion.** `Init` resolves dependencies and sets up internal state (no side effects). `Start` connects events and begins loops (side effects). Mixing these phases leads to race conditions.
- **Circular dependencies.** Service A requires B, B requires A. Solutions: extract shared logic to a third module, use signals for decoupling, or use [[module-lazy-loading]] to defer the require.
- **Client-server service mismatch.** In Knit/Flamework, server services and client controllers are separate. A client controller calling a server service method goes through a remote -- it is NOT a local function call. Treat it as a network boundary.

## Related

- [[client-server-split]] -- services exist on both sides of the boundary
- [[module-lazy-loading]] -- breaks circular dependencies between services
- [[signal-pattern]] -- signals are the event API exposed by services

## Sources

- [wiki/raw/community/devforum/service-registry-design-pattern.md](../raw/community/devforum/service-registry-design-pattern.md) -- full registry with lifecycle, dependency detection, tags
- [wiki/raw/community/devforum/knit-game-framework-template.md](../raw/community/devforum/knit-game-framework-template.md) -- Knit service/controller architecture
- [wiki/raw/community/devforum/roblox-ts-flamework-introduction.md](../raw/community/devforum/roblox-ts-flamework-introduction.md) -- Flamework singletons, components, lifecycle
- [wiki/raw/community/articles/architecture/framework-comparison.md](../raw/community/articles/architecture/framework-comparison.md) -- decision guide for picking a framework
