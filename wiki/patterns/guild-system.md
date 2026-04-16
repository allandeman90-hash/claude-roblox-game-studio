---
title: Guild System
type: pattern
category: patterns
subcategory: social
owner: game-designer
status: draft
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/social-features/guild-party-system-patterns.md
  - wiki/raw/community/articles/social-features/groupservice-api-reference.md
related:
  - "[[friends-system]]"
  - "[[DataStoreService]]"
  - "[[MessagingService]]"
  - "[[trading-system]]"
tags: [pattern, social, guild, clan, party, cross-server]
---

# Guild System

> In-game player organizations (guilds, clans, factions) with persistent membership, ranks, and cross-server synchronization.

## Summary

A guild system allows players to form persistent groups with shared identity, ranks, currency, and goals. Unlike Roblox Groups (platform-level), in-game guilds are experience-specific, stored in DataStores, and managed entirely through game code. The core challenge is concurrent mutation from multiple servers: two officers promoting members simultaneously, or an invite accepted while a kick is processed.

## When to Use It

- RPGs, MMO-style games, or competitive games with team identity
- Games needing persistent player organizations beyond friends lists
- Experiences with shared guild banks, territory, or progression

## Data Model

### Guild Record (DataStore)

```lua
export type GuildData = {
    guildId: string,           -- unique identifier (GUID)
    name: string,
    tag: string,               -- 3-5 char abbreviation
    leaderId: number,          -- owner UserId
    createdAt: number,         -- os.time()
    currency: number,
    level: number,
    members: {[string]: {      -- keyed by tostring(UserId)
        role: string,          -- "Leader" | "Officer" | "Member"
        joinedAt: number,
    }},
    settings: {
        isOpen: boolean,       -- open join vs. invite-only
        maxMembers: number,    -- default 50
        motd: string,          -- message of the day
    },
    version: number,           -- schema version for migrations
}
```

### Player Record (in player DataStore)

```lua
-- Inside the player's save data
guildId: string?,  -- nil if not in a guild
```

### Storage Strategy

| Store | Purpose |
|-------|---------|
| DataStoreService (one key per guild: `"guild_<id>"`) | Persistent guild data |
| Player DataStore | Quick lookup of player's guild membership |
| MemoryStoreService (HashMap) | Cross-server invite cache, pending applications |
| MessagingService | Broadcast guild mutations to all servers for cache invalidation |

## Implementation

### Server-Authoritative Operations

All guild mutations go through the server via RemoteEvent. The server uses `UpdateAsync` with check-and-set logic:

```lua
local DataStoreService = game:GetService("DataStoreService")
local guildStore = DataStoreService:GetDataStore("Guilds")

local function promoteGuildMember(guildId: string, promoterId: number, targetId: number): (boolean, string?)
    local success, err = pcall(function()
        guildStore:UpdateAsync("guild_" .. guildId, function(data)
            if not data then return nil end -- guild doesn't exist

            local promoter = data.members[tostring(promoterId)]
            local target = data.members[tostring(targetId)]

            -- Validate permissions
            if not promoter or promoter.role ~= "Leader" then
                return nil -- abort: no permission
            end
            if not target or target.role ~= "Member" then
                return nil -- abort: invalid target
            end

            target.role = "Officer"
            return data
        end)
    end)

    if not success then
        return false, "DataStore error: " .. tostring(err)
    end
    return true, nil
end
```

### Cross-Server Synchronization

```lua
local MessagingService = game:GetService("MessagingService")

-- After any guild mutation, broadcast
MessagingService:PublishAsync("GuildUpdates", {
    guildId = guildId,
    action = "memberPromoted",
    targetId = targetId,
    timestamp = os.time(),
})

-- All servers subscribe
MessagingService:SubscribeAsync("GuildUpdates", function(message)
    local data = message.Data
    -- Invalidate local cache for this guild
    guildCache[data.guildId] = nil
end)
```

### Invite System with MemoryStoreService

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local inviteMap = MemoryStoreService:GetHashMap("GuildInvites")

-- Send invite (expires in 5 minutes)
inviteMap:SetAsync(
    tostring(targetUserId) .. "_" .. guildId,
    { senderId = senderId, guildId = guildId, guildName = guildName },
    300  -- 5 minute expiry
)

-- Accept invite (on target's server)
local invite = inviteMap:GetAsync(tostring(playerId) .. "_" .. guildId)
if invite then
    -- Add player to guild via UpdateAsync
    inviteMap:RemoveAsync(tostring(playerId) .. "_" .. guildId)
end
```

## Transient Party System (In-Memory)

For short-lived groups (dungeon parties, matchmaking squads), use an in-memory approach instead of DataStore:

- Store party data in a server-side table (not persisted).
- Use `ReplicatedStorage` folder hierarchy for client replication.
- Support invite, kick, transfer leadership, blacklist.
- Use `TeleportService:TeleportAsync()` to move party members together.

Parties are destroyed when the last member leaves or disconnects.

## Pitfalls

- **Concurrent writes:** Two servers mutating the same guild simultaneously can conflict. `UpdateAsync` with validation logic is essential; never use `SetAsync` for guild data.
- **Member list size:** DataStore values max at 4 MB. A guild with thousands of members may need pagination or a separate member store.
- **MessagingService limits:** 150 requests/min per server. Batch updates if guild activity is high.
- **Stale caches:** After MessagingService notification, re-fetch from DataStore before acting on cached data.
- **Leave/kick race conditions:** A player being kicked while they leave can cause double-removal logic. Use `UpdateAsync` to atomically check and remove.

## Related

- [[friends-system]] -- Friends list integration for invite suggestions.
- [[DataStoreService]] -- Persistent storage for guild records.
- [[MessagingService]] -- Cross-server event broadcasting.
- [[trading-system]] -- Guild banks may use similar atomic transaction patterns.

## Sources

- [DevForum: Guild/Clan System design discussion](wiki/raw/community/articles/social-features/guild-party-system-patterns.md)
- [DevForum: OOP Party System V1](https://devforum.roblox.com/t/party-system-oop-party-system-v1/2042243)
- [DevForum: Creating a Guild/Clan system](https://devforum.roblox.com/t/creating-a-guildclan-system/486665)
