---
title: BindableEvent
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/BindableEvent
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/BindableEvent.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: events
tags: [roblox-class, events, in-context]
---

# BindableEvent

An object which enables custom events through asynchronous one-way
communication between scripts on the same side of the client-server boundary.
Scripts firing a `Class.BindableEvent` do not yield.

## Description

The **BindableEvent** object enables custom events through asynchronous
one-way communication between scripts on the same side of the
[client-server](../../../projects/client-server.md) boundary. When you fire a
`Class.BindableEvent` through the `Class.BindableEvent:Fire()` method, the
firing script does **not** yield and the target function receives the passed
arguments with certain [limitations](#argument-limitations).
`Class.BindableEvent|BindableEvents` create threads of each connected
function, so even if one firing errors, others continue.

As an alternative for two-way communication between two scripts on the same
side of the client-server boundary, consider `Class.BindableFunction`.

As stated, `Class.BindableEvent|BindableEvents` do not allow for communication
between the server and clients. If you are looking for this functionality, use
a `Class.RemoteEvent` as outlined in
[Remote Events and Callbacks](../../../scripting/events/remote.md).

See [Bindable events and callbacks](../../../scripting/events/bindable.md) for
code samples and further details on `Class.BindableEvent`.

#### Parameter Limitations

Any type of Roblox object such as an `Datatype.Enum`, `Class.Instance`, or
others can be passed as a parameter when a `Class.BindableEvent` is fired, as
well as Luau types such as numbers, strings, and booleans, although you should
carefully explore the
[limitations](../../../scripting/events/bindable.md#argument-limitations).

## Inheritance

Inherits from: `Instance`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `BindableEvent:Fire`

```
Fire(arguments: Tuple) -> ()
```

- security=`None` ; thread-safety=`Safe`

Fires the `Class.BindableEvent` which in turn fires the
`Class.BindableEvent.Event|Event` event.

Fires the `Class.BindableEvent` which in turn fires the
`Class.BindableEvent.Event|Event` event. This method does not yield, even
if no script has connected to the event, and even if a connected function
yields.

Any type of Roblox object such as an `Datatype.Enum`, `Class.Instance`, or
others can be passed as a parameter to
`Class.BindableEvent:Fire()|Fire()`, as well as Luau types such as
numbers, strings, and booleans, although you should carefully explore the
[limitations](../../../scripting/events/bindable.md#argument-limitations).

See [Bindable events and callbacks](../../../scripting/events/bindable.md)
for code samples and further details on
`Class.BindableEvent:Fire()|Fire()`.

**Parameters:**

- `arguments` : `Tuple` — Values to pass to `Class.BindableEvent.Event|Event` events connected to the same `Class.BindableEvent`.

**Returns:**

- `()` — 

## Events

### `BindableEvent.Event`

```
Event(arguments: Tuple)
```

- security=`None`

Fires when any script calls the `Class.BindableEvent:Fire()|Fire()` method
on the same `Class.BindableEvent` instance.

Fires when any script calls the `Class.BindableEvent:Fire()|Fire()` method
on the same `Class.BindableEvent` instance, using the same arguments as
parameters.

See [Bindable events and callbacks](../../../scripting/events/bindable.md)
for code samples and further details on `Class.BindableEvent.Event|Event`.

**Parameters:**

- `arguments` : `Tuple` — The parameters sent through `Class.BindableEvent:Fire()|Fire()`.

## Notes / Deprecations

_None flagged in source YAML._

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/BindableEvent
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/BindableEvent.yaml
- Captured: 2026-04-16
