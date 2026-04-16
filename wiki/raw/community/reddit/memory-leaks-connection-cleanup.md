---
title: Should I be concerned over memory leaks? (Connection cleanup)
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/yfmw6u/should_i_be_concerned_over_memory_leaks/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [memory-leaks, connections, disconnect, maid, trove, garbage-collection]
---

# Should I be concerned over memory leaks?

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/yfmw6u/

## The Question

A common worry for Roblox beginners: "Does Lua garbage-collect for me, or do I have to manage memory like C?"

## The Short Answer

Lua/Luau **does** have a garbage collector. You do not `free` memory by hand. But there is one Roblox-specific leak you **will** hit: **unreleased signal connections hold references to everything they capture**, and that keeps objects alive even when you think they're gone.

## How A Connection Leak Happens

```lua
-- BAD
local function setupPlayer(player)
	player.CharacterAdded:Connect(function(character)
		character.Humanoid.Died:Connect(function()
			-- do something when they die
		end)
	end)
end
```

Every time a player respawns, `CharacterAdded` fires. You connect a *new* `Died` listener to the new humanoid but never disconnect the old ones. After 10 deaths, you have 10 listeners. After 1000, you have 1000. Each one keeps a reference to its closure — which includes the character, any upvalues, and so on — so the garbage collector can never reclaim them.

Even when the player leaves, your code is holding onto their data through the dead connection.

## The Rule The Thread Establishes

> "When you disconnect the signal, the function no longer has any active script connections and should be GC'd."

Every connection you create has a matching cleanup point. You must decide where that cleanup lives and make sure it runs.

## Automatic Cleanup Cases (Good News)

Some connections clean themselves up:

- **Instance destroyed**: When you call `instance:Destroy()`, all connections *to events on that instance* are disconnected automatically. (But connections you made on *other* instances that reference this one are NOT.)
- **Player removing**: The server automatically cleans up connections attached to events on `player` itself when the player leaves. (But again, connections to other services that reference the player are not.)
- **Script stops**: When a LocalScript is destroyed (e.g., in a respawn or teleport), its connections are disconnected.

## The Case You Usually Hit (Bad News)

```lua
-- RunService connections are NOT automatically cleaned up
RunService.Heartbeat:Connect(function()
	-- this runs forever, even after your character dies
end)
```

`RunService.Heartbeat`, `RunService.RenderStepped`, and any connection to a persistent service like `MessagingService`, `DataStoreService`, `CollectionService`, etc. is your responsibility to disconnect.

## The Canonical Fix: Maid / Trove

The community has standardized on a utility called `Maid` (or its modern successor `Trove` from the Nevermore/Sleitnick stack). You create a maid, hand it every connection and destroyable thing, and call `:Destroy()` / `:Clean()` once to release everything.

```lua
local Trove = require(ReplicatedStorage.Packages.Trove)

local function setupPlayer(player)
	local trove = Trove.new()

	trove:Connect(player.CharacterAdded, function(character)
		trove:Connect(character.Humanoid.Died, function()
			-- handle death
		end)
	end)

	trove:Connect(player.Destroying or game.Players.PlayerRemoving, function(leaving)
		if leaving == player then
			trove:Destroy()
		end
	end)
end
```

Everything the trove touched is disconnected / destroyed in one call. No leaks.

## How To Verify You Have A Leak

1. **In-Studio Memory tab** (View → Memory). Watch the `Instances` count and any custom categories. If it climbs during normal play and never drops after respawns, something is leaking.
2. **`Stats.GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Instances)`** — script-readable, useful for automated sanity checks.
3. **Dev Console** in a running game — the Memory tab shows per-category usage and is the best tool for spotting real leaks in production.
4. **print(#CollectionService:GetTagged("Tag"))** over time — if it grows without bound while the actual in-world count is stable, your binder is leaking references.

## Common Leak Sources In Roblox Code

1. `RunService` connections created per-character and never disconnected.
2. `Touched` / `TouchEnded` handlers that capture the part and live past the part's destruction.
3. Player tables (`local playerData = {}`) that never delete the entry on `PlayerRemoving`.
4. References to `Character` / `Humanoid` kept in upvalues after they died.
5. `CollectionService:GetInstanceAddedSignal` without a matching `RemovedSignal` cleanup.
6. `Remote.OnServerEvent:Connect` inside a function that's called multiple times per player, creating duplicate listeners.

## The Meta Rule

> "Every `Connect` deserves a home for its `Disconnect`."

If you can't say exactly when and where a connection will be disconnected, you have a potential leak. Wrap it in a Trove / Maid.

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/yfmw6u/should_i_be_concerned_over_memory_leaks/
Captured: 2026-04-16

## Notes

Content reconstructed from search snippets. The Trove/Maid pattern is the canonical community answer and is used in every major Roblox framework (Knit, Matter, Fusion, Flamework).
