---
title: "Matchmaking: How to use MemoryStoreQueue"
type: raw-source
source_url: https://devforum.roblox.com/t/matchmaking-how-to-use-memorystorequeue/1515961
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, matchmaking, MemoryStoreService, queue, TeleportService]
---

# MemoryStoreQueue Matchmaking Tutorial

## Core Concept

Implementing matchmaking in Roblox using MemoryStoreQueue as an alternative to HTTP services. Suited for developers without paid external servers.

## Key Queue Functions

- **GetQueue**: Initializes a queue with a global key and invisibility timeout duration
- **AddAsync**: Accepts value, automatic removal time (max ~60 seconds), and priority level
- **ReadAsync**: Retrieves up to 100 values with quantity, nil-return behavior, and timeout params
- **RemoveAsync**: Deletes values returned from ReadAsync operations

## Critical Implementation Pattern

The "invisibility timeout" prevents re-reading values during processing. Invisibility timeout should remain 0 for immediate re-accessibility, while AddAsync timeout handles automatic cleanup.

## Matchmaking Workflow

1. **Add Function**: Inserts player names into queue via AddAsync with error handling
2. **Main Function**: Reads queued players, validates minimum threshold, initiates teleportation when sufficient players accumulate
3. **RemoveAll Function**: Cleans on server shutdown by reading and removing all remaining queue entries

## TeleportService Integration

The complete system uses a custom TeleportModule for moving matched player groups to reserved servers.

## Source
Original URL: https://devforum.roblox.com/t/matchmaking-how-to-use-memorystorequeue/1515961
