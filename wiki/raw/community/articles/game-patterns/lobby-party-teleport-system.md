---
title: Lobby/Party System with TeleportService
type: raw-source
source_url: https://devforum.roblox.com/t/lobby-systemparty-system/1238427
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, lobby, party-system, TeleportService, hub-world]
---

# Roblox Lobby/Party System

## Architecture Patterns

OOP is recommended for scalability. A platform class with table properties tracks player counts on each platform instance.

## Implementation Approach

- **Touch Detection**: A door/entrance part triggers when players approach
- **Exit Mechanism**: A ClickDetector button allows players to leave the party
- **Party Formation**: Once target player count is reached, automatic teleport after countdown
- **State Management**: A Lua table stores active party members

## Key APIs

- `BasePart.Touched` event for entrance detection
- `ClickDetector` for exit button functionality
- `TeleportService:TeleportAsync()` to move players to game levels
- Lua tables for player data storage

## Code Example

```lua
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local lobby = {}

door.Touched:Connect(function(hit)
    if hit.Parent:IsA("Model") and hit.Parent:FindFirstChildOfClass("Humanoid") then
        local check = Players:GetPlayerFromCharacter(hit.Parent)
        if check and #lobby < 3 then
            table.insert(lobby, check)
            if #lobby == 3 then
                TeleportService:TeleportAsync(examplePlaceId, lobby)
            end
        end
    end
end)
```

## DOORS-Style Lobby Pattern

Uses TeleportService with reserved servers:
1. Collect players in a table (must be Player objects, not names)
2. Reserve a private server using `ReserveServer(placeId)`
3. Teleport grouped players using `TeleportToPrivateServer(placeId, code, playerTable)`
4. Party size validation: check table size before teleporting

```lua
local function teleportPlayers()
    if #list > 0 then
        local playersToTeleport = {}
        for i = 1, #list do
            if game.Players:FindFirstChild(list[i]) then
                table.insert(playersToTeleport, game.Players:FindFirstChild(list[i]))
            else
                table.remove(list, i)
            end
        end
        local code = TeleportService:ReserveServer(placeId)
        TeleportService:TeleportToPrivateServer(placeId, code, playersToTeleport)
    end
end
```

## Hub World Architecture

Two approaches for hub-to-gamemode teleportation:

**DataStore-Based:** Maintain a table of servers where each instance adds its JobId. Hub polls every 3 seconds to update the server list. Requires careful rate-limit management.

**External Service (Recommended):** External databases enable complex queries about server metrics, advanced filtering by access levels, performance advantages through stored procedures, and analytics tracking.

## Source
Original URL: https://devforum.roblox.com/t/lobby-systemparty-system/1238427
