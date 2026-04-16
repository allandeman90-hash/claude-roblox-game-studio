---
title: "MatchMaker: Flexible Matchmaking Module (MemoryStores + Promises)"
type: raw-source
source_url: https://devforum.roblox.com/t/betav022025-matchmaker-a-flexible-matchmaking-module-built-on-promises-and-memorystores/3663545
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, matchmaking, MemoryStoreService, queue, skill-based, party-aware]
---

# MatchMaker Module for Roblox (v0.2, 2025)

## Module Introduction

MatchMaker is a modular matchmaking system built on promises and MemoryStoreService for Roblox multiplayer games. It handles region-based player queues, asynchronous coordination, private server management, and cross-server state synchronization.

## Key Architecture Features

- Region-based queue organization for geographic player grouping
- Promise-driven asynchronous operations (non-blocking)
- Automatic match coordination via designated server instances
- Dynamic private server integration with metadata tracking
- Graceful error propagation and isolation
- Customizable matchmaking logic through pluggable functions

## API Surface

### Core Method: `.new()`

```lua
local SoloMatchMaker = MatchMakerService.new({
    Name = "Solo",
    MatchMaking = function(parties)
        local matches = {}
        for _, party in ipairs(parties) do
            table.insert(matches, {
                PlaceId = game.PlaceId,
                Parties = { party },
            })
        end
        return matches
    end,
})
```

### Party Management

**Method: `:AddPartyAsync(PartyMemberIds, PartyData)`**

Adds player groups to the queue with associated metadata. Single-player parties are supported (list containing one UserID). Parties can include skill ratings or other ranking data as metadata for skill-based matching implementations.

### Events

- `PartyAdded`: Fires when a party enters queue
- `PartyRemoved`: Fires when a party leaves queue

## Skill-Based Matching Implementation

The module supports rating-based matchmaking through metadata. When adding parties via `:AddPartyAsync`, include player ratings in the metadata. The custom `MatchMaking` function receives all queued parties with their metadata, enabling developers to implement custom ranking algorithms.

## 2v2 Team Matching Example

```lua
local function Matchmaking2v2(Parties)
    local Matches = {}
    if #Parties < 2 then return Matches end

    local Duos = {}
    local Solos = {}

    for _, party in ipairs(Parties) do
        if #party.MemberIds == 2 then
            table.insert(Duos, party)
        else
            table.insert(Solos, party)
        end
    end

    -- Duo vs Duo
    while #Duos >= 2 do
        local p1 = table.remove(Duos, 1)
        local p2 = table.remove(Duos, 1)
        table.insert(Matches, {
            PlaceId = MatchPlaceId,
            Parties = {p1, p2},
        })
    end

    -- Duo vs 2 Solos
    while #Duos >= 1 and #Solos >= 2 do
        local duo = table.remove(Duos, 1)
        local s1 = table.remove(Solos, 1)
        local s2 = table.remove(Solos, 1)
        table.insert(Matches, {
            PlaceId = MatchPlaceId,
            Parties = {duo, s1, s2},
        })
    end

    -- 4 Solos
    while #Solos >= 4 do
        local s1 = table.remove(Solos, 1)
        local s2 = table.remove(Solos, 1)
        local s3 = table.remove(Solos, 1)
        local s4 = table.remove(Solos, 1)
        table.insert(Matches, {
            PlaceId = MatchPlaceId,
            Parties = {s1, s2, s3, s4},
        })
    end

    return Matches
end
```

## Known Limitations

- Region-based latency optimization is limited by Roblox's server assignment process
- Cross-region matching may not function reliably with extended timeout configs
- Parties may not automatically remove when players leave the queue

## Resources

- Documentation: mlesne1.github.io/MatchMaker
- Demo Place: Roblox MatchMaker Template Place (game ID: 131765851319441)

## Source
Original URL: https://devforum.roblox.com/t/betav022025-matchmaker-a-flexible-matchmaking-module-built-on-promises-and-memorystores/3663545
