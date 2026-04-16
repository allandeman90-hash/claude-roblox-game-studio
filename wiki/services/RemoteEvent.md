---
title: RemoteEvent
type: service
category: services
subcategory: networking
owner: remotes-networking-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/RemoteEvent.md
  - .claude/agents/remotes-networking-specialist.md
  - .claude/rules/remotes.md
related:
  - "[[RemoteFunction]]"
  - "[[UnreliableRemoteEvent]]"
  - "[[BindableEvent]]"
  - "[[server-authority]]"
  - "[[rate-limiting]]"
  - "[[unvalidated-remote-args]]"
  - "[[remote-spam]]"
  - "[[client-trust]]"
tags: [roblox-class, networking]
---

# RemoteEvent

> Fire-and-forget message passing between server and clients. The default tool for client-server communication on Roblox.

## Summary

`RemoteEvent` is the primary mechanism for sending messages across the client-server boundary. It is **non-blocking** (neither side waits for the other) and works in both directions. Client → server messages are attacker-controlled; server → client messages are replicated from the authoritative game state.

For requests that need a response, prefer RemoteEvent with a separate reply RemoteEvent, rather than [[RemoteFunction]] — a Client → Server RemoteFunction lets the client hang the server.

For high-frequency cosmetic updates (animations, particle positions), use [[UnreliableRemoteEvent]] instead.

## API Surface

### Properties
- No data properties — `RemoteEvent` is a message pipe.

### Methods (Server)
- `:FireClient(player: Player, ...args)` — Send a message to a specific client.
- `:FireAllClients(...args)` — Broadcast to every connected client.

### Methods (Client)
- `:FireServer(...args)` — Send a message to the server.

### Events (Server)
- `.OnServerEvent:Connect(function(player, ...args) end)` — Fires when any client calls `:FireServer`. `player` is always the invoking player.

### Events (Client)
- `.OnClientEvent:Connect(function(...args) end)` — Fires when the server calls `:FireClient` (for this player) or `:FireAllClients`.

## Security Model

**The golden rule: never trust the client.**

Every argument passed through `:FireServer` is attacker-controlled. Real-world exploit tools (Synapse X, Script-Ware, etc.) let a user inject arbitrary Luau code on the client side and fire any RemoteEvent with any arguments. The server must validate **every** field:

- **Type check** — `typeof(arg) == "expected"`
- **Range check** — `arg >= 0 and arg <= MAX_VALUE`
- **Sanity check** — does this action make sense given the player's current state?
- **Rate limit** — no more than N calls per second per player (see [[rate-limiting]])

See [[server-authority]] and [[unvalidated-remote-args]] for full context.

## Common Patterns

### Server Handler Template

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RATE_LIMIT_PER_SECOND = 10
local lastCallTimes: {[Player]: {number}} = {}

local function handlePurchase(player: Player, itemId: string)
    -- 1. Rate limit
    local now = os.clock()
    lastCallTimes[player] = lastCallTimes[player] or {}
    local calls = lastCallTimes[player]
    while #calls > 0 and calls[1] < now - 1 do
        table.remove(calls, 1)
    end
    if #calls >= RATE_LIMIT_PER_SECOND then
        return
    end
    table.insert(calls, now)

    -- 2. Type validation
    if typeof(itemId) ~= "string" then return end

    -- 3. Range validation
    if #itemId > 50 or #itemId == 0 then return end

    -- 4. Sanity check
    if not ShopConfig[itemId] then return end
    if not Inventory.playerCanAfford(player, itemId) then return end

    -- 5. Proceed with the operation
    Inventory.purchaseItem(player, itemId)
end

Remotes.PurchaseItem.OnServerEvent:Connect(handlePurchase)
```

### Centralized Remotes Module

```lua
-- ReplicatedStorage/Shared/Remotes.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local function getOrCreate(name: string, className: string): Instance
    local existing = ReplicatedStorage:FindFirstChild(name)
    if existing then return existing end
    local new = Instance.new(className)
    new.Name = name
    new.Parent = ReplicatedStorage
    return new
end

Remotes.PurchaseItem = getOrCreate("PurchaseItem", "RemoteEvent")
Remotes.StartAttack = getOrCreate("StartAttack", "RemoteEvent")
Remotes.UpdateHUD = getOrCreate("UpdateHUD", "UnreliableRemoteEvent")

return Remotes
```

### Cleanup on Player Leave

Rate-limit state and any per-player tracking tied to a `RemoteEvent` should be cleaned up when the player leaves, to avoid memory leaks:

```lua
game:GetService("Players").PlayerRemoving:Connect(function(player)
    lastCallTimes[player] = nil
end)
```

## Bandwidth

Target **< 50 KB/s per player** outgoing. A `RemoteEvent` firing at 60 Hz with a ~100-byte payload is 6 KB/s per player — quickly adds up. For per-frame cosmetic updates, use [[UnreliableRemoteEvent]] instead.

## Pitfalls

- **No validation → instant exploit**: Every handler must type-check, range-check, sanity-check, and rate-limit.
- **Client → Server RemoteFunction**: Use RemoteEvent instead; see [[client-to-server-remote-function]] anti-pattern.
- **Instance references in arguments**: Don't pass `Instance` through a remote. Use string IDs. See [[instance-in-remote]].
- **Assuming ordering**: Different `RemoteEvent`s have no ordering guarantee between them. If A then B is sent, B may arrive first.
- **High-frequency reliable remotes for cosmetics**: Use [[UnreliableRemoteEvent]] for animations, particles, chat bubbles.
- **Not cleaning up handlers on PlayerRemoving**: Per-player state leaks memory over time.
- **Using a single remote for everything**: Makes auditing harder. Split by feature area.

## Related

- [[RemoteFunction]] — request-response variant (use carefully, only Server → Client)
- [[UnreliableRemoteEvent]] — packet-drop-tolerant for cosmetic updates
- [[BindableEvent]] — same-side (non-network) messaging
- [[server-authority]] — the foundational concept
- [[rate-limiting]] — required pattern for every client → server remote
- [[client-trust]] — anti-pattern this defends against
- [[unvalidated-remote-args]] — anti-pattern: missing validation
- [[remote-spam]] — exploit: spam attack
- [[argument-spoofing]] — exploit: sending invalid types
- [Remotes Rules](../../.claude/rules/remotes.md)

## Sources

- [Roblox Creator Docs — RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent)
- [wiki/raw/roblox-creator-docs/services/RemoteEvent.md](../raw/roblox-creator-docs/services/RemoteEvent.md)
- [.claude/agents/remotes-networking-specialist.md](../../.claude/agents/remotes-networking-specialist.md)
- [.claude/rules/remotes.md](../../.claude/rules/remotes.md)
