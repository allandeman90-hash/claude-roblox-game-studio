---
title: "Badge Module with Caching Pattern"
source_url: "https://devforum.roblox.com/t/how-to-make-a-somewhat-good-badge-systemoutdatedfor-beginners/2178478"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: achievement-system
---

# Badge Module with Caching

## Module Structure

```lua
local Badge = {}
local Cache = {}
local Badges = {}
local BadgeService = game:GetService("BadgeService")

local Badges = {
    ["100 wins"] = 19384757,
    ["10 kills"] = 1945886,
    ["5 deaths"] = 1838576
}
```

## Loading Player Badges

```lua
game.Players.PlayerAdded:Connect(function(Player: Player)
    BadgeService:LoadBadgesAsync(Player.UserId)
end)
```

## Fetching with pcall

```lua
local function Fetch(PlayerId: number, BadgeId: number)
    local Success, Owns = pcall(BadgeService.UserHasBadgeAsync,
        BadgeService, PlayerId, BadgeId)
    if not Success then
        warn("Badge fetch error: " ..tostring(Owns))
        return nil
    end
    return Owns
end
```

## Checking Ownership

```lua
local function HasBadge(PlrBadges, BadgeName: string)
    return PlrBadges[BadgeName] == true
end
```

## Awarding with Dedup

```lua
function Badge:AwardBadge(PlayerId: number, BadgeName: string)
    local PlrBadges = Cache[PlayerId]
    BadgeName = BadgeName:lower()
    if not HasBadge(PlrBadges, BadgeName) then
        local BadgeId = Badges[BadgeName]
        AttemptAward(PlayerId, BadgeId)
    end
end

local function AttemptAward(PlayerId: number, BadgeId: number)
    local Success, Awarded = pcall(BadgeService.AwardBadge,
        BadgeService, PlayerId, BadgeId)
    if not Success then
        warn("Couldn't award badge due to error")
        return
    end
    return Awarded
end
```
