---
title: MemoryStoreSortedMap
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MemoryStoreSortedMap.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: memory-store
tags: [roblox-class, memory-store]
---

# MemoryStoreSortedMap

Provides access to a sorted map within `Class.MemoryStoreService`.

## Description

Provides access to a sorted map within `Class.MemoryStoreService`. A sorted
map is a collection of items where string keys are associated with arbitrary
values (up to the maximum allowed size -- see
[Memory Stores](../../../cloud-services/memory-stores/sorted-map.md)). Each
item can also have an optional sort key, which can be a number or a string. In
the ordering of items, the sort key, if provided, takes precedence over the
key. Items with numeric sort keys are sorted before items with string sort
keys, which are sorted before items with no sort key. Items with the same sort
key and items with no sort key are arranged in alphabetical order by key.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `NotReplicated`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `MemoryStoreSortedMap:GetAsync`

```
GetAsync(key: string) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Retrieves the value and sort key of a key in the sorted map.

**Parameters:**

- `key` : `string` — Key whose value and sort key to retrieve.

**Returns:**

- `Tuple` — A tuple of two values:  - Key value, or `nil` if there's no item with the specified key. - Sort key, or `nil` if there's no sort key associated with the   specified key.

### `MemoryStoreSortedMap:GetRangeAsync`

```
GetRangeAsync(direction: SortDirection, count: int, exclusiveLowerBound: Variant, exclusiveUpperBound: Variant) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Retrieves items within a sorted range of keys and sort keys.

Gets items within a sorted range of keys and sort keys.

**Parameters:**

- `direction` : `SortDirection` — Sort direction, ascending or descending.
- `count` : `int` — The number of items to retrieve; the maximum allowed value for this parameter is 200.
- `exclusiveLowerBound` : `Variant` — **(Optional)** Lower bound, exclusive, for the returned keys. This is provided as a table where one or both of key and sort key can be specified: { key: string, sortKey: Variant } .
- `exclusiveUpperBound` : `Variant` — **(Optional)** Upper bound, exclusive, for the returned keys. This is provided as a table where one or both of key and sort key can be specified: { key: string, sortKey: Variant } .

**Returns:**

- `Array` — Item keys, values and sort keys in the requested range.

### `MemoryStoreSortedMap:GetSizeAsync`

```
GetSizeAsync() -> int
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Gets the size of the sorted map.

**Returns:**

- `int` — 

### `MemoryStoreSortedMap:RemoveAsync`

```
RemoveAsync(key: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Removes the provided key from the sorted map.

**Parameters:**

- `key` : `string` — Key to remove.

**Returns:**

- `()` — 

### `MemoryStoreSortedMap:SetAsync`

```
SetAsync(key: string, value: Variant, expiration: int64, sortKey: Variant) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Sets the value of a key.

Sets the value and sort key of the key overwriting any existing key value
and sort key.

**Parameters:**

- `key` : `string` — Key whose value to set.
- `value` : `Variant` — Key value to set.
- `expiration` : `int64` — Item expiration, in seconds. The item is automatically removed from the sorted map once the expiration duration is reached. The maximum expiration time is 45 days (3,888,000 seconds).
- `sortKey` : `Variant` — **(Optional)** Sort key to set for this key. Accepted types are a number (integer or decimal) or a string.

**Returns:**

- `boolean` — 

### `MemoryStoreSortedMap:UpdateAsync`

```
UpdateAsync(key: string, transformFunction: Function, expiration: int64) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Retrieves the value and sort key of a key from a sorted map and updates it
with a new value and sort key.

Retrieves the value and sort key of a key from a sorted map and lets you
update it to a new value and sort key via a callback function.

This method accepts a callback function that transforms the old value and
old sort key into the updated value and updated sort key as required. The
method retrieves the existing key value and sort key and passes it to the
transform function which returns the new value and sort key for the item,
with these exceptions:

- If the key does not exist, the old value and old sort key passed to the
  function will be `nil`.
- If the function returns `nil`, the update is canceled.

The new value and new sort key is saved only if the key was not updated
(e.g. by a different game server) since the moment it was read. If the
value or sort key did change, the transform function is invoked again with
the most recent item value and sort key. This cycle repeats until the
value and sort key are saved successfully or the transform function
returns `nil` to abort the operation.

**Parameters:**

- `key` : `string` — Key whose value to update.
- `transformFunction` : `Function` — A function which you need to provide. The function takes the key's old value and old sort key as input and returns the new value and new sort key.
- `expiration` : `int64` — Item expiration time, in seconds, after which the item will be automatically removed from the sorted map. The maximum expiration time is 45 days (3,888,000 seconds).

**Returns:**

- `Tuple` — The return value is a tuple of the last value and sort key returned by the transform function.

## Events

_No public events documented._

## Notes / Deprecations

- Method `MemoryStoreSortedMap:GetAsync` yields (tag `Yields`).
- Method `MemoryStoreSortedMap:GetRangeAsync` yields (tag `Yields`).
- Method `MemoryStoreSortedMap:GetSizeAsync` yields (tag `Yields`).
- Method `MemoryStoreSortedMap:RemoveAsync` yields (tag `Yields`).
- Method `MemoryStoreSortedMap:SetAsync` yields (tag `Yields`).
- Method `MemoryStoreSortedMap:UpdateAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- MemoryStoreSortedMap:GetRangeAsync: retrieving-memorystore-keys
- MemoryStoreSortedMap:UpdateAsync: updating-sorted-map-memory-store

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MemoryStoreSortedMap.yaml
- Captured: 2026-04-16
