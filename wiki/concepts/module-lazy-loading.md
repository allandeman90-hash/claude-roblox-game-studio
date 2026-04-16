---
title: module-lazy-loading
type: concept
category: concepts
subcategory: architecture
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/devforum/service-registry-design-pattern.md
  - wiki/raw/community/articles/architecture/framework-comparison.md
related:
  - "[[client-server-split]]"
  - "[[service-pattern]]"
  - "[[streaming-enabled]]"
tags: [concept, architecture, modules, circular-dependencies]
---

# Module Lazy Loading

> Deferring `require()` of a module until first use, avoiding upfront initialization cost and breaking circular dependency chains.

## What It Is

In Roblox, `require(module)` executes the module immediately and caches the result. When module A requires module B at the top level, and module B requires module A, Roblox detects the cycle and one of the two calls returns an incomplete (partially initialized) table. This is a circular dependency, and it is the most common architecture bug in medium-to-large Roblox projects.

Lazy loading defers the `require()` call to the first time the dependency is actually used. The module reference is resolved at runtime rather than at load time, by which point both modules have finished their top-level initialization.

## When to Use It

- **Breaking circular dependencies.** Module A needs to call a function from module B, and vice versa. One of them (or both) can lazy-load the other.
- **Optional features.** A heavy module (e.g., a debug overlay) that is only needed when a flag is enabled.
- **Reducing startup latency.** If a module takes significant time to initialize (parsing large config tables, connecting to external services), deferring its load until first use can speed up server start.

Do NOT lazy-load everything. Eager require at module top is the standard and should remain the default. Lazy loading is a targeted tool for specific problems.

## Implementation

### Pattern 1: Lazy Require Wrapper

```lua
-- Shared/Util/LazyRequire.lua
local function lazyRequire(moduleInstance: ModuleScript)
    local cached = nil
    return function()
        if not cached then
            cached = require(moduleInstance)
        end
        return cached
    end
end

return lazyRequire
```

Usage:

```lua
-- ServiceA.lua
local lazyRequire = require(game.ReplicatedStorage.Shared.Util.LazyRequire)

-- Defer the require -- returns a function, not the module
local getServiceB = lazyRequire(game.ServerStorage.Services.ServiceB)

function ServiceA.doSomething()
    -- ServiceB is resolved here, on first call, not at module load
    local ServiceB = getServiceB()
    ServiceB.handleAction()
end

return ServiceA
```

### Pattern 2: Init-Phase Resolution

Used by the [[service-pattern]] (Knit, Flamework, custom registries). Dependencies are resolved during the `Init` phase, after all modules have been required but before any `Start` logic runs.

```lua
-- CombatService.lua
local CombatService = {}

-- NOT required at top level
local InventoryService

function CombatService.Init()
    -- By this point, all services have been require()'d by the registry
    InventoryService = require(game.ServerStorage.Services.InventoryService)
end

function CombatService.Start()
    -- InventoryService is guaranteed to be available here
end

return CombatService
```

This is the recommended approach when using a service registry. The registry ensures all modules are loaded before any `Init` runs, so the circular dependency never materializes.

### Pattern 3: Signal-Based Decoupling

Instead of requiring the other module at all, communicate through a [[signal-pattern]]:

```lua
-- CombatService.lua (does NOT require QuestService)
local Signal = require(...)
CombatService.OnEnemyKilled = Signal.new()

function CombatService.processKill(player, enemyId)
    -- ...
    CombatService.OnEnemyKilled:Fire(player, enemyId)
end

-- QuestService.lua (does NOT require CombatService)
-- Instead, the service registry or a bootstrap script wires them:
CombatService.OnEnemyKilled:Connect(function(player, enemyId)
    QuestService.advanceObjective(player, "killQuest", "kills", 1)
end)
```

This eliminates the dependency entirely rather than deferring it.

## Variants

| Approach | Complexity | When to use |
|----------|-----------|-------------|
| **Lazy require wrapper** | Low | Ad-hoc fixes for 1-2 circular pairs |
| **Init-phase resolution** | Medium | Service registries with dependency ordering |
| **Signal decoupling** | Low | When modules only need to notify each other, not call methods |
| **Event bus / middleware** | High | Large projects with many cross-cutting concerns |

## Pitfalls

- **Hidden first-access latency.** The first call to a lazy-loaded module pays the full `require()` cost. If this happens during a latency-sensitive path (e.g., processing a remote event), it can cause a noticeable hitch. Pre-warm during `Init` instead.
- **Harder to trace dependencies.** Lazy loading hides the dependency graph from static analysis. Tools like Selene or grep for `require(` will not find the dependency. Comment the lazy require clearly.
- **Not a substitute for good architecture.** If two modules have a genuine circular dependency, lazy loading is a band-aid. The real fix is usually to extract the shared concern into a third module or use signals.
- **Require caching.** Roblox caches `require()` results by ModuleScript identity. Multiple lazy calls to the same module return the same table. This is expected and correct.

## Related

- [[client-server-split]] -- lazy loading is sometimes needed when shared modules have different server/client paths
- [[service-pattern]] -- provides Init-phase resolution as a structured alternative
- [[streaming-enabled]] -- analogous concept for content: defer loading 3D content until needed

## Sources

- [wiki/raw/community/devforum/service-registry-design-pattern.md](../raw/community/devforum/service-registry-design-pattern.md) -- dependency management and lifecycle ordering
- [wiki/raw/community/articles/architecture/framework-comparison.md](../raw/community/articles/architecture/framework-comparison.md) -- framework patterns for dependency resolution
