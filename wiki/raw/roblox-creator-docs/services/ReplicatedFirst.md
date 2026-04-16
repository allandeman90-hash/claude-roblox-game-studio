---
title: ReplicatedFirst
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ReplicatedFirst
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ReplicatedFirst.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: containers
tags: [roblox-class, containers, replication, load]
---

# ReplicatedFirst

A container whose contents are replicated to all clients (but not back to the
server) first before anything else.

## Description

`ReplicatedFirst` is a container whose contents are replicated to all clients
(but not back to the server) before anything else. It's most commonly used to
store `Class.LocalScript|LocalScripts` and other elements that are essential
for the experience's start such as
[loading screens](../../../players/loading-screens.md).

For objects that do **not** need to be replicated before anything else, use
the `Class.ReplicatedStorage` container instead.

There are some key considerations for running `Class.LocalScript|LocalScripts`
in `ReplicatedFirst`:

- Since its contents replicate before anything else in the experience,
  `Class.LocalScript|LocalScripts` running in `ReplicatedFirst` will need to
  wait for any objects they require to replicate using
  `Class.Instance:WaitForChild()`
- Any objects that are to be used by a `Class.LocalScript` in
  `ReplicatedFirst` should also be parented to `ReplicatedFirst`. Otherwise,
  they may replicate to the client late, yielding the script and negating the
  benefit of initial replication.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `ReplicatedFirst:RemoveDefaultLoadingScreen`

```
RemoveDefaultLoadingScreen() -> ()
```

- security=`None` ; thread-safety=`Unsafe`

Immediately removes the default Roblox loading screen.

Immediately removes the default Roblox loading screen. Note that if any
object has been placed in `ReplicatedFirst`, the default loading screen
will be removed after a few seconds regardless if this method has been
called or not.

You should **not** remove the default loading screen unless you want to
display your own. If you remove the default screen without a replacement,
players will be able to see geometry loading in the background.

**Returns:**

- `()` — 

## Events

_No public events documented._

## Notes / Deprecations

_None flagged in source YAML._

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ReplicatedFirst
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ReplicatedFirst.yaml
- Captured: 2026-04-16
