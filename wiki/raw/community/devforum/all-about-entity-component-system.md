---
title: All about Entity Component System
type: raw-source
source_url: https://devforum.roblox.com/t/all-about-entity-component-system/1664447
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: Ukendio (Marcus)
post_date: 2022-02-12
tags: [ecs, matter, composition, oop-alternative, tutorial]
---

# All about Entity Component System

**Author:** Ukendio (Marcus)
**Posted:** February 12, 2022

## Core Concept

ECS provides infrastructure where distinct objects consist of unique entity IDs paired with pure data components, manipulated by systems containing behavior logic. This contrasts with OOP's object-centric inheritance approach.

## Key Problem Solved

Traditional OOP inheritance creates complexity with multiple inheritance scenarios (the "diamond problem"). ECS resolves this through composition—entities gain capabilities by adding components rather than inheriting from classes.

Per Ukendio:
> "Think of what specific data a _thing_ contains instead of what that thing _is_."

## Practical Example: Float Planes

To create a vehicle that both flies and floats using OOP requires inheriting from conflicting parent classes. With ECS, simply add a `Fly` component for aerial movement and a `Float` component for water dynamics to the same entity.

## Implementation in Roblox (Matter Library)

**Basic setup:**
```lua
local world = Matter.World.new()
local Velocity = Matter.component("Velocity")
local Renderable = Matter.component("Renderable")

local arrow = world:spawn(
    Velocity({ speed = 50}),
    Renderable({ model = arrowModel })
)
```

**Query and system execution:**
```lua
local function arrowsFly(world)
    for id, vel, render in world:query(Velocity, Renderable) do
        render.model:PivotTo(CFrame.new(
            currentPosition + Vector3.new(vel.speed * Matter.useDeltaTime(), 0, 0)
        ))
    end
end
```

## When to Use ECS

ECS excels when games have overlapping, complex behaviors across many entities. It's less beneficial for simpler projects with limited object interaction.

## Source

Original URL: https://devforum.roblox.com/t/all-about-entity-component-system/1664447
Captured: 2026-04-16
