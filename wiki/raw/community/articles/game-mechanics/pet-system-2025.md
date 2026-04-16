---
title: "Pet System 2025 - Full Architecture"
captured_by: mechanics-genres
source: https://devforum.roblox.com/t/new-how-to-make-a-pet-system-in-roblox-2025-high-effort-post/3792525
captured_date: 2026-04-15
type: devforum-tutorial
---

# Pet System 2025 Architecture

## Structure
- ReplicatedStorage: EggInfo, PetModels, PlayerDatas, Remotes
- ServerScriptService: Datastore, Template, Version, Pets modules
- StarterGui: Client, Hatching, Pets modules

## Hatching
- Weighted probability via rollPet() with cumulative weights
- Single or triple hatches via RemoteEvents
- New pets stored with unique GUIDs and metadata

## Inventory & Data Storage
- DataStoreService with version-control support
- Data syncs to ReplicatedStorage.PlayerDatas as instances
- Enables real-time GUI access

## Equipped Pets
- Pets have Equipped boolean value
- Only equipped pet models spawn in workspace
- Unequipped pets destroyed automatically

## Follow System (Client-Side)
- Heartbeat connections for movement
- Pets arrange in rows behind players
- Raycasting for terrain collision
- Each client tweens all players' pets locally
