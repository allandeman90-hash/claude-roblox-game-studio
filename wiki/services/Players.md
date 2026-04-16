---
title: Players
type: service
category: services
subcategory: players
owner: luau-gameplay-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/Players.md
related:
  - "[[Player]]"
  - "[[session-locking]]"
  - "[[DataStoreService]]"
tags: [roblox-class, players]
---

# Players

**Status:** stub

The service that manages all `Player` instances. Key events: `PlayerAdded`, `PlayerRemoving`, `CharacterAutoLoads`. Lookup: `GetPlayerByUserId`, `GetPlayerFromCharacter`, `GetPlayers`.

`PlayerAdded` / `PlayerRemoving` are the canonical hooks for player lifecycle logic (data load, session lock, save).

## Related

- [[Player]]
- [[session-locking]]
- [[DataStoreService]]

## Sources

- [wiki/raw/roblox-creator-docs/services/Players.md](../raw/roblox-creator-docs/services/Players.md)
