---
title: trading-system
type: pattern
category: patterns
subcategory: economy
owner: economy-designer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/devforum/session-locking-explained-datastore.md
  - wiki/raw/community/articles/datastore/datastore-best-practices.md
related:
  - "[[atomic-trading]]"
  - "[[item-duplication]]"
  - "[[inventory-pattern]]"
  - "[[session-locking]]"
  - "[[DataStoreService]]"
  - "[[rate-limiting]]"
tags: [pattern, economy, trading]
---

# Trading System

> Player-to-player item exchange using an offer-accept-confirm flow with atomic swap to prevent item duplication.

## Summary

A trading system allows two players on the same server to exchange items. The pattern follows a multi-step flow: initiate trade, both players set their offers, both confirm, the server validates and executes an [[atomic-trading]] swap. Every step is server-authoritative. The system includes anti-abuse measures: trade tax (currency sink), per-day limits, account-age gates, and restricted-item lists.

## When to Use It

- Games with player-driven economies (RPGs, simulators, pet collectors).
- Any game where items have subjective value and players want to exchange.
- Do NOT add trading to games where item scarcity is not a design goal -- it creates secondary markets and RWT pressure.

## Implementation

### Trade State Machine

```
Idle → Invited → Offering → Locked → Confirmed → Executing → Complete
                                                          └→ Failed
```

```lua
-- ServerStorage/Services/TradeService.lua
local TradeService = {}

local InventoryService = require(...)

export type TradeState = "invited" | "offering" | "locked" | "confirmed" | "executing" | "complete" | "failed"

export type TradeSession = {
    id: string,
    playerA: Player,
    playerB: Player,
    offerA: {[string]: number},  -- itemId → quantity
    offerB: {[string]: number},
    lockedA: boolean,
    lockedB: boolean,
    confirmedA: boolean,
    confirmedB: boolean,
    state: TradeState,
    createdAt: number,
}

local activeTrades: {[string]: TradeSession} = {}
local playerTrade: {[Player]: string} = {}  -- player → tradeId

local TRADE_TIMEOUT = 120  -- seconds
local MAX_TRADES_PER_DAY = 20
local MIN_ACCOUNT_AGE_DAYS = 7
local TRADE_TAX_RATE = 0.05  -- 5% currency tax
```

### Initiation with Anti-Abuse Gates

```lua
function TradeService.invite(initiator: Player, target: Player): (boolean, string?)
    -- Gate: already in a trade
    if playerTrade[initiator] or playerTrade[target] then
        return false, "busy"
    end

    -- Gate: account age
    if initiator.AccountAge < MIN_ACCOUNT_AGE_DAYS
    or target.AccountAge < MIN_ACCOUNT_AGE_DAYS then
        return false, "account_too_new"
    end

    -- Gate: daily trade limit (tracked in player data)
    -- if playerData.tradesToday >= MAX_TRADES_PER_DAY then return false, "daily_limit" end

    -- Gate: same server
    if not target:IsDescendantOf(game) then
        return false, "player_left"
    end

    local tradeId = game:GetService("HttpService"):GenerateGUID(false)
    local session: TradeSession = {
        id = tradeId,
        playerA = initiator,
        playerB = target,
        offerA = {},
        offerB = {},
        lockedA = false,
        lockedB = false,
        confirmedA = false,
        confirmedB = false,
        state = "invited",
        createdAt = os.time(),
    }

    activeTrades[tradeId] = session
    playerTrade[initiator] = tradeId
    -- Notify target via RemoteEvent
    return true, nil
end
```

### Offer, Lock, Confirm

```lua
function TradeService.setOffer(player: Player, items: {[string]: number}): boolean
    local session = getSessionForPlayer(player)
    if not session or session.state ~= "offering" then return false end

    -- Validate all items exist in player's inventory and quantities are valid
    local inventory = PlayerDataService.getData(player).inventory
    for itemId, qty in pairs(items) do
        if typeof(itemId) ~= "string" or typeof(qty) ~= "number" then return false end
        if qty <= 0 or qty ~= math.floor(qty) then return false end
        if InventoryService.getQuantity(inventory, itemId) < qty then return false end
        -- Check item is tradeable
        if not ItemConfig[itemId] or not ItemConfig[itemId].tradeable then return false end
    end

    if player == session.playerA then
        session.offerA = items
    else
        session.offerB = items
    end
    return true
end

function TradeService.lock(player: Player): boolean
    local session = getSessionForPlayer(player)
    if not session or session.state ~= "offering" then return false end

    if player == session.playerA then session.lockedA = true
    else session.lockedB = true end

    if session.lockedA and session.lockedB then
        session.state = "locked"
    end
    return true
end

function TradeService.confirm(player: Player): boolean
    local session = getSessionForPlayer(player)
    if not session or session.state ~= "locked" then return false end

    if player == session.playerA then session.confirmedA = true
    else session.confirmedB = true end

    if session.confirmedA and session.confirmedB then
        session.state = "confirmed"
        TradeService.execute(session)
    end
    return true
end
```

### Atomic Execution

```lua
function TradeService.execute(session: TradeSession)
    session.state = "executing"

    local dataA = PlayerDataService.getData(session.playerA)
    local dataB = PlayerDataService.getData(session.playerB)
    if not dataA or not dataB then
        TradeService.fail(session, "data_unavailable")
        return
    end

    -- Re-validate both offers against current inventories
    for itemId, qty in pairs(session.offerA) do
        if InventoryService.getQuantity(dataA.inventory, itemId) < qty then
            TradeService.fail(session, "insufficient_items_A")
            return
        end
    end
    for itemId, qty in pairs(session.offerB) do
        if InventoryService.getQuantity(dataB.inventory, itemId) < qty then
            TradeService.fail(session, "insufficient_items_B")
            return
        end
    end

    -- Remove from both (atomic within single server frame)
    for itemId, qty in pairs(session.offerA) do
        InventoryService.remove(dataA.inventory, itemId, qty)
    end
    for itemId, qty in pairs(session.offerB) do
        InventoryService.remove(dataB.inventory, itemId, qty)
    end

    -- Add to recipients
    for itemId, qty in pairs(session.offerA) do
        InventoryService.add(dataB.inventory, itemId, qty)
    end
    for itemId, qty in pairs(session.offerB) do
        InventoryService.add(dataA.inventory, itemId, qty)
    end

    -- Apply trade tax on currency items if applicable
    -- TradeService.applyTax(dataA, dataB, session)

    session.state = "complete"
    TradeService.cleanup(session)
end

function TradeService.fail(session: TradeSession, reason: string)
    session.state = "failed"
    -- Notify both players
    TradeService.cleanup(session)
end

function TradeService.cleanup(session: TradeSession)
    playerTrade[session.playerA] = nil
    playerTrade[session.playerB] = nil
    activeTrades[session.id] = nil
end
```

## Anti-Abuse Measures

| Measure | Purpose |
|---------|---------|
| **Account age gate** (7+ days) | Prevents alt-farming for RWT |
| **Daily trade limit** (20/day) | Rate-limits economy manipulation |
| **Trade tax** (5% currency) | Currency sink, discourages wash trades |
| **Same-value warning** | Alert if offer values are severely unbalanced |
| **Restricted item list** | Event-exclusive or untradeable items blocked |
| **Trade logging** | Full audit trail for moderation review |
| **Confirmation step** | Two-phase confirm prevents swap scams |

## Pitfalls

- **Item duplication.** The critical risk. Both profiles must be modified within a single server frame while both are session-locked. If either player disconnects mid-trade, the cleanup must not leave items in limbo. See [[atomic-trading]] and [[item-duplication]].
- **Cross-server trading.** Same-server trades are safe because both profiles are in-memory. Cross-server trading requires DataStore-level atomic swaps via `UpdateAsync`, which is dramatically more complex. Avoid unless strictly necessary.
- **Scam UX.** Implement a "locked" phase where neither player can change their offer, followed by a separate "confirm" phase. Without this, a player can swap items at the last second.
- **Player disconnect.** If either player leaves during the trade, cancel immediately and ensure no items were moved.

## Related

- [[atomic-trading]] -- the concept ensuring all-or-nothing swaps
- [[item-duplication]] -- the exploit this system must prevent
- [[inventory-pattern]] -- the underlying item storage
- [[session-locking]] -- ensures only one server owns each profile
- [[rate-limiting]] -- anti-abuse on trade remotes

## Sources

- [wiki/raw/community/devforum/session-locking-explained-datastore.md](../raw/community/devforum/session-locking-explained-datastore.md)
- [wiki/raw/community/articles/datastore/datastore-best-practices.md](../raw/community/articles/datastore/datastore-best-practices.md)
