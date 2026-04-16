---
title: UnreliableRemoteEvents
type: raw-source
source_url: https://devforum.roblox.com/t/introducing-unreliableremoteevents/2724155
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: network
tags: [unreliable-remote-events, network, packet-loss, replication]
---

# UnreliableRemoteEvents

## Overview

UnreliableRemoteEvent is a Roblox instance that transmits events "unreliably and unordered through the network," contrasting with standard RemoteEvents which are reliable and ordered.

## Key Use Cases

The feature suits "ephemeral events" including:
- Particle effects
- Sound effects
- Visual events not critical to game state
- Movement replication systems
- Mass data transmission that doesn't require guaranteed delivery

## Technical Specifications

### Payload Limits (Updated March 12, 2025)
- **Maximum: 1000 bytes** on both client and server
- Previously had inconsistencies between platforms that were fixed

### Network Guarantees
- **No ordering guarantee** between UnreliableRemoteEvents or other network traffic
- Events may be dropped to "prioritize bandwidth or CPU usage" beyond standard network loss
- Not currently prioritized over other traffic types

## Performance Benefits

In poor network conditions (40% packet loss test), unreliable remote events handle packet loss much better than reliable ones that need to retransmit lost packets. Reliable remotes can stall and bunch up behind retransmitted packets.

## Basic Implementation

**Server:**
```lua
local unreliableEvent = Instance.new("UnreliableRemoteEvent")
unreliableEvent.Name = "UnreliableEvent"
unreliableEvent.Parent = workspace

unreliableEvent:FireAllClients()
```

**Client:**
```lua
local unreliableEvent = workspace:WaitForChild("UnreliableEvent")
unreliableEvent.OnClientEvent:Connect(function()
    print('Received UnreliableRemoteEvent from Server!')
end)
```

## Known Limitations

- Events with listeners will not queue if no connections exist
- Delivery affected by congestion from reliable and unreliable messages
- No guarantee of delivery - must tolerate dropped packets

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Max payload size | 1000 bytes |
| Typical use case | Particle effects, movement replication |

## Decision Matrix

| Use Case | Reliable RemoteEvent | UnreliableRemoteEvent |
|----------|---------------------|----------------------|
| Damage events | Yes | No |
| Inventory changes | Yes | No |
| Player position stream | No | Yes |
| Hit VFX on bullet impact | No | Yes |
| Sound spawn on event | No | Yes |
| Critical state transitions | Yes | No |

## Source

Original URL: https://devforum.roblox.com/t/introducing-unreliableremoteevents/2724155
Captured: 2026-04-16
