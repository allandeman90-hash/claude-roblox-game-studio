---
title: Debris
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Debris
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Debris.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: utility
tags: [roblox-class, cleanup, scheduling, utility]
---

# Debris

Allows scheduling the guaranteed destruction of an object without yielding.  
.

## Description

The **Debris** service allows scheduling guaranteed destruction of an object
without yielding.

#### Advantages

Besides creating a bit of a mess, objects that are no longer required can use
up system memory and cause an experience to run slower over time. For this
reason, it's always advised to call `Class.Instance:Destroy()` on objects you
no longer need. In some cases, however, an object may have a specific period
of utility before it can be destroyed.

Consider a wall being smashed into individual bricks. If you want a brick to
linger for 3 seconds before being destroyed, you can use the following code:

```lua
task.wait(3)
brick:Destroy()
```

However, waiting causes the thread to yield which may be undesired. To avoid
yielding, a callback function can be scheduled to run on a new thread after 3
seconds:

```lua
task.delay(3, function()
	brick:Destroy()
end)
```

Or in one line:

```lua
task.delay(3, brick.Destroy, brick)
```

While this now avoids yielding, it has a potential drawback in that the
scheduled callback will never run if the script is disabled or destroyed
before the callback runs.

This is where `Class.Debris` has a specific advantage, as it does not yield
the current thread and runs outside the context of the script, guaranteeing
the instance is eventually destroyed even if the script is disabled or
destroyed. The following code does not yield and guarantees the instance will
be destroyed:

```lua
Debris:AddItem(brick, 3)
```

Note that `Class.Debris` has a hardcoded maximum of 1,000 objects, so if more
than 1,000 items are added, the oldest debris will be destroyed instantly to
make room for new debris.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

### `Debris.MaxItems`

- **Type:** `int`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `Basic`
- **Deprecated:** This property is deprecated and should not be used in new work.

The maximum number of items that can be assigned to the `Class.Debris`
service at one time.

The maximum number of items that can be assigned to the Debris service at
one time.

If this number is exceeded, objects are automatically destroyed in order
from oldest to newest until the amount is less than or equal to MaxItems.

This property is currently restricted and will error if set. The value is
hardcoded to 1,000 items.

## Methods

### `Debris:AddItem`

```
AddItem(item: Instance, lifetime: double = 10) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Schedules a given `Class.Instance` for destruction within the specified
lifetime.

Schedules a given `Class.Instance` for destruction within the specified
lifetime. After the `lifetime` argument has elapsed, the object is
destroyed in the same manner as `Class.Instance:Destroy()`. Note that the
`lifetime` argument is optional and defaults to 10 seconds.

Note that `Class.Debris` has a hardcoded maximum of 1,000 objects, so if
more than 1,000 items are added, the oldest debris will be destroyed
instantly to make room for new debris. This means you should treat the
`lifetime` parameter as a **maximum** lifetime, not an exact lifetime.

**Parameters:**

- `item` : `Instance` --- The `Class.Instance` to add to `Class.Debris`.
- `lifetime` : `double` (default `10`) --- Number of seconds before the `Class.Instance` should be destroyed.

**Returns:**

- `()` --- 

### `Debris:addItem`

```
addItem(item: Instance, lifetime: double = 10) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This function is a deprecated variant of `Class.Debris:AddItem()` which
should be used instead.

**Parameters:**

- `item` : `Instance` --- 
- `lifetime` : `double` (default `10`) --- 

**Returns:**

- `()` --- 

## Events

_No public events documented._

## Notes / Deprecations

- Deprecated property `Debris.MaxItems`: This property is deprecated and should not be used in new work.
- Deprecated method `Debris:addItem`: This function is a deprecated variant of `Class.Debris:AddItem()` which
should be used instead.
- Property `Debris.MaxItems` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `Debris-AddItem` --- https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/Debris
- Debris:AddItem: Debris-AddItem

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Debris
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Debris.yaml
- Captured: 2026-04-16
