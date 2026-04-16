---
title: "Raycast Hitbox 4.01: For all your melee needs!"
type: raw-source
source_url: https://devforum.roblox.com/t/raycast-hitbox-401-for-all-your-melee-needs/374482
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: TeamSwordphin
post_date: 2019-10-24
tags: [raycast, hitbox, melee, weapons, combat, community-resource]
---

# Raycast Hitbox 4.01: For All Your Melee Needs!

**Author:** TeamSwordphin (Phin)
**Current Version:** V.4.01 Stable (09/21/2021)
**Posted:** October 24, 2019

## Important Notice

This resource is no longer actively supported and has been superseded by ShapecastHitbox. While still functional, it contains bugs and performance issues that are no longer being addressed by the original team.

## Key Features

The module offers several advantages for melee combat systems:

- **Accuracy and Performance:** Uses raycasting from attachment positions to detect hits precisely while maintaining good frame rates
- **Flexible Setup:** Configure hitboxes using attachments or vector positions within seconds
- **Attachment Pairing:** Create straight-line hit detection by linking attachment pairs
- **Detection Modes:** Support for individual part tracking, humanoid-only hits, or unfiltered detection
- **Hitbox Distinction:** Enable tipper-style effects (like Super Smash Bros mechanics)
- **Time Scheduler:** Set hitboxes to deactivate automatically after specified durations
- **Mesh Deformation Support:** Works with deformed mesh parts
- **No Attribution Required:** Use freely with full community support available

## Why Raycasting Over Alternatives?

The creator chose raycasting because traditional methods like `.Touched` or `Region3` struggle with fast-moving weapons:

> "I needed accurate hitboxing while maintaining adequate performance"

for fluid combat systems inspired by games like MORDHAU and Chivalry.

## Core Limitations

1. **Single-Hit Per Target:** HitStart only registers each target once; call HitStop to reset the target pool for re-engagement
2. **Wide Object Requirements:** Large weapons need numerous attachments for accurate detection

## Setup Method

The module fires rays from attachment positions each frame, tracing movement between frames to catch fast strikes. Multiple attachments spaced along a weapon create comprehensive coverage without excessive performance overhead.

## Version History Summary

- **V.4.01** (Sept 2021): Fixed inaccuracy issues, added GoodSignal implementation
- **V.4.0** (July 2021): Major rewrite with improved legibility, typechecking, mesh deformation support
- **V.3.3** (Feb 2021): Added automatic hitbox scheduling
- **V.3.0** (Oct 2020): New hit distinction groups, improved detection performance

## Resources

- **GitHub Repository:** https://github.com/Swordphin/raycastHitboxRbxl
- **Documentation:** Comprehensive wiki with beginner examples
- **Example Place:** RaycastHitboxShowcaseV4.rbxl available for download

## Source

Original URL: https://devforum.roblox.com/t/raycast-hitbox-401-for-all-your-melee-needs/374482
Captured: 2026-04-16
