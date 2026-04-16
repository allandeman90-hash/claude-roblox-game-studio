---
title: "Plant Growth and Farming Code Patterns"
source_url: "https://devforum.roblox.com/t/how-to-do-the-farmingsmelting-system-like-in-sky-block/592994"
captured_by: mechanics-misc
captured_date: 2026-04-15
topic: farming-system
---

# Plant Growth System

## Growth Function

```lua
local Plant = script.Parent
local WaitInterval = 10 -- 10 Seconds per count
local PlantGrown = false
local PlantName = "AppleTree"
local PlantPercentage = Plant.Size.Y / 1.5

local function GrowPlant(Plant, PlantName, WaitInterval, PlantGrown, PlantPercentage)
    if PlantGrown == false and PlantName == "AppleTree" then
        repeat
            wait(WaitInterval)
            PlantPercentage = PlantPercentage + 20
            Plant.Size = Vector3.new(Plant.Size.X, Plant.Size.Y + 1/5, Plant.Size.Z)
        until PlantPercentage == 100
        Plant.Size = Vector3.new(Plant.Size.X, math.ceil(Plant.Size.Y), Plant.Size.Z)
    end
end
```

## Tick-Based Growth Check

```lua
if Plants[i] - tick() >= TIME_LIMIT then
    plant.Grown = true
end
```

## Best Practices

- Store crop data in tables with growth counters that increment over time intervals
- Avoid simultaneous loops for all plants
- Use a "chunk system" to group calculations and prevent server lag with numerous crops
