---
title: party-system
type: pattern
category: patterns
subcategory: social
owner: luau-gameplay-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md
  - wiki/raw/community/monetization/live-ops/messagingservice-in-game-patterns.md
  - wiki/raw/community/monetization/live-ops/memorystore-best-practices.md
  - wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md
related:
  - "[[cross-server-events]]"
  - "[[MemoryStoreService]]"
  - "[[MessagingService]]"
  - "[[TeleportService]]"
  - "[[core-loop]]"
tags: [pattern, social, party, cross-server, matchmaking]
---

# Party System

> Cross-server player grouping that keeps friends together through matchmaking, teleports, and session transitions using MemoryStoreService for shared state and MessagingService for coordination.

## Summary

A party system lets players form groups (2-8 members) that persist across server transitions. The party leader can queue for matches, start activities, or teleport the group together. Party state lives in MemoryStoreService (visible from any server), and coordination messages flow through MessagingService for real-time responsiveness.

## When to Use It

- Games with matchmaking (the party queues as a unit).
- Games with multiple worlds/areas connected via TeleportService.
- Any game that benefits from "play with friends" social hooks -- which is nearly every Roblox game. Social features are a proven retention multiplier.

## Implementation

### Party State (MemoryStoreService HashMap)

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local partyStore = MemoryStoreService:GetHashMap("Parties")

export type PartyData = {
    partyId: string,
    leaderId: number,          -- UserId of the leader
    members: {number},          -- array of UserIds
    maxSize: number,
    status: "idle" | "queued" | "in_game",
    createdAt: number,
    serverJobId: string?,       -- current server (if all together)
}

local PARTY_TTL = 3600  -- 1 hour; refresh on any mutation
local MAX_PARTY_SIZE = 4
```

### Creating and Managing Parties

```lua
local HttpService = game:GetService("HttpService")

local function createParty(leaderId: number): string?
    local partyId = HttpService:GenerateGUID(false)
    local party: PartyData = {
        partyId = partyId,
        leaderId = leaderId,
        members = { leaderId },
        maxSize = MAX_PARTY_SIZE,
        status = "idle",
        createdAt = os.time(),
        serverJobId = game.JobId,
    }
    local ok = pcall(function()
        partyStore:SetAsync(partyId, party, PARTY_TTL)
    end)
    if ok then
        -- Also store the player -> partyId mapping
        pcall(function()
            partyStore:SetAsync("player:" .. leaderId, partyId, PARTY_TTL)
        end)
        return partyId
    end
    return nil
end

local function joinParty(userId: number, partyId: string): (boolean, string?)
    local joined = false
    local err
    pcall(function()
        partyStore:UpdateAsync(partyId, function(party)
            if not party then
                err = "not_found"
                return nil
            end
            if #party.members >= party.maxSize then
                err = "full"
                return nil
            end
            -- Check not already in party
            for _, id in ipairs(party.members) do
                if id == userId then
                    err = "already_member"
                    return nil
                end
            end
            table.insert(party.members, userId)
            joined = true
            return party
        end, PARTY_TTL)
    end)
    if joined then
        pcall(function()
            partyStore:SetAsync("player:" .. userId, partyId, PARTY_TTL)
        end)
    end
    return joined, err
end

local function leaveParty(userId: number, partyId: string)
    pcall(function()
        partyStore:UpdateAsync(partyId, function(party)
            if not party then return nil end
            local newMembers = {}
            for _, id in ipairs(party.members) do
                if id ~= userId then
                    table.insert(newMembers, id)
                end
            end
            party.members = newMembers
            -- Transfer leadership if leader left
            if party.leaderId == userId and #newMembers > 0 then
                party.leaderId = newMembers[1]
            end
            if #newMembers == 0 then
                return nil  -- delete empty party
            end
            return party
        end, PARTY_TTL)
    end)
    pcall(function()
        partyStore:RemoveAsync("player:" .. userId)
    end)
end
```

### Cross-Server Coordination (MessagingService)

When a party member on a different server needs to be notified (invite, kick, teleport):

```lua
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")

local function notifyParty(partyId: string, eventType: string, payload: {[string]: any})
    local message = HttpService:JSONEncode({
        partyId = partyId,
        type = eventType,
        data = payload,
    })
    pcall(function()
        MessagingService:PublishAsync("party:" .. partyId, message)
    end)
end

-- Each server subscribes to parties of local players
local function subscribeToParty(partyId: string)
    pcall(function()
        MessagingService:SubscribeAsync("party:" .. partyId, function(message)
            local ok, data = pcall(function()
                return HttpService:JSONDecode(message.Data)
            end)
            if not ok then return end

            if data.type == "teleport" then
                -- Teleport local party members to the specified server
                teleportPartyMembers(data.data.placeId, data.data.serverCode)
            elseif data.type == "kick" then
                -- Remove kicked player locally
                handleKick(data.data.userId)
            elseif data.type == "disband" then
                -- Party disbanded; clean up local state
                handleDisband(data.partyId)
            end
        end)
    end)
end
```

### Party Teleportation

The party leader triggers a group teleport via TeleportService:

```lua
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local function teleportParty(partyId: string, placeId: number)
    local ok, party = pcall(function()
        return partyStore:GetAsync(partyId)
    end)
    if not ok or not party then return end

    -- Gather local players who are in this party
    local localMembers = {}
    for _, userId in ipairs(party.members) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            table.insert(localMembers, player)
        end
    end

    if #localMembers > 0 then
        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions.ShouldReserveServer = true

        local ok, result = pcall(function()
            return TeleportService:TeleportAsync(placeId, localMembers, teleportOptions)
        end)

        if ok then
            -- Notify remote party members to teleport to the same server
            notifyParty(partyId, "teleport", {
                placeId = placeId,
                serverCode = result.PrivateServerId,
            })
        end
    end
end
```

## Variants

| Variant | Description |
|---------|-------------|
| **Same-server only** | Party members must be on the same server. Simplest implementation -- no MemoryStore needed. |
| **Cross-server with MemoryStore** | Full pattern shown above. Party persists across server transitions. |
| **Invite-link parties** | Party ID shared via deep link or code. Anyone with the link can join. |
| **Matchmaking integration** | Party queues as a unit; matchmaker groups parties into matches. Requires MemoryStore Queue. |

## Pitfalls

- **MemoryStore TTL expiration.** Party state has a TTL. If no mutations occur for an extended period, the party silently expires. Implement a heartbeat: refresh TTL periodically while party is active.
- **Leader disconnect.** If the party leader leaves, automatically promote the next member. Handle this in both the `leaveParty` function and the `PlayerRemoving` handler.
- **Cross-server race conditions.** Two servers modifying party membership simultaneously can conflict. `UpdateAsync` on the HashMap provides atomicity per-key.
- **MessagingService delivery.** Messages are at-most-once. A teleport command might not reach a remote server. Implement a fallback: remote members poll party state from MemoryStore if they do not receive a message within a timeout.
- **Budget consumption.** Frequent party state reads/writes consume MemoryStore budget. Cache locally and only fetch from MemoryStore on significant events (join, leave, teleport), not per-frame.

## Related

- [[cross-server-events]] -- the underlying coordination primitives
- [[MemoryStoreService]] -- shared state for party data
- [[MessagingService]] -- real-time coordination messages
- [[TeleportService]] -- moving players between servers
- [[core-loop]] -- parties enhance the social dimension of the loop

## Sources

- [wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md](../raw/community/monetization/live-ops/memorystore-cross-server-patterns.md) -- MemoryStore patterns for shared state
- [wiki/raw/community/monetization/live-ops/messagingservice-in-game-patterns.md](../raw/community/monetization/live-ops/messagingservice-in-game-patterns.md) -- pub/sub coordination patterns
- [wiki/raw/community/monetization/live-ops/memorystore-best-practices.md](../raw/community/monetization/live-ops/memorystore-best-practices.md) -- sharding and budget management
- [wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md](../raw/community/monetization/live-ops/liveops-essentials-cadence.md) -- social systems as major update category
