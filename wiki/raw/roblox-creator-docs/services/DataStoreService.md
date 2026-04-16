---
title: DataStoreService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/DataStoreService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/DataStoreService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: persistence
tags: [roblox-class, data-stores, persistence]
---

# DataStoreService

A game service that gives access to persistent data storage across places in a
game.

## Description

**DataStoreService** exposes methods for getting `Class.GlobalDataStore` and
`Class.OrderedDataStore` objects. Data stores can only be accessed by game
servers, so you can only use `Class.DataStoreService` within a `Class.Script`
or a `Class.ModuleScript` that is used by a `Class.Script`.

See [Data stores](../../../cloud-services/data-stores/index.md) for an
in-depth guide on data structure, management, error handling, limits, and
more.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`, `NotReplicated`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `DataStoreService:GetDataStore`

```
GetDataStore(name: string, scope: string = global, options: Instance = nil) -> DataStore
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Creates a `Class.DataStore` instance with the provided name and scope.

This function creates a `Class.DataStore` instance with the provided name
and scope. Subsequent calls to this method with the same name/scope will
return the same object.

Using the `scope` parameter will restrict operations to that scope by
automatically prepending the scope to keys in all operations done on the
data store. This function also accepts an optional
`Class.DataStoreOptions` instance which includes options for enabling
`Class.DataStoreOptions.AllScopes|AllScopes`. See
[Versioning, listing, and caching](../../../cloud-services/data-stores/versioning-listing-and-caching.md#scopes)
for details on scope.

**Parameters:**

- `name` : `string` — Name of the data store.
- `scope` : `string` (default `global`) — **(Optional)** A string specifying the scope.
- `options` : `Instance` (default `nil`) — **(Optional)** A `Class.DataStoreOptions` instance to enable experimental features and v2 API features.

**Returns:**

- `DataStore` — A `Class.DataStore` instance with provided name and optional scope.

### `DataStoreService:GetGlobalDataStore`

```
GetGlobalDataStore() -> DataStore
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Returns the default data store.

This function returns the default `Class.GlobalDataStore`. If you want to
access a specific **named** data store instead, you should use the
`Class.DataStoreService:GetDataStore()|GetDataStore()` function.

Note that the `Class.DataStore` returned by this function always uses the
scope `u`. See [Data stores](../../../cloud-services/data-stores/index.md)
for details on scope.

**Returns:**

- `DataStore` — 

### `DataStoreService:GetOrderedDataStore`

```
GetOrderedDataStore(name: string, scope: string = global) -> OrderedDataStore
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Get an `Class.OrderedDataStore` given a name and optional scope.

This method returns an `Class.OrderedDataStore`, similar to the way
`Class.DataStoreService:GetDataStore()|GetDataStore()` does with
`Class.GlobalDataStore|GlobalDataStores`. Subsequent calls to this method
with the same name/scope will return the same object.

**Parameters:**

- `name` : `string` — 
- `scope` : `string` (default `global`) — 

**Returns:**

- `OrderedDataStore` — 

### `DataStoreService:GetRequestBudgetForRequestType`

```
GetRequestBudgetForRequestType(requestType: DataStoreRequestType) -> int
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Returns the number of requests that can be made by the given request type.

This function returns the number of data store requests that the current
place can make based on the given `Enum.DataStoreRequestType`. Any
requests made that exceed this budget are subject to throttling.
Monitoring and adjusting the frequency of data store requests using this
function is recommended.

**Parameters:**

- `requestType` : `DataStoreRequestType` — 

**Returns:**

- `int` — 

### `DataStoreService:ListDataStoresAsync`

```
ListDataStoresAsync(prefix: string, pageSize: int = 0, cursor: string) -> DataStoreListingPages
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Returns a `Class.DataStoreListingPages` object for enumerating through all
of the experience's data stores.

Returns a `Class.DataStoreListingPages` object for enumerating through all
of the experience's data stores. It accepts an optional `prefix` parameter
to only locate data stores whose names start with the provided prefix.

Only data stores containing at least one object will be listed via this
function.

**Parameters:**

- `prefix` : `string` — **(Optional)** Prefix to enumerate data stores that start with the given prefix.
- `pageSize` : `int` (default `0`) — **(Optional)** Number of items to be returned in each page. If no value is given, the engine sends a default value of 0 to the data store web service, which in turn defaults to 32 items per page.
- `cursor` : `string` — **(Optional)** Cursor to continue iteration.

**Returns:**

- `DataStoreListingPages` — `Class.DataStoreListingPages` instance containing `Class.DataStoreInfo` instances that provide details such as name, creation time, and time last updated.

### `DataStoreService:SetRateLimitForRequestType`

```
SetRateLimitForRequestType(requestType: DataStoreRequestType, baseLimit: int, perPlayerLimit: int) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Sets the rate limit for a given request type per minute.

Sets the per-server rate limit (requests per minute) for a given Data
Store request type. The configured limit overrides the default rate limit
for that request type on the current server. The rate limit is calculated
as `rateLimit = baseLimit + (perPlayerLimit * numPlayers)`, where
`numPlayers` is the current number of active players on the server.
`Enum.DataStoreRequestType.OnUpdate|DataStoreRequestType.OnUpdate` and
`Enum.DataStoreRequestType.UpdateAsync|DataStoreRequestType.UpdateAsync`
cannot be configured with this function. Calling this API with those
request types will result in an error.

You should call this API **once per request type during server
initialization**. We don't recommend calling this API during active
experience logic. If called multiple times, the new limit definitions will
immediately overwrite the previous ones.

The `baseLimit` and `perPlayerLimit` have different constraints depending
on the request type. See the table below for more information.

##### Constraints by Request Type

| Request Type            | baseLimit constraints | perPlayerLimit constraints |
| :---------------------- | :-------------------- | :------------------------- |
| GetAsync                | [0, 60]               | [0, 40]                    |
| SetIncrementAsync       | [0, 60]               | [0, 40]                    |
| UpdateAsync             | N/A                   | N/A                        |
| GetSortedAsync          | [0, 5]                | [0, 2]                     |
| SetIncrementSortedAsync | [0, 30]               | [0, 5]                     |
| OnUpdate                | N/A                   | N/A                        |
| ListAsync               | [0, 5]                | [0, 2]                     |
| GetVersionAsync         | [0, 5]                | [0, 2]                     |
| RemoveVersionAsync      | [0, 5]                | [0, 2]                     |
| StandardRead            | [0, 10000]            | [0, 200]                   |
| StandardWrite           | [0, 10000]            | [0, 200]                   |
| StandardList            | [0, 10000]            | [0, 200]                   |
| StandardRemove          | [0, 10000]            | [0, 200]                   |
| OrderedRead             | [0, 10000]            | [0, 200]                   |
| OrderedWrite            | [0, 10000]            | [0, 200]                   |
| OrderedList             | [0, 10000]            | [0, 200]                   |
| OrderedRemove           | [0, 10000]            | [0, 200]                   |

**Parameters:**

- `requestType` : `DataStoreRequestType` — 
- `baseLimit` : `int` — 
- `perPlayerLimit` : `int` — 

**Returns:**

- `()` — 

## Events

_No public events documented._

## Notes / Deprecations

- Method `DataStoreService:ListDataStoresAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `DataStore-Budget` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/DataStoreService
- DataStoreService:GetGlobalDataStore: get-a-globaldatastore-instance
- DataStoreService:GetOrderedDataStore: OrderedDataStore-Basics
- DataStoreService:GetRequestBudgetForRequestType: DataStoreService-GetRequestBudgetForRequestType1
- DataStoreService:SetRateLimitForRequestType: DataStoreService-SetRateLimitForRequestType1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/DataStoreService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/DataStoreService.yaml
- Captured: 2026-04-16
