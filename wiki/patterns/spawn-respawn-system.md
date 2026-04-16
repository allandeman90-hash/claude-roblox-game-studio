---
title: Spawn/Respawn System
type: pattern
category: patterns
subcategory: gameplay-loop
owner: game-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/game-patterns/spawn-respawn-system.md
  - wiki/raw/community/articles/game-patterns/spectator-mode-tutorial.md
related:
  - "[[round-system]]"
  - "[[lobby-system]]"
  - "[[state-machine-pattern]]"
tags: [pattern, spawn, respawn, safe-zone, spectator, force-field]
---

# Spawn/Respawn System

> Server-controlled spawn point selection, respawn delay, safe zones, and spectator mode for dead players -- managing how and where characters enter the game world.

## Summary

The spawn/respawn system controls character placement in the game world. Roblox provides built-in spawning via `SpawnLocation` instances, but most competitive games override the default behavior for team-based spawns, respawn delays, safe zones, and spectator mode for eliminated players.

Key decisions: (1) where players spawn (lobby vs team vs dynamic), (2) respawn timing (instant, delayed, or round-locked), (3) protection on spawn (ForceField duration), and (4) what happens while dead (spectator camera, respawn UI, or nothing).

## When to Use It

- Any game with team-based spawns (team colors, per-team spawn areas).
- Games with respawn delay or limited lives per round.
- Games requiring safe zones where players cannot take damage.
- Competitive games where dead players spectate the remainder of the round.

## Implementation

### SpawnLocation Configuration

```lua
-- Server setup: configure spawn points on map load
local function configureSpawns(map: Model)
    for _, spawn in map:GetDescendants() do
        if spawn:IsA("SpawnLocation") then
            spawn.Neutral = false           -- restrict to matching team
            spawn.AllowTeamChangeOnTouch = false
            spawn.Duration = 3              -- ForceField seconds (0 = no FF)
        end
    end
end
```

### Custom Spawn Selection (Server)

```lua
-- ServerScriptService/Services/SpawnService.lua
local Players = game:GetService("Players")

local SpawnService = {}

local RESPAWN_DELAY = 5  -- seconds

function SpawnService.init()
    -- Disable auto-spawn to control it manually
    Players.CharacterAutoLoads = false

    Players.PlayerAdded:Connect(function(player)
        SpawnService.spawnPlayer(player, "lobby")
    end)
end

function SpawnService.spawnPlayer(player: Player, location: string)
    local spawnCFrame = SpawnService.getSpawnPoint(player, location)
    player:LoadCharacter()

    -- Wait for character to exist, then move it
    local character = player.Character or player.CharacterAdded:Wait()
    task.defer(function()
        character:PivotTo(spawnCFrame)
    end)
end

function SpawnService.getSpawnPoint(player: Player, location: string): CFrame
    if location == "lobby" then
        local lobbySpawns = workspace.LobbySpawns:GetChildren()
        return lobbySpawns[math.random(#lobbySpawns)].CFrame + Vector3.new(0, 3, 0)
    end

    -- Team-based: find spawns matching player's team
    local teamSpawns = {}
    for _, spawn in workspace.GameSpawns:GetChildren() do
        if spawn:IsA("SpawnLocation") and spawn.TeamColor == player.TeamColor then
            table.insert(teamSpawns, spawn)
        end
    end

    if #teamSpawns > 0 then
        return teamSpawns[math.random(#teamSpawns)].CFrame + Vector3.new(0, 3, 0)
    end

    -- Fallback: random spawn
    local allSpawns = workspace.GameSpawns:GetChildren()
    return allSpawns[math.random(#allSpawns)].CFrame + Vector3.new(0, 3, 0)
end
```

### FFA Distance-Based Spawning

```lua
-- Pick the spawn farthest from all living players
function SpawnService.getFarthestSpawn(spawns: {SpawnLocation}): CFrame
    local bestSpawn = spawns[1]
    local bestMinDist = 0

    for _, spawn in spawns do
        local minDist = math.huge
        for _, player in Players:GetPlayers() do
            local char = player.Character
            if char and char.PrimaryPart then
                local dist = (spawn.Position - char.PrimaryPart.Position).Magnitude
                minDist = math.min(minDist, dist)
            end
        end
        if minDist > bestMinDist then
            bestMinDist = minDist
            bestSpawn = spawn
        end
    end

    return bestSpawn.CFrame + Vector3.new(0, 3, 0)
end
```

### Respawn with Delay

```lua
function SpawnService.onPlayerDied(player: Player)
    -- Option A: Respawn after delay
    if RESPAWN_ENABLED then
        task.delay(RESPAWN_DELAY, function()
            if player:IsDescendantOf(game) then
                SpawnService.spawnPlayer(player, "game")
            end
        end)
    end

    -- Option B: Spectator mode (round-based, no respawn)
    if SPECTATOR_ENABLED then
        SpectatorRemote:FireClient(player, true)
    end
end
```

### Safe Zone (Damage Prevention)

```lua
-- Server: tag safe zones with CollectionService
local CollectionService = game:GetService("CollectionService")

local function isInSafeZone(character: Model): boolean
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    for _, zone in CollectionService:GetTagged("SafeZone") do
        local size = zone.Size
        local cf = zone.CFrame
        local localPos = cf:PointToObjectSpace(rootPart.Position)
        if math.abs(localPos.X) < size.X/2
           and math.abs(localPos.Y) < size.Y/2
           and math.abs(localPos.Z) < size.Z/2 then
            return true
        end
    end
    return false
end

-- In damage handler:
-- if isInSafeZone(targetCharacter) then return end
```

### Spectator Camera (Client)

```lua
-- StarterPlayerScripts/SpectatorController.client.lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local spectating = false
local spectateIndex = 1
local alivePlayers: {Player} = {}

local function getAlivePlayers(): {Player}
    local alive = {}
    for _, p in Players:GetPlayers() do
        if p ~= player and p.Character
           and p.Character:FindFirstChildOfClass("Humanoid")
           and p.Character.Humanoid.Health > 0 then
            table.insert(alive, p)
        end
    end
    return alive
end

local function spectatePlayer(target: Player)
    local humanoid = target.Character
        and target.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        camera.CameraSubject = humanoid
    end
end

local function cycleSpectate(direction: number)
    alivePlayers = getAlivePlayers()
    if #alivePlayers == 0 then return end
    spectateIndex = ((spectateIndex - 1 + direction) % #alivePlayers) + 1
    spectatePlayer(alivePlayers[spectateIndex])
end

-- Called by server when player dies
SpectatorRemote.OnClientEvent:Connect(function(enabled: boolean)
    spectating = enabled
    if enabled then
        cycleSpectate(0)
        SpectateUI.Visible = true
    else
        camera.CameraSubject = player.Character
            and player.Character:FindFirstChildOfClass("Humanoid")
        SpectateUI.Visible = false
    end
end)

-- UI buttons
NextButton.Activated:Connect(function() cycleSpectate(1) end)
PrevButton.Activated:Connect(function() cycleSpectate(-1) end)
```

## Variants

| Variant | Description |
|---------|-------------|
| **Instant respawn** | `CharacterAutoLoads = true`, default Roblox behavior |
| **Delayed respawn** | Server waits N seconds before `LoadCharacter()` |
| **Wave spawn** | All dead players respawn together at fixed intervals (e.g., every 10s) |
| **Round-locked** | No respawn until round ends; dead players spectate |
| **Checkpoint** | Respawn at last checkpoint touched (obbies, adventure games) |

## Pitfalls

- **Character not loaded.** After `LoadCharacter()`, the character is not immediately available. Use `player.CharacterAdded:Wait()` and `task.defer()` for reliable positioning.
- **Spectator stuck on dead player.** When the spectated player dies or leaves, the camera freezes. Monitor `Humanoid.Died` and `Players.PlayerRemoving` to auto-cycle.
- **StreamingEnabled and spectator.** When spectating a distant player with StreamingEnabled, their character may not be streamed in. The camera may show nothing. Mark spectated characters as Persistent or use `Player:RequestStreamAroundAsync()`.
- **Safe zone exploits.** Players may camp in safe zones. Add a timer or damage-over-time once the round starts to push them out.
- **ForceField stacking.** If `SpawnLocation.Duration > 0`, Roblox auto-creates a ForceField. If you also create one manually, they can stack. Set `Duration = 0` and manage ForceFields entirely in script.

## Related

- [[round-system]] -- manages when players spawn and respawn during matches
- [[lobby-system]] -- the pre-game spawn area
- [[state-machine-pattern]] -- managing player states (alive, dead, spectating)

## Sources

- [Customizable Spawn System Module](wiki/raw/community/articles/game-patterns/spawn-respawn-system.md)
- [Spectator Mode Tutorial](wiki/raw/community/articles/game-patterns/spectator-mode-tutorial.md)
