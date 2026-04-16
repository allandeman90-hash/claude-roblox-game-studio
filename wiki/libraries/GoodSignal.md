---
title: GoodSignal
type: library
category: libraries
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/goodsignal-readme.md
  - wiki/raw/community/devforum/goodsignal-lua-signal-comparison.md
related: [[[Trove]], [[Knit]], [[Fusion]]]
tags: [library, signal, events, memory-management]
---

# GoodSignal

> Leak-free pure-Lua signal implementation with full RBXScriptSignal API parity. The reference implementation for custom signals in Roblox games.

## Summary

GoodSignal is a custom signal class by stravant (a Roblox engineer) that replicates the full API of `RBXScriptSignal` without the memory-leak problems of BindableEvent-based signals. It is implemented in pure Lua using the `task` library, so disconnected handlers are immediately eligible for garbage collection. At approximately 100 lines of code with zero dependencies, it is the reference implementation that most other Roblox signal libraries are based on.

**Maintainer:** stravant
**Status:** Stable (the code is effectively complete)

## Installation

### Wally

```toml
[dependencies]
GoodSignal = "stravant/goodsignal@latest"
```

### Inline copy

GoodSignal is often copy-pasted directly into projects because it is ~100 lines with no dependencies. Both approaches are common in the ecosystem.

## Quick Start

```lua
local Signal = require(ReplicatedStorage.Packages.GoodSignal)

-- Create a signal
local onDamage = Signal.new()

-- Connect a handler
local connection = onDamage:Connect(function(amount, source)
    print("Took", amount, "damage from", source)
end)

-- Fire the signal
onDamage:Fire(25, "Enemy")

-- Wait for the next fire (yields)
local amount, source = onDamage:Wait()

-- Disconnect
connection:Disconnect()

-- Disconnect all handlers
onDamage:DisconnectAll()
```

## Key API

| Symbol | Description |
|--------|-------------|
| `Signal.new()` | Creates a new signal instance. |
| `signal:Connect(fn)` | Connects a handler. Returns a connection with `:Disconnect()`. Handlers run via `task.spawn` on separate threads. |
| `signal:Fire(...)` | Synchronously invokes every connected handler in connection order. |
| `signal:Wait()` | Yields the current thread until the signal fires. Returns the fired arguments. |
| `connection:Disconnect()` | Removes a single handler. The closure is immediately GC-eligible. |
| `signal:DisconnectAll()` | Removes all handlers. |

## Why Not BindableEvent

The traditional approach wraps a `BindableEvent` instance for custom signals. This has problems:

1. **Memory leaks.** `BindableEvent:Fire` serializes arguments (deep-copying tables). Unhandled exceptions in connected handlers can keep the closure alive even after disconnection.
2. **Serialization overhead.** Arguments pass through the Roblox object model rather than being passed by reference.
3. **Instance system overhead.** Each signal creates a Roblox Instance, engaging the instance lifecycle machinery.

GoodSignal avoids all three: arguments pass by reference, the connection list is a plain linked list (O(1) connect/disconnect), and cleanup is immediate on disconnection.

## Ecosystem Adoption

GoodSignal or variants of its pattern are used by:

- **Sleitnick's Signal** (in RbxUtil) -- slight reimplementation of the same pattern
- **[[Knit]]'s internal signal** -- based on this approach
- **[[Fusion]]'s observer primitives** -- reactive updates flow through a similar dispatch
- **[[Trove]]** -- `trove:Connect(signal, handler)` works uniformly on GoodSignal and native `RBXScriptSignal` because the API shapes match

## When to Use / When Not to Use

**Use when:**
- You need custom events for your own modules (not wrapping existing Roblox events)
- Memory-leak-free signal dispatch is important (high-frequency signals, long-lived connections)
- You want API parity with `RBXScriptSignal` so utilities like [[Trove]] work uniformly

**Do not use when:**
- You already have a native `RBXScriptSignal` (e.g., `Part.Touched`) -- use it directly
- You need cross-network signaling (use RemoteEvent)

## Alternatives

| Library | Trade-off |
|---------|-----------|
| Sleitnick Signal (RbxUtil) | Same pattern, slightly different implementation. Distributed via Wally. |
| FastSignal | Faster but sacrifices correctness (yielding in handlers blocks the caller). |
| BindableEvent wrapper | Built-in, but has memory leak and serialization overhead. |

## Related

- [[Trove]] -- cleanup utility that works with GoodSignal connections
- [[Knit]] -- uses the same signal pattern internally
- [[Fusion]] -- observer system based on similar dispatch

## Sources

- [GoodSignal README](wiki/raw/community/articles/library-readmes/goodsignal-readme.md)
- [DevForum: Lua Signal Class Comparison & Optimal GoodSignal](wiki/raw/community/devforum/goodsignal-lua-signal-comparison.md)
- GitHub: https://github.com/stravant/goodsignal
