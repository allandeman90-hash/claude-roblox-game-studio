---
title: "Starting a 3D Placement System"
source_url: "https://devforum.roblox.com/t/starting-a-3d-placement-system/1417860"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: building-placement
---

# 3D Placement System Tutorial

## Input Handling

Three keybinds for placement control:
- **E**: Toggle building mode on/off
- **R**: Rotate 90 degrees on Y-axis
- **T**: Rotate 90 degrees on Z-axis

```lua
userInputService.InputBegan:Connect(function(input, inGui)
    if inGui then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.E then
        -- Toggle build mode
    elseif key == Enum.KeyCode.R then
        -- Rotate Y-axis
    elseif key == Enum.KeyCode.T then
        -- Rotate Z-axis
    end
end)
```

## Grid Snapping (0.5-unit)

Position calculation snaps to 0.5 using floor operations and offsets using the surface normal for flush placement.

## Raycasting

```lua
local params = RaycastParams.new()
params.FilterDescendantsInstances = {player.Character, currentObject}
params.FilterType = Enum.RaycastFilterType.Blacklist
local unitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y)
return workspace:Raycast(unitRay.Origin, unitRay.Direction * 200, params)
```

## Model Requirements

- Model requires a primary part (sized with whole numbers)
- Primary part should have CanCollide disabled
- The part centers and encompasses the entire model

## Performance Tip

Use InputChanged event for mouse movement rather than Heartbeat; raycast only when the mouse moves.
