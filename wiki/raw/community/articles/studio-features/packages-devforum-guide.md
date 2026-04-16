---
title: "YOU Should use Packages. Yes, YOU! — DevForum Staff Post"
type: raw-source
source_url: https://devforum.roblox.com/t/you-should-use-packages-yes-you/3182086
source_type: devforum
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: studio-features
author: Roblox Staff
post_date: 2024-10-01
tags: [packages, version-control, nesting, workflow]
---

# YOU Should use Packages. Yes, YOU!

**Author:** Roblox Staff
**Posted:** October 2024

## Overview

Packages are reusable asset instances that share identical underlying data, comparable to Blueprints in Unreal or Prefabs in Unity. They can exist across multiple places, groups, and teams.

## Key Capabilities

- Automatically update all copies to the latest version
- Auto-update mode pushes changes immediately to all instances
- Permission controls for team collaboration
- Version control and rollback functionality

## Creating Packages — Crate Example

1. Create a 6x6x6 stud cube, reposition pivot to bottom, name as Crate_A_Part
2. Group into Model: Wrap part in a Model named Crate_A, designating the part as Primary Part
3. Convert to Package: Transform the model into a package
4. Enable auto-update: Activate automatic propagation to all instances

## Publishing Updates

- Duplicate packages throughout the scene at various positions/scales
- Import new mesh assets
- Drag mesh into package's modelGroup
- Publish changes; updates propagate automatically to all instances

## Nesting Packages

Create modular, composable packages:
- Develop standalone SurfaceAppearance packages with textures
- Nest inside mesh packages for independent texture updates
- Updating any of them lets you update all of them across the world

**Known limitation:** Modifying nested packages requires manually republishing parent packages.

## Version Control

1. Right-click package -> "Compare Package Versions"
2. Cycle through versions in viewport
3. Access "Package Details" -> "Versions" tab
4. Select desired version and check "Restore"
5. Save changes

## Community Feedback and Challenges

- Packages marked modified without actual changes
- Historical data corruption concerns
- Nested package friction requiring manual updates
- Lack of local/instance-based package alternatives
- Missing Cloud API for CI/CD automation

**Planned improvements:** API enabling GitHub repository-to-package asset deployment (announced in comments).
