---
title: Attachment
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Attachment
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Attachment.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: physics
tags: [roblox-class, attachment, constraints, joints]
---

# Attachment

Defines a point and orientation relative to an ancestor `Class.PVInstance`,
`Class.Bone`, or another `Class.Attachment`.

## Description

An `Attachment` defines a point and orientation relative to an ancestor
`Class.PVInstance`, `Class.Bone`, or another `Attachment`. The offset is
stored in the `Class.Attachment.CFrame|CFrame` property. The offset can also
be set through other properties, such as
`Class.Attachment.WorldCFrame|WorldCFrame`.

If no ancestral `Class.PVInstance` or `Class.Attachment` exists, then
`Class.Attachment.CFrame|CFrame` and
`Class.Attachment.WorldCFrame|WorldCFrame` are the same.

Attachments are used by several kinds of `Class.Constraint|Constraints` and
are also valid alternatives to `Class.BasePart` as a parent for objects such
as:

- `Class.ParticleEmitter|ParticleEmitters` which will emit particles from the
  attachment's specific position/orientation instead of the `Class.BasePart`
  bounds.

- Light-emitting objects like `Class.PointLight` and `Class.SpotLight` which
  will shine from the attachment's position/orientation instead of the
  `Class.BasePart` center.

- `Class.AudioEmitter` which will use the attachment's position as the audio's
  point of emission.

## Inheritance

Inherits from: `Instance`

Memory category: `Instances`

## Properties

### `Attachment.Axis`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

Direction of the **X** axis of the attachment, represented as a unit
`Datatype.Vector3`.

### `Attachment.CFrame`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

`Datatype.CFrame` offset of the attachment.

The `Datatype.CFrame` offset of the attachment. Changes to this property
will reflect onto the `Class.Attachment.Position|Position` and
`Class.Attachment.Rotation|Rotation` properties of this object. Similarly,
a change to either of those properties will reflect onto this property.

### `Attachment.Orientation`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `Basic`

Orientation of the attachment relative to the orientation of its parent.

Orientation of the attachment relative to the orientation of its parent.
Rotations are in **Z**,&nbsp;**X**,&nbsp;**Y** order.

### `Attachment.Position`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `Basic`

Positional offset of the attachment, relative to the position and
orientation of its parent.

### `Attachment.Rotation`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Basic`
- **Deprecated:** This property is deprecated and should not be used in new work. See
`Class.Attachment.Orientation|Orientation` instead.

Rotation of the attachment relative to the rotation of its parent.

Rotation of the attachment relative to the rotation of its parent.
Rotations are in **Z**,&nbsp;**Y**,&nbsp;**X** order.

### `Attachment.SecondaryAxis`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

Direction of the **Y** axis of the attachment, represented as a unit
`Datatype.Vector3`.

### `Attachment.Visible`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Toggles the in-experience visibility of the attachment.

### `Attachment.WorldAxis`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

Direction of the **X** axis of the attachment relative to the world,
represented as a unit `Datatype.Vector3` with a length of 1.

### `Attachment.WorldCFrame`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

The exact `Datatype.CFrame` of the attachment in world space coordinates.

The exact `Datatype.CFrame` of the attachment in world space coordinates,
independent of its parent. The value of this property is equivalent to
multiplying the `Datatype.CFrame` of the attachment's parent by its own
`Datatype.CFrame`.

### `Attachment.WorldOrientation`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `Basic`

Orientation of the attachment relative to the world rather than its own
parent.

Orientation of the attachment relative to the world rather than its own
parent. Rotations are in **Z**,&nbsp;**X**,&nbsp;**Y** order.

### `Attachment.WorldPosition`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`
- **Capabilities:** `Basic`

Position of the attachment relative to the world rather than its own
parent.

### `Attachment.WorldRotation`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `ReadOnly`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Basic`
- **Deprecated:** This item has been superseded by
`Class.Attachment.WorldOrientation|WorldOrientation` which should be used
in new work.

Rotation of the attachment relative to the world rather than its own
parent.

### `Attachment.WorldSecondaryAxis`

- **Type:** `Vector3`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

Direction of the **Y** axis of the attachment relative to the world,
represented as a unit `Datatype.Vector3` with a length of 1.

## Methods

### `Attachment:GetAxis`

```
GetAxis() -> Vector3
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method is deprecated and should not be used in new work.

Returns the value of the attachment's `Class.Attachment.Axis|Axis`.

**Returns:**

- `Vector3` --- 

### `Attachment:GetConstraints`

```
GetConstraints() -> List<Constraint>
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Returns a list of `Class.Constraint|Constraints` connected to the
attachment.

**Returns:**

- `List<Constraint>` --- 

### `Attachment:GetSecondaryAxis`

```
GetSecondaryAxis() -> Vector3
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method is deprecated and should not be used in new work.

Returns the value of the attachment's
`Class.Attachment.SecondaryAxis|SecondaryAxis`.

**Returns:**

- `Vector3` --- 

### `Attachment:SetAxis`

```
SetAxis(axis: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method is deprecated and should not be used in new work.

Sets the value of the attachment's `Class.Attachment.Axis|Axis`.

**Parameters:**

- `axis` : `Vector3` --- 

**Returns:**

- `()` --- 

### `Attachment:SetSecondaryAxis`

```
SetSecondaryAxis(axis: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method is deprecated and should not be used in new work.

Sets the value of the attachment's
`Class.Attachment.SecondaryAxis|SecondaryAxis`.

**Parameters:**

- `axis` : `Vector3` --- 

**Returns:**

- `()` --- 

## Events

_No public events documented._

## Notes / Deprecations

- Deprecated property `Attachment.Rotation`: This property is deprecated and should not be used in new work. See
`Class.Attachment.Orientation|Orientation` instead.
- Deprecated property `Attachment.WorldRotation`: This item has been superseded by
`Class.Attachment.WorldOrientation|WorldOrientation` which should be used
in new work.
- Deprecated method `Attachment:GetAxis`: This method is deprecated and should not be used in new work.
- Deprecated method `Attachment:GetSecondaryAxis`: This method is deprecated and should not be used in new work.
- Deprecated method `Attachment:SetAxis`: This method is deprecated and should not be used in new work.
- Deprecated method `Attachment:SetSecondaryAxis`: This method is deprecated and should not be used in new work.
- Property `Attachment.Axis` security: `read=None, write=None`
- Property `Attachment.CFrame` security: `read=None, write=None`
- Property `Attachment.Orientation` security: `read=None, write=None`
- Property `Attachment.Position` security: `read=None, write=None`
- Property `Attachment.Rotation` security: `read=None, write=None`
- Property `Attachment.SecondaryAxis` security: `read=None, write=None`
- Property `Attachment.Visible` security: `read=None, write=None`
- Property `Attachment.WorldAxis` security: `read=None, write=None`
- Property `Attachment.WorldCFrame` security: `read=None, write=None`
- Property `Attachment.WorldOrientation` security: `read=None, write=None`
- Property `Attachment.WorldPosition` security: `read=None, write=None`
- Property `Attachment.WorldRotation` security: `read=None, write=None`
- Property `Attachment.WorldSecondaryAxis` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Attachment
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Attachment.yaml
- Captured: 2026-04-16
