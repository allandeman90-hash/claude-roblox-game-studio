---
title: "StateQ: Typed Finite State Machine Library for Luau"
type: raw-source
source_url: https://github.com/BusyCityGuy/finite-state-machine-luau
source_type: github
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, state-machine, FSM, library, async, typed-luau]
---

# StateQ: Finite State Machine Library for Luau

## Overview

StateQ is a fully-typed Finite State Machine in Luau that supports async transitions by queueing events, designed for Roblox development. The library enforces logical flow among defined states through event-driven transitions.

## State Change Sequence

1. Fire `beforeEvent` signal (with event name and current state)
2. Execute `transition.beforeAsync()` (required; returns next state)
3. Fire `leavingState` signal
4. Update internal state
5. Fire `stateEntered` signal
6. Execute `transition.afterAsync()` (optional)
7. Fire `afterEvent` signal
8. Fire `finished` signal if the next state is nil and marked as final

**Async Support:** Events queue in FIFO order, allowing asynchronous transitions without blocking subsequent events.

**Final States:** If a transition returns nil during a "canBeFinal" event, the FSM finishes and rejects further events.

## Installation

**Wally:**
```
StateQ = "busycityguy/stateq@0.0.6"
```

## Usage Example

```lua
local StateQ = require(ReplicatedStorage.Packages.StateQ)

local LightState = {
    On = "On",
    Off = "Off",
}

local Event = {
    SwitchOn = "SwitchOn",
    SwitchOff = "SwitchOff",
}

local light = StateQ.new(LightState.On, {
    [Event.SwitchOn] = {
        canBeFinal = true,
        from = {
            [LightState.Off] = {
                beforeAsync = function()
                    print("Light is transitioning to On")
                    for i = 1, 100 do
                        task.wait()
                    end
                    return LightState.On
                end,
                afterAsync = function()
                    print("Light is now On")
                end,
            }
        },
    },
    [Event.SwitchOff] = {
        canBeFinal = true,
        from = {
            [LightState.On] = {
                beforeAsync = function()
                    print("Light is transitioning to Off")
                    return LightState.Off
                end,
            }
        },
    },
})

light:handle(Event.SwitchOff)
light:handle(Event.SwitchOn)
```

## Configuration Structure

Each event defines:
- `canBeFinal`: Boolean indicating if returning nil finishes the FSM
- `from`: Table mapping source states to transition objects
  - `beforeAsync`: Required function returning next state
  - `afterAsync`: Optional callback after state change

## License
MIT License

## Source
Original URL: https://github.com/BusyCityGuy/finite-state-machine-luau
