---
title: Connection Leaks
type: performance
category: performance
subcategory: memory
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/memory/connection-memory-leaks.md
  - wiki/raw/community/performance/memory/garbage-collection-guide.md
related:
  - "[[server-memory-budget]]"
  - "[[object-pooling]]"
tags: [performance, memory, leaks, connections, gc]
---

# Connection Leaks

## Summary

Event connections (`:Connect()`) create closures that hold strong references to captured variables. When a closure references an instance and the connection is never disconnected, the instance persists in memory indefinitely. The Lua garbage collector cannot break these cycles because Roblox stores connection lists as opaque C++ references. Connection leaks are the **single most common source of memory leaks** in Roblox games.

## Measurements / Budgets

Connection leaks have no fixed numeric threshold -- they manifest as steadily growing memory over time:

| Symptom | Indicator |
|---------|-----------|
| Memory growing linearly over time | Leak likely |
| LuauHeap increasing without gameplay changes | Closure/table leak |
| InstanceCount growing without new objects being created | Instances held by leaked connections |
| Server crash after extended uptime | Memory exhaustion from accumulated leaks |

Source: [connection-memory-leaks.md](../raw/community/performance/memory/connection-memory-leaks.md)

## How to Measure

- **Developer Console (F9)** > Memory tab: watch LuauHeap, Instances, and Signals categories over time. A steadily increasing line is the primary red flag.
- **Creator Hub dashboard**: P50/P90 server memory graphs. Healthy servers plateau; leaking servers trend upward.
- **Weak reference test** (programmatic):

```lua
local weakRef = setmetatable({}, { __mode = "v" })
weakRef.target = suspectedObject
suspectedObject = nil
task.wait(1)
if weakRef.target ~= nil then
    warn("LEAK: object still referenced")
end
```

Source: [garbage-collection-guide.md](../raw/community/performance/memory/garbage-collection-guide.md)

## Common Issues

### Direct Reference Leak

The closure captures `part` as an upvalue. The part's connection list holds the closure. Neither can be collected:

```lua
local part = Instance.new("Part")
part.Touched:Connect(function()
    print(part.Name) -- captures 'part'
end)
-- 'part' can never be garbage collected
```

### Indirect Reference Leak

The closure captures `dataTable`, which holds a reference to the part:

```lua
local part = Instance.new("Part")
local dataTable = { Message = "Test", Part = part }
part.Touched:Connect(function()
    print(dataTable.Message)
end)
-- Closure -> dataTable -> part -> connection -> closure (cycle)
```

### Connections Inside Event Handlers

Creating new connections inside other event handlers without tracking them is a common pattern that leaks:

```lua
-- BAD: creates a new connection every time PlayerAdded fires
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- this connection is never tracked or cleaned up
    end)
end)
```

Source: [connection-memory-leaks.md](../raw/community/performance/memory/connection-memory-leaks.md)

## Optimization Patterns

### Explicit Disconnection

Store the connection reference and disconnect when no longer needed:

```lua
local connection = part.Touched:Connect(function()
    print(part.Name)
end)
-- When done:
connection:Disconnect()
```

### Destroy Pattern (Recommended)

Calling `:Destroy()` on an instance recursively disconnects all connections on it and its descendants:

```lua
local part = Instance.new("Part")
part.Touched:Connect(function()
    print(part.Name)
end)
-- Cleanup:
part:Destroy() -- disconnects all connections, allows GC
```

### Maid / Trove Utility

Use a cleanup utility to track connections and instances together:

```lua
local trove = Trove.new()
trove:Add(part.Touched:Connect(function() ... end))
trove:Add(part)

-- Cleanup everything at once:
trove:Clean()
```

### Do-Block Scoping

Isolate temporary variables in a do block so they can be collected sooner:

```lua
local persistent = {}
do
    local temporary = buildLargeTable()
    persistent.summary = summarize(temporary)
    -- 'temporary' eligible for GC after block exits
end
```

Source: [garbage-collection-guide.md](../raw/community/performance/memory/garbage-collection-guide.md)

### Weak Tables for Caches

For caches that should not prevent collection of their contents:

```lua
local cache = setmetatable({}, { __mode = "v" }) -- weak values
cache[player] = expensiveData
-- When player leaves and no other reference exists, entry is auto-collected
```

Source: [garbage-collection-guide.md](../raw/community/performance/memory/garbage-collection-guide.md)

## Pitfalls

- **`collectgarbage("collect")` errors in Roblox.** You cannot force a GC cycle to test cleanup. Use the weak reference pattern instead.
- **`.Touched` listeners persist** even when `CanCollide = false`. Disabling collisions does not disconnect the event.
- **Never-ending coroutines** (`coroutine.yield()` without resume) retain all referenced data indefinitely.
- **Root script environments** may not garbage collect their globals. Avoid storing large data in module-level variables that are never cleared.
- **GC timing is unpredictable.** The weak reference test requires `task.wait()` to give the collector time to run, but there is no guaranteed timing.

## Related

- [[server-memory-budget]]
- [[object-pooling]]

## Sources

- [connection-memory-leaks.md](../raw/community/performance/memory/connection-memory-leaks.md)
- [garbage-collection-guide.md](../raw/community/performance/memory/garbage-collection-guide.md)
