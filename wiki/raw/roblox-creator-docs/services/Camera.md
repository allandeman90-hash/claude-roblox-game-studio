---
title: Camera
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Camera
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Camera.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: rendering
tags: [roblox-class, camera, viewport, rendering]
---

# Camera

A class which defines a view of the 3D world.

## Description

The `Camera` object defines a view of the 3D world. In a running experience,
each client has its own `Camera` object which resides in that client's local
`Class.Workspace`, accessible through the `Class.Workspace.CurrentCamera`
property.

The most important camera properties are:

- `Class.Camera.CFrame|CFrame` which represents the position and orientation
  of the camera.

- `Class.Camera.CameraType|CameraType` which is read by the experience's
  camera scripts and determines how the camera should update each frame.

- `Class.Camera.CameraSubject|CameraSubject` which is read by the experience's
  camera scripts and determines what object the camera should follow.

- `Class.Camera.FieldOfView|FieldOfView` which represents the visible extent
  of the observable world.

- `Class.Camera.Focus|Focus` which represents the point the camera is looking
  at. It's important this property is set, as certain visuals will be more
  detailed and will update more frequently depending on how close they are to
  the focus point.

See [Customizing the Camera](../../../workspace/camera.md) for more
information on how to adjust and customize the camera's behavior.

#### Storing Multiple Cameras

Note that when changing `Class.Workspace.CurrentCamera` to a new
`Class.Camera`, all other `Class.Camera|Cameras` directly descending from
`Class.Workspace` will be destroyed. If you need to store multiple cameras and
swap between them on demand, it's recommended that you store them in a
`Class.Folder` or `Class.Model` under `Class.Workspace`, inside which they
will remain even when `Class.Workspace.CurrentCamera|CurrentCamera` is
changed.

## Inheritance

Inherits from: `PVInstance`

Class tags: `NotReplicated`

Memory category: `Instances`

## Properties

### `Camera.CameraSubject`

- **Type:** `Instance`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

The `Class.Humanoid` or `Class.BasePart` that is the `Class.Camera`
subject.

`CameraSubject` accepts a variety of `Class.Instance|Instances`. The
default camera scripts respond differently to the available settings:

- By default, the camera scripts follow the local character's
  `Class.Humanoid`, factoring in the humanoid's current state and
  `Class.Humanoid.CameraOffset`.

- When set to a `Class.BasePart`, the camera scripts follow its position,
  with a vertical offset in the case of `Class.VehicleSeat|VehicleSeats`.

`CameraSubject` cannot be set to `nil`. Attempting to do so will revert it
to its previous value.

To restore `CameraSubject` to its default value, set it to the local
character's `Class.Humanoid`:

```lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local function resetCameraSubject()
	if camera and localPlayer.Character then
		local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end
end
```

### `Camera.CameraType`

- **Type:** `CameraType`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Specifies the `Enum.CameraType` to be read by the camera scripts.

The default Roblox camera scripts have several built-in behaviors. Setting
this property toggles between the various `Enum.CameraType` behaviors.
Note that some camera types require a valid
`Class.Camera.CameraSubject|CameraSubject` to work correctly.

The default camera scripts will not move or update the camera if
`CameraType` is set to `Enum.CameraType.Scriptable`. For more information
on positioning and orienting the camera manually, see
`Class.Camera.CFrame|CFrame`.

For all `CameraType` settings **except** `Enum.CameraType.Scriptable`, the
`Class.Camera.CameraSubject|CameraSubject` property represents the object
whose position the camera's `Class.Camera.Focus|Focus` is set to.

### `Camera.CFrame`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

The `Datatype.CFrame` of the `Class.Camera`, defining its position and
orientation in the 3D world.

This property is the `Datatype.CFrame` of the `Class.Camera`, defining its
position and orientation in the 3D world. Note that some transformations,
such as the rotation of the head when using VR devices, are not reflected
in this property, so you should use
`Class.Camera:GetRenderCFrame()|GetRenderCFrame()` to obtain the "true"
`Datatype.CFrame` of the camera.

You can move the camera by setting this property. However, the default
camera scripts also set it, so you should either:

- Set the camera `Class.Camera.CameraType|CameraType` to
  `Enum.CameraType.Scriptable` so that the default camera scripts will not
  update the camera's `Datatype.CFrame`. This method is simplest and
  recommended in most cases.

- Completely replace the default camera scripts with alternatives. This
  approach is only recommended if you do not need any default camera
  functionality.

The most intuitive way to position and orient the `Class.Camera` is by
using the `Datatype.CFrame.lookAt()` constructor. In the following
example, the `Class.Camera` is positioned at
`Datatype.Vector3.new(0, 10, 0)` and is oriented to be looking towards
`Datatype.Vector3.new(10, 0, 0)`.

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable

local pos = Vector3.new(0, 10, 0)
local lookAtPos = Vector3.new(10, 0, 0)

Workspace.CurrentCamera.CFrame = CFrame.lookAt(pos, lookAtPos)
```

Although the camera can be placed in the manner demonstrated above, you
may want to animate it to move smoothly from one `Datatype.CFrame` to
another. For this, you can either:

- Set the camera's position/orientation every frame with
  `Class.RunService:BindToRenderStep()` and the `Datatype.CFrame:Lerp()`
  method.
- Create and play a `Class.Tween` that animates the position/orientation
  of the camera:

  ```lua
  local Players = game:GetService("Players")
  local TweenService = game:GetService("TweenService")
  local Workspace = game:GetService("Workspace")

  local camera = Workspace.CurrentCamera
  camera.CameraType = Enum.CameraType.Scriptable

  local player = Players.LocalPlayer
  local character = player.Character
  if not character or character.Parent == nil then
  	character = player.CharacterAdded:Wait()
  end

  local pos = camera.CFrame * Vector3.new(0, 20, 0)
  local lookAtPos = character.PrimaryPart.Position
  local targetCFrame = CFrame.lookAt(pos, lookAtPos)

  local tween = TweenService:Create(camera, TweenInfo.new(2), {CFrame = targetCFrame})

  tween:Play()
  ```

### `Camera.CoordinateFrame`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `Hidden`, `NotReplicated`, `Deprecated`
- **Capabilities:** `Basic`
- **Deprecated:** This item has been superseded by `Class.Camera.CFrame` which should be
used in all new work.

The old version of the `Class.Camera.CFrame|CFrame` property which
functions identically to it.

This item should be used in a `Class.LocalScript` in order to work as
expected online.

### `Camera.DiagonalFieldOfView`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

Sets the angle of the camera's diagonal field of view.

Sets how many degrees in the diagonal direction (from one corner of the
viewport to its opposite corner) the camera can view. See
`Class.Camera.FieldOfView|FieldOfView` for a more general explanation of
field of view.

Note that `DiagonalFieldOfView` represents the field of view that is
visible by the `Class.Camera` rendering into the fullscreen area which may
be occluded by notches or screen cutouts on some devices. See
`Class.Camera.ViewportSize|ViewportSize` for more information.

### `Camera.FieldOfView`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Sets the angle of the camera's vertical field of view.

The `FieldOfView` (FOV) property sets how many degrees in the vertical
direction the camera can view. This property is clamped between `1` and
`120` degrees and defaults at `70`. Very low or very high fields of view
are not recommended as they can be disorientating to players.

Note that uniform scaling is enforced, meaning the vertical and horizontal
field of view are always related by the aspect ratio of the screen.

Suggested uses for `FieldOfView` include:

- Reducing FOV to give the impression of magnification, for example when
  using binoculars.
- Increasing FOV when the player is "sprinting" to give the impression of
  a lack of control.

Note that `FieldOfView` represents the field of view that is visible by
the `Class.Camera` rendering into the fullscreen area which may be
occluded by notches or screen cutouts on some devices. See
`Class.Camera.ViewportSize|ViewportSize` for more information.

### `Camera.FieldOfViewMode`

- **Type:** `FieldOfViewMode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Determines the FOV value of the `Class.Camera` that's invariant under
viewport size changes.

The camera's `Class.Camera.FieldOfView|FieldOfView` (FOV) must be updated
to reflect `Class.Camera.ViewportSize|ViewportSize` changes. The value of
`FieldOfViewMode` determines which FOV value will be kept constant.

For example, when this property is set to `Enum.FieldOfViewMode.Vertical`,
the horizontal FOV is updated when the viewport is resized, but the
vertical FOV is kept constant. If this property is set to
`Enum.FieldOfViewMode.Diagonal`, both horizontal and vertical FOV might be
changed to keep the diagonal FOV constant.

### `Camera.Focus`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Sets the area in 3D space that is prioritized by Roblox's graphical
systems.

Certain graphical operations the engine performs, such as updating
lighting, can take time or computational effort to complete. The camera's
`Focus` property tells the engine which area in 3D space to prioritize
when performing such operations. For example, dynamic lighting from
objects such as `Class.PointLight|PointLights` may not render at distances
far from the focus.

The default Roblox camera scripts automatically set `Focus` to follow the
`Class.Camera.CameraSubject|CameraSubject` (usually a `Class.Humanoid`).
However, `Focus` will **not** automatically update when
`Class.Camera.CameraType|CameraType` is set to
`Enum.CameraType.Scriptable` or when the default camera scripts are not
being used. In these cases, you should update `Focus` every frame, using
`Class.RunService:BindToRenderStep()` method at the
`Enum.RenderPriority.Camera` priority.

`Focus` has no bearing on the position or orientation of the camera; see
`Class.Camera.CFrame|CFrame` for this.

### `Camera.focus`

- **Type:** `CFrame`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`, `Deprecated`
- **Capabilities:** `Basic`
- **Deprecated:** This property is a deprecated variant of `Class.Camera.Focus|Focus` which
should be used instead.

### `Camera.HeadLocked`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Toggles whether the camera will automatically track the head motion of a
player using a VR device.

Toggles whether the camera will automatically track the head motion of a
player using a VR device. When `true` (default), the engine combines
`Class.Camera.CFrame|CFrame` with the `Enum.UserCFrame` of the user's head
to render the player's view with head tracking factored in. The view will
be rendered at the following `Datatype.CFrame`:

```lua
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local headCFrame = UserInputService:GetUserCFrame(Enum.UserCFrame.Head)
headCFrame = headCFrame.Rotation + headCFrame.Position * camera.HeadScale

-- This will be equivalent to Camera:GetRenderCFrame()
local renderCFrame = camera.CFrame * headCFrame
```

It is recommended to **not** disable this property for the following
reasons:

- Players may experience motion sickness if an equivalent head tracking
  solution is not added.
- The Roblox Engine performs latency optimizations when `HeadLocked` is
  true.

##### See Also

- `Class.VRService:GetUserCFrame()` which can be used to obtain the
  `Datatype.CFrame` of the head.
- `Class.VRService:RecenterUserHeadCFrame()` which is used to recenter the
  head to the current position and orientation of the VR device.
- The `Class.Camera:GetRenderCFrame()|GetRenderCFrame()` method which
  returns the `Class.Camera.CFrame|CFrame` combined with the
  `Datatype.CFrame` of the user's head.

### `Camera.HeadScale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Sets the scale of the user's perspective of the world when using VR.

`HeadScale` is the scale of the user's perspective of the world when using
VR.

The size of 1 stud in VR is `0.3 meters / HeadScale`, meaning that larger
`HeadScale` values equate to the world looking smaller from the user's
perspective when using VR devices. For example, a part that's 1 stud tall
appears to be 0.6 meters tall to a VR player with a `HeadScale` of `0.5`.

This property is automatically controlled by
`Class.VRService.AutomaticScaling` to align the player's perspective with
the size of their avatar. If you intend to control `HeadScale` yourself or
use custom characters, toggle `Class.VRService.AutomaticScaling` to
`Enum.VRScaling.Off`.

This property should not be confused with `Class.Humanoid.HeadScale` which
is a `Class.NumberValue` parented to a `Class.Humanoid` to control its
scaling.

### `Camera.MaxAxisFieldOfView`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `NotReplicated`
- **Capabilities:** `Basic`

Sets the angle of the camera's field of view along the longest viewport
axis.

The `MaxAxisFieldOfView` property sets how many degrees along the longest
viewport axis the camera can view.

When the longest axis is the vertical axis, this property will behave
similar to the `Class.Camera.FieldOfView|FieldOfView` property. This is
generally the case when a device is in a portrait orientation. In a
landscape orientation, the longest axis will be the horizontal axis; in
this case, the property describes the horizontal field of view of the
`Class.Camera`.

### `Camera.NearPlaneZ`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Basic`

Describes the negative **Z** offset, in studs, of the camera's near
clipping plane.

The `NearPlaneZ` property describes how far away the camera's near
clipping plane is, in studs. The near clipping plane is a geometric plane
that sits in front of the camera's `Class.Camera.CFrame|CFrame`. Anything
between this plane and the camera will not render, creating a cutaway view
when viewing objects at very short distances. The value of `NearPlaneZ`
varies across different platforms and is currently always between `-0.1`
and `-0.5`.

<img src="/assets/engine-api/classes/Camera/NearPlaneZ.jpg" width="720" alt="Diagram showing how the NearPlaneZ clips (does not render) 3D content between the plane and the camera." />

### `Camera.ViewportSize`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Tags:** `ReadOnly`, `NotReplicated`
- **Capabilities:** `Basic`

The dimensions of the device safe area on a Roblox client.

`ViewportSize` returns the dimensions of the device safe area on the
current screen. This area is a rectangle which includes the Roblox top bar
area but does not include any device notches or screen cutouts. The units
of `ViewportSize` are Roblox UI offset units which may be different from
native display pixels.

<img src="../../../assets/engine-api/classes/Camera/DeviceSafeAreaVsFullscreen.png" width="840" alt="Mobile device screen with cutout showing device safe area." />

As noted above, `ViewportSize` is not equal to the fullscreen area size on
displays with cutouts or notches. To obtain the fullscreen area size on
all displays, you can query the
`Class.ScreenGui.AbsoluteSize|AbsoluteSize` property of a
`Class.ScreenGui` with `Class.ScreenGui.ScreenInsets|ScreenInsets` set to
`Enum.ScreenInsets.None|None`. See `Enum.ScreenInsets` for a more
information about how screen areas are defined.

Finally, note that `ViewportSize` is not the actual viewport size the
camera uses for rendering (the camera renders in the fullscreen area).
Also, the `Class.Camera.FieldOfView|FieldOfView` and
`Class.Camera.DiagonalFieldOfView|DiagonalFieldOfView` properties are
based on the fullscreen area, not `ViewportSize`.

##### Camera Updates

Only the `Class.Camera` currently referred to by
`Class.Workspace.CurrentCamera` has its `ViewportSize` updated each frame
during the `Class.RunService.PreRender|PreRender` step. The `ViewportSize`
of all other cameras in your experience won't be updated, including those
used for `Class.ViewportFrame|ViewportFrames`.

### `Camera.VRTiltAndRollEnabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `Basic`

Toggles whether to apply tilt and roll from the
`Class.Camera.CFrame|CFrame` property while the player is using a VR
device.

This property toggles whether to apply tilt and roll from the
`Class.Camera.CFrame|CFrame` property while the player is using a VR
device.

To prevent motion sickness, the horizon should remain level. Tilting and
rolling the player's view while using a VR device can cause a disconnect
between the player's physical space and the virtual space they are
viewing. Changing the apparent downwards direction can cause players to
lose balance or experience dizziness.

For these reasons, it is generally advisable to leave this property
disabled, unless you have extensively tested your experience for these
effects. Even with tilt and roll enabled, you may want to ensure the
player always has a stable reference frame, such as the interior of a
vehicle or a floor that can help the player ground themselves in their
physical space.

## Methods

### `Camera:GetLargestCutoffDistance`

```
GetLargestCutoffDistance(ignoreList: Instances) -> float
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic`

Returns how much the `Class.Camera` needs to be pushed towards its
`Class.Camera.Focus|Focus` in order to make sure there is no obstructions
between the `Class.Camera.Focus|Focus` and `Class.Camera.CFrame|CFrame`.

This method is used by `PopperCam` in the default camera scripts to ensure
obstructions do not come between the `Class.Camera` and its subject.

This method will check all `Class.BasePart|BaseParts` and `Class.Terrain`
in the `Class.Workspace` with the following exceptions:

- Any `Class.Instance` specified in the `ignoreList` (including its
  descendants) will be ignored
- `Class.BasePart|BaseParts` with `Class.BasePart.CanCollide` set to false
  are ignored
- `Class.BasePart|BaseParts` with a `Class.BasePart.Transparency` greater
  than 0.95 will be ignored Water `Class.Terrain` is ignored

Note, as this method requires an `ignoreList` to run, you should pass an
empty table when none is required.

**Parameters:**

- `ignoreList` : `Instances` --- An array of `Class.Instance|Instances` to ignore. Descendants of these instances will also be ignored.

**Returns:**

- `float` --- The distance, in studs, that the `Class.Camera` needs to be pushed towards its `Class.Camera.Focus|Focus` to ensure there are no obstructions between the `Class.Camera.Focus|Focus` and `Class.Camera.CFrame|CFrame` of the `Class.Camera`.

### `Camera:GetPanSpeed`

```
GetPanSpeed() -> float
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method has been deprecated and no longer works. It should not be used
in new work.

Returns the current 'pan' speed of the `Class.Camera`.

This method is broken and should not be used.

This method returns the current pan speed of the `Class.Camera`.

The pan speed of the `Class.Camera` describes the speed at which the
`Class.Camera` is rotating around its `Class.Camera.Focus|Focus` around
the **Y** axis.

**Returns:**

- `float` --- The speed at which the `Class.Camera` is rotating around its `Class.Camera.Focus|Focus` on the **Y** axis.

### `Camera:GetPartsObscuringTarget`

```
GetPartsObscuringTarget(castPoints: Array, ignoreList: Instances) -> Instances
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Returns an array of `Class.BasePart|BaseParts` that are obscuring the
lines of sight between the camera's `Class.Camera.CFrame|CFrame` and the
cast points.

This method returns an array of `Class.BasePart|BaseParts` that are
obscuring the lines of sight between the camera's
`Class.Camera.CFrame|CFrame` and `Datatype.Vector3` positions in the
`castPoints` array. Any `Class.Instance|Instances` included in the
`ignoreList` array will be ignored, along with their descendants.

The `castPoints` parameter is given as an array of `Datatype.Vector3`
positions. Note that the array of `Class.BasePart|BaseParts` returned is
in an arbitrary order, and no additional raycast data is provided. If you
need data such as hit position, hit material, or surface normal, you
should opt for the `Class.WorldRoot:Raycast()` method.

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local castPoints = {
	Vector3.new(0, 10, 0),
	Vector3.new(0, 15, 0)
}
local ignoreList = {}

local partsObscuringTarget = camera:GetPartsObscuringTarget(castPoints, ignoreList)
```

If `Class.Terrain` obscures a cast point, `Class.BasePart|BaseParts`
obscuring the cast point between the obscuring `Class.Terrain` and the
cast point will not be returned.

**Parameters:**

- `castPoints` : `Array` --- An array of `Datatype.Vector3` positions of cast points.
- `ignoreList` : `Instances` --- An array of `Class.Instance|Instances` that should be ignored, along with their descendants.

**Returns:**

- `Instances` --- An array of `Class.BasePart|BaseParts` that obscure the lines of sight between the camera's `Class.Camera.CFrame|CFrame` and the `castPoints`.

### `Camera:GetRenderCFrame`

```
GetRenderCFrame() -> CFrame
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Returns the actual `Datatype.CFrame`where the `Class.Camera` is being
rendered, accounting for any roll applied and the impact of VR devices.

This method returns the actual `Datatype.CFrame` of the `Class.Camera` as
it is rendered, including the impact of VR (VR head transformations are
not applied to the `Class.Camera.CFrame|CFrame` property, so it is best
practice to use `Class.Camera:GetRenderCFrame()|GetRenderCFrame()` to
obtain the "true" `Datatype.CFrame` of a player's view).

For example, when using VR, the `Class.Camera` is actually rendered at the
following `Datatype.CFrame`:

```lua
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local headCFrame = UserInputService:GetUserCFrame(Enum.UserCFrame.Head)
headCFrame = headCFrame.Rotation + headCFrame.Position * camera.HeadScale
renderCFrame = camera.CFrame * headCFrame
```

The camera's render `Datatype.CFrame` will only be changed to account for
the head when the `Class.Camera.HeadLocked|HeadLocked` property is true.

**Returns:**

- `CFrame` --- The `Datatype.CFrame` the `Class.Camera` is being rendered at.

### `Camera:GetRoll`

```
GetRoll() -> float
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic` ; **Deprecated:** This method has been deprecated.

Returns in radians the current roll, or rotation around the camera's
Z-axis, applied to the `Class.Camera` using
`Class.Camera:SetRoll()|SetRoll()`.

This method returns, in radians, the current roll applied to the
`Class.Camera` using `Class.Camera:SetRoll()|SetRoll()`. Roll is defined
as rotation around the camera's Z-axis.

This method only returns roll applied using the
`Class.Camera:SetRoll()|SetRoll()` method. Roll manually applied to the
camera's `Class.Camera.CFrame|CFrame` is not accounted for. To obtain the
actual roll of the `Class.Camera`, including roll manually applied, you
can use the following snippet:

```lua
local Workspace = game:GetService("Workspace")

local function getActualRoll()
	local camera = Workspace.CurrentCamera

	local trueUp = Vector3.new(0, 1, 0)
	local cameraUp = camera:GetRenderCFrame().upVector

	return math.acos(trueUp:Dot(cameraUp))
end
```

**Returns:**

- `float` --- The current roll applied by `Class.Camera:SetRoll()|SetRoll()`, in radians.

### `Camera:GetTiltSpeed`

```
GetTiltSpeed() -> float
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method has been deprecated and no longer works.

Returns the current tilt speed of the `Class.Camera`.

This method is broken and should not be used.

This method returns the current tilt speed of the `Class.Camera`.

The tilt speed of the `Class.Camera` describes the speed at which the
`Class.Camera` is rotating around its `Class.Camera.Focus|Focus` around
the camera's **X** axis.

**Returns:**

- `float` --- The speed at which the `Class.Camera` is rotating around its `Class.Camera.Focus|Focus` around the camera's **X** axis.

### `Camera:Interpolate`

```
Interpolate(endPos: CFrame, endFocus: CFrame, duration: float) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method has been deprecated. Instead use `Class.TweenService` to
smoothly animate the `Class.Camera`, see the code snippets below for an
example.

Tweens the `Class.Camera` in a linear fashion towards a new
`Class.Camera.CFrame|CFrame` and `Class.Camera.Focus|Focus` over a given
duration.

This method tweens the `Class.Camera` in a linear fashion towards a new
`Class.Camera.CFrame|CFrame` and `Class.Camera.Focus|Focus` over a given
duration, for example:

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable

camera:Interpolate(
	CFrame.new(0, 10, 100),
	CFrame.new(0, 0, 100),
	5
)
```

Throughout the tween, the camera's `Class.Camera.CFrame|CFrame` will be
orientated towards the camera's `Class.Camera.Focus|Focus`.

When the tween has completed, the camera's
`Class.Camera.InterpolationFinished|InterpolationFinished` event will
fire.

If this method is called while the `Class.Camera` is already tweening, the
older tween will be stopped (without firing
`Class.Camera.InterpolationFinished|InterpolationFinished`) and overridden
by the new tween.

Interpolate can only be used if the current
`Class.Camera.CameraType|CameraType` is `Scriptable`, regardless of
whether the default camera scripts are being used. If it is used with any
other `Class.Camera.CameraType|CameraType` an error will be thrown.

You are advised to use `Class.TweenService` to tween the `Class.Camera`
instead as it is more reliable and offers a variety of easing styles. See
below for an example:

```lua
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable

local tween = TweenService:Create(
	camera,
	TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{
		CFrame = CFrame.new(0, 10, 100),
		Focus = CFrame.new(0, 0, 100)
	}
)

tween:Play()
```

**Parameters:**

- `endPos` : `CFrame` --- The `Datatype.CFrame` for the `Class.Camera` to tween to.
- `endFocus` : `CFrame` --- The `Datatype.CFrame` for the camera's `Class.Camera.Focus|Focus` to tween to.
- `duration` : `float` --- The duration, in seconds, of the tween.

**Returns:**

- `()` --- 

### `Camera:PanUnits`

```
PanUnits(units: int) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method was used for legacy camera controls and has since been
deprecated. Do not use in new work.

Pans the `Class.Camera` around the `Class.Camera.Focus|Focus` in 45 degree
increments around the **Y** axis.

This method pans the `Class.Camera` around the `Class.Camera.Focus|Focus`
in 45 degree increments around the **Y** axis.

The rotation is applied to the camera's `Class.Camera.CFrame|CFrame`
property.

This method pans the `Class.Camera` in 45 degree increments, for example:

```lua
local Workspace = game:GetService("Workspace")

Workspace.CurrentCamera:PanUnits(1) -- 45 degrees
Workspace.CurrentCamera:PanUnits(-2) -- -90 degrees
```

PanUnits does not require the `Class.Camera.CameraType|CameraType` to be
`Scriptable`.

**Parameters:**

- `units` : `int` --- The number of 45 degree increments by which to pan the `Class.Camera`.

**Returns:**

- `()` --- 

### `Camera:ScreenPointToRay`

```
ScreenPointToRay(x: float, y: float, depth: float = 0) -> Ray
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Creates a unit `Datatype.Ray` from a position on the screen (in pixels),
at a set depth from the `Class.Camera` orientated in the camera's
direction. Accounts for the GUI inset.

This method creates a unit `Datatype.Ray` from a 2D position on the screen
(defined in pixels), accounting for the GUI inset. The `Datatype.Ray`
originates from the `Datatype.Vector3` equivalent of the 2D position in
the world at the given depth (in studs) away from the `Class.Camera`.

As this method acknowledges the GUI inset, the offset applied to GUI
elements (such as from the top bar) is accounted for. This means the
screen position specified will start in the top left corner below the top
bar. For an otherwise identical method that does not account for the GUI
offset, use `Class.Camera:ViewportPointToRay()|ViewportPointToRay()`.

As the `Datatype.Ray` created is a unit ray, it is only one stud long. To
create a longer ray, you can do the following:

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera
local length = 500
local unitRay = camera:ScreenPointToRay(100, 100)
local extendedRay = Ray.new(unitRay.Origin, unitRay.Direction * length)
```

This method only works for the current `Class.Workspace` camera. Other
cameras, such as those you create for a `Class.ViewportFrame`, have an
initial viewport size of <Typography noWrap>`(1, 1)`</Typography> and are
only updated after you set them to `Class.Workspace.CurrentCamera`. The
mismatch in viewport size causes the camera to return a ray with an
incorrect `Datatype.Ray.Direction`.

**Parameters:**

- `x` : `float` --- The position on the **X** axis, in pixels, of the screen point at which to originate the `Datatype.Ray`. This position accounts for the GUI inset.
- `y` : `float` --- The position on the **Y** axis, in pixels, of the screen point at which to originate the `Datatype.Ray`. This position accounts for the GUI inset.
- `depth` : `float` (default `0`) --- The depth from the `Class.Camera`, in studs, from which to offset the origin of the `Datatype.Ray`.

**Returns:**

- `Ray` --- A unit `Datatype.Ray`, originating from the equivalent `Datatype.Vector3` world position of the given screen coordinates at the given depth away from the `Class.Camera`. This ray is orientated in the direction of the `Class.Camera`.

### `Camera:SetCameraPanMode`

```
SetCameraPanMode(mode: CameraPanMode = Classic) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method has been deprecated and should not be used in new work.

Sets the `Enum.CameraPanMode` to be used by the `Class.Camera` on mobile
devices.

This method sets the `Enum.CameraPanMode` to be used by the `Class.Camera`
on mobile devices.

When the \*'EdgeBump' `Enum.CameraPanMode` is used, swipe to pan is
disabled and the edge bump camera controls are enabled.

SetCameraPan mode has no effect on Windows or Mac users.

**Parameters:**

- `mode` : `CameraPanMode` (default `Classic`) --- The `Enum.CameraPanMode` to set the `Class.Camera` to.

**Returns:**

- `()` --- 

### `Camera:SetRoll`

```
SetRoll(rollAngle: float) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic` ; **Deprecated:** This method has been deprecated. Instead use the
`Class.Camera.CFrame|CFrame` property to 'roll' the `Class.Camera`.

Sets the current rotation applied around the camera's Z-axis.

This method is outdated and no longer considered best practice.

This method sets the current roll, in radians, of the `Class.Camera`. The
roll is applied after the `Class.Camera.CFrame|CFrame` and represents the
rotation around the camera's Z-axis.

For example, the following would invert the `Class.Camera`:

```lua
local Workspace = game:GetService("Workspace")

Workspace.CurrentCamera:SetRoll(math.pi) -- math.pi radians = 180 degrees
```

SetRoll has no effect on any roll applied using the
`Class.Camera.CFrame|CFrame` property. Roll applied using SetRoll is not
reflected in the `Class.Camera.CFrame|CFrame` property but is reflected in
the `Datatype.CFrame` returned
by`Class.Camera:GetRenderCFrame()|GetRenderCFrame()`.

This method can only be used when the `Class.Camera.CameraType|CameraType`
is set to `Scriptable`, regardless of whether the default camera scripts
are being used. If it is used with any other
`Class.Camera.CameraType|CameraType` a warning is given in the output.

Any roll applied using this method will be lost when the
`Class.Camera.CameraType|CameraType` is changed from `Scriptable`.

To obtain the roll set using this method use
`Class.Camera:GetRoll()|GetRoll()`.

As this method is outdated, you are advised to instead apply roll to the
`Class.Camera` using the `Class.Camera.CFrame|CFrame` property. For
example:

```lua
local Workspace = game:GetService("Workspace")

local currentCFrame = Workspace.CurrentCamera.CFrame
local rollCFrame = CFrame.Angles(0, 0, roll)
Workspace.CurrentCamera.CFrame = currentCFrame * rollCFrame
```

**Parameters:**

- `rollAngle` : `float` --- The roll angle, in radians, to be applied to the `Class.Camera`.

**Returns:**

- `()` --- 

### `Camera:TiltUnits`

```
TiltUnits(units: int) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Deprecated` ; capabilities=`Basic` ; **Deprecated:** This method was used for legacy camera controls and has been deprecated.
Do not use in new work.

Tilts the `Class.Camera` around its `Class.Camera.Focus|Focus` in 10
degree increments around the camera's **X** axis.

This method tilts the `Class.Camera` by rotating it around the
`Class.Camera.Focus|Focus` around the camera's **X** axis by a given
multiple of 10 degrees.

The rotation is applied to the camera's `Class.Camera.CFrame|CFrame`
property and is constrained between `-81.05` and `81.05` degrees.

**Parameters:**

- `units` : `int` --- The number of 10 degree units by which to tilt the `Class.Camera`.

**Returns:**

- `boolean` --- Whether the `Class.Camera` tilt applied was constrained.

### `Camera:ViewportPointToRay`

```
ViewportPointToRay(x: float, y: float, depth: float = 0) -> Ray
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Creates a unit `Datatype.Ray` from a position on the viewport (in pixels),
at a given depth from the `Class.Camera`, orientated in the camera's
direction. Does not account for the `Enum.ScreenInsets|CoreUISafeInsets`
inset.

This method creates a unit `Datatype.Ray` from a 2D position in device
safe viewport coordinates, defined in pixels. The ray originates from the
`Datatype.Vector3` equivalent of the 2D position in the world at the given
depth (in studs) away from the `Class.Camera`.

As illustrated below, `(0, 0)` corresponds to the top‑left point of the
Roblox top bar. This means that the input 2D position does **not** account
for the `Enum.ScreenInsets|CoreUISafeInsets` inset, but it does account
for any `Enum.ScreenInsets|DeviceSafeInsets`.

<img src="../../../assets/engine-api/classes/Camera/ViewportPointToRayOrigin.png" width="840" alt="Diagram showing the origin of the device safe area viewport coordinate system." />

Note that UI instances use a different coordinate system
(`Class.GuiObject.AbsolutePosition` uses the
`Enum.ScreenInsets|CoreUISafeInsets` viewport coordinate system while this
method uses the `Enum.ScreenInsets|DeviceSafeInsets` viewport coordinate
system). If you would like to specify position in core UI coordinates,
please use `Class.Camera:ScreenPointToRay()|ScreenPointToRay()`.

Also note that this method only works for the
`Class.Workspace.CurrentCamera` camera. Other cameras, such as those you
create for a `Class.ViewportFrame`, have an initial viewport size of
`(1, 1)` and are only updated after you set them to
`Class.Workspace.CurrentCamera|CurrentCamera`. The mismatch in viewport
size causes the camera to return a ray with an incorrect
`Datatype.Ray.Direction`.

This method can be used in conjunction with the
`Class.Camera.ViewportSize|ViewportSize` property to create a ray from the
centre of the screen, for example:

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local viewportPoint = camera.ViewportSize / 2
local unitRay = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y, 0)
```

As the `Datatype.Ray` created is a unit ray, it is only one stud long. To
create a longer ray, you can do the following:

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local length = 500
local unitRay = camera:ScreenPointToRay(100, 100)
local extendedRay = Ray.new(unitRay.Origin, unitRay.Direction * length)
```

**Parameters:**

- `x` : `float` --- The position on the **X** axis, in pixels, of the viewport point at which to originate the `Datatype.Ray`, in device safe area coordinates.
- `y` : `float` --- The position on the **Y** axis, in pixels, of the viewport point at which to originate the `Datatype.Ray`, in device safe area coordinates.
- `depth` : `float` (default `0`) --- The depth from the `Class.Camera`, in studs, from which to offset the origin of the `Datatype.Ray`.

**Returns:**

- `Ray` --- A unit `Datatype.Ray`, originating from the equivalent `Datatype.Vector3` world position of the given viewport coordinates at the given depth away from the `Class.Camera`. This ray is orientated in the direction of the `Class.Camera`.

### `Camera:WorldToScreenPoint`

```
WorldToScreenPoint(worldPoint: Vector3) -> Tuple
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Returns the screen location and depth of a `Datatype.Vector3` `worldPoint`
and whether this point is within the bounds of the screen. Accounts for
the GUI inset.

This method returns the screen location and depth of a `Datatype.Vector3`
`worldPoint` and whether this point is within the bounds of the screen.

This method takes in account the current GUI inset, such as the space
occupied by the top bar, meaning that the 2D position returned is in the
same term as GUI positions and can be used to place GUI elements. For an
otherwise identical method that ignores the GUI inset, see
`Class.Camera:WorldToViewportPoint()|WorldToViewportPoint()`.

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local worldPoint = Vector3.new(0, 10, 0)
local vector, onScreen = camera:WorldToScreenPoint(worldPoint)

local screenPoint = Vector2.new(vector.X, vector.Y)
local depth = vector.Z
```

Note this method does not perform any raycasting and the boolean
indicating whether `worldPoint` is within the bounds of the screen will be
`true` regardless of whether the point is obscured by
`Class.BasePart|BaseParts` or `Class.Terrain`.

**Parameters:**

- `worldPoint` : `Vector3` --- The `Datatype.Vector3` world position.

**Returns:**

- `Tuple` --- A tuple containing, in order:  - A `Datatype.Vector3` whose **X** and **Y** components represent the   offset of the `worldPoint` from the top left corner of the screen,   in pixels. The `Datatype.Vector3` **Z** component represents the   depth of the `worldPoint` from the screen (in studs).  - A boolean indicating if the `worldPoint` is within the bounds of the   screen.

### `Camera:WorldToViewportPoint`

```
WorldToViewportPoint(worldPoint: Vector3) -> Tuple
```

- security=`None` ; thread-safety=`Safe` ; capabilities=`Basic`

Returns the screen location and depth of a `Datatype.Vector3` `worldPoint`
and whether this point is within the bounds of the screen. Does not
account for the GUI inset.

This method returns the screen location and depth of a `Datatype.Vector3`
`worldPoint` and whether this point is within the bounds of the screen.

This method does not take in account the current GUI inset, such as the
space occupied by the top bar, meaning that the 2D position returned is
taken from the top left corner of the viewport. Unless you are using
`Class.ScreenGui.IgnoreGuiInset`, this position is not appropriate for
placing GUI elements.

For an otherwise identical method that accounts for the GUI inset, see
`Class.Camera:WorldToScreenPoint()|WorldToScreenPoint()`.

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local worldPoint = Vector3.new(0, 10, 0)
local vector, onScreen = camera:WorldToViewportPoint(worldPoint)

local viewportPoint = Vector2.new(vector.X, vector.Y)
local depth = vector.Z
```

Note this method does not perform any raycasting and the boolean
indicating whether `worldPoint` is within the bounds of the screen will be
`true` regardless of whether the point is obscured by
`Class.BasePart|BaseParts` or `Class.Terrain`.

**Parameters:**

- `worldPoint` : `Vector3` --- The `Datatype.Vector3` world position.

**Returns:**

- `Tuple` --- A tuple containing, in order:  - A `Datatype.Vector3` whose **X** and **Y** components represent the   offset of the `worldPoint` from the top left corner of the viewport,   in pixels. The `Datatype.Vector3` **Z** component represents the   depth of the `worldPoint` from the screen (in studs).  - A boolean indicating if the `worldPoint` is within the bounds of the   screen.

### `Camera:ZoomToExtents`

```
ZoomToExtents(boundingBoxCFrame: CFrame, boundingBoxSize: Vector3) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`Basic`

Adjusts the `Class.Camera.CFrame|CFrame` so that the specified bounding
box is fully visible within the camera's viewport.

This method adjusts the `Class.Camera.CFrame|CFrame` so that a specified
bounding box is fully visible within the camera's viewport, without
cropping any part of the box.

The bounding box is defined by its center and orientation
(`boundingBoxCFrame`) and its size (`boundingBoxSize`).

This can be used to focus the camera on a 3D object or model, such as when
framing content in a `Class.ViewportFrame`, taking screenshots, or
smoothly transitioning the camera to highlight specific content.

The method automatically accounts for the camera's field of view and
viewport aspect ratio to ensure the entire bounding box fits.

```lua
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera
local model = Workspace:FindFirstChild("MyModel")

if model then
	local modelCFrame = model:GetModelCFrame()
	local extentsSize = model:GetExtentsSize()
	camera:ZoomToExtents(modelCFrame, extentsSize)
end
```

**Parameters:**

- `boundingBoxCFrame` : `CFrame` --- The `Datatype.CFrame` representing the center and orientation of the bounding box to fit into the viewport.
- `boundingBoxSize` : `Vector3` --- The `Datatype.Vector3` size of the bounding box to fit into the viewport.

**Returns:**

- `()` --- 

## Events

### `Camera.InterpolationFinished`

```
InterpolationFinished()
```

- security=`None` ; capabilities=`Basic` ; **Deprecated:** This event has been deprecated. Instead use `Class.TweenService` to
smoothly animate the `Class.Camera`.

Fired when the `Class.Camera` has finished interpolating
using`Class.Camera:Interpolate()|Interpolate()`.

This event fires when the `Class.Camera` has finished interpolating using
the `Class.Camera:Interpolate()` method. It will not fire if a tween is
interrupted due to `Class.Camera:Interpolate()` being called again.

You are advised to use `Class.TweenService` to animate the `Class.Camera`
instead, as it is more reliable and provides more options for easing
styles.

## Notes / Deprecations

- Deprecated property `Camera.CoordinateFrame`: This item has been superseded by `Class.Camera.CFrame` which should be
used in all new work.
- Deprecated property `Camera.focus`: This property is a deprecated variant of `Class.Camera.Focus|Focus` which
should be used instead.
- Deprecated method `Camera:GetPanSpeed`: This method has been deprecated and no longer works. It should not be used
in new work.
- Deprecated method `Camera:GetRoll`: This method has been deprecated.
- Deprecated method `Camera:GetTiltSpeed`: This method has been deprecated and no longer works.
- Deprecated method `Camera:Interpolate`: This method has been deprecated. Instead use `Class.TweenService` to
smoothly animate the `Class.Camera`, see the code snippets below for an
example.
- Deprecated method `Camera:PanUnits`: This method was used for legacy camera controls and has since been
deprecated. Do not use in new work.
- Deprecated method `Camera:SetCameraPanMode`: This method has been deprecated and should not be used in new work.
- Deprecated method `Camera:SetRoll`: This method has been deprecated. Instead use the
`Class.Camera.CFrame|CFrame` property to 'roll' the `Class.Camera`.
- Deprecated method `Camera:TiltUnits`: This method was used for legacy camera controls and has been deprecated.
Do not use in new work.
- Deprecated event `Camera.InterpolationFinished`: This event has been deprecated. Instead use `Class.TweenService` to
smoothly animate the `Class.Camera`.
- Property `Camera.CameraSubject` security: `read=None, write=None`
- Property `Camera.CameraType` security: `read=None, write=None`
- Property `Camera.CFrame` security: `read=None, write=None`
- Property `Camera.CoordinateFrame` security: `read=None, write=None`
- Property `Camera.DiagonalFieldOfView` security: `read=None, write=None`
- Property `Camera.FieldOfView` security: `read=None, write=None`
- Property `Camera.FieldOfViewMode` security: `read=None, write=None`
- Property `Camera.Focus` security: `read=None, write=None`
- Property `Camera.focus` security: `read=None, write=None`
- Property `Camera.HeadLocked` security: `read=None, write=None`
- Property `Camera.HeadScale` security: `read=None, write=None`
- Property `Camera.MaxAxisFieldOfView` security: `read=None, write=None`
- Property `Camera.NearPlaneZ` security: `read=None, write=None`
- Property `Camera.ViewportSize` security: `read=None, write=None`
- Property `Camera.VRTiltAndRollEnabled` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- Camera:GetRoll: Camera-GetRoll1

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Camera
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Camera.yaml
- Captured: 2026-04-16
