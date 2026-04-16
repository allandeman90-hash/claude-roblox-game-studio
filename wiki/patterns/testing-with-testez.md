---
title: Testing with TestEZ
type: pattern
category: patterns
subcategory: testing
owner: qa-tester
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/testing/testez-readme.md
  - wiki/raw/community/articles/testing/testez-api-reference.md
  - wiki/raw/community/articles/testing/jest-lua-readme.md
related:
  - "[[mocking-strategies]]"
  - "[[integration-testing]]"
  - "[[play-solo-team-test]]"
tags: [pattern, testing, testez, jest-lua, bdd, unit-testing]
---

# Testing with TestEZ

> BDD-style unit testing in Roblox using TestEZ's describe/it/expect API, with guidance on when to reach for Jest-Lua instead.

## Summary

TestEZ is Roblox's canonical test framework -- a BDD-style library with `describe`/`it`/`expect` syntax inspired by RSpec, Mocha, and Chai. It is used internally by Roblox to test Roact, Rodux, and core scripts. Jest-Lua is a richer community port of JavaScript's Jest (aligned to v27.4.7) that adds mocks, spies, snapshot testing, and timer control at the cost of a heavier runtime. For most gameplay code, TestEZ is the right default. For library code with complex dependency mocking, Jest-Lua pays for its weight.

## When to Use It

- **TestEZ** -- pure gameplay logic, service modules, utility functions, any code without complex mocking needs. Simpler, smaller, Roblox-native.
- **Jest-Lua** -- library code that needs `jest.fn()`, `jest.spyOn()`, snapshot regression, or timer mocking. Heavier runtime, but the Jest API is familiar to JavaScript developers.
- **Either** -- both frameworks run inside Roblox Studio. Both discover `.spec` files. Both support `describe`/`it`/`beforeEach`/`afterEach`.

## Implementation

### Project Setup (TestEZ)

Install via Wally:

```toml
[dev-dependencies]
TestEZ = "roblox/testez@0.4.1"
```

File layout -- test files live next to their modules with a `.spec` suffix:

```
src/
  shared/
    Math.luau
    Math.spec.luau       -- test for Math
  server/
    Inventory.luau
    Inventory.spec.luau
```

Test runner script:

```lua
-- ServerScriptService/TestRunner.server.lua
local TestEZ = require(game.ReplicatedStorage.Packages.TestEZ)
TestEZ.TestBootstrap:run(
    { game.ReplicatedStorage.Shared, game.ServerStorage.Services },
    TestEZ.Reporters.TextReporter
)
```

### Project Setup (Jest-Lua)

Install via Wally:

```toml
[dev-dependencies]
Jest = "jsdotlua/jest@3.10.0"
JestGlobals = "jsdotlua/jest-globals@3.10.0"
```

Requires the `FFlagEnableLoadModule` feature flag in `ClientAppSettings.json`.

Test runner:

```lua
-- ServerScriptService/TestRunner.server.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Jest = require(ReplicatedStorage.Packages.Jest)
Jest.runCLI(ReplicatedStorage.Tests, {
    verbose = true,
    ci = false,
}, { ReplicatedStorage.Tests }):await()
```

### Writing Tests (TestEZ)

TestEZ modules return a function. The outer function is invoked by the test runner to register describes and its.

```lua
-- Inventory.spec.luau
return function()
    local InventoryService = require(script.Parent.InventoryService)

    describe("InventoryService", function()
        local inventory

        beforeEach(function()
            inventory = InventoryService.new()
        end)

        describe(":add", function()
            it("should store the item", function()
                inventory:add("Sword")
                expect(inventory:contains("Sword")).to.equal(true)
            end)

            it("should not duplicate", function()
                inventory:add("Sword")
                inventory:add("Sword")
                expect(inventory:count("Sword")).to.equal(1)
            end)
        end)

        describe(":remove", function()
            it("should remove existing items", function()
                inventory:add("Sword")
                inventory:remove("Sword")
                expect(inventory:contains("Sword")).to.equal(false)
            end)

            it("should no-op on missing items", function()
                expect(function()
                    inventory:remove("NonExistent")
                end).never.to.throw()
            end)
        end)
    end)
end
```

### Writing Tests (Jest-Lua)

Jest-Lua requires explicit imports from JestGlobals. Uses camelCase matchers (`toBe`, `toEqual`) instead of TestEZ's dot-chain (`.to.equal`).

```lua
-- Inventory.spec.luau
local JestGlobals = require("@Packages/JestGlobals")
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach

local InventoryService = require(script.Parent.InventoryService)

describe("InventoryService", function()
    local inventory

    beforeEach(function()
        inventory = InventoryService.new()
    end)

    it("stores items", function()
        inventory:add("Sword")
        expect(inventory:contains("Sword")).toBe(true)
    end)

    it("rejects duplicates", function()
        inventory:add("Sword")
        inventory:add("Sword")
        expect(inventory:count("Sword")).toBe(1)
    end)
end)
```

### TestEZ Expect Matchers

```lua
expect(x).to.equal(y)              -- strict equality
expect(x).to.be.ok()               -- truthy (not nil, not false)
expect(x).to.be.near(y, epsilon)   -- approximate numeric equality
expect(x).to.be.a("string")        -- type check
expect(fn).to.throw()              -- error thrown
expect(fn).to.throw("substring")   -- error with message match

-- Negation via .never:
expect(x).never.to.equal(y)
expect(fn).never.to.throw()
```

### Jest-Lua Expect Matchers (superset)

```lua
expect(value).toBe(other)                   -- reference equality
expect(value).toEqual(other)                -- deep equality
expect(value).toStrictEqual(other)          -- deep, no extra fields
expect(arr).toContain(item)
expect(arr).toHaveLength(n)
expect(obj).toHaveProperty("nested.field")
expect(fn).toThrow()
expect(fn).toThrow("expected message")
expect(value).never.toBe(other)             -- negation

-- Async:
expect(promiseFn()).resolves.toBe(value)
expect(promiseFn()).rejects.toThrow()
```

### Lifecycle Hooks

Both frameworks support the same lifecycle:

| Hook | Runs | Use Case |
|------|------|----------|
| `beforeAll` | Once before all `it` blocks in the `describe` | Expensive one-time setup |
| `beforeEach` | Before each `it` block | Fresh test fixture |
| `afterEach` | After each `it` block (even on failure) | Cleanup, reset state |
| `afterAll` | Once after all `it` blocks complete | Teardown shared resources |

### Focus and Skip (TestEZ)

```lua
-- Run only this describe block:
describeFOCUS("only this runs", function() ... end)
-- or: fdescribe("only this runs", function() ... end)

-- Skip this test:
itSKIP("not ready yet", function() ... end)
-- or: xit("not ready yet", function() ... end)

-- Mark as broken:
itFIXME("known bug #123", function() ... end)
```

### Context Object (TestEZ)

TestEZ passes a `context` table to hooks and tests for sharing data within a `describe` scope:

```lua
return function()
    describe("with context", function()
        beforeEach(function(context)
            context.player = createTestPlayer()
        end)

        it("uses the context", function(context)
            expect(context.player).to.be.ok()
        end)
    end)
end
```

Context keys are write-once to enforce test isolation.

## Variants

| Framework | Strengths | Weaknesses |
|-----------|-----------|------------|
| **TestEZ** | Simple, lightweight, Roblox-native, battle-tested | No mocks, no snapshots, no timer control |
| **Jest-Lua** | Mocks, spies, snapshots, timer mocks, richer matchers | Heavier runtime, requires FFlag, more boilerplate imports |
| **Custom harness** | Full control, minimal overhead | Maintenance burden, no community support |

## Pitfalls

- **Forgetting `return function()` in TestEZ.** Test files must return a function. Forgetting this causes the file to be silently skipped.
- **Shared mutable state between tests.** Always use `beforeEach` to create fresh fixtures. Never rely on test execution order.
- **Testing implementation instead of behavior.** Tests that verify internal state are brittle. Test the public API surface.
- **Not testing error paths.** Happy-path-only tests miss the most common production failures. Test what happens when DataStore is down, when inputs are invalid, when the player disconnects mid-operation.
- **Running tests in production.** Guard test runner scripts with `RunService:IsStudio()` checks. Never ship test code to live servers.

## Related

- [[mocking-strategies]] -- how to mock DataStoreService, HttpService, RemoteEvents for testable code
- [[integration-testing]] -- testing client-server flows beyond unit tests
- [[play-solo-team-test]] -- Studio testing modes for manual and automated integration testing

## Sources

- [wiki/raw/community/articles/testing/testez-readme.md](../raw/community/articles/testing/testez-readme.md) -- TestEZ overview, API inspiration, file layout, TestEZ vs Jest-Lua comparison
- [wiki/raw/community/articles/testing/testez-api-reference.md](../raw/community/articles/testing/testez-api-reference.md) -- full API: describe, it, expect matchers, lifecycle hooks, FOCUS/SKIP, context, reporters
- [wiki/raw/community/articles/testing/jest-lua-readme.md](../raw/community/articles/testing/jest-lua-readme.md) -- Jest-Lua overview, installation, mocks, snapshots, timer mocks
- [wiki/raw/community/articles/testing/jest-lua-setup-guide.md](../raw/community/articles/testing/jest-lua-setup-guide.md) -- Jest-Lua Wally setup, configuration, FFlag, test runner
