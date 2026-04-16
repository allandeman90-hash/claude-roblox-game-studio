---
title: GlobalDataStore
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/GlobalDataStore.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: persistence
tags: [roblox-class, data-stores, persistence]
---

# GlobalDataStore

An object that exposes methods to access a single data store.

## Description

A **GlobalDataStore** exposes functions for saving and loading data for the
`Class.DataStoreService`.

See [Data stores](../../../cloud-services/data-stores/index.md) for an
in-depth guide on data structure, management, error handling, limits, and
more.

Ordered data stores do not support versioning and metadata, so
`Class.DataStoreKeyInfo` is always `nil` for keys in an
`Class.OrderedDataStore`. If you need versioning and metadata support, use a
`Class.DataStore`.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `NotReplicated`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `GlobalDataStore:GetAsync`

```
GetAsync(key: string, options: DataStoreGetOptions = nil) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Returns the value of a key in a specified data store and a
`Class.DataStoreKeyInfo` instance.

This function returns the latest value of the provided key and a
`Class.DataStoreKeyInfo` instance. If the key does not exist or if the
latest version has been marked as deleted, both return values will be
`nil`.

Keys are cached locally for 4 seconds after the first read. A
`Class.GlobalDataStore:GetAsync()` call within these 4 seconds returns a
value from the cache. Modifications to the key by
`Class.GlobalDataStore:SetAsync()` or
`Class.GlobalDataStore:UpdateAsync()` apply to the cache immediately and
restart the 4 second timer.

To get a specific version, such as a version before the latest, use
`Class.DataStore:GetVersionAsync()`.

**Parameters:**

- `key` : `string` — The key name for which the value is requested. If `Class.DataStoreOptions.AllScopes` was set to true when accessing the data store through `Class.DataStoreService:GetDataStore()`, this key name must be prepended with the original scope as in "scope/key".
- `options` : `DataStoreGetOptions` (default `nil`) — 

**Returns:**

- `Tuple` — The value of the entry in the data store with the given key and a `Class.DataStoreKeyInfo` instance that includes the version number, date and time the version was created, and functions to retrieve `Class.Player.UserId|UserIds` and metadata.

### `GlobalDataStore:IncrementAsync`

```
IncrementAsync(key: string, delta: int = 1, userIds: Array = {}, options: DataStoreIncrementOptions = nil) -> Variant
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Increments the value of a key by the provided amount (both must be
integers).

This function increments the value of a key by the provided amount (both
must be integers).

Values in `Class.GlobalDataStore|GlobalDataStores` are **versioned** as
outlined in
[versioning](../../../cloud-services/data-stores/versioning-listing-and-caching.md#versioning).
`Class.OrderedDataStore|OrderedDataStores` do not support versioning, so
calling this method on an ordered data store key will overwrite the
current value with the incremented value and make previous versions
inaccessible.

**Parameters:**

- `key` : `string` — Key name for which the value should be updated. If `Class.DataStoreOptions.AllScopes` was set to true when accessing the data store through `Class.DataStoreService:GetDataStore()`, this key name must be prepended with the original scope as in "scope/key".
- `delta` : `int` (default `1`) — Amount to increment the current value by.
- `userIds` : `Array` (default `{}`) — **(Optional)** A table of `Class.Player.UserId|UserIds` to associate with the key.
- `options` : `DataStoreIncrementOptions` (default `nil`) — **(Optional)** `Class.DataStoreIncrementOptions` instance that combines multiple additional parameters as custom metadata and allows for future extensibility.

**Returns:**

- `Variant` — The updated value of the entry in the data store with the given key.

### `GlobalDataStore:OnUpdate`

```
OnUpdate(key: string, callback: Function) -> RBXScriptConnection
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`DataStore` ; **Deprecated:** This function has been deprecated and should not be used in new work. You
can use the `Class.MessagingService|Cross Server Messaging Service` to
publish and subscribe to topics to receive near real-time updates,
completely replacing the need for this function.

Sets a callback function to be executed any time the value associated with
a key is changed.

This function sets `callback` as the function to be run any time the value
associated with the `key` changes. Once every minute, OnUpdate polls for
changes by other servers. Changes made on the same server will run the
function immediately. In other words, functions like
`Class.GlobalDataStore:IncrementAsync()|IncrementAsync()`,
`Class.GlobalDataStore:SetAsync()|SetAsync()`, and
`Class.GlobalDataStore:UpdateAsync()|UpdateAsync()` change the key's value
in the data store and will cause the function to run.

It's recommended that you **disconnect** the connection when the
subscription to the key is no longer needed.

**Parameters:**

- `key` : `string` — The key identifying the entry being retrieved from the data store.
- `callback` : `Function` — The function to be executed any time the value associated with **key** is changed.

**Returns:**

- `RBXScriptConnection` — The connection to the key being tracked for updates.

### `GlobalDataStore:RemoveAsync`

```
RemoveAsync(key: string) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Removes the specified key while also retaining an accessible version.

This function marks the specified key as deleted by creating a new
"tombstone" version of the key. Prior to this, it returns the latest
version prior to the remove call.

After a key is removed via this function,
`Class.GlobalDataStore:GetAsync()` calls for the key will return `nil`.
Older versions of the key remain accessible through
`Class.DataStore:ListVersionsAsync()` and
`Class.DataStore:GetVersionAsync()`, assuming they have not expired.

`Class.OrderedDataStore` does not support versioning, so calling
`Class.GlobalDataStore:RemoveAsync()|RemoveAsync()` on an
`Class.OrderedDataStore` key will permanently delete it.

Removed objects will be deleted permanently after 30 days.

If the previous values were already deleted via
`Class.GlobalDataStore:RemoveAsync()` or
`Class.DataStore:RemoveVersionAsync()`, the function will return `nil`,
`nil` for value and `Class.DataStoreKeyInfo` respectively.

**Parameters:**

- `key` : `string` — Key name to be removed. If `Class.DataStoreOptions.AllScopes` was set to true when accessing the data store through `Class.DataStoreService:GetDataStore()`, this key name must be prepended with the original scope as in "scope/key".

**Returns:**

- `Tuple` — The value of the data store prior to deletion and a `Class.DataStoreKeyInfo` instance that includes the version number, date and time the version was created, and functions to retrieve `Class.Player.UserId|UserIds` and metadata.

### `GlobalDataStore:SetAsync`

```
SetAsync(key: string, value: Variant, userIds: Array = {}, options: DataStoreSetOptions = nil) -> Variant
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Sets the value of the data store for the given key.

This function sets the latest value, `Class.Player.UserId|UserIds`, and
metadata for the given key.

Values in `Class.GlobalDataStore|GlobalDataStores` are **versioned** as
outlined in
[versioning](../../../cloud-services/data-stores/versioning-listing-and-caching.md#versioning).
`Class.OrderedDataStore|OrderedDataStores` do not support versioning, so
calling this method on an ordered data store key will overwrite the
current value and make previous versions inaccessible.

Metadata definitions must always be updated with a value, even if there
are no changes to the current value; otherwise the current value will be
lost.

Any string being stored in a data store must be valid
`Library.utf8|UTF-8`. In UTF-8, values greater than 127 are used
exclusively for encoding multi-byte codepoints, so a single byte greater
than 127 will not be valid UTF-8 and the
`Class.GlobalDataStore:SetAsync()` attempt will fail.

#### Set vs. Update

`Class.GlobalDataStore:SetAsync()` is best for a quick update of a
specific key, and it only counts against the write limit. However, it may
cause data inconsistency if two servers attempt to set the same key at the
same time. `Class.GlobalDataStore:UpdateAsync()` is safer for handling
multi-server attempts because it reads the current key value (from
whatever server last updated it) before making any changes. However, it's
somewhat slower because it reads before it writes, and it also counts
against both the read and write limit.

**Parameters:**

- `key` : `string` — Key name for which the value should be set. If `Class.DataStoreOptions.AllScopes` was set to true when accessing the data store through `Class.DataStoreService:GetDataStore()`, this key name must be prepended with the original scope as in "scope/key".
- `value` : `Variant` — The value that the data store key will be set to.
- `userIds` : `Array` (default `{}`) — Table of `Class.Player.UserId|UserIds`, highly recommended to assist with GDPR tracking/removal.
- `options` : `DataStoreSetOptions` (default `nil`) — **(Optional)** `Class.DataStoreSetOptions` instance that allows for metadata specification on the key.

**Returns:**

- `Variant` — The version identifier of the newly created version. It can be used to retrieve key info using `Class.DataStore:GetVersionAsync()|GetVersionAsync()` or to remove it using `Class.DataStore:RemoveVersionAsync()|RemoveVersionAsync()`.

### `GlobalDataStore:UpdateAsync`

```
UpdateAsync(key: string, transformFunction: Function) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`DataStore`

Updates a key's value with a new value from the specified callback
function.

This function retrieves the value and metadata of a key from the data
store and updates it with a new value determined by the callback function
specified through the second parameter. If the callback returns `nil`, the
write operation is cancelled and the value remains unchanged.

Values in `Class.GlobalDataStore|GlobalDataStores` are **versioned** as
outlined in
[versioning](../../../cloud-services/data-stores/versioning-listing-and-caching.md#versioning).
`Class.OrderedDataStore|OrderedDataStores` do not support versioning, so
calling this method on an ordered data store key will overwrite the
current value and make previous versions inaccessible.

In cases where another game server updated the key in the short timespan
between retrieving the key's current value and setting the key's value,
`Class.GlobalDataStore:UpdateAsync()` will call the function again,
discarding the result of the previous call. The function will be called as
many times as needed until the data is saved **or** until the callback
function returns `nil`. This can be used to ensure that no data is
overwritten.

Any string being stored in a data store must be valid
`Library.utf8|UTF-8`. In UTF-8, values greater than 127 are used
exclusively for encoding multi-byte codepoints, so a single byte greater
than 127 will not be valid UTF-8 and the
`Class.GlobalDataStore:UpdateAsync()` attempt will fail.

#### Set vs. Update

`Class.GlobalDataStore:SetAsync()` is best for a quick update of a
specific key, and it only counts against the write limit. However, it may
cause data inconsistency if two servers attempt to set the same key at the
same time. `Class.GlobalDataStore:UpdateAsync()` is safer for handling
multi-server attempts because it reads the current key value (from
whatever server last updated it) before making any changes. However, it's
somewhat slower because it reads before it writes, and it also counts
against both the read and write limit.

#### Callback Function

The callback function accepts two arguments:

- Current value of the key prior to the update.
- `Class.DataStoreKeyInfo` instance that contains the latest version
  information (this argument can be ignored if metadata is not being
  used).

In turn, the callback function returns up to three values:

- The new value to set for the key.
- An array of `Class.Player.UserId|UserIds` to associate with the key.
  `Class.DataStoreKeyInfo:GetUserIds()` should be returned unless the
  existing IDs are being changed; otherwise all existing IDs will be
  cleared.
- A Luau table containing metadata to associate with the key.
  `Class.DataStoreKeyInfo:GetMetadata()` should be returned unless the
  existing metadata is being changed; otherwise all existing metadata will
  be cleared.

If the callback returns `nil` instead, the current server will stop
attempting to update the key.

The callback function cannot yield, so do **not** include calls like
`Library.task.wait()`.

**Parameters:**

- `key` : `string` — Key name for which the value should be updated. If `Class.DataStoreOptions.AllScopes` was set to true when accessing the data store through `Class.DataStoreService:GetDataStore()`, this key name must be prepended with the original scope as in "scope/key".
- `transformFunction` : `Function` — Transform function that takes the current value and `Class.DataStoreKeyInfo` as parameters and returns the new value along with optional `Class.Player.UserId|UserIds` and metadata.

**Returns:**

- `Tuple` — The updated value of the entry in the data store with the given key and a `Class.DataStoreKeyInfo` instance that includes the version number, date and time the version was created, and functions to retrieve `Class.Player.UserId|UserIds` and metadata.

## Events

_No public events documented._

## Notes / Deprecations

- Deprecated method `GlobalDataStore:OnUpdate`: This function has been deprecated and should not be used in new work. You
can use the `Class.MessagingService|Cross Server Messaging Service` to
publish and subscribe to topics to receive near real-time updates,
completely replacing the need for this function.
- Method `GlobalDataStore:GetAsync` yields (tag `Yields`).
- Method `GlobalDataStore:IncrementAsync` yields (tag `Yields`).
- Method `GlobalDataStore:RemoveAsync` yields (tag `Yields`).
- Method `GlobalDataStore:SetAsync` yields (tag `Yields`).
- Method `GlobalDataStore:UpdateAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- GlobalDataStore:OnUpdate: GlobalDataStore-OnUpdate1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/GlobalDataStore.yaml
- Captured: 2026-04-16
