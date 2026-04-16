---
title: ByteNet — Buffer-Serialized Networking Library for Luau / Roblox
type: raw-source
source_url: https://github.com/ffrostfall/ByteNet
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: networking
author: ffrostfall
tags: [networking, bytenet, buffer, serialization, performance, luau]
---

# ByteNet — Buffer-Serialized Networking Library for Luau / Roblox

**Author:** ffrostfall
**Source:** GitHub — `ffrostfall/ByteNet`
**License:** MIT

## What it is

ByteNet is an advanced, modern networking library for Luau/Roblox. It is, in a single sentence, "a networking library which takes your Luau data, and serializes it into buffers" — then sends those buffers across a single `RemoteEvent` and deserializes on the other side. It is the successor pattern to BridgeNet2 (same author) and is the library most high-performance Roblox projects migrate to when they outgrow naive `RemoteEvent:FireClient(table)` patterns.

## Why buffer serialization

Roblox's stock `RemoteEvent` replicates arbitrary Lua tables using a runtime-reflection tag format. Every value in a table pays header bytes for its type, every string carries its length as a 4-byte prefix, and every numeric field pays a type tag plus 8 bytes (doubles). For packets sent 60 times per second (movement, projectiles, effects), this adds up fast:

- A single `{x: number, y: number, z: number}` position packet costs ~40 bytes with stock replication.
- The same packet encoded as three `f32`s in a 12-byte buffer is ~70% smaller.

ByteNet defines a schema at load time, compiles a serializer/deserializer pair from it, and then every send is a tight binary encode into a pre-sized `buffer` object. The savings compound with packet frequency: at 60 Hz, reducing each packet by 30 bytes saves 1.8 KB/s per player, which at 50 players is 90 KB/s per server — a very real bandwidth and CPU win.

## Core features (from the README)

- **Strictly-typed API.** Schemas are defined with Luau primitives (`bytenet.u8`, `bytenet.f32`, `bytenet.string`, `bytenet.struct`, etc.) that propagate through strict Luau type inference, so fire/receive code gets full autocomplete.
- **Custom serializer.** Not a generic "encode any Lua table" library — schemas are defined explicitly and compiled once at load time.
- **Buffer-based architecture.** Uses Roblox's native `buffer` type for zero-copy encoding where possible.
- **roblox-ts support.** A typed `@rbxts/bytenet` wrapper exists for TypeScript projects.
- **Significantly faster than non-buffer libraries** like BridgeNet2 (which was itself faster than stock RemoteEvents).

## Example schema

```lua
local bytenet = require(ReplicatedStorage.Packages.ByteNet)

local PlayerMovement = bytenet.defineNamespace("PlayerMovement", function()
    return {
        move = bytenet.definePacket({
            value = bytenet.struct({
                position = bytenet.vec3(),    -- 12 bytes (3x f32)
                velocity = bytenet.vec3(),    -- 12 bytes
                yaw      = bytenet.f32(),     -- 4 bytes
            }),
        }),
    }
end)

-- Server: receive
PlayerMovement.move.listen(function(data, player)
    -- validate, then apply
end)

-- Client: send
PlayerMovement.move.send({
    position = char.HumanoidRootPart.Position,
    velocity = char.HumanoidRootPart.AssemblyLinearVelocity,
    yaw = camera.CFrame.LookVector.X,
})
```

Total payload for the struct above: 28 bytes on the wire, versus roughly 100+ bytes through a stock `RemoteEvent` with a table of the same fields.

## Installation

**Wally:**
```toml
[dependencies]
ByteNet = "ffrostfall/bytenet@^0.4"
```

**Pre-built `.rbxm`:** download from the GitHub releases page and drop into ReplicatedStorage.

**roblox-ts:** `npm i @rbxts/bytenet`.

## When to use ByteNet

- Projectile replication (arrows, bullets, magic)
- Movement packets for custom character controllers
- Particle/effect spawning at high frequency
- Any packet you send more than ~10 times per second per player
- Any packet whose shape is small and fixed (structs)

## When not to use it

- One-off game events (trade confirmations, purchases) — stock RemoteEvents are fine and easier
- Variable/dynamic payloads where the schema would need to be a polymorphic union; ByteNet supports these but the boilerplate cost rises
- Teams that are not bandwidth-constrained

## Positioning vs. BridgeNet2 and Red

The same author wrote BridgeNet2 first, which saved bytes by packing events into a single underlying RemoteEvent but still used the Roblox table replication format. ByteNet is the next-generation approach — same single-RemoteEvent trick, plus full buffer serialization.

Red (by jackdotink) takes a similar single-RemoteEvent-with-identifiers approach but stays with Lua table encoding, favoring ease of use over raw throughput. Rough ranking for wire size and CPU:

1. **ByteNet / ByteNet Max** — smallest, fastest, strict schemas required
2. **Red** — small, fast, minimal setup
3. **BridgeNet2** — smaller than stock, author now recommends ByteNet
4. **Stock RemoteEvents** — easiest, largest, slowest

## Source

Original URL: https://github.com/ffrostfall/ByteNet
Devforum announcement: https://devforum.roblox.com/t/bytenet-advanced-networking-library-w-buffer-serialization-strict-luau-absurd-optimization-and-rbxts-support-043/2733365
Captured: 2026-04-15
