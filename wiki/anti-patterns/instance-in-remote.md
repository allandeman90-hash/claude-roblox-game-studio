---
title: instance-in-remote
type: anti-pattern
category: anti-patterns
subcategory: security
owner: remotes-networking-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: medium
sources:
  - wiki/raw/roblox-creator-docs/best-practices/security/client-server-boundary.md
  - wiki/raw/community/articles/security/remote-event-security.md
  - .claude/rules/remotes.md
related:
  - "[[RemoteEvent]]"
  - "[[unvalidated-remote-args]]"
  - "[[argument-spoofing]]"
tags: [anti-pattern, security]
---

# Instance Reference in Remote

> Passing `Instance` references as RemoteEvent arguments. The client controls which Instance it sends, enabling spoofed object references and table-mimicry attacks.

**Severity:** Medium

## What It Looks Like

```lua
-- Client sends an Instance reference
local item = workspace.Shop.Items.UltraBlade
buyRemote:FireServer(item)

-- Server trusts the reference
buyRemote.OnServerEvent:Connect(function(player, item)
    local price = item.Price.Value  -- reads from the object the client sent
    if playerData[player].gold >= price then
        playerData[player].gold -= price
        giveItem(player, item.Name)
    end
end)
```

## Why It's Bad

1. **Object spoofing**: the client can send any Instance it has access to. Instead of the intended shop item, the exploiter sends a different object with a lower Price value, or an object from a different part of the DataModel entirely.
2. **Table mimicry**: as documented in the Roblox Creator Docs, exploiters can send a plain Lua table that mimics an Instance's interface (with `Name`, `ClassName`, and child-like fields). Without `typeof(item) == "Instance"` checks, the server treats the table as an object and reads attacker-controlled values.
3. **Cross-boundary leakage**: an exploiter might reference an Instance from `ServerStorage` that was briefly parented to a replicated container. If the server reads properties from it without verifying location, it may expose or modify server-only state.
4. **Nil dereference**: if the Instance was destroyed between the client sending it and the server processing it, `item.Price` throws an error. Without pcall, this crashes the handler.
5. **Arbitrary modification**: the Roblox Creator Docs warn against remotes that accept an Instance reference and modify it. An exploiter can reference any replicated Instance, turning a "modify item" remote into a "modify anything" remote.

## How to Fix It

Pass a string identifier (name, ID, or enum key) and resolve it server-side from a trusted source:

```lua
-- Client sends a string key
buyRemote:FireServer("UltraBlade")

-- Server resolves from its own authoritative data
local ItemDefinitions = require(ServerStorage.ItemDefinitions)

buyRemote.OnServerEvent:Connect(function(player, itemId)
    -- Type check
    if typeof(itemId) ~= "string" then return end
    if #itemId > 50 then return end

    -- Resolve from server-owned definitions
    local itemDef = ItemDefinitions[itemId]
    if not itemDef then return end

    -- Server owns the price
    if playerData[player].gold >= itemDef.price then
        playerData[player].gold -= itemDef.price
        addToInventory(player, itemId)
    end
end)
```

If you must accept an Instance (rare cases like targeting another player's character), validate it rigorously:

```lua
buyRemote.OnServerEvent:Connect(function(player, item)
    -- 1. Type check: must be an actual Instance, not a table
    if typeof(item) ~= "Instance" then return end

    -- 2. Location check: must be a descendant of the expected container
    if not item:IsDescendantOf(ReplicatedStorage.ItemData) then return end

    -- 3. Class check: must be the expected class
    if not item:IsA("Folder") then return end

    -- Now safe to read item properties
end)
```

## Detection

```
:FireServer(workspace
:FireServer(game
OnServerEvent.*Instance
\.Value  -- reading .Value from a remote argument without validation
```

Look for `OnServerEvent` handlers that index properties on arguments (like `.Price.Value`, `.Name`, `.Parent`) without first checking `typeof(arg) == "Instance"` and `arg:IsDescendantOf(expectedContainer)`.

## Related

- [[RemoteEvent]]
- [[unvalidated-remote-args]]
- [[argument-spoofing]]

## Sources

- [Roblox Creator Docs: Type and structure validation](../raw/roblox-creator-docs/best-practices/security/client-server-boundary.md) -- "Type and structure validation" with table mimicry example
- [Community: Securing RemoteEvents -- Core Patterns](../raw/community/articles/security/remote-event-security.md) -- "Sanity checks" section
- [Remotes Rules](../../.claude/rules/remotes.md) -- "Never send Instance references through remotes"
