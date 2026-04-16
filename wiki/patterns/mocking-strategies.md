---
title: Mocking Strategies
type: pattern
category: patterns
subcategory: testing
owner: qa-tester
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/testing/mocking-roblox-services.md
  - wiki/raw/community/articles/testing/jest-lua-mock-functions.md
  - wiki/raw/community/articles/testing/jest-lua-readme.md
related:
  - "[[testing-with-testez]]"
  - "[[integration-testing]]"
  - "[[DataStoreService]]"
  - "[[HttpService]]"
  - "[[RemoteEvent]]"
tags: [pattern, testing, mocking, dependency-injection, testability]
---

# Mocking Strategies

> How to mock DataStoreService, HttpService, RemoteEvents, and other Roblox singletons for unit testing, using dependency injection and mock objects.

## Summary

Roblox services are global singletons retrieved via `game:GetService()`. They cannot be called in unit tests -- DataStoreService requires a live session, HttpService hits real endpoints, RemoteEvents need a client-server split. Making Roblox code testable requires decoupling modules from their service dependencies. The community has converged on three patterns: constructor injection, service locator, and module-level injection tables. For call tracking and assertions, Jest-Lua's `jest.fn()` and `jest.spyOn()` replace hand-rolled mocks.

## When to Use It

- Any module that calls DataStoreService, HttpService, MessagingService, or MemoryStoreService.
- Any module that fires or listens to RemoteEvents/RemoteFunctions.
- Any module with side effects (network calls, persistent storage, analytics) that should be testable in isolation.
- Skip mocking for pure functions (math, string manipulation, config lookups) -- test those directly.

## Implementation

### Pattern 1: Constructor Injection (Recommended)

Pass dependencies into the module constructor. Production code passes real services; tests pass mocks.

```lua
-- ServerStorage/Services/PlayerDataService.lua
local PlayerDataService = {}

function PlayerDataService.new(dataStore)
    local self = {
        _dataStore = dataStore
            or game:GetService("DataStoreService"):GetDataStore("PlayerData"),
    }
    return setmetatable(self, { __index = PlayerDataService })
end

function PlayerDataService:load(userId: number): any?
    local success, data = pcall(function()
        return self._dataStore:GetAsync("player_" .. userId)
    end)
    return success and data or nil
end

function PlayerDataService:save(userId: number, data: any): boolean
    local success = pcall(function()
        self._dataStore:SetAsync("player_" .. userId, data)
    end)
    return success
end

return PlayerDataService
```

Test with a mock DataStore:

```lua
return function()
    local PlayerDataService = require(path.to.PlayerDataService)

    describe("PlayerDataService", function()
        local mockDataStore, service

        beforeEach(function()
            mockDataStore = {
                _data = {},
                GetAsync = function(self, key)
                    return self._data[key]
                end,
                SetAsync = function(self, key, value)
                    self._data[key] = value
                end,
            }
            service = PlayerDataService.new(mockDataStore)
        end)

        it("loads stored data", function()
            mockDataStore._data["player_123"] = { gold = 500 }
            local data = service:load(123)
            expect(data.gold).to.equal(500)
        end)

        it("returns nil on failure", function()
            mockDataStore.GetAsync = function()
                error("DataStore is down")
            end
            expect(service:load(123)).to.equal(nil)
        end)

        it("saves data", function()
            service:save(123, { gold = 100 })
            expect(mockDataStore._data["player_123"].gold).to.equal(100)
        end)
    end)
end
```

### Pattern 2: Service Locator

A central registry resolves services. Tests swap entries before requiring the module under test.

```lua
-- ReplicatedStorage/Shared/ServiceLocator.lua
local ServiceLocator = {}
local overrides = {}

function ServiceLocator.get(serviceName: string)
    return overrides[serviceName] or game:GetService(serviceName)
end

function ServiceLocator.override(serviceName: string, mock: any)
    overrides[serviceName] = mock
end

function ServiceLocator.reset()
    table.clear(overrides)
end

return ServiceLocator
```

Production code uses `ServiceLocator.get("DataStoreService")` instead of `game:GetService()`. Tests call `override()` before each test and `reset()` after.

### Pattern 3: Module-Level Injection Table

Expose the dependency table; tests overwrite entries directly.

```lua
local CurrencyService = {}
CurrencyService._deps = {
    dataStore = game:GetService("DataStoreService"):GetDataStore("Currency"),
}

function CurrencyService.getBalance(userId: number): number
    local ok, bal = pcall(function()
        return CurrencyService._deps.dataStore:GetAsync("bal_" .. userId)
    end)
    return ok and (bal or 0) or 0
end

return CurrencyService
```

Test: `CurrencyService._deps.dataStore = mockDataStore` before calling `getBalance`.

## Mock Implementations for Common Services

### DataStoreService Mock

```lua
local function createMockDataStore(initialData)
    local data = initialData or {}
    return {
        GetAsync = function(self, key) return data[key] end,
        SetAsync = function(self, key, value) data[key] = value end,
        UpdateAsync = function(self, key, transformFn)
            data[key] = transformFn(data[key])
            return data[key]
        end,
        RemoveAsync = function(self, key) data[key] = nil end,
    }
end

local function createMockDataStoreService()
    local stores = {}
    return {
        GetDataStore = function(self, name)
            if not stores[name] then
                stores[name] = createMockDataStore()
            end
            return stores[name]
        end,
    }
end
```

### HttpService Mock

```lua
local function createMockHttpService(responses)
    responses = responses or {}
    return {
        RequestAsync = function(self, options)
            local key = options.Method .. " " .. options.Url
            local response = responses[key]
            if response then return response end
            error("No mock response for: " .. key)
        end,
        JSONEncode = function(self, tbl)
            return game:GetService("HttpService"):JSONEncode(tbl)
        end,
        JSONDecode = function(self, json)
            return game:GetService("HttpService"):JSONDecode(json)
        end,
    }
end
```

Usage in test:

```lua
local mockHttp = createMockHttpService({
    ["GET https://api.example.com/data"] = {
        Success = true,
        StatusCode = 200,
        Body = '{"result": "ok"}',
    },
})
```

### RemoteEvent Mock

```lua
local function createMockRemoteEvent()
    local serverCallbacks = {}
    return {
        _lastFiredArgs = nil,

        FireServer = function(self, ...)
            self._lastFiredArgs = { ... }
            for _, fn in serverCallbacks do fn(...) end
        end,

        FireClient = function(self, player, ...)
            self._lastFiredArgs = { player, ... }
        end,

        FireAllClients = function(self, ...)
            self._lastFiredArgs = { ... }
        end,

        OnServerEvent = {
            Connect = function(_, fn)
                table.insert(serverCallbacks, fn)
                return {
                    Disconnect = function()
                        local idx = table.find(serverCallbacks, fn)
                        if idx then table.remove(serverCallbacks, idx) end
                    end,
                }
            end,
        },
    }
end
```

### Jest-Lua Mocks (when richer tracking is needed)

```lua
local JestGlobals = require("@Packages/JestGlobals")
local jest = JestGlobals.jest
local expect = JestGlobals.expect

-- Create a mock function
local mockSave = jest.fn()
mockSave("player_123", { gold = 100 })
expect(mockSave).toHaveBeenCalledWith("player_123", { gold = 100 })
expect(mockSave).toHaveBeenCalledTimes(1)

-- Spy on an existing method
local spy = jest.spyOn(myService, "save")
myService:save(123, data)
expect(spy).toHaveBeenCalled()
spy:mockRestore()

-- Mock return values
local mockGet = jest.fn():mockReturnValue({ gold = 500 })
expect(mockGet()).toEqual({ gold = 500 })

-- Mock implementation
local mockProcess = jest.fn():mockImplementation(function(x)
    return x * 2
end)
expect(mockProcess(5)).toBe(10)
```

## Variants

| Pattern | Pros | Cons |
|---------|------|------|
| **Constructor injection** | Explicit deps, easy to test, no globals | Requires changing module API |
| **Service locator** | Minimal code changes | Hidden global state, harder to trace |
| **Module-level injection** | Zero API change | Brittle, test can corrupt module state |
| **Jest-Lua jest.fn()** | Call tracking, assertions, chaining | Requires Jest-Lua dependency |
| **Hand-rolled mocks** | No dependencies, full control | Boilerplate, no call tracking |

## Pitfalls

- **Mocking too much.** If every dependency is mocked, the test verifies the mock wiring, not the actual behavior. Mock at the boundary (DataStore, HTTP, Remotes) and let intermediate modules run for real.
- **Not testing error paths.** Override mock methods to `error()` and verify pcall handling. DataStore failures are common in production.
- **Forgetting to reset mocks between tests.** Use `beforeEach` to create fresh mocks. Shared mutable mock state between tests causes order-dependent failures.
- **Mocking methods your code does not call.** Keep mock implementations minimal. Add methods only as tests require them. This also documents which parts of the API your code actually uses.
- **Testing private implementation.** Mock the external dependency, test the public API. If refactoring internals breaks tests, the tests are too tightly coupled.

## Related

- [[testing-with-testez]] -- framework setup and test writing patterns
- [[integration-testing]] -- testing real client-server flows without mocks
- [[DataStoreService]] -- the most commonly mocked Roblox service
- [[HttpService]] -- outbound HTTP calls that need mocking
- [[RemoteEvent]] -- client-server messaging that needs mocking in unit tests

## Sources

- [wiki/raw/community/articles/testing/mocking-roblox-services.md](../raw/community/articles/testing/mocking-roblox-services.md) -- constructor injection, service locator, module injection, mock implementations for DataStore/Http/Remote
- [wiki/raw/community/articles/testing/jest-lua-mock-functions.md](../raw/community/articles/testing/jest-lua-mock-functions.md) -- jest.fn(), jest.spyOn(), mock assertions, mock reset/clear/restore
- [wiki/raw/community/articles/testing/jest-lua-readme.md](../raw/community/articles/testing/jest-lua-readme.md) -- Jest-Lua mock and spy overview
