---
title: SoundService
type: service
category: services
subcategory: audio
owner: sound-designer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/SoundService.md
related:
  - "[[Sound]]"
  - "[[SoundGroup]]"
tags: [roblox-class, audio]
---

# SoundService

> Global audio configuration service that controls how Sounds behave in an experience. [[Sound]]

## Summary

SoundService determines various aspects of how the audio engine works, including Doppler effect simulation, distance attenuation scaling, ambient reverb, and filtering behavior. Most of its properties affect how [[Sound]] instances play, while others affect the advanced audio system (AudioPlayer, AudioEmitter, AudioListener).

SoundService is also the standard container for [[SoundGroup]] instances, though groups work regardless of where they are parented. The service provides methods to control the audio listener position (the point from which the player "hears" the world) and to play sounds locally on a single client.

The default listener is `Workspace.CurrentCamera`. This can be changed via `:SetListener()` to follow a specific BasePart or CFrame -- useful for third-person games or spectator cameras.

## API Surface

### Properties

- `AmbientReverb: Enum.ReverbType` -- Global reverb preset applied to all Sounds (e.g., Hangar, Forest, Arena). Does not affect the advanced audio system.
- `DistanceFactor: float` -- Studs per meter for Doppler calculations. Default 3.33. Higher values = less Doppler shift.
- `DopplerScale: float` -- Multiplier for Doppler effect intensity. Default 1. Set to 0 to disable Doppler.
- `RolloffScale: float` -- Global attenuation speed multiplier for 3D Sounds.
- `RespectFilteringEnabled: boolean` -- When true (default), client-initiated Sound playback does not replicate to other clients.
- `VolumetricAudio: Enum.VolumetricAudio` -- Whether Sounds parented to Parts emit volumetrically (from the part's interior) vs. from a single center point.
- `AcousticSimulationEnabled: boolean` -- Enables global acoustic simulation (occlusion, diffraction, reverb) for the advanced audio system.

### Methods

- `:SetListener(listenerType: Enum.ListenerType, listener: any?) -> ()` -- Sets the audio listener. Types: Camera (default), CFrame, ObjectPosition, ObjectCFrame.
- `:GetListener() -> (Enum.ListenerType, any?)` -- Returns the current listener type and target.
- `:PlayLocalSound(sound: Sound) -> ()` -- Plays a copy of the Sound locally on this client only. Useful for UI sounds.
- `:GetMixerTime() -> number` -- Returns seconds since the audio engine started mixing. Monotonic and sample-accurate; useful for scheduling.

### Events

_No public events._

## Budgets and Limits

No explicit rate limits on SoundService methods. The audio engine handles mixing and spatialization internally.

## Common Patterns

### Setting up listener on a character

```lua
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
player.CharacterAdded:Connect(function(character)
    local rootPart = character:WaitForChild("HumanoidRootPart")
    SoundService:SetListener(Enum.ListenerType.ObjectCFrame, rootPart)
end)
```

### Organizing SoundGroups

```lua
local SoundService = game:GetService("SoundService")

-- Standard mixing hierarchy
-- SoundService/
--   Music (SoundGroup, Volume = 0.5)
--   SFX (SoundGroup, Volume = 0.8)
--   UI (SoundGroup, Volume = 1.0)
--   Ambient (SoundGroup, Volume = 0.6)
```

## Pitfalls

- **RespectFilteringEnabled default**: This is true by default. If you want client-played sounds to be heard by all players, you need to fire them from the server.
- **AmbientReverb scope**: Only affects legacy Sound instances, not the advanced audio system (AudioPlayer/AudioEmitter). Use AudioReverb for the new system.
- **SetListener is client-only**: Changing the listener only makes sense on the client. The server does not have a "listener."
- **PlayLocalSound limitations**: The copy does not inherit `Looped` or `AmbientReverb`. Only Volume, TimePosition, PlaybackSpeed, and spatialization/effects carry over.

## Related

- [[Sound]] -- individual sound instances
- [[SoundGroup]] -- group-level volume and effects control

## Sources

- [wiki/raw/roblox-creator-docs/services/SoundService.md](../raw/roblox-creator-docs/services/SoundService.md)
