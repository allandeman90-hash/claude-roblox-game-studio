---
title: daily-rewards
type: pattern
category: patterns
subcategory: retention
owner: game-designer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md
related:
  - "[[ftue-design]]"
  - "[[DataStoreService]]"
  - "[[core-loop]]"
  - "[[code-redemption-system]]"
  - "[[feature-flags]]"
tags: [pattern, retention, live-ops, daily-login]
---

# Daily Rewards

> Escalating reward cycle tied to consecutive daily logins; the single strongest D1-to-D7 retention lever on Roblox.

## Summary

Daily reward systems give players a reason to return every day. The standard Roblox pattern is a 7- or 14-day cycle where rewards escalate in value, with a large capstone on the final day. After the cycle completes it either resets or advances to a higher tier. Streaks break if the player misses more than a configurable window (typically 36-48 hours), creating gentle urgency without punishing time zones.

## When to Use It

- Every Roblox game that cares about retention. Daily rewards are near-universal across top games.
- Pair with [[ftue-design]] -- the first daily reward should fire within the first session.
- Combine with [[feature-flags]] to adjust reward values live without a code deploy.

## Implementation

### Data Schema

Store the minimum state in the player's DataStore profile:

```lua
-- Inside player data template
dailyRewards = {
    streak = 0,              -- current consecutive day count (0-based)
    lastClaimTimestamp = 0,   -- os.time() of last claim
    totalClaims = 0,          -- lifetime counter for analytics
}
```

### Reward Table (config-driven)

```lua
-- ReplicatedStorage/Shared/Config/DailyRewardsConfig.lua
local DailyRewardsConfig = {}

DailyRewardsConfig.CYCLE_LENGTH = 7
DailyRewardsConfig.STREAK_WINDOW_SECONDS = 48 * 3600  -- 48 hours

DailyRewardsConfig.Rewards = {
    [1] = { coins = 100 },
    [2] = { coins = 150 },
    [3] = { coins = 200 },
    [4] = { coins = 300, item = "RareChest" },
    [5] = { coins = 400 },
    [6] = { coins = 500 },
    [7] = { coins = 1000, item = "LegendaryChest", pet = "GoldenDragon" },
}

return DailyRewardsConfig
```

### Server-Side Claim Logic

```lua
-- ServerStorage/Services/DailyRewardService.lua
local DailyRewardService = {}

local Config = require(game.ReplicatedStorage.Shared.Config.DailyRewardsConfig)

local ONE_DAY = 86400  -- seconds

function DailyRewardService.canClaim(dailyData): boolean
    if dailyData.lastClaimTimestamp == 0 then
        return true  -- first ever claim
    end
    local elapsed = os.time() - dailyData.lastClaimTimestamp
    return elapsed >= ONE_DAY
end

function DailyRewardService.claim(player: Player, playerData): (boolean, {[string]: any}?)
    local daily = playerData.dailyRewards
    if not DailyRewardService.canClaim(daily) then
        return false, nil
    end

    local elapsed = os.time() - daily.lastClaimTimestamp

    -- Reset streak if gap exceeds window
    if daily.lastClaimTimestamp > 0 and elapsed > Config.STREAK_WINDOW_SECONDS then
        daily.streak = 0
    end

    daily.streak += 1
    daily.lastClaimTimestamp = os.time()
    daily.totalClaims += 1

    -- Wrap streak within cycle
    local rewardDay = ((daily.streak - 1) % Config.CYCLE_LENGTH) + 1
    local reward = Config.Rewards[rewardDay]

    -- Grant rewards through inventory/currency services (server-authoritative)
    -- InventoryService.grantReward(player, reward)

    return true, reward
end

return DailyRewardService
```

### Client UI Flow

The client never decides whether a claim is valid. It only renders the UI and fires a remote.

```lua
-- Client: fire the claim remote
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

claimButton.Activated:Connect(function()
    Remotes.ClaimDailyReward:FireServer()
end)

-- Server handler validates and responds
Remotes.ClaimDailyReward.OnServerEvent:Connect(function(player)
    local data = PlayerDataService.getData(player)
    if not data then return end

    local ok, reward = DailyRewardService.claim(player, data)
    Remotes.DailyRewardResult:FireClient(player, { ok = ok, reward = reward })
end)
```

## Variants

| Variant | Description | Trade-off |
|---------|-------------|-----------|
| **Fixed 7-day cycle** | Resets to day 1 after day 7 | Simple, predictable |
| **Escalating tiers** | Cycle 2 has better rewards than cycle 1 | Stronger long-term hook, harder to balance |
| **No streak break** | Progress pauses on miss, never resets | Less urgency, more player-friendly |
| **Weekly milestones** | Claim any 5 of 7 days to get the capstone | Forgives a missed day, reduces churn frustration |

## Pitfalls

- **Time zone abuse.** Use `os.time()` (server UTC) for the claim timestamp, never the client's local time. A 24-hour minimum gap measured server-side prevents double-claiming by changing device clocks.
- **Streak window too tight.** A 24-hour window penalizes players who log in at slightly different times each day. 36-48 hours is standard to account for schedule variation.
- **Reward inflation.** If the day-7 reward is too valuable relative to normal gameplay, players stop engaging with the core loop and just log in to claim. The daily reward supplements the [[core-loop]]; it does not replace it.
- **No BindToClose safety.** Daily claim state is part of the player profile. Ensure it persists through the standard save-on-leave and BindToClose paths.
- **Client trust.** Never let the client determine which day's reward to grant. The server reads the streak counter and looks up the reward table.

## Related

- [[ftue-design]] -- the first daily reward is part of the first-session hook
- [[core-loop]] -- daily rewards are the meta-loop (days/weeks scale)
- [[DataStoreService]] -- claim state persisted in player data
- [[code-redemption-system]] -- another live-ops engagement tool
- [[feature-flags]] -- tune reward values live

## Sources

- [wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md](../raw/community/monetization/live-ops/liveops-essentials-cadence.md) -- daily reward cycles: 7-14 days with escalating value
