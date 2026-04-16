---
title: Task Scheduler Overview
type: raw-source
source_url: https://create.roblox.com/docs/scripting/scheduler
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, task, scheduler, concurrency, legacy, deprecated-globals]
---

# Task Scheduler Overview

Roblox provides the `task` library for scheduling code execution with the engine's task scheduler, optimized for the engine's frame lifecycle. It also supports the `coroutine` library as an alternative with additional functionality.

> **Note:** This file was captured as a structured summary. See the source URL and the companion [task-library.md](./task-library.md) for definitive details.

## Key Methods

- **`task.spawn()`** — Executes a function or thread immediately through the engine's scheduler. Supports additional arguments that are forwarded to the function/thread.
- **`task.defer()`** — Schedules execution until the end of the current resume point within the frame. Similar to `task.spawn()` but does not require the thread to run immediately.
- **`task.delay(duration, fn, ...)`** — Schedules a function after a specified time duration on the next Heartbeat step, with built-in error handling. A zero duration resumes on the next step.
- **`task.wait(duration)`** — Yields the current thread for a given duration, then resumes on the next Heartbeat step. Returns the actual elapsed time. Defaults to zero if no duration is specified.

## Legacy Method Comparison

Roblox originally exposed global scheduling functions (`wait()`, `spawn()`, `delay()`) that are now deprecated. These legacy methods are **less optimized and configurable** than their `task` library equivalents, and they have throttling behavior that can introduce surprising delays.

| Legacy global | Modern equivalent |
|---|---|
| `wait(duration)` | `task.wait(duration)` |
| `spawn(fn)` | `task.spawn(fn)` |
| `delay(duration, fn)` | `task.delay(duration, fn)` |

Key differences:

- `task.wait()` **does not throttle** — it guarantees the resumption of the thread on the first Heartbeat that occurs when the delay has elapsed. The deprecated `wait()` throttles and may delay significantly under load.
- `task.delay()` with a zero duration guarantees the function is called on the very next Heartbeat.
- `task.wait()` returns only the elapsed time, whereas legacy `wait()` returned elapsed-time plus game time.
- Use `task` methods over legacy scheduling methods for all new code.

## Important Notes

- All task methods are superior alternatives to legacy scheduling functions.
- Actual delay times may vary slightly from requested durations due to frame pacing.
- `task.wait()` with no arguments behaves similarly to `RunService.Heartbeat:Wait()`.

## Source

Original URL: https://create.roblox.com/docs/scripting/scheduler
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/scheduler.md
Captured: 2026-04-16
