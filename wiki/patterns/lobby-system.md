---
title: Lobby System
type: pattern
category: patterns
subcategory: multiplayer
owner: game-designer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/game-patterns/lobby-party-teleport-system.md
related:
  - "[[round-system]]"
  - "[[matchmaking-queue]]"
  - "[[spawn-respawn-system]]"
  - "[[TeleportService]]"
tags: [pattern, lobby, hub-world, party, teleport, game-selection]
---

# Lobby System

> The persistent pre-game space where players gather, form parties, select game modes, and wait for matches -- serving as the hub between rounds or game sessions.

## Summary

A lobby system provides the social and logistical space between gameplay sessions. It encompasses the **hub world** (the physical space players occupy), **party formation** (grouping friends before queuing), **game selection UI** (choosing mode, map, difficulty), and **teleportation** (moving groups to private game servers). The lobby can be a zone within the same place (same-server lobby) or a separate place in a universe (dedicated lobby server).

On Roblox, lobby-to-game transitions use **TeleportService** with **reserved servers** for isolated matches. Party state can be tracked in a Lua table (same-server) or **MemoryStoreService** (cross-server parties).

## When to Use It

- Any game with discrete matches or rounds that players queue into from a shared space.
- Games with multiple game modes or maps that players choose from a menu.
- Social games where players form parties of 2-4 before entering content together.
- Games using the "hub world + instanced dungeons" pattern (like DOORS, Dungeon Quest).

Not needed for: single-continuous-world games, games that auto-assign players on join without a pregame phase.

## Implementation

### Same-Server Lobby (Simple)

Players spawn in a lobby zone within the same place. A round system manages transitions without teleportation.

```lua
-- ServerScriptService/Services/LobbyService.lua
local LobbyService = {}

local lobbyPlayers: {Player} = {}
local LOBBY_SPAWN = workspace.LobbySpawns

function LobbyService.addToLobby(player: Player)
    table.insert(lobbyPlayers, player)
    player.Team = Teams.Lobby
    -- Character spawns at lobby spawn via team-colored SpawnLocation
end

function LobbyService.removeFromLobby(player: Player)
    local idx = table.find(lobbyPlayers, player)
    if idx then
        table.remove(lobbyPlayers, idx)
    end
end

function LobbyService.getWaitingPlayers(): {Player}
    return lobbyPlayers
end

return LobbyService
```

### Dedicated Lobby Server (Hub World)

The lobby is a separate Roblox place. Players teleport to reserved game servers.

```lua
-- ServerScriptService/Services/HubService.lua (Lobby Place)
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local HubService = {}

local GAME_MODES = {
    solo = { placeId = 111111111, minPlayers = 1, maxPlayers = 1 },
    duo = { placeId = 222222222, minPlayers = 2, maxPlayers = 2 },
    squad = { placeId = 333333333, minPlayers = 3, maxPlayers = 4 },
}

function HubService.startGame(leader: Player, mode: string, partyMembers: {Player})
    local config = GAME_MODES[mode]
    if not config then return false, "invalid_mode" end

    if #partyMembers < config.minPlayers then
        return false, "not_enough_players"
    end
    if #partyMembers > config.maxPlayers then
        return false, "too_many_players"
    end

    -- Verify all party members are still in the game
    local validPlayers = {}
    for _, p in partyMembers do
        if p:IsDescendantOf(game) then
            table.insert(validPlayers, p)
        end
    end

    local success, result = pcall(function()
        local code = TeleportService:ReserveServer(config.placeId)
        TeleportService:TeleportToPrivateServer(
            config.placeId, code, validPlayers
        )
    end)

    if not success then
        warn("Teleport failed:", result)
        return false, "teleport_failed"
    end

    return true
end

return HubService
```

### Party Formation

```lua
-- ServerScriptService/Services/PartyService.lua
local PartyService = {}

export type Party = {
    leaderId: number,
    members: {Player},
    maxSize: number,
    createdAt: number,
}

local parties: {[number]: Party} = {}  -- leaderId → Party
local playerParty: {[Player]: number} = {}  -- player → leaderId

local MAX_PARTY_SIZE = 4

function PartyService.createParty(leader: Player): Party
    if playerParty[leader] then
        return parties[playerParty[leader]]
    end

    local party: Party = {
        leaderId = leader.UserId,
        members = {leader},
        maxSize = MAX_PARTY_SIZE,
        createdAt = os.time(),
    }
    parties[leader.UserId] = party
    playerParty[leader] = leader.UserId
    return party
end

function PartyService.invite(leader: Player, target: Player): (boolean, string?)
    local party = parties[leader.UserId]
    if not party then return false, "no_party" end
    if party.leaderId ~= leader.UserId then return false, "not_leader" end
    if #party.members >= party.maxSize then return false, "party_full" end
    if playerParty[target] then return false, "already_in_party" end

    -- Send invite to target via RemoteEvent
    InviteRemote:FireClient(target, leader.Name, leader.UserId)
    return true
end

function PartyService.acceptInvite(target: Player, leaderId: number): boolean
    local party = parties[leaderId]
    if not party then return false end
    if #party.members >= party.maxSize then return false end

    table.insert(party.members, target)
    playerParty[target] = leaderId

    -- Notify all party members
    for _, member in party.members do
        PartyUpdateRemote:FireClient(member, party)
    end
    return true
end

function PartyService.leave(player: Player)
    local leaderId = playerParty[player]
    if not leaderId then return end

    local party = parties[leaderId]
    if not party then return end

    local idx = table.find(party.members, player)
    if idx then table.remove(party.members, idx) end
    playerParty[player] = nil

    -- If leader left, promote next member or disband
    if player.UserId == leaderId then
        if #party.members > 0 then
            local newLeader = party.members[1]
            party.leaderId = newLeader.UserId
            parties[newLeader.UserId] = party
            parties[leaderId] = nil
            for _, m in party.members do
                playerParty[m] = newLeader.UserId
            end
        else
            parties[leaderId] = nil
        end
    end
end

-- Cleanup on player leaving
Players.PlayerRemoving:Connect(function(player)
    PartyService.leave(player)
end)

return PartyService
```

### Elevator/Room-Based Lobby (DOORS Pattern)

```lua
-- Players step onto a platform, countdown starts, group teleports together
local ELEVATOR_MAX = 4
local COUNTDOWN = 10

local elevatorPlayers: {Player} = {}
local countdownActive = false

ElevatorZone.Touched:Connect(function(hit)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if not player then return end
    if table.find(elevatorPlayers, player) then return end
    if #elevatorPlayers >= ELEVATOR_MAX then return end

    table.insert(elevatorPlayers, player)
    updateElevatorUI()

    if #elevatorPlayers >= 1 and not countdownActive then
        countdownActive = true
        for i = COUNTDOWN, 0, -1 do
            CountdownRemote:FireAllClients(i)
            task.wait(1)
            -- Remove disconnected players
            for j = #elevatorPlayers, 1, -1 do
                if not elevatorPlayers[j]:IsDescendantOf(game) then
                    table.remove(elevatorPlayers, j)
                end
            end
            if #elevatorPlayers == 0 then
                countdownActive = false
                return
            end
        end

        -- Teleport
        local code = TeleportService:ReserveServer(GAME_PLACE_ID)
        pcall(function()
            TeleportService:TeleportToPrivateServer(
                GAME_PLACE_ID, code, elevatorPlayers
            )
        end)

        elevatorPlayers = {}
        countdownActive = false
    end
end)
```

## Architecture Comparison

| Pattern | Lobby Location | Party State | Pros | Cons |
|---------|---------------|-------------|------|------|
| **Same-server** | Zone in game place | Lua table | Simple, no teleport latency | Server holds lobby + game players |
| **Dedicated lobby place** | Separate place | Lua table or MemoryStore | Isolated, scales independently | Teleport latency, more complex |
| **Hub + instanced dungeons** | Hub place + private game places | MemoryStore for cross-server | Clean separation, supports many modes | Most complex, requires universe setup |

## Pitfalls

- **Teleport failures.** `TeleportService:TeleportToPrivateServer()` can fail silently or throw. Always wrap in pcall and provide feedback to the player. Implement retry logic with `TeleportService.TeleportInitFailed`.
- **Party desync.** If a party member disconnects between party creation and teleport, the teleport call fails for the entire group. Validate all members immediately before teleporting.
- **Lobby crowding.** High-CCU games may have 50+ players in one lobby server. Manage player density with multiple lobby instances or `TeleportService:TeleportAsync()` overflow routing.
- **Cross-server party state.** For parties that span multiple servers (invite while in different servers), MemoryStoreService is required. Same-server Lua tables are simpler but only work when all party members are co-located.
- **Back-teleport after game.** When the game ends, teleport players back to the lobby place. Use `TeleportService:Teleport(LOBBY_PLACE_ID, player)`. Include teleport data (rewards, stats) via `TeleportOptions:SetTeleportData()`.

## Related

- [[round-system]] -- what runs after players leave the lobby
- [[matchmaking-queue]] -- cross-server player grouping before teleport
- [[spawn-respawn-system]] -- where players appear in the lobby and game
- [[TeleportService]] -- the underlying API for moving players between places

## Sources

- [Lobby/Party System with TeleportService](wiki/raw/community/articles/game-patterns/lobby-party-teleport-system.md)
