---
title: ServerScriptService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ServerScriptService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ServerScriptService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: containers
tags: [roblox-class, containers, scripts, server]
---

# ServerScriptService

A container service for server-only `Class.Script` objects.

## Description

**ServerScriptService** is a container service for `Class.Script`,
`Class.ModuleScript` and other scripting-related assets that are only meant
for server use. The contents are never replicated to player clients at all,
which allows for a secure storage of important game logic. Script objects will
run if they are within this service and not
`Class.BaseScript.Disabled|Disabled`.

This service houses just one property,
`Class.ServerScriptService.LoadStringEnabled|LoadStringEnabled`, which
determines whether the `loadstring` function in Luau is enabled. It's
recommended to keep this disabled for security reasons, as misusing this
function can lead to remote code execution vulnerabilities.

Scripts running in ServerScriptService may need access to various other assets
which are not scripting-related, such as prefabricated models to be
`Class.Instance:Clone()|cloned`. Such assets should go in
`Class.ServerStorage`, which behaves similarly to this service except that
`Class.Script` objects will not run even if they are not
`Class.BaseScript.Disabled|Disabled`. Assets and `Class.ModuleScript` that are
useful to both the server and clients should go in `Class.ReplicatedStorage`
instead. Finally, you can further organize objects within this service through
the use of `Class.Folder|Folders` without affecting the way it behaves.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`, `NotReplicated`

Memory category: `Instances`

## Properties

### `ServerScriptService.LoadStringEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `NotScriptable`
- **Capabilities:** `Basic`

Toggles whether or not the `loadstring` function can be used by server
scripts. Defaults to false.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `ServerScriptService.LoadStringEnabled` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ServerScriptService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ServerScriptService.yaml
- Captured: 2026-04-16
