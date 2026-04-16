---
title: BindableEvent
type: service
category: services
subcategory: networking
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/BindableEvent.md
related:
  - "[[RemoteEvent]]"
  - "[[signal-pattern]]"
  - "[[BindableFunction]]"
tags: [roblox-class, events]
---

# BindableEvent

> Asynchronous one-way communication between scripts on the same side of the client-server boundary. [[RemoteEvent]]

## Summary

BindableEvent enables custom events through asynchronous one-way communication between scripts on the **same side** of the client-server boundary (server-to-server or client-to-client only). When `:Fire()` is called, the firing script does **not** yield and the target function receives the passed arguments with certain limitations.

BindableEvents create threads for each connected function, so even if one handler errors, others continue executing. This makes them useful for decoupled pub/sub patterns within a single context (e.g., multiple server scripts reacting to a game event).

For two-way same-side communication, use `BindableFunction`. For cross-boundary communication (server to client or vice versa), use [[RemoteEvent]] instead. For complex in-code eventing with better parameter semantics, consider a Signal library (GoodSignal, FastSignal) -- see [[signal-pattern]].

## API Surface

### Properties

_No public properties._

### Methods

- `:Fire(arguments: Tuple) -> ()` -- Fires the event, invoking all connected handlers. Does not yield, even if no script is connected or if a connected function yields.

### Events

- `.Event:Connect(fn(arguments: Tuple))` -- Fires when any script calls `:Fire()` on the same BindableEvent instance. Receives the same arguments passed to `:Fire()`.

## Budgets and Limits

No explicit rate limits documented. However, tables and non-primitive types passed through `:Fire()` are **copied** (not passed by reference). Metatables are lost. This can be expensive for large data structures.

## Common Patterns

### Basic same-side event bus

```lua
-- ServerScriptService/EventBus.server.lua
local roundEndEvent = Instance.new("BindableEvent")
roundEndEvent.Name = "RoundEnd"
roundEndEvent.Parent = game.ServerStorage

-- Fire from game loop
roundEndEvent:Fire("TeamA", 15)
```

```lua
-- ServerScriptService/Rewards.server.lua
local roundEndEvent = game.ServerStorage:WaitForChild("RoundEnd")
roundEndEvent.Event:Connect(function(winnerTeam: string, score: number)
    print(winnerTeam, "won with score", score)
end)
```

## Pitfalls

- **Parameter copying**: Tables are passed by value-like copy. Changes to a table after `:Fire()` do not propagate to handlers. Metatables are stripped.
- **Not cross-boundary**: BindableEvent does NOT communicate between server and client. Use [[RemoteEvent]] for that.
- **No return value**: `:Fire()` is fire-and-forget. For request-response, use `BindableFunction`.
- **Signal libraries preferred**: For complex in-script eventing, a Signal library (GoodSignal, FastSignal) avoids the parameter-copy overhead and metatables limitation.

## Related

- [[RemoteEvent]] -- network variant for cross-boundary communication
- [[signal-pattern]] -- more flexible in-code alternative
- [[BindableFunction]] -- two-way same-side communication

## Sources

- [wiki/raw/roblox-creator-docs/services/BindableEvent.md](../raw/roblox-creator-docs/services/BindableEvent.md)
