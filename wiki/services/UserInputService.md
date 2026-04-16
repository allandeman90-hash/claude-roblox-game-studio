---
title: UserInputService
type: service
category: services
subcategory: input
owner: ui-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/UserInputService.md
related:
  - "[[ContextActionService]]"
tags: [roblox-class, input, client-only]
---

# UserInputService

> Client-side service for detecting device capabilities and raw input events. [[ContextActionService]]

## Summary

UserInputService is the primary service for detecting what input devices are available on a user's device and for receiving raw input events. It allows games to adapt behavior based on whether the player is using a keyboard, mouse, touch screen, gamepad, or VR headset.

The service fires events for all input types: `InputBegan`, `InputChanged`, and `InputEnded` are the core events that provide an `InputObject` describing what happened. Device capability detection properties (`KeyboardEnabled`, `TouchEnabled`, `GamepadEnabled`, `VREnabled`) allow branching UI and control schemes per platform. The `PreferredInput` property more accurately reflects which input method the player is actively using.

Since this service deals with user input, it can **only be used in client-side code** (LocalScripts or client-context Scripts). For contextual input binding that works across platforms, prefer [[ContextActionService]], which handles the input stack and touch button generation automatically.

## API Surface

### Properties (key subset)

- `KeyboardEnabled: boolean` -- Whether a keyboard is available (read-only).
- `MouseEnabled: boolean` -- Whether a mouse is available (read-only).
- `TouchEnabled: boolean` -- Whether a touch screen is available (read-only).
- `GamepadEnabled: boolean` -- Whether a gamepad is connected (read-only).
- `VREnabled: boolean` -- Whether a VR headset is active (read-only).
- `PreferredInput: Enum.UserInputType` -- The input type the player is most likely using as primary input.
- `MouseBehavior: Enum.MouseBehavior` -- Controls mouse lock behavior (Default, LockCenter, LockCurrentPosition).
- `MouseIcon: string` -- Custom cursor image asset ID. Empty string for default.
- `MouseIconEnabled: boolean` -- Whether the mouse cursor is visible.
- `MouseDeltaSensitivity: float` -- Mouse sensitivity multiplier (1-10).
- `ModalEnabled: boolean` -- When true, touch input is consumed by GUI elements only (no 3D interaction).

### Methods (key subset)

- `:IsKeyDown(keyCode: Enum.KeyCode) -> boolean` -- Whether a specific key is currently pressed.
- `:IsMouseButtonPressed(mouseButton: Enum.UserInputType) -> boolean` -- Whether a mouse button is pressed.
- `:IsGamepadButtonDown(gamepad: Enum.UserInputType, button: Enum.KeyCode) -> boolean` -- Whether a gamepad button is pressed.
- `:GetKeysPressed() -> {InputObject}` -- Returns all currently pressed keys.
- `:GetMouseLocation() -> Vector2` -- Returns the mouse position in screen coordinates (accounts for inset).
- `:GetMouseDelta() -> Vector2` -- Returns mouse movement since last frame (for mouse-lock modes).
- `:GetLastInputType() -> Enum.UserInputType` -- Returns the most recent input type used.
- `:GetConnectedGamepads() -> {Enum.UserInputType}` -- Returns an array of connected gamepads.
- `:GetGamepadState(gamepad: Enum.UserInputType) -> {InputObject}` -- Returns the current state of all inputs on a gamepad.
- `:GetFocusedTextBox() -> TextBox?` -- Returns the TextBox that currently has focus, or nil.

### Events

- `.InputBegan:Connect(fn(input: InputObject, gameProcessedEvent: boolean))` -- Fires when an input begins (key press, mouse click, touch start). `gameProcessedEvent` is true if the input was consumed by a GUI element.
- `.InputChanged:Connect(fn(input: InputObject, gameProcessedEvent: boolean))` -- Fires when an input changes (mouse move, scroll, gamepad stick).
- `.InputEnded:Connect(fn(input: InputObject, gameProcessedEvent: boolean))` -- Fires when an input ends (key release, touch end).
- `.LastInputTypeChanged:Connect(fn(lastInputType: Enum.UserInputType))` -- Fires when the player switches input methods (e.g., keyboard to gamepad).
- `.JumpRequest:Connect(fn())` -- Fires when the player requests a jump (spacebar, touch jump button).
- `.TouchStarted / .TouchMoved / .TouchEnded` -- Touch-specific events with position data.
- `.TouchPinch / .TouchRotate / .TouchPan / .TouchSwipe / .TouchTap / .TouchLongPress` -- Gesture events.
- `.GamepadConnected / .GamepadDisconnected` -- Fires when gamepads are added/removed.
- `.WindowFocused / .WindowFocusReleased` -- Fires when the game window gains/loses focus.

## Budgets and Limits

No explicit rate limits. Input events fire at the engine's frame rate (typically 60 Hz). High-frequency input processing should be lightweight.

## Common Patterns

### Device-adaptive UI

```lua
local UserInputService = game:GetService("UserInputService")

if UserInputService.TouchEnabled then
    -- Show mobile UI controls
elseif UserInputService.GamepadEnabled then
    -- Show gamepad button prompts
else
    -- Show keyboard/mouse prompts
end

UserInputService.LastInputTypeChanged:Connect(function(inputType)
    -- Dynamically switch UI when player changes input method
end)
```

### Raw keyboard input

```lua
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- ignore if GUI consumed it
    if input.KeyCode == Enum.KeyCode.E then
        -- Handle E key press
    end
end)
```

## Pitfalls

- **Client-only**: UserInputService only works in LocalScripts or client-context code. Server scripts cannot access it.
- **gameProcessedEvent**: Always check the second parameter in InputBegan/InputChanged/InputEnded. When true, the input was consumed by a GUI element (TextBox, Button). Ignoring this check causes actions to fire while the player is typing in chat.
- **Prefer ContextActionService for actions**: UserInputService is global and unconditional. For context-dependent actions (e.g., "E to interact when near a door"), [[ContextActionService]] is cleaner.
- **MouseBehavior requires focus**: Setting `MouseBehavior` to `LockCenter` only works when the game window has focus.
- **GetMouseLocation inset**: Returns position accounting for the top bar inset. Use `GuiService:GetGuiInset()` if you need to convert.

## Related

- [[ContextActionService]] -- contextual input binding (preferred for most game actions)

## Sources

- [wiki/raw/roblox-creator-docs/services/UserInputService.md](../raw/roblox-creator-docs/services/UserInputService.md)
