---
title: "BadgeService API Reference (GameDev Academy)"
source_url: "https://gamedevacademy.org/roblox-badges-tutorial-complete-guide/"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: achievement-system
---

# BadgeService API - Complete Guide

## Three Primary Methods

1. `BadgeService:AwardBadge(userId, badgeId)` - Grants a badge to a player
2. `BadgeService:UserHasBadgeAsync(userId, badgeId)` - Checks if a player owns a badge
3. Badge creation through Developer Portal

## Core Pattern

```lua
local BadgeService = game:GetService("BadgeService")
local badgeId = YOUR_BADGE_ID

if not BadgeService:UserHasBadgeAsync(player.UserId, badgeId) then
    BadgeService:AwardBadge(player.UserId, badgeId)
end
```

## Use Cases

- Touch-based triggers: rewarding players for reaching specific locations
- Achievement milestones: recognizing cumulative accomplishments
- Time-based rewards: granting badges after gameplay duration thresholds
- Multiple ownership checks: verifying collections of badges simultaneously
- Entry rewards: awarding badges upon initial game join

## Best Practices

- Always check existing badge ownership before awarding
- Connect badge rewards to specific game events
- Organize related badges using Lua tables for scalability
- Wrap badge checks with existence verification to prevent runtime failures
