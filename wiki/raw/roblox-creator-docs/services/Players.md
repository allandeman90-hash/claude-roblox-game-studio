---
title: Players
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Players
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Players.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: players
tags: [roblox-class, players, service]
---

# Players

A service that contains presently connected `Class.Player` objects.

## Description

The `Class.Players` service contains `Class.Player` objects for presently
connected clients to a Roblox server. It also contains information about a
place's configuration. It can fetch information about players not connected to
the server, such as character appearances, friends, and avatar thumbnail.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

### `Players.BanningEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Players`

Enables or disables the three `Class.Players` methods
(`Class.Players:BanAsync()|BanAsync()`,
`Class.Players:UnbanAsync()|UnbanAsync()`, and
`Class.Players:GetBanHistoryAsync()|GetBanHistoryAsync()`) that constitute
the ban API. This property is not scriptable and can only be modified in
Studio.

### `Players.BubbleChat`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Chat`, `Players`

Indicates whether or not bubble chat is enabled. It is set with the
`Class.Players:SetChatStyle()` method.

This property indicates whether or not bubble chat is enabled. It is set
with the `Class.Players:SetChatStyle()` method using the `Enum.ChatStyle`
enum.

When this chat mode is enabled, the experience displays chats in the chat
user interface at the top-left corner of the screen.

There are two other chat modes, `Class.Players.ClassicChat` and a chat
mode where both classic and bubble chat are enabled.

### `Players.CharacterAutoLoads`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Players`

Indicates whether `Class.Player.Character|characters` will respawn
automatically.

This property indicates whether `Class.Player.Character|characters` will
respawn automatically. The default value is true.

If this property is disabled (false), player
`Class.Player.Character|characters` will not spawn until the
`Class.Player:LoadCharacterAsync()` function is called for each
`Class.Player`, including when players join the experience.

This can be useful in experiences where players have finite lives, such as
competitive experiences in which players do not respawn until a round
ends.

### `Players.ClassicChat`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Chat`, `Players`

Indicates whether or not classic chat is enabled; set by the
`Class.Players:SetChatStyle()` method.

Indicates whether or not classic chat is enabled. This property is set by
the `Class.Players:SetChatStyle()` method using the `Enum.ChatStyle` enum.

When this chat mode is enabled, the experience displays chats in a bubble
above the sender's head.

There are two other chat modes, `Class.Players.BubbleChat` and a chat mode
where both classic and bubble chat are enabled.

### `Players.LocalPlayer`

- **Type:** `Player`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Players`

The `Class.Player` that the `Class.LocalScript` is running for.

This read-only property refers to the `Class.Player` whose client is
running the experience.

This property is only defined for `Class.LocalScript|LocalScripts` and
`Class.ModuleScript|ModuleScripts` required by them, since they run on the
client. For the server, on which `Class.Script` objects run their code,
this property is `nil`.

### `Players.localPlayer`

- **Type:** `Player`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Players`
- **Deprecated:** This property is a deprecated variant of `Class.Players.LocalPlayer` which
should be used instead.

### `Players.MaxPlayers`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Players`

The maximum number of players that can be in a server.

This property determines the maximum number of players that can be in a
server. This property can only be set through a specific place's settings
on the [Creator Dashboard](https://create.roblox.com/dashboard/creations)
or through [Experience Settings](../../../studio/experience-settings.md).

### `Players.NumPlayers`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Players`
- **Deprecated:** This item is deprecated. Instead, of using this item, you should count the
number of players returned by `Class.Players:GetPlayers()`.

Returns the number of people in the server at the current time.

This property indicates the number of people in the server at the current
time. It is read only. Meaning it cannot be written to, only read.

### `Players.numPlayers`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Players`
- **Deprecated:** This property is a deprecated variant of `Class.Players.NumPlayers` which
has also been deprecated. Neither property should be used in new work.
Instead, you should count the number of players returned by
`Class.Players:GetPlayers()`.

Returns the number of people in the server at the current time.

This property indicates the number of people in the server at the current
time. It is read only. Meaning it cannot be written to, only read.

### `Players.PreferredPlayers`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Players`

The preferred number of players for a server.

This property indicates the number of players to which Roblox's matchmaker
will fill servers. This number will be less than the maximum number of
players (`Class.Players.MaxPlayers`) supported by the experience.

### `Players.RespawnTime`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Players`

Controls the amount of time taken for a players character to respawn.

This property controls the time, in seconds, it takes for a player to
respawn when `Class.Players.CharacterAutoLoads` is true. It defaults to
5.0 seconds.

This is useful when you want to change how long it takes to respawn based
on the type of your experience but don't want to handle spawning players
individually.

Although this property can be set from within a `Class.Script`, you can
more easily set it directly on the `Class.Players` object in Studio's
[Explorer](../../../studio/explorer.md) window.

### `Players.UseStrafingAnimations`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Players`

## Methods

### `Players:BanAsync`

```
BanAsync(config: Dictionary) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Consequences`

Bans users from your experience, with options to specify duration, reason,
whether the ban applies to the entire universe or just the current place,
and more. This method is enabled and disabled by the
`Class.Players.BanningEnabled` property, which you can toggle in Studio.

The `Class.Players:BanAsync()` method allows you to easily ban users who
violate your experience's guidelines. You can specify the ban duration,
enable the ban to propagate to suspected alternate accounts, and provide a
message to the banned user in accordance with the
[Usage Guidelines](../../../players/index.md#banning-users). You should
also post your experience rules somewhere accessible to all users and
provide a way for them to appeal. This method is enabled and disabled by
the `Class.Players.BanningEnabled` property, which you can toggle in
Studio.

##### Banning and Messaging

Banned users will be immediately evicted and prevented from rejoining your
experiences. They will be presented with an error modal displaying the
time left on their ban and your `DisplayReason`. Roblox's backend systems
will evict players across all servers from the place(s) that you specify.
`DisplayReason` can have a maximum length of 400 characters and is subject
to a text filter. For more information on acceptable modal text, see
[ban messaging](../../../players/index.md#message-guidelines).

##### Places and Universe

By default, bans extend to any place within that universe. To limit the
ban to only the place from which this API is called, configure
`ApplyToUniverse` to `false`. However, if a user is banned in the start
place of the universe, it effectively results in the user being excluded
from the entirety of the universe, irrespective of whether a universal ban
is in place or not.

##### Alternative Accounts

Users often play under multiple different accounts, known as alternate
accounts or alt accounts, which are sometimes used to circumvent account
bans. To help you keep banned users out, the default behavior of this API
will propagate all bans from the source account you banned to any of their
suspected alt accounts. You can turn off ban propagations to alt accounts
by configuring `ExcludeAltAccounts` to `true`.

##### Ban Duration

Not all transgressions are the same, so not all bans should be the same
length. This API lets you configure the duration of the ban, in seconds,
with the `Duration` field. To specify a permanent ban, set the field to
`-1`. You may also want to dynamically configure the ban duration based on
the user's ban history, which you can query for using
`Class.Players:GetBanHistoryAsync()`. For example, you may want to
consider the number of bans, the duration of previous bans, or build logic
off of the notes you save under `PrivateReason` which can be up to 1000
characters and are not text filtered. `PrivateReason` notes are never
shared with the client and can be considered safe from attackers.

##### Errors and Throttling

This method invokes an HTTP call to backend services which are subject to
throttling and may fail. If you're calling this API with more than one
`Class.Player.UserId|UserId`, this method will attempt to make the HTTP
call for each ID. It will then aggregate any error messages and join them
as a comma separated list. For example, if this method is invoked for five
users and requests for those with `Class.Player.UserId|UserIds` 2 and 4
fail, the following error message appears:

`HTTP failure for UserId 2: Timedout, HTTP 504 (Service unavailable) failure for UserId 4: Service exception`

The message will always include `failure for UserId {}` if it is an HTTP
error.

##### Client-Side Requirement

Because of the risks associated with banning users, this method may only
be called on the backend experience server (client-side calls will result
in an error). You may test this API in Studio, during
[collaborative](../../../projects/collaboration.md) creation, or in a
[team test](../../../studio/testing-modes.md#collaborative-testing), but
the bans will not apply to production.

This API uses the
[User Restrictions Open Cloud API](/cloud/reference/UserRestriction). You
will be able to utilize these APIs to manage your bans in third party
applications.

**Parameters:**

- `config` : `Dictionary` — - `UserIds` (required; array) — Array of `Class.Player.UserId|UserIds`   of players to be banned. Max size is `50`.  - `ApplyToUniverse` (optional; boolean) — Whether ban propagates to   all places within the experience universe. Default is `true`.  - `Duration` (required; integer) — Duration of the ban, in seconds.   Permanent bans should have a value of `-1`. `0` and all other   negative values are invalid.  - `DisplayReason` (required; string) — The message that will be   displayed to users when they attempt to and fail to join an   experience. Maximum string length is `400`.  - `PrivateReason` (required; string) — Internal messaging that will be   returned when querying the user's ban history. Maximum string length   is `1000`.  - `ExcludeAltAccounts` (optional; boolean) — When `true`, Roblox does   not attempt to ban alt accounts. Default is `false`.

**Returns:**

- `()` — 

### `Players:Chat`

```
Chat(message: string) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; capabilities=`Players`

Makes the local player chat the given message.

This function makes the local player chat the given message. Since this
item is protected, attempting to use it in a `Class.Script` or
`Class.LocalScript` will cause an error.

Instead, when creating a custom chat system, or a system that needs access
to the chat, you can use the `Class.Chat` service's `Class.Chat:Chat()`
function instead.

**Parameters:**

- `message` : `string` — The message chatted.

**Returns:**

- `()` — 

### `Players:CreateHumanoidModelFromDescription`

```
CreateHumanoidModelFromDescription(description: HumanoidDescription, rigType: HumanoidRigType, assetTypeVerification: AssetTypeVerification = Default) -> Model
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`AvatarAppearance`, `Players` ; **Deprecated:** This method has been superseded by
`Class.Players:CreateHumanoidModelFromDescription()|CreateHumanoidModelFromDescription()`.

Returns a character `Class.Model` equipped with everything specified in
the passed in `Class.HumanoidDescription`.

**Parameters:**

- `description` : `HumanoidDescription` — Specifies the appearance of the returned character.
- `rigType` : `HumanoidRigType` — Specifies whether the returned character will be R6 or R15.
- `assetTypeVerification` : `AssetTypeVerification` (default `Default`) — The asset type verification mode.

**Returns:**

- `Model` — A `Class.Humanoid` character `Class.Model`.

### `Players:CreateHumanoidModelFromDescriptionAsync`

```
CreateHumanoidModelFromDescriptionAsync(description: HumanoidDescription, rigType: HumanoidRigType, assetTypeVerification: AssetTypeVerification = Default) -> Model
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AvatarAppearance`, `Players`

Returns a character `Class.Model` equipped with everything specified in
the passed in `Class.HumanoidDescription`.

Returns a character `Class.Model` equipped with everything specified in
the passed in `Class.HumanoidDescription`, and is R6 or R15 as specified
by `rigType`.

**Parameters:**

- `description` : `HumanoidDescription` — Specifies the appearance of the returned character.
- `rigType` : `HumanoidRigType` — Specifies whether the returned character will be R6 or R15.
- `assetTypeVerification` : `AssetTypeVerification` (default `Default`) — The asset type verification mode.

**Returns:**

- `Model` — A `Class.Humanoid` character `Class.Model`.

### `Players:CreateHumanoidModelFromUserId`

```
CreateHumanoidModelFromUserId(userId: int64) -> Model
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players` ; **Deprecated:** This method has been superseded by
`Class.Players:CreateHumanoidModelFromUserIdAsync()|CreateHumanoidModelFromUserIdAsync()`.

Returns a character Model set-up with everything equipped to match the
avatar of the user specified by the passed in userId.

**Parameters:**

- `userId` : `int64` — The userId for a Roblox user. (The UserId is the number in the profile of the user e.g www.roblox.com/users/1/profile).

**Returns:**

- `Model` — A Humanoid character Model.

### `Players:CreateHumanoidModelFromUserIdAsync`

```
CreateHumanoidModelFromUserIdAsync(userId: int64) -> Model
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`

Returns a character Model set-up with everything equipped to match the
avatar of the user specified by the passed in userId.

Returns a character Model set-up with everything equipped to match the
avatar of the user specified by the passed in userId. This includes
whether that character is currently R6 or R15.

**Parameters:**

- `userId` : `int64` — The userId for a Roblox user. (The UserId is the number in the profile of the user e.g www.roblox.com/users/1/profile).

**Returns:**

- `Model` — A Humanoid character Model.

### `Players:GetBanHistoryAsync`

```
GetBanHistoryAsync(userId: int64) -> BanHistoryPages
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Consequences`

Retrieves the ban and unban history of any user within the experience's
universe. This method is enabled and disabled by the
`Class.Players.BanningEnabled` property, which you can toggle in Studio.

Retrieves the ban and unban history of any user within the experience's
universe. This method returns a `Class.BanHistoryPages` instance that
inherits from `Class.Pages`. This method is enabled and disabled by the
`Class.Players.BanningEnabled` property, which you can toggle in Studio.

This function call will only succeed on production servers and not on
client devices or in Studio.

This API uses the
[User Restrictions Open Cloud API](/cloud/reference/UserRestriction). You
will be able to utilize these APIs to manage your bans in third party
applications.

**Parameters:**

- `userId` : `int64` — 

**Returns:**

- `BanHistoryPages` — See `Class.BanHistoryPages` for return reference.

### `Players:GetCharacterAppearanceAsync`

```
GetCharacterAppearanceAsync(userId: int64) -> Model
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Players`

Returns a `Class.Model` containing the assets which the player is wearing,
excluding gear.

This function returns a `Class.Model` containing the assets which the
player is wearing, excluding gear.

If you prefer a Luau table of information about these assets instead of a
model, use `Class.Players:GetCharacterAppearanceInfoAsync()`.

This method behaves similar to `Class.InsertService:LoadAsset()`, and is
like using `Class.InsertService:LoadAsset()|LoadAsset` on the asset
information returned by `Class.Players:GetCharacterAppearanceInfoAsync()`
except faster.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId` of the specified player.

**Returns:**

- `Model` — 

### `Players:GetCharacterAppearanceInfoAsync`

```
GetCharacterAppearanceInfoAsync(userId: int64) -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`

Returns information about the character appearance of a given user.

This function returns information about a player's avatar on the Roblox
website in the form of a dictionary. It is not to be confused with
`Class.Players:GetCharacterAppearanceAsync()|GetCharacterAppearanceAsync`,
which actually loads the assets described by this method. You can use
`Class.InsertService:LoadAsset()` to load the assets that are used in the
player's avatar. The structure of the returned dictionary is as follows:

<table>
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Description</th>
		</tr>
	</thead>
  <tr>
    <td><code>assets</code></td>
    <td>table (see below)</td>
    <td>Describes the equipped assets (hats, body parts, etc)</td>
  </tr>
  <tr>
    <td><code>bodyColors</code></td>
    <td>table (see below)</td>
    <td>Describes the BrickColor values for each limb</td>
  </tr>
  <tr>
    <td><code>bodyColor3s</code></td>
    <td>table (see below)</td>
    <td>Describes the Color3 instance for each limb which may not match perfectly with bodyColors</td>
  </tr>
	<tr>
    <td><code>defaultPantsApplied</code></td>
    <td>bool</td>
    <td>Describes whether default pants are applied</td>
  </tr>
	<tr>
    <td><code>defaultShirtApplied</code></td>
    <td>bool</td>
    <td>Describes whether default shirt is applied</td>
  </tr>
  <tr>
    <td><code>emotes</code></td>
    <td>table (see below)</td>
    <td>Describes the equipped emote animations</td>
  </tr>
	<tr>
    <td><code>playerAvatarType</code></td>
    <td>string</td>
    <td>Either "R15" or "R6"</td>
  </tr>
	<tr>
    <td><code>scales</code></td>
    <td>table (see below)</td>
    <td>Describes various body scaling factors</td>
  </tr>
</table>

##### Assets Sub-Table

The `assets` table is an array of tables containing the following keys
that describe the assets currently equipped by the player:

<table>
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Description</th>
		</tr>
	</thead>
	<tr>
    <td><code>id</code></td>
    <td>number</td>
    <td>The asset ID of the equipped asset</td>
  </tr>
	<tr>
    <td><code>assetType</code></td>
    <td>table</td>
    <td>A table with <code>name</code> and <code>id</code> fields, each describing the kind of asset equipped ("Hat", "Face", etc.)</td>
  </tr>
	<tr>
    <td><code>name</code></td>
    <td>string</td>
    <td>The name of the equipped asset</td>
  </tr>
</table>

##### Scales Sub-Table

The `scales` table has the following keys, each a number corresponding to
one `Class.Humanoid` scaling property: `bodyType`, `head`, `height`,
`proportion`, `depth`, `width`.

##### Body Colors Sub-Table

The `bodyColors` table has the following keys, each a number corresponding
to a `Datatype.BrickColor` ID number which can be used with
`Datatype.BrickColor.new(id)`: `leftArmColorId`, `torsoColorId`,
`rightArmColorId`, `headColorId`, `leftLegColorId`, `rightLegColorId`.

**Parameters:**

- `userId` : `int64` — The \*_userId_ of the specified player.

**Returns:**

- `Dictionary` — A dictionary containing information about the character appearance of a given user.

### `Players:GetFriendsAsync`

```
GetFriendsAsync(userId: int64) -> FriendPages
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Social`

Returns a `Class.FriendPages` object which contains information for all of
the given player's friends.

The GetFriends `Class.Players` function returns a `Class.FriendPages`
object which contains information for all of the given user's friends. The
items within the `Class.FriendPages` object are tables with the following
fields:

<table>
	<thead>
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Description</th>
		</tr>
	</thead>
	<tr>
		<td>Id</td>
		<td>int64</td>
		<td>The friend's UserId</td>
	</tr>
	<tr>
		<td>Username</td>
		<td>string</td>
		<td>The friend's username</td>
	</tr>
    <tr>
      <td>DisplayName</td>
      <td>string</td>
      <td>The <code>Class.Player.DisplayName|display name</code> of the friend.</td>
    </tr>
</table>

See the code samples for an easy way to iterate over all a player's
friends.

**Parameters:**

- `userId` : `int64` — The user ID of the player being specified.

**Returns:**

- `FriendPages` — 

### `Players:GetHumanoidDescriptionFromOutfitId`

```
GetHumanoidDescriptionFromOutfitId(outfitId: int64) -> HumanoidDescription
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`AvatarAppearance`, `Players` ; **Deprecated:** This method has been superseded by
`Class.Players:GetHumanoidDescriptionFromOutfitIdAsync()|GetHumanoidDescriptionFromOutfitIdAsync()`.

Returns the HumanoidDescription for a specified outfit, which will be set
with the parts/colors/Animations etc of the outfit.

**Parameters:**

- `outfitId` : `int64` — The ID of the outfit for which the HumanoidDescription is sought.

**Returns:**

- `HumanoidDescription` — HumanoidDescription initialized with the specification for the passed in outfitId.

### `Players:GetHumanoidDescriptionFromOutfitIdAsync`

```
GetHumanoidDescriptionFromOutfitIdAsync(outfitId: int64) -> HumanoidDescription
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AvatarAppearance`, `Players`

Returns the HumanoidDescription for a specified outfit, which will be set
with the parts/colors/Animations etc of the outfit.

Returns the HumanoidDescription for a specified outfitId, which will be
set with the parts/colors/Animations etc of the outfit. An outfit can be
one created by a user, or it can be the outfit for a bundle created by
Roblox.

**Parameters:**

- `outfitId` : `int64` — The ID of the outfit for which the HumanoidDescription is sought.

**Returns:**

- `HumanoidDescription` — HumanoidDescription initialized with the specification for the passed in outfitId.

### `Players:GetHumanoidDescriptionFromUserId`

```
GetHumanoidDescriptionFromUserId(userId: int64) -> HumanoidDescription
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`AvatarAppearance`, `Players` ; **Deprecated:** This method has been superseded by
`Class.Players.GetHumanoidDescriptionFromUserIdAsync|GetHumanoidDescriptionFromUserIdAsync()`.

Returns a HumanoidDescription which specifies everything equipped for the
avatar of the user specified by the passed in userId.

**Parameters:**

- `userId` : `int64` — The userId for a Roblox user. (The UserId is the number in the profile of the user e.g www.roblox.com/users/1/profile).

**Returns:**

- `HumanoidDescription` — HumanoidDescription initialized with the passed in user's avatar specification.

### `Players:GetHumanoidDescriptionFromUserIdAsync`

```
GetHumanoidDescriptionFromUserIdAsync(userId: int64) -> HumanoidDescription
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AvatarAppearance`, `Players`

Returns a HumanoidDescription which specifies everything equipped for the
avatar of the user specified by the passed in userId.

Returns a HumanoidDescription which specifies everything equipped for the
avatar of the user specified by the passed in userId. Also includes scales
and body colors.

**Parameters:**

- `userId` : `int64` — The userId for a Roblox user. (The UserId is the number in the profile of the user e.g www.roblox.com/users/1/profile).

**Returns:**

- `HumanoidDescription` — HumanoidDescription initialized with the passed in user's avatar specification.

### `Players:GetNameFromUserIdAsync`

```
GetNameFromUserIdAsync(userId: int64) -> string
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`

Sends a query to the Roblox website for the username of an account with a
given `Class.Player.UserId|UserId`.

The GetNameFromUserIdAsync `Class.Players` function will send a query to
the Roblox website asking what the username is of the account with the
given `Class.Player.UserId|UserId`.

This method errors if no account exists with the given UserId. If you
aren't certain such an account exists, it's recommended to wrap calls to
this function with `Global.LuaGlobals.pcall()`. In addition, you can
manually cache results to make future calls with the same UserId fast. See
the code samples to learn more.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId` of the player being specified.

**Returns:**

- `string` — The name of a user with the specified `Class.Player.UserId`.

### `Players:GetPlayerByUserId`

```
GetPlayerByUserId(userId: int64) -> Player
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Players`

Returns the `Class.Player` with the given `Class.Player.UserId|UserId` if
they are in-experience.

This function searches each `Class.Player` in `Class.Players` for one
whose `Class.Player.UserId` matches the given `userId`. If such a player
does not exist, it returns `nil`.

This method is useful in finding the purchaser of a developer product
using `Class.MarketplaceService.ProcessReceipt` which provides a table
that includes the purchaser's `Class.Player.UserId|UserId` and not a
reference to the `Class.Player` object itself. Most experiences will
require a reference to the player in order to grant products.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId` of the player being specified.

**Returns:**

- `Player` — 

### `Players:GetPlayerFromCharacter`

```
GetPlayerFromCharacter(character: Model) -> Player
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Players`

Returns the `Class.Player` whose `Class.Player.Character` matches the
given instance, or `nil` if one cannot be found.

This function returns the `Class.Player` associated with the given
`Class.Player.Character`, or `nil` if one cannot be found. It is
equivalent to the following function:

```lua
local function getPlayerFromCharacter(character)
	for _, player in game:GetService("Players"):GetPlayers() do
		if player.Character == character then
			return player
		end
	end
end
```

This method is often used when some event in player's character fires
(such as their `Class.Humanoid` `Class.Humanoid.Died|dying`). Such an
event might not directly reference the Player object, but this method
provides easy access. The inverse of this function can be described as
getting the Character of a Player. To do this, simply access the Character
property.

**Parameters:**

- `character` : `Model` — A character instance that you want to get the player from.

**Returns:**

- `Player` — 

### `Players:GetPlayers`

```
GetPlayers() -> List<Player>
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Players`

Returns a table of all presently connected `Class.Player` objects.

This method returns a table of all presently connected `Class.Player`
objects. It functions the same way `Class.Instance:GetChildren()` would
except that it only returns `Class.Player` objects found under
`Class.Players`. When used with a `for` loop, it is useful for iterating
over all players in an experience.

```lua
local Players = game:GetService("Players")

for _, player in Players:GetPlayers() do
	print(player.Name)
end
```

Scripts that connect to `Class.Players.PlayerAdded` are often trying to
process every Player that connects to the experience. This method is
useful for iterating over already-connected players that wouldn't fire
`Class.Players.PlayerAdded|PlayerAdded`. Using this method ensures that no
player is missed!

```lua
local Players = game:GetService("Players")

local function onPlayerAdded(player)
	print("Player: " .. player.Name)
end

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
```

**Returns:**

- `List<Player>` — A table containing all the players in the server.

### `Players:getPlayers`

```
getPlayers() -> List<Player>
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is a deprecated variant of `Class.Players:GetPlayers()`
which should be used instead.

**Returns:**

- `List<Player>` — 

### `Players:GetUserIdFromNameAsync`

```
GetUserIdFromNameAsync(userName: string) -> int64
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`

Sends a query to the Roblox website for the `Class.Player.UserId|userId`
of an account with a given username.

This function will send a query to the Roblox website asking what the
`Class.Player.UserId` is of the account with the given `Class.Player`
name.

This method errors if no account exists with the given username. If you
aren't certain such an account exists, it's recommended to wrap calls to
this function with `Global.LuaGlobals.pcall()`. In addition, you can
manually cache results to quickly make future calls with the same
username. See the code samples to learn more.

**Parameters:**

- `userName` : `string` — The username of the player being specified.

**Returns:**

- `int64` — The `Class.Player.UserId` of a user whose name is specified.

### `Players:GetUserThumbnailAsync`

```
GetUserThumbnailAsync(userId: int64, thumbnailType: ThumbnailType, thumbnailSize: ThumbnailSize) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`

Returns the content URL of a player thumbnail given the size and type, as
well as a boolean describing if the image is ready to use.

This function returns the content URL of an image of a player's avatar
given their `Class.Player.UserId|UserId`, the desired image size as a
`Enum.ThumbnailSize` enum, and the desired type as a `Enum.ThumbnailType`
enum. It also returns a boolean describing if the image is ready to use.

Most often, this method is used with `Class.ImageLabel.Image` or
`Class.Decal.Texture` to display user avatar pictures in an experience.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId` of the player being specified.
- `thumbnailType` : `ThumbnailType` — A `Enum.ThumbnailType` describing the type of thumbnail.
- `thumbnailSize` : `ThumbnailSize` — A `Enum.ThumbnailSize` specifying the size of the thumbnail.

**Returns:**

- `Tuple` — A tuple containing the content URL of a user thumbnail based on the specified parameters, and a bool describing if the image is ready to be used or not.

### `Players:playerFromCharacter`

```
playerFromCharacter(character: Model) -> Player
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This function is a deprecated variant of
`Class.Players:GetPlayerFromCharacter()` which should be used in new work.

**Parameters:**

- `character` : `Model` — 

**Returns:**

- `Player` — 

### `Players:players`

```
players() -> List<Player>
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Players` ; **Deprecated:** This item has been superseded by `Class.Players:GetPlayers()` which should
be used in all new work.

Returns a list of players in an experience.

This function was once used to return a list of players in an experience,
but has since been deprecated in favor of `Class.Players:GetPlayers()`

**Returns:**

- `List<Player>` — 

### `Players:SetChatStyle`

```
SetChatStyle(style: ChatStyle = Classic) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; capabilities=`Players`

Sets whether BubbleChat and ClassicChat are being used, and tells TeamChat
and `Class.Chat` what to do.

This function sets whether BubbleChat and ClassicChat are being used, and
tells TeamChat and Chat what to do using the `Enum.ChatStyle` enum. Since
this item is protected, attempting to use it in a `Class.Script` or
`Class.LocalScript` will cause an error.

This function is used internally when the chat mode is set by the
experience.

**Parameters:**

- `style` : `ChatStyle` (default `Classic`) — The specified chat style being set.

**Returns:**

- `()` — 

### `Players:TeamChat`

```
TeamChat(message: string) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; capabilities=`Players`

Makes the local player chat the given message, which will only be viewable
by users on the same team.

This function makes the `Class.Players.LocalPlayer` chat the given
message, which will only be viewable by users on the same team. Since this
item is protected, attempting to use it in a `Class.Script` or
`Class.LocalScript` will cause an error.

This function is used internally when the `Class.Players.LocalPlayer`
sends a message to their team.

**Parameters:**

- `message` : `string` — The message being chatted.

**Returns:**

- `()` — 

### `Players:UnbanAsync`

```
UnbanAsync(config: Dictionary) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Players`, `Consequences`

Unbans players banned from `Class.Players:BanAsync()` or the User
Restrictions Open Cloud API. This method is enabled and disabled by the
`Class.Players.BanningEnabled` property, which you can toggle in Studio.

Unbans players banned from `Class.Players:BanAsync()` or the
[User Restrictions Open Cloud API](/cloud/reference/UserRestriction). This
method is enabled and disabled by the `Class.Players.BanningEnabled`
property, which you can toggle in Studio.

Like `Class.Players:BanAsync()`, this method takes in a `config`
dictionary that will let you bulk unban users. This configures the users
that are unbanned and the scope from which they are unbanned from.

Unbans will only take effect on bans with the same `ApplyToUniverse`
scope. For example, an unban with `ApplyToUniverse` set to `true` will not
invalidate a previous ban with `ApplyToUniverse` set to `false`. In other
words, a universe level unban will not invalidate a place level ban. The
opposite also holds true.

This method invokes a HTTP call to backend services, which are throttled
and may fail. If you are calling this API with multiple UserIds, this
method will attempt to make this HTTP call for each UserId. It will then
aggregate any error messages and join them as a comma separated list. For
example, if this method is invoked for five `UserIds`: `{1, 2, 3, 4, 5}`
and requests for users 2 and 4 fail then the following error message
appears:
`HTTP failure for UserId 2: Timedout, HTTP 504 (Service unavailable) failure for UserId 4: Service exception.`
The message will always include `failure for UserId {}` if it is an HTTP
error. It is undefined behavior if you pass in both valid and invalid
UserIds, i.e. a `UserId` that is not a positive number, as some network
requests may succeed before all input is validated.

Because of the risks associated with banning users, this method may only
be called on the backend server. Client side calls will result in an
error. You may test this API in Studio, Team Create, and Team Test, but
the bans will not apply to production. This function call will only
attempt ban requests on production servers and not in Studio testing.
However, all input validation steps will still work in Studio.

This API uses the
[User Restrictions Open Cloud API](/cloud/reference/UserRestriction). You
will be able to utilize these APIs to manage your bans in third party
applications.

**Parameters:**

- `config` : `Dictionary` — <table><thead> <tr>   <th>Name</th>   <th>Type</th>   <th>Description</th> </tr></thead> <tbody>   <tr>     <td><code>UserIds</code></td>     <td>array</td>     <td>UserIDs to be force allowed into the experience(s). <br /> <br />Max size is <code>50</code>.</td>   </tr>   <tr>     <td><code>ApplyToUniverse</code></td>     <td>boolean</td>     <td>Propagates the unban to all places within this universe.<br /></td>   </tr> </tbody> </table>

**Returns:**

- `()` — 

## Events

### `Players.PlayerAdded`

```
PlayerAdded(player: Player)
```

- security=`None` ; capabilities=`Players`

Fires when a player enters the experience.

This event fires when a player enters the experience, such as loading the
player's saved `Class.GlobalDataStore` data.

This can be used alongside the `Class.Players.PlayerRemoving` event, which
fires when a player is about to leave the experience. For instance, if you
would like print a message every time a new player joins or leaves:

```lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined the experience!")
end)

Players.PlayerRemoving:Connect(function(player, reason)
	print(player.Name .. " left the experience! Reason: " .. tostring(exitReason))
end)
```

If you want to track when a player's character is added or removed from
the experience, such as when a player respawns or dies, you can use the
`Class.Player.CharacterAdded` and `Class.Player.CharacterRemoving`
functions.

Note that this event does not work as expected in a solo playtest mode
because the player is created before scripts run that connect to
`Class.Players.PlayerAdded|PlayerAdded`. To handle this case, as well as
cases in which the script is added into the experience after a player
enters, create an `onPlayerAdded()` function that you can call to handle a
player's entrance.

**Parameters:**

- `player` : `Player` — An instance of the player that joined the experience.

### `Players.PlayerMembershipChanged`

```
PlayerMembershipChanged(player: Player)
```

- security=`None` ; capabilities=`Players`

Fires when the experience server recognizes that a player's membership has
changed.

This event fires when the experience server recognizes that a player's
membership has changed. Note, however, that the server will only attempt
to check and update the membership **after** the Premium modal has been
closed. Thus, to account for cases where the user purchases Premium
**outside** of the experience while playing, you must still prompt them to
purchase Premium; this will then show a message telling them they're
already upgraded and, once they close the modal, the server will update
their membership and trigger this event.

To learn more about and incorporating Premium into your experience and
monetizing with the engagement-based payouts system, see
[Engagement-Based Payouts](../../../production/monetization/engagement-based-payouts.md).

See also:

- `Class.MarketplaceService:PromptPremiumPurchase()`, used to prompt a
  user to purchase Premium
- `Class.MarketplaceService.PromptPremiumPurchaseFinished`, fires when the
  Premium purchase UI closes

**Parameters:**

- `player` : `Player` — 

### `Players.PlayerRemoving`

```
PlayerRemoving(player: Player, reason: PlayerExitReason)
```

- security=`None` ; capabilities=`Players`

Fires when a player is about to leave the experience.

This event fires right before a `Class.Player` leaves the experience,
before `Class.Instance.ChildRemoved|ChildRemoved` fires on
`Class.Players`, and behaves somewhat similarly to
`Class.Instance.DescendantRemoving`. Since it fires before the actual
removal of a `Class.Player`, this event is useful for storing player data
using a `Class.GlobalDataStore`.

This can be used alongside the `Class.Player.PlayerAdded` event, which
fires when a player joins the experience. For instance, to print a message
every time a new player joins or leaves:

```lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined the experience!")
end)

Players.PlayerRemoving:Connect(function(player, exitReason)
	print(player.Name .. " left the experience! - Reason: " .. tostring(exitReason))
end)
```

If you want to track when a player's character is added or removed from
the experience, such as when a player respawns or dies, you can use the
`Class.Player.CharacterAdded` and `Class.Player.CharacterRemoving`
functions.

**Parameters:**

- `player` : `Player` — An instance of the player that is leaving.
- `reason` : `PlayerExitReason` — Enum.PlayerExitReason in attempt to inform why.

### `Players.UserSubscriptionStatusChanged`

```
UserSubscriptionStatusChanged(user: Player, subscriptionId: string)
```

- security=`None` ; capabilities=`Players`, `Monetization`

Fires when the experience server recognizes that the user's status for a
certain subscription has changed.

This event fires when the experience server recognizes that the user's
status for a certain subscription has changed. Note that the server only
attempts to check and update the status **after** the Subscription
Purchase modal has been closed. To account for cases in which the user
purchases the subscription **outside** of the experience while playing,
you must still prompt them to purchase the subscription; the prompt shows
a message telling the user they're already subscribed, and after they
close the modal, the server updates their subscription status and triggers
this event.

Note that only server scripts receive this event.

**Parameters:**

- `user` : `Player` — User whose subscription status has changed.
- `subscriptionId` : `string` — The ID of the subscription with a status change.

## Notes / Deprecations

- Deprecated property `Players.localPlayer`: This property is a deprecated variant of `Class.Players.LocalPlayer` which
should be used instead.
- Deprecated property `Players.NumPlayers`: This item is deprecated. Instead, of using this item, you should count the
number of players returned by `Class.Players:GetPlayers()`.
- Deprecated property `Players.numPlayers`: This property is a deprecated variant of `Class.Players.NumPlayers` which
has also been deprecated. Neither property should be used in new work.
Instead, you should count the number of players returned by
`Class.Players:GetPlayers()`.
- Deprecated method `Players:CreateHumanoidModelFromDescription`: This method has been superseded by
`Class.Players:CreateHumanoidModelFromDescription()|CreateHumanoidModelFromDescription()`.
- Deprecated method `Players:CreateHumanoidModelFromUserId`: This method has been superseded by
`Class.Players:CreateHumanoidModelFromUserIdAsync()|CreateHumanoidModelFromUserIdAsync()`.
- Deprecated method `Players:GetHumanoidDescriptionFromOutfitId`: This method has been superseded by
`Class.Players:GetHumanoidDescriptionFromOutfitIdAsync()|GetHumanoidDescriptionFromOutfitIdAsync()`.
- Deprecated method `Players:GetHumanoidDescriptionFromUserId`: This method has been superseded by
`Class.Players.GetHumanoidDescriptionFromUserIdAsync|GetHumanoidDescriptionFromUserIdAsync()`.
- Deprecated method `Players:getPlayers`: This function is a deprecated variant of `Class.Players:GetPlayers()`
which should be used instead.
- Deprecated method `Players:playerFromCharacter`: This function is a deprecated variant of
`Class.Players:GetPlayerFromCharacter()` which should be used in new work.
- Deprecated method `Players:players`: This item has been superseded by `Class.Players:GetPlayers()` which should
be used in all new work.
- Method `Players:Chat` security: `PluginSecurity`
- Method `Players:SetChatStyle` security: `PluginSecurity`
- Method `Players:TeamChat` security: `PluginSecurity`
- Property `Players.BanningEnabled` security: `read=None, write=None`
- Property `Players.BubbleChat` security: `read=None, write=None`
- Property `Players.CharacterAutoLoads` security: `read=None, write=None`
- Property `Players.ClassicChat` security: `read=None, write=None`
- Property `Players.LocalPlayer` security: `read=None, write=None`
- Property `Players.localPlayer` security: `read=None, write=None`
- Property `Players.MaxPlayers` security: `read=None, write=None`
- Property `Players.NumPlayers` security: `read=None, write=None`
- Property `Players.numPlayers` security: `read=None, write=None`
- Property `Players.PreferredPlayers` security: `read=None, write=None`
- Property `Players.RespawnTime` security: `read=None, write=None`
- Property `Players.UseStrafingAnimations` security: `read=None, write=None`
- Method `Players:BanAsync` yields (tag `Yields`).
- Method `Players:CreateHumanoidModelFromDescription` yields (tag `Yields`).
- Method `Players:CreateHumanoidModelFromDescriptionAsync` yields (tag `Yields`).
- Method `Players:CreateHumanoidModelFromUserId` yields (tag `Yields`).
- Method `Players:CreateHumanoidModelFromUserIdAsync` yields (tag `Yields`).
- Method `Players:GetBanHistoryAsync` yields (tag `Yields`).
- Method `Players:GetCharacterAppearanceAsync` yields (tag `Yields`).
- Method `Players:GetCharacterAppearanceInfoAsync` yields (tag `Yields`).
- Method `Players:GetFriendsAsync` yields (tag `Yields`).
- Method `Players:GetHumanoidDescriptionFromOutfitId` yields (tag `Yields`).
- Method `Players:GetHumanoidDescriptionFromOutfitIdAsync` yields (tag `Yields`).
- Method `Players:GetHumanoidDescriptionFromUserId` yields (tag `Yields`).
- Method `Players:GetHumanoidDescriptionFromUserIdAsync` yields (tag `Yields`).
- Method `Players:GetNameFromUserIdAsync` yields (tag `Yields`).
- Method `Players:GetUserIdFromNameAsync` yields (tag `Yields`).
- Method `Players:GetUserThumbnailAsync` yields (tag `Yields`).
- Method `Players:UnbanAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- Players:BanAsync: Players-Ban
- Players:Chat: Players-Chat1
- Players:CreateHumanoidModelFromDescriptionAsync: create-humanoid-model-from-description
- Players:CreateHumanoidModelFromUserId: create-humanoid-model-from-userid
- Players:CreateHumanoidModelFromUserIdAsync: create-humanoid-model-from-userid
- Players:GetCharacterAppearanceAsync: how-to-get-a-character-s-appearance
- Players:GetCharacterAppearanceInfoAsync: example-return-dictionary
- Players:GetFriendsAsync: print-roblox-friends
- Players:GetHumanoidDescriptionFromOutfitId: get-humanoiddescription-from-outfitid
- Players:GetHumanoidDescriptionFromOutfitIdAsync: get-humanoiddescription-from-outfitid
- Players:GetHumanoidDescriptionFromUserId: get-humanoiddescription-from-userid
- Players:GetHumanoidDescriptionFromUserIdAsync: get-humanoiddescription-from-userid
- Players:GetNameFromUserIdAsync: Name-From-UserId
- Players:GetNameFromUserIdAsync: Name-From-UserId-Cache
- Players:GetPlayerByUserId: Players-GetPlayerByUserId1
- Players:GetPlayerFromCharacter: Players-GetPlayerFromCharacter1
- Players:GetPlayers: Give-Sparkles-to-Everyone
- Players:GetUserIdFromNameAsync: UserId-From-Name
- Players:GetUserIdFromNameAsync: UserId-From-Name-Cache
- Players:GetUserThumbnailAsync: display-player-thumbnail
- Players:SetChatStyle: setting-a-player-s-chat-style
- Players:TeamChat: sending-team-chat
- Players:UnbanAsync: Players-Unban
- Players.CharacterAutoLoads: player-respawn-timer
- Players.PlayerAdded: Players-PlayerAdded1
- Players.PlayerMembershipChanged: handling-premium-membership-changes
- Players.PlayerRemoving: Players-PlayerRemoving1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Players
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Players.yaml
- Captured: 2026-04-16
