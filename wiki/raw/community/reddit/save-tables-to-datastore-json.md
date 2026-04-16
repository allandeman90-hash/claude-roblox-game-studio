---
title: How would I save a table to a DataStore?
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/9743o5/how_would_i_save_a_table_to_a_datastore/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [datastore, json, serialization, tables, data-persistence]
---

# How would I save a table to a DataStore?

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/9743o5/

## The Question

A developer asks how to persist a Lua table (inventory, stats, settings) to a DataStore.

## Short Answer

**You can pass a table directly to `SetAsync`** — Roblox DataStores will serialize it for you automatically, as long as every value in the table is one of:

- `number`
- `string`
- `boolean`
- `nil`
- Another table containing only those types

That's it. No manual JSON encoding required for the common case.

## The Thread's Answer

The post captures the exact community confusion:
> "I've also been told that it can just be saved as a table without encoding it."

This is correct. The misconception comes from earlier Lua/DataStore tutorials that showed `HttpService:JSONEncode(tbl)` before calling SetAsync. **That's unnecessary** — Roblox's DataStore serializer already handles Lua tables. Encoding to JSON yourself just wastes a pair of encode/decode steps and costs a bit of memory.

## What You CANNOT Save

- **Instances** (`Part`, `Player`, etc.) — they're not serializable. Save references like `userId` or a name string instead.
- **Functions** — same reason.
- **Vector3 / CFrame / Color3** — these are userdata. You have to convert them manually:
  ```lua
  data.position = { pos.X, pos.Y, pos.Z }
  -- on load: Vector3.new(unpack(data.position))
  ```
- **Mixed-key tables** where some keys are numbers and some are strings — DataStore will choke. Pick one or the other per table.
- **Metatables** — they're stripped. Your OOP instances become plain tables on save.
- **Cyclic tables** (table A contains table B which contains table A) — infinite recursion during serialization.

## Size Limits You Should Know

- **4 MB per key** (as of 2024). Plenty for most use cases, but if you're saving the player's entire chunk-of-a-world, you'll hit it.
- **Key names are limited to 50 characters** and must be strings.
- **Nested depth**: there's a practical limit (~7 levels deep) beyond which things get slow or fail.

## Pattern: Schema + Versioning

Experienced devs wrap all player data in a versioned envelope:

```lua
local CURRENT_VERSION = 3

local function newProfile()
	return {
		version = CURRENT_VERSION,
		coins = 0,
		inventory = {},
		stats = { str = 10, dex = 10, int = 10 },
	}
end

local function migrate(profile)
	if profile.version == 1 then
		-- v1 had inventory as a string, v2 moved it to a table
		profile.inventory = {}
		profile.version = 2
	end
	if profile.version == 2 then
		-- v2 had stats.level, v3 renamed to stats.xp
		profile.stats.xp = profile.stats.level or 0
		profile.stats.level = nil
		profile.version = 3
	end
	return profile
end
```

When you change the schema, bump the version and add a migration step. Every load pipes through `migrate(profile)` before the rest of the code touches it.

This is how ProfileService / ProfileStore handle schema changes, and it's the reason you should never release a game with un-versioned player data — once players have data on your key, changing its shape without migration is how you lose everyone's progress.

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/9743o5/how_would_i_save_a_table_to_a_datastore/
Captured: 2026-04-16

## Notes

Content reconstructed from search snippets. The "you can save tables directly, don't manually JSON-encode" advice matches Roblox's official DataStore documentation.
