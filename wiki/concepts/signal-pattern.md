---
title: signal-pattern
type: concept
category: concepts
subcategory: event-handling
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/devforum/goodsignal-lua-signal-comparison.md
  - wiki/raw/community/devforum/fastsignal-consistent-signal-library.md
  - wiki/raw/community/articles/library-readmes/goodsignal-readme.md
related:
  - "[[trove-maid-cleanup]]"
  - "[[BindableEvent]]"
  - "[[RemoteEvent]]"
  - "[[service-pattern]]"
tags: [concept, event-handling, signals, pub-sub]
---

# Signal Pattern

> Pure-Lua pub/sub primitives that match the `RBXScriptSignal` API without the serialization overhead or memory-leak risk of `BindableEvent`.

## What It Is

A Signal is a custom event object that provides `:Connect`, `:Fire`, `:Wait`, `:Once`, and `:DisconnectAll` methods. Signals enable intra-server event coordination -- one module fires, any number of listeners react -- without coupling the producer to the consumers. Unlike `BindableEvent`, custom signals pass arguments by reference (no deep-copy), run in pure Lua (no trip through the instance system), and release memory immediately on disconnect.

## When to Use It

- **Decoupling services.** `CombatService` fires `OnEnemyKilled`; `QuestService` and `LeaderboardService` both listen. Neither knows the other exists.
- **Replacing BindableEvent.** Any place you would create `Instance.new("BindableEvent")` purely for intra-script communication, use a Signal instead.
- **Trove/Maid integration.** Connections from custom signals work with [[trove-maid-cleanup]] the same way `RBXScriptConnection` does, because the API shape matches.

Do NOT use signals for client-server communication -- that is the domain of [[RemoteEvent]].

## Implementation

### GoodSignal (Recommended)

GoodSignal by stravant is the reference implementation. It achieves ~2x the performance of SimpleSignal while maintaining full correctness (safe disconnect during iteration, no memory leaks, proper yield handling).

**Key design decisions:**
- Uses an intrusive linked list for the connection chain. Disconnected nodes remain traversable via their `next` pointer, so iteration is stable even when handlers disconnect other handlers mid-fire.
- Handlers are invoked via `task.spawn`, running on separate threads. A yield in one handler does not block others.
- Coroutines are recycled across invocations -- only allocated when a handler actually yields.
- Double-disconnect throws an error by design, treating it as a bug rather than silently ignoring.

```lua
local Signal = require(game.ReplicatedStorage.Packages.GoodSignal)

-- Create
local onDamageDealt = Signal.new()

-- Connect
local connection = onDamageDealt:Connect(function(target, amount)
    print(target.Name, "took", amount, "damage")
end)

-- Fire (synchronous dispatch to all handlers)
onDamageDealt:Fire(targetNPC, 50)

-- Wait (blocks current thread until next fire)
task.spawn(function()
    local target, amount = onDamageDealt:Wait()
    print("Waited for:", target.Name, amount)
end)

-- Once (auto-disconnects after first fire)
onDamageDealt:Once(function(target, amount)
    print("First hit:", target.Name)
end)

-- Cleanup
connection:Disconnect()
onDamageDealt:DisconnectAll()
```

### FastSignal (Performance-Critical Alternative)

FastSignal by LucasMZ trades correctness for maximum speed. Yielding in handlers blocks the calling thread. Connecting new handlers during execution causes unpredictable ordering. Use only in hot paths where the handler contract is tightly controlled.

**Additional features over GoodSignal:**
- `.Connected` property on connections
- `:Destroy()` method that prevents new connections
- Adaptive mode that auto-detects Deferred or Immediate signal behavior
- Full type declarations for IDE support
- Available on Wally as `lucasmzreal/fastsignal`

### Performance Comparison

From stravant's benchmark (microseconds per operation):

| Operation | FastSignal | GoodSignal | SimpleSignal | BindableEvent |
|-----------|-----------|-----------|-------------|--------------|
| CreateAndFire | 0.6 us | 1.2 us | 2.4 us | 18.5 us |
| Fire | 0.2 us | 0.8 us | 3.8 us | 3.2 us |
| FireManyHandlers | 0.2 us | 4.4 us | 15.2 us | 6.0 us |

GoodSignal is the right default. FastSignal is warranted only when profiling shows signal overhead is a measurable bottleneck.

## Variants

| Library | Correctness | Speed | Extra features | Install |
|---------|-------------|-------|----------------|---------|
| **GoodSignal** (stravant) | Full | Fast | Minimal API, ~100 lines | Copy-paste or Wally |
| **FastSignal** (LucasMZ) | Partial (no safe mid-fire disconnect) | Fastest | `.Connected`, `:Destroy`, adaptive mode, types | Wally `lucasmzreal/fastsignal` |
| **Sleitnick Signal** (RbxUtil) | Full | Fast | Reimplementation of GoodSignal | Wally `sleitnick/signal` |
| **Knit internal Signal** | Full | Fast | Bundled with Knit | Knit framework |
| **BindableEvent wrapper** | Mostly | Slow | Native Roblox | Built-in |

## Pitfalls

- **Memory leaks from undisconnected handlers.** If a module connects to a signal and never disconnects, the handler closure stays alive. Use [[trove-maid-cleanup]] to bind signal connections to the lifecycle of the owning object.
- **BindableEvent serialization cost.** `BindableEvent:Fire` deep-copies table arguments. Passing large tables through a BindableEvent is significantly slower than through a pure-Lua signal. This is the #1 reason to migrate from BindableEvent to GoodSignal.
- **Yielding in handlers.** With GoodSignal, yielding is safe but the handler will resume on a different frame. With FastSignal, yielding blocks the entire `Fire` call. Know which library you are using.
- **Confusing signals with remotes.** Signals are intra-server only. They do not cross the client-server boundary. For that, use [[RemoteEvent]].

## Related

- [[trove-maid-cleanup]] -- cleanup pattern for signal connections
- [[BindableEvent]] -- the built-in Roblox equivalent (replaced by signals in most modern code)
- [[RemoteEvent]] -- client-server communication (different domain)
- [[service-pattern]] -- services expose signals as their public event API

## Sources

- [wiki/raw/community/devforum/goodsignal-lua-signal-comparison.md](../raw/community/devforum/goodsignal-lua-signal-comparison.md) -- stravant's comparison and GoodSignal recommendation
- [wiki/raw/community/devforum/fastsignal-consistent-signal-library.md](../raw/community/devforum/fastsignal-consistent-signal-library.md) -- FastSignal features and API
- [wiki/raw/community/articles/library-readmes/goodsignal-readme.md](../raw/community/articles/library-readmes/goodsignal-readme.md) -- GoodSignal deep-dive and ecosystem adoption
