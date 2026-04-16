---
title: TeleportService
type: service
category: services
subcategory: networking
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/TeleportService.md
related:
  - "[[Players]]"
  - "[[MessagingService]]"
tags: [roblox-class, networking]
---

# TeleportService

> Transports players between places and servers within or across experiences. [[Players]]

## Summary

TeleportService is responsible for transporting players between different places within the same experience (universe) or to other experiences entirely. The primary method is `TeleportAsync`, which replaces several older methods and supports `TeleportOptions` for passing data, reserving servers, and specifying custom loading screens.

TeleportService also supports **reserved servers** (private instances created on demand) via `ReserveServer`/`ReserveServerAsync`, which returns an access code that can be used to teleport players to that specific server. This is the foundation for matchmaking, private lobbies, and instanced dungeons.

Data can be passed to the destination via `TeleportOptions:SetTeleportData()`. However, this data arrives on the client first -- the server must retrieve and **validate** it via `Player:GetJoinData()`. Never trust teleport data without server-side validation.

## API Surface

### Properties

_No scriptable properties._

### Methods (key subset)

- `:TeleportAsync(placeId: number, players: {Player}, teleportOptions: TeleportOptions?) -> TeleportAsyncResult` -- Teleports one or more players to a place. Supports TeleportOptions for data, reserved servers, and custom loading screens. Yields.
- `:ReserveServer(placeId: number) -> (string, string)` -- Creates a reserved server and returns (accessCode, privateServerId). Yields. Deprecated in favor of `ReserveServerAsync`.
- `:ReserveServerAsync(placeId: number) -> (string, string)` -- Async variant. Returns (accessCode, privateServerId). Yields.
- `:GetLocalPlayerTeleportData() -> any` -- Client-only. Returns the teleport data the local player arrived with.
- `:GetArrivingTeleportGui() -> ScreenGui?` -- Returns the custom loading screen the player arrived with.
- `:SetTeleportGui(gui: ScreenGui) -> ()` -- Sets a custom loading screen for outgoing teleports.
- `:GetPlayerPlaceInstanceAsync(userId: number) -> (boolean, number, string)` -- Returns whether a player is in a place, and if so which placeId and jobId. Yields.

### Events

- `.TeleportInitFailed:Connect(fn(player: Player, teleportResult: Enum.TeleportResult, errorMessage: string))` -- Fires when a teleport fails. Deprecated: use the error from TeleportAsync instead.

## Budgets and Limits

- Teleport calls are rate-limited. Rapid consecutive teleport requests will fail.
- Custom loading screens only work when teleporting within the same experience (universe).
- Teleport data has a size limit (cannot pass arbitrarily large payloads).

## Common Patterns

### Basic teleport with data

```lua
local TeleportService = game:GetService("TeleportService")

local LOBBY_PLACE_ID = 123456789

local options = Instance.new("TeleportOptions")
options:SetTeleportData({ team = "Red", score = 100 })

local success, result = pcall(function()
    return TeleportService:TeleportAsync(LOBBY_PLACE_ID, { player }, options)
end)

if not success then
    warn("Teleport failed:", result)
end
```

### Reserved server for matchmaking

```lua
local TeleportService = game:GetService("TeleportService")
local ARENA_PLACE_ID = 987654321

local success, accessCode, privateServerId = pcall(function()
    return TeleportService:ReserveServerAsync(ARENA_PLACE_ID)
end)

if success then
    local options = Instance.new("TeleportOptions")
    options.ReservedServerAccessCode = accessCode
    TeleportService:TeleportAsync(ARENA_PLACE_ID, matchedPlayers, options)
end
```

## Pitfalls

- **Validate teleport data server-side**: Data arrives on the client. Retrieve it via `Player:GetJoinData().TeleportData` on the server and validate every field.
- **Teleport failures**: Teleports can fail for many reasons (rate limits, player leaving, invalid placeId). Always pcall and handle failures.
- **Deprecated methods**: `Teleport`, `TeleportPartyAsync`, `TeleportToPlaceInstance`, `TeleportToPrivateServer`, `TeleportToSpawnByName` are deprecated in favor of `TeleportAsync` with `TeleportOptions`.
- **Cross-experience limits**: Custom loading screens do not work when teleporting to a different experience.

## Related

- [[Players]] -- player lifecycle during teleports
- [[MessagingService]] -- cross-server communication alternative

## Sources

- [wiki/raw/roblox-creator-docs/services/TeleportService.md](../raw/roblox-creator-docs/services/TeleportService.md)
