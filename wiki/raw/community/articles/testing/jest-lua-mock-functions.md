---
title: Jest Lua Mock Functions — Complete Mock API Reference
type: raw-source
source_url: https://jsdotlua.github.io/jest-lua/mock-functions
captured_at: 2026-04-15
captured_by: research-agent-phase2
category: community-article
subcategory: testing
author: jsdotlua organization
tags: [testing, jest-lua, mocks, spies, mock-functions]
---

# Jest Lua Mock Functions

**Source:** https://jsdotlua.github.io/jest-lua/mock-functions
**Captured:** 2026-04-15

## Overview

Mock functions allow testing the links between code by erasing the actual implementation of a function, capturing calls to the function and the parameters passed in those calls. They also enable capturing constructor instances and configuring return values at test time.

## Creating Mock Functions

```lua
local JestGlobals = require("@Packages/JestGlobals")
local jest = JestGlobals.jest
local expect = JestGlobals.expect

local mockCallback = jest.fn()
```

## The .mock Property

All mock functions expose a `.mock` object that tracks:

- **calls** — Array of arguments passed to each invocation
- **instances** — Constructor call results
- **results** — Return values from each call

```lua
#mockFunc.mock.calls           -- count of invocations
mockFunc.mock.calls[1][1]      -- first argument of first call
mockFunc.mock.results[1].value -- return value of first call
mockFunc.mock.instances[1]     -- instance from constructor call
```

## Mock Return Values

Configure return behaviors with chainable methods:

```lua
local myMock = jest.fn()
    :mockReturnValueOnce(10)
    :mockReturnValueOnce("x")
    :mockReturnValue(true)

-- First call returns 10, second returns "x", all others return true
```

Methods:
- `mockReturnValue(value)` — default return for all calls
- `mockReturnValueOnce(value)` — single-use return, consumed in order
- `mockReturnThis()` — returns self for method chaining patterns

## Mock Implementations

Replace function logic entirely:

```lua
-- Via constructor
local myMockFn = jest.fn(function(cb)
    return cb(nil, true)
end)

-- Via mockImplementation
myMockFn:mockImplementation(function(x)
    return x * 2
end)

-- Single-call override
myMockFn:mockImplementationOnce(function(cb)
    return cb(nil, false)
end)
```

When `mockImplementationOnce` calls exhaust, execution falls back to the default implementation set via `jest.fn(impl)` or `mockImplementation`.

## Mock Names

Identify mocks in error output:

```lua
local myMock = jest.fn():mockName("onlyReturnsDefault")
```

## Spy on Existing Methods

```lua
local spy = jest.spyOn(myObject, "someMethod")
myObject:someMethod(42)
expect(spy).toHaveBeenCalled()
spy:mockRestore()
```

`jest.spyOn` wraps an existing method with a mock, preserving the original implementation by default. Call `mockRestore()` to unwrap.

## Mock Assertions (Custom Matchers)

```lua
expect(mockFn).toHaveBeenCalled()
expect(mockFn).toHaveBeenCalledTimes(3)
expect(mockFn).toHaveBeenCalledWith("hello", 42)
expect(mockFn).toHaveBeenLastCalledWith("goodbye")
expect(mockFn).toHaveBeenNthCalledWith(2, "second call arg")
```

## Resetting Mocks

- `mockClear()` — resets `.mock.calls`, `.mock.instances`, `.mock.results`; keeps implementation
- `mockReset()` — like clear but also removes return values and implementations
- `mockRestore()` — restores the original (non-mocked) implementation (only for spyOn)

## Source

Original URL: https://jsdotlua.github.io/jest-lua/mock-functions
Captured: 2026-04-15
