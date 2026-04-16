---
title: Connections Can Memory Leak Instances - PSA
type: raw-source
source_url: https://devforum.roblox.com/t/psa-connections-can-memory-leak-instances/90082
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: memory
tags: [memory-leak, connections, garbage-collection, instances, events]
---

# Connections Can Memory Leak Instances

## Core Problem

Event connections can create circular references that prevent garbage collection. When a closure connected to an event references an instance (directly or indirectly), the instance persists in memory indefinitely because Roblox stores connections as opaque C++ references that the Lua garbage collector cannot track.

## How Leaks Occur

### Bad Pattern - Direct Reference
```lua
local p = Instance.new('Part')
p.Touched:connect(function() print(p) end)
-- Part 'p' never gets garbage collected
```

### Bad Pattern - Indirect Reference
```lua
local p = Instance.new('Part')
local dataTable = {Message = "Test"; Part = p}
p.Touched:connect(function() print(dataTable.message) end)
-- Closure holds dataTable, dataTable holds p, p holds connection
```

## Why It Happens

The closure has a reference to the dataTable, through the upvalue. The dataTable has a reference to the part. The part has a connection list which includes a reference to the closure.

The Lua garbage collector cannot recognize this cycle because the connection list is a "C++ list of opaque references" rather than something Lua can introspect.

## Correct Solutions

### Explicit Disconnection
```lua
local p = Instance.new('Part')
local cn = p.Touched:connect(function() print(p) end)
cn:disconnect()
-- Connection broken, instance can be garbage collected
```

### Destroy Pattern (Recommended)
```lua
local p = Instance.new('Part')
p.Touched:connect(function() print(p) end)
p:Destroy()  -- Recursively disconnects all connections
```

## Severity

Accumulated leaks manifest as "a huge amount of stuff in memory" causing the garbage collector to "run really slowly," eventually leading to server crashes from memory exhaustion.

## Takeaway

Always use one of these cleanup patterns:
1. Store connection references and call `:Disconnect()` when done
2. Call `:Destroy()` on the parent instance (auto-disconnects)
3. Use a Maid/Trove utility to track and clean up connections
4. Never create new connections inside other event handlers without tracking them

## Source

Original URL: https://devforum.roblox.com/t/psa-connections-can-memory-leak-instances/90082
Captured: 2026-04-16
