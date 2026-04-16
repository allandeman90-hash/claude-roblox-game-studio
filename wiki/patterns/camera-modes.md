---
title: Camera Modes
type: pattern
category: patterns
subcategory: camera
owner: luau-gameplay-programmer
status: draft
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/camera/third-person-camera-tutorial-devforum.md
  - wiki/raw/community/articles/camera/third-person-camera-system-devforum.md
  - wiki/raw/community/articles/camera/isometric-camera-devforum.md
  - wiki/raw/community/articles/camera/cutscene-camera-tutorial-devforum.md
  - wiki/raw/community/articles/camera/first-third-person-toggle-devforum.md
related:
  - "[[constraints-guide]]"
  - "[[ui-framework-comparison]]"
  - "[[responsive-design]]"
tags: [camera, first-person, third-person, isometric, top-down, cutscene, CFrame, TweenService]
---

# Camera Modes

> Camera behavior defines how the player perceives the game world. Roblox provides built-in camera types and full CFrame access for custom implementations.

## What It Is

A catalog of camera modes commonly used in Roblox games, with implementation patterns for each. The camera is a client-side concept -- all camera manipulation runs in LocalScripts.

## When to Use It

Every game needs a camera strategy. The default Roblox camera (Classic mode) works for many games, but custom camera behavior is needed for shooters, RPGs, strategy games, cutscenes, and any experience requiring a specific perspective.

## Built-In Camera Types

Roblox's `Camera.CameraType` enum provides several modes:

| CameraType | Behavior |
|------------|----------|
| **Custom** | Default. Player-controlled orbit around character. |
| **Scriptable** | Fully manual. Developer controls CFrame every frame. |
| **Follow** | Follows character with slight lag. |
| **Fixed** | Stationary camera at a fixed point. |
| **Attach** | Attached to a part, follows its CFrame. |
| **Watch** | Stationary, rotates to watch a subject. |
| **Track** | Follows subject along its movement axis. |
| **Orbital** | Orbits a fixed point. |

For custom implementations, set `Camera.CameraType = Enum.CameraType.Scriptable` and update `Camera.CFrame` every frame via `RunService.RenderStepped`.

## Implementation Patterns

### First-Person Camera

Lock the camera to the character's head. Roblox provides a built-in mode:

```lua
local player = game:GetService("Players").LocalPlayer
player.CameraMode = Enum.CameraMode.LockFirstPerson
```

This automatically:
- Locks camera to head position
- Hides the character model (head only)
- Locks mouse to screen center
- Removes zoom capability

**Custom first-person** (more control):

```lua
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    local head = character:FindFirstChild("Head")
    if head then
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = head.CFrame
    end
end)
```

### Third-Person Camera (Over-the-Shoulder)

Two approaches:

#### Approach 1: Scriptable Camera (Full Control)

```lua
local Camera = workspace.CurrentCamera
local CameraAngleX, CameraAngleY = 0, 0
local CameraOffset = Vector3.new(1, 3, 9.5)  -- right, up, back

RunService.RenderStepped:Connect(function()
    Camera.CameraType = Enum.CameraType.Scriptable
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local startCFrame = CFrame.new(rootPart.Position)
        * CFrame.Angles(0, math.rad(CameraAngleX), 0)
        * CFrame.Angles(math.rad(CameraAngleY), 0, 0)

    local cameraCFrame = startCFrame:ToWorldSpace(CFrame.new(CameraOffset))
    local focusPoint = startCFrame:ToWorldSpace(CFrame.new(CameraOffset.X, CameraOffset.Y, -10000))

    Camera.CFrame = CFrame.new(cameraCFrame.Position, focusPoint.Position)
end)

-- Mouse input for rotation
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        CameraAngleX = CameraAngleX - input.Delta.X
        CameraAngleY = math.clamp(CameraAngleY - input.Delta.Y, -75, 75)
    end
end)
```

#### Approach 2: CameraOffset (Non-Invasive)

Uses `Humanoid.CameraOffset` to shift the default camera without replacing it:

```lua
local ThirdPersonCamera = require(ReplicatedFirst.ThirdPersonCamera)

local function CharacterAdded(character)
    local camera = ThirdPersonCamera.new(character)
    character:WaitForChild("Humanoid").Died:Once(function()
        camera:Destroy()
    end)
end
player.CharacterAdded:Connect(CharacterAdded)
```

**Advantages**: Works alongside Roblox's built-in camera, gets collision handling for free, spring-based smooth motion.

### Isometric / Top-Down Camera

Fixed-angle camera looking down at the character. Movement input is remapped relative to camera direction.

```lua
local CAMERA_DEPTH = 64
local HEIGHT_OFFSET = 25

RunService.RenderStepped:Connect(function()
    Camera.CameraType = Enum.CameraType.Scriptable
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        local rootPos = root.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
        local cameraPos = rootPos + Vector3.new(CAMERA_DEPTH, CAMERA_DEPTH, CAMERA_DEPTH)
        Camera.CFrame = CFrame.lookAt(cameraPos, rootPos)
    end
end)
```

**Movement remapping**: When using isometric cameras, WASD must move relative to camera direction, not world axes. Project camera's look vector onto the ground plane to determine "forward":

```lua
local cameraLook = Camera.CFrame.LookVector
local forward = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
local right = Vector3.new(forward.Z, 0, -forward.X)
-- Use forward/right for movement direction calculation
```

**Alternative**: Customize Roblox's OrbitalCamera module for built-in input handling across all platforms.

### First-Person / Third-Person Toggle

Allow players to switch perspectives via a keybind:

```lua
local isFirstPerson = true

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.V then
        isFirstPerson = not isFirstPerson
        if isFirstPerson then
            player.CameraMode = Enum.CameraMode.LockFirstPerson
        else
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMinZoomDistance = 8
            player.CameraMaxZoomDistance = 8
        end
    end
end)
```

**Critical**: Lock zoom distance when in third-person to prevent the character becoming invisible at certain distances.

### Cutscene Camera

Cinematic camera sequences using TweenService to animate between waypoints:

```lua
local TweenService = game:GetService("TweenService")

local scenes = {
    {
        InitialOffset = CFrame.new(5, 3, 10) * CFrame.Angles(0, math.rad(-30), 0),
        EndOffset = CFrame.new(-2, 1, 5),
        TweenInfo = TweenInfo.new(5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
        Delay = 1,
    },
    -- Additional scenes...
}

local function playCutscene(anchor: BasePart, sceneList: {any})
    local camera = workspace.CurrentCamera
    local savedType = camera.CameraType
    camera.CameraType = Enum.CameraType.Scriptable

    for _, scene in ipairs(sceneList) do
        camera.CFrame = anchor.CFrame:ToWorldSpace(scene.InitialOffset)
        local endCFrame = anchor.CFrame:ToWorldSpace(scene.EndOffset)

        local tween = TweenService:Create(camera, scene.TweenInfo, {
            CFrame = endCFrame,
        })
        tween:Play()
        tween.Completed:Wait()
        task.wait(scene.Delay)
    end

    camera.CameraType = savedType  -- ALWAYS restore
end
```

**Capturing waypoints in Studio**: Position the camera, then run in command bar:
```lua
print(anchorPart.CFrame:ToObjectSpace(workspace.CurrentCamera.CFrame))
```

**Easing styles for cutscenes**:
- Cubic/Quart: cinematic acceleration/deceleration
- Sine: gentle, subtle movement
- Linear: mechanical, constant speed

## Variants

| Game Type | Recommended Camera | Notes |
|-----------|-------------------|-------|
| FPS/Shooter | First-person or OTS third-person | Lock mouse center, add recoil shake |
| RPG/Adventure | Third-person orbit | Default Roblox camera often sufficient |
| Strategy/Tycoon | Top-down or isometric | Remap movement to camera-relative |
| Horror | Fixed camera angles | Use cutscene system for cinematic tension |
| Racing | Follow camera | Attach to vehicle with offset |
| Platformer | Side-scroll fixed or orbit | Constrain horizontal movement |

## Pitfalls

- Forgetting to restore `Camera.CameraType` after cutscenes locks the player out of camera control.
- Scriptable camera without collision detection clips through walls. Add raycasting to pull camera forward when obstructed.
- Processing camera transforms in input events causes jitter. Always update camera in `RenderStepped`.
- Not clamping vertical angle allows the camera to flip upside down. Clamp Y rotation to approximately -75 to 75 degrees.
- Isometric camera without movement remapping makes WASD controls feel wrong relative to the visual perspective.
- Ignoring `GameProcessedEvent` in input handlers causes camera switches during chat typing or menu interaction.

## Related

- [[constraints-guide]]
- [[ui-framework-comparison]]
- [[responsive-design]]

## Sources

- [3rd Person Camera Tutorial](wiki/raw/community/articles/camera/third-person-camera-tutorial-devforum.md)
- [Non-Invasive Third-Person Camera System](wiki/raw/community/articles/camera/third-person-camera-system-devforum.md)
- [Isometric Camera Scripting](wiki/raw/community/articles/camera/isometric-camera-devforum.md)
- [Camera Cutscene Tutorial](wiki/raw/community/articles/camera/cutscene-camera-tutorial-devforum.md)
- [First/Third Person Toggle](wiki/raw/community/articles/camera/first-third-person-toggle-devforum.md)
