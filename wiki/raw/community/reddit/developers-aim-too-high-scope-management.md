---
title: Why do most developers on here aim way too high? (Scope management)
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/1c90jfg/why_do_most_developers_on_here_aim_way_to_high/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [scope, project-management, mvp, beginner-advice, anti-patterns]
---

# Why do most developers on here aim way too high? (Scope Management)

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/1c90jfg/

## The Original Observation

The poster (who identifies as a player rather than a developer themselves) describes a pattern they see constantly in the subreddit:

> "A lot of people I see on this sub are new to game development in Lua and they have great ideas! The problem is they think it's easy to code said idea."

This is one of the most common failure modes in r/robloxgamedev and the thread captures the community's standard advice for it.

## Why New Developers Over-Scope

The thread identifies several recurring patterns:

1. **Inspiration from finished games.** New developers play Adopt Me, Blox Fruits, or Doors and think "I want to make that." But the games they're inspired by are the output of years of iteration by large teams.
2. **Not knowing what they don't know.** A "simple" feature like "inventory with drag-and-drop" touches UI, animation, hit detection, data serialization, replication, and anti-exploit — each of which is its own rabbit hole.
3. **Confusing conception with execution.** Describing a game takes 15 minutes. Building a production-quality MMORPG takes 5+ years of full-time work.
4. **Ignoring the asset cost.** Even a finished script engine needs models, textures, audio, animation, and UI art. A solo dev rarely can do all of these at production quality.

## The Community's Standard Advice

### 1. Start with a genre you can finish in 2-3 weeks
- A Tycoon
- An Obby
- A short round-based PvP arena
- A clicker game with a progression loop

These teach the full "build, test, publish, iterate" cycle in the minimum time. Your tenth small game will be way more impressive than your first abandoned MMO.

### 2. Build a Vertical Slice, Not a Horizontal Plan
Instead of writing a 40-page design doc for your dream game and then trying to build every system, pick **one gameplay moment** and make it fully playable and fun. If that single moment isn't fun, the rest of the game doesn't matter.

### 3. Ship Something Broken
Publishing a rough, unfinished game to Roblox — even to a private server for 5 friends — teaches you more than polishing a Studio-only prototype for 6 months. Real players break things in ways you never predicted.

### 4. The "3-Week Rule"
A community heuristic that shows up in this thread and elsewhere:

> "Spend at least 3 weeks watching basic YouTube tutorials and practicing either building, programming, animation, etc., to see if you even like it first."

If after 3 weeks of honest effort you still love it, commit more. If you hate it, you haven't lost much.

### 5. Scale with Skill
Your project should be *slightly* harder than your last one. Not 10x harder. If the last thing you finished was a door that opens when you touch it, your next project should not be "a 64-player persistent open-world RPG."

## Recurring Quotes From This Cluster of Threads

- "Your first game should be something you can finish in a weekend."
- "Finish ugly games before you try to make beautiful ones."
- "If you can't finish a clicker, you can't finish an MMO."
- "Scope is the biggest killer of Roblox games, not skill."

## The Meta-Lesson For A Wiki

When answering "I want to make [ambitious game], where do I start?", the correct community answer is almost never "here's a tutorial for the system you asked about." It's "here's a smaller version of your idea you can finish, come back when you've finished it and we'll help you with the next step."

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/1c90jfg/why_do_most_developers_on_here_aim_way_to_high/
Captured: 2026-04-16

## Related Posts (same theme)
- "I just started Roblox development, what should I learn first" — /r/robloxgamedev/comments/198osy6/
- "Roblox Game Development Beginner's Guide" — /r/robloxgamedev/comments/vqr513/
- "How to learn to make a game?" — /r/robloxgamedev/comments/1d6rllk/

## Notes

Content reconstructed from search snippets. The scope-management theme is one of the most consistent pieces of advice across the entire subreddit.
