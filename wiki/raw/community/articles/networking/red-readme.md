---
title: Red — Simple, Fast, Powerful Networking Library for Roblox
type: raw-source
source_url: https://github.com/red-blox/Red
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: networking
author: jackdotink (red-blox organization)
tags: [networking, red, luau, typed, compression]
---

# Red — Simple, Fast, Powerful Networking Library for Roblox

**Author:** jackdotink (red-blox organization)
**Source:** GitHub — `red-blox/Red`

## What it is

Red is a networking library for Roblox that combines a good structure with blazing fast performance to provide a good developer experience. It's described as suitable for any project, from tiny experiments to large-scale games. Red sits between Knit's fully auto-generated remote layer and ByteNet's schema-first buffer encoder — it's opinionated enough to enforce good patterns, but not so ceremonial as to require a declared binary schema for every packet.

## The three design pillars (from the introduction page)

### 1. Structure

Red ships with its own recommended architectural approach "that enforces good practices and creates more performant code." Specifically it encourages defining all of a feature's remotes in a single namespace module, then importing that module from both server and client. This prevents the common mistake of scattering `RemoteEvent` instances across the DataModel and losing track of which listener handles which event.

### 2. Performance

Red does not just wrap Remote Events and Functions like most networking libraries. Instead:

> Red uses a single Remote Event and identifiers to pack remote events and functions into a single call.

This is the same single-RemoteEvent-dispatcher pattern pioneered by BridgeNet2, with two additional twists:
- Events are **compressed** during packing, so Red uses **up to 75% less bandwidth** than stock RemoteEvent usage.
- The library adds **network data obfuscation** as a side effect, making it harder for exploiters to reverse-engineer packets.

### 3. Developer experience

- **Strict Luau throughout** — the whole library is typed in strict Luau, so users get full editor intellisense and lint-time checking.
- **No setup process** — require the library and begin developing. There's no bootstrap code, no required manifest, no packages-directory configuration.
- **Type inference** — when you define an event's payload shape, the handler's parameter type is inferred automatically.

## Minimal example

```lua
-- shared/Net.luau
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Server("Combat", function(): {
    Damage: Red.ServerEvent<{target: Instance, amount: number}>,
    Heal: Red.ServerEvent<{amount: number}>,
}
    return {
        Damage = Red.Event(),
        Heal = Red.Event(),
    }
end)
```

Red is namespaced — you create a `Red.Server("Combat", ...)` on the server and a matching `Red.Client("Combat", ...)` on the client. The namespace string is the logical partition; under the hood, every Red namespace shares the single global RemoteEvent and is distinguished by a small integer id.

Fire an event from the client:
```lua
local Net = require(ReplicatedStorage.Shared.Net)
Net:Fire("Damage", {target = someEnemy, amount = 10})
```

Listen on the server:
```lua
Net:On("Damage", function(player, payload)
    -- type of payload is inferred from the declaration
end)
```

## Performance claims

The README advertises **"up to 75% less bandwidth"** compared with stock RemoteEvent usage. The mechanism:

1. Single RemoteEvent eliminates per-call instance path overhead.
2. Event identifiers are 1–2 bytes each rather than full string names.
3. Payloads are compressed during packing (Red uses a custom table serializer that strips Lua type tags where safe).

These compound: a packet that stock RemoteEvents would send as ~80 bytes often lands under 20 bytes through Red.

## Where Red sits in the ecosystem

| Library | Shape | Best for |
|---|---|---|
| Stock RemoteEvents | Per-feature `RemoteEvent` instances | Tutorials, tiny games |
| Knit | Auto-generated from Service methods | Framework-driven projects |
| Red | Namespace modules, one shared remote, compressed tables | General-purpose, any project size |
| BridgeNet2 | One shared remote, raw tables | Legacy BridgeNet users |
| ByteNet | One shared remote, declared buffer schemas | Extreme perf, high-frequency packets |

Red is generally the best starting point for teams that have outgrown stock RemoteEvents but don't want to write buffer schemas. It gives most of ByteNet's perf win with none of the schema ceremony.

## Source

Original URL: https://github.com/red-blox/Red
Docs: https://red.redblox.dev/
Introduction: https://jackdotink.github.io/Red/guide/introduction/what-is-red.html
Captured: 2026-04-15
