---
title: Integration Testing
type: pattern
category: patterns
subcategory: testing
owner: qa-tester
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/testing/integration-testing-roblox.md
  - wiki/raw/community/articles/testing/load-testing-stress-testing.md
related:
  - "[[testing-with-testez]]"
  - "[[mocking-strategies]]"
  - "[[play-solo-team-test]]"
  - "[[heartbeat-budget]]"
  - "[[server-memory-budget]]"
  - "[[bandwidth-budget]]"
tags: [pattern, testing, integration-testing, load-testing, team-test, client-server]
---

# Integration Testing

> Testing client-server interactions, multi-player scenarios, and server performance under load in Roblox Studio, beyond what unit tests with mocks can catch.

## Summary

Unit tests with mocks verify isolated logic but miss integration bugs: wrong remote argument order, type mismatches between client and server, replication timing, and race conditions under concurrent players. Roblox Studio provides playtest modes (Play, Run, Team Test) for manual and automated integration testing. For load testing beyond Studio's 8-client limit, server-side bot scripts simulate higher player counts. The MicroProfiler and Developer Console provide real-time performance data during tests.

## When to Use It

- After unit tests pass but before shipping. Integration tests catch the bugs that mocks hide.
- When adding or modifying RemoteEvent/RemoteFunction flows.
- When changing DataStore save/load logic that affects the join/leave lifecycle.
- When optimizing for higher player counts (load testing).
- When investigating production bugs that only reproduce with multiple players.

## Implementation

### Studio Playtest Modes

| Mode | What It Does | Best For |
|------|-------------|----------|
| **Play (F5)** | Local server + 1 client in same window | Single-player feature testing, fast iteration |
| **Run (F8)** | Server only, no client | Server-only scripts, DataStore logic, scheduled events |
| **Team Test** | Separate server + N client windows (1-8) | Multi-player interactions, remote flows, replication |

Team Test is the primary integration testing mode:

1. Click **Start Server** on the Test tab -- launches a server window
2. Click **Start Player** -- each click opens a new client window
3. Set player count (1-8) in the Test tab dropdown

Each client runs the full client stack (LocalScripts, UI, PlayerScripts). The server runs the full server stack. RemoteEvents/RemoteFunctions work exactly as in production.

### Manual Smoke Test Checklist

The simplest integration test is a structured manual walkthrough:

```
[ ] Player A joins -- data loads, character spawns, UI appears
[ ] Player A triggers action -- server validates, client sees result
[ ] Player B joins -- sees Player A in-game, independent state
[ ] Player A and B interact -- trade/combat/chat works correctly
[ ] Player A disconnects -- data saves, Player B unaffected
[ ] Server shuts down -- all players' data saved within 30s
[ ] Rejoin after disconnect -- data persisted correctly
```

### Automated Server-Side Integration Tests

Run integration tests as guarded server scripts:

```lua
-- ServerScriptService/IntegrationTests.server.lua
if not game:GetService("RunService"):IsStudio() then return end

local Players = game:GetService("Players")
local PlayerDataService = require(game.ServerStorage.Services.PlayerDataService)

local function waitForPlayer(): Player
    if #Players:GetPlayers() > 0 then
        return Players:GetPlayers()[1]
    end
    return Players.PlayerAdded:Wait()
end

local results = {}

local function test(name: string, fn: () -> ())
    local ok, err = pcall(fn)
    table.insert(results, {
        name = name,
        passed = ok,
        error = if ok then nil else tostring(err),
    })
end

task.spawn(function()
    local player = waitForPlayer()
    task.wait(2) -- let player fully initialize

    test("Player data loads on join", function()
        local data = PlayerDataService.getData(player)
        assert(data ~= nil, "data should exist")
        assert(type(data.gold) == "number", "gold should be number")
    end)

    test("Player data has required fields", function()
        local data = PlayerDataService.getData(player)
        assert(data.gold ~= nil, "missing gold")
        assert(data.level ~= nil, "missing level")
        assert(data.inventory ~= nil, "missing inventory")
    end)

    -- Print results
    local passed, failed = 0, 0
    for _, r in results do
        if r.passed then
            passed += 1
            print("[PASS] " .. r.name)
        else
            failed += 1
            warn("[FAIL] " .. r.name .. ": " .. r.error)
        end
    end
    print(string.format("[INTEGRATION] %d passed, %d failed", passed, failed))
end)
```

### Client-Server Contract Testing

Define remote payload shapes in a shared module. Both client and server validate against the contract. Unit test the contract; trust it in integration.

```lua
-- ReplicatedStorage/Shared/Contracts/PurchaseContract.lua
local PurchaseContract = {}

export type PurchaseRequest = {
    itemId: string,
    quantity: number,
}

function PurchaseContract.validateRequest(data: any): (boolean, string?)
    if type(data) ~= "table" then return false, "not a table" end
    if type(data.itemId) ~= "string" then return false, "itemId not string" end
    if type(data.quantity) ~= "number" then return false, "quantity not number" end
    if data.quantity < 1 or data.quantity > 99 then
        return false, "quantity out of range"
    end
    return true, nil
end

return PurchaseContract
```

The server handler validates with the contract:

```lua
Remotes.Purchase.OnServerEvent:Connect(function(player, request)
    local valid, err = PurchaseContract.validateRequest(request)
    if not valid then
        warn("Invalid purchase from", player.Name, ":", err)
        return
    end
    -- proceed with validated request
end)
```

### Load Testing with Bot Scripts

For player counts beyond Studio's 8-client limit, simulate server-side load:

```lua
-- ServerScriptService/LoadTest/BotSimulator.server.lua
if not game:GetService("RunService"):IsStudio() then return end

local RunService = game:GetService("RunService")

local BOT_COUNT = 50
local bots = table.create(BOT_COUNT)

for i = 1, BOT_COUNT do
    bots[i] = {
        id = 1000000 + i,
        gold = math.random(0, 10000),
        position = Vector3.new(
            math.random(-500, 500), 5, math.random(-500, 500)
        ),
        lastAction = os.clock(),
    }
end

RunService.Heartbeat:Connect(function(dt)
    for _, bot in bots do
        -- Simulate per-player computation cost
        bot.position += Vector3.new(
            math.random() * 2 - 1, 0, math.random() * 2 - 1
        ) * 16 * dt

        if os.clock() - bot.lastAction > 5 then
            bot.lastAction = os.clock()
            bot.gold += math.random(-10, 10)
        end
    end
end)

-- Performance monitor
task.spawn(function()
    while true do
        local stats = game:GetService("Stats")
        print(string.format(
            "[LOAD] Bots: %d | Heartbeat: %.1fms | Memory: %.0fMB",
            BOT_COUNT,
            stats.HeartbeatTimeMs,
            stats:GetTotalMemoryUsageMb()
        ))
        task.wait(5)
    end
end)
```

### Performance Targets During Load Tests

| Metric | Target | Tool |
|--------|--------|------|
| Server heartbeat | <33ms (30 FPS) | MicroProfiler, Stats.HeartbeatTimeMs |
| Server memory | <2GB | Stats:GetTotalMemoryUsageMb() |
| Network per player | <50 KB/s | Developer Console > Network |
| DataStore calls/min | Within budget | Count pcall wrappers |
| Client FPS | >30 mobile, >60 PC | Stats.FPS |

Use the MicroProfiler (Ctrl+F6 in Studio) during load tests to identify which functions consume the most frame time.

## Variants

| Approach | Player Count | Realism | Setup Cost |
|----------|-------------|---------|------------|
| **Studio Team Test** | 1-8 | High (real clients) | Low |
| **Server bot scripts** | 10-200+ | Medium (no real clients) | Medium |
| **Published place test** | 1-100+ | Highest (real network) | High |
| **Open Cloud Luau API** | Automated | Medium | High |

## Pitfalls

- **Testing only the happy path.** Integration tests must cover disconnects, DataStore failures, invalid remote arguments, and race conditions.
- **No Studio guard.** Every test script must check `RunService:IsStudio()` and bail in production. Shipping test code to live servers wastes resources and risks exposing test endpoints.
- **Confusing load test artifacts with bugs.** Bot scripts do not create real Player instances or fire real remotes. They measure server-side computation cost, not full-stack behavior. For full realism, use published place tests.
- **Ignoring scaling curves.** Track metrics as bot count increases. Linear growth is acceptable; quadratic growth (e.g., O(N^2) player-vs-player loops) needs spatial partitioning or other optimization.
- **Not cleaning up.** Bot scripts that run indefinitely consume heartbeat budget. Add an auto-shutdown timer or a toggle remote.

## Related

- [[testing-with-testez]] -- unit testing framework setup
- [[mocking-strategies]] -- how to mock services for unit tests
- [[play-solo-team-test]] -- Studio testing modes reference
- [[heartbeat-budget]] -- the 33ms frame budget that load tests stress
- [[server-memory-budget]] -- memory limits to monitor during load tests
- [[bandwidth-budget]] -- per-player network budget to track

## Sources

- [wiki/raw/community/articles/testing/integration-testing-roblox.md](../raw/community/articles/testing/integration-testing-roblox.md) -- Studio playtest modes, automated integration tests, contract testing, load testing bots
- [wiki/raw/community/articles/testing/load-testing-stress-testing.md](../raw/community/articles/testing/load-testing-stress-testing.md) -- stress testing approaches, metrics, common findings, bot scripts
