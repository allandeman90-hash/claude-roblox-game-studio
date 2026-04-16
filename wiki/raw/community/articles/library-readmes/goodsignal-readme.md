---
title: GoodSignal — Leak-Free Signal Implementation for Roblox Luau
type: raw-source
source_url: https://github.com/stravant/goodsignal
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: library
author: stravant (Roblox engineer)
tags: [signal, goodsignal, bindable-event, memory-leak, events]
---

# GoodSignal — Leak-Free Signal Implementation for Roblox Luau

**Author:** stravant (Roblox engineer)
**Source:** GitHub — `stravant/goodsignal`

## What it is

GoodSignal is a Roblox Lua Signal implementation that has full API and behavioral parity with Roblox's RBXScriptSignal. It is the reference implementation for writing custom signals in Roblox games — not a replacement for native `RBXScriptSignal` on Roblox events you already have, but the answer to "how do I make my own signal for my own events?"

Before GoodSignal, the canonical approach was to create a `BindableEvent` and wrap it. GoodSignal exists because that approach has a subtle but real memory-leak problem, and stravant (a Roblox engineer) wrote this pure-Lua alternative to demonstrate the fix.

## The problem with BindableEvent-based signals

```lua
-- The traditional approach:
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._bindable = Instance.new("BindableEvent")
    return self
end

function Signal:Connect(fn)
    return self._bindable.Event:Connect(fn)
end

function Signal:Fire(...)
    self._bindable:Fire(...)
end
```

The issue: `BindableEvent:Fire` serializes its arguments. For tables and userdata, this means deep-copying. For Instances, it means re-referencing them (which can keep them alive). For any unhandled exception inside a connected function, the BindableEvent machinery can leak the function closure even if the connection is disconnected.

GoodSignal is implemented in pure Lua (using the `task` library, rather than internally using a BindableEvent), so it does not suffer from memory leaks. Specifically: when you disconnect a connection, the closure holding the function reference is eligible for GC immediately. There's no hidden internal storage keeping it alive.

## API (identical to RBXScriptSignal)

### Construction

```lua
local Signal = require(ReplicatedStorage.Packages.GoodSignal)
local sig = Signal.new()
```

### Connecting

```lua
local connection = sig:Connect(function(arg1, arg2)
    print("Got:", arg1, arg2)
end)
```

Returns a connection object with a `:Disconnect()` method, matching `RBXScriptConnection`.

### Firing

```lua
sig:Fire("hello", 42)
```

Synchronously calls every connected handler in the order they were connected. Handlers are called via `task.spawn`, so they run on separate threads and a yield in one handler doesn't block others.

### Waiting

```lua
local a, b = sig:Wait()
```

Blocks the current thread until the signal fires, then returns the fired arguments. Direct equivalent to `RBXScriptSignal:Wait()`.

### Cleanup

```lua
connection:Disconnect()   -- Drop one handler
sig:DisconnectAll()       -- Drop everything
```

## Why "exact API parity" matters

Because GoodSignal matches the shape of `RBXScriptSignal` exactly, code that expects to take "a signal-like object" (custom signals, RBXScriptSignals, etc.) can treat them uniformly. For example, utilities like Trove's `:Connect` method:

```lua
trove:Connect(signalOrScriptSignal, handler)
```

...work on GoodSignal instances and native `RBXScriptSignal`s without special-casing, because they have the same `Connect` method shape.

This parity also means GoodSignal is a drop-in replacement anywhere a BindableEvent-wrapped signal was previously used. Swap the require, everything else is unchanged.

## Performance characteristics

GoodSignal is measurably faster than BindableEvent-wrapped signals because:

- **No serialization overhead.** Arguments are passed directly by reference, not deep-copied.
- **No trip through the Roblox object model.** Pure-Lua dispatch doesn't engage the instance system.
- **Connection list is a plain linked list**, so connect/disconnect are O(1).

For signals fired at high frequency (per-frame or per-physics-step), this matters. For occasional events, the difference is negligible but the memory-leak fix is still the real win.

## Where it shows up in the ecosystem

GoodSignal or variants of it are used by:

- **Sleitnick's Signal** (in RbxUtil) — a slight reimplementation of the same pattern
- **Knit's internal signal** — also based on this approach
- **Fusion's observer primitives** — reactive updates flow through a similar pattern
- **Custom signals in any project that takes cleanup seriously**

The actual stravant/goodsignal file is often copy-pasted into projects rather than installed as a package, because it's ~100 lines of pure Lua and has no dependencies. Wally distribution exists, but the inline-copy pattern is common.

## Source

Original URL: https://github.com/stravant/goodsignal
Captured: 2026-04-15
