---
title: Detect User Input
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/input-and-camera/detect-user-input
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, input, contextactionservice, keybindings, tools, keycode]
difficulty: intermediate
---

# Detect User Input

Connecting user input to actions gives users much better and more intuitive control over your experience's features. In this tutorial, you will bind a reloading action to a specific key.

## Steps

### Get started

This tutorial uses the **Blaster** tool created in Create Player Tools. You can download the [Blaster](https://www.roblox.com/library/6571559694/Blaster) model and insert it into **StarterPack**.

To add a model to your experience:
1. In a browser, open the model page and click **Get** to add it to your inventory.
2. From Studio's Window menu or Home tab toolbar, open the Toolbox and select the **Inventory** tab.
3. Make sure the dropdown is on **My Models**.
4. Select the **Blaster** model to add it into the experience.

### Create an action handler

First, you'll need a function to handle when user input is detected.

1. Open the **ToolController** `LocalScript` inside of the Blaster.
2. Make a variable to store a name for the action:

```lua
local tool = script.Parent

local RELOAD_ACTION = "reloadWeapon"

local function toolEquipped()
    tool.Handle.Equip:Play()
end

local function toolActivated()
    tool.Handle.Activate:Play()
end

tool.Equipped:Connect(toolEquipped)
tool.Activated:Connect(toolActivated)
```

3. Create a function named `onAction` that receives three arguments: `actionName`, `inputState`, and `inputObject`:

```lua
local function onAction(actionName, inputState, inputObject)

end
```

4. Inside the function, check that the given `actionName` matches the reload action name and make sure `inputState` is `Enum.UserInputState.Begin`:

```lua
local function onAction(actionName, inputState, inputObject)
    if actionName == RELOAD_ACTION and inputState == Enum.UserInputState.Begin then

    end
end
```

5. Change the `TextureId` of the tool to signal a reload:

```lua
local function onAction(actionName, inputState, inputObject)
    if actionName == RELOAD_ACTION and inputState == Enum.UserInputState.Begin then
        tool.TextureId = "rbxassetid://6593020923"
        task.wait(2)
        tool.TextureId = "rbxassetid://92628145"
    end
end
```

### Bind the action

`ContextActionService` can be used to **bind** a function to a specific input by using the `BindAction` function, which accepts several arguments:

- The name of the action
- The function to handle the action (also called a "callback")
- Whether or not a touchscreen button should be displayed
- Any amount of `Enum.KeyCodes` to detect and associate with the action

```lua
local ContextActionService = game:GetService("ContextActionService")

local tool = script.Parent
local RELOAD_ACTION = "reloadWeapon"

local function onAction(actionName, inputState, inputObject)
    if actionName == RELOAD_ACTION and inputState == Enum.UserInputState.Begin then
        tool.TextureId = "rbxassetid://6593020923"
        task.wait(2)
        tool.TextureId = "rbxassetid://92628145"
    end
end

local function toolEquipped()
    ContextActionService:BindAction(RELOAD_ACTION, onAction, true, Enum.KeyCode.R)
    tool.Handle.Equip:Play()
end
```

### Unbind the action

When the user unequips the tool, the action needs to be **unbound** so they can't reload without the tool being equipped.

```lua
local function toolUnequipped()
    ContextActionService:UnbindAction(RELOAD_ACTION)
end

tool.Equipped:Connect(toolEquipped)
tool.Unequipped:Connect(toolUnequipped)
tool.Activated:Connect(toolActivated)
```

## Key Concepts

- **ContextActionService**: Central service for binding input to actions
- **`BindAction(name, handler, createTouchButton, ...keyCodes)`**: Registers a handler
- **`UnbindAction(name)`**: Removes a binding
- **Action handler signature**: `(actionName, inputState, inputObject)`
- **`Enum.UserInputState.Begin`**: Fires when input starts
- **`Enum.UserInputState.Change`**: Fires during hold
- **`Enum.UserInputState.End`**: Fires when input releases
- **`Enum.KeyCode`**: Keyboard keys, gamepad buttons
- **Touch buttons**: Set to `true` to auto-create a mobile button
- **Tool.Equipped / Tool.Unequipped**: Lifecycle events for Tools

## Code Snippets

### Complete reload binding

```lua
local ContextActionService = game:GetService("ContextActionService")

local tool = script.Parent
local RELOAD_ACTION = "reloadWeapon"

local function onAction(actionName, inputState, inputObject)
    if actionName == RELOAD_ACTION and inputState == Enum.UserInputState.Begin then
        tool.TextureId = "rbxassetid://6593020923"
        task.wait(2)
        tool.TextureId = "rbxassetid://92628145"
    end
end

local function toolEquipped()
    ContextActionService:BindAction(RELOAD_ACTION, onAction, true, Enum.KeyCode.R)
    tool.Handle.Equip:Play()
end

local function toolUnequipped()
    ContextActionService:UnbindAction(RELOAD_ACTION)
end

local function toolActivated()
    tool.Handle.Activate:Play()
end

tool.Equipped:Connect(toolEquipped)
tool.Unequipped:Connect(toolUnequipped)
tool.Activated:Connect(toolActivated)
```

## Notes

- Always check `inputState == Enum.UserInputState.Begin` to avoid duplicate firings
- Bind inputs only while the tool is equipped — unbind on unequip
- Setting `createTouchButton` to `true` auto-creates a mobile-friendly button
- You can pass multiple KeyCodes for the same action (keyboard + gamepad)
- Prefer `ContextActionService` over `UserInputService` for context-scoped bindings

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/input-and-camera/detect-user-input
Captured: 2026-04-16
