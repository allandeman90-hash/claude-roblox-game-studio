---
title: client-to-server-remote-function
type: anti-pattern
category: anti-patterns
subcategory: security
owner: remotes-networking-specialist
status: draft
created: 2026-04-16
updated: 2026-04-16
severity: high
sources:
  - wiki/raw/roblox-creator-docs/best-practices/security/client-server-boundary.md
  - wiki/raw/community/articles/security/remote-event-security.md
  - .claude/rules/remotes.md
  - .claude/docs/roblox-architecture-guide.md
related:
  - "[[RemoteFunction]]"
  - "[[RemoteEvent]]"
  - "[[remote-spam]]"
tags: [anti-pattern, security]
---

# Client -> Server RemoteFunction

> Setting `OnServerInvoke` on a RemoteFunction so the client can call it. The server thread blocks until the client returns -- which a malicious client never will.

**Severity:** High

## What It Looks Like

```lua
-- Server script: accepts client invocations
local remote = ReplicatedStorage:WaitForChild("GetPlayerStats")

remote.OnServerInvoke = function(player)
    -- This function blocks the server thread until it returns
    return {
        gold = playerData[player].gold,
        level = playerData[player].level,
    }
end
```

```lua
-- Client script: invokes the server
local remote = ReplicatedStorage:WaitForChild("GetPlayerStats")
local stats = remote:InvokeServer()
```

The pattern looks harmless, but the inverse is the real danger: if the **server** calls `InvokeClient` and the client never responds, the server thread hangs forever. More critically, if the client calls `InvokeServer` and the handler yields waiting on the client in any nested way, the server cannot time out the call.

The broader risk: `OnServerInvoke` creates a synchronous request-response contract where the server must trust the client to cooperate. An exploiter can fire `InvokeServer` with malicious arguments and the server's yielding handler cannot be cancelled.

## Why It's Bad

1. **Server thread hang**: `RemoteFunction:InvokeClient()` blocks the server thread until the client returns. A malicious client can hook the callback to never return, permanently consuming a server thread. There is no built-in timeout mechanism.
2. **Uncontrollable yielding**: even without `InvokeClient`, if the `OnServerInvoke` handler yields (e.g., waiting on a DataStore), the client's thread is blocked, but more importantly the pattern encourages designs where server logic is coupled to client request timing.
3. **No rate limit support**: RemoteFunction invocations are harder to rate-limit than RemoteEvent fires because the server must return a value. Dropping the call silently is not straightforward.
4. **Queue exhaustion**: rapid `InvokeServer` calls from an exploiter queue up server-side handlers that each consume a thread. Combined with yielding handlers, this can exhaust the server's thread pool.

## How to Fix It

Replace with a RemoteEvent pair (request + response):

```lua
-- Server
local requestRemote = ReplicatedStorage:WaitForChild("RequestStats")
local responseRemote = ReplicatedStorage:WaitForChild("ResponseStats")

requestRemote.OnServerEvent:Connect(function(player)
    -- Rate limit check here
    local stats = {
        gold = playerData[player].gold,
        level = playerData[player].level,
    }
    responseRemote:FireClient(player, stats)
end)
```

```lua
-- Client
local requestRemote = ReplicatedStorage:WaitForChild("RequestStats")
local responseRemote = ReplicatedStorage:WaitForChild("ResponseStats")

requestRemote:FireServer()
responseRemote.OnClientEvent:Connect(function(stats)
    updateUI(stats)
end)
```

If a synchronous return value is needed on the client, wrap the event pair with a Promise or a one-shot callback:

```lua
-- Client utility
local function requestAsync(requestRemote, responseRemote, timeout)
    timeout = timeout or 5
    requestRemote:FireServer()
    local result
    local conn
    conn = responseRemote.OnClientEvent:Connect(function(data)
        result = data
        conn:Disconnect()
    end)
    local start = time()
    while not result and (time() - start) < timeout do
        task.wait()
    end
    if conn.Connected then conn:Disconnect() end
    return result
end
```

**Exception**: `RemoteFunction` is acceptable for **Server -> Client** direction (`InvokeClient`) in non-critical scenarios where the server can tolerate the client not responding (with a manual timeout wrapper). Even then, prefer RemoteEvents.

## Detection

```
OnServerInvoke
:InvokeServer(
RemoteFunction.*OnServerInvoke
```

Any `OnServerInvoke` assignment is a violation. The project rule is: no Client -> Server RemoteFunctions.

## Related

- [[RemoteFunction]]
- [[RemoteEvent]]
- [[remote-spam]]

## Sources

- [Roblox Creator Docs: RemoteEvents and RemoteFunctions](../raw/roblox-creator-docs/best-practices/security/client-server-boundary.md) -- "RemoteEvents and RemoteFunctions" section
- [Remotes Rules](../../.claude/rules/remotes.md) -- "No Client->Server RemoteFunctions" rule
- [Architecture Guide](../../.claude/docs/roblox-architecture-guide.md) -- Section 4: Networking: Remotes
