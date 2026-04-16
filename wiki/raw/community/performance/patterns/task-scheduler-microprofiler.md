---
title: Task Scheduler - Frame Phases and MicroProfiler Labels
type: raw-source
source_url: https://create.roblox.com/docs/performance-optimization/microprofiler/task-scheduler
source_type: official-docs
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: patterns
tags: [task-scheduler, run-service, frame-phases, microprofiler]
---

# Task Scheduler - Frame Phases and MicroProfiler Labels

## Purpose

The task scheduler manages frame-by-frame operations including input detection, character animation, physics updates, and script resumption from `task.wait()` states.

## Key Phases (Order of Execution)

1. **PreAnimation** - Initial frame preparation
2. **PreSimulation** - Before physics calculations (use for gameplay logic affecting physics)
3. **PostSimulation** - After physics calculations (use for reactions to physics)
4. **Heartbeat** - Main game logic (behavior varies by `SignalBehavior` setting)
5. **BindToRenderStep()** - Custom rendering priority control
6. **PreRender** - Final pre-rendering tasks

## Task Library Functions

### task.spawn()
Takes a thread or function and resumes it **immediately** through the engine's scheduler. Executes without delay.

```lua
task.spawn(function()
    print("Immediate execution")
end)
```

### task.defer()
Defers until the end of the current resume point within the current frame. Optimized alternative to legacy `spawn()` without throttling.

```lua
task.defer(function()
    print("End of frame")
end)
```

### task.delay()
Schedules resumption after specified time on next `Heartbeat` step.

```lua
task.delay(1, function()  -- 1 second
    print("Delayed")
end)
```

### task.wait()
Yields current thread for specified duration, resumes on next `Heartbeat` step. Returns actual elapsed time.

```lua
local elapsed = task.wait(0.1)  -- wait ~100ms
```

## Performance Considerations

Scheduler overload occurs when:
- Using custom character rigs or input schemes
- Manually animating parts instead of using `Animator`
- Heavily relying on precise physics
- Frequently replicating objects
- Having hundreds of scripts in tight `task.wait()` loops

## Best Practices

### Manager Pattern
Instead of many scripts each calling `task.wait()` or connecting to Heartbeat, use a single manager:

```lua
-- BAD: many tiny waits
-- script1.lua
while true do
    task.wait(0.1)
    doWork1()
end
-- script2.lua
while true do
    task.wait(0.1)
    doWork2()
end

-- GOOD: single manager
local workers = {}
RunService.Heartbeat:Connect(function(dt)
    for _, fn in workers do
        fn(dt)
    end
end)
```

### Phase Selection
| Task | Phase |
|------|-------|
| Gameplay logic affecting physics | PreSimulation |
| Reactions to physics (post-step) | PostSimulation |
| Motor6D transforms | PreSimulation (else Animator overwrites) |
| Camera movement | BindToRenderStep (high priority) |
| UI updates | Heartbeat or PreRender |
| Visual-only updates | PreRender |

## Legacy vs Modern

Legacy methods (`wait()`, `spawn()`, `delay()`) are "less optimized and configurable" than their task equivalents. Migrate to `task.*` variants.

| Legacy | Modern | Notes |
|--------|--------|-------|
| `wait(t)` | `task.wait(t)` | More precise timing |
| `spawn(fn)` | `task.spawn(fn)` or `task.defer(fn)` | No throttling |
| `delay(t, fn)` | `task.delay(t, fn)` | No silent errors |

## Performance Tip

"Over-relying on the Roblox task scheduler to manage hundreds of tiny waits can lead to performance issues, as every time you call a wait function you're telling the engine to yield the script and put it in a queue, and these tiny yields add up in complex games."

## Source

Original URLs:
- https://create.roblox.com/docs/performance-optimization/microprofiler/task-scheduler
- https://create.roblox.com/docs/scripting/scheduler

Captured: 2026-04-16
