---
title: RemoteFunction
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/RemoteFunction
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/RemoteFunction.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: networking
tags: [roblox-class, networking, rpc]
---

# RemoteFunction

An object which facilitates synchronous, two-way communication across the
client-server boundary. Scripts invoking a `Class.RemoteFunction` yield until
they receive a response from the recipient.

## Description

The **RemoteFunction** object facilitates synchronous, two-way communication
across the [client-server](../../../projects/client-server.md) boundary. You
can use it to define a custom callback function and invoke it manually by
calling `Class.RemoteFunction:InvokeClient()` or
`Class.RemoteFunction:InvokeServer()`. The code invoking the function
**yields** until it receives a response from the recipient.

In order for both the server and clients to access a `Class.RemoteFunction`
instance, it must be in a place where both sides can see it, such as
`Class.ReplicatedStorage`, although in some cases it's appropriate to store it
in `Class.Workspace` or inside a `Class.Tool`.

If the result is **not** needed, it is recommended that you use a
`Class.RemoteEvent` instead, since its call is asynchronous and doesn't need
to wait for a response to continue execution. See
[Remote Events and Callbacks](../../../scripting/events/remote.md) for code
samples and further details on `Class.RemoteFunction`.

#### Streaming Precautions

Note that if an invoked `Class.RemoteFunction` creates an instance on the
server, there is no guarantee that it exists on the client when the function
returns. This is particularly important in places where instance
[streaming](../../../workspace/streaming/index.md) is enabled and when the
created instances are `Class.BasePart|BaseParts` or `Class.Model|Models`,
since parts that are far away from the player's character may not be streamed
to the client, and models that are `Enum.ModelStreamingMode|Atomic` depend on
whether their parts are streamed. Even if a model is
`Enum.ModelStreamingMode|Persistent`, there may be some delay between the
creation of the model and when it is replicated to the client.

#### Parameter Limitations

Any type of Roblox object such as an `Datatype.Enum`, `Class.Instance`, or
others can be passed as a parameter when a `Class.RemoteFunction` is invoked,
as well as Luau types such as numbers, strings, and booleans, although you
should carefully explore the
[limitations](../../../scripting/events/remote.md#argument-limitations).

## Inheritance

Inherits from: `Instance`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `RemoteFunction:InvokeClient`

```
InvokeClient(player: Player, arguments: Tuple) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`RemoteEvent`

Invokes the `Class.RemoteFunction` which in turn calls the
`Class.RemoteFunction.OnClientInvoke|OnClientInvoke` callback.

Invokes the `Class.RemoteFunction` which in turn calls the
`Class.RemoteFunction.OnClientInvoke|OnClientInvoke` callback. Since this
method is used to communicate from the server to a client, it will only
work when used in a `Class.Script`.

Any type of Roblox object such as an `Datatype.Enum`, `Class.Instance`, or
others can be passed as a parameter to
`Class.RemoteFunction:InvokeClient()|InvokeClient()`, as well as Luau
types such as numbers, strings, and booleans, although you should
carefully explore the
[limitations](../../../scripting/events/remote.md#argument-limitations).

See [Remote Events and Callbacks](../../../scripting/events/remote.md) for
code samples and further details on `Class.RemoteFunction`.

#### Warning

In practice, the server does not often invoke the client, as clients
typically do not have information that the server doesn't have, and
actions that only a client can take, such as displaying a GUI, typically
do not require a callback. As such, `Class.RemoteEvent:FireClient()` is
recommended as an asynchronous method that doesn't need to wait for a
response to continue execution.

If you legitimately need to invoke a client from the server, note the
following risks:

- If the client throws an error, the server throws the error too.
- If the client disconnects while it's being invoked,
  `Class.RemoteFunction:InvokeClient()|InvokeClient()` throws an error.
- If the client doesn't return a value, the server yields forever.

**Parameters:**

- `player` : `Player` — The `Class.Player` associated with the client to invoke.
- `arguments` : `Tuple` — Values to pass to the `Class.RemoteFunction.OnClientInvoke|OnClientInvoke` callback.

**Returns:**

- `Tuple` — Values returned from the `Class.RemoteFunction.OnClientInvoke|OnClientInvoke` callback.

### `RemoteFunction:InvokeServer`

```
InvokeServer(arguments: Tuple) -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`RemoteEvent`

Invokes the `Class.RemoteFunction` which in turn calls the
`Class.RemoteFunction.OnServerInvoke|OnServerInvoke` callback.

Invokes the `Class.RemoteFunction` which in turn calls the
`Class.RemoteFunction.OnServerInvoke|OnServerInvoke` callback. Since this
method is used to communicate from a client to the server, it will only
work when used in a `Class.LocalScript`.

If a returned result is not needed, it's recommended to use
`Class.RemoteEvent:FireServer()` instead, as its call is asynchronous and
doesn't need to wait for a response to continue execution.

Any type of Roblox object such as an `Datatype.Enum`, `Class.Instance`, or
others can be passed as a parameter to
`Class.RemoteFunction:InvokeServer()|InvokeServer()`, as well as Luau
types such as numbers, strings, and booleans, although you should
carefully explore the
[limitations](../../../scripting/events/remote.md#argument-limitations).

See [Remote Events and Callbacks](../../../scripting/events/remote.md) for
code samples and further details on `Class.RemoteFunction`.

**Parameters:**

- `arguments` : `Tuple` — Values to pass to the `Class.RemoteFunction.OnServerInvoke|OnServerInvoke` callback.

**Returns:**

- `Tuple` — Values returned from the `Class.RemoteFunction.OnServerInvoke|OnServerInvoke` callback.

## Events

_No public events documented._

## Notes / Deprecations

- Method `RemoteFunction:InvokeClient` yields (tag `Yields`).
- Method `RemoteFunction:InvokeServer` yields (tag `Yields`).

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/RemoteFunction
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/RemoteFunction.yaml
- Captured: 2026-04-16
