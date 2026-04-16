---
title: Roblox Lua Style Guide - Keep code clean and consistent
type: raw-source
source_url: https://devforum.roblox.com/t/roblox-lua-style-guide-keep-code-clean-and-consistent/415376
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: AIasdair
post_date: 2019-12-23
tags: [style-guide, lua, naming-conventions, best-practices, formatting]
---

# Roblox Lua Style Guide: Keep code clean and consistent

**Author:** AIasdair (Joseph)
**Posted:** December 23, 2019

## Overview

> "This is a guide about Lua code style. It's important to keep all code consistent across scripts, especially when working in teams."

The guide references two sources: Roblox's official style guide and Olivine Labs' Lua style guide.

## File Structure

Files should organize content in this sequence:
1. Services via `GetService`
2. Module imports
3. Constants
4. Variables and Functions

## Variables and Naming Conventions

**Key Rules:**
- "Always try to assign variables at the top of their scope whenever possible"
- Always use `local` for variable declarations
- File names should match exported object names
- Spell out words fully rather than abbreviating
- Use `camelCase` for local variables
- Use `Upper_Snake_Case` for local constants
- Use `PascalCase` for everything else

**Example:**
```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Running_Velocity = 50
local Walking_Velocity = 25

local isWalking = false
local isRunning = false

local PlayerCharacter = {}

local function PlayerCharacter.IsMoving()
    return isRunning or isWalking
end
```

## Tables

**Principles:**
- "Avoid tables with both list-like and dictionary-like keys"
- Use `ipairs` for list-like tables; `pairs` for dictionary-like
- Break multi-key dictionaries across multiple lines
- Use constructor syntax for table creation
- Define functions externally to table definitions

**Good Practice:**
```lua
local Inventory = {
    backpack = {},
    belt = {},
    primaryWeapon = "Hatchet",
}
```

```lua
local Beans = {
    quality = 90
    hungerRefill = 80
    thirstRefill = 10
}

function Beans:eat()
    -- EAT DEM BEANS!!!
end
```

## Functions

**Core Guidelines:**
- "Declare functions using `local` whenever possible"
- "Keep functions as small, and as focused on one goal as humanly possible"
- "Most important!" for code organization
- Limit function arguments
- Use `:` for functions calling events/actions; `.` for value-returning functions
- Prefer function syntax over variable assignment syntax
- Perform validation as early as possible

**Example - Calling Convention Differentiation:**
```lua
Pet = {}

function Pet:walkTo(position)
    -- walks the pet to position
end

function Pet.getName()
    -- returns the pet's name
end
```

**Early Validation Pattern:**
```lua
local canRunNewFunction = false

local function newFunction()
    if not canRunNewFunction then return end

    print("Running newFunction")
end
```

## Code Blocks

- Small single-line blocks acceptable; maintain 80-character limit
- Use `do` blocks for variable scope limitation

```lua
local getId
do
    local lastId = 0
    function getId()
        lastId = lastId + 1
        return lastId
    end
end
```

## Strings

- Use double quotes for most strings
- Bracket notation for strings containing quotation marks
- Split strings exceeding 80 characters across lines using concatenation

```lua
superLongString = "This is a super long string that "..
    "I am writing for the purpose of "..
    "this resource. As you can see, "..
    "it is not on one line and is much"..
    "easier to read!"
```

## Whitespace

**Standards:**
- "Always use proper indentation with tabs"
- Avoid trailing whitespace
- One statement per line
- No vertical alignment
- Use single empty lines between logical groups
- Space before/after operators
- Space after commas
- Inline opening syntax with blocks

```lua
function add(a, b)
    return a + b
end
```

```lua
local foo = {
    bar = 2,
}

if foo then
    -- do something
end
```

## Source

Original URL: https://devforum.roblox.com/t/roblox-lua-style-guide-keep-code-clean-and-consistent/415376
Captured: 2026-04-16
