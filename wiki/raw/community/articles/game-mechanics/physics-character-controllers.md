# How to Actually Use Roblox's Physics Character Controllers

**Source:** https://devforum.roblox.com/t/how-to-actually-use-robloxs-physics-character-controllers/3092097
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Tutorial by 04robot48 providing a practical procedural (non-OOP) guide to Roblox's ControllerManager-based character controller system. Uses two scripts: a server setup script and a per-character update script.

## Architecture

Two-script system:
1. **SetupCharacterController** (ServerScriptService) — initializes ControllerManager infrastructure on player join
2. **CharacterControllerUpdate** (StarterCharacterScripts) — per-frame state update

## ControllerManager Configuration

- `RootPart` references HumanoidRootPart
- `BaseMoveSpeed` set to 25
- `FacingDirection` updated from movement input

## GroundController Setup

```lua
local GroundController = Instance.new("GroundController")
GroundController.GroundOffset = 2
GroundController.BalanceRigidityEnabled = true
```

GroundOffset of 2 accounts for character leg height. BalanceRigidity maintains upright posture.

## AirController Setup

```lua
local AirController = Instance.new("AirController")
AirController.MaintainLinearMomentum = true
AirController.MaintainAngularMomentum = false
AirController.BalanceRigidityEnabled = true
AirController.MoveMaxForce = 75000
```

## ControllerPartSensor (Ground Detection)

```lua
local groundSensor = Instance.new("ControllerPartSensor")
groundSensor.SensorMode = Enum.SensorMode.Floor
groundSensor.UpdateType = Enum.SensorUpdateType.Manual
```

### Critical Undocumented Requirement

When updating the ground sensor via raycast, three properties MUST be set:
```lua
groundSensor.SensedPart = raycastToGround.Instance
groundSensor.HitNormal = raycastToGround.Normal
groundSensor.HitFrame = CFrame.new(raycastToGround.Position)
```
Omitting `HitFrame` prevents ascending slopes properly.

## Core Update Loop

```lua
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {character}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local raycastToGround = workspace:Raycast(
    humanoidRootPart.Position,
    Vector3.new(0, -4.5, 0),
    raycastParams
)
```

Raycast hit → switch to GroundController. Miss → switch to AirController.

## Jump Implementation

```lua
local jumpImpulse = Vector3.new(0, 750, 0)
controllerManager.RootPart:ApplyImpulse(jumpImpulse)
floor:ApplyImpulseAtPosition(-jumpImpulse, controllerManager.GroundSensor.HitNormal)
```

Equal-opposite force applied to floor for proper physics.

## Air Control

Dynamic MoveMaxForce prevents overpowered air directional influence:
```lua
airController.MoveMaxForce = humanoidRootPart.AssemblyLinearVelocity.Magnitude
                             * controllerManager.BaseMoveSpeed
```

## Scope

Included: R6/R15, ground movement, jumping, air control.
Excluded: Swimming, climbing.
