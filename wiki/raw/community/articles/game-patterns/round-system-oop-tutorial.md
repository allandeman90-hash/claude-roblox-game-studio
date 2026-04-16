---
title: Round System with OOP
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-make-a-simple-round-system-with-object-oriented-programming/3126614
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, round-system, oop, state-management, gameplay-loop]
---

# Round System with OOP in Roblox

## Overview
This tutorial teaches creating a functional round system using object-oriented programming in Roblox Luau.

## Architecture Setup

**Folder Structure:**
- ServerScriptService/Modules (module scripts)
- ServerScriptService/Scripts (server scripts)
- ReplicatedStorage/RemoteEvents (remote event objects)

## Core Round Class

```lua
local Round = {}
Round.__index = Round

function Round.new()
    local self = setmetatable({}, Round)
    self.IntermissionTime = 15
    self.GraceTime = 10
    self.RoundTime = 60
    self.IsRound = false
    self.Status = ""
    self.Timer = 0
    return self
end
```

## Key Methods

**Player Check:**
```lua
function Round.EnoughPlayers()
    return #Players:GetPlayers() >= 2
end
```

**Intermission Phase:**
```lua
function Round:Intermission()
    self.Status = "Intermission"
    statusRemoteEvent:FireAllClients(self.Status)
    for index = self.IntermissionTime, 0, -1 do
        self.Timer = index
        timerRemoteEvent:FireAllClients(self.Timer)
        task.wait(1)
    end
end
```

**Player Teleportation:**
```lua
function Round:BringPlayers()
    self.IsRound = true
    self.Status = "Bringing players..."
    statusRemoteEvent:FireAllClients(self.Status)
    for index, player in Players:GetPlayers() do
        local character = player.Character
        local randomNumberX = math.random(-100, 100)
        local randomNumberZ = math.random(-100, 100)
        character:SetPrimaryPartCFrame(CFrame.new(randomNumberX, 0, randomNumberZ))
    end
    task.wait(1)
end
```

**Grace Period:**
```lua
function Round:GracePeriod()
    self.Status = "Grace"
    statusRemoteEvent:FireAllClients(self.Status)
    for index = self.GraceTime, 0, -1 do
        self.Timer = index
        timerRemoteEvent:FireAllClients(self.Timer)
        task.wait(1)
    end
end
```

**Round Execution:**
```lua
function Round:Start()
    self.Status = "Round"
    statusRemoteEvent:FireAllClients(self.Status)
    for index = self.RoundTime, 0, -1 do
        self.Timer = index
        timerRemoteEvent:FireAllClients(self.Timer)
        task.wait(1)
    end
    self.IsRound = false
end
```

## Abstraction Pattern — Daisy-Chain All Phases

```lua
function Round:Initiate()
    while true do
        if not self.EnoughPlayers() then return end
        if self.IsRound then return end
        self:Intermission()
        self:BringPlayers()
        self:GracePeriod()
        self:Start()
    end
end
```

## Server Implementation

```lua
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Round = require(ServerScriptService.Modules.Round)
local newRound = Round.new()

Players.PlayerAdded:Connect(function()
    newRound:Initiate()
end)
```

## Client-Side GUI Updates

```lua
local statusRemoteEvent = ReplicatedStorage.RemoteEvents.StatusRemoteEvent
local timerRemoteEvent = ReplicatedStorage.RemoteEvents.TimerRemoteEvent

local function onStatusRemoteEvent(status: string)
    container.Status.Text = status
end

local function onTimerRemoteEvent(timer: number)
    container.Timer.Text = timer
end

statusRemoteEvent.OnClientEvent:Connect(onStatusRemoteEvent)
timerRemoteEvent.OnClientEvent:Connect(onTimerRemoteEvent)
```

## State Phases
1. **Intermission** - Waiting period before round
2. **Bringing Players** - Teleporting to spawn locations
3. **Grace** - Protected period before combat
4. **Round** - Active gameplay phase

## Source
Original URL: https://devforum.roblox.com/t/how-to-make-a-simple-round-system-with-object-oriented-programming/3126614
