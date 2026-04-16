---
title: MemoryStoreQueue
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreQueue
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MemoryStoreQueue.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: memory-store
tags: [roblox-class, memory-store]
---

# MemoryStoreQueue

Provides access to a queue within MemoryStore.

## Description

Provides access to a queue within MemoryStore. A queue is a data structure
that provides temporary storage for arbitrary items (up to the maximum item
size -- see
[MemoryStore Limits](../../../cloud-services/memory-stores/index.md#limits-and-quotas)).
Each queue item has a numeric priority: MemoryStore retrieves items with
higher priority from the queue first, and it retrieves Items with the same
priority in order of addition.

Items in the queue can optionally be set to expire after a certain amount of
time. Expired items simply disappear from the queue as if they were never
added.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `NotReplicated`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `MemoryStoreQueue:AddAsync`

```
AddAsync(value: Variant, expiration: int64, priority: double = 0) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Adds an item to the queue.

**Parameters:**

- `value` : `Variant` — The value of the item to add to the queue.
- `expiration` : `int64` — Item expiration time, in seconds, after which the item will be automatically removed from the queue.
- `priority` : `double` (default `0`) — Item priority. Items with higher priority are retrieved from the queue before items with lower priority.

**Returns:**

- `()` — 

### `MemoryStoreQueue:GetSizeAsync`

```
GetSizeAsync(excludeInvisible: boolean = False) -> int
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Gets the size of the queue.

**Parameters:**

- `excludeInvisible` : `boolean` (default `False`) — Determines whether to exclude invisible items from the size count.

**Returns:**

- `int` — 

### `MemoryStoreQueue:ReadAsync`

```
ReadAsync(count: int, allOrNothing: boolean = False, waitTimeout: double = -1) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Reads one or more items from the queue.

Reads one or more items from the queue as a single atomic operation.

This method does not automatically delete the returned items from the
queue but makes them invisible to other ReadAsync calls for the period of
the invisibility timeout. The items must be explicitly removed from the
queue with `Class.MemoryStoreQueue:RemoveAsync()` before the invisibility
timeout expires. The invisibility timeout defaults to 30 seconds unless a
different value was provided in `Class.MemoryStoreService:GetQueue()`.

**Parameters:**

- `count` : `int` — Number of items to read. The maximum allowed value of this parameter is 100.
- `allOrNothing` : `boolean` (default `False`) — Controls the behavior of the method in the case the queue has fewer than `count` items: if set to false the method returns all available items; if set to true, it returns no items. The default value is false.
- `waitTimeout` : `double` (default `-1`) — The duration, in seconds, for which the method will wait if the required number of items is not immediately available in the queue. Reads are attempted every two seconds during this period. This parameter can be set to zero to indicate no wait. If this parameter is not provided or set to -1, the method will wait indefinitely.

**Returns:**

- `Tuple` — A tuple of two elements. The first element is an array of item values read from the queue. The second element is a string identifier that should be passed to `Class.MemoryStoreQueue:RemoveAsync()` to permanently remove these items from the queue.

### `MemoryStoreQueue:RemoveAsync`

```
RemoveAsync(id: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Removes an item or items previously read from the queue.

Removes an item or items previously read from the queue. This method uses
the identifier returned by `Class.MemoryStoreQueue:ReadAsync()` to
identify the items to remove. If called after the invisibility timeout has
expired, the call has no effect.

**Parameters:**

- `id` : `string` — Identifies the items to delete. Use the value returned by `Class.MemoryStoreQueue:ReadAsync()`.

**Returns:**

- `()` — 

## Events

_No public events documented._

## Notes / Deprecations

- Method `MemoryStoreQueue:AddAsync` yields (tag `Yields`).
- Method `MemoryStoreQueue:GetSizeAsync` yields (tag `Yields`).
- Method `MemoryStoreQueue:ReadAsync` yields (tag `Yields`).
- Method `MemoryStoreQueue:RemoveAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- MemoryStoreQueue:ReadAsync: using-a-memorystorequeue
- MemoryStoreQueue:RemoveAsync: using-a-memorystorequeue

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreQueue
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MemoryStoreQueue.yaml
- Captured: 2026-04-16
