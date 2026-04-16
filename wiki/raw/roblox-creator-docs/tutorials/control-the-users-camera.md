---
title: Control the User's Camera
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/input-and-camera/control-the-users-camera
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, camera, runservice, cframe, localscript, camera-mode, side-scroller, isometric]
difficulty: intermediate
---

# Control the User's Camera

The user's view of the world is represented by a `Camera` object. You can change the camera behavior to suit your experience in a variety of ways. For example, the camera can react to events in the world, such as shaking when a monster walks by, or locked to the side of the user character, as in a side-scroller.

## Steps

### Create a first-person camera

A first-person camera is a view where the camera stays locked with the character's head.

In Studio, the `StarterPlayer` object contains properties that affect the user's camera. The **CameraMode** property determines how the camera behaves.

1. Select **StarterPlayer**.
2. Change CameraMode to **LockFirstPerson**.
3. Playtest to see the first person camera in action.

> If your cursor is stuck in the middle of the screen while testing, press **Escape** to free the mouse, or **Shift+F5** to end the test.

### Create a side-scrolling camera

A side-scrolling view keeps the camera at a fixed position relative to the side of the character.

**Script the camera:**

1. Expand StarterPlayer, and in StarterPlayerScripts add a **LocalScript** named `CameraManager`.
2. Get the Players service and local player:

```lua
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function updateCamera()

end
```

> Only a user can see their own camera configuration, so it is always controlled using `LocalScript`.

3. Inside the function, get the character model and check it exists:

```lua
local function updateCamera()
    local character = player.Character
    if character then

    end
end
```

**Point the camera:**

All character models contain a `HumanoidRootPart`, which can be used to get the character's position. The HumanoidRootPart's position is 2 studs below the user's head, so add a height offset.

```lua
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local HEIGHT_OFFSET = 2

local function updateCamera()
    local character = player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local rootPosition = root.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
        end
    end
end
```

**Set the camera position:**

For a side-scrolling look, place the camera to the side by adding depth to the Z axis.

```lua
local CAMERA_DEPTH = 24
local HEIGHT_OFFSET = 2

local function updateCamera()
    local character = player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local rootPosition = root.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
            local cameraPosition = Vector3.new(rootPosition.X, rootPosition.Y, CAMERA_DEPTH)
        end
    end
end
```

**Update CurrentCamera:**

Access the user's camera through `workspace.CurrentCamera`. Use `CFrame.lookAt()` to create a CFrame at the first position pointed towards the second.

```lua
local camera = workspace.CurrentCamera

local function updateCamera()
    local character = player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local rootPosition = root.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
            local cameraPosition = Vector3.new(rootPosition.X, rootPosition.Y, CAMERA_DEPTH)
            camera.CFrame = CFrame.lookAt(cameraPosition, rootPosition)
        end
    end
end
```

**Sync the camera:**

Run this function repeatedly to keep the camera in sync. `RunService:BindToRenderStep()` executes a function on every frame:

- `name` — Unique name for this binding
- `priority` — Higher = later; should be **after** Roblox's default camera update
- `function` — The callback to bind

```lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local CAMERA_DEPTH = 24
local HEIGHT_OFFSET = 2

local function updateCamera()
    local character = player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local rootPosition = root.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
            local cameraPosition = Vector3.new(rootPosition.X, rootPosition.Y, CAMERA_DEPTH)
            camera.CFrame = CFrame.lookAt(cameraPosition, rootPosition)
        end
    end
end

RunService:BindToRenderStep("SidescrollingCamera", Enum.RenderPriority.Camera.Value + 1, updateCamera)
```

### Create an isometric camera

An isometric camera is a 3D view pointing slightly down at a fixed angle. The basic structure is the same — only the camera position calculation changes.

**Modify position and view:**

```lua
local function updateCamera()
    local character = player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local rootPosition = root.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
            local cameraPosition = rootPosition + Vector3.new(CAMERA_DEPTH, CAMERA_DEPTH, CAMERA_DEPTH)
            camera.CFrame = CFrame.lookAt(cameraPosition, rootPosition)
        end
    end
end

RunService:BindToRenderStep("IsometricCamera", Enum.RenderPriority.Camera.Value + 1, updateCamera)
```

Setting the camera's `FieldOfView` property to `20` gives a flatter look — combine with greater CAMERA_DEPTH to compensate:

```lua
camera.FieldOfView = 20
```

## Key Concepts

- **StarterPlayer.CameraMode**: Global default camera behavior (LockFirstPerson, etc.)
- **workspace.CurrentCamera**: The local player's active camera
- **Camera.CFrame**: Position AND orientation of the camera
- **`CFrame.lookAt(from, to)`**: Creates a CFrame at `from` pointed at `to`
- **HumanoidRootPart**: Character's root; position is 2 studs below head
- **`RunService:BindToRenderStep(name, priority, fn)`**: Runs callback each frame
- **`Enum.RenderPriority.Camera`**: Priority after default camera update
- **LocalScript only**: Camera control is per-client

## Notes

- Always use LocalScript for camera control
- Bind camera updates to render step, not Heartbeat, for smooth visuals
- Use priority **above** `Enum.RenderPriority.Camera` to override default
- HumanoidRootPart position is 2 studs below head — add offset
- `FieldOfView` controls zoom (lower = more zoomed in)

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/input-and-camera/control-the-users-camera
Captured: 2026-04-16
