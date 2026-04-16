---
title: First-Person Interaction
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/interaction-proximityprompt-vs-custom.md
  - wiki/raw/community/articles/game-mechanics/flashlight-systems.md
  - wiki/raw/community/articles/game-mechanics/first-person-mode-system.md
  - wiki/raw/community/articles/game-mechanics/weapon-switching-system.md
related:
  - "[[first-person-framework]]"
  - "[[viewmodel-system]]"
  - "[[first-person-horror]]"
  - "[[inventory-pattern]]"
tags: [pattern, first-person, interaction, proximity-prompt, raycast, pickup, flashlight, door, inventory]
---

# First-Person Interaction

> Interaction systems for first-person games: crosshair-based raycasting, ProximityPrompt integration, object pickup/drop, flashlight, doors, item inspection, and inventory quick-select.

## Summary

First-person interaction differs from third-person because the player's intent is communicated through the camera center (crosshair), not by clicking on visible world objects from an offset perspective. The camera's LookVector becomes the primary interaction ray. Two approaches dominate: (1) custom raycasting from the camera center with per-frame checks, and (2) `ProximityPrompt` with `Style = Custom` and `RequiresLineOfSight = true`, leveraging the engine's built-in detection while overlaying custom UI. The hybrid approach -- ProximityPrompt for detection, custom UI for display -- offers the best balance of performance and control.

## Implementation

### 1. Crosshair Raycast Interaction

The simplest first-person interaction: cast a ray from the camera center each frame and highlight interactable objects:

```lua
-- StarterPlayerScripts/InteractionController.client.lua
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local INTERACT_RANGE = 10 -- studs
local currentTarget: BasePart? = nil
local highlight: Highlight? = nil

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude

local function updateInteractionRay()
    local character = player.Character
    if not character then return end
    params.FilterDescendantsInstances = { character }

    local origin = camera.CFrame.Position
    local direction = camera.CFrame.LookVector * INTERACT_RANGE
    local result = workspace:Raycast(origin, direction, params)

    local newTarget = nil
    if result then
        local part = result.Instance
        -- Walk up to find an interactable model
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model:GetAttribute("Interactable") then
            newTarget = model
        end
    end

    if newTarget ~= currentTarget then
        -- Remove old highlight
        if highlight then highlight:Destroy() end
        highlight = nil

        currentTarget = newTarget
        if currentTarget then
            highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.8
            highlight.OutlineColor = Color3.fromRGB(255, 255, 100)
            highlight.Adornee = currentTarget
            highlight.Parent = currentTarget
        end
    end
end

RunService.RenderStepped:Connect(updateInteractionRay)

-- Interact on key press
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonX then
        if currentTarget then
            local Remotes = require(game.ReplicatedStorage.Shared.Remotes)
            Remotes.Interact:FireServer(currentTarget)
        end
    end
end)
```

### 2. ProximityPrompt Hybrid (Recommended)

Use ProximityPrompt for engine-level detection with custom crosshair-based UI:

```lua
-- ProximityPrompt setup (in each interactable object)
local prompt = Instance.new("ProximityPrompt")
prompt.Style = Enum.ProximityPromptStyle.Custom -- hide default UI
prompt.RequiresLineOfSight = true
prompt.MaxActivationDistance = 8
prompt.Parent = interactablePart
```

```lua
-- Client: custom prompt display (shows only when crosshair aligns)
local ProximityPromptService = game:GetService("ProximityPromptService")

local activePrompts: {[ProximityPrompt]: boolean} = {}

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
    activePrompts[prompt] = true
    -- Show custom UI element at screen center
    showCrosshairPrompt(prompt.ObjectText, prompt.ActionText)
end)

ProximityPromptService.PromptHidden:Connect(function(prompt)
    activePrompts[prompt] = nil
    if next(activePrompts) == nil then
        hideCrosshairPrompt()
    end
end)

-- Optional: filter to crosshair proximity
ProximityPromptService.PromptShown:Connect(function(prompt)
    local promptPos = prompt.Parent.Position
    local screenPos, onScreen = camera:WorldToViewportPoint(promptPos)
    if not onScreen then return end

    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
    if distFromCenter < 100 then -- pixels from crosshair
        showCrosshairPrompt(prompt)
    end
end)
```

### 3. Object Pickup and Drop

Carrying objects in first person uses WeldConstraint + NetworkOwnership transfer:

```lua
-- Server: handle pickup request
Remotes.PickupObject.OnServerEvent:Connect(function(player: Player, target: Model)
    if typeof(target) ~= "Instance" or not target:IsA("Model") then return end
    if not target:GetAttribute("Pickupable") then return end

    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Validate distance
    local rootPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end
    if (rootPart.Position - head.Position).Magnitude > 12 then return end

    -- Check not already held
    if target:GetAttribute("HeldBy") then return end
    target:SetAttribute("HeldBy", player.UserId)

    -- Transfer network ownership to the holding player
    rootPart:SetNetworkOwner(player)

    -- Notify client to attach
    Remotes.ObjectPickedUp:FireClient(player, target)
end)
```

```lua
-- Client: attach held object in front of camera
local heldObject: Model? = nil
local holdWeld: WeldConstraint? = nil

Remotes.ObjectPickedUp.OnClientEvent:Connect(function(target: Model)
    heldObject = target
    local rootPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")

    -- Position in front of camera
    rootPart.CFrame = camera.CFrame * CFrame.new(0, -0.5, -3)

    -- Weld to character HumanoidRootPart
    local hrp = player.Character.HumanoidRootPart
    holdWeld = Instance.new("WeldConstraint")
    holdWeld.Part0 = hrp
    holdWeld.Part1 = rootPart
    holdWeld.Parent = rootPart
end)

-- Drop on key press
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G and heldObject then
        Remotes.DropObject:FireServer(heldObject)
        if holdWeld then holdWeld:Destroy() end
        heldObject = nil
    end
end)
```

### 4. Flashlight

A flashlight attached to the camera/character with toggle and smooth following:

```lua
-- Client: flashlight controller
local flashlightEnabled = false
local spotLight = Instance.new("SpotLight")
spotLight.Brightness = 3
spotLight.Range = 60
spotLight.Angle = 45
spotLight.Face = Enum.NormalId.Front
spotLight.Enabled = false

-- Attach to a part that follows camera direction
local lightAnchor = Instance.new("Part")
lightAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
lightAnchor.Transparency = 1
lightAnchor.CanCollide = false
lightAnchor.Anchored = true
spotLight.Parent = lightAnchor
lightAnchor.Parent = workspace.CurrentCamera

local LIGHT_SMOOTH = 0.15 -- lower = smoother lag

RunService.RenderStepped:Connect(function()
    if flashlightEnabled then
        -- Smooth follow with slight delay for realism
        local targetCF = camera.CFrame * CFrame.new(0.5, -0.3, 0)
        lightAnchor.CFrame = lightAnchor.CFrame:Lerp(targetCF, LIGHT_SMOOTH)
    end
end)

CAS:BindAction("Flashlight", function(_, state)
    if state == Enum.UserInputState.Begin then
        flashlightEnabled = not flashlightEnabled
        spotLight.Enabled = flashlightEnabled
    end
end, false, Enum.KeyCode.F, Enum.KeyCode.ButtonB)
```

### 5. Door Opening

Interactive doors use a raycast check + server-validated state toggle:

```lua
-- Server: door handler
local doorStates: {[Model]: boolean} = {} -- true = open

Remotes.InteractDoor.OnServerEvent:Connect(function(player: Player, door: Model)
    if typeof(door) ~= "Instance" or not door:IsA("Model") then return end
    if not door:GetAttribute("IsDoor") then return end

    -- Distance check
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if (hrp.Position - door.PrimaryPart.Position).Magnitude > 10 then return end

    -- Toggle state
    local isOpen = doorStates[door] or false
    doorStates[door] = not isOpen

    -- Tween the door hinge
    local TweenService = game:GetService("TweenService")
    local hinge = door:FindFirstChild("Hinge") -- Part with HingeConstraint
    local goalAngle = (not isOpen) and 90 or 0
    TweenService:Create(hinge, TweenInfo.new(0.5), {
        CFrame = hinge.CFrame * CFrame.Angles(0, math.rad(goalAngle), 0),
    }):Play()
end)
```

### 6. Item Inspection (Rotate in Front of Camera)

Hold an item in front of the camera and rotate it with mouse drag for examination:

```lua
-- Client: inspection mode
local inspecting = false
local inspectModel: Model? = nil
local inspectAngleX, inspectAngleY = 0, 0

local function startInspection(model: Model)
    inspecting = true
    inspectModel = model:Clone()
    inspectModel.Parent = workspace.CurrentCamera
    UIS.MouseBehavior = Enum.MouseBehavior.Default -- unlock mouse
end

RunService.RenderStepped:Connect(function()
    if inspecting and inspectModel then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local delta = UIS:GetMouseDelta()
            inspectAngleX += delta.X * 0.01
            inspectAngleY += delta.Y * 0.01
        end
        inspectModel:PivotTo(
            camera.CFrame * CFrame.new(0, 0, -2)
                * CFrame.Angles(inspectAngleY, inspectAngleX, 0)
        )
    end
end)
```

### 7. Inventory Wheel / Quick-Select

A radial menu for weapon or item selection:

```lua
-- Client: inventory wheel (simplified)
local wheelOpen = false

CAS:BindAction("InventoryWheel", function(_, state)
    if state == Enum.UserInputState.Begin then
        wheelOpen = true
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        showRadialUI() -- show ScreenGui with radial segments
    elseif state == Enum.UserInputState.End then
        wheelOpen = false
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        local selected = getSelectedSegment() -- based on mouse angle from center
        hideRadialUI()
        if selected then
            Remotes.EquipWeapon:FireServer(selected)
        end
    end
end, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonL1)
```

## Server vs Client Split

| Component | Side | Notes |
|---|---|---|
| Interaction raycast (highlight) | Client | Visual feedback only |
| Interaction trigger (E key) | Client -> Server | Server validates proximity and state |
| Pickup NetworkOwnership | Server | Only server can call SetNetworkOwner |
| Object holding position | Client | Cosmetic; weld is physics |
| Flashlight visual | Client | SpotLight in camera space; other players do not see it |
| Door state | Server | Authoritative open/closed |
| Inventory selection | Client -> Server | Server validates equip request |

## Performance Notes

- **Raycast per frame**: One 10-stud ray per RenderStepped is negligible. Do not add per-frame raycasts for every interactable object; use one camera-center ray and check what it hits.
- **ProximityPrompt vs custom**: ProximityPrompt detection is handled by the engine (C++ side) and is more efficient than Lua-side distance checks for large numbers of interactable objects.
- **Highlight count**: Creating/destroying Highlight instances each frame causes GC pressure. Reuse a single Highlight and re-parent its Adornee.
- **NetworkOwnership transfer**: Changing network owner is not instant and causes a brief physics hiccup. Use for pickup/drop, not for continuous updates.

## Pitfalls

1. **Not validating interaction distance on server** -- The client can fire the Interact remote for any object. Always check distance server-side.
2. **ProximityPrompt PromptShown firing twice** -- When multiple prompts overlap, PromptShown fires for each. Track active prompts in a table and show UI for the closest one.
3. **Held object physics jitter** -- WeldConstraint between character and held object can jitter. Set the held part to `Massless = true` and `CanCollide = false` for smoother behavior.
4. **Flashlight on other players** -- A camera-parented SpotLight is only visible to the local player. For multiplayer visibility, replicate a separate light attached to the character model.
5. **Mouse unlock during inspection** -- When entering inspection mode, unlock the mouse (`MouseBehavior.Default`). Re-lock it when exiting. Forgetting to re-lock breaks camera control.

## Related

- [[first-person-framework]] -- overall FP architecture
- [[viewmodel-system]] -- weapon viewmodel rendering
- [[first-person-horror]] -- horror-specific interaction patterns
- [[inventory-pattern]] -- broader inventory management

## Sources

- [ProximityPrompts vs Custom Interaction (DevForum)](https://devforum.roblox.com/t/proximityprompts-vs-custom-interaction-mechanic/2400536)
- [Advanced Flashlight Module (DevForum)](https://devforum.roblox.com/t/advanced-flashlight-horror-game/1972508)
- [A Moving Flashlight Tutorial (DevForum)](https://devforum.roblox.com/t/a-moving-flashlight/2521276)
- [IK Flashlight for Horror Games (DevForum)](https://devforum.roblox.com/t/inverse-kinematics-flashlight-horror-game-feedback/2624202)
- [FPS Weapon Switching System (DevForum)](https://devforum.roblox.com/t/fps-weapon-switching-system/3225625)
- [First Person Mode V1.1 (DevForum)](https://devforum.roblox.com/t/first-person-mode-v11/1888136)
