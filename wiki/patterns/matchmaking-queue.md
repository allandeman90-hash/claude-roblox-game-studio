---
title: Matchmaking Queue
type: pattern
category: patterns
subcategory: multiplayer
owner: game-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/game-patterns/matchmaker-module-memorystores.md
  - wiki/raw/community/articles/game-patterns/matchmaking-memorystore-architecture.md
  - wiki/raw/community/articles/game-patterns/matchmaking-memorystorequeue-tutorial.md
related:
  - "[[round-system]]"
  - "[[lobby-system]]"
  - "[[MemoryStoreService]]"
  - "[[TeleportService]]"
tags: [pattern, matchmaking, queue, skill-based, MemoryStoreService, cross-server]
---

# Matchmaking Queue

> Cross-server player grouping using MemoryStoreService queues, enabling skill-based, party-aware, and region-aware match formation before teleporting groups to reserved game servers.

## Summary

Matchmaking is the process of grouping players across multiple servers into balanced matches before teleporting them to a private game instance. On Roblox, this is built on top of **MemoryStoreService** (for cross-server shared state) and **TeleportService** (for moving players). A designated coordinator server periodically reads the queue, applies grouping logic, reserves private servers, and teleports matched players.

The three key architectural decisions are: (1) what data structure stores the queue (SortedMap vs Queue), (2) how a coordinator is elected among competing servers, and (3) what matching algorithm groups players (random, skill-based, party-aware).

## When to Use It

- Competitive games requiring balanced teams (ELO/MMR-based).
- Games where party groups (2-4 friends) need to stay together.
- Any game teleporting players from a lobby place to a separate game place.
- High-CCU games where a single server cannot hold all queued players.

Not needed for single-server games where all players on one server enter the same round.

## Implementation

### Queue Entry Structure

```lua
-- The data stored per party in the queue
export type QueueEntry = {
    partyLeaderId: number,        -- UserId of party leader
    memberIds: {number},          -- All member UserIds
    rating: number?,              -- Optional: skill rating / MMR
    region: string?,              -- Optional: geographic region
    enqueuedAt: number,           -- os.time() when queued
    metadata: {[string]: any}?,   -- Game-specific metadata
}
```

### Adding to Queue (Any Server)

```lua
local MemoryStoreService = game:GetService("MemoryStoreService")
local matchQueue = MemoryStoreService:GetSortedMap("MatchQueue_Ranked")

local QUEUE_EXPIRY = 120  -- seconds before auto-removal

function MatchmakingService.enqueue(players: {Player}, rating: number)
    local leader = players[1]
    local memberIds = {}
    for _, p in players do
        table.insert(memberIds, p.UserId)
    end

    local entry: QueueEntry = {
        partyLeaderId = leader.UserId,
        memberIds = memberIds,
        rating = rating,
        enqueuedAt = os.time(),
    }

    local success, err = pcall(function()
        matchQueue:SetAsync(
            tostring(leader.UserId),  -- key
            entry,                     -- value
            QUEUE_EXPIRY               -- TTL in seconds
        )
    end)

    if not success then
        warn("Failed to enqueue:", err)
    end
end
```

### Coordinator Election

```lua
local coordinatorMap = MemoryStoreService:GetHashMap("MatchCoordinator")
local REFRESH_TIME = 10  -- seconds between election attempts
local myJobId = game.JobId

local function tryBecomeCoordinator(gameMode: string): boolean
    local success, isCoordinator = pcall(function()
        return coordinatorMap:UpdateAsync(gameMode, function(current)
            if current == nil or current.jobId == myJobId then
                -- No coordinator or we already are it: claim/renew
                return {
                    jobId = myJobId,
                    claimedAt = os.time(),
                }
            end
            -- Another server is coordinator, check if expired
            if os.time() - current.claimedAt > REFRESH_TIME * 3 then
                return {
                    jobId = myJobId,
                    claimedAt = os.time(),
                }
            end
            return current  -- Keep existing coordinator
        end, REFRESH_TIME * 4)
    end)

    return success and isCoordinator and isCoordinator.jobId == myJobId
end
```

### Match Formation (Skill-Based)

```lua
local SKILL_RANGE = 200       -- initial MMR window
local SKILL_EXPAND_RATE = 50  -- widen per cycle
local TEAM_SIZE = 4

local function formMatches(entries: {QueueEntry}): {{QueueEntry}}
    -- Sort by rating
    table.sort(entries, function(a, b)
        return (a.rating or 0) < (b.rating or 0)
    end)

    local matches = {}
    local used = {}

    for i, entry in entries do
        if used[entry.partyLeaderId] then continue end

        local team = {entry}
        local teamSize = #entry.memberIds
        used[entry.partyLeaderId] = true

        -- Find nearby-rated players to fill the team
        for j = i + 1, #entries do
            local candidate = entries[j]
            if used[candidate.partyLeaderId] then continue end

            local ratingDiff = math.abs((entry.rating or 0) - (candidate.rating or 0))
            local waitTime = os.time() - entry.enqueuedAt
            local expandedRange = SKILL_RANGE + (waitTime / 10) * SKILL_EXPAND_RATE

            if ratingDiff <= expandedRange then
                if teamSize + #candidate.memberIds <= TEAM_SIZE then
                    table.insert(team, candidate)
                    teamSize += #candidate.memberIds
                    used[candidate.partyLeaderId] = true
                end
            end

            if teamSize >= TEAM_SIZE then break end
        end

        if teamSize >= TEAM_SIZE then
            table.insert(matches, team)
        end
    end

    return matches
end
```

### Teleport Matched Players

```lua
local TeleportService = game:GetService("TeleportService")
local GAME_PLACE_ID = 123456789

local function teleportMatch(match: {{QueueEntry}})
    local code = TeleportService:ReserveServer(GAME_PLACE_ID)

    -- Collect all Player objects from all parties
    local allPlayers = {}
    for _, entry in match do
        for _, userId in entry.memberIds do
            local player = Players:GetPlayerByUserId(userId)
            if player then
                table.insert(allPlayers, player)
            end
        end
    end

    if #allPlayers > 0 then
        local success, err = pcall(function()
            TeleportService:TeleportToPrivateServer(
                GAME_PLACE_ID, code, allPlayers
            )
        end)
        if not success then
            warn("Teleport failed:", err)
        end
    end
end
```

## Variants

| Variant | Queue Type | Matching Logic |
|---------|-----------|----------------|
| **Random** | MemoryStoreQueue | First-come-first-served, fill matches sequentially |
| **Skill-based (ELO/MMR)** | SortedMap (keyed by rating) | Match players within a rating window that expands over time |
| **Party-aware** | SortedMap with party metadata | Group parties first, fill remaining slots with solos |
| **Region-aware** | Separate queues per region | Cross-region fallback after timeout |

## Pitfalls

- **Coordinator crash.** If the coordinator server shuts down, use TTL-based expiry on the coordinator claim so another server can take over within ~30 seconds.
- **MemoryStore rate limits.** Budget is 1000 + (numPlayers x 100) per minute per server. A coordinator processing 200 entries per cycle can hit ~8,400 units/minute. Monitor usage.
- **Stale queue entries.** Players may disconnect after queueing. Use short TTL (60-120s) on queue entries and re-enqueue periodically from the client.
- **Party splitting.** When teleporting, verify all party members are still in the game. If one left, cancel the match and re-queue remaining members.
- **Region limitations.** Roblox assigns server regions at creation time, not per-player. Region-based queuing reduces but does not guarantee latency optimization.

## Related

- [[round-system]] -- what happens after players are matched
- [[lobby-system]] -- where players wait while in queue
- [[MemoryStoreService]] -- the underlying cross-server data layer
- [[TeleportService]] -- the API for moving players between servers

## Sources

- [MatchMaker Module (MemoryStores + Promises)](wiki/raw/community/articles/game-patterns/matchmaker-module-memorystores.md)
- [Custom Matchmaking Service with MemoryStore](wiki/raw/community/articles/game-patterns/matchmaking-memorystore-architecture.md)
- [MemoryStoreQueue Matchmaking Tutorial](wiki/raw/community/articles/game-patterns/matchmaking-memorystorequeue-tutorial.md)
