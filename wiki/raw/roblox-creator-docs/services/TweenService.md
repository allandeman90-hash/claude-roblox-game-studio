---
title: TweenService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/TweenService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TweenService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: animation
tags: [roblox-class, tweens, animation, service]
---

# TweenService

Used to create `Class.Tween|Tweens` which interpolate, or tween, the
properties of instances.

## Description

`Class.TweenService` is used to create `Class.Tween|Tweens` which interpolate,
or tween, the properties of instances. `Class.Tween|Tweens` can be used on any
object with compatible property types, including:

- [number](../../../luau/numbers.md)
- [boolean](../../../luau/booleans.md)
- `Datatype.CFrame`
- `Datatype.Rect`
- `Datatype.Color3`
- `Datatype.UDim`
- `Datatype.UDim2`
- `Datatype.Vector2`
- `Datatype.Vector2int16`
- `Datatype.Vector3`
- `Datatype.EnumItem`

`Class.TweenService:Create()`, the primary constructor function, takes
`Datatype.TweenInfo` specifications about the tween and generates the
`Class.Tween` object which can then be used to play the tween.

Note that `Class.Tween|Tweens` can interpolate multiple properties at the same
time, but they must not be interpolating the same property. If two tweens
attempt to modify the same property, the initial tween will be cancelled and
overwritten by the most recent tween.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `TweenService:Create`

```
Create(instance: Instance, tweenInfo: TweenInfo, propertyTable: Dictionary) -> Tween
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Creates a new `Class.Tween` given the object whose properties are to be
tweened, a `Datatype.TweenInfo`, and a dictionary of goal property values.

This constructor creates a new `Class.Tween` from three arguments: the
object to tween, the `Datatype.TweenInfo` specifications, and a table
containing the properties to tween and values to tween to.

The `propertyTable` parameter needs to be a dictionary where the keys are
the string names of the property (for example `Position`, `Transparency`,
or `Color`), and the values are the property targets at the end of the
tween.

The `Class.Tween` created using this function is unique to the object
given as the `instance` parameter. To apply the same tween to another
object, call this function again with the new object.

**Parameters:**

- `instance` : `Instance` — The `Class.Instance` whose properties are to be tweened.
- `tweenInfo` : `TweenInfo` — The `Datatype.TweenInfo` to be used.
- `propertyTable` : `Dictionary` — A dictionary of properties, and their target values, to be tweened.

**Returns:**

- `Tween` — 

### `TweenService:GetValue`

```
GetValue(alpha: float, easingStyle: EasingStyle, easingDirection: EasingDirection) -> float
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Calculates a new alpha given an `Enum.EasingStyle` and
`Enum.EasingDirection`.

Returns a new alpha value for interpolating using the given alpha value,
`Enum.EasingStyle`, and `Enum.EasingDirection`. The provided `alpha` value
will be clamped between `0` and `1`.

**Parameters:**

- `alpha` : `float` — An interpolation value between `0` and `1`.
- `easingStyle` : `EasingStyle` — The easing style to use.
- `easingDirection` : `EasingDirection` — The easing direction to use.

**Returns:**

- `float` — A new alpha value generated from the given easing style and direction.

### `TweenService:SmoothDamp`

```
SmoothDamp(current: Variant, target: Variant, velocity: Variant, smoothTime: float, maxSpeed: float?, dt: float?) -> Tuple
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Smoothly interpolates a value towards a target, simulating a critically
damped spring.

Smoothly interpolates a value towards a target, simulating a critically
damped spring. Returns a tuple with `(newValue, newVelocity`).
`newVelocity` needs to be fed to the next call of SmoothDamp to ensure
smooth results. Supports `Datatype.number`, `Datatype.Vector2`,
`Datatype.Vector3`, and `Datatype.CFrame`.

**Parameters:**

- `current` : `Variant` — The current value to smooth.
- `target` : `Variant` — The target value to reach.
- `velocity` : `Variant` — The current velocity with which the current value should approach the target value. You shouldn't modify this value between calls yourself, it's used to store the stateful velocity. In most cases, initialize this with `0`, `Vector2.zero`, `Vector3.zero`, or `CFrame.identity` depending on the type, or if needed, with your initial velocity.
- `smoothTime` : `float` — The duration over which the total smoothing operation should take place. Note that since this is a damped spring, there's no guarantee `current` will be exactly `target` after this time, but it will be close. Smaller values result in quicker smoothing.
- `maxSpeed` : `float?` — The maximum speed at which the current value should approach the target value. Leaving this nil defaults to `math.huge`, meaning the velocity isn't clamped.
- `dt` : `float?` — The rate at which the smoothing operation should be applied. If left nil, the current engine delta time will be used.

**Returns:**

- `Tuple` — The new value and new velocity calculated from the smoothing operation.

## Events

_No public events documented._

## Notes / Deprecations

_None flagged in source YAML._

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `Tween-Creation` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/TweenService
- `Looped-Tween` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/TweenService
- `Tween-Pausing` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/TweenService
- TweenService:Create: Tween-Creation
- TweenService:Create: Looped-Tween

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/TweenService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/TweenService.yaml
- Captured: 2026-04-16
