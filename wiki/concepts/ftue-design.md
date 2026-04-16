---
title: ftue-design
type: concept
category: concepts
subcategory: retention
owner: game-designer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md
related:
  - "[[core-loop]]"
  - "[[daily-rewards]]"
  - "[[code-redemption]]"
  - "[[quest-system]]"
tags: [concept, retention, design, onboarding]
---

# FTUE Design (First-Time User Experience)

> The first-session experience for a new player; on Roblox, the first 5 minutes determine D1 retention.

## What It Is

FTUE is the designed sequence of events a new player experiences from the moment they join until they either leave or become a retained player. On Roblox, where the audience skews young and the platform offers thousands of competing experiences one click away, the FTUE window is brutally short: players who do not find value within the first 60-120 seconds rarely return.

The FTUE is not just a tutorial. It is the entire first impression: load time, visual quality, audio feedback, initial reward, clarity of purpose, and the hook that creates anticipation for the next session.

## When to Use It

Every game with retention goals needs an intentional FTUE. Even sandbox games with no explicit "tutorial" benefit from a designed first-60-seconds flow.

## Implementation

### The 5-Minute Rule

Empirical guidance from Roblox analytics and community post-mortems:

| Milestone | Target time | Purpose |
|-----------|------------|---------|
| **First reward** | < 60 seconds | Immediate positive feedback |
| **Core loop experienced** | < 2 minutes | Player understands "what I do in this game" |
| **First meaningful choice** | < 3 minutes | Agency and investment |
| **Session hook planted** | < 5 minutes | Reason to come back (daily reward countdown, quest in progress) |

### Structural Pattern

```
Join -> Loading screen (< 5s) -> Spawn -> Guided first action -> Reward
    -> Brief tutorial (core mechanic) -> Second reward
    -> Core loop entry -> Show daily rewards / quest log
    -> Session hook ("come back tomorrow for X")
```

### Tutorial Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Guided tutorial** (NPC dialogue, arrows, forced path) | Clear, measurable completion rate | Annoying for experienced players, dev-heavy |
| **Organic onboarding** (contextual tooltips, progressive disclosure) | Less intrusive, scales with player skill | Harder to measure, some players miss cues |
| **Video/cutscene intro** | Sets tone, fast | Players skip it, no interactivity |
| **Learn-by-doing** (sandbox with soft gates) | Feels natural, no scripted flow | Players may miss core mechanics |

**Recommendation:** Use guided tutorial for the first 60 seconds (ensure the core mechanic is shown), then switch to organic onboarding (contextual tooltips as needed). Always make the tutorial skippable for returning players.

### Skippability for Returning Players

```lua
-- Server: check if player has completed FTUE
local function shouldShowTutorial(playerData): boolean
    return not playerData.ftueCompleted
end

-- After FTUE completes:
playerData.ftueCompleted = true
playerData.ftueCompletedAt = os.time()
```

Store the FTUE completion flag in the player's DataStore profile. Never force a returning player through the tutorial again.

### Device-Specific Onboarding

Roblox runs on PC, mobile, console, and VR. The FTUE must account for input differences:

- **Mobile:** Larger touch targets, simplified controls, shorter text.
- **PC:** Can assume keyboard/mouse; show keybinds.
- **Console:** Gamepad-focused prompts; different button icons.
- **VR:** Minimal UI; spatial onboarding cues.

Detect the input method at join and branch the tutorial flow:

```lua
local UserInputService = game:GetService("UserInputService")

local function getInputType(): string
    if UserInputService.TouchEnabled then
        return "mobile"
    elseif UserInputService.GamepadEnabled then
        return "console"
    elseif UserInputService.VREnabled then
        return "vr"
    else
        return "pc"
    end
end
```

### Funnel Analysis

Track FTUE completion as a series of events to identify where players drop off:

```lua
-- Emit custom analytics events at each FTUE milestone
local AnalyticsService = game:GetService("AnalyticsService")

AnalyticsService:LogCustomEvent(player, "ftue_step_1_spawn")
AnalyticsService:LogCustomEvent(player, "ftue_step_2_first_action")
AnalyticsService:LogCustomEvent(player, "ftue_step_3_first_reward")
AnalyticsService:LogCustomEvent(player, "ftue_step_4_core_loop")
AnalyticsService:LogCustomEvent(player, "ftue_complete")
```

The drop-off between steps reveals exactly where the experience fails. If 80% complete step 1 but only 30% reach step 3, the problem is between steps 2 and 3.

### D1 Retention Targets

| Game quality | D1 retention target |
|-------------|---------------------|
| Top-tier Roblox game | 35-45% |
| Good | 25-35% |
| Average | 15-25% |
| Needs work | < 15% |

D1 retention is almost entirely a function of FTUE quality. If D1 is low, the first place to investigate is the first 5 minutes.

## Variants

| Variant | Description |
|---------|-------------|
| **Linear tutorial** | Fixed sequence: step 1, 2, 3. Simplest to build and measure. |
| **Branching tutorial** | Player chooses a class/path early; tutorial adapts. Higher engagement, more dev work. |
| **No tutorial** | Sandbox games rely on organic discovery. Works for simple mechanics; fails for complex ones. |
| **Progressive disclosure** | Features unlock over time (first session = basic, second = intermediate). Reduces information overload. |

## Pitfalls

- **Loading time kills FTUE.** If the game takes > 10 seconds to load, many players leave before seeing anything. Optimize asset loading; use [[streaming-enabled]] for large maps. Show a visually interesting loading screen.
- **Too much text.** Roblox's core audience is young. Long dialogue or instruction text is skipped. Show, do not tell. Use visual cues and immediate interactive feedback.
- **No session hook.** If the first session ends without a reason to return, the player is lost. Plant the hook explicitly: show a daily reward countdown, display the next quest reward, preview locked content.
- **Unskippable tutorial.** Forcing experienced players (or alts) through a 5-minute tutorial every time is a retention killer. Always persist FTUE completion.
- **Testing with experienced eyes.** Developers know their own game. FTUE testing must use first-time players or watch-me-play recordings to catch real confusion points.

## Related

- [[core-loop]] -- the FTUE leads into the core loop
- [[daily-rewards]] -- the first daily reward is part of the session hook
- [[code-redemption]] -- a starter code can be part of the FTUE reward
- [[quest-system]] -- tutorial quests guide the FTUE

## Sources

- [wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md](../raw/community/monetization/live-ops/liveops-essentials-cadence.md) -- content cadence and retention context
