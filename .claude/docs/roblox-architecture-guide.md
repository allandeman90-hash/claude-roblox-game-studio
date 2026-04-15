# Roblox Architecture Guide

This guide covers the architecture every Roblox developer — and every agent in this system — needs to internalize.

## 1. Client-Server Architecture

Roblox runs a **dedicated server** with multiple **clients** (one per player). Unlike single-player games, game state lives on the server, not the client.

### The Security Boundary

```
┌─────────────────────┐      ┌─────────────────────┐
│    Server (trust)   │◄────►│  Client (no trust)  │
│                     │      │                     │
│ Game state          │      │ Input collection    │
│ DataStore           │      │ Rendering           │
│ MarketplaceService  │      │ Local prediction    │
│ Validation          │      │ UI                  │
└─────────────────────┘      └─────────────────────┘
```

**The Golden Rule**: The server is ALWAYS authoritative. Never trust the client.

Anything the client sends (via RemoteEvent/RemoteFunction) is **attacker-controlled**. Exploit tools like Synapse X and Script-Ware let users inject arbitrary Luau code into the client. Assume every value from a remote is malicious until validated.

### What the Client CAN Do

- Display UI and game state
- Play sounds and animations
- Render particles and visual effects
- Collect player input
- Predict movement (reconciled with server)
- Cache visual data for smooth rendering

### What the Client CANNOT Do (Trusted)

- Change game state
- Grant items / XP / currency
- Read other players' private data
- Access DataStore
- Read secrets from ReplicatedStorage (anything there is public)

## 2. Service Hierarchy

Roblox organizes code into services:

### ServerScriptService
- **Purpose**: Server-only scripts that run automatically
- **Contains**: Active game logic, event handlers
- **Security**: Not replicated to clients — server-only code is safe here
- **Typical files**: `Main.server.lua`, `PlayerService.server.lua`, `CombatService.server.lua`

### ServerStorage
- **Purpose**: Server-only data and inactive modules
- **Contains**: ModuleScripts, templates, secrets, admin lists
- **Security**: Not replicated — safe for sensitive data
- **Typical files**: `PlayerDataService.lua`, `SecretConfig.lua`, `EnemyTemplates/`

### ReplicatedStorage
- **Purpose**: Shared modules and data (client AND server accessible)
- **Contains**: Types, config tables, utility modules, Remote references
- **Security**: Clients can read EVERYTHING here. Never put secrets here.
- **Typical files**: `Shared/Types.lua`, `Shared/WeaponConfig.lua`, `Shared/Remotes.lua`

### ReplicatedFirst
- **Purpose**: Client scripts that run before anything else (loading screen, early init)
- **Contains**: Loading UI, early connection setup
- **Security**: Client-visible

### StarterGui
- **Purpose**: UI that gets cloned into `Player.PlayerGui` on spawn
- **Contains**: ScreenGuis with their LocalScripts
- **Security**: Client-visible

### StarterPlayer
- **StarterPlayerScripts**: LocalScripts that run when player joins
- **StarterCharacterScripts**: Scripts attached to the player's character on spawn

### Workspace
- **Purpose**: The 3D world. Parts, meshes, models, lighting
- **Security**: Client-visible and editable (with replication rules)

## 3. DataStore Architecture

DataStore is Roblox's persistent storage. It has specific limits:

### Budgets
- `GetAsync`: 60 + (numPlayers × 10) per minute
- `SetAsync` / `UpdateAsync`: 60 + (numPlayers × 10) per minute
- Each key has a 6-second write cooldown
- Max value size: 4MB per key
- Max key length: 50 characters

### Required Patterns

#### Session Locking
Prevents data duplication across servers. See `.claude/agents/datastore-architect.md`.

#### Schema Versioning
Every data structure includes a `version` field so you can migrate between formats.

#### BindToClose
The server fires `BindToClose` on shutdown. You have 30 seconds to save all players. Use this to guarantee no data loss.

#### Retry with Backoff
DataStore calls can fail. Retry up to 5 times with exponential backoff.

## 4. Networking: Remotes

Roblox networking uses three types:

### RemoteEvent
- Fire-and-forget
- Both directions (client → server, server → client)
- Preferred for most networking

### RemoteFunction
- Request-response
- **Only Server → Client** — never Client → Server (server hang risk!)
- Use sparingly; RemoteEvent + explicit reply is usually safer

### UnreliableRemoteEvent
- Fire-and-forget
- May drop packets
- No ordering guarantee
- For high-frequency cosmetic data (particles, animations, chat bubbles)

### Centralized Remotes
Store all remotes in a single module:

```lua
-- ReplicatedStorage/Shared/Remotes.lua
local Remotes = {}
Remotes.PurchaseItem = getOrCreate("PurchaseItem", "RemoteEvent")
Remotes.RequestData = getOrCreate("RequestData", "RemoteFunction")
Remotes.UpdateHUD = getOrCreate("UpdateHUD", "UnreliableRemoteEvent")
return Remotes
```

Both client and server `require` this module.

## 5. Module Organization

Roblox modules follow this pattern:

```lua
-- Service caching at top
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

-- Type definitions
export type PlayerData = {
    gold: number,
    level: number,
}

-- Constants
local CURRENT_VERSION = 3
local AUTOSAVE_INTERVAL = 300  -- seconds

-- Private state
local playerDataCache: {[Player]: PlayerData} = {}

-- Private functions
local function loadData(player: Player): PlayerData?
    -- ...
end

-- Public module
local PlayerDataService = {}

function PlayerDataService.getData(player: Player): PlayerData?
    return playerDataCache[player]
end

function PlayerDataService.saveData(player: Player)
    -- ...
end

return PlayerDataService
```

### Circular Dependency Avoidance
If Module A requires Module B and Module B requires Module A, you have a circular dependency. Solutions:
- Extract the shared functionality to Module C
- Use events/signals to decouple
- Lazy-require with a wrapper function

## 6. StreamingEnabled

When `workspace.StreamingEnabled = true`:
- Parts stream in/out based on player distance
- Allows much larger worlds
- Saves memory
- **Caveat**: Parts may not exist on the client when accessed. Use `WaitForChild` or handle missing references gracefully.

Mark critical models (characters, HUD) as "Persistent" to ensure they're always loaded.

## 7. Cross-Server Communication

For communication between different server instances:

### MessagingService
- Publish/subscribe to topics
- Limit: 150 requests/min per server
- Best-effort delivery (may drop under load)
- Good for: announcements, global events, cross-server chat

### MemoryStoreService
- Shared in-memory storage
- SortedMap, HashMap, Queue
- 45-day max expiry
- Budget: 1000 + numPlayers × 100 per minute per instance
- Good for: cross-server leaderboards, matchmaking queues, global counters

## 8. Rojo / Argon Mapping

Rojo and Argon map your file system to Roblox's instance hierarchy:

```
src/                              →  DataModel (game)
├── ServerScriptService/          →  ServerScriptService
│   └── Main.server.lua           →  Script "Main"
├── ServerStorage/                →  ServerStorage
│   └── Config.lua                →  ModuleScript "Config"
├── ReplicatedStorage/            →  ReplicatedStorage
│   └── Shared/
│       └── Remotes.lua           →  ModuleScript "Remotes"
├── StarterGui/                   →  StarterGui
│   └── MainHud/
│       ├── init.client.lua       →  LocalScript "MainHud"
│       └── Button.lua            →  ModuleScript "Button"
└── StarterPlayer/
    └── StarterPlayerScripts/     →  StarterPlayer.StarterPlayerScripts
        └── Client.client.lua     →  LocalScript "Client"
```

File extensions determine type:
- `.lua` / `.luau` → ModuleScript (default)
- `.server.lua` / `.server.luau` → Script
- `.client.lua` / `.client.luau` → LocalScript

## 9. Security Checklist

Before shipping any feature, verify:

- [ ] All game state is server-authoritative
- [ ] All RemoteEvent handlers validate every argument (type, range, sanity)
- [ ] Rate limiting on client → server remotes
- [ ] No RemoteFunctions client → server
- [ ] DataStore operations wrapped in pcall
- [ ] Session locking on player data
- [ ] BindToClose save handler
- [ ] No secrets in ReplicatedStorage or StarterGui
- [ ] Purchase processing via `ProcessReceipt` (idempotent)
- [ ] Movement validated server-side (at least spot-checked)

## 10. Performance Targets

### Server
- Heartbeat time < 33ms (30 FPS minimum)
- Memory < 2GB typical
- Network < 50 KB/s per player

### Client
- FPS > 30 on low-end mobile, > 60 on PC
- Memory < 800MB on mobile
- Load time < 10 seconds from join
- Input latency < 100ms

See [`agent-roster.md`](./agent-roster.md) for which specialists own each part of this architecture.
