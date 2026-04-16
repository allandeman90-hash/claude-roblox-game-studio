---
title: Device Testing - Studio Emulators for Mobile, Xbox, VR
type: raw-source
source_url: https://github.com/Roblox/creator-docs/blob/main/content/en-us/studio/testing-modes.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-10
category: publishing
subcategory: deployment
tags: [testing, device-emulator, vr, mobile, xbox, team-test]
---

# Device Testing — Studio Emulators for Mobile, Xbox, VR

Roblox experiences must run on a bewildering array of platforms: PC,
Mac, iOS, Android, Xbox, PlayStation, Meta Quest. Studio provides
emulators so you don't need a device farm for routine QA.

## Studio testing modes

Accessible from the Test dropdown:

| Mode | What it does |
|------|--------------|
| **Test (Play Solo)** | Single-process client-server simulation |
| **Test Here** | Play Solo starting at the currently selected location |
| **Server & Clients** | Multi-window local multiplayer: one Studio is server, others are clients |
| **Team Test** | Single live session multiple collaborators can join |

## Client/Server perspective toggle

During Play Solo you can toggle perspective via the bar at the top:

- **Client mode** — **blue** viewport border, normal player controls,
  what a regular user sees.
- **Server mode** — **green** border, free-floating camera, no
  character control. Useful for inspecting server-side state.
- Output window labels messages with the same color so you know
  where a print came from.

## Device Emulator

`View` → `Device Emulator`. Simulates various phones, tablets,
consoles, and VR headsets. You see:

- The correct screen resolution and aspect ratio
- The correct on-screen UI overlays (mobile touch buttons, VR
  controllers)
- The correct input type (touch / gamepad / VR controller)

Supported targets include iPhone, iPad, Android phones/tablets,
consoles, and VR headsets.

## Controller Emulator

Under Device Emulator, supports gamepad input simulation, including
VR controllers. Trigger via the emulator toolbar.

## Touch Simulation

View menu → Touch Simulation. Turns mouse-clicks into touch events
so you can test mobile-touch specific code paths without a real phone.

## VR Emulator (Beta)

Select **Meta Quest 2** or **Meta Quest 3** in the device selector
menu. The controller emulator automatically selects appropriate
controllers. Motion tracking:

- **Alt+1** (⌥+1) — lock / unlock the mouse into the virtual headset
- **Shift+←** / **Shift+→** — cycle through common combinations of
  headset + controller positions

This lets you run VR code paths (`UserInputService.VREnabled`,
`VRService`, etc.) without a real headset.

## Player Emulator

Tests localization and content policies:

- Emulate locale (e.g. fr-FR, pt-BR, ja-JP)
- Pseudo-localize text (character substitution to find untranslated
  strings)
- Elongate strings to find truncation bugs
- Adjust regional settings

## Real-device testing flow

### iOS / Android

1. Publish experience privately
2. Install Roblox app on the target device
3. Sign in as the creator account
4. Open the experience from Creations tab

### Xbox / PlayStation

1. Publish privately
2. Ensure the experience is set to support the console platform
   (Device support in Game Settings)
3. Sign in on Xbox/PS with the creator account
4. Open from the Creations tab

Some Xbox behaviors (accelerated gamepad cursor, TV safe area,
mandatory chat filtering) only appear on actual console hardware.
Keep a real device in the QA loop for release candidates.

### Meta Quest (VR)

1. Add the Quest app from the Meta Store
2. Sign in with your Roblox account
3. Publish the experience privately
4. Favorite the experience on web / Roblox app
5. Open it from the Favorites tab on Quest

The VR emulator catches ~90% of VR bugs but cannot emulate:

- Room-scale tracking accuracy
- Headset-specific render artifacts
- Actual frame pacing / asynchronous timewarp

## Team Test

Only **one Team Test session** per experience at a time. Collaborators
join via the Game menu → Team Create. Great for reproducing multi-user
bugs without coordinating multiple Studio windows.

## Concrete Numbers / Examples

- Testing mode colors: **blue = client, green = server**
- Only **1** Team Test session per experience at a time
- VR emulator targets: **Meta Quest 2 / 3**
- VR mouse lock: **Alt+1**
- Server & Clients mode: **multi-window multiplayer locally**

## Source

Original URL: https://github.com/Roblox/creator-docs/blob/main/content/en-us/studio/testing-modes.md
Captured: 2026-04-16
