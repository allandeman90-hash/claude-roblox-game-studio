---
title: Player
type: service
category: services
subcategory: players
owner: luau-gameplay-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/Player.md
related:
  - "[[Players]]"
  - "[[Humanoid]]"
  - "[[DataStoreService]]"
tags: [roblox-class, players]
---

# Player

> Represents a presently connected client in the experience. [[Players]]

## Summary

A Player object is created when a client connects to the server and is added to the [[Players]] service. It is removed when the player disconnects. The `Name` property reflects the player's username, but for persistent data you must use `UserId` since usernames can change.

The Player object bridges many systems: it holds the reference to the player's `Character` model (the 3D avatar in the world), camera settings, team assignment, device input modes, and more. Core lifecycle events like `CharacterAdded` and `CharacterRemoving` fire on this object and are essential for setting up per-character logic (health bars, animations, tools).

Always use `Players:GetPlayers()` instead of `Players:GetChildren()`, and use `Players.PlayerAdded`/`Players.PlayerRemoving` instead of `ChildAdded`/`ChildRemoved` on the Players service. `PlayerRemoving` fires just **before** the Player is removed, giving you time to save data.

## API Surface

### Properties (key subset)

- `UserId: number` -- Unique, stable numeric identifier. Use this as the DataStore key, never `Name`.
- `Name: string` -- The player's username. Can change over time.
- `DisplayName: string` -- The player's display name (may differ from username).
- `Character: Model?` -- The player's character model in the Workspace. Nil before first spawn.
- `Team: Team?` -- The player's current Team assignment.
- `TeamColor: BrickColor` -- The player's team color.
- `MembershipType: Enum.MembershipType` -- Whether the player has a Roblox Premium subscription.
- `AccountAge: number` -- Account age in days (read-only).
- `LocaleId: string` -- The player's locale (e.g., "en-us"). Useful for localization.
- `FollowUserId: number` -- The UserId of the player this player followed into the experience (0 if none).
- `RespawnLocation: SpawnLocation?` -- Override spawn point for this player.
- `CameraMaxZoomDistance: float` / `CameraMinZoomDistance: float` -- Camera zoom limits in studs.
- `CameraMode: Enum.CameraMode` -- Classic or LockFirstPerson.
- `HealthDisplayDistance: float` / `NameDisplayDistance: float` -- Display distances for health bars and name labels.

### Methods (key subset)

- `:Kick(message: string?) -> ()` -- Disconnects the player with an optional message.
- `:LoadCharacter() -> ()` -- Forces a character respawn. Yields.
- `:LoadCharacterAsync() -> ()` -- Async variant that yields until the character is loaded.
- `:GetMouse() -> Mouse` -- Returns the player's Mouse object (client-side only).
- `:GetNetworkPing() -> number` -- Returns the player's network ping in seconds.
- `:IsFriendsWithAsync(otherUserId: number) -> boolean` -- Checks if this player is friends with another user. Yields.
- `:IsInGroupAsync(groupId: number) -> boolean` -- Checks if this player is in a Roblox group. Yields.
- `:GetRankInGroupAsync(groupId: number) -> number` -- Returns the player's rank in a group (0-255). Yields.
- `:IsVerified() -> boolean` -- Returns whether the player has verified their identity.
- `:DistanceFromCharacter(point: Vector3) -> number` -- Returns the distance from the player's character to a point.
- `:RequestStreamAroundAsync(position: Vector3, timeout: number?) -> ()` -- Requests that the area around a position be streamed to this client. Yields.
- `:GetJoinData() -> Dictionary` -- Returns data about how the player joined (teleport data, launch data, etc.).

### Events

- `.CharacterAdded:Connect(fn(character: Model))` -- Fires when the player's character spawns or respawns.
- `.CharacterRemoving:Connect(fn(character: Model))` -- Fires just before the character is removed (death, leave).
- `.CharacterAppearanceLoaded:Connect(fn(character: Model))` -- Fires when the character's appearance has fully loaded.
- `.Chatted:Connect(fn(message: string, recipient: Player?))` -- Fires when the player sends a chat message.
- `.Idled:Connect(fn(idleTime: number))` -- Fires when the player has been idle for ~2 minutes (server-side only). Fires every 30 seconds thereafter.
- `.OnTeleport:Connect(fn(teleportState: Enum.TeleportState, placeId: number, spawnName: string))` -- Fires during teleport state transitions.

## Budgets and Limits

No explicit rate limits on Player methods, but `IsFriendsWithAsync`, `IsInGroupAsync`, and `GetRankInGroupAsync` are web API calls that yield and can fail -- always pcall.

## Common Patterns

### Character lifecycle setup

```lua
local Players = game:GetService("Players")

local function onCharacterAdded(character: Model)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        print("Player died")
    end)
end

local function onPlayerAdded(player: Player)
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character) -- handle already-spawned character
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
    onPlayerAdded(player) -- handle players who joined before script ran
end
```

## Pitfalls

- **UserId vs Name**: Always use `UserId` for DataStore keys and persistent references. `Name` can change.
- **Character can be nil**: `player.Character` is nil before first spawn and briefly nil during respawn. Always nil-check or use `CharacterAdded`.
- **PlayerRemoving timing**: `PlayerRemoving` fires before removal. `CharacterRemoving` fires before the character is destroyed. Save data in `PlayerRemoving`, not `ChildRemoved`.
- **GetMouse is client-only**: Calling `:GetMouse()` from a server script errors.
- **Idled event**: Only fires on the server and only after ~2 minutes of inactivity.

## Related

- [[Players]] -- the service containing all Player instances
- [[Humanoid]] -- the character's humanoid component
- [[DataStoreService]] -- saving/loading player data using UserId

## Sources

- [wiki/raw/roblox-creator-docs/services/Player.md](../raw/roblox-creator-docs/services/Player.md)
