# Server Authority in Roblox Combat

**Source:** https://devforum.roblox.com/t/server-authority-how-to-begin/4139185
**Captured:** 2026-04-15

## Overview

Tutorial introducing Roblox's Server Authority system (released from Early Access into Beta, December 2025). Server Authority makes the server the only source of truth for game actions, logic, and data. Clients can no longer modify their character properties (velocity, position, rotation) to exploit gameplay.

## Rollback Netcode

To address high-latency problems, the system uses client-side prediction with server-authoritative correction:
- Clients predict outcomes of their inputs immediately
- Server calculates authoritative results
- When predictions diverge (mispredictions), clients "rollback" and resimulate
- 100ms of latency is equivalent to ~6 frames (100 ms / 16.67 ms/frame), meaning the client will be 6 frames ahead of the server

## Required Workspace Settings

- StreamingEnabled: Enabled
- UseFixedSimulation: Enabled
- PlayerScriptsUseInputActionSystem: Enabled
- NextGenerationReplication: Enabled
- Server Authority > AuthorityMode: Server

## Core Architecture

Shared module approach with BindToSimulation:

```lua
-- SimulationModule (in ReplicatedStorage)
local RunService = game:GetService("RunService")

local module = {}

function module.Run()
    RunService:BindToSimulation(function(deltaTime: number)
        -- Runs on both server and client
        -- Core game logic here
    end)
end

return module
```

Both server and client scripts require and execute this module, ensuring identical simulation logic.

## Key APIs

- `RunService:BindToSimulation()` - Right place for core game logic, processing input, updating synchronized game data
- `SetPredictionMode()` - Controls rollback behavior per instance (Off/Automatic/On)
- `GetPredictionStatus()` - Checks prediction status for debugging
- Input Action System (IAS) - Transmits player inputs reliably to servers

## Limitations

- StreamingEnabled required for Server Authority functionality
- System remains in beta; APIs may change
- Use "Server & Clients" test mode rather than single-application testing
