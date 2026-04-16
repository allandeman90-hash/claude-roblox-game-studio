---
title: Behavior Trees
type: pattern
category: patterns
subcategory: game-mechanics
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/behaviour-tree-lua.md
  - wiki/raw/community/articles/game-mechanics/enemy-ai-system-simplepath.md
  - wiki/raw/community/articles/game-mechanics/combat-npc-tutorial.md
related:
  - "[[npc-ai-system]]"
  - "[[pathfinding-system]]"
  - "[[boss-patterns]]"
  - "[[state-machine-pattern]]"
tags:
  - behavior-tree
  - ai
  - npc
  - decision-making
  - architecture
---

# Behavior Trees

> Selector/Sequence/Decorator pattern for structuring complex NPC AI, with comparison to finite state machines and a Luau implementation.

## Summary

A behavior tree is a hierarchical decision-making structure where an NPC's logic is organized as a tree of nodes. Each node returns one of three statuses: `Success`, `Failure`, or `Running`. The tree is "ticked" each AI frame, and control flows from the root through composite nodes (Selector, Sequence) down to leaf nodes (actions and conditions). Behavior trees scale better than flat state machines for NPCs with many behaviors because adding a new behavior means adding a subtree rather than wiring new transitions between every existing state.

## When to Use Behavior Trees vs FSM

| Factor | Finite State Machine | Behavior Tree |
|--------|---------------------|---------------|
| Number of states | < 6 states | > 6 behaviors |
| Transition complexity | Few, well-defined | Many conditional branches |
| Adding new behavior | Requires new transitions from every state | Add a subtree; existing tree unchanged |
| Readability | Simple and obvious for small AI | Scales better visually and logically |
| Debugging | Easy to log current state | Requires tree visualization tooling |
| Implementation cost | Minimal (if/elseif chain) | Needs a library or framework |
| Roblox ecosystem | Built-in with basic scripts | BTreesV5 plugin, behaviortree.rbxlua |

**Rule of thumb**: Use an FSM for simple NPCs (idle/patrol/chase/attack). Use a behavior tree when an NPC has 6+ distinct behaviors with overlapping conditions.

## Implementation

### Node Types

Every behavior tree is built from these node types:

**Leaf Nodes (Actions/Conditions)**
- Execute actual game logic or check a condition
- Return `Success`, `Failure`, or `Running`

**Composite Nodes**
- **Sequence**: Runs children left to right. Fails immediately if any child fails. Succeeds only when ALL children succeed. (AND logic)
- **Selector** (Priority): Runs children left to right. Succeeds immediately if any child succeeds. Fails only when ALL children fail. (OR logic)
- **Random**: Picks one child at random and runs it.

**Decorator Nodes**
- Wrap a single child and modify its result
- **Inverter**: Flips Success to Failure and vice versa
- **AlwaysSucceed**: Converts Failure to Success
- **AlwaysFail**: Converts Success to Failure
- **RepeatN**: Runs the child N times

### Luau Implementation

A minimal behavior tree framework in Luau. No external dependencies.

```lua
-- ReplicatedStorage/Shared/BehaviorTree.lua

export type NodeStatus = "Success" | "Failure" | "Running"

export type BTNode = {
    tick: (self: BTNode, blackboard: Blackboard) -> NodeStatus,
}

export type Blackboard = {
    npc: Model,
    target: Model?,
    [string]: any,
}

local BehaviorTree = {}

-- LEAF: Action node
function BehaviorTree.Action(fn: (blackboard: Blackboard) -> NodeStatus): BTNode
    return {
        tick = function(self, blackboard)
            return fn(blackboard)
        end,
    }
end

-- LEAF: Condition node (returns Success or Failure, never Running)
function BehaviorTree.Condition(fn: (blackboard: Blackboard) -> boolean): BTNode
    return {
        tick = function(self, blackboard)
            return if fn(blackboard) then "Success" else "Failure"
        end,
    }
end

-- COMPOSITE: Sequence (AND — all must succeed)
function BehaviorTree.Sequence(children: {BTNode}): BTNode
    return {
        tick = function(self, blackboard)
            for _, child in children do
                local status = child:tick(blackboard)
                if status ~= "Success" then
                    return status -- Failure or Running propagates up
                end
            end
            return "Success"
        end,
    }
end

-- COMPOSITE: Selector (OR — first success wins)
function BehaviorTree.Selector(children: {BTNode}): BTNode
    return {
        tick = function(self, blackboard)
            for _, child in children do
                local status = child:tick(blackboard)
                if status ~= "Failure" then
                    return status -- Success or Running propagates up
                end
            end
            return "Failure"
        end,
    }
end

-- COMPOSITE: Random (pick one child)
function BehaviorTree.Random(children: {BTNode}): BTNode
    return {
        tick = function(self, blackboard)
            local child = children[math.random(1, #children)]
            return child:tick(blackboard)
        end,
    }
end

-- DECORATOR: Inverter (flip Success/Failure)
function BehaviorTree.Inverter(child: BTNode): BTNode
    return {
        tick = function(self, blackboard)
            local status = child:tick(blackboard)
            if status == "Success" then return "Failure"
            elseif status == "Failure" then return "Success"
            else return "Running"
            end
        end,
    }
end

-- DECORATOR: AlwaysSucceed
function BehaviorTree.AlwaysSucceed(child: BTNode): BTNode
    return {
        tick = function(self, blackboard)
            child:tick(blackboard)
            return "Success"
        end,
    }
end

-- DECORATOR: RepeatUntilFail
function BehaviorTree.RepeatUntilFail(child: BTNode): BTNode
    return {
        tick = function(self, blackboard)
            while true do
                local status = child:tick(blackboard)
                if status == "Failure" then return "Failure" end
                if status == "Running" then return "Running" end
                -- Success: keep looping
            end
        end,
    }
end

return BehaviorTree
```

### Blackboard Pattern

The blackboard is a shared data table passed to every node. It holds the NPC's perception of the world so nodes can communicate without coupling.

```lua
local function createBlackboard(npc: Model): Blackboard
    return {
        npc = npc,
        target = nil,
        lastKnownTargetPosition = nil,
        distanceToTarget = math.huge,
        healthPercent = 1.0,
        isInCombat = false,
        patrolWaypoints = workspace.PatrolPoints:GetChildren(),
        currentPatrolIndex = 1,
    }
end
```

### Building an Enemy AI Tree

Compose nodes into a complete enemy behavior.

```lua
local BT = require(game.ReplicatedStorage.Shared.BehaviorTree)
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

-- Condition: is there a player within aggro range?
local hasTarget = BT.Condition(function(bb)
    local rootPart = bb.npc:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local nearest, nearestDist = nil, 40 -- aggro radius
    for _, player in Players:GetPlayers() do
        local char = player.Character
        if not char then continue end
        local targetRoot = char:FindFirstChild("HumanoidRootPart")
        local targetHum = char:FindFirstChildWhichIsA("Humanoid")
        if not targetRoot or not targetHum or targetHum.Health <= 0 then continue end

        local dist = (targetRoot.Position - rootPart.Position).Magnitude
        if dist < nearestDist then
            nearest = char
            nearestDist = dist
        end
    end

    bb.target = nearest
    bb.distanceToTarget = nearestDist
    return nearest ~= nil
end)

-- Condition: is target in attack range?
local isInAttackRange = BT.Condition(function(bb)
    return bb.distanceToTarget <= 5
end)

-- Action: pathfind toward target
local chaseTarget = BT.Action(function(bb)
    local humanoid = bb.npc:FindFirstChildWhichIsA("Humanoid")
    local rootPart = bb.npc:FindFirstChild("HumanoidRootPart")
    local target = bb.target
    if not humanoid or not rootPart or not target then return "Failure" end

    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return "Failure" end

    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5})
    local success = pcall(path.ComputeAsync, path, rootPart.Position, targetRoot.Position)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        if #waypoints >= 2 then
            humanoid:MoveTo(waypoints[2].Position)
            if waypoints[2].Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
        end
        return "Running"
    end
    return "Failure"
end)

-- Action: attack the target
local attackTarget = BT.Action(function(bb)
    local target = bb.target
    if not target then return "Failure" end

    local targetHum = target:FindFirstChildWhichIsA("Humanoid")
    if not targetHum or targetHum.Health <= 0 then return "Failure" end

    -- Deal damage (server-side)
    targetHum:TakeDamage(10)
    return "Success"
end)

-- Action: patrol between waypoints
local patrol = BT.Action(function(bb)
    local humanoid = bb.npc:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return "Failure" end

    local waypoints = bb.patrolWaypoints
    if #waypoints == 0 then return "Failure" end

    local target = waypoints[bb.currentPatrolIndex]
    humanoid:MoveTo(target.Position)

    bb.currentPatrolIndex = (bb.currentPatrolIndex % #waypoints) + 1
    return "Success"
end)

-- Compose the tree:
--
--   Selector
--   ├── Sequence (combat)
--   │   ├── hasTarget
--   │   └── Selector
--   │       ├── Sequence (attack if in range)
--   │       │   ├── isInAttackRange
--   │       │   └── attackTarget
--   │       └── chaseTarget
--   └── patrol (fallback)

local enemyTree = BT.Selector({
    BT.Sequence({
        hasTarget,
        BT.Selector({
            BT.Sequence({
                isInAttackRange,
                attackTarget,
            }),
            chaseTarget,
        }),
    }),
    patrol,
})
```

### Ticking the Tree

Run the tree at a fixed rate on the server.

```lua
local TICK_RATE = 0.2 -- 5 ticks per second

local function runNpcAI(npc: Model)
    local blackboard = createBlackboard(npc)

    while true do
        local humanoid = npc:FindFirstChildWhichIsA("Humanoid")
        if not humanoid or humanoid.Health <= 0 then break end

        blackboard.healthPercent = humanoid.Health / humanoid.MaxHealth
        enemyTree:tick(blackboard)

        task.wait(TICK_RATE)
    end
end

-- Centralized: spawn one coroutine per NPC
for _, npc in workspace.NPCs:GetChildren() do
    task.spawn(runNpcAI, npc)
end
```

## Variants

### Using behaviortree.rbxlua Library

The `behaviortree.rbxlua` library (ported from JavaScript via Lua) provides a class-based approach with registration and lifecycle hooks.

```lua
local BehaviourTree = require(game.ServerStorage.BehaviourTree)

-- Register reusable tasks by name
BehaviourTree.Task:new({
    name = "findTarget",
    run = function(task, npc)
        -- detection logic
        if foundTarget then
            task:success()
        else
            task:fail()
        end
    end,
})

BehaviourTree.Task:new({
    name = "chase",
    run = function(task, npc)
        -- pathfinding logic
        task:running() -- still moving
    end,
})

-- Build tree using registered names
local tree = BehaviourTree:new({
    tree = BehaviourTree.Selector:new({
        nodes = {
            BehaviourTree.Sequence:new({
                nodes = { "findTarget", "chase" }
            }),
            "patrol",
        }
    })
})

tree:setObject(npcModel)
-- In game loop:
tree:run()
```

**Lifecycle**: `start()` runs once before first `run()`. `run()` must call `self:success()`, `self:fail()`, or `self:running()`. `finish()` runs after success or failure.

**GitHub sources**: `github.com/seyaidev/behaviortree.rbxlua`, `github.com/howmanysmall/behaviortree.rbxlua`.

### BTreesV5 Visual Editor

The BTrees Visual Editor plugin (by Defaultio) provides a node-graph UI inside Roblox Studio for visually composing behavior trees. The plugin generates a tree configuration that a runtime module interprets. This is the most popular visual approach in the Roblox ecosystem but requires the plugin for editing.

### Hybrid FSM + Behavior Tree

Use an FSM for high-level states (idle, combat, fleeing) and a behavior tree within each state for detailed decision-making. This keeps the top-level logic readable while allowing complex behavior within each state.

```lua
-- High-level FSM
if state == "combat" then
    combatBehaviorTree:tick(blackboard)
elseif state == "idle" then
    idleBehaviorTree:tick(blackboard)
elseif state == "fleeing" then
    fleeBehaviorTree:tick(blackboard)
end
```

## Pitfalls

1. **No Running state handling**: Nodes that represent ongoing actions (pathfinding, animation playback) must return `Running`, not `Success`. A Sequence receiving `Running` from a child should also return `Running` to the parent, preserving the in-progress state across ticks.

2. **Ticking too frequently**: Behavior trees for NPC AI do not need 60 Hz. Tick at 0.1-0.5 second intervals. Heavy logic in leaf nodes at high tick rates causes server lag.

3. **Blackboard bloat**: Storing large data structures (full player lists, path arrays) in the blackboard every tick wastes memory. Store references and indices, not copies.

4. **Forgetting to reset blackboard state**: A condition node that sets `bb.target` should clear it when the condition fails. Otherwise stale target references persist across ticks.

5. **Deep trees without debugging tools**: Trees deeper than 4-5 levels become hard to reason about without visualization. Use the BTreesV5 plugin or log each node's tick result during development.

6. **Mixing client and server in the tree**: All NPC behavior tree logic must run on the server. Client-side behavior trees are only appropriate for cosmetic-only NPCs with no gameplay impact.

7. **No Selector fallback**: A tree with only Sequences and no Selector has no fallback behavior. If any condition fails, the NPC does nothing. Always provide a fallback (patrol, idle) as the last child of the root Selector.

## Related

- [[npc-ai-system]] -- FSM-based NPC AI (simpler alternative)
- [[pathfinding-system]] -- Pathfinding used in chase/patrol actions
- [[boss-patterns]] -- Phase-based AI for bosses
- [[state-machine-pattern]] -- FSM pattern for comparison

## Sources

- [BehaviourTree.lua Library](wiki/raw/community/articles/game-mechanics/behaviour-tree-lua.md)
- [Enemy AI System with SimplePath](wiki/raw/community/articles/game-mechanics/enemy-ai-system-simplepath.md)
- [General Combat NPC Tutorial](wiki/raw/community/articles/game-mechanics/combat-npc-tutorial.md)
- [GitHub: behaviortree.rbxlua](https://github.com/seyaidev/behaviortree.rbxlua)
- [GitHub: behaviourtree.lua](https://github.com/tanema/behaviourtree.lua)
- [DevForum: Behaviour Trees In-Depth Tutorial](https://devforum.roblox.com/t/how-to-use-behaviour-trees-to-create-enemy-npcs-in-depth-tutorial/3326581)
- [DevForum: Behavior Trees for NPC](https://devforum.roblox.com/t/tutorial-for-how-i-use-behavior-trees-for-my-npc/2806049)
