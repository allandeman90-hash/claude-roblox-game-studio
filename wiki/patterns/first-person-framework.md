---
title: First-Person Framework
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
  - wiki/raw/community/articles/game-mechanics/fps-framework-beginners-guide.md
  - wiki/raw/community/articles/game-mechanics/first-person-mode-system.md
  - wiki/raw/community/articles/game-mechanics/fps-tutorial-part1.md
related:
  - "[[viewmodel-system]]"
  - "[[fps-weapon-system]]"
  - "[[first-person-interaction]]"
  - "[[first-person-horror]]"
  - "[[camera-modes]]"
  - "[[combat-system]]"
tags: [pattern, first-person, fps, camera, viewmodel, CameraMode, input, replication]
---

# First-Person Framework

> An architectural overview of building first-person experiences on Roblox, covering camera locking, body hiding, viewmodel rendering, input handling, and the client-server split for all player actions.

## Summary

A first-person framework on Roblox consists of four interlocking layers: (1) camera management that locks the player into a head-attached perspective, (2) character body handling that hides the local player's mesh while keeping it visible to others, (3) a [[viewmodel-system]] that renders separate camera-space arms and weapons only the local player can see, and (4) input routing that feeds mouse, touch, and gamepad data into the viewmodel and sends authoritative actions to the server.

The server never renders a viewmodel. It receives action intents (fire, reload, interact) and validates them against authoritative state (ammo, cooldowns, health). The client predicts immediate feedback (muzzle flash, recoil shake, animation) and reconciles with server confirmations.

## Architecture

```
Client (LocalScript)                     Server (Script)
  |                                        |
  |  Camera: LockFirstPerson               |
  |  Character body: Transparent            |
  |  Viewmodel: arms + weapon in cam space  |
  |                                        |
  |-- RenderStepped ---------------------->|  (viewmodel update, sway, bob)
  |                                        |
  |-- UserInputService ------------------->|  (mouse, touch, gamepad)
  |       |                                |
  |       |-- "FireWeapon" RemoteEvent --->|  Server validates:
  |       |   (origin, direction)          |  - Player alive?
  |       |                                |  - Ammo > 0?
  |       |                                |  - Cooldown expired?
  |       |                                |  - Origin near character?
  |       |                                |  - Rate limit OK?
  |       |                                |
  |       |                                |-- Raycast / FastCast
  |       |                                |-- Apply damage
  |       |                                |-- Replicate to others
  |       |                                |
  |<------| "FireFeedback" Remote ---------|  (confirmed hit/miss)
  |                                        |
  |-- Tilt replication (0.1s interval) --->|  Server updates Neck/Waist C0
  |                                        |  for other players to see tilt
```

## Implementation

### 1. Camera Lock

The simplest approach uses Roblox's built-in `CameraMode`:

```lua
-- LocalScript in StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Method 1: Property (works immediately if character exists)
player.CameraMode = Enum.CameraMode.LockFirstPerson

-- Method 2: StarterPlayer property (set in Studio or via script)
-- game.StarterPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
```

For a custom camera (e.g., DOORS-style smooth camera with head bob), set `CameraType` to `Scriptable` and drive the CFrame manually:

```lua
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable

local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")

RunService.RenderStepped:Connect(function(dt)
    local headCF = head.CFrame
    -- Add head bobbing (sine wave on movement velocity)
    local velocity = character.HumanoidRootPart.AssemblyLinearVelocity
    local speed = Vector2.new(velocity.X, velocity.Z).Magnitude
    local bobAmount = math.sin(workspace.DistributedGameTime * 10) * speed * 0.001
    camera.CFrame = headCF * CFrame.new(0, bobAmount, 0)
end)
```

### 2. Character Body Hiding

When `CameraMode` is `LockFirstPerson`, Roblox automatically makes the local player's `BasePart` instances invisible (sets `LocalTransparencyModifier` to 1). No extra code is needed for basic first person.

For custom cameras, hide the body manually:

```lua
local function hideBodyParts(character: Model)
    for _, part in character:GetDescendants() do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        end
    end
end

-- Detect first-person state
local function isFirstPerson(): boolean
    local head = character:FindFirstChild("Head")
    return head and head.LocalTransparencyModifier == 1
end
```

Accessories are hidden for the local player only -- other players still see the full avatar. This is built into the engine when using `LockFirstPerson`.

### 3. Viewmodel Attachment

The viewmodel is a separate Model (arms + weapon) parented to `workspace.CurrentCamera`, updated every `RenderStepped`. See [[viewmodel-system]] for full details.

```lua
local viewModel = game.ReplicatedStorage.Viewmodel:Clone()
viewModel.Parent = workspace.CurrentCamera

RunService.RenderStepped:Connect(function(dt)
    viewModel.PrimaryPart.CFrame = camera.CFrame * hipOffset
end)
```

### 4. Input Handling

First-person input routes through `UserInputService` and `ContextActionService`:

```lua
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

-- Mouse look is handled automatically by LockFirstPerson
-- For custom camera, capture mouse delta:
UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
local mouseDelta = UIS:GetMouseDelta() -- per frame in RenderStepped

-- Gamepad: right stick controls camera via built-in system
-- Touch: built-in touch camera handles rotation

-- Action bindings
CAS:BindAction("Fire", function(_, state)
    if state == Enum.UserInputState.Begin then
        weaponHandler:fire(true)
    elseif state == Enum.UserInputState.End then
        weaponHandler:fire(false)
    end
end, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

CAS:BindAction("ADS", function(_, state)
    weaponHandler:aim(state == Enum.UserInputState.Begin)
end, false, Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2)
```

### 5. Server Tilt Replication

Other players need to see where the first-person player is looking vertically. The client sends tilt angle at a throttled rate; the server applies it to Neck and Waist Motor6Ds:

```lua
-- Client: fire tilt every 0.1s (not every frame)
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
local lastTiltTime = 0

RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - lastTiltTime < 0.1 then return end
    lastTiltTime = now
    local theta = math.asin(camera.CFrame.LookVector.Y)
    Remotes.TiltAt:FireServer(theta)
end)
```

```lua
-- Server: apply tilt to character joints (visible to other players)
local NECK_C0_BASE = CFrame.new(0, 1, 0) -- cache the default
local WAIST_C0_BASE = CFrame.new(0, 0, 0)

Remotes.TiltAt.OnServerEvent:Connect(function(player: Player, theta: number)
    if typeof(theta) ~= "number" then return end
    theta = math.clamp(theta, -math.pi/2, math.pi/2)

    local character = player.Character
    if not character then return end

    local neck = character:FindFirstChild("Head") and character.Head:FindFirstChild("Neck")
    local waist = character:FindFirstChild("UpperTorso")
        and character.UpperTorso:FindFirstChild("Waist")

    if neck then
        neck.C0 = NECK_C0_BASE * CFrame.fromEulerAnglesYXZ(theta * 0.5, 0, 0)
    end
    if waist then
        waist.C0 = WAIST_C0_BASE * CFrame.fromEulerAnglesYXZ(theta * 0.5, 0, 0)
    end
end)
```

The tilt is split 50/50 between neck and waist for natural appearance.

## Server vs Client Split

| Responsibility | Owner | Why |
|---|---|---|
| Camera CFrame, FOV | Client | Rendering only; no gameplay impact |
| Viewmodel rendering | Client | Visual-only; invisible to server |
| Sway, bob, recoil visuals | Client | Cosmetic feedback |
| Tilt angle broadcast | Client -> Server | Server replicates to other players |
| Fire/Reload/Interact intent | Client -> Server | Server validates and executes |
| Ammo count, cooldowns | Server | Anti-cheat; client cannot grant ammo |
| Hit detection, damage | Server | Server-authoritative; see [[combat-system]] |
| Weapon equip state | Server | Prevents equip exploits |

## Performance Notes

First-person rendering is more expensive than third-person because the viewmodel is very close to the camera, meaning every polygon is at full detail. Key budgets:

- **RenderStepped callback**: Keep viewmodel update under 0.5ms. Avoid creating instances or heavy math in the update loop.
- **Viewmodel triangle count**: Keep arms + weapon under 5,000 triangles. The viewmodel fills a large portion of the screen.
- **Motor6D count**: Minimize joints on the viewmodel. Each Motor6D is solved per frame.
- **Tilt remote**: Fire at 10 Hz (every 0.1s), not every frame. This is 600 messages/min, well within the remote budget.
- **Spring updates**: Springs (for sway/recoil) are cheap but multiply with weapon count. Update only the equipped weapon.

## Pitfalls

1. **Not throttling tilt replication** -- Firing a RemoteEvent every RenderStepped (60+ times/sec) wastes bandwidth. Throttle to 10 Hz.
2. **Trusting client hit detection** -- The client can predict hits for visual feedback, but the server must perform the authoritative raycast. Never apply damage from client data alone.
3. **Forgetting BindToClose cleanup** -- If weapons are stored in server state tables, clean them up when the player leaves.
4. **Viewmodel clipping** -- The viewmodel can clip through walls because it occupies camera space. Solutions include ViewportFrame isolation (expensive) or scaling the viewmodel down and positioning it close to the camera near-plane.
5. **SetPrimaryPartCFrame deprecation** -- Use `PivotTo()` instead of `SetPrimaryPartCFrame()` for positioning the viewmodel. The latter is deprecated and slower.
6. **CameraMode toggle delay** -- Switching from Classic to LockFirstPerson does not instantly snap the camera; the engine smoothly zooms in. For instant transitions, set `CameraMinZoomDistance` and `CameraMaxZoomDistance` both to 0.5.

## Related

- [[viewmodel-system]] -- camera-space arms rendering in detail
- [[fps-weapon-system]] -- fire, reload, recoil, spread mechanics
- [[first-person-interaction]] -- interaction systems for FP games
- [[first-person-horror]] -- horror-specific FP patterns
- [[camera-modes]] -- all Roblox camera modes
- [[combat-system]] -- server-authoritative combat flow

## Sources

- [The First Person Element of a First Person Shooter (EgoMoose, DevForum)](https://devforum.roblox.com/t/the-first-person-element-of-a-first-person-shooter/160434)
- [Writing an FPS Framework (2020, DevForum)](https://devforum.roblox.com/t/writing-an-fps-framework-2020/503318)
- [Designing an FPS Framework: Beginner's Guide (DevForum)](https://devforum.roblox.com/t/designing-an-fps-framework-beginners-guide/1198208)
- [First Person Mode V1.1 (DevForum)](https://devforum.roblox.com/t/first-person-mode-v11/1888136)
- [FPS Tutorial Part 1 (DevForum)](https://devforum.roblox.com/t/fps-tutorial-part-1/1013047)
- [Control the User's Camera (Roblox Creator Hub)](https://create.roblox.com/docs/tutorials/use-case-tutorials/input-and-camera/control-the-users-camera)
