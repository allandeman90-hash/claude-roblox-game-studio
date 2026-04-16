---
title: Tween
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Tween
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Tween.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: animation
tags: [roblox-class, tweens, animation]
---

# Tween

The `Class.Tween` object controls the playback of an interpolation.

## Description

The `Class.Tween` object controls the playback of an interpolation. Creating
and configuring a `Class.Tween` is done with the `Class.TweenService:Create()`
function; `Datatype.Instance.new()` cannot be used for this particular object.

Note that while the configuration of a tween can be accessed after a tween has
been created, it can not be modified. If new goals are needed for an
interpolation, a new `Class.Tween` must be created.

Also note that multiple tweens can be played on the same object at the same
time, but they must not be interpolating the same property. If two tweens
attempt to modify the same property, the initial tween will be cancelled and
overwritten by the most recent tween.

## Inheritance

Inherits from: `TweenBase`

Memory category: `Instances`

## Properties

### `Tween.Instance`

- **Type:** `Instance`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Basic`

Read-only property that points to the `Class.Instance` whose properties
are being interpolated by the tween.

This property of a `Class.Tween` (read-only) points to the
`Class.Instance` whose properties are being interpolated.

### `Tween.TweenInfo`

- **Type:** `TweenInfo`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Basic`

Read-only property that includes information on how the interpolation of
the `Class.Tween` is to be carried out.

Read-only property that includes information on how the interpolation of
the `Class.Tween` is to be carried out, using the `Datatype.TweenInfo`
data type.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `Tween.Instance` security: `read=None, write=None`
- Property `Tween.TweenInfo` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `Tween-Creation` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/Tween
- Tween.Instance: Tween-Instance
- Tween.TweenInfo: TweenInfo

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Tween
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Tween.yaml
- Captured: 2026-04-16
