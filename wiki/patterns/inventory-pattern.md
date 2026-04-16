---
title: inventory-pattern
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/devforum/profileservice-datastore-module.md
  - wiki/raw/community/devforum/profilestore-datastore-module.md
  - wiki/raw/community/articles/datastore/datastore-best-practices.md
related:
  - "[[DataStoreService]]"
  - "[[schema-versioning]]"
  - "[[atomic-trading]]"
  - "[[trading-system]]"
  - "[[session-locking]]"
tags: [pattern, gameplay, inventory, items]
---

# Inventory Pattern

> Server-authoritative item storage using a dictionary of item IDs to quantities, with atomic operations and max-slot enforcement.

## Summary

The inventory pattern stores a player's owned items as a flat dictionary `{[itemId]: quantity}` inside the player's DataStore profile. All mutations (add, remove, check) run server-side through an `InventoryService`. The client receives a read-only snapshot for rendering the UI. This pattern supports stackable items, unique items (quantity = 1), slot limits, and integrates cleanly with [[atomic-trading]] for player-to-player exchanges.

## When to Use It

- Any game with collectible items, currencies, or equipment.
- Pet collectors, tycoons, RPGs, simulators -- virtually every monetized Roblox game.
- Pair with [[trading-system]] when players exchange items.

## Implementation

### Data Schema

```lua
-- Inside player data template
inventory = {
    items = {},          -- { [itemId: string]: number }
    maxSlots = 50,       -- server-enforced cap
}
-- Example populated:
-- items = { Sword_01 = 1, HealthPotion = 12, GoldCoin = 5430 }
```

### Item Definition Config

```lua
-- ReplicatedStorage/Shared/Config/ItemConfig.lua
return {
    Sword_01 = {
        displayName = "Iron Sword",
        category = "weapon",
        maxStack = 1,         -- unique items
        tradeable = true,
        rarity = "common",
    },
    HealthPotion = {
        displayName = "Health Potion",
        category = "consumable",
        maxStack = 99,
        tradeable = true,
        rarity = "common",
    },
    GoldCoin = {
        displayName = "Gold Coin",
        category = "currency",
        maxStack = math.huge,  -- no stack limit
        tradeable = false,
        rarity = "common",
    },
}
```

### InventoryService (Server)

```lua
-- ServerStorage/Services/InventoryService.lua
local InventoryService = {}

local ItemConfig = require(game.ReplicatedStorage.Shared.Config.ItemConfig)

function InventoryService.getQuantity(inventory, itemId: string): number
    return inventory.items[itemId] or 0
end

function InventoryService.contains(inventory, itemId: string): boolean
    return (inventory.items[itemId] or 0) > 0
end

function InventoryService.canAfford(inventory, costs: {[string]: number}): boolean
    for itemId, amount in pairs(costs) do
        if InventoryService.getQuantity(inventory, itemId) < amount then
            return false
        end
    end
    return true
end

function InventoryService.slotCount(inventory): number
    local count = 0
    for _ in pairs(inventory.items) do
        count += 1
    end
    return count
end

function InventoryService.add(
    inventory,
    itemId: string,
    amount: number
): (boolean, string?)
    local config = ItemConfig[itemId]
    if not config then
        return false, "unknown_item"
    end

    amount = math.floor(math.max(0, amount))
    if amount == 0 then return true, nil end

    local current = inventory.items[itemId] or 0

    -- Slot limit check (only for new items)
    if current == 0 and InventoryService.slotCount(inventory) >= inventory.maxSlots then
        return false, "inventory_full"
    end

    -- Stack limit check
    if current + amount > config.maxStack then
        return false, "stack_full"
    end

    inventory.items[itemId] = current + amount
    return true, nil
end

function InventoryService.remove(
    inventory,
    itemId: string,
    amount: number
): (boolean, string?)
    amount = math.floor(math.max(0, amount))
    local current = inventory.items[itemId] or 0

    if current < amount then
        return false, "insufficient"
    end

    local newAmount = current - amount
    if newAmount == 0 then
        inventory.items[itemId] = nil  -- free the slot
    else
        inventory.items[itemId] = newAmount
    end
    return true, nil
end

function InventoryService.transfer(
    fromInventory,
    toInventory,
    itemId: string,
    amount: number
): (boolean, string?)
    local removeOk, removeErr = InventoryService.remove(fromInventory, itemId, amount)
    if not removeOk then
        return false, removeErr
    end

    local addOk, addErr = InventoryService.add(toInventory, itemId, amount)
    if not addOk then
        -- Roll back the remove
        InventoryService.add(fromInventory, itemId, amount)
        return false, addErr
    end
    return true, nil
end

return InventoryService
```

### Client Synchronization

Push the full inventory snapshot on join, then send deltas on changes:

```lua
-- Server: on player join
Remotes.InventorySnapshot:FireClient(player, playerData.inventory.items)

-- Server: after any mutation
Remotes.InventoryDelta:FireClient(player, {
    itemId = "HealthPotion",
    newQuantity = 15,  -- or nil if removed
})
```

## Variants

| Variant | Description |
|---------|-------------|
| **Flat dictionary** (shown above) | `{[itemId]: quantity}`. Best for stackable items. |
| **Unique-instance array** | `{ {id = uuid, itemId = "Sword", damage = 42} }`. Required when items have individual stats (RPG loot). |
| **Slot-based grid** | `{ [slotIndex]: {itemId, quantity} }`. UI maps directly to data. Higher complexity, niche benefit. |

## Pitfalls

- **Never trust client quantities.** The client sends "I want to use item X." The server checks the inventory, deducts, and responds. The client never sends "I have 50 potions."
- **Atomic trades.** When transferring items between two players, use [[atomic-trading]] to prevent duplication. A naive remove-then-add across two profiles can fail midway, duplicating or destroying items.
- **Save size creep.** Each unique item ID in the dictionary is a key in the serialized table. Games with thousands of distinct items per player can approach the 4 MB DataStore value limit. Monitor serialized size.
- **Slot limit enforcement.** Check slot count before `add`, not after. A race between two concurrent adds can exceed the limit if both pass the check before either writes.
- **Schema migration.** When adding new item fields or restructuring the inventory format, use [[schema-versioning]] to migrate on load.

## Related

- [[DataStoreService]] -- persistence layer
- [[schema-versioning]] -- data migration on format changes
- [[atomic-trading]] -- safe player-to-player item transfer
- [[trading-system]] -- full trading UX pattern built on this inventory
- [[session-locking]] -- prevents two servers from mutating the same inventory

## Sources

- [wiki/raw/community/devforum/profileservice-datastore-module.md](../raw/community/devforum/profileservice-datastore-module.md) -- profile template + reconcile pattern
- [wiki/raw/community/devforum/profilestore-datastore-module.md](../raw/community/devforum/profilestore-datastore-module.md) -- session-based data management
- [wiki/raw/community/articles/datastore/datastore-best-practices.md](../raw/community/articles/datastore/datastore-best-practices.md) -- UpdateAsync for shared keys
