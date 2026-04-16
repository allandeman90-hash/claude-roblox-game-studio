---
title: coroutine Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/coroutine
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, coroutine, threads, yield, resume, concurrency]
---

# coroutine Library

A **coroutine** is used to perform multiple tasks at the same time from within the same script. Such tasks might include producing values from inputs or performing work on a subroutine when solving a larger problem. A task doesn't even need to have a defined ending point, but it does need to define particular times at which it **yields** (pause) to let other things be worked on.

## Using Coroutines

A new coroutine can be created by providing a function to `coroutine.create()`. Once created, a coroutine doesn't begin running until the first call to `coroutine.resume()` which passes the arguments to the function. This call returns when the function either halts or calls `coroutine.yield()` and, when this happens, `coroutine.resume()` returns either the values returned by the function, the values sent to `coroutine.yield()`, or an error message. If it does error, the second return value is the thrown error.

```lua
local function task(...)
	-- This function might do some work for a bit then yield some value
	coroutine.yield("first")  -- To be returned by coroutine.resume()
	-- The function continues once it is resumed again
	return "second"
end

local taskCoro = coroutine.create(task)
-- Call resume for the first time, which runs the function from the beginning
local success, result = coroutine.resume(taskCoro, ...)
print(success, result)  --> true, first (task called coroutine.yield())
-- Continue running the function until it yields or halts
success, result = coroutine.resume(taskCoro)
print(success, result)  --> true, second (task halted because it returned "second")
```

During the lifetime of the coroutine, you can call `coroutine.status()` to inspect its status:

| Status | Meaning |
|---|---|
| **suspended** | The coroutine is waiting to be resumed. Coroutines begin in this state and enter it when their function calls `coroutine.yield()`. |
| **running** | The coroutine is running right now. |
| **normal** | The coroutine is awaiting the yield of another coroutine; in other words, it has resumed another coroutine. |
| **dead** | The function has halted (returned or thrown an error). The coroutine cannot be used further. |

## Wrapping Coroutines

When working with coroutines, you can also forgo the use of the coroutine object and instead use a wrapper function. Such a wrapper function will resume a particular coroutine when it is called and will return only the yielded values. You can do this using `coroutine.wrap()`:

```lua
-- Create coroutine and return a wrapper function that resumes it
local f = coroutine.wrap(task)
-- Resume the coroutine as if we called coroutine.resume()
local result = f()
-- If an error occurs it will be raised here!
-- This differs from coroutine.resume() which acts similar to pcall()
```

The first value returned from `coroutine.resume()` describes whether a coroutine ran without errors. However, functions returned by `coroutine.wrap()` will not do this: instead they directly return the values returned or passed to `coroutine.yield()`, if any. Should an error have occurred while running the coroutine function, the error is raised on the call of the returned function.

## Producer Pattern Example

```lua
-- This function repeats a word every time its coroutine is resumed
local function repeatThis(word)
	local repetition = ""
	while true do
		-- Do one repetition then yield the result
		repetition = repetition .. word
		coroutine.yield(repetition)
	end
end
```

To run this function as a coroutine:

```lua
local repetitionCoro = coroutine.create(repeatThis)
print(coroutine.resume(repetitionCoro, "Hello"))  -- true, Hello
print(coroutine.resume(repetitionCoro))           -- true, HelloHello
print(coroutine.resume(repetitionCoro))           -- true, HelloHelloHello
```

Or with `coroutine.wrap()`:

```lua
local f = coroutine.wrap(repeatThis)
print(f("Hello"))  -- Hello
print(f())         -- HelloHello
print(f())         -- HelloHelloHello
```

## Functions

### coroutine.close

```
coroutine.close(co: thread): (bool, Variant<string, void>)
```

Closes and puts the provided coroutine in a dead state. Returns `true` unless the coroutine is in an error state, in which case it returns `false` and the error message. A coroutine that is currently running cannot be closed. A coroutine cannot be resumed after it is closed.

### coroutine.create

```
coroutine.create(f: function): thread
```

Creates a new coroutine, with body `f`. `f` must be a Luau function.

### coroutine.isyieldable

```
coroutine.isyieldable(): bool
```

Returns `true` if the coroutine this function is called within can safely yield. Yielding a coroutine inside metamethods or C functions is prohibited, with the exception of `pcall` and `xpcall`.

### coroutine.resume

```
coroutine.resume(co: thread, ...: Variant): (bool, Variant<Tuple, string>)
```

Starts or continues the execution of coroutine `co`. The first time you resume a coroutine, it starts running its body. The values `...` are passed as the arguments to the body function. If the coroutine has yielded, resume restarts it; the values `...` are passed as the results from the yield. If the coroutine runs without any errors, resume returns `true` plus any values passed to yield (if the coroutine yields) or any values returned by the body function (if the coroutine terminates). If there is any error, resume returns `false` plus the error message.

### coroutine.running

```
coroutine.running(): thread
```

Returns the running coroutine.

### coroutine.status

```
coroutine.status(co: thread): string
```

Returns the status of coroutine `co` as a string: `'running'`, `'suspended'`, `'normal'`, or `'dead'`.

### coroutine.wrap

```
coroutine.wrap(f: function): function
```

Creates a new coroutine, with body `f`. `f` must be a Luau function. Returns a function that resumes the coroutine each time it is called. Any arguments passed to the function behave as the extra arguments to `resume`. Returns the same values returned by resume, except the first boolean. In case of error, propagates the error.

### coroutine.yield

```
coroutine.yield(...: Tuple): Tuple<Variant>
```

Suspends the execution of the calling coroutine. Any arguments to yield are passed as extra results to resume. Yielding a coroutine inside metamethods or C functions is prohibited, with the exception of `pcall` and `xpcall`.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/coroutine
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/coroutine.yaml
Captured: 2026-04-16
