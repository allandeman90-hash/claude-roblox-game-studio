---
title: How to use Parallel Luau
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-use-parallel-luau/1176605
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: CoderHusk
post_date: 2021-04-19
tags: [parallel-luau, actors, multi-threading, performance, task-library]
---

# How to Use Parallel Luau

**Author:** CoderHusk
**Posted:** April 19, 2021

## Core Concept

Parallel Luau enables multi-threaded code execution on CPU cores. CoderHusk explains:

> "All Parallel Luau does is run code multi threaded on your cpu."

## Setup Requirements

1. Enable Parallel Luau in beta features
2. Create an Actor instance as a parent for scripts with parallel capabilities

## Key Implementation Patterns

**Actor Creation:**
```lua
local p = Instance.new("Actor")
p.Parent = game.StarterGui
```

**Parallel Event Connection:**
```lua
local bindable = Instance.new("BindableEvent")
bindable.Parent = script.Parent
bindable.Event:ConnectParallel(function()
    local data = {}
    for i = 1, 1000 do
       data[i] = i * i
    end
end)
bindable:Fire()
```

## Critical Functions

- **`ConnectParallel`** — Executes functions multi-threaded
- **`task.synchronize()`** — Transitions from parallel to serial execution, enabling write access to game objects
- **`task.desynchronize()`** — Returns to multi-threaded operation

## Practical Use Case

The tutorial demonstrates switching between parallel computation-heavy tasks and serial operations for GUI updates, allowing developers to optimize performance-critical code sections while maintaining safe object access.

## Source

Original URL: https://devforum.roblox.com/t/how-to-use-parallel-luau/1176605
Captured: 2026-04-16
