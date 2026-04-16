---
title: Play Solo and Team Test
type: studio
category: studio
subcategory: workflow
owner: roblox-studio-specialist
status: complete
created: 2026-04-16
updated: 2026-04-15
sources:
  - wiki/raw/community/monetization/publishing/device-testing-emulator.md
  - wiki/raw/community/monetization/publishing/universe-place-structure.md
  - wiki/raw/community/monetization/publishing/bindtoclose-deployment.md
related:
  - "[[rojo-mapping]]"
  - "[[open-cloud-api]]"
  - "[[bind-to-close]]"
tags: [studio, workflow, testing, play-solo, team-test, device-emulator]
---

# Play Solo and Team Test

> Studio provides multiple testing modes -- Play Solo, Server & Clients, Team Test, and device emulators -- so developers can validate single-player, multiplayer, and cross-platform behavior without leaving the editor.

## Summary

Roblox experiences must run on PC, Mac, iOS, Android, Xbox, PlayStation, and Meta Quest. Studio's built-in testing modes let developers validate behavior across these targets without a device farm. The modes range from single-process Play Solo to multi-window local multiplayer to real-device testing flows.

## Testing Modes

| Mode | Shortcut | What it does | Best for |
|---|---|---|---|
| **Play Solo** | F5 | Single-process client+server simulation | UI, visual tests, quick iteration |
| **Test Here** | -- | Play Solo starting at the currently selected location | Testing specific map areas |
| **Run** | F8 | Server only, no player spawned | Environment tests, server-side logic |
| **Server & Clients** | -- | Multi-window local multiplayer: one Studio is server, others are clients | Multiplayer interactions, RemoteEvent testing |
| **Team Test** | -- | Live session multiple collaborators can join | Reproducing multi-user bugs with real teammates |

## Client/Server Perspective Toggle

During Play Solo, a bar at the top of the viewport toggles perspective:

- **Client mode** -- **blue** viewport border. Normal player controls, what a regular user sees.
- **Server mode** -- **green** border. Free-floating camera, no character control. Inspect server-side state.
- The Output window labels messages with the same color, so `print()` calls are identifiable as client or server origin.

This is essential for debugging [[client-server-split]] issues where the server and client see different state.

## Device Emulator

`View` > `Device Emulator`. Simulates phones, tablets, consoles, and VR headsets:

- Correct screen resolution and aspect ratio
- Correct on-screen UI overlays (mobile touch buttons, VR controllers)
- Correct input type (touch / gamepad / VR controller)

Supported targets include iPhone, iPad, Android phones/tablets, consoles, and VR headsets.

### Touch Simulation

`View` > `Touch Simulation`. Turns mouse clicks into touch events for testing mobile-touch code paths without a real phone.

### VR Emulator (Beta)

Select **Meta Quest 2** or **Meta Quest 3** in the device selector. Motion tracking:

- **Alt+1** -- lock/unlock mouse into the virtual headset
- **Shift+Left/Right** -- cycle through headset + controller position presets

Tests `UserInputService.VREnabled` and `VRService` code paths without a real headset. Cannot emulate room-scale tracking accuracy or actual frame pacing.

### Player Emulator

Tests localization and content policies:

- Emulate locale (e.g., `fr-FR`, `pt-BR`, `ja-JP`)
- Pseudo-localize text (character substitution to find untranslated strings)
- Elongate strings to find truncation bugs

## Real-Device Testing Flow

### iOS / Android

1. Publish experience privately.
2. Install Roblox app on the target device.
3. Sign in as the creator account.
4. Open the experience from the **Creations** tab.

### Xbox / PlayStation

1. Publish privately.
2. Set the experience to support the console platform (Device support in Game Settings).
3. Sign in on Xbox/PS with the creator account.
4. Open from the **Creations** tab.

Some Xbox-specific behaviors (accelerated gamepad cursor, TV safe area, mandatory chat filtering) only appear on actual console hardware. Keep a real device in the QA loop for release candidates.

### Meta Quest (VR)

1. Install the Roblox app from the Meta Store.
2. Sign in with the creator Roblox account.
3. Publish the experience privately.
4. Favorite the experience on web.
5. Open from the **Favorites** tab on Quest.

The VR emulator catches ~90% of VR bugs but cannot emulate room-scale tracking, headset-specific render artifacts, or actual asynchronous timewarp.

## Team Test

Only **one Team Test session** per experience at a time. Collaborators join via the Game menu > Team Create. Useful for reproducing multi-user bugs without coordinating multiple Studio windows.

## BindToClose in Studio

Play Solo triggers `game:BindToClose()`. DataStore writes in Studio can block or fail silently. Gate BindToClose logic with `RunService:IsStudio()` to keep dev loops fast:

```lua
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
    game:BindToClose(function()
        -- save all players in parallel
    end)
end
```

See [[bind-to-close]] for the full production pattern.

## Universe vs. Place Structure

Understanding the testing model requires understanding the publish model:

| Term | Meaning |
|---|---|
| **Experience / Universe** | Top-level game on Discover. Has a `UniverseId`. |
| **Place** | Individual `.rbxl` file within a universe. Has a `PlaceId`. |
| **Start Place** | The place new players join by default. |

Testing modes operate on a single place. Multi-place experiences require teleportation (via `TeleportService`) to test cross-place flows. For CI/CD testing, the Luau Execution API runs against a specific place (see [[open-cloud-api]]).

## Publishing Workflow

### From Studio

1. **File** > **Publish to Roblox** for initial publish.
2. Experience starts as **private** (creator-only access).
3. Going public requires: account 48+ hours old, content maturity questionnaire, ID-verified or post-2025-01-01 purchase. Max 5 private-to-public transitions per day.

### Version History and Rollback

**File** > **Game Settings** > **Version History** (or Creator Hub > place > Versions). Version history is per-place, not per-universe. For CI/CD, track the `versionNumber` returned by the Open Cloud publish API to automate rollback.

### Beta Mode

A public experience can opt into Beta mode, excluding it from the "Recommended for You" algorithm. Use for soft launches, live-ops testing, and monetization A/B experiments before going wide.

## Pitfalls

- **Play Solo is not multiplayer.** Tests that pass in Play Solo may fail with real clients. Always validate RemoteEvent logic in Server & Clients mode or Team Test.
- **Device emulator is not real hardware.** The emulator approximates resolution and input type but not actual GPU performance, thermal throttling, or platform-specific behaviors.
- **BindToClose fires in Studio.** Gate production save logic with `RunService:IsStudio()`.
- **Team Test limit.** Only one session per experience at a time.

## Related

- [[rojo-mapping]]
- [[open-cloud-api]]
- [[bind-to-close]]

## Sources

- [Device testing and emulators](../raw/community/monetization/publishing/device-testing-emulator.md)
- [Universe vs. Place structure](../raw/community/monetization/publishing/universe-place-structure.md)
- [BindToClose deployment pattern](../raw/community/monetization/publishing/bindtoclose-deployment.md)
