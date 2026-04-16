---
title: UIScale
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/UIScale
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UIScale.yaml
captured_at: 2026-04-16
captured_by: research-agent-p2-classes
category: gui-layout
tags: [roblox-class, gui, layout, scaling]
---

# UIScale

An object that acts as a multiplier for the size of the parent UI element's
scale.

## Description

A UIScale object simply contains a number that is used to multiply the
`Class.GuiBase2d.AbsoluteSize` of the parent UI element. This number is stored
in `Class.UIScale.Scale`.

## Inheritance

Inherits from: `UIComponent`

Memory category: `Instances`

## Properties

### `UIScale.Scale`

- **Type:** `float`
- **Security:** `read=None, write=None`
- **Thread safety:** `ReadSafe`
- **Capabilities:** `UI`

Determines the multiplier to apply to the parent UI element's size.

The Scale property determines the multiplier used on the parent UI
element's `Class.GuiBase2d.AbsoluteSize`. When set to 0.5, an AbsoluteSize
of {0, 200}, {0, 50} becomes {0, 100}, {0, 25}. Similarly, when set to 2,
such an AbsoluteSize would become {0, 400}, {0, 100}.

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

- Property `UIScale.Scale` security: `read=None, write=None`

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- `UI-Scale-Demo` --- https://github.com/Roblox/creator-docs/tree/main/content/en-us/reference/engine/classes/UIScale
- UIScale.Scale: UI-Scale-Demo

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/UIScale
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/UIScale.yaml
- Captured: 2026-04-16
