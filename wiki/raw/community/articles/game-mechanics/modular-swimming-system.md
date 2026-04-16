# Modular Swimming System

**Source:** https://devforum.roblox.com/t/modular-swimming-system/2072322
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Community module allowing players to swim through designated parts with custom animations. 82 likes. Asset ID: 11754462043.

## Detection & Physics

- Detects when player reaches water surface level
- Boundary violation detection on X and Z axes
- Launches player upward at surface for easier exit
- Raycasting to distinguish water from non-water parts

## Movement

- Rotation relative to camera direction
- Distinct idle and swimming animations
- Responds to player input for swimming motion
- Uses BodyPosition and BodyGyro for swimming physics

## Limitations

- Does NOT work with rotated parts
- Top surface must always be upright (horizontal water only)
- Modified by community to accept a table of part references instead of string-based identification

## Setup

Place parts to represent water zones. Module detects entry/exit and handles swim state automatically.
