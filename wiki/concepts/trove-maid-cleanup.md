---
title: trove-maid-cleanup
type: concept
category: concepts
subcategory: resource-management
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - .claude/agents/luau-systems-programmer.md
  - wiki/raw/community/devforum/using-janitor-memory-leaks.md
related:
  - "[[signal-pattern]]"
  - "[[RemoteEvent]]"
  - "[[client-server-split]]"
tags: [concept, memory, cleanup]
---

# Trove / Maid / Janitor Cleanup

> The pattern of grouping disposable resources (connections, instances, threads, callbacks) into a single container so they can all be cleaned up together.

## What It Is

Luau code frequently creates resources that need cleanup: `RBXScriptSignal` connections, Instances, spawned threads, timers, listeners. Forgetting to clean any of them causes memory leaks, double-firing handlers, or orphaned objects.

Trove (and its alternatives Maid and Janitor) are tiny utility modules that:
1. Accept resources via `trove:Add(resource)` or similar
2. Track them internally
3. Dispose all of them with a single `trove:Clean()` call

The three libraries are largely interchangeable:
- **Trove** (Sleitnick) — actively maintained, clean API, most popular in modern codebases
- **Janitor** (howmanysmall) — adds feature flags, observer-style methods, named items
- **Maid** — the classic, simpler API, still widely used in legacy code

Pick one and be consistent. This wiki uses Trove as the reference implementation.

## When to Use It

Any time you're creating something disposable inside a function that could be called again or whose lifetime is bounded. Examples:

- Creating a UI (must clean up on close)
- Spawning a character (must clean up on respawn)
- Starting a game round (must clean up when round ends)
- Setting up a player session (must clean up when player leaves)
- Running an animation sequence (must clean up when cancelled)

## Implementation

### Trove Pattern

```lua
local Trove = require(game.ReplicatedStorage.Shared.Trove)

local function createEnemy(position: Vector3)
    local trove = Trove.new()

    -- Add an instance (will be :Destroy()-ed)
    local enemy = Instance.new("Part")
    enemy.Position = position
    enemy.Parent = workspace
    trove:Add(enemy)

    -- Add a connection (will be :Disconnect()-ed)
    trove:Add(enemy.Touched:Connect(function(hit)
        -- handle collision
    end))

    -- Add a function (will be called)
    trove:Add(function()
        print("Enemy destroyed")
    end)

    -- Add a running task (will be task.cancel()-ed)
    trove:Add(task.spawn(function()
        while true do
            task.wait(1)
            enemy.Position += Vector3.new(0, 1, 0)
        end
    end))

    return trove
end

-- Later
local enemyTrove = createEnemy(Vector3.new(0, 10, 0))
task.wait(10)
enemyTrove:Clean()  -- everything added above is disposed in one call
```

### Nested Troves

```lua
local outer = Trove.new()
local inner = outer:Extend()  -- child trove

inner:Add(someInstance)
inner:Add(someConnection)

-- Cleaning outer cleans inner too
outer:Clean()
```

Child troves let you group related resources and dispose them independently if needed.

### Per-Player Troves

```lua
local playerTroves: {[Player]: Trove.Trove} = {}

game.Players.PlayerAdded:Connect(function(player)
    local trove = Trove.new()
    playerTroves[player] = trove

    trove:Add(player.Chatted:Connect(function(msg)
        onPlayerChat(player, msg)
    end))

    trove:Add(player.CharacterAdded:Connect(function(char)
        setupCharacter(player, char)
    end))
end)

game.Players.PlayerRemoving:Connect(function(player)
    if playerTroves[player] then
        playerTroves[player]:Clean()
        playerTroves[player] = nil
    end
end)
```

All per-player state is cleaned up on leave. No leaks.

## Variants

### Maid (simpler, legacy)

```lua
local Maid = require(ReplicatedStorage.Shared.Maid)
local maid = Maid.new()

maid:GiveTask(someConnection)
maid:GiveTask(someInstance)
maid:GiveTask(function() print("done") end)

maid:DoCleaning()  -- or maid:Destroy()
```

### Janitor (richer features)

```lua
local Janitor = require(ReplicatedStorage.Shared.Janitor)
local janitor = Janitor.new()

janitor:Add(someConnection, "Disconnect")
janitor:Add(someInstance, "Destroy", "EnemyPart")  -- named
janitor:Remove("EnemyPart")  -- clean a specific item

janitor:Cleanup()
```

## Pitfalls

- **Not cleaning the trove**: the whole point is to `:Clean()` it. Set up cleanup triggers (PlayerRemoving, character death, UI close).
- **Mixing cleanup libraries**: pick one. Don't mix Trove with Maid with raw `connection:Disconnect()` calls.
- **Global troves that never clean**: defeats the point. Troves should be scoped.
- **Adding mutable state to a trove**: `trove:Add(tableReference)` won't `:Destroy()` a plain table. Wrap in a function or Instance.
- **Cleaning a trove twice**: Trove handles this safely (idempotent), but be aware.
- **Forgetting cleanup on error paths**: use `task.spawn` + `pcall` wrappers that always clean.

## Related

- [[signal-pattern]] — signals are common connections that go into Troves
- [[RemoteEvent]] — remote handler connections should be in a Trove
- [[client-server-split]] — cleanup is especially important on the client where UIs recreate constantly

## Sources

- [Trove by Sleitnick (GitHub)](https://github.com/Sleitnick/RbxUtil/tree/main/modules/trove)
- [.claude/agents/luau-systems-programmer.md](../../.claude/agents/luau-systems-programmer.md)
- [wiki/raw/community/devforum/using-janitor-memory-leaks.md](../raw/community/devforum/using-janitor-memory-leaks.md)
