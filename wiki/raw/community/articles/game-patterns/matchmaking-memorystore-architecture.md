---
title: Custom Matchmaking Service with MemoryStore
type: raw-source
source_url: https://devforum.roblox.com/t/conceptual-implementation-building-a-custom-matchmaking-service-with-memorystore/3652856
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, matchmaking, MemoryStoreService, coordinator-election, queue]
---

# Custom Matchmaking Service with MemoryStore

## Core Architecture

A theoretical framework for building scalable matchmaking in Roblox using MemoryStoreService rather than traditional DataStores. MemoryStore supports high-frequency, cross-server access unlike DataStore alternatives that face server-based rate limiting constraints.

## Key Components

### Matchmaker Coordinator Election

Servers compete to become the coordinator for a specific game mode and region by calling `UpdateAsync` on a MemoryStoreHashMap. The process involves:
- Periodic election attempts every `REFRESH_TIME` seconds
- A transform function that manages role assignment atomically
- Expiration timeouts preventing permanent locks if servers crash

The transform function logic:
- Grants coordinator role if no current holder exists
- Maintains role if caller is current coordinator
- Denies claims from non-coordinator servers

### Queue Management

Parties are stored in a `MemoryStoreSortedMap` keyed by party leader ID, with timestamps as sort keys. This maintains queue order for fair matchmaking.

### Matchmaking Flow

The coordinator:
1. Fetches up to 200 parties from the sorted map
2. Applies custom grouping logic to form lobbies
3. Validates lobbies using `UpdateAsync` to confirm parties remain available
4. Marks matched parties with lobby information via HashMap

## Performance Considerations

For 200 solo parties across servers with 1 lobby per party: approximately 8,400 units/minute against a 21,000-unit allocation for 200 concurrent players.

## Source
Original URL: https://devforum.roblox.com/t/conceptual-implementation-building-a-custom-matchmaking-service-with-memorystore/3652856
