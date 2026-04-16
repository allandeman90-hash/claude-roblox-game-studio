---
title: UnreliableRemoteEvent
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UnreliableRemoteEvent.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: networking
tags: [roblox-class, networking, events, unreliable]
---

# UnreliableRemoteEvent

An object which facilitates asynchronous, unordered and unreliable, one-way
communication across the client-server boundary. Scripts firing a
`Class.UnreliableRemoteEvent` do not yield.

## Description

The **UnreliableRemoteEvent** object is a variant of the `Class.RemoteEvent`
object. It facilitates asynchronous, unordered and unreliable, one-way
communication across the [client-server](../../../projects/client-server.md)
boundary without yielding for a response. This communication can be directed
from one client to the server, from the server to a specific client, or from
the server to all clients.

In order for both the server and clients to access a
`Class.UnreliableRemoteEvent` instance, it must be in a place where both sides
can see it, such as `Class.ReplicatedStorage`, although in some cases it's
appropriate to store it in `Class.Workspace` or inside a `Class.Tool`.

`Class.UnreliableRemoteEvent` is best used for ephemeral events, including
effects that are only relevant for a short time, or for replicating
continuously changing data. These events are not resent if they are lost and
they do not wait for previously fired events to arrive before being processed,
potentially resulting in reduced latency and network traffic. When you need
ordering and reliability, use a `Class.RemoteEvent` instead.

If no connected listener exists to handle an event, you might see a
`Remote event invocation discarded` error in the log to indicate that the
event was discarded and that you need to implement either `OnClientEvent` or
`OnServerEvent`.

#### Throttling

Remote events are subject to rate limits when sent from the client to the
server with the `Class.RemoteEvent:FireServer()|FireServer()` method.
`Class.RemoteEvent|RemoteEvents` and
`Class.UnreliableRemoteEvent|UnreliableRemoteEvents` both have a limit of
approximately 500 requests per second, per client. This limit is **shared
among all remote events of the same type**. To avoid throttling and latency
issues, limit recurring remote events whenever possible.

#### Parameter limitations

Any type of Roblox object (`Datatype.Enum`, `Class.Instance`, etc.) can be
passed as a parameter when an `Class.UnreliableRemoteEvent` is fired, as well
as Luau types such as numbers, strings, and booleans, although you should
carefully explore the
[limitations](../../../scripting/events/remote.md#argument-limitations).

Events with payloads larger than 1000 bytes are dropped. When this happens in
Studio, a log message in the [Output](../../../studio/output.md) window
indicates the number of bytes the event went over.

Like all events, the `Class.UnreliableRemoteEvent` methods encode and compress
certain object types, such as buffers, which shrinks the payload size and can
make it difficult to verify whether you are under the limit prior to firing
the event. If you frequently reach this limit, consider whether a standard
`Class.RemoteEvent` is the better fit for your use case.

## Inheritance

Inherits from: `BaseRemoteEvent`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `UnreliableRemoteEvent:FireAllClients`

```
FireAllClients(arguments: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`RemoteEvent`

Fires the `Class.UnreliableRemoteEvent.OnClientEvent|OnClientEvent` event
for all connected clients. Has a 1000 byte limit to the payload of the
event. Events with larger payloads are dropped.

Fires the `Class.UnreliableRemoteEvent.OnClientEvent|OnClientEvent` event
for all connected clients. Unlike
`Class.UnreliableRemoteEvent:FireClient()|FireClient()`, this event does
not take a target `Class.Player` as the first argument, since it fires to
multiple clients. Since this method is used to communicate from the server
to clients, it only works when used in a `Class.Script`.

**Parameters:**

- `arguments` : `Tuple` — Values to pass to all `Class.UnreliableRemoteEvent.OnClientEvent|OnClientEvent` events connected to the same `Class.UnreliableRemoteEvent`.

**Returns:**

- `()` — 

### `UnreliableRemoteEvent:FireClient`

```
FireClient(player: Player, arguments: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`RemoteEvent`

Fires the `Class.UnreliableRemoteEvent.OnClientEvent|OnClientEvent` event
for a specific client. Has a 1000 byte limit to the payload of the event.
Events with larger payloads are dropped.

Fires the `Class.UnreliableRemoteEvent.OnClientEvent|OnClientEvent` event
for the specific client in the required `Class.Player` argument. Since
this method is used to communicate from the server to a client, it only
works when used in a `Class.Script`.

**Parameters:**

- `player` : `Player` — The client of the `Class.Player` to fire the event to.
- `arguments` : `Tuple` — Values to pass to `Class.UnreliableRemoteEvent.OnClientEvent|OnClientEvent` events connected to the same `Class.UnreliableRemoteEvent`.

**Returns:**

- `()` — 

### `UnreliableRemoteEvent:FireServer`

```
FireServer(arguments: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`RemoteEvent`

Fires the `Class.UnreliableRemoteEvent.OnServerEvent|OnServerEvent` event
on the server from one connected client. Has a 1000 byte limit to the
payload of the event. Events with larger payloads are dropped.

Fires the `Class.UnreliableRemoteEvent.OnServerEvent|OnServerEvent` event
on the server from one connected client. Connected events receive the
`Class.Player` argument of the firing client. Since this method is used to
communicate from a client to the server, it only works when used in a
client script.

**Parameters:**

- `arguments` : `Tuple` — Values to pass to `Class.UnreliableRemoteEvent.OnServerEvent|OnServerEvent` events connected to the same `Class.UnreliableRemoteEvent`.

**Returns:**

- `()` — 

## Events

### `UnreliableRemoteEvent.OnClientEvent`

```
OnClientEvent(arguments: Tuple)
```

- security=`None` ; capabilities=`RemoteEvent`

Fires from a `Class.LocalScript` when either
`Class.UnreliableRemoteEvent:FireClient()|FireClient()` or
`Class.UnreliableRemoteEvent:FireAllClients()|FireAllClients()` is called
on the same `Class.UnreliableRemoteEvent` instance from a `Class.Script`,
although this firing is not guaranteed even if one of the above methods
are called. This can occur due to packet loss or to maintain optimal
engine performance.

Fires from a `Class.LocalScript` when either
`Class.UnreliableRemoteEvent:FireClient()|FireClient()` or
`Class.UnreliableRemoteEvent:FireAllClients()|FireAllClients()` is called
on the same `Class.UnreliableRemoteEvent` instance from a `Class.Script`,
although this firing is not guaranteed even if one of the above methods
are called. This can occur due to packet loss or to maintain optimal
engine performance.

Also note that it is not guaranteed that the order of events will match
the order of `Class.UnreliableRemoteEvent:FireClient()|FireClient()` or
`Class.UnreliableRemoteEvent:FireAllClients()|FireAllClients()` calls.

**Parameters:**

- `arguments` : `Tuple` — The parameters sent through `Class.UnreliableRemoteEvent:FireClient()|FireClient()` or `Class.UnreliableRemoteEvent:FireAllClients()|FireAllClients()`.

### `UnreliableRemoteEvent.OnServerEvent`

```
OnServerEvent(player: Player, arguments: Tuple)
```

- security=`None` ; capabilities=`RemoteEvent`

Fires from a `Class.Script` when
`Class.UnreliableRemoteEvent:FireServer()|FireServer()` is called on the
same `Class.UnreliableRemoteEvent` instance from a `Class.LocalScript`,
although this firing is not guaranteed even if the above methods is
called. This can occur due to packet loss or to maintain optimal engine
performance.

Fires from a `Class.Script` when
`Class.UnreliableRemoteEvent:FireServer()|FireServer()` is called on the
same `Class.UnreliableRemoteEvent` instance from a `Class.LocalScript`,
although this firing is not guaranteed even if the above methods is
called. This can occur due to packet loss or to maintain optimal engine
performance.

Also note that it is not guaranteed that the order of events will match
the order of `Class.UnreliableRemoteEvent:FireServer()|FireServer()`
calls.

**Parameters:**

- `player` : `Player` — The `Class.Player` associated with the client that the `Class.UnreliableRemoteEvent:FireServer()|FireServer()` call originates from.
- `arguments` : `Tuple` — The parameters sent through `Class.UnreliableRemoteEvent:FireServer()|FireServer()`.

## Notes / Deprecations

_None flagged in source YAML._

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UnreliableRemoteEvent.yaml
- Captured: 2026-04-16
