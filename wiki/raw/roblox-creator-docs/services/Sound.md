---
title: Sound
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Sound
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Sound.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: audio
tags: [roblox-class, audio, instance]
---

# Sound

An object that emits sound. This object can be placed within a
`Class.BasePart` or `Class.Attachment` to emit a sound from a particular
position within a place or world, or it can be attached elsewhere to play the
sound at a constant volume throughout the entire place.

## Description

`Class.Sound` is an object that emits sound. When placed in a `Class.BasePart`
or an `Class.Attachment`, this object will emit its sound from that part's
`Class.BasePart.Position` or the attachment's
`Class.Attachment.WorldPosition`. In this placement, a `Class.Sound` exhibits
the Doppler effect, meaning its frequency and pitch varies with the relative
motion of whatever attachment or part it is attached to. Additionally, its
volume will be determined by the distance between the client's sound listener
(by default the `Class.Camera` position) and the position of the sound's
parent. For more information, see `Class.Sound.RollOffMode|RollOffMode`.

A sound is considered "global" if it is **not** parented to a `Class.BasePart`
or an `Class.Attachment`. In this case, the sound will play at the same volume
throughout the entire place.

## Inheritance

Inherits from: `Instance`

Memory category: `Internal`

## Properties

### `Sound.AcousticSimulationEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

### `Sound.AudioContent`

- **Type:** `Content`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`
- **Capabilities:** `LegacySound`

A reference to an audio asset.

This property is a reference to an audio asset.

### `Sound.EmitterSize`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `LegacySound`
- **Deprecated:** This property has deprecated in favor of `Class.Sound.RollOffMinDistance`
and `Class.Sound.RollOffMaxDistance` which should be used instead in new
work.

The minimum distance, in studs, at which a 3D `Class.Sound` (direct child
of a `Class.BasePart` or `Class.Attachment`) will begin to attenuate
(decrease in volume).

The minimum distance, in studs, at which a 3D `Class.Sound` (direct child
of a `Class.BasePart` or `Class.Attachment`) will begin to attenuate
(decrease in volume).

Sounds parented to a `Class.BasePart` or `Class.Attachment` that are
descendants of the `Class.Workspace` are considered 3D sounds and their
volume while playing is dependent on the distance between the client's
sound listener (`Class.Camera` position by default) and the Sound's
parent. Two properties influence this behavior EmitterSize and
`Class.Sound.RollOffMode`.

The way the `Class.Sound` attenuates (fades out) after the distance
between the listener and the sound exceeds the EmitterSize is determined
by RollOffMode.

### `Sound.IsLoaded`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `LegacySound`

This property is `true` when the `Class.Sound` has loaded from Roblox
servers and is ready to play.

This property is `true` when the `Class.Sound` has loaded from Roblox
servers and is ready to play. You can use this property and the
`Class.Sound.Loaded|Loaded` event to verify a sound has loaded before
playing it.

### `Sound.IsPaused`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`
- **Capabilities:** `LegacySound`

Read-only property which returns `true` when the `Class.Sound` is not
playing.

This read-only property returns `true` when the `Class.Sound` is not
playing. Note that it can return `true` if a sound has been paused using
`Class.Sound:Pause()|Pause()`, if it has been stopped using
`Class.Sound:Stop()|Stop()`, or the sound has never been played.

As `Class.Sound.IsPaused|IsPaused` is read-only, it cannot be used to stop
the sound; `Class.Sound:Stop()|Stop()` or `Class.Sound:Pause()|Pause()`
should be used instead.

### `Sound.IsPlaying`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`
- **Capabilities:** `LegacySound`

Read-only property which returns `true` when the `Class.Sound` is playing.

This read-only property returns true when the `Class.Sound` is playing.

As `Class.Sound.IsPlaying|IsPlaying` is read-only, it cannot be used to
play the sound; `Class.Sound:Play()|Play()` should be used instead.

### `Sound.isPlaying`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `LegacySound`
- **Deprecated:** This deprecated property is a variant of `Class.Sound.IsPlaying` which
should be used instead.

### `Sound.Looped`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

Sets whether or not the `Class.Sound` repeats once it has finished
playing.

This sets whether or not the `Class.Sound` repeats once it has finished
playing. Looped sounds are suitable for a range of applications including
music and background ambient sounds.

The `Class.Sound.DidLoop|DidLoop` event can be used to track the number of
times as sound has looped.

### `Sound.LoopRegion`

- **Type:** `NumberRange`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

A range denoting a desired loop start and loop end within the
`Class.Sound.PlaybackRegion|PlaybackRegion`, in seconds.

A range denoting a desired loop start and loop end within the
`Class.Sound.PlaybackRegion|PlaybackRegion`, in seconds.

- If `Class.Sound.LoopRegion|LoopRegion.Min` `>`
  `Class.Sound.PlaybackRegion|PlaybackRegion.Min`, the loop starts from
  `Class.Sound.LoopRegion|LoopRegion.Min`.

- If `Class.Sound.LoopRegion|LoopRegion.Min` `<`
  `Class.Sound.PlaybackRegion|PlaybackRegion.Min`, the loop starts from
  `Class.Sound.PlaybackRegion|PlaybackRegion.Min`.

- If `Class.Sound.LoopRegion|LoopRegion.Max` `>`
  `Class.Sound.PlaybackRegion|PlaybackRegion.Max`, the loop starts at
  `Class.Sound.PlaybackRegion|PlaybackRegion.Max`.

- If `Class.Sound.LoopRegion|LoopRegion.Max` `<`
  `Class.Sound.PlaybackRegion|PlaybackRegion.Max`, the loop starts at
  **exactly** that time.

- If `Class.Sound.LoopRegion|LoopRegion.Min` `==`
  `Class.Sound.LoopRegion|LoopRegion.Max`, the `Class.Sound` uses the
  `Class.Sound.PlaybackRegion|PlaybackRegion` property instead.

### `Sound.MaxDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `LegacySound`
- **Deprecated:** This property has deprecated in favor of `Class.Sound.RollOffMinDistance`
and `Class.Sound.RollOffMaxDistance` which should be used instead in new
work.

The maximum distance, in studs, a client's listener can be from the
`Class.Sound|Sound\s` origin and still hear it. Only applies to Sounds
parented to a `Class.Part` or `Class.Attachment` (3D sounds).

The maximum distance, in studs, a client's listener can be from the
`Class.Sound` origin and still hear it. Only applies to Sounds parented to
a `Class.Part` or `Class.Attachment` (3D sounds).

How MaxDistance impacts the attenuation of a sound (manner in which it
fades out) is dependent on the `Class.Sound.RollOffMode` property. When
RollOffMode is set to use an inverse type distance model (Inverse or
InverseTapered) the MaxDistance will not effect the attenuation of the
sound. This means that low values for MaxDistance will cause the sound to
abruptly cut off when the listener reaches the MaxDistance. In most cases
this is not desirable and developers are advised not to use low
MaxDistance values.

When RollOffMode is set to a linear type distance model (Linear or
LinearSquared) the sound will attenuate between `Class.Sound.EmitterSize`
and MaxDistance (with playback volume reaching zero at MaxDistance). This
is less realistic, but in some cases allows attenuation to be handled in a
more intuitive way.

### `Sound.MinDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `LegacySound`
- **Deprecated:** MinDistance has been superseded by `Class.Sound.EmitterSize`, whose name
better describes this properties behavior.

The minimum distance at which a 3D `Class.Sound` (direct child of a
`Class.BasePart` or `Class.Attachment`) will begin to attenuate.
Effectively, the emitter size.

### `Sound.Pitch`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `LegacySound`
- **Deprecated:** This property has been deprecated in favor of `Class.Sound.PlaybackSpeed`
whose name suits the behavior better.

Sets how high pitched and fast a `Class.Sound` is when it is played. The
greater the integer, the higher and faster the `Class.Sound` is.

Sets how high pitched and fast a `Class.Sound` is when it is played. The
greater the integer, the higher and faster the sound is.

### `Sound.PlaybackLoudness`

- **Type:** `double`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `LegacySound`

A number between `0` and `1000` indicating how loud the `Class.Sound` is
currently playing back.

A number between `0` and `1000` indicating how loud the `Class.Sound` is
currently playing back. This property reflects the amplitude of the
sound's playback in the instance of time it is read.

### `Sound.PlaybackRegion`

- **Type:** `NumberRange`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

A range denoting a desired start and stop time within the
`Class.Sound.TimeLength|TimeLength`, in seconds.

A range denoting a desired start and stop time within the
`Class.Sound.TimeLength|TimeLength`, in seconds.

- If `Class.Sound.PlaybackRegion|PlaybackRegion.Min` `>` `0`, the sound
  begins to play from the `Class.Sound.PlaybackRegion|PlaybackRegion.Min`
  time.

- If `Class.Sound.PlaybackRegion|PlaybackRegion.Min` `<` `0`, the sound
  begins to play from `0`.

- If `Class.Sound.PlaybackRegion|PlaybackRegion.Max` `>`
  `Class.Sound.TimeLength`, the sound stops at `Class.Sound.TimeLength`.

- If `Class.Sound.PlaybackRegion|PlaybackRegion.Max` `<`
  `Class.Sound.TimeLength`, the sound stops at **exactly** that time.

- If `Class.Sound.PlaybackRegion|PlaybackRegion.Min` `==`
  `Class.Sound.PlaybackRegion|PlaybackRegion.Max`, this property is
  inactive.

### `Sound.PlaybackRegionsEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

If `true`, this property gives your `Class.Sound` access to the
`Class.Sound.PlaybackRegion|PlaybackRegion` and
`Class.Sound.LoopRegion|LoopRegion` properties which can more-accurately
control its playback.

### `Sound.PlaybackSpeed`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `LegacySound`

Determines the speed at which a `Class.Sound` will play, with higher
values causing the sound to play faster and at a higher pitch.

### `Sound.Playing`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `LegacySound`

Indicates whether the `Class.Sound` is currently playing.

Indicates whether the `Class.Sound` is currently playing. This can be
toggled, and this property will always replicate.

In Studio's [Properties](../../../studio/properties.md) window, while in
**Edit** mode, toggling `Class.Sound.Playing|Playing` to `true` does not
begin playing the sound, but the sound will begin playing during runtime.

This property should not be confused with
`Class.Sound.IsPlaying|IsPlaying` which is a read-only property.

Note that when `Class.Sound.Playing|Playing` is set to `false`, the
`Class.Sound.TimePosition|TimePosition` property of the sound will not
reset, meaning that when `Class.Sound.Playing|Playing` is set to `true`
again, the audio will continue from the time position it was at when it
was stopped. However, if the `Class.Sound:Play()|Play()` function is used
to resume the sound, the time position will reset to `0`.

### `Sound.PlayOnRemove`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

When `true`, the `Class.Sound` will play when it is removed from the
experience.

When `true`, the `Class.Sound` will play when it is removed from the
experience by parenting the `Class.Sound` or one if its ancestors to
`nil`. This means all of the following will cause the sound to play when
`Class.Sound.PlayOnRemove|PlayOnRemove` is `true`:

- `sound:Destroy()`
- `sound.Parent = nil`
- `sound.Parent.Parent = nil`

### `Sound.RollOffMaxDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

The maximum distance, in studs, a client's listener can be from the
sound's origin and still hear it. Only applies to `Class.Sound|Sounds`
parented to a `Class.BasePart` or `Class.Attachment`.

The maximum distance, in studs, a client's listener can be from the
sound's origin and still hear it. Only applies to `Class.Sound|Sounds`
parented to a `Class.BasePart` or `Class.Attachment`.

How `Class.Sound.RollOffMaxDistance|RollOffMaxDistance` impacts the
attenuation of a sound (manner in which it fades out) is dependent on the
`Class.Sound.RollOffMode|RollOffMode` property.

### `Sound.RollOffMinDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

The minimum distance, in studs, at which a `Class.Sound` which is parented
to a `Class.BasePart` or `Class.Attachment` will begin to attenuate
(decrease in volume).

The minimum distance, in studs, at which a `Class.Sound` which is parented
to a `Class.BasePart` or `Class.Attachment` will begin to attenuate
(decrease in volume).

How `Class.Sound.RollOffMinDistance|RollOffMinDistance` impacts the
attenuation of a sound (manner in which it fades out) is dependent on the
`Class.Sound.RollOffMode|RollOffMode` property.

### `Sound.RollOffMode`

- **Type:** `RollOffMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

Controls how the volume of a `Class.Sound` which is parented to a
`Class.BasePart` or `Class.Attachment` attenuates (fades out) as the
distance between the listener and parent changes.

This property controls how the volume of a `Class.Sound` which is parented
to a `Class.BasePart` or `Class.Attachment` attenuates (fades out) as the
distance between the listener and parent changes.

For details on the different modes, see `Enum.RollOffMode`.

### `Sound.SoundGroup`

- **Type:** `SoundGroup`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

The `Class.SoundGroup` that is linked to this `Class.Sound`.

### `Sound.SoundId`

- **Type:** `ContentId`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

Content ID of the sound file to associate with the `Class.Sound`.

This property is the content ID of the sound file to associate with the
`Class.Sound`. See [Audio Assets](../../../audio/assets.md) for more
information.

### `Sound.TimeLength`

- **Type:** `double`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `LegacySound`

The length of the `Class.Sound` in seconds.

The length of the `Class.Sound` in seconds. If the `Class.Sound` is not
loaded, this value will be `0`.

This property is often used in conjunction with
`Class.Sound.PlaybackSpeed|PlaybackSpeed` to adjust the speed of a sound
so that it lasts for a specific duration.

### `Sound.TimePosition`

- **Type:** `double`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `LegacySound`

Progress of the `Class.Sound` in seconds. Can be changed to move the
playback position of the `Class.Sound` both before and during playback.

This property reflects the progress of the `Class.Sound` in seconds. It
can be changed to move the playback position of the sound both before and
during playback.

As a `Class.Sound` is played, `Class.Sound.TimePosition|TimePosition`
increases at a rate of `Class.Sound.PlaybackSpeed|PlaybackSpeed` per
second. Once `Class.Sound.TimePosition|TimePosition` reaches
`Class.Sound.TimeLength|TimeLength`, the sound will stop unless it is
`Class.Sound.Looped|Looped`.

Note that setting `Class.Sound.TimePosition|TimePosition` to a value
greater than the length in a looped track will not cause it to wrap
around. If that behavior is desired, consider the following code snippet:

```
local newPosition = 1.5

if newPosition >= sound.TimeLength then
	newPosition = newPosition - sound.TimeLength
end
sound.TimePosition = newPosition
```

### `Sound.Volume`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `LegacySound`

The volume of the `Class.Sound`.

The volume of the `Class.Sound`. Can be set between `0` and `10` and
defaults to `0.5`.

Note that if the `Class.Sound` is a member of a `Class.SoundGroup`, its
playback volume (but not its `Class.Sound.Volume|Volume` property) will be
influenced by the group's `Class.SoundGroup.Volume` property.

## Methods

### `Sound:Pause`

```
Pause() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`LegacySound`

Pauses playback of the `Class.Sound` if it is playing.

This method pauses playback of the `Class.Sound` if it is playing, setting
`Class.Sound.Playing|Playing` to `false`. Unlike
`Class.Sound:Stop()|Stop()`, it does not reset
`Class.Sound.TimePosition|TimePosition`, meaning the sound can be resumed
using `Class.Sound:Resume()|Resume()`.

**Returns:**

- `()` — 

### `Sound:pause`

```
pause() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`LegacySound` ; **Deprecated:** This deprecated function is a variant of `Class.Sound:Pause()` which
should be used instead.

**Returns:**

- `()` — 

### `Sound:Play`

```
Play() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`LegacySound`

Plays the `Class.Sound`.

This method plays the `Class.Sound` and sets
`Class.Sound.TimePosition|TimePosition` to the last value set by a script
(or `0` if it has not been set), then sets `Class.Sound.Playing|Playing`
to `true`.

**Returns:**

- `()` — 

### `Sound:play`

```
play() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`LegacySound` ; **Deprecated:** This deprecated function is a variant of `Class.Sound:Play()` which should
be used instead.

**Returns:**

- `()` — 

### `Sound:Resume`

```
Resume() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`LegacySound`

Resumes the `Class.Sound`.

This method resumes the `Class.Sound` and sets
`Class.Sound.Playing|Playing` to `true`. Does not alter
`Class.Sound.TimePosition|TimePosition` and thus can be used to resume
playback of a sound paused through `Class.Sound:Pause()|Pause()`.

**Returns:**

- `()` — 

### `Sound:Stop`

```
Stop() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`LegacySound`

Stops the `Class.Sound`.

This method stops the `Class.Sound` and sets `Class.Sound.Playing|Playing`
to `false`, then sets `Class.Sound.TimePosition|TimePosition` to `0`.

**Returns:**

- `()` — 

### `Sound:stop`

```
stop() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`LegacySound` ; **Deprecated:** This deprecated function is a variant of `Class.Sound:Stop()` which should
be used instead.

**Returns:**

- `()` — 

## Events

### `Sound.DidLoop`

```
DidLoop(soundId: string, numOfTimesLooped: int)
```

- security=`None` ; capabilities=`LegacySound`

Fires whenever the `Class.Sound` loops.

Fires whenever the `Class.Sound` loops. Returns `soundId` and
`numOfTimesLooped`, giving the content ID of the sound and the number of
times looped respectively.

When the `Class.Sound` is stopped through `Class.Sound:Stop()|Stop()`, the
looped counter resets meaning the next `Class.Sound.DidLoop|DidLoop` event
will return `1` for `numOfTimesLooped`.

**Parameters:**

- `soundId` : `string` — The `Class.Sound.SoundId|SoundId` of the `Class.Sound` that looped.
- `numOfTimesLooped` : `int` — The number of times the `Class.Sound` has looped.

### `Sound.Ended`

```
Ended(soundId: string)
```

- security=`None` ; capabilities=`LegacySound`

Fires when the `Class.Sound` has completed playback and stopped.

Fires when the `Class.Sound` has completed playback and stopped. This
event is often used to destroy a sound when it has completed playback:

```
sound:Play()
sound.Ended:Wait()
sound:Destroy()
```

Note that this event will **not** fire for sounds with
`Class.Sound.Looped|Looped` set to `true`, as they continue playing upon
reaching their end. This event will also **not** fire when the sound is
stopped before playback has completed; for this use the
`Class.Sound.Stopped|Stopped` event.

**Parameters:**

- `soundId` : `string` — The `Class.Sound.SoundId|SoundId` of the `Class.Sound` that has ended.

### `Sound.Loaded`

```
Loaded(soundId: string)
```

- security=`None` ; capabilities=`LegacySound`

Fires when the `Class.Sound` is loaded.

Fires when the `Class.Sound` is loaded.

As this event only fires at the time the sound is loaded, it's recommended
to check the sound's `Class.Sound.IsLoaded|IsLoaded` property prior to
connecting to this event.

**Parameters:**

- `soundId` : `string` — The `Class.Sound.SoundId|SoundId` of the `Class.Sound` that loaded.

### `Sound.Paused`

```
Paused(soundId: string)
```

- security=`None` ; capabilities=`LegacySound`

Fires whenever the `Class.Sound` is paused using
`Class.Sound:Pause()|Pause()`.

**Parameters:**

- `soundId` : `string` — The `Class.Sound.SoundId|SoundId` of the `Class.Sound` that was paused.

### `Sound.Played`

```
Played(soundId: string)
```

- security=`None` ; capabilities=`LegacySound`

Fires whenever the `Class.Sound` is played using
`Class.Sound:Play()|Play()`.

Fires whenever the `Class.Sound` is played using
`Class.Sound:Play()|Play()`. This event will **not** fire if the
`Class.Sound` is played due to `Class.Sound.PlayOnRemove|PlayOnRemove`
being set to `true` and the sound being destroyed.

**Parameters:**

- `soundId` : `string` — The `Class.Sound.SoundId|SoundId` of the `Class.Sound` that was played.

### `Sound.Resumed`

```
Resumed(soundId: string)
```

- security=`None` ; capabilities=`LegacySound`

Fires when the `Class.Sound` is resumed using
`Class.Sound:Resume()|Resume()`.

**Parameters:**

- `soundId` : `string` — The `Class.Sound.SoundId|SoundId` of the `Class.Sound` being resumed.

### `Sound.Stopped`

```
Stopped(soundId: string)
```

- security=`None` ; capabilities=`LegacySound`

Fires when the `Class.Sound` is stopped through using
`Class.Sound:Stop()|Stop()`.

Fires when the `Class.Sound` is stopped through using
`Class.Sound:Stop()|Stop()`. Destroying a sound while it is playing will
not cause this event to fire.

**Parameters:**

- `soundId` : `string` — The `Class.Sound.SoundId|SoundId` of the `Class.Sound` that stopped.

## Notes / Deprecations

- Deprecated property `Sound.EmitterSize`: This property has deprecated in favor of `Class.Sound.RollOffMinDistance`
and `Class.Sound.RollOffMaxDistance` which should be used instead in new
work.
- Deprecated property `Sound.isPlaying`: This deprecated property is a variant of `Class.Sound.IsPlaying` which
should be used instead.
- Deprecated property `Sound.MaxDistance`: This property has deprecated in favor of `Class.Sound.RollOffMinDistance`
and `Class.Sound.RollOffMaxDistance` which should be used instead in new
work.
- Deprecated property `Sound.MinDistance`: MinDistance has been superseded by `Class.Sound.EmitterSize`, whose name
better describes this properties behavior.
- Deprecated property `Sound.Pitch`: This property has been deprecated in favor of `Class.Sound.PlaybackSpeed`
whose name suits the behavior better.
- Deprecated method `Sound:pause`: This deprecated function is a variant of `Class.Sound:Pause()` which
should be used instead.
- Deprecated method `Sound:play`: This deprecated function is a variant of `Class.Sound:Play()` which should
be used instead.
- Deprecated method `Sound:stop`: This deprecated function is a variant of `Class.Sound:Stop()` which should
be used instead.
- Property `Sound.AcousticSimulationEnabled` security: `read=None, write=None`
- Property `Sound.AudioContent` security: `read=None, write=None`
- Property `Sound.EmitterSize` security: `read=None, write=None`
- Property `Sound.IsLoaded` security: `read=None, write=None`
- Property `Sound.IsPaused` security: `read=None, write=None`
- Property `Sound.IsPlaying` security: `read=None, write=None`
- Property `Sound.isPlaying` security: `read=None, write=None`
- Property `Sound.Looped` security: `read=None, write=None`
- Property `Sound.LoopRegion` security: `read=None, write=None`
- Property `Sound.MaxDistance` security: `read=None, write=None`
- Property `Sound.MinDistance` security: `read=None, write=None`
- Property `Sound.Pitch` security: `read=None, write=None`
- Property `Sound.PlaybackLoudness` security: `read=None, write=None`
- Property `Sound.PlaybackRegion` security: `read=None, write=None`
- Property `Sound.PlaybackRegionsEnabled` security: `read=None, write=None`
- Property `Sound.PlaybackSpeed` security: `read=None, write=None`
- Property `Sound.Playing` security: `read=None, write=None`
- Property `Sound.PlayOnRemove` security: `read=None, write=None`
- Property `Sound.RollOffMaxDistance` security: `read=None, write=None`
- Property `Sound.RollOffMinDistance` security: `read=None, write=None`
- Property `Sound.RollOffMode` security: `read=None, write=None`
- Property `Sound.SoundGroup` security: `read=None, write=None`
- Property `Sound.SoundId` security: `read=None, write=None`
- Property `Sound.TimeLength` security: `read=None, write=None`
- Property `Sound.TimePosition` security: `read=None, write=None`
- Property `Sound.Volume` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `Sound-3D-Parent` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/Sound
- Sound:Pause: Sound-Functions
- Sound:Play: Sound-Functions
- Sound:Resume: Sound-Functions
- Sound:Stop: Sound-Functions
- Sound.EmitterSize: Sound-3D-Parent
- Sound.IsLoaded: Sound-Loaded
- Sound.IsPaused: Sound-IsPlaying-IsPaused
- Sound.IsPlaying: Sound-IsPlaying-IsPaused
- Sound.Looped: Sound-Looping-2
- Sound.MaxDistance: Sound-MaxDistance
- Sound.PlaybackLoudness: Sound-PlaybackLoudness
- Sound.PlaybackSpeed: Sound-PlaybackSpeed
- Sound.Playing: Sound-Playing
- Sound.TimeLength: Sound-PlaybackSpeed-TimeLength
- Sound.TimePosition: Sound-TimePosition
- Sound.DidLoop: Sound-Looping-2
- Sound.Loaded: Sound-Loaded
- Sound.Paused: Sound-Functions
- Sound.Played: Sound-Functions
- Sound.Resumed: Sound-Functions
- Sound.Stopped: Sound-Functions

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Sound
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Sound.yaml
- Captured: 2026-04-16
