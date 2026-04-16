---
title: "First Person Mode System V1.1"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/first-person-mode-v11/1888136
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [first-person, camera, neck-movement, body-rotation, R15, R6]
---

# First Person Mode System V1.1

Complete first-person mode resource with camera, body, and input handling.

## Features

- Locked first-person mode (prevents camera switching)
- Custom camera placement (default: near player eyes)
- Neck movement (R15 and R6 compatible)
- Player body rotation toward looking position
- Ability to cancel mouse lock (default: LeftAlt key)
- Accessories invisible only on player side (other players see them)

## Architecture

- FirstPersonScript (server-side handler)
- FirstPersonCamera (client-side GUI and LocalScript)
- FirstPersonSettings (ModuleScript with configurable parameters)
- PlayerCameraSettings (enforces client-side restrictions)

## Key Patterns

- Selective transparency: accessories hidden for local player only
- Forced camera settings via StarterPlayer properties
- Neck/Waist Motor6D manipulation for head tracking
- Mouse lock toggle for UI interaction moments
