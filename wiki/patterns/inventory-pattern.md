---
title: inventory-pattern
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[DataStoreService]]"
  - "[[schema-versioning]]"
  - "[[atomic-trading]]"
tags: [pattern, gameplay]
---

# Inventory Pattern

**Status:** stub

Inventory as `{[itemId: string]: quantity: number}` in player data. Operations: `add`, `remove`, `contains`, `getQuantity`, `canAfford`. Max slots enforced server-side. Changes batched into player-data dirty flag; persisted via standard save loop.

## Related

- [[DataStoreService]]
- [[schema-versioning]]
- [[atomic-trading]]
