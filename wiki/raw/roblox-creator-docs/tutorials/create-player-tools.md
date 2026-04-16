---
title: Create Player Tools
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/intermediate-scripting/create-player-tools
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, scripting, tools, backpack, starterpack, sound, equipped, activated, localscript]
difficulty: intermediate
---

# Create Player Tools

Tools are a simple way to manage items that the player can hold in their hand and use in-game. They can range from weapons such as swords to food items.

In this tutorial, you'll learn how to create a tool in the shape of a laser blaster that will play sound effects when equipped or activated.

## Steps

### Create the tool

The `Tool` object is the basis of any tool in Roblox. It's easier to change how tools look by adding objects such as Parts and MeshParts to the tool in the workspace where they are visible.

1. Insert a **Tool** into the workspace and name it **Blaster**.
2. Insert a `MeshPart` into the tool.
3. Set the **MeshId** property to `rbxassetid://92656610`.
4. Set the **TextureId** property to `rbxassetid://92658105`.
5. The tool needs a part named **Handle** for the player to hold. Change the name of the MeshPart to **Handle**.

> **Warning:** If you don't include a part named **Handle** in the tool, it will drop to the ground when a player tries to equip it.

### Store the tool

Tools can be kept in the 3D world as **collectable tools** or given to all players as **starter tools**.

**Collectable tool:**
The blaster as a child of **Workspace** is collectable. A player picks up the tool by touching it, causing it to become a child of the character model; the tool is then equipped and placed in their hotbar.

Unequipped tools are stored in the player's **Backpack** and moved to their character model when equipped.

**Starter tool:**
Storing a tool in `StarterPack` will place it in a player's `Backpack` when they join or respawn.

1. Move the **Blaster** to **StarterPack**.
2. Play the experience. Click on the hotbar or press **1** to equip.

### Tool properties

**Position / orientation:**
A tool's position and orientation can be changed using the **grip** properties:
- **GripPos**: Position of the grip
- **GripForward / GripRight / GripUp**: Rotation

Example: Set the **GripPos** property of the tool to `0, -0.4, 1.1`.

**Hotbar icon:**
Set the **TextureId** property of the tool to `rbxassetid://92628145` for an image icon.

**Tooltip:**
A tooltip appears when the mouse hovers over a tool in the hotbar. Change the **ToolTip** property to **Blaster**.

### Use scripts with tools

A tool has three key events you can connect to:

| Event | Description |
|---|---|
| `Equipped` | Fired when a tool is equipped (selected in hotbar) |
| `Unequipped` | Fired when a tool is unequipped (deselected in hotbar) |
| `Activated` | Fired when a tool is activated (e.g., left-click) |

> These events only work in `LocalScripts` because only the player's device knows when input happens.

### Add the sounds

1. Insert two `Sound` objects into the **Handle**.
2. Rename one sound **Equip** and set its SoundId property to `rbxassetid://282906960`.
3. Rename the other sound **Activate** and set its SoundId property to `rbxassetid://130113322`.

### Add the code

1. Insert a **LocalScript** into the tool and name it **ToolController**.
2. Add this code:

```lua
local tool = script.Parent

local function toolEquipped()
    tool.Handle.Equip:Play()
end

local function toolActivated()
    tool.Handle.Activate:Play()
end

tool.Equipped:Connect(toolEquipped)
tool.Activated:Connect(toolActivated)
```

3. Test the blaster sound effects by equipping and clicking to activate the tool.

## Key Concepts

- **Tool**: Object that can be equipped in a player's hand
- **Handle**: Required named Part for the tool; player grips this
- **Backpack**: Player's inventory of unequipped tools
- **StarterPack**: Auto-populates every player's Backpack on join/respawn
- **GripPos / GripForward / GripRight / GripUp**: Control how the tool sits in the hand
- **TextureId**: Icon displayed in the hotbar
- **ToolTip**: Hover text on the hotbar icon
- **Tool.Equipped / Unequipped / Activated**: LocalScript-only events
- **Tools under Workspace**: Collectable by touch
- **Tools under StarterPack**: Given to every player

## Code Snippets

### Basic tool controller

```lua
local tool = script.Parent

local function toolEquipped()
    tool.Handle.Equip:Play()
end

local function toolActivated()
    tool.Handle.Activate:Play()
end

tool.Equipped:Connect(toolEquipped)
tool.Activated:Connect(toolActivated)
```

## Notes

- Must include a part named `Handle` or the tool drops to ground
- LocalScripts only for Tool events (input is client-side)
- Adjust `GripPos` to position the tool in the player's hand
- Tools in `Workspace` = pickupable; tools in `StarterPack` = automatic

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/intermediate-scripting/create-player-tools
Captured: 2026-04-16
