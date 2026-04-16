---
title: server-authority
type: concept
category: concepts
subcategory: security
owner: technical-director
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - .claude/agents/technical-director.md
  - .claude/agents/exploit-security-specialist.md
  - .claude/rules/server-scripts.md
  - .claude/docs/roblox-architecture-guide.md
related:
  - "[[client-server-split]]"
  - "[[rate-limiting]]"
  - "[[RemoteEvent]]"
  - "[[client-trust]]"
  - "[[unvalidated-remote-args]]"
  - "[[speed-hack]]"
  - "[[item-duplication]]"
tags: [concept, security, foundational]
---

# Server Authority

> The foundational security principle of Roblox development: the server is the only trusted actor. Every game-state mutation happens on the server, validated from first principles.

## What It Is

Server authority is the model where:

1. **Only the server owns game state.** Health, currency, inventory, score, position (for anti-cheat), quest progress — all lives in server-side memory and DataStores.
2. **The client is a thin presentation layer.** It reads replicated state from the server, renders it, and sends input events. It does not *own* anything game-critical.
3. **Every client → server message is distrusted.** The server treats every argument as attacker-controlled and validates from scratch.

This is the single most important concept on Roblox. Every exploit vector on the platform traces back to a violation of server authority.

## Why It Matters

Roblox clients can be modified. Exploit tools like Synapse X, Script-Ware, and Krnl inject arbitrary Luau code into the local client process. An exploiter can:
- Read any client-side table
- Modify any `LocalPlayer` property
- Fire any `RemoteEvent` with any arguments
- Inspect every ReplicatedStorage module

None of this is preventable. But **it doesn't matter** if the server never trusts the client. The client can lie about anything it wants — as long as the server validates, the lies never affect persistent state or other players.

The only way to lose is to trust the client. The way to win is: **never trust the client**.

## When to Use It

**Always.** There is no Roblox game that should not follow this rule. Even single-player-feeling experiences run on a shared server; even cosmetic-only purchases can be exploited if the server doesn't gatekeep.

Client-side game state is acceptable for:
- UI state (menus, tooltips, hover effects)
- Visual prediction (rubber-banded to server)
- Local settings (graphics quality, audio volume)
- Input handling (which is then sent to the server)

Client-side game state is **not** acceptable for:
- Currency, inventory, XP, stats
- Quest progression
- Ability cooldowns (for actual cooldown enforcement; visual countdowns are fine)
- Combat damage application
- Movement validation
- Purchase decisions

## Implementation

### The "Server Validates" Pattern for Every RemoteEvent

```lua
Remotes.PurchaseItem.OnServerEvent:Connect(function(player, itemId)
    -- Server owns: the authoritative inventory and currency
    -- Client sent: a request to spend currency on an item

    -- 1. Type validation
    if typeof(itemId) ~= "string" then return end
    if #itemId > 50 then return end

    -- 2. Rate limit (see [[rate-limiting]])
    if isRateLimited(player) then return end

    -- 3. Sanity: does this item exist?
    local itemDef = ShopConfig[itemId]
    if not itemDef then return end

    -- 4. Authority check: does the player have the currency?
    local data = PlayerData.get(player)
    if data.gold < itemDef.price then return end

    -- 5. Perform the state mutation (server-owned)
    data.gold -= itemDef.price
    Inventory.addItem(data, itemId)
    PlayerData.save(player)  -- eventually

    -- 6. Tell the client what happened (for UI)
    Remotes.PurchaseSuccess:FireClient(player, itemId, data.gold)
end)
```

The client does not mutate `data.gold` — it can't, because `data` is in server memory. The client just asks, and the server says yes/no based on its own authoritative view.

### Movement: Server-Validated or Server-Reconciled

For player movement, full server authority is too slow (latency makes the character feel laggy). The usual compromise:

- **Client predicts** its own movement locally for responsiveness.
- **Server validates** position updates with a **tolerance**: sudden huge jumps, high velocity, or teleporting through walls are rejected.
- **Server reconciles** by snapping the client back to a server-authoritative position if they cheat.

```lua
-- Server tick (every few hundred ms)
for _, player in ipairs(game.Players:GetPlayers()) do
    local hrp = player.Character and player.Character.PrimaryPart
    if not hrp then continue end

    local lastPos = lastServerPositions[player]
    if lastPos then
        local dist = (hrp.Position - lastPos).Magnitude
        if dist > MAX_EXPECTED_DISTANCE then
            -- snap them back
            hrp.CFrame = CFrame.new(lastPos)
        end
    end
    lastServerPositions[player] = hrp.Position
end
```

See [[speed-hack]] and [[teleport-hack]] for specific mitigations.

## Variants

- **Strict server authority**: server rejects invalid state outright (e.g., can't buy without gold). The default.
- **Server reconciliation**: client predicts, server corrects (movement, latency-critical gameplay).
- **Client authoritative + trusted telemetry**: rare, fragile, not recommended outside very specific scenarios.

## Pitfalls

- **Client-side validation only**: you can only hide the warning label; the server still needs to check.
- **Trusting values in `LocalPlayer`**: `LocalPlayer.leaderstats.Gold` is a replicated display — the real value lives server-side.
- **Exposing config to client**: ReplicatedStorage is readable by clients. Sensitive data (admin lists, API keys) must live in `ServerStorage` or `ServerScriptService` only.
- **RemoteFunctions from client**: server thread hangs on client non-response. See [[client-to-server-remote-function]].
- **Mutation via Instance properties**: replicating a Part property doesn't give the client authority over that property. But *a LocalScript editing a BasePart* can trigger a local replication the server will see... beware: test whether replicated change originates from an untrusted client.
- **Trusting `player.Name`**: names change. Use `UserId`.

## Related

- [[client-server-split]] — the broader architecture
- [[rate-limiting]] — required for every client → server remote
- [[RemoteEvent]] — the primary client → server channel
- [[client-trust]] — anti-pattern this defends against
- [[unvalidated-remote-args]] — most common violation
- [[speed-hack]], [[teleport-hack]], [[item-duplication]] — exploits this defends against
- [Server Scripts Rules](../../.claude/rules/server-scripts.md)
- [Client Scripts Rules](../../.claude/rules/client-scripts.md)

## Sources

- [.claude/agents/technical-director.md](../../.claude/agents/technical-director.md)
- [.claude/agents/exploit-security-specialist.md](../../.claude/agents/exploit-security-specialist.md)
- [.claude/docs/roblox-architecture-guide.md](../../.claude/docs/roblox-architecture-guide.md)
- [wiki/raw/roblox-creator-docs/best-practices/security/server-authority-index.md](../raw/roblox-creator-docs/best-practices/security/server-authority-index.md)
- [wiki/raw/roblox-creator-docs/best-practices/security/client-server-boundary.md](../raw/roblox-creator-docs/best-practices/security/client-server-boundary.md)
