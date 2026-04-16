---
title: building-placement-system
type: pattern
category: patterns
subcategory: building
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/3d-placement-system-tutorial.md
  - wiki/raw/community/articles/game-mechanics/grid-placement-snapping.md
  - wiki/raw/community/articles/game-mechanics/interior-building-system-guide.md
  - wiki/raw/community/articles/game-mechanics/plot-based-placement-system.md
related:
  - "[[inventory-pattern]]"
  - "[[DataStoreService]]"
  - "[[notification-system]]"
  - "[[lobby-system]]"
tags: [pattern, building, placement, grid, raycasting, plot]
---

# Building / Placement System

> Grid-based placement with ghost preview, raycast surface detection, rotation snapping, collision checking, server validation, and DataStore persistence.

## Summary

A building/placement system lets players position objects in the 3D world -- furniture in a house, blocks on an island, or walls in a base. The canonical Roblox pattern uses raycasting from the mouse to find the target surface, snaps the position to a grid, shows a transparent "ghost" preview that follows the cursor, validates placement on the server, and serializes the build to DataStore for persistence.

The system splits cleanly: the client handles preview rendering and input, while the server validates ownership, collision, and plot boundaries before creating the real object.

## Implementation

### Grid Snapping

Snap world positions to a grid so objects align neatly:

```lua
-- ReplicatedStorage/Shared/PlacementUtils.lua
local PlacementUtils = {}

local GRID_SIZE = 4  -- studs; adjust per game

function PlacementUtils.snap(value: number): number
    return math.floor((value / GRID_SIZE) + 0.5) * GRID_SIZE
end

function PlacementUtils.snapVector(v: Vector3): Vector3
    return Vector3.new(
        PlacementUtils.snap(v.X),
        PlacementUtils.snap(v.Y),
        PlacementUtils.snap(v.Z)
    )
end

return PlacementUtils
```

### Mouse Raycasting (Surface Detection)

Cast a ray from the camera through the mouse position to find where the player is pointing:

```lua
-- Client placement controller
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local function getMouseRayResult(filterInstances: {Instance}): RaycastResult?
    local mousePos = UserInputService:GetMouseLocation()
    local unitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = filterInstances
    params.FilterType = Enum.RaycastFilterType.Exclude

    return workspace:Raycast(unitRay.Origin, unitRay.Direction * 200, params)
end
```

### Ghost Preview (Transparent Clone)

The ghost is a semi-transparent clone of the object that follows the mouse. It exists only on the client.

```lua
local function createGhost(model: Model): Model
    local ghost = model:Clone()
    ghost.Name = "PlacementGhost"

    for _, part in ghost:GetDescendants() do
        if part:IsA("BasePart") then
            part.Transparency = 0.5
            part.CanCollide = false
            part.Anchored = true
            part.CastShadow = false
        end
    end

    ghost.Parent = workspace
    return ghost
end

local function updateGhostPosition(ghost: Model, targetCFrame: CFrame)
    if ghost.PrimaryPart then
        ghost:PivotTo(targetCFrame)
    end
end

local function setGhostValid(ghost: Model, isValid: boolean)
    local color = isValid and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 80, 80)
    for _, part in ghost:GetDescendants() do
        if part:IsA("BasePart") then
            part.Color = color
        end
    end
end
```

### Rotation Snapping

Rotate the placement object in 90-degree increments around the Y-axis:

```lua
local currentRotation = 0  -- degrees

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.R then
        currentRotation = (currentRotation + 90) % 360
    end
end)

local function getPlacementCFrame(position: Vector3, surfaceNormal: Vector3): CFrame
    local snapped = PlacementUtils.snapVector(position)
    return CFrame.new(snapped) * CFrame.Angles(0, math.rad(currentRotation), 0)
end
```

### Collision Checking

Before placing, verify the target volume is unoccupied:

```lua
local function isPlacementClear(cframe: CFrame, size: Vector3, ignoreList: {Instance}): boolean
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = ignoreList
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude

    local touching = workspace:GetPartBoundsInBox(cframe, size, overlapParams)
    return #touching == 0
end
```

### Plot Boundary Checking

If the game uses per-player plots, verify the object stays within bounds:

```lua
local function isInsidePlot(plotPart: BasePart, objectCFrame: CFrame, objectSize: Vector3): boolean
    -- Check all 8 corners of the object bounding box
    local halfSize = objectSize / 2
    local corners = {
        objectCFrame * CFrame.new( halfSize.X, 0,  halfSize.Z),
        objectCFrame * CFrame.new(-halfSize.X, 0,  halfSize.Z),
        objectCFrame * CFrame.new( halfSize.X, 0, -halfSize.Z),
        objectCFrame * CFrame.new(-halfSize.X, 0, -halfSize.Z),
    }

    local plotCFrame = plotPart.CFrame
    local plotSize = plotPart.Size / 2

    for _, corner in corners do
        local localPos = plotCFrame:PointToObjectSpace(corner.Position)
        if math.abs(localPos.X) > plotSize.X or math.abs(localPos.Z) > plotSize.Z then
            return false
        end
    end
    return true
end
```

### Client Input Loop

Update the ghost every frame based on mouse position. Use `InputChanged` instead of `Heartbeat` for better performance (only recast when the mouse moves):

```lua
local ghost: Model? = nil
local selectedItem: string? = nil

UserInputService.InputChanged:Connect(function(input)
    if not ghost or not selectedItem then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

    local result = getMouseRayResult({ghost, player.Character})
    if not result then return end

    local placementCF = getPlacementCFrame(result.Position, result.Normal)
    updateGhostPosition(ghost, placementCF)

    local objectSize = ghost:GetExtentsSize()
    local valid = isPlacementClear(placementCF, objectSize, {ghost})
    -- Optional: check plot boundary too
    setGhostValid(ghost, valid)
end)
```

### Server Validation

The client sends the requested placement; the server re-validates everything before creating the real object:

```lua
-- ServerScriptService/PlacementHandler.server.lua
local PlaceRemote = ReplicatedStorage.Remotes.PlaceObject

PlaceRemote.OnServerEvent:Connect(function(player, itemId: string, cframe: CFrame)
    -- 1. Validate types
    if typeof(itemId) ~= "string" or typeof(cframe) ~= "CFrame" then return end

    -- 2. Validate the player owns this item
    local inventory = PlayerDataService.getData(player).inventory
    if not inventory[itemId] or inventory[itemId] <= 0 then return end

    -- 3. Validate the item exists in the catalog
    local itemDef = ItemCatalog[itemId]
    if not itemDef then return end

    -- 4. Validate CFrame is on the player's plot
    local plot = getPlayerPlot(player)
    if not plot then return end
    if not isInsidePlot(plot.Boundary, cframe, itemDef.Size) then return end

    -- 5. Validate no collision
    if not isPlacementClear(cframe, itemDef.Size, {}) then return end

    -- 6. Place the object
    local model = itemDef.Template:Clone()
    model:PivotTo(cframe)
    model.Parent = plot.ObjectsFolder

    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = true
        end
    end

    -- 7. Deduct from inventory
    inventory[itemId] -= 1

    -- 8. Record placement for DataStore save
    table.insert(plot.PlacedObjects, {
        itemId = itemId,
        cframe = {cframe:GetComponents()},  -- serialize to numbers
    })
end)
```

### Serialization (DataStore Persistence)

CFrame cannot be stored directly in DataStore. Serialize to component numbers:

```lua
-- Save
local function serializePlacement(itemId: string, cf: CFrame): {}
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return {
        id = itemId,
        cf = {x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22},
    }
end

-- Load
local function deserializePlacement(data: {}): (string, CFrame)
    local c = data.cf
    return data.id, CFrame.new(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12])
end
```

## Data Schema

```lua
-- Per-player placement data (inside DataStore profile)
plotData = {
    plotId = "plot_A3",
    placements = {
        -- array of placed objects
        { id = "wooden_table", cf = {10, 4, 20, 1, 0, 0, 0, 1, 0, 0, 0, 1} },
        { id = "red_chair",    cf = {12, 4, 20, 0, 0, 1, 0, 1, 0, -1, 0, 0} },
    },
}
```

## Pitfalls

- **Client ghost is cosmetic only**: The ghost preview exists solely on the client for UX. The server never trusts the client's placement decision; it re-validates position, collision, ownership, and boundary.
- **Raycast filter list**: Always exclude the player's character and the ghost model from the raycast, or the ray will hit the ghost instead of the world surface.
- **`Enum.RaycastFilterType.Blacklist` is deprecated**: Use `Enum.RaycastFilterType.Exclude` in new code.
- **Model primary part required**: `PivotTo` needs a `PrimaryPart` set on the model. Without it, placement positioning is undefined.
- **CFrame serialization size**: Storing 12 floats per object adds up. For large builds (1000+ objects), consider rounding to reduce JSON size, or store only position + rotation index if using 90-degree snaps.
- **Object category matters**: Floor objects snap to the ground plane; wall objects snap to walls via surface normal detection. The interior building system guide categorizes objects as FLOOR, WALL, CEILING, and DECORATIVE, each with its own placement function.
- **Mobile input**: Touch devices do not have a continuous mouse position. Use `UserInputService.TouchMoved` and `Camera:ViewportPointToRay` for touch equivalents.
- **Undo/redo**: Production systems need an undo stack. Store a history of placement actions and allow reversal.

## Related

- [[inventory-pattern]] -- items must be in inventory before placement
- [[DataStoreService]] -- persistence of placed objects
- [[notification-system]] -- feedback when placement succeeds/fails
- [[lobby-system]] -- plot assignment on join

## Sources

- [Starting a 3D Placement System](wiki/raw/community/articles/game-mechanics/3d-placement-system-tutorial.md) -- DevForum tutorial with raycasting and grid snapping
- [Grid Placement System](wiki/raw/community/articles/game-mechanics/grid-placement-snapping.md) -- DevForum snapping math and collision approaches
- [Interior Building System Guide](wiki/raw/community/articles/game-mechanics/interior-building-system-guide.md) -- DevForum guide with category-based placement and server validation
- [Plot-Based Placement System](wiki/raw/community/articles/game-mechanics/plot-based-placement-system.md) -- DevForum boundary detection and surface snapping
- [DevForum: Starting a 3D Placement System](https://devforum.roblox.com/t/starting-a-3d-placement-system/1417860)
- [DevForum: Grid Placement System](https://devforum.roblox.com/t/how-to-make-a-grid-placement-system-closed/2723673)
- [DevForum: Plot Based Placement System](https://devforum.roblox.com/t/plot-based-placement-system-boundary-detection-and-surface-snapping/3619986)
- [DevForum: Interior Building System Guide](https://devforum.roblox.com/t/an-interior-building-system-guide/759289)
