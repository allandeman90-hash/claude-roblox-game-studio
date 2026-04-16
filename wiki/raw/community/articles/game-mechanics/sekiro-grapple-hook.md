# Sekiro Grapple Hook (Open Source)

**Source:** https://devforum.roblox.com/t/open-source-sekiro-grapple-hook/438788
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Open-source grapple hook by x_o (Rudimentality). Inspired by Sekiro's traversal. 400+ likes.

## Mechanic

Press E to grapple toward designated points.

## Visual System

- Uses **Beam** object stored in `ReplicatedStorage.effects.grapple`
- Beam connects via attachments
- Attachment placed on arm, beam `Attachment0` linked to it
- Supports R15 and R6 (R6 requires chain display adjustment)

## Known Issues

- Repeated grapple to same location without repositioning can cause position errors or damage.

## Implementation Notes

- Grapple targets are pre-placed points in the world
- Player is pulled toward target using physics objects
- Beam provides visual rope/chain connecting player to grapple point
