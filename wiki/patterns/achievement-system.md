---
title: achievement-system
type: pattern
category: patterns
subcategory: progression
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/achievementservice-open-source.md
  - wiki/raw/community/articles/game-mechanics/custom-badge-system-tutorial.md
  - wiki/raw/community/articles/game-mechanics/badge-module-pattern.md
  - wiki/raw/community/articles/game-mechanics/badgeservice-api-reference.md
related:
  - "[[notification-system]]"
  - "[[DataStoreService]]"
  - "[[quest-system]]"
  - "[[daily-rewards]]"
tags: [pattern, progression, badges, achievements, BadgeService]
---

# Achievement System

> Server-authoritative badge and achievement tracking using Roblox BadgeService for platform badges and DataStore for custom progress-based achievements.

## Summary

An achievement system awards players for reaching milestones. Roblox provides `BadgeService` for platform-level badges (visible on player profiles), but most games also need custom achievement tracking for progressive goals (e.g., "Kill 100 enemies") that go beyond simple binary unlocks. A production system combines both: BadgeService for the platform badge, DataStore for progress state, and a notification layer for the unlock moment.

The key architectural decision is whether to rely solely on BadgeService (simpler, limited to binary unlocks) or build a custom layer on top (more flexible, supports progress tracking, but requires DataStore integration).

## Implementation

### BadgeService Core (Platform Badges)

Three methods form the BadgeService API surface:

- `BadgeService:AwardBadge(userId, badgeId)` -- grants the badge
- `BadgeService:UserHasBadgeAsync(userId, badgeId)` -- ownership check
- `BadgeService:GetBadgeInfoAsync(badgeId)` -- metadata (includes `IsEnabled`)

Always check ownership before awarding. All calls are yielding and can fail; wrap in `pcall`.

```lua
-- ServerStorage/Services/AchievementService.lua
local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local AchievementService = {}

local BADGE_MAP = {
    Welcome       = 123456789,
    FirstKill     = 123456790,
    HundredKills  = 123456791,
    Explorer      = 123456792,
}

function AchievementService.awardBadge(player: Player, badgeName: string)
    local badgeId = BADGE_MAP[badgeName]
    if not badgeId then
        warn("[AchievementService] Unknown badge: " .. badgeName)
        return false
    end

    local success, alreadyOwned = pcall(function()
        return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
    end)

    if not success then
        warn("[AchievementService] UserHasBadgeAsync failed: " .. tostring(alreadyOwned))
        return false
    end

    if alreadyOwned then
        return false -- already has it
    end

    local awardSuccess, awardResult = pcall(function()
        return BadgeService:AwardBadge(player.UserId, badgeId)
    end)

    if not awardSuccess then
        warn("[AchievementService] AwardBadge failed: " .. tostring(awardResult))
        return false
    end

    return awardResult
end

return AchievementService
```

### Disabling Default Badge Notification

To show a custom popup instead of the default Roblox badge notification, disable it on the client:

```lua
-- StarterGui LocalScript
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
-- Disable only badge notifications
pcall(function()
    StarterGui:SetCore("BadgesNotificationsActive", false)
end)
```

### Custom Achievement Tracking (Progress-Based)

For achievements like "Kill 100 enemies," store progress in the player's DataStore profile and check thresholds on each relevant event.

```lua
-- Inside player data template
achievements = {
    kills = 0,            -- running counter
    deaths = 0,
    itemsCollected = 0,
    distanceTraveled = 0,
    unlocked = {},        -- { [achievementId] = os.time() }
}
```

```lua
-- ServerStorage/Services/AchievementService.lua (extended)
local ACHIEVEMENT_DEFS = {
    {
        id = "first_kill",
        badgeName = "FirstKill",
        stat = "kills",
        threshold = 1,
    },
    {
        id = "hundred_kills",
        badgeName = "HundredKills",
        stat = "kills",
        threshold = 100,
    },
}

function AchievementService.incrementStat(player: Player, statName: string, amount: number)
    local data = PlayerDataService.getData(player)
    if not data or not data.achievements then return end

    data.achievements[statName] = (data.achievements[statName] or 0) + amount

    -- Check all achievements tied to this stat
    for _, def in ipairs(ACHIEVEMENT_DEFS) do
        if def.stat == statName then
            local currentVal = data.achievements[def.stat] or 0
            local alreadyUnlocked = data.achievements.unlocked[def.id]

            if not alreadyUnlocked and currentVal >= def.threshold then
                data.achievements.unlocked[def.id] = os.time()
                AchievementService.awardBadge(player, def.badgeName)
                -- Fire notification to client
                AchievementRemote:FireClient(player, def.id, def.badgeName)
            end
        end
    end
end
```

### Trigger Patterns

Achievements fire from game events, not from polling:

```lua
-- In combat module
Humanoid.Died:Connect(function()
    local attacker = getLastAttacker(humanoid)
    if attacker then
        AchievementService.incrementStat(attacker, "kills", 1)
    end
end)

-- On player join (retroactive check)
Players.PlayerAdded:Connect(function(player)
    -- Wait for data to load
    local data = PlayerDataService.waitForData(player)
    if data then
        -- Retroactive: check all achievements against current stats
        for _, def in ipairs(ACHIEVEMENT_DEFS) do
            local val = data.achievements[def.stat] or 0
            if val >= def.threshold and not data.achievements.unlocked[def.id] then
                data.achievements.unlocked[def.id] = os.time()
                AchievementService.awardBadge(player, def.badgeName)
            end
        end
    end
end)
```

### Client Notification

```lua
-- StarterGui/AchievementNotification (LocalScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AchievementRemote = ReplicatedStorage:WaitForChild("AchievementRemote")

AchievementRemote.OnClientEvent:Connect(function(achievementId, badgeName)
    -- Show custom UI (tween in, hold, tween out)
    -- See [[notification-system]] for queue-based approach
end)
```

## Data Schema

```lua
-- Player data template
{
    achievements = {
        -- Running stat counters
        kills = 0,
        deaths = 0,
        itemsCollected = 0,
        distanceTraveled = 0,
        questsCompleted = 0,

        -- Unlock timestamps (sparse; only unlocked achievements appear)
        unlocked = {
            -- [achievementId] = os.time()
            -- e.g., first_kill = 1713200000
        },
    },
}
```

## Pitfalls

- **Rate limits on BadgeService**: `AwardBadge` and `UserHasBadgeAsync` are yielding HTTP calls. Do not call them in tight loops. Cache ownership checks per-session in a local table.
- **Badge must be enabled**: `GetBadgeInfoAsync(badgeId).IsEnabled` must be true or the award silently fails. Check this during development.
- **Badge must belong to the experience**: A badge created under Experience A cannot be awarded from Experience B.
- **Retroactive awarding**: If you add a new achievement after players have already reached the threshold, run a retroactive check on join. Without this, veterans never get the badge.
- **pcall everything**: Every BadgeService call can fail due to network issues. Never assume success.
- **Do not trust the client**: Achievement progress is server-authoritative. The client only receives notification events; it never sends "I unlocked X."
- **Session caching**: For games that check `UserHasBadgeAsync` frequently, cache the result per session to avoid burning through API budget.

## Related

- [[notification-system]] -- queue-based popup for achievement unlock moments
- [[quest-system]] -- quests and achievements often share progress-tracking infrastructure
- [[daily-rewards]] -- another progression system that pairs with achievements
- [[DataStoreService]] -- persistence layer for custom achievement progress

## Sources

- [AchievementService Open Source Module](wiki/raw/community/articles/game-mechanics/achievementservice-open-source.md) -- community module with retry logic and animation support
- [Creating a Custom Badge System](wiki/raw/community/articles/game-mechanics/custom-badge-system-tutorial.md) -- DevForum tutorial on custom badge popups
- [Badge Module with Caching Pattern](wiki/raw/community/articles/game-mechanics/badge-module-pattern.md) -- DevForum caching approach
- [BadgeService Complete Guide](wiki/raw/community/articles/game-mechanics/badgeservice-api-reference.md) -- GameDev Academy comprehensive tutorial
- [Roblox BadgeService API Docs](https://create.roblox.com/docs/reference/engine/classes/BadgeService) -- official reference
- [DevForum: AchievementService v1.03](https://devforum.roblox.com/t/open-source-achievementservice-easily-manage-and-award-badges-v103/3277796)
- [DevForum: Creating a Custom Badge System](https://devforum.roblox.com/t/creating-a-custom-badge-system/1735737)
