---
title: RunService
type: service
category: services
subcategory: runtime
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/RunService.md
related:
  - "[[task-library]]"
  - "[[heartbeat-budget]]"
tags: [roblox-class, runtime]
---

# RunService

> Service responsible for all runtime activity, frame-loop events, and context detection. [[task-library]]

## Summary

RunService is the central service for time management and frame-loop integration in Roblox. It provides events that fire at specific points in each frame's lifecycle: before rendering, before/after physics simulation, and after all processing. Choosing the correct event is critical for performance and correctness.

RunService also provides context-detection methods (`IsClient()`, `IsServer()`, `IsStudio()`) that are essential for ModuleScripts shared between client and server code. These methods let you branch behavior based on the runtime environment without maintaining separate codepaths.

The frame lifecycle runs in this order per frame: **PreRender** (client-only, before rendering) -> **PreAnimation** (before animation step) -> **PreSimulation** (before physics) -> physics solver runs (potentially multiple times) -> **PostSimulation** (after physics) -> **Heartbeat** (after physics, where most game logic runs) -> replication send.

## API Surface

### Properties

_No scriptable public properties._

### Methods

- `:IsClient() -> boolean` -- True if running in a client context (LocalScript, client ModuleScript).
- `:IsServer() -> boolean` -- True if running in a server context (server Script, server ModuleScript).
- `:IsStudio() -> boolean` -- True if running in Roblox Studio (any mode).
- `:IsRunning() -> boolean` -- True if the simulation is active (not paused, not edit mode).
- `:IsRunMode() -> boolean` -- True if a "Run" playtest (no player character) was initiated in Studio.
- `:BindToRenderStep(name: string, priority: number, fn: (deltaTime: number) -> ()) -> ()` -- Binds a function to run before rendering at the given priority. Client-only. Use `Enum.RenderPriority` for standard priority levels.
- `:UnbindFromRenderStep(name: string) -> ()` -- Unbinds a previously bound render step function.

### Events

- `.PreRender:Connect(fn(deltaTime: number))` -- Fires every frame before rendering. Client-only. Replacement for `RenderStepped`. Use for camera updates, UI animations. Keep code fast -- blocks rendering.
- `.PreAnimation:Connect(fn(deltaTime: number))` -- Fires before the animation step. Useful for modifying animation speed/priority.
- `.PreSimulation:Connect(fn(deltaTime: number))` -- Fires before physics simulation. Replacement for `Stepped`. Use for applying forces/velocities.
- `.PostSimulation:Connect(fn(deltaTime: number))` -- Fires after physics simulation. Use for final adjustments to physics results.
- `.Heartbeat:Connect(fn(deltaTime: number))` -- Fires after physics, at the end of each frame. **This is where most game logic should run.** Waiting scripts (task.wait, task.delay) also resume here.
- `.RenderStepped:Connect(fn(deltaTime: number))` -- Deprecated; use `PreRender` instead.
- `.Stepped:Connect(fn(time: number, deltaTime: number))` -- Deprecated; use `PreSimulation` instead.

## Budgets and Limits

- **Heartbeat target**: Server must complete within 33ms (30 FPS). Exceeding this causes server lag for all players.
- **PreRender/BindToRenderStep**: Blocks rendering. Long-running code here directly reduces client FPS.
- **Default priorities for BindToRenderStep**: Player Input = 100, Camera Controls = 200. Use `Enum.RenderPriority.Camera.Value - 1` to run just before camera.

## Common Patterns

### Server-side game loop

```lua
local RunService = game:GetService("RunService")

local TICK_RATE = 1 / 20 -- 20 Hz game tick
local accumulator = 0

RunService.Heartbeat:Connect(function(deltaTime: number)
    accumulator += deltaTime
    while accumulator >= TICK_RATE do
        accumulator -= TICK_RATE
        -- Run fixed-rate game logic
        updateGameState(TICK_RATE)
    end
end)
```

### Client-side camera update

```lua
local RunService = game:GetService("RunService")

RunService:BindToRenderStep("CameraShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
    local camera = workspace.CurrentCamera
    -- Apply camera shake offset
    camera.CFrame = camera.CFrame * CFrame.new(
        math.random() * shakeIntensity,
        math.random() * shakeIntensity,
        0
    )
end)
```

### Context branching in a shared module

```lua
local RunService = game:GetService("RunService")

if RunService:IsServer() then
    -- Server-only initialization
elseif RunService:IsClient() then
    -- Client-only initialization
end
```

## Pitfalls

- **PreRender is client-only**: Connecting to `PreRender` or calling `BindToRenderStep` from a server script errors.
- **Heartbeat vs PreRender**: Use `Heartbeat` for game logic. Use `PreRender`/`BindToRenderStep` only for visual updates that must happen before the frame renders. Misuse causes FPS drops.
- **IsClient and IsServer in Edit mode**: In Studio edit mode (not running), both `IsClient()` and `IsServer()` return true. Only use these checks during runtime.
- **Deprecated events**: `RenderStepped` is replaced by `PreRender`; `Stepped` is replaced by `PreSimulation`. Use the new names in new code.
- **BindToRenderStep priority ordering**: Lower priority numbers run first. If two bindings share a priority, execution order is random.

## Related

- [[task-library]] -- task.wait, task.spawn, task.delay resume during Heartbeat
- [[heartbeat-budget]] -- performance budget for server Heartbeat

## Sources

- [wiki/raw/roblox-creator-docs/services/RunService.md](../raw/roblox-creator-docs/services/RunService.md)
