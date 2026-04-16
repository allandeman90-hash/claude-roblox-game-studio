---
title: Garbage Collection and Memory Leaks in Roblox - What you should know
type: raw-source
source_url: https://devforum.roblox.com/t/garbage-collection-and-memory-leaks-in-roblox-what-you-should-know/374954
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: Hexcede
post_date: 2019-10-24
tags: [memory-leaks, garbage-collection, weak-tables, references, lua]
---

# Garbage Collection and Memory Leaks in Roblox - What You Should Know

**Author:** Hexcede
**Posted:** October 24, 2019

## Core Concepts

**Garbage Collection** is the automated process that frees memory from unused values. In Roblox Lua, garbage collection occurs periodically at undocumented intervals—you cannot force it manually.

**Memory Leaks** are sections of memory that never get cleaned up, not security vulnerabilities. They occur when values remain referenced even after they're no longer needed.

## Key Differences from Standard Lua

Unlike vanilla Lua, Roblox Lua prohibits forced garbage collection via `collectgarbage("collect")`. However, you can check memory usage with `collectgarbage("count")`, which returns kilobytes.

## Reference Types

**Strong references** prevent garbage collection (variables, functions, tables).

**Weak references** don't prevent collection. You create weak tables using the `__mode` metamethod with `"k"` for weak keys or `"v"` for weak values.

## Primary Memory Leak Causes

The tutorial identifies four main sources:

1. **Functions referencing external variables** — Connected functions hold strong references to captured values
2. **Tables storing values** — Tables prevent referenced values from being collected
3. **Callbacks with captured variables** — Similar behavior to event connections
4. **Never-ending threads** — Permanently yielding coroutines retain root scope values

## Prevention Strategies

Use `do` blocks to isolate temporary variables. Once execution exits a `do` block, variables created within it become eligible for collection. Disconnect event connections when no longer needed, or ensure the parent instance gets destroyed.

## Testing for Leaks

Create weak tables to detect collection:

```lua
local ref = setmetatable({myValue}, {__mode = "v"})
local function isReferenced()
    return ref[1]
end
```

If `ref[1]` returns `nil`, the value was garbage collected.

## Source

Original URL: https://devforum.roblox.com/t/garbage-collection-and-memory-leaks-in-roblox-what-you-should-know/374954
Captured: 2026-04-16
