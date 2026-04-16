---
title: OrderedDataStore
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/OrderedDataStore
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/OrderedDataStore.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: persistence
tags: [roblox-class, data-stores, persistence, leaderboards]
---

# OrderedDataStore

A GlobalDataStore that also allows for ordered data store entries.

## Description

A **OrderedDataStore** is essentially a `Class.GlobalDataStore` with the
exception that stored values must be **integers**. It exposes a method
`Class.OrderedDataStore:GetSortedAsync()|GetSortedAsync()` which allows
inspection of the entries in sorted order using a `Class.DataStorePages`
object.

Ordered data stores do not support versioning and metadata, so
`Class.DataStoreKeyInfo` is always `nil` for keys in an
`Class.OrderedDataStore`. If you need versioning and metadata support, use a
`Class.DataStore`.

Ordered data stores do not support the optional `userIds` parameter for
`Class.OrderedDataStore:SetAsync()|SetAsync()` or
`Class.OrderedDataStore:IncrementAsync()|IncrementAsync()`.

See [Data stores](../../../cloud-services/data-stores/index.md) for an
overview on how to use ordered data stores.

## Inheritance

Inherits from: `GlobalDataStore`

Class tags: `NotCreatable`, `NotReplicated`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `OrderedDataStore:GetSortedAsync`

```
GetSortedAsync(ascending: boolean, pagesize: int, minValue: Variant, maxValue: Variant) -> DataStorePages
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Returns a `Class.DataStorePages` object.

Returns a `Class.DataStorePages` object. The sort order is determined by
**ascending**, the length of each page by **pageSize**, and
**minValue**/**maxValue** are optional parameters which filter the
results.

See
[Error codes and limits](../../../cloud-services/data-stores/error-codes-and-limits.md)
for request limits and descriptions of the error codes.

**Parameters:**

- `ascending` : `boolean` — A boolean indicating whether the returned data pages are in ascending order.
- `pagesize` : `int` — The length of each page. By default is 50. The max allowed value is 100.
- `minValue` : `Variant` — Optional parameter. If set, data pages with a value less than **minValue** will be excluded.
- `maxValue` : `Variant` — Optional parameter. If set, data pages with a value greater than **maxValue** will be excluded.

**Returns:**

- `DataStorePages` — A sorted `Class.DataStorePages` object based on the provided arguments.

## Events

_No public events documented._

## Notes / Deprecations

- Method `OrderedDataStore:GetSortedAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `OrderedDataStore-Basics` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/OrderedDataStore

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/OrderedDataStore
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/OrderedDataStore.yaml
- Captured: 2026-04-16
