---
title: RemoteEvent
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/RemoteEvent
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/RemoteEvent.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: networking
tags: [roblox-class, networking, events]
---

# RemoteEvent

An object which facilitates asynchronous, one-way communication across the
client-server boundary. Scripts firing a `Class.RemoteEvent` do not yield.

## Description

The **RemoteEvent** object facilitates asynchronous, one-way communication
across the [client-server](../../../projects/client-server.md) boundary
without yielding for a response. This communication can be directed from one
client to the server, from the server to a specific client, or from the server
to all clients.

In order for both the server and clients to access a `Class.RemoteEvent`
instance, it must be in a place where both sides can see it, such as
`Class.ReplicatedStorage`, although in some cases it's appropriate to store it
in `Class.Workspace` or inside a `Class.Tool`.

If no connected listener exists to handle an event, you might see a
`Remote event invocation discarded` error in the log to indicate that the
event was discarded and that you need to implement either `OnClientEvent` or
`OnServerEvent`. Unlike `Class.UnreliableRemoteEvent|UnreliableRemoteEvents`,
`Class.RemoteEvent|RemoteEvents` buffer a large number of events before
throwing this error.

If you need the result of the call, you should use a `Class.RemoteFunction`
instead. Otherwise a remote event is recommended since it will minimize
network traffic/latency and won't yield the script to wait for a response.

See [Remote events and callbacks](../../../scripting/events/remote.md) for
code samples and further details.

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
passed as a parameter when a `Class.RemoteEvent` is fired, as well as Luau
types such as numbers, strings, and booleans, although you should carefully
explore the
[limitations](../../../scripting/events/remote.md#argument-limitations).

## Inheritance

Inherits from: `BaseRemoteEvent`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `RemoteEvent:FireAllClients`

```
FireAllClients(arguments: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`RemoteEvent`

Fires the `Class.RemoteEvent.OnClientEvent|OnClientEvent` event for each
connected client.

Fires the `Class.RemoteEvent.OnClientEvent|OnClientEvent` event for each
connected client. Unlike `Class.RemoteEvent:FireClient()|FireClient()`,
this event does not take a target `Class.Player` as the first argument,
since it fires to multiple clients. Since this method is used to
communicate from the server to clients, it only works when used in a
`Class.Script`.

**Parameters:**

- `arguments` : `Tuple` — Values to pass to all `Class.RemoteEvent.OnClientEvent|OnClientEvent` events connected to the same `Class.RemoteEvent`.

**Returns:**

- `()` — 

### `RemoteEvent:FireClient`

```
FireClient(player: Player, arguments: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`RemoteEvent`

Fires the `Class.RemoteEvent.OnClientEvent|OnClientEvent` event for a
specific client.

Fires the `Class.RemoteEvent.OnClientEvent|OnClientEvent` event for the
specific client in the required `Class.Player` argument. Since this method
is used to communicate from the server to a client, it only works when
used in a `Class.Script`.

**Parameters:**

- `player` : `Player` — The client of the `Class.Player` to fire the event to.
- `arguments` : `Tuple` — Values to pass to `Class.RemoteEvent.OnClientEvent|OnClientEvent` events connected to the same `Class.RemoteEvent`.

**Returns:**

- `()` — 

### `RemoteEvent:FireServer`

```
FireServer(arguments: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`RemoteEvent`

Fires the `Class.RemoteEvent.OnServerEvent|OnServerEvent` event on the
server from one connected client.

Fires the `Class.RemoteEvent.OnServerEvent|OnServerEvent` event on the
server from one client. Connected events receive the `Class.Player`
argument of the firing client. Since this method is used to communicate
from a client to the server, it only works when used in a client script.

**Parameters:**

- `arguments` : `Tuple` — Values to pass to `Class.RemoteEvent.OnServerEvent|OnServerEvent` events connected to the same `Class.RemoteEvent`.

**Returns:**

- `()` — 

## Events

### `RemoteEvent.OnClientEvent`

```
OnClientEvent(arguments: Tuple)
```

- security=`None` ; capabilities=`RemoteEvent`

Fires from a `Class.LocalScript` when either
`Class.RemoteEvent:FireClient()|FireClient()` or
`Class.RemoteEvent:FireAllClients()|FireAllClients()` is called on the
same `Class.RemoteEvent` instance from a `Class.Script`.

Fires from a `Class.LocalScript` when either
`Class.RemoteEvent:FireClient()|FireClient()` or
`Class.RemoteEvent:FireAllClients()|FireAllClients()` is called on the
same `Class.RemoteEvent` instance from a `Class.Script`.

See [Remote Events and Callbacks](../../../scripting/events/remote.md) for
code samples and further details on
`Class.RemoteEvent.OnClientEvent|OnClientEvent`.

**Parameters:**

- `arguments` : `Tuple` — The parameters sent through `Class.RemoteEvent:FireClient()|FireClient()` or `Class.RemoteEvent:FireAllClients()|FireAllClients()`.

### `RemoteEvent.OnServerEvent`

```
OnServerEvent(player: Player, arguments: Tuple)
```

- security=`None` ; capabilities=`RemoteEvent`

Fires from a `Class.Script` when
`Class.RemoteEvent:FireServer()|FireServer()` is called on the same
`Class.RemoteEvent` instance from a `Class.LocalScript`.

Fires from a `Class.Script` when
`Class.RemoteEvent:FireServer()|FireServer()` is called on the same
`Class.RemoteEvent` instance from a `Class.LocalScript`.

See [Remote Events and Callbacks](../../../scripting/events/remote.md) for
code samples and further details on
`Class.RemoteEvent.OnServerEvent|OnServerEvent`.

**Parameters:**

- `player` : `Player` — The `Class.Player` associated with the client that the `Class.RemoteEvent:FireServer()|FireServer()` call originates from.
- `arguments` : `Tuple` — The parameters sent through `Class.RemoteEvent:FireServer()|FireServer()`.

## Notes / Deprecations

_None flagged in source YAML._

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/RemoteEvent
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/RemoteEvent.yaml
- Captured: 2026-04-16
