---
title: How To Make A Round-Based System
type: raw-source
source_url: https://devforum.roblox.com/t/how-to-make-a-round-based-system/487712
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-p2-game-patterns
category: game-pattern
tags: [game-pattern, round-system, lobby, intermission, gameplay-loop]
---

# Round-Based System Tutorial for Roblox

## Overview
This tutorial demonstrates how to create a game loop that cycles through intermission, team assignment, gameplay, and cleanup phases.

## Core Phases

**Phase 1: Intermission**
The system waits for a configured duration (default: 20 seconds) while continuously checking player count. If insufficient players exist, it pauses until more join.

**Phase 2: Team Assignment**
A map is selected and loaded. One random player becomes the Killer; remaining players become Survivors. Players are teleported to their respective spawn locations.

**Phase 3: Gameplay**
The round runs for a set duration (default: 200 seconds). The system monitors three end conditions: all survivors eliminated, killer leaves, or time expires.

**Phase 4: Cleanup**
Players return to the lobby, the map is destroyed, and the cycle restarts.

## Configuration Variables

```lua
local roundtime = 200  -- Round duration in seconds
local inter = 20       -- Intermission duration in seconds
```

## Key Implementation Details

**Team Sorting Function:**
The tutorial shows selecting a random player for the Killer role: `local index = math.random(1,#players)` then assigning them to the Killer team while removing them from the available pool.

**Spawn Management:**
Players can be directed to team-specific spawns using conditional logic based on team membership, with separate spawn points for Killers versus Survivors.

**Deprecated Code:**
The tutorial notes that `table.foreach()` is deprecated. The recommended replacement uses a standard for loop: `for i, player in ipairs(players)`.

## Notable Best Practices

- Maintain a local timer variable separate from global state to prevent synchronization issues
- Verify sufficient players exist before starting gameplay
- Check for active players during rounds (killer and survivor counts) to trigger early termination
- Use a 3-second wait after team assignment to allow character loading before teleporting

## Source
Original URL: https://devforum.roblox.com/t/how-to-make-a-round-based-system/487712
