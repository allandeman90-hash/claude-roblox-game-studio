---
title: GuiService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/GuiService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/GuiService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: gui
tags: [roblox-class, gui, service]
---

# GuiService

Offers numerous properties and methods for working with
`Class.GuiObject|GuiObjects`, player preferences, and other UI‑related tasks.

## Description

`GuiService` offers numerous properties and methods for working with
`Class.GuiObject|GuiObjects`, player preferences, and other UI‑related tasks.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`, `NotReplicated`

Memory category: `Instances`

## Properties

### `GuiService.AutoSelectGuiEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

If activated, the <kbd>Select</kbd> button on a gamepad or
<kbd>Backslash</kbd> will automatically set a GUI as the selected object.

If activated, the <kbd>Select</kbd> button on a gamepad or
<kbd>Backslash</kbd> will automatically set a GUI as the selected object.
Disabling this means that GUI navigation will still work if
`Class.GuiService.GuiNavigationEnabled|GuiNavigationEnabled` is enabled,
but you will have to set `Class.GuiService.SelectedObject|SelectedObject`
manually to start navigation.

### `GuiService.CoreGuiNavigationEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `UI`, `Input`

Toggles whether or not objects in the `Class.CoreGui` can be navigated
using a gamepad.

### `GuiService.GuiNavigationEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

Used to enable and disable the default controller GUI navigation.

### `GuiService.IsModalDialog`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `UI`
- **Deprecated:** This item is deprecated. Do not use it for new work.

Indicates whether a modal dialog is visible.

This property tells whether or not a modal dialog is visible, such as the
game menu or a purchase prompt.

### `GuiService.IsWindows`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `UI`
- **Deprecated:** This item is deprecated. Do not use it for new work.

Indicates whether the user is playing on a computer running Windows.

The IsWindows property defines if the user is playing on a computer
running Windows.

### `GuiService.MenuIsOpen`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Returns `true` if any menu of `Class.CoreGui` is open.

### `GuiService.PreferredTextSize`

- **Type:** `PreferredTextSize`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Gets the player's preferred text size as an `Enum.PreferredTextSize`
value.

Gets the player's preferred text size as an `Enum.PreferredTextSize` value
of `Enum.PreferredTextSize.Medium|Medium` (default),
`Enum.PreferredTextSize.Large|Large`,
`Enum.PreferredTextSize.Larger|Larger`, or
`Enum.PreferredTextSize.Largest|Largest`. This property maps to the
**Text&nbsp;Size** setting available to players from the Roblox and
in‑game **Settings** menus, and it can be combined with
`Class.Object.GetPropertyChangedSignal()` to detect text size setting
changes for purposes of adjusting UI.

When working with UI elements, note the following behaviors:

- Text that is constrained to a minimum and/or maximum size through a
  `Class.UITextSizeConstraint` will **not** shrink below or expand above
  the set
  `Class.UITextSizeConstraint.MinTextSize|MinTextSize`/`Class.UITextSizeConstraint.MaxTextSize|MaxTextSize`,
  regardless of the player's text size setting.

- When `Class.TextLabel.TextScaled|TextScaled` is enabled for a
  `Class.TextLabel.TextScaled|TextLabel` or
  `Class.TextButton.TextScaled|TextButton`, the element's text will
  **not** be scaled by the
  `Class.GuiService.PreferredTextSize|PreferredTextSize` value.

- UI elements with `Class.GuiObject.AutomaticSize|AutomaticSize` enabled
  will shrink/grow as
  `Class.GuiService.PreferredTextSize|PreferredTextSize`
  decreases/increases (element bounds will resize to fit the resized
  text).

- When `Class.TextLabel.TextWrapped|TextWrapped` is enabled for a
  `Class.TextLabel.TextWrapped|TextLabel` or
  `Class.TextButton.TextWrapped|TextButton`, the element's text will wrap
  to additional lines as
  `Class.GuiService.PreferredTextSize|PreferredTextSize` increases, within
  limits of the element's absolute size.

- The results returned by `Class.TextService:GetTextSize()` and
  `Class.TextService:GetTextBoundsAsync()` honor changes related to
  `Class.GuiService.PreferredTextSize|PreferredTextSize`.

### `GuiService.PreferredTransparency`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Gets the player's preferred transparency as a number between `0` and `1`.

Gets the player's preferred transparency as a number between `0` and `1`.
This property maps to the **Background&nbsp;Transparency** setting
available to players from the Roblox and in‑experience **Settings** menus,
and it can be combined with `Class.Object.GetPropertyChangedSignal()` to
detect transparency setting changes for purposes of adjusting UI.

A value of `1` (default) indicates the player prefers the default
background transparency, while a value of `0` indicates the player prefers
fully opaque (non‑transparent) background transparency for improved
readability and contrast. Multiplying a UI element's
`Class.GuiObject.BackgroundTransparency|BackgroundTransparency` with
`Class.GuiService.PreferredTransparency|PreferredTransparency` is the
recommended approach, such that backgrounds become more opaque as
`Class.GuiService.PreferredTransparency|PreferredTransparency` approaches
`0`.

### `GuiService.ReducedMotionEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Returns `true` if the player has enabled reduced motion.

Returns `true` if the player has enabled reduced motion, indicating that
they want motion effects and animations to be reduced or completely
removed. This property maps to the **Reduce&nbsp;Motion** toggle available
from the Roblox and in‑experience **Settings** menus. See
[accessibility guidelines](../../../production/publishing/accessibility.md#reduced-motion)
for usage recommendations.

### `GuiService.SelectedObject`

- **Type:** `GuiObject`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

Sets the `Class.GuiObject` currently being focused on by the GUI
navigator.

Sets the `Class.GuiObject` currently being focused on by the GUI
navigator. This may reset to `nil` if the object is off screen.

This property is changed by the
`Class.GuiObject.SelectionGained|SelectionGained` and
`Class.GuiObject.SelectionLost|SelectionLost` events. If you would like to
determine when this property changes without tracking these events for all
GUI elements, you can use the `Class.Object.Changed|Changed` event.

### `GuiService.TopbarInset`

- **Type:** `Rect`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Used to determine the absolute size and position of unobstructed area
within top bar space.

Returns a `Datatype.Rect` object representing the unoccupied area between
the Roblox left-most controls and the edge of the device safe area.

The value is dynamic and can be expected to change based on the visibility
of UI controls such as changing the local player's
`Class.Humanoid.Health|Health` property, usage of
`Class.StarterGui:SetCoreGuiEnabled()`, changing the size and position of
Roblox UI Controls, and/or others. For this reason, it's recommend that
you detect and react to changes of this property with
`Class.Object:GetPropertyChangedSignal()`.

### `GuiService.TouchControlsEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

Used to enable and disable touch controls and touch control display UI.
Defaults to `true`.

### `GuiService.ViewportDisplaySize`

- **Type:** `DisplaySize`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `UI`

Read-only property which represents the physical rendering size of the
viewport.

Read-only property which represents the physical rendering size of the
viewport. You can listen for changes to this property through the
`Class.Object:GetPropertyChangedSignal()|GetPropertyChangedSignal()`
method to adapt UI to various display sizes.

## Methods

### `GuiService:AddSelectionParent`

```
AddSelectionParent(selectionName: string, selectionParent: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`UI`

Creates a selection group where gamepad GUI navigation will only consider
selectable objects that are within the group.

Creates a selection group where gamepad GUI navigation will only consider
selectable objects that are within the group (children of
`selectionParent`). An example is when you have a menu pop open and there
are other selectable objects on the screen, possibly from previous menus,
but you want the user to only be able to select GUI objects in the new
menu.

**Parameters:**

- `selectionName` : `string` — 
- `selectionParent` : `Instance` — 

**Returns:**

- `()` — 

### `GuiService:AddSelectionTuple`

```
AddSelectionTuple(selectionName: string, selections: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`UI`

**AddSelectionTuple** works similarly to
`Class.GuiService:AddSelectionParent()`, but you can give it a tuple of
`Class.GuiObject` that you want to be contained in the group.

Beware that the second argument is _not_ a table, but rather the first of
several `Class.GuiObject` in the tuple. To pass the contents of a table,
use `unpack`/`table.unpack`:

```lua
local frame = script.Parent
-- Passing various GuiObject individually
GuiService:AddSelectionTuple("InventoryButtons", frame.Sort, frame.Trash, frame.Drop)
-- Unpacking a table of GuiObject (unpack/table.unpack are equivalent)
local inventoryButtons = { frame.Sort, frame.Trash, frame.Drop }
GuiService:AddSelectionTuple("InventoryButtons", unpack(inventoryButtons))
```

Functions similarly to `Class.GuiService:AddSelectionParent()`, but you
can give it a tuple of `Class.GuiObject` that you want to be contained in
the group.

**Parameters:**

- `selectionName` : `string` — The name of the added selection.
- `selections` : `Tuple` — The selection(s) added.

**Returns:**

- `()` — 

### `GuiService:CloseInspectMenu`

```
CloseInspectMenu() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Closes the avatar inspection menu, if open.

This method closes the
[Avatar Inspect Menu](../../../players/avatar-inspect-menu.md), if open,
when run from a `Class.LocalScript`.

#### See Also

- `Class.GuiService:InspectPlayerFromHumanoidDescription()|InspectPlayerFromHumanoidDescription()`
  which allows the avatar inspection menu to appear showing the assets
  listed in a `Class.HumanoidDescription` object.

- `Class.GuiService:InspectPlayerFromUserId()|InspectPlayerFromUserId()`
  which allows the avatar inspection menu to appear showing the user that
  has the given `Class.Player.UserId|UserId`.

**Returns:**

- `()` — 

### `GuiService:DismissNotification`

```
DismissNotification(notificationId: string) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

**Parameters:**

- `notificationId` : `string` — 

**Returns:**

- `boolean` — 

### `GuiService:GetEmotesMenuOpen`

```
GetEmotesMenuOpen() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Checks if the player emotes menu is open.

Returns a boolean indicating whether or not the player emotes menu is
open. You can open or close the emotes menu by calling the
`Class.GuiService:SetEmotesMenuOpen()|SetEmotesMenuOpen()` method.

**Returns:**

- `boolean` — Whether the emotes menu is open.

### `GuiService:GetGameplayPausedNotificationEnabled`

```
GetGameplayPausedNotificationEnabled() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Returns whether or not the `Class.Player.GameplayPaused` notification has
been disabled.

This method returns whether or not the `Class.Player.GameplayPaused`
notification has been disabled through
`Class.GuiService:SetGameplayPausedNotificationEnabled()|SetGameplayPausedNotificationEnabled()`.

See also `Class.Workspace.StreamingIntegrityMode` and
`Enum.StreamingIntegrityMode` for more details on when gameplay is paused.

**Returns:**

- `boolean` — Whether or not the `Class.Player.GameplayPaused` notification has been disabled.

### `GuiService:GetGuiInset`

```
GetGuiInset() -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Returns two `Datatype.Vector2` values representing the inset of user GUIs
in pixels, from the top‑left corner of the screen and the bottom‑right
corner of the screen respectively.

Returns two `Datatype.Vector2` values representing the inset of user GUIs
in pixels, from the top‑left corner of the screen and the bottom‑right
corner of the screen respectively.

The inset values supplied by this method only take effect on
`Class.ScreenGui|ScreenGuis` that have their
`Class.ScreenGui.IgnoreGuiInset|IgnoreGuiInset` property set to `false`.

**Returns:**

- `Tuple` — A tuple of two `Datatype.Vector2` values describing the current specified GUI inset.

### `GuiService:GetInsetArea`

```
GetInsetArea(screenInsets: ScreenInsets) -> Rect
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

**Parameters:**

- `screenInsets` : `ScreenInsets` — 

**Returns:**

- `Rect` — 

### `GuiService:GetInspectMenuEnabled`

```
GetInspectMenuEnabled() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Returns whether the avatar inspection menu is enabled.

This method returns whether the
[Avatar Inspect Menu](../../../players/avatar-inspect-menu.md) is
currently enabled. The feature is enabled by default and can be disabled
using the
`Class.GuiService:SetInspectMenuEnabled()|SetInspectMenuEnabled()` method.

**Returns:**

- `boolean` — Whether the avatar inspection menu is enabled.

### `GuiService:InspectPlayerFromHumanoidDescription`

```
InspectPlayerFromHumanoidDescription(humanoidDescription: Instance, name: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `AvatarAppearance`

Allows the avatar inspection menu to appear showing the assets listed in a
`Class.HumanoidDescription` object.

This method allows the
[Avatar Inspect Menu](../../../players/avatar-inspect-menu.md) to appear
showing the assets listed in a `Class.HumanoidDescription` object. This
allows further customization with what is shown in the inspection menu
when players inspect other players in your experience.

See also
`Class.GuiService:InspectPlayerFromUserId()|InspectPlayerFromUserId()`
which allows the avatar inspection menu to appear showing the user that
has the given `Class.Player.UserId|UserId`.

**Parameters:**

- `humanoidDescription` : `Instance` — A `Class.HumanoidDescription` object that contains the assets to show in the inspection menu.
- `name` : `string` — The name of the player being inspected to show in the menu.

**Returns:**

- `()` — 

### `GuiService:InspectPlayerFromUserId`

```
InspectPlayerFromUserId(userId: int64) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `AvatarAppearance`

Allows the avatar inspection menu to appear showing the user that has the
given `Class.Player.UserId|UserId`.

This method allows the
[Avatar Inspect Menu](../../../players/avatar-inspect-menu.md) to appear
showing the user that has the given `Class.Player.UserId|UserId`. This is
especially useful when you want to inspect players who aren't in the
current experience.

See also
`Class.GuiService:InspectPlayerFromHumanoidDescription()|InspectPlayerFromHumanoidDescription()`
which allows you to bring up the avatar inspection menu showing the assets
listed in a `Class.HumanoidDescription` object.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId|UserId` of the player to inspect.

**Returns:**

- `()` — 

### `GuiService:IsTenFootInterface`

```
IsTenFootInterface() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Returns `true` if the client is using the ten foot interface, a special
version of Roblox's UI exclusive to consoles.

Returns `true` if the client is using the ten foot interface, a special
version of Roblox's UI exclusive to consoles.

Note that you should **not** use this property in an attempt to verify if
the player is on a console or not. Instead, consider reading
`Class.GuiService.ViewportDisplaySize|ViewportDisplaySize`.

**Returns:**

- `boolean` — 

### `GuiService:RemoveSelectionGroup`

```
RemoveSelectionGroup(selectionName: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`UI`

Removes a group that was created with
`Class.GuiService:AddSelectionParent()|AddSelectionParent()` or
`Class.GuiService:AddSelectionTuple()|AddSelectionTuple()`.

**Parameters:**

- `selectionName` : `string` — 

**Returns:**

- `()` — 

### `GuiService:Select`

```
Select(selectionParent: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Sets `Class.GuiService.SelectedObject` to a child of a provided instance
that is the `Class.PlayerGui` or its descendants.

When called on an instance `selectionParent` that is the `Class.PlayerGui`
or a descendant of it, the engine searches all available selectable,
visible and on-screen `Class.GuiObject|GuiObjects` that are descendants of
`selectionParent` and sets the
`Class.GuiService.SelectedObject|SelectedObject` to the `Class.GuiObject`
with the smallest `Class.GuiObject.SelectionOrder|SelectionOrder`.

**Parameters:**

- `selectionParent` : `Instance` — The parent of selection whose descendants are searched.

**Returns:**

- `()` — 

### `GuiService:SendNotification`

```
SendNotification(notificationInfo: Dictionary) -> string
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

**Parameters:**

- `notificationInfo` : `Dictionary` — 

**Returns:**

- `string` — 

### `GuiService:SetEmotesMenuOpen`

```
SetEmotesMenuOpen(isOpen: boolean) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Opens or closes the player emotes menu.

**Parameters:**

- `isOpen` : `boolean` — 

**Returns:**

- `()` — 

### `GuiService:SetGameplayPausedNotificationEnabled`

```
SetGameplayPausedNotificationEnabled(enabled: boolean) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Lets you disable the built-in notification when a player's gameplay is
paused.

This method lets you disable the built-in notification when a player's
gameplay is paused. You can then add in your own UI and customize it.

You can query whether the notification is enabled by calling the
`Class.GuiService:GetGameplayPausedNotificationEnabled()|GetGameplayPausedNotificationEnabled()`
method.

See also `Class.Workspace.StreamingIntegrityMode` and
`Enum.StreamingIntegrityMode` for more details on when gameplay is paused.

**Parameters:**

- `enabled` : `boolean` — Whether or not the built-in notification GUI is disabled.

**Returns:**

- `()` — 

### `GuiService:SetInspectMenuEnabled`

```
SetInspectMenuEnabled(enabled: boolean) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Allows you to enable or disable the avatar inspection menu.

This method allows you to enable or disable the
[Avatar Inspect Menu](../../../players/avatar-inspect-menu.md). The
feature is enabled by default.

**Parameters:**

- `enabled` : `boolean` — A boolean indicating whether to enable or disable the menu.

**Returns:**

- `()` — 

## Events

### `GuiService.MenuClosed`

```
MenuClosed()
```

- security=`None` ; capabilities=`UI`

Fires when the user **closes** the Roblox `Class.CoreGui` escape menu.

### `GuiService.MenuOpened`

```
MenuOpened()
```

- security=`None` ; capabilities=`UI`

Fires when the user **opens** the Roblox `Class.CoreGui` escape menu.

## Notes / Deprecations

- Deprecated property `GuiService.IsModalDialog`: This item is deprecated. Do not use it for new work.
- Deprecated property `GuiService.IsWindows`: This item is deprecated. Do not use it for new work.
- Property `GuiService.AutoSelectGuiEnabled` security: `read=None, write=None`
- Property `GuiService.CoreGuiNavigationEnabled` security: `read=None, write=None`
- Property `GuiService.GuiNavigationEnabled` security: `read=None, write=None`
- Property `GuiService.IsModalDialog` security: `read=None, write=None`
- Property `GuiService.IsWindows` security: `read=None, write=None`
- Property `GuiService.MenuIsOpen` security: `read=None, write=None`
- Property `GuiService.PreferredTextSize` security: `read=None, write=None`
- Property `GuiService.PreferredTransparency` security: `read=None, write=None`
- Property `GuiService.ReducedMotionEnabled` security: `read=None, write=None`
- Property `GuiService.SelectedObject` security: `read=None, write=None`
- Property `GuiService.TopbarInset` security: `read=None, write=None`
- Property `GuiService.TouchControlsEnabled` security: `read=None, write=None`
- Property `GuiService.ViewportDisplaySize` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- GuiService.PreferredTextSize: GuiService-PreferredTextSize
- GuiService.PreferredTransparency: GuiService-PreferredTransparency
- GuiService.TopbarInset: GuiService-TopbarInset
- GuiService.ViewportDisplaySize: GuiService-ViewportDisplaySize

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/GuiService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/GuiService.yaml
- Captured: 2026-04-16
