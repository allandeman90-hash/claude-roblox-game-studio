---
title: ClickDetector
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ClickDetector
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ClickDetector.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: interaction
tags: [roblox-class, interaction, click]
---

# ClickDetector

An object that provides user input on in-experience `Class.BasePart|BaseParts`
and `Class.Model|Models`.

## Description

`ClickDetector` allows `Class.Script|Scripts` and
`Class.LocalScript|LocalScripts` to receive pointer input on 3D objects
through their `Class.ClickDetector.MouseClick|MouseClick` event. They work
when parented to `Class.BasePart`, `Class.Model`, or `Class.Folder` objects.
They detect basic mouse events: enter, leave, left click and right click.
Touch input on `Class.UserInputService.TouchEnabled|TouchEnabled` devices also
fires click events.

The default control scripts bind `Enum.KeyCode|ButtonR2` to interact with
`Class.ClickDetector|ClickDetectors` using
`Class.ContextActionService:BindActivate()`, which can also be used to
override this. When using gamepads, the center dot triggers
`Class.ClickDetector.MouseHoverEnter|MouseHoverEnter` and
`Class.ClickDetector.MouseHoverLeave|MouseHoverLeave`. The bound activation
button fires `Class.ClickDetector.MouseClick|MouseClick`.

`Class.ClickDetector.MaxActivationDistance|MaxActivationDistance` can be used
to limit the distance a player may be from a click detector before it is no
longer clickable.

`Class.ClickDetector` events fire on both the client and the server. Since a
`Class.LocalScript` will only run if it descends from a `Class.Player` or
player `Class.Player.Character|Character`, it's usually not useful to put a
`Class.LocalScript` inside a `Class.ClickDetector`, since the script won't run
or the object won't be clickable. If you need a `Class.LocalScript` to detect
`Class.ClickDetector` events, `Class.StarterPlayerScripts` may be a better
place instead.

#### Input Priority

If multiple `Class.ClickDetector|ClickDetectors` may detect user input, only
the deepest will fire events. If two `Class.ClickDetector|ClickDetectors` are
siblings, the first will take priority.

If an action bound with `Class.ContextActionService` uses the same input as a
`Class.ClickDetector`, the action bound with `Class.ContextActionService` will
take priority over the click detector's events.

`Class.UserInputService.InputBegan` will fire before `Class.ClickDetector`
events.

## Inheritance

Inherits from: `Instance`

Memory category: `Instances`

## Properties

### `ClickDetector.CursorIcon`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Input`

Sets the cursor icon to display when the mouse is hovered over the parent
of this `Class.ClickDetector` or `Class.DragDetector`.

Sets the cursor icon to display when the mouse is hovered over the parent
of this `Class.ClickDetector` or `Class.DragDetector`. If this property is
left blank, the detector will use the default icon.

To change the cursor icon, set this property to the asset ID of the image
you'd like to use.

### `ClickDetector.CursorIconContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Input`

Sets the cursor icon to display when the mouse is hovered over the parent
of this `Class.ClickDetector` or `Class.DragDetector`. Only supports asset
URIs.

Sets the cursor icon to display when the mouse is hovered over the parent
of this `Class.ClickDetector` or `Class.DragDetector`. If this property is
left blank, the detector will use the default icon.

To change the cursor icon, set this property to the asset ID of the image
you'd like to use. Only asset URIs are supported for this property.

### `ClickDetector.MaxActivationDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Input`

Maximum distance between a character and the `Class.ClickDetector` or
`Class.DragDetector` for the player to be able to interact with it.

This property controls the maximum distance, in studs, between a
`Class.Player.Character|Character` and the `Class.ClickDetector` or
`Class.DragDetector` for the player to be able to interact with it. For
instance, a character within 10 studs of a `Class.ClickDetector` or
`Class.DragDetector` with a max activation distance of 5 would not be able
to use the detector because they are out of range.

## Methods

_No public methods documented._

## Events

### `ClickDetector.MouseClick`

```
MouseClick(playerWhoClicked: Player)
```

- security=`None` ; capabilities=`Input`

Fires when a player interacts with the parent of a `Class.ClickDetector`
or `Class.DragDetector`.

This event fires from either a `Class.Script` or `Class.LocalScript` when
a player interacts with a `Class.ClickDetector` or `Class.DragDetector`
via the following inputs:

- On platforms with a mouse, when the player left mouse clicks.
- On `Class.UserInputService.TouchEnabled|TouchEnabled` platforms, when
  the player taps.
- On `Class.UserInputService.GamepadEnabled|GamepadEnabled` platforms,
  when the center dot is over the same model and the **A** button is
  pressed and released.

Note that the player's `Class.Player.Character|Character` must be within
the `Class.ClickDetector.MaxActivationDistance|MaxActivationDistance` of
the detector.

**Parameters:**

- `playerWhoClicked` : `Player` — The `Class.Player` who clicked on the parent of a `Class.ClickDetector` or `Class.DragDetector`.

### `ClickDetector.mouseClick`

```
mouseClick(playerWhoClicked: Player)
```

- security=`None` ; tags=`Deprecated` ; capabilities=`Input` ; **Deprecated:** This deprecated event is a variant of `Class.ClickDetector.MouseClick`,
which should be used instead.

**Parameters:**

- `playerWhoClicked` : `Player` — 

### `ClickDetector.MouseHoverEnter`

```
MouseHoverEnter(playerWhoHovered: Player)
```

- security=`None` ; capabilities=`Input`

Fires when the parent of a `Class.ClickDetector` or `Class.DragDetector`
is hovered over by a player.

This event fires from either a `Class.Script` or `Class.LocalScript` when
the parent of a `Class.ClickDetector` or `Class.DragDetector` is hovered
over by a player. This does not entail explicit interaction with the
detector, for which you can listen to either
`Class.ClickDetector.MouseClick|MouseClick` and
`Class.ClickDetector.RightMouseClick|RightMouseClick` events.

Due to the nature of user input, you should not depend on all
`Class.ClickDetector.MouseHoverEnter|MouseHoverEnter` events firing a
corresponding `Class.ClickDetector.MouseHoverLeave|MouseHoverLeave` event.

**Parameters:**

- `playerWhoHovered` : `Player` — The `Class.Player` who started hovering over the parent of a `Class.ClickDetector` or `Class.DragDetector`.

### `ClickDetector.MouseHoverLeave`

```
MouseHoverLeave(playerWhoHovered: Player)
```

- security=`None` ; capabilities=`Input`

Fires when a player's cursor hovers off the parent of a
`Class.ClickDetector` or `Class.DragDetector`.

This event fires from either a `Class.Script` or `Class.LocalScript` when
a player's cursor hovers off the parent of a `Class.ClickDetector` or
`Class.DragDetector`. This does not entail explicit interaction with the
detector, for which you can listen to either
`Class.ClickDetector.MouseClick|MouseClick` and
`Class.ClickDetector.RightMouseClick|RightMouseClick` events.

Due to the nature of user input, you should not depend on all
`Class.ClickDetector.MouseHoverLeave|MouseHoverLeave` events firing after
a corresponding `Class.ClickDetector.MouseHoverEnter|MouseHoverEnter`
event.

**Parameters:**

- `playerWhoHovered` : `Player` — The `Class.Player` whose cursor hovered off the parent of a `Class.ClickDetector` or `Class.DragDetector`.

### `ClickDetector.RightMouseClick`

```
RightMouseClick(playerWhoClicked: Player)
```

- security=`None` ; capabilities=`Input`

Fires when a player right clicks their mouse cursor on a
`Class.ClickDetector` or `Class.DragDetector`.

This event fires from either a `Class.Script` or `Class.LocalScript` when
a player right clicks their mouse cursor on a `Class.ClickDetector` or
`Class.DragDetector`. Note that the player's
`Class.Player.Character|Character` must be within the
`Class.ClickDetector.MaxActivationDistance|MaxActivationDistance` of the
detector.

**Parameters:**

- `playerWhoClicked` : `Player` — The `Class.Player` who right clicked their mouse cursor on the parent of a `Class.ClickDetector` or `Class.DragDetector`.

## Notes / Deprecations

- Deprecated event `ClickDetector.mouseClick`: This deprecated event is a variant of `Class.ClickDetector.MouseClick`,
which should be used instead.
- Property `ClickDetector.CursorIcon` security: `read=None, write=None`
- Property `ClickDetector.CursorIconContent` security: `read=None, write=None`
- Property `ClickDetector.MaxActivationDistance` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `ClickDetector-Example` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/ClickDetector
- `Part-Anchored-Toggle` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/ClickDetector
- ClickDetector.MouseHoverEnter: ClickDetector-MouseHoverLeave1
- ClickDetector.MouseHoverLeave: ClickDetector-MouseHoverLeave1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ClickDetector
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ClickDetector.yaml
- Captured: 2026-04-16
