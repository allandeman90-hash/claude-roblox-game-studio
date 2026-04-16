---
title: "AI Development: Finite State Machines"
type: raw-source
source_url: https://devforum.roblox.com/t/ai-development-finite-state-machines/606268
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, state-machine, FSM, AI, enemy-ai, NPC]
---

# AI Development: Finite State Machines in Roblox

## Core Concepts

A Finite State Machine is a concept used in designing computer programs or digital logic with a finite number of states and transitions. Useful for AI development by outlining NPC behaviors tied to specific states.

**Machine Anatomy:**
- An initial state (where the machine starts)
- Named states (Idle, Walking, Jumping, etc.)
- Events/triggers that cause transitions between states
- Conditions determining which transitions are valid

## Basic Implementation

```lua
local states = {
    "Locked";
    "Unlocked";
}
local machine_current_state = states[1]

function switchStates(input)
    if input == "Push" then
        if machine_current_state == "Locked" then
            machine_current_state = states[1]
        elseif machine_current_state == "Unlocked" then
            machine_current_state = states[1]
        end
    elseif input == "Coin" then
        if machine_current_state == "Locked" then
            machine_current_state = states[2]
        elseif machine_current_state == "Unlocked" then
            machine_current_state = states[2]
        end
    end
end
```

## Module-Based FSM

```lua
local my_states = {
    ["Walking"] = {
        ["Stop"] = "Idle";
        ["Jump"] = "Falling";
    },
    ["Idle"] = {
        ["Walk"] = "Walking";
        ["Jump"] = "Falling";
    },
    ["Falling"] = {
        ["Landed"] = "Idle";
    }
}

local machine = require(stateModule).new("Idle", my_states)

machine:switch("Walk")
print(machine.current_state) --> "Walking"

machine:switch("Jump")
print(machine.current_state) --> "Falling"

machine.onStateChanged:Connect(function(oldState, newState)
    print("Machine changed state from :"..oldState.." To : "..newState)
end)
```

## AI Pet Example (Complete Heartbeat Loop)

```lua
local states = {
    ["Idling"] = {
        ["Walk"] = "Walking";
        ["Jump"] = "Jumping";
    };
    ["Walking"] = {
        ["Idle"] = "Idling";
        ["Jump"] = "Jumping";
    };
    ["Jumping"] = {
        ["Idle"] = "Idling";
        ["Fall"] = "Falling"
    };
    ["Falling"] = {
        ["Land"] = "Landed"
    };
    ["Landed"] = {
        ["Idle"] = "Idling";
        ["Jump"] = "Jumping";
        ["Walk"] = "Walking"
    }
}

local state_machine = require(game.ReplicatedStorage.state).new("Idling", states)

game["Run Service"].Heartbeat:Connect(function()
    if state_machine.current_state == "Idling" then
        -- Play idle animation, rotate, wait 5 seconds then walk
    end
    if state_machine.current_state == "Walking" then
        -- Lerp toward random target point
    end
    if state_machine.current_state == "Jumping" then
        -- Move upward until maxJumpHeight
    end
    if state_machine.current_state == "Falling" then
        -- Move downward until ground level
    end
    if state_machine.current_state == "Landed" then
        -- Transition back to idle
    end
end)

state_machine.onStateChanged:Connect(function(oldState, newState)
    -- Cleanup previous state (reset timers, clear targets)
end)
```

## Source
Original URL: https://devforum.roblox.com/t/ai-development-finite-state-machines/606268
