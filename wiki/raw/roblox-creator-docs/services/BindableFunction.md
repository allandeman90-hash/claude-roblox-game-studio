---
title: BindableFunction
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/BindableFunction
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/BindableFunction.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: events
tags: [roblox-class, events, rpc, in-context]
---

# BindableFunction

An object which allows for synchronous two-way communication between scripts
on the same side of the client-server boundary. Scripts invoking a
`Class.BindableFunction` yield until the corresponding callback is found.

## Description

The **BindableFunction** object allows for synchronous two-way communication
between scripts on the same side of the
[client-server](../../../projects/client-server.md) boundary. You can use it
to define a custom callback function and invoke it manually by calling
`Class.BindableFunction:Invoke()`. The code invoking the function **yields**
until the corresponding callback is found, and the callback receives the
arguments that you passed to `Class.BindableFunction:Invoke()|Invoke()`. If
the callback was never set, the script that invokes it will not resume
execution.

As an alternative for one-way communication between two scripts on the same
side of the client-server boundary, consider `Class.BindableEvent` which does
**not** yield for a return.

As stated, `Class.BindableFunction|BindableFunctions` do not allow for
communication between the server and clients. If you are looking for this
functionality, use a `Class.RemoteFunction` as outlined in
[Remote events and callbacks](../../../scripting/events/remote.md).

See [Bindable events and callbacks](../../../scripting/events/bindable.md) for
code samples and further details on `Class.BindableFunction`.

#### Parameter Limitations

Any type of Roblox object such as an `Datatype.Enum`, `Class.Instance`, or
others can be passed as a parameter when a `Class.BindableFunction` is
invoked, as well as Luau types such as numbers, strings, and booleans,
although you should carefully explore the
[limitations](../../../scripting/events/bindable.md#argument-limitations).

## Inheritance

Inherits from: `Instance`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `BindableFunction:Invoke`

```
Invoke(arguments: Tuple) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`

Invokes the `Class.BindableFunction` which in turn calls the
`Class.BindableFunction.OnInvoke|OnInvoke` callback, returning any values
returned by the callback.

Invokes the `Class.BindableFunction` which in turn calls the
`Class.BindableFunction.OnInvoke|OnInvoke` callback, returning any values
returned by the callback. Invocations yield until the corresponding
callback is found, and if the callback was never set, the script that
invokes it will not resume execution.

Any type of Roblox object such as an `Datatype.Enum`, `Class.Instance`, or
others can be passed as a parameter to
`Class.BindableFunction:Invoke()|Invoke()`, as well as Luau types such as
numbers, strings, and booleans, although you should carefully explore the
[limitations](../../../scripting/events/bindable.md#argument-limitations).

Only one function can be bound to
`Class.BindableFunction:Invoke()|Invoke()` at a time. If you assign
multiple functions, only the last one assigned will be used.

See [Bindable events and callbacks](../../../scripting/events/bindable.md)
for code samples and further details on
`Class.BindableFunction:Invoke()|Invoke()`.

**Parameters:**

- `arguments` : `Tuple` — Values to pass to the `Class.BindableFunction.OnInvoke|OnInvoke` callback.

**Returns:**

- `Tuple` — Values returned from the `Class.BindableFunction.OnInvoke|OnInvoke` callback.

## Events

_No public events documented._

## Notes / Deprecations

- Method `BindableFunction:Invoke` yields (tag `Yields`).

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/BindableFunction
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/BindableFunction.yaml
- Captured: 2026-04-16
