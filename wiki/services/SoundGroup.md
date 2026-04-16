---
title: SoundGroup
type: service
category: services
subcategory: audio
owner: sound-designer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/SoundGroup.md
related:
  - "[[SoundService]]"
  - "[[Sound]]"
tags: [roblox-class, audio]
---

# SoundGroup

> Manages volume and effects for multiple Sounds simultaneously. [[Sound]]

## Summary

SoundGroup allows group-level volume and effects control over multiple [[Sound]] instances. The group's `Volume` property acts as a **multiplier** on each member Sound's volume -- a Sound with Volume 0.5 in a SoundGroup with Volume 0.5 has an effective playback volume of 0.25.

Any `SoundEffect` instances parented to a SoundGroup (e.g., `EqualizerSoundEffect`, `ReverbSoundEffect`) are applied to all Sounds in that group. This makes SoundGroups ideal for implementing user-facing volume sliders (Music, SFX, UI, Voice, Ambient) and applying shared audio processing.

A Sound is assigned to a SoundGroup by setting its `Sound.SoundGroup` property, **not** by parenting the Sound to the group. A Sound can belong to only one SoundGroup at a time. SoundGroups can be nested for hierarchical mixing. SoundGroups are commonly stored in [[SoundService]], though this is not required.

## API Surface

### Properties

- `Volume: float` -- Volume multiplier applied to all member Sounds. Range 0 to 10.

### Methods

_No public methods._

### Events

_No public events._

## Budgets and Limits

No explicit rate limits. SoundGroup is a lightweight mixing node with minimal performance impact.

## Common Patterns

### Volume slider implementation

```lua
local SoundService = game:GetService("SoundService")

-- Create groups
local musicGroup = Instance.new("SoundGroup")
musicGroup.Name = "Music"
musicGroup.Volume = 1
musicGroup.Parent = SoundService

local sfxGroup = Instance.new("SoundGroup")
sfxGroup.Name = "SFX"
sfxGroup.Volume = 1
sfxGroup.Parent = SoundService

-- When user adjusts the Music slider:
musicGroup.Volume = 0.3  -- All music sounds now play at 30% of their individual volume
```

## Pitfalls

- **Assignment, not parenting**: Sounds join a group via the `Sound.SoundGroup` property, not by being parented to the SoundGroup.
- **One group per sound**: A Sound can only belong to one SoundGroup at a time.
- **Volume is multiplicative**: Group Volume 0 silences all member sounds regardless of their individual Volume settings.

## Related

- [[SoundService]] -- often used as the parent container for SoundGroups
- [[Sound]] -- individual sound instance that can be assigned to a group

## Sources

- [wiki/raw/roblox-creator-docs/services/SoundGroup.md](../raw/roblox-creator-docs/services/SoundGroup.md)
