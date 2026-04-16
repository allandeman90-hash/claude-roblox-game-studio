---
title: SoundService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/SoundService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/SoundService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: audio
tags: [roblox-class, audio, service]
---

# SoundService

A service that determines various aspects of how the audio engine works. Most
of its properties affect how `Class.Sound|Sounds` play in the experience.

## Description

A service that determines various aspects of how the audio engine works. Most
of its properties affect how `Class.Sound|Sounds` play in the experience,
while others affect the behavior of instances in the advanced audio system
such as `Class.AudioPlayer|AudioPlayers` and
`Class.AudioEmitter|AudioEmitters`.

`Class.SoundService` is also often used to store
`Class.SoundGroup|SoundGroups`, although this is not mandatory for groups to
work.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

### `SoundService.AcousticSimulationEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Audio`

Determines whether acoustic simulation is enabled globally in the advanced
audio system.

Determines at a global level whether sound from
`Class.AudioEmitter|AudioEmitters` and
`Class.AudioListener|AudioListeners` should automatically implement
features of acoustic simulation, such as occlusion (being muffled through
walls), diffraction (bending around corners), and reverberation (echoing
off of walls).

If set to `false`, these instances will not simulate these features,
regardless of their individual
`Class.AudioEmitter.AcousticSimulationEnabled|AcousticSimulationEnabled`
settings.

### `SoundService.AmbientReverb`

- **Type:** `ReverbType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Audio`

The ambient sound environment preset applied to all `Class.Sound|Sounds`.

A reverb preset that should be applied to all `Class.Sound|Sounds` in the
experience.

Each `Enum.ReverbType` option for this property corresponds to a preset
available in the FMOD sound engine. For example, when
`Class.SoundService.AmbientReverb|AmbientReverb` is set to
`Enum.ReverbType.Hangar`, `Class.Sound|Sounds` will have reverb applied to
simulate being in a large enclosed space.

Note that this only affects `Class.Sound|Sounds` and **not** instances in
the advanced audio system such as `Class.AudioPlayer|AudioPlayers` and
`Class.AudioEmitter|AudioEmitters`. See `Class.AudioReverb` for a way to
apply reverb in that system.

### `SoundService.CharacterSoundsUseNewApi`

- **Type:** `RolloutState`
- **Security:** `read=None, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Audio`

Determines whether the default character sounds will use instances in the
advanced audio system vs. `Class.Sound|Sounds`.

Determines which set of instances core scripts will use to create default
character sounds. If set to `Enum.RolloutState.Enabled`, it will use
instances in the advanced audio system such as
`Class.AudioPlayer|AudioPlayers` and `Class.AudioEmitter|AudioEmitters`.
If set to `Enum.RolloutState.Disabled`, it will use instances in the
legacy sound system such as `Class.Sound|Sounds`.

### `SoundService.DefaultListenerLocation`

- **Type:** `ListenerLocation`
- **Security:** `read=PluginSecurity, write=PluginSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Audio`

Determines where (if anywhere) to place an `Class.AudioListener` by
default.

Determines where to place an `Class.AudioListener` by default. The
`Class.AudioListener` will automatically be wired to a
`Class.AudioDeviceOutput` and will have an empty
`Class.AudioListener.InteractionGroup` set.

See `Enum.ListenerLocation` for detailed descriptions of each option.

### `SoundService.DistanceFactor`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Audio`

The number of studs to be considered a meter by `Class.SoundService` when
simulating the Doppler effect for `Class.Sound|Sounds`.

The number of studs to be considered a meter by `Class.SoundService` when
simulating the Doppler effect for `Class.Sound|Sounds`. This impacts any
`Class.Sound` parented to a `Class.BasePart` or `Class.Attachment`.

By default, this property is `3.33`, meaning that a meter is considered
3.33 studs for the purposes of simulating the Doppler effect. The greater
the `Class.SoundService.DistanceFactor|DistanceFactor`, the faster the
listener has to travel relative to `Class.Sound|Sounds` in order to
experience the same Doppler shift.

It's recommended that you only change this property if the objects in your
experience are scaled differently from what they represent. For example,
if your character is meant to be very small (but is normal-sized in the
engine), you may want to increase `Class.SoundService.DistanceFactor`.

Note that this does not impact the behavior of instances in the advanced
audio system, such as `Class.AudioPlayer` or `Class.AudioEmitter`.

### `SoundService.DopplerScale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Audio`

Degree to which the pitch of a `Class.Sound` varies due to the Doppler
effect.

This property determines the degree to which the pitch of a `Class.Sound`
varies due to the Doppler effect. This impacts any `Class.Sound` parented
to a `Class.BasePart` or `Class.Attachment`.

The Doppler effect is a phenomenon whereby the pitch of a sound changes as
the source and observer of the sound move further away or closer together,
which is stronger the more quickly they are moving. Increasing
`Class.SoundService.DopplerScale` exaggerates the impact of this effect,
whereas decreasing it minimizes it. By default, the value of this property
is `1`.

Note that this does not impact the behavior of instances in the advanced
audio system, such as `Class.AudioPlayer` or `Class.AudioEmitter`.

### `SoundService.RespectFilteringEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Audio`

Sets whether `Class.Sound` playback from a client will replicate to the
server.

This property determines whether `Class.Sound` playback is replicated from
the client to the server, and therefore from the server. In other words,
when a `Class.LocalScript` calls `Class.Sound:Play()|Play()` and this
property is `true`, the sound will only play on the respective client. If
this property is `false`, other clients will also hear the sound.

Default is `true`, meaning filtering is enabled.

### `SoundService.RolloffScale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Audio`

Determines how fast the volume of a `Class.Sound` attenuates beyond its
`Class.Sound.RollOffMinDistance`.

Determines how fast the volume of a spatialized `Class.Sound` attenuates.
This impacts any `Class.Sound` parented to a `Class.BasePart` or
`Class.Attachment`.

A higher `Class.SoundService.RolloffScale|RolloffScale` means the volume
of a `Class.Sound` will attenuate more rapidly as the distance between the
listener and the `Class.Sound|Sound` grows. More precisely, the volume of
the `Class.Sound` will still start attenuating at a distance equal to
`Class.Sound.RollOffMinDistance`, but the attenuation curve will be
steeper or more gradual based on the value of
`Class.SoundService.RolloffScale|RolloffScale`. Note that the
`Class.Sound` will still be inaudible past its the
`Class.Sound.RollOffMaxDistance` regardless of the value of
`Class.SoundService.RolloffScale`.

Note that this property does not affect the behavior of instances in the
advanced audio system, such as `Class.AudioEmitter`. See
`Class.AudioEmitter:SetDistanceAttenuation` for a way to apply custom
attenuation in that system.

### `SoundService.VolumetricAudio`

- **Type:** `VolumetricAudio`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Audio`

Determines whether certain spatialized `Class.Sound|Sounds` emit
volumetrically, throughout the space of their parent object.

Determines whether any `Class.Sound|Sounds` parented to a `Class.Part`
emit volumetrically. If set to `Enum.VolumetricAudio.Enabled`, the
`Class.Sound` will simulate being emitted from every point in the interior
of the `Class.Part`. If set to `Enum.VolumetricAudio.Disabled`, the
`Class.Sound` will only emit from a single point in the center of the
`Class.Part`.

Note that this does not impact `Class.Sound|Sounds` parented to other
objects, such as `Class.Attachment|Attachments` or
`Class.MeshPart|MeshParts`. This also does not impact the behavior of
instances in the advanced audio system such as `Class.AudioEmitter`.

## Methods

### `SoundService:GetListener`

```
GetListener() -> Tuple
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Audio`

Returns the current listener type used by `Class.Sound|Sounds`, as well as
what that listener is currently set to.

Returns the current listener type used by `Class.Sound|Sounds` and what
object or position that listener is currently set to. This is the point
from which `Class.Sound` audio in the experience is heard by the player.
By default, the listener is set to `Class.Workspace.CurrentCamera`. The
listener can be changed using
`Class.SoundService:SetListener()|SetListener()`.

Note that this does not affect the listener location when using the
advanced audio system. See `Class.AudioListener` for a way to set the
listener location in that system.

**Returns:**

- `Tuple` — A table containing two results. The first result is the listener's `Enum.ListenerType` and the second result is dependent on that type:  <table>       <thead> 	  <tr> 	      <th>Listener Type</th> 	      <th>Description</th> 	  </tr>       </thead>       <tbody> 	  <tr> 	      <td><code>Enum.ListenerType.Camera</code></td> 	      <td>Does not return a listener object as <code>Class.Workspace.CurrentCamera|CurrentCamera</code> is always used.</td> 	  </tr> 	  <tr> 	      <td><code>Enum.ListenerType.CFrame</code></td> 	      <td>Returns the <code>Datatype.CFrame</code> used in <code>Class.SoundService:SetListener()|SetListener()</code>.</td> 	  </tr> 	  <tr> 	      <td><code>Enum.ListenerType.ObjectPosition</code></td> 	      <td>Returns the <code>Class.BasePart</code> used in <code>Class.SoundService:SetListener()|SetListener()</code>.</td> 	  </tr> 	  <tr> 	      <td><code>Enum.ListenerType.ObjectCFrame</code></td> 	      <td>Returns the <code>Class.BasePart</code> used in <code>Class.SoundService:SetListener()|SetListener()</code>.</td> 	  </tr>       </tbody> </table>

### `SoundService:GetMixerTime`

```
GetMixerTime() -> double
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Audio`

Returns the number of seconds since the audio engine began mixing.

**Returns:**

- `double` — The number of seconds since the audio engine began mixing. This value is stable, sample-accurate, and monotonically-increasing – intended to be used for scheduling audible changes at precise times.

### `SoundService:OpenAttenuationCurveEditor`

```
OpenAttenuationCurveEditor(selectedCurveObjects: Instances) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; capabilities=`Audio`

Opens the attenuation curve editor in Studio for the provided
`Class.AudioEmitter` or `Class.AudioListener` instances.

**Parameters:**

- `selectedCurveObjects` : `Instances` — A list of `Class.AudioEmitter|AudioEmitters` or `Class.AudioListener|AudioListeners`.

**Returns:**

- `()` — 

### `SoundService:OpenDirectionalCurveEditor`

```
OpenDirectionalCurveEditor(selectedCurveObjects: Instances) -> ()
```

- security=`PluginSecurity` ; thread-safety=`Unsafe` ; capabilities=`Audio`

Opens the directional curve editor in Studio for the provided
`Class.AudioEmitter` or `Class.AudioListener` instances.

**Parameters:**

- `selectedCurveObjects` : `Instances` — A list of `Class.AudioEmitter|AudioEmitters` or `Class.AudioListener|AudioListeners`.

**Returns:**

- `()` — 

### `SoundService:PlayLocalSound`

```
PlayLocalSound(sound: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Audio`

Plays a copy of a `Class.Sound` locally, such that it will only be heard
by the client calling this method.

Plays a copy of a `Class.Sound` locally. The `Class.Sound` will only be
heard by the client calling this method, regardless of where it's parented
to.

Some properties of the `Class.Sound` will be carried over into the copy.
These include its `Class.Sound.Volume`, `Class.Sound.TimePosition`,
`Class.Sound.PlaybackSpeed`, and any spatialization and effects that are
applied to it, including through `Class.Sound.SoundGroup|SoundGroups`.
Properties that do not affect the copy include `Class.Sound.Looped` and
`Class.SoundService.AmbientReverb`.

**Parameters:**

- `sound` : `Instance` — The `Class.Sound` to be played.

**Returns:**

- `()` — 

### `SoundService:SetListener`

```
SetListener(listenerType: ListenerType, listener: Tuple) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Audio`

Sets the listener used by `Class.Sound|Sounds`.

Sets the listener type for any `Class.Sound|Sounds` in the experience,
which defines the point from which `Class.Sound` audio in the experience
is heard by the player. For `Class.Sound|Sounds` parented to a
`Class.BasePart` or `Class.Attachment`, the listener influences the volume
and left/right balance of a playing sound. By default, this listener is
set to `Class.Workspace.CurrentCamera`.

Note that this does not affect the listener location when using the
advanced audio system. See `Class.AudioListener` for a way to set the
listener location in that system.

**Parameters:**

- `listenerType` : `ListenerType` — The `Enum.ListenerType` of the listener.
- `listener` : `Tuple` — Dependent on the `Enum.ListenerType`. Use a `Class.BasePart` for `Enum.ListenerType.ObjectPosition` or `Enum.ListenerType.ObjectCFrame`, a `Datatype.CFrame` for `Enum.ListenerType.CFrame`, or `nil` for `Enum.ListenerType.Camera`.

**Returns:**

- `()` — 

## Events

_No public events documented._

## Notes / Deprecations

- Method `SoundService:OpenAttenuationCurveEditor` security: `PluginSecurity`
- Method `SoundService:OpenDirectionalCurveEditor` security: `PluginSecurity`
- Property `SoundService.AcousticSimulationEnabled` security: `read=None, write=None`
- Property `SoundService.AmbientReverb` security: `read=None, write=None`
- Property `SoundService.CharacterSoundsUseNewApi` security: `read=None, write=PluginSecurity`
- Property `SoundService.DefaultListenerLocation` security: `read=PluginSecurity, write=PluginSecurity`
- Property `SoundService.DistanceFactor` security: `read=None, write=None`
- Property `SoundService.DopplerScale` security: `read=None, write=None`
- Property `SoundService.RespectFilteringEnabled` security: `read=None, write=None`
- Property `SoundService.RolloffScale` security: `read=None, write=None`
- Property `SoundService.VolumetricAudio` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `SoundService-Reverb-System` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/SoundService

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/SoundService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/SoundService.yaml
- Captured: 2026-04-16
