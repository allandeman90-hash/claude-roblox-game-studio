---
title: Roblox Garbage Collection and Memory Leak Prevention
type: raw-source
source_url: https://devforum.roblox.com/t/garbage-collection-and-memory-leaks-in-roblox-what-you-should-know/374954
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: memory
tags: [garbage-collection, memory-leak, gc, weak-references]
---

# Roblox Garbage Collection and Memory Leak Prevention

## Core Concepts

### Garbage Collection
Roblox Lua automatically cleans up unused memory through periodic garbage collection cycles at undocumented, unpredictable intervals.

**Important**: Unlike vanilla Lua, `collectgarbage("collect")` **errors in Roblox**. You cannot force a GC cycle.

### Memory Leaks
Sections of memory that never get cleaned up - not a security vulnerability, but a performance issue where objects persist indefinitely due to lingering references.

## Strong vs Weak References

### Strong References (default)
All variables, functions, and tables use these by nature. They prevent garbage collection.

### Weak References
Can be applied to table keys or values using the `__mode` metamethod:

```lua
local cache = setmetatable({}, {__mode = "v"})  -- weak values
local keyTable = setmetatable({}, {__mode = "k"}) -- weak keys
local kvTable = setmetatable({}, {__mode = "kv"}) -- both
```

A table with `__mode = "kv"` won't prevent its contents from being collected.

## Critical Memory Leak Patterns

### 1. Function Closures
Functions referencing external variables hold strong references to them. These persist until the function itself is garbage collected.

```lua
-- LEAK: closure holds part forever
local part = Instance.new("Part")
local leakyFn = function() return part.Name end
```

### 2. Event Connections
"When you make a connection to an event the function that is connected can hold a reference to values in your script. If the connection is never disconnected, the values you reference in the function will exist forever!"

```lua
-- LEAK: never disconnected
part.Touched:Connect(function()
    print(part.Name) -- captures part
end)
-- part can never be GC'd

-- FIX: store connection and disconnect
local conn = part.Touched:Connect(...)
-- later:
conn:Disconnect()
```

### 3. Never-Ending Threads
Coroutines using `coroutine.yield()` that aren't explicitly cleaned up retain all referenced data.

### 4. Table References
Tables retain values they reference until explicitly cleared or the table is collected.

## Prevention Strategies

### Do Blocks
Isolate temporary variables in new scopes for faster cleanup:

```lua
local persistent = {}
do
    local temporary = {}
    -- temporary can GC after block exits
end
```

### Connection Management
- Disconnect event connections when no longer needed
- Rely on automatic cleanup when parent instances are destroyed via `:Destroy()`
- Use Maid/Trove utilities

### Weak Table Testing for Leaks

Programmatically test for leaks:
```lua
local weakRef = setmetatable({}, {__mode = "v"})
weakRef.target = someObject
someObject = nil
task.wait(1) -- let GC run
-- If weakRef.target is nil, no leak
if weakRef.target == nil then
    print("GC'd successfully")
else
    print("LEAK: still referenced")
end
```

## Important Limitations

- **Cannot force GC**: `collectgarbage("collect")` errors
- Root script environments may not GC their globals
- Numbers and string literals have special collection rules
- Garbage collection timing is automatic

## Key Takeaways

1. The strongest leak source is **event connection closures**
2. Use `:Destroy()` on parents to cascade cleanup
3. Weak tables for caches that shouldn't hold references
4. Test leaks with weak references, not manual GC
5. Keep connections tracked (Maid pattern)

## Source

Original URL: https://devforum.roblox.com/t/garbage-collection-and-memory-leaks-in-roblox-what-you-should-know/374954
Captured: 2026-04-16
