---
title: Create Interactive UI
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/ui/interactive-ui
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, ui, imagebutton, uidragdetector, modulescript, tweenservice, uilistlayout, uiaspectratioconstraint]
difficulty: intermediate
---

# Create Interactive UI

Almost every experience requires **interactive** UI such as buttons that respond to player activation, animate when activated, tween in/out menus with other interactive controls, etc. This tutorial demonstrates:

- Positioning a settings button along the top screen edge
- Designing a settings menu containing interactive draggable sliders
- Using `ModuleScripts` to form "controller" modules for extensible UI control
- Connecting buttons to player activation to toggle the settings menu
- Connecting draggable UI sliders to adjust volume independently

## Steps

### Create the settings button

`GuiButton` objects are interactive user interface elements with built-in functionality such as the multi-platform `Activated` event. `GuiButton` extends to `TextButton` and `ImageButton`.

1. Insert an `ImageButton` into **HUDContainer** and rename to **SettingsButton**.
2. Set:
   - `AnchorPoint` = `0.5, 0.25`
   - `BackgroundTransparency` = `1`
   - `Position` = `0.5, 0, 0, 0`
   - `Size` = `0.1, 0, 0.1, 0`
   - `Image` = `rbxassetid://104919049969988`
3. Insert a `UIAspectRatioConstraint` (default 1:1).
4. Insert a `UISizeConstraint` with `MaxSize = inf, 44`.

### Create the settings menu

1. Insert a `Frame` into **HUDContainer** named **SettingsMenu**.
2. Set:
   - `AnchorPoint` = `0.5`
   - `BackgroundColor3` = `30, 30, 60`
   - `BackgroundTransparency` = `0.25`
   - `Position` = `0.5, 0, 0.5, 0`
   - `Size` = `0.75, 0, 0.75, 0`
3. Insert a `UIAspectRatioConstraint` with `AspectRatio = 2.5`.
4. Insert a `UICorner` with `CornerRadius = 0.1, 0`.
5. Insert a `UISizeConstraint` with `MaxSize = 800, inf`, `MinSize = 350, 0`.

### Construct a slider

Use `UIDragDetector` for interactive drag controls.

1. Insert a Frame named **EffectsVolumeSlider** into **SettingsMenu**.
2. Insert a `UIListLayout` with:
   - `Padding` = `0.06, 0`
   - `FillDirection` = `Horizontal`
   - `HorizontalFlex` = `Fill`
   - `VerticalAlignment` = `Center`

**Slider icon:**
- Insert `ImageLabel` named **Icon**, set `Image`, `UIAspectRatioConstraint`.

**Range frame:**
- Insert `Frame` named **SliderFrame** as sibling to icon.
- Set `LayoutOrder = 1`, `Size = 1, 0, 1, 0`, background transparent.
- Add `UICorner` (`CornerRadius = 0.5, 0`) for pill shape.
- Add `UISizeConstraint` (`MaxSize = inf, 30`).
- Add `UIStroke` for outline.

**Interactive handle:**
- Insert `Frame` named **Handle** into SliderFrame.
- Set `AnchorPoint = 0.5`, `Position = 0.5, 0, 0.5, 0`, `Size = 1.2, 0, 1.2, 0`.
- Insert `UIAspectRatioConstraint`, `UICorner` (circular), `UIStroke` (blue).
- Insert a `UIDragDetector` with:
  - `DragStyle` = `TranslateLine`
  - `ResponseStyle` = `Scale`
  - Link `BoundingUI` to SliderFrame

**Inner fill:**
- Insert `Frame` named **InnerFill** into SliderFrame with background color matching handle.

### Create control modules

**StatefulObjectController** ModuleScript in ReplicatedStorage:

```lua
local TweenService = game:GetService("TweenService")

local StatefulObjectController = {}
StatefulObjectController.__index = StatefulObjectController

export type StateName = string
export type State = {
    transition: TweenInfo,
    properties: { [string]: any },
}

function StatefulObjectController.hydrate(props: {
        object: Instance,
        states: { [StateName]: State },
        initialStateName: StateName
    })
    local object, states, initialStateName = props.object, props.states, props.initialStateName

    local self = setmetatable({
        states = states,
        currentStateName = initialStateName,
        tweens = {},
    }, StatefulObjectController)

    for stateName, state in states do
        self.tweens[stateName] = TweenService:Create(object, state.transition, state.properties)
    end

    self:setState(self.currentStateName)
    return self
end

function StatefulObjectController:setState(stateName: StateName)
    local stateTween: Tween = self.tweens[stateName]
    if not stateTween then
        warn(string.format("Attempted to set %s to unknown state '%s'", self.object:GetFullName(), stateName))
        return
    end

    self.currentStateName = stateName

    for _, tween in self.tweens do
        tween:Cancel()
    end

    stateTween:Play()
end

return StatefulObjectController
```

**SliderController** ModuleScript:

```lua
local SliderController = {}
SliderController.__index = SliderController

export type Value = number
export type OnChanged = (Value) -> ()

function SliderController.hydrate(props: {
        object: Instance,
        onChanged: OnChanged,
        initialValue: Value?
    })
    local object, onChanged, initialValue = props.object, props.onChanged, props.initialValue

    local handle = object:FindFirstChild("Handle", true)
    local innerFill = object:FindFirstChild("InnerFill", true)
    local dragDetector = handle:FindFirstChildWhichIsA("UIDragDetector")

    local self = setmetatable({
        handle = handle,
        innerFill = innerFill,
        dragDetector = dragDetector,
        value = initialValue or 0.5,
        onChanged = onChanged,
    }, SliderController)

    self:setValue(self.value)

    self.dragConnection = dragDetector.DragContinue:Connect(function()
        self:setValue(handle.Position.X.Scale)
    end)

    return self
end

function SliderController:setValue(value: Value)
    local clampedValue = math.clamp(value, 0, 1)
    self.value = clampedValue

    self.handle.Position = UDim2.fromScale(clampedValue, 0.5)
    self.innerFill.Size = UDim2.fromScale(clampedValue, 1)

    local changeSuccess, changeResult = pcall(self.onChanged, clampedValue)
    if not changeSuccess then
        warn("Error in slider callback:", changeResult)
    end
end

return SliderController
```

### Create the settings script

LocalScript in HUDContainer:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SliderController = require(ReplicatedStorage.SliderController)
local StatefulObjectController = require(ReplicatedStorage.StatefulObjectController)

local HUDContainer = script.Parent

local settingsButton = StatefulObjectController.hydrate({
    object = HUDContainer:FindFirstChild("SettingsButton"),
    states = {
        menuOpen = {
            transition = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
            properties = { Rotation = 45 },
        },
        menuClosed = {
            transition = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
            properties = { Rotation = 0 },
        },
    },
    initialStateName = "menuClosed"
})

local settingsMenu = StatefulObjectController.hydrate({
    object = HUDContainer:FindFirstChild("SettingsMenu"),
    states = {
        menuOpen = {
            transition = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
            properties = {
                Position = UDim2.fromScale(0.5, 0.5),
                Visible = true,
            },
        },
        menuClosed = {
            transition = TweenInfo.new(0),
            properties = {
                Position = UDim2.fromScale(0.5, 0.4),
                Visible = false,
            },
        },
    },
    initialStateName = "menuClosed"
})

local effectsAudio = SoundService:FindFirstChild("Effects")
local effectsVolumeSlider = SliderController.hydrate({
    object = HUDContainer:FindFirstChild("EffectsVolumeSlider", true),
    initialValue = effectsAudio and effectsAudio.Volume or 0.5,
    onChanged = function(value)
        if effectsAudio then
            effectsAudio.Volume = value
        end
    end,
})

HUDContainer:FindFirstChild("SettingsButton").Activated:Connect(function()
    local targetState = if settingsButton.currentStateName == "menuClosed"
        then "menuOpen"
        else "menuClosed"
    settingsButton:setState(targetState)
    settingsMenu:setState(targetState)
end)

HUDContainer:FindFirstChild("CloseButton", true).Activated:Connect(function()
    settingsButton:setState("menuClosed")
    settingsMenu:setState("menuClosed")
end)
```

## Key Concepts

- **GuiButton / ImageButton / TextButton**: Interactive UI elements
- **Activated event**: Cross-platform activation (click/tap)
- **UIDragDetector**: Convenient drag interaction object
- **DragStyle / ResponseStyle**: TranslateLine / Scale for slider behavior
- **BoundingUI**: Constrains drag to parent bounds
- **UIAspectRatioConstraint**: Locks width:height ratio
- **UISizeConstraint**: Min/max pixel bounds
- **UICorner**: Rounded corners
- **UIListLayout with HorizontalFlex=Fill**: Flex-based arrangement
- **UIStroke**: Outline modifier
- **ModuleScript controllers**: Reusable, stateful UI management
- **TweenService**: Smooth property animation
- **SoundGroup.Volume**: Controls all sounds in a group

## Notes

- `UIDragDetector` simplifies drag interaction vs manual mouse tracking
- Use ModuleScripts for reusable UI logic instead of per-object scripts
- Always use `FindFirstChild(name, true)` for recursive search
- `TweenInfo.new(0)` makes an instant state change
- `BoundingUI` property is linked via click+select in Properties

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/ui/interactive-ui
Captured: 2026-04-16
