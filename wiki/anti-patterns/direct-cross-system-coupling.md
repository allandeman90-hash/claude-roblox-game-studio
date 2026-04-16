---
title: direct-cross-system-coupling
type: anti-pattern
category: anti-patterns
subcategory: architecture
owner: lead-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: medium
sources:
  - wiki/raw/roblox-creator-docs/best-practices/security/security-tactics.md
  - wiki/raw/roblox-creator-docs/best-practices/security/defensive-design.md
  - .claude/docs/roblox-architecture-guide.md
related:
  - "[[server-authority]]"
  - "[[client-trust]]"
tags: [anti-pattern, architecture]
---

# Direct Cross-System Coupling

> Systems that directly modify each other's state instead of going through well-defined interfaces. A single compromised remote can cascade into multiple game systems.

**Severity:** Medium

## What It Looks Like

```lua
-- CombatService directly modifies EconomyService's data
local function onPlayerKill(attacker, victim)
    -- Combat directly reaches into economy state
    playerData[attacker].gold += 50
    playerData[attacker].killStreak += 1

    -- Combat directly reaches into inventory state
    if playerData[attacker].killStreak >= 5 then
        table.insert(playerData[attacker].inventory, "KillStreakBadge")
    end

    -- Combat directly reaches into leaderboard state
    leaderboardStore:SetAsync(attacker.Name, playerData[attacker].gold)

    -- Combat directly modifies UI state for all clients
    uiRemote:FireAllClients("ShowKillFeed", attacker.Name, victim.Name)
end
```

The problem: the combat handler has direct write access to gold, inventory, leaderboards, and client UI. If an exploiter finds a way to trigger `onPlayerKill` (e.g., through argument spoofing on a damage remote), they compromise four systems at once.

## Why It's Bad

1. **Blast radius amplification**: a single vulnerability in one system propagates to every system it directly touches. If the combat remote is exploited, the attacker gets free gold, free items, and leaderboard position in one call.
2. **Validation bypass**: each system should validate its own invariants. When System A directly writes to System B's state, System B's validation logic is bypassed entirely.
3. **Testing difficulty**: tightly coupled systems cannot be tested in isolation. Changing the economy formula requires understanding and testing every system that directly writes to economy state.
4. **Refactoring risk**: renaming a field in the economy data table breaks combat, inventory, and leaderboard code. There is no interface contract.
5. **Security audit complexity**: to assess the security of the economy system, you must trace every code path that writes to economy state -- which could be scattered across dozens of files.

## How to Fix It

Use a service-oriented architecture where each system exposes a validated interface:

```lua
-- EconomyService.lua (single source of truth for gold)
local EconomyService = {}

function EconomyService.addGold(player: Player, amount: number, reason: string): boolean
    if amount <= 0 then return false end
    if amount > MAX_SINGLE_GRANT then return false end

    local data = playerData[player]
    if not data then return false end

    data.gold += amount
    Logger.info("Gold granted:", player.Name, amount, reason)
    return true
end

return EconomyService
```

```lua
-- CombatService.lua (combat logic only)
local EconomyService = require(ServerScriptService.Services.EconomyService)
local InventoryService = require(ServerScriptService.Services.InventoryService)

local function onPlayerKill(attacker, victim)
    -- Combat requests gold through the economy interface
    EconomyService.addGold(attacker, Config.KILL_REWARD, "pvp_kill")

    -- Combat requests item through the inventory interface
    local killStreak = getKillStreak(attacker)
    if killStreak >= Config.STREAK_THRESHOLD then
        InventoryService.grantItem(attacker, "KillStreakBadge", "streak_reward")
    end
end
```

Key principles:
- **Each system validates its own state**: `EconomyService.addGold` checks that `amount > 0` and `amount <= MAX_SINGLE_GRANT`, regardless of who calls it.
- **Single writer**: only `EconomyService` writes to gold data. No other module touches `playerData[player].gold` directly.
- **Audit trail**: the `reason` parameter creates a log trail that shows why gold was granted, making anomaly detection possible.
- **Blast radius contained**: if the combat remote is compromised, the attacker can trigger `addGold` with `Config.KILL_REWARD` (a small, bounded amount), not an arbitrary value.

The Roblox Creator Docs' defensive design principle applies: "design systems where cheating provides no meaningful advantage." Bounded, validated interfaces limit the damage of any single exploit.

## Detection

Look for direct writes to another system's state:

```
playerData.*gold
playerData.*inventory
playerData.*level
```

If these appear in files other than the owning service (EconomyService, InventoryService, ProgressionService), the code has cross-system coupling.

Also look for a single remote handler that modifies multiple unrelated data fields -- this usually indicates the handler is doing too much and should delegate to service interfaces.

## Related

- [[server-authority]]
- [[client-trust]]

## Sources

- [Roblox Creator Docs: Security tactics](../raw/roblox-creator-docs/best-practices/security/security-tactics.md) -- "Partition responsibilities early"
- [Roblox Creator Docs: Defensive design](../raw/roblox-creator-docs/best-practices/security/defensive-design.md) -- Design to limit exploit impact
- [Architecture Guide](../../.claude/docs/roblox-architecture-guide.md) -- Module organization, circular dependency avoidance
