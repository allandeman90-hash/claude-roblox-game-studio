---
title: StarterPlayer
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/StarterPlayer
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/StarterPlayer.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: players
tags: [roblox-class, starter, players]
---

# StarterPlayer

A service which allows the defaults of properties in the `Class.Player` object
to be set.

## Description

A service which allows the defaults of properties in the `Class.Player` object
to be set. When a player enters the server, each property of the player object
is set to the current value of the corresponding property in
`Class.StarterPlayer`.

Additionally, you may add four objects to this service:

- A `Class.StarterPlayerScripts` instance with scripts that run once for each
  player.
- A `Class.StarterCharacterScripts` instance with scripts to add to each
  player's character every time they spawn.
- A `Class.Humanoid` instance named `StarterHumanoid` which will be used as
  the default humanoid for each player's character.
- A `Class.Model` instance named `StarterCharacter` which will be used as the
  character model for all players.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

### `StarterPlayer.AllowCustomAnimations`

- **Type:** `boolean`
- **Security:** `read=None, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`
- **Capabilities:** `Players`

Describes the current game's permission levels regarding custom avatar
animations from the website.

This property describes the current game's permission levels regarding
custom avatar `Class.Animation|Animations` from the website.

As such, this value cannot be changed from within the game. It can only be
changed by changing the game's permission levels within the game's
setting's page on the website.

This property is not intended for use in the game.

### `StarterPlayer.AutoJumpEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Sets whether the character will automatically jump when hitting an
obstacle on a mobile device.

This property sets whether the character will automatically jump when
hitting an obstacle on a mobile device.

This property is copied from the `Class.StarterPlayer` to a `Class.Player`
when they join the game. Following that. the value of this property is
copied to `Class.Humanoid.AutoJumpEnabled` property of the character's
`Class.Humanoid` on spawn. In other words, it is possible to set the
auto-jump behavior on a per-character, per-player and per-game basis using
these three properties.

### `StarterPlayer.AvatarJointUpgrade`

- **Type:** `RolloutState`
- **Security:** `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Players`

Controls whether avatars spawn with `Class.AnimationConstraint` joints for
physical simulation.

This property controls the rollout state of new
`Class.AnimationConstraint` joints in avatars. When disabled, avatars
spawn with legacy `Class.Motor6D|Motor6Ds` connecting their limbs. When
enabled, avatars spawn with
`Class.AnimationConstraint|AnimationConstraints` and
`Class.BallSocketConstraint|BallSocketConstraints` connecting their limbs.
This makes it easier to write scripts that enable physical simulation,
like arm strength and ragdoll falling down.

### `StarterPlayer.CameraMaxZoomDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

The maximum distance the player's default camera is allowed to zoom out in
studs.

This property sets the maximum distance in studs the camera can be from
the character with the default cameras.

This property sets the default value of
`Class.Player.CameraMaxZoomDistance` for each player who joins the game.
If this value is set to a lower value than
`Class.StarterPlayer.CameraMinZoomDistance` it will be increased to
CameraMinZoomDistance.

### `StarterPlayer.CameraMinZoomDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

The minimum distance in studs the player's default camera is allowed to
zoom in.

This property sets the minimum distance in studs the camera can be from
the character with the default cameras.

This property sets the default value of
`Class.Player.CameraMinZoomDistance` for each player who joins the game.
If this value is set to a higher value than
`Class.StarterPlayer.CameraMaxZoomDistance` it will be decreased to
CameraMaxZoomDistance.

### `StarterPlayer.CameraMode`

- **Type:** `CameraMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Changes the default camera's mode to either first or third person.

Sets the default value for `Class.Player.CameraMode` for each player in
the game. The camera has two modes:

#### First Person

In first person mode, the player's camera is zoomed all the way in. Unless
there is a visible GUI present with the `Class.GuiButton.Modal` property
set to `true`, the mouse will be locked and the user's camera will turn as
the mouse moves.

#### Third Person

In third person mode (default), the character can be seen in the camera.
While in third person mode on Roblox:

- You may right-click and drag to rotate your camera, or use the arrow
  keys at the bottom right-hand corner of the screen.
- When you move your mouse, your camera does not change (unless you move
  the mouse to the end of the screen).
- When you press any of the arrow keys, the user's character will face in
  the corresponding arrow key's direction.
- You can zoom in and out freely.

### `StarterPlayer.CharacterBreakJointsOnDeath`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines the starting value of `Class.Humanoid.BreakJointsOnDeath` for
`Class.Player.Character`.

This property determines the starting value of
`Class.Humanoid.BreakJointsOnDeath` for a player's
`Class.Player.Character`.

Note that `Class.StarterPlayer.AvatarJointUpgrade|AvatarJointUpgrade` must
be enabled for this property to take effect.

### `StarterPlayer.CharacterJumpHeight`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines the starting value of `Class.Humanoid.JumpHeight` for
`Class.Player.Character`.

This property determines the starting value of `Class.Humanoid.JumpHeight`
for a player's `Class.Player.Character` in studs, with a default of `7.2`.

This property is only visible in the **Properties** window If
`Class.StarterPlayer.CharacterUseJumpPower|CharacterUseJumpPower` is set
to `false`, as it would not be relevant otherwise.

Since this property is only relevant for characters being spawned in the
future, changing it will not change any existing player characters.
Changes to this property will only take effect when a player respawns.

### `StarterPlayer.CharacterJumpPower`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines the starting value of `Class.Humanoid.JumpPower` for
`Class.Player.Character`.

This property determines the starting value of `Class.Humanoid.JumpPower`
for a player's `Class.Player.Character`, with a default of `50`, minimum
of `0`, and maximum of `1000`.

This property is only visible in the **Properties** window If
`Class.StarterPlayer.CharacterUseJumpPower|CharacterUseJumpPower` is set
to `true`, as it would not be relevant otherwise.

Since this property is only relevant for characters being spawned in the
future, changing it will not change any existing player characters.
Changes to this property will only take effect when a player respawns.

### `StarterPlayer.CharacterMaxSlopeAngle`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines the starting value of `Class.Humanoid.MaxSlopeAngle` for
`Class.Player.Character`.

This property determines the starting value of
`Class.Humanoid.MaxSlopeAngle` for a player's `Class.Player.Character` in
degrees. It defaults to `89`, so humanoids can climb pretty much any slope
they want by default.

Since this property is only relevant for characters being spawned in the
future, changing it will not change any existing player characters.
Changes to this property will only take effect when a player respawns.

### `StarterPlayer.CharacterUseJumpPower`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines the starting state of `Class.Humanoid.UseJumpPower` for
`Class.Player.Character`.

This property determines the starting value of
`Class.Humanoid.UseJumpPower` for a player's `Class.Player.Character`.
Toggling it will change which property is visible in the **Properties**
window (`Class.StarterPlayer.CharacterJumpHeight|CharacterJumpHeight` if
`false` or `Class.StarterPlayer.CharacterJumpPower|CharacterJumpPower` if
`true`). Defaults to `true`.

Since this property is only relevant for characters being spawned in the
future, changing it will not change any existing player characters.
Changes to this property will only take effect when a player respawns.

### `StarterPlayer.CharacterWalkSpeed`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines the starting value of `Class.Humanoid.WalkSpeed` for
`Class.Player.Character`.

This property determines the starting value of `Class.Humanoid.WalkSpeed`
for a player's `Class.Player.Character` with a default of `16`.

Since this property is only relevant for characters being spawned in the
future, changing it will not change any existing player characters.
Changes to this property will only take effect when a player respawns.

### `StarterPlayer.ClassicDeath`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

### `StarterPlayer.CreateDefaultPlayerModule`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Players`

Controls how the default player module and related scripts are handled.

This property is only visible when
`Class.Workspace.PlayerScriptsUseInputActionSystem` is enabled. When set
to `true` (default), the `PlayerModule` injection point occurs at
`Class.StarterPlayer`. When set to `false`, the default camera and control
scripts will not be added to the place.

### `StarterPlayer.DevCameraOcclusionMode`

- **Type:** `DevCameraOcclusionMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Sets how the default camera handles objects between the camera and the
player.

Defines how the default camera scripts handle objects between the camera
and the camera subject. Applies to all players as they join the experience
and can't be changed for individual players.

The default value is `Enum.DevCameraOcclusionMode|Zoom` (0). See
`Enum.DevCameraOcclusionMode` for a list of available modes.

### `StarterPlayer.DevComputerCameraMovementMode`

- **Type:** `DevComputerCameraMovementMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Lets you overwrite the player's camera mode on a computer.

This property lets you overwrite the player's camera mode on a computer.

If set to `Enum.DevComputerCameraMovementMode|UserChoice`, the player's
camera movement mode will be determined by whatever they set in the
experience's settings. Otherwise, the mode will be set based on this
property.

This property does not affect players who are not on a computer.

### `StarterPlayer.DevComputerMovementMode`

- **Type:** `DevComputerMovementMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Lets you overwrite the player's movement mode on a computer.

This property lets you overwrite the player's movement mode on a computer.

If set to `Enum.DevComputerMovementMode|UserChoice`, the player's movement
mode will be determined by whatever they set in the experience's settings.
Otherwise, the mode will be set based on this property.

This property does not affect players who are not on a computer.

### `StarterPlayer.DevTouchCameraMovementMode`

- **Type:** `DevTouchCameraMovementMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Lets you overwrite the player's camera mode on a touch-enabled device.

This property lets you overwrite the player's camera mode on a
touch-enabled device.

If set to `Enum.DevTouchCameraMovementMode|UserChoice`, the player's
camera movement mode will be determined by whatever they set in the
experience's settings. Otherwise, the mode will be set based on this
property.

This property does not affect players who are not on a touch-enabled
device.

### `StarterPlayer.DevTouchMovementMode`

- **Type:** `DevTouchMovementMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Lets you overwrite the player's movement mode on a touch-enabled device.

Lets you overwrite the player's movement mode on a touch-enabled device.

If set to `Enum.DevTouchMovementMode|UserChoice`, the player's movement
mode will be determined by whatever they set in the experience's settings.
Otherwise, the mode will be set based on this property.

This property does not affect players who are not on a touch-enabled
device.

### `StarterPlayer.EnableDynamicHeads`

- **Type:** `LoadDynamicHeads`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Players`

Sets the use of dynamic heads. When true, enables the use of avatar heads
with facial animation data.

### `StarterPlayer.EnableMouseLockOption`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines if a player can toggle mouse lock by default.

This property determines if a player can toggle mouse lock by default.

Mouselock will lock the player's cursor to the center of the screen.
Moving the mouse will rotate the `Class.Camera` and `Class.Player` will
move relative to the current rotation of the camera.

This property sets the value of `Class.Player.DevEnableMouseLock`.

Note that shift-lock related APIs are in the process of being deprecated,
so it's recommended to use `Class.UserInputService.MouseBehavior` instead
to lock the mouse.

### `StarterPlayer.HealthDisplayDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Sets the distance at which this player will see other `Class.Humanoid`
health bars. If set to 0, the health bars will not be displayed.

This property sets the distance in studs at which this player will see
other `Class.Humanoid` health bars. If set to 0, the health bars will not
be displayed. This property is set to 100 studs by default.

To change the display distance for a player once they join the game, you
can set the `Class.Player.HealthDisplayDistance` property.

If a `Class.Humanoid` health bar is visible, you can set the display type
using `Class.Humanoid.DisplayDistanceType`.

### `StarterPlayer.LoadCharacterAppearance`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Whether or not the appearance of a player's character should be loaded.

This property sets whether or not the appearance of a player's character
should be loaded.

Setting this to `false` results in the player having no clothes (including
hats), body colors, body packages or anything else related to the
appearance of the player's avatar. By default, this property is set to
`true`.

Setting this to `true` results in the player loading the appearance
corresponding to the player's `Class.Player.CharacterAppearanceId`.

If `Class.Player:LoadCharacterWithHumanoidDescriptionAsync()` is used, it
can be advantageous to set `Class.StarterPlayer.LoadCharacterAppearance`
to false as the player's avatar is not required as all asset IDs to equip
on the character will come from the passed in `Class.HumanoidDescription`.

### `StarterPlayer.LoadCharacterLayeredClothing `

- **Type:** `LoadCharacterLayeredClothing`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `NotScriptable`
- **Capabilities:** `Players`

Indicates whether characters spawning into an experience will have layered
clothing accessories equipped on them.

Indicates whether characters spawning into an experience will have layered
clothing accessories equipped on them (Although
`Class.Workspace.MeshPartHeadsAndAccessories` also need to be enabled in
the `Class.Workspace`).

### `StarterPlayer.LuaCharacterController`

- **Type:** `CharacterControlMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

### `StarterPlayer.NameDisplayDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Sets the distance at which this player will see other `Class.Humanoid`
names.

Sets the distance at which this player will see other `Class.Humanoid`
names. If set to `0`, names are hidden. This property is set to `100`
studs by default.

To change the display distance for a player once they join the game, you
can set the `Class.Player.NameDisplayDistance` property.

If a `Class.Humanoid` name is visible, you can set the display type using
`Class.Humanoid.DisplayDistanceType`.

### `StarterPlayer.UserEmotesEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Determines if user-owned emotes are loaded when loading avatars.

This property determines if user-owned emotes are loaded when loading
avatars. Setting this property to `false` disables loading. Developers can
set the property in Studio directly.

When emote loading is disabled, the emotes UI will still work as long as
developers choose to use the emotes feature by adding emotes within their
game.

See also [Avatar Emotes](../../../characters/emotes.md), an article
detailing how to control, customize, and play avatar emotes.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `StarterPlayer.AllowCustomAnimations` security: `read=None, write=RobloxScriptSecurity`
- Property `StarterPlayer.AutoJumpEnabled` security: `read=None, write=None`
- Property `StarterPlayer.AvatarJointUpgrade` security: `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- Property `StarterPlayer.CameraMaxZoomDistance` security: `read=None, write=None`
- Property `StarterPlayer.CameraMinZoomDistance` security: `read=None, write=None`
- Property `StarterPlayer.CameraMode` security: `read=None, write=None`
- Property `StarterPlayer.CharacterBreakJointsOnDeath` security: `read=None, write=None`
- Property `StarterPlayer.CharacterJumpHeight` security: `read=None, write=None`
- Property `StarterPlayer.CharacterJumpPower` security: `read=None, write=None`
- Property `StarterPlayer.CharacterMaxSlopeAngle` security: `read=None, write=None`
- Property `StarterPlayer.CharacterUseJumpPower` security: `read=None, write=None`
- Property `StarterPlayer.CharacterWalkSpeed` security: `read=None, write=None`
- Property `StarterPlayer.ClassicDeath` security: `read=None, write=None`
- Property `StarterPlayer.CreateDefaultPlayerModule` security: `read=None, write=None`
- Property `StarterPlayer.DevCameraOcclusionMode` security: `read=None, write=None`
- Property `StarterPlayer.DevComputerCameraMovementMode` security: `read=None, write=None`
- Property `StarterPlayer.DevComputerMovementMode` security: `read=None, write=None`
- Property `StarterPlayer.DevTouchCameraMovementMode` security: `read=None, write=None`
- Property `StarterPlayer.DevTouchMovementMode` security: `read=None, write=None`
- Property `StarterPlayer.EnableDynamicHeads` security: `read=None, write=None`
- Property `StarterPlayer.EnableMouseLockOption` security: `read=None, write=None`
- Property `StarterPlayer.HealthDisplayDistance` security: `read=None, write=None`
- Property `StarterPlayer.LoadCharacterAppearance` security: `read=None, write=None`
- Property `StarterPlayer.LoadCharacterLayeredClothing ` security: `read=None, write=None`
- Property `StarterPlayer.LuaCharacterController` security: `read=None, write=None`
- Property `StarterPlayer.NameDisplayDistance` security: `read=None, write=None`
- Property `StarterPlayer.UserEmotesEnabled` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- StarterPlayer.AutoJumpEnabled: Auto-Jump-Toggle
- StarterPlayer.CameraMaxZoomDistance: setting-camera-zoom-distance
- StarterPlayer.CameraMinZoomDistance: setting-camera-zoom-distance
- StarterPlayer.CameraMode: playing-in-first-person
- StarterPlayer.EnableMouseLockOption: enabling-a-player-s-mouse-lock
- StarterPlayer.HealthDisplayDistance: hiding-player-health-and-names
- StarterPlayer.LoadCharacterAppearance: disabling-a-player-s-appearance
- StarterPlayer.NameDisplayDistance: hiding-player-health-and-names

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/StarterPlayer
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/StarterPlayer.yaml
- Captured: 2026-04-16
