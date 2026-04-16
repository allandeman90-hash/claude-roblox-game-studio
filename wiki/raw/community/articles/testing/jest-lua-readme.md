---
title: Jest Lua — Delightful Lua Testing (Jest Port for Roblox)
type: raw-source
source_url: https://github.com/jsdotlua/jest-lua
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: testing
author: jsdotlua organization (port from Roblox internal)
tags: [testing, jest, jest-lua, mocks, snapshot, roblox]
---

# Jest Lua — Delightful Lua Testing (Jest Port for Roblox)

**Author:** jsdotlua organization (based on Roblox's internal port)
**Source:** GitHub — `jsdotlua/jest-lua`
**License:** MIT

## What it is

Jest Lua is a testing framework for Luau, specifically designed for the Roblox platform. It is a Lua port of the JavaScript testing framework Jest, aligned with Jest version 27.4.7. The project's tagline is "Delightful Lua Testing," and it is used by Roblox internally to test applications, core scripts, Studio plugins, and libraries such as Roact Navigation.

It is the modern alternative to TestEZ for projects that want richer testing features — mocks, spies, snapshot testing, timer control — at the cost of a heavier runtime.

## Current limitations

From the README: the framework currently runs exclusively within Roblox environments. The maintainers actively seek help to expand compatibility to Lune and Luvit (other Lua runtimes). For now, Jest Lua tests run inside Roblox Studio or via the Open Cloud Luau Execution API — not in a bare Node-like CLI.

## Installation

Add to `wally.toml` under dev-dependencies:

```toml
[dev-dependencies]
JestGlobals = "jsdotlua/jest-globals@3.10.0"
```

Then import globals where you need them:

```lua
local JestGlobals = require("@Packages/JestGlobals")
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
```

## The Jest API ported to Lua

If you have used Jest in JavaScript, the Luau version will be immediately familiar. The key surface:

### `describe` / `it` / `beforeEach` / `afterEach`

```lua
describe("Calculator", function()
    local calc

    beforeEach(function()
        calc = Calculator.new()
    end)

    it("adds two numbers", function()
        expect(calc:add(1, 2)).toBe(3)
    end)

    it("subtracts", function()
        expect(calc:sub(5, 2)).toBe(3)
    end)
end)
```

Syntactically nearly identical to TestEZ, with one notable difference: Jest Lua uses camelCase method names (`toBe`, `toEqual`) instead of TestEZ's dot-chain syntax (`.to.equal`).

### `expect` matchers

Jest's matcher library is much larger than TestEZ's:

```lua
expect(value).toBe(other)                -- reference equality
expect(value).toEqual(other)             -- deep equality
expect(value).toStrictEqual(other)       -- deep, no extra fields allowed
expect(arr).toContain(item)
expect(arr).toHaveLength(n)
expect(obj).toHaveProperty("nested.field")
expect(fn).toThrow()
expect(fn).toThrow("expected message substring")

-- Negation:
expect(value).never.toBe(other)

-- Async (for promise-returning code):
expect(promiseFn()).resolves.toBe(value)
expect(promiseFn()).rejects.toThrow()
```

### Mocks and spies

This is Jest Lua's biggest feature gap versus TestEZ:

```lua
local jest = JestGlobals.jest

-- Create a mock function
local mockFn = jest.fn()
mockFn("hello")
expect(mockFn).toHaveBeenCalledWith("hello")
expect(mockFn).toHaveBeenCalledTimes(1)

-- Spy on an existing object method
local spy = jest.spyOn(myObject, "someMethod")
myObject:someMethod(42)
expect(spy).toHaveBeenCalled()
spy:mockRestore()

-- Mock a return value
local mockFn2 = jest.fn():mockReturnValue(42)
expect(mockFn2()).toBe(42)

-- Mock implementation
jest.fn():mockImplementation(function(x) return x * 2 end)
```

For libraries that need to verify third-party modules were called correctly, this is indispensable. TestEZ has no mocking story at all — you either write your own or use dependency injection everywhere.

### Snapshot testing

```lua
it("renders a player card", function()
    local component = PlayerCard.new({name = "Alice", level = 10})
    expect(component:render()).toMatchSnapshot()
end)
```

The first time the test runs, it stores the rendered output. Subsequent runs compare against the snapshot and fail if the output changes. Update snapshots with `jest.fn():mockClear()` or by deleting the snapshot file.

This is very useful for UI components and for serialized output that you want to "freeze" against regression.

### Timer mocks

```lua
jest.useFakeTimers()
jest.advanceTimersByTime(1000)  -- advance virtual clock
jest.runAllTimers()              -- fire everything
jest.useRealTimers()
```

Mock timer control lets you test debounce/throttle logic without waiting for real time to pass.

## Why it's heavy vs TestEZ

Jest Lua's richness costs startup time. It loads a significant runtime of matcher code, mock infrastructure, and snapshot comparison utilities. For a handful of simple unit tests, TestEZ is snappier. For a large test suite with many mocks and snapshots, Jest Lua's features save more time than they cost.

## Roblox's own usage

Roblox uses Jest Lua internally for production testing of Roact Navigation and other libraries that originated on the JS side. If you're porting a JavaScript library to Luau, or if your project has more than a handful of dependencies that need mocking, Jest Lua is the natural fit.

## Source

Original URL: https://github.com/jsdotlua/jest-lua
Captured: 2026-04-15
