---
title: tycoon-mechanics
type: pattern
category: patterns
subcategory: genre-mechanics
owner: game-designer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/tycoon-dropper-best-practices.md
  - wiki/raw/community/articles/game-mechanics/tycoon-button-system.md
related:
  - "[[simulator-mechanics]]"
  - "[[daily-rewards]]"
  - "[[inventory-pattern]]"
  - "[[DataStoreService]]"
  - "[[lobby-system]]"
tags: [pattern, tycoon, dropper, conveyor, buttons, upgrades, genre]
---

# Tycoon Mechanics

> Dropper-conveyor-collector pipeline with button-based purchases, upgrade tiers, and per-player plot ownership. The second most popular idle-progression genre on Roblox after simulators.

## Summary

Tycoon games give each player (or team) a personal plot where they build a factory-like pipeline: droppers create resource items, conveyors move them, and collectors convert them into currency. Players spend currency by stepping on floor buttons that unlock new droppers, upgrades, decorations, and areas. The progression is spatial -- the player's plot visibly grows richer as they advance. Tycoon templates (Zed's Tycoon Kit, Bennet's Tycoon Kit) are widely used starting points, but understanding the underlying architecture is essential for customization and performance.

## Core Loop

```
Dropper spawns resource part on timer
       |
       v
Conveyor belt moves part via physics (AssemblyLinearVelocity)
       |
       v
Collector detects part via Touched --> awards currency, destroys part
       |
       v
Player steps on Purchase Button --> spends currency, unlocks next item
       |
       v
New dropper / upgrade / area appears on plot
       |
       v
Revenue rate increases --> repeat
       |
       v
(Optional) Rebirth resets plot, grants permanent multiplier
```

## Implementation

### Plot Ownership / Claiming

Each plot is a Model with a designated claim zone. When a player touches or interacts with the claim pad, the server assigns ownership.

```lua
-- ServerScriptService/TycoonManager.server.lua
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local plots: {[Model]: Player?} = {}

local function claimPlot(plot: Model, player: Player)
    if plots[plot] then return end -- already claimed

    plots[plot] = player
    -- Parent plot items under the player's ownership for cleanup
    plot:SetAttribute("Owner", player.UserId)

    -- Show the first purchase button
    local firstButton = plot:FindFirstChild("Button_001")
    if firstButton then
        firstButton.Transparency = 0
        firstButton.CanCollide = true
    end
end

-- On player leave, unclaim their plot
Players.PlayerRemoving:Connect(function(player)
    for plot, owner in plots do
        if owner == player then
            plots[plot] = nil
            plot:SetAttribute("Owner", 0)
            resetPlot(plot)
        end
    end
end)
```

### Dropper System

Droppers clone a template part at a fixed interval. The server creates the part; the physics system handles movement via the conveyor.

```lua
-- ServerStorage/DropperModule.lua
local DropperModule = {}

local DROP_INTERVAL = 2 -- seconds
local MAX_DROPS_PER_DROPPER = 10 -- prevent buildup

function DropperModule.start(dropper: Model, config: DropperConfig)
    local spawnPoint = dropper:FindFirstChild("SpawnPoint")
    local template = dropper:FindFirstChild("DropTemplate")
    if not spawnPoint or not template then return end

    local activeParts = 0

    task.spawn(function()
        while dropper.Parent do
            if activeParts < MAX_DROPS_PER_DROPPER then
                local drop = template:Clone()
                drop.Position = spawnPoint.Position
                drop.Parent = workspace.ActiveDrops

                activeParts += 1
                drop.Destroying:Connect(function()
                    activeParts -= 1
                end)
            end
            task.wait(DROP_INTERVAL / (config.speedMultiplier or 1))
        end
    end)
end

return DropperModule
```

### Conveyor Belt

Conveyors move parts using `AssemblyLinearVelocity` -- the physics engine handles the rest. No per-frame scripts needed.

```lua
-- Set on the conveyor part itself (one-time setup)
local conveyor = script.Parent
conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * 10 -- studs/sec
```

For visual effect, apply a `SurfaceAppearance` or scrolling `Texture` on the conveyor face.

### Collector

The collector detects arriving parts, awards currency based on the part's value attribute, and destroys the part.

```lua
-- ServerScriptService/Collector.server.lua
local CollectionService = game:GetService("CollectionService")

for _, collector in CollectionService:GetTagged("Collector") do
    local plot = collector:FindFirstAncestorOfClass("Model")

    collector.Touched:Connect(function(hit)
        if not hit:GetAttribute("DropValue") then return end

        local ownerId = plot:GetAttribute("Owner")
        if ownerId == 0 then return end

        local player = Players:GetPlayerByUserId(ownerId)
        if not player then return end

        local value = hit:GetAttribute("DropValue") or 1
        local data = PlayerDataService.getData(player)
        if data then
            data.currency += value * (data.collectMultiplier or 1)
        end

        hit:Destroy()
    end)
end
```

### Button Purchase System

Buttons are floor pads with a price, a dependency, and an item to unlock. The system supports sequential unlocking via dependency chains.

```lua
-- ServerStorage/ButtonSystem.lua
local ButtonSystem = {}

export type ButtonConfig = {
    price: number,
    itemToUnlock: string,   -- name of the Model to make visible
    dependency: string?,    -- name of a previously purchased item (nil = always visible)
}

function ButtonSystem.setupPlot(plot: Model, buttons: {ButtonConfig})
    local purchased: {[string]: boolean} = {}

    for _, config in buttons do
        local buttonPart = plot:FindFirstChild("Btn_" .. config.itemToUnlock)
        if not buttonPart then continue end

        -- Initially hide buttons that have unmet dependencies
        if config.dependency and not purchased[config.dependency] then
            buttonPart.Transparency = 1
            buttonPart.CanCollide = false
        end

        buttonPart.Touched:Connect(function(hit)
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if not player then return end

            -- Verify ownership
            if plot:GetAttribute("Owner") ~= player.UserId then return end

            -- Check dependency
            if config.dependency and not purchased[config.dependency] then
                return
            end

            local data = PlayerDataService.getData(player)
            if not data or data.currency < config.price then return end

            -- Purchase
            data.currency -= config.price
            purchased[config.itemToUnlock] = true

            -- Hide button
            buttonPart.Transparency = 1
            buttonPart.CanCollide = false

            -- Show the unlocked item
            local item = plot:FindFirstChild(config.itemToUnlock)
            if item then
                for _, part in item:GetDescendants() do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end

            -- Reveal dependent buttons
            for _, otherConfig in buttons do
                if otherConfig.dependency == config.itemToUnlock then
                    local nextBtn = plot:FindFirstChild("Btn_" .. otherConfig.itemToUnlock)
                    if nextBtn then
                        nextBtn.Transparency = 0
                        nextBtn.CanCollide = true
                    end
                end
            end
        end)
    end
end

return ButtonSystem
```

### Upgrade Tiers

Upgrades enhance existing systems (faster droppers, higher value drops, bigger collectors). Each upgrade is a button that replaces the current tier with the next.

```lua
local UpgradeTiers = {
    DropperSpeed = {
        [1] = { cost = 1000,  multiplier = 1.5 },
        [2] = { cost = 5000,  multiplier = 2.0 },
        [3] = { cost = 25000, multiplier = 3.0 },
    },
    DropValue = {
        [1] = { cost = 2000,  multiplier = 2 },
        [2] = { cost = 10000, multiplier = 5 },
        [3] = { cost = 50000, multiplier = 10 },
    },
}
```

## Data Schema

```lua
export type TycoonData = {
    -- Currency
    currency: number,

    -- Plot state
    plotId: number?,             -- which plot the player claimed
    purchasedItems: {string},    -- list of unlocked item names
    upgradeTiers: {[string]: number}, -- upgrade name -> current tier

    -- Multipliers
    collectMultiplier: number,
    dropSpeedMultiplier: number,
    dropValueMultiplier: number,

    -- Rebirth (optional)
    rebirths: number,
    rebirthMultiplier: number,
}
```

## Economy Integration

| Revenue Source | Typical GamePass | Price (Robux) |
|----------------|------------------|---------------|
| 2x Income | Permanent 2x all drops | 199-399 |
| Auto-Collect | Collector range covers entire plot | 149-299 |
| VIP Plot | Exclusive plot with better layout | 299-499 |
| Instant Buttons | All current buttons cost 0 | 99 (one-time) |

## Tycoon Template Architecture

Most Roblox tycoons start from a template kit. The standard structure:

```
Workspace/
  Tycoons/
    Plot1/
      ClaimPad
      Buttons/
        Btn_Dropper1 (Price attribute, Dependency attribute)
        Btn_Dropper2
        Btn_Upgrade1
      Items/
        Dropper1 (initially invisible)
        Dropper2
        Conveyor1
        Collector1
      Upgrades/
        SpeedUpgrade1
```

Templates use Attributes on parts rather than Value objects for cleaner configuration.

## Pitfalls

- **Dropper part buildup**: If parts are not destroyed after reaching the collector, they accumulate and crash the server. Always set a max lifetime (e.g., `Debris:AddItem(drop, 30)`) as a safety net.
- **Physics performance**: Hundreds of active physics parts across many plots is expensive. Use the client-rendering pattern: server calculates currency per second, client shows visual drops for cosmetic effect only.
- **Button race condition**: Two players touching the same button simultaneously can cause double-purchase. Use a debounce flag per button.
- **Plot cleanup on leave**: If a player disconnects without the plot being reset, the next claimer inherits stale state. Always reset all items, buttons, and active drops on unclaim.
- **Conveyor velocity drift**: `AssemblyLinearVelocity` can be affected by other physics interactions. Anchor conveyor parts and use `CanCollide = false` on the belt surface if needed, or apply velocity via `Touched` events on drop parts instead.

## Related

- [[simulator-mechanics]] -- similar idle loop but without spatial building
- [[daily-rewards]] -- retention mechanic that pairs with tycoon login streaks
- [[inventory-pattern]] -- if the tycoon has collectible items
- [[lobby-system]] -- tycoons often have a shared lobby before plot assignment
- [[DataStoreService]] -- persisting purchased items and upgrades

## Sources

- [Best practice for efficient tycoon droppers - DevForum](https://devforum.roblox.com/t/best-practice-for-efficient-tycoon-droppers-and-moving-parts/339303)
- [Tycoon button system - DevForum](https://devforum.roblox.com/t/tycoon-button-system/1923669)
- [Tycoon button dependency system - DevForum](https://devforum.roblox.com/t/tycoon-button-dependency-system/1565731)
- [How to make a conveyor belt - DevForum](https://devforum.roblox.com/t/how-to-make-an-conveyor-belt/2059575)
- [Tycoon dropper optimization - DevForum](https://devforum.roblox.com/t/tycoon-dropper-optimization/1732295)
- [Roblox Tycoon Tutorial - GameDev Academy](https://gamedevacademy.org/roblox-tycoon-tutorial-tutorial-complete-guide/)
- [Tycoon Droppers code review - DevForum](https://devforum.roblox.com/t/tycoon-droppers-code-review/2225205)
