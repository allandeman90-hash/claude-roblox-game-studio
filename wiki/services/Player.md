---
title: Player
type: service
category: services
subcategory: players
owner: luau-gameplay-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/Player.md
related:
  - "[[Players]]"
  - "[[Humanoid]]"
tags: [roblox-class, players]
---

# Player

**Status:** stub

Represents a connected player. Key properties: `UserId`, `Name`, `DisplayName`, `Character`, `Team`, `MembershipType`. Key events: `CharacterAdded`, `CharacterRemoving`, `Chatted`, `Idled`.

Always use `UserId` (stable) as the DataStore key, not `Name` (which can change).

## Related

- [[Players]]
- [[Humanoid]]

## Sources

- [wiki/raw/roblox-creator-docs/services/Player.md](../raw/roblox-creator-docs/services/Player.md)
