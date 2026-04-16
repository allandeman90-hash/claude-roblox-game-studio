---
title: Promise
type: library
category: libraries
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/promise-readme.md
  - wiki/raw/community/devforum/promises-and-why-you-should-use-them.md
related: [[[Knit]], [[Trove]]]
tags: [library, async, concurrency, error-handling]
---

# Promise

> Promise/A+ implementation for Luau with composability, predictable timing, and cancellation. The canonical async primitive in the Roblox community ecosystem.

## Summary

`roblox-lua-promise` by evaera is the standard promise library in the Roblox Luau ecosystem. It provides an object representing a unit of asynchronous work with chaining (`:andThen`), error handling (`:catch`), composition (`Promise.all`, `Promise.race`), and cooperative cancellation. It is used by [[Knit]], [[Trove]], [[Fusion]], and most other community libraries that deal with async operations.

**Maintainer:** evaera
**Status:** Stable and widely adopted

## Installation

### Wally

```toml
[dependencies]
Promise = "evaera/promise@latest"
```

## Quick Start

```lua
local Promise = require(ReplicatedStorage.Packages.Promise)

-- Create a promise
local p = Promise.new(function(resolve, reject, onCancel)
    local success, result = pcall(function()
        return game:GetService("DataStoreService"):GetDataStore("Main"):GetAsync("key")
    end)
    if success then
        resolve(result)
    else
        reject(result)
    end
end)

-- Chain transformations and error handling
p:andThen(function(data)
    return processData(data)
end):andThen(function(processed)
    updateUI(processed)
end):catch(function(err)
    warn("Pipeline failed:", err)
end):finally(function()
    print("Done (success or failure)")
end)
```

## Key API

| Symbol | Description |
|--------|-------------|
| `Promise.new(executor)` | Creates a promise. Executor receives `(resolve, reject, onCancel)`. |
| `Promise.resolve(value)` | Returns an immediately resolved promise. |
| `Promise.reject(reason)` | Returns an immediately rejected promise. |
| `Promise.promisify(fn)` | Wraps a yielding function into a promise-returning one. |
| `promise:andThen(fn)` | Chains a transformation. Returns a new promise. |
| `promise:catch(fn)` | Handles rejections. Errors bubble down to the nearest `:catch`. |
| `promise:finally(fn)` | Runs on resolution or rejection. Always executes. |
| `promise:await()` | Blocks the current thread until resolved. Returns `(ok, result)`. |
| `promise:cancel()` | Cooperatively cancels the promise. The executor's `onCancel` handler is called. |
| `Promise.all(promises)` | Resolves when all promises resolve. The "fan out, fan in" pattern. |
| `Promise.race(promises)` | Resolves when the first promise resolves. |
| `Promise.some(promises, n)` | Resolves when `n` of the promises resolve. |
| `Promise.any(promises)` | Resolves when any single promise resolves. |

## Why Promises Over Yielding Threads

Roblox's default async model (coroutine yielding) has four structural problems that Promises solve:

1. **Accidental yields.** Any function can yield without the caller knowing. Promises make async explicit -- the return type tells you.
2. **Concurrent operations.** "Load 5 DataStores and continue when all are done" is `Promise.all({p1, p2, p3, p4, p5})` instead of hand-rolled event coordination.
3. **Error handling ceremony.** `pcall` everywhere becomes `:catch` at the end of a chain.
4. **No introspection or cancellation.** Once a coroutine yields, you cannot ask if it is still running or tell it to stop. Promises expose status and cancellation.

## Integration with Yielding Code

```lua
-- Wrap a yielding function into a promise-returning one
local promisedGet = Promise.promisify(function(key)
    return DataStore:GetAsync(key)
end)

promisedGet("Player_123"):andThen(function(data)
    print(data)
end)

-- Go the other direction: block until a promise finishes
local ok, result = somePromise:await()
```

## When to Use / When Not to Use

**Use when:**
- Composing multiple async operations (DataStore loads, HTTP requests, remote calls)
- You want explicit async boundaries instead of implicit yields
- Working within [[Knit]] (its client API is promise-based)
- Cancellation of in-flight operations is needed

**Do not use when:**
- A single synchronous operation that never fails
- Simple `task.wait` delays where no composition or error handling is needed

## Alternatives

| Library | Trade-off |
|---------|-----------|
| `task.spawn` + `pcall` | No library dependency, but no composition, cancellation, or chaining. |
| Nevermore `@quenty/promise` | Quenty's own promise implementation within [[Nevermore]]. Same concept, different module. |
| Native coroutines | Built-in, but accidental yields, no cancellation, no composition primitives. |

## Related

- [[Knit]] -- client API is entirely promise-based
- [[Trove]] -- cleanup often integrates with promise cancellation

## Sources

- [Promise README](wiki/raw/community/articles/library-readmes/promise-readme.md)
- [DevForum: Promises and Why You Should Use Them](wiki/raw/community/devforum/promises-and-why-you-should-use-them.md)
- GitHub: https://github.com/evaera/roblox-lua-promise
- Docs: https://eryn.io/roblox-lua-promise/
