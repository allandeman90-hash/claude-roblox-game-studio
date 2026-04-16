---
title: Trove — Cleanup Task Tracker for Luau / Roblox
type: raw-source
source_url: https://sleitnick.github.io/RbxUtil/api/Trove/
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: library
author: Stephen Leitnick (Sleitnick)
tags: [trove, cleanup, janitor, disposable, lifecycle]
---

# Trove — Cleanup Task Tracker for Luau / Roblox

**Author:** Stephen Leitnick (Sleitnick)
**Source:** GitHub — `Sleitnick/RbxUtil` (modules/trove)
**Docs:** https://sleitnick.github.io/RbxUtil/api/Trove/

## What it is

A Trove is helpful for tracking any sort of object during runtime that needs to get cleaned up at some point. It is the modern successor to the older "Janitor" pattern popularized by Howmanysmall and Quenty. Trove collapses the common "I created N things and now need to destroy them all" problem into a single object with a single `:Destroy()` call.

This is the foundational cleanup utility in the modern Roblox OSS ecosystem. Every modern framework either uses Trove directly (Knit, WindShake) or reinvents the same pattern.

## Why you need it

Any non-trivial Roblox script creates a pile of things that must be released when a scope ends:

- `Instance`s that need `:Destroy()`
- `RBXScriptConnection`s that need `:Disconnect()`
- Custom objects with `:Destroy()` / `:destroy()` methods
- Functions that run as cleanup callbacks
- Threads started with `task.spawn` that need `task.cancel`

Without a tracker, the boilerplate is substantial. Typical pre-Trove code:

```lua
local conn1, conn2, conn3
local part
local thread

local function cleanup()
    if conn1 then conn1:Disconnect() end
    if conn2 then conn2:Disconnect() end
    if conn3 then conn3:Disconnect() end
    if part then part:Destroy() end
    if thread then task.cancel(thread) end
end
```

With Trove:

```lua
local trove = Trove.new()

trove:Connect(workspace.ChildAdded, onAdded)
trove:Connect(workspace.ChildRemoved, onRemoved)
trove:Connect(player.CharacterAdded, onChar)
trove:Add(Instance.new("Part"))
trove:Add(task.spawn(loop))

-- Later:
trove:Destroy()
```

## Supported types

Trove accepts anything destroyable: Instances, `RBXScriptConnection`s, functions, threads, and tables with `:Destroy`/`:Disconnect`/`:destroy`/`:disconnect` methods (either case works).

## Core API

### `:Add(object, [method])`

Register an object for tracking. When the Trove is cleaned, the object is disposed according to its type:

- Instance → `:Destroy()`
- RBXScriptConnection → `:Disconnect()`
- function → called as `fn()`
- thread → `task.cancel(thread)`
- table with `:Destroy` or `:destroy` → called

You can override the cleanup method with a string second arg.

```lua
local part = Instance.new("Part")
trove:Add(part)
trove:Destroy() -- Part is destroyed automatically
```

### `:Construct(class, ...)`

Creates an object and adds it to the Trove in one call. Equivalent to `trove:Add(Class.new(...))`.

```lua
local Signal = require(somewhere.Signal)
local s = trove:Construct(Signal)
```

### `:Connect(signal, fn)`

Shorthand for `trove:Add(signal:Connect(fn))`.

```lua
trove:Connect(workspace.ChildAdded, function(instance)
    print(instance.Name .. " added")
end)
```

### `:Extend()`

Creates a sub-Trove and adds it as a tracked child. When the parent Trove is cleaned, the sub-Trove is cleaned too. This is how you model hierarchical lifetimes — e.g. a character-scoped Trove that cleans up when the character dies, inside a player-scoped Trove that cleans up when the player leaves.

### `:AttachToInstance(instance)`

Inverts ownership: instead of the Trove controlling the instance's lifetime, the instance's destruction triggers the Trove's cleanup. Useful when you want to cleanly bind a bag of resources to an Instance (e.g. a NPC model and all its connections).

### `:Clean()` and `:Destroy()`

Both run cleanup. After `Destroy()`, the Trove is unusable. After `Clean()`, it can be reused.

## Canonical pattern: one Trove per scope

The idiomatic way to use Trove is one Trove per well-defined scope — per player, per character, per UI screen, per ability cast. When that scope ends, destroy the Trove and all its tracked work goes away at once. This makes scope-based lifetime reasoning trivial, which is the hard problem in real Roblox code.

## Source

Docs: https://sleitnick.github.io/RbxUtil/api/Trove/
Source: https://github.com/Sleitnick/RbxUtil/tree/main/modules/trove
Captured: 2026-04-15
