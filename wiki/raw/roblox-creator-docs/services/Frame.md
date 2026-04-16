---
title: Frame
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/Frame
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Frame.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui
tags: [roblox-class, gui, container, ui-layout]
---

# Frame

A `Class.GuiObject` that renders as a plain rectangle, generally used as a
container.

## Description

`Class.Frame` is a `Class.GuiObject` that acts as a container for other
`Class.GuiObject|GuiObjects`. You can use it for UI that either displays on a
user's [screen](../../../ui/on-screen-containers.md) or on a
[surface](../../../ui/in-experience-containers.md) within the experience.

<img src="/assets/ui/ui-objects/Frame-Example.jpg" width="840" />

`Class.Frame|Frames` are ideal containers for responsive layouts such as
[list and flex layouts](../../../ui/list-flex-layouts.md), allowing you to
change the size of the frame and dynamically adjust how layout items fit
within it. `Class.Frame|Frames` are also core `Class.GuiObject|GuiObjects`, so
you can customize properties such as
`Class.GuiObject.BackgroundColor3|BackgroundColor3`,
`Class.GuiObject.Transparency|Transparency`, apply a
[background gradient](../../../ui/appearance-modifiers.md#gradient) or
[border](../../../ui/appearance-modifiers.md#stroke), and more.

## Inheritance

Inherits from: `GuiObject`

Memory category: `Gui`

## Properties

### `Frame.Style`

- **Type:** `FrameStyle`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Sets what the frame looks like from a selection of pre-determined styles.

Sets what the frame looks like from a selection of pre-determined styles.
See `Enum.FrameStyle` for a description of each style.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `Frame.Style` security: `read=None, write=None`

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/Frame
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/Frame.yaml
- Captured: 2026-04-16
