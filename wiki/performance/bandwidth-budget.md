---
title: Bandwidth Budget
type: performance
category: performance
subcategory: budgets
owner: performance-analyst
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/performance/network/remote-event-optimization.md
  - wiki/raw/community/performance/network/luau-buffer-type.md
  - wiki/raw/community/performance/network/unreliable-remote-events.md
  - wiki/raw/community/performance/network/streaming-enabled-guide.md
  - wiki/raw/community/performance/rendering/optimization-guide-draw-calls.md
related:
  - "[[heartbeat-budget]]"
  - "[[server-memory-budget]]"
tags: [performance, budgets, network, bandwidth]
---

# Bandwidth Budget

## Summary

Roblox throttles both network send and receive at **50 KB/s per player**. Exceeding this causes packet queuing, increased latency, and degraded gameplay. The primary optimization strategies are batching, metadata reduction, binary encoding via the `buffer` type, and using `UnreliableRemoteEvent` for non-critical data.

## Measurements / Budgets

| Budget | Value | Source |
|--------|-------|--------|
| **Network throttle** | **50 KB/s per player** (send and receive) | [remote-event-optimization.md](../raw/community/performance/network/remote-event-optimization.md) |
| Max per RemoteEvent send | **50 MB** (hard limit) | [luau-buffer-type.md](../raw/community/performance/network/luau-buffer-type.md) |
| Max UnreliableRemoteEvent payload | **1000 bytes** | [unreliable-remote-events.md](../raw/community/performance/network/unreliable-remote-events.md) |
| Target Data Sent/Received | **< 5-10 ms** | [improving-game-performance-guide.md](../raw/community/performance/profiling/improving-game-performance-guide.md) |
| Buffer compression algorithm | **Zstd** (transparent on-the-wire) | [luau-buffer-type.md](../raw/community/performance/network/luau-buffer-type.md) |
| Reported buffer savings | **up to 60x** | [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md) |
| Max incoming network | **< 50 KB/s** | [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md) |

### Streaming Defaults

| Setting | Default | Source |
|---------|---------|--------|
| StreamingMinRadius | **64 studs** | INDEX.md |
| StreamingTargetRadius | **1024 studs** | INDEX.md |
| Mobile-recommended TargetRadius | **512-768 studs** | INDEX.md |

## How to Measure

- **Developer Console (F9)** > Network tab: shows Data Sent and Data Received in real time.
- **Performance Stats bar** (`Ctrl+Alt+F7`): includes network summary.
- Monitor remote traffic per-event to identify which remotes consume the most bandwidth.

Source: [remote-event-optimization.md](../raw/community/performance/network/remote-event-optimization.md)

## Common Issues

### High-Frequency Reliable RemoteEvents

Firing reliable RemoteEvents at high frequency (e.g., every frame for position updates) quickly saturates the 50 KB/s budget. Reliable events guarantee delivery, so dropped packets trigger retransmission, which can stall and bunch up behind lost packets.

### Oversized Payloads

Sending full CFrame objects (position + rotation) when only position is needed wastes ~2x the bytes. Sending string keys instead of numeric IDs wastes metadata bandwidth.

### Server-Side Visual Work

Tweening, animating, or updating CFrames on the server replicates every change to all clients. Move visual-only work to the client.

Source: [remote-event-optimization.md](../raw/community/performance/network/remote-event-optimization.md)

## Optimization Patterns

### 1. Data Batching

Combine related updates into one event instead of firing separately:

```lua
-- BAD: two events
RemoteEvent:FireServer("UpdateHealth", 50)
RemoteEvent:FireServer("UpdateStamina", 80)

-- GOOD: one event
RemoteEvent:FireServer("UpdateStats", { Health = 50, Stamina = 80 })
```

### 2. Metadata Reduction with Enums

Replace string identifiers with numeric IDs:

```lua
local Protocol = { UpdateHealth = 10001, UpdateStamina = 10002 }
RemoteEvent:FireClient(player, Protocol.UpdateHealth, 50)
```

### 3. Binary Encoding with `buffer`

Pack data into a fixed-size buffer for compact transmission. Roblox applies Zstd compression transparently:

```lua
local buf = buffer.create(#objects * 18) -- 12 bytes pos + 6 bytes rot each
for i, obj in objects do
    local offset = (i - 1) * 18
    local pos = obj.Position
    buffer.writef32(buf, offset + 0, pos.X)
    buffer.writef32(buf, offset + 4, pos.Y)
    buffer.writef32(buf, offset + 8, pos.Z)
    local ori = obj.Orientation
    buffer.writei16(buf, offset + 12, math.round(ori.X * 100))
    buffer.writei16(buf, offset + 14, math.round(ori.Y * 100))
    buffer.writei16(buf, offset + 16, math.round(ori.Z * 100))
end
RemoteEvent:FireAllClients(buf)
```

This packs 18 bytes per part. With Zstd compression, reported savings reach **up to 60x** compared to naive table serialization.

Source: [luau-buffer-type.md](../raw/community/performance/network/luau-buffer-type.md)

### 4. UnreliableRemoteEvent for Cosmetic Data

For data that tolerates packet loss (particles, sound effects, movement hints):

```lua
local unreliable = Instance.new("UnreliableRemoteEvent")
unreliable:FireAllClients(effectId, position)
```

Max payload: **1000 bytes**. No ordering guarantee. Under poor network conditions (40% packet loss), unreliable events handle packet loss much better than reliable ones that stall on retransmission.

**Decision matrix:**

| Use Case | Reliable | Unreliable |
|----------|----------|------------|
| Damage events | Yes | No |
| Inventory changes | Yes | No |
| Player position stream | No | Yes |
| Hit VFX | No | Yes |
| Sound triggers | No | Yes |

Source: [unreliable-remote-events.md](../raw/community/performance/network/unreliable-remote-events.md)

### 5. Additional Techniques

- Round numerical values with `math.floor()` where precision is not critical.
- Leverage Roblox's built-in network ownership for automatic replication instead of custom remotes.
- Implement throttling through debounces or queue systems for rapid updates.

Source: [remote-event-optimization.md](../raw/community/performance/network/remote-event-optimization.md)

## Pitfalls

- **Buffer has no cursor abstraction.** Manual offset tracking is required. Off-by-one errors in offsets cause silent data corruption.
- **Buffer is fixed size.** Pre-allocate based on expected object count. Adaptive resizing requires `buffer.create` + `buffer.copy`.
- **UnreliableRemoteEvent payload limit is 1000 bytes, not configurable.** Exceeding it silently drops the event.
- **Zstd compression is transparent** -- you cannot control compression level or disable it. Larger buffers compress more efficiently than many small ones.
- **Buffer does not support Attributes** as of 2024. Cannot store buffers as instance attributes.

## Related

- [[heartbeat-budget]]
- [[server-memory-budget]]

## Sources

- [remote-event-optimization.md](../raw/community/performance/network/remote-event-optimization.md)
- [luau-buffer-type.md](../raw/community/performance/network/luau-buffer-type.md)
- [unreliable-remote-events.md](../raw/community/performance/network/unreliable-remote-events.md)
- [optimization-guide-draw-calls.md](../raw/community/performance/rendering/optimization-guide-draw-calls.md)
