---
title: farming-system
type: pattern
category: patterns
subcategory: gameplay
owner: game-designer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/farming-system-islands-pattern.md
  - wiki/raw/community/articles/game-mechanics/plant-growth-system.md
related:
  - "[[inventory-pattern]]"
  - "[[building-placement-system]]"
  - "[[DataStoreService]]"
  - "[[notification-system]]"
  - "[[daily-rewards]]"
tags: [pattern, gameplay, farming, resources, gathering, tools]
---

# Farming System

> Resource nodes with respawn timers, tool-based collection, server-authoritative validation, growth state machines, and inventory integration.

## Summary

Farming and resource gathering systems let players collect materials from the world -- mining rocks, chopping trees, harvesting crops, picking flowers. The pattern applies to any game with collectible resource nodes: survival games, tycoons, RPGs, and simulators.

The core loop is: player equips a tool, activates it near a resource node, the server validates the interaction and awards resources, the node shows depletion feedback and enters a respawn cooldown. For crop-based farming, nodes also have a growth lifecycle (plant, water, grow, harvest) driven by a server-side state machine with timers.

All resource awards and state transitions are server-authoritative to prevent exploits.

## Implementation

### Resource Node Definition

Define resource types in config so designers can tune without touching code:

```lua
-- ReplicatedStorage/Shared/Config/ResourceConfig.lua
local ResourceConfig = {}

ResourceConfig.Nodes = {
    OakTree = {
        displayName = "Oak Tree",
        resourceId = "wood",
        resourceAmount = { min = 3, max = 6 },
        requiredTool = "Axe",
        hitPoints = 3,                -- hits to deplete
        respawnTime = 30,             -- seconds
        collectSfx = "rbxassetid://666666",
        depletedModel = "OakTreeStump",
    },
    IronRock = {
        displayName = "Iron Deposit",
        resourceId = "iron_ore",
        resourceAmount = { min = 1, max = 3 },
        requiredTool = "Pickaxe",
        hitPoints = 5,
        respawnTime = 60,
        collectSfx = "rbxassetid://777777",
        depletedModel = "IronRockDepleted",
    },
    BlueberryBush = {
        displayName = "Blueberry Bush",
        resourceId = "blueberry",
        resourceAmount = { min = 2, max = 4 },
        requiredTool = nil,           -- hand-pickable
        hitPoints = 1,
        respawnTime = 45,
        collectSfx = "rbxassetid://888888",
        depletedModel = nil,          -- just hide
    },
}

ResourceConfig.Tools = {
    Axe     = { speedMultiplier = 1.0, bonusChance = 0.1 },
    Pickaxe = { speedMultiplier = 1.0, bonusChance = 0.1 },
}

return ResourceConfig
```

### Server-Side Resource Node Manager

```lua
-- ServerScriptService/ResourceNodeManager.server.lua
local ResourceConfig = require(game.ReplicatedStorage.Shared.Config.ResourceConfig)

local ResourceNodeManager = {}

-- State per active node: { hp: number, depleted: boolean, lastHitBy: Player?, cooldownEnd: number }
local nodeStates: { [Model]: {} } = {}

local function initNode(nodeModel: Model)
    local nodeType = nodeModel:GetAttribute("NodeType")
    local config = ResourceConfig.Nodes[nodeType]
    if not config then return end

    nodeStates[nodeModel] = {
        hp = config.hitPoints,
        depleted = false,
        cooldownEnd = 0,
    }
end

local function depleteNode(nodeModel: Model)
    local nodeType = nodeModel:GetAttribute("NodeType")
    local config = ResourceConfig.Nodes[nodeType]
    local state = nodeStates[nodeModel]

    state.depleted = true

    -- Visual feedback: swap to depleted model or hide
    if config.depletedModel then
        -- Swap visual (simplified)
        for _, part in nodeModel:GetDescendants() do
            if part:IsA("BasePart") then
                part.Transparency = 0.7
            end
        end
    else
        nodeModel:SetAttribute("Visible", false)
    end

    -- Schedule respawn
    state.cooldownEnd = os.clock() + config.respawnTime
    task.delay(config.respawnTime, function()
        state.hp = config.hitPoints
        state.depleted = false
        state.cooldownEnd = 0
        -- Restore visual
        for _, part in nodeModel:GetDescendants() do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        nodeModel:SetAttribute("Visible", true)
    end)
end

function ResourceNodeManager.hitNode(player: Player, nodeModel: Model, toolName: string?): boolean
    local nodeType = nodeModel:GetAttribute("NodeType")
    local config = ResourceConfig.Nodes[nodeType]
    if not config then return false end

    local state = nodeStates[nodeModel]
    if not state or state.depleted then return false end

    -- Validate tool requirement
    if config.requiredTool then
        if toolName ~= config.requiredTool then return false end
    end

    -- Validate distance (anti-exploit)
    local character = player.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local distance = (rootPart.Position - nodeModel:GetPivot().Position).Magnitude
    if distance > 15 then return false end  -- max interaction range

    -- Apply hit
    state.hp -= 1

    if state.hp <= 0 then
        -- Award resources
        local amount = math.random(config.resourceAmount.min, config.resourceAmount.max)

        -- Bonus chance from tool tier
        local toolConfig = ResourceConfig.Tools[toolName]
        if toolConfig and math.random() < toolConfig.bonusChance then
            amount += 1
        end

        InventoryService.addItem(player, config.resourceId, amount)
        depleteNode(nodeModel)

        return true -- fully collected
    end

    return false -- still has HP remaining
end

-- Initialize all nodes in workspace
for _, nodeModel in workspace.ResourceNodes:GetChildren() do
    initNode(nodeModel)
end

return ResourceNodeManager
```

### Tool Activation (Client-Side)

```lua
-- StarterPlayer/StarterCharacterScripts/ToolController.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local HarvestRemote = ReplicatedStorage.Remotes.Harvest

local COOLDOWN = 0.5  -- seconds between swings
local lastSwing = 0

local function onToolActivated(tool: Tool)
    local now = os.clock()
    if now - lastSwing < COOLDOWN then return end
    lastSwing = now

    -- Raycast forward from character to find a resource node
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(
        rootPart.Position,
        rootPart.CFrame.LookVector * 10,
        params
    )

    if result and result.Instance then
        local nodeModel = result.Instance:FindFirstAncestorWhichIsA("Model")
        if nodeModel and nodeModel:GetAttribute("NodeType") then
            HarvestRemote:FireServer(nodeModel, tool.Name)
        end
    end
end
```

### Server Remote Handler

```lua
-- ServerScriptService/HarvestHandler.server.lua
local HarvestRemote = ReplicatedStorage.Remotes.Harvest

-- Rate limit per player
local lastHarvestTime: { [Player]: number } = {}
local HARVEST_COOLDOWN = 0.4

HarvestRemote.OnServerEvent:Connect(function(player, nodeModel, toolName)
    -- Type validation
    if typeof(nodeModel) ~= "Instance" or typeof(toolName) ~= "string" then return end
    if not nodeModel:IsA("Model") then return end
    if not nodeModel:IsDescendantOf(workspace.ResourceNodes) then return end

    -- Rate limit
    local now = os.clock()
    if lastHarvestTime[player] and (now - lastHarvestTime[player]) < HARVEST_COOLDOWN then
        return
    end
    lastHarvestTime[player] = now

    -- Validate player actually has this tool equipped
    local character = player.Character
    if not character then return end
    local equippedTool = character:FindFirstChildWhichIsA("Tool")
    if not equippedTool or equippedTool.Name ~= toolName then return end

    ResourceNodeManager.hitNode(player, nodeModel, toolName)
end)
```

### Crop Growth State Machine (Farming Variant)

For plantable crops that grow over time:

```lua
-- ServerStorage/Services/FarmingService.lua
local FarmingService = {}

export type CropState = "empty" | "seeded" | "growing" | "ready" | "dead"

export type CropTile = {
    state: CropState,
    seedType: string?,
    plantedAt: number,       -- os.clock
    lastWatered: number,     -- os.clock
    growthProgress: number,  -- 0.0 to 1.0
}

local GROWTH_CONFIGS = {
    Wheat   = { growTime = 120, waterInterval = 60, droughtLimit = 90 },
    Carrot  = { growTime = 180, waterInterval = 45, droughtLimit = 75 },
    Pumpkin = { growTime = 300, waterInterval = 90, droughtLimit = 120 },
}

function FarmingService.plant(tile: CropTile, seedType: string)
    if tile.state ~= "empty" then return false end
    tile.state = "seeded"
    tile.seedType = seedType
    tile.plantedAt = os.clock()
    tile.lastWatered = os.clock()
    tile.growthProgress = 0
    return true
end

function FarmingService.water(tile: CropTile)
    if tile.state ~= "seeded" and tile.state ~= "growing" then return false end
    tile.lastWatered = os.clock()
    if tile.state == "seeded" then
        tile.state = "growing"
    end
    return true
end

function FarmingService.tick(tile: CropTile, dt: number)
    if tile.state ~= "growing" then return end

    local config = GROWTH_CONFIGS[tile.seedType]
    if not config then return end

    -- Check drought
    local timeSinceWater = os.clock() - tile.lastWatered
    if timeSinceWater > config.droughtLimit then
        tile.state = "dead"
        return
    end

    -- Progress growth (only if watered recently enough)
    if timeSinceWater < config.waterInterval * 1.5 then
        tile.growthProgress += dt / config.growTime
    end

    if tile.growthProgress >= 1.0 then
        tile.growthProgress = 1.0
        tile.state = "ready"
    end
end

function FarmingService.harvest(tile: CropTile): (string?, number?)
    if tile.state ~= "ready" then return nil, nil end

    local seedType = tile.seedType
    local amount = math.random(2, 5)  -- config-driven in production

    -- Reset tile
    tile.state = "empty"
    tile.seedType = nil
    tile.growthProgress = 0

    return seedType, amount
end

return FarmingService
```

### Server Tick Loop for Crops

Process all crop tiles in batches to avoid frame spikes:

```lua
-- ServerScriptService/FarmTickLoop.server.lua
local RunService = game:GetService("RunService")
local FarmingService = require(game.ServerStorage.Services.FarmingService)

local TILES_PER_FRAME = 50  -- chunk processing
local allTiles: { FarmingService.CropTile } = {}
local tickIndex = 1

RunService.Heartbeat:Connect(function(dt)
    local processed = 0
    while processed < TILES_PER_FRAME and tickIndex <= #allTiles do
        FarmingService.tick(allTiles[tickIndex], dt)
        tickIndex += 1
        processed += 1
    end
    if tickIndex > #allTiles then
        tickIndex = 1
    end
end)
```

## Data Schema

```lua
-- Per-player farm data (inside DataStore profile)
farmData = {
    tiles = {
        -- indexed by tile position or ID
        ["3,5"] = {
            state = "growing",
            seedType = "Wheat",
            plantedAt = 1713200000,
            lastWatered = 1713200050,
            growthProgress = 0.45,
        },
    },
    -- Resource inventory (or use shared inventory)
    resources = {
        wood = 24,
        iron_ore = 8,
        blueberry = 12,
        wheat = 0,
    },
}
```

## Pitfalls

- **AFK farming prevention**: Rate-limit harvest remotes server-side. A 0.4-second cooldown per player prevents autoclicker exploits. For additional protection, check that the player's character is actually moving/animating (not stationary for 10+ minutes).
- **Chunk-based tick processing**: Ticking hundreds of crop tiles every Heartbeat causes frame spikes. Process a fixed number of tiles per frame (e.g., 50) and rotate through the full set. The DevForum community recommends this "chunk system" approach.
- **`os.clock()` vs `os.time()`**: Use `os.clock()` for in-session timers (higher resolution, monotonic). Use `os.time()` for cross-session persistence (epoch-based, survives server restarts). Crop growth that should continue offline must use `os.time()`.
- **Distance validation**: Always check the distance between the player's HumanoidRootPart and the resource node. Without this, exploiters can harvest nodes from across the map.
- **Instance validation**: Verify that the node model sent by the client is actually inside `workspace.ResourceNodes` (or whatever container). Never accept arbitrary Instances from the client.
- **Visual feedback on depletion**: Swap to a depleted model, reduce transparency, or play a particle effect. Without feedback, players cannot tell if a node is available.
- **Tool validation**: Confirm the player actually has the required tool equipped (check `Character:FindFirstChildWhichIsA("Tool")`). Exploiters can spoof tool names over remotes.
- **Growth persistence**: When saving crop tile state to DataStore, store `os.time()` for `plantedAt` and `lastWatered`. On load, compute elapsed time and fast-forward growth: `elapsedGrowth = (os.time() - data.plantedAt) / config.growTime`.

## Related

- [[inventory-pattern]] -- collected resources flow into the inventory system
- [[building-placement-system]] -- farming plots use the same grid-based placement infrastructure
- [[DataStoreService]] -- persistence of farm state and resource inventory
- [[notification-system]] -- "Crop ready!" notifications when growth completes
- [[daily-rewards]] -- farming games often pair with daily login bonuses

## Sources

- [Farming System Patterns (Islands-style)](wiki/raw/community/articles/game-mechanics/farming-system-islands-pattern.md) -- DevForum state-machine lifecycle for farming tiles
- [Plant Growth and Farming Code Patterns](wiki/raw/community/articles/game-mechanics/plant-growth-system.md) -- DevForum growth function and tick-based patterns
- [DevForum: Efficient Farming System Like Islands](https://devforum.roblox.com/t/how-could-i-making-an-efficient-farming-system-like-islands/1837315)
- [DevForum: Farming/Smelting System Like Sky Block](https://devforum.roblox.com/t/how-to-do-the-farmingsmelting-system-like-in-sky-block/592994)
- [DevForum: Factory Building / Resource Gathering Mechanics](https://devforum.roblox.com/t/help-needed-with-factory-building-resource-gathering-mechanics/2077413)
- [DevForum: How Should Players Obtain Resources](https://devforum.roblox.com/t/how-should-players-obtain-resources/2439406)
