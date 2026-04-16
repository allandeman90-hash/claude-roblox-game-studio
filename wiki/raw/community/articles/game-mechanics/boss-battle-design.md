---
title: "Making Boss Battles Correctly"
source_url: "https://devforum.roblox.com/t/making-boss-battles-correctly/861910"
source_type: devforum-tutorial
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# Making Boss Battles Correctly

Two boss fight frameworks.

## Survival Bosses
Finite loop repeating attack sequences N times, then ending cutscene or phase transition.

## Health Bar Bosses
Vulnerability windows where players can damage between attack cycles. Phase transitions triggered by health thresholds:

```lua
if BossHealth <= Phase2HealthRequirement then
    break  -- advance to tougher attack patterns
end
```

## Randomized Attacks
Community suggested using arrays for procedural attack selection:

```lua
phaseOneAttacks[math.random(1, #phaseOneAttacks)](boss)
```

## Limitations Noted
Original tutorial is beginner-focused; does not cover telegraph/windup/recovery cycles, enrage mechanics, add spawning, safe zones, or state machines.
