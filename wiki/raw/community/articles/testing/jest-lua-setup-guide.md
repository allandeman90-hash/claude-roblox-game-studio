---
title: Jest Lua Setup and Configuration Guide
type: raw-source
source_url: https://jsdotlua.github.io/jest-lua/
captured_at: 2026-04-15
captured_by: research-agent-phase2
category: community-article
subcategory: testing
author: jsdotlua organization
tags: [testing, jest-lua, setup, configuration, wally, roblox]
---

# Jest Lua Setup and Configuration

**Source:** https://jsdotlua.github.io/jest-lua/
**Captured:** 2026-04-15

## Installation via Wally

Add to `wally.toml` under dev-dependencies:

```toml
[dev-dependencies]
Jest = "jsdotlua/jest@3.10.0"
JestGlobals = "jsdotlua/jest-globals@3.10.0"
```

Run `wally install` to fetch.

## Project Configuration

### jest.config.lua

```lua
return {
    testMatch = { "**/*.spec" },
}
```

The `testMatch` array defines glob patterns for discovering test files. By default, Jest-Lua looks for ModuleScripts matching the pattern.

### default.project.json (Rojo)

Ensure test files and the Jest package are mapped into the Roblox instance tree:

```json
{
    "tree": {
        "$className": "DataModel",
        "ReplicatedStorage": {
            "Packages": {
                "$path": "Packages"
            },
            "Tests": {
                "$path": "src/tests"
            }
        }
    }
}
```

### FFlag Requirement

Jest-Lua requires the `FFlagEnableLoadModule` feature flag. Create or edit `ClientAppSettings.json`:

```json
{
    "FFlagEnableLoadModule": true
}
```

Location: `%LOCALAPPDATA%\Roblox\ClientSettings\ClientAppSettings.json` (Windows)

## Test Runner Entry Point

Create `run-tests.server.lua`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Jest = require(ReplicatedStorage.Packages.Jest)

Jest.runCLI(ReplicatedStorage.Tests, {
    verbose = true,
    ci = false,
}, { ReplicatedStorage.Tests }):await()
```

## Writing Tests

All test globals must be explicitly required from JestGlobals:

```lua
local JestGlobals = require("@Packages/JestGlobals")
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
local jest = JestGlobals.jest

describe("MyModule", function()
    it("does something", function()
        expect(1 + 1).toBe(2)
    end)
end)
```

## Running Tests

Two primary methods:

1. **Roblox Studio** — Open the place, run the test script. Output appears in the Output window.
2. **run-in-roblox CLI** — Headless execution for CI pipelines:
   ```bash
   run-in-roblox --place test-place.rbxl --script run-tests.server.lua
   ```

## Key Documentation Sections

- Using Matchers — expect().toBe(), toEqual(), toContain(), etc.
- Testing Asynchronous Code — promise-based assertions
- Setup and Teardown — beforeEach, afterEach, beforeAll, afterAll
- Mock Functions — jest.fn(), jest.spyOn(), mock implementations
- Snapshot Testing — toMatchSnapshot() for regression detection
- Deviations from JavaScript Jest — Lua-specific differences

## Deviations from JavaScript Jest

Jest-Lua follows the Jest 27.x API but with Lua idioms:
- Uses `never` instead of `not` for negation (Lua keyword conflict)
- Table equality uses deep comparison via `toEqual()`
- No automatic module mocking (manual mocking via dependency injection)
- Promise-based async instead of async/await

## Source

Original URL: https://jsdotlua.github.io/jest-lua/
Captured: 2026-04-15
