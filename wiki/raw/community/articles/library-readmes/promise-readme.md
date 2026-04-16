---
title: roblox-lua-promise — Promise/A+ Implementation for Luau
type: raw-source
source_url: https://github.com/evaera/roblox-lua-promise
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: library
author: evaera
tags: [promise, async, concurrency, error-handling]
---

# roblox-lua-promise — Promise/A+ Implementation for Luau

**Author:** evaera
**Source:** GitHub — `evaera/roblox-lua-promise`
**Docs:** https://eryn.io/roblox-lua-promise/

## What it is

`roblox-lua-promise` is an implementation of `Promise` similar to Promise/A+ (the JavaScript promise specification). It is the canonical promise library in the Roblox Luau ecosystem and is used by Knit, Trove, Fusion, and most other community libraries. If you work with async code in Roblox for long, you will eventually touch this library.

## Why you should use Promises

The README lays out four specific reasons Roblox's default async model (yielding threads) is problematic:

### 1. Accidental yields are a huge class of bugs

> Functions you call can yield without warning, or only yield sometimes, leading to unpredictable and surprising results. Accidentally yielding the thread is the source of a large class of bugs and race conditions that Roblox developers run into.

In Lua, any function can yield via `task.wait`, `pcall` over a yielding call, `:WaitForChild`, or a remote invoke. The calling code has no way to know, which means the "is this synchronous?" question is never statically answerable.

### 2. Concurrent operations are awkward

> It is difficult to deal with running multiple asynchronous operations concurrently and then retrieve all of their values at the end without extraneous machinery.

You end up hand-rolling event-based coordination for things like "load 5 DataStores and continue when all are done."

### 3. Error handling requires ceremony

> When an asynchronous operation fails or an error is encountered, Lua functions usually either raise an error or return a success value followed by the actual value. Both of these methods lead to repeating the same tired patterns many times over for checking if the operation was successful.

Every call becomes either `local ok, result = pcall(...)` or `local success, result = doThing()`. Composing many of these is verbose and error-prone.

### 4. No introspection or cancellation

> Yielding lacks easy access to introspection and the ability to cancel an operation if the value is no longer needed.

Once you've started a yielding task, you can't ask "is it still running?" and you can't say "never mind, stop."

## The four properties this library aims for

> This Promise implementation attempts to satisfy these traits:
>
> - An object that represents a unit of asynchronous work
> - Composability
> - Predictable timing
> - Cancellation

## Core API (abbreviated)

### Creating promises

```lua
local Promise = require(ReplicatedStorage.Packages.Promise)

local p = Promise.new(function(resolve, reject, onCancel)
    task.wait(1)
    resolve("hello")
end)

-- Already-resolved shortcuts:
Promise.resolve("value")
Promise.reject("reason")

-- Wrap a yielding function:
local wrapped = Promise.promisify(someYieldingFunction)
```

### Chaining

```lua
p:andThen(function(value)
    return doSomething(value)
end):andThen(function(next)
    return doMore(next)
end):catch(function(err)
    warn("pipeline failed:", err)
end):finally(function()
    print("done (success or failure)")
end)
```

The chain-style API is where Promises pay for themselves: each `:andThen` is a transformation step, errors bubble down to `:catch`, and cleanup always runs in `:finally`.

### Composition

```lua
Promise.all({p1, p2, p3}):andThen(function(results)
    -- results is a table with three values
end)

Promise.race({p1, p2}):andThen(function(firstResult)
    -- whichever finished first
end)

Promise.some({p1, p2, p3}, 2)   -- resolve when 2 of 3 succeed
Promise.any({p1, p2, p3})        -- resolve when any succeeds
```

`Promise.all` is the canonical "fan out, fan in" pattern for concurrent work — essentially the correct answer to "load 5 DataStores in parallel and continue when all are done."

### Cancellation

```lua
local p = Promise.new(function(resolve, reject, onCancel)
    local running = true
    onCancel(function() running = false end)
    while running do task.wait(0.1) end
end)

p:cancel()
```

Cancellation is cooperative: the producer side of the promise registers an `onCancel` handler that signals whatever background work should stop.

### Integrating with yielding code

```lua
-- Turn a yielding function into a promise-returning one:
local promised = Promise.promisify(function()
    return DataStore:GetAsync("key")
end)

promised():andThen(function(data) print(data) end)

-- Go the other way (block until a promise finishes):
local ok, result = p:await()
```

`:await()` is how you integrate promise code with existing yielding code when you can't be chain-based all the way down.

## Why it matters in Knit

Knit's entire client API is promise-based: `Knit.GetService("X"):Method()` returns a promise rather than yielding. This is explicit in the framework design because it sidesteps the "accidental yield" problem — the caller knows the call is async because the return type says so. Most Knit code ends up reading like:

```lua
local MoneyService = Knit.GetService("MoneyService")
MoneyService:GetMoney():andThen(function(money)
    updateUI(money)
end):catch(warn)
```

## Source

Original URL: https://github.com/evaera/roblox-lua-promise
Docs: https://eryn.io/roblox-lua-promise/
Captured: 2026-04-15
