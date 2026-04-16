---
title: pcall / xpcall
type: luau-feature
category: luau
subcategory: error-handling
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/luau-spec/library/standard-library.md
  - wiki/raw/roblox-creator-docs/luau/functions.md
related:
  - "[[task-library]]"
  - "[[coroutines]]"
  - "[[buffer-type]]"
tags: [luau, error-handling, pcall, xpcall]
---

# `pcall` / `xpcall`

> Luau's protected-call primitives for error handling. `pcall` catches errors and returns a success boolean; `xpcall` adds a custom error handler for stack inspection before unwinding.

## Syntax

```lua
-- pcall: protected call
local success, result = pcall(fn, arg1, arg2, ...)
-- success: boolean (true if fn returned normally, false if it errored)
-- result: the return value(s) if success, or the error object if not

-- xpcall: extended protected call with error handler
local success, result = xpcall(fn, errorHandler, arg1, arg2, ...)
-- errorHandler receives the error object before the stack unwinds
```

### Signatures

```lua
pcall(f: (...any) -> ...any, ...: any): (boolean, ...any)
xpcall(f: (...any) -> ...any, err: (any) -> any, ...: any): (boolean, ...any)
```

## Semantics

### `pcall(fn, ...)`

Calls `fn(...)` in protected mode. If `fn` executes without error, `pcall` returns `true` followed by all return values. If `fn` raises an error (via `error()` or a runtime fault), `pcall` returns `false` followed by the error value.

```lua
local ok, val = pcall(function()
    return 42
end)
-- ok = true, val = 42

local ok2, err = pcall(function()
    error("something broke")
end)
-- ok2 = false, err = "something broke"
```

### `xpcall(fn, handler, ...)`

Like `pcall`, but on error calls `handler(errorValue)` before returning. The handler runs **while the stack is still intact**, allowing stack trace capture via `debug.traceback()`.

```lua
local ok, result = xpcall(function()
    error("oops")
end, function(err)
    return debug.traceback(err, 2)
end)
-- ok = false
-- result = "oops\n<stack trace>"
```

The handler's return value becomes the error value returned by `xpcall`.

### Luau-specific: pcall catches yields

Unlike standard Lua 5.1, Luau allows `pcall` and `xpcall` to catch errors from functions that yield (e.g., `task.wait()`). A yielding function inside `pcall` works correctly; the coroutine suspends and resumes through the protected frame.

```lua
local ok, elapsed = pcall(function()
    return task.wait(1)
end)
-- ok = true, elapsed ~ 1.0
```

### Error objects

The value passed to `error()` can be any type: string, number, table. `pcall` returns it as-is.

```lua
local ok, err = pcall(function()
    error({ code = 404, message = "Not found" })
end)
-- err.code == 404, err.message == "Not found"
```

## Examples

### DataStore call with retry

Every DataStore, HttpService, and MarketplaceService call must be wrapped in `pcall`:

```lua
--!strict
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("PlayerData")

local function loadData(key: string): (boolean, any)
    local MAX_RETRIES = 5
    for attempt = 1, MAX_RETRIES do
        local success, result = pcall(function()
            return store:GetAsync(key)
        end)
        if success then
            return true, result
        end
        warn(`DataStore GetAsync failed (attempt {attempt}): {result}`)
        task.wait(2 ^ attempt) -- exponential backoff: 2, 4, 8, 16, 32
    end
    return false, nil
end
```

### xpcall for structured error logging

```lua
local function riskyOperation()
    -- complex logic that might error
    error("unexpected state")
end

local function errorHandler(err: any): string
    local trace = debug.traceback(tostring(err), 2)
    -- Could send to analytics here
    return trace
end

local success, message = xpcall(riskyOperation, errorHandler)
if not success then
    warn("Operation failed:\n" .. message)
end
```

### Protected event handler

```lua
local function onPlayerAdded(player: Player)
    local success, err = pcall(function()
        -- Load data, setup character, etc.
        PlayerDataService.load(player)
    end)
    if not success then
        warn(`Failed to initialize player {player.Name}: {err}`)
        player:Kick("Failed to load your data. Please rejoin.")
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

## Pitfalls

- **Do not pcall internal code that should crash.** Use `pcall` for external/unreliable calls (DataStore, HttpService, user input). Internal logic errors should propagate to catch bugs early during development.
- **Error values are not always strings.** Code that does `err .. " more info"` will error if `err` is a table. Use `tostring(err)` for safe concatenation.
- **pcall swallows the stack trace.** Without `xpcall`, you lose the call stack. Use `xpcall` with `debug.traceback` when debugging production errors.
- **Retry loops need backoff.** Retrying DataStore calls without delay triggers rate limits faster. Always use exponential backoff (2^attempt seconds).
- **pcall around yielding code.** While Luau supports this, be aware that the protected frame persists across yields. Long-running yielding code inside pcall is fine but can make error attribution harder to trace.
- **Nested pcall performance.** Each `pcall` has a small overhead for setting up the protected frame. In hot loops (thousands of iterations per frame), avoid pcall inside the loop body; move it outside.

## Related

- [[task-library]]
- [[coroutines]]
- [[buffer-type]]

## Sources

- [Luau Standard Library Reference](../raw/luau-spec/library/standard-library.md)
- [Roblox Creator Docs: Functions](../raw/roblox-creator-docs/luau/functions.md)
