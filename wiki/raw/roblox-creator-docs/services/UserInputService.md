---
title: UserInputService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/UserInputService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UserInputService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: input
tags: [roblox-class, input, service]
---

# UserInputService

`UserInputService` is primarily used to detect the input types available on a
user's device, as well as detect input events.

## Description

`UserInputService` is primarily used to detect the input types available on a
user's device, as well as detect input events. It allows you to perform
different actions depending on the device and, in turn, provide the best
experience for the end user.

As this service is intended for client-side usage only, its properties,
methods, and events can only be used in a `Class.LocalScript`, a
`Class.ModuleScript` required by a `Class.LocalScript`, or a `Class.Script`
with `Class.BaseScript.RunContext|RunContext` set to `Enum.RunContext.Client`.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`, `NotReplicated`

Memory category: `Instances`

## Properties

### `UserInputService.AccelerometerEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Describes whether the user's device has an accelerometer.

This property describes whether the user's device has an accelerometer, a
component found in most mobile devices that measures acceleration (change
in speed).

If the device has an enabled accelerometer, you can get its current
acceleration by using the
`Class.UserInputService:GetDeviceAcceleration()|GetDeviceAcceleration()`
method or track when the device's acceleration changes through the
`Class.UserInputService.DeviceAccelerationChanged|DeviceAccelerationChanged`
event.

### `UserInputService.GamepadEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Describes whether the user's device has an available gamepad.

This property describes whether the user's device has an available
gamepad. If `true`, you can use gamepad‑related methods such as
`Class.UserInputService:GetConnectedGamepads()|GetConnectedGamepads()`.

For seamless cross-platform compatibility on mixed-input devices, see
`Class.UserInputService.PreferredInput|PreferredInput` which more
accurately reflects which input (mouse/keyboard, touch, gamepad, etc.) the
player is likely using as the **primary** input.

### `UserInputService.GyroscopeEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Describes whether the user's device has a gyroscope.

This property describes whether the user's device has a gyroscope, a
component found in most mobile devices that detects orientation and
rotational speed.

If the device has a gyroscope, you can incorporate it into your experience
using the `Class.UserInputService:GetDeviceRotation()|GetDeviceRotation()`
method or track when the device's rotation changes through the
`Class.UserInputService.DeviceRotationChanged|DeviceRotationChanged`
event.

### `UserInputService.KeyboardEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Describes whether the user's device has a keyboard available.

This property describes whether the user's device has a keyboard
available. If `true`, you can use key‑related methods such as
`Class.UserInputService:IsKeyDown()|IsKeyDown()` or
`Class.UserInputService:GetKeysPressed()|GetKeysPressed()`.

For seamless cross-platform compatibility on mixed-input devices, see
`Class.UserInputService.PreferredInput|PreferredInput` which more
accurately reflects which input (mouse/keyboard, touch, gamepad, etc.) the
player is likely using as the **primary** input.

### `UserInputService.ModalEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `Input`
- **Deprecated:** This item has been superseded by `Class.GuiService.TouchControlsEnabled`
which should be used in all new work.

Toggles whether Roblox's mobile controls are hidden on mobile devices.

The `ModalEnabled` property determines whether character controls are
hidden on `Class.UserInputService.TouchEnabled|TouchEnabled` devices. By
default, this property is `false` and controls are visible.

This property will only work when used in a `Class.LocalScript` running
for the player whose character controls are to be hidden.

Even if mobile controls are hidden for a player on a touch‑enabled device,
other events such as `Class.UserInputService.InputBegan|InputBegan` and
`Class.UserInputService.TouchSwipe|TouchSwipe` can still be used to
process other forms of input.

### `UserInputService.MouseBehavior`

- **Type:** `MouseBehavior`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Input`

Determines whether the user's mouse can be moved freely or is locked.

This property sets how the user's mouse behaves based on the
`Enum.MouseBehavior` enum. It can be set to three values:

- `Enum.MouseBehavior.Default` &mdash; The mouse moves freely around the
  user's screen.
- `Enum.MouseBehavior.LockCenter` &mdash; The mouse is locked and cannot
  move from the center of the user's screen.
- `Enum.MouseBehavior.LockCurrentPosition` &mdash; The mouse is locked and
  cannot move from its current position on the user's screen at the time
  of locking.

The value of this property does not affect the sensitivity of events
tracking mouse movement. For example,
`Class.UserInputService:GetMouseDelta()|GetMouseDelta` returns the same
`Datatype.Vector2` screen position in pixels regardless of whether the
mouse is locked or able to move freely around the user's screen. As a
result, default scripts like those controlling the camera are not impacted
by this property.

This property is overridden if a `Class.GuiButton` with
`Class.GuiButton.Modal|Modal` enabled is `Class.GuiButton.Visible|Visible`
unless the player's right mouse button is down.

Note that if the mouse is locked,
`Class.UserInputService.InputChanged|InputChanged` will still fire when
the player moves the mouse and will pass in the delta that the mouse
attempted to move by. Additionally, if the player is kicked from the
experience, the mouse will be forcefully unlocked.

### `UserInputService.MouseDeltaSensitivity`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Input`

Scales the delta (change) output of the user's `Class.Mouse`.

This property determines the sensitivity of the user's `Class.Mouse`. It
can be used to adjust the sensitivity of events tracking mouse movement,
such as `Class.UserInputService:GetMouseDelta()|GetMouseDelta()`.

This property does not affect the movement of the mouse icon, nor the
camera sensitivity that the user has selected for their client.

This property has a maximum value of `10` and a minimum value of `0`. When
sensitivity is `0`, events that track the mouse's movement will still fire
but all parameters and properties indicating the change in mouse position
will return `0`.

### `UserInputService.MouseEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Describes whether the user's device has a mouse available.

This property describes whether the user's device has a mouse available.
If `true`, you can use mouse‑related methods such as
`Class.UserInputService:GetMouseLocation()|GetMouseLocation()`.

For seamless cross-platform compatibility on mixed-input devices, see
`Class.UserInputService.PreferredInput|PreferredInput` which more
accurately reflects which input (mouse/keyboard, touch, gamepad, etc.) the
player is likely using as the **primary** input.

### `UserInputService.MouseIcon`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Input`

The content ID of the image for the user's mouse icon.

This property determines the content ID of the image for the user's mouse
icon. If blank, a default arrow pointer is used. While the cursor hovers
over certain UI objects such as an `Class.ImageButton`,
`Class.TextButton`, `Class.TextBox`, or `Class.ProximityPrompt`, this
image will be overridden and temporarily ignored.

To hide the cursor entirely, do **not** use a transparent image; instead,
set `Class.UserInputService.MouseIconEnabled|MouseIconEnabled` to `false`.

### `UserInputService.MouseIconContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Input`

The content ID of the image for the user's mouse icon. Only supports asset
URIs.

This property determines the content ID of the image for the user's mouse
icon. If blank, a default arrow pointer is used. While the cursor hovers
over certain UI objects such as an `Class.ImageButton`,
`Class.TextButton`, `Class.TextBox`, or `Class.ProximityPrompt`, this
image will be overridden and temporarily ignored. Only asset URIs are
supported for this property.

To hide the cursor entirely, do **not** use a transparent image; instead,
set `Class.UserInputService.MouseIconEnabled|MouseIconEnabled` to `false`.

### `UserInputService.MouseIconEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Input`

Determines whether the mouse icon is visible.

This property determines whether the mouse icon is visible. To detect when
this property changes, you must listen to when the
`Class.UserInputService.MouseEnabled|MouseEnabled` property changes.

### `UserInputService.OnScreenKeyboardPosition`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Determines the position of the on-screen keyboard.

This property describes the position of the on-screen keyboard in pixels.
The keyboard's position is `Datatype.Vector2|Vector2.new(0, 0)` when it is
not visible.

See also
`Class.UserInputService.OnScreenKeyboardVisible|OnScreenKeyboardVisible`
and `Class.UserInputService.OnScreenKeyboardSize|OnScreenKeyboardSize`.

### `UserInputService.OnScreenKeyboardSize`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Determines the size of the on-screen keyboard.

This property describes the size of the on-screen keyboard in pixels. The
keyboard's size is `Datatype.Vector2|Vector2.new(0, 0)` when it is not
visible.

See also
`Class.UserInputService.OnScreenKeyboardVisible|OnScreenKeyboardVisible`
and
`Class.UserInputService.OnScreenKeyboardPosition|OnScreenKeyboardPosition`.

### `UserInputService.OnScreenKeyboardVisible`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Describes whether an on-screen keyboard is currently visible on the user's
screen.

This property describes whether an on-screen keyboard is currently visible
on the user's screen.

See also
`Class.UserInputService.OnScreenKeyboardSize|OnScreenKeyboardSize` and
`Class.UserInputService.OnScreenKeyboardPosition|OnScreenKeyboardPosition`.

### `UserInputService.PreferredInput`

- **Type:** `PreferredInput`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Queries the primary input type a player is using, based on anticipated
user behavior.

This read-only property lets you query the **primary** input type a player
is likely using, based on anticipated user behavior, to ensure UI elements
like on‑screen buttons and menus work elegantly across devices. For
example, a touch‑enabled device assumes touch is the default input and
that touch buttons may appear for actions, but if a player connects an
additional bluetooth keyboard/mouse or gamepad, you can assume they want
to switch to that as the primary input type and possibly use touch as a
backup input for on‑screen UI.

The value of `PreferredInput` changes based on built‑in device inputs and
the player's most recent interaction with a connected gamepad or
keyboard/mouse. Examples include:

<table>
  <thead>
    <tr>
      <th>Real-World Scenario</th>
      <th><code>PreferredInput</code></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Player is using a phone with no other connected input devices; no possibility of an input type change.</td>
      <td><code>Enum.PreferredInput|Touch</code></td>
    </tr>
    <tr>
      <td>Player is using a mobile device with a bluetooth keyboard & mouse connected, but no gamepad is connected.</td>
      <td><code>Enum.PreferredInput|KeyboardAndMouse</code></td>
    </tr>
    <tr>
      <td>Player is using a tablet with a bluetooth gamepad connected, but no keyboard or mouse is connected.</td>
      <td><code>Enum.PreferredInput|Gamepad</code></td>
    </tr>
    <tr>
      <td>Player is using an Xbox or PlayStation with a bluetooth keyboard & mouse connected and has most recently interacted with the keyboard or mouse.</td>
      <td><code>Enum.PreferredInput|KeyboardAndMouse</code></td>
    </tr>
    <tr>
      <td>Player is on a Windows or Mac PC with a gamepad connected and has most recently interacted with the gamepad.</td>
      <td><code>Enum.PreferredInput|Gamepad</code></td>
    </tr>
  </tbody>
</table>

### `UserInputService.TouchEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Describes whether the user's device has a touch screen available.

This property describes whether the user's device has a touch screen
available. If `true`, you can use touch‑related events such as
`Class.UserInputService.TouchStarted|TouchStarted` and
`Class.UserInputService.TouchMoved|TouchMoved`.

For seamless cross-platform compatibility on mixed-input devices, see
`Class.UserInputService.PreferredInput|PreferredInput` which more
accurately reflects which input (mouse/keyboard, touch, gamepad, etc.) the
player is likely using as the **primary** input.

### `UserInputService.TouchScreenEnabled`

- **Type:** `boolean`
- **Security:** `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

### `UserInputService.UserHeadCFrame`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Input`
- **Deprecated:** This item has been superseded by `Class.UserInputService:GetUserCFrame()`
which should be used in all new work.

Describes the orientation and position of a user's head, if they are
actively using a virtual reality headset.

The UserHeadCFrame used to describe the orientation and position of a
user's head, if they are actively using a virtual reality headset.

### `UserInputService.VREnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Input`

Indicates whether the user is using a virtual reality headset.

This property describes whether the user is using a virtual reality (VR)
device. If `true`, you can use VR‑related properties, methods, and events
in `Class.VRService`.

## Methods

### `UserInputService:GamepadSupports`

```
GamepadSupports(gamepadNum: UserInputType, gamepadKeyCode: KeyCode) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns whether the given `Enum.UserInputType` gamepad supports a button
corresponding with the given `Enum.KeyCode`.

This method returns whether the given `Enum.UserInputType` gamepad
supports a button corresponding with the given `Enum.KeyCode`.

**Parameters:**

- `gamepadNum` : `UserInputType` — The `Enum.UserInputType` of the gamepad.
- `gamepadKeyCode` : `KeyCode` — The `Enum.KeyCode` of the button in question.

**Returns:**

- `boolean` — Whether the given gamepad supports a button corresponding with the given `Enum.KeyCode`.

### `UserInputService:GetConnectedGamepads`

```
GetConnectedGamepads() -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an array of `Enum.UserInputType` gamepads currently connected.

This method returns an array of `Enum.UserInputType` gamepads currently
connected. If no gamepads are connected, the array will be empty.

Alternatively to detecting all gamepads, the
`Class.UserInputService.PreferredInput|PreferredInput` property can be
used to more accurately reflect which input (mouse/keyboard, touch,
gamepad, etc.) the player is likely using as the **primary** input.

**Returns:**

- `Array` — An array of `Enum.UserInputType|UserInputTypes` corresponding with the gamepads connected to the user's device.

### `UserInputService:GetDeviceAcceleration`

```
GetDeviceAcceleration() -> InputObject
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an `Class.InputObject` that describes the device's current
acceleration.

This method returns an `Class.InputObject` that describes the device's
current acceleration. For this to function, the user's device must have an
enabled accelerometer as queried through the
`Class.UserInputService.AccelerometerEnabled|AccelerometerEnabled`
property.

To track when the device's acceleration changes, use the
`Class.UserInputService.DeviceAccelerationChanged|DeviceAccelerationChanged`
event.

**Returns:**

- `InputObject` — 

### `UserInputService:GetDeviceGravity`

```
GetDeviceGravity() -> InputObject
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an `Class.InputObject` describing the device's current gravity
vector.

This method returns an `Class.InputObject` describing the device's current
gravity vector. The vector is determined by the device's orientation
relative to the real-world force of gravity. For example:

- `Datatype.Vector3|Vector3.new(0, 0, -9.18)` if the device is perfectly
  upright (portrait)
- `Datatype.Vector3|Vector3.new(9.81, 0, 0)` if the left side of the
  device is pointing down
- `Datatype.Vector3|Vector3.new(0, -9.81, 0)` if the back of the device is
  pointing down

Gravity is only tracked for devices with an enabled gyroscope as queried
through `Class.UserInputService.GyroscopeEnabled|GyroscopeEnabled`.

To track when the device's gravity changes, use the
`Class.UserInputService.DeviceGravityChanged|DeviceGravityChanged` event.

**Returns:**

- `InputObject` — 

### `UserInputService:GetDeviceRotation`

```
GetDeviceRotation() -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an `Class.InputObject` and a `Datatype.CFrame` describing the
device's current rotation vector.

This method returns an `Class.InputObject` and a `Datatype.CFrame`
describing the device's current rotation vector.

Device rotation is only tracked for devices with an enabled gyroscope as
queried through
`Class.UserInputService.GyroscopeEnabled|GyroscopeEnabled`.

**Returns:**

- `Tuple` — A tuple containing two properties: The delta describing the amount of rotation that last happened, and the `Datatype.CFrame` of the device's current rotation relative to its default reference frame.

### `UserInputService:GetFocusedTextBox`

```
GetFocusedTextBox() -> TextBox
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns the `Class.TextBox` the client is currently focused on.

This method returns the `Class.TextBox` the client is currently focused
on. A `Class.TextBox` can be manually selected by the user, or selection
can be forced using the `Class.TextBox:CaptureFocus()` method. If no
`Class.TextBox` is selected, this method will return `nil`.

**Returns:**

- `TextBox` — 

### `UserInputService:GetGamepadConnected`

```
GetGamepadConnected(gamepadNum: UserInputType) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns whether a gamepad with the given `Enum.UserInputType` is
connected.

This method returns whether a gamepad with the given `Enum.UserInputType`
is connected.

Alternatively to detecting a specific gamepad by `Enum.UserInputType`, the
`Class.UserInputService.PreferredInput|PreferredInput` property can be
used to more accurately reflect which input (mouse/keyboard, touch,
gamepad, etc.) the player is likely using as the **primary** input.

**Parameters:**

- `gamepadNum` : `UserInputType` — The `Enum.UserInputType` of the gamepad in question.

**Returns:**

- `boolean` — Whether a gamepad associated with `Enum.UserInputType` is connected.

### `UserInputService:GetGamepadState`

```
GetGamepadState(gamepadNum: UserInputType) -> List<InputObject>
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an array of `Class.InputObject|InputObjects` for all available
inputs on the given gamepad, representing each input's last input state.

This method returns an array of `Class.InputObject|InputObjects` for all
available inputs on the given `Enum.UserInputType` gamepad, representing
each input's last input state.

**Parameters:**

- `gamepadNum` : `UserInputType` — The `Enum.UserInputType` corresponding with the gamepad in question.

**Returns:**

- `List<InputObject>` — An array of `Class.InputObject|InputObjects` representing the current state of all available inputs for the given gamepad.

### `UserInputService:GetImageForKeyCode`

```
GetImageForKeyCode(keyCode: KeyCode) -> ContentId
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an image for the requested `Enum.KeyCode`.

This method takes the requested `Enum.KeyCode` and returns the associated
image for the currently connected gamepad device (limited to Xbox,
PlayStation, and Windows). This means that if the connected controller is
an Xbox&nbsp;One controller, the user sees Xbox assets. Similarly, if the
connected device is a PlayStation controller, the user sees PlayStation
assets. If you want to use custom assets, see
`Class.UserInputService.GetStringForKeyCode()|GetStringForKeyCode()`.

**Parameters:**

- `keyCode` : `KeyCode` — The `Enum.KeyCode` for which to fetch the associated image.

**Returns:**

- `ContentId` — The returned image asset ID.

### `UserInputService:GetKeysPressed`

```
GetKeysPressed() -> List<InputObject>
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an array of `Class.InputObject|InputObjects` associated with the
`Enum.KeyCode|keys` currently being pressed down.

This method returns an array of `Class.InputObject|InputObjects`
associated with the keys currently being pressed down. The array can be
iterated through to determine which keys are currently being pressed,
using the `Class.InputObject.KeyCode` names or values.

To check if a specific key is being pressed, use
`Class.UserInputService:IsKeyDown()|IsKeyDown()`.

**Returns:**

- `List<InputObject>` — An array of `Class.InputObject|InputObjects` associated with the keys currently being pressed.

### `UserInputService:GetLastInputType`

```
GetLastInputType() -> UserInputType
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns the `Enum.UserInputType` associated with the user's most recent
input.

This method returns the `Enum.UserInputType` associated with the user's
most recent input. For example, if the user's previous input had been
pressing the <kbd>A</kbd> key, the returned `Enum.UserInputType` value
would be `Enum.UserInputType|Keyboard`.

For seamless cross-platform compatibility on mixed-input devices, see
`Class.UserInputService.PreferredInput|PreferredInput` which more
accurately reflects which input (mouse/keyboard, touch, gamepad, etc.) the
player is likely using as the **primary** input. `GetLastInputType()`
remains for advanced workflows or control schemes that rely on detecting
and responding to the player's specific most recent `Enum.UserInputType`.

**Returns:**

- `UserInputType` — The `Enum.UserInputType` associated with the user's most recent input.

### `UserInputService:GetMouseButtonsPressed`

```
GetMouseButtonsPressed() -> List<InputObject>
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an array of `Class.InputObject|InputObjects` associated with the
mouse buttons currently being held down.

This method returns an array of `Class.InputObject|InputObjects`
associated with the mouse buttons currently being held down. The array can
be iterated through to determine which buttons are currently being held,
using the `Class.InputObject.KeyCode` names or values.

Mouse buttons that are tracked by this method include `MouseButton1`
(left), `MouseButton2` (right), and `MouseButton3` (middle).

If the user is not pressing any mouse button down when the method is
called, it will return an empty array.

**Returns:**

- `List<InputObject>` — An array of `Class.InputObject|InputObjects` corresponding to the mouse buttons currently being currently held down.

### `UserInputService:GetMouseDelta`

```
GetMouseDelta() -> Vector2
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns the change, in pixels, of the position of the player's
`Class.Mouse` in the last rendered frame. Only works if the mouse is
locked.

This method returns the change, in pixels, of the position of the player's
`Class.Mouse` in the last rendered frame, only if the mouse has been
locked using the `Class.UserInputService.MouseBehavior|MouseBehavior`
property; otherwise the returned `Datatype.Vector2` values will be `0`.

The sensitivity of the mouse, determined in the client's settings and
`Class.UserInputService.MouseDeltaSensitivity|MouseDeltaSensitivity`, will
influence the result.

**Returns:**

- `Vector2` — Change in movement of the mouse.

### `UserInputService:GetMouseLocation`

```
GetMouseLocation() -> Vector2
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns the current screen location of the player's `Class.Mouse` relative
to the top-left corner of the screen.

This method returns a `Datatype.Vector2` representing the current screen
location of the player's `Class.Mouse` in pixels relative to the top‑left
corner. This does not account for the `Enum.ScreenInsets`; to get the
top‑left and bottom‑right insets, call `Class.GuiService:GetGuiInset()`.

If the location of the mouse pointer is offscreen or the player's device
does not have a mouse, the returned value will be undetermined.

**Returns:**

- `Vector2` — A `Datatype.Vector2` representing the current screen location of the mouse, in pixels.

### `UserInputService:GetNavigationGamepads`

```
GetNavigationGamepads() -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an array of gamepads connected and enabled for `Class.GuiObject`
navigation in descending order of priority.

This method returns an array of gamepads that are connected and enabled
for `Class.GuiObject` navigation, but does not influence navigation
controls. This list is in descending order of priority, meaning it can be
iterated over to determine which gamepad should have navigation control.

See also
`Class.UserInputService:SetNavigationGamepad()|SetNavigationGamepad()`,
`Class.UserInputService:IsNavigationGamepad()|IsNavigationGamepad()`, and
`Class.UserInputService:GetConnectedGamepads()|GetConnectedGamepads()`.

**Returns:**

- `Array` — An array of `Enum.UserInputType|UserInputTypes` that can be used for navigation, in descending order of priority.

### `UserInputService:GetStringForKeyCode`

```
GetStringForKeyCode(keyCode: KeyCode) -> string
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns a string representing a key the user should press in order to
input a given `Enum.KeyCode`.

This method returns a string representing a key the user should press in
order to input a given `Enum.KeyCode`, keeping in mind their keyboard
layout. For key codes that require some modifier to be held, this method
returns the key to be pressed in addition to the modifier. See the
examples below for further explanation.

When using Roblox with a non‑QWERTY keyboard layout, key codes are mapped
to equivalent QWERTY positions. For example, pressing <kbd>A</kbd> on an
AZERTY keyboard results in `Enum.KeyCode.Q`, potentially leading to
mismatched information on experience UI elements. This method solves the
issue by providing the actual key to be pressed while using non‑QWERTY
keyboard layouts.

<table size="small">
  <thead>
    <tr>
      <th>KeyCode</th>
      <th>QWERTY Return</th>
      <th>AZERTY Return</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>Enum.KeyCode.Q</code></td>
      <td><code>Q</code></td>
      <td><code>A</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.W</code></td>
      <td><code>W</code></td>
      <td><code>Z</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Equals</code></td>
      <td><code>=</code></td>
      <td><code>=</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.At</code></td>
      <td><code>2</code> because <code>@</code> is typed with <kbd>Shift</kbd><kbd>2</kbd></td>
      <td><code>É</code></td>
    </tr>
  </tbody>
</table>

#### Gamepad Usage

`GetStringForKeyCode()` returns the string mapping for the `Enum.KeyCode`
for the most recently connected gamepad. If the connected controller is
not supported, the method returns the default string conversion for the
requested key code.

The following example shows how you can map custom assets for
`Enum.KeyCode.ButtonA|ButtonA`:

```
local UserInputService = game:GetService("UserInputService")

local imageLabel = script.Parent
local key = Enum.KeyCode.ButtonA

local mappings = {
	ButtonA = "rbxasset://BUTTON_A_ASSET", -- Replace with the desired ButtonA asset
	ButtonCross = "rbxasset://BUTTON_CROSS_ASSET"  -- Replace with the desired ButtonCross asset
}

local mappedKey = UserInputService:GetStringForKeyCode(key)
local image = mappings[mappedKey]

imageLabel.Image = image
```

#### Gamepad Mappings

The directional pad key codes do not have any differences based on device.
`Enum.KeyCode.ButtonSelect` has slightly different behavior in some cases.
Use both PlayStation mappings to ensure users see the correct buttons.

<table size="small">
  <thead>
    <tr>
      <th>KeyCode</th>
      <th>PlayStation Return Value</th>
      <th>Xbox Return Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>Enum.KeyCode.ButtonA</code></td>
      <td><code>ButtonCross</code></td>
      <td><code>ButtonA</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonB</code></td>
      <td><code>ButtonCircle</code></td>
      <td><code>ButtonB</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonX</code></td>
      <td><code>ButtonSquare</code></td>
      <td><code>ButtonX</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonY</code></td>
      <td><code>ButtonTriangle</code></td>
      <td><code>ButtonY</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonL1</code></td>
      <td><code>ButtonL1</code></td>
      <td><code>ButtonLB</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonL2</code></td>
      <td><code>ButtonL2</code></td>
      <td><code>ButtonLT</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonL3</code></td>
      <td><code>ButtonL3</code></td>
      <td><code>ButtonLS</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonR1</code></td>
      <td><code>ButtonR1</code></td>
      <td><code>ButtonRB</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonR2</code></td>
      <td><code>ButtonR2</code></td>
      <td><code>ButtonRT</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonR3</code></td>
      <td><code>ButtonR3</code></td>
      <td><code>ButtonRS</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonStart</code></td>
      <td><code>ButtonOptions</code></td>
      <td><code>ButtonStart</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonSelect</code></td>
      <td><code>ButtonTouchpad</code> and <code>ButtonShare</code></td>
      <td><code>ButtonSelect</code></td>
    </tr>
  </tbody>
</table>

#### Legacy System Images

When using a `Enum.KeyCode` that may be better represented as an image,
such as for an `Class.ImageLabel` in a user interface, you can use the
following legacy icons. However, it's recommended that you use
`Class.UserInputService:GetImageForKeyCode()|GetImageForKeyCode()` as a
more modern, cross‑platform method to retrieve Xbox and PlayStation
controller icons.

<table size="small">
  <thead>
    <tr>
      <th>KeyCode</th>
      <th>Asset ID</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>Enum.KeyCode.ButtonX</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxX.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonY</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxY.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonA</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxA.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonB</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxB.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.DPadLeft</code></td>
      <td><code>rbxasset://textures/ui/Controls/dpadLeft.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.DPadRight</code></td>
      <td><code>rbxasset://textures/ui/Controls/dpadRight.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.DPadUp</code></td>
      <td><code>rbxasset://textures/ui/Controls/dpadUp.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.DPadDown</code></td>
      <td><code>rbxasset://textures/ui/Controls/dpadDown.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonSelect</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxView.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonStart</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxmenu.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonL1</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxLB.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonR1</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxRB.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonL2</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxLT.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonR2</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxRT.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonL3</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxLS.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.ButtonR3</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxRS.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Thumbstick1</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxLSDirectional.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Thumbstick2</code></td>
      <td><code>rbxasset://textures/ui/Controls/xboxRSDirectional.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Backspace</code></td>
      <td><code>rbxasset://textures/ui/Controls/backspace.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Return</code></td>
      <td><code>rbxasset://textures/ui/Controls/return.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.LeftShift</code></td>
      <td><code>rbxasset://textures/ui/Controls/shift.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.RightShift</code></td>
      <td><code>rbxasset://textures/ui/Controls/shift.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Tab</code></td>
      <td><code>rbxasset://textures/ui/Controls/tab.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Quote</code></td>
      <td><code>rbxasset://textures/ui/Controls/apostrophe.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Comma</code></td>
      <td><code>rbxasset://textures/ui/Controls/comma.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Backquote</code></td>
      <td><code>rbxasset://textures/ui/Controls/graveaccent.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Period</code></td>
      <td><code>rbxasset://textures/ui/Controls/period.png</code></td>
    </tr>
    <tr>
      <td><code>Enum.KeyCode.Space</code></td>
      <td><code>rbxasset://textures/ui/Controls/spacebar.png</code></td>
    </tr>
  </tbody>
</table>

**Parameters:**

- `keyCode` : `KeyCode` — 

**Returns:**

- `string` — 

### `UserInputService:GetSupportedGamepadKeyCodes`

```
GetSupportedGamepadKeyCodes(gamepadNum: UserInputType) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns an array of `Enum.KeyCode|KeyCodes` that the gamepad associated
with the given `Enum.UserInputType` supports.

This method returns an array of `Enum.KeyCode|KeyCodes` that the gamepad
associated with the given `Enum.UserInputType` supports. If called on a
non‑connected gamepad, returns an empty array.

To determine if a specific `Enum.KeyCode` is supported, use
`Class.UserInputService:GamepadSupports()|GamepadSupports()`.

**Parameters:**

- `gamepadNum` : `UserInputType` — The `Enum.UserInputType` of the gamepad.

**Returns:**

- `Array` — An array of `Enum.KeyCode|KeyCodes` supported by the given gamepad.

### `UserInputService:GetUserCFrame`

```
GetUserCFrame(type: UserCFrame) -> CFrame
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Input`

Returns a `Datatype.CFrame` describing the position and orientation of a
specified virtual reality device.

The `Class.UserInputService:GetUserCFrame()` method returns a
`Datatype.CFrame` describing the position and orientation of a specified
`Enum.UserCFrame` virtual reality (VR) device. If the specified device is
not connected, the method returns `Datatype.CFrame|CFrame.new()`.

For example, the code snippet below prints the CFrame of the user's VR
headset.

```lua
local UserInputService = game:GetService("UserInputService")
local cframe = UserInputService:GetUserCFrame(Enum.UserCFrame.Head)

print(cframe)
```

By using the method, players can implement features such as re-positioning
the user's in-game character corresponding to the location of a connected
VR device. This can be done by changing the _CFrame_ of the user's in-game
body parts to match the _CFrame_ of the specified VR device using
`Enum.UserCFrame` and `Datatype.CFrame` value arguments passed by the
event.

See also:

- `Class.UserInputService.UserCFrameChanged`, an event which fires when
  the `Datatype.CFrame` of a VR device changes
- `Class.VRService`, a service used to implement VR support

As this event only fires locally, it can only be used in a
`Class.LocalScript`.

**Parameters:**

- `type` : `UserCFrame` — The `Enum.UserCFrame` corresponding to the VR device.

**Returns:**

- `CFrame` — A `Datatype.CFrame` describing the position and orientation of the specified VR device.

### `UserInputService:IsGamepadButtonDown`

```
IsGamepadButtonDown(gamepadNum: UserInputType, gamepadKeyCode: KeyCode) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Determines whether a particular button is pressed on a gamepad.

This method returns `true` if a particular button is pressed on a gamepad,
otherwise returns `false`.

See also `Class.InputBinding` as a way to hook gamepad and other input
interactions to `Class.InputAction|InputActions`.

**Parameters:**

- `gamepadNum` : `UserInputType` — The `Enum.UserInputType` of the given gamepad.
- `gamepadKeyCode` : `KeyCode` — The `Enum.KeyCode` of the specified gamepad button.

**Returns:**

- `boolean` — Whether the specified button on the given gamepad is pressed is pressed.

### `UserInputService:IsKeyDown`

```
IsKeyDown(keyCode: KeyCode) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns whether the given `Enum.KeyCode|key` is currently held down.

This method returns `true` if a particular key is pressed on a keyboard,
otherwise returns `false`.

See also `Class.InputBinding` as a way to hook key and other input
interactions to `Class.InputAction|InputActions`.

**Parameters:**

- `keyCode` : `KeyCode` — The `Enum.KeyCode` of the key.

**Returns:**

- `boolean` — Whether the specified key is being held down.

### `UserInputService:IsMouseButtonPressed`

```
IsMouseButtonPressed(mouseButton: UserInputType) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns whether the given mouse button is currently held down.

This method returns `true` if a particular mouse button is pressed,
otherwise returns `false`.

See also `Class.InputBinding` as a way to hook mouse button and other
input interactions to `Class.InputAction|InputActions`.

**Parameters:**

- `mouseButton` : `UserInputType` — The `Enum.UserInputType` of the mouse button.

**Returns:**

- `boolean` — Whether the given mouse button is currently held down.

### `UserInputService:IsNavigationGamepad`

```
IsNavigationGamepad(gamepadEnum: UserInputType) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Returns `true` if the specified gamepad is allowed to control navigation
and selection `Class.GuiObject|GuiObjects`.

This method returns `true` if the specified gamepad is allowed to control
navigation and selection `Class.GuiObject|GuiObjects`.

Use `Class.UserInputService:SetNavigationGamepad()|SetNavigationGamepad()`
to set a navigation gamepad, or
`Class.UserInputService:GetNavigationGamepads()|GetNavigationGamepads()`
to get a list of all navigation gamepads.

**Parameters:**

- `gamepadEnum` : `UserInputType` — The `Enum.UserInputType` of the specified gamepad.

**Returns:**

- `boolean` — Whether the specified gamepad is a navigation gamepad.

### `UserInputService:RecenterUserHeadCFrame`

```
RecenterUserHeadCFrame() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Recenters the `Datatype.CFrame` of the VR headset to the current
orientation of the headset worn by the user.

This method recenters the `Datatype.CFrame` of the VR headset to the
current orientation of the headset worn by the user. This means that the
headset's current orientation is set to `Datatype.CFrame.new()`.

This method behaves identically to the `Class.VRService` method
`Class.VRService:RecenterUserHeadCFrame()|RecenterUserHeadCFrame()`.

**Returns:**

- `()` — 

### `UserInputService:SetNavigationGamepad`

```
SetNavigationGamepad(gamepadEnum: UserInputType, enabled: boolean) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Sets whether or not the specified gamepad can move the `Class.GuiObject`
navigator.

This method sets whether the specified gamepad can move the
`Class.GuiObject` navigator.

Use `Class.UserInputService:IsNavigationGamepad()|IsNavigationGamepad()`
to check if a specified gamepad is a set to be a navigation gamepad, or
`Class.UserInputService:GetNavigationGamepads()|GetNavigationGamepads()`
to retrieve a list of all navigation gamepads.

**Parameters:**

- `gamepadEnum` : `UserInputType` — The `Enum.UserInputType` of the specified gamepad.
- `enabled` : `boolean` — Whether the specified gamepad can move the GUI navigator.

**Returns:**

- `()` — 

## Events

### `UserInputService.DeviceAccelerationChanged`

```
DeviceAccelerationChanged(acceleration: InputObject)
```

- security=`None` ; capabilities=`Input`

Fires when a user moves a device that has an accelerometer.

This event fires when a user moves a device that has an accelerometer, a
component found in most mobile devices that measures acceleration (change
in speed). To determine whether a user's device has an accelerometer
enabled, use
`Class.UserInputService.AccelerometerEnabled|AccelerometerEnabled`.

This event can be used along with
`Class.UserInputService:GetDeviceAcceleration()|GetDeviceAcceleration()`
to determine the current movement of a user's device.

**Parameters:**

- `acceleration` : `InputObject` — An `Class.InputObject`, with a `Class.InputObject.UserInputType|UserInputType` of `Enum.UserInputType.Accelerometer|Accelerometer` and `Class.InputObject.Position|Position` that shows the force of gravity on each local device axis.

### `UserInputService.DeviceGravityChanged`

```
DeviceGravityChanged(gravity: InputObject)
```

- security=`None` ; capabilities=`Input`

Fires when the force of gravity changes on a device that has an enabled
accelerometer.

This event fires when the device's gravity `Datatype.Vector3` changes on a
device that has an accelerometer. To determine whether a user's device has
an accelerometer enabled, use
`Class.UserInputService.AccelerometerEnabled|AccelerometerEnabled`.

A device's gravity vector represent the force of gravity on each of the
device's **X**, **Y**, and **Z** axes. While gravity never changes, the
force it exerts on each axis changes when the device rotates and changes
orientation. The force value exerted on each axis is a unit vector ranging
from `-1` to `1`.

If the device has an enabled accelerometer, you can use the
`Class.UserInputService:GetDeviceGravity()|GetDeviceGravity()` method to
get the current force of gravity on the user's device.

**Parameters:**

- `gravity` : `InputObject` — An `Class.InputObject` with a `Class.InputObject.Position|Position` property that shows the force of gravity on each local device axis. This position can be used as a direction to determine the direction of gravity relative to the device.

### `UserInputService.DeviceRotationChanged`

```
DeviceRotationChanged(rotation: InputObject, cframe: CFrame)
```

- security=`None` ; capabilities=`Input`

Fires when a user rotates a device that has a gyroscope.

This event fires when a user rotates a device that has a gyroscope, a
component found in most mobile devices that detects orientation and
rotational speed. To check if a user's device has an enabled gyroscope,
use `Class.UserInputService.GyroscopeEnabled|GyroscopeEnabled`.

To query the current device rotation, use the
`Class.UserInputService:GetDeviceRotation()|GetDeviceRotation()` method.

Note that this event only fires when the Roblox client window is in focus.
Inputs will not be captured when the window is minimized.

**Parameters:**

- `rotation` : `InputObject` — An `Class.InputObject` providing info about the device's rotation. `Class.InputObject.Position|Position` represents the new rotation a `Datatype.Vector3` positional value and `Class.InputObject.Delta|Delta` represents the change in rotation in a `Datatype.Vector3` positional value.
- `cframe` : `CFrame` — A `Datatype.CFrame` representing the device's current orientation.

### `UserInputService.GamepadConnected`

```
GamepadConnected(gamepadNum: UserInputType)
```

- security=`None` ; capabilities=`Input`

Fires when a gamepad is connected to the client.

This event fires when a gamepad is connected to the client. You can also
use `Class.UserInputService:GetConnectedGamepads()|GetConnectedGamepads()`
to find the correct gamepad to use.

Alternatively, you can detect value changes to the
`Class.UserInputService.PreferredInput|PreferredInput` property which more
accurately reflects which input (mouse/keyboard, touch, gamepad, etc.) the
player is likely using as the **primary** input.

See also `Class.UserInputService.GamepadDisconnected|GamepadDisconnected`.

**Parameters:**

- `gamepadNum` : `UserInputType` — The `Enum.UserInputType` of the connected gamepad.

### `UserInputService.GamepadDisconnected`

```
GamepadDisconnected(gamepadNum: UserInputType)
```

- security=`None` ; capabilities=`Input`

Fires when a gamepad is disconnected from the client.

This event fires when a gamepad is disconnected from the client.

Alternatively, you can detect value changes to the
`Class.UserInputService.PreferredInput|PreferredInput` property which more
accurately reflects which input (mouse/keyboard, touch, gamepad, etc.) the
player is likely using as the **primary** input.

See also `Class.UserInputService.GamepadConnected|GamepadConnected`.

**Parameters:**

- `gamepadNum` : `UserInputType` — The`Enum.UserInputType` of the disconnected gamepad.

### `UserInputService.InputBegan`

```
InputBegan(input: InputObject, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user begins interacting with an input device such as a mouse
or gamepad.

This event fires when a user begins interacting with an input device such
as a mouse or gamepad, such as when they first interact with a gamepad
button, although it does not capture mouse wheel movements. Can be used
along with `Class.UserInputService.InputChanged|InputChanged` and
`Class.UserInputService.InputEnded|InputEnded` to track when user input
begins, changes, and ends.

See also `Class.InputBinding` as a way to hook input device interactions
to `Class.InputAction|InputActions`.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `input` : `InputObject` — An `Class.InputObject` instance containing information about the user's input.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.InputChanged`

```
InputChanged(input: InputObject, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user changes how they're interacting with an input device
such as a mouse or gamepad.

This event fires when a user changes how they're interacting with an input
device such as a mouse or gamepad. Can be used along with
`Class.UserInputService.InputBegan|InputBegan` and
`Class.UserInputService.InputEnded|InputEnded` to track when user input
begins, changes, and ends.

See also `Class.InputBinding` as a way to hook input device interactions
to `Class.InputAction|InputActions`.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `input` : `InputObject` — An `Class.InputObject` instance containing information about the user's input.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`. To ignore events that are automatically handled by Roblox like scrolling in a `Class.ScrollingFrame`, check that `gameProcessedEvent` is `false`.

### `UserInputService.InputEnded`

```
InputEnded(input: InputObject, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user stops interacting with an input device such as a mouse
or gamepad.

This event fires when a user stops interacting with an input device such
as a mouse or gamepad, such as when they release a gamepad button. Can be
used along with `Class.UserInputService.InputBegan|InputBegan` and
`Class.UserInputService.InputChanged|InputChanged` to track when user
input begins, changes, and ends.

See also `Class.InputBinding` as a way to hook input device interactions
to `Class.InputAction|InputActions`.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `input` : `InputObject` — An `Class.InputObject` instance containing information about the user input.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.JumpRequest`

```
JumpRequest()
```

- security=`None` ; capabilities=`Input`

Fires whenever the client makes a request for their character to jump.

This event fires when there is a jump request from the client, for example
when the client presses the spacebar or jump button on mobile. Default
behavior is to set the player's `Class.Humanoid.Jump` property to `true`
which makes the player's character jump.

Since this event fires multiple times for a single jump request, using a
[debounce](../../../scripting/debounce.md) is recommended. This event does
not fire if `Class.Player.Character` is set to nil.

### `UserInputService.LastInputTypeChanged`

```
LastInputTypeChanged(lastInputType: UserInputType)
```

- security=`None` ; capabilities=`Input`

Fires whenever the client's `Enum.UserInputType` is changed.

This event fires whenever the client's `Enum.UserInputType` is changed.

To get the value of the last input type, regardless of whether it has
changed, use the
`Class.UserInputService:GetLastInputType()|GetLastInputType()` method.

**Parameters:**

- `lastInputType` : `UserInputType` — A `Enum.UserInputType` indicating the last input type.

### `UserInputService.PointerAction`

```
PointerAction(wheel: float, pan: Vector2, pinch: float, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when the user performs a specific pointer action.

This event fires when the user performs a specific pointer action
(`wheel`, `pan`, `pitch`).

**Parameters:**

- `wheel` : `float` — 
- `pan` : `Vector2` — 
- `pinch` : `float` — 
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it.

### `UserInputService.TextBoxFocused`

```
TextBoxFocused(textboxFocused: TextBox)
```

- security=`None` ; capabilities=`Input`

Fires when the client focuses on a `Class.TextBox`.

This event fires when the client gains focus on a `Class.TextBox`,
typically when a user clicks/taps it to begin inputting text. Also fires
if the `Class.TextBox` is focused using `Class.TextBox:CaptureFocus()`.
Can be used alongside
`Class.UserInputService.TextBoxFocusReleased|TextBoxFocusReleased` to
track when a `Class.TextBox` loses focus.

See also `Class.UserInputService:GetFocusedTextBox()|GetFocusedTextBox()`,
`Class.TextBox.Focused`, and `Class.TextBox.FocusLost`.

**Parameters:**

- `textboxFocused` : `TextBox` — The `Class.TextBox` that gained focus.

### `UserInputService.TextBoxFocusReleased`

```
TextBoxFocusReleased(textboxReleased: TextBox)
```

- security=`None` ; capabilities=`Input`

Fires when the client loses focus on a `Class.TextBox`.

This event fires when the client loses focus on a `Class.TextBox`,
typically when a user stops text entry by pressing <kbd>Enter</kbd> or
clicking/touching elsewhere on the screen. Can be used alongside
`Class.UserInputService.TextBoxFocused|TextBoxFocused` to track when a
`Class.TextBox` gains focus.

See also `Class.UserInputService:GetFocusedTextBox()|GetFocusedTextBox()`,
`Class.TextBox.Focused`, and `Class.TextBox.FocusLost`.

**Parameters:**

- `textboxReleased` : `TextBox` — The `Class.TextBox` that lost focus.

### `UserInputService.TouchDrag`

```
TouchDrag(dragDirection: SwipeDirection, numberOfTouches: int, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when the user drags on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when the user drags on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `dragDirection` : `SwipeDirection` — The predominant drag direction for the event (`Enum.SwipeDirection|Up`, `Enum.SwipeDirection|Down`, `Enum.SwipeDirection|Left`, or `Enum.SwipeDirection|Right`).
- `numberOfTouches` : `int` — Currently only supports one touch for a value of `1`.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchEnded`

```
TouchEnded(touch: InputObject, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user releases their finger from the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when a user releases their finger from the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device. Can be paired
with `Class.UserInputService.TouchStarted|TouchStarted` to determine when
a user starts and stops touching the screen.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `touch` : `InputObject` — An `Class.InputObject` instance containing information about the user's input. This is the same object throughout the lifetime of the touch, so comparing `Class.InputObject|InputObjects` when they are touch objects is valid to determine if it's the same finger.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchLongPress`

```
TouchLongPress(touchPositions: Array, state: UserInputState, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user holds at least one finger for a short amount of time on
the screen of a `Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when a user holds at least one finger for a short amount
of time on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `touchPositions` : `Array` — An array of `Datatype.Vector2` objects indicating the position of the fingers involved in the gesture.
- `state` : `UserInputState` — The `Enum.UserInputState` of the gesture.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchMoved`

```
TouchMoved(touch: InputObject, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user moves their finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when a user moves their finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device, useful for
tracking whether a user is moving their finger on the screen and where
they're moving it. Can be paired with
`Class.UserInputService.TouchStarted|TouchStarted` and
`Class.UserInputService.TouchEnded|TouchEnded` to determine when a user
starts touching the screen, how their finger moves while touching it, and
when the they stop touching the screen.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `touch` : `InputObject` — An `Class.InputObject` instance containing information about the user's input. Note that its `Class.InputObject.Position|Position` is a `Datatype.Vector3` but only includes **X** and **Y** coordinates (**Z** is always `0`).
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchPan`

```
TouchPan(touchPositions: Array, totalTranslation: Vector2, velocity: Vector2, state: UserInputState, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when the user drags at least one finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when the user drags at least one finger on the screen of
a `Class.UserInputService.TouchEnabled|TouchEnabled` device.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `touchPositions` : `Array` — An array of `Datatype.Vector2|Vector2s` indicating the positions of the touches involved in the gesture.
- `totalTranslation` : `Vector2` — The size of the pan gesture from start to end, in pixels.
- `velocity` : `Vector2` — The speed of the pan gesture in pixels per second.
- `state` : `UserInputState` — The `Enum.UserInputState` of the gesture.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchPinch`

```
TouchPinch(touchPositions: Array, scale: float, velocity: float, state: UserInputState, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user performs a pinch gesture on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when a user performs a pinch gesture on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `touchPositions` : `Array` — An array of `Datatype.Vector2|Vector2s` indicating the screen position, in pixels, of the fingers involved in the pinch gesture.
- `scale` : `float` — The magnitude of the pinch from start to finish (in pixels) divided by the starting pinch positions.
- `velocity` : `float` — The speed of the pinch gesture in pixels per second.
- `state` : `UserInputState` — The `Enum.UserInputState` of the gesture.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchRotate`

```
TouchRotate(touchPositions: Array, rotation: float, velocity: float, state: UserInputState, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user rotates two fingers on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when a user rotates two fingers on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `touchPositions` : `Array` — An array of `Datatype.Vector2|Vector2s` indicating the positions of the fingers involved in the gesture.
- `rotation` : `float` — The number of degree the gesture has rotated since the start of the gesture.
- `velocity` : `float` — The change in rotation (in degrees) divided by the duration of the change (in seconds).
- `state` : `UserInputState` — The `Enum.UserInputState` of the gesture.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchStarted`

```
TouchStarted(touch: InputObject, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user places their finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when a user places their finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device. Can be paired
with `Class.UserInputService.TouchEnded|TouchEnded` to determine when a
user starts and stops touching the screen.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `touch` : `InputObject` — An `Class.InputObject` instance, which contains information about the user's input. This is the same object throughout the lifetime of the touch, so comparing `Class.InputObject|InputObjects` when they are touch objects is valid to determine if it's the same finger.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchSwipe`

```
TouchSwipe(swipeDirection: SwipeDirection, numberOfTouches: int, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires on a `Class.UserInputService.TouchEnabled|TouchEnabled` device when
a user places their finger(s) down on the screen, pans across the screen,
and lifts their finger(s) off with a certain speed of movement.

This event fires on a `Class.UserInputService.TouchEnabled|TouchEnabled`
device when a user places their finger(s) down on the screen, pans across
the screen, and lifts their finger(s) off with a certain speed of
movement.

For more precise tracking of touch input movement, use
`Class.UserInputService.TouchMoved|TouchMoved`.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `swipeDirection` : `SwipeDirection` — An `Enum.SwipeDirection` indicating the direction the user swiped.
- `numberOfTouches` : `int` — Number of touches involved in the swipe gesture.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchTap`

```
TouchTap(touchPositions: Array, gameProcessedEvent: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user taps their finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device.

This event fires when a user taps their finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device, regardless of
whether the user taps in the 3D world or on a `Class.GuiObject` element.
If you're looking for an event that only fires when the user taps in the
3D world, use `Class.UserInputService.TouchTapInWorld|TouchTapInWorld`.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `touchPositions` : `Array` — An array of `Datatype.Vector2` objects indicating the position of the fingers involved in the tap gesture.
- `gameProcessedEvent` : `boolean` — Indicates whether the engine internally observed this input and acted on it. Generally this refers to UI processing, so if a button was touched or clicked from this input, `gameProcessedEvent` will be `true`.

### `UserInputService.TouchTapInWorld`

```
TouchTapInWorld(position: Vector2, processedByUI: boolean)
```

- security=`None` ; capabilities=`Input`

Fires when a user taps their finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device and the tap
location is in the 3D world.

This event fires when a user taps their finger on the screen of a
`Class.UserInputService.TouchEnabled|TouchEnabled` device and the tap
location is in the 3D world rather than on a `Class.GuiObject` element.

Note that this event only fires when the Roblox client window is in focus.
It will not fire when the window is minimized.

**Parameters:**

- `position` : `Vector2` — A `Datatype.Vector2` indicating the position of the tap.
- `processedByUI` : `boolean` — Whether the user tapped a UI element.

### `UserInputService.UserCFrameChanged`

```
UserCFrameChanged(type: UserCFrame, value: CFrame)
```

- security=`None` ; tags=`Deprecated` ; capabilities=`Input`

Fires when the `Datatype.CFrame` of a specified Virtual Reality device
changes.

The UserCFrameChanged event fires when the `Datatype.CFrame` of a VR
device changes.

This event can be used to track the movement of a connected VR device.

Using the event, you can implement features such as moving the user's
in-game character limbs as the user moves their VR device. This can be
done by changing the CFrame of the user's in-game limbs to match the
CFrame changes of the VR device using the `Enum.UserCFrame` enum and
_CFrame_ value arguments passed by the event.

To retrieve the `Datatype.CFrame` of a connected VR device, use
`Class.UserInputService:GetUserCFrame()`.

As the event fires locally, it can only be used in a `Class.LocalScript`.

See also:

- `Class.VRService`, used to implement support, including an identical
  event `Class.VRService.UserHeadCFrameChanged`
- `Class.Camera.HeadLocked`, when this property is `true` the
  `Class.Camera` will automatically track the head motion of a player
  using a VR device
- `Class.Camera:GetRenderCFrame()`, a method which retrieves the
  `Datatype.CFrame` the `Class.Camera` is being orientated at, including
  the impact of VR devices

**Parameters:**

- `type` : `UserCFrame` — A `Enum.UserCFrame` value indicating which body part moved.
- `value` : `CFrame` — A `Datatype.CFrame` value indicating the updated CFrame of the body part that moved.

### `UserInputService.WindowFocused`

```
WindowFocused()
```

- security=`None` ; capabilities=`Input`

Fires when the window of the Roblox client gains focus on the user's
screen.

This event fires when the window of the Roblox client gains focus,
typically when it is maximized or actively opened by the user. Can be used
alongside `Class.UserInputService.WindowFocusReleased|WindowFocusReleased`
to track when the client loses focus on a user's screen.

### `UserInputService.WindowFocusReleased`

```
WindowFocusReleased()
```

- security=`None` ; capabilities=`Input`

Fires when the window of the Roblox client loses focus on the user's
screen.

This event fires when the window of the Roblox client loses focus,
typically when it is minimized by the user. Can be used alongside
`Class.UserInputService.WindowFocused|WindowFocused` to track when the
client gains focus on a user's screen.

## Notes / Deprecations

- Deprecated property `UserInputService.ModalEnabled`: This item has been superseded by `Class.GuiService.TouchControlsEnabled`
which should be used in all new work.
- Deprecated property `UserInputService.UserHeadCFrame`: This item has been superseded by `Class.UserInputService:GetUserCFrame()`
which should be used in all new work.
- Property `UserInputService.AccelerometerEnabled` security: `read=None, write=None`
- Property `UserInputService.GamepadEnabled` security: `read=None, write=None`
- Property `UserInputService.GyroscopeEnabled` security: `read=None, write=None`
- Property `UserInputService.KeyboardEnabled` security: `read=None, write=None`
- Property `UserInputService.ModalEnabled` security: `read=None, write=None`
- Property `UserInputService.MouseBehavior` security: `read=None, write=None`
- Property `UserInputService.MouseDeltaSensitivity` security: `read=None, write=None`
- Property `UserInputService.MouseEnabled` security: `read=None, write=None`
- Property `UserInputService.MouseIcon` security: `read=None, write=None`
- Property `UserInputService.MouseIconContent` security: `read=None, write=None`
- Property `UserInputService.MouseIconEnabled` security: `read=None, write=None`
- Property `UserInputService.OnScreenKeyboardPosition` security: `read=None, write=None`
- Property `UserInputService.OnScreenKeyboardSize` security: `read=None, write=None`
- Property `UserInputService.OnScreenKeyboardVisible` security: `read=None, write=None`
- Property `UserInputService.PreferredInput` security: `read=None, write=None`
- Property `UserInputService.TouchEnabled` security: `read=None, write=None`
- Property `UserInputService.TouchScreenEnabled` security: `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- Property `UserInputService.UserHeadCFrame` security: `read=None, write=None`
- Property `UserInputService.VREnabled` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- UserInputService:GetDeviceAcceleration: UserInputService-GetDeviceAcceleration
- UserInputService:GetDeviceGravity: UserInputService-GetDeviceGravity
- UserInputService:GetDeviceRotation: UserInputService-GetDeviceRotation
- UserInputService:GetImageForKeyCode: UserInputService-GetImageForKeyCode
- UserInputService:GetLastInputType: UserInputService-GetLastInputType
- UserInputService:GetMouseButtonsPressed: UserInputService-GetMouseButtonsPressed
- UserInputService:GetMouseDelta: UserInputService-GetMouseDelta
- UserInputService:GetUserCFrame: UserInputService-UserCFrameChanged
- UserInputService.AccelerometerEnabled: UserInputService-DeviceGravityChanged
- UserInputService.MouseIcon: UserInputService-MouseIcon
- UserInputService.MouseIconContent: UserInputService-MouseIcon
- UserInputService.PreferredInput: UserInputService-PreferredInput
- UserInputService.DeviceAccelerationChanged: UserInputService-DeviceAccelerationChanged
- UserInputService.DeviceGravityChanged: UserInputService-DeviceGravityChanged
- UserInputService.JumpRequest: UserInputService-JumpRequest
- UserInputService.TextBoxFocused: UserInputService-TextBoxFocused
- UserInputService.TextBoxFocusReleased: UserInputService-TextBoxFocused
- UserInputService.UserCFrameChanged: UserInputService-UserCFrameChanged
- UserInputService.WindowFocusReleased: UserInputService-Window-Focus-Client
- UserInputService.WindowFocusReleased: UserInputService-Window-Focus-Server

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/UserInputService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UserInputService.yaml
- Captured: 2026-04-16
