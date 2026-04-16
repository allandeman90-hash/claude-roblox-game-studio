---
title: Player
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Player
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Player.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: players
tags: [roblox-class, players, instance]
---

# Player

An object that represents a presently connected client to the experience.

## Description

A `Player` object is a client that is currently connected. These objects are
added to the `Class.Players` service when a new player connects, then removed
when they eventually disconnect from the server.

The `Class.Instance.Name` property reflects the player's username. When saving
information about a player, you should use their `Class.Player.UserId|UserId`
since it is possible that a player can change their username.

There are several similar methods in the `Class.Players` service for working
with Player objects. Use these over their respective `Class.Instance` methods:

- You can get a table of current `Player` objects using
  `Class.Players:GetPlayers()`; again, use this instead of
  `Class.Instance:GetChildren()`.
- To detect the addition of `Player` objects, it is recommended to use the
  `Class.Players.PlayerAdded` event (instead of `Class.Instance.ChildAdded` on
  the `Class.Players` service).
- Similarly, you can detect the removal of `Player` objects using
  `Class.Players.PlayerRemoving`, which fires just **before** the `Player` is
  removed (instead of `Class.Instance.ChildRemoved` which fires after). This
  is important if you are saving information about the player that might be
  removed or cleaned up on removal.

## Inheritance

Inherits from: `Instance`

Memory category: `Instances`

## Properties

### `Player.AccountAge`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Players`

Describes the player's account age in days.

This property describes how long ago a player's account was registered in
days. It is set using the `Class.Player:SetAccountAge()|SetAccountAge()`
method, which cannot be accessed by scripts.

### `Player.AutoJumpEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines whether the character of a player using a mobile device will
automatically jump upon hitting an obstacle.

This property determines whether the `Class.Player.Character|Character` of
a `Class.Player` using a mobile device will automatically jump when they
hit an obstacle. This can make levels more navigable while on a mobile
device.

When the player joins the experience, the
`Class.StarterPlayer.AutoJumpEnabled` value determines the initial state
of this property. Then, this property determines the value of the
`Class.Humanoid.AutoJumpEnabled` property of the
`Class.Player.Character|Character` on spawn. In other words, it is
possible to set the auto-jump behavior on a per-character, per-player, and
per-experience basis using these three properties.

### `Player.CameraMaxZoomDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

The maximum distance the player's camera is allowed to zoom out.

This property sets the maximum distance the player's camera is allowed to
zoom out, in studs.

The default value of this property is set by
`Class.StarterPlayer.CameraMaxZoomDistance`. If this value is set to a
lower value than
`Class.Player.CameraMinZoomDistance|CameraMinZoomDistance`, it will be
increased to `Class.Player.CameraMinZoomDistance|CameraMinZoomDistance`.

### `Player.CameraMinZoomDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

The minimum distance the player's camera is allowed to zoom in.

This property sets the minimum distance the player's camera is allowed to
zoom in, in studs.

The default value of this property is set by
`Class.StarterPlayer.CameraMinZoomDistance`. If this value is set to a
higher value than
`Class.Player.CameraMaxZoomDistance|CameraMaxZoomDistance`, it will be
decreased to `Class.Player.CameraMaxZoomDistance|CameraMaxZoomDistance`.

### `Player.CameraMode`

- **Type:** `CameraMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Changes the camera's mode to either first or third person.

This property sets the player's camera mode, defaulting to third person.

#### Third Person

In the default third person mode (`Enum.CameraMode.Classic`), the
character can be seen in the camera. While in this mode, the default
behavior is:

- Players can right-click and drag (mouse), tap and drag (mobile), use the
  secondary thumbstick (gamepad), or press the left/right arrows
  (keyboard) to rotate the camera around their character.
- When a player moves their character, it faces in the corresponding
  movement direction.
- Players can zoom in and out freely, even to first person on full zoom
  in.

#### First Person

In first person mode (`Enum.CameraMode.LockFirstPerson`), the player's
camera is zoomed all the way in. Unless there is a visible GUI present
with the `Class.GuiButton.Modal` property set to `true`, moving the mouse,
tap-dragging on mobile, or using the secondary thumbstick on a gamepad
will rotate the camera around the character.

### `Player.CanLoadCharacterAppearance`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines whether the character's appearance will be loaded when the
player spawns. If `false`, the player will spawn with a default
appearance.

This property determines whether the character's appearance will be loaded
when the player spawns. The default value of this property is set by
`Class.StarterPlayer.LoadPlayerAppearance`.

- If `true`, the character will load the appearance of the player
  corresponding to the player's
  `Class.Player.CharacterAppearanceId|CharacterAppearanceId`.

- If `false`, the player will spawn with a default appearance.

Attempting to set the property after the character has spawned will not
change the character; you must call
`Class.Player:LoadCharacterAsync()|LoadCharacterAsync()` to load the new
appearance.

### `Player.Character`

- **Type:** `Model`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

A `Class.Model` controlled by the player that contains a `Class.Humanoid`,
body parts, scripts, and other objects.

This property contains a reference to a `Class.Model` containing a
`Class.Humanoid`, body parts, scripts, and other objects required for
simulating the player's avatar in-experience. The model is parented to the
`Class.Workspace` but it may be moved. It is automatically loaded when
`Class.Players.CharacterAutoLoads` is `true` and it can be manually loaded
otherwise using `Class.Player:LoadCharacterAsync()|LoadCharacterAsync()`.

Initially this property is `nil` and it is set when the player's character
first spawns. Use the `Class.Player.CharacterAdded|CharacterAdded` event
to detect when a player's character properly loads, and the
`Class.Player.CharacterRemoving|CharacterRemoving` event to detect when
the character is about to despawn. Avoid using
`Class.Object:GetPropertyChangedSignal()` on this property.

Note that `Class.LocalScript|LocalScripts` that are cloned from
`Class.StarterGui` or `Class.StarterPack` into a player's
`Class.PlayerGui` or `Class.Backpack` respectively are often run before
the old character model is replaced, so `Class.Player.Character` may refer
to the old model whose `Class.Instance.Parent|Parent` property is `nil`.
Therefore, in a `Class.LocalScript` under `Class.StarterGui` or
`Class.StarterPack`, it is advisable to make sure the parent of
`Character` is not `nil` before using it, for example:

```lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local character = player.Character
if not character or character.Parent == nil then
	character = player.CharacterAdded:Wait()
end
```

### `Player.CharacterAppearance`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotBrowsable`, `Deprecated`
- **Capabilities:** `Players`
- **Deprecated:** This item is deprecated. Do not use it for new work.

The URL of the asset containing the character's appearance, clothing, and
gear.

This property indicates the URL of the asset containing the character's
appearance, clothing, and gear. It is automatically set by Roblox to load
your avatar's appearance when you join an experience.

Attempting to set the property after the character has spawned will not
change the character, you must call
`Class.Player:LoadCharacterAsync()|LoadCharacterAsync()` to load the new
appearance.

### `Player.CharacterAppearanceId`

- **Type:** `int64`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines the user ID of the account whose character appearance is used
for a player's `Class.Player.Character|Character`.

This property determines the user ID of the account whose character
appearance is used for a player's `Class.Player.Character|Character`. By
default, this property is the `Class.Player.UserId|UserId`, which uses the
player's avatar as they have created it on Roblox.

Changing this property to the user ID of another account will cause the
player to spawn with that account's appearance.

You can also toggle whether or not a player's character appearance is
loaded in experience by changing the
`Class.StarterPlayer.LoadCharacterAppearance` property.

### `Player.DataComplexity`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Players`
- **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

The total amount of data currently being stored in the player's cache on
the current place.

This property was once used by an ancient data persistence method to
indicate the total amount of data currently being stored in the player's
cache on the current place.

#### Notes

- Booleans and numbers cost 1 data complexity unit.
- Strings cost their length divided by 100 in data complexity units.
- Instances cost their DataCost in data complexity units.
- Saving the default value (0 for numbers, false for booleans, "" for
  strings and `nil` for Instances) removes the key from the DataComplexity
  count.
- If, when using the SaveBoolean, SaveString, SaveNumber or SaveInstance
  functions, the DataComplexity for the player goes over the limit
  (currently 45000 units, defined by DataComplexityLimit), the function
  throws an error, the value is not saved, and any previous value of the
  key that was being saved to is deleted.

### `Player.DataReady`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Players`
- **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Indicates when the player's data is available to load.

This property was once used by an ancient data persistence method to
indicate when the player's data is available to load. Becomes true when
data is available.

### `Player.DevCameraOcclusionMode`

- **Type:** `DevCameraOcclusionMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Sets how the default camera handles objects between the camera and the
player.

Defines how the default camera scripts handle objects between the camera
and the camera subject. Set by
`Class.StarterPlayer.DevCameraOcclusionMode` and can't be changed for
individual players.

The default value is `Enum.DevCameraOcclusionMode|Zoom`. See
`Enum.DevCameraOcclusionMode` for a list of available modes.

### `Player.DevComputerCameraMode`

- **Type:** `DevComputerCameraMovementMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines player's camera movement mode when using a device with a mouse
and keyboard.

This property determines the manner in which a player moves their camera
when using a device with a mouse and keyboard. This property cannot be set
using a `Class.LocalScript` (it must be set on the server using a
`Class.Script`).

The default value of this property is determined by
`Class.StarterPlayer.DevComputerCameraMovementMode`.

This property doesn't affect players using a
`Class.UserInputService.TouchEnabled|TouchEnabled` device. See
`Class.Player.DevTouchCameraMode|DevTouchCameraMode` instead.

### `Player.DevComputerMovementMode`

- **Type:** `DevComputerMovementMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines player's character movement mode when using a device with a
mouse and keyboard.

This property determines the manner in which a player moves their
character when using a device with a mouse and keyboard. This property
cannot be set using a `Class.LocalScript` (it must be set on the server
using a `Class.Script`).

The default value of this property is determined by
`Class.StarterPlayer.DevComputerMovementMode`.

This property doesn't affect players using a
`Class.UserInputService.TouchEnabled|TouchEnabled` device. See
`Class.Player.DevTouchMovementMode|DevTouchMovementMode` instead.

### `Player.DevEnableMouseLock`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines if the player can toggle mouse lock.

This property determines if a player is able to toggle mouse lock by
pressing <kbd>Shift</kbd>. A player can disable the mouse lock switch in
the experience's settings during play. By default, this property is set to
the value of `Class.StarterPlayer.EnableMouseLockOption`. This can be set
server-side during runtime by using a `Class.Script`. It can not be set
client-side.

When mouse lock is enabled, the player's cursor is locked to the center of
the screen. Moving the mouse will orbit the camera around the player's
`Class.Player.Character|Character`, and the character will face the same
direction as the `Class.Camera`. It also offsets the camera view just over
the right shoulder of the player's character.

### `Player.DevTouchCameraMode`

- **Type:** `DevTouchCameraMovementMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines player's camera movement mode when using a touch-enabled
device.

This property determines the manner in which a player moves their camera
when using a `Class.UserInputService.TouchEnabled|TouchEnabled` device.
This property cannot be set using a `Class.LocalScript` (it must be set on
the server using a `Class.Script`).

The default value of this property is determined by
`Class.StarterPlayer.DevTouchCameraMovementMode`.

This property doesn't affect players who aren't using a
`Class.UserInputService.TouchEnabled|TouchEnabled` device. See
`Class.Player.DevComputerCameraMode|DevComputerCameraMode` instead.

### `Player.DevTouchMovementMode`

- **Type:** `DevTouchMovementMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines player's character movement mode when using a touch-enabled
device.

This property determines the manner in which a player moves their
character when using a `Class.UserInputService.TouchEnabled|TouchEnabled`
device. This property cannot be set using a `Class.LocalScript` (it must
be set on the server using a `Class.Script`).

The default value of this property is determined by
`Class.StarterPlayer.DevTouchMovementMode`.

This property doesn't affect players who aren't using a
`Class.UserInputService.TouchEnabled|TouchEnabled` device. See
`Class.Player.DevComputerMovementMode|DevComputerMovementMode` instead.

### `Player.DisplayName`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

The display name of the authenticated user associated with the
`Class.Player`.

This property contains the display name of the authenticated user
associated with the `Class.Player` object. Unlike
`Class.Player.UserId|UserId`, display names are non-unique names a player
displays to others.

#### Usage Notes

- Since display names are non-unique, it's possible for two players in a
  single instance to have identical names. If you need a globally unique
  identifier for a player, use `Class.Player.UserId|UserId` instead.

- Characters generated with
  `Class.Player:LoadCharacterAsync()|LoadCharacterAsync()` or by the
  Roblox engine will have their `Class.Humanoid.DisplayName` property
  assigned to the `Class.Player.DisplayName` property.

- Display names may have unicode characters in the string. See
  `Library.utf8|UTF-8` for more information on how to work with strings
  with unicode characters.

### `Player.FollowUserId`

- **Type:** `int64`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Players`

Describes the user ID of the player who was followed into an experience by
a player.

This property contains the `Class.Player.UserId|UserId` of the user that a
player followed into the experience, or `0` if the player did not follow
anyone in. This property is useful for alerting players who have been
followed by another player into the experience.

You can get the name of the player followed using this user ID and the
`Class.Players:GetNameFromUserIdAsync()` method.

### `Player.GameplayPaused`

- **Type:** `boolean`
- **Security:** `read=None, write=NotAccessibleSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`
- **Capabilities:** `Players`

Whether player client-side gameplay is currently paused.

This property indicates if the player is currently in a pause state in a
place with `Class.Workspace.StreamingEnabled|StreamingEnabled` activated.
It is set on the client but replicated to the server.

#### See Also

- `Class.Workspace.StreamingEnabled` which controls whether content
  streaming is enabled
- `Class.Workspace.StreamingIntegrityMode` and
  `Enum.StreamingIntegrityMode` for more details on when gameplay is
  paused.

### `Player.HasRobloxSubscription`

- **Type:** `boolean`
- **Security:** `read=None, write=RobloxEngineSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Indicates whether the player has an active Roblox subscription.

This read-only property is `true` when the player has an active Roblox
subscription (the flagship Roblox membership), and `false` otherwise. It
is set by the server and cannot be changed by scripts.

Use this property instead of `Class.Player.MembershipType` to check for
the Roblox subscription.

### `Player.HasVerifiedBadge`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Indicates if a player has a **Verified** badge.

This property indicates if the player has a **Verified** badge.

### `Player.HealthDisplayDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Sets the distance at which this player will see other players' health
bars.

This property sets the distance in studs at which this player will see
other `Class.Humanoid` health bars. If set to `0`, the health bars will
not be displayed. This property is set to
`Class.StarterPlayer.HealthDisplayDistance` by default.

If a humanoid's health bar is visible, you can set the display type using
`Class.Humanoid.DisplayDistanceType`.

### `Player.InputLatency`

- **Type:** `int`
- **Security:** `read=RobloxEngineSecurity, write=RobloxEngineSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

### `Player.LocaleId`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`
- **Capabilities:** `Players`

This property shows the locale ID that the local player has set for their
Roblox account.

This property shows the locale ID that the local player has set for their
Roblox account. It holds a string with the two letter code, for example
`en-us`.

See also `Class.LocalizationService.RobloxLocaleId`, the locale ID used
for localizing internal content. This will be a different value when
Roblox does not yet internally support the local player's set locale.

### `Player.MembershipType`

- **Type:** `MembershipType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Players`
- **Deprecated:** This property is deprecated. Use `Class.Player.HasRobloxSubscription` to
check whether a player has an active Roblox subscription.

Describes the account's membership type.

This property can only be read from to determine membership (it cannot be
set to another membership type). It holds a `Enum.MembershipType` enum of
the account's membership type.

### `Player.NameDisplayDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Sets the distance at which this player will see other players' names.

This property sets the distance in studs at which this player will see
other `Class.Humanoid` names. If the property is set to `0`, names are
hidden. This property is set to `Class.StarterPlayer.NameDisplayDistance`
by default.

If a humanoid's name is visible, you can set the display type using
`Class.Humanoid.DisplayDistanceType`.

### `Player.Neutral`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines whether the player is on a specific team.

This property determines whether the player is on a specific team.

- When `true`, the player is not on a specific team. This also means that
  the `Class.Player.Team|Team` property will be `nil` and the
  `Class.Player.TeamColor|TeamColor` will be white.

- When `false`, the player is on a specific team. The
  `Class.Player.Team|Team` property will correspond to the `Class.Team`
  that the player is on, as will the `Class.Player.TeamColor|TeamColor`.

### `Player.PartyId`

- **Type:** `string`
- **Security:** `read=None, write=RobloxEngineSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `Players`

A unique identifier of the party a `Class.Player` belongs to.

A read-only string identifying the party the player currently belongs to
within the experience. If the player is not in a party, this value is an
empty string.

This property is essential for integrating with the Roblox Party feature.
Use it in combination with `Class.SocialService:GetPlayersByPartyId()` and
`Class.SocialService:GetPartyAsync()` to access information about a
player's party and its members.

To test this service in your experience, use the
[Party Simulator](../../../studio/testing-modes.md#party-simulation) in
Roblox Studio or publish the experience and play it in the Roblox
application.

### `Player.ReplicationFocus`

- **Type:** `Instance`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Sets the part to focus replication around.

This property sets the part to focus replication around a player.
Different Roblox systems that communicate over the network (such as
physics, streaming, etc.) replicate at different rates depending on how
close objects are to the replication focus.

When this property is `nil`, it reverts to its default behavior which is
to treat the local player's character's
`Class.Model.PrimaryPart|PrimaryPart` as the replication focus.

This property should only be set on the server with a `Class.Script`, not
a `Class.LocalScript`. Note that this property does not change or update
network ownership of parts.

### `Player.RespawnLocation`

- **Type:** `SpawnLocation`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

If set, the player will respawn at the given `Class.SpawnLocation`.

If set, the player will respawn at the given `Class.SpawnLocation` which
must meet the following criteria:

- Descendant of `Class.Workspace`.

- The `Class.SpawnLocation.TeamColor` property is set to the player's
  `Class.Player.TeamColor|TeamColor` or the `Class.SpawnLocation.Neutral`
  property is set to `true`.

#### Alternatives

- A `Class.Player` will spawn from `Class.SpawnLocation|SpawnLocations`
  belonging to their team. In some cases it may be simpler to change the
  player's `Class.Player.Team|Team` instead.
- Implement your own custom spawn logic using `Class.PVInstance:PivotTo()`
  to manually move the `Class.Player.Character|Character`.

### `Player.StepIdOffset`

- **Type:** `int`
- **Security:** `read=RobloxEngineSecurity, write=RobloxEngineSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

### `Player.Team`

- **Type:** `Team`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Players`

Determines the `Class.Team` with which the player is associated.

This property is a reference to a `Class.Team` object within the
`Class.Teams` service. If the player isn't on a team or has an invalid
`Class.Player.TeamColor|TeamColor`, this property is `nil`. When this
property is set, the player has joined the `Class.Team` and the
`Class.Team.PlayerAdded` event fires on the associated team. Similarly,
`Class.Team.PlayerRemoved` fires when the property is unset from a certain
`Class.Team`.

### `Player.TeamColor`

- **Type:** `BrickColor`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines the `Class.Team` with which the player is associated with
according to that team's `Class.Team.TeamColor`.

This property determines which `Class.Team` a player is associated with
according to that team's `Class.Team.TeamColor`. If no `Class.Team` object
has the associated `Datatype.BrickColor`, the player will not be
associated with a team.

It's often a better idea to set `Class.Player.Team` to the respective
`Class.Team` instead of using this property. Setting this property often
leads to repetition of the same `Datatype.BrickColor` value for a certain
team across many scripts.

### `Player.ThirdPartyTextChatRestrictionStatus`

- **Type:** `ChatRestrictionStatus`
- **Security:** `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Players`

### `Player.UserId`

- **Type:** `int64`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

A unique identifying integer assigned to all user accounts.

This property contains a read-only integer that **uniquely and
consistently** identifies the user's account on Roblox. Unlike the
player's `Class.Player.DisplayName|DisplayName` which may change, this
value will never change for the same account.

This property is essential when saving/loading player data using
`Class.GlobalDataStore|GlobalDataStores`.

### `Player.userId`

- **Type:** `int64`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `Players`
- **Deprecated:** This property is a deprecated variant of `Class.Player.UserId` which
should be used instead.

## Methods

### `Player:AddReplicationFocus`

```
AddReplicationFocus(part: BasePart) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`

Adds an additional replication focus for the player.

This method adds an additional replication focus for the player in order
to trigger streaming around the location of the specified `part`. In this
manner, streaming can occur around multiple locations, not just the
location of `Class.Player.ReplicationFocus`. This has no effect in
experiences that are not streaming enabled.

Additional foci will use the same values of
`Class.Workspace.StreamingMinRadius` and
`Class.Workspace.StreamingTargetRadius` as are used by the primary focus.

This method should only be called on the server. It has no effect when
called from a `Class.LocalScript`.

**Parameters:**

- `part` : `BasePart` — The `Class.BasePart` to use as a new replication focus.

**Returns:**

- `()` — 

### `Player:ClearCharacterAppearance`

```
ClearCharacterAppearance() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`

Removes all accessories and other character appearance objects from a
player's `Class.Player.Character|Character`.

This method removes all `Class.Accessory`, `Class.Shirt`, `Class.Pants`,
`Class.CharacterMesh`, and `Class.BodyColors` from the given player's
`Class.Player.Character|Character`. In addition, it also removes the
T-Shirt `Class.Decal` on the player's torso. The character's body part
colors and face will remain unchanged. This method does nothing if the
player does not have a `Class.Player.Character|Character`.

**Returns:**

- `()` — 

### `Player:DistanceFromCharacter`

```
DistanceFromCharacter(point: Vector3) -> float
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`

Returns the distance between the character's head and the given
`Datatype.Vector3`, or `0` if the player has no character.

This method returns the distance between the character's head and the
given `Datatype.Vector3` point, or `0` if the player has no
`Class.Player.Character|Character`.

This is useful when determining the distance between a player and another
object or location in experience.

If you would like to determine the distance between two non-player
instances or positions, you can use the following:

```lua
local distance = (position1 - position2).Magnitude
```

**Parameters:**

- `point` : `Vector3` — The location from which player's distance to is being measured.

**Returns:**

- `float` — The distance in studs between the player and the location.

### `Player:GetFriendsOnline`

```
GetFriendsOnline(maxFriends: int = 200) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players`, `Social` ; **Deprecated:** This method has been superseded by
`Class.Player:GetFriendsOnlineAsync()|GetFriendsOnlineAsync()`.

Returns a dictionary of online friends. Returns the product information of
an asset using its asset ID.

**Parameters:**

- `maxFriends` : `int` (default `200`) — The maximum number of online friends to return.

**Returns:**

- `Array` — A dictionary of online friends (see the table above).

### `Player:GetFriendsOnlineAsync`

```
GetFriendsOnlineAsync(maxFriends: int = 200) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Social`

Returns a dictionary of online friends.

This function returns a dictionary array of online friends, using a 30
second cache. In the returned array, some fields are only present for
certain location types; for example, `PlaceId` won't be present when
`LocationType` is `0` (mobile website).

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><code>VisitorId</code></td>
            <td>number</td>
            <td>The <code>Class.Player.UserId|UserId</code> of the friend.</td>
        </tr>
        <tr>
            <td><code>UserName</code></td>
            <td>string</td>
            <td>The username of the friend.</td>
        </tr>
        <tr>
            <td><code>DisplayName</code></td>
            <td>string</td>
            <td>The <code>Class.Player.DisplayName|DisplayName</code> of the friend.</td>
        </tr>
        <tr>
            <td><code>LastOnline</code></td>
            <td>string</td>
            <td>When the friend was last online.</td>
        </tr>
        <tr>
            <td><code>IsOnline</code></td>
            <td>boolean</td>
            <td>If the friend is currently online.</td>
        </tr>
        <tr>
            <td><code>LastLocation</code></td>
            <td>string</td>
            <td>The name of the friend's current location.</td>
        </tr>
        <tr>
            <td><code>PlaceId</code></td>
            <td>number</td>
            <td>The place ID of the friend's last location.</td>
        </tr>
        <tr>
            <td><code>GameId</code></td>
            <td>string</td>
            <td>The <code>Class.DataModel.JobId</code> of the friend's last location.</td>
        </tr>
        <tr>
            <td><code>LocationType</code></td>
            <td>number</td>
            <td>The location type of the friend's last location.</td>
        </tr>
    </tbody>
</table>

**Parameters:**

- `maxFriends` : `int` (default `200`) — The maximum number of online friends to return.

**Returns:**

- `Array` — A dictionary of online friends (see the table above).

### `Player:GetJoinData`

```
GetJoinData() -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Players`

Returns a dictionary containing information describing how the player
joins the experience.

Returns a dictionary containing information describing how the player
joins the experience. The dictionary contains any of the following fields:

<table>
  <thead>
    <tr>
      <th>Key</th>
      <th>Value Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th><code>SourceGameId</code></th>
      <td>number</td>
      <td>The <code>Class.DataModel.GameId</code> of the experience the <code>Player</code> teleported from. Only present if the player teleports to the current experience and if a server calls the teleport function.</td>
    </tr>
    <tr>
      <th><code>SourcePlaceId</code></th>
      <td>number</td>
      <td>The <code>Class.DataModel.PlaceId</code> of the place the <code>Player</code> teleported from. Only present if the player teleports to the current place and a server calls the teleport function.</td>
    </tr>
    <tr>
      <th><code>ReferredByPlayerId</code></th>
      <td>number</td>
      <td>The <code>Class.Player.UserId|UserId</code> of the player who invited the current player to the experience. Use this data to identify the referrer and trigger reward logic.</td>
    </tr>
    <tr>
      <th><code>Members</code></th>
      <td>array</td>
      <td>An array containing the <code>Class.Player.UserId|UserId</code> numbers of the users teleported alongside the player. Only present if the player teleported as part of a group.</td>
    </tr>
    <tr>
      <th><code>TeleportData</code></th>
      <td>variant</td>
      <td>Reflects the <code>teleportData</code> specified in the original teleport. Useful for sharing information between servers the player teleports to. Only present if <code>teleportData</code> was specified and a server calls the teleport function.</td>
    </tr>
    <tr>
      <th><code>LaunchData</code></th>
      <td>string</td>
      <td>A plain or JSON encoded string that contains launch data specified in a <a href="../../../production/promotion/share-links.md">share link</a> or
      <code>Class.ExperienceInviteOptions.LaunchData</code>.</td>
    </tr>
    <tr>
      <th><code>GameJoinContext</code></th>
      <td>dictionary</td>
      <td>
        A dictionary that includes relevant information based on the context of the join. It contains the following keys:<br /><br />
        <ul>
          <li><code>JoinSource</code>: <code>Enum.JoinSource</code></li>
          <li><code>ItemType</code>: optional <code>Enum.AvatarItemType</code></li>
          <li><code>AssetId</code>: optional <code>string</code></li>
          <li><code>OutfitId</code>: optional <code>string</code></li>
          <li><code>AssetType</code>: optional <code>Enum.AssetType</code></li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

If a server initiates the player's teleport, the dictionary that this
method returns includes the player's teleport data. The
`Class.Player:GetJoinData()|GetJoinData()` method can only be used to
fetch teleport data on the server. To fetch the data on the client, use
`Class.TeleportService:GetLocalPlayerTeleportData()`.

Unlike `Class.TeleportService:GetLocalPlayerTeleportData()`,
`Class.Player:GetJoinData()|GetJoinData()` only provides teleport data
that meets the following security criteria:

- It's guaranteed to have been sent by a Roblox server in the past 48
  hours.
- It's guaranteed to have been sent with this `Class.Player`.
- The `SourcePlaceId` and `SourceGameId` are guaranteed to be the place
  and universe the data was sent from. This means you can verify the
  teleport data came from an approved place.

As this data is transmitted by the client, it can still potentially be
abused by an exploiter. Sensitive data such as player currency should be
transmitted via a secure solution like
[Memory Stores](../../../cloud-services/memory-stores/index.md).

**Returns:**

- `Dictionary` — A dictionary containing PlaceId and UserId values (see table in description).

### `Player:GetMouse`

```
GetMouse() -> Mouse
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Input`, `Players`

Returns the mouse being used by the client.

This method returns the `Class.Mouse` being used by the client. The
player's mouse instance can be used to track user mouse input including
left and right mouse button clicks and movement and location.

Note that `Class.UserInputService` provides additional methods,
properties, and events to track user input, especially for devices that do
not use a mouse.

**Returns:**

- `Mouse` — 

### `Player:GetNetworkPing`

```
GetNetworkPing() -> float
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Players`

Returns the round-trip, isolated network latency in seconds.

Returns the round-trip, isolated network latency of the player in seconds.
"Ping" is a measurement of the time taken for data to be sent from the
client to the server, then back again. It doesn't involve data
deserialization or processing.

For client-side `Class.LocalScript|LocalScripts`, this function can only
be called on the `Class.Players.LocalPlayer`. This function is useful in
identifying and debugging issues that occur in high network latency
scenarios. It's also useful for masking latency, such as adjusting the
speed of throwing animations for projectiles.

**Returns:**

- `float` — 

### `Player:GetRankInGroup`

```
GetRankInGroup(groupId: int64) -> int
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players`, `Groups`

Returns the player's rank in the group as an integer.

**Parameters:**

- `groupId` : `int64` — The `groupId` of the specified group.

**Returns:**

- `int` — The player's rank in the group.

### `Player:GetRankInGroupAsync`

```
GetRankInGroupAsync(groupId: int64) -> int
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Groups`

Returns the player's rank in the group as an integer.

This method returns the player's rank in the group as an integer between
`0` and `255`, where `0` is a non-member and `255` is the group's owner.

This call may not yield the most up-to-date information. If a player
leaves a group while they are in the experience, `GetRankInGroupAsync()`
will still think they're in that group until they leave. However, this
does not happen when used with a `Class.LocalScript` because the method
caches results, so multiple calls of `GetRankInGroupAsync()` on the same
player with the same group ID will yield the same result as when the
method was first called with the given group ID. The caching behavior is
on a per-peer basis: a server does not share the same cache as a client.

When a player joins a group in-experience due to a call to
`Class.GroupService:PromptJoinAsync()`, any cached value for that player
will be cleared on the client where the prompt was shown.

**Parameters:**

- `groupId` : `int64` — The `groupId` of the specified group.

**Returns:**

- `int` — The player's rank in the group.

### `Player:GetRoleInGroup`

```
GetRoleInGroup(groupId: int64) -> string
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players`, `Groups` ; **Deprecated:** This method has been superseded by
`Class.Player.GetRoleInGroupAsync|GetRoleInGroup()`.

Returns the player's role in the group as a string, or `Guest` if the
player isn't part of the group.

**Parameters:**

- `groupId` : `int64` — The group ID of the specified group.

**Returns:**

- `string` — The player's role in the specified group, or `Guest` if the player is not a member.

### `Player:GetRoleInGroupAsync`

```
GetRoleInGroupAsync(groupId: int64) -> string
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Groups`

Returns the player's role in the group as a string, or `Guest` if the
player isn't part of the group.

This method returns the player's role in the group as a string, or `Guest`
if the player isn't part of the group.

This call may not yield the most up-to-date information. If a player
leaves a group while they are in the experience, `GetRoleInGroupAsync()`
will still think they're in that group until they leave. However, this
does not happen when used with a `Class.LocalScript` because the method
caches results, so multiple calls of `GetRoleInGroupAsync()` on the same
player with the same group ID will yield the same result as when the
method was first called with the given group ID. The caching behavior is
on a per-peer basis: a server does not share the same cache as a client.

When a player joins a group in-experience due to a call to
`Class.GroupService:PromptJoinAsync()`, any cached value for that player
will be cleared on the client where the prompt was shown.

**Parameters:**

- `groupId` : `int64` — The group ID of the specified group.

**Returns:**

- `string` — The player's role in the specified group, or `Guest` if the player is not a member.

### `Player:HasAppearanceLoaded`

```
HasAppearanceLoaded() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`

Returns whether or not the appearance of the player's character has
loaded.

This method returns whether or not the appearance of the player's
`Class.Player.Character|Character` has loaded. Appearance includes items
such as the player's `Class.Shirt`, `Class.Pants`, and
`Class.Accessory|Accessories`.

This is useful when determining whether a player's appearance has loaded
after they first join the experience, which can be tracked using the
`Class.Players.PlayerAdded` event.

**Returns:**

- `boolean` — A boolean indicating whether or not the appearance of the player's character has loaded.

### `Player:IsBestFriendsWith`

```
IsBestFriendsWith(userId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is obsolete because the "best friends" feature was removed.
Use `Class.Player:IsFriendsWithAsync()` instead.

Returns whether a player is friends with the specified user.

This function was once used to return whether a player is best friends
with the specified user, but the feature has since been removed.

**Parameters:**

- `userId` : `int64` — 

**Returns:**

- `boolean` — 

### `Player:IsFriendsWith`

```
IsFriendsWith(userId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players`, `Social` ; **Deprecated:** This method has been superseded by the `Class.Player:IsFriendsWithAsync()`
method which should be used for new work.

Checks whether a player is a friend of the user with the given
`Class.Player.UserId`.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId` of the specified player.

**Returns:**

- `boolean` — A boolean indicating whether a player is a friend of the specified user.

### `Player:isFriendsWith`

```
isFriendsWith(userId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players` ; **Deprecated:** This method has been superseded by the `Class.Player:IsFriendsWithAsync()`
method which should be used for new work.

**Parameters:**

- `userId` : `int64` — 

**Returns:**

- `boolean` — 

### `Player:IsFriendsWithAsync`

```
IsFriendsWithAsync(userId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Social`

Checks whether a player is a friend of the user with the given
`Class.Player.UserId`.

This method sends a request to Roblox asking whether a player is a friend
of another user, given the `Class.Player.UserId|UserId` of that user. This
method caches results so multiple calls on the same player with the same
`userId` may not yield the most up-to-date result.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId` of the specified player.

**Returns:**

- `boolean` — A boolean indicating whether a player is a friend of the specified user.

### `Player:IsInGroup`

```
IsInGroup(groupId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players`, `Groups` ; **Deprecated:** This method has been superseded by
`Class.Player.IsInGroupAsync|IsInGroupAsync()`.

Checks whether a player is a member of a group with the given ID.

**Parameters:**

- `groupId` : `int64` — The group ID of the specified group.

**Returns:**

- `boolean` — A boolean indicating whether the player is in the specified group.

### `Player:IsInGroupAsync`

```
IsInGroupAsync(groupId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Groups`

Checks whether a player is a member of a group with the given ID.

This method sends a request to Roblox asking whether a player is a member
of a group, given the ID of that group.

This call may not yield the most up-to-date information. If a player
leaves a group while they are in the experience, `IsInGroupAsync()` will
still think they're in that group until they leave. However, this does not
happen when used with a `Class.LocalScript` because the method caches
results, so multiple calls of `IsInGroupAsync()` on the same player with
the same group ID will yield the same result as when the method was first
called with the given group ID. The caching behavior is on a per-peer
basis: a server does not share the same cache as a client.

When a player joins a group in-experience due to a call to
`Class.GroupService:PromptJoinAsync()`, any cached value for that player
will be cleared on the client where the prompt was shown.

**Parameters:**

- `groupId` : `int64` — The group ID of the specified group.

**Returns:**

- `boolean` — A boolean indicating whether the player is in the specified group.

### `Player:IsVerified`

```
IsVerified() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`

Returns whether the player is verified with concrete, real-world signals.

Returns a boolean value indicating that player's verification status. When
`true`, the player is verified. Verification includes, but isn't limited
to, non-VOIP phone number or government ID verification.

When implementing `IsVerified`, exercise caution to ensure that the
implementation does not inadvertently block all unverified users.

Note that the method can only be called on the backend server. Calling it
client-side results in an error. Additionally, this method will always
return `false` in Studio.

**Returns:**

- `boolean` — A boolean indicating whether the player is verified.

### `Player:Kick`

```
Kick(message: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`, `Consequences`

Forcibly disconnect a player from the experience, optionally providing a
message.

This method allows an experience to gracefully disconnect a client and
optionally provide a message to the disconnected user. This is useful for
moderating abusive users. You should only allow specific users whom you
trust to trigger this method on other users.

Calling this method on a `Class.Player` with no arguments disconnects the
user from the server and provides a default notice message. Calling this
method on a `Class.Player` along with a string as the first argument
replaces the default message with the provided string.

When using this method from a `Class.LocalScript`, only the local user's
client can be kicked.

**Parameters:**

- `message` : `string` — The message to show the user upon kicking.

**Returns:**

- `()` — 

### `Player:LoadBoolean`

```
LoadBoolean(key: string) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Returns a boolean value that was previously saved to the player with
`Class.Player:SaveBoolean()` with the same key.

This function returns a boolean value that was previously saved to the
player with `Class.Player:SaveBoolean()` with the same key. Returns false
if the key doesn't exist, not `nil`.

**Parameters:**

- `key` : `string` — 

**Returns:**

- `boolean` — 

### `Player:loadBoolean`

```
loadBoolean(key: string) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This deprecated function is a variant of `Class.Player:LoadBoolean()`
which has also been deprecated. Neither function should be used in new
work.

**Parameters:**

- `key` : `string` — 

**Returns:**

- `boolean` — 

### `Player:LoadCharacter`

```
LoadCharacter() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players` ; **Deprecated:** This method has been superseded by
`Class.Player:LoadCharacterAsync()|LoadCharacterAsync()`.

Creates a new character for the player, removing the old one. Also clears
the player's `Class.Backpack` and `Class.PlayerGui`.

**Returns:**

- `()` — 

### `Player:LoadCharacterAppearance`

```
LoadCharacterAppearance(assetInstance: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`AvatarAppearance`, `Players`

Places the given instance either in the player's character, head, or
StarterGear based on the instance's class.

The LoadCharacterAppearance `Class.Player` function places the given
instance either in the player's `Class.Player.Character`, head, or
`Class.StarterGear` based on the instance's class.

This is useful when giving a player's character an asset from the Roblox
catalog, such as a hat or piece of gear.

It is similar to `Class.Player:LoadCharacterAsync()`, except it does not
reload the entire character instance, StarterGear, or `Class.PlayerGui`.

Note:

- `Class.Accessory`, `Class.Shirt`, `Class.ShirtGraphic`,
  `Class.CharacterMesh`, `Class.BodyColors`, and `Class.Accoutrement` are
  parented to the player's character.
- `Class.Decal`, `Class.FileMesh`, `Class.SpecialMesh`, `Class.BlockMesh`,
  `Class.CylinderMesh`, and `Class.Texture` are parented to the
  character's head.
- `Class.Tool` is parented to the player's `Class.StarterGear`.
- All other classes are ignored.

**Parameters:**

- `assetInstance` : `Instance` — An instance of the asset being loaded, which can be obtained using the `Class.InsertService:LoadAsset()` function.

**Returns:**

- `()` — 

### `Player:LoadCharacterAsync`

```
LoadCharacterAsync() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`

Creates a new character for the player, removing the old one. Also clears
the player's `Class.Backpack` and `Class.PlayerGui`.

This method creates a new character for the player, removing the old one.
It also clears the player's `Class.Backpack` and `Class.PlayerGui`. This
is useful in cases where you want to reload the character without killing
the player, such as when you want to load a new character appearance after
changing the player's
`Class.Player.CharacterAppearance|CharacterAppearance`.

After calling `LoadCharacterAsync()` for an individual player, it is not
recommended to call it again for the same player until after that player's
`Class.Player.CharacterAppearanceLoaded|CharacterAppearanceLoaded` event
has fired.

#### Character Loading Event Order

Calling the `LoadCharacterAsync()` method on any `Player` fires events in
the following order:

1. `Class.Player.Character` sets, automatically removing old character.
2. `Class.Player.CharacterAdded` fires.
3. `Class.Object.Changed` fires on the `Class.Player` with a value of
   `Character`.
4. The character appearance initializes.
5. `Class.Player.CharacterAppearanceLoaded` fires.
6. The character's `Class.Instance.Parent|Parent` sets to the
   `Class.DataModel`.
7. The character rig builds and scales.
8. The character moves to the spawn location.

**Returns:**

- `()` — 

### `Player:LoadCharacterWithHumanoidDescription`

```
LoadCharacterWithHumanoidDescription(humanoidDescription: HumanoidDescription, assetTypeVerification: AssetTypeVerification = Default) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players` ; **Deprecated:** This method has been superseded by
`Class.Player:LoadCharacterWithHumanoidDescriptionAsync()|LoadCharacterWithHumanoidDescriptionAsync()`.

Spawns a player character with everything equipped in the passed in
`Class.HumanoidDescription`.

**Parameters:**

- `humanoidDescription` : `HumanoidDescription` — A `Class.HumanoidDescription` containing traits like body parts/colors, body scaling, accessories, clothing, and animations that will be equipped to the loaded character.
- `assetTypeVerification` : `AssetTypeVerification` (default `Default`) — The asset type verification mode.

**Returns:**

- `()` — 

### `Player:LoadCharacterWithHumanoidDescriptionAsync`

```
LoadCharacterWithHumanoidDescriptionAsync(humanoidDescription: HumanoidDescription, assetTypeVerification: AssetTypeVerification = Default) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`

Spawns a player character with everything equipped in the passed in
`Class.HumanoidDescription`.

This method spawns a player character with everything equipped in the
passed in `Class.HumanoidDescription`.

After calling this method for an individual player, it is not recommended
to call it again for the same player until after that player's
`Class.Player.CharacterAppearanceLoaded|CharacterAppearanceLoaded` event
has fired.

See also
[HumanoidDescription System](../../../characters/appearance.md#humanoiddescription),
an article which explains the humanoid description system in greater
detail and provides several scripting examples.

**Parameters:**

- `humanoidDescription` : `HumanoidDescription` — A `Class.HumanoidDescription` containing traits like body parts/colors, body scaling, accessories, clothing, and animations that will be equipped to the loaded character.
- `assetTypeVerification` : `AssetTypeVerification` (default `Default`) — The asset type verification mode.

**Returns:**

- `()` — 

### `Player:LoadInstance`

```
LoadInstance(key: string) -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Returns an instance that was previously saved to the player with
`Class.Player:SaveInstance()` with the same key.

This function returns an instance that was previously saved to the player
with `Class.Player:SaveInstance()` with the same key. Returns `nil` if the
key doesn't exist.

**Parameters:**

- `key` : `string` — 

**Returns:**

- `Instance` — 

### `Player:loadInstance`

```
loadInstance(key: string) -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This deprecated function is a variant of `Class.Player:LoadInstance()`
which has also been deprecated. Neither function should be used in new
work.

**Parameters:**

- `key` : `string` — 

**Returns:**

- `Instance` — 

### `Player:LoadNumber`

```
LoadNumber(key: string) -> double
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Returns a number value that was previously saved to the player.

This function was once used by an ancient data persistence method to
return a number value that was previously saved to the player with
`Class.Player:SaveNumber()` with the same key. Returns 0 if the key
doesn't exist, not `nil`.

**Parameters:**

- `key` : `string` — 

**Returns:**

- `double` — 

### `Player:loadNumber`

```
loadNumber(key: string) -> double
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This deprecated function is a variant of `Class.Player:LoadNumber()` which
has also been deprecated. Neither function should be used in new work.

**Parameters:**

- `key` : `string` — 

**Returns:**

- `double` — 

### `Player:LoadString`

```
LoadString(key: string) -> string
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Returns a string value that was previously saved to the player.

This function returns a string value that was previously saved to the
player with `Class.Player:SaveString()` with the same key. Returns an
empty string ("") if the key doesn't exist, not `nil`.

**Parameters:**

- `key` : `string` — 

**Returns:**

- `string` — 

### `Player:loadString`

```
loadString(key: string) -> string
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is a deprecated variant of `Class.Player:LoadString()` which
has also been deprecated. Neither function should be used in new work.

**Parameters:**

- `key` : `string` — 

**Returns:**

- `string` — 

### `Player:Move`

```
Move(walkDirection: Vector3, relativeToCamera: boolean = False) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`

Causes the player's character to walk in the given direction until
stopped, or interrupted by the player (by using their controls).

This method causes the player's character to walk in the given direction
until stopped, or interrupted by the player (by using their controls).

This is useful when scripting NPC `Class.Humanoid|Humanoids` that move
around a map but are not controlled by an actual player's input.

Note that the function's second argument indicates whether the provided
`Datatype.Vector3` should move the player relative to world coordinates
(`false`) or the player's `Class.Camera` (`true`).

**Parameters:**

- `walkDirection` : `Vector3` — The Vector3 direction that the player should move.
- `relativeToCamera` : `boolean` (default `False`) — A boolean indicating whether the player should move relative to the player's camera.

**Returns:**

- `()` — 

### `Player:RemoveReplicationFocus`

```
RemoveReplicationFocus(part: BasePart) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`

Removes a previously added replication focus.

This method removes a replication focus previously added by
`Class.Player:AddReplicationFocus()|AddReplicationFocus()`. Has no effect
in experiences that are not streaming enabled.

This method should only be called on the server. It has no effect when
called from a `Class.LocalScript`.

**Parameters:**

- `part` : `BasePart` — The `Class.BasePart` to remove as a replication focus.

**Returns:**

- `()` — 

### `Player:RequestStreamAroundAsync`

```
RequestStreamAroundAsync(position: Vector3, timeOut: double = 0) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`

Requests that the server stream to the player around the specified
location.

For experiences where
[instance streaming](../../../workspace/streaming/index.md) is enabled,
requests that the server stream to the player regions (parts and terrain)
around the specified **X**, **Y**, **Z** location in the 3D world. It is
useful if the experience knows that the player's `Datatype.CFrame` will be
set to the specified location in the near future. Without providing the
location with this call, the player may not have streamed in content for
the destination, resulting in a streaming pause or other undesirable
behavior.

The effect of this call will be temporary and there are no guarantees of
what will be streamed in around the specified location. Client memory
limits and network conditions may impact what will be available on the
client.

#### Usage Precaution

Requesting streaming around an area is **not a guarantee** that the
content will be present when the request completes, as streaming is
affected by the client's network bandwidth, memory limitations, and other
factors.

**Parameters:**

- `position` : `Vector3` — World location where streaming is requested.
- `timeOut` : `double` (default `0`) — Optional timeout for the request, the maximum duration that the engine attempts to stream regions around the `position` parameter before abandoning the request. If you don't specify a value, the timeout is effectively infinite. However, if the client is low on memory, the engine abandons all streaming requests, even those that are still within the timeout duration.

**Returns:**

- `()` — 

### `Player:SaveBoolean`

```
SaveBoolean(key: string, value: boolean) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Used to save a boolean value that can be loaded again at a later time
using `Class.Player:LoadBoolean()`.

This function is used to save a boolean value that can be loaded again at
a later time using `Class.Player:LoadBoolean()`.

**Parameters:**

- `key` : `string` — 
- `value` : `boolean` — 

**Returns:**

- `()` — 

### `Player:saveBoolean`

```
saveBoolean(key: string, value: boolean) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is a deprecated variant of `Class.Player:SaveBoolean()`
which has also been deprecated. Neither function should be used in new
work.

**Parameters:**

- `key` : `string` — 
- `value` : `boolean` — 

**Returns:**

- `()` — 

### `Player:SaveInstance`

```
SaveInstance(key: string, value: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Saves an instance which can be loaded again at a later time.

This function was once used by an ancient data persistence method to save
an instance which can be loaded again at a later time using
`Class.Player:LoadInstance()`..

**Parameters:**

- `key` : `string` — 
- `value` : `Instance` — 

**Returns:**

- `()` — 

### `Player:saveInstance`

```
saveInstance(key: string, value: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is a deprecated variant of `Class.Player:SaveInstance()`
which has also been deprecated. Neither function should be used in new
work.

**Parameters:**

- `key` : `string` — 
- `value` : `Instance` — 

**Returns:**

- `()` — 

### `Player:SaveNumber`

```
SaveNumber(key: string, value: double) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Saves a number value that can be loaded again at a later time using.

This function was once used by an ancient data persistence method to save
a number value that can be loaded again at a later time using
`Class.Player:LoadNumber()`.

**Parameters:**

- `key` : `string` — 
- `value` : `double` — 

**Returns:**

- `()` — 

### `Player:saveNumber`

```
saveNumber(key: string, value: double) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is a deprecated variant of `Class.Player:SaveNumber()` which
has also been deprecated. Neither function should be used in new work.

**Parameters:**

- `key` : `string` — 
- `value` : `double` — 

**Returns:**

- `()` — 

### `Player:SaveString`

```
SaveString(key: string, value: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Saves a string value that can be loaded again at a later time.

This function was once used by an ancient data persistence method to save
a string value that can be loaded again at a later time using
`Class.Player:LoadString()`.

**Parameters:**

- `key` : `string` — 
- `value` : `string` — 

**Returns:**

- `()` — 

### `Player:saveString`

```
saveString(key: string, value: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is a deprecated variant of `Class.Player:SaveString()` which
has also been deprecated. Neither function should be used in new work.

**Parameters:**

- `key` : `string` — 
- `value` : `string` — 

**Returns:**

- `()` — 

### `Player:SetAccountAge`

```
SetAccountAge(accountAge: int) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; capabilities=`Players`

Sets the `Class.Player.AccountAge|AccountAge` of the player.

This method sets the `Class.Player.AccountAge|AccountAge` of the player in
days, meaning the age of the account itself relative to when it was first
created.

**Parameters:**

- `accountAge` : `int` — The age of the account in days.

**Returns:**

- `()` — 

### `Player:SetSuperSafeChat`

```
SetSuperSafeChat(value: boolean) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; capabilities=`Players`

Sets whether or not the player sees filtered chats, rather than normal
chats.

This method sets whether or not the player sees chat filtered by
`Class.TextService:FilterStringAsync()` rather than normal chats.

```lua
local Players = game:GetService("Players")

local player = Players.LocalPlayer
player:SetSuperSafeChat(true)
```

Regardless of whether a player has filtered chat enabled, all chat should
be filtered by `Class.TextService` when broadcast to other players or on
the player's own screen. `Class.TextService:FilterStringAsync()` returns a
`Class.TextFilterResult` object that can be filtered differently according
to the message's intended use.

**Parameters:**

- `value` : `boolean` — A boolean indicating whether or not the player sees filtered chat.

**Returns:**

- `()` — 

### `Player:WaitForDataReady`

```
WaitForDataReady() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players` ; **Deprecated:** This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.

Used to pause the script until the player's data is available to
manipulate, or until a certain amount of time has elapsed without fetching
the player's data.

This function is used to pause the script until the player's data is
available to manipulate, or until a certain amount of time has elapsed
without fetching the player's data

**Returns:**

- `boolean` — 

### `Player:waitForDataReady`

```
waitForDataReady() -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is a deprecated variant of `Class.Player:WaitForDataReady()`
which has also been deprecated. Neither function should be used in new
work.

**Returns:**

- `boolean` — 

## Events

### `Player.CharacterAdded`

```
CharacterAdded(character: Model)
```

- security=`None` ; capabilities=`Players`

Fires when a player's character spawns or respawns.

This event fires when a player's character spawns or respawns. It fires
soon after setting `Class.Player.Character|Character` to a non-`nil` value
or calling `Class.Player:LoadCharacterAsync()|LoadCharacterAsync()`, which
is before the character is parented to the `Class.Workspace`.

This can be used alongside the
`Class.Player.CharacterRemoving|CharacterRemoving` event which fires right
before a player's character is about to be removed, typically after death.
As such, both of these events can potentially fire many times as players
die then respawn in a place.

Note that the `Class.Humanoid` and its default body parts (head, torso,
and limbs) will exist on the server when this event fires, but clothing
items like `Class.Hat|Hats`, `Class.Shirt|Shirts`, and `Class.Pants` might
take a few seconds to be added to the character. The parts will also take
time to replicate to clients. Connect `Class.Instance.ChildAdded` on the
added character to detect these, or wait for the
`Class.Player.CharacterAppearanceLoaded|CharacterAppearanceLoaded` event
to be sure the character has everything equipped.

If you instead need to track when a player joins/leaves the experience,
use the events `Class.Players.PlayerAdded` and
`Class.Players.PlayerRemoving`.

**Parameters:**

- `character` : `Model` — An instance of the character that spawned/respawned.

### `Player.CharacterAppearanceLoaded`

```
CharacterAppearanceLoaded(character: Model)
```

- security=`None` ; capabilities=`Players`

Fires when the full appearance of a `Class.Player.Character|Character` has
been inserted.

This event fires when the full appearance of a
`Class.Player.Character|Character` has been inserted. It only fires on the
server.

A `Class.Player.Character|Character` generally has a range of objects
modifying its appearance, including `Class.Accoutrement|Accoutrements`,
`Class.Shirt|Shirts`, `Class.Pants` and
`Class.CharacterMesh|CharacterMeshes`. This event will fire when all such
objects have been inserted into the character.

For custom character implementations, such as using a character model
named `StarterCharacter` inside `Class.StarterPlayer`, use
`Class.Player.CharacterAdded|CharacterAdded` and handle your own
accessories.

One use for this event is to ensure all accessories have loaded before
destroying them. See below for an example of this.

**Parameters:**

- `character` : `Model` — The `Class.Player.Character` `Class.Model`.

### `Player.CharacterRemoving`

```
CharacterRemoving(character: Model)
```

- security=`None` ; capabilities=`Players`

Fires right before a player's character is removed.

This event fires right before a player's
`Class.Player.Character|Character` is removed, such as when the player is
respawning. This can be used alongside the
`Class.Player.CharacterAdded|CharacterAdded` event which fires when a
player's character spawns or respawns.

If you instead need to track when a player joins/leaves the experience,
use the events `Class.Players.PlayerAdded` and
`Class.Players.PlayerRemoving`.

**Parameters:**

- `character` : `Model` — An instance of the character that is being removed.

### `Player.Chatted`

```
Chatted(message: string, recipient: Player)
```

- security=`None` ; capabilities=`Chat`, `Players`

Fires when a player chats in experience using Roblox's provided chat bar.

This event fires when a `Class.Player` types a message and presses
<kbd>Enter</kbd> in Roblox's provided chat bar. This is done using some
Luau bindings by the default chat script. You can prevent players from
chatting by using `Class.StarterGui:SetCoreGuiEnabled()` and setting
`Enum.CoreGuiType.Chat` to `false`.

**Parameters:**

- `message` : `string` — The content of the message the player typed in chat.
- `recipient` : `Player` — **Deprecated.** For whisper messages, this was the Player who was the intended target of the chat message.

### `Player.Idled`

```
Idled(time: double)
```

- security=`None` ; capabilities=`Players`

This event fires approximately two minutes after the engine classifies the
player as idle. Time is the number of seconds that have elapsed since that
point.

This event fires approximately two minutes after the engine classifies the
player as idle. Time is the number of seconds that have elapsed since that
point. The event continues to fire every 30 seconds for as long as the
player remains idle.

This event only fires in client scripts, not server scripts; use a
`Class.RemoteEvent` to notify the server of idle players.

Roblox automatically disconnects players that have been idle for at least
20 minutes, so this event is useful for warning players that they will be
disconnected soon, disconnecting players prior to those 20 minutes, or
other away from keyboard (AFK) features.

To track how often automatic disconnects occur, try correlating this event
with occurrences of `Class.Players.PlayerRemoving`.

**Parameters:**

- `time` : `double` — The time in seconds the player has been idle.

### `Player.OnTeleport`

```
OnTeleport(teleportState: TeleportState, placeId: int64, spawnName: string)
```

- security=`None` ; capabilities=`Players`, `Teleport`

Fires when the teleport state of a player changes.

This event fires when the `Enum.TeleportState` of a player changes. This
event is useful for detecting whether a teleportation was successful.

**Parameters:**

- `teleportState` : `TeleportState` — The new `Enum.TeleportState` of the `Class.Player`.
- `placeId` : `int64` — The ID of the place the `Class.Player` is being teleported to.
- `spawnName` : `string` — The name of the spawn to teleport to, if `Class.TeleportService:TeleportToSpawnByName()` has been used.

## Notes / Deprecations

- Deprecated property `Player.CharacterAppearance`: This item is deprecated. Do not use it for new work.
- Deprecated property `Player.DataComplexity`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated property `Player.DataReady`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated property `Player.MembershipType`: This property is deprecated. Use `Class.Player.HasRobloxSubscription` to
check whether a player has an active Roblox subscription.
- Deprecated property `Player.userId`: This property is a deprecated variant of `Class.Player.UserId` which
should be used instead.
- Deprecated method `Player:GetFriendsOnline`: This method has been superseded by
`Class.Player:GetFriendsOnlineAsync()|GetFriendsOnlineAsync()`.
- Deprecated method `Player:GetRoleInGroup`: This method has been superseded by
`Class.Player.GetRoleInGroupAsync|GetRoleInGroup()`.
- Deprecated method `Player:IsBestFriendsWith`: This function is obsolete because the "best friends" feature was removed.
Use `Class.Player:IsFriendsWithAsync()` instead.
- Deprecated method `Player:IsFriendsWith`: This method has been superseded by the `Class.Player:IsFriendsWithAsync()`
method which should be used for new work.
- Deprecated method `Player:isFriendsWith`: This method has been superseded by the `Class.Player:IsFriendsWithAsync()`
method which should be used for new work.
- Deprecated method `Player:IsInGroup`: This method has been superseded by
`Class.Player.IsInGroupAsync|IsInGroupAsync()`.
- Deprecated method `Player:LoadBoolean`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:loadBoolean`: This deprecated function is a variant of `Class.Player:LoadBoolean()`
which has also been deprecated. Neither function should be used in new
work.
- Deprecated method `Player:LoadCharacter`: This method has been superseded by
`Class.Player:LoadCharacterAsync()|LoadCharacterAsync()`.
- Deprecated method `Player:LoadCharacterWithHumanoidDescription`: This method has been superseded by
`Class.Player:LoadCharacterWithHumanoidDescriptionAsync()|LoadCharacterWithHumanoidDescriptionAsync()`.
- Deprecated method `Player:LoadInstance`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:loadInstance`: This deprecated function is a variant of `Class.Player:LoadInstance()`
which has also been deprecated. Neither function should be used in new
work.
- Deprecated method `Player:LoadNumber`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:loadNumber`: This deprecated function is a variant of `Class.Player:LoadNumber()` which
has also been deprecated. Neither function should be used in new work.
- Deprecated method `Player:LoadString`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:loadString`: This function is a deprecated variant of `Class.Player:LoadString()` which
has also been deprecated. Neither function should be used in new work.
- Deprecated method `Player:SaveBoolean`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:saveBoolean`: This function is a deprecated variant of `Class.Player:SaveBoolean()`
which has also been deprecated. Neither function should be used in new
work.
- Deprecated method `Player:SaveInstance`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:saveInstance`: This function is a deprecated variant of `Class.Player:SaveInstance()`
which has also been deprecated. Neither function should be used in new
work.
- Deprecated method `Player:SaveNumber`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:saveNumber`: This function is a deprecated variant of `Class.Player:SaveNumber()` which
has also been deprecated. Neither function should be used in new work.
- Deprecated method `Player:SaveString`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:saveString`: This function is a deprecated variant of `Class.Player:SaveString()` which
has also been deprecated. Neither function should be used in new work.
- Deprecated method `Player:WaitForDataReady`: This item is deprecated, as it may have been used for a now obsolete data
persistence method. Please save and load player data using
`Class.DataStoreService` for new work.
- Deprecated method `Player:waitForDataReady`: This function is a deprecated variant of `Class.Player:WaitForDataReady()`
which has also been deprecated. Neither function should be used in new
work.
- Method `Player:SetAccountAge` security: `PluginSecurity`
- Method `Player:SetSuperSafeChat` security: `PluginSecurity`
- Property `Player.AccountAge` security: `read=None, write=None`
- Property `Player.AutoJumpEnabled` security: `read=None, write=None`
- Property `Player.CameraMaxZoomDistance` security: `read=None, write=None`
- Property `Player.CameraMinZoomDistance` security: `read=None, write=None`
- Property `Player.CameraMode` security: `read=None, write=None`
- Property `Player.CanLoadCharacterAppearance` security: `read=None, write=None`
- Property `Player.Character` security: `read=None, write=None`
- Property `Player.CharacterAppearance` security: `read=None, write=None`
- Property `Player.CharacterAppearanceId` security: `read=None, write=None`
- Property `Player.DataComplexity` security: `read=None, write=None`
- Property `Player.DataReady` security: `read=None, write=None`
- Property `Player.DevCameraOcclusionMode` security: `read=None, write=None`
- Property `Player.DevComputerCameraMode` security: `read=None, write=None`
- Property `Player.DevComputerMovementMode` security: `read=None, write=None`
- Property `Player.DevEnableMouseLock` security: `read=None, write=None`
- Property `Player.DevTouchCameraMode` security: `read=None, write=None`
- Property `Player.DevTouchMovementMode` security: `read=None, write=None`
- Property `Player.DisplayName` security: `read=None, write=None`
- Property `Player.FollowUserId` security: `read=None, write=None`
- Property `Player.GameplayPaused` security: `read=None, write=NotAccessibleSecurity`
- Property `Player.HasRobloxSubscription` security: `read=None, write=RobloxEngineSecurity`
- Property `Player.HasVerifiedBadge` security: `read=None, write=None`
- Property `Player.HealthDisplayDistance` security: `read=None, write=None`
- Property `Player.InputLatency` security: `read=RobloxEngineSecurity, write=RobloxEngineSecurity`
- Property `Player.LocaleId` security: `read=None, write=None`
- Property `Player.MembershipType` security: `read=None, write=None`
- Property `Player.NameDisplayDistance` security: `read=None, write=None`
- Property `Player.Neutral` security: `read=None, write=None`
- Property `Player.PartyId` security: `read=None, write=RobloxEngineSecurity`
- Property `Player.ReplicationFocus` security: `read=None, write=None`
- Property `Player.RespawnLocation` security: `read=None, write=None`
- Property `Player.StepIdOffset` security: `read=RobloxEngineSecurity, write=RobloxEngineSecurity`
- Property `Player.Team` security: `read=None, write=None`
- Property `Player.TeamColor` security: `read=None, write=None`
- Property `Player.ThirdPartyTextChatRestrictionStatus` security: `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- Property `Player.UserId` security: `read=None, write=None`
- Property `Player.userId` security: `read=None, write=None`
- Method `Player:GetFriendsOnline` yields (tag `Yields`).
- Method `Player:GetFriendsOnlineAsync` yields (tag `Yields`).
- Method `Player:GetRankInGroup` yields (tag `Yields`).
- Method `Player:GetRankInGroupAsync` yields (tag `Yields`).
- Method `Player:GetRoleInGroup` yields (tag `Yields`).
- Method `Player:GetRoleInGroupAsync` yields (tag `Yields`).
- Method `Player:IsBestFriendsWith` yields (tag `Yields`).
- Method `Player:IsFriendsWith` yields (tag `Yields`).
- Method `Player:isFriendsWith` yields (tag `Yields`).
- Method `Player:IsFriendsWithAsync` yields (tag `Yields`).
- Method `Player:IsInGroup` yields (tag `Yields`).
- Method `Player:IsInGroupAsync` yields (tag `Yields`).
- Method `Player:LoadCharacter` yields (tag `Yields`).
- Method `Player:LoadCharacterAsync` yields (tag `Yields`).
- Method `Player:LoadCharacterWithHumanoidDescription` yields (tag `Yields`).
- Method `Player:LoadCharacterWithHumanoidDescriptionAsync` yields (tag `Yields`).
- Method `Player:RequestStreamAroundAsync` yields (tag `Yields`).
- Method `Player:WaitForDataReady` yields (tag `Yields`).
- Method `Player:waitForDataReady` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- Player:ClearCharacterAppearance: Player-ClearCharacterAppearance1
- Player:DistanceFromCharacter: Player-DistanceFromCharacter1
- Player:GetFriendsOnline: how-to-get-a-list-of-online-friends
- Player:GetFriendsOnlineAsync: how-to-get-a-list-of-online-friends
- Player:GetJoinData: Player-GetJoinData-Tracking-Traffic-Sources
- Player:GetJoinData: Player-GetJoinData-Referral-Url-Generator
- Player:GetJoinData: Player-GetJoinData-Table-as-Launch-Data
- Player:GetJoinData: Player-GetJoinData-Decoding-Json-Launch-Data
- Player:GetJoinData: server-teleportdata-example
- Player:GetRankInGroup: Player-GetRankInGroup1
- Player:GetRankInGroupAsync: Player-GetRankInGroup1
- Player:GetRoleInGroup: Player-GetRoleInGroup1
- Player:GetRoleInGroupAsync: Player-GetRoleInGroup1
- Player:HasAppearanceLoaded: check-if-a-player-s-appearance-has-loaded
- Player:IsVerified: Player-IsVerified
- Player:LoadCharacter: Player-LoadCharacter1
- Player:LoadCharacterAppearance: Player-LoadCharacterAppearance1
- Player:LoadCharacterAsync: Player-LoadCharacter1
- Player:LoadCharacterWithHumanoidDescription: spawn-characters-with-humanoiddescription
- Player:LoadCharacterWithHumanoidDescriptionAsync: spawn-characters-with-humanoiddescription
- Player:LoadInstance: Player-LoadInstance1
- Player:LoadNumber: Player-LoadNumber1
- Player:LoadString: Player-LoadString1
- Player:Move: Player-Move1
- Player:SaveBoolean: Player-SaveBoolean1
- Player:SaveInstance: Player-SaveInstance1
- Player:SaveNumber: Player-SaveNumber1
- Player:SaveString: Player-SaveString1
- Player.AutoJumpEnabled: Auto-Jump-Toggle
- Player.CameraMode: playing-in-first-person
- Player.FollowUserId: Followed-Alert
- Player.HasRobloxSubscription: check-roblox-subscription
- Player.MembershipType: check-membership-status
- Player.PartyId: Player-PartyId
- Player.RespawnLocation: change-spawn-on-touch
- Player.UserId: Player-UserId1
- Player.UserId: GlobalDataStore-GetAsync1
- Player.CharacterAdded: spawns-and-despawns
- Player.CharacterAdded: accessory-remover
- Player.CharacterAppearanceLoaded: remove-accessories-after-loading
- Player.CharacterRemoving: spawns-and-despawns
- Player.OnTeleport: Player-OnTeleport1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Player
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Player.yaml
- Captured: 2026-04-16
