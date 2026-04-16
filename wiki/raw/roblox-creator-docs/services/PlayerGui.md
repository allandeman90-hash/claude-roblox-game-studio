---
title: PlayerGui
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/PlayerGui
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/PlayerGui.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: gui
tags: [roblox-class, gui, players]
---

# PlayerGui

A container for a player's currently rendered `Class.ScreenGui|ScreenGuis`.

## Description

`Class.PlayerGui` is a container that holds a player's UI. If a
`Class.ScreenGui` is a descendant, then any `Class.GuiObject` inside of the
`Class.ScreenGui` will be drawn to the player's screen. Any
`Class.LocalScript` will also run if it is inserted into a `Class.PlayerGui`.

When a player first joins the experience, their `Class.PlayerGui` is
automatically inserted into their `Class.Player` object. When the player's
`Class.Player.Character` spawns for the first time, all of the contents of
`Class.StarterGui` are automatically copied into the player's
`Class.PlayerGui`. Note that if `Class.Players.CharacterAutoLoads` is set to
`false`, the character will not spawn and `Class.StarterGui` contents will not
be copied until `Class.Player:LoadCharacterAsync()` is called. If
`Class.StarterGui.ResetPlayerGuiOnSpawn` is set to `true`, then every time the
player's character respawns, all of the contents of that player's
`Class.PlayerGui` are cleared and replaced with the contents of
`Class.StarterGui`.

If you need to control a player's UI container during playtime, for example to
show/hide a specific `Class.ScreenGui` or any of its children, access it as
follows from a `Class.LocalScript`:

```lua
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
```

## Inheritance

Inherits from: `BasePlayerGui`

Class tags: `NotCreatable`, `PlayerReplicated`

Memory category: `Instances`

## Properties

### `PlayerGui.CurrentScreenOrientation`

- **Type:** `ScreenOrientation`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Describes the player's current screen orientation.

### `PlayerGui.ScreenOrientation`

- **Type:** `ScreenOrientation`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Sets the preferred screen orientation mode for this player, if on a mobile
device.

### `PlayerGui.SelectionImageObject`

- **Type:** `GuiObject`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Overrides the default selection adornment used for gamepads.

Overrides the default selection adornment used for gamepads. For best
results, this should point to a `Class.GuiObject`.

## Methods

### `PlayerGui:GetTopbarTransparency`

```
GetTopbarTransparency() -> float
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`UI`

Returns the transparency of the Topbar.

**Returns:**

- `float` — 

### `PlayerGui:SetTopbarTransparency`

```
SetTopbarTransparency(transparency: float) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`UI`

Sets the transparency of the top bar.

This method sets the transparency of the top bar `Class.CoreGui`. A value
of `0` is completely opaque and a value of `1` is completely transparent.
Values outside of the range `[0, 1]` are clamped. The default transparency
of the topbar is `0.5`.

Using the `Class.StarterGui:SetCore()` method with the `"TopbarEnabled"`
option allows you to enable/disable the entire topbar and all of its
features (player list, health, etc). By contrast, this method only affects
how the top bar is displayed.

**Parameters:**

- `transparency` : `float` — 

**Returns:**

- `()` — 

## Events

### `PlayerGui.TopbarTransparencyChangedSignal`

```
TopbarTransparencyChangedSignal(transparency: float)
```

- security=`None` ; tags=`Deprecated` ; capabilities=`UI`

Fires when the transparency of the Topbar CoreGui changes.

**Parameters:**

- `transparency` : `float` — 

## Notes / Deprecations

- Property `PlayerGui.CurrentScreenOrientation` security: `read=None, write=None`
- Property `PlayerGui.ScreenOrientation` security: `read=None, write=None`
- Property `PlayerGui.SelectionImageObject` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- PlayerGui:GetTopbarTransparency: PlayerGui-GetTopbarTransparency1
- PlayerGui:SetTopbarTransparency: PlayerGui-SetTopbarTransparency1
- PlayerGui:SetTopbarTransparency: custom-topbar-style
- PlayerGui.TopbarTransparencyChangedSignal: PlayerGui-TopbarTransparencyChangedSignal1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/PlayerGui
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/PlayerGui.yaml
- Captured: 2026-04-16
