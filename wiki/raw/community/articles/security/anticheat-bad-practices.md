---
title: Anticheat Bad Practices and What Exploiters Can Actually Do
type: raw-source
source_url: https://devforum.roblox.com/t/securing-your-anticheat-common-bad-practices-and-how-powerful-are-exploiters-guide-on-handshakes/2519952
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: security
tags: [anticheat, exploits, handshakes, bad-practices, security]
---

# Anticheat Bad Practices and What Exploiters Can Actually Do

**Source:** Roblox DevForum community tutorial — "Securing your anticheat: Common bad practices, and how powerful are exploiters"

## What exploiters can actually do

This guide is primarily about calibrating your expectations of how far an attacker can reach. The TL;DR: on a Roblox client, an exploit tool has effectively god-mode over the client's Lua state. It can:

- Read and write any ModuleScript that has been required
- Hook (intercept and rewrite) any function in the global environment, including `rawget`, `rawequal`, `string.sub`, `tostring`, etc.
- Spawn arbitrary threads that run alongside your code
- Walk the DataModel and inspect every Instance
- Fire any `RemoteEvent`/`RemoteFunction` with any argument, from any context
- Spoof caller identity (on advanced executors) so `getfenv(0)`/`getfenv(1)` checks can be bypassed

What they cannot do (yet):
- Inspect server-side code or server-only ModuleScripts (those live in `ServerScriptService`/`ServerStorage`)
- Read data from DataStores (that's server-side)
- Forge the source of a RemoteEvent's `OnServerEvent` (the server knows which connection fired)

These constraints are what make server-authoritative patterns the only ones that hold up.

## Common bad practices

### 1. Using RemoteEvents for tamper signals

Pattern: "If the client-side anticheat detects X, fire a RemoteEvent to the server." The problem is exploiters can easily bypass this method by hooking the function. They look at the metatable of the remote, see your FireServer call, and intercept it to never fire.

> The guide recommends using RemoteFunctions instead, as they are "harder to spy on" preventing a large number of script developers from spying on the anticheat remote.

But the deeper point: any client-side detection signal can be suppressed by the client. The question isn't "how do I send the signal more reliably" — it's "why am I trusting the client to report on itself at all?"

### 2. Client-side noclip/physics checks

Pattern: "Raycast from the client to detect if the character is inside a wall, then report to the server." The fundamental flaw: exploiters can spoof position values, causing raycasts to return nothing and bypass checks entirely. The raycast happens in the client's view of the world, and the exploit tool controls that view.

Position-based noclip detection belongs on the server, where the physics simulation is authoritative.

### 3. Relying on `rawequal`, `rawget`, `rawset`

Pattern: "Use `rawget(obj, 'x')` to bypass `__index` metamethods that an exploiter may have overridden." The flaw: functions like `rawequal` can themselves be hooked and spoofed through exploiter functions. The raw-accessor trick works against bad exploits and fails against good ones.

### 4. String-matching ban lists of known exploit function names

Pattern: "Check if `getgenv().synapse` exists; if it does, ban." Exploit tools explicitly rename their functions to evade this check, and advanced tools spoof caller info so `getfenv` lies.

## What exploit power actually depends on

Exploit capability varies dramatically across tools:

- **High-end executors** (Synapse X historically) expose functions like `syn.trampoline_call` for spoofing caller information, full Lua bytecode dumps, and hooks that can intercept `game:FindFirstChild` at the C++ level.
- **Mid-tier executors** give Lua-level environment access but miss deep hooks.
- **Free executors** often have partial API support and are more detectable.

Within a single game, most cheaters are using script consumers — people running scripts made by other people. These users have less technical skill than the script's author and are generally not capable of adapting a script to bypass a custom check. Your anticheat is really playing two games at once:
- Against **script authors** who will eventually bypass any client-side trick
- Against **script consumers** who follow the path of least resistance

Building checks that the script consumer can't simply turn off — checks that live entirely on the server — is the only lasting defense.

## The handshake pattern

For cases where you must run *some* code on the client (e.g. to observe what the client sees), the guide proposes encryption-based handshakes:

1. The server periodically sends a random challenge string to the client.
2. The client must cipher the challenge using a shared-secret algorithm and return the response.
3. The server verifies the response and kicks the client if it's wrong or missing after a timeout (~60 seconds).

This detects:
- **Deleted/yielded anticheat scripts** — the client can't produce the response because the ciphering code is gone
- **Script replay attacks** — each challenge is random, so recording and replaying a previous response fails
- **Tampering with the anticheat module** — if the exploiter modifies the cipher function, the response is wrong

The handshake isn't cryptographically secure (a dedicated attacker can reverse-engineer the cipher and reimplement it outside the anticheat module), but it raises the bar high enough to deter script consumers. It's specifically a counter-measure against the "just yield the anticheat script" class of attack.

## Implementation sketch

```lua
-- Server
local OUTSTANDING = {}  -- [player.UserId] = {challenge, deadline}
local HANDSHAKE_REMOTE = game.ReplicatedStorage:FindFirstChild("Handshake") or Instance.new("RemoteFunction", game.ReplicatedStorage)
HANDSHAKE_REMOTE.Name = "Handshake"

local function issueChallenge(player)
    local challenge = generateRandomString(16)
    OUTSTANDING[player.UserId] = {
        challenge = challenge,
        deadline = os.clock() + 60,
    }
    task.spawn(function()
        local ok, response = pcall(function()
            return HANDSHAKE_REMOTE:InvokeClient(player, challenge)
        end)
        if not ok or response ~= expectedCipher(challenge) then
            player:Kick("Anticheat handshake failed")
        end
        OUTSTANDING[player.UserId] = nil
    end)
end

task.spawn(function()
    while true do
        task.wait(30)  -- challenge every 30 seconds
        for _, player in ipairs(Players:GetPlayers()) do
            issueChallenge(player)
        end
    end
end)
```

Notes:
- The cipher function must live inside the anticheat LocalScript. If the exploit deletes or yields that script, the InvokeClient call returns nothing and the server kicks.
- The 60-second timeout accounts for legit network hiccups; tune for your game.
- Rotate the cipher algorithm every few weeks so script authors can't cache a working response.

## The honest conclusion

Client-side anticheat is a deterrent, not a wall. Its only real value is raising the cost of cheating high enough that:
- Free scripts don't work against your game
- Script consumers give up and move on
- You catch the naive attackers

For anything that actually matters (currency, items, progression, competitive outcomes), **server-authoritative validation is the only defense**. Everything else is the cost floor before your server-side checks kick in.

## Source

Original URL: https://devforum.roblox.com/t/securing-your-anticheat-common-bad-practices-and-how-powerful-are-exploiters-guide-on-handshakes/2519952
Captured: 2026-04-15
