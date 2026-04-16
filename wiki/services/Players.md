---
title: Players
type: service
category: services
subcategory: players
owner: luau-gameplay-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/Players.md
related:
  - "[[Player]]"
  - "[[session-locking]]"
  - "[[DataStoreService]]"
tags: [roblox-class, players]
---

# Players

> The service that contains all presently connected Player objects. [[Player]]

## Summary

The Players service contains [[Player]] objects for every client currently connected to a server. It also exposes utility methods for looking up players by UserId or character model, fetching player information (names, thumbnails, friends), and controlling character spawning behavior.

`PlayerAdded` and `PlayerRemoving` are the canonical lifecycle hooks for player management. They drive data loading/saving, session locking, team assignment, and any per-player initialization. `PlayerRemoving` fires just before the Player object is removed -- this is where you save data, not in `ChildRemoved`.

The `CharacterAutoLoads` property controls whether characters spawn automatically. When set to false, you must call `Player:LoadCharacter()` manually -- useful for lobby systems, round-based games, or custom spawn sequences.

## API Surface

### Properties

- `LocalPlayer: Player?` -- The Player object for the local client. Only available in LocalScripts; nil on the server.
- `CharacterAutoLoads: boolean` -- Whether characters auto-spawn. Default true. Set to false for manual spawn control.
- `MaxPlayers: number` -- Maximum players allowed in the server (read-only).
- `PreferredPlayers: number` -- Target player count for matchmaking (read-only).
- `RespawnTime: number` -- Seconds between death and respawn. Default 5.
- `BubbleChat: boolean` -- Whether bubble chat is enabled (read-only).
- `ClassicChat: boolean` -- Whether classic chat is enabled (read-only).

### Methods (key subset)

- `:GetPlayers() -> {Player}` -- Returns an array of all connected players. Use this instead of `:GetChildren()`.
- `:GetPlayerByUserId(userId: number) -> Player?` -- Returns the Player with the given UserId, or nil if not connected.
- `:GetPlayerFromCharacter(character: Model) -> Player?` -- Returns the Player whose Character is the given model, or nil.
- `:GetNameFromUserIdAsync(userId: number) -> string` -- Looks up a username by UserId. Yields. Works for offline players.
- `:GetUserIdFromNameAsync(name: string) -> number` -- Looks up a UserId by username. Yields. Works for offline players.
- `:GetUserThumbnailAsync(userId: number, thumbnailType: Enum.ThumbnailType, thumbnailSize: Enum.ThumbnailSize) -> (string, boolean)` -- Returns the thumbnail URL and whether it's ready. Yields.
- `:GetFriendsAsync(userId: number) -> FriendPages` -- Returns a paginated list of a player's friends. Yields.
- `:GetHumanoidDescriptionFromUserIdAsync(userId: number) -> HumanoidDescription` -- Returns the avatar description for a user. Yields.
- `:BanAsync(config: Dictionary) -> ()` -- Bans a player. Requires BanningEnabled. Yields.
- `:UnbanAsync(config: Dictionary) -> ()` -- Unbans a player. Requires BanningEnabled. Yields.
- `:GetBanHistoryAsync(userId: number) -> Pages` -- Returns ban history. Requires BanningEnabled. Yields.

### Events

- `.PlayerAdded:Connect(fn(player: Player))` -- Fires when a player joins the server. The canonical hook for data loading and initialization.
- `.PlayerRemoving:Connect(fn(player: Player))` -- Fires just before a player is removed. The canonical hook for data saving.
- `.PlayerMembershipChanged:Connect(fn(player: Player))` -- Fires when a player's Premium membership status changes during the session.
- `.UserSubscriptionStatusChanged:Connect(fn(player: Player, subscriptionId: string))` -- Fires when a player's subscription status changes.

## Budgets and Limits

- `GetNameFromUserIdAsync` and `GetUserIdFromNameAsync` are web API calls -- results are cached but initial calls yield.
- `BanAsync`/`UnbanAsync` require the `BanningEnabled` property to be toggled in Studio.
- `GetFriendsAsync` returns paginated results -- iterate pages carefully.

## Common Patterns

### Player lifecycle with data loading

```lua
local Players = game:GetService("Players")

local function onPlayerAdded(player: Player)
    -- Load data from DataStore
    local data = loadPlayerData(player.UserId)
    -- Set up player state
    setupPlayer(player, data)
end

local function onPlayerRemoving(player: Player)
    -- Save data before player is removed
    savePlayerData(player.UserId)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players who joined before this script connected
for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end
```

### Finding which player a character belongs to

```lua
local function onPartTouched(hit: BasePart)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if player then
        print(player.Name, "touched the part")
    end
end
```

## Pitfalls

- **Race condition on PlayerAdded**: Scripts may run after players have already joined. Always iterate `GetPlayers()` in addition to connecting `PlayerAdded`.
- **PlayerRemoving vs ChildRemoved**: Use `PlayerRemoving` (fires before removal) for saving data. `ChildRemoved` fires after the Player is already gone.
- **LocalPlayer is nil on server**: `Players.LocalPlayer` only works in LocalScripts. Accessing it from a server script returns nil.
- **GetPlayerByUserId returns nil**: If the player is not currently connected, this returns nil. It does not look up offline players.
- **CharacterAutoLoads = false**: When disabled, you must manually call `Player:LoadCharacter()`. Forgetting to do so means players see a black screen forever.

## Related

- [[Player]] -- individual player instance
- [[session-locking]] -- preventing data duplication across servers
- [[DataStoreService]] -- saving/loading player data

## Sources

- [wiki/raw/roblox-creator-docs/services/Players.md](../raw/roblox-creator-docs/services/Players.md)
