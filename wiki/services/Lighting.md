---
title: Lighting
type: service
category: services
subcategory: world
owner: technical-artist
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/roblox-creator-docs/services/Lighting.md
related:
  - "[[Workspace]]"
tags: [roblox-class, world, art]
---

# Lighting

> Controls global lighting in an experience, including time of day, ambient color, fog, and shadows. [[Workspace]]

## Summary

The Lighting service controls all global lighting in a Roblox experience. It provides a range of adjustable properties for ambient light, brightness, fog, time of day, shadows, and environment reflections. Lighting also acts as a container for `Atmosphere` objects (realistic atmospheric effects), `Sky` objects, `Clouds`, and post-processing effects like `BloomEffect`, `BlurEffect`, `ColorCorrectionEffect`, `DepthOfFieldEffect`, and `SunRaysEffect`.

Time of day is controlled via `ClockTime` (numeric hours), `TimeOfDay` (string "HH:MM:SS"), or `SetMinutesAfterMidnight()`. These do not advance automatically -- a script must drive changes for day/night cycles. The sun and moon positions are derived from `ClockTime` and `GeographicLatitude`.

Shadows are voxel-based (4x4x4 stud resolution) and controlled by `GlobalShadows`. The `LightingStyle` property (successor to the deprecated `Technology` property) determines the artistic intent for the lighting system. `ShadowSoftness` controls shadow blur when using ShadowMap or Future modes.

## API Surface

### Properties

- `Ambient: Color3` -- Hue applied to indoor/occluded areas. Default `[0, 0, 0]`.
- `OutdoorAmbient: Color3` -- Hue applied to outdoor areas. Default `[127, 127, 127]`.
- `Brightness: float` -- Intensity of the sun/moon illumination.
- `ClockTime: float` -- Time of day in hours (0-24). Not replicated.
- `TimeOfDay: string` -- 24-hour string representation of time (e.g., `"14:30:00"`).
- `GlobalShadows: boolean` -- Toggles voxel-based dynamic shadows.
- `ShadowSoftness: float` -- Shadow blur amount. Default `0.2`. Requires ShadowMap or Future mode.
- `FogColor: Color3` -- Fog hue (hidden when Atmosphere object is present).
- `FogStart: float` -- Distance in studs where fog begins.
- `FogEnd: float` -- Distance in studs where fog is fully opaque.
- `GeographicLatitude: float` -- Latitude in degrees; affects sun/moon position arc.
- `EnvironmentDiffuseScale: float` -- Dynamic ambient light derived from environment. Default `0`.
- `EnvironmentSpecularScale: float` -- Environment reflections on smooth surfaces. Default `0`.
- `ExposureCompensation: float` -- Exposure bias before tonemapping. Range `-5` to `5`. Default `0`.
- `ColorShift_Top: Color3` -- Hue shift on surfaces facing the sun/moon.
- `ColorShift_Bottom: Color3` -- Hue shift on surfaces opposite the sun/moon.

### Methods

- `:GetSunDirection() -> Vector3` -- Direction of the sun from origin. Continues pointing below horizon when the sun sets.
- `:GetMoonDirection() -> Vector3` -- Direction of the moon from origin.
- `:GetMinutesAfterMidnight() -> number` -- Current time as minutes after midnight.
- `:SetMinutesAfterMidnight(minutes: number) -> ()` -- Sets time of day. Accepts values > 1440 (wraps to next day).

### Events

- `.LightingChanged:Connect(fn(skyChanged: boolean))` -- Fires when a Lighting property changes or a Sky is added/removed. Does NOT fire for GlobalShadows or fog property changes.

## Budgets and Limits

- **Shadow voxel size**: 4x4x4 studs. Objects smaller than this do not cast realistic shadows.
- **Shadow recalculation**: Happens when BaseParts move, which can be expensive in physics-heavy scenes.

## Common Patterns

### Simple day/night cycle

```lua
local Lighting = game:GetService("Lighting")

local TIME_SPEED = 60  -- 1 real minute = 1 in-game hour
local START_TIME = 9   -- 9 AM

local minutesAfterMidnight = START_TIME * 60
local waitTime = 60 / TIME_SPEED

while true do
    minutesAfterMidnight += 1
    Lighting:SetMinutesAfterMidnight(minutesAfterMidnight)
    task.wait(waitTime)
end
```

### Setting a mood

```lua
local Lighting = game:GetService("Lighting")

-- Moody evening with warm fog
Lighting.ClockTime = 18.5
Lighting.Ambient = Color3.fromRGB(30, 20, 40)
Lighting.OutdoorAmbient = Color3.fromRGB(100, 80, 60)
Lighting.FogColor = Color3.fromRGB(180, 140, 100)
Lighting.FogStart = 50
Lighting.FogEnd = 500
Lighting.ExposureCompensation = -0.5
```

## Pitfalls

- **Time does not advance automatically**: ClockTime/TimeOfDay stays static unless a script changes it.
- **Fog hidden by Atmosphere**: If a Lighting child `Atmosphere` object exists, FogColor/FogStart/FogEnd are hidden and have no effect.
- **LightingChanged gaps**: Changing `GlobalShadows`, `FogColor`, `FogStart`, or `FogEnd` does NOT fire `LightingChanged`. Use `GetPropertyChangedSignal()` instead.
- **Deprecated properties**: `Technology` is superseded by `LightingStyle` + `PrioritizeLightingQuality`. `ShadowColor` and `Outlines` have no current functionality.
- **Shadow resolution**: 4x4x4 stud voxels mean small objects (< 4 studs) produce unrealistic or missing shadows.

## Related

- [[Workspace]] -- the 3D world container

## Sources

- [wiki/raw/roblox-creator-docs/services/Lighting.md](../raw/roblox-creator-docs/services/Lighting.md)
