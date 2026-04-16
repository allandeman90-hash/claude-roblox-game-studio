---
title: "Creating A Basic Skill Tree"
type: raw-source
source_url: https://devforum.roblox.com/t/creating-a-basic-skill-tree/1248068
source_type: devforum
captured_at: 2026-04-15
captured_by: mechanics-rpg
category: devforum-tutorial
author: DevForum Community
post_date: 2021-05-24
tags: [skill-tree, gui, prerequisite-chains, progression]
---

# Creating A Basic Skill Tree

**Source:** DevForum Community Tutorial

## GUI Structure

- ScreenGUI container
- Frame positioned at center with anchor point (0.5, 0.5)
- NumberValue named "Points" to track skill points
- Buttons for each skill (Gun, Speed, etc.)

## Data Structure

Value-based system:
- `GUI.Frame.Points.Value` tracks available skill points
- Boolean values (GunButton.Value, SpeedButton.Value) gate progression

## Prerequisite Chain Logic

Speed button requires gun button first. Gun button checks:
```
GUI.Frame.Points.Value > 0 and GUI.Frame.GunButton.Value == false
```

## Community Feedback (Critical Issues)

- No FilteringEnabled support -- changes won't replicate to server or other players
- Missing RemoteEvents/Functions -- required for proper synchronization
- Poor script organization -- LocalScripts scattered across UI elements
- Server-side validation completely absent

## Additional Sources

- "Skill tree design for big skill trees" (2025): Nodes two nodes away from any unlocked node are hidden to prevent overloading new players
- "Skill Tree - using the new Roblox UIDragDetector" (2025): OOP-based skill assignment with CollectionService for data gathering
- "What's a good organized way to make a skill tree?" (2021): Structure using parts and clickdetectors
