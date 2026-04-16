---
title: TextChatService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/TextChatService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TextChatService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: chat
tags: [roblox-class, chat, text, service]
---

# TextChatService

A service handling in-experience text chat.

## Description

A service handling in-experience text chat, including managing
`Class.TextChannel|TextChannels`, decorating messages, filtering text,
creating `Class.TextChatCommand|TextChatCommands`, and
[developing custom chats interfaces](../../../chat/examples/simple-custom-frontend-ui.md).
To learn more, see
[text chat overview](../../../chat/in-experience-text-chat.md).

For further customization, `TextChatService` has the following singleton
children:

- `Class.ChatWindowConfiguration`
- `Class.ChatInputBarConfiguration`
- `Class.BubbleChatConfiguration`
- `Class.ChannelTabsConfiguration`

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

### `TextChatService.ChatTranslationEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Chat`

Determines whether a user has chat translation enabled.

Determines whether a user has chat translation enabled. If `true`,
messages the user receives will be translated into their preferred
language. Use `Class.TextChatMessage.Translation` to get the message
translation.

### `TextChatService.ChatVersion`

- **Type:** `ChatVersion`
- **Security:** `read=None, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Chat`
- **Deprecated:** This property has been deprecated in newly created Studio experiences.
`TextChatService` is the only allowed chat system and is automatically
enabled.

Determines whether to fully enable `Class.TextChatService` or revert to
the legacy chat system.

Determines whether to fully enable `Class.TextChatService` or revert to
the legacy chat system. Setting this property to
`Enum.ChatVersion.LegacyChatService` effectively disables
`Class.TextChatService`.

### `TextChatService.CreateDefaultCommands`

- **Type:** `boolean`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Chat`

Determines whether `Class.TextChatService` should create default
`Class.TextChatCommand|TextChatCommands`.

Determines whether `Class.TextChatService` should create default
`Class.TextChatCommand|TextChatCommands`. If `true`, the following
`Class.TextChatCommand|TextChatCommands` are created and put in a
`Class.Folder` named **TextChatCommands** inside `Class.TextChatService`:

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Primary Alias</th>
      <th>Secondary Alias</th>
      <th>Description</th>
      <th>Usage Example</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>RBXClearCommand</b></td>
      <td>clear</td>
      <td>cls</td>
      <td>Clears the chat log for the local user.</td>
      <td><code>/cls</code></td>
    </tr>
    <tr>
      <td><b>RBXConsoleCommand</b></td>
      <td>console</td>
      <td></td>
      <td>Opens the Developer Console.</td>
      <td><code>/console</code></td>
    </tr>
    <tr>
      <td><b>RBXEmoteCommand</b></td>
      <td>emote</td>
      <td>e</td>
      <td>Plays an avatar emote.</td>
      <td><code>/e dance</code></td>
    </tr>
    <tr>
      <td><b>RBXHelpCommand</b></td>
      <td>help</td>
      <td>?</td>
      <td>Shows a list of chat commands.</td>
      <td><code>/help</code></td>
    </tr>
    <tr>
      <td><b>RBXMuteCommand</b></td>
      <td>mute</td>
      <td>m</td>
      <td>Mutes a user by their <code>Class.Player.Name|Name</code> or <code>Class.Player.DisplayName|DisplayName</code> in all <code>Class.TextChannel|TextChannels</code>.</td>
      <td><code>/m Username</code></td>
    </tr>
    <tr>
      <td><b>RBXTeamCommand</b></td>
      <td>team</td>
      <td>t</td>
      <td>Enters team chat mode where messages are only visible to teammates.</td>
      <td><code>/t</code></td>
    </tr>
    <tr>
      <td><b>RBXUnmuteCommand</b></td>
      <td>unmute</td>
      <td>um</td>
      <td>Unmutes a user by their <code>Class.Player.Name|Name</code> or <code>Class.Player.DisplayName|DisplayName</code> in all <code>Class.TextChannel|TextChannels</code>.</td>
      <td><code>/um Username</code></td>
    </tr>
    <tr>
      <td><b>RBXVersionCommand</b></td>
      <td>version</td>
      <td>v</td>
      <td>Shows the chat version.</td>
      <td><code>/version</code></td>
    </tr>
    <tr>
      <td><b>RBXWhisperCommand</b></td>
      <td>whisper</td>
      <td>w</td>
      <td>Enters whisper mode with another <code>Class.Player</code>.</td>
      <td><code>/w DisplayName</code> or <code>/w @Username</code></td>
    </tr>
  </tbody>
</table>

Note that you can edit, create, and remove
`Class.TextChatCommand|TextChatCommands` even if
`Class.TextChatService.CreateDefaultCommands|CreateDefaultCommands` is
`true`. Also note that mute and unmute commands apply to all
`Class.TextChannel|TextChannels`.

### `TextChatService.CreateDefaultTextChannels`

- **Type:** `boolean`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Chat`

Determines whether `Class.TextChatService` should create default
`Class.TextChannel|TextChannels`.

Determines whether `Class.TextChatService` should create default
`Class.TextChannel|TextChannels`. If `true`, a `Class.Folder` named
**TextChannels** is created inside `Class.TextChatService` at runtime to
contain the `Class.TextChannel|TextChannels` outlined in the table below.
Each of the default channels has the described special behavior applied to
messages using its internally bound `Class.TextChannel.OnIncomingMessage`
callback function, changing how messages appear when sent through the
channel. The callback is assigned automatically either at runtime (if the
`Class.TextChannel` exists) or when the `Class.TextChannel` is created.

<table>
  <thead>
    <tr>
      <th>Channel</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>RBXGeneral</b></td>
      <td><code>Class.TextChannel</code> for player messages. In the chat window, messages are modified such that <code>Class.TextChatMessage.PrefixText|PrefixText</code> receives a <a href="../../../ui/rich-text.md">rich text</a> font color tag to give chatting players their distinctive name color. If <code>Class.Player.Team</code> exists, that <code>Class.Team.TeamColor</code> is used instead of the default name color.</td>
    </tr>
    <tr>
      <td><b>RBXSystem</b></td>
      <td><code>Class.TextChannel</code> for system messages. In the chat window, messages are modified such that <code>Class.TextChatMessage.Text</code> is given a light grey color tag by default, or a red color tag if <code>Class.TextChatMessage.Metadata</code> contains the word <code>"Error"</code>.</td>
    </tr>
    <tr>
      <td><b>RBXTeam[BrickColor]</b></td>
      <td><code>Class.TextChannel</code> for team-specific player messages, created when a <code>Class.Team.TeamColor|TeamColor</code> is in use by any <code>Class.Team</code> within the <code>Class.Teams</code> service. Name of the created channel is <b>RBXTeam</b> followed by the <code>Class.Team.TeamColor|TeamColor</code> name. For example, <b>RBXTeamCrimson</b> is a <code>Class.TextChannel</code> created when there is an active team whose <code>Class.Team.TeamColor|TeamColor</code> property is the "Crimson" <code>Datatype.BrickColor</code>.<br /><br />In the chat window, messages are modified such that <code>Class.TextChatMessage.PrefixText|PrefixText</code> is colored according to the <code>Class.Player.TeamColor|TeamColor</code> and is prepended with <b>[Team]</b>.<br /><br />Team channels create <code>Class.TextSource|TextSources</code> for all non‑<code>Class.Player.Neutral|Neutral</code> players with the matching <code>Class.Team.TeamColor|TeamColor</code>, allowing them to use team‑only chat. Channels are removed if there are no remaining teams with an associated <code>Class.Team.TeamColor|TeamColor</code>.</td>
    </tr>
    <tr>
      <td><b>RBXWhisper:[UserId1]_[UserId2]</b></td>
      <td><code>Class.TextChannel</code> for whisper messages between two players, created when a player uses the <code>/whisper</code> command on another player. For example <b>RBXWhisper:2276836_505306092</b> is a <code>Class.TextChannel</code> for players with <code>Class.Player.UserId|UserIds</code> <b>2276836</b> and <b>505306092</b>. Inside whisper channels are two <code>Class.TextSource|TextSources</code> associated with the respective <code>Class.Player.UserId|UserIds</code>.<br /><br />In the chat window, messages are colored the same as those in <b>RBXGeneral</b> and <code>Class.TextChatMessage.PrefixText</code> is modified to show whether a message was sent from or received by the local user.<br /><br />Whisper channels are removed when either player leaves the experience.</td>
    </tr>
  </tbody>
</table>

Note that the default `Class.TextChannel.OnIncomingMessage` callbacks can
be overwritten. Also note that you can edit, create, and remove
`Class.TextChannel|TextChannels` even if
`Class.TextChatService.CreateDefaultTextChannels|CreateDefaultTextChannels`
is `true`.

Messages from different TextChannels can be separated into different tabs
in the chat window using `Class.ChannelTabsConfiguration`.

## Methods

### `TextChatService:CanUserChatAsync`

```
CanUserChatAsync(userId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Chat`

Determines whether a user has permission to chat in experiences.

Determines whether a user has permission to chat in experiences. Factors
such as parental control settings may prevent the user from sending
messages. Errors if the `userId` is not in the current server. Note that
this method can be used with all current player
`Class.Player.UserId|UserIds` in a `Class.Script` with
`Class.Script.RunContext|RunContext` of `Enum.RunContext.Server` or
`Enum.RunContext.Legacy`. This method can also be used in a
`Class.LocalScript` but only with the `Class.Player.UserId|UserId` of the
local player.

**Parameters:**

- `userId` : `int64` — 

**Returns:**

- `boolean` — 

### `TextChatService:CanUsersChatAsync`

```
CanUsersChatAsync(userIdFrom: int64, userIdTo: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Chat`

Determines whether or not two users can receive messages from each other.

Determines whether or not two users can receive messages from each other.
Both users must be in the current server, otherwise an error will occur.

Factors such as incompatible parental control settings or blocked status
may prevent the delivery of messages between users
(`Class.TextChannel|TextChannels` internally use this result to determine
whether to deliver messages between users). Note that this method is only
available for use in a `Class.Script` with
`Class.Script.RunContext|RunContext` of `Enum.RunContext.Server` or
`Enum.RunContext.Legacy`.

**Parameters:**

- `userIdFrom` : `int64` — 
- `userIdTo` : `int64` — 

**Returns:**

- `boolean` — 

### `TextChatService:CanUsersDirectChatAsync`

```
CanUsersDirectChatAsync(requesterUserId: int64, userIds: Array) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Chat`

Determines whether a user has permission to chat directly with other users
in experiences based on factors such as their parental control settings.

Determines whether a user has permission to chat directly with other users
in experiences based on their parental control settings, such as a whisper
channel between two users. To be used when:

- The line of communication is user-initiated (not developer- or
  gameplay-initiated).
- Access to the communication is closed and limited.

You may use this method to gate certain features in your experience
depending on the result.

When creating a `Class.TextChannel` for a direct chat, use
`Class.TextChannel:SetDirectChatRequester` to set the `requesterUserId` so
that the channel can determine whether to deliver messages between users.
When `Class.TextChannel.DirectChatRequester` is non-`nil`,
`Class.TextChannel|TextChannels` internally use this result to determine
whether to deliver messages between users.

Note that this method is only available for use in a `Class.Script` with
`Class.Script.RunContext|RunContext` of `Enum.RunContext.Server` or
`Enum.RunContext.Legacy`.

**Parameters:**

- `requesterUserId` : `int64` — The user who would have initiated the direct chat request. If the user is not in the current server, this method will error.
- `userIds` : `Array` — A list of users who the `requesterUserId` would like to chat with directly. Users not in the current server are ignored.

**Returns:**

- `Array` — A list of users who could participate in the direct chat request. If none of the users can direct chat with the `requesterUserId`, the result is an empty array.

### `TextChatService:DisplayBubble`

```
DisplayBubble(partOrCharacter: Instance, message: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Chat`

Displays a chat bubble above the provided part or player character.

Displays a chat bubble above the provided part or player character, and
fires the `Class.TextChatService.BubbleDisplayed|BubbleDisplayed` event
with the parameters specified in this method. Can display bubbles for
non-player characters (NPCs) if you specify a part within the character,
such as its head.

Note that this method is only available for use in `Class.LocalScript`, or
in a `Class.Script` with `Class.Script.RunContext|RunContext` of
`Enum.RunContext.Client`.

**Parameters:**

- `partOrCharacter` : `Instance` — The part or character that the bubble to be displayed above.
- `message` : `string` — The text to be displayed in the chat bubble.

**Returns:**

- `()` — 

### `TextChatService:GetChatGroupsAsync`

```
GetChatGroupsAsync(players: Instances) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Chat`

Returns chat group IDs that indicate which players can synchronously text
chat together.

Returns a sorted array of arrays of chat group IDs for the given players.
Each chat group ID is a string that represents a communication-compatible
group within the current universe.

If two or more players share the same chat group ID, those players are
able to synchronously text chat with each other based on their age-check
status and chat settings.

This method is server-side only and intended for real-time use cases such
as matchmaking and teleporting. Chat group IDs are unique to the current
universe, may change over time, and should not be stored once the user has
left the experience. While you can hold onto the data returned for the
purposes of gameplay while the user is in the experience, this data should
not be stored after they've left.

To use this method, you must enable **Chat & Voice Groups APIs** in
**Experience Settings** ⟩ **Communication** in Roblox Studio and agree to
the Roblox Terms of Use.

In Roblox Studio this API is only available when the experience is running
in **Team Test**.

```lua
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local players = Players:GetPlayers()

local success, chatGroups = pcall(function()
  return TextChatService:GetChatGroupsAsync(players)
end)

if not success then
  warn("Failed to retrieve chat groups")
  return
end

for _, group in ipairs(chatGroups) do
  -- Each group contains chat group ID strings.
  -- Players who share a matching group ID can chat with each other.
  for _, groupId in ipairs(group) do
    print("Chat group ID:", groupId)
  end
end
```

**Parameters:**

- `players` : `Instances` — A list of `Class.Player|Players` currently in the experience to evaluate for text chat compatibility.

**Returns:**

- `Array` — A sorted array of arrays of chat group ID strings. Players who share a matching chat group ID are eligible to synchronously text chat with each other.

## Events

### `TextChatService.BubbleDisplayed`

```
BubbleDisplayed(partOrCharacter: Instance, textChatMessage: TextChatMessage)
```

- security=`None` ; capabilities=`Chat`

Fires when `Class.TextChatService:DisplayBubble()` is called.

**Parameters:**

- `partOrCharacter` : `Instance` — 
- `textChatMessage` : `TextChatMessage` — 

### `TextChatService.MessageReceived`

```
MessageReceived(textChatMessage: TextChatMessage)
```

- security=`None` ; capabilities=`Chat`

Fires when `Class.TextChannel:DisplaySystemMessage()` is invoked on the
client, or when the client receives a valid
`Class.TextChannel:SendAsync()` response from the server.

Like `Class.TextChannel.MessageReceived`, fires when
`Class.TextChannel:DisplaySystemMessage()` is invoked on the client, or
when the client receives a valid `Class.TextChannel:SendAsync()` response
from the server. This event is only fired on the client.

If the server's `Class.TextChannel.ShouldDeliverCallback` property is
bound and returns `false`, the client will not fire
`Class.TextChatService.MessageReceived`.

Use the `Class.TextChatMessage` parameter to get the `Class.TextSource`
and the text of the message (with `Class.TextChatMessage.Text`).

The `Class.TextChatMessage` parameter is the final result of any functions
bound to `Class.TextChatService.OnIncomingMessage` or
`Class.TextChannel.OnIncomingMessage`.

**Parameters:**

- `textChatMessage` : `TextChatMessage` — The received `Class.TextChatMessage`.

### `TextChatService.SendingMessage`

```
SendingMessage(textChatMessage: TextChatMessage)
```

- security=`None` ; capabilities=`Chat`

Fires when `Class.TextChannel:SendAsync()` is called by the sending
client.

Fires when `Class.TextChannel:SendAsync()` is called by the sending
client. Use this to allow placeholder messages to be shown to the user
while waiting for server response to `Class.TextChannel:SendAsync()`.

**Parameters:**

- `textChatMessage` : `TextChatMessage` — The `Class.TextChatMessage` from the `Class.TextChannel:SendAsync()` call.

## Notes / Deprecations

- Deprecated property `TextChatService.ChatVersion`: This property has been deprecated in newly created Studio experiences.
`TextChatService` is the only allowed chat system and is automatically
enabled.
- Property `TextChatService.ChatTranslationEnabled` security: `read=None, write=RobloxScriptSecurity`
- Property `TextChatService.ChatVersion` security: `read=None, write=RobloxScriptSecurity`
- Property `TextChatService.CreateDefaultCommands` security: `read=None, write=PluginSecurity`
- Property `TextChatService.CreateDefaultTextChannels` security: `read=None, write=PluginSecurity`
- Method `TextChatService:CanUserChatAsync` yields (tag `Yields`).
- Method `TextChatService:CanUsersChatAsync` yields (tag `Yields`).
- Method `TextChatService:CanUsersDirectChatAsync` yields (tag `Yields`).
- Method `TextChatService:GetChatGroupsAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- TextChatService:CanUsersDirectChatAsync: TextChatService-User-Chat
- TextChatService:GetChatGroupsAsync: TextChatService-Chat-Groups-Teleport

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/TextChatService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TextChatService.yaml
- Captured: 2026-04-16
