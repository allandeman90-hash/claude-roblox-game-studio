---
title: Object Properties
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/fundamentals/coding-1/object-properties
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, scripting, properties, color3, comments, explorer, dot-notation]
difficulty: beginner
---

# Object Properties

This tutorial teaches how to modify Roblox object properties using Luau scripting. Properties control how objects look and function. Each object in Roblox Studio has its own set of properties.

## Steps

### Access properties

Properties are available in the **Properties** window for each selected object. Common properties include:
- **BrickColor** / **Color**: Visual color
- **Size**: Dimensions (X, Y, Z)
- **Material**: Physical material (Plastic, Wood, Neon, etc.)
- **Transparency**: 0 (opaque) to 1 (invisible)
- **Anchored**: Whether physics moves it
- **CanCollide**: Whether other parts pass through

### Comments in code

Comments are special lines starting with `--` that help coders remember what parts of scripts do.

```lua
-- This is a single-line comment

--[[
This is a multi-line comment
spanning multiple lines
]]
```

### Referencing objects with dot notation

To locate objects in your scripts, use the Explorer hierarchy and translate to dot notation:

```lua
-- Finds a part named PracticePart inside Workspace
local part = workspace.PracticePart
```

The `workspace` variable is equivalent to `game.Workspace`. Objects are accessed by their name property using dots.

### Changing color

Use `Color3.fromRGB()` with RGB values from 0 to 255:

```lua
local part = workspace.PracticePart
part.Color = Color3.fromRGB(0, 255, 0)  -- Green
```

You can also use `Color3.new(r, g, b)` with normalized values from 0 to 1:

```lua
part.Color = Color3.new(0, 1, 0)  -- Green
```

### Changing other properties

```lua
local part = workspace.PracticePart
part.Transparency = 0.5
part.Material = Enum.Material.Neon
part.Size = Vector3.new(10, 2, 10)
part.Anchored = true
```

## Key Concepts

- **Properties**: Control how objects look and function
- **Dot notation**: `workspace.PartName` to reference objects
- **`workspace`**: Shortcut for `game.Workspace`
- **Comments**: `--` for single-line, `--[[ ]]` for multi-line
- **Color3.fromRGB(r, g, b)**: Colors via 0-255 values
- **Color3.new(r, g, b)**: Colors via 0-1 normalized values
- **Enum.Material**: Preset materials (Plastic, Wood, Neon, Metal, etc.)
- **Vector3.new(x, y, z)**: Size and position vectors
- **Enum values**: Enumerated constants used in properties

## Notes

- Properties can be changed at runtime via scripts
- Autocomplete helps you explore available properties in Studio
- Use the color picker in Properties to find RGB values
- Always describe where to find objects in the Explorer hierarchy when referencing them

## Source

Original URL: https://create.roblox.com/docs/tutorials/fundamentals/coding-1/object-properties
Captured: 2026-04-16
