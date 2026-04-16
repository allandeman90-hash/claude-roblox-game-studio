---
title: no-pcall
type: anti-pattern
category: anti-patterns
subcategory: error-handling
owner: lead-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: high
sources:
  - .claude/docs/luau-style-guide.md
  - .claude/docs/coding-standards.md
  - wiki/raw/community/devforum/pcalls-when-how-to-use.md
  - wiki/raw/roblox-creator-docs/best-practices/security/http-service.md
related:
  - "[[pcall-xpcall]]"
  - "[[DataStoreService]]"
tags: [anti-pattern, error-handling]
---

# Missing `pcall`

> Calling failable external services (DataStoreService, HttpService, MarketplaceService) without wrapping in `pcall`. An unhandled error crashes the script.

**Severity:** High

## What It Looks Like

```lua
-- DataStore without protection
local data = DataStore:GetAsync(key)
player.leaderstats.Gold.Value = data.gold

-- HttpService without protection
local response = HttpService:GetAsync("https://api.example.com/data")
local parsed = HttpService:JSONDecode(response)

-- MarketplaceService without protection
local info = MarketplaceService:GetProductInfo(productId)

-- SetAsync on player leave (crash here = data loss)
Players.PlayerRemoving:Connect(function(player)
    DataStore:SetAsync("Player_" .. player.UserId, playerData[player])
end)
```

## Why It's Bad

1. **Script crash**: DataStoreService, HttpService, and MarketplaceService make network requests that can fail at any time (rate limits, timeouts, server outages). An unhandled error terminates the entire script, not just the failing line.
2. **Data loss**: if `SetAsync` in a `PlayerRemoving` handler throws, that player's session data is lost permanently. In a `BindToClose` handler, one crash can prevent saves for all remaining players.
3. **Cascade failure**: a crashing server script takes out all logic in that Script. If the main game loop, data loading, and remote handlers all live in one script, a single DataStore hiccup kills everything.
4. **Silent corruption**: `GetAsync` might return `nil` on failure instead of throwing. Without checking `success`, the code treats `nil` as the player's data and overwrites real data with defaults on the next save.
5. **Rate limit exhaustion**: without pcall + retry logic, a rate-limited call fails once and is never retried, leaving the player with missing data.

## How to Fix It

Wrap every external service call in `pcall` and handle the failure path:

```lua
-- Basic pcall pattern
local success, data = pcall(function()
    return DataStore:GetAsync(key)
end)

if success then
    applyData(player, data)
else
    warn("DataStore GetAsync failed for", player.Name, ":", tostring(data))
    applyData(player, getDefaultData())
end
```

For critical operations, add retry logic with exponential backoff:

```lua
local function retryAsync(fn: () -> any, maxRetries: number): (boolean, any)
    for attempt = 1, maxRetries do
        local success, result = pcall(fn)
        if success then
            return true, result
        end
        warn("Attempt", attempt, "failed:", tostring(result))
        if attempt < maxRetries then
            task.wait(2 ^ attempt)  -- 2s, 4s, 8s, ...
        end
    end
    return false, nil
end

-- Usage
local success, data = retryAsync(function()
    return DataStore:GetAsync("Player_" .. player.UserId)
end, 5)
```

For `BindToClose`, ensure all players save even if individual saves fail:

```lua
game:BindToClose(function()
    local threads = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(threads, task.spawn(function()
            local ok, err = pcall(function()
                DataStore:SetAsync("Player_" .. player.UserId, playerData[player])
            end)
            if not ok then
                warn("BindToClose save failed for", player.Name, ":", err)
            end
        end))
    end
    -- BindToClose has 30 seconds before forced shutdown
end)
```

## Detection

Grep for unprotected external service calls:

```
:GetAsync(
:SetAsync(
:UpdateAsync(
:IncrementAsync(
:RemoveAsync(
HttpService:GetAsync(
HttpService:PostAsync(
HttpService:RequestAsync(
MarketplaceService:GetProductInfo(
Players:GetUserIdFromNameAsync(
```

Then check whether each match is inside a `pcall` or `xpcall` wrapper. Lines not inside a pcall are violations.

## Related

- [[pcall-xpcall]]
- [[DataStoreService]]

## Sources

- [DevForum: Pcalls - When and how to use them](../raw/community/devforum/pcalls-when-how-to-use.md)
- [Roblox Creator Docs: HttpService best practices](../raw/roblox-creator-docs/best-practices/security/http-service.md) -- "Handle errors gracefully" section
- [Luau Style Guide](../../.claude/docs/luau-style-guide.md) -- Section 6: Error Handling
