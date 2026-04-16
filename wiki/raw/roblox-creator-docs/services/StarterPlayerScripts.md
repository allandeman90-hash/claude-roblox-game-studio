---
title: StarterPlayerScripts
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/StarterPlayerScripts
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/StarterPlayerScripts.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: players
tags: [roblox-class, starter, players, scripts]
---

# StarterPlayerScripts

A container for objects to be copied to a Player's PlayerScripts when they
join a game.

## Description

`Class.StarterPlayerScripts` is a container object located within the
`Class.StarterPlayer` service. It can contain `Class.LocalScript|LocalScripts`
and other objects to be copied to the `Class.PlayerScripts` container once
when a `Class.Player` joins the game. For example, if you want to create
special effects on the client when certain conditions are met, you can place a
`Class.LocalScript` within this container to do that.

When an experience is run, this object will also house the default
multi-platform Roblox control scripts for the camera and character. If
`Class.LocalScript|LocalScripts` named `CameraScript` or `ControlScript` are
placed within this container, they will **replace** the Roblox defaults for
those scripts respectively. If desired, you can add empty
`Class.LocalScript|LocalScripts` for each of these to disable them altogether;
this is useful for experiences that do not follow the typical control
paradigms of a Roblox experience.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

_No public methods documented._

## Events

_No public events documented._

## Notes / Deprecations

_None flagged in source YAML._

## Examples

_No code samples referenced in source YAML._

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/StarterPlayerScripts
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/StarterPlayerScripts.yaml
- Captured: 2026-04-16
