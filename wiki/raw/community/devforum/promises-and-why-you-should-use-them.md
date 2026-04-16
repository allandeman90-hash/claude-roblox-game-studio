---
title: Promises and Why You Should Use Them
type: raw-source
source_url: https://devforum.roblox.com/t/promises-and-why-you-should-use-them/350825
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: evaera
post_date: 2019-09-16
tags: [promise, async, coroutines, library, error-handling, cancellation]
---

# Promises and Why You Should Use Them

**Author:** evaera
**Posted:** September 16, 2019

## Core Concepts

### Synchronous vs. Asynchronous Operations
The post distinguishes between operations with immediately available results and those requiring future values (network requests, user input, pending processes).

### Coroutines and Threading
Lua uses green threads/coroutines running concurrently within a single OS thread, managed by a scheduler. Unlike true OS threads, coroutines don't execute in parallel—only one runs at a time.

## Problems with Traditional Coroutine Model

Evaera identifies five key limitations:

1. **Unpredictable yielding:** Functions may unexpectedly yield without clear documentation
2. **Error handling inconsistency:** Requires repetitive success/failure checking patterns
3. **Concurrent operation complexity:** Managing multiple simultaneous async tasks lacks standardized approaches
4. **Limited introspection:** Difficult to query coroutine state without manual implementation
5. **Difficult cancellation:** No straightforward mechanism to stop operations

## Promise Solution

Promises provide an abstraction returning objects representing future values. Key mechanisms include:

- **Resolution/Rejection:** Operations complete successfully or fail
- **Chaining:** Methods like `andThen()` and `catch()` enable composable chains
- **Synchronous returns:** Functions return immediately without blocking

## Core Methods

```lua
Promise.new(function(resolve, reject) end)
promise:andThen(callback)
promise:catch(errorHandler)
promise:finally(handler)
Promise.all(promiseArray)
Promise.race(promiseArray)
promise:cancel()
```

## Cancellation Model

Promises support cancellation through `onCancel` hooks, with propagation both upward (through chains) and downward (to dependent promises).

## Code Example

```lua
local HttpService = game:GetService("HttpService")
local function httpGet(url)
    return Promise.new(function(resolve, reject)
        local ok, result = pcall(HttpService.GetAsync, HttpService, url)
        if ok then
            resolve(result)
        else
            reject(result)
        end
    end)
end

httpGet("https://google.com")
    :andThen(function(body)
        print("Success:", body)
    end)
    :catch(function(err)
        warn("Error:", err)
    end)
```

## Key Advantages

Promises standardize asynchronous operation handling across codebases, preventing implementation inconsistencies and usage mistakes through consistent, composable APIs.

## Source

Original URL: https://devforum.roblox.com/t/promises-and-why-you-should-use-them/350825
Captured: 2026-04-16
