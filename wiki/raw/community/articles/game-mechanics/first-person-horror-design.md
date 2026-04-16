---
title: "First Person Horror Game Design"
author: Roblox DevForum Community
source: https://devforum.roblox.com/t/1st-person-only-horror/652817
related:
  - https://devforum.roblox.com/t/how-to-make-a-realistic-first-person-system-in-a-horror-game/762698
  - https://devforum.roblox.com/t/midnight-hours-new-first-person-horror-game/1896564
  - https://devforum.roblox.com/t/how-would-i-go-about-making-a-smooth-custom-first-person-camera-system-like-doors/2200738
platform: DevForum
captured_date: 2026-04-15
captured_by: mechanics-fps
tags: [horror, first-person, atmosphere, fog, audio, camera]
---

# First Person Horror Game Design

Community design advice for first-person horror experiences on Roblox.

## Why First Person for Horror

- Limited vision = cannot see threats behind you
- Creates psychological tension absent in third-person
- "The limited vision and lifelike feel will up your creep factor"
- Player uncertainty: "Who was that?", "What was that noise?"

## Atmosphere Techniques

- Fog effects (FogEnd, FogStart, FogColor in Lighting)
- Low ambient lighting
- Selective use of PointLight and SpotLight
- Environmental audio (footsteps, ambient sounds, distant noises)
- Red screen tint on damage

## Camera Techniques

- CameraMinDistance = 0, CameraMaxDistance = 0 for forced first person
- Custom white dot cursor replacing default
- Smooth camera with slight overshoot (DOORS style)
- Head bobbing via sine wave on DistributedGameTime
- Camera tilting based on velocity

## DOORS-Style Camera

```
- Smooth movement with overshoot (1.2x multiplier)
- math.sin(workspace.DistributedGameTime * 10) * cameraBobbing
- Velocity-responsive tilting
```

## Design Principles

- Choose perspective based on game goals, not assumptions
- Avoid cheap gimmicks; leverage perspective meaningfully
- Toggle option between FP/TP can broaden accessibility
- First person excels for story-driven horror
