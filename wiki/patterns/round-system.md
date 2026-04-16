---
title: Round System
type: pattern
category: patterns
subcategory: gameplay-loop
owner: game-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/game-patterns/round-system-basic-tutorial.md
  - wiki/raw/community/articles/game-patterns/round-system-oop-tutorial.md
  - wiki/raw/community/articles/game-patterns/round-system-team-game.md
related:
  - "[[lobby-system]]"
  - "[[spawn-respawn-system]]"
  - "[[matchmaking-queue]]"
  - "[[state-machine-pattern]]"
tags: [pattern, round-system, gameplay-loop, intermission, teams]
---

# Round System

> A server-driven loop that cycles through lobby, intermission, gameplay, and endgame phases, forming the core gameplay cadence of competitive and cooperative Roblox games.

## Summary

The round system is the backbone of round-based Roblox games (murder mystery, battle royale, team deathmatch, minigame collections). It manages the transition from a passive lobby state through active gameplay and back again. The server owns the entire lifecycle -- clients receive state updates via RemoteEvents for UI but never control progression.

A typical round cycles through 4-6 discrete phases: **Lobby/Waiting** (accumulate minimum players), **Intermission** (countdown before start), **Setup** (map load, team assign, teleport), **Grace Period** (brief invulnerability), **Gameplay** (active round with win/lose conditions), **Endgame** (display results, award XP, cleanup).

## When to Use It

- Any game where play sessions are divided into discrete matches with clear start/end boundaries.
- Games requiring a minimum player count before starting (competitive, team-based).
- Minigame collections rotating through different maps or modes.

Not appropriate for open-world sandbox games, persistent survival worlds, or games without discrete match boundaries.

## Implementation

### Phase Enum

```lua
-- ReplicatedStorage/Shared/RoundPhases.lua
export type RoundPhase = "waiting" | "intermission" | "setup" | "grace" | "gameplay" | "endgame"

return {
    Waiting = "waiting" :: RoundPhase,
    Intermission = "intermission" :: RoundPhase,
    Setup = "setup" :: RoundPhase,
    Grace = "grace" :: RoundPhase,
    Gameplay = "gameplay" :: RoundPhase,
    Endgame = "endgame" :: RoundPhase,
}
```

### OOP Round Class

```lua
-- ServerScriptService/Services/RoundService.lua
local Players = game:GetService("Players")

local RoundService = {}
RoundService.__index = RoundService

local CONFIG = {
    MIN_PLAYERS = 2,
    INTERMISSION_TIME = 15,   -- seconds
    GRACE_TIME = 10,
    ROUND_TIME = 120,
    ENDGAME_TIME = 5,
}

function RoundService.new()
    local self = setmetatable({}, RoundService)
    self.phase = "waiting"
    self.timer = 0
    self.isActive = false
    return self
end

function RoundService:setPhase(phase: string)
    self.phase = phase
    -- Fire RemoteEvent to all clients for UI update
    PhaseRemote:FireAllClients(phase)
end

function RoundService:setTimer(seconds: number)
    self.timer = seconds
    TimerRemote:FireAllClients(seconds)
end
```

### Main Loop

```lua
function RoundService:run()
    while true do
        -- Phase 1: Wait for minimum players
        self:setPhase("waiting")
        while #Players:GetPlayers() < CONFIG.MIN_PLAYERS do
            task.wait(1)
        end

        -- Phase 2: Intermission countdown
        self:setPhase("intermission")
        for i = CONFIG.INTERMISSION_TIME, 0, -1 do
            self:setTimer(i)
            task.wait(1)
            -- Abort if players drop below minimum
            if #Players:GetPlayers() < CONFIG.MIN_PLAYERS then
                break
            end
        end

        -- Recheck player count after intermission
        if #Players:GetPlayers() < CONFIG.MIN_PLAYERS then
            continue
        end

        -- Phase 3: Setup (map load, team assign, teleport)
        self:setPhase("setup")
        self:loadMap()
        self:assignTeams()
        self:teleportPlayers()
        task.wait(2)  -- allow character loading

        -- Phase 4: Grace period
        self:setPhase("grace")
        for i = CONFIG.GRACE_TIME, 0, -1 do
            self:setTimer(i)
            task.wait(1)
        end

        -- Phase 5: Gameplay
        self:setPhase("gameplay")
        self.isActive = true
        for i = CONFIG.ROUND_TIME, 0, -1 do
            self:setTimer(i)
            task.wait(1)
            if self:checkWinCondition() then
                break
            end
        end
        self.isActive = false

        -- Phase 6: Endgame
        self:setPhase("endgame")
        self:announceResults()
        self:awardRewards()
        task.wait(CONFIG.ENDGAME_TIME)

        -- Cleanup
        self:returnPlayersToLobby()
        self:destroyMap()
    end
end
```

### Win Condition Monitoring

```lua
function RoundService:checkWinCondition(): boolean
    -- Override per game type. Examples:
    -- Murder mystery: all survivors dead OR killer eliminated
    -- Team deathmatch: one team eliminated
    -- Minigame: objective completed
    return false
end
```

### Team Assignment (Balanced)

```lua
function RoundService:assignTeams()
    local players = Players:GetPlayers()
    -- Shuffle for randomness
    for i = #players, 2, -1 do
        local j = math.random(1, i)
        players[i], players[j] = players[j], players[i]
    end

    for i, player in players do
        if i % 2 == 1 then
            player.Team = Teams.TeamA
        else
            player.Team = Teams.TeamB
        end
    end
end
```

## Variants

| Variant | Description | Example Games |
|---------|-------------|---------------|
| **Asymmetric** | One player has a unique role (killer, seeker) | Murder Mystery 2, Flee the Facility |
| **Team-based** | Two or more balanced teams | Arsenal, BedWars |
| **Free-for-all** | Every player competes individually | Super Doomspire |
| **Elimination** | Dead players spectate until round ends | Survive the Killer |
| **Rotating minigames** | Different game each round from a pool | Epic Minigames |

## Pitfalls

- **Player count drops mid-round.** Always monitor player count during gameplay. If only 1 player remains in a team game, end the round gracefully rather than leaving them alone.
- **Map loading race.** When cloning a map from ServerStorage, `task.wait(2)` before teleporting prevents players from spawning on nothing. Use `Model:PivotTo()` for positioning.
- **Concurrent round attempts.** If `PlayerAdded` triggers `run()`, guard against multiple loops. Use an `isActive` flag or ensure only one coroutine runs the loop.
- **Client UI desync.** Fire phase and timer updates via separate RemoteEvents. If a client joins mid-round, send the current phase and remaining time on join.
- **Cleanup leaks.** Destroy the map clone and disconnect any event connections created during the round. A Trove/Maid per round prevents memory leaks.

## Related

- [[lobby-system]] -- the hub players occupy between rounds
- [[spawn-respawn-system]] -- how players enter the round map
- [[matchmaking-queue]] -- how players are grouped before rounds
- [[state-machine-pattern]] -- a more structured approach to phase management

## Sources

- [Round-Based System Tutorial](wiki/raw/community/articles/game-patterns/round-system-basic-tutorial.md)
- [Round System with OOP](wiki/raw/community/articles/game-patterns/round-system-oop-tutorial.md)
- [Round-Based Team Game Framework](wiki/raw/community/articles/game-patterns/round-system-team-game.md)
