---
title: Create a Health Pickup
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/intermediate-scripting/create-a-health-pickup
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, scripting, ipairs, attributes, debounce, touched, humanoid, folder, waitforchild]
difficulty: intermediate
---

# Create a Health Pickup

Throughout the Basic Scripting tutorials, you have scripted individual parts to create playable scenes. With the previous method, if you were to duplicate the parts you would then also have duplicate scripts.

In this tutorial, a different pattern will be used to create a number of health pickups, with only a single copy of the script which determines the health pickup behavior. When the pickup is touched, it will restore the player's health, fade slightly and be disabled for a short period of time.

## Steps

### Set up

First up, you'll need a part or a model to use as a pickup. Each health pickup is stored in one folder in the Workspace called **HealthPickups**, which is where the script will look for them. If you add any more to the map, it's essential you ensure that they are also stored in this folder.

### Restore health

1. In **ServerScriptService**, add a script called **PickupManager**.
2. Declare a constant `MAX_HEALTH = 100`.
3. Create a function `onTouchHealthPickup` with parameters for the other part and the pickup itself.

```lua
local MAX_HEALTH = 100

local function onTouchHealthPickup(otherPart, healthPickup)
    local character = otherPart.Parent
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid.Health = MAX_HEALTH
    end
end
```

> The code calls `FindFirstChildWhichIsA()` — which takes the **type** of the object desired — instead of `FindFirstChild()` which only takes the name. This is a safer option as it can only ever return a Humanoid instead of something which just happens to be called "Humanoid".

### Get the pickups folder

The folder holding the health pickups may not have loaded into the experience by the time the script runs. `WaitForChild` can be used to pause the script and get the HealthPickups folder when it loads.

```lua
local MAX_HEALTH = 100

local healthPickupsFolder = workspace:WaitForChild("HealthPickups")
local healthPickups = healthPickupsFolder:GetChildren()

local function onTouchHealthPickup(otherPart, healthPickup)
    local character = otherPart.Parent
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid.Health = MAX_HEALTH
    end
end
```

### Loop with ipairs

`ipairs` is a function that can be used with a for loop to go through each element of an array.

```
for index, value in ipairs(array) do
```

- **Index**: equivalent to the control variable in a regular for loop (use `_` if unused)
- **Value**: each element in the array as the loop iterates
- **Array**: passed to ipairs

```lua
for _, healthPickup in ipairs(healthPickups) do
    healthPickup.Touched:Connect(function(otherPart)
        onTouchHealthPickup(otherPart, healthPickup)
    end)
end
```

### Pickup cooldown

Use an **attribute** for debouncing per-pickup.

```lua
local function onTouchHealthPickup(otherPart, healthPickup)
    if healthPickup:GetAttribute("Enabled") then
        local character = otherPart.Parent
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.Health = MAX_HEALTH
        end
    end
end

for _, healthPickup in ipairs(healthPickups) do
    healthPickup:SetAttribute("Enabled", true)
    healthPickup.Touched:Connect(function(otherPart)
        onTouchHealthPickup(otherPart, healthPickup)
    end)
end
```

### Disable the pickup

```lua
local MAX_HEALTH = 100
local ENABLED_TRANSPARENCY = 0.4
local DISABLED_TRANSPARENCY = 0.9
local COOLDOWN = 10

local function onTouchHealthPickup(otherPart, healthPickup)
    if healthPickup:GetAttribute("Enabled") then
        local character = otherPart.Parent
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.Health = MAX_HEALTH
            healthPickup.Transparency = DISABLED_TRANSPARENCY
            healthPickup:SetAttribute("Enabled", false)
            task.wait(COOLDOWN)
            healthPickup.Transparency = ENABLED_TRANSPARENCY
            healthPickup:SetAttribute("Enabled", true)
        end
    end
end
```

## Key Concepts

- **One script for many objects**: Pattern for avoiding duplicate scripts
- **Folder organization**: Group related parts under a Folder
- **`GetChildren()`**: Returns array of folder contents
- **`WaitForChild()`**: Safely waits for child instance to load
- **`ipairs(array)`**: Loop through array elements; use `_` for unused index
- **Anonymous function with closure**: Captures `healthPickup` per iteration
- **`FindFirstChildWhichIsA("Humanoid")`**: Type-safe child lookup
- **Attributes for debounce**: Per-object debounce state using `SetAttribute`/`GetAttribute`
- **Constants at top**: Tunable values (MAX_HEALTH, COOLDOWN, etc.)

## Code Snippets

### Final code

```lua
local MAX_HEALTH = 100
local ENABLED_TRANSPARENCY = 0.4
local DISABLED_TRANSPARENCY = 0.9
local COOLDOWN = 10

local healthPickupsFolder = workspace:WaitForChild("HealthPickups")
local healthPickups = healthPickupsFolder:GetChildren()

local function onTouchHealthPickup(otherPart, healthPickup)
    if healthPickup:GetAttribute("Enabled") then
        local character = otherPart.Parent
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.Health = MAX_HEALTH
            healthPickup.Transparency = DISABLED_TRANSPARENCY
            healthPickup:SetAttribute("Enabled", false)
            task.wait(COOLDOWN)
            healthPickup.Transparency = ENABLED_TRANSPARENCY
            healthPickup:SetAttribute("Enabled", true)
        end
    end
end

for _, healthPickup in ipairs(healthPickups) do
    healthPickup:SetAttribute("Enabled", true)
    healthPickup.Touched:Connect(function(otherPart)
        onTouchHealthPickup(otherPart, healthPickup)
    end)
end
```

## Notes

- One script managing many objects is DRY; avoid per-object scripts
- Prefer `FindFirstChildWhichIsA(className)` over `FindFirstChild(name)` for type safety
- Attributes provide per-instance state without external tables
- Always close over iteration values in anonymous functions (each pickup gets its own closure)
- Organize related objects under a Folder for easy iteration

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/intermediate-scripting/create-a-health-pickup
Captured: 2026-04-16
