---
title: Animation
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Animation
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Animation.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: animation
tags: [roblox-class, animation, asset]
---

# Animation

References an animation asset which can be loaded by an
`Class.AnimationController`.

## Description

An object that references an animation asset
(`Class.Animation.AnimationId|AnimationId`) which can be loaded by an
`Class.AnimationController`.

#### Loading an Animation on Client or Server

In order for `Class.AnimationTrack|AnimationTracks` to replicate correctly,
it's important to know when they should be loaded on the client or on the
server:

- If an `Class.Animator` is a descendant of a `Class.Humanoid` or
  `Class.AnimationController` in a player's `Class.Player.Character`,
  animations started on that player's client will be replicated to the server
  and other clients.

- If the `Class.Animator` is **not** a descendant of a player character, its
  animations must be loaded and started on the server to replicate.

The `Class.Animator` object must be initially created on the server and
replicated to clients for animation replication to work at all. If an
`Class.Animator` is created locally, then
`Class.AnimationTrack|AnimationTracks` loaded with that `Class.Animator` will
not replicate.

See also [Animation Editor](../../../animation/editor.md) and
[Using Animations](../../../animation/using.md) to learn how to create and add
pre-built or custom animations to your game.

## Inheritance

Inherits from: `Instance`

Memory category: `Animation`

## Properties

### `Animation.AnimationId`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Animation`

Asset ID of the animation an `Class.Animation` object is referencing.

This property is the asset ID of the animation an `Class.Animation` object
is referencing. Once an animation has been created and uploaded to Roblox,
the ID can be copied from the
[Creator Dashboard](https://create.roblox.com/dashboard/creations?activeTab=Animation).

Note that the animation will need to be loaded onto an
`Class.AnimationTrack` in order to play it.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `Animation.AnimationId` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Animation
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Animation.yaml
- Captured: 2026-04-16
