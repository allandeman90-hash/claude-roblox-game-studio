---
title: "Grid Placement System - Snapping and Collision"
source_url: "https://devforum.roblox.com/t/how-to-make-a-grid-placement-system-closed/2723673"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: building-placement
---

# Grid Placement System

## Grid Snapping Function

```lua
local grid_size = 4

function snap(x)
    return math.floor((x / grid_size) + 0.5) * grid_size
end

function snapVector(v)
    return Vector3.new(snap(v.X), snap(v.Y), snap(v.Z))
end
```

## Mouse Hit Offset

Prevent parts being placed inside surfaces:

```lua
local TranslatedCFrame = Mouse.Hit * Vector3.new(0, 0, 0.0001)
```

Alternative: Use surface normals to calculate proper placement orientation on irregular surfaces.

## Collision Detection

Two recommended approaches:
1. Raycasts / Shapecasts
2. `GetPartBoundsInBox()` function

## Community Resources

- "Creating A Furniture Placement System" tutorial by EgoMoose
- Placement Service module with YouTube series
- Grid placement is considered a "very advanced topic" requiring understanding of raycasting, collision detection, and coordinate mathematics
