---
title: TestEZ API Reference — Full BDD Testing API
type: raw-source
source_url: https://roblox.github.io/testez/api-reference/
captured_at: 2026-04-15
captured_by: research-agent-phase2
category: community-article
subcategory: testing
author: Roblox
tags: [testing, bdd, testez, api-reference, describe, it, expect, matchers]
---

# TestEZ API Reference

**Source:** https://roblox.github.io/testez/api-reference/
**Captured:** 2026-04-15

## Core Testing Functions

### describe(phrase: string, callback(context: table))

Creates a test suite block. Contains `it` blocks for specific behaviors. Nesting `describe` blocks creates readable hierarchies in output.

### it(phrase: string, callback(context: table))

Defines individual test cases within a `describe` block. Each `it` contains assertions about expected behavior.

### expect(value: any)

Initiates an assertion chain. Reads like English: `expect(x).to.equal(y)`.

## Expect Matchers

- `.to.equal(value)` — Strict equality comparison
- `.to.be.ok()` — Checks if value is truthy (nil fails, false fails)
- `.to.be.near(value, optionalLimit)` — Approximate numerical equality (default epsilon 1e-7)
- `.to.be.a(type: string)` — Type checking (`expect(x).to.be.a("string")`)
- `.to.throw(optionalMessage)` — Verifies function throws an error, optionally matching a message substring
- `.never` — Negates any assertion (`expect(x).never.to.equal(y)`)

The chained grammar (`.to.be.a(...)`) is implemented by metatables that return the same assertion object when you access `.to`, `.be`, `.a`. This pattern is lifted from Chai (JavaScript).

## Lifecycle Hooks

### beforeAll(callback(context: table))
Runs once before all tests in the enclosing `describe` block.

### beforeEach(callback(context: table))
Runs before each `it` block in the enclosing `describe`. Essential for creating fresh test fixtures.

### afterEach(callback(context: table))
Runs after each `it` block, even if the test failed. Used for cleanup.

### afterAll(callback(context: table))
Runs once after all tests in the enclosing `describe` block complete.

All lifecycle callbacks receive a `context` table parameter for sharing data between hooks and tests within the same `describe` scope. Context is write-once per key to prevent test interference.

## Focus and Skip Modifiers

### FOCUS()
Marks a `describe` block as focused. When any block is focused, only focused blocks execute. Useful for running a single test suite during development.

### SKIP()
Marks a `describe` block as skipped. Skipped blocks do not execute but are reported as skipped.

### FIXME(optionalMessage: string?)
Identifies known-broken tests. Skips the block and includes the message in the report.

### Shorthand Variants

Since FOCUS/SKIP/FIXME cannot be called inside an `it` block (they operate at the describe level), shorthand variants exist:

- `describeFOCUS` / `fdescribe` — describe with built-in FOCUS
- `describeSKIP` / `xdescribe` — describe with built-in SKIP
- `itFOCUS` / `fit` — it with built-in FOCUS
- `itSKIP` / `xit` — it with built-in SKIP
- `itFIXME` — it with built-in FIXME

## Special Files

### init.spec.lua
When a test file is named `init.spec.lua`, its code attaches to the folder's implicit describe block rather than creating a new one. This is useful for folder-level setup code.

## Context Object

The `context` table is passed to lifecycle hooks and `it` callbacks. It enables data sharing within a describe block's scope without leaking between unrelated tests. Keys are write-once to enforce test isolation.

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

## Test Runners and Reporters

### TestBootstrap:run(roots, reporter)

```lua
local TestEZ = require(ReplicatedStorage.Packages.TestEZ)
TestEZ.TestBootstrap:run({ReplicatedStorage.Tests}, TestEZ.Reporters.TextReporter)
```

### Built-in Reporters
- **TextReporter** — Prints a human-readable text summary to the Output window
- **TeamCityReporter** — Formatted output for TeamCity CI integration

### File Discovery
TestEZ walks an Instance tree and discovers ModuleScripts whose names end in `.spec`:
- `Math.spec.luau` — test for Math module
- `Inventory.spec.luau` — test for Inventory module

## Source

Original URL: https://roblox.github.io/testez/api-reference/
Captured: 2026-04-15
