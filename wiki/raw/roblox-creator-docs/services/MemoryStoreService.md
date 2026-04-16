---
title: MemoryStoreService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MemoryStoreService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: memory-store
tags: [roblox-class, memory-store, persistence]
---

# MemoryStoreService

Exposes methods to access specific primitives within MemoryStore.

## Description

A top-level singleton class which exposes methods to access specific
primitives within the MemoryStoreService. Use it for any data that rapidly
changes that other servers can restore, such as global leaderboards,
matchmaking queues, and auction houses.

For a more in-depth look, see
[Memory Stores](../../../cloud-services/memory-stores/index.md). For the
limits and quotas of the service, see
[Limits and Quotas](../../../cloud-services/memory-stores/index.md#limits-and-quotas).

## Inheritance

Inherits from: `Instance`

Class tags: `Service`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `MemoryStoreService:GetHashMap`

```
GetHashMap(name: string) -> MemoryStoreHashMap
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Returns a `Class.MemoryStoreHashMap` instance for the provided name.

Returns a `Class.MemoryStoreHashMap` instance for the provided name. The
name is global within the game, so any place that uses the same name
accesses the same hash map.

**Parameters:**

- `name` : `string` — The name of the hash map.

**Returns:**

- `MemoryStoreHashMap` — A `Class.MemoryStoreHashMap` instance for the provided name.

### `MemoryStoreService:GetQueue`

```
GetQueue(name: string, invisibilityTimeout: int = 30) -> MemoryStoreQueue
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Returns a `Class.MemoryStoreQueue` instance for the provided name.

Returns a `Class.MemoryStoreQueue` instance for the provided name. The
name is global within the game, thus any place that uses the same name
accesses the same queue.

**Parameters:**

- `name` : `string` — Name of the queue.
- `invisibilityTimeout` : `int` (default `30`) — **(Optional)** Invisibility timeout, in seconds, for read operations through this queue instance. If not provided, defaults to 30 seconds.

**Returns:**

- `MemoryStoreQueue` — A `Class.MemoryStoreQueue` instance for the provided name.

### `MemoryStoreService:GetSortedMap`

```
GetSortedMap(name: string) -> MemoryStoreSortedMap
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Returns a `Class.MemoryStoreSortedMap` instance for the provided name.

Returns a `Class.MemoryStoreSortedMap` instance for the provided name. The
name is global within the game, so any place that uses the same name
accesses the same sorted map.

**Parameters:**

- `name` : `string` — Name of the sorted map.

**Returns:**

- `MemoryStoreSortedMap` — A `Class.MemoryStoreSortedMap` instance for the provided name.

## Events

_No public events documented._

## Notes / Deprecations

_None flagged in source YAML._

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MemoryStoreService.yaml
- Captured: 2026-04-16
