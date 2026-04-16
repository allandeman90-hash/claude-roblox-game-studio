---
title: DataStore Best Practices — pcall, Retry, Budget, and Race Conditions
type: raw-source
source_url: https://create.roblox.com/docs/cloud-services/data-stores/best-practices
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: datastore
tags: [datastore, pcall, retry, budget, best-practices, race-conditions]
---

# DataStore Best Practices — pcall, Retry, Budget, and Race Conditions

**Sources:** Roblox official docs on DataStore best practices + community writeups

## The three core rules

If you write raw DataStore code (rather than using ProfileStore or DataStore2), three rules matter more than any others:

1. **Always wrap in `pcall`.** Every call can fail.
2. **Always check the request budget** before firing.
3. **Use `UpdateAsync` for shared keys** to avoid race conditions.

Everything else is incremental. Get these three right and most DataStore pain goes away.

## Why `pcall` is non-negotiable

DataStore requests can fail due to network issues, rate limits, or service outages — so wrap all DataStore operations in `pcall` to catch errors gracefully. Unhandled DataStore errors cascade: one failed `:GetAsync()` inside `PlayerAdded` can crash the connect, which leaves the player in a partial-load state that other systems assume is impossible.

```lua
local success, data = pcall(function()
    return DataStoreService:GetDataStore("PlayerData"):GetAsync("Player_" .. userId)
end)

if not success then
    warn("DataStore read failed:", data)
    -- `data` contains the error string on failure
    return
end
```

Two specific tips:

- **Wrap only the code that might fail**, not large blocks. This isolates errors so you know exactly what failed.
- **Inspect the error string** — some errors are retryable (timeout), some aren't (schema violations). You'll want different handling.

## Retry with exponential backoff

A naive retry loop tries again immediately and hammers the same failing endpoint. Exponential backoff waits longer after each failure, spreading retries out and giving the service time to recover:

```lua
local function retryWithBackoff(fn, maxAttempts)
    maxAttempts = maxAttempts or 5
    local attempt = 0
    while attempt < maxAttempts do
        attempt += 1
        local ok, result = pcall(fn)
        if ok then
            return true, result
        end
        warn("Attempt", attempt, "failed:", result)
        if attempt < maxAttempts then
            local delay = 2 ^ (attempt - 1)  -- 1, 2, 4, 8 seconds
            task.wait(delay + math.random() * 0.5)  -- jitter to avoid thundering herd
        end
    end
    return false, "max retries exceeded"
end

local ok, data = retryWithBackoff(function()
    return DataStoreService:GetDataStore("PlayerData"):GetAsync("Player_" .. userId)
end)
```

Notes:
- The jitter (`math.random() * 0.5`) is important: without it, many servers failing at the same moment all retry at exactly the same intervals and overwhelm the service again.
- After `maxAttempts` failures, the data is *unknown*, not *empty*. Do not save zero-filled defaults back — see DataStore2's backup mode for the right pattern.

## Request budget management

Every place has a per-minute DataStore budget that scales with CCU. `GetAsync` and `SetAsync` consume different budget buckets. Check before calling:

```lua
local DataStoreService = game:GetService("DataStoreService")

local function waitForBudget(requestType)
    local budget = DataStoreService:GetRequestBudgetForRequestType(requestType)
    while budget < 1 do
        task.wait(1)
        budget = DataStoreService:GetRequestBudgetForRequestType(requestType)
    end
end

-- Before a read:
waitForBudget(Enum.DataStoreRequestType.GetAsync)
local data = DataStoreService:GetDataStore(name):GetAsync(key)
```

For high-volume use cases, budget-aware queuing is what separates "works in testing" from "works in production at 100 CCU." ProfileService, ProfileStore, and DataStore2 all handle this automatically — this is one of the main reasons to use them instead of rolling your own.

## `SetAsync` vs `UpdateAsync` — the race condition

For per-player keys where only the owning server writes, `SetAsync` is fine. For any key that multiple servers might modify (leaderboards, shared counters, matchmaking slots), **use `UpdateAsync` to prevent race conditions**.

```lua
-- BAD (race condition): two servers reading 100 simultaneously, both adding 10, both writing 110.
-- Result: final value is 110, but it should be 120.
local current = store:GetAsync("sharedCount") or 0
store:SetAsync("sharedCount", current + 10)

-- GOOD: UpdateAsync atomically reads and writes, retrying on conflict.
store:UpdateAsync("sharedCount", function(current)
    return (current or 0) + 10
end)
```

`UpdateAsync` takes a callback that receives the current value and returns the new value. Roblox handles the atomic compare-and-swap under the hood — if another server wrote between the read and the write, the callback runs again with the new value.

**Important caveat** (from a known bug): `UpdateAsync` pcall failure does not guarantee the write did not commit. If `pcall(UpdateAsync, ...)` returns false, you cannot distinguish "the write never happened" from "the write committed but the network response was lost." For critical operations this means retrying an `UpdateAsync` after a pcall failure can cause a duplicated write. The safest pattern is to use `UpdateAsync` for idempotent operations (where the callback is designed to handle being called twice) or to use a monotonic version counter inside the data so the second call can detect "already applied."

## Save cadence

The guide recommends saving:
- **When players leave** (via `BindToClose` + a PlayerRemoving handler)
- **After significant purchases or progression milestones**
- **On a timed interval** — every 5 minutes is the minimum reasonable rate; 10 minutes is fine for less-critical games

Do NOT save:
- On every field change (blows the budget)
- On every heartbeat (definitely blows the budget)
- In a tight loop (will hit throttle limits within seconds)

The 5–10 minute cadence is where the sweet spot lies because it balances data loss exposure (at most 5–10 minutes of progress if the server crashes) against DataStore budget consumption.

## `BindToClose` for shutdown saves

```lua
game:BindToClose(function()
    local deadline = time() + 25  -- must finish within 30s shutdown window
    for _, player in ipairs(Players:GetPlayers()) do
        if time() > deadline then break end
        task.spawn(function()
            saveData(player)
        end)
    end
    task.wait(5)  -- yield so saves can complete
end)
```

Roblox gives servers a 30-second window on shutdown to finish work. `BindToClose` callbacks yield the shutdown until they return (or time out). This is the last-resort save opportunity — use it to flush any in-memory state that hasn't been saved yet.

## Why you almost never want to write this yourself

Everything above is what ProfileService, ProfileStore, and DataStore2 already do — plus session locking, plus auto-save, plus backup retries, plus migration via `Reconcile`. The purpose of this article is not to teach you to write a DataStore wrapper from scratch. It's to explain what those libraries do under the hood so you understand *why* they exist.

If you find yourself writing raw `pcall(function() return store:GetAsync(key) end)` calls in your game code, stop and install ProfileStore. The scenarios where hand-rolled DataStore code is the right answer are rare and specialized (global leaderboards with custom ordering, cross-experience data sharing), and even those usually want a thin wrapper around `MemoryStoreService` rather than `DataStoreService`.

## Sources

- https://create.roblox.com/docs/cloud-services/data-stores/best-practices
- https://devforum.roblox.com/t/datastore-best-practices/2845439
- https://devforum.roblox.com/t/datastore-updateasync-pcall-failure-does-not-guarantee-write-did-not-commit-no-way-to-distinguish-timeout-but-committed-from-real-failure/4526895
Captured: 2026-04-15
