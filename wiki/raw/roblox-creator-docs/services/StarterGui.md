---
title: StarterGui
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/StarterGui
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/StarterGui.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: gui
tags: [roblox-class, gui, starter]
---

# StarterGui

A container for `Class.LayerCollector` objects to be copied into the
`Class.PlayerGui` of `Class.Player|Players`. Also provides a range of
functions for interacting with the `Class.CoreGui`.

## Description

`Class.StarterGui` is a container object designed to hold
`Class.LayerCollector` objects such as `Class.ScreenGui|ScreenGuis`.

When a `Class.Player.Character` spawns, the contents of their
`Class.PlayerGui` (if any) are emptied. Children of the `Class.StarterGui` are
then copied along with their descendants into the `Class.PlayerGui`. Note,
however, that `Class.LayerCollector` objects such as
`Class.ScreenGui|ScreenGuis` with their
`Class.LayerCollector.ResetOnSpawn|ResetOnSpawn` property set to `false` will
only be placed into each player's `Class.PlayerGui` once and will not be
deleted when the `Class.Player` respawns.

`Class.StarterGui` also includes a range of functions allowing you to interact
with the `Class.CoreGui`. For example `Class.StarterGui:SetCoreGuiEnabled()`
can be used to disable elements of the `Class.CoreGui`, and
`Class.StarterGui:SetCore()` can perform a range of functions including
creating notifications and system messages.

## Inheritance

Inherits from: `BasePlayerGui`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

### `StarterGui.ProcessUserInput`

- **Type:** `boolean`
- **Security:** `read=PluginSecurity, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `UI`

Allows this service to process input like `Class.PlayerGui` and
`Class.CoreGui` do.

Allows `Class.StarterGui` to process input like `Class.PlayerGui` and
`Class.CoreGui` do. The default value is `false`.

### `StarterGui.ResetPlayerGuiOnSpawn`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `UI`
- **Deprecated:** This property is deprecated. Use `Class.LayerCollector.ResetOnSpawn` to
control the resetting behavior for individual `Class.LayerCollector`
objects.

Determines whether each child parented to the StarterGui will be cloned
into a player's PlayerGui when that player's character is respawned.

If set to true, each child parented to the `Class.StarterGui` will be
cloned into a player's `Class.PlayerGui` when that player's character is
respawned.

If one of the children is a PlayerGui and it has its PlayerGui property
set to false, it will not be cloned.

### `StarterGui.RtlTextSupport`

- **Type:** `RtlTextSupport`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `UI`

### `StarterGui.ScreenOrientation`

- **Type:** `ScreenOrientation`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Sets the default screen orientation mode for users with mobile devices.

This property sets the preferred screen orientation mode for users with
mobile devices. For the different modes available, see
`Enum.ScreenOrientation`.

By default, this property is set to
`Enum.ScreenOrientation.Sensor|Sensor`, meaning the experience is
displayed depending on the best match to the device's current orientation,
either landscape (left/right) or portrait.

When a `Class.Player` joins the experience on a mobile device, this
property determines the device's starting orientation and sets that
player's `Class.PlayerGui.ScreenOrientation` accordingly. You can also get
the player's current screen orientation through
`Class.PlayerGui.CurrentScreenOrientation`, useful when using one of the
"sensor" `Enum.ScreenOrientation` settings.

Note that changing this property will not change the screen orientation
for `Class.Player|Players` already in the experience. To change the
orientation for an existing player, use their
`Class.PlayerGui.ScreenOrientation` property.

### `StarterGui.ShowDevelopmentGui`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines whether the contents of `Class.StarterGui` is visible in
Studio.

This property determines whether the contents of `Class.StarterGui` is
visible in Studio.

### `StarterGui.VirtualCursorMode`

- **Type:** `VirtualCursorMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `UI`

## Methods

### `StarterGui:GetCore`

```
GetCore(parameterName: string) -> Variant
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`UI`

Returns a variable that has been specified by a Roblox core script.

This method returns data set or made available by Roblox's core scripts.
The first and only parameter is a string that selects the information to
be fetched. The following sections describe the strings and the data they
return by this function.

Calling this method may yield. Many of these also register an equivalent
`Class.StarterGui:SetCore()|SetCore()` function (these are marked with an
asterisk).

##### PointsNotificationsActive \*

Returns `true` if player point notifications are enabled.

##### BadgesNotificationsActive \*

Returns `true` if badge notifications are enabled.

##### AvatarContextMenuEnabled \*

Returns `true` if the
[Avatar Context Menu](../../../players/avatar-context-menu.md) is enabled.

##### ChatActive \*

Returns whether the chat is active or not. This is indicated by the
selection state of the top bar's chat icon.

##### ChatWindowSize \*

Returns the size of the chat window as a `Datatype.UDim2`.

##### ChatWindowPosition \*

Returns the size of the chat window as a `Datatype.UDim2`.

##### ChatBarDisabled \*

Returns `true` if the chat bar is disabled.

##### GetBlockedUserIds

Returns a list of `Class.Player.UserId|UserIds` associated with users that
have been blocked by the local player.

##### PlayerBlockedEvent

Returns a `Class.BindableEvent` that is fired whenever a player is blocked
by the local player.

##### PlayerUnblockedEvent

Returns a `Class.BindableEvent` that is fired whenever a player is
unblocked by the local player.

##### PlayerMutedEvent

Returns a `Class.BindableEvent` that is fired whenever a player is muted
by the local player.

##### PlayerUnmutedEvent

Returns a `Class.BindableEvent` that is fired whenever a player is unmuted
by the local player.

##### PlayerFriendedEvent

Returns a `Class.BindableEvent` that is fired whenever a player is
connected by the local player.

##### PlayerUnfriendedEvent

Returns a `Class.BindableEvent` that is fired whenever a player is
unconnected by the local player.

##### DevConsoleVisible \*

Returns `true` if the
[Developer Console](../../../studio/developer-console.md) is visible.

##### VRRotationIntensity

Returns a string describing the camera rotation sensitivity in VR: `Low`,
`High` and `Smooth`. This will not be available unless
`Class.VRService.VREnabled` is `true`.

**Parameters:**

- `parameterName` : `string` — 

**Returns:**

- `Variant` — 

### `StarterGui:GetCoreGuiEnabled`

```
GetCoreGuiEnabled(coreGuiType: CoreGuiType) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Returns whether the given `Enum.CoreGuiType`is enabled, or if it has been
disabled using `Class.StarterGui:SetCoreGuiEnabled()`.

This function returns whether the given `Enum.CoreGuiType`is enabled, or
if it has been disabled using `Class.StarterGui:SetCoreGuiEnabled()`. This
function should be called on the client.

Note that setting `"TopbarEnabled"` to `false` using
`Class.StarterGui:SetCore()|SetCore()` hides all
`Enum.CoreGuiType|CoreGuiTypes` but does not affect the result of this
function.

**Parameters:**

- `coreGuiType` : `CoreGuiType` — The given `Enum.CoreGuiType`.

**Returns:**

- `boolean` — Whether the given `Enum.CoreGuiType` is enabled.

### `StarterGui:SetCore`

```
SetCore(parameterName: string, value: Variant) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Allows you to perform certain interactions with Roblox's core scripts.

This method (not to be confused with
`Class.StarterGui:SetCoreGuiEnabled()|SetCoreGuiEnabled()`) exposes a
variety of functionality defined by Roblox's core scripts, such as sending
notifications, toggling notifications for badges/points, defining a
callback for the reset button, or toggling the topbar.

The first parameter is a string that selects the functionality with which
the call will interact. It may be necessary to call this method multiple
times using `Global.LuaGlobals.pcall()` in case the respective core script
has not yet loaded (or if it has been disabled entirely).

The following table describes the strings that may be accepted as the
first parameter. The parameters that should follow are dependent on the
functionality that will be used and are described in sub-tables.

##### ChatActive

Controls whether the chat is active.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>	
    </tr>
	</thead>
  <tbody>
	<tr>
    <td><code>active</code></td>
    <td>boolean</td>
    <td>(required)</td>
    <td>Determines whether the chat should be made active.</td>
  </tr>
  </tbody>
</table>

##### PointsNotificationsActive

Controls whether notifications for earned player points will appear.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
	</thead>
  <tbody>
	<tr>
    <td><code>active</code></td>
    <td>boolean</td>
    <td>(required)</td>
    <td>Determines whether notifications for earned player points will appear.</td>
  </tr>
  </tbody>
</table>

##### BadgesNotificationsActive

Controls whether notifications for earned badges will appear.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
      </tr>
	</thead>
  <tbody>
	<tr>
    <td><code>active</code></td>
    <td>boolean</td>
    <td>(required)</td>
    <td>Determines whether notifications for earned badges
will appear.</td>
  </tr>
  </tbody>
</table>

##### ResetButtonCallback

Determines the behavior, if any, of the reset button given a boolean or a
`Class.BindableEvent` to be fired when a player requests to reset.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
		</thead>
    <tbody>
	<tr>
    <td><code>enabled</code></td>
    <td>boolean</td>
    <td>(required)</td>
    <td>Determines whether the reset button retains its default behavior.</td>
  </tr>
	<tr>
    <td colspan="4"><b>OR</b></td>
  </tr>
	<tr>
    <td><code>callback</code></td>
    <td><code>Class.BindableEvent</code></td>
    <td>(required)</td>
    <td>A <code>Class.BindableEvent</code> to be fired when the player confirms they want to reset.</td>
  </tr>
  </tbody>
</table>

##### ChatMakeSystemMessage

Display a formatted message in the chat. Using this method requires the
experience's `Class.TextChatService.ChatVersion` to be set to
`Enum.ChatVersion|LegacyChatService`, although legacy chat is
**deprecated** and usage is discouraged. For experiences using the current
`Class.TextChatService`, refer to
`Class.TextChannel:DisplaySystemMessage()`.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
      </tr>
	</thead>
  <tbody>
	<tr>
    <td><code>configTable</code></td>
    <td>dictionary</td>
    <td>(required)</td>
    <td>A dictionary of information describing the message (see below).</td>
  </tr>
  </tbody>
</table>

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>Text</code></td>
    <td>string</td>
    <td>(required)</td>
    <td>The message to display.</td>
  </tr>
	<tr>
    <td><code>Color</code></td>
    <td><code>Datatype.Color3</code></td>
    <td><code>Datatype.Color3.fromRGB(255, 255, 243)</code></td>
    <td>Text color of the message.</td>
  </tr>
	<tr>
    <td><code>Font</code></td>
    <td><code>Enum.Font</code></td>
    <td><code>SourceSansBold</code></td>
    <td>Font of the message.</td>
  </tr>
	<tr>
    <td><code>TextSize</code></td>
    <td>integer</td>
    <td><code>18</code></td>
    <td>Text size of the message.</td>
  </tr>
  </tbody>
</table>

##### SendNotification

Causes a non-intrusive notification to appear at the bottom right of the
screen. The notification may have up to two buttons.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
  <tbody>
	<tr>
    <td><code>configTable</code></td>
    <td>dictionary</td>
    <td>(required)</td>
    <td>A dictionary of information describing the notification (see below).</td>
  </tr>
  </tbody>
</table>

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>Title</code></td>
    <td>string</td>
    <td>(required)</td>
    <td>The title of the notification.</td>
  </tr>
	<tr>
    <td><code>Text</code></td>
    <td>string</td>
    <td>(required)</td>
    <td>The main text of the notification.</td>
  </tr>
	<tr>
    <td><code>Icon</code></td>
    <td>string</td>
    <td></td>
    <td>The image to display with the notification.</td>
  </tr>
	<tr>
    <td><code>Duration</code></td>
    <td>number</td>
    <td><code>5</code></td>
    <td>Duration (in seconds) the notification should stay visible.</td>
  </tr>
	<tr>
    <td><code>Callback</code></td>
    <td><code>Class.BindableFunction</code></td>
    <td></td>
    <td>A <code>Class.BindableFunction</code> that should be invoked with the text of the button pressed by the player.</td>
  </tr>
	<tr>
    <td><code>Button1</code></td>
    <td>string</td>
    <td></td>
    <td>The text to display on the first button.</td>
  </tr>
	<tr>
    <td><code>Button2</code></td>
    <td>string</td>
    <td></td>
    <td>The text to display on the second button.</td>
  </tr>
  </tbody>
</table>

##### TopbarEnabled

Determines whether the topbar is displayed. Disabling the topbar will also
disable all `Class.CoreGui|CoreGuis` such as the chat, inventory, and
player list (for example, those set with
`Class.StarterGui:SetCoreGuiEnabled()|SetCoreGuiEnabled`).

When disabled, the region the topbar once occupied will still capture
mouse events; however, buttons placed there will not respond to clicks.
The origin of GUI space will still be offset 36 pixels from the top of the
screen.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>enabled</code></td>
    <td>boolean</td>
    <td>(required)</td>
    <td>Determines whether the topbar should be visible.</td>
  </tr>
</tbody>
</table>

##### DevConsoleVisible

Determines whether the
[Developer Console](../../../studio/developer-console.md) is visible.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>visibility</code></td>
    <td>boolean</td>
    <td>(required)</td>
    <td>Determines whether the console is visible.</td>
  </tr>
</tbody>
</table>

##### PromptSendFriendRequest

Prompts the current player to send a friend request to the given
`Class.Player`.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>player</code></td>
    <td><code>Class.Player</code></td>
    <td>(required)</td>
    <td>The player to which the friend request should be sent.</td>
  </tr>
</tbody>
</table>

##### PromptUnfriend

Prompts the current player to remove a given `Class.Player` from their
friends list.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>player</code></td>
    <td><code>Class.Player</code></td>
    <td>(required)</td>
    <td>The player who should be unconnected.</td>
  </tr>
</tbody>
</table>

##### PromptBlockPlayer

Prompts the current player to block the given `Class.Player`.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>player</code></td>
    <td><code>Class.Player</code></td>
    <td>(required)</td>
    <td>The player who should be blocked.</td>
  </tr>
  </tbody>
</table>

##### PromptUnblockPlayer

Prompts the current player to unblock the given `Class.Player`.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
 </thead>
 <tbody>
	<tr>
    <td><code>player</code></td>
    <td><code>Class.Player</code></td>
    <td>(required)</td>
    <td>The player who should be unblocked.</td>
  </tr>
  </tbody>
</table>

##### AvatarContextMenuEnabled

Determines whether the
[Avatar Context Menu](../../../players/avatar-context-menu.md) is enabled.

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>enabled</code></td>
    <td>boolean</td>
    <td>(required)</td>
    <td>Determines whether the context menu is enabled.</td>
  </tr>
</tbody>
</table>

##### AvatarContextMenuTarget

Forcibly opens the
[Avatar Context Menu](../../../players/avatar-context-menu.md).

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>player</code></td>
    <td><code>Class.Player</code></td>
    <td>(required)</td>
    <td>The player on whom the context menu will be opened.</td>
  </tr>
</tbody>
</table>

##### AddAvatarContextMenuOption

Adds an option to the
[Avatar Context Menu](../../../players/avatar-context-menu.md).

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>option</code></td>
    <td><code>Enum.AvatarContextMenuOption</code></td>
    <td>(required)</td>
    <td>Option to add.</td>
  </tr>
	<tr>
    <td colspan="4"><b>OR</b></td>
  </tr>
	<tr>
    <td><code>option</code></td>
    <td>table</td>
    <td>(required)</td>
    <td>A two-element table, where the first is the name of the custom action, and the second is a <code>Class.BindableEvent</code> which will be fired with a player was selected when the option was activated.</td>
  </tr>
</tbody>
</table>

##### RemoveAvatarContextMenuOption

Removes an option to the
[Avatar Context Menu](../../../players/avatar-context-menu.md). The
`option` argument must be the same as what was used with
`"AddAvatarContextMenuOption"` (see above).

<table size="small">
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Default</th>
			<th>Description</th>
    </tr>
</thead>
<tbody>
	<tr>
    <td><code>option</code></td>
    <td>Variant</td>
    <td>(required)</td>
    <td>The same value provided to <b>AddAvatarContextMenuOption</b>.</td>
  </tr>
  </tbody>
</table>

##### AvatarContextMenuTheme

Configures the customizable
[Avatar Context Menu](../../../players/avatar-context-menu.md) which is an
opt-in feature that allows easy player-to-player social interaction via
custom actions, such as initiating trades, battles, and more. For more
info on how to customize its theme, see the
[Avatar Context Menu](../../../players/avatar-context-menu.md) article.

##### CoreGuiChatConnections

Sets up a bindable gateway connection between the `Class.CoreGui` topbar's
chat button and the legacy chat system. The second parameter must be a
table of `Class.BindableEvent|BindableEvents` and
`Class.BindableFunction|BindableFunctions`.

**Parameters:**

- `parameterName` : `string` — Selects the functionality with which the call will interact.
- `value` : `Variant` — A table of `Class.BindableEvent|BindableEvents` and `Class.BindableFunction|BindableFunctions`.

**Returns:**

- `()` — 

### `StarterGui:SetCoreGuiEnabled`

```
SetCoreGuiEnabled(coreGuiType: CoreGuiType, enabled: boolean) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`

Sets whether the `Class.CoreGui` element associated with the given
`Enum.CoreGuiType` is enabled or disabled.

This function sets whether the `Class.CoreGui` element associated with the
given `Enum.CoreGuiType` is enabled or disabled.

The top bar cannot be disabled using this function. To disable it, set
`"TopbarEnabled"` to `false` using `Class.StarterGui:SetCore()`.

**Parameters:**

- `coreGuiType` : `CoreGuiType` — The given `Enum.CoreGuiType`.
- `enabled` : `boolean` — Whether to enable or disable the given `Enum.CoreGuiType`.

**Returns:**

- `()` — 

## Events

_No public events documented._

## Notes / Deprecations

- Deprecated property `StarterGui.ResetPlayerGuiOnSpawn`: This property is deprecated. Use `Class.LayerCollector.ResetOnSpawn` to
control the resetting behavior for individual `Class.LayerCollector`
objects.
- Property `StarterGui.ProcessUserInput` security: `read=PluginSecurity, write=PluginSecurity`
- Property `StarterGui.ResetPlayerGuiOnSpawn` security: `read=None, write=None`
- Property `StarterGui.RtlTextSupport` security: `read=None, write=None`
- Property `StarterGui.ScreenOrientation` security: `read=None, write=None`
- Property `StarterGui.ShowDevelopmentGui` security: `read=None, write=None`
- Property `StarterGui.VirtualCursorMode` security: `read=None, write=None`
- Method `StarterGui:GetCore` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- StarterGui:GetCoreGuiEnabled: StarterGui-GetCoreGuiEnabled1
- StarterGui:SetCore: StarterGui-SetCore1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/StarterGui
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/StarterGui.yaml
- Captured: 2026-04-16
