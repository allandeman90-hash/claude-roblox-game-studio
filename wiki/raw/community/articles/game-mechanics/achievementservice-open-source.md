---
title: "AchievementService - Open Source Badge Module"
source_url: "https://devforum.roblox.com/t/open-source-achievementservice-easily-manage-and-award-badges-v103/3277796"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: achievement-system
---

# AchievementService - Open Source Module (v1.03)

## Basic Award Pattern

```lua
AchievementService:Award(player, badgeIdentifier)
-- badgeIdentifier can be BadgeName or BadgeId
```

## Usage Example

```lua
local AchievementService = require(game.ReplicatedStorage.AchievementService)

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        AchievementService:Award(player, "Welcome")
        AchievementService:Award(player, 123456789)
    end)
end)
```

## Configuration Variables

- `UseHTTPService` - Fetches badges via Roblox API (default: true)
- `BadgeIdFallback` - Falls back to manual BadgeIds if HTTP fails
- `BadgeIds` - Manual table of badge identifiers
- Animation support with style selection
- Audio playback with sound selection
- Haptic feedback for mobile/console
- Default Roblox badge notifications toggle
- `AutoInitialize` - Automatic initialization on require

## Performance Control

- `MaxRetryLimit` - Maximum retry attempts (default: 5)
- `RetryDelay` - Delay between retries in seconds (default: 1)
- Speed multiplier for animations

## Error Handling

Module includes a `SafeCall()` internal recovery mechanism for resilient function calls with configurable retry logic. Modern versions (v1.02+) use silent self-initialization via a coroutine.
