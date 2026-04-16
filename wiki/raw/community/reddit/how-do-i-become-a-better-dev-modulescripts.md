---
title: How do I become a better dev? (specifically about module scripts)
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/1cndm61/how_do_i_become_a_better_dev_specifically/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [module-scripts, architecture, career-advice, learning, OOP]
---

# How do I become a better dev? (specifically about module scripts)

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/1cndm61/

## The Question

> "I really want to learn how to use module scripts efficiently but I feel there's a lack of tutorials on anything but the basics on how they work, not how to use them."

This is a very common complaint in r/robloxgamedev: every tutorial shows you the syntax of `local module = {}; return module` but almost nothing explains *when* and *how* to actually structure your codebase around modules.

## Top Community Advice

### 1. Finish projects (any project)
> "Spend at least 3 weeks watching basic YouTube tutorials and practicing either building, programming, animation, etc."

The recurring advice is to stop chasing "the right way" and instead finish a series of small projects. Each finished project:
- Forces you to make architectural decisions and see the consequences.
- Builds muscle memory for the API.
- Becomes portfolio material.
- Teaches you which bits of the last project were a pain, so you refactor next time.

Quote: "Completing projects helps you build a habit of finishing things, it lets you practice and experience every stage of game development, and it builds up your portfolio."

### 2. Read OTHER people's code
A frequent recommendation: read the Sleitnick modules (Knit, Comm, Signal), the evaera modules (Promise, Roact), osyris' code. Open an uncopylocked game that has a reputation for being well-structured and just click through the Explorer looking at how files are organized.

### 3. Research, don't just practice blindly
> "Research optimization techniques and superior methodologies by exploring forums and online resources related to specific challenges."

When you hit a problem, stop and search. Most problems you will hit have a canonical solution that someone on the DevForum or Reddit has already worked out.

### 4. Reality check from an 8-year developer
> "Roblox development faces challenges — you gotta do a lot of extra work that you wouldn't have to do in most other engines."

The platform has quirks (state sync, undocumented behaviour, DataStore rate limits, Studio crashes) that are part of the job. Accept them early.

## On Module Scripts Specifically

### The "Script Per System" Pattern
Most experienced Roblox devs converge on roughly this structure:

- One small bootstrap Script on the server (e.g., `Main.server.lua`) that `require`s a ServerScriptService folder full of ModuleScripts.
- One small bootstrap LocalScript on the client (e.g., `Main.client.lua`) that `require`s a ReplicatedStorage folder of ModuleScripts.
- Each gameplay system (DamageService, InventoryService, ShopService…) is a ModuleScript with a consistent shape (e.g., a `.Start()` method).
- All state lives in the module; scripts just kick off the modules.

This is essentially the Knit/Flamework/Matter pattern, and it's what frameworks formalize.

### The Anti-Pattern the Thread Calls Out
Having dozens of individual Scripts in `ServerScriptService`, each handling one RemoteEvent. This makes it impossible to share helpers, hard to control startup order, and annoying to turn off for testing.

Replace them with a single Script that requires module-per-feature.

### Useful Module Tricks
- **Expose a table of functions, not a singleton with hidden state** — unless you *want* a singleton.
- **Return a class constructor** (`Module.new(...)`) when you need multiple instances (enemies, shops, quests).
- **Don't put `task.wait` or yields at the top of a ModuleScript** — it will block every `require`.
- **Don't require a module multiple times expecting fresh state** — `require` caches the return value per environment. If you need a fresh instance, use a `.new()` constructor.

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/1cndm61/how_do_i_become_a_better_dev_specifically/
Captured: 2026-04-16

## Notes

Content reconstructed from search snippets. The "script per system" pattern is the de facto standard in r/robloxgamedev, the DevForum, and every major framework (Knit, Flamework, AGF).
