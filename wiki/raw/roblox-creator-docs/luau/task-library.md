---
title: task Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/task
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, task, scheduler, concurrency, wait, spawn, defer, delay, parallel]
---

# task Library

The **task** library allows for functions and threads to be scheduled with the engine's scheduler.

The functions available in this library generally support functions and threads. In most cases using a function is sufficient, but for more advanced cases it's recommended you familiarize yourself with the `coroutine` library.

## task.spawn

**Summary:** Calls/resumes a function/coroutine immediately through the engine's scheduler.

```
task.spawn(functionOrThread: function | thread, ...: Variant): thread
```

Accepts a function or a thread (as returned by `coroutine.create()`) and calls/resumes it immediately through the engine's scheduler. Arguments after the first are sent to the function/thread.

If the calling script is currently running in a serial execution phase, then the spawned function or thread is resumed in the current serial execution phase. If the calling script is currently running in a parallel execution phase, then the spawned function or thread is resumed in the current parallel execution phase. For more information, see [Parallel Luau](../../../scripting/multithreading.md).

**Parameters:**
- `functionOrThread: function | thread` — A function or a thread returned by `coroutine.create()`.
- `...: Variant` — Arguments to send to the function or thread.

**Returns:** `thread` — The scheduled thread.

## task.defer

**Summary:** Calls/resumes a function/coroutine at the end of the current resumption cycle.

```
task.defer(functionOrThread: function | thread, ...: Variant): thread
```

Accepts a function or a thread (as returned by `coroutine.create()`) and defers it until the end of the current resume point within the current frame.

This function should be used when a similar behavior to `task.spawn()` is desirable, but the thread does not need to run immediately.

If the calling script is currently running in a serial execution phase, then the deferred function or thread is resumed in a serial execution phase. If the calling script is currently running in a parallel execution phase, then the deferred function or thread is resumed in a parallel execution phase.

**Parameters:**
- `functionOrThread: function | thread` — A function or a thread returned by `coroutine.create`.
- `...: Variant` — Arguments to send to the function or thread.

**Returns:** `thread` — The scheduled thread.

## task.delay

**Summary:** Schedules a function/coroutine to be called/resumed on the next Heartbeat after the given duration (in seconds) has passed, without throttling.

```
task.delay(duration: number, functionOrThread: function | thread, ...: Variant): thread
```

Accepts a function or a thread (as returned by `coroutine.create()`) and schedules it to be called/resumed on the next `RunService.Heartbeat` after the given amount of time in seconds has elapsed. Arguments after the second are sent to the function/thread.

This function differs from the deprecated global `delay()` function in that **no throttling occurs**: on the very same `RunService.Heartbeat` step in which enough time has passed, the function is guaranteed to be called/resumed. Providing a duration of zero (`0`) will guarantee that the function is called on the very next `RunService.Heartbeat`.

You can calculate the actual time passed by calling `os.clock()` upon scheduling and in the scheduled function.

**Parameters:**
- `duration: number` — The minimum number of seconds that must pass before the function/thread is called/resumed.
- `functionOrThread: function | thread`
- `...: Variant` — Arguments to be passed to the function/thread when it is due to be called/resumed.

**Returns:** `thread` — The scheduled thread.

## task.desynchronize

**Summary:** Causes the following code to be run in parallel.

```
task.desynchronize(): ()
```

If the calling script is currently running in a serial execution phase, `desynchronize()` suspends the script and the script will be resumed in the next parallel execution phase. If the calling script is currently running in a parallel execution phase, `desynchronize()` returns immediately and has no effect.

Only scripts which are descendants of an `Actor` may call this method. If a script outside of an `Actor` calls this method, an error will be raised. `ModuleScripts` may also call `desynchronize()` as long as the instantiation of the module calling it was required by a script that is a descendant of an `Actor`.

## task.synchronize

**Summary:** Causes the following code to be run in serial.

```
task.synchronize(): ()
```

If the calling script is currently running in a parallel execution phase, `synchronize()` suspends the script and the script will be resumed in the next serial execution phase. If the calling script is currently running in a serial execution phase, `synchronize()` returns immediately and has no effect.

Only scripts which are descendants of an `Actor` may call this method.

## task.wait

**Summary:** Yields the current thread without throttling.

```
task.wait(duration: number = 0): number
```

Yields the current thread until the given duration (in seconds) has elapsed, then resumes the thread on the next `RunService.Heartbeat` step. The actual amount of time elapsed is returned.

If no duration is given, it will default to zero (`0`). This means the thread resumes on the very next step, which is equivalent in behavior to `RunService.Heartbeat:Wait()`.

Unlike the deprecated global `wait()`, this function **does not throttle** and guarantees the resumption of the thread on the first Heartbeat that occurs when it is due. This function also only returns the elapsed time and nothing else.

**Parameters:**
- `duration: number` (default: 0) — The amount of time in seconds that should elapse before the current thread is resumed.

**Returns:** `number`

## task.cancel

**Summary:** Cancels a thread, preventing it from being resumed.

```
task.cancel(thread: thread): ()
```

Cancels a thread and closes it, preventing it from being resumed manually or by the engine's scheduler.

This function can be used with other members of the **task** library that return a thread to cancel them before they are resumed. For example:

```lua
local thread = task.delay(5, function()
	print("Hello world!")
end)

task.cancel(thread)
```

Note that threads may be in a state where it is impossible to cancel them. For example, the currently executing thread and threads that have resumed another coroutine may not be cancelled. If this is the case, an error will be generated. However, code should not rely on specific thread states or conditions causing `task.cancel()` to fail. It is possible that future updates will eliminate these constraints and allow threads in these states to be successfully cancelled.

## Notes / Edge Cases

- Use the `task` methods over legacy scheduling methods (`wait()`, `spawn()`, `delay()`) — the legacy globals can provide similar results but are less optimized and configurable.
- `task.wait()` does not throttle, whereas the deprecated `wait()` does.
- `task.delay()` with duration `0` guarantees execution on the very next Heartbeat.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/task
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/task.yaml
Captured: 2026-04-16
