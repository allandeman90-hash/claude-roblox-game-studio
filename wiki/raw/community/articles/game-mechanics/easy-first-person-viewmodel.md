---
title: "EasyFirstPerson - Drag-and-Drop Viewmodel System"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/easyfirstperson-drag-and-drop-first-person-view-models/1198782
model_id: 6741899793
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [viewmodel, easy-first-person, sway, bobbing, plug-and-play]
---

# EasyFirstPerson - Drag-and-Drop Viewmodel System

Plug-and-play first-person viewmodel system with built-in camera effects.

## Features

- Works with R6 and R15
- Camera sway (mouse-based)
- Walk bobbing animations
- Jump sway
- Customizable feature selection
- Auto-activates when entering first-person
- Tool animations work as expected on viewmodel

## How It Works

1. Attaches player's actual character arms to a fake HumanoidRootPart viewmodel
2. Fake HumanoidRootPart anchored to camera
3. Viewmodel receives camera manipulations (sway)
4. Real arms maintain animations and tool attachments

## Known Issues

- Tool position glitches when entering seats
- Self-damage with melee tools in FP (fix: character validation)
- Animation-related flight exploits (fixed in later versions)
- Reset functionality patches needed
