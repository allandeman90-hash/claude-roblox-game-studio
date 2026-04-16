---
title: task-library
type: luau-feature
category: luau
subcategory: concurrency
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/luau/task-library.md
  - .claude/docs/luau-style-guide.md
related:
  - "[[deprecated-wait]]"
  - "[[deprecated-spawn]]"
  - "[[deprecated-delay]]"
  - "[[coroutines]]"
  - "[[RunService]]"
tags: [luau, concurrency]
---

# `task` Library

> The modern Luau concurrency primitive. Replaces the deprecated `wait`, `spawn`, and `delay` globals.

## Syntax

```lua
task.wait(duration: number?) -> number           -- yield for N seconds (or one frame if nil)
task.spawn(fn: (...any) -> (), ...any)           -- run fn on a new thread, immediately
task.defer(fn: (...any) -> (), ...any)           -- run fn on a new thread, after current resumption cycle
task.delay(duration: number, fn, ...any) -> thread  -- run fn after N seconds
task.cancel(thread: thread)                       -- cancel a pending thread (from task.spawn/delay/defer)
task.desynchronize()                              -- parallel Luau: leave serial phase
task.synchronize()                                -- parallel Luau: enter serial phase
```

## Semantics

### `task.wait(duration?)`
- Yields the current thread for **approximately** `duration` seconds
- Returns the actual elapsed time
- With no argument, yields for exactly one frame (same as `RunService.Heartbeat:Wait()`)
- Unlike the deprecated `wait()`, it's **not** throttled — you get close to the duration you asked for

### `task.spawn(fn, ...)`
- Immediately runs `fn(...)` on a new thread
- The new thread starts before the caller resumes
- Use for fire-and-forget async work where you want it to start NOW

### `task.defer(fn, ...)`
- Queues `fn(...)` to run after the current resumption cycle completes
- Runs on a new thread at the end of the current phase
- Useful when you want to run something "after the current signal listener chain finishes"
- Also unblocks re-entrant issues: if firing a BindableEvent from inside a handler, `task.defer` prevents stack explosion

### `task.delay(duration, fn, ...)`
- Like `setTimeout` in JavaScript
- Schedules `fn(...)` to run after `duration` seconds
- Returns the spawned thread, so you can `task.cancel` it if needed

### `task.cancel(thread)`
- Cancels a thread spawned via `task.spawn`, `task.defer`, or `task.delay`
- Safe to call on an already-finished thread (no-op)

### `task.desynchronize()` / `task.synchronize()` (Parallel Luau)
- Used inside an `Actor` parented to `workspace.Actors` or similar
- `desynchronize` moves execution off the serial phase, enabling parallel work
- `synchronize` returns to the serial phase (required before mutating shared state)

## Examples

### Basic wait

```lua
print("Start")
task.wait(2)
print("2 seconds later")
```

### Parallel fire-and-forget

```lua
for _, player in ipairs(game.Players:GetPlayers()) do
    task.spawn(function()
        saveData(player)
    end)
end
-- All saves run in parallel
```

### Deferred callback

```lua
-- Avoid re-entrant signal stack
someEvent:Connect(function(arg)
    task.defer(function()
        anotherEvent:Fire(arg)
    end)
end)
```

### Cancellable delay

```lua
local thread = task.delay(5, function()
    player:Kick("AFK timeout")
end)

-- If the player moves before 5s, cancel
player.Character:GetPropertyChangedSignal("Position"):Connect(function()
    task.cancel(thread)
end)
```

### Throttled Heartbeat loop

```lua
local lastTick = 0
local INTERVAL = 0.1  -- 10 Hz

game:GetService("RunService").Heartbeat:Connect(function(dt)
    lastTick += dt
    if lastTick >= INTERVAL then
        lastTick = 0
        doExpensiveWork()
    end
end)
```

Or equivalent using `task.wait`:

```lua
task.spawn(function()
    while true do
        task.wait(0.1)
        doExpensiveWork()
    end
end)
```

## Pitfalls

- **Using deprecated `wait()` / `spawn()` / `delay()`**: see [[deprecated-wait]], [[deprecated-spawn]], [[deprecated-delay]].
- **Not cancelling threads on cleanup**: long-running `task.delay` threads can fire after their target is gone. Use `task.cancel` or store in a Trove.
- **`task.defer` confusion**: it's "run at end of current phase", not "run next frame". Use `task.wait()` or `RunService.Heartbeat:Wait()` for next-frame.
- **Heavy work inside `task.spawn`**: spawning is cheap but the work still runs. Don't use `task.spawn` to hide expensive synchronous code.
- **`task.wait(0)` in a tight loop**: yields for one frame but still runs every frame. Use `RunService.Heartbeat` or throttle properly.
- **Thread leaks**: `task.spawn` without bounds can create thousands of threads. Use a Trove/Maid to track them.

## Parallel Luau Note

`task.desynchronize()` and `task.synchronize()` are part of Roblox's Parallel Luau feature, which runs code in `Actor` instances on worker threads. This is advanced; most gameplay code uses the single-threaded (serial) path. Parallel Luau is valuable for:
- Voxel/chunk processing
- Physics offload
- ECS-style systems with many independent entities

The Actor and SharedTable APIs are separate topics — see [Parallel Luau docs](https://create.roblox.com/docs/scripting/multithreading).

## Related

- [[deprecated-wait]] — the API this replaces
- [[deprecated-spawn]] — same
- [[deprecated-delay]] — same
- [[coroutines]] — the underlying thread primitive
- [[RunService]] — alternative scheduling via `Heartbeat`, `Stepped`, `RenderStepped`
- [[trove-maid-cleanup]] — for tracking spawned threads

## Sources

- [Roblox Creator Docs — task library](https://create.roblox.com/docs/reference/engine/libraries/task)
- [wiki/raw/roblox-creator-docs/luau/task-library.md](../raw/roblox-creator-docs/luau/task-library.md)
- [.claude/docs/luau-style-guide.md](../../.claude/docs/luau-style-guide.md)
