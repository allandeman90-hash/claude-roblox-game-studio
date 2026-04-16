---
title: "FPS Weapon Switching System"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/fps-weapon-switching-system/3225625
related:
  - https://devforum.roblox.com/t/switching-weapons-in-viewmodels/2208510
  - https://devforum.roblox.com/t/switching-system-of-guns-using-the-keybind-q/1976986
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [weapon-switching, inventory, keybind, equip-unequip]
---

# FPS Weapon Switching System

Bare-bones weapon switching system for FPS games.

## Keybinds

- Press 1: equip Primary weapon
- Press 2: equip Secondary weapon
- Controller button Y: alternate primary bind

## State Management

Four values on player Character:
- EquippedPrimary (BoolValue)
- EquippedSecondary (BoolValue)
- Primary (StringValue) -- tool name
- Secondary (StringValue) -- tool name

## Flow

1. LocalScript detects key press (1 or 2)
2. Checks if weapon is not already equipped (bool == false)
3. Fires RemoteEvent (EquipPrimary or EquipSecondary)
4. Server searches Guns folder in ReplicatedStorage
5. Clones matching tool
6. Updates boolean states
7. Removes previous tool

## Inventory Pattern

- Tools stored in ReplicatedStorage.Guns folder
- Setting value to "None" means no weapon equipped
- Bug fix: preserve tool data (ammo) across re-equip cycles
