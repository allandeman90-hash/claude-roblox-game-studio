---
title: print-in-production
type: anti-pattern
category: anti-patterns
subcategory: code-quality
owner: lead-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: low
sources:
  - .claude/docs/coding-standards.md
  - wiki/raw/roblox-creator-docs/best-practices/security/access-control.md
related:
  - "[[server-authority]]"
tags: [anti-pattern, code-quality]
---

# `print()` in Production Code

> Using `print()` statements in shipped code. Wastes CPU, leaks implementation details to exploiters, and pollutes the output log.

**Severity:** Low

## What It Looks Like

```lua
-- Debug prints left in production code
Players.PlayerAdded:Connect(function(player)
    print("Player joined: " .. player.Name)
    print("Loading data for UserId: " .. player.UserId)
    local data = loadData(player)
    print("Data loaded:", data)
    print("Gold:", data.gold, "Level:", data.level)
end)

-- Print inside a hot loop
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        print("Processing player:", player.Name)
        updatePlayer(player)
    end
end)

-- Printing remote arguments (leaks validation logic to exploiters)
remote.OnServerEvent:Connect(function(player, action, data)
    print("Remote received:", player.Name, action, data)
    -- ...
end)
```

## Why It's Bad

1. **CPU cost in hot paths**: `print()` is not free. Each call serializes its arguments to strings, formats the output, and pushes to the output buffer. Inside a `Heartbeat` or `RenderStepped` loop running 60 times per second for every player, print calls measurably impact frame time.
2. **Information leakage**: on the client, print output goes to the developer console (F9), which players can open. Exploiters routinely inspect the console to learn remote names, data formats, validation logic, and internal state -- information that helps them craft attacks. The Roblox Creator Docs warn against "overly descriptive or predictable names for sensitive instances" and the same principle applies to log output.
3. **Log noise**: in production, meaningful warnings and errors from `warn()` and the engine get buried under thousands of debug print lines. When investigating a live issue, signal-to-noise ratio is critical.
4. **Memory pressure**: on long-running servers, print output accumulates in the log buffer. While the buffer has limits, the string allocations for formatting still occur and contribute to GC pressure.
5. **False sense of debugging**: print-based debugging is the least efficient method. Roblox provides the MicroProfiler, the developer console, and structured logging via `warn()` and custom log modules. Relying on print trains developers to leave noise in the codebase.

## How to Fix It

Replace with a structured logging module that supports level filtering:

```lua
-- Shared/Logger.lua
local Logger = {}

local LOG_LEVEL = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

local currentLevel = LOG_LEVEL.WARN  -- production default

function Logger.setLevel(level: string)
    currentLevel = LOG_LEVEL[level] or LOG_LEVEL.WARN
end

function Logger.debug(...)
    if currentLevel <= LOG_LEVEL.DEBUG then
        print("[DEBUG]", ...)
    end
end

function Logger.info(...)
    if currentLevel <= LOG_LEVEL.INFO then
        print("[INFO]", ...)
    end
end

function Logger.warn(...)
    warn("[WARN]", ...)
end

function Logger.error(...)
    warn("[ERROR]", ...)
end

return Logger
```

Usage:

```lua
local Logger = require(ReplicatedStorage.Shared.Logger)

-- In development, enable debug output via a config flag:
if Config.DEBUG_MODE then
    Logger.setLevel("DEBUG")
end

Players.PlayerAdded:Connect(function(player)
    Logger.debug("Player joined:", player.Name)
    local data = loadData(player)
    Logger.info("Data loaded for", player.UserId)
end)
```

For production builds:
- Set log level to `WARN` or `ERROR`.
- Use `warn()` for actual warnings (not debug output).
- Gate debug prints behind a `DEBUG` flag that is `false` in production.
- The `validate-commit.sh` hook catches bare `print(` in staged files.

## Detection

```
print(
print %(
[^_]print(
```

Exclude test files, logger modules, and explicit debug-gated blocks. Any bare `print()` call in `ServerScriptService/` or `StarterPlayer/` files is a candidate for removal or replacement.

## Related

- [[server-authority]]

## Sources

- [Roblox Creator Docs: Access control](../raw/roblox-creator-docs/best-practices/security/access-control.md) -- "Avoid overly descriptive or predictable names" guidance applies to log output
- [Coding Standards](../../.claude/docs/coding-standards.md) -- Section 6: Error Handling
