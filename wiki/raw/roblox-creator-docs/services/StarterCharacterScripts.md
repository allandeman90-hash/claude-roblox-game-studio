---
title: StarterCharacterScripts
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/StarterCharacterScripts
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/StarterCharacterScripts.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: players
tags: [roblox-class, starter, characters, scripts]
---

# StarterCharacterScripts

Stores instances to be parented to a player's character when it spawns.

## Description

The `Class.StarterCharacterScripts` container stores scripts to be parented to
a player's `Class.Player.Character` when it spawns. Unlike scripts stored in
the `Class.StarterPlayerScripts` folder, these scripts will not persist when
the character respawns.

If a `Class.LocalScript` named `Animate`, `Sound`, or `Health` is placed in
this container, it will replace the default script that manages character
animations, character sounds, and character health regeneration respectively.

## Inheritance

Inherits from: `StarterPlayerScripts`

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

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/StarterCharacterScripts
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/StarterCharacterScripts.yaml
- Captured: 2026-04-16
