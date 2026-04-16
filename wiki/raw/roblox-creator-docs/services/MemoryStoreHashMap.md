---
title: MemoryStoreHashMap
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreHashMap
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MemoryStoreHashMap.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: memory-store
tags: [roblox-class, memory-store]
---

# MemoryStoreHashMap

Provides access to a hash map within `Class.MemoryStoreService`.

## Description

Provides access to a hash map within `Class.MemoryStoreService`. A hash map is
a collection of items where string keys are associated with arbitrary values
(up to the maximum allowed size -- see
[Memory Stores](../../../cloud-services/memory-stores/hash-map.md)). The keys
have no ordering guarantees.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `NotReplicated`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `MemoryStoreHashMap:GetAsync`

```
GetAsync(key: string) -> Variant
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Retrieves the value of a key in the hash map.

**Parameters:**

- `key` : `string` — The key whose value you want to retrieve.

**Returns:**

- `Variant` — The value, or `nil` if the key doesn't exist.

### `MemoryStoreHashMap:ListItemsAsync`

```
ListItemsAsync(count: int) -> MemoryStoreHashMapPages
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Returns a `Class.MemoryStoreHashMapPages` object for enumerating through
items in the hash map.

Returns a `Class.MemoryStoreHashMapPages` object for enumerating through
items in the hash map. The valid range is 1 to 200 inclusive.

**Parameters:**

- `count` : `int` — Maximum possible number of items that can be returned.

**Returns:**

- `MemoryStoreHashMapPages` — A `Class.MemoryStoreHashMapPages` instance that enumerates the items as `Class.MemoryStoreHashMapPages` instances.

### `MemoryStoreHashMap:RemoveAsync`

```
RemoveAsync(key: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Removes an item from the hash map.

**Parameters:**

- `key` : `string` — The key to remove.

**Returns:**

- `()` — 

### `MemoryStoreHashMap:SetAsync`

```
SetAsync(key: string, value: Variant, expiration: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Sets the value of a key in the hash map.

Sets the value of a key in the hash map, overwriting any existing value.

**Parameters:**

- `key` : `string` — The key whose value to set.
- `value` : `Variant` — The value to set.
- `expiration` : `int64` — Item expiration in seconds, after which the item is automatically removed from the hash map. The maximum expiration time is 45 days (3,888,000 seconds).

**Returns:**

- `boolean` — 

### `MemoryStoreHashMap:UpdateAsync`

```
UpdateAsync(key: string, transformFunction: Function, expiration: int64) -> Variant
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Retrieves the value of a key from a hash map and lets you update it to a
new value.

Retrieves the value of a key from a hash map and lets you update it to a
new value.

This method accepts a callback function that retrieves the existing key
value and passes it to a transform function, which returns the new value
for the item, with these exceptions:

- If the key does not exist, the old value passed to the function is
  `nil`.
- If the function returns `nil`, the update is canceled.

The new value is saved only if the key was not updated (for example, by a
different game server) since the moment it was read. If the value changed
in that time, the transform function is called again with the most recent
item value. This cycle repeats until the value is saved successfully or
the transform function returns `nil` to abort the operation.

**Parameters:**

- `key` : `string` — The key whose value you want to update.
- `transformFunction` : `Function` — The transform function, which you provide. This function takes the old value as an input and returns the new value.
- `expiration` : `int64` — Item expiration in seconds, after which the item is automatically removed from the hash map. The maximum expiration time is 45 days (3,888,000 seconds).

**Returns:**

- `Variant` — The last value returned by the transform function.

## Events

_No public events documented._

## Notes / Deprecations

- Method `MemoryStoreHashMap:GetAsync` yields (tag `Yields`).
- Method `MemoryStoreHashMap:ListItemsAsync` yields (tag `Yields`).
- Method `MemoryStoreHashMap:RemoveAsync` yields (tag `Yields`).
- Method `MemoryStoreHashMap:SetAsync` yields (tag `Yields`).
- Method `MemoryStoreHashMap:UpdateAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- MemoryStoreHashMap:GetAsync: getting-data-hash-map-memory-store
- MemoryStoreHashMap:ListItemsAsync: listing-data-hash-map-memory-store
- MemoryStoreHashMap:RemoveAsync: removing-data-hash-map-memory-store
- MemoryStoreHashMap:SetAsync: adding-data-hash-map-memory-store
- MemoryStoreHashMap:UpdateAsync: updating-hash-map-memory-store

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreHashMap
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MemoryStoreHashMap.yaml
- Captured: 2026-04-16
