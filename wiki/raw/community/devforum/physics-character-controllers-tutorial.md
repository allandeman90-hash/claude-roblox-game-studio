---
title: How to Actually Use Roblox's Physics Character Controllers
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-actually-use-robloxs-physics-character-controllers/3092097
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: 04robot48
post_date: 2024-07-29
tags: [character-controller, physics, controllermanager, movement, platformer]
---

# How to Actually Use Roblox's Physics Character Controllers

**Author:** 04robot48 (Robotstics)
**Posted:** July 29, 2024

## Overview

This tutorial explains how to implement Roblox's physics character controllers, addressing gaps in official documentation. The author spent significant time learning these systems and created this guide to help others understand their practical application.

## Key Setup Pattern

The tutorial uses two scripts:

1. **SetupCharacterController** (Server) - Creates a ControllerManager for each joining player
2. **CharacterControllerUpdate** (LocalScript) - Updates character movement and sensor data each frame

## Core Implementation Steps

**ControllerManager Setup:**
The server disables default humanoid physics with `Humanoid.EvaluateStateMachine = false`, then creates a ControllerManager with:
- BaseMoveSpeed property (set to 25 by default)
- RootPart reference
- GroundSensor (ControllerPartSensor in Floor mode)
- GroundController and AirController children

**Critical Finding:**
As the author notes:

> "one consequence of not writing this property is that the character won't be able to go up slopes"

—referring to the HitFrame property that Roblox's documentation reportedly omitted.

## Movement Update Loop

The character updates each frame via `RunService.RenderStepped`:
- Raycasts downward to detect ground contact
- Updates sensor properties (Instance, Normal, HitFrame)
- Sets ActiveController based on ground detection
- Syncs ControllerManager.MovingDirection with Humanoid.MoveDirection

## Bonus Feature: Smooth Air Movement

The tutorial includes a technique for balanced in-air directional influence by dynamically adjusting the AirController's maximum force based on current velocity.

## Limitations

- Non-OOP approach
- No climbing or swimming
- Requires custom death/reset logic (Humanoid.Died event doesn't work with disabled state machine)

A working place file is provided for download.

## Source

Original URL: https://devforum.roblox.com/t/how-to-actually-use-robloxs-physics-character-controllers/3092097
Captured: 2026-04-16
