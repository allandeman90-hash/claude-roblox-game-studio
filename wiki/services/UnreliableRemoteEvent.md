---
title: UnreliableRemoteEvent
type: service
category: services
subcategory: networking
owner: remotes-networking-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/UnreliableRemoteEvent.md
  - .claude/agents/remotes-networking-specialist.md
related:
  - "[[RemoteEvent]]"
  - "[[RemoteFunction]]"
  - "[[rate-limiting]]"
  - "[[bandwidth-budget]]"
tags: [roblox-class, networking, performance]
---

# UnreliableRemoteEvent

> Fire-and-forget messaging **without delivery guarantees**. For cosmetic, high-frequency data where occasional dropped packets are acceptable.

## Summary

`UnreliableRemoteEvent` works like [[RemoteEvent]] but uses UDP-style transport:
- **May drop packets** under load
- **No ordering guarantees** — messages may arrive out of order
- **Lower latency and higher throughput** than `RemoteEvent`
- **Smaller overhead per message**

Use it whenever you're sending data that (a) doesn't need to arrive and (b) doesn't need to arrive in order.

## API Surface

Same interface as `RemoteEvent`:
- Server: `:FireClient(player, ...)`, `:FireAllClients(...)`
- Client: `:FireServer(...)`
- Events: `.OnServerEvent`, `.OnClientEvent`

The only difference is transport reliability.

## When to Use

**Great fits:**
- Per-frame character position/rotation for non-authoritative visual effects
- Particle system positions and emissions
- Chat bubble triggers
- Trail/beam endpoint updates
- Ambient scene updates (bird positions, leaf sway, etc.)
- Animation state hints (the "feels smoother" tier, not the "gameplay correct" tier)

**Bad fits:**
- Purchase requests
- Combat damage events
- Anything that affects scorekeeping, inventory, or persistent state
- Chat message bodies (content — the chat bubble visual trigger is fine)
- Anything the server must receive to stay authoritative

## Security

Unreliable remotes are still attacker-controlled on the client → server path. Validate arguments the same way you would for a regular `RemoteEvent`:
- Type check
- Range check
- Rate limit

The only difference is that you accept "sometimes my rate-limit state loses a call, and that's fine" — because the packet can drop anyway.

## Bandwidth Trade-offs

Compared to `RemoteEvent`:
- **Smaller per-packet overhead** (no reliable-delivery metadata)
- **No retransmission cost** when packets drop
- **Same bytes-on-the-wire for the payload itself**

If you're firing at 60 Hz with a 40-byte payload, the difference per player is ~600 B/s → ~500 B/s savings — real, but small. The bigger win is that unreliable packets don't jam the reliable channel when they get dropped.

## Pattern: Smooth Position Replication

```lua
-- Server: broadcast authoritative positions at 20 Hz
local RunService = game:GetService("RunService")
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

local lastBroadcast = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastBroadcast < 0.05 then return end
    lastBroadcast = now

    local snapshot = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character and player.Character.PrimaryPart then
            snapshot[player.UserId] = player.Character.PrimaryPart.CFrame
        end
    end
    Remotes.CharacterSnapshot:FireAllClients(snapshot)
end)
```

```lua
-- Client: interpolate between received snapshots
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

Remotes.CharacterSnapshot.OnClientEvent:Connect(function(snapshot)
    for userId, cframe in pairs(snapshot) do
        if userId ~= game.Players.LocalPlayer.UserId then
            local other = game.Players:GetPlayerByUserId(userId)
            if other and other.Character and other.Character.PrimaryPart then
                -- smooth toward received position
                other.Character.PrimaryPart.CFrame = cframe:Lerp(
                    other.Character.PrimaryPart.CFrame, 0.5)
            end
        end
    end
end)
```

Dropping a snapshot is fine — the next one arrives in 50 ms and smoothing hides the gap.

## Pitfalls

- **Using it for game-critical state**: if the packet drops, your game forgets. Never for inventory, purchases, combat damage.
- **Assuming order**: packets arrive in arbitrary order. Your handler must tolerate stale data.
- **Skipping validation because "it's unreliable"**: the client can still send malicious payloads. Validate the same way.
- **Using it when RemoteEvent would work fine**: only use unreliable when the payload is truly per-frame cosmetic.
- **Firing at > 60 Hz**: still bandwidth-expensive. Throttle to 20-30 Hz for position updates.

## Related

- [[RemoteEvent]] — reliable alternative (default choice)
- [[RemoteFunction]] — request-response (use sparingly)
- [[rate-limiting]] — still needed on client → server
- [[bandwidth-budget]] — 50 KB/s per-player target

## Sources

- [Roblox Creator Docs — UnreliableRemoteEvent](https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent)
- [wiki/raw/roblox-creator-docs/services/UnreliableRemoteEvent.md](../raw/roblox-creator-docs/services/UnreliableRemoteEvent.md)
