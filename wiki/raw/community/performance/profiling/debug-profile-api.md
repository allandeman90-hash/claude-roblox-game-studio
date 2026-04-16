---
title: debug.profilebegin and debug.profileend API
type: raw-source
source_url: https://devforum.roblox.com/t/lua-performance-profiling-api/28934
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: profiling
tags: [debug-profilebegin, profile-api, microprofiler, instrumentation]
---

# debug.profilebegin and debug.profileend API

## Overview

`debug.profilebegin()` and `debug.profileend()` create custom labeled profiling scopes that appear in:
- The **MicroProfiler** (Ctrl+Alt+F6)
- The **Script Profiler**

This lets developers measure specific code paths without relying on engine-provided scopes.

## Basic Usage

```lua
debug.profilebegin("MyExpensiveFunction")

-- ... code to measure ...

debug.profileend()
```

The label appears in the MicroProfiler timeline at the call stack level where you invoked it.

## Nested Scopes

Scopes can be nested for hierarchical profiling:

```lua
debug.profilebegin("OuterLoop")
for i = 1, 100 do
    debug.profilebegin("InnerWork")
    doExpensiveWork(i)
    debug.profileend()
end
debug.profileend()
```

## Common Patterns

### Critical Systems
```lua
RunService.Heartbeat:Connect(function(dt)
    debug.profilebegin("AI.Update")
    AI:Update(dt)
    debug.profileend()
    
    debug.profilebegin("Physics.Custom")
    PhysicsSystem:Update(dt)
    debug.profileend()
end)
```

### Per-Module Scoping
Wrap public methods of heavy modules:

```lua
function Combat:Update(dt)
    debug.profilebegin("Combat.Update")
    -- work...
    debug.profileend()
end
```

## Overhead

The actual overhead when MicroProfiler is inactive is not officially documented. Community consensus: overhead is very low (nanoseconds per call), safe to leave in production.

However, for extremely hot loops (millions of calls per frame), even no-op function calls add up. Consider gating with a constant:

```lua
local PROFILE_ENABLED = true  -- or false in production

local function profileBegin(label)
    if PROFILE_ENABLED then
        debug.profilebegin(label)
    end
end

local function profileEnd()
    if PROFILE_ENABLED then
        debug.profileend()
    end
end
```

## Parallel Luau Restrictions

`debug.profilebegin` and `debug.profileend` may error in parallel/Actor contexts in certain configurations. Check Actor-specific documentation.

## Best Practices

1. **Label meaningfully**: "PlayerDamageCalc" not "step1"
2. **Use namespace dots**: "Combat.DealDamage" for hierarchy
3. **Always pair begin/end**: Use `pcall` for safety if errors possible
4. **Don't over-profile**: Only wrap top-level entries of hot paths
5. **Leave them in**: Code survives to help future debugging

## Safe Error Pattern

```lua
debug.profilebegin("RiskyOperation")
local ok, err = pcall(doRiskyThing)
debug.profileend()  -- ALWAYS called
if not ok then error(err) end
```

## Source

Original URLs:
- https://devforum.roblox.com/t/lua-performance-profiling-api/28934
- https://devforum.roblox.com/t/performance-overhead-of-microprofiler-labels-with-debugprofilebeginend/2074492

Captured: 2026-04-16
