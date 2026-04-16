---
title: ContextActionService
type: service
category: services
subcategory: input
owner: ui-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/ContextActionService.md
related:
  - "[[UserInputService]]"
  - "[[ProximityPrompt]]"
tags: [roblox-class, input]
---

# ContextActionService

> Binds user input to contextual actions that are only enabled under specific conditions. [[UserInputService]]

## Summary

ContextActionService allows an experience to bind user input to **contextual actions** -- actions that are only enabled during a certain condition or period of time. For example, allowing a player to open a door only while close by, or honking a car horn only while seated. An action is identified by a unique string name.

The key advantage over raw [[UserInputService]] is the **action binding stack**: if two actions are bound to the same input, the most recently bound action handler runs first. When it is unbound, the previous one takes control again. This eliminates complex conditional checks for "is the player in the right context for this input?". Since it deals with user input, ContextActionService can only be used in client-side LocalScripts.

ContextActionService is especially useful for cross-platform input. A single `BindAction` call can bind a keyboard key, gamepad button, and auto-create a touch screen button simultaneously, making it the preferred approach for games targeting multiple device types.

## API Surface

### Properties

_No public properties._

### Methods

- `:BindAction(actionName: string, handler: Function, createTouchButton: boolean, ...inputTypes: Enum) -> ()` -- Binds a handler to input types. Handler receives `(actionName, inputState, inputObject)`.
- `:BindActionAtPriority(actionName: string, handler: Function, createTouchButton: boolean, priorityLevel: number, ...inputTypes: Enum) -> ()` -- Like BindAction but with explicit priority (higher runs first, overriding stack order).
- `:UnbindAction(actionName: string) -> ()` -- Unbinds an action by name. Does not error if the action does not exist.
- `:UnbindAllActions() -> ()` -- Removes all bound actions and touch buttons.
- `:GetButton(actionName: string) -> ImageButton?` -- Returns the touch button created by BindAction (yields). Returns nil if no button exists.
- `:GetBoundActionInfo(actionName: string) -> Dictionary` -- Returns info about a bound action (stackOrder, priorityLevel, inputTypes, etc.).
- `:GetAllBoundActionInfo() -> Dictionary` -- Returns info for all bound actions.
- `:SetImage(actionName: string, image: string) -> ()` -- Sets the image on the action's touch button.
- `:SetTitle(actionName: string, title: string) -> ()` -- Sets the text on the action's touch button.
- `:SetPosition(actionName: string, position: UDim2) -> ()` -- Sets the position of the action's touch button.
- `:SetDescription(actionName: string, description: string) -> ()` -- Sets a text description for the action (metadata only, does not affect the touch button).
- `:BindActivate(userInputType: Enum.UserInputType, ...keyCodes: Enum.KeyCode) -> ()` -- Binds a KeyCode to trigger Tool activation.
- `:UnbindActivate(userInputType: Enum.UserInputType, keyCode: Enum.KeyCode?) -> ()` -- Unbinds a Tool activation binding.

### Events

- `.LocalToolEquipped:Connect(fn(toolEquipped: Instance))` -- Fires when the current player equips a Tool.
- `.LocalToolUnequipped:Connect(fn(toolUnequipped: Instance))` -- Fires when the current player unequips a Tool.

## Budgets and Limits

- Maximum of **7 touch buttons** can be created through BindAction at once.
- Action handler return values: `Enum.ContextActionResult.Sink` (or `nil`) consumes the input; `Enum.ContextActionResult.Pass` passes it down the stack.

## Common Patterns

### Cross-platform action binding

```lua
local ContextActionService = game:GetService("ContextActionService")

local ACTION_NAME = "HonkHorn"

local function handleAction(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        -- Play horn sound
    elseif inputState == Enum.UserInputState.End then
        -- Stop horn sound
    end
end

-- Bind when player enters car
ContextActionService:BindAction(
    ACTION_NAME,
    handleAction,
    true, -- create touch button
    Enum.KeyCode.H,
    Enum.KeyCode.ButtonY
)

-- Unbind when player exits car
ContextActionService:UnbindAction(ACTION_NAME)
```

### Priority-based override

```lua
-- Default movement bound at default priority (2000)
-- Override specific key at higher priority
ContextActionService:BindActionAtPriority(
    "SpecialAbility",
    abilityHandler,
    false,
    3000, -- higher than default
    Enum.KeyCode.W
)
```

## Pitfalls

- **Name your actions semantically**: Use `"CarHorn"` not `"KeyH"`. The name should describe the action, not the input.
- **Stack conflicts**: Default camera and movement scripts bind common keys (WASD, right-click). Your actions may be overridden if those scripts run after yours. Check the "Action Bindings" tab in the Developer Console (F9) to debug.
- **Touch button limits**: Only 7 simultaneous touch buttons. For richer mobile UI, create custom `ImageButton`/`TextButton` instances instead.
- **Cancel state**: When a bound action is overridden or unbound while input is in progress, the handler receives `Enum.UserInputState.Cancel` with `Enum.KeyCode.Unknown`.
- **Deprecated**: `BindActionToInputTypes` is deprecated; use `BindAction` instead.

## Related

- [[UserInputService]] -- lower-level input API (global, not contextual)
- [[ProximityPrompt]] -- built-in contextual interaction UI

## Sources

- [wiki/raw/roblox-creator-docs/services/ContextActionService.md](../raw/roblox-creator-docs/services/ContextActionService.md)
