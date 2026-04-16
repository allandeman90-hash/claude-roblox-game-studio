---
title: Coroutines
type: luau-feature
category: luau
subcategory: concurrency
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/coroutine-library.md
  - wiki/raw/luau-spec/library/standard-library.md
related:
  - "[[task-library]]"
  - "[[pcall-xpcall]]"
tags: [luau, concurrency, coroutine, threads]
---

# Coroutines

> Lua's cooperative multithreading primitive. A coroutine is a function that can suspend (yield) and resume execution at specific points, enabling cooperative concurrency within a single OS thread.

## Syntax

```lua
-- Create
local co: thread = coroutine.create(fn)

-- Resume (start or continue)
local success, ...results = coroutine.resume(co, ...args)

-- Yield from inside the coroutine
coroutine.yield(...values)

-- Wrap (convenience: returns a resuming function instead of the thread object)
local f: (...any) -> ...any = coroutine.wrap(fn)

-- Status inspection
local status: string = coroutine.status(co)  -- "suspended" | "running" | "normal" | "dead"

-- Close (terminate a suspended or dead coroutine)
local ok, err = coroutine.close(co)

-- Introspection
local current: thread = coroutine.running()
local canYield: boolean = coroutine.isyieldable()
```

## Semantics

### Lifecycle

A coroutine begins in the **suspended** state. Calling `coroutine.resume(co, ...)` transitions it to **running**. When the coroutine calls `coroutine.yield(...)`, it returns to **suspended** and the yield values become the return values of `resume`. When the function body returns, the coroutine enters the **dead** state and cannot be resumed again.

| Status | Meaning |
|---|---|
| `suspended` | Waiting to be resumed. Initial state and state after `yield`. |
| `running` | Currently executing. |
| `normal` | Has resumed another coroutine and is waiting for it to yield. |
| `dead` | Function returned or threw an error. Cannot be reused. |

### `coroutine.resume` return values

- On success: `true, <yield/return values>`
- On error: `false, <error message>`

This makes `resume` behave like `pcall` -- errors inside the coroutine do not propagate to the caller.

### `coroutine.wrap` vs `coroutine.create`

`coroutine.wrap(fn)` returns a plain function that resumes the coroutine on each call. Unlike `resume`, the wrapper:
- Does **not** return a success boolean
- **Raises** errors directly (instead of returning `false, err`)
- Returns only the yield/return values

### `coroutine.close`

Puts a suspended or dead coroutine into the dead state. Returns `true` on success. If the coroutine is in an error state, returns `false` and the error message. A running coroutine cannot be closed.

### Yielding restrictions

Yielding is prohibited inside metamethods and C functions, **except** inside `pcall` and `xpcall`. `coroutine.isyieldable()` returns `true` if the current context permits yielding.

### Deviation from Lua 5.1

Luau coroutines are largely compatible with Lua 5.1 but add:
- `coroutine.close()` (from Lua 5.4)
- `coroutine.isyieldable()` (from Lua 5.3)
- Yielding through `pcall`/`xpcall` is allowed (blocked in standard Lua 5.1)

## Examples

### Basic yield/resume

```lua
local function task(greeting: string)
    print(greeting)
    local response = coroutine.yield("waiting")
    print(response)
    return "done"
end

local co = coroutine.create(task)

local ok, val = coroutine.resume(co, "Hello")
-- prints "Hello", ok = true, val = "waiting"

ok, val = coroutine.resume(co, "World")
-- prints "World", ok = true, val = "done"

print(coroutine.status(co)) --> dead
```

### Producer pattern (iterator)

```lua
local function range(start: number, stop: number, step: number?)
    local s = step or 1
    return coroutine.wrap(function()
        local i = start
        while i <= stop do
            coroutine.yield(i)
            i += s
        end
    end)
end

for n in range(1, 10, 2) do
    print(n) --> 1, 3, 5, 7, 9
end
```

### Wrapped coroutine for data generation

```lua
local function repeatWord(word: string)
    local result = ""
    while true do
        result ..= word
        coroutine.yield(result)
    end
end

local gen = coroutine.wrap(repeatWord)
print(gen("Hi"))   --> Hi
print(gen())       --> HiHi
print(gen())       --> HiHiHi
```

### Error handling with resume

```lua
local co = coroutine.create(function()
    error("something went wrong")
end)

local ok, err = coroutine.resume(co)
print(ok, err) --> false, "something went wrong"
print(coroutine.status(co)) --> dead
```

## Pitfalls

- **Prefer `task` library for Roblox scheduling.** For timed delays, deferred execution, and fire-and-forget async work, `task.spawn`, `task.defer`, and `task.delay` integrate with Roblox's scheduler and are simpler. Use raw coroutines only when you need manual yield/resume control (e.g., custom iterators, state machines).
- **Dead coroutines cannot be restarted.** Once a coroutine returns or errors, it is permanently dead. Attempting to resume it returns `false, "cannot resume dead coroutine"`.
- **`coroutine.wrap` propagates errors.** Unlike `resume`, a wrapped coroutine raises errors at the call site. Use `pcall` around the wrapper call if error handling is needed.
- **Memory leaks from abandoned coroutines.** A suspended coroutine holds references to its entire stack. If a coroutine yields and is never resumed or closed, those references prevent garbage collection. Use `coroutine.close()` to release resources.
- **No preemption.** Coroutines are cooperative; a coroutine that never yields blocks the thread. Long computations should yield periodically.

## Related

- [[task-library]]
- [[pcall-xpcall]]

## Sources

- [Roblox Creator Docs: coroutine Library](../raw/roblox-creator-docs/luau/coroutine-library.md)
- [Luau Standard Library Reference](../raw/luau-spec/library/standard-library.md)
