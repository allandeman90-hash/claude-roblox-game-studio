---
title: Character Controller
type: pattern
category: patterns
subcategory: movement
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/physics-character-controllers.md
  - wiki/raw/community/articles/game-mechanics/character-controller-library-release.md
  - wiki/raw/community/articles/game-mechanics/wall-climbing-system.md
related:
  - "[[movement-abilities]]"
  - "[[state-machine-pattern]]"
  - "[[vehicle-physics]]"
  - "[[spawn-respawn-system]]"
tags: [pattern, character-controller, humanoid, ControllerManager, movement, BodyMovers, LinearVelocity, server-authority]
---

# Character Controller

> Extending or replacing the default Humanoid movement system to support custom locomotion, including WalkSpeed/JumpPower tuning, the new ControllerManager physics system, and server-authoritative movement validation.

## Summary

Roblox provides two character movement systems. The **legacy Humanoid** system handles walking, jumping, climbing, and swimming through internal engine code driven by properties like `WalkSpeed`, `JumpPower`, and `HumanoidStateType`. The **ControllerManager** system (fully released via the Character Controller Library) moves all movement logic into transparent Luau code, giving developers direct control over ground, air, swim, and climb physics through discrete controller objects.

Most games start by tuning Humanoid properties. Games requiring advanced locomotion -- variable gravity, momentum conservation, custom friction, or abilities like wall running -- benefit from the ControllerManager approach or from layering custom forces via LinearVelocity on top of the Humanoid.

Regardless of approach, server-side movement validation is required to prevent speed hacks and teleport exploits.

## Implementation

### Approach 1: Humanoid Property Tuning

The simplest path. Modify Humanoid properties at runtime from the server.

```lua
-- ServerScriptService/CharacterSetup.server.lua
local Players = game:GetService("Players")

local BASE_WALK_SPEED = 16
local BASE_JUMP_POWER = 50

Players.PlayerAdded:Connect(function(player: Player)
    player.CharacterAdded:Connect(function(character: Model)
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid

        humanoid.WalkSpeed = BASE_WALK_SPEED
        humanoid.JumpPower = BASE_JUMP_POWER
        humanoid.MaxSlopeAngle = 60

        -- Disable states the game does not use
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    end)
end)
```

**Humanoid states** drive animation and physics behavior. Key states:

| State | Trigger |
|-------|---------|
| `Running` | Character on ground with non-zero MoveDirection |
| `Freefall` | Character in air, not jumping |
| `Jumping` | Jump initiated (transitions to Freefall) |
| `Climbing` | Contact with TrussPart |
| `Swimming` | Submerged in Terrain water |
| `Seated` | Occupying a Seat or VehicleSeat |
| `Dead` | Health reaches 0 |

Listen to state changes via `Humanoid.StateChanged`:

```lua
humanoid.StateChanged:Connect(function(oldState: Enum.HumanoidStateType, newState: Enum.HumanoidStateType)
    if newState == Enum.HumanoidStateType.Landed then
        -- Reset jump counter, play landing effect, etc.
    end
end)
```

### Approach 2: ControllerManager (New Physics System)

The ControllerManager replaces Humanoid's internal movement with explicit controller objects. This approach is procedural and does not require OOP.

**Server setup** (ServerScriptService):

```lua
-- ServerScriptService/SetupCharacterController.server.lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player: Player)
    player.CharacterAdded:Connect(function(character: Model)
        local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

        local controllerManager = Instance.new("ControllerManager")
        controllerManager.RootPart = rootPart
        controllerManager.BaseMoveSpeed = 25

        -- Ground controller
        local groundController = Instance.new("GroundController")
        groundController.GroundOffset = 2 -- accounts for leg height
        groundController.BalanceRigidityEnabled = true
        groundController.Parent = controllerManager

        -- Air controller
        local airController = Instance.new("AirController")
        airController.MaintainLinearMomentum = true
        airController.MaintainAngularMomentum = false
        airController.BalanceRigidityEnabled = true
        airController.MoveMaxForce = 75000
        airController.Parent = controllerManager

        -- Ground sensor (manual raycasting)
        local groundSensor = Instance.new("ControllerPartSensor")
        groundSensor.SensorMode = Enum.SensorMode.Floor
        groundSensor.UpdateType = Enum.SensorUpdateType.Manual
        groundSensor.Parent = controllerManager

        controllerManager.GroundSensor = groundSensor
        controllerManager.Parent = character
    end)
end)
```

**Client update loop** (StarterCharacterScripts):

```lua
-- StarterCharacterScripts/CharacterControllerUpdate.client.lua
local RunService = game:GetService("RunService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
local controllerManager = character:WaitForChild("ControllerManager") :: ControllerManager

local groundSensor = controllerManager.GroundSensor :: ControllerPartSensor
local groundController = controllerManager:FindFirstChildOfClass("GroundController")
local airController = controllerManager:FindFirstChildOfClass("AirController")

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {character}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

RunService.Heartbeat:Connect(function()
    -- Update ground sensor via raycast
    local rayResult = workspace:Raycast(
        rootPart.Position,
        Vector3.new(0, -4.5, 0),
        raycastParams
    )

    if rayResult then
        -- CRITICAL: all three properties must be set for slopes
        groundSensor.SensedPart = rayResult.Instance
        groundSensor.HitNormal = rayResult.Normal
        groundSensor.HitFrame = CFrame.new(rayResult.Position)
        controllerManager.ActiveController = groundController
    else
        groundSensor.SensedPart = nil
        controllerManager.ActiveController = airController
    end

    -- Sync movement direction from Humanoid input
    local moveDir = humanoid.MoveDirection
    controllerManager.MovingDirection = moveDir

    if moveDir.Magnitude > 0 then
        controllerManager.FacingDirection = moveDir
    end
end)
```

**Jump with equal-opposite floor force:**

```lua
local JUMP_IMPULSE = Vector3.new(0, 750, 0)

local function jump()
    if controllerManager.ActiveController ~= groundController then return end

    rootPart:ApplyImpulse(JUMP_IMPULSE)

    local floor = groundSensor.SensedPart
    if floor then
        floor:ApplyImpulseAtPosition(-JUMP_IMPULSE, groundSensor.HitFrame.Position)
    end

    controllerManager.ActiveController = airController
end
```

### Approach 3: Custom Forces via LinearVelocity

Layer custom movement on top of the Humanoid without replacing it. LinearVelocity (the modern replacement for BodyVelocity) applies forces in a specific direction.

```lua
-- Apply a horizontal boost (e.g., knockback, launch pad)
local function applyImpulse(rootPart: BasePart, direction: Vector3, speed: number, duration: number)
    local attachment = Instance.new("Attachment")
    attachment.Parent = rootPart

    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Attachment0 = attachment
    linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linearVelocity.MaxForce = math.huge
    linearVelocity.LineVelocity = direction.Unit * speed -- for Line mode
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVelocity.Parent = rootPart

    task.delay(duration, function()
        linearVelocity:Destroy()
        attachment:Destroy()
    end)
end
```

**Legacy BodyMovers** (BodyVelocity, BodyPosition, BodyForce) still work but are deprecated. New code should use LinearVelocity, AlignPosition, AlignOrientation, and VectorForce.

## Server Validation

Movement exploits (speed hacks, teleports, fly hacks) are the most common Roblox cheats. Server-side validation is not optional.

### Distance-Based Sanity Check

```lua
-- ServerScriptService/MovementValidator.server.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MAX_SPEED = 50 -- studs per second (generous margin above WalkSpeed)
local CHECK_INTERVAL = 1 -- seconds

local lastPositions: {[Player]: Vector3} = {}

Players.PlayerAdded:Connect(function(player: Player)
    player.CharacterAdded:Connect(function(character: Model)
        local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
        lastPositions[player] = rootPart.Position
    end)
end)

-- Periodic position check
while true do
    task.wait(CHECK_INTERVAL)
    for _, player in Players:GetPlayers() do
        local character = player.Character
        if not character then continue end

        local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not rootPart then continue end

        local lastPos = lastPositions[player]
        if lastPos then
            local distance = (rootPart.Position - lastPos).Magnitude
            local maxAllowed = MAX_SPEED * CHECK_INTERVAL * 1.5 -- 1.5x tolerance

            if distance > maxAllowed then
                -- Teleport back or flag for review
                rootPart.CFrame = CFrame.new(lastPos)
                warn(`[AntiCheat] {player.Name} moved {distance:.1f} studs in {CHECK_INTERVAL}s`)
            end
        end

        lastPositions[player] = rootPart.Position
    end
end
```

### WalkSpeed Enforcement

```lua
-- Ensure client cannot tamper with WalkSpeed
RunService.Heartbeat:Connect(function()
    for _, player in Players:GetPlayers() do
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed > MAX_WALK_SPEED then
            humanoid.WalkSpeed = BASE_WALK_SPEED
        end
    end
end)
```

## Pitfalls

1. **Forgetting HitFrame on ControllerPartSensor.** Omitting `HitFrame` when updating the ground sensor prevents characters from ascending slopes. All three properties (`SensedPart`, `HitNormal`, `HitFrame`) must be set together.

2. **Client-only WalkSpeed changes.** Setting `Humanoid.WalkSpeed` from a LocalScript is trivially overridden by exploiters. Always set movement properties from the server or validate them server-side.

3. **BodyMovers vs LinearVelocity.** BodyVelocity, BodyPosition, and BodyForce are deprecated. New implementations should use LinearVelocity, AlignPosition, and VectorForce. Mixing legacy and new movers on the same assembly produces unpredictable results.

4. **ControllerManager + Humanoid coexistence.** The ControllerManager does not disable the Humanoid. If both attempt to drive movement simultaneously, conflicts arise. When using ControllerManager, disable Humanoid movement states or set `WalkSpeed = 0`.

5. **Humanoid:MoveTo() not supported on ControllerManager.** The Character Controller Library does not yet implement `Humanoid:MoveTo()`. NPC pathfinding that relies on it needs a workaround (direct CFrame or custom move-to logic).

6. **Overcorrecting anti-cheat.** Legitimate lag spikes cause position jumps. Use tolerance multipliers (1.5x-2x) and accumulate violations before punishing. A single spike should not trigger a teleport-back.

## Related

- [[movement-abilities]] -- dash, double jump, wall slide, sprint, grapple hook built on these foundations
- [[state-machine-pattern]] -- FSM for managing character action states (idle, running, jumping, climbing)
- [[vehicle-physics]] -- VehicleSeat and custom vehicle controllers
- [[spawn-respawn-system]] -- character loading and respawn flow

## Sources

- [How to Actually Use Roblox's Physics Character Controllers](https://devforum.roblox.com/t/how-to-actually-use-robloxs-physics-character-controllers/3092097) (DevForum tutorial by 04robot48, 2024)
- [Character Controller Library — Full Release](https://devforum.roblox.com/t/full-release-the-future-of-character-movement-character-controller-library/4565267) (Official Roblox announcement)
- [ControllerManager API Reference](https://create.roblox.com/docs/reference/engine/classes/ControllerManager) (Roblox Creator Docs)
- [How should I make a custom character controller?](https://devforum.roblox.com/t/how-should-i-make-a-custom-character-controller/2664167) (DevForum discussion)
- [Best way to make a custom character controller?](https://devforum.roblox.com/t/best-way-to-make-a-custom-character-controller/1244912) (DevForum discussion)
