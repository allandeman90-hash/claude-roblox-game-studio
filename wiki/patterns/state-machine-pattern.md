---
title: State Machine Pattern
type: pattern
category: patterns
subcategory: architecture
owner: lead-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/game-patterns/fsm-ai-development.md
  - wiki/raw/community/articles/game-patterns/stateq-fsm-library.md
related:
  - "[[round-system]]"
  - "[[spawn-respawn-system]]"
  - "[[ecs-pattern]]"
tags: [pattern, state-machine, FSM, AI, enemy-ai, character-state, architecture]
---

# State Machine Pattern

> A finite set of named states with explicit transitions between them, used to organize entity behavior (enemy AI, character actions, combat phases, UI flows) into predictable, debuggable logic.

## Summary

A Finite State Machine (FSM) constrains an entity to be in exactly one state at a time. Each state defines allowed transitions to other states, triggered by events or conditions. The pattern replaces tangled if/else chains with a clean state diagram that maps directly to code.

In Roblox games, FSMs are used for: **enemy AI** (idle/patrol/chase/attack/flee), **character controllers** (idle/running/jumping/falling/attacking), **combat systems** (ready/windup/active/recovery/cooldown), **round phases** (waiting/intermission/gameplay/endgame), and **UI flows** (menu/settings/inventory/confirmation).

## When to Use It

- Any entity with 3+ distinct behavioral modes and rules about which transitions are valid.
- Enemy/NPC AI where behaviors map cleanly to discrete states.
- Character action systems where animations and logic depend on current state.
- Game-wide phase management (round system, tutorial flow).

Not ideal when: entities have many orthogonal concerns that need to be active simultaneously (use [[ecs-pattern]] or hierarchical state machines instead).

## Implementation

### Minimal Table-Based FSM

```lua
-- ReplicatedStorage/Shared/StateMachine.lua
local StateMachine = {}
StateMachine.__index = StateMachine

export type StateMap = {
    [string]: {           -- state name
        [string]: string  -- event name → next state
    }
}

function StateMachine.new(initialState: string, states: StateMap)
    local self = setmetatable({}, StateMachine)
    self.currentState = initialState
    self.states = states
    self.onStateChanged = Instance.new("BindableEvent")
    return self
end

function StateMachine:getState(): string
    return self.currentState
end

function StateMachine:handle(event: string): boolean
    local transitions = self.states[self.currentState]
    if not transitions then
        warn("No transitions defined for state:", self.currentState)
        return false
    end

    local nextState = transitions[event]
    if not nextState then
        -- Invalid transition: event not allowed from current state
        return false
    end

    local oldState = self.currentState
    self.currentState = nextState
    self.onStateChanged:Fire(oldState, nextState, event)
    return true
end

function StateMachine:destroy()
    self.onStateChanged:Destroy()
end

return StateMachine
```

### Enemy AI FSM

```lua
-- ServerScriptService/AI/GuardAI.lua
local StateMachine = require(game.ReplicatedStorage.Shared.StateMachine)

local STATES: StateMachine.StateMap = {
    idle = {
        playerDetected = "chase",
        patrolTimer    = "patrol",
    },
    patrol = {
        playerDetected = "chase",
        reachedWaypoint = "idle",
    },
    chase = {
        inAttackRange  = "attack",
        playerLost     = "idle",
        lowHealth      = "flee",
    },
    attack = {
        attackFinished = "chase",
        playerLost     = "idle",
        lowHealth      = "flee",
    },
    flee = {
        reachedSafety = "idle",
        healthRecovered = "patrol",
    },
}

local function createGuard(npc: Model)
    local fsm = StateMachine.new("idle", STATES)
    local humanoid = npc:FindFirstChildOfClass("Humanoid")

    fsm.onStateChanged.Event:Connect(function(old, new, event)
        -- Cleanup previous state
        if old == "patrol" then
            -- Stop pathfinding
        end

        -- Enter new state
        if new == "idle" then
            humanoid.WalkSpeed = 0
        elseif new == "patrol" then
            humanoid.WalkSpeed = 8
            -- Start pathfinding to next waypoint
        elseif new == "chase" then
            humanoid.WalkSpeed = 16
            -- Path toward detected player
        elseif new == "attack" then
            humanoid.WalkSpeed = 0
            -- Play attack animation, deal damage
        elseif new == "flee" then
            humanoid.WalkSpeed = 20
            -- Path away from threat
        end
    end)

    -- Heartbeat evaluation loop
    local detect_range = 40
    local attack_range = 5
    local flee_threshold = 0.3

    game:GetService("RunService").Heartbeat:Connect(function()
        local state = fsm:getState()
        local health = humanoid.Health / humanoid.MaxHealth
        local nearestPlayer, dist = findNearestPlayer(npc)

        if health < flee_threshold and state ~= "flee" then
            fsm:handle("lowHealth")
            return
        end

        if state == "idle" then
            if nearestPlayer and dist < detect_range then
                fsm:handle("playerDetected")
            end
        elseif state == "patrol" then
            if nearestPlayer and dist < detect_range then
                fsm:handle("playerDetected")
            end
        elseif state == "chase" then
            if not nearestPlayer or dist > detect_range * 1.5 then
                fsm:handle("playerLost")
            elseif dist < attack_range then
                fsm:handle("inAttackRange")
            end
        elseif state == "attack" then
            -- Attack animation fires "attackFinished" event on completion
        end
    end)

    return fsm
end
```

### Character State Controller

```lua
local CHARACTER_STATES: StateMachine.StateMap = {
    idle = {
        move   = "running",
        jump   = "jumping",
        attack = "attacking",
        damage = "staggered",
    },
    running = {
        stop   = "idle",
        jump   = "jumping",
        attack = "attacking",
        damage = "staggered",
    },
    jumping = {
        land   = "idle",
        fall   = "falling",
        damage = "staggered",
    },
    falling = {
        land   = "idle",
        damage = "staggered",
    },
    attacking = {
        attackEnd = "idle",
        damage    = "staggered",
    },
    staggered = {
        recover = "idle",
    },
}
```

### Using the StateQ Library (Typed + Async)

For production systems needing async transitions and strict typing, the StateQ library (Wally: `busycityguy/stateq`) provides:

```lua
local StateQ = require(ReplicatedStorage.Packages.StateQ)

local fsm = StateQ.new("idle", {
    ["StartPatrol"] = {
        canBeFinal = false,
        from = {
            ["idle"] = {
                beforeAsync = function()
                    -- Async: compute path before transitioning
                    local path = PathfindingService:CreatePath()
                    path:ComputeAsync(start, target)
                    return "patrol"
                end,
                afterAsync = function()
                    -- Start walking animation
                end,
            },
        },
    },
    -- ... more events
})

fsm:handle("StartPatrol")
```

## Variants

| Variant | Description | Use Case |
|---------|-------------|----------|
| **Simple table FSM** | State map + event dispatch | Small entity behaviors, prototyping |
| **OOP FSM with signals** | BindableEvent for state changes | Production AI, character controllers |
| **Typed async FSM (StateQ)** | FIFO event queue, async beforeAsync/afterAsync | Complex async transitions, UI flows |
| **Hierarchical FSM** | States contain sub-state-machines | Character with combat sub-states |
| **Pushdown automaton** | Stack of states (push/pop) | Menu navigation, ability interrupts |

## Pitfalls

- **God Heartbeat loop.** Avoid one giant `if state == X then ... elseif` block in Heartbeat. Move per-state logic into separate functions or modules.
- **Missing transitions.** If an event is not defined for the current state, decide whether to silently ignore (return false) or error. Silent ignore is safer for gameplay; error is better for debugging.
- **Animation desync.** State transitions and animations can desync if an animation ends before the state changes. Tie `AnimationTrack.Stopped` events to FSM transition events.
- **Concurrent state machines.** An entity may need multiple FSMs for orthogonal concerns (movement FSM + combat FSM). This is valid but increases complexity. Consider [[ecs-pattern]] for highly compositional behavior.
- **State explosion.** If you have >10 states with dense transition tables, the FSM becomes hard to maintain. Refactor into hierarchical FSM or switch to behavior trees.

## Related

- [[round-system]] -- uses phase-based state management (a round is an FSM)
- [[spawn-respawn-system]] -- player lifecycle states (alive, dead, spectating)
- [[ecs-pattern]] -- alternative for compositional behavior without rigid state boundaries

## Sources

- [AI Development: Finite State Machines](wiki/raw/community/articles/game-patterns/fsm-ai-development.md)
- [StateQ: Typed FSM Library for Luau](wiki/raw/community/articles/game-patterns/stateq-fsm-library.md)
