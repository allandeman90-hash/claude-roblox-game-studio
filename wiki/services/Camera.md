---
title: Camera
type: service
category: services
subcategory: rendering
owner: luau-gameplay-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources: [wiki/raw/roblox-creator-docs/services/Camera.md]
related:
  - "[[Instance]]"
  - "[[Humanoid]]"
  - "[[Player]]"
tags: [roblox-class, camera, viewport, rendering]
---

# Camera

> Defines the client's view of the 3D world, controlling position, orientation, field of view, and camera behavior. [[Player]]

## Summary

Camera defines what the player sees. Each client has its own Camera object stored at `workspace.CurrentCamera`. The camera's CFrame determines the viewpoint position and orientation; CameraType and CameraSubject determine how the default camera scripts update the view each frame.

In the default configuration, the camera follows the local player's Humanoid with third-person/first-person behavior driven by scroll-wheel zoom. Setting CameraType to Scriptable disables all automatic camera control, giving scripts full authority over CFrame.

Camera also provides coordinate conversion methods (WorldToScreenPoint, WorldToViewportPoint, ScreenPointToRay, ViewportPointToRay) that are essential for UI targeting, mouse picking, and billboard positioning.

## API Surface

### Properties
- `CFrame: CFrame` -- Position and orientation of the camera in world space
- `CameraType: Enum.CameraType` -- Controls default camera script behavior (Custom, Scriptable, Attach, Watch, Track, Follow, Orbital)
- `CameraSubject: Instance?` -- The object the camera follows (typically the local Humanoid)
- `FieldOfView: number` -- Vertical FOV in degrees. Default 70
- `Focus: CFrame` -- Point the camera looks at (affects rendering quality/LOD near this point)
- `ViewportSize: Vector2` -- Screen resolution in pixels (read-only)
- `NearPlaneZ: number` -- Near clip plane distance (read-only)
- `MaxAxisFieldOfView: number` -- FOV along the longest viewport axis (useful for ultrawide)
- `DiagonalFieldOfView: number` -- Diagonal FOV

### Methods
- `:WorldToScreenPoint(worldPos: Vector3) -> (Vector3, boolean)` -- Converts world position to screen coordinates. Boolean indicates if point is in front of camera
- `:WorldToViewportPoint(worldPos: Vector3) -> (Vector3, boolean)` -- Like WorldToScreenPoint but accounts for GUI inset
- `:ScreenPointToRay(x: number, y: number, depth: number?) -> Ray` -- Creates a ray from screen coordinates into the world
- `:ViewportPointToRay(x: number, y: number, depth: number?) -> Ray` -- Like ScreenPointToRay but accounts for GUI inset
- `:GetRenderCFrame() -> CFrame` -- Returns the true render CFrame (includes VR head tracking)
- `:GetPartsObscuringTarget(castPoints: {Vector3}, ignoreList: {Instance}) -> {BasePart}` -- Returns parts between camera and target points
- `:Interpolate(endPos: CFrame, endFocus: CFrame, duration: number) -> ()` -- Smoothly tweens camera (deprecated -- use TweenService)

### Events
- `.InterpolationFinished:Connect(fn())` -- Fires when Interpolate completes (deprecated)

## Budgets and Limits

- **CameraType Scriptable**: When set to Scriptable, the default camera scripts do not update CFrame. Scripts must update it every frame (via RunService.RenderStepped or BindToRenderStep).
- **ViewportSize**: Read-only. Reflects the actual screen resolution which varies per device.
- **Focus accuracy**: Roblox uses the Focus property to determine rendering quality. Always set Focus to the point the player is looking at for best visual fidelity.

## Common Patterns

### Scriptable camera for cutscenes

```lua
-- LocalScript in StarterPlayerScripts
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

camera.CameraType = Enum.CameraType.Scriptable

local startCFrame = CFrame.new(0, 50, 0) * CFrame.Angles(-math.pi/2, 0, 0)
local endCFrame = CFrame.new(0, 10, 20) * CFrame.lookAt(Vector3.new(0, 10, 20), Vector3.new(0, 5, 0))

local duration = 3
local elapsed = 0

RunService.RenderStepped:Connect(function(dt)
    elapsed = math.min(elapsed + dt, duration)
    local alpha = elapsed / duration
    camera.CFrame = startCFrame:Lerp(endCFrame, alpha)
end)
```

### Mouse picking via ScreenPointToRay

```lua
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local function getMouseTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    return result
end
```

### Restoring default camera

```lua
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Custom
local humanoid = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
if humanoid then
    camera.CameraSubject = humanoid
end
```

## Pitfalls

- **Scriptable requires manual updates**: Setting CameraType to Scriptable without updating CFrame each frame results in a frozen view.
- **CameraSubject cannot be nil**: Setting CameraSubject to nil reverts it to the previous value silently.
- **WorldToScreenPoint vs ViewportPointToRay**: Screen coordinates include the top bar (CoreGui inset). Viewport coordinates exclude it. Use the matching pair (WorldToViewportPoint + ViewportPointToRay, or WorldToScreenPoint + ScreenPointToRay).
- **Multiple cameras destroyed**: When changing workspace.CurrentCamera to a new Camera, all other Cameras directly under workspace are destroyed. Store extra cameras in a Folder to preserve them.
- **Focus matters for rendering**: The Focus property affects texture streaming quality and LOD. If Focus is not set near the viewed area, textures may appear blurry.

## Related

- [[Instance]] -- base class
- [[Humanoid]] -- default CameraSubject for player characters
- [[Player]] -- each player's client has its own Camera

## Sources

- [Roblox Creator Docs](wiki/raw/roblox-creator-docs/services/Camera.md)
