---
title: Movement Abilities
type: pattern
category: patterns
subcategory: movement
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/consistent-dash-ability.md
  - wiki/raw/community/articles/game-mechanics/reliable-double-jump.md
  - wiki/raw/community/articles/game-mechanics/wall-jump-wall-slide.md
  - wiki/raw/community/articles/game-mechanics/sprint-stamina-system.md
  - wiki/raw/community/articles/game-mechanics/sekiro-grapple-hook.md
  - wiki/raw/community/articles/game-mechanics/modular-swimming-system.md
  - wiki/raw/community/articles/game-mechanics/wall-climbing-system.md
related:
  - "[[character-controller]]"
  - "[[state-machine-pattern]]"
  - "[[spawn-respawn-system]]"
tags: [pattern, movement, dash, double-jump, wall-slide, wall-jump, sprint, stamina, grapple-hook, swimming, climbing]
---

# Movement Abilities

> Bolt-on locomotion abilities -- dash, double jump, wall slide/jump, sprint with stamina, grapple hook, and swimming zones -- layered on top of the default Humanoid or ControllerManager character controller.

## Summary

Movement abilities extend the base character controller with context-specific locomotion. Each ability follows a common structure: **input detection** (key press, state change, zone entry), **physics application** (LinearVelocity, CFrame manipulation, BodyPosition), **state tracking** (cooldowns, counters, resource bars), and **cleanup** (destroy movers, reset state). All gameplay-affecting movement must be validated server-side to prevent exploits.

This page covers seven movement abilities commonly implemented in Roblox games, with complete code for each.

---

## 1. Dash (CFrame Impulse + Cooldown + I-Frames)

A short-distance burst of movement in the character's facing direction. Typically 15-25 studs over 0.2-0.3 seconds with a 1-3 second cooldown.

### Implementation

```lua
-- StarterCharacterScripts/DashAbility.client.lua
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local character = script.Parent
local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local DASH_DISTANCE = 20       -- studs
local DASH_DURATION = 0.2      -- seconds
local DASH_COOLDOWN = 1.5      -- seconds
local IFRAME_DURATION = 0.15   -- seconds of invulnerability

local lastDashTime = 0

local function dash()
    local now = tick()
    if now - lastDashTime < DASH_COOLDOWN then return end
    if humanoid.Health <= 0 then return end

    lastDashTime = now

    -- Direction: use MoveDirection if moving, otherwise LookVector
    local direction = humanoid.MoveDirection
    if direction.Magnitude < 0.1 then
        direction = rootPart.CFrame.LookVector
    end
    direction = Vector3.new(direction.X, 0, direction.Z).Unit

    -- Create LinearVelocity for consistent distance
    local attachment = Instance.new("Attachment")
    attachment.Parent = rootPart

    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Attachment0 = attachment
    linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linearVelocity.MaxForce = math.huge
    linearVelocity.VectorVelocity = direction * (DASH_DISTANCE / DASH_DURATION)
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVelocity.Parent = rootPart

    -- I-frames: fire remote to server for damage immunity
    local dashRemote = game.ReplicatedStorage:FindFirstChild("DashRemote")
    if dashRemote then
        dashRemote:FireServer()
    end

    task.delay(DASH_DURATION, function()
        linearVelocity:Destroy()
        attachment:Destroy()
    end)
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        dash()
    end
end)
```

**Server-side i-frames and validation:**

```lua
-- ServerScriptService/DashHandler.server.lua
local IFRAME_DURATION = 0.15
local DASH_COOLDOWN = 1.5

local lastDashTimes: {[Player]: number} = {}

local dashRemote = Instance.new("RemoteEvent")
dashRemote.Name = "DashRemote"
dashRemote.Parent = game.ReplicatedStorage

dashRemote.OnServerEvent:Connect(function(player: Player)
    local now = tick()
    local lastTime = lastDashTimes[player] or 0

    -- Rate limit
    if now - lastTime < DASH_COOLDOWN * 0.9 then return end
    lastDashTimes[player] = now

    -- Grant i-frames
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
    if not humanoid then return end

    -- Tag for i-frame check (other systems skip damage on tagged characters)
    local tag = Instance.new("BoolValue")
    tag.Name = "IFrameActive"
    tag.Value = true
    tag.Parent = character

    task.delay(IFRAME_DURATION, function()
        tag:Destroy()
    end)
end)
```

---

## 2. Double Jump (StateChanged Detection)

An additional mid-air jump triggered by pressing jump while in freefall. Uses `JumpRequest` and `StateChanged` for reliable detection across all devices.

### Implementation

```lua
-- StarterCharacterScripts/DoubleJump.client.lua
local UserInputService = game:GetService("UserInputService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local MAX_EXTRA_JUMPS = 1
local JUMP_MULTIPLIER = 1.2  -- extra jump is 1.2x normal height

local extraJumpsLeft = 0
local canBoost = false

-- Reset on landing
humanoid.StateChanged:Connect(function(_old: Enum.HumanoidStateType, new: Enum.HumanoidStateType)
    if new == Enum.HumanoidStateType.Landed then
        extraJumpsLeft = MAX_EXTRA_JUMPS
        canBoost = false
        humanoid.JumpPower = 50 -- reset to base
    elseif new == Enum.HumanoidStateType.Freefall then
        canBoost = true
    end
end)

-- Detect jump request (works on all platforms: keyboard, mobile, gamepad)
UserInputService.JumpRequest:Connect(function()
    if not canBoost then return end
    if extraJumpsLeft <= 0 then return end
    if humanoid:GetState() == Enum.HumanoidStateType.Landed then return end

    extraJumpsLeft -= 1
    humanoid.JumpPower = 50 * JUMP_MULTIPLIER
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)
```

**Key detail:** `JumpRequest` fires on all platforms (keyboard spacebar, mobile jump button, gamepad A-button). Using `InputBegan` for spacebar misses mobile and gamepad players.

---

## 3. Wall Slide (Raycast + Reduced Gravity)

The character slides slowly down a wall when pressing into it while airborne. Detected via raycasting in the move direction.

### Implementation

```lua
-- StarterCharacterScripts/WallSlide.client.lua
local RunService = game:GetService("RunService")

local character = script.Parent
local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local SLIDE_SPEED = -4         -- studs/s downward (normal fall is ~100+)
local WALL_DETECT_DISTANCE = 3 -- studs
local MIN_HEIGHT_FOR_SLIDE = 5 -- must be at least 5 studs above ground

local isSliding = false
local slideVelocity: LinearVelocity? = nil
local slideAttachment: Attachment? = nil

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {character}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function startSlide(wallNormal: Vector3)
    if isSliding then return end
    isSliding = true

    slideAttachment = Instance.new("Attachment")
    slideAttachment.Parent = rootPart

    slideVelocity = Instance.new("LinearVelocity")
    slideVelocity.Attachment0 = slideAttachment
    slideVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    slideVelocity.MaxForce = math.huge
    slideVelocity.VectorVelocity = Vector3.new(0, SLIDE_SPEED, 0)
    slideVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    slideVelocity.Parent = rootPart
end

local function stopSlide()
    if not isSliding then return end
    isSliding = false

    if slideVelocity then slideVelocity:Destroy() end
    if slideAttachment then slideAttachment:Destroy() end
    slideVelocity = nil
    slideAttachment = nil
end

RunService.Heartbeat:Connect(function()
    -- Only check while airborne
    if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
        stopSlide()
        return
    end

    -- Check height above ground
    local groundRay = workspace:Raycast(
        rootPart.Position,
        Vector3.new(0, -MIN_HEIGHT_FOR_SLIDE, 0),
        raycastParams
    )
    if groundRay then
        stopSlide()
        return
    end

    -- Raycast in move direction to detect wall
    local moveDir = humanoid.MoveDirection
    if moveDir.Magnitude < 0.1 then
        stopSlide()
        return
    end

    local wallRay = workspace:Raycast(
        rootPart.Position,
        moveDir.Unit * WALL_DETECT_DISTANCE,
        raycastParams
    )

    if wallRay then
        startSlide(wallRay.Normal)
    else
        stopSlide()
    end
end)

-- Stop on landing
humanoid.StateChanged:Connect(function(_, new: Enum.HumanoidStateType)
    if new == Enum.HumanoidStateType.Landed then
        stopSlide()
    end
end)
```

---

## 4. Wall Jump

Launches the character away from and upward off the wall. Typically combined with wall slide -- the player presses jump while sliding.

### Implementation (extends wall slide)

```lua
-- Add to WallSlide script
local WALL_JUMP_UP_FORCE = 600
local WALL_JUMP_OUT_FORCE = 400
local lastWallNormal: Vector3 = Vector3.zero

-- Modify startSlide to store wall normal
local function startSlide(wallNormal: Vector3)
    lastWallNormal = wallNormal
    -- ... rest of startSlide
end

UserInputService.JumpRequest:Connect(function()
    if not isSliding then return end

    stopSlide()

    -- Launch away from wall + upward
    local impulse = (lastWallNormal * WALL_JUMP_OUT_FORCE) + Vector3.new(0, WALL_JUMP_UP_FORCE, 0)
    rootPart:ApplyImpulse(impulse)

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end)
```

---

## 5. Sprint with Stamina

Hold shift to increase WalkSpeed. Stamina depletes while sprinting and moving; regenerates while idle or walking.

### Implementation

```lua
-- StarterCharacterScripts/Sprint.client.lua
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local camera = workspace.CurrentCamera

local BASE_SPEED = 16
local SPRINT_SPEED = 28
local STAMINA_MAX = 100
local DRAIN_RATE = 20          -- per second
local REGEN_RATE = 10          -- per second
local REGEN_DELAY = 1.5        -- seconds after stopping sprint
local SPRINT_FOV = 80
local NORMAL_FOV = 70

local stamina = STAMINA_MAX
local isSprinting = false
local lastSprintStop = 0

-- UI (assumes ScreenGui with a Frame named StaminaBar)
local staminaBar = script.Parent.Parent:WaitForChild("PlayerGui")
    :WaitForChild("StaminaHUD"):WaitForChild("StaminaBar") :: Frame

local function updateStaminaBar()
    TweenService:Create(staminaBar, TweenInfo.new(0.15), {
        Size = UDim2.new(stamina / STAMINA_MAX, 0, 1, 0)
    }):Play()
end

UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isSprinting = true
    end
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isSprinting = false
        lastSprintStop = tick()
    end
end)

RunService.Heartbeat:Connect(function(dt: number)
    local isMoving = humanoid.MoveDirection.Magnitude > 0.1

    if isSprinting and isMoving and stamina > 0 then
        -- Drain
        stamina = math.max(0, stamina - DRAIN_RATE * dt)
        humanoid.WalkSpeed = SPRINT_SPEED
        TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = SPRINT_FOV}):Play()

        if stamina <= 0 then
            isSprinting = false
            lastSprintStop = tick()
        end
    else
        -- Walk speed
        humanoid.WalkSpeed = BASE_SPEED
        TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = NORMAL_FOV}):Play()

        -- Regen after delay
        if tick() - lastSprintStop > REGEN_DELAY then
            stamina = math.min(STAMINA_MAX, stamina + REGEN_RATE * dt)
        end
    end

    updateStaminaBar()
end)
```

**Important:** Stamina drains only when `MoveDirection.Magnitude > 0` (player is actually moving). The common bug of draining while standing still holding shift is fixed by this check.

---

## 6. Grapple Hook (Beam + BodyPosition)

Pull the player toward a grapple point with a visual rope connecting them.

### Implementation

```lua
-- StarterCharacterScripts/GrappleHook.client.lua
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local character = script.Parent
local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local GRAPPLE_RANGE = 100     -- studs
local PULL_SPEED = 80         -- studs per second
local STOP_DISTANCE = 5       -- studs from target to release

local isGrappling = false

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {character}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function createBeam(startPart: BasePart, targetPosition: Vector3): (Beam, Attachment, Attachment, Part)
    -- Anchor point at target
    local anchorPart = Instance.new("Part")
    anchorPart.Size = Vector3.new(0.5, 0.5, 0.5)
    anchorPart.Position = targetPosition
    anchorPart.Anchored = true
    anchorPart.Transparency = 1
    anchorPart.CanCollide = false
    anchorPart.Parent = workspace

    local startAttach = Instance.new("Attachment")
    startAttach.Parent = startPart

    local endAttach = Instance.new("Attachment")
    endAttach.Parent = anchorPart

    local beam = Instance.new("Beam")
    beam.Attachment0 = startAttach
    beam.Attachment1 = endAttach
    beam.Width0 = 0.15
    beam.Width1 = 0.15
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(180, 180, 180))
    beam.Parent = startPart

    return beam, startAttach, endAttach, anchorPart
end

local function grapple()
    if isGrappling then return end

    -- Raycast from camera to find grapple target
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local result = workspace:Raycast(ray.Origin, ray.Direction * GRAPPLE_RANGE, raycastParams)
    if not result then return end

    isGrappling = true
    local targetPos = result.Position

    -- Visual beam
    local beam, startAttach, endAttach, anchorPart = createBeam(rootPart, targetPos)

    -- Pull via AlignPosition (modern replacement for BodyPosition)
    local attachment = Instance.new("Attachment")
    attachment.Parent = rootPart

    local alignPos = Instance.new("AlignPosition")
    alignPos.Attachment0 = attachment
    alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    alignPos.Position = targetPos
    alignPos.MaxForce = 50000
    alignPos.MaxVelocity = PULL_SPEED
    alignPos.Responsiveness = 30
    alignPos.Parent = rootPart

    -- Monitor distance; release when close
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        local dist = (rootPart.Position - targetPos).Magnitude
        if dist < STOP_DISTANCE or not isGrappling then
            connection:Disconnect()
            alignPos:Destroy()
            attachment:Destroy()
            beam:Destroy()
            startAttach:Destroy()
            endAttach:Destroy()
            anchorPart:Destroy()
            isGrappling = false
        end
    end)
end

UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E then
        grapple()
    end
end)
```

---

## 7. Swimming Zones

Custom swimming in part-based water volumes (not Terrain water). Detects player entry, applies buoyancy, and plays swim animations.

### Implementation

```lua
-- StarterCharacterScripts/SwimZone.client.lua
local RunService = game:GetService("RunService")

local character = script.Parent
local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local BUOYANCY_FORCE = 30
local SWIM_SPEED = 14
local SURFACE_OFFSET = 1  -- how far above water surface to float

local isSwimming = false
local swimAttachment: Attachment? = nil
local buoyancyForce: VectorForce? = nil

-- Tag water parts with CollectionService tag "SwimZone"
local CollectionService = game:GetService("CollectionService")

local function isInWater(): (boolean, BasePart?)
    -- Check overlap with tagged water parts
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {character}
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude

    local parts = workspace:GetPartsInPart(rootPart, overlapParams)
    for _, part in parts do
        if CollectionService:HasTag(part, "SwimZone") then
            return true, part
        end
    end
    return false, nil
end

local function enterSwim(waterPart: BasePart)
    if isSwimming then return end
    isSwimming = true

    humanoid.WalkSpeed = SWIM_SPEED

    swimAttachment = Instance.new("Attachment")
    swimAttachment.Parent = rootPart

    -- Buoyancy via VectorForce (upward force counteracting gravity)
    buoyancyForce = Instance.new("VectorForce")
    buoyancyForce.Attachment0 = swimAttachment
    buoyancyForce.Force = Vector3.new(0, rootPart.AssemblyMass * workspace.Gravity * 0.95, 0)
    buoyancyForce.RelativeTo = Enum.ActuatorRelativeTo.World
    buoyancyForce.Parent = rootPart

    -- Disable jumping while swimming
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

local function exitSwim()
    if not isSwimming then return end
    isSwimming = false

    humanoid.WalkSpeed = 16 -- restore default

    if buoyancyForce then buoyancyForce:Destroy() end
    if swimAttachment then swimAttachment:Destroy() end
    buoyancyForce = nil
    swimAttachment = nil

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
end

RunService.Heartbeat:Connect(function()
    local inWater, waterPart = isInWater()
    if inWater and waterPart then
        enterSwim(waterPart)

        -- Clamp to water surface
        local waterTop = waterPart.Position.Y + waterPart.Size.Y / 2
        if rootPart.Position.Y > waterTop - SURFACE_OFFSET then
            -- At surface; reduce upward velocity
            local vel = rootPart.AssemblyLinearVelocity
            if vel.Y > 0 then
                rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
            end
        end
    else
        exitSwim()
    end
end)
```

---

## Server Validation

All movement abilities need server-side checks. Common patterns:

| Ability | Server Check |
|---------|-------------|
| Dash | Rate-limit dash remote (match cooldown). Verify distance traveled matches expected dash distance within tolerance. |
| Double Jump | Validate jump count. Server tracks `FloorMaterial` to know if player is grounded. |
| Wall Slide | Verify player is near a wall (server raycast). Limit slide duration. |
| Sprint | Enforce max WalkSpeed on server. Compare actual distance traveled to max sprint speed. |
| Grapple | Verify grapple target exists and is within range. Limit grapple frequency. |
| Swimming | Verify player is inside a SwimZone tagged part before accepting swim state. |

General approach: the server maintains an authoritative position history and rejects movement that exceeds physically possible bounds.

## Pitfalls

1. **Using `InputBegan` for jump detection.** `InputBegan` with `Enum.KeyCode.Space` misses mobile and gamepad players. Use `UserInputService.JumpRequest` for cross-platform jump detection.

2. **Draining stamina while stationary.** Check `Humanoid.MoveDirection.Magnitude > 0` before draining stamina during sprint. Holding shift while standing still should not consume stamina.

3. **Stacking multiple LinearVelocity instances.** If a player dashes while wall-sliding, both movers fight. Implement a state machine that cleans up the previous ability's physics objects before activating the next.

4. **Forgetting to destroy physics objects.** LinearVelocity, AlignPosition, VectorForce, and Attachment instances leak memory if not destroyed after the ability ends. Always clean up in a `task.delay` or state-exit function.

5. **Client-only cooldowns.** Exploiters bypass client-side cooldown timers. Server must independently track and enforce cooldowns for every ability that fires a RemoteEvent.

6. **Swimming in rotated parts.** Part-based swimming systems that check Y-position for the water surface break when the water part is rotated. Restrict swim zones to axis-aligned parts or use more robust point-in-volume checks.

7. **Grapple through walls.** A grapple raycast from the camera can target points behind walls. Verify line-of-sight from the character position (not camera) to the grapple target before pulling.

## Related

- [[character-controller]] -- base movement system these abilities extend
- [[state-machine-pattern]] -- managing transitions between idle, dashing, sliding, sprinting, swimming states
- [[spawn-respawn-system]] -- resetting ability state on respawn

## Sources

- [How do I achieve a dash ability that moves a consistent distance each time](https://devforum.roblox.com/t/how-do-i-achieve-a-dash-ability-that-moves-a-consistent-distance-each-time/2305209) (DevForum, 2023)
- [Reliable Customisable Double Jump System](https://devforum.roblox.com/t/reliable-customisable-double-jump-system/1853471) (DevForum community resource, 2022)
- [Making wall jump and wall slide](https://devforum.roblox.com/t/making-wall-jump-and-wall-slide/1353049) (DevForum, 2021)
- [How to make a PROPER stamina/sprinting system](https://devforum.roblox.com/t/how-to-make-a-proper-staminasprinting-system/3001735) (DevForum, 2024)
- [[Updated] Free Sprint System](https://devforum.roblox.com/t/updated-free-sprint-system/1215024) (DevForum community resource)
- [Open source Sekiro grapple hook](https://devforum.roblox.com/t/open-source-sekiro-grapple-hook/438788) (DevForum, 2020)
- [Modular Swimming System](https://devforum.roblox.com/t/modular-swimming-system/2072322) (DevForum, 2022)
- [Creating a Wall Climbing System (With Wall Switching)](https://devforum.roblox.com/t/creating-a-wall-climbing-system-with-wall-switching/3645787) (DevForum tutorial)
- [Making a consistent dash ability that is affected by gravity](https://devforum.roblox.com/t/making-a-consistent-dash-ability-that-is-affected-by-gravity/3545916) (DevForum, 2025)
