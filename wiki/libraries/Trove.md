---
title: Trove
type: library
category: libraries
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/trove-readme.md
  - wiki/raw/community/devforum/cleanup-modules-comparison.md
related: [[[GoodSignal]], [[Fusion]], [[Knit]]]
tags: [library, cleanup, lifecycle, memory-management]
---

# Trove

> Cleanup task tracker that collapses "I created N things and need to destroy them all" into a single `:Destroy()` call. The modern successor to Janitor and Maid.

## Summary

Trove is a cleanup utility by Stephen Leitnick (Sleitnick), part of the RbxUtil collection. It tracks Instances, connections, threads, functions, and custom objects during runtime, then cleans them all up with one call. It is the foundational cleanup utility in the modern Roblox OSS ecosystem -- every modern framework either uses Trove directly (Knit, WindShake) or reinvents the same pattern. Trove replaces the older Janitor (Howmanysmall) and Maid (Quenty) patterns.

**Maintainer:** Sleitnick
**Status:** Active (part of RbxUtil)

## Installation

### Wally

```toml
[dependencies]
Trove = "sleitnick/trove@latest"
```

## Quick Start

```lua
local Trove = require(ReplicatedStorage.Packages.Trove)

local trove = Trove.new()

-- Track connections
trove:Connect(workspace.ChildAdded, function(instance)
    print(instance.Name .. " added")
end)

-- Track instances
local part = Instance.new("Part")
part.Parent = workspace
trove:Add(part)

-- Track threads
trove:Add(task.spawn(function()
    while true do
        task.wait(1)
        print("tick")
    end
end))

-- Track custom objects with :Destroy()
local signal = trove:Construct(Signal)

-- Clean everything at once
trove:Destroy()
```

## Key API

| Symbol | Description |
|--------|-------------|
| `Trove.new()` | Creates a new Trove instance. |
| `trove:Add(object, [method])` | Registers an object for cleanup. Auto-detects type: Instance -> `:Destroy()`, connection -> `:Disconnect()`, function -> called, thread -> `task.cancel`, table with `:Destroy`/`:destroy` -> called. Optional second arg overrides cleanup method. |
| `trove:Connect(signal, fn)` | Shorthand for `trove:Add(signal:Connect(fn))`. Works with both `RBXScriptSignal` and [[GoodSignal]]. |
| `trove:Construct(class, ...)` | Creates `class.new(...)` and adds it to the Trove in one call. |
| `trove:Extend()` | Creates a child Trove tracked by the parent. Parent cleanup cascades to children. Models hierarchical lifetimes. |
| `trove:AttachToInstance(instance)` | Inverts ownership: the Instance's destruction triggers the Trove's cleanup. |
| `trove:Clean()` | Runs all cleanup tasks. Trove is reusable afterward. |
| `trove:Destroy()` | Runs all cleanup tasks. Trove is unusable afterward. |

## Supported Cleanup Types

| Type | Cleanup action |
|------|---------------|
| `Instance` | `:Destroy()` |
| `RBXScriptConnection` | `:Disconnect()` |
| `function` | Called as `fn()` |
| `thread` | `task.cancel(thread)` |
| Table with `:Destroy` or `:destroy` | Method called |
| Table with `:Disconnect` or `:disconnect` | Method called |

## Canonical Pattern: One Trove Per Scope

The idiomatic usage is one Trove per well-defined lifetime scope:

- **Per player:** created on `PlayerAdded`, destroyed on `PlayerRemoving`
- **Per character:** created on `CharacterAdded`, destroyed on death or respawn
- **Per UI screen:** created when screen opens, destroyed when it closes
- **Per ability cast:** created on activation, destroyed on completion

Hierarchical lifetimes use `:Extend()` -- a character Trove inside a player Trove ensures character cleanup on death, and cascading cleanup on player leave.

## When to Use / When Not to Use

**Use when:**
- Any script creates multiple objects (connections, instances, threads) that need coordinated cleanup
- You want deterministic, scope-based lifetime management
- Working with UI, character systems, NPC behavior, or any long-lived subsystem

**Do not use when:**
- You have a single connection to clean up (a bare `:Disconnect()` is simpler)
- Using [[Fusion]] (Fusion scopes handle cleanup natively with the same pattern)

## Alternatives

| Library | Trade-off |
|---------|-----------|
| Janitor (Howmanysmall) | Predecessor. More methods, including custom cleanup method per object. Still used in some projects. |
| Maid (Quenty / Nevermore) | Oldest cleanup pattern. Part of [[Nevermore]]. Rawest implementation. |
| Fusion scopes | Fusion's `scope:doCleanup()` solves the same problem for reactive objects. |

## Related

- [[GoodSignal]] -- signals cleaned up by Trove's `:Connect`
- [[Fusion]] -- scopes provide equivalent cleanup for reactive objects
- [[Knit]] -- uses Trove internally

## Sources

- [Trove README / Docs](wiki/raw/community/articles/library-readmes/trove-readme.md)
- [DevForum: Best Cleanup Module - Maid vs Trove vs Janitor](wiki/raw/community/devforum/cleanup-modules-comparison.md)
- Docs: https://sleitnick.github.io/RbxUtil/api/Trove/
- Source: https://github.com/Sleitnick/RbxUtil/tree/main/modules/trove
