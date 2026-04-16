---
title: Lua Signal Class Comparison & Optimal GoodSignal Class
type: raw-source
source_url: https://devforum.roblox.com/t/lua-signal-class-comparison-optimal-goodsignal-class/1387063
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: stravant
post_date: 2021-08-02
tags: [signal, goodsignal, fastsignal, events, performance, library-comparison]
---

# Lua Signal Class Comparison & Optimal GoodSignal Class

**Author:** stravant
**Posted:** August 2, 2021

## Overview

A comprehensive analysis of four Signal class implementations for Roblox, concluding that GoodSignal offers the optimal balance of performance and correctness.

**Key Recommendation:**
> "Use this GoodSignal implementation unless you have a good reason not to!"

## Four Signal Implementations Compared

### 1. RobloxSignal
A wrapper around Roblox's BindableEvent. While straightforward, it requires workarounds for table deep-copying and introduces potential memory leaks if connections aren't properly disconnected.

### 2. SimpleSignal
Pure Lua implementation respecting RBXScriptSignal behaviors:
- Yield-safe (handlers spawn in separate threads)
- Handlers execute in reverse connection order
- Supports `:Wait()` method
- May fail when disconnecting other handlers within a handler function

### 3. FastSignal
Sacrifices correctness for maximum performance:
- Yielding in handlers blocks the calling thread
- Connecting new handlers during execution causes unpredictable behavior
- Best for performance-critical scenarios with careful code patterns

### 4. GoodSignal (recommended)
The recommended implementation achieving "2x or better performance" over SimpleSignal while maintaining full correctness:
- Never allocates memory during `:Fire()` unless handlers yield
- Handles all edge cases (disconnecting other handlers safely)
- Uses intrusive linked list for stable iteration without copying

## Performance Benchmarks

| Operation | FastSignal | GoodSignal | SimpleSignal | RobloxSignal |
|-----------|-----------|-----------|-------------|------------|
| CreateAndFire | 0.6μs | 1.2μs | 2.4μs | 18.5μs |
| Fire | 0.2μs | 0.8μs | 3.8μs | 3.2μs |
| FireManyHandlers | 0.2μs | 4.4μs | 15.2μs | 6.0μs |

## Technical Advantages of GoodSignal

**Linked List Architecture:** Uses an intrusive linked list where connections serve as nodes. This enables safe iteration even when handlers are disconnected mid-execution—removed nodes stay traversable via their next pointers.

**Coroutine Recycling:** Reuses coroutines across multiple handler invocations, only allocating new ones when handlers actually yield, reducing overhead compared to SimpleSignal's approach of spawning fresh threads.

## API Reference

```lua
local Signal = require(--[[module]])
local sig = Signal.new()
local connection = sig:Connect(function(...)
    print(...)
end)
sig:Fire(nil, "test1") --> Invokes handler
connection:Disconnect()
sig:DisconnectAll()
task.spawn(function()
    print(sig:Wait())
end)
sig:Fire(nil, "test2") --> Resumes waiter
```

## Design Decisions

The implementation deliberately throws errors on double-disconnection, unlike RobloxSignal, because "disconnecting the same connection twice is almost always a bug." This reflects intentional stricter error handling over preserving legacy code patterns.

## Updates
- **June 19, 2022:** Added `Once()` function; allowed multiple `Disconnect()` calls; fixed argument leaking in specific edge cases

## Source

Original URL: https://devforum.roblox.com/t/lua-signal-class-comparison-optimal-goodsignal-class/1387063
Captured: 2026-04-16
