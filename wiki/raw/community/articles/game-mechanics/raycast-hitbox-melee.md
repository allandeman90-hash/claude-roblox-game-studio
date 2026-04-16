# Raycast Hitbox 4.01 — Melee Combat Module

**Source:** https://devforum.roblox.com/t/raycast-hitbox-401-for-all-your-melee-needs/374482
**Captured:** 2026-04-15

## Overview

Community module for accurate melee weapon hit detection using attachment-based raycasting. Inspired by MORDHAU/Chivalry. Fires rays from attachment points on a weapon each frame, tracing from previous position to current position to detect intersections. No longer maintained; successor is ShapecastHitbox.

## How It Works

- Place 7-15 Roblox attachments along a weapon, spaced ~1 stud apart
- Module fires rays from each attachment's previous position to current position every frame
- Continuous ray-casting ensures hits register even during rapid weapon movements
- More accurate than .Touched events or Region3

## API

- `Initialize(model, raycastParams)` - Creates hitbox from model
- `HitStart(seconds)` - Activates detection; optional auto-disable timer
- `HitStop()` - Deactivates; clears hit target cache
- `LinkAttachments(part1, part2)` - Rays between two attachment pairs
- `SetPoints(part, vectorTable)` - Vector positions instead of attachments
- `OnHit:Connect(function(part, humanoid))` - Hit event

## Performance

- 181+ rays per frame with smooth gameplay in testing
- Hundreds of rays per second before noticeable degradation
- Scales better than Touched events or Region3

## Why Raycasting Over Alternatives

- Touched events: Unreliable during fast movement, physics delays
- Region3: Deprecated, performance-intensive for continuous detection
- GetTouchingParts: Frame-skipping during rapid motion
- Raycasting traces movement paths between frames
