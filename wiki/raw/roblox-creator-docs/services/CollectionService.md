---
title: CollectionService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/CollectionService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/CollectionService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: world
tags: [roblox-class, tags, collection, service]
---

# CollectionService

A service which manages instance collections using assigned tags.

## Description

`CollectionService` manages groups (collections) of instances with **tags**.
Tags are sets of strings applied to instances that replicate from the server
to the client. They are also serialized when places are saved.

The primary use of `CollectionService` is to register instances with specific
tags that you can use to extend their behavior. If you find yourself adding
the same script to many different instances, a script that uses
`CollectionService` may be better.

Tags can be added or removed through this class' methods such as
`Class.CollectionService:AddTag()|AddTag()` or
`Class.CollectionService:RemoveTag()|RemoveTag()`. They can also be managed
directly in Studio through the
[Tags](../../../studio/properties.md#instance-tags) section of an instance's
properties.

##### Replication

When tags replicate, **all tags on an instance replicate at the same time**.
Therefore, if you set a tag on an instance from the client then add/remove a
**different** tag on the same instance from the server, the client's local
tags on the instance are overwritten. In
`Class.Workspace.StreamingEnabled|StreamingEnabled` places, instances can be
unloaded as they leave the client's streamed area. If such an instance
re-enters the streamed area, properties and tags will be re-synchronized from
the server. This can cause changes made by `Class.LocalScript|LocalScripts` to
be overwritten/removed.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `CollectionService:AddTag`

```
AddTag(instance: Instance, tag: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Basic`

Applies a tag to an `Class.Instance`.

This method applies a tag to an `Class.Instance`, doing nothing if the tag
is already applied to that instance. Successfully adding a tag will fire a
signal created by
`Class.CollectionService:GetInstanceAddedSignal()|GetInstanceAddedSignal()`
with the given tag.

##### Warnings

- An instance's tags that were added client-side will be dropped if the
  server later adds or removes a tag on that instance because the server
  replicates all tags together and overwrites previous tags.

- When tagging an instance, it is common that some resources are used to
  give the tag its functionality, for example event connections or tables.
  To prevent memory leaks, it's a good idea to clean these up (disconnect,
  set to `nil`, etc.) when no longer needed for a tag. Do this when
  calling `Class.CollectionService:RemoveTag()|RemoveTag()`, calling
  `Class.Instance:Destroy()` or in a function connected to a signal
  returned by
  `Class.CollectionService:GetInstanceRemovedSignal()|GetInstanceRemovedSignal()`.

**Parameters:**

- `instance` : `Instance` — 
- `tag` : `string` — 

**Returns:**

- `()` — 

### `CollectionService:GetAllTags`

```
GetAllTags() -> Array
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Returns an array of all tags in the experience.

**Returns:**

- `Array` — 

### `CollectionService:GetCollection`

```
GetCollection(class: string) -> Instances
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This item has been superseded by a `Class.CollectionService` tagging
method. The equivalent function using the new method is
`Class.CollectionService:GetTagged()` which should be used in new work.

Returns all instances of a given class which are in the `Class.DataModel`.

This function returns all instances of a given class which are in the
`Class.DataModel`. Only works for `Class.Configuration`,
`Class.CustomEvent`, `Class.CustomEventReceiver`, `Class.Dialog`, and
`Class.VehicleSeat`.

**Parameters:**

- `class` : `string` — 

**Returns:**

- `Instances` — 

### `CollectionService:GetInstanceAddedSignal`

```
GetInstanceAddedSignal(tag: string) -> RBXScriptSignal
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Returns a signal that fires when a given tag is added to an instance.

Given a tag (string), this method returns a signal which fires under two
conditions:

- The tag is assigned to an instance within the `Class.DataModel` using
  `Class.CollectionService:AddTag()` or `Class.Instance:AddTag()`.

- An instance with the given tag is added as a descendant of the
  `Class.DataModel`, for example by setting `Class.Instance.Parent` or
  similar.

Subsequent calls to this method with the same tag return the same signal
object. Consider also calling
`Class.CollectionService:GetTagged()|GetTagged()` to get a list of
instances that already have a tag (and thus won't fire the event if they
already are in the `Class.DataModel`).

See also
`Class.CollectionService:GetInstanceRemovedSignal()|GetInstanceRemovedSignal()`
which returns an event that fires under similar conditions.

**Parameters:**

- `tag` : `string` — The tag to watch for.

**Returns:**

- `RBXScriptSignal` — An event that fires when you add the tag to an instance.

### `CollectionService:GetInstanceRemovedSignal`

```
GetInstanceRemovedSignal(tag: string) -> RBXScriptSignal
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Returns a signal that fires when a given tag is removed from an instance.

Given a tag (string), this method returns a signal which fires under two
conditions:

- The tag is removed from an instance within the `Class.DataModel` using
  `Class.CollectionService:RemoveTag()` or `Class.Instance:RemoveTag()`.

- An instance with the given tag is removed as a descendant of the
  `Class.DataModel`, for example by un‑setting `Class.Instance.Parent` or
  similar.

Subsequent calls to this method with the same tag return the same signal
object. The signal is useful for cleaning up resources used by instances
that once had tags, such as disconnecting connections.

See also
`Class.CollectionService:GetInstanceAddedSignal()|GetInstanceAddedSignal()`
which returns an event that fires under similar conditions.

**Parameters:**

- `tag` : `string` — The tag to watch for.

**Returns:**

- `RBXScriptSignal` — An event that fires when you remove the tag from an instance.

### `CollectionService:GetTagged`

```
GetTagged(tag: string) -> Instances
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Returns an array of instances in the game with a given tag.

This method returns an array of instances with a given tag which are
descendants of the `Class.DataModel`. Removing a tag using
`Class.CollectionService:RemoveTag()` or `Class.Instance:RemoveTag()`
ensures this method does not return them.

If you want to detect all instances with a tag, both present **and**
future, use this method to iterate over instances while also making a
connection to a signal returned by
`Class.CollectionService:GetInstanceAddedSignal()|GetInstanceAddedSignal()`.

This method does not guarantee any ordering of the returned instances.
Additionally, it's possible that instances can have the given tag assigned
to them but not be a descendant of the `Class.DataModel`, for example its
parent is `nil`; this method will not return such instances.

**Parameters:**

- `tag` : `string` — The tag to search for.

**Returns:**

- `Instances` — An array of all instances with the tag.

### `CollectionService:GetTags`

```
GetTags(instance: Instance) -> Array
```

- security=`None` ; thread-safety=`Safe` ; tags=`CustomLuaState` ; capabilities=`Basic`

Gets an array of all tags applied to a given instance.

Given an `Class.Instance`, this method returns an array of strings which
are the tags applied to the instance.

This method is useful when you want to do something with multiple instance
tags at once, but it's inefficient to check for the existence of a single
tag. For this, use `Class.CollectionService:HasTag()|HasTag()` to check
for a single tag.

**Parameters:**

- `instance` : `Instance` — The instance whose tags should be returned.

**Returns:**

- `Array` — An array of strings which are the tags applied to the given instance.

### `CollectionService:HasTag`

```
HasTag(instance: Instance, tag: string) -> boolean
```

- security=`None` ; thread-safety=`Safe` ; tags=`CustomLuaState` ; capabilities=`Basic`

Check whether an instance has a given tag.

This method returns whether a given `Class.Instance` has a tag.

By extension, any tags returned by a call to
`Class.CollectionService:GetTags()|GetTags()` on an instance will return
`true` when used with this method.

**Parameters:**

- `instance` : `Instance` — The instance to check for the presence of a tag.
- `tag` : `string` — The tag to check for.

**Returns:**

- `boolean` — Whether the instance has the tag.

### `CollectionService:RemoveTag`

```
RemoveTag(instance: Instance, tag: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Basic`

Removes a tag from an instance.

This method removes a tag from an instance. Successfully removing a tag
will fire a signal created by
`Class.CollectionService:GetInstanceRemovedSignal()|GetInstanceRemovedSignal()`
with the given tag.

When removing a tag, it's common that some resources are used to give the
tag its functionality, for example event connections or tables. To prevent
memory leaks, it's a good idea to clean these up (disconnect, set to
`nil`, etc.) when no longer needed for a tag.

**Parameters:**

- `instance` : `Instance` — The instance to remove the tag from.
- `tag` : `string` — The tag to remove from the instance.

**Returns:**

- `()` — 

## Events

### `CollectionService.ItemAdded`

```
ItemAdded(instance: Instance)
```

- security=`None` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This item has been superseded by a `Class.CollectionService` tagging
method. There is currently no means of checking when a tag is added.

Fires when a `Class.Configuration`, `Class.CustomEvent`,
`Class.CustomEventReceiver`, `Class.Dialog`, or `Class.VehicleSeat` is
added to the `Class.DataModel`.

This function fires when a `Class.Configuration`, `Class.CustomEvent`,
`Class.CustomEventReceiver`, `Class.Dialog`, or `Class.VehicleSeat` is
added to the `Class.DataModel`.

**Parameters:**

- `instance` : `Instance` — 

### `CollectionService.ItemRemoved`

```
ItemRemoved(instance: Instance)
```

- security=`None` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This item has been superseded by a `Class.CollectionService` tagging
method. There is currently no means of checking when a tag is removed.

Fires when a `Class.Configuration`, `Class.CustomEvent`,
`Class.CustomEventReceiver`, `Class.Dialog`, or `Class.VehicleSeat` is
removed from the `Class.DataModel`.

This function fires when a `Class.Configuration`, `Class.CustomEvent`,
`Class.CustomEventReceiver`, `Class.Dialog`, or `Class.VehicleSeat` is
removed from the `Class.DataModel`.

**Parameters:**

- `instance` : `Instance` — 

### `CollectionService.TagAdded`

```
TagAdded(tag: string)
```

- security=`None` ; capabilities=`Basic`

Fires when a tag is added to an instance and the added tag is the only
occurrence of that tag in the place.

This event fires when a tag is added to an instance and the added tag is
the only occurrence of that tag in the place.

**Parameters:**

- `tag` : `string` — 

### `CollectionService.TagRemoved`

```
TagRemoved(tag: string)
```

- security=`None` ; capabilities=`Basic`

Fires when a tag is removed from an instance and the removed tag is no
longer used anywhere in the place.

This event fires when a tag is removed from an instance and the removed
tag is no longer used anywhere in the place.

**Parameters:**

- `tag` : `string` — 

## Notes / Deprecations

- Deprecated method `CollectionService:GetCollection`: This item has been superseded by a `Class.CollectionService` tagging
method. The equivalent function using the new method is
`Class.CollectionService:GetTagged()` which should be used in new work.
- Deprecated event `CollectionService.ItemAdded`: This item has been superseded by a `Class.CollectionService` tagging
method. There is currently no means of checking when a tag is added.
- Deprecated event `CollectionService.ItemRemoved`: This item has been superseded by a `Class.CollectionService` tagging
method. There is currently no means of checking when a tag is removed.

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- CollectionService:GetCollection: CollectionService-GetCollection1
- CollectionService:GetInstanceAddedSignal: Deadly-Bricks-using-CollectionService
- CollectionService:GetInstanceRemovedSignal: Deadly-Bricks-using-CollectionService
- CollectionService:GetTagged: Deadly-Bricks-using-CollectionService
- CollectionService:GetTags: Using-Tags-and-CollectionService
- CollectionService:HasTag: Using-Tags-and-CollectionService
- CollectionService:RemoveTag: Using-Tags-and-CollectionService
- CollectionService.ItemAdded: CollectionService-ItemAdded1
- CollectionService.ItemRemoved: CollectionService-ItemRemoved1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/CollectionService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/CollectionService.yaml
- Captured: 2026-04-16
