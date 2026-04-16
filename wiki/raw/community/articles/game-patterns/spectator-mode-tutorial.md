---
title: "Spectator Mode: Camera System Tutorial"
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-make-a-spectate/606352
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, spectator, camera, respawn, death-handling]
---

# Roblox Spectate System Tutorial

## Overview
Tutorial covering creation of a spectate feature allowing players to watch other players through camera manipulation and UI controls.

## UI Components
- A ScreenGui with ResetOnSpawn set to false
- A circular button frame with UIAspectRatioConstraint (ratio: 1)
- An ImageButton centered within the frame
- A SpectateFrame (initially invisible) containing:
  - Central TextLabel for player names
  - Left/Right navigation buttons
  - Stop spectating button

## Core Scripting

**Key Variables:**
```lua
local spectateFrame = script.Parent.SpectateFrame
local button = script.Parent.Frame.ImageButton
local playerList = game:GetService("Players"):GetPlayers()
local position = 1
local cam = workspace.CurrentCamera
```

**Player List Management:**
Maintain a persistent player table that updates when players join/leave, rather than calling `:GetPlayers()` repeatedly, to maintain consistent cycling order.

**Camera Switching Function:**
```lua
local function updateCamera(playerSubject)
    pcall(function()
        spectateFrame.TextLabel.Text = tostring(playerSubject)
        cam.CameraSubject = playerSubject.Character
    end)
end
```

**Button Connections:**
- Toggle visibility with the main button
- Left/Right buttons cycle through playerList with wraparound
- Stop button restores camera to local player

## Community Improvements
- Setting CameraSubject to the Humanoid object (rather than Character) provides better camera positioning
- Detecting player deaths requires monitoring humanoid health changes to prevent stuck camera views
- Using `spectateFrame.Visible = not spectateFrame.Visible` simplifies toggle logic

## Source
Original URL: https://devforum.roblox.com/t/how-to-make-a-spectate/606352
