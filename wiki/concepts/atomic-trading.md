---
title: atomic-trading
type: concept
category: concepts
subcategory: economy
owner: economy-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/devforum/session-locking-explained-datastore.md
  - wiki/raw/community/articles/datastore/datastore-best-practices.md
  - wiki/raw/community/devforum/profileservice-datastore-module.md
  - wiki/raw/community/devforum/profilestore-datastore-module.md
related:
  - "[[DataStoreService]]"
  - "[[session-locking]]"
  - "[[item-duplication]]"
  - "[[trading-system]]"
  - "[[inventory-pattern]]"
tags: [concept, economy, trading, atomic]
---

# Atomic Trading

> The pattern ensuring a trade between two players is all-or-nothing -- either both sides receive their items, or neither does, preventing item duplication and partial-trade corruption.

## What It Is

Atomic trading guarantees that a player-to-player item exchange is indivisible. If any step fails (validation, removal, addition, save), the entire operation rolls back. Without atomicity, a failure between removing items from player A and adding them to player B duplicates or destroys items.

This is not just a convenience -- it is a **security requirement**. The [[item-duplication]] exploit family targets exactly this gap.

## When to Use It

- Any player-to-player item exchange.
- NPC shop purchases where the cost and reward span different data domains.
- Cross-system transfers (e.g., converting currency to items) where partial completion would corrupt state.

## Implementation

### Same-Server Trading (Standard Case)

When both players are on the same server, their data is in memory (session-locked). The trade can execute within a single server frame, making it inherently atomic:

```lua
local function executeTrade(
    dataA,  -- player A's in-memory profile
    dataB,  -- player B's in-memory profile
    offerA: {[string]: number},  -- items A gives
    offerB: {[string]: number}   -- items B gives
): (boolean, string?)
    -- 1. Validate both sides can fulfill their offer
    for itemId, qty in pairs(offerA) do
        if InventoryService.getQuantity(dataA.inventory, itemId) < qty then
            return false, "A_insufficient"
        end
    end
    for itemId, qty in pairs(offerB) do
        if InventoryService.getQuantity(dataB.inventory, itemId) < qty then
            return false, "B_insufficient"
        end
    end

    -- 2. Validate recipients can receive
    -- (slot limits, stack limits, tradeable flags)

    -- 3. Remove from both (still in same frame)
    for itemId, qty in pairs(offerA) do
        InventoryService.remove(dataA.inventory, itemId, qty)
    end
    for itemId, qty in pairs(offerB) do
        InventoryService.remove(dataB.inventory, itemId, qty)
    end

    -- 4. Add to recipients
    for itemId, qty in pairs(offerA) do
        local ok, err = InventoryService.add(dataB.inventory, itemId, qty)
        if not ok then
            -- Rollback: put everything back
            rollbackTrade(dataA, dataB, offerA, offerB)
            return false, "add_failed: " .. err
        end
    end
    for itemId, qty in pairs(offerB) do
        local ok, err = InventoryService.add(dataA.inventory, itemId, qty)
        if not ok then
            rollbackTrade(dataA, dataB, offerA, offerB)
            return false, "add_failed: " .. err
        end
    end

    return true, nil
end
```

**Why this is atomic:** Both profiles are in-memory tables. All mutations happen in the same Luau execution frame. No yield points exist between the remove and add operations. If the server crashes mid-frame, neither profile has been saved yet (the dirty flag triggers a save on the next autosave or BindToClose), so the pre-trade state persists.

### Rollback Function

```lua
local function rollbackTrade(dataA, dataB, offerA, offerB)
    -- Return A's items
    for itemId, qty in pairs(offerA) do
        InventoryService.add(dataA.inventory, itemId, qty)
    end
    -- Return B's items
    for itemId, qty in pairs(offerB) do
        InventoryService.add(dataB.inventory, itemId, qty)
    end
end
```

### Cross-Server Trading (Advanced, Avoid If Possible)

If players are on different servers, their profiles are owned by different session locks. An atomic swap requires DataStore-level coordination:

```lua
-- Conceptual flow (not full implementation):
-- 1. Both servers agree on the trade terms (via MessagingService)
-- 2. Server A uses UpdateAsync to remove items from A's DataStore key
--    and write a "pending_trade" record
-- 3. Server B uses UpdateAsync to remove items from B's DataStore key
--    and write a "pending_trade" record
-- 4. A "finalize" step adds items to recipients
-- 5. If any step fails, a cleanup job reverses pending trades

-- This is dramatically more complex than same-server trading.
-- Most production Roblox games restrict trading to same-server only.
```

**Recommendation:** Avoid cross-server trading. Teleport both players to the same server for the trade, then teleport them back. This reduces the problem to the same-server case.

### ProfileStore Integration

ProfileStore (loleris) provides session locking that guarantees only one server owns a player's data at a time. This means same-server trades are safe as long as both players' profiles are loaded on the current server:

```lua
local profileA = Profiles[playerA]
local profileB = Profiles[playerB]

if not profileA or not profileB then
    return false, "profile_not_loaded"
end

-- Both profiles are session-locked to this server
-- Mutations are safe within a single frame
local ok = executeTrade(profileA.Data, profileB.Data, offerA, offerB)
```

## Variants

| Variant | Complexity | Safety |
|---------|-----------|--------|
| **Same-server in-memory swap** | Low | Full atomicity via single-frame execution |
| **Teleport-to-trade-server** | Medium | Same as above, with TeleportService overhead |
| **DataStore-level cross-server** | Very high | Requires multi-key transaction pattern |
| **Escrow model** | High | Items moved to a third "escrow" key, then distributed |

## Pitfalls

- **Yield points break atomicity.** If a `task.wait()`, DataStore call, or any yielding operation occurs between removing items from A and adding to B, the operation is no longer atomic. Another event (disconnect, error) can fire during the yield, leaving the system in a partial state.
- **Trade tax as currency sink.** Apply a percentage tax on traded currency (e.g., 5%) to act as a currency sink. This should be deducted during the atomic swap, not as a separate operation.
- **Player disconnect during trade.** Cancel the trade immediately if either player leaves. The `PlayerRemoving` event fires before the profile is saved, so unsaved in-memory mutations are still revertible.
- **Race between validation and execution.** Validate inventory quantities immediately before the swap, not during the offer phase. A player could spend items between locking their offer and confirming the trade.

## Related

- [[DataStoreService]] -- persistence layer for trade state
- [[session-locking]] -- guarantees only one server owns each profile
- [[item-duplication]] -- the exploit family this pattern prevents
- [[trading-system]] -- the full UX pattern built on this concept
- [[inventory-pattern]] -- the item storage layer

## Sources

- [wiki/raw/community/devforum/session-locking-explained-datastore.md](../raw/community/devforum/session-locking-explained-datastore.md) -- session locking prevents cross-server data corruption
- [wiki/raw/community/articles/datastore/datastore-best-practices.md](../raw/community/articles/datastore/datastore-best-practices.md) -- UpdateAsync for atomic operations
- [wiki/raw/community/devforum/profileservice-datastore-module.md](../raw/community/devforum/profileservice-datastore-module.md) -- session locking implementation
- [wiki/raw/community/devforum/profilestore-datastore-module.md](../raw/community/devforum/profilestore-datastore-module.md) -- modern session-locked profile management
