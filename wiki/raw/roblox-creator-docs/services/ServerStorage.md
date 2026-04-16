---
title: ServerStorage
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ServerStorage
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ServerStorage.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: containers
tags: [roblox-class, containers, server]
---

# ServerStorage

A container whose contents are only accessible on the server. Objects
descending from ServerStorage will not replicate to the client and will not be
accessible from `Class.LocalScript|LocalScripts`.

## Description

A container whose contents are only accessible on the server. Objects
descending from ServerStorage will not replicate to the client and will not be
accessible from `Class.LocalScript|LocalScripts`.

As ServerStorage is a service it can only be accessed using the
`Class.DataModel.GetService` method.

By storing large objects such as maps in ServerStorage until they are needed,
network traffic will not be used up transmitting these objects to the client
when they join the game.

`Class.Script|Scripts` will not run when they are parented to ServerStorage,
although `Class.ModuleScript|ModuleScripts` contained within can be accessed
and ran. It is recommended developers use `Class.ServerScriptService` to hold
`Class.Script|Scripts` they wish the server to execute.

Note that as the contents of ServerStorage can only be accessed by the server,
its contents will need to be parented elsewhere (such as `Class.Workspace`)
before clients can access them. Developers who require a container that is
accessible by both the server and client are advised to use
`Class.ReplicatedStorage` instead.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`, `NotReplicated`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

_None flagged in source YAML._

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `ServerStorage-Maps` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/ServerStorage

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ServerStorage
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ServerStorage.yaml
- Captured: 2026-04-16
