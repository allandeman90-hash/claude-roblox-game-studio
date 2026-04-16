---
title: client-trust
type: anti-pattern
category: anti-patterns
subcategory: security
owner: exploit-security-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: critical
sources:
  - .claude/agents/exploit-security-specialist.md
  - .claude/rules/server-scripts.md
related:
  - "[[server-authority]]"
  - "[[RemoteEvent]]"
  - "[[rate-limiting]]"
  - "[[unvalidated-remote-args]]"
  - "[[item-duplication]]"
  - "[[speed-hack]]"
tags: [anti-pattern, security, critical]
---

# Client Trust

> Treating any value received from the client as reliable. The root cause of virtually every Roblox exploit.

**Severity:** Critical

## What It Looks Like

```lua
-- ❌ Bad: server trusts client-sent state
Remotes.SetGold.OnServerEvent:Connect(function(player, newGold)
    PlayerData.get(player).gold = newGold
end)

-- ❌ Bad: server trusts an item claim
Remotes.UseItem.OnServerEvent:Connect(function(player, itemId, effect)
    applyEffect(player, effect)  -- what if client sent a spoofed effect?
end)

-- ❌ Bad: server trusts client position
Remotes.TeleportTo.OnServerEvent:Connect(function(player, targetCFrame)
    player.Character.HumanoidRootPart.CFrame = targetCFrame
end)

-- ❌ Bad: server reads LocalPlayer-side state
-- (This one's in a LocalScript — but using it to determine server-side truth is wrong)
local isAdmin = game.ReplicatedStorage.AdminList[game.Players.LocalPlayer.UserId]
Remotes.AdminAction:FireServer(isAdmin, "ban", targetUserId)  -- hopes server trusts the flag
```

## Why It's Bad

The Roblox client runs in an untrusted environment. Exploit tools (Synapse X, Script-Ware, Krnl) inject arbitrary Luau into the local client process. An exploiter can:

- Read any client-side table
- Call any function in the local environment
- Fire any `RemoteEvent` with any arguments
- Modify any `LocalPlayer` property
- Freeze the client mid-execution and inject values

**None of this is preventable**. Roblox does not sandbox the client process against the user who owns it.

The only defense is **server authority**: the server assumes every client-sent value is a lie until proven otherwise. Validated locally. Cross-checked against the server's own state. Range-checked. Rate-limited. Sanity-checked.

Any place you trust the client is where your game breaks next week.

## Examples of Exploits That Client Trust Enables

- **Infinite currency**: `SetGold.OnServerEvent` that accepts a new gold value → exploiter sends `1e308`
- **Item duplication**: `UseItem` that doesn't verify ownership → exploiter sends any item ID
- **Teleport hack**: server applies `targetCFrame` without distance checks → exploiter teleports across map
- **Speed hack**: server doesn't re-check player position → exploiter runs at 1000 studs/sec
- **God mode**: client says "I didn't take damage" → server believes it
- **Purchase replay**: client re-fires "I bought X" → server grants again
- **Admin escalation**: client sends `isAdmin = true` → server trusts the flag

## How to Fix It

Invert the trust relationship. The client **asks** the server for things; the server **decides** using its own state.

```lua
-- ✅ Good: server decides
Remotes.PurchaseItem.OnServerEvent:Connect(function(player, itemId)
    -- Validate shape
    if typeof(itemId) ~= "string" or #itemId > 50 then return end

    -- Rate limit
    if isRateLimited(player) then return end

    -- Sanity
    local item = ShopConfig[itemId]
    if not item then return end

    -- Authority: server reads its own truth
    local data = PlayerData.get(player)
    if data.gold < item.price then return end  -- not client's claim, server's truth

    -- Perform the mutation server-side
    data.gold -= item.price
    Inventory.addItem(data, itemId)

    -- Tell the client what happened (for UI only)
    Remotes.PurchaseSuccess:FireClient(player, itemId, data.gold)
end)
```

The server:
1. Validates the **shape** of every argument
2. Checks a **rate limit**
3. Sanity-checks against config
4. Makes the decision from **its own** state
5. Tells the client the result (for UI)

The client never gets to say "here's my new gold value."

## Detection

Grep for red flags in server code:

```bash
# Server code that assigns from client-sent data
grep -rnE "OnServerEvent:Connect" src/ServerScriptService | grep -A 3 "function(player"
```

Manual review needed to spot:
- `data.<field> = <arg>` inside a remote handler (assignment from client arg)
- Missing type check before use
- Missing range check
- Missing sanity check (does the action even make sense?)
- Missing rate limit

Also:
```bash
# Find servers reading ReplicatedStorage secrets (they shouldn't exist)
grep -rn "ReplicatedStorage.*AdminList\|ReplicatedStorage.*ApiKey" src/
```

## Related

- [[server-authority]] — the correct mental model
- [[RemoteEvent]] — where most client-trust violations happen
- [[rate-limiting]] — complementary defense
- [[unvalidated-remote-args]] — the specific sub-pattern
- [[item-duplication]] — exploit enabled by this
- [[speed-hack]] — exploit enabled by this
- [Server Scripts Rules](../../.claude/rules/server-scripts.md)

## Sources

- [.claude/agents/exploit-security-specialist.md](../../.claude/agents/exploit-security-specialist.md)
- [.claude/rules/server-scripts.md](../../.claude/rules/server-scripts.md)
- [wiki/raw/roblox-creator-docs/best-practices/security/client-server-boundary.md](../raw/roblox-creator-docs/best-practices/security/client-server-boundary.md)
