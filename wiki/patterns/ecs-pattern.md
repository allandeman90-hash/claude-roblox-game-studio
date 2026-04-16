---
title: ECS Pattern
type: pattern
category: patterns
subcategory: architecture
owner: lead-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/game-patterns/ecs-tutorial-matter.md
  - wiki/raw/community/articles/game-patterns/jecs-ecs-library.md
related:
  - "[[state-machine-pattern]]"
  - "[[round-system]]"
tags: [pattern, ECS, entity-component-system, data-oriented, Matter, Jecs, architecture]
---

# ECS Pattern

> Entity Component System -- a data-oriented architecture where game objects are unique IDs (entities), data is stored in typed containers (components), and behavior is defined by functions (systems) that query entities by component combination.

## Summary

ECS replaces deep OOP inheritance hierarchies with flat composition. Instead of a `FlyingFireEnemy` class inheriting from `FlyingEnemy` inheriting from `Enemy` inheriting from `Character`, an entity simply has `Position`, `Velocity`, `Flying`, `Fire`, and `Health` components. Systems like `movementSystem` and `fireSystem` independently process any entity that has the relevant components.

On Roblox, two ECS libraries dominate: **Matter** (established, event-driven, good debugger) and **Jecs** (newer, faster archetype-based storage, entity relationships). A custom lightweight ECS is also viable for simpler games.

## When to Use It

- Games with many entities sharing overlapping behaviors (tower defense, survival, factory games).
- When the same behavior (damage, movement, rendering) applies to diverse entity types (players, NPCs, projectiles, traps).
- When you expect frequent additions of new entity types or behaviors without refactoring.
- Performance-sensitive loops iterating over thousands of entities per frame.

Not ideal for: simple games with few entity types, prototyping (OOP is faster to iterate), or when the team is unfamiliar with data-oriented design.

## Implementation

### Matter (Established ECS)

```lua
-- ServerScriptService/Systems/init.server.lua
local Matter = require(game.ReplicatedStorage.Packages.Matter)
local RunService = game:GetService("RunService")

-- Create world
local world = Matter.World.new()

-- Define components (pure data, no methods)
local Position = Matter.component("Position")     -- { x, y, z }
local Velocity = Matter.component("Velocity")     -- { x, y, z }
local Health = Matter.component("Health")          -- { current, max }
local Renderable = Matter.component("Renderable")  -- { model }
local Enemy = Matter.component("Enemy")            -- { tag component }
local Projectile = Matter.component("Projectile")  -- { damage, owner }

-- Spawn an enemy
local goblin = world:spawn(
    Position({ x = 0, y = 5, z = 0 }),
    Velocity({ x = 0, y = 0, z = 0 }),
    Health({ current = 100, max = 100 }),
    Renderable({ model = goblinModel }),
    Enemy({})
)

-- Spawn a projectile
local arrow = world:spawn(
    Position({ x = 10, y = 5, z = 0 }),
    Velocity({ x = -50, y = 0, z = 0 }),
    Renderable({ model = arrowModel }),
    Projectile({ damage = 25, owner = playerId })
)
```

### Systems (Functions That Query the World)

```lua
-- Movement system: applies to ANYTHING with Position + Velocity
local function movementSystem(world)
    for id, pos, vel in world:query(Position, Velocity) do
        local dt = Matter.useDeltaTime()
        world:insert(id, Position({
            x = pos.x + vel.x * dt,
            y = pos.y + vel.y * dt,
            z = pos.z + vel.z * dt,
        }))
    end
end

-- Render system: syncs ECS position to Roblox model
local function renderSystem(world)
    for id, pos, render in world:query(Position, Renderable) do
        if render.model and render.model.PrimaryPart then
            render.model:PivotTo(CFrame.new(pos.x, pos.y, pos.z))
        end
    end
end

-- Damage system: projectiles hitting enemies
local function damageSystem(world)
    for projId, projPos, proj in world:query(Position, Projectile) do
        for enemyId, enemyPos, health in world:query(Position, Health) do
            local dist = ((projPos.x - enemyPos.x)^2
                        + (projPos.y - enemyPos.y)^2
                        + (projPos.z - enemyPos.z)^2) ^ 0.5
            if dist < 3 then
                world:insert(enemyId, Health({
                    current = health.current - proj.damage,
                    max = health.max,
                }))
                world:despawn(projId)
                break
            end
        end
    end
end

-- Death system: remove entities at 0 health
local function deathSystem(world)
    for id, health, render in world:query(Health, Renderable) do
        if health.current <= 0 then
            if render.model then render.model:Destroy() end
            world:despawn(id)
        end
    end
end
```

### Running the Loop

```lua
local loop = Matter.Loop.new(world)
loop:scheduleSystems({
    movementSystem,
    renderSystem,
    damageSystem,
    deathSystem,
})

loop:begin({
    default = RunService.Heartbeat,
})
```

### Jecs (High-Performance Alternative)

```lua
local jecs = require(game.ReplicatedStorage.Packages.jecs)
local world = jecs.World.new()

-- Components are typed IDs
local Position = world:component() :: jecs.Id<Vector3>
local Velocity = world:component() :: jecs.Id<Vector3>
local Health = world:component() :: jecs.Id<{current: number, max: number}>
local Damage = world:component() :: jecs.Id<number>

-- Spawn entity
local entity = world:entity()
world:set(entity, Position, Vector3.new(0, 5, 0))
world:set(entity, Velocity, Vector3.zero)
world:set(entity, Health, {current = 100, max = 100})

-- Query and process
local function moveSystem(dt: number)
    for e, pos, vel in world:query(Position, Velocity) do
        world:set(e, Position, pos + vel * dt)
    end
end
```

### Entity Relationships (Jecs)

```lua
-- Hierarchical ownership: bullets belong to players
local pair = jecs.pair
local OwnedBy = world:entity()

local bullet = world:entity()
world:set(bullet, Position, Vector3.new(0, 5, 0))
world:set(bullet, Damage, 25)
world:add(bullet, pair(OwnedBy, playerEntity))

-- Query: "all bullets owned by a specific player"
for e, pos, dmg in world:query(Position, Damage, pair(OwnedBy, playerEntity)) do
    -- process this player's bullets
end
```

## Matter vs Jecs Comparison

| Feature | Matter | Jecs |
|---------|--------|------|
| **Storage** | Archetype-based | Archetype/SoA (column-major) |
| **Performance** | Good | Faster (800K entities at 60fps) |
| **Entity relationships** | No | Yes (first-class) |
| **Event handling** | `useEvent` hook | Manual |
| **Debugger** | Built-in Plasma debugger | Via external tools |
| **Maturity** | Established, widely used | Newer, rapidly evolving |
| **Dependencies** | Some | Zero |
| **API style** | Functional (hooks) | Imperative (world methods) |

## When to Use Which

- **Matter**: Team already familiar with it, need debugger UI, moderate entity counts (<50K).
- **Jecs**: Need entity relationships, high entity counts (100K+), performance-critical loops, zero-dependency requirement.
- **Custom lightweight**: Simple games with <1K entities, want to avoid dependency, educational.

## Pitfalls

- **Overengineering.** ECS is not a god-pattern. For a game with 3 enemy types and 1 projectile type, OOP is simpler and faster to develop.
- **Roblox instance management.** ECS manages data, but Roblox models live in the DataModel. A render/sync system must bridge ECS state to Roblox instances. Forgetting this causes invisible entities or orphaned models.
- **Component data is immutable in Matter.** You replace components, not mutate them. `world:insert(id, Health({...}))` creates a new component record. This is by design but surprises OOP developers.
- **System ordering.** Systems execute in schedule order. Damage before death means entities process damage and die in the same frame. Death before damage means dead entities might still take hits. Define execution order deliberately.
- **Server/client split.** Run authoritative systems (damage, health, spawning) on the server. Run visual-only systems (particles, animations) on the client. Replicate the minimum component data needed.

## Related

- [[state-machine-pattern]] -- alternative for entities with sequential behavioral phases
- [[round-system]] -- game-level state management (often uses FSM, not ECS)

## Sources

- [All About Entity Component System (Matter)](wiki/raw/community/articles/game-patterns/ecs-tutorial-matter.md)
- [Jecs: Fast ECS for Luau](wiki/raw/community/articles/game-patterns/jecs-ecs-library.md)
