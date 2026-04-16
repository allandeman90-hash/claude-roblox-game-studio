---
title: Viewmodel System
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/fps-first-person-element-egomoose.md
  - wiki/raw/community/articles/game-mechanics/fps-framework-2020.md
  - wiki/raw/community/articles/game-mechanics/easy-first-person-viewmodel.md
  - wiki/raw/community/articles/game-mechanics/gun-sway-recoil-systems.md
  - wiki/raw/community/articles/game-mechanics/ads-aim-down-sights.md
related:
  - "[[first-person-framework]]"
  - "[[fps-weapon-system]]"
  - "[[first-person-interaction]]"
  - "[[state-machine-pattern]]"
tags: [pattern, viewmodel, first-person, arms, camera-space, sway, bob, ADS, animation, Motor6D]
---

# Viewmodel System

> The "arms in camera space" pattern: a separate Model containing arms and weapon geometry is parented to the camera and updated every RenderStepped, providing the first-person visual independent of the actual player character.

## Summary

The viewmodel is the defining visual element of any first-person game on Roblox. It is a client-only Model containing arm meshes and weapon geometry, parented to `workspace.CurrentCamera`. Each frame, the viewmodel's root CFrame is set to the camera's CFrame plus a configurable offset. The viewmodel uses an `AnimationController` (not a `Humanoid`) to play animations, and relies on Motor6D joints for arm-to-weapon attachment. Sway, bob, sprint, and ADS transitions are layered on top via CFrame math and spring modules.

The server never sees the viewmodel. Other players see the real character's third-person weapon model, driven by replicated animations. The viewmodel exists purely for local visual feedback.

## Architecture

```
workspace.CurrentCamera
  |
  +-- Viewmodel (Model)
        |-- HumanoidRootPart (PrimaryPart, anchored)
        |-- Head (invisible, used as joint parent)
        |-- LeftUpperArm, LeftLowerArm, LeftHand
        |-- RightUpperArm, RightLowerArm, RightHand
        |-- AnimationController
        |-- [Weapon parts cloned at equip time]
        |
        Motor6D tree:
          Head -> LeftShoulder -> LeftUpperArm -> LeftElbow -> ...
          Head -> RightShoulder -> RightUpperArm -> RightElbow -> ...
          Head -> WeaponJoint -> Weapon.Handle
```

### Offset Stack

The final viewmodel CFrame each frame is a product of layered offsets:

```
finalCFrame = camera.CFrame
    * hipOffset           -- base weapon position (per-weapon config)
    * aimOffset           -- lerped toward aim position when ADS
    * swayOffset          -- mouse-delta-driven lag
    * bobOffset           -- walk cycle sine wave
    * recoilOffset        -- spring-driven kick from firing
    * sprintOffset        -- lowered/tilted when sprinting
    * equipOffset         -- lerped during equip animation
```

## Implementation

### 1. Viewmodel Creation and Camera Attachment

```lua
-- StarterPlayerScripts/ViewmodelController.client.lua
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local camera = workspace.CurrentCamera

-- Clone the viewmodel rig from storage
local viewmodel = ReplicatedStorage:WaitForChild("Viewmodel"):Clone()
viewmodel.Parent = camera

-- AnimationController for viewmodel animations (not Humanoid)
local animController = viewmodel:FindFirstChildOfClass("AnimationController")
    or Instance.new("AnimationController", viewmodel)

-- The core update loop
RunService.RenderStepped:Connect(function(dt)
    local finalOffset = computeFinalOffset(dt)
    viewmodel:PivotTo(camera.CFrame * finalOffset)
end)
```

### 2. Weapon Attachment via Motor6D

When a weapon is equipped, its parts are cloned into the viewmodel and connected via a Motor6D joint:

```lua
local function equipWeapon(weaponName: string)
    -- Clean previous weapon
    local oldJoint = viewmodel.Head:FindFirstChild("WeaponJoint")
    if oldJoint then oldJoint:Destroy() end

    local weaponModel = ReplicatedStorage.Weapons:FindFirstChild(weaponName):Clone()
    for _, part in weaponModel:GetChildren() do
        part.Parent = viewmodel
    end

    -- Create Motor6D: Head -> Weapon Handle
    local joint = Instance.new("Motor6D")
    joint.Name = "WeaponJoint"
    joint.Part0 = viewmodel.Head
    joint.Part1 = weaponModel.Handle
    joint.C0 = weaponConfig.jointOffset -- per-weapon tuning CFrame
    joint.Parent = viewmodel.Head
end
```

### 3. Arm Positioning via Shoulder Joints

Arms are positioned so hands grip the weapon's designated grip points:

```lua
local function updateArm(side: string) -- "Left" or "Right"
    local shoulder = viewmodel[side .. "UpperArm"][side .. "Shoulder"]
    local gripCF = currentWeapon[side .. "Grip"].CFrame
    -- Rotate from grip orientation to shoulder space
    local targetCF = gripCF * CFrame.Angles(math.pi / 2, 0, 0) * CFrame.new(0, 1.5, 0)
    shoulder.C1 = targetCF:Inverse() * shoulder.Part0.CFrame * shoulder.C0
end
```

### 4. Sway (Mouse Delta)

Sway adds a lagging rotation based on how fast the player moves the mouse, creating a weighty feel:

```lua
local UIS = game:GetService("UserInputService")
local swayOffset = CFrame.new()
local lastCameraCF = camera.CFrame

local SWAY_AMOUNT = 1       -- multiplier
local SWAY_SMOOTH = 0.1     -- lerp alpha (lower = smoother)

local function updateSway(dt: number): CFrame
    local rotation = camera.CFrame:ToObjectSpace(lastCameraCF)
    local rx, ry, rz = rotation:ToOrientation()
    local target = CFrame.Angles(
        math.sin(rx) * SWAY_AMOUNT,
        math.sin(ry) * SWAY_AMOUNT,
        0
    )
    swayOffset = swayOffset:Lerp(target, SWAY_SMOOTH)
    lastCameraCF = camera.CFrame
    return swayOffset
end
```

**Spring-based alternative** (recommended for production): Use a spring module for more natural, physics-driven sway with overshoot and damping:

```lua
local swaySprings = {
    x = Spring.new(0), -- horizontal
    y = Spring.new(0), -- vertical
}

local function updateSwaySprings(dt: number): CFrame
    local delta = UIS:GetMouseDelta()
    swaySprings.x:Impulse(delta.X / 200)
    swaySprings.y:Impulse(delta.Y / 200)
    return CFrame.Angles(
        swaySprings.y:Update(dt),
        swaySprings.x:Update(dt),
        0
    )
end
```

### 5. Walk Bob (Sine Wave)

A sine wave on movement speed creates the rhythmic head/weapon bob:

```lua
local BOB_SPEED = 10        -- oscillation frequency
local BOB_AMOUNT = 0.05     -- vertical displacement (studs)
local BOB_TILT = 0.02       -- rotational roll (radians)
local bobTimer = 0

local function updateBob(dt: number, speed: number): CFrame
    if speed < 1 then
        -- Lerp back to zero when standing still
        bobTimer = 0
        return CFrame.new()
    end

    bobTimer += dt * BOB_SPEED * (speed / 16) -- 16 = default WalkSpeed
    local sinVal = math.sin(bobTimer)
    local cosVal = math.cos(bobTimer)

    return CFrame.new(sinVal * BOB_AMOUNT, math.abs(cosVal) * BOB_AMOUNT, 0)
        * CFrame.Angles(0, 0, sinVal * BOB_TILT)
end
```

### 6. ADS (Aim Down Sights) Transition

ADS lerps the viewmodel from its hip offset to an aim offset where the weapon's sight aligns with the camera center. FOV is tweened simultaneously for a zoom effect.

```lua
local TweenService = game:GetService("TweenService")

local aimAlpha = Instance.new("NumberValue") -- 0 = hip, 1 = ADS
local ADS_TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ADS_FOV = 45
local HIP_FOV = 70

local function setADS(aiming: boolean)
    local goal = aiming and 1 or 0
    TweenService:Create(aimAlpha, ADS_TWEEN_INFO, { Value = goal }):Play()

    -- FOV tween
    TweenService:Create(camera, ADS_TWEEN_INFO, {
        FieldOfView = aiming and ADS_FOV or HIP_FOV,
    }):Play()
end

-- In the update loop:
local function computeAimOffset(): CFrame
    local hipCF = weaponConfig.hipOffset
    local aimCF = weaponConfig.aimOffset -- CFrame that puts sight at camera center
    return hipCF:Lerp(aimCF, aimAlpha.Value)
end
```

The `aimOffset` is derived from the weapon's `AimPart`:

```lua
-- Compute aim offset from weapon AimPart at equip time
local aimPartOffset = weaponModel.Handle.CFrame:Inverse() * weaponModel.AimPart.CFrame
weaponConfig.aimOffset = weaponConfig.hipOffset * aimPartOffset:Inverse()
```

### 7. Sprint Animation Blending

During sprint, the viewmodel lowers and tilts. Sway and bob amplitudes increase:

```lua
local SPRINT_OFFSET = CFrame.new(0.3, -0.3, 0.2)
    * CFrame.Angles(math.rad(-15), math.rad(20), math.rad(-10))
local sprintAlpha = Instance.new("NumberValue")

local function setSprinting(sprinting: boolean)
    TweenService:Create(sprintAlpha, TweenInfo.new(0.3), {
        Value = sprinting and 1 or 0,
    }):Play()
end

-- In update loop:
local sprintCF = CFrame.new():Lerp(SPRINT_OFFSET, sprintAlpha.Value)
```

### 8. Animations via AnimationController

Viewmodel animations use `AnimationController:LoadAnimation()`, not a Humanoid. This avoids conflicts with the character's Humanoid state:

```lua
local idleTrack = animController:LoadAnimation(weaponConfig.idleAnim)
local fireTrack = animController:LoadAnimation(weaponConfig.fireAnim)
local reloadTrack = animController:LoadAnimation(weaponConfig.reloadAnim)
local equipTrack = animController:LoadAnimation(weaponConfig.equipAnim)

idleTrack:Play()
idleTrack.Looped = true
idleTrack.Priority = Enum.AnimationPriority.Idle

-- On fire:
fireTrack:Play()
fireTrack:GetMarkerReachedSignal("EjectCasing"):Connect(function()
    -- spawn casing particle
end)
```

## Server vs Client Split

| Component | Side | Notes |
|---|---|---|
| Viewmodel Model | Client only | Never replicated; parented to Camera |
| Viewmodel animations | Client only | AnimationController, not Humanoid |
| Sway / Bob / Recoil visuals | Client only | Cosmetic CFrame math |
| ADS state | Client (visual), Server (gameplay) | Server tracks ADS for spread/speed modifiers |
| Weapon equip/unequip | Server authoritative | Server clones weapon, fires event to client |
| Third-person weapon model | Server replicated | Visible to all other players |

## Performance Notes

- **RenderStepped budget**: The viewmodel update (PivotTo + offset math + spring updates) should take under 0.3ms. Profile with MicroProfiler label "ViewmodelUpdate".
- **Triangle count**: Keep viewmodel under 5,000 triangles. Arms are very close to the camera; every polygon counts.
- **AnimationController vs Humanoid**: AnimationController has no physics overhead (no State Machine, no MoveDirection), making it cheaper per frame.
- **Spring module choice**: Lightweight spring modules (e.g., a single Luau module with `position`, `velocity`, `damping`, `speed` fields) are preferred over physics-based springs using BodyMovers.
- **Cleanup on death/leave**: Destroy the viewmodel when the character dies or the player leaves. Use `Humanoid.Died` and `Players.PlayerRemoving` connections cleaned via Trove.

## Pitfalls

1. **Using Humanoid on viewmodel** -- Humanoid introduces physics, state management, and death logic. Use AnimationController for viewmodel-only rigs.
2. **Forgetting to cancel ADS tween** -- When the player dies or switches weapons mid-ADS, the tween continues on a destroyed model. Track and cancel active tweens.
3. **SetPrimaryPartCFrame instead of PivotTo** -- `SetPrimaryPartCFrame` is deprecated. Use `Model:PivotTo()`.
4. **Not multiplying by deltaTime** -- Sway, bob, and spring updates must multiply by dt for frame-rate independence. Without this, behavior changes with FPS Unlocker users.
5. **Viewmodel clipping into walls** -- The viewmodel occupies camera space. When the player walks into a wall, arms pass through. Mitigations: scale down the viewmodel and position near the camera near-plane, or use a ViewportFrame (expensive).
6. **Stale lastCameraCF** -- If the camera teleports (e.g., respawn), `lastCameraCF` causes a single-frame sway spike. Reset it on character spawn.

## Related

- [[first-person-framework]] -- overall FP architecture
- [[fps-weapon-system]] -- weapon fire, reload, recoil
- [[first-person-interaction]] -- interaction in FP games
- [[state-machine-pattern]] -- state machines for equip/fire/reload states

## Sources

- [The First Person Element of a First Person Shooter (EgoMoose, DevForum)](https://devforum.roblox.com/t/the-first-person-element-of-a-first-person-shooter/160434)
- [Writing an FPS Framework (2020, DevForum)](https://devforum.roblox.com/t/writing-an-fps-framework-2020/503318)
- [EasyFirstPerson: Drag-and-Drop Viewmodels (DevForum)](https://devforum.roblox.com/t/easyfirstperson-drag-and-drop-first-person-view-models/1198782)
- [Gun Sway and Recoil Discussion (DevForum)](https://devforum.roblox.com/t/how-does-gun-sway-work-how-would-recoil-work-any-tips-ideas-or-suggestions/641434)
- [Understanding Gun Sway with math.sin (DevForum)](https://devforum.roblox.com/t/help-on-understanding-gun-sway-script-with-mathsin/2185564)
- [ADS Viewmodel Help (DevForum)](https://devforum.roblox.com/t/help-with-ads-aim-down-sights-viewmodel/1793985)
- [First Person Viewmodel Plugin (DevForum)](https://devforum.roblox.com/t/first-person-viewmodel-pluginfree/2669460)
