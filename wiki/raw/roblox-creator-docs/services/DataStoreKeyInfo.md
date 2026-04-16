---
title: DataStoreKeyInfo
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/DataStoreKeyInfo
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/DataStoreKeyInfo.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: persistence
tags: [roblox-class, data-stores, persistence]
---

# DataStoreKeyInfo

An object specifying information about a particular version of the key.

## Description

An object describing information about a particular version of the key. This
is returned as the second return value by `Class.GlobalDataStore:GetAsync()`,
`Class.GlobalDataStore:UpdateAsync()`,
`Class.GlobalDataStore:IncrementAsync()`,
`Class.GlobalDataStore:RemoveAsync()`, and
`Class.DataStore:GetVersionAsync()`.

See also:

- [Data Stores](../../../cloud-services/data-stores/index.md), an in-depth
  guide on data structure, management, error handling, etc.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `NotReplicated`

Memory category: `Instances`

## Properties

### `DataStoreKeyInfo.CreatedTime`

- **Type:** `int64`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `DataStore`

The date and time the object was created.

This property indicates the date and time the object was created,
formatted as the number of milliseconds since epoch.

### `DataStoreKeyInfo.UpdatedTime`

- **Type:** `int64`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `DataStore`

The date and time the object was last updated.

This property indicates the date and time the object was last updated,
formatted as the number of milliseconds since epoch.

### `DataStoreKeyInfo.Version`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `DataStore`

Uniquely identifies the version of the object.

This property uniquely identifies the version of the object. It can be
passed to `Class.DataStore:GetVersionAsync()` or
`Class.DataStore:RemoveVersionAsync()` to get or remove the version
respectively.

## Methods

### `DataStoreKeyInfo:GetMetadata`

```
GetMetadata() -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

Returns the metadata associated with the object.

This function returns the metadata associated with the latest version of
the object.

**Returns:**

- `Dictionary` — Metadata associated with the key.

### `DataStoreKeyInfo:GetUserIds`

```
GetUserIds() -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`DataStore`

An array of `Class.Player.UserId|UserIds` tagged with a key.

This function returns an array of `Class.Player.UserId|UserIds` tagged
with the object.

**Returns:**

- `Array` — An array of `Class.Player.UserId|UserIds` associated with the object.

## Events

_No public events documented._

## Notes / Deprecations

- Property `DataStoreKeyInfo.CreatedTime` security: `read=None, write=None`
- Property `DataStoreKeyInfo.UpdatedTime` security: `read=None, write=None`
- Property `DataStoreKeyInfo.Version` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/DataStoreKeyInfo
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/DataStoreKeyInfo.yaml
- Captured: 2026-04-16
