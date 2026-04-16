---
title: AnimationTrack
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/AnimationTrack
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/AnimationTrack.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: animation
tags: [roblox-class, animation, playback, track]
---

# AnimationTrack

Controls the playback of an animation on an `Class.Animator`.

## Description

Controls the playback of an animation on an `Class.Animator`. This object
cannot be created, instead it is returned by the
`Class.Animator:LoadAnimation()` method.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`

Memory category: `Animation`

## Properties

### `AnimationTrack.Animation`

- **Type:** `Animation`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Animation`

The `Class.Animation` object that was used to create this
`Class.AnimationTrack`.

The `Class.Animation` object that was used to create this
`Class.AnimationTrack`. To create an `Class.AnimationTrack`, you must load
an `Class.Animation` object onto an `Class.Animator` using the
`Class.Animator:LoadAnimation()` method.

### `AnimationTrack.IsPlaying`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Animation`

A read-only property that returns true when the `Class.AnimationTrack` is
playing.

A read-only property that returns true when the `Class.AnimationTrack` is
playing.

This property can be used to check if an animation is already playing
before playing it (as that would cause it to restart). If you want to
obtain all playing `Class.AnimationTrack|AnimationTracks` on an
`Class.Animator` or a `Class.Humanoid`, they should use
`Class.Animator:GetPlayingAnimationTracks()`

### `AnimationTrack.Length`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Animation`

A read-only property that returns the length (in seconds) of an
`Class.AnimationTrack`. This will return `0` until the animation has fully
loaded and thus may not be immediately available.

A read-only property that returns the length (in seconds) of an
`Class.AnimationTrack`. This will return `0` until the animation has fully
loaded and thus may not be immediately available.

When the `Class.AnimationTrack.Speed` of an `Class.AnimationTrack` is
equal to `1`, the animation will take `Class.AnimationTrack.Length` (in
seconds) to complete.

### `AnimationTrack.Looped`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Animation`

Sets whether the animation will repeat after finishing. If it is changed
while playing the result will take effect after the animation finishes.

This property sets whether the animation will repeat after finishing. If
it is changed while playing the result will take effect after the
animation finishes.

This property defaults to how it was set in the
[Animation Editor](../../../animation/editor.md). However, this property
can be changed, allowing control over the `Class.AnimationTrack` while it
is running. This property also correctly handles animations played in
reverse (negative `Class.AnimationTrack.Speed`). After the first keyframe
is reached, it will restart at the last keyframe.

### `AnimationTrack.Priority`

- **Type:** `AnimationPriority`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Animation`

Sets the priority of an `Class.AnimationTrack`. Depending on what this is
set to, playing multiple animations at once will look to this property to
figure out which `Class.Keyframe` `Class.Pose|Poses` should be played over
one another.

This property sets the priority of an `Class.AnimationTrack`. Depending on
what this is set to, playing multiple animations at once will look to this
property to figure out which `Class.Keyframe` poses should be played over
one another. It uses `Enum.AnimationPriority` which has 7 priority levels:

1. `Enum.AnimationPriority|Action4` (highest priority)
2. `Enum.AnimationPriority|Action3`
3. `Enum.AnimationPriority|Action2`
4. `Enum.AnimationPriority|Action`
5. `Enum.AnimationPriority|Movement`
6. `Enum.AnimationPriority|Idle`
7. `Enum.AnimationPriority|Core` (lowest priority)

Properly set animation priorities, either through the
[Animation Editor](../../../animation/editor.md) or through this property,
allow multiple animations to be played without them clashing. Where two
playing animations direct the target to move the same limb in different
ways, the `Class.AnimationTrack` with the highest priority will show. If
both animations have the same priority, the weights of the tracks will be
used to combine the animations.

### `AnimationTrack.Speed`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Animation`

Read-only property that gives the current playback speed of the
`Class.AnimationTrack`.

This read-only property gives the current playback speed of the
`Class.AnimationTrack`. When equal to `1`, the amount of time an animation
takes to complete is equal to `Class.AnimationTrack.Length`, in seconds.

If the speed is adjusted through `Class.AnimationTrack:AdjustSpeed()`, the
actual time it will take a track to play can be computed by dividing the
length by the speed. Speed is a unitless quantity.

### `AnimationTrack.TimePosition`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Animation`

Returns the position in time in seconds that an `Class.AnimationTrack` is
through playing its source animation. Can be set to make the track jump to
a specific moment in the animation.

Returns the position in time in seconds that an `Class.AnimationTrack` is
through playing its source animation. Can be set to make the track jump to
a specific moment in the animation, but the `Class.AnimationTrack` must be
playing to do so. It can also be used in combination with
`Class.AnimationTrack:AdjustSpeed()` to freeze the animation at a desired
point by setting speed to `0`.

### `AnimationTrack.WeightCurrent`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Animation`

Read-only property that gives the current weight of the
`Class.AnimationTrack`.

When weight is set in an `Class.AnimationTrack` it does not change
instantaneously but moves from `Class.AnimationTrack.WeightCurrent` to
`Class.AnimationTrack.WeightTarget`. The time it takes to do this is
determined by the `fadeTime` parameter given when the animation is played,
or the weight is adjusted.

`Class.AnimationTrack.WeightCurrent` can be checked against
`Class.AnimationTrack.WeightTarget` to see if the desired weight has been
reached. Note that these values should not be checked for equality with
the `==` operator, as both of these values are floats. To see if
`Class.AnimationTrack.WeightCurrent` has reached the target weight, it is
recommended to see if the distance between those values is sufficiently
small.

### `AnimationTrack.WeightTarget`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Animation`

Read-only property that gives the current weight of the
`Class.AnimationTrack`.

This read-only property gives the current weight of the
`Class.AnimationTrack`. It has a default value of `1` and is set when
`Class.AnimationTrack:Play()`, `Class.AnimationTrack:Stop()` or
`Class.AnimationTrack:AdjustWeight()` is called. When weight is set in an
`Class.AnimationTrack` it does not change instantaneously but moves from
`Class.AnimationTrack.WeightCurrent` to
`Class.AnimationTrack.WeightTarget`. The time it takes to do this is
determined by the `fadeTime` parameter given when the animation is played,
or the weight is adjusted.

`Class.AnimationTrack.WeightCurrent` can be checked against
`Class.AnimationTrack.WeightTarget` to see if the desired weight has been
reached. Note that these values should not be checked for equality with
the `==` operator, as both of these values are floats. To see if
`Class.AnimationTrack.WeightCurrent` has reached the target weight, it is
recommended to see if the distance between those values is sufficiently
small.

## Methods

### `AnimationTrack:AdjustSpeed`

```
AdjustSpeed(speed: float = 1) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Animation`

Changes the `Class.AnimationTrack.Speed` of an animation. A positive value
for speed plays the animation forward, a negative one plays it backwards,
and `0` pauses it.

This method changes the `Class.AnimationTrack.Speed` of an animation. A
positive value for speed plays the animation forward, a negative one plays
it backwards, and `0` pauses it.

A track's initial speed is set as a parameter in
`Class.AnimationTrack:Play()`. However a track's
`Class.AnimationTrack.Speed` can be changed during playback using this
method. When speed is equal to `1`, the amount of time an animation takes
to complete is equal to `Class.AnimationTrack.Length` (in seconds).

When is adjusted, then the actual time it will take a track to play can be
computed by dividing the length by the speed. `Class.AnimationTrack.Speed`
is a unitless quantity.

**Parameters:**

- `speed` : `float` (default `1`) --- The playback speed the animation is to be changed to.

**Returns:**

- `()` --- 

### `AnimationTrack:AdjustWeight`

```
AdjustWeight(weight: float = 1, fadeTime: float = 0.100000001) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Animation`

Changes the weight of an animation, with the optional `fadeTime` parameter
determining how long it takes for `Class.AnimationTrack.WeightCurrent` to
reach `Class.AnimationTrack.WeightTarget`.

Changes the weight of an animation, with the optional `fadeTime` parameter
determining how long it takes for `Class.AnimationTrack.WeightCurrent` to
reach `Class.AnimationTrack.WeightTarget`.

When weight is set in an `Class.AnimationTrack` it does not change
instantaneously but moves from `Class.AnimationTrack.WeightCurrent` to
`Class.AnimationTrack.WeightTarget`. The time it takes to do this is
determined by the `fadeTime` parameter given when the animation is played,
or the weight is adjusted.

The animation weighting system is used to determine how
`Class.AnimationTrack|AnimationTracks` playing at the same priority are
blended together. The default weight is `1`, and no movement will be
visible on an `Class.AnimationTrack` with a weight of `0`. The pose that
is shown at any point in time is determined by the weighted average of all
the `Class.Pose|Poses` and the `Class.AnimationTrack.WeightCurrent` of
each `Class.AnimationTrack`. See below for an example of animation
blending in practice. In most cases blending animations is not required
and using `Class.AnimationTrack.Priority` is more suitable.

**Parameters:**

- `weight` : `float` (default `1`) --- The weight the animation is to be changed to.
- `fadeTime` : `float` (default `0.100000001`) --- The duration of time that the animation will fade between the old weight and the new weight for.

**Returns:**

- `()` --- 

### `AnimationTrack:GetMarkerReachedSignal`

```
GetMarkerReachedSignal(name: string) -> RBXScriptSignal
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

Returns an `Datatype.RBXScriptSignal` (event) that fires when a specified
`Class.KeyframeMarker` has been hit in an `Class.Animation|animation`.

This method returns an `Datatype.RBXScriptSignal` (event) similar to the
`Class.AnimationTrack.KeyframeReached` event, except it only fires when a
specified `Class.KeyframeMarker` has been hit in an
`Class.Animation|animation`. The difference allows for greater control of
when the event will fire.

To learn more about using this method, see
[here](../../../animation/events.md).

#### See Also

- `Class.KeyframeMarker`
- `Class.AnimationTrack`, controls the playback of an animation on a
  `Class.Humanoid` or `Class.AnimationController`
- `Class.Keyframe`, holds the `Class.Pose|Poses` applied to joints in a
  `Class.Model` at a given point of time in an animation
- `Class.Keyframe:AddMarker()`
- `Class.Keyframe:RemoveMarker()`
- `Class.Keyframe:GetMarkers()`

**Parameters:**

- `name` : `string` --- The name of the `Class.KeyframeMarker` the signal is being created for. Not to be confused with the name of the `Class.Keyframe`.

**Returns:**

- `RBXScriptSignal` --- The signal created and fired when the animation reaches the created `Class.KeyframeMarker`.

### `AnimationTrack:GetParameter`

```
GetParameter(key: string) -> Variant
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

**Parameters:**

- `key` : `string` --- 

**Returns:**

- `Variant` --- 

### `AnimationTrack:GetParameterDefaults`

```
GetParameterDefaults() -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

**Returns:**

- `Dictionary` --- 

### `AnimationTrack:GetTargetInstance`

```
GetTargetInstance(name: string) -> Instance?
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

**Parameters:**

- `name` : `string` --- 

**Returns:**

- `Instance?` --- 

### `AnimationTrack:GetTargetNames`

```
GetTargetNames() -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

**Returns:**

- `Array` --- 

### `AnimationTrack:GetTimeOfKeyframe`

```
GetTimeOfKeyframe(keyframeName: string) -> double
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

Returns the time position of the first `Class.Keyframe` of the given name
in an `Class.AnimationTrack`.

Returns the time position of the first `Class.Keyframe` of the given name
in an `Class.AnimationTrack`. If multiple `Class.Keyframe|Keyframes` share
the same name, it will return the earliest one in the animation.

This method will return an error if it is uses with an invalid keyframe
name (one that does not exist for example) or if the underlying
`Class.Animation` has not yet loaded. To address this make sure only
correct keyframe names are used and the animation has loaded before
calling this method.

To check if the animation has loaded, verify that the
`Class.AnimationTrack.Length` is greater than zero.

**Parameters:**

- `keyframeName` : `string` --- The name associated with the `Class.Keyframe` to be found.

**Returns:**

- `double` --- The time, in seconds, the `Class.Keyframe` occurs at normal playback speed.

### `AnimationTrack:Play`

```
Play(fadeTime: float = 0.100000001, weight: float = 1, speed: float = 1) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Animation`

Plays the `Class.AnimationTrack`. Once called an `Class.AnimationTrack`
will play with the specified `fadeTime`, weight and speed.

When `Class.AnimationTrack:Play()` is called the track's animation will
begin playing and the weight of the animation will increase from `0` to
the specified `weight` (defaults to `1`) over the specified `fadeTime`.

The speed the `Class.AnimationTrack` will play at is determined by the
speed parameter (defaults to `1`). When the speed is equal to `1` the
number of seconds the track will take to complete is equal to the track's
`Class.AnimationTrack.Length` property. For example, a speed of `2` will
cause the track to play twice as fast.

The weight and speed of the animation can also be changed after the
animation has begun playing by using the
`Class.AnimationTrack:AdjustWeight()` and
`Class.AnimationTrack:AdjustSpeed()` methods.

If you want to start the animation at a specific point using
`Class.AnimationTrack.TimePosition`, it's important the animation is
played before this is done.

**Parameters:**

- `fadeTime` : `float` (default `0.100000001`) --- The duration of time that the animation's weight should be faded in for.
- `weight` : `float` (default `1`) --- The weight the animation is to be played at.
- `speed` : `float` (default `1`) --- The playback speed of the animation.

**Returns:**

- `()` --- 

### `AnimationTrack:SetParameter`

```
SetParameter(key: string, value: Variant) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

**Parameters:**

- `key` : `string` --- 
- `value` : `Variant` --- 

**Returns:**

- `()` --- 

### `AnimationTrack:SetTargetInstance`

```
SetTargetInstance(name: string, target: Instance?) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Animation`

**Parameters:**

- `name` : `string` --- 
- `target` : `Instance?` --- 

**Returns:**

- `()` --- 

### `AnimationTrack:Stop`

```
Stop(fadeTime: float = 0.100000001) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`CustomLuaState` ; capabilities=`Animation`

Stops the `Class.AnimationTrack`.

Stops the `Class.AnimationTrack`. Once called, the weight of the animation
will move towards zero over a length of time specified by the optional
`fadeTime` parameter. For example, if `Stop()` is called with a `fadeTime`
of `2`, it will take two seconds for the weight of the track to reach zero
and its effects completely end. Please note this will be the case
regardless of the initial weight of the animation.

It is not recommended to use a `fadeTime` of `0` in an attempt to override
this effect and end the animation immediately for `Class.Motor6D|Motor6Ds`
that have their `Class.Motor.MaxVelocity` set to zero, as this causes the
joints to freeze in place. If it must end immediately, ensure the
`Class.Motor.MaxVelocity` of `Class.Motor6D|Motor6Ds` in your rig are high
enough for them to snap properly.

**Parameters:**

- `fadeTime` : `float` (default `0.100000001`) --- The time, in seconds, for which animation weight is to be faded out over.

**Returns:**

- `()` --- 

## Events

### `AnimationTrack.DidLoop`

```
DidLoop()
```

- security=`None` ; capabilities=`Animation`

Fires when an `Class.AnimationTrack` loops on the next update following
the end of the previous animation loop.

This event fires whenever a looped `Class.AnimationTrack` completes a
loop, on the next update.

Currently it may also fire at the exact end of a non looped animation
track but this behavior should not be relied upon.

### `AnimationTrack.Ended`

```
Ended()
```

- security=`None` ; capabilities=`Animation`

Fires when the `Class.AnimationTrack` is completely done moving anything
in the world.

Fires when the `Class.AnimationTrack` is completely done moving anything
in the world, meaning the animation has finished playing, the "fade out"
is finished, and the subject is in a neutral pose.

You can use this to take action when the animation track's subject is back
in a neutral pose that's unaffected by the `Class.AnimationTrack` or to
clean up the `Class.AnimationTrack`.

### `AnimationTrack.KeyframeReached`

```
KeyframeReached(keyframeName: string)
```

- security=`None` ; capabilities=`Animation` ; **Deprecated:** This event has been superseded by the
`Class.AnimationTrack:GetMarkerReachedSignal()` method.

Fires every time playback of an `Class.AnimationTrack` reaches a
`Class.Keyframe` that does not have the default name of `Keyframe`.

Fires every time playback of an `Class.AnimationTrack` reaches a
`Class.Keyframe` that does not have the default name of `Keyframe`. This
event lets you run code at predefined points in an animation (set by
`Class.Keyframe` names).

`Class.Keyframe` names do not need to be unique. For example, if an
animation has three keyframes named `Particles`, this event will fire each
time one of these keyframes is reached.

`Class.Keyframe` names can be set in the
[Animation Editor](../../../animation/editor.md) when creating or editing
an animation. They cannot however be set by a `Class.Script` on an
existing animation prior to playing it.

**Parameters:**

- `keyframeName` : `string` --- The name of the `Class.Keyframe` reached.

### `AnimationTrack.Stopped`

```
Stopped()
```

- security=`None` ; capabilities=`Animation`

Fires when the `Class.AnimationTrack` finishes playing. The AnimationTrack
might still animate the subject while the animation "fades out". To catch
when the AnimationTrack is completely done moving anything in the world,
use the `Class.AnimationTrack.Ended` event.

Fires whenever the `Class.AnimationTrack` finishes playing.

This event has a number of uses. It can be used to wait until an
`Class.AnimationTrack` has stopped before continuing (for example, if
chaining a series of animations to play after each other). It can also be
used to clean up any `Class.Instance|Instances` created during the
animation playback.

## Notes / Deprecations

- Deprecated event `AnimationTrack.KeyframeReached`: This event has been superseded by the
`Class.AnimationTrack:GetMarkerReachedSignal()` method.
- Property `AnimationTrack.Animation` security: `read=None, write=None`
- Property `AnimationTrack.IsPlaying` security: `read=None, write=None`
- Property `AnimationTrack.Length` security: `read=None, write=None`
- Property `AnimationTrack.Looped` security: `read=None, write=None`
- Property `AnimationTrack.Priority` security: `read=None, write=None`
- Property `AnimationTrack.Speed` security: `read=None, write=None`
- Property `AnimationTrack.TimePosition` security: `read=None, write=None`
- Property `AnimationTrack.WeightCurrent` security: `read=None, write=None`
- Property `AnimationTrack.WeightTarget` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- AnimationTrack:AdjustSpeed: Animation-Speed-2
- AnimationTrack:AdjustSpeed: Animation-Speed
- AnimationTrack:AdjustWeight: AnimationTrack-Change-Weight
- AnimationTrack:GetMarkerReachedSignal: listening-to-keyframemarkers
- AnimationTrack:GetTimeOfKeyframe: Animation-GetTimeOfKeyframe
- AnimationTrack:Play: Animation-Speed-2
- AnimationTrack:Play: Animation-TimePosition
- AnimationTrack:Stop: AnimationTrack-Stop
- AnimationTrack.Animation: AnimationPlayed
- AnimationTrack.IsPlaying: AnimationTrack-IsPlaying
- AnimationTrack.Length: Animation-Speed-2
- AnimationTrack.Looped: Animation-Looping
- AnimationTrack.Looped: AnimationTrack-DidLoop
- AnimationTrack.Speed: Animation-Speed
- AnimationTrack.Speed: Animation-Speed-2
- AnimationTrack.TimePosition: Animation-TimePosition
- AnimationTrack.WeightCurrent: AnimationWeight
- AnimationTrack.WeightTarget: AnimationWeight
- AnimationTrack.DidLoop: AnimationTrack-DidLoop
- AnimationTrack.Ended: AnimationTrack-Ended
- AnimationTrack.Stopped: AnimationTrack-Stopped

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/AnimationTrack
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/AnimationTrack.yaml
- Captured: 2026-04-16
