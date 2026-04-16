---
title: RemoteFunction
type: service
category: services
subcategory: networking
owner: remotes-networking-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/RemoteFunction.md
  - .claude/agents/remotes-networking-specialist.md
  - .claude/rules/remotes.md
related:
  - "[[RemoteEvent]]"
  - "[[UnreliableRemoteEvent]]"
  - "[[client-to-server-remote-function]]"
  - "[[server-authority]]"
tags: [roblox-class, networking]
---

# RemoteFunction

> Request-response messaging across the client-server boundary. **Blocking** — use sparingly, and ONLY server-initiated.

## Summary

`RemoteFunction` is a synchronous request-response primitive. The caller invokes and **yields until the callee returns**. This makes it powerful but dangerous: a Client → Server `RemoteFunction` call lets the server be blocked by the client.

**Rule**: Only ever use `RemoteFunction` in the **server → client** direction, where the server invokes and the client returns a value. Never the other way around.

For most client → server work, use [[RemoteEvent]] instead. If you need a reply, have the server reply via another RemoteEvent.

## API Surface

### Methods (Client — DO NOT CALL)
- `:InvokeServer(...args) -> results` — **FORBIDDEN** in production code. Creates the hang risk.

### Methods (Server)
- `:InvokeClient(player: Player, ...args) -> results` — Server calls client, client returns a value. Use for "client, tell me your local state" kinds of queries.

### Events (Server — DO NOT SET)
- `.OnServerInvoke = function(player, ...args) return ... end` — **FORBIDDEN**. If set, a client can call this and hang the server thread by not returning.

### Events (Client)
- `.OnClientInvoke = function(...args) return ... end` — Client handler for server-initiated queries.

## Why Client → Server RemoteFunction is Banned

When the client calls `:InvokeServer(...)`, the server thread handling the `OnServerInvoke` callback **yields until it returns**. A malicious client can just... not return. The server thread is stuck until timeout. In the meantime it can't serve other requests. This is a denial-of-service vector.

Exploit tools can exploit this by:
1. Invoking the server function
2. Never responding, or responding with an infinite yield
3. Repeating until server threads are exhausted

See [[client-to-server-remote-function]] for the full anti-pattern.

## When to Use It (Server → Client only)

Legitimate uses:
- "Client, tell me what graphics quality you've chosen" — server queries client preference
- "Client, show this modal and tell me which button the user clicked" — a blocking UI confirmation
- "Client, what UI theme are you currently rendering" — server querying client UI state for rollback

In all cases, the server is asking the client for local-only state that the server doesn't already know. The server should NOT trust this response for game-critical decisions.

## Pattern: Server-Initiated Query

```lua
-- ServerScriptService/ShowConfirmation.lua
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

local function askPlayerForConfirmation(player: Player, message: string): boolean
    local ok, result = pcall(function()
        return Remotes.ConfirmationPrompt:InvokeClient(player, message)
    end)
    if not ok then return false end
    return result == true
end
```

```lua
-- StarterPlayer/StarterPlayerScripts/HandleConfirmation.client.lua
local Remotes = require(game.ReplicatedStorage.Shared.Remotes)

Remotes.ConfirmationPrompt.OnClientInvoke = function(message: string): boolean
    -- Show UI, wait for button press, return result
    return showConfirmationUIAndWait(message)
end
```

## Pitfalls

- **Client → Server invocation** ([[client-to-server-remote-function]]): the core anti-pattern. Never set `.OnServerInvoke`.
- **Trusting client responses**: even server-initiated queries return values from an untrusted source. Don't use them for game-critical decisions.
- **Timeout handling**: wrap every `:InvokeClient` in `pcall` — the client may disconnect mid-call.
- **Blocking game logic**: even server-to-client, the server yields on `InvokeClient`. Don't use it in latency-critical paths.

## Alternative: Request-Reply via RemoteEvent

If you need request-response client → server, do this instead:

```lua
-- Client
local requestId = HttpService:GenerateGUID(false)
Remotes.RequestPurchase:FireServer(requestId, itemId)

-- Later, on reply
Remotes.PurchaseResult.OnClientEvent:Connect(function(responseId, result)
    if responseId == requestId then
        handleResult(result)
    end
end)
```

```lua
-- Server
Remotes.RequestPurchase.OnServerEvent:Connect(function(player, requestId, itemId)
    -- validate, process, reply
    local success, msg = processPurchase(player, itemId)
    Remotes.PurchaseResult:FireClient(player, requestId, { success = success, msg = msg })
end)
```

This has the same semantics without the hang risk.

## Related

- [[RemoteEvent]] — the preferred alternative
- [[UnreliableRemoteEvent]] — for cosmetic data
- [[client-to-server-remote-function]] — the forbidden anti-pattern
- [[server-authority]] — why this matters
- [Remotes Rules](../../.claude/rules/remotes.md)

## Sources

- [Roblox Creator Docs — RemoteFunction](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction)
- [wiki/raw/roblox-creator-docs/services/RemoteFunction.md](../raw/roblox-creator-docs/services/RemoteFunction.md)
- [.claude/agents/remotes-networking-specialist.md](../../.claude/agents/remotes-networking-specialist.md)
