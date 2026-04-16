---
title: Friends System
type: pattern
category: patterns
subcategory: social
owner: game-designer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/social-features/friends-api-reference.md
  - wiki/raw/community/articles/social-features/experience-notifications-reference.md
  - wiki/raw/community/articles/social-features/groupservice-api-reference.md
related:
  - "[[guild-system]]"
  - "[[Players]]"
tags: [pattern, social, friends, groups, notifications, engagement]
---

# Friends System

> Leveraging Roblox's built-in social graph (friends, groups) and notification APIs to build in-game social features.

## Summary

Roblox provides platform-level APIs for friends lists, group membership, and experience notifications. Games use these to surface social context: highlighting friends in a lobby, giving group members perks, sending re-engagement notifications, and building invite flows. Unlike guild systems (fully custom, in-DataStore), friends and groups are platform-managed and accessed through read-only APIs.

## Friends API

### Players:GetFriendsAsync(userId) -> FriendPages

Returns a paginated list of a player's friends. Each page contains up to ~50 entries.

```lua
local Players = game:GetService("Players")

local function getFriends(userId: number): {{Id: number, Username: string, DisplayName: string}}
    local friends = {}
    local success, pages = pcall(function()
        return Players:GetFriendsAsync(userId)
    end)
    if not success then
        warn("GetFriendsAsync failed: " .. tostring(pages))
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
        pcall(function() pages:AdvanceToNextPageAsync() end)
    end
    return friends
end
```

### Checking If Two Players Are Friends

```lua
local player = game.Players.LocalPlayer
local isFriend = player:IsFriendsWith(otherUserId)
```

### Common Use Cases

- **"Friends in server" UI:** On join, call `GetFriendsAsync` for the local player, cross-reference with `Players:GetPlayers()`.
- **Friend invite prompts:** Show a button that uses `SocialService:PromptGameInvite(player)` to open the platform invite dialog.
- **Friend-only trading:** Gate trade requests behind `IsFriendsWith` checks.
- **Friend XP bonus:** Server checks friend status between party members and applies multiplier.

### Limitations

- Results capped at ~200 friends (inconsistent for users with 200+).
- Pages return ~50 entries each; must iterate with `AdvanceToNextPageAsync`.
- UK/EU users may have friend data restricted (GDPR compliance).
- Intermittent HTTP 500/502/401 errors reported; always wrap in pcall.
- No real-time friend status change event (must poll or check on join).

## Groups API

### Player Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `Player:IsInGroup(groupId)` | boolean | Whether player is in the group |
| `Player:GetRankInGroup(groupId)` | number (0-255) | Player's rank; 0 if not a member |
| `Player:GetRoleInGroup(groupId)` | string | Role name; "Guest" if not a member |

### GroupService Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `GetGroupInfoAsync(groupId)` | table | Group details: Name, Id, Owner, Roles, Description |
| `GetGroupsAsync(userId)` | array | All groups a user belongs to |
| `GetAlliesAsync(groupId)` | StandardPages | Allied groups |
| `GetEnemiesAsync(groupId)` | StandardPages | Enemy groups |
| `PromptJoinAsync(groupId)` | GroupMembershipStatus | Prompts player to join a group |

### Common Group Patterns

```lua
-- Gate content behind group membership
local function isGroupMember(player: Player, groupId: number): boolean
    return player:IsInGroup(groupId)
end

-- Rank-based perks
local function getGroupPerks(player: Player, groupId: number): string
    local rank = player:GetRankInGroup(groupId)
    if rank >= 200 then return "vip"
    elseif rank >= 100 then return "member"
    else return "none"
    end
end
```

### OpenCloud Groups API

For server-side group management (ranking users), use the OpenCloud API via HttpService:

- `GET /cloud/v2/groups/{id}/memberships` -- list members
- `GET /cloud/v2/groups/{id}/roles` -- list roles
- `PATCH /cloud/v2/groups/{id}/memberships/{membershipId}` -- change rank

Requires API key with `group:read` and `group:write` permissions.

## Experience Notifications

### Overview

Push notifications to opted-in users (13+) to re-engage them with the experience.

### Implementation

1. Define notification templates in Creator Dashboard with personalizable parameters.
2. Trigger from server code via OpenCloud API or `ExperienceNotificationService`.

### Constraints

| Constraint | Value |
|------------|-------|
| Rate limit | 1 notification per day per user per experience |
| Eligible users | 13+ who opted in |
| User mentions | Recipient and mentioned user must be friends |
| Analytics threshold | 100 impressions minimum to view data |

### Best Practices

- Notify for high-value moments (egg hatched, base attacked, weekly challenge reset).
- Personalize content with player-specific data.
- Monitor analytics dashboard for opt-in rates and click-through.
- In-experience permission prompt: use the Lua API to ask players to enable notifications during gameplay.

## Pitfalls

- **GetFriendsAsync is not real-time.** Friend additions/removals during a session are not reflected without re-calling.
- **Group rank caching.** `Player:GetRankInGroup` may cache results for a few minutes; do not rely on instant rank changes.
- **Notification delivery is best-effort.** No guarantee of delivery; do not use for critical game logic.
- **Privacy compliance.** UK/EU users may have restricted social data. Always handle nil/empty results gracefully.
- **Rate limits on GroupService.** `GetGroupInfoAsync` and `GetGroupsAsync` yield and have throttling; cache results server-side.

## Related

- [[guild-system]] -- For custom in-game organizations beyond platform groups.
- [[Players]] -- The Players service hosts friend and group APIs.

## Sources

- [Friends API reference](wiki/raw/community/articles/social-features/friends-api-reference.md)
- [GroupService API reference](wiki/raw/community/articles/social-features/groupservice-api-reference.md)
- [Experience Notifications](wiki/raw/community/articles/social-features/experience-notifications-reference.md)
- [DevForum: Introducing Experience Notifications](https://devforum.roblox.com/t/introducing-experience-notifications/2826474)
