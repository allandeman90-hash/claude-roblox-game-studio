---
title: SoundGroup
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/SoundGroup
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/SoundGroup.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: audio
tags: [roblox-class, audio, mixing]
---

# SoundGroup

A `Class.SoundGroup` is used to manage the volume and sound effects on
multiple `Class.Sound|Sounds` at once. `Class.Sound|Sounds` in the SoundGroup
will have their volume and effects adjusted by the SoundGroup.

## Description

A `Class.SoundGroup` is used to manage the volume and effects on multiple
`Class.Sound|Sounds` at once. Every sound in the sound group will have its
volume adjusted by the group's `Class.SoundGroup.Volume|Volume` property which
acts as a multiplier, meaning a `Class.Sound` with volume `0.5` assigned to a
`Class.SoundGroup` with a volume of `0.5` will have an effective volume of
`0.25`.

If the `Class.SoundGroup` has any `Class.SoundEffect|SoundEffects` as
children, those effects will be applied to all of the `Class.Sound|Sounds` in
the group.

Note that a `Class.Sound` must be added to a `Class.SoundGroup` by setting its
`Class.Sound.SoundGroup|SoundGroup` property, not by simply parenting the
`Class.Sound` to the `Class.SoundGroup`. A `Class.Sound` can only belong to
one `Class.SoundGroup` at a time, although you can nest groups as outlined
[here](../../../sound/groups.md#nesting-soundgroups).

See [Sound Groups](../../../sound/groups.md) for further details on working
with the `Class.SoundGroup` class.

## Inheritance

Inherits from: `Instance`

Memory category: `Internal`

## Properties

### `SoundGroup.Volume`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

The volume multiplier applied to `Class.Sound|Sounds` that are in the
`Class.SoundGroup`.

The volume multiplier applied to `Class.Sound|Sounds` which belong to the
`Class.SoundGroup`. Value can range from `0` to `10`.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `SoundGroup.Volume` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- SoundGroup.Volume: Sound-SoundGroup

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/SoundGroup
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/SoundGroup.yaml
- Captured: 2026-04-16
