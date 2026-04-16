---
title: play-solo-team-test
type: studio
category: studio
subcategory: workflow
owner: roblox-studio-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[rojo-mapping]]"
tags: [studio, workflow, testing]
---

# Play Solo vs Team Test

**Status:** stub

## Summary

Roblox Studio testing modes:

- **Play Solo (F5)** — Client-only; single player on local machine. Good for UI and visual tests.
- **Run (F8)** — No player spawned. Good for environment tests.
- **Team Test (Shift+F5)** — Simulated server + multiple clients. Best for networked gameplay.
- **Device Emulator** — Simulates mobile / tablet viewports (not actual mobile perf).

Use Team Test for anything that involves RemoteEvents, multi-player interactions, or server-side logic.

## Related

- [[rojo-mapping]]

## Sources

- [wiki/raw/community/monetization/publishing/device-testing-emulator.md](../raw/community/monetization/publishing/device-testing-emulator.md)
