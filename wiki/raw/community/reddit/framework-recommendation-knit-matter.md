---
title: Framework recommendation? (Knit, Matter, Nevermore, etc.)
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/slmxaj/framework_recommendation/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [frameworks, knit, matter, nevermore, flamework, architecture]
---

# Framework recommendation? (Knit, Matter, Nevermore)

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/slmxaj/

## The Question

> "I'm having trouble figuring out which ones have good documentation, examples, and might be efficient."

A recurring r/robloxgamedev question: which framework should I pick?

## Community Consensus

### Blunt take that the thread repeats
> "The industry standard framework for Roblox is: **none!**"

Frameworks are tools, not requirements. A lot of shipped Roblox games use zero external frameworks. Pick one only when you feel the pain of not having one.

### Where the OSS Discord discussion landed
> "For performance-related questions, you can use the Roblox OSS Community discord server, they have a knit channel."

The OSS community (Open Source Roblox) has channels for each major framework and is the go-to place for live help.

## The Landscape (Framework Options)

### Knit (Sleitnick)
- Lightweight server/client services framework.
- "Simplifies communication between core parts of your game and seamlessly bridges the gap between the server and the client."
- **Warning from the thread:** Knit has **stopped receiving updates**. Sleitnick published a post titled "Knit, its history, and how to build it better" indicating the project is effectively in maintenance mode.
- Still widely used, good for small-to-medium projects.

### Matter (evaera)
- ECS (Entity-Component-System) framework.
- Designed around deterministic state updates, great for multiplayer simulation, rollback, replication.
- Steep learning curve — ECS is a different mental model from services.
- Most popular choice for games that need predictable state (RTS, simulation, competitive multiplayer).

### Flamework (fireboltofdeath)
- TypeScript-first framework built for roblox-ts.
- Uses decorators and dependency injection, compiles to Luau.
- Not usable from plain Luau — you have to adopt roblox-ts.
- Extremely good DX if you're coming from TypeScript, NestJS, Angular, etc.

### Nevermore (Quenty)
- More of a module ecosystem than a framework.
- Massive library of small, well-tested utility modules (Rx, Signal, LifetimeComponent, Maid, etc.).
- Less opinionated about your project structure — just use the bits you need.

### Others Mentioned
- **AeroGameFramework** — Sleitnick's pre-Knit framework. Legacy at this point.
- **Roact / Fusion** — UI frameworks, not full game frameworks. Often composed with Knit or Matter.

## What the Thread Recommends

1. **For beginners**: Don't start with a framework. Build a small game with plain ModuleScripts first. You will not understand what a framework buys you until you've felt the pain it solves.
2. **For small/medium server-client games**: Knit is still fine, with the caveat that it's no longer being actively improved.
3. **For games that need rollback, determinism, or heavy state sync**: Matter.
4. **For TypeScript developers**: Flamework + roblox-ts.
5. **For libraries you pick and choose**: Nevermore via Wally.

## Key Insight

A frequent thread comment: **"Frameworks are patterns, not magic."** If you can't explain what a framework does for you in plain English ("services register with a central locator, RemoteEvents get generated automatically"), you will struggle to debug when it misbehaves. Learn the pattern first, use the framework second.

## Related

- Sleitnick's Medium post: "Knit, its history, and how to build it better"
- Matter docs: matter-ecs.github.io/matter
- Flamework docs: flamework.fireboltofdeath.dev
- Roblox OSS Community Discord

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/slmxaj/framework_recommendation/
Captured: 2026-04-16

## Notes

Content reconstructed from search snippets. The "no standard" consensus and the Knit/Matter/Flamework trichotomy match the current state of r/robloxgamedev, the DevForum, and the OSS Discord as of 2024-2026.
