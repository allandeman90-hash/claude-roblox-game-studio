---
title: Lighting
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Lighting
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Lighting.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: environment
tags: [roblox-class, lighting, environment, service]
---

# Lighting

The `Lighting` service controls global lighting in an experience. It includes
a range of adjustable properties that you can use to change how lighting
appears and interacts with other objects.

## Description

The `Lighting` service controls global lighting in an experience. It includes
a range of adjustable properties that you can use to change how lighting
appears and interacts with other objects, as summarized in
[Lighting Properties](../../../environment/lighting.md).

<img src="../../../assets/lighting-and-effects/lighting-properties/TimeOfDay-17.jpg" width="800" />

`Lighting` may also contain an `Class.Atmosphere` object to render realistic
atmospheric effects, including particle density, haze, glare, and color. See
[Atmospheric Effects](../../../environment/atmosphere.md) for details.

<img src="../../../assets/lighting-and-effects/atmosphere/Offset-A.jpg" width="800" />

In addition, `Lighting` (along with `Class.Workspace.CurrentCamera`) may
contain
[post‑processing effects](../../../environment/post-processing-effects.md)
such as `Class.SunRaysEffect` and `Class.BlurEffect`.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

### `Lighting.Ambient`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The lighting hue applied to areas that are occluded from the sky, such as
indoor areas.

`Ambient` is the lighting hue applied to areas that are occluded from the
sky, such as indoor areas.

`Ambient` defaults to `[0, 0, 0]` (black). As long as the red, green, and
blue channels of this property do not exceed the corresponding channels in
`Class.Lighting.OutdoorAmbient|OutdoorAmbient`, the change in hue will be
reserved for areas occluded from the sun/moon.

Note that when `Class.Lighting.GlobalShadows|GlobalShadows` is disabled,
there is no distinction between areas occluded from the sky and
non‑occluded areas. In this case,
`Class.Lighting.OutdoorAmbient|OutdoorAmbient` will be ignored and the hue
from the `Ambient` property will be applied everywhere.

### `Lighting.Brightness`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The intensity of illumination in the place.

The intensity of illumination in the place.

Changing this value will influence the impact of the light source (sun or
moon) on the place's lighting. Note that `Class.Lighting.Ambient|Ambient`
and `Class.Lighting.OutdoorAmbient|OutdoorAmbient` can also be used to
influence how bright a place appears. For example, setting
`Class.Lighting.OutdoorAmbient|OutdoorAmbient` to <Typography
noWrap>`[255, 255, 255]`</Typography> will make the place appear brighter
than its default value of <Typography noWrap>`127, 127, 127`</Typography>
(as it is more white).

### `Lighting.ClockTime`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Environment`

A numerical representation (in hours) of the current time of day used by
`Lighting`.

A numerical representation (in hours) of the current time of day used by
`Lighting`. Note that this property does not correspond with the actual
time of day and will not change during gameplay unless it has been changed
by a script.

For a measure of `Lighting` time formatted as a 24-hour string, use
`Class.Lighting.TimeOfDay|TimeOfDay`. Changing
`Class.Lighting.TimeOfDay|TimeOfDay` or using
`Class.Lighting:SetMinutesAfterMidnight()|SetMinutesAfterMidnight()` will
also change this property.

### `Lighting.ColorShift_Bottom`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The hue represented in light reflected in the opposite surfaces to those
facing the sun or moon.

The hue represented in light reflected in the opposite surfaces to those
facing the sun or moon.

The surfaces of a `Class.BasePart` influenced by `ColorShift_Bottom`
depends on the position and orientation of the `Class.BasePart` relative
to the sun or moon's position. Where the sun is directly overhead a
`Class.BasePart`, the shift in color will only apply to the bottom
surface.

This effect can be increased or reduced by altering
`Class.Lighting.Brightness|Brightness`.

Note that `Class.Lighting.ColorShift_Top|ColorShift_Top` and
`ColorShift_Bottom` will interact with the
`Class.Lighting.Ambient|Ambient` and
`Class.Lighting.OutdoorAmbient|OutdoorAmbient` properties if they are
greater than <Typography noWrap>`[0, 0, 0]`</Typography>. Also note that
the influence of `ColorShift_Bottom` can be very hard to identify when
`Class.Lighting.GlobalShadows|GlobalShadows` is enabled (default).

### `Lighting.ColorShift_Top`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The hue represented in light reflected from surfaces facing the sun or
moon.

The hue represented in light reflected from surfaces facing the sun or
moon.

The surfaces of a `Class.BasePart` influenced by `ColorShift_Top` depends
on the position and orientation of the `Class.BasePart` relative to the
sun or moon's position. Where the sun is directly overhead a
`Class.BasePart`, the shift in color will only apply to the top surface.

This effect can be increased or reduced by altering
`Class.Lighting.Brightness|Brightness`.

Note that `ColorShift_Top` and
`Class.Lighting.ColorShift_Bottom|ColorShift_Bottom` will interact with
the `Class.Lighting.Ambient|Ambient` and
`Class.Lighting.OutdoorAmbient|OutdoorAmbient` properties if they are
greater than <Typography noWrap>`[0, 0, 0]`</Typography>.

### `Lighting.EnvironmentDiffuseScale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

Ambient light that is derived from the environment.

Ambient light that is derived from the environment with a default of `0`.
This property is similar to `Class.Lighting.Ambient|Ambient` and
`Class.Lighting.OutdoorAmbient|OutdoorAmbient` but it's dynamic and can
change according to the sky and time of day. When this property is
increased, it's recommended to decrease `Class.Lighting.Ambient|Ambient`
and `Class.Lighting.OutdoorAmbient|OutdoorAmbient` accordingly.

### `Lighting.EnvironmentSpecularScale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

Specular light derived from environment.

Specular light derived from environment with a default of `0`. This
property will make smooth objects reflect the environment and it is
especially important to make metal look more realistic.

### `Lighting.ExposureCompensation`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The exposure compensation value.

This property determines the exposure compensation amount which applies a
bias to the exposure level of the scene prior to the tonemap step.
Defaults to `0` (no exposure compensation) and has a range from `-5` to
`5`. A value of `1` indicates twice as much exposure and `-1` means half
as much exposure.

### `Lighting.ExtendLightRangeTo120`

- **Type:** `RolloutState`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotScriptable`
- **Capabilities:** `Environment`

### `Lighting.FogColor`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

A `Datatype.Color3` value giving the hue of `Lighting` fog.

A `Datatype.Color3` value giving the hue of `Lighting` fog. Note that fog
properties are hidden when `Lighting` contains an `Class.Atmosphere`
object.

### `Lighting.FogEnd`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The depth from the `Class.Workspace.CurrentCamera`, in studs, at which fog
will be completely opaque.

The depth from the `Class.Workspace.CurrentCamera`, in studs, at which fog
will be completely opaque. Note that fog properties are hidden when
`Lighting` contains an `Class.Atmosphere` object.

### `Lighting.FogStart`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The depth from the `Class.Workspace.CurrentCamera`, in studs, at which fog
begins to show.

The depth from the `Class.Workspace.CurrentCamera`, in studs, at which fog
begins to show. Note that fog properties are hidden when `Lighting`
contains an `Class.Atmosphere` object.

### `Lighting.GeographicLatitude`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The geographic latitude, in degrees, of the scene, influencing the result
of `Lighting` time on the position of the sun and moon.

The geographic latitude, in degrees, of the scene, influencing the result
of `Lighting` time on the position of the sun and moon. When calculating
the position of the sun, the earth's tilt is also taken into account.

Changing `GeographicLatitude` will alter the position of the sun at every
`Class.Lighting.TimeOfDay|TimeOfDay`. If you're looking to obtain the sun
or moon's position, use
`Class.Lighting:GetSunDirection()|GetSunDirection()` or
`Class.Lighting:GetMoonDirection()|GetMoonDirection()`.

### `Lighting.GlobalShadows`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

Toggles voxel-based dynamic lighting for the place.

Toggles voxel-based dynamic lighting in the place. When set to `true`,
shadows are rendered in sheltered areas depending on the position of the
sun and moon. The lighting hue applied to these sheltered areas is
determined by the `Class.Lighting.Ambient|Ambient` property while the
lighting hue in all other areas is determined by the
`Class.Lighting.OutdoorAmbient|OutdoorAmbient` property.

When `false`, shadows are not drawn and no distinction is made between
indoor and outdoor areas. As a result, the
`Class.Lighting.Ambient|Ambient` property determines the lighting hue and
`Class.Lighting.OutdoorAmbient|OutdoorAmbient` will do nothing.

Shadows are calculated using a voxel system and each lighting voxel is
4&times;4&times;4 studs. This means objects need to be larger than
4&times;4&times;4 studs to display a realistic shadow. Shadows are also
recalculated when `Class.BasePart|BaseParts` are moving.

### `Lighting.LightingStyle`

- **Type:** `LightingStyle`
- **Security:** `read=None, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The artistic intent behind lighting in the experience.

`LightingStyle` indicates the artistic intent behind lighting in the
experience, as an `Enum.LightingStyle` option.

### `Lighting.OutdoorAmbient`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

The lighting hue applied to outdoor areas.

`OutdoorAmbient` is the lighting hue applied to outdoor areas.

`OutdoorAmbient` defaults to `[127, 127, 127]`. As long as the red, green,
and blue channels of `Class.Lighting.Ambient|Ambient` do not exceed the
corresponding channels in `OutdoorAmbient`, the hue of the lighting in
outdoor areas will be determined by this property.

The effective `OutdoorAmbient` value is clamped to be greater than or
equal to `Class.Lighting.Ambient|Ambient` in all channels, meaning that if
a channel of `Class.Lighting.Ambient|Ambient` exceeds its corresponding
`OutdoorAmbient` channel, the hue of `Class.Lighting.Ambient|Ambient` will
begin to apply to outdoor areas.

Note that when `Class.Lighting.GlobalShadows|GlobalShadows` is disabled,
there is no distinction between areas occluded from the sky and
non‑occluded areas. In this case, `OutdoorAmbient` will be ignored and the
hue from the `Class.Lighting.Ambient|Ambient` property will be applied
everywhere.

### `Lighting.Outlines`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Deprecated`
- **Capabilities:** `Environment`
- **Deprecated:** This item is no longer supported as the outlines feature was removed from
the Roblox platform.

Determines whether outlines are enabled or disabled in a place.

This property determines whether outlines are enabled or disabled in a
place.

Outlines can be disabled on a global basis, using this `Lighting`
property, or alternatively on a surface-by-surface basis for
`Class.BasePart|BaseParts` using `Enum.SurfaceType`.

Although this property can be set by scripts, it recommended this property
is set in Roblox Studio prior to publishing the place.

### `Lighting.PrioritizeLightingQuality`

- **Type:** `boolean`
- **Security:** `read=None, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

Indicates whether you prefer lighting/shading quality or view distance to
scale down first.

This property indicates whether you prefer lighting/shading quality or
view distance to scale down first. As the rendering quality level reduces,
a setting of `true` prioritizes features such as advanced shadows and
high‑quality shaders at closer distances, while a setting of `false`
prioritizes view distance.

### `Lighting.ShadowColor`

- **Type:** `Color3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `Deprecated`
- **Capabilities:** `Environment`
- **Deprecated:** This item is deprecated and has no current functionality. Do not use it
for new work.

This is supposed to change the color of player shadows, but currently
doesn't do anything.

### `Lighting.ShadowSoftness`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

Controls how blurry the shadows are.

Controls how blurry the shadows are with a default of `0.2`. This property
only works when `Class.Lighting.Technology|Technology` mode is
`Enum.Technology|ShadowMap` or `Enum.Technology|Future` and the device is
capable of rendering shadow maps.

### `Lighting.Technology`

- **Type:** `Technology`
- **Security:** `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`
- **Deprecated:** This property has been superseded by
`Class.Lighting.LightingStyle|LightingStyle` which determines the artistic
intent behind lighting, and
`Class.Lighting.PrioritizeLightingQuality|PrioritizeLightingQuality` which
indicates whether you prefer lighting/shading quality or view distance to
scale down first.

Determines the lighting system for rendering the 3D world. Non-scriptable.

Determines the lighting system for rendering the 3D world. This property
is non‑scriptable and only modifiable in Studio.

### `Lighting.TimeOfDay`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Environment`

A 24-hour string representation of the current time of day used by
`Lighting`.

A 24-hour string representation of the current time of day used by
`Lighting`. For example:

```lua
local Lighting = game:GetService("Lighting")

Lighting.TimeOfDay = "11:00" -- Set time of day to 11:00 AM
Lighting.TimeOfDay = "21:30" -- Set time of day to 9:30 PM
```

Note that this property does not correspond with the real-world time of
day and will not change during gameplay unless it has been changed by a
script.

For a numeric measure of `Lighting` time, use
`Class.Lighting.ClockTime|ClockTime`. Changing
`Class.Lighting.ClockTime|ClockTime` or using
`Class.Lighting:SetMinutesAfterMidnight()|SetMinutesAfterMidnight()` will
also change this property.

## Methods

### `Lighting:GetMinutesAfterMidnight`

```
GetMinutesAfterMidnight() -> double
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Environment`

Returns the number of minutes that have passed after midnight for the
purposes of lighting.

Returns the number of minutes that have passed after midnight for the
purposes of lighting. This number will be nearly identical to
`Class.Lighting.ClockTime|ClockTime` multiplied by `60`.

Note that this number will not always be equal to the value given in
`Class.Lighting:SetMinutesAfterMidnight()|SetMinutesAfterMidnight()` as it
returns minutes after midnight in the current day.

**Returns:**

- `double` — The number of minutes after midnight.

### `Lighting:getMinutesAfterMidnight`

```
getMinutesAfterMidnight() -> double
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This method is a deprecated variant of
`Class.Lighting:GetMinutesAfterMidnight()` which should be used instead.

**Returns:**

- `double` — 

### `Lighting:GetMoonDirection`

```
GetMoonDirection() -> Vector3
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Environment`

Returns a `Datatype.Vector3` representing the direction of the moon.

Returns a `Datatype.Vector3` representing the direction of the moon from
the position <Typography noWrap>`(0, 0, 0)`</Typography>. Note that when
the moon has "set" and is no longer visible, the `Datatype.Vector3`
returned by this method will continue to point towards the moon below the
horizon.

`Class.Lighting:GetSunDirection()|GetSunDirection()` is a variant of this
method for obtaining the direction of the sun.

**Returns:**

- `Vector3` — `Datatype.Vector3` representing the direction of the moon.

### `Lighting:GetMoonPhase`

```
GetMoonPhase() -> float
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment` ; **Deprecated:** There is currently no way to change the moon's phase, and thus this method
should not be used.

Returns the moon's current phase.

Returns the moon's current phase. There is no way to change the moon's
phase so this will always return `0.75`.

**Returns:**

- `float` — 

### `Lighting:GetSunDirection`

```
GetSunDirection() -> Vector3
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Environment`

Returns a `Datatype.Vector3` representing the direction of the sun.

Returns a `Datatype.Vector3` representing the direction of the sun from
the position <Typography noWrap>`(0, 0, 0)`</Typography>. Note that when
the sun has "set" and is no longer visible, the `Datatype.Vector3`
returned by this method will continue to point towards the sun below the
horizon.

`Class.Lighting:GetMoonDirection()|GetMoonDirection()` is a variant of
this method for obtaining the direction of the moon.

**Returns:**

- `Vector3` — `Datatype.Vector3` representing the direction of the sun.

### `Lighting:SetMinutesAfterMidnight`

```
SetMinutesAfterMidnight(minutes: double) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Environment`

Sets `Class.Lighting.TimeOfDay|TimeOfDay` and
`Class.Lighting.ClockTime|ClockTime` to the given number of minutes after
midnight.

Sets `Class.Lighting.TimeOfDay|TimeOfDay` and
`Class.Lighting.ClockTime|ClockTime` to the given number of minutes after
midnight.

This method allows a numerical value to be used, for example in a
day/night cycle `Class.Script`, without the need to convert to a string in
the format required by `Class.Lighting.TimeOfDay|TimeOfDay`. It also
allows values greater than 24 hours to be given that correspond to times
in the next day.

The following code sample includes a simple day/night cycle script. The
speed of time and the initial time can be changed using the `TIME_SPEED`
and `START_TIME` parameters.

```lua
local Lighting = game:GetService("Lighting")

local TIME_SPEED = 60  -- 1 min = 1 hour
local START_TIME = 9  -- 9 AM

local minutesAfterMidnight = START_TIME * 60
local waitTime = 60 / TIME_SPEED

while true do
	minutesAfterMidnight = minutesAfterMidnight + 1

	Lighting:SetMinutesAfterMidnight(minutesAfterMidnight)

	task.wait(waitTime)
end
```

**Parameters:**

- `minutes` : `double` — The number of minutes after midnight.

**Returns:**

- `()` — 

### `Lighting:setMinutesAfterMidnight`

```
setMinutesAfterMidnight(minutes: double) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Environment` ; **Deprecated:** This method is a deprecated variant of
`Class.Lighting:SetMinutesAfterMidnight()` which should be used instead.

**Parameters:**

- `minutes` : `double` — 

**Returns:**

- `()` — 

## Events

### `Lighting.LightingChanged`

```
LightingChanged(skyChanged: boolean)
```

- security=`None` ; capabilities=`Environment`

This event fires when a `Lighting` property is changed or a `Class.Sky` is
added or removed from `Lighting`.

This event fires when a `Lighting` property is changed or a `Class.Sky` is
added or removed from `Lighting`, with some exceptions:

- Changing `Class.Lighting.GlobalShadows|GlobalShadows` will not fire this
  event.
- Changing fog properties `Class.Lighting.FogColor|FogColor`,
  `Class.Lighting.FogStart|FogStart`, or `Class.Lighting.FogEnd|FogEnd`
  will not fire this event.

In cases where this behavior is not desired, the `Class.Object.Changed`
event or `Class.Object:GetPropertyChangedSignal()` method can be used.

**Parameters:**

- `skyChanged` : `boolean` — 

## Notes / Deprecations

- Deprecated property `Lighting.Outlines`: This item is no longer supported as the outlines feature was removed from
the Roblox platform.
- Deprecated property `Lighting.ShadowColor`: This item is deprecated and has no current functionality. Do not use it
for new work.
- Deprecated property `Lighting.Technology`: This property has been superseded by
`Class.Lighting.LightingStyle|LightingStyle` which determines the artistic
intent behind lighting, and
`Class.Lighting.PrioritizeLightingQuality|PrioritizeLightingQuality` which
indicates whether you prefer lighting/shading quality or view distance to
scale down first.
- Deprecated method `Lighting:getMinutesAfterMidnight`: This method is a deprecated variant of
`Class.Lighting:GetMinutesAfterMidnight()` which should be used instead.
- Deprecated method `Lighting:GetMoonPhase`: There is currently no way to change the moon's phase, and thus this method
should not be used.
- Deprecated method `Lighting:setMinutesAfterMidnight`: This method is a deprecated variant of
`Class.Lighting:SetMinutesAfterMidnight()` which should be used instead.
- Property `Lighting.Ambient` security: `read=None, write=None`
- Property `Lighting.Brightness` security: `read=None, write=None`
- Property `Lighting.ClockTime` security: `read=None, write=None`
- Property `Lighting.ColorShift_Bottom` security: `read=None, write=None`
- Property `Lighting.ColorShift_Top` security: `read=None, write=None`
- Property `Lighting.EnvironmentDiffuseScale` security: `read=None, write=None`
- Property `Lighting.EnvironmentSpecularScale` security: `read=None, write=None`
- Property `Lighting.ExposureCompensation` security: `read=None, write=None`
- Property `Lighting.ExtendLightRangeTo120` security: `read=None, write=None`
- Property `Lighting.FogColor` security: `read=None, write=None`
- Property `Lighting.FogEnd` security: `read=None, write=None`
- Property `Lighting.FogStart` security: `read=None, write=None`
- Property `Lighting.GeographicLatitude` security: `read=None, write=None`
- Property `Lighting.GlobalShadows` security: `read=None, write=None`
- Property `Lighting.LightingStyle` security: `read=None, write=RobloxScriptSecurity`
- Property `Lighting.OutdoorAmbient` security: `read=None, write=None`
- Property `Lighting.Outlines` security: `read=None, write=None`
- Property `Lighting.PrioritizeLightingQuality` security: `read=None, write=RobloxScriptSecurity`
- Property `Lighting.ShadowColor` security: `read=None, write=None`
- Property `Lighting.ShadowSoftness` security: `read=None, write=None`
- Property `Lighting.Technology` security: `read=RobloxScriptSecurity, write=RobloxScriptSecurity`
- Property `Lighting.TimeOfDay` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Lighting
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Lighting.yaml
- Captured: 2026-04-16
