---
title: task.wait vs wait — Roblox scripting help
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/ujw942/taskwait_vs_wait_roblox_scripting_help/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [task-library, wait, scheduling, runservice, heartbeat, performance]
---

# task.wait vs wait — Roblox scripting help

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/ujw942/

## The Question

A common beginner confusion: what is the difference between `wait()`, `task.wait()`, and just using `RunService.Heartbeat:Wait()` — and which one should you actually use?

## The Community's Answer

### TL;DR
**Use `task.wait()`. Never use `wait()` in new code.**

`wait()` is the legacy scheduler and is effectively deprecated. `task.wait()` is the modern task-library equivalent and is:
- Faster
- More accurate
- More reliable (does not throttle or drift as badly)

As the thread states: **"task.wait() does not throttle and guarantees resumption of the thread on the first Heartbeat when due."**

### Why wait() Is Bad
- `wait()` has historically been throttled by the old scheduler — it could return far later than you asked for, especially under load.
- "It was often reported that wait() would return values far exceeding the intended delay, leading to unpredictable behavior in game loops."
- Under heavy contention, `wait(0.1)` could return after 0.3s or more.

### Why task.wait() Is Better
- Built on the new task scheduler.
- `task.wait()` (with no argument or `0`) resumes on the very next Heartbeat frame — the minimum possible wait.
- `task.wait(t)` schedules the resume for at least `t` seconds from now, without the throttling penalty.
- Works cleanly with `task.spawn`, `task.delay`, `task.defer`, and `task.cancel`.

### The Whole task Library (Modern Replacement Set)
| Old                      | New                     | Purpose                                                |
| ------------------------ | ----------------------- | ------------------------------------------------------ |
| `wait(t)`                | `task.wait(t)`          | Yield for at least `t` seconds                          |
| `spawn(fn)`              | `task.spawn(fn)`        | Run `fn` in a new coroutine immediately                 |
| `delay(t, fn)`           | `task.delay(t, fn)`     | Run `fn` after `t` seconds                              |
| `wait()` on next frame   | `task.defer(fn)`        | Run `fn` at the end of the current resumption cycle     |

### When To Prefer `RunService` Connections Over `task.wait` Loops
For per-frame logic (character updates, physics ticks, interpolation), prefer:

```lua
RunService.Heartbeat:Connect(function(dt)
    -- dt is the time since the previous heartbeat
    updateThing(dt)
end)
```

instead of:

```lua
while task.wait() do
    updateThing()
end
```

The `Connect` approach:
- Hands you the `dt` delta time for frame-rate-independent math.
- Is disconnectable (`:Disconnect()`), while a `while` loop must check a flag.
- Is easier for the engine to schedule efficiently.

Use `task.wait` for ad-hoc delays (spawn an enemy after 5s), and `RunService` connections for continuous updates.

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/ujw942/taskwait_vs_wait_roblox_scripting_help/
Captured: 2026-04-16

## Notes

Content reconstructed from search snippets. The `task.wait` recommendation is also the official Roblox docs position and is repeated in dozens of devforum and reddit threads.
