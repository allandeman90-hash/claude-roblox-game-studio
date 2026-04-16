---
title: "Interior Building System Guide"
source_url: "https://devforum.roblox.com/t/an-interior-building-system-guide/759289"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: building-placement
---

# Interior Building System Guide

## Object Categories

Objects classified as FLOOR, WALL, CEILING, and DECORATIVE with distinct placement rules.

## Object Setup

- `ObjectType` string value (category classification)
- `isObject` boolean (identification)
- `Color3` value (for recoloring feedback)

## Client-Side Selection

```lua
button.MouseButton1Click:Connect(function()
    if placing.Value == false and button:FindFirstChild("AssignedObject").Value then
        selectedObject = button:FindFirstChild("AssignedObject").Value
        objectType = (selectedObject.Parent.Name)
        replicatedStorage.Client.Bindables.PlaceGhost:Fire(selectedObject, objectType)
        placing.Value = true
    end
end)
```

## Category-Specific Placement

```lua
local objectOptions = {
    ["FLOOR"] = function() checkMouseSurface("FLOOR") end,
    ["WALL"] = function() checkMouseSurface("WALL") end,
}
```

Uses raycasting instead of Mouse API for surface normal detection.

## Server-Side Confirmation

```lua
replicatedStorage.Client.Remotes.PlaceObject.OnServerInvoke = function(player, object, objectType, objectPosition, canPlace)
    if canPlace then
        local newObject = object:Clone()
        newObject.Parent = workspace.PlayerObjects:FindFirstChild(objectType)
        newObject:SetPrimaryPartCFrame(objectPosition)
        for _, child in pairs(newObject:GetChildren()) do
            if child:IsA("BasePart") then child.CanCollide = true end
        end
        return true
    end
end
```

## Serialization

Save tables containing object names and CFrame data to DataStore, then reconstruct on load by cloning from asset storage and restoring CFrames.
