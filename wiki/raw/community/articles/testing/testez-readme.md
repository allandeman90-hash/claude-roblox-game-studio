---
title: TestEZ — BDD-Style Testing Framework for Roblox Luau
type: raw-source
source_url: https://github.com/Roblox/testez
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: testing
author: Roblox
tags: [testing, bdd, testez, describe-it, assertions]
---

# TestEZ — BDD-Style Testing Framework for Roblox Luau

**Author:** Roblox
**Source:** GitHub — `Roblox/testez`
**Docs:** https://roblox.github.io/testez/
**License:** Apache-2.0

## What it is

TestEZ is a BDD-style Roblox Lua testing framework. It is Roblox's internal testing framework for its applications, in-game CoreScripts, Studio plugins, and libraries including Roact and Rodux. It runs inside Roblox Studio and in Lemur for continuous integration testing environments.

It is the canonical test framework of the pre-Jest-Lua Roblox ecosystem — and is still in wide use because its API is simpler and its runtime assumptions are lighter than Jest-Lua's.

## API inspiration

The syntax is inherited from two well-known families:

- **`describe` / `it`** — behavior-driven development syntax, as used by RSpec (Ruby), Mocha (JavaScript), busted (Lua), and Ginkgo (Go)
- **`expect`** — assertion syntax modeled after Chai, the JavaScript library commonly paired with Mocha

Together, a TestEZ test reads like English:

```lua
return function()
    describe("Math", function()
        it("should add two numbers", function()
            expect(1 + 1).to.equal(2)
        end)

        it("should multiply correctly", function()
            expect(3 * 4).to.equal(12)
        end)
    end)
end
```

The outer `return function() ... end` is the convention — test modules are ModuleScripts that return a function, which the TestEZ runner invokes to register the describes and its.

## The describe/it/beforeEach pattern

```lua
return function()
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
        end)
    end)
end
```

- `describe` blocks group related tests. Nesting describes creates readable hierarchies in output.
- `it` blocks are individual test cases.
- `beforeEach` runs before each `it`, giving a fresh test fixture.
- `afterEach` runs after each `it`, for cleanup.

## `expect` — the assertion DSL

```lua
expect(x).to.equal(y)
expect(x).to.be.ok()
expect(x).to.be.near(y, epsilon)
expect(fn).to.throw()

-- Negation via `.never`:
expect(x).never.to.equal(y)
expect(fn).never.to.throw()

-- Type assertions:
expect(x).to.be.a("string")
```

The chained grammar (`expect(x).to.be.a(...)`) is implemented by metatables that return the same assertion object when you access `.to`, `.be`, `.a`, etc. This pattern is lifted directly from Chai.

## Running tests

```lua
local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

-- Run all tests under ReplicatedStorage.Tests
TestEZ.TestBootstrap:run({ReplicatedStorage.Tests}, TestEZ.Reporters.TextReporter)
```

TestEZ provides multiple reporters:

- **`TextReporter`** — prints a text summary to Output
- **`TeamCityReporter`** — for TeamCity CI integration

TestEZ also exposes a granular lifecycle API so you can run tests inside your own pipeline, collect results programmatically, and build custom reporters.

## File layout conventions

TestEZ discovers test files by walking an Instance tree and looking for ModuleScripts whose names end in `.spec`:

```
src/
  shared/
    Math.luau
    Math.spec.luau       <- test for Math
  server/
    Inventory.luau
    Inventory.spec.luau
```

With Rojo, both files live next to each other on disk and TestEZ finds the `.spec` variant automatically.

## Why TestEZ (and why not Jest-Lua)

TestEZ is:
- **Simpler and smaller** — just describe/it/expect, no module mocking, no snapshot testing
- **Roblox-native** — written for Roblox's environment from the start, doesn't assume Node-like semantics
- **Battle-tested** — used by Roblox internally at scale

Jest-Lua is:
- **Richer** — snapshot testing, mocks, spies, timer control
- **Familiar to JS devs** — the Jest API port is faithful
- **Heavier runtime** — boots more infrastructure per run

For pure gameplay code with no complex mocking needs, TestEZ is usually the right call. For libraries that need to mock third-party dependencies or snapshot UI output, Jest-Lua pays for its weight.

## Source

Original URL: https://github.com/Roblox/testez
Docs: https://roblox.github.io/testez/
Captured: 2026-04-15
