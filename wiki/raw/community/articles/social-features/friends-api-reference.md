---
title: "Friends System API — Players:GetFriendsAsync Reference"
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Players
source_type: official-docs
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: social-features
tags: [friends, social, Players, GetFriendsAsync, FriendPages]
---

# Friends System API Reference

## Players:GetFriendsAsync(userId: int64) -> FriendPages

Yields. Returns a FriendPages object containing information for all of a given player's friends.

### Parameters
- userId (int64): User ID of the player whose friends are being retrieved

### Return Type
FriendPages: A paginated collection (inherits from Pages).

### Return Structure (each item)
- Id (int64): The friend's UserId
- Username (string): The friend's username
- DisplayName (string): The friend's display name

### Tags
- Yields
- Thread Safety: Unsafe
- Capabilities: Players, Social

### Usage Pattern

```lua
local Players = game:GetService("Players")

local function getFriendsList(userId: number): {FriendInfo}
    local friends = {}
    local success, pages = pcall(function()
        return Players:GetFriendsAsync(userId)
    end)
    if not success then
        warn("Failed to get friends: " .. tostring(pages))
        return friends
    end

    while true do
        for _, item in ipairs(pages:GetCurrentPage()) do
            table.insert(friends, {
                Id = item.Id,
                Username = item.Username,
                DisplayName = item.DisplayName,
            })
        end
        if pages.IsFinished then break end
        local advanceSuccess = pcall(function()
            pages:AdvanceToNextPageAsync()
        end)
        if not advanceSuccess then break end
    end
    return friends
end
```

## Known Limitations and Issues

- Results capped at approximately 200 friends per call (multiple pages of ~50 each)
- For users with many friends (200+), results may be inconsistent
- GetFriendsAsync only returns 50 friends per page; must iterate with AdvanceToNextPageAsync
- UK users' friends may have privacy restrictions (GDPR compliance)
- Intermittent HTTP 500, 502, 401 errors reported (engine bugs)
- No IsFriendsWith method on Players service (must iterate friend list or use Player:IsFriendsWith if available)

## Related Social Methods

### Player:IsFriendsWith(userId: number) -> boolean
Returns whether the local player is friends with the specified user. Available on Player instances.

### Player.FriendStatusChanged(player: Player, friendStatus: Enum.FriendStatus)
Event that fires when a player's friend status changes with another player.

## Experience Notification Integration
Friends are relevant for Experience Notifications: recipient and mentioned users must be friends for notification eligibility.
