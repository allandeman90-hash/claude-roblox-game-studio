---
title: Skill Tree
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/creating-basic-skill-tree.md
  - wiki/raw/community/articles/game-mechanics/class-loadout-system.md
  - wiki/raw/community/articles/game-mechanics/stat-system-design.md
related:
  - "[[rpg-progression]]"
  - "[[equipment-system]]"
  - "[[crafting-system]]"
  - "[[DataStoreService]]"
tags: [pattern, skill-tree, node-graph, prerequisites, passive, active, respec, rpg]
---

# Skill Tree

> Directed-acyclic-graph of unlockable nodes -- passive stat boosts and active abilities -- gated by prerequisites and spent with points earned on level-up.

## Summary

A skill tree presents players with a visual graph of unlockable nodes. Each node is either a passive bonus (e.g., +5% attack) or an active ability (e.g., "Fireball"). Nodes have prerequisite chains: a node is unlockable only when its parent nodes are already purchased. Players spend skill points (typically 1 per level-up) to purchase nodes. A respec option lets players refund all points and reallocate, either for free or for an in-game currency cost. The entire tree is validated server-side: the client renders the UI and sends purchase requests, but the server checks prerequisites, point balance, and node availability before applying.

## Implementation

### Node Graph Data Structure

```lua
-- ReplicatedStorage/Shared/Config/SkillTreeConfig.lua
local SkillTreeConfig = {}

-- Each node has a unique ID, prerequisites (parent node IDs), and effects
SkillTreeConfig.Nodes = {
    -- Tier 1 (no prerequisites)
    STR_1 = {
        name = "Strength I",
        description = "+5 Attack",
        type = "passive",
        tier = 1,
        prerequisites = {},
        cost = 1,  -- skill points
        effects = { attack = 5 },
        position = Vector2.new(0, 0),  -- UI grid position
    },
    DEF_1 = {
        name = "Fortitude I",
        description = "+5 Defense",
        type = "passive",
        tier = 1,
        prerequisites = {},
        cost = 1,
        effects = { defense = 5 },
        position = Vector2.new(2, 0),
    },

    -- Tier 2 (requires Tier 1)
    STR_2 = {
        name = "Strength II",
        description = "+10 Attack",
        type = "passive",
        tier = 2,
        prerequisites = {"STR_1"},
        cost = 2,
        effects = { attack = 10 },
        position = Vector2.new(0, 1),
    },
    CRIT_1 = {
        name = "Critical Strike",
        description = "+5% Crit Chance",
        type = "passive",
        tier = 2,
        prerequisites = {"STR_1"},
        cost = 2,
        effects = { critChance = 0.05 },
        position = Vector2.new(1, 1),
    },

    -- Tier 3 (requires multiple Tier 2)
    FIREBALL = {
        name = "Fireball",
        description = "Launch a fireball dealing 50 + 2x Attack damage",
        type = "active",
        tier = 3,
        prerequisites = {"STR_2", "CRIT_1"},
        cost = 3,
        effects = { ability = "Fireball" },
        abilityConfig = {
            baseDamage = 50,
            scalingStat = "attack",
            scalingFactor = 2,
            cooldown = 5,
            range = 50,
        },
        position = Vector2.new(0.5, 2),
    },
}

-- Points awarded per level-up
SkillTreeConfig.POINTS_PER_LEVEL = 1

-- Respec cost (in gold, increases per respec)
SkillTreeConfig.BASE_RESPEC_COST = 500
SkillTreeConfig.RESPEC_COST_MULTIPLIER = 1.5  -- 500, 750, 1125, ...

return SkillTreeConfig
```

### Server-Side Validation of Unlocks

```lua
-- ServerStorage/Services/SkillTreeService.lua
local SkillTreeService = {}

local Config = require(game.ReplicatedStorage.Shared.Config.SkillTreeConfig)

function SkillTreeService.canUnlock(playerData, nodeId: string): (boolean, string?)
    local node = Config.Nodes[nodeId]
    if not node then
        return false, "Node does not exist"
    end

    -- Already purchased?
    if playerData.skills.unlocked[nodeId] then
        return false, "Already unlocked"
    end

    -- Sufficient points?
    if playerData.skills.availablePoints < node.cost then
        return false, "Insufficient skill points"
    end

    -- All prerequisites met?
    for _, prereqId in ipairs(node.prerequisites) do
        if not playerData.skills.unlocked[prereqId] then
            return false, "Missing prerequisite: " .. prereqId
        end
    end

    return true, nil
end

function SkillTreeService.unlock(playerData, nodeId: string): (boolean, string?)
    local canDo, reason = SkillTreeService.canUnlock(playerData, nodeId)
    if not canDo then
        return false, reason
    end

    local node = Config.Nodes[nodeId]

    -- Deduct points
    playerData.skills.availablePoints -= node.cost

    -- Mark as unlocked
    playerData.skills.unlocked[nodeId] = true

    -- Apply passive effects immediately
    if node.type == "passive" then
        SkillTreeService.applyPassiveEffects(playerData)
    end

    -- Register active ability
    if node.type == "active" and node.effects.ability then
        table.insert(playerData.skills.activeAbilities, node.effects.ability)
    end

    return true, nil
end

function SkillTreeService.applyPassiveEffects(playerData)
    -- Reset passive bonuses to zero, then sum all unlocked passives
    local bonuses = {}
    for nodeId, isUnlocked in pairs(playerData.skills.unlocked) do
        if isUnlocked then
            local node = Config.Nodes[nodeId]
            if node and node.type == "passive" then
                for stat, value in pairs(node.effects) do
                    bonuses[stat] = (bonuses[stat] or 0) + value
                end
            end
        end
    end
    playerData.skills.passiveBonuses = bonuses
    -- These bonuses are added during stat recalculation
end
```

### Respec (Point Refund)

```lua
function SkillTreeService.respec(playerData): (boolean, string?)
    local respecCount = playerData.skills.respecCount or 0
    local cost = math.floor(
        Config.BASE_RESPEC_COST * (Config.RESPEC_COST_MULTIPLIER ^ respecCount)
    )

    if playerData.currency.gold < cost then
        return false, "Insufficient gold for respec"
    end

    -- Deduct gold
    playerData.currency.gold -= cost

    -- Refund all spent points
    local totalRefunded = 0
    for nodeId, isUnlocked in pairs(playerData.skills.unlocked) do
        if isUnlocked then
            totalRefunded += Config.Nodes[nodeId].cost
        end
    end

    -- Clear all unlocks
    playerData.skills.unlocked = {}
    playerData.skills.activeAbilities = {}
    playerData.skills.passiveBonuses = {}
    playerData.skills.availablePoints += totalRefunded
    playerData.skills.respecCount = respecCount + 1

    return true, nil
end
```

### Remote Event Handler

```lua
-- Server remote handler
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

Remotes.UnlockSkill.OnServerEvent:Connect(function(player, nodeId)
    -- Type check: nodeId must be a string
    if typeof(nodeId) ~= "string" then return end

    local data = PlayerDataService.getData(player)
    if not data then return end

    local ok, err = SkillTreeService.unlock(data, nodeId)
    Remotes.SkillUnlockResult:FireClient(player, {
        success = ok,
        nodeId = nodeId,
        error = err,
        availablePoints = data.skills.availablePoints,
    })
end)
```

### UI Patterns for Skill Trees (Client)

```lua
-- Client-side tree renderer (display only)
local function renderTree(treeFrame: Frame, playerSkills)
    for nodeId, nodeConfig in pairs(SkillTreeConfig.Nodes) do
        local button = treeFrame:FindFirstChild(nodeId)
        if not button then continue end

        local isUnlocked = playerSkills.unlocked[nodeId] == true
        local canUnlock = true

        -- Check prerequisites visually
        for _, prereqId in ipairs(nodeConfig.prerequisites) do
            if not playerSkills.unlocked[prereqId] then
                canUnlock = false
                break
            end
        end

        -- Visual states
        if isUnlocked then
            button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)  -- green
            button.Active = false
        elseif canUnlock and playerSkills.availablePoints >= nodeConfig.cost then
            button.BackgroundColor3 = Color3.fromRGB(255, 255, 100) -- yellow
            button.Active = true
        else
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)   -- gray
            button.Active = false
        end
    end

    -- Draw connection lines between nodes
    for nodeId, nodeConfig in pairs(SkillTreeConfig.Nodes) do
        for _, prereqId in ipairs(nodeConfig.prerequisites) do
            drawLine(treeFrame, prereqId, nodeId,
                playerSkills.unlocked[prereqId] and playerSkills.unlocked[nodeId])
        end
    end
end
```

## Data Schema

What persists in DataStore per player:

```lua
{
    skills = {
        availablePoints = 5,
        unlocked = {
            STR_1 = true,
            STR_2 = true,
            CRIT_1 = true,
        },
        activeAbilities = {},  -- list of ability names unlocked
        passiveBonuses = {     -- computed sum of all passive effects
            attack = 15,
            critChance = 0.05,
        },
        respecCount = 0,
    },
    version = 1,
}
```

The `passiveBonuses` table is recomputed on load from the `unlocked` set, so it is technically derivable. Storing it avoids recomputation on every stat check but must stay in sync.

## Formulas

**Skill points available at level L:** `L * POINTS_PER_LEVEL`

**Respec cost for the Nth respec:** `BASE_RESPEC_COST * RESPEC_COST_MULTIPLIER ^ N`
- 1st: 500g, 2nd: 750g, 3rd: 1125g, 4th: 1688g, ...

**Ability damage formula (example):**
```
damage = baseDamage + (scalingStat * scalingFactor) * (1 + critChance * critMultiplier)
```
Where `critChance` and `critMultiplier` come from skill tree passives.

## Pitfalls

- **Client-side unlock without server validation.** Exploiters send arbitrary node IDs. The server must verify the node exists, prerequisites are met, and points are available before applying. Never trust the client's "unlocked" state.
- **Circular prerequisites.** The data structure is a DAG (directed acyclic graph). Validate at config load time that no circular chains exist, or the prerequisite check will infinite-loop.
- **Orphan nodes after respec.** After respec, all nodes are cleared. If the client UI does not refresh immediately, the player sees stale "unlocked" states. Fire a full tree state update to the client after respec.
- **passiveBonuses desync.** If the stored `passiveBonuses` table drifts from the actual `unlocked` set (e.g., due to a partial save), stats will be wrong. Recompute `passiveBonuses` from `unlocked` on every player join.
- **Large skill trees and DataStore size.** A 200-node tree with boolean unlock flags is approximately 2-4KB serialized. Well within limits, but do not store node config data per player -- only the unlock state.
- **No progressive disclosure.** Showing all 200 nodes to a new player is overwhelming. Show only nodes within 2 hops of unlocked nodes; hide the rest. Reveal as the player progresses.

## Related

- [[rpg-progression]] -- level-ups generate skill points
- [[equipment-system]] -- passive skill bonuses modify equipment effectiveness
- [[crafting-system]] -- crafting-tree skills may unlock recipe tiers
- [[DataStoreService]] -- persistence for skill unlock state

## Sources

- [Creating A Basic Skill Tree](../raw/community/articles/game-mechanics/creating-basic-skill-tree.md) -- prerequisite chains, GUI structure, community critique on missing server validation
- [Class/Loadout System Design](../raw/community/articles/game-mechanics/class-loadout-system.md) -- class-specific skill trees, module script configuration, spawning architecture
- [Stat System Design](../raw/community/articles/game-mechanics/stat-system-design.md) -- single-table stat storage, module-based approach
