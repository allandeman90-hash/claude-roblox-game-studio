---
title: ContextActionService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ContextActionService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ContextActionService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: input
tags: [roblox-class, input, actions, service]
---

# ContextActionService

A service used to bind user input to contextual actions.

## Description

Allows an experience to bind user input to contextual actions, or actions that
are only enabled under some condition or period of time. For example, allowing
a player to open a door only while close by. In code, an action is simply a
string (the name of the action) used by the service to differentiate between
unique actions. The action string is provided to
`Class.ContextActionService:BindAction()|BindAction` and
`Class.ContextActionService:UnbindAction()|UnbindAction`, among other member
functions. If two actions are bound to the same input, the most recently bound
will take priority. When the most recent action is unbound, the one bound
before that takes control again. Since this service deals with user input, you
can only use it in client-side `Class.LocalScript|LocalScripts`.

#### Context and Action

A **context** is simply a condition during which a player may perform some
action. Some examples include holding a `Class.Tool`, being
`Class.Seat|seated` in a car or standing near a door. Whatever the case may
be, it is up to your `Class.LocalScript|LocalScripts` to call
`Class.ContextActionService:BindAction()|BindAction` when the context is
entered and `Class.ContextActionService:UnbindAction()|UnbindAction` when the
context is left.

An **action** is simply some input that can be performed by the player while
in that context. Such an action could open/close some menu, trigger a
secondary tool action or send a request to the server using
`Class.RemoteFunction:InvokeServer()`. An action is identified by a unique
string as the first parameter of both
`Class.ContextActionService:BindAction()|BindAction` and
`Class.ContextActionService:UnbindAction()|UnbindAction`. The string can be
anything, but it should reflect the **action being performed, not the input
being used**. For example, don't use "KeyH" as an action name - use "CarHorn"
instead. It is best to define your actions as a constant at the top of your
script since you will use it in at least three different places in your code.

#### Binding Actions Contextually

It's better to use ContextActionService's
`Class.ContextActionService:BindAction()|BindAction` than
`Class.UserInputService.InputBegan` for most cases. For
`Class.UserInputService.InputBegan`, your connected function would have to
check if the player is in the context of the action being performed. In most
cases, this is harder than just calling a function when a context is entered/
left. For example, if you want to have the `H` key trigger a car horn sound
while the player is sitting in it, the player might type "hello" in chat or
otherwise use the `H` key for something else. It is harder to determine if
something else is using the H key (like chat) - the car might honk when the
player didn't mean to. If you instead use
`Class.ContextActionService:BindAction()|BindAction` and
`Class.ContextActionService:UnbindAction()|UnbindAction` when the player
enters/leaves the car, `Class.ContextActionService` will make sure that `H`
key presses trigger the honk action only when it is the most recently bound
action. If something else (like chat) takes control, you won't have to worry
about checking that.

#### Inspecting Bound Actions

To see a list of actions and their bound inputs, you can inspect the "Action
Bindings" tab in the Developer Console (F9 while in game). This shows all
bindings, including those bound by Roblox core scripts and default
camera/control scripts too. This is useful for debugging if your actions are
being bound/unbound at the correct times, or if some other action is stealing
input from your actions. For example, if you are attempting to bind
<kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd>, it may be the case that
default character movement scripts are binding over those same keys.
Similarly, the camera control script can steal right-click input if the script
runs after yours.

#### Keyboardless Input

This service is especially useful for supporting gamepad and touch input. For
gamepad input, you might choose to bind the B button to an action that returns
the user to the previous menu when they enter another menu. For touch,
on-screen touch buttons can be used in place of key presses: these buttons
display only while the action is bound, and the position, text and/or images
of these buttons can be configured through this service. They're somewhat
limited in the amount of customization provided by this service; it's usually
a better idea to make your own on-screen buttons using `Class.ImageButton` or
`Class.TextButton`.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `ContextActionService:BindAction`

```
BindAction(actionName: string, functionToBind: Function, createTouchButton: boolean, inputTypes: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Bind user input to an action given an action handling function.

Bind an action to user input given an action handling function. Upon a
matching input being performed, the action handler function will be called
with the arguments listed below. Valid input enum items include those
within the following: `Enum.KeyCode`, `Enum.UserInputType` or
`Enum.PlayerActions` . Call this function when a player **enters the
context** in which an action can be performed. When the player leaves the
context, call `Class.ContextActionService:UnbindAction()|UnbindAction()`
with the same `actionName`.

The code sample below shows how a `Class.Sound` can be
`Class.Sound:Play()|played` while a key (<kbd>H</kbd>), game pad button,
or touch screen button is pressed.

```lua
local ContextActionService = game:GetService("ContextActionService")

-- A car horn sound
local honkSound = Instance.new("Sound", workspace)
honkSound.Looped = true
honkSound.SoundId = "rbxassetid://9120386436"

local function handleAction(actionName, inputState, inputObject)
	if actionName == "HonkHorn" then
		if inputState == Enum.UserInputState.Begin then
			honkSound:Play()
		else
			honkSound:Pause()
		end
	end
end

-- When the player sits in the vehicle:
ContextActionService:BindAction("HonkHorn", handleAction, true, Enum.KeyCode.H, Enum.KeyCode.ButtonY)

-- When the player gets out:
ContextActionService:UnbindAction("HonkHorn")
```

#### Action Handler Parameters

The action handler functions are called with the following parameters:

<table>
<tr>
  <th>#</th>
  <th>Type</th>
  <th>Description</th>
</tr>
<tr>
  <td>1</td>
  <td><code>string</code></td>
  <td>The same string that was originally passed to <code>Class.ContextActionService:BindAction()|BindAction()</code>.
  This allows one function to handle multiple actions at once, if necessary.</td>
</tr>
<tr>
  <td>2</td>
  <td><code>Enum.UserInputState</code></td>
  <td>The state of the input. <code>Enum.UserInputState|Cancel</code> is sent
  if some input was in progress and another action bound over that in-progress
  input, or if the in-progress bound action was unbound through <code>Class.ContextActionService:UnbindAction()|UnbindAction()</code>.</td>
</tr>
<tr>
  <td>3</td>
  <td><code>InputObject</code></td>
  <td>An object that contains information about the input (varies based on
  <code>Enum.UserInputType</code>). The <code>Class.InputObject</code> sometimes won't match the inputs the action
  was bound to: when the <code>Enum.UserInputState|Cancel</code> state is sent, this object will be
  <code>Enum.KeyCode.Unknown</code> and <code>Enum.UserInputType.None</code>.</td>
</tr>
</table>

#### Action Bindings Stack

Action bindings behave like a stack: if two actions are bound to the same
user input, the **most recently bound** action handler will be used. If an
action handler returns `Enum.ContextActionResult.Pass`, the next most
recently bound action handler will be called, and so on until a handler
sinks the input (by returning `nil` or `Enum.ContextActionResult.Sink`).
When `Class.ContextActionService:UnbindAction()|UnbindAction` is called,
the action handler is removed from the stack. This stack behavior can be
overridden using
`Class.ContextActionService:BindActionAtPriority()|BindActionAtPriority`,
where an additional priority parameter after `createTouchButton` may
override the order in which actions are bound (higher before lower).

#### Touch Buttons

In addition to input types, this function's third parameter controls
whether a button is created for
`Class.UserInputService.TouchEnabled|TouchEnabled` devices. Upon the first
touch button's creation, a `Class.ScreenGui` named "ContextActionGui" is
added to the `Class.PlayerGui`. Inside the ScreenGui is a `Class.Frame`
called "ContextButtonFrame" is added. It is in this frame in which
`Class.ImageButton|ImageButtons` for bound actions are parented; you can
use `Class.ContextActionService:GetButton()|GetButton()` to retrieve such
buttons for customization. A maximum of 7 touch buttons can be created
through `Class.ContextActionService:BindAction()|BindAction()`.

**Parameters:**

- `actionName` : `string` — A string representing the action being performed (e.g. "HonkHorn" or "OpenDoor").
- `functionToBind` : `Function` — The action-handling function, called with the following parameters when the bound inputs are triggered: string (actionName), `Enum.UserInputState` and an InputObject.
- `createTouchButton` : `boolean` — Whether a GUI button should be created for the action on touch input devices.
- `inputTypes` : `Tuple` — Any number of `Enum.KeyCode` or `Enum.UserInputType` representing the inputs to bind to the action.

**Returns:**

- `()` — 

### `ContextActionService:BindActionAtPriority`

```
BindActionAtPriority(actionName: string, functionToBind: Function, createTouchButton: boolean, priorityLevel: int, inputTypes: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Behaves like `Class.ContextActionService:BindAction()|BindAction` but also
allows a priority to be assigned to the bound action for overlapping input
types (higher before lower).

BindActionAtPriority behaves like
`Class.ContextActionService:BindAction()|BindAction` but also allows a
priority to be assigned to the bound action. If multiple actions are bound
to the same input, the higher priority function is called regardless of
the order in which the actions were bound. In other words, this function
overrides the normal "stack" behavior of BindAction.

**Parameters:**

- `actionName` : `string` — A string representing the action being performed (e.g. "HonkHorn" or "OpenDoor").
- `functionToBind` : `Function` — The action-handling function, called with the following parameters when the bound inputs are triggered: string (actionName), `Enum.UserInputState` and an InputObject.
- `createTouchButton` : `boolean` — Whether a GUI button should be created for the action on touch input devices.
- `priorityLevel` : `int` — The priority level at which the action should be bound (higher considered before lower).
- `inputTypes` : `Tuple` — Any number of Enum.KeyCode or Enum.UserInputType representing the inputs to bind to the action.

**Returns:**

- `()` — 

### `ContextActionService:BindActionToInputTypes`

```
BindActionToInputTypes(actionName: string, functionToBind: Function, createTouchButton: boolean, inputTypes: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Input` ; **Deprecated:** This item has been superseded by `Class.ContextActionService:BindAction()`
which should be used in all new work.

Binds _functionToBind_ to input events such as key presses, mouse
movement, or controller input.

This function binds _functionToBind_ to input events such as key presses,
mouse movement, or controller input. The specific input types the engine
listens for are listed as parameters of BindAction. Whenever a player uses
any of these input types, the Roblox Engine calls "functionToBind".
BindAction sets the priorityLevel via `Enum.ContextActionPriority` to
Default.Value, which is 2000. Use `Class.ContextActionService:GetButton()`
to control the priority of bound events.

In addition to input types, BindAction has a createTouchButton parameter.
When this is set to true it creates an `Class.ImageButton` on any device
with a touchscreen. A `Class.ScreenGui` is also created to put the context
buttons into named ContextActionGui and is parented to `Class.PlayerGui`.
The created ImageButton is parented to this ContextActionGui. GetButton
can be used to retrieve the button that was created.

If an input has more than one function bound to it, each function will be
placed on a stack. A stack obeys the principle of last in first out. So
the first object placed on the stack will be on the top. The next object
placed on the stack becomes the top and the previous object moves one
position down (like a stack of books). When the input is triggered, the
function at the top of the stack is called. If the function returns
`Enum.ContextActionResult`.Pass this will continue down the stack. To
remove a function from being called by all input that it was bound by use
`Class.ContextActionService:UnbindAction()`.

BindAction allows control over whether or not a bound action should be
processed by other actions on the stack using `Enum.ContextActionResult`.
If `Enum.ContextActionResult.Pass` is returned in the callback function,
every action below it in the stack (last function called gets executed
first) will get a chance to process it. Anything other than Pass will be
treated as `Enum.ContextActionResult.Sink`, including `nil`. It will also
sink if the callback is yielded.

**Parameters:**

- `actionName` : `string` — 
- `functionToBind` : `Function` — 
- `createTouchButton` : `boolean` — 
- `inputTypes` : `Tuple` — 

**Returns:**

- `()` — 

### `ContextActionService:BindActivate`

```
BindActivate(userInputTypeForActivation: UserInputType, keyCodesForActivation: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Bind a `Enum.KeyCode` with a specific `Enum.UserInputType` to trigger
`Class.Tool.Activation` and `Class.ClickDetector` events.

Bind a `Enum.KeyCode` that can be used with a `Enum.UserInputType` to
activate `Class.ClickDetector` events, `Class.Tool|Tools`, and
`Class.GuiButton|GuiButtons`. When the given key/button is pressed, it
fires the `Class.Mouse.Button1Down` event on the mouse sent to
`Class.Tool.Equipped`. This in turn fires the `Class.Tool.Activated` event
if `Class.Tool.ManualActivationOnly` is not set to true. For gamepad
input, this function is called by the default control scripts in order to
bind the ButtonR2 `Enum.KeyCode`.

Note that the `Enum.UserInputType` specified must be `Keyboard` or
`Gamepad1` through `Gamepad8` in order to be valid.

**Parameters:**

- `userInputTypeForActivation` : `UserInputType` — Must be Keyboard or Gamepad1 through Gamepad8.
- `keyCodesForActivation` : `Tuple` — 

**Returns:**

- `()` — 

### `ContextActionService:GetAllBoundActionInfo`

```
GetAllBoundActionInfo() -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Get a table of information about all bound actions (key is the name passed
to `Class.ContextActionService:BindAction()|BindAction`, value is a table
from `Class.ContextActionService:GetBoundActionInfo()|GetBoundActionInfo`
when called with the key).

GetAllBoundActioninfo returns a table which maps all actions' names (those
originally passed to `Class.ContextActionService:BindAction()|BindAction`)
to a table returned by
`Class.ContextActionService:GetBoundActionInfo()|GetBoundActionInfo` when
called with the action name itself. Using this function, you can inspect
all presently bound actions. This is useful when debugging their priority
levels or stack orders.

**Returns:**

- `Dictionary` — 

### `ContextActionService:GetBoundActionInfo`

```
GetBoundActionInfo(actionName: string) -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Get a table of information about a bound action given its name originally
passed to `Class.ContextActionService:BindAction()|BindAction`.

GetBoundActionInfo returns a table with the following keys describing a
bound action given its name. To get the same information for all actions
at once, use
`Class.ContextActionService:GetAllBoundActionInfo()|GetAllBoundActionInfo`.

<table>
<tr>
  <th>Name</th>
  <th>Type</th>
  <th>Description</th>
</tr>
<tr>
  <td><code>stackOrder</code></td>
  <td>number</td>
  <td>

Describes the index of the action on the stack (increasing)

</td>
</tr>
<tr>
  <td><code>priorityLevel</code>*</td>
  <td>number</td>
  <td>

Describes the
<code>Class.ContextActionService:BindActionAtPriority()|priority</code>
level of the action

</td>
</tr>
<tr>
  <td><code>createTouchButton</code></td>
  <td>bool</td>
  <td>

Describes whether a touch button should be created on
<code>Class.UserInputService.TouchEnabled|TouchEnabled</code> devices

</td>
</tr>
<tr>
  <td><code>inputTypes</code></td>
  <td>table</td>
  <td>

The input types passed to
<code>Class.ContextActionService:BindAction()|BindAction</code> for which
this action will trigger

</td>
</tr>
<tr>
  <td><code>description</code>†</td>
  <td>string</td>
  <td>

The description of action set by
<code>Class.ContextActionService:SetDescription()|SetDescription</code>

</td>
</tr>
<tr>
  <td><code>title</code>†</td>
  <td>string</td>
  <td>

The title of the action set by
<code>Class.ContextActionService:SetTitle()|SetTitle</code>

</td>
</tr>
<tr>
  <td><code>image</code>†</td>
  <td>string</td>
  <td>

The image of the action's touch button set by
<code>Class.ContextActionService:SetImage()|SetImage</code>

</td>
</tr>
</table>

\* Priority level will still be included even if
`Class.ContextActionService:BindActionAtPriority()|BindActionAtPriority`
wasn't used - by default it will be 2000.

† Indicates that this field will be `nil` if the associated method was not
called for the given action.

**Parameters:**

- `actionName` : `string` — 

**Returns:**

- `Dictionary` — 

### `ContextActionService:GetButton`

```
GetButton(actionName: string) -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Input`

Retrieves a `Class.ImageButton` of a
`Class.ContextActionService:BindAction()|bound` action that had a touch
input button created.

GetButton returns the `Class.ImageButton` created by
`Class.ContextActionService:BindAction()|BindAction` if its third
parameter was true and the device is
`Class.UserInputService.TouchEnabled|TouchEnabled`. The only parameter to
this function must match exactly the name of the action originally sent to
BindAction.

If no such action was bound or if a button was not created, this function
returns `nil`.

**Parameters:**

- `actionName` : `string` — The name of the action originally passed to BindAction.

**Returns:**

- `Instance` — An ImageButton created by BindAction.

### `ContextActionService:GetCurrentLocalToolIcon`

```
GetCurrentLocalToolIcon() -> string
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Return the `Class.BackpackItem.TextureId` of a `Class.Tool` currently
`Class.Tool.Equipped|equipped` by the `Class.Player`.

GetCurrentLocalToolIcon will return the `Class.BackpackItem.TextureId` of
a `Class.Tool` currently `Class.Tool.Equipped|equipped` by the
`Class.Player`, or `nil` if there is no such Tool or if the player lacks a
`Class.Player.Character|Character`.

**Returns:**

- `string` — A content string from the Tool's TextureId, or `nil` if one could not be found.

### `ContextActionService:SetDescription`

```
SetDescription(actionName: string, description: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Given the name of a bound action with a touch button, sets the description
of the action.

SetDescription will set the description of an action bound by
`Class.ContextActionService:BindAction()|BindAction`. In a list of
available actions, this would be text that describes the given action.

Although the name may suggest that this method is related to the family of
functions that customize a touch button for actions that create them
(`Class.ContextActionService:SetTitle()|SetTitle`,
`Class.ContextActionService:SetImage()|SetImage` and
`Class.ContextActionService:SetPosition()|SetPosition`), this method does
not affect such a button. This method merely sets a text description of an
action, and nothing more.

**Parameters:**

- `actionName` : `string` — The name of the action originally passed to BindAction.
- `description` : `string` — A text description of the action, such as "Honk the car's horn" or "Open the inventory".

**Returns:**

- `()` — 

### `ContextActionService:SetImage`

```
SetImage(actionName: string, image: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

If `actionName` key contains a bound action, then `image` is set as the
image of the touch button.

This method sets the image shown on a touch button created by
`Class.ContextActionService:BindAction()|BindAction()`. Specifically, it
sets the `Class.ImageLabel.Image` property of the `Class.ImageLabel`
within the `Class.ImageButton` that would be returned by
`Class.ContextActionService:GetButton()|GetButton`. If no such bound
action exists (e.g. nothing is returned by GetButton), this function does
nothing and throws no error.

This function is part of a family of methods that customize the touch
button of an action. Others in this family include
`Class.ContextActionService:SetPosition()|SetPosition` and
`Class.ContextActionService:SetTitle()|SetTitle`.

**Parameters:**

- `actionName` : `string` — The name of the action originally passed to BindAction.
- `image` : `string` — The value to which the Image property should be set.

**Returns:**

- `()` — 

### `ContextActionService:SetPosition`

```
SetPosition(actionName: string, position: UDim2) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Given the name of a bound action with a touch button, sets the position of
the button within the ContextButtonFrame.

This method sets the position of a touch button created by
`Class.ContextActionService:BindAction()|BindAction()`. Specifically, it
sets the `Class.GuiObject.Position` property of the `Class.ImageButton`
that would be returned by
`Class.ContextActionService:GetButton()|GetButton`. If no such bound
action exists (e.g. nothing is returned by GetButton), this function does
nothing and throws no error.

This function is part of a family of methods that customize the touch
button of an action. Others in this family include
`Class.ContextActionService:SetImage()|SetImage` and
`Class.ContextActionService:SetTitle()|SetTitle`.

**Parameters:**

- `actionName` : `string` — The name of the action originally passed to BindAction.
- `position` : `UDim2` — The position within the ContextButtonFrame.

**Returns:**

- `()` — 

### `ContextActionService:SetTitle`

```
SetTitle(actionName: string, title: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Given the name of a bound action with a touch button, sets the text shown
on the button.

SetTitle will set the text shown on a touch button created by
`Class.ContextActionService:BindAction()|BindAction`. Specifically, this
sets the `Class.TextLabel.Text` property of a `Class.TextLabel` within the
`Class.ImageButton` that would be returned by
`Class.ContextActionService:GetButton()|GetButton`. If no such bound
action exists (e.g. nothing is returned by GetButton), this function does
nothing and throws no error.

This function is part of a family of methods that customize the touch
button of an action. Others in this family include
`Class.ContextActionService:SetImage()|SetImage` and
`Class.ContextActionService:SetPosition()|SetPosition`.

**Parameters:**

- `actionName` : `string` — The name of the action originally passed to BindAction.
- `title` : `string` — The text to display on the button.

**Returns:**

- `()` — 

### `ContextActionService:UnbindAction`

```
UnbindAction(actionName: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Unbind an action from input given its name.

UnbindAction will unbind an action by name from user inputs so that the
action handler function will no longer be called. Call this function when
the context for some action is no longer applicable, such as closing a
user interface, exiting a car or `Class.Tool.Unequipped|unequipping` a
`Class.Tool`. See `Class.ContextActionService:BindAction()|BindAction` for
more information on how bound actions operate.

This function **will not** throw an error if there is no such action bound
with the given string. Using
`Class.ContextActionService:GetAllBoundActionInfo()|GetAllBoundActionInfo`
or the Developer Console's "Action Bindings" tab, you can find out what
actions are presently bound.

**Parameters:**

- `actionName` : `string` — 

**Returns:**

- `()` — 

### `ContextActionService:UnbindActivate`

```
UnbindActivate(userInputTypeForActivation: UserInputType, keyCodeForActivation: KeyCode = Unknown) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Unbind a `Enum.KeyCode` with a specific `Enum.UserInputType` from
triggering `Class.Tool.Activation` when bound with
`Class.ContextActionService:BindActivate()`.

UnbindActivate unbinds an `Enum.KeyCode` used with an `Enum.UserInputType`
for activating a `Class.Tool` (or a `Class.HopperBin`) using
`Class.ContextActionService:BindActivate()|BindActivate`. This function
essentially undoes the action performed by that function.

**Parameters:**

- `userInputTypeForActivation` : `UserInputType` — The same UserInputType originally sent to BindActivate.
- `keyCodeForActivation` : `KeyCode` (default `Unknown`) — The same KeyCode originally sent to BindActivate.

**Returns:**

- `()` — 

### `ContextActionService:UnbindAllActions`

```
UnbindAllActions() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`

Removes all functions bound. No actionNames will remain. All touch buttons
will be removed.

Removes all functions bound. No actionNames will remain. All touch buttons
will be removed. If a button was manipulated manually there is no
guarantee it will be cleaned up.

**Returns:**

- `()` — 

## Events

### `ContextActionService.LocalToolEquipped`

```
LocalToolEquipped(toolEquipped: Instance)
```

- security=`None` ; capabilities=`Input`

Fires when the current player equips a `Class.Tool`.

**Parameters:**

- `toolEquipped` : `Instance` — 

### `ContextActionService.LocalToolUnequipped`

```
LocalToolUnequipped(toolUnequipped: Instance)
```

- security=`None` ; capabilities=`Input`

Fires when the current player unequips a `Class.Tool`.

**Parameters:**

- `toolUnequipped` : `Instance` — 

## Notes / Deprecations

- Deprecated method `ContextActionService:BindActionToInputTypes`: This item has been superseded by `Class.ContextActionService:BindAction()`
which should be used in all new work.
- Method `ContextActionService:GetButton` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `ContextActionService-Tool-Reload` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/ContextActionService
- ContextActionService:BindAction: ContextActionService-Tool-Reload
- ContextActionService:BindAction: General-Action-Handler
- ContextActionService:BindAction: Stacked-Action-Handlers
- ContextActionService:BindActionAtPriority: contextactionservice-bindaction-priorities
- ContextActionService:SetDescription: contextactionservice-touch-button
- ContextActionService:SetImage: contextactionservice-touch-button
- ContextActionService:SetPosition: contextactionservice-touch-button
- ContextActionService:SetTitle: contextactionservice-touch-button
- ContextActionService:UnbindAction: ContextActionService-Tool-Reload

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ContextActionService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ContextActionService.yaml
- Captured: 2026-04-16
