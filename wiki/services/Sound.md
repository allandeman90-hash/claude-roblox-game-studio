---
title: Sound
type: service
category: services
subcategory: audio
owner: sound-designer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/Sound.md
related:
  - "[[SoundService]]"
  - "[[SoundGroup]]"
tags: [roblox-class, audio]
---

# Sound

> An object that emits sound, either positionally (3D) or globally (2D). [[SoundService]]

## Summary

Sound is an instance that plays audio in a Roblox experience. When parented to a `BasePart` or `Attachment`, it becomes a **3D sound** that exhibits the Doppler effect and attenuates based on distance from the listener (by default the Camera position). When parented elsewhere (e.g., SoundService, PlayerGui), it becomes a **global sound** that plays at constant volume throughout the place.

The `SoundId` property holds the content ID of the audio asset. Playback is controlled via `:Play()`, `:Pause()`, `:Resume()`, and `:Stop()`. Key audio properties include `Volume` (0-10, default 0.5), `PlaybackSpeed` (pitch/speed multiplier), `Looped`, and distance attenuation settings (`RollOffMode`, `RollOffMinDistance`, `RollOffMaxDistance`).

Sounds can be assigned to a [[SoundGroup]] via the `SoundGroup` property (not by parenting) for group-level volume control. SoundEffects (child instances) can also be applied for equalization, reverb, distortion, etc.

## API Surface

### Properties (key subset)

- `SoundId: string` -- Content ID of the audio asset (e.g., `"rbxassetid://123456"`).
- `Volume: float` -- Volume level, 0 to 10. Default 0.5. Multiplied by SoundGroup volume.
- `PlaybackSpeed: float` -- Speed/pitch multiplier. 1 = normal, 2 = double speed/pitch.
- `Looped: boolean` -- Whether the sound loops on completion.
- `Playing: boolean` -- Whether the sound is currently playing. Can be toggled.
- `TimePosition: double` -- Current playback position in seconds. Can be set.
- `TimeLength: double` -- Total duration in seconds (read-only, 0 if not loaded).
- `IsLoaded: boolean` -- Whether the audio asset has loaded from Roblox servers (read-only).
- `IsPlaying: boolean` -- Whether the sound is currently playing (read-only).
- `PlaybackLoudness: double` -- Real-time amplitude, 0 to 1000 (read-only). Useful for visualizers.
- `RollOffMode: Enum.RollOffMode` -- Attenuation curve type (Inverse, Linear, InverseTapered, LinearSquared).
- `RollOffMinDistance: float` -- Distance in studs where attenuation begins (3D sounds only).
- `RollOffMaxDistance: float` -- Distance in studs where sound is inaudible (3D sounds only).
- `SoundGroup: SoundGroup?` -- The SoundGroup this Sound belongs to (set via property, not parenting).
- `PlayOnRemove: boolean` -- If true, the sound plays when removed from the DataModel.

### Methods

- `:Play() -> ()` -- Starts playback from the beginning (resets TimePosition to 0).
- `:Pause() -> ()` -- Pauses playback without resetting TimePosition.
- `:Resume() -> ()` -- Resumes playback from the current TimePosition.
- `:Stop() -> ()` -- Stops playback and resets TimePosition to 0.

### Events

- `.Played:Connect(fn(soundId: string))` -- Fires when `:Play()` is called.
- `.Paused:Connect(fn(soundId: string))` -- Fires when `:Pause()` is called.
- `.Resumed:Connect(fn(soundId: string))` -- Fires when `:Resume()` is called.
- `.Stopped:Connect(fn(soundId: string))` -- Fires when `:Stop()` is called.
- `.Ended:Connect(fn(soundId: string))` -- Fires when playback completes naturally (does not fire for looped sounds or when manually stopped).
- `.Loaded:Connect(fn(soundId: string))` -- Fires when the audio asset finishes loading.
- `.DidLoop:Connect(fn(soundId: string, numOfTimesLooped: number))` -- Fires each time a looped sound loops.

## Budgets and Limits

No explicit rate limits on Sound playback. However, playing many sounds simultaneously can impact client performance, especially 3D sounds with attenuation calculations.

## Common Patterns

### Playing a one-shot sound effect

```lua
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://9120386436"
sound.Parent = workspace.Part
sound:Play()
sound.Ended:Wait()
sound:Destroy()
```

### Background music with group volume

```lua
local SoundService = game:GetService("SoundService")

local musicGroup = Instance.new("SoundGroup")
musicGroup.Name = "Music"
musicGroup.Volume = 0.5
musicGroup.Parent = SoundService

local bgm = Instance.new("Sound")
bgm.SoundId = "rbxassetid://123456789"
bgm.Looped = true
bgm.Volume = 0.8
bgm.SoundGroup = musicGroup
bgm.Parent = SoundService
bgm:Play()
```

## Pitfalls

- **Play vs Resume**: `:Play()` resets `TimePosition` to 0. To continue from where paused, use `:Resume()`.
- **Ended does not fire for looped sounds**: Use `.DidLoop` instead to track loop completion.
- **Ended does not fire on Stop**: Manually stopping a sound fires `.Stopped`, not `.Ended`.
- **SoundGroup assignment**: Set `Sound.SoundGroup` property -- do not parent the Sound to a SoundGroup.
- **Deprecated properties**: `Pitch` is replaced by `PlaybackSpeed`; `EmitterSize`/`MinDistance`/`MaxDistance` are replaced by `RollOffMinDistance`/`RollOffMaxDistance`.

## Related

- [[SoundService]] -- global audio configuration
- [[SoundGroup]] -- group-level volume control

## Sources

- [wiki/raw/roblox-creator-docs/services/Sound.md](../raw/roblox-creator-docs/services/Sound.md)
