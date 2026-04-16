---
title: Securing RemoteEvents and RemoteFunctions — Core Patterns
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-secure-your-remoteevent-and-remotefunction/3345363
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: security
tags: [security, remote-events, validation, anti-exploit, sanitization]
---

# Securing RemoteEvents and RemoteFunctions — Core Patterns

**Source:** Roblox DevForum community tutorial — "How to secure your RemoteEvent and RemoteFunction"

## The core threat model

Every RemoteEvent/RemoteFunction is a public endpoint. Assume the client is hostile: any value the client can send, an exploit tool can send with arbitrary content, at arbitrary frequency, from any context. The goal of securing a remote is to:

1. Reject malformed data before it hits game logic
2. Rate-limit the caller so spam cannot DoS the server
3. Never trust client-supplied state (money, position, ownership) directly
4. Avoid patterns that let the caller exhaust the remote queue or yield the server

## The four layers of defense

### 1. Server-side rate limiting (cooldowns)

Keep a per-player timestamp table and reject calls that arrive too close together. A common baseline is 0.2 seconds (5 calls/sec max) for fast-path events like damage or ability-use, and 1–2 seconds for low-frequency events like shop purchases.

```lua
local lastCall = {}

remote.OnServerEvent:Connect(function(player, ...)
    local now = tick()
    local prev = lastCall[player.UserId] or 0
    if now - prev < 0.2 then
        return  -- too frequent
    end
    lastCall[player.UserId] = now

    -- proceed with validation...
end)

game.Players.PlayerRemoving:Connect(function(player)
    lastCall[player.UserId] = nil
end)
```

Without this, an exploit can fire the remote thousands of times per second, overrunning the RemoteEvent queue and causing "remote queue exhaustion" errors that crash the server.

### 2. Type validation

Use `typeof()` to check every argument matches the expected type. Reject anything that does not.

```lua
remote.OnServerEvent:Connect(function(player, itemId, quantity)
    if typeof(itemId) ~= "string" then return end
    if typeof(quantity) ~= "number" then return end
    if quantity ~= quantity or quantity <= 0 or quantity > 99 then return end  -- NaN check + range
    -- ...
end)
```

The `quantity ~= quantity` trick catches `NaN`, which compares unequal to itself and is a classic exploit input that breaks arithmetic checks silently.

### 3. Sanity checks

Validate the *meaning* of the data, not just its type:

- **String length** — reject strings over a hard cap (e.g. 200 chars). Exploiters send multi-megabyte strings hoping to exhaust memory or cause `string.sub` to hang.
- **Table shape** — never `for k, v in pairs(clientTable) do` without validation; search for specific indices you expect. An exploiter can send a table with a metatable that yields on indexing, or one with millions of keys.
- **Game state** — "does this player actually own that item?" "does this part actually exist?" "is the player within interaction range of the thing they're interacting with?" These are the questions the server must always answer itself.

```lua
local ITEMS = require(ReplicatedStorage.Shared.ItemDefinitions)
local MAX_NAME_LENGTH = 50

remote.OnServerEvent:Connect(function(player, itemId)
    if typeof(itemId) ~= "string" then return end
    if #itemId > MAX_NAME_LENGTH then return end

    local itemDef = ITEMS[itemId]
    if not itemDef then return end  -- item must exist in server's definition

    local inventory = getInventory(player)
    if not inventory:Has(itemId) then return end  -- player must actually own it

    -- only now apply the effect
    inventory:Remove(itemId)
    applyEffect(player, itemDef.effect)
end)
```

### 4. Async processing to avoid queue exhaustion

If a remote handler can yield (DataStore, HTTP, long loop), run it inside `task.spawn` so the event handler itself returns immediately:

```lua
remote.OnServerEvent:Connect(function(player, key)
    if not validate(player, key) then return end

    task.spawn(function()
        local data = DataStore:GetAsync(key)
        -- ...
    end)
end)
```

This is critical. A handler that yields inside the event thread will block subsequent events from the same remote, and the queue fills with buffered calls. Once the queue hits its cap, Roblox throws the "remote queue exhaustion" error and the server may crash.

## Common anti-patterns to avoid

### Passing raw values that should be derived server-side

**Bad:**
```lua
-- Client tells server "I dealt 50 damage"
damageRemote:FireServer(target, 50)
```

**Good:**
```lua
-- Client says "I swung my sword at this target"
swingRemote:FireServer(target)

-- Server computes damage from authoritative state
swingRemote.OnServerEvent:Connect(function(player, target)
    if not validate(player, target) then return end
    local weapon = inventory:GetEquippedWeapon(player)
    local damage = weapon.BaseDamage * getPlayerStats(player).Strength
    target.Humanoid:TakeDamage(damage)
end)
```

The general rule: the client tells the server *intent*, not *outcome*. The server derives outcomes from its own authoritative state.

### Trusting positions

Positions sent from the client (for teleports, for hit detection, for pickups) should be validated against the player's server-side character position. If the client-reported position is further than the player could have reached in the time since the last update, reject the event or snap the player back.

### Unpacking client tables naively

```lua
-- BAD: iterates arbitrarily deep structures an exploiter could supply
for k, v in pairs(clientTable) do
    process(k, v)
end
```

Instead, pull specific indices you expect and validate each:

```lua
local name = clientTable.name
local amount = clientTable.amount
if typeof(name) ~= "string" or typeof(amount) ~= "number" then return end
```

### Relying on LocalScripts for validation

LocalScripts are not a trust boundary. Any check done on the client is advisory only — the server must re-check every constraint. If the UI won't let you click "Buy" when you have no money, the server must still verify the balance, because exploits can fire the remote without going through the UI.

## Summary checklist

Before shipping any remote:

- [ ] Rate-limited on the server?
- [ ] Every argument type-checked with `typeof`?
- [ ] NaN handled for numeric args?
- [ ] String length capped?
- [ ] Table shape validated by pulling specific indices (not `pairs` over client data)?
- [ ] Game state validated (ownership, range, existence)?
- [ ] Handler wraps any yielding work in `task.spawn`?
- [ ] Client sends *intent* and server computes *outcome*?

## Source

Original URL: https://devforum.roblox.com/t/how-to-secure-your-remoteevent-and-remotefunction/3345363
Related: https://create.roblox.com/docs/scripting/events/remote
Captured: 2026-04-15
