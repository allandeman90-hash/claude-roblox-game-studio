---
title: TeleportService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/TeleportService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TeleportService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: networking
tags: [roblox-class, teleport, service]
---

# TeleportService

Enables transporting `Class.Player|Players` between places and servers. For
more information on how to teleport players between servers, see
[Teleport between places](../../../projects/teleport.md).

## Description

**TeleportService** is responsible for transporting `Class.Player|Players`
between different places and servers.

For more information on how to teleport players between servers, see
[Teleport between places](../../../projects/teleport.md).

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

### `TeleportService.CustomizedTeleportUI`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `Deprecated`
- **Capabilities:** `Teleport`
- **Deprecated:** This item is deprecated since the default message it controls has been
removed. Do not use it for new work.

No longer functional.

This property used to control whether or not a `Class.Message` would be
shown by default. The default message has been removed, so this no longer
does anything.

## Methods

### `TeleportService:GetArrivingTeleportGui`

```
GetArrivingTeleportGui() -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `Teleport`

Returns the _customLoadingScreen_ the
`Class.Players.LocalPlayer|LocalPlayer` arrived into the place with.

This function returns the _customLoadingScreen_ the
`Class.Players.LocalPlayer|LocalPlayer` arrived into the place with.

Note, the _customLoadingScreen_ will not be used if the destination place
is in a different game.

#### Loading Screen

During a teleport, while the destination place is loading, the
_customLoadingScreen_ is parented to the `Class.CoreGui`. Once the place
has loaded the `Class.ScreenGui|loading screen` is
`Class.Instance.Parent|parented` to _nil_.

If you wish to preserve the _customLoadingScreen_ and perform your own
transitions, you will need to parent it to the local player's
`Class.PlayerGui`. For an example of this, see the code sample below.

#### Studio Limitation

Note that this service does not work during playtesting in Roblox Studio;
to test aspects of your experience using it, you must publish the
experience and play it in the Roblox application.

**Returns:**

- `Instance` — The _customLoadingScreen_ the `Class.Players.LocalPlayer|LocalPlayer` arrived into the place with.

### `TeleportService:GetLocalPlayerTeleportData`

```
GetLocalPlayerTeleportData() -> Variant
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Teleport`

Returns the _teleportData_ the `Class.Players.LocalPlayer` arrived into
the place with.

This function returns the teleport data the `Class.Players.LocalPlayer`
arrived with. It can only be called from the client.

Exploiters can spoof teleport data. Send secure data such as player
currency through a server-side service such as `Class.DataStoreService` to
prevent tampering.

**Returns:**

- `Variant` — The teleport data the `Class.Players.LocalPlayer` arrived into the place with.

### `TeleportService:GetPlayerPlaceInstanceAsync`

```
GetPlayerPlaceInstanceAsync(userId: int64) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Teleport`

Returns the `Class.DataModel.PlaceId|PlaceId` and
`Class.DataModel.JobId|JobId` of the server the user with the given
`Class.Player.UserId|UserId` is in provided it is in the same game as the
current place.

This function returns the `Class.DataModel.PlaceId|PlaceId` and
`Class.DataModel.JobId|JobId` of the server the user with the given
`Class.Player.UserId|UserId` is in, provided it is in the same game as the
current place.

Then, `Class.TeleportService:TeleportToPlaceInstance()` can be called with
this information to allow a user to join the target user's server.

Upon a successful lookup, the function returns the following values:

<table>
	<thead>
		<tr>
			<th>#</th>
			<th>Name</th>
			<th>Type</th>
			<th>Description</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td><b>1</b></td>
   			<td> currentInstance</td>
			<td>bool</td>
			<td>A bool indicating if the user was found in the current instance</td>
		</tr>
		<tr>
			<td><b>2</b></td>
   			<td>error</td>
			<td>string</td>
			<td>An error message in the event of the lookup failing</td>
		</tr>
		<tr>
			<td><b>3</b></td>
   			<td>placeId</td>
			<td>int64</td>
			<td>The PlaceId of the server the user is in</td>
		</tr>
		<tr>
			<td><b>4</b></td>
   			<td>instanceId</td>
			<td>string</td>
			<td>The JobId of the server the user is in</td>
		</tr>
	</tbody>
</table>

If there is a problem during lookup, such as the user being offline, an
error is thrown. It is recommended that you wrap calls to this function in
`pcall`.

#### Limitations

You should be aware of the following limitations when using this function:

- This function can only be called by the server.
- This function may fail to return the correct information if the user is
  teleporting.
- It is possible for this function to throw an error, hence developers
  should wrap it in a `Global.LuaGlobals.pcall()` (see example below)
- As this function returns the JobId of the server and not the access code
  returned by `Class.TeleportService:ReserveServerAsync()`, the ID
  returned is not appropriate for use with reserved servers.

#### Studio Limitation

Note that this service does not work during playtesting in Roblox Studio;
to test aspects of your experience using it, you must publish the
experience and play it in the Roblox application.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId` of the `Class.Player`.

**Returns:**

- `Tuple` — See the table above.

### `TeleportService:GetTeleportSetting`

```
GetTeleportSetting(setting: string) -> Variant
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Teleport`

Retrieves a teleport setting saved using
`Class.TeleportService:SetTeleportSetting()` using the given key.

This function retrieves a teleport setting saved using
`Class.TeleportService:SetTeleportSetting()` using the given key.

This method is intended for use on the client only and should not be used
on the server.

Teleport settings are preserved across teleportations within the same
game. This means data can be saved using
`Class.TeleportService:SetTeleportSetting()` in one place and retrieved
using GetTeleportSetting in another place the user has been teleported to.

For example, in a game that allowed crouching you could save whether the
user is currently crouching prior to teleporting as a teleport setting.
This could then be retrieved in the destination place after the
teleportation:

```lua
local TeleportService = game:GetService("TeleportService")

local isCrouching = TeleportService:GetTeleportSetting("isCrouching")
```

If no teleport setting exists under the given key, this function will
return _nil_.

#### Differences from GlobalDataStores

Although they share some similarities, there are some key differences
between teleport settings and datastores:

- `Class.GlobalDataStore:SetAsync()` stores the data on Roblox servers
  whereas SetTeleportSetting stores the data locally
- Data stored in a `Class.GlobalDataStore` is preserved after the user
  leaves the game universe whereas teleport settings are not
- `Class.GlobalDataStore|GlobalDataStores` can only be accessed on the
  server, whereas teleport settings can only be accessed on the client
- `Class.GlobalDataStore|GlobalDataStores` have usage limits, whereas
  teleport settings do not

In general teleport settings should be used to preserve client side
information within a single play session across different places in a
game. `Class.GlobalDataStore|GlobalDataStores` should be used to save
important player data that needs to be accessed across player sessions.

#### Teleport settings and security

As teleport settings are stored locally, it is possible they can be
manipulated by malicious users. This risk can be mitigated by employing
server side validation.

#### Studio Limitation

Note that this service does not work during playtesting in Roblox Studio;
to test aspects of your experience using it, you must publish the
experience and play it in the Roblox application.

**Parameters:**

- `setting` : `string` — The key the value was stored under using `Class.TeleportService:SetTeleportSetting()`.

**Returns:**

- `Variant` — The value stored under the given key.

### `TeleportService:PromptExperienceDetailsAsync`

```
PromptExperienceDetailsAsync(player: Player, universeId: int64) -> PromptExperienceDetailsResult
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Teleport`

Prompts a `Class.Player` with information about the specified experience.
The player can choose to teleport to the target experience through the
prompt.

Prompts the specified `Class.Player` with information of the specified
experience. The prompt includes the experience name, creator name,
maturity rating, etc. The prompt also includes a **Join** button which the
player can use to be teleported to the target experience. If the player is
ineligible to join the target experience, the button will be disabled.

Any teleport failures after the player clicks the **Join** button will
also fire `Class.TeleportService.TeleportInitFailed` providing a reason
for the failure.

#### Limitations

- For security purposes, teleporting a user from your experience to
  another experience owned by others fails by default. See
  [here](../../../projects/teleport.md#enable-cross-experience-teleportation)
  for steps to enable cross-experience teleportation.
- This function currently can only be called from the client with
  `Class.Players.LocalPlayer` as the `player` parameter.
- The join button will always be disabled during Studio playtesting; to
  test aspects of your experience using it, you must publish the
  experience and play it in the Roblox application.

**Parameters:**

- `player` : `Player` — The `Class.Player` to be presented the prompt.
- `universeId` : `int64` — `Class.DataModel.UniverseId` of the experience to be presented to the `Class.Player`.

**Returns:**

- `PromptExperienceDetailsResult` — `Enum.PromptExperienceDetailsResult`

### `TeleportService:ReserveServer`

```
ReserveServer(placeId: int64) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`Teleport`

Returns an access code that can be used to teleport players to a reserved
server, along with the `Class.DataModel.PrivateServerId` for it.

**Parameters:**

- `placeId` : `int64` — The `Class.DataModel.PlaceId` of the place the reserved server is being created for.

**Returns:**

- `Tuple` — The server access code required by `Class.TeleportService:TeleportToPrivateServer()` and the `Class.DataModel.PrivateServerId` for the reserved server.

### `TeleportService:ReserveServerAsync`

```
ReserveServerAsync(placeId: int64) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Teleport`

Returns an access code that can be used to teleport players to a reserved
server, along with the `Class.DataModel.PrivateServerId` for it.

This function returns an access code that can be used to teleport players
to a reserved server, along with the server's
`Class.DataModel.PrivateServerId`. It can only be called on the server.

#### Reserved Servers

You can access reserved servers using:

- `Class.TeleportService:TeleportAsync()` with the
  `Class.TeleportOptions.ReservedServerAccessCode` parameter.
- `Class.TeleportService:TeleportToPrivateServer()`, with the access code
  `ReserveServerAsync` returns.
  - A server is started when the access code is first used.
  - Access codes remain valid indefinitely, meaning reserved servers can
    still be joined if no game server is running (in this case a new
    server will be started).

You can see if the current server is a reserved server by using the
following code:

```lua
local isReserved = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
```

The `Class.DataModel.PrivateServerId` is constant across all server
instances associated with the server access code, the
`Class.DataModel.JobId` is not.

#### Studio Limitation

Note that this service does not work during playtesting in Roblox Studio;
to test aspects of your experience using it, you must publish the
experience and play it in the Roblox application.

#### Cross-Platform Play

Players on Xbox and PlayStation with cross‑play disabled will arrive in a
different server than players with cross‑play enabled. This can cause
multiple game servers with the same
`Class.DataModel.PrivateServerId|PrivateServerId` to exist. You can use
`Class.DataModel.MatchmakingType` to differentiate these game servers.

**Parameters:**

- `placeId` : `int64` — The `Class.DataModel.PlaceId` of the place the reserved server is being created for.

**Returns:**

- `Tuple` — The server access code required by `Class.TeleportService:TeleportToPrivateServer()` and the `Class.DataModel.PrivateServerId` for the reserved server.

### `TeleportService:SetTeleportGui`

```
SetTeleportGui(gui: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `Teleport`

Sets the custom `Class.ScreenGui|teleport GUI` that will be shown to the
local user during teleportation, prior to the teleport being invoked.

This function sets the custom `Class.ScreenGui|teleport GUI` that will be
shown to the local user during teleportation, prior to the teleport being
invoked.

Note, the `Class.ScreenGui|teleport GUI` will not be used if the
destination place is in a different game. It will also not persist across
multiple teleports and will need to be set prior to each one.

This function should only be used on the client. If the teleportation
function is called from the server (as is the case with
`Class.TeleportService:TeleportAsync()`) then this function should be
called on the client prior to this. One way of doing this is listening to
a `Class.RemoteEvent` that fires several seconds before teleportation.

#### Loading screen

During a teleport, while the destination place is loading, the
_customLoadingScreen_ is parented to the `Class.CoreGui`. Once the place
has loaded the `Class.ScreenGui|loading screen` is
`Class.Instance.Parent|parented` to _nil_.

This `Class.ScreenGui` can be fetched at the destination place using
`Class.TeleportService:GetArrivingTeleportGui()`, allowing you to parent
it to the `Class.PlayerGui` and perform your own transitions.

You are advised to also `Class.Instance.Parent|parent` the
`Class.ScreenGui` to the `Class.PlayerGui` in the start place while the
teleport is initiating.

#### Studio Limitation

Note that this service does not work during playtesting in Roblox Studio;
to test aspects of your experience using it, you must publish the
experience and play it in the Roblox application.

**Parameters:**

- `gui` : `Instance` — The loading `Class.ScreenGui` that is to be displayed during teleportation.

**Returns:**

- `()` — 

### `TeleportService:SetTeleportSetting`

```
SetTeleportSetting(setting: string, value: Variant) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Teleport`

Stores a value under a given key that persists across all teleportations
in the same game.

This function stores a value under a given key that persists across all
teleportations in the same game.

This method is intended for use on the client only and should not be used
on the server.

The stored value can later be retrieved using
`Class.TeleportService:GetTeleportSetting()`. This will work in the
current place and any subsequent places the `Class.Players.LocalPlayer`
teleports to, provided they are in the same game.

For example, in a game that allowed crouching you could save whether the
user is currently crouching prior to teleporting as a teleport setting:

```lua
local TeleportService = game:GetService("TeleportService")

local isCrouching = false
TeleportService:SetTeleportSetting("isCrouching", isCrouching)
```

The stored value can take one of the following forms:

- A table without mixed keys (all strings or all integers)
- A string
- A number
- A bool

If data is already stored under the given key, the previous value will be
overwritten by the new value.

#### Differences from GlobalDataStores

Although they share some similarities, there are some key differences
between teleport settings and datastores:

- `Class.GlobalDataStore:SetAsync()` stores the data on Roblox servers
  whereas SetTeleportSetting stores the data locally
- Data stored in a `Class.GlobalDataStore` is preserved after the user
  leaves the game universe whereas teleport settings are not
- `Class.GlobalDataStore|GlobalDataStores` can only be accessed on the
  server, whereas teleport settings can only be accessed on the client
- `Class.GlobalDataStore|GlobalDataStores` have usage limits, whereas
  teleport settings do not

In general teleport settings should be used to preserve client side
information within a single play session across different places in a
game. `Class.GlobalDataStore|GlobalDataStores` should be used to save
important player data that needs to be accessed across player sessions.

#### Teleport settings and security

As teleport settings are stored locally, it is possible they can be
manipulated by malicious users. This risk can be mitigated by employing
server side validation.

#### Studio Limitation

Note that this service does not work during playtesting in Roblox Studio;
to test aspects of your experience using it, you must publish the
experience and play it in the Roblox application.

**Parameters:**

- `setting` : `string` — The key to store the _value_ under. This key can be used to retrieve the value using `Class.TeleportService:GetTeleportSetting()`.
- `value` : `Variant` — The value to store.

**Returns:**

- `()` — 

### `TeleportService:Teleport`

```
Teleport(placeId: int64, player: Instance = nil, teleportData: Variant, customLoadingScreen: Instance = nil) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `Teleport`

Teleports a `Class.Player` to the place associated with the given
`placeId`.

This method should not be used for new work; the numerous teleport
functions have been combined into a single method,
`Class.TeleportService:TeleportAsync()|TeleportAsync()`, which should be
used instead.

**Parameters:**

- `placeId` : `int64` — The ID of the place to teleport to.
- `player` : `Instance` (default `nil`) — The `Class.Player` to teleport, if this function is being called from the client this defaults to the `Class.Players.LocalPlayer`.
- `teleportData` : `Variant` — Optional data to be passed to the destination place. Can be retrieved using `Class.TeleportService:GetLocalPlayerTeleportData()`.
- `customLoadingScreen` : `Instance` (default `nil`) — Optional custom loading screen to be placed in the `Class.CoreGui` at the destination place. Can be retrieved using `Class.TeleportService:GetArrivingTeleportGui()`.

**Returns:**

- `()` — 

### `TeleportService:TeleportAsync`

```
TeleportAsync(placeId: int64, players: Instances, teleportOptions: Instance = nil) -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`UI`, `Teleport`

The all-encompassing method to teleport a player or group of players from
one server to another.

This function serves as the all-encompassing method to teleport a player
or group of players from one server to another. It can be used to:

- Teleport players to a different place.
- Teleport players to a specific server.
- Teleport players to a reserved server.

#### Group Teleport Limitations

- Groups of players can only be teleported within a single experience.
- No more than 50 players can be teleported with a single
  `Class.TeleportService:TeleportAsync()` call.

#### Potential Errors

This is a list of potential reasons a teleport may fail, ranging from
invalid teleports to network issues.

<table>
    <thead>
        <tr>
            <th>Error</th>
           	<th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Invalid placeId</td>
            <td>The provided place ID is below 0.</td>
        </tr>
        <tr>
            <td>Players empty</td>
            <td>The provided list of players to teleport is empty.</td>
        </tr>
        <tr>
            <td>List of players instances is incorrect</td>
            <td>Any of the provided players is not a Player object.</td>
        </tr>
        <tr>
            <td>TeleportOptions not of correct type</td>
            <td>The provided teleportOption is not a TeleportOptions object.</td>
        </tr>
        <tr>
            <td>TeleportAsync called from Client</td>
            <td>The client called TeleportAsync, which can only be called from the server.</td>
        </tr>
        <tr>
            <td>Incompatible Parameters</td>
            <td>
              Conflicting teleport options were used and TeleportService doesn't know where to send the player.<br><br>
              Conflicting TeleportOption parameters:<br>
               * ReservedServerAccessCode and ServerInstanceId<br>
               * ShouldReserveServer and ServerInstanceId<br>
               * ShouldReserveServer and ReservedServerAccessCode
            </td>
        </tr>
    </tbody>
</table>

For more information on how to teleport players between servers and
receive user data from a teleport, see
[Teleport between places](../../../projects/teleport.md#sending-user-data-along-with-teleports).

**Parameters:**

- `placeId` : `int64` — The place ID the player(s) should be teleported to.
- `players` : `Instances` — An array of the player(s) to teleport.
- `teleportOptions` : `Instance` (default `nil`) — An optional `Class.TeleportOptions` object containing additional arguments to the `Class.TeleportService:TeleportAsync()` call. If this is not passed, no result will be returned.

**Returns:**

- `Instance` — If a `Class.TeleportOptions` parameter is passed, this will be a `Class.TeleportAsyncResult` object that provides information about the final teleport destination.

### `TeleportService:TeleportPartyAsync`

```
TeleportPartyAsync(placeId: int64, players: Instances, teleportData: Variant, customLoadingScreen: Instance = nil) -> string
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`UI`, `Teleport`

Teleports a group of `Class.Player|Players` to the same server of the
place with the given `Class.DataModel.PlaceId|PlaceId`, returning the
`Class.DataModel.JobId|JobId` of the server instance they were teleported
to.

This method should not be used for new work; the numerous teleport
functions have been combined into a single method,
`Class.TeleportService:TeleportAsync()|TeleportAsync()`, which should be
used instead.

**Parameters:**

- `placeId` : `int64` — The ID of the place to teleport to.
- `players` : `Instances` — An array containing the `Class.Player|Players` to teleport.
- `teleportData` : `Variant` — Optional data to be passed to the destination place. Can be retrieved using `Class.TeleportService:GetLocalPlayerTeleportData()`.
- `customLoadingScreen` : `Instance` (default `nil`) — Optional custom loading screen to be placed in the `Class.CoreGui` at the destination place. Can be retrieved using `Class.TeleportService:GetArrivingTeleportGui()`.

**Returns:**

- `string` — The `Class.DataModel.JobId` of the server instance the `Class.Player|Players` were teleported to.

### `TeleportService:TeleportToPlaceInstance`

```
TeleportToPlaceInstance(placeId: int64, instanceId: string, player: Instance = nil, spawnName: string, teleportData: Variant, customLoadingScreen: Instance = nil) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `Teleport`

Teleports a `Class.Player` to the server instance associated with the
given _placeId_ and _instanceId_.

This method should not be used for new work; the numerous teleport
functions have been combined into a single method,
`Class.TeleportService:TeleportAsync()|TeleportAsync()`, which should be
used instead.

**Parameters:**

- `placeId` : `int64` — The ID of the place to teleport to.
- `instanceId` : `string` — The `Class.DataModel.JobId` of the server instance to teleport to.
- `player` : `Instance` (default `nil`) — The `Class.Player` to teleport, if this function is being called from the client this defaults to the `Class.Players.LocalPlayer`.
- `spawnName` : `string` — Optional name of the `Class.SpawnLocation` to spawn at.
- `teleportData` : `Variant` — Optional data to be passed to the destination place. Can be retrieved using `Class.TeleportService:GetLocalPlayerTeleportData()`.
- `customLoadingScreen` : `Instance` (default `nil`) — Optional custom loading screen to be placed in the `Class.CoreGui` at the destination place. Can be retrieved using `Class.TeleportService:GetArrivingTeleportGui()`.

**Returns:**

- `()` — 

### `TeleportService:TeleportToPrivateServer`

```
TeleportToPrivateServer(placeId: int64, reservedServerAccessCode: string, players: Instances, spawnName: string, teleportData: Variant, customLoadingScreen: Instance = nil) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `Teleport`

Teleport a group of `Class.Player|Players` to a reserved server created
using `Class.TeleportService:ReserveServerAsync()`.

This method should not be used for new work; the numerous teleport
functions have been combined into a single method,
`Class.TeleportService:TeleportAsync()|TeleportAsync()`, which should be
used instead.

**Parameters:**

- `placeId` : `int64` — The ID of the place to teleport to.
- `reservedServerAccessCode` : `string` — The reserved server access code returned by `Class.TeleportService:ReserveServerAsync()`.
- `players` : `Instances` — An array of `Class.Player|Players` to teleport.
- `spawnName` : `string` — Optional name of the `Class.SpawnLocation` to spawn at.
- `teleportData` : `Variant` — Optional data to be passed to the destination place. Can be retrieved using `Class.TeleportService:GetLocalPlayerTeleportData()`.
- `customLoadingScreen` : `Instance` (default `nil`) — Optional custom loading screen to be placed in the `Class.CoreGui` at the destination place. Can be retrieved using `Class.TeleportService:GetArrivingTeleportGui()`.

**Returns:**

- `()` — 

### `TeleportService:TeleportToSpawnByName`

```
TeleportToSpawnByName(placeId: int64, spawnName: string, player: Instance = nil, teleportData: Variant, customLoadingScreen: Instance = nil) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `Teleport`

A variant of `Class.TeleportService:Teleport()` that causes the
`Class.Player` to spawn at a `Class.SpawnLocation` of the given name at
the destination place.

This method should not be used for new work; the numerous teleport
functions have been combined into a single method,
`Class.TeleportService:TeleportAsync()|TeleportAsync()`, which should be
used instead.

**Parameters:**

- `placeId` : `int64` — The ID of the place to teleport to.
- `spawnName` : `string` — The name of the `Class.SpawnLocation` to spawn at.
- `player` : `Instance` (default `nil`) — The `Class.Player` to teleport, if this function is being called from the client this defaults to the `Class.Players.LocalPlayer`.
- `teleportData` : `Variant` — Optional data to be passed to the destination place. Can be retrieved using `Class.TeleportService:GetLocalPlayerTeleportData()`.
- `customLoadingScreen` : `Instance` (default `nil`) — Optional custom loading screen to be placed in the `Class.CoreGui` at the destination place. Can be retrieved using `Class.TeleportService:GetArrivingTeleportGui()`.

**Returns:**

- `()` — 

## Events

### `TeleportService.LocalPlayerArrivedFromTeleport`

```
LocalPlayerArrivedFromTeleport(loadingGui: Instance, dataTable: Variant)
```

- security=`None` ; capabilities=`Teleport`

Fires when the `Class.Players.LocalPlayer|LocalPlayer` enters the place
following a teleport.

This function fires when the `Class.Players.LocalPlayer` enters the place
following a teleport. The `teleportData` and `customLoadingScreen` are
provided as arguments.

When fetching _teleportData_ and the _customLoadingScreen_ you are advised
to use `Class.TeleportService:GetLocalPlayerTeleportData()` and
`Class.TeleportService:GetArrivingTeleportGui()` instead. This is because
these functions can be called immediately without having to wait for this
event to fire.

This event should be connected immediately in a `Class.LocalScript`
parented to `Class.ReplicatedFirst`. Otherwise, when the connection is
made the event may have already fired.

#### Loading Screen

During a teleport, while the destination place is loading, the
_customLoadingScreen_ is parented to the `Class.CoreGui`. Once the place
has loaded the `Class.ScreenGui|loading screen` is
`Class.Instance.Parent|parented` to _nil_.

If you wish to preserve the _customLoadingScreen_ and perform your own
transitions, you will need to parent it to the local player's
`Class.PlayerGui`. For example, using the following code inside a
`Class.LocalScript` in `Class.ReplicatedFirst`:

```lua
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

TeleportService.LocalPlayerArrivedFromTeleport:Connect(function(customLoadingScreen, teleportData)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	ReplicatedFirst:RemoveDefaultLoadingScreen()

	customLoadingScreen.Parent = playerGui
	-- animate screen here
	wait(5)
	-- destroy screen
	customLoadingScreen:Destroy()
end)
```

The _customLoadingScreen_ will not be used if the destination place is in
a different game.

#### Studio Limitation

Note that this service does not work during playtesting in Roblox Studio;
to test aspects of your experience using it, you must publish the
experience and play it in the Roblox application.

**Parameters:**

- `loadingGui` : `Instance` — The _customLoadingScreen_ the `Class.Players.LocalPlayer|LocalPlayer` arrived into the place with.
- `dataTable` : `Variant` — The _teleportData_ the `Class.Players.LocalPlayer|LocalPlayer` arrived into the place with.

### `TeleportService.TeleportInitFailed`

```
TeleportInitFailed(player: Instance, teleportResult: TeleportResult, errorMessage: string, placeId: int64, teleportOptions: Instance)
```

- security=`None` ; capabilities=`Teleport`

Fires when a teleport fails to start, leaving the player in their current
server.

This event fires on both the client and the server when a request to
teleport from a function such as `Class.TeleportService:TeleportAsync()`
fails and the player does not leave the current server. It provides a
reason for the failure, as well as all of the information necessary to
retry the teleport. If a group teleport fails, the event will fire once
per player.

#### TeleportOptions

The `Class.TeleportOptions` object provided by this event is not identical
to the one passed to the original `Class.TeleportService:TeleportAsync()`
call. It is a new object populated with the necessary parameters to retry
the teleport and send the player to the exact same destination. This is
especially important for facilitating group teleports when they fail.

<table>
    <thead>
        <tr>
            <th>Original Teleport Type</th>
	          <th>Teleport Data</th>
	          <th>ReservedServerAccessCode</th>
	          <th>ServerInstanceId</th>
	          <th>ShouldReserveServer</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Individual player to place</td>
            <td>Original value</td>
            <td>None</td>
            <td>None</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Player(s) to reserved server</td>
            <td>Original value</td>
            <td>Original value, or the code generated if ShouldReserveServer was originally true</td>
            <td>None</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Player(s) to specific server</td>
            <td>Original value</td>
            <td>None</td>
            <td>Original value</td>
            <td>false</td>
        </tr>
        <tr>
            <td>Players to place</td>
            <td>Original value</td>
            <td>None</td>
            <td>Same destination ID as the other players in the original teleport</td>
            <td>false</td>
        </tr>
    </tbody>
</table>

For more information on how to teleport players between servers, see
[Teleport between places](../../../projects/teleport.md).

**Parameters:**

- `player` : `Instance` — The `Class.Player` instance that failed to teleport.
- `teleportResult` : `TeleportResult` — The reason for the teleport failure.
- `errorMessage` : `string` — The message provided to the player explaining the teleport failure.
- `placeId` : `int64` — The original target place ID of the teleport.
- `teleportOptions` : `Instance` — A `Class.TeleportOptions` object that can be passed back to `Class.TeleportService:TeleportAsync()` to retry the failed teleport.

## Notes / Deprecations

- Deprecated property `TeleportService.CustomizedTeleportUI`: This item is deprecated since the default message it controls has been
removed. Do not use it for new work.
- Property `TeleportService.CustomizedTeleportUI` security: `read=None, write=None`
- Method `TeleportService:GetPlayerPlaceInstanceAsync` yields (tag `Yields`).
- Method `TeleportService:PromptExperienceDetailsAsync` yields (tag `Yields`).
- Method `TeleportService:ReserveServer` yields (tag `Yields`).
- Method `TeleportService:ReserveServerAsync` yields (tag `Yields`).
- Method `TeleportService:TeleportAsync` yields (tag `Yields`).
- Method `TeleportService:TeleportPartyAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- TeleportService:GetArrivingTeleportGui: handling-a-teleport-loading-gui
- TeleportService:GetLocalPlayerTeleportData: getting-LocalPlayer-teleport-data
- TeleportService:GetPlayerPlaceInstanceAsync: following-a-player-in-a-universe
- TeleportService:PromptExperienceDetailsAsync: present-experience-details-page
- TeleportService:ReserveServer: TeleportService-ReserveServer1
- TeleportService:ReserveServer: teleportservice-teleport-to-a-reserved-server-via-chat
- TeleportService:ReserveServerAsync: TeleportService-ReserveServer1
- TeleportService:ReserveServerAsync: teleportservice-teleport-to-a-reserved-server-via-chat
- TeleportService:SetTeleportGui: teleporting-the-local-player
- TeleportService:Teleport: teleporting-the-local-player
- TeleportService:Teleport: teleporting-from-the-server
- TeleportService:TeleportPartyAsync: teleport-all-players-in-the-server
- TeleportService:TeleportToPlaceInstance: following-a-player-in-a-universe
- TeleportService:TeleportToPrivateServer: teleportservice-teleport-to-a-reserved-server-via-chat
- TeleportService:TeleportToPrivateServer: TeleportService-ReserveServer1
- TeleportService:TeleportToSpawnByName: TeleportService-TeleportToSpawnByName1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/TeleportService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TeleportService.yaml
- Captured: 2026-04-16
