---
title: Animator
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Animator
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Animator.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: animation
tags: [roblox-class, animation, controller]
---

# Animator

Responsible for the playback and replication of `Class.Animation|Animations`.

## Description

The main class responsible for the playback and replication of
`Class.Animation|Animations`. All replication of playing
`Class.AnimationTrack|AnimationTracks` is handled through the `Class.Animator`
instance.

See also [Animation Editor](../../../animation/editor.md) and
[Using Animations](../../../animation/using.md) to learn how to create and add
pre-built or custom animations to your game.

## Inheritance

Inherits from: `Instance`

Memory category: `Instances`

## Properties

### `Animator.EvaluationThrottled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `Safe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Animation`

### `Animator.PreferLodEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Animation`

### `Animator.RootMotion`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `Safe`
- **Tags:** `ReadOnly`, `NotReplicated`, `NotBrowsable`
- **Capabilities:** `Animation`

### `Animator.RootMotionWeight`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `Safe`
- **Tags:** `ReadOnly`, `NotReplicated`, `NotBrowsable`
- **Capabilities:** `Animation`

## Methods

### `Animator:ApplyJointVelocities`

```
ApplyJointVelocities(motors: Variant) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

Computes relative velocities between parts and apply them to
`Class.Motor6D.Part1`. These relative velocity calculations and
assignments happen in the order provided.

Given the current set of `Class.AnimationTrack|AnimationTracks` playing,
and their current times and play speeds, compute relative velocities
between the parts and apply them to Motor6D.Part1 (the part which
`Class.Animator` considers the "child" part). These relative velocity
calculations and assignments happen in the order provided.

This method doesn't apply velocities for a given joint if both of the
joint's parts are currently part of the same assembly, for example, if
they are still connected directly or indirectly by Motors or Welds.

This method doesn't disable or remove the joints for you. You must disable
or otherwise remove the rigid joints from the assembly before calling this
method.

The given `Motor6Ds` are not required to be descendants of the
`Class.DataModel`. Removing the joints from the `Class.DataModel` before
calling this method is supported.

**Parameters:**

- `motors` : `Variant` --- 

**Returns:**

- `()` --- 

### `Animator:GetPlayingAnimationTracks`

```
GetPlayingAnimationTracks() -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

Returns the list of currently playing
`Class.AnimationTrack|AnimationTracks`.

**Returns:**

- `Array` --- 

### `Animator:LoadAnimation`

```
LoadAnimation(animation: Animation) -> AnimationTrack
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

Loads an `Class.Animation` onto an `Class.Animator`, returning an
`Class.AnimationTrack`.

This function loads the given `Class.Animation` onto this
`Class.Animator`, returning a playable `Class.AnimationTrack`. When called
on an `Class.Animator` within models that the client has network ownership
of, for example the local player's character or from
`Class.BasePart:SetNetworkOwner()`, this function also loads the animation
for the server as well.

Note that the `Class.Animator` must be in the `Class.Workspace` before
making a call to `LoadAnimation()` or else it will be unable to retrieve
the `Class.AnimationClipProvider` service and throw an error.

You should use this function directly instead of the similarly-named
`Class.Humanoid:LoadAnimation()` and
`Class.AnimationController:LoadAnimation()` functions. These are
deprecated proxies of this function which also create an `Class.Animator`
if one does not exist; this can cause replication issues if you are not
careful.

#### Loading an Animation on Client or Server

In order for `Class.AnimationTrack|AnimationTracks` to replicate
correctly, it's important to know when they should be loaded on the client
or on the server:

- If an `Class.Animator` is a descendant of a `Class.Humanoid` or
  `Class.AnimationController` in a player's `Class.Player.Character`,
  animations started on that player's client will be replicated to the
  server and other clients.

- If the `Class.Animator` is **not** a descendant of a player character,
  its animations must be loaded and started on the server to replicate.

The `Class.Animator` object must be initially created on the server and
replicated to clients for animation replication to work at all. If an
`Class.Animator` is created locally, then
`Class.AnimationTrack|AnimationTracks` loaded with that `Class.Animator`
will not replicate.

**Parameters:**

- `animation` : `Animation` --- The `Class.Animation` to be used.

**Returns:**

- `AnimationTrack` --- 

### `Animator:RegisterEvaluationParallelCallback`

```
RegisterEvaluationParallelCallback(callback: Function) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

**Parameters:**

- `callback` : `Function` --- 

**Returns:**

- `()` --- 

### `Animator:StepAnimations`

```
StepAnimations(deltaTime: float) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; capabilities=`Animation`

Increments the `Class.AnimationTrack.TimePosition` of all playing
`Class.AnimationTrack|AnimationTracks` that are loaded onto the
`Class.Animator`, applying the offsets to the model associated with the
`Class.Animator`. For use in the command bar or by plugins only.

Increments the `Class.AnimationTrack.TimePosition` of all playing
`Class.AnimationTrack|AnimationTracks` that are loaded onto the
`Class.Animator`, applying the offsets to the model associated with the
`Class.Animator`. For use in the command bar or by plugins only.

The deltaTime parameter determines the number of seconds to increment on
the animation's progress. Typically this function will be called in a loop
to preview the length of an animation (see example).

Note that once animations have stopped playing, the model's joints will
need to be manually reset to their original positions (see example).

This function is used to simulate playback of `Class.Animation|Animations`
when the game isn't running. This allows animations to be previewed
without the consequences of running the game, such as scripts executing.
If the function is called while the game is running, or by
`Class.Script|Scripts` or `Class.LocalScript|LocalScripts`, it will return
an error.

Developers designing their own custom animation editors are advised to use
this function to preview animations, as it is the method the official
Roblox Animation Editor plugin uses.

**Parameters:**

- `deltaTime` : `float` --- The amount of time in seconds animation playback is to be incremented by.

**Returns:**

- `()` --- 

## Events

### `Animator.AnimationPlayed`

```
AnimationPlayed(animationTrack: AnimationTrack)
```

- security=`None` ; capabilities=`Animation`

Fires when the Animator starts playing an AnimationTrack.

Fires for all `Class.AnimationTrack:Play()` calls on AnimationTracks
created and owned by the Animator.

**Parameters:**

- `animationTrack` : `AnimationTrack` --- 

## Notes / Deprecations

- Method `Animator:StepAnimations` security: `PluginSecurity`
- Property `Animator.EvaluationThrottled` security: `read=None, write=None`
- Property `Animator.PreferLodEnabled` security: `read=None, write=None`
- Property `Animator.RootMotion` security: `read=None, write=None`
- Property `Animator.RootMotionWeight` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- Animator:StepAnimations: Animator-StepAnimations

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Animator
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Animator.yaml
- Captured: 2026-04-16
