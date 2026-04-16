---
title: ProximityPrompt
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ProximityPrompt.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: interaction
tags: [roblox-class, interaction, prompt]
---

# ProximityPrompt

An object that lets you prompt players to interact with an object in the 3D
world.

## Description

The **ProximityPrompt** instance lets you prompt players to interact with an
object in the 3D world, such as opening a door or picking up an item. A
`Class.ProximityPrompt` object works when parented to a `Class.BasePart`,
`Class.Attachment`, or `Class.Model` (with
`Class.Model.PrimaryPart|PrimaryPart` set) in the workspace. When the player's
character approaches, a UI appears to prompt them for input.

Prompts consist of three primary elements, each of which can be controlled by
the noted properties. The default UI can be swapped out for your own custom
appearance as outlined in `Class.ProximityPrompt.Style|Style`.

<img src="../../../assets/ui/proximity-prompt/Prompt-Diagram.png" width="600" />

<table>
<thead>
  <tr>
    <td>Property</td>
    <td>Description</td>
    <td>Default</td>
  </tr>
</thead>
<tbody>
  <tr>
    <td><code>Class.ProximityPrompt.ObjectText|ObjectText</code></td>
    <td>An optional name for the object being interacted with.</td>
    <td></td>
  </tr>
  <tr>
    <td><code>Class.ProximityPrompt.ActionText|ActionText</code></td>
    <td>An optional action name shown to the player.</td>
    <td>Interact</td>
  </tr>
  <tr>
    <td><code>Class.ProximityPrompt.KeyboardKeyCode|KeyboardKeyCode</code></td>
    <td>The keyboard key which will trigger the prompt.</td>
    <td>E</td>
  </tr>
  <tr>
    <td><code>Class.ProximityPrompt.GamepadKeyCode|GamepadKeyCode</code></td>
    <td>The gamepad button which will trigger the prompt.</td>
    <td>ButtonX</td>
  </tr>
</tbody>
</table>

You can connect to proximity prompt events either on the
`Class.ProximityPrompt` object itself or globally through
`Class.ProximityPromptService`. The `Class.ProximityPromptService` allows you
to manage all proximity prompt behavior from one location, preventing any need
for duplicate code in your experience.

For more information regarding proximity prompts, see the
[Proximity Prompts](../../../ui/proximity-prompts.md) guide.

## Inheritance

Inherits from: `Instance`

Memory category: `Instances`

## Properties

### `ProximityPrompt.ActionText`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

The action text shown to the user.

This property determines the action text shown to the user.

### `ProximityPrompt.AutoLocalize`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

Whether the prompt's `Class.ProximityPrompt.ActionText` and
`Class.ProximityPrompt.ObjectText` will be localized according to the
`Class.ProximityPrompt.RootLocalizationTable`.

This property determines whether the prompt's
`Class.ProximityPrompt.ActionText` and `Class.ProximityPrompt.ObjectText`
will be localized according to the
`Class.ProximityPrompt.RootLocalizationTable`. When set to true,
localization will be applied.

### `ProximityPrompt.ClickablePrompt`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

Whether the prompt can be activated by clicking/tapping on the prompt UI.

This property determines whether the prompt can be activated by
clicking/tapping on the prompt's UI. When set to false, the prompt cannot
be activated by click/tap except on mobile.

### `ProximityPrompt.Enabled`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

Whether or not this prompt should be shown.

This property indicates whether or this `Class.ProximityPrompt` should be
shown.

### `ProximityPrompt.Exclusivity`

- **Type:** `ProximityPromptExclusivity`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

Used to customize which prompts can be shown at the same time.

This property is used to customize which prompts can be shown at the same
time.

### `ProximityPrompt.GamepadKeyCode`

- **Type:** `KeyCode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

The gamepad button the player should press to trigger the prompt.

This property determines the gamepad button the player should press to
trigger the `Class.ProximityPrompt|ProximityPrompt`. Default is
**ButtonX**.

### `ProximityPrompt.HoldDuration`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

The duration, in seconds, that the player must hold the button/key down to
trigger the prompt.

This property indicates the duration, in seconds, that the player must
hold the button/key down to trigger the prompt.

### `ProximityPrompt.KeyboardKeyCode`

- **Type:** `KeyCode`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

The key the player should press to trigger the prompt.

This property determines the key the player should press to trigger the
`Class.ProximityPrompt|ProximityPrompt`. Default is <kbd>E</kbd>.

### `ProximityPrompt.MaxActivationDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

The maximum distance a Player's `Class.Player.Character|character` can be
from the `Class.ProximityPrompt` for the prompt to appear.

This property determines the maximum distance a Player's
`Class.Player.Character|character` can be from the `Class.ProximityPrompt`
for the prompt to appear.

### `ProximityPrompt.MaxIndicatorDistance`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

### `ProximityPrompt.ObjectText`

- **Type:** `string`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

An optional property that determines the object name text shown to the
user.

This optional property determines the optional object name text shown to
the user.

### `ProximityPrompt.RequiresLineOfSight`

- **Type:** `boolean`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

Whether the prompt is hidden if the path between the player's
`Class.Camera` and object parented to the `Class.ProximityPrompt` is
obstructed.

This property indicates whether the prompt is hidden if the path between
the player's `Class.Camera` and object parented to the
`Class.ProximityPrompt` is obstructed. If true, this prompt will only be
shown if there is a clear path from the camera to the object.

The parent `Class.Part` or `Class.Model` of the prompt will be excluded
from this check.

### `ProximityPrompt.RootLocalizationTable`

- **Type:** `LocalizationTable`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

A reference to a `Class.LocalizationTable` to be used to apply automated
localization to this prompt's `Class.ProximityPrompt.ActionText` and
`Class.ProximityPrompt.ObjectText`.

This property serves as a reference to the `Class.LocalizationTable` used
to apply automated localization to the prompt's
`Class.ProximityPrompt.ActionText` and `Class.ProximityPrompt.ObjectText`.
In order for this to apply, `Class.ProximityPrompt.AutoLocalize` must be
set.

Developers can set this to reference a LocalizationTable anywhere in the
`Class.DataModel`. It is not required to be a child of
`Class.LocalizationService`. If there is no translation available in the
referenced table it will look for a translation in the parent of that
table, if it is also a LocalizationTable, and so on.

### `ProximityPrompt.Style`

- **Type:** `ProximityPromptStyle`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

The style of the prompt's UI.

This property indicates the prompt's style. When set to Custom, no default
UI will be provided.

The provided UI can be swapped out for a custom UI. In order to do this,
set Style to Custom. Then, listen to the
`Class.ProximityPrompt.PromptShown` and
`Class.ProximityPrompt.PromptHidden` events in a `Class.LocalScript`,
where developers should create and tear down the UI.

Developers may also use `Class.ProximityPrompt.PromptButtonHoldBegan` and
`Class.ProximityPrompt.PromptButtonHoldEnded` in order to utilize the
`Class.ProximityPrompt.HoldDuration` progress animation feature.

### `ProximityPrompt.UIOffset`

- **Type:** `Vector2`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`, `Input`

The pixel offset applied to the prompt's UI.

This property indicates the pixel offset applied to the prompt's UI.

## Methods

### `ProximityPrompt:InputHoldBegin`

```
InputHoldBegin() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `Input`

Fires a signal indicating that the user began pressing the prompt GUI
button.

This function triggers a signal indicating that the user began pressing
the `Class.ProximityPrompt` prompt button. It should be used by developers
who wish to customize the prompt and trigger it from a prompt GUI button
press.

**Returns:**

- `()` — 

### `ProximityPrompt:InputHoldEnd`

```
InputHoldEnd() -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`UI`, `Input`

Fires a signal indicating that the user ended pressing the prompt GUI
button.

A counterpoint to `Class.ProximityPrompt:InputHoldBegin()`, this signals
that the user ended pressing the prompt GUI button.

**Returns:**

- `()` — 

## Events

### `ProximityPrompt.IndicatorHidden`

```
IndicatorHidden()
```

- security=`None` ; capabilities=`UI`, `Input`

### `ProximityPrompt.IndicatorShown`

```
IndicatorShown()
```

- security=`None` ; capabilities=`UI`, `Input`

### `ProximityPrompt.PromptButtonHoldBegan`

```
PromptButtonHoldBegan(playerWhoTriggered: Player)
```

- security=`None` ; capabilities=`UI`, `Input`

Triggered when a player begins holding down the
`Class.ProximityPrompt.KeyboardKeyCode|key`/button connected to a prompt
with a non-zero `Class.ProximityPrompt.HoldDuration`.

This event triggers when a player begins holding down the
`Class.ProximityPrompt.KeyboardKeyCode|key`/button on a prompt with a
non-zero `Class.ProximityPrompt.HoldDuration`. One possible usage includes
to animate a hold progress bar.

**Parameters:**

- `playerWhoTriggered` : `Player` — The `Class.Player` who begins holding down the prompt button.

### `ProximityPrompt.PromptButtonHoldEnded`

```
PromptButtonHoldEnded(playerWhoTriggered: Player)
```

- security=`None` ; capabilities=`UI`, `Input`

Triggers when the player ends holding down the button on a prompt with a
non-zero `Class.ProximityPrompt.HoldDuration`.

This event triggers when the player ends holding down the button on a
prompt with a non-zero `Class.ProximityPrompt.HoldDuration`. One possible
usage includes to animate a hold progress bar.

**Parameters:**

- `playerWhoTriggered` : `Player` — The player who ended the input hold.

### `ProximityPrompt.PromptHidden`

```
PromptHidden()
```

- security=`None` ; capabilities=`UI`, `Input`

Triggers when the `Class.ProximityPrompt|prompt` becomes hidden.

This event triggers when the `Class.ProximityPrompt|prompt` becomes
hidden. This event is triggered client-side for `LocalScripts`.

### `ProximityPrompt.PromptShown`

```
PromptShown(inputType: ProximityPromptInputType)
```

- security=`None` ; capabilities=`UI`, `Input`

Triggers when the `Class.ProximityPrompt|prompt` becomes visible.

This event triggers when the `Class.ProximityPrompt|prompt` becomes
visible. This event is triggered client-side for `LocalScripts`.

**Parameters:**

- `inputType` : `ProximityPromptInputType` — The input that triggers the prompt.

### `ProximityPrompt.Triggered`

```
Triggered(playerWhoTriggered: Player)
```

- security=`None` ; capabilities=`UI`, `Input`

Triggered when the prompt
`Class.ProximityPrompt.KeyboardKeyCode|key`/button is pressed, or after a
specified amount of time holding the button, if
`Class.ProximityPrompt.HoldDuration` is used.

This event is triggered when the prompt
`Class.ProximityPrompt.KeyboardKeyCode|key`/button is pressed, or after a
specified amount of time holding the button, if
`Class.ProximityPrompt.HoldDuration` is used.

**Parameters:**

- `playerWhoTriggered` : `Player` — The `Class.Player` who triggered the prompt.

### `ProximityPrompt.TriggerEnded`

```
TriggerEnded(playerWhoTriggered: Player)
```

- security=`None` ; capabilities=`UI`, `Input`

Triggers when `Class.ProximityPrompt.KeyboardKeyCode|key`/button is
released, for longer events where the user is required to hold down the
button.

This event is triggered when the
`Class.ProximityPrompt.KeyboardKeyCode|key`/button is released, for longer
events where the user is required to hold down the button (e.g. heal
another player over time.)

**Parameters:**

- `playerWhoTriggered` : `Player` — The `Class.Player` who released the key/button, ending the trigger event.

## Notes / Deprecations

- Property `ProximityPrompt.ActionText` security: `read=None, write=None`
- Property `ProximityPrompt.AutoLocalize` security: `read=None, write=None`
- Property `ProximityPrompt.ClickablePrompt` security: `read=None, write=None`
- Property `ProximityPrompt.Enabled` security: `read=None, write=None`
- Property `ProximityPrompt.Exclusivity` security: `read=None, write=None`
- Property `ProximityPrompt.GamepadKeyCode` security: `read=None, write=None`
- Property `ProximityPrompt.HoldDuration` security: `read=None, write=None`
- Property `ProximityPrompt.KeyboardKeyCode` security: `read=None, write=None`
- Property `ProximityPrompt.MaxActivationDistance` security: `read=None, write=None`
- Property `ProximityPrompt.MaxIndicatorDistance` security: `read=None, write=None`
- Property `ProximityPrompt.ObjectText` security: `read=None, write=None`
- Property `ProximityPrompt.RequiresLineOfSight` security: `read=None, write=None`
- Property `ProximityPrompt.RootLocalizationTable` security: `read=None, write=None`
- Property `ProximityPrompt.Style` security: `read=None, write=None`
- Property `ProximityPrompt.UIOffset` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `using-a-proximity-prompt-with-a-seat` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/ProximityPrompt
- `generating-a-custom-proximity-prompt` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/ProximityPrompt
- `healing-proximity-prompt` — https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/ProximityPrompt

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/ProximityPrompt.yaml
- Captured: 2026-04-16
