---
title: client-server-split
type: concept
category: concepts
subcategory: architecture
owner: technical-director
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - .claude/docs/roblox-architecture-guide.md
  - .claude/agents/technical-director.md
related:
  - "[[server-authority]]"
  - "[[RemoteEvent]]"
  - "[[module-lazy-loading]]"
  - "[[streaming-enabled]]"
tags: [concept, architecture, foundational]
---

# Client-Server Split

> The architectural model that divides Roblox code into three zones — server-only, client-only, and shared — based on which side runs which logic.

## What It Is

Every Roblox experience runs on two kinds of machines:
- **One dedicated server** per game instance, running Luau scripts in the "server" context
- **Many clients** (one per player), each running Luau scripts in the "client" context

Code is placed in Roblox's service hierarchy, and Roblox decides which side runs it based on the service:

| Service | Runs on | Notes |
|---|---|---|
| `ServerScriptService` | **Server only** | Scripts auto-execute at runtime. Safe for secrets. |
| `ServerStorage` | **Server only** | Inactive modules and data. Safe for secrets. |
| `ReplicatedStorage` | **Both** | Shared modules, types, configs. Everything here is visible to every client. |
| `ReplicatedFirst` | **Client (early)** | Runs before regular StarterPlayer scripts. Loading screens go here. |
| `StarterGui` | **Client** | Cloned into each player's PlayerGui on spawn. |
| `StarterPlayer.StarterPlayerScripts` | **Client** | LocalScripts that run when player joins. |
| `StarterPlayer.StarterCharacterScripts` | **Client** | Scripts attached to each spawned character. |
| `Workspace` | **Both (replicated)** | The 3D world. Replicated to clients. |

## Why It Matters

The client-server split is what makes [[server-authority]] possible. By placing sensitive logic (data persistence, purchase processing, combat validation) in server-only services, you can trust that code to run in an untampered environment.

Placing logic in the wrong zone is a security bug:
- **Admin list in `ReplicatedStorage`**: every client reads it — exploiters see who can give admin. Put it in `ServerStorage` or hardcode in a `ServerScriptService` script.
- **Purchase processing in `StarterPlayerScripts`**: clients "buy" items for themselves without the server ever seeing. Impossible to enforce prices.
- **DataStore access from a LocalScript**: LocalScripts can't even access `DataStoreService`. Roblox blocks this — good.

## The Zones

### Server-Only (`ServerScriptService`, `ServerStorage`)
- Active game logic: combat resolution, inventory mutations, DataStore access
- Secrets: admin lists, API keys, master config
- Authoritative game state (the "source of truth")
- Anti-exploit validation

**Rule**: if code reading it would compromise security, it belongs here.

### Client-Only (`StarterGui`, `StarterPlayer*`, `ReplicatedFirst`)
- UI rendering (HUD, menus, modals)
- Input capture (keyboard, touch, gamepad)
- Visual effects triggered by replicated state
- Local prediction (movement smoothing, responsive feedback)
- Sound playback
- Animations

**Rule**: if it's a presentation or input concern and doesn't affect game state, it belongs here.

### Shared (`ReplicatedStorage`)
- Type definitions
- Configuration tables (non-sensitive)
- Utility modules (math helpers, signal libraries, Trove)
- The remotes registry (centralized `RemoteEvent` module)
- Shared constants

**Rule**: if both sides need it and nothing in it is secret, it belongs here. Clients can read everything here — design accordingly.

## Implementation Sketch

```
src/
├── ServerScriptService/
│   ├── CombatService.lua            — damage calculations, server-side validation
│   ├── ShopService.lua               — PurchaseItem remote handler
│   └── PlayerDataService.lua         — DataStore read/write
├── ServerStorage/
│   ├── AdminList.lua                 — { [userId] = true }  (secret!)
│   └── EnemyTemplates/               — ModelTemplates that clients shouldn't see
├── ReplicatedStorage/
│   └── Shared/
│       ├── Remotes.lua               — centralized remote registry
│       ├── Types.lua                 — shared types (PlayerData, ItemDef, etc.)
│       ├── ItemConfig.lua            — non-secret item definitions
│       ├── Trove.lua                 — cleanup utility
│       └── GoodSignal.lua            — signal library
├── StarterGui/
│   └── MainHud/
│       ├── init.client.lua            — HUD LocalScript
│       └── components/                — UI code
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── InputHandler.client.lua   — input capture
```

## Communication Across the Boundary

Use `RemoteEvent` and (rarely) `RemoteFunction`:
- **Client action** → `Remotes.<Name>:FireServer(args)` → server handler
- **Server state update** → `Remotes.<Name>:FireClient(player, args)` or `:FireAllClients(args)` → client listener

See [[RemoteEvent]] and [[RemoteFunction]] for the primitives.

## Pitfalls

- **Secret data in `ReplicatedStorage`**: visible to every client. Move to `ServerStorage`.
- **Game logic in a LocalScript**: can be bypassed by exploiters. Move to a server Script.
- **Script in `Workspace`**: don't — it runs wherever Workspace replicates it. Use ServerScriptService.
- **Shared state in `ReplicatedStorage` that's actually per-player**: it's global, not per-client. Per-player state lives in `Player:WaitForChild(...)` or server-side tables.
- **`WaitForChild` not used for replicated instances**: instance may not have arrived on the client yet. Always `WaitForChild` when accessing replicated content from a LocalScript.
- **Placing cross-cutting modules inconsistently**: pick one home for each module and stick with it.

## Related

- [[server-authority]] — the reason the split exists
- [[RemoteEvent]] — primary communication primitive
- [[module-lazy-loading]] — module system that lives in this architecture
- [[streaming-enabled]] — changes how `Workspace` replicates

## Sources

- [.claude/docs/roblox-architecture-guide.md](../../.claude/docs/roblox-architecture-guide.md)
- [.claude/agents/technical-director.md](../../.claude/agents/technical-director.md)
- [Roblox Creator Docs — client-server model](https://create.roblox.com/docs/projects/client-server)
