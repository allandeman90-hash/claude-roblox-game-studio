---
title: "MVC: A Practical Approach Towards Developing Games"
type: raw-source
source_url: https://devforum.roblox.com/t/mvc-a-practical-approach-towards-developing-games-and-how-to-stop-confusing-yourself-with-ecs-vs-oop/3026159
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: uatemycookie22
post_date: 2024-06-16
tags: [mvc, architecture, oop, ecs, game-design, patterns]
---

# MVC: A Practical Approach to Game Development on Roblox

**Author:** uatemycookie22
**Posted:** June 16, 2024

## Overview

This tutorial addresses confusion between OOP, ECS, and MVC paradigms in Roblox game development. The core argument is that these architectural patterns should guide thinking rather than dictate rigid implementations.

## The Central Problem

The post follows "Lee," a developer who initially embraces OOP, then switches to ECS, only to find both approaches problematic when applied dogmatically. The key insight:

> "too much theory does not convert well when you put it into practice."

## Key Misconceptions Addressed

1. **OOP and ECS are mutually exclusive** — they work better combined through multi-paradigm approaches
2. **Lua OOP is universally bad** — it serves specific cases well (like NPC abstractions)
3. **Frameworks always improve development** — dependencies risk obsolescence and limited transferability

## MVC Architecture Explained

The pattern separates code into three layers:

| Layer | Purpose |
|-------|---------|
| **Controller** | Business logic; updates game state |
| **Model** | Internal state storage |
| **View** | Presentation layer (what players see) |

## Practical Implementation Example

```lua
-- LootService.lua (Model)
local module = {}
module.LootDrops = {}

function module.SpawnLoot(origin, lootItems)
    -- ...
end

function module.GetLootFromItemId(itemId)
    -- ...
end

return module
```

## Core Recommendation

The author advocates "simplicity over complexity" and leverages Roblox's native event-driven programming paradigm, using MVC with standard modules rather than heavyweight frameworks.

## Source

Original URL: https://devforum.roblox.com/t/mvc-a-practical-approach-towards-developing-games-and-how-to-stop-confusing-yourself-with-ecs-vs-oop/3026159
Captured: 2026-04-16
