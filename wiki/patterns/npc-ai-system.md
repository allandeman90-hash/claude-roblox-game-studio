---
title: NPC AI System
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/combat-npc-tutorial.md
  - wiki/raw/community/articles/game-mechanics/simple-pathfinding-ai.md
  - wiki/raw/community/articles/game-mechanics/efficient-aggro-approaches.md
  - wiki/raw/community/articles/game-mechanics/enemy-ai-system-simplepath.md
related:
  - "[[pathfinding-system]]"
  - "[[behavior-trees]]"
  - "[[boss-patterns]]"
  - "[[state-machine-pattern]]"
tags:
  - npc
  - ai
  - combat
  - state-machine
  - aggro
---

# NPC AI System

> Server-side NPC brain using a finite state machine with aggro radius detection, target selection, and leash mechanics.

## Summary

An NPC AI system governs how non-player characters perceive, decide, and act in the game world. The standard Roblox approach runs all NPC logic on the server (never trust the client with AI decisions) and uses a finite state machine (FSM) to transition between behavioral states: idle, patrol, chase, attack, and flee. The system detects players via magnitude checks against configurable radii, selects the best target, and pathfinds toward it using PathfindingService or the SimplePath module.

## Implementation

### State Machine Core

The NPC cycles through discrete states. A centralized loop evaluates conditions each tick and transitions between states.

```lua
-- ServerScriptService/NpcAiController.server.lua

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

-- Config
local AGGRO_RADIUS = 40        -- studs to detect a player
local ATTACK_RANGE = 5         -- studs to start attacking
local LEASH_DISTANCE = 80      -- studs before NPC gives up chase
local DEAGGRO_TIME = 5         -- seconds with no target before returning idle
local TICK_RATE = 0.2          -- seconds between AI ticks

export type NpcState = "idle" | "patrol" | "chase" | "attack" | "flee" | "dead"

local function createNpcBrain(npc: Model)
    local humanoid: Humanoid = npc:FindFirstChildWhichIsA("Humanoid")
    local rootPart: BasePart = npc:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local spawnPosition: Vector3 = rootPart.Position
    local state: NpcState = "idle"
    local currentTarget: Model? = nil
    local deaggroTimer: number = 0

    -- Keep NPC movement server-authoritative
    rootPart:SetNetworkOwner(nil)

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
    })

    return {
        npc = npc,
        humanoid = humanoid,
        rootPart = rootPart,
        spawnPosition = spawnPosition,
        state = state,
        currentTarget = currentTarget,
        deaggroTimer = deaggroTimer,
        path = path,
    }
end
```

### Target Detection and Selection

Scan all players within the aggro radius and pick the closest valid target. This runs every tick but only iterates the player list (small in Roblox: max 100 players).

```lua
local function findNearestTarget(brain): Model?
    local nearestTarget: Model? = nil
    local nearestDistance: number = AGGRO_RADIUS

    for _, player in Players:GetPlayers() do
        local character = player.Character
        if not character then continue end

        local targetRoot = character:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not targetRoot or not targetHumanoid then continue end
        if targetHumanoid.Health <= 0 then continue end

        local distance = (targetRoot.Position - brain.rootPart.Position).Magnitude

        if distance < nearestDistance then
            nearestDistance = distance
            nearestTarget = character
        end
    end

    return nearestTarget
end
```

### State Transitions

```lua
local function tickBrain(brain)
    if brain.humanoid.Health <= 0 then
        brain.state = "dead"
        return
    end

    local target = findNearestTarget(brain)
    local distanceToSpawn = (brain.rootPart.Position - brain.spawnPosition).Magnitude

    -- Leash check: too far from spawn, give up and return
    if distanceToSpawn > LEASH_DISTANCE then
        brain.state = "idle"
        brain.currentTarget = nil
        brain.humanoid:MoveTo(brain.spawnPosition)
        return
    end

    if brain.state == "idle" or brain.state == "patrol" then
        if target then
            brain.currentTarget = target
            brain.deaggroTimer = 0
            brain.state = "chase"
        end

    elseif brain.state == "chase" then
        if not target then
            brain.deaggroTimer += TICK_RATE
            if brain.deaggroTimer >= DEAGGRO_TIME then
                brain.state = "idle"
                brain.currentTarget = nil
                brain.humanoid:MoveTo(brain.spawnPosition)
            end
            return
        end

        brain.deaggroTimer = 0
        brain.currentTarget = target

        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        local distToTarget = (targetRoot.Position - brain.rootPart.Position).Magnitude

        if distToTarget <= ATTACK_RANGE then
            brain.state = "attack"
        else
            -- Pathfind toward target
            local success, err = pcall(function()
                brain.path:ComputeAsync(brain.rootPart.Position, targetRoot.Position)
            end)

            if success and brain.path.Status == Enum.PathStatus.Success then
                local waypoints = brain.path:GetWaypoints()
                if #waypoints >= 2 then
                    brain.humanoid:MoveTo(waypoints[2].Position)
                    if waypoints[2].Action == Enum.PathWaypointAction.Jump then
                        brain.humanoid.Jump = true
                    end
                end
            end
        end

    elseif brain.state == "attack" then
        if not target then
            brain.state = "chase"
            return
        end

        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        local distToTarget = (targetRoot.Position - brain.rootPart.Position).Magnitude

        if distToTarget > ATTACK_RANGE then
            brain.state = "chase"
        else
            -- Face target and deal damage
            brain.rootPart.CFrame = CFrame.new(
                brain.rootPart.Position,
                Vector3.new(targetRoot.Position.X, brain.rootPart.Position.Y, targetRoot.Position.Z)
            )
            -- Fire attack logic (animation + hitbox)
        end

    elseif brain.state == "dead" then
        -- Cleanup or respawn logic
        return
    end
end
```

### Centralized Controller Loop

A single server script manages all NPCs rather than one script per NPC. This reduces thread count and simplifies coordination.

```lua
local brains: {typeof(createNpcBrain(Instance.new("Model")))} = {}

-- Initialize all NPCs
for _, npc in workspace.NPCs:GetChildren() do
    local brain = createNpcBrain(npc)
    if brain then
        table.insert(brains, brain)
    end
end

-- Single loop drives all NPCs
while true do
    for _, brain in brains do
        tickBrain(brain)
    end
    task.wait(TICK_RATE)
end
```

## Variants

### SimplePath Integration

Replace raw PathfindingService calls with SimplePath for automatic path recomputation and stuck detection.

```lua
local SimplePath = require(game.ServerStorage.SimplePath)

local pathParams = {
    AgentHeight = 5,
    AgentRadius = 2,
    AgentCanJump = true,
}
local npcPath = SimplePath.new(npc, pathParams)

-- In chase state, instead of manual ComputeAsync:
npcPath:Run(targetRoot)

npcPath.Blocked:Connect(function()
    -- Path blocked; recompute or switch to idle
end)

npcPath.Error:Connect(function(errorType)
    if errorType == SimplePath.ErrorType.AgentStuck then
        -- Handle stuck NPC
    end
end)
```

### Flee State

Add a flee state for NPCs that retreat when health drops below a threshold.

```lua
local FLEE_HEALTH_PERCENT = 0.2

-- In tickBrain, before chase/attack logic:
if brain.humanoid.Health / brain.humanoid.MaxHealth <= FLEE_HEALTH_PERCENT then
    brain.state = "flee"
    -- Move away from target
    local fleeDirection = (brain.rootPart.Position - targetRoot.Position).Unit
    local fleeTarget = brain.rootPart.Position + fleeDirection * 30
    brain.humanoid:MoveTo(fleeTarget)
    return
end
```

### Aggro Priority System

Instead of nearest-target, weight targets by threat (damage dealt, proximity, class role).

```lua
local function calculateThreat(brain, character: Model): number
    local targetRoot = character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return 0 end

    local distance = (targetRoot.Position - brain.rootPart.Position).Magnitude
    local distanceScore = 1 - (distance / AGGRO_RADIUS) -- closer = higher

    -- Add damage-dealt weight from a tracking table
    local damageScore = (brain.damageReceived[character] or 0) / 100

    return distanceScore * 0.6 + damageScore * 0.4
end
```

## Pitfalls

1. **One script per NPC**: Spawning a Script inside each NPC model creates excessive threads. Use a centralized controller loop with a table of NPC brains.

2. **Heartbeat for AI ticks**: Using `RunService.Heartbeat` for NPC AI creates a new coroutine every frame and is far too frequent for decision-making. A `while true` loop with `task.wait(0.1)` to `task.wait(0.5)` is sufficient.

3. **Forgetting SetNetworkOwner(nil)**: Without this call, Roblox may assign network ownership of the NPC's parts to a nearby player, causing jittery server-side movement. Always call `rootPart:SetNetworkOwner(nil)` for server-controlled NPCs.

4. **Missing deaggro timer**: Without a deaggro delay, NPCs flicker between chase and idle when a player dances at the edge of the aggro radius. Always require N seconds of no-target before returning to idle.

5. **No leash distance**: NPCs that chase forever can be kited across the entire map. Always enforce a maximum distance from spawn before the NPC resets.

6. **Client-side AI**: Running NPC logic on the client is tempting for lag reduction but opens the AI to exploitation. All NPC state decisions belong on the server.

7. **Magnitude on every frame**: Computing `(a - b).Magnitude` involves a square root. For simple threshold checks in hot loops, compare `.Magnitude` against a pre-squared constant only if profiling shows it matters. In practice, with <100 NPCs this is rarely a bottleneck.

## Related

- [[pathfinding-system]] -- PathfindingService details and waypoint following
- [[behavior-trees]] -- Alternative to FSM for complex AI
- [[boss-patterns]] -- Phase-based AI for bosses
- [[state-machine-pattern]] -- General FSM pattern

## Sources

- [General Combat NPC Tutorial](wiki/raw/community/articles/game-mechanics/combat-npc-tutorial.md)
- [Simple Pathfinding AI](wiki/raw/community/articles/game-mechanics/simple-pathfinding-ai.md)
- [Efficient Aggro Approaches](wiki/raw/community/articles/game-mechanics/efficient-aggro-approaches.md)
- [Enemy AI System with SimplePath](wiki/raw/community/articles/game-mechanics/enemy-ai-system-simplepath.md)
- [DevForum: How You Can Use AI Pathfinding](https://devforum.roblox.com/t/how-you-can-use-ai-pathfinding/570721)
- [DevForum: General Combat NPC Tutorial](https://devforum.roblox.com/t/general-combat-npc-tutorial/1862031)
- [DevForum: Efficient Aggro Approaches](https://devforum.roblox.com/t/efficient-aggro-approaches/501394)
