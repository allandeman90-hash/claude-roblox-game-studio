---
title: Nevermore
type: library
category: libraries
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/nevermore-readme.md
  - wiki/raw/community/articles/architecture/framework-comparison.md
related: [[[Knit]], [[Flamework]], [[framework-comparison]]]
tags: [library, framework, utility, npm, modules]
---

# Nevermore

> 270-package utility collection with a ModuleScript loader. An unopinionated "standard library" for Roblox, distributed via npm.

## Summary

NevermoreEngine by Quenty (James Onnen) is a portable ModuleScript loader plus a collection of 270 battle-tested utility packages spanning signals, springs, networking, state management, promises, UI primitives, math utilities, input mapping, reactive programming, and more. Unlike [[Knit]] and [[Flamework]], which prescribe a Services/Controllers architecture, Nevermore is an unopinionated library pool: pick the modules you need and structure the project however you like. It is used in all Studio Koi Koi games and many other shipped titles.

**Maintainer:** Quenty (James Onnen)
**Status:** Active
**Distribution:** npm (not Wally)

## Installation

Nevermore uses npm/pnpm rather than Wally. Requires Node.js v14+ and Rojo v7+.

```bash
npm install @quenty/loader @quenty/signal @quenty/promise @quenty/springutils
```

Configure Rojo to sync `node_modules/@quenty/*` into `ReplicatedStorage`. The loader resolves dependencies by name at runtime.

## Quick Start

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local require = require(ServerScriptService:WaitForChild("Nevermore"))

-- Require by logical name, not path
local Signal = require("Signal")
local Promise = require("Promise")
local Maid = require("Maid")
local Spring = require("Spring")
```

The loader walks module directories, resolves dependencies by name, and decouples consumer code from physical file location. Moving `Signal.luau` anywhere in the project does not break `require("Signal")`.

## Key Modules (from 270)

| Package | Description |
|---------|-------------|
| `@quenty/maid` | Cleanup tracker (similar to [[Trove]] / Janitor). |
| `@quenty/signal` | RBXScriptSignal-compatible custom signal (similar to [[GoodSignal]]). |
| `@quenty/promise` | Promise implementation (similar to evaera's [[Promise]]). |
| `@quenty/spring` | Critically damped spring for animation. |
| `@quenty/binder` | Tag-based Instance binding (CollectionService helper). |
| `@quenty/servicebag` | Dependency injection container. |
| `@quenty/inputkeymaputils` | Input mapping utilities. |
| `@quenty/ragdoll` | Ragdoll physics controller. |
| `@quenty/rxlua` | Reactive programming primitives (like RxJS). Distinctive -- few other Roblox libraries offer this. |
| `@quenty/playersservice` | Players tracker with connect-style events. |

## When to Use / When Not to Use

**Use when:**
- You want to pick individual, battle-tested modules without adopting a framework contract
- Gradually adopting into an existing codebase (install one module at a time)
- You prefer a "standard library" mental model over an opinionated framework
- You need reactive programming primitives (`@quenty/rxlua`) not available elsewhere

**Do not use when:**
- You want a prescribed project structure with clear boot ordering (use [[Knit]] or [[Flamework]])
- The team is not comfortable with Node.js/npm tooling
- You want Wally-based package management (Nevermore is npm-only)

## npm vs. Wally

Nevermore's use of npm is deliberate:

| Aspect | npm (Nevermore) | Wally (most Roblox libs) |
|--------|----------------|--------------------------|
| Dependency resolution | Mature, well-tested semantic versioning | Newer, Roblox-specific |
| Transitive dependencies | Handled by npm automatically | Handled by Wally |
| Tooling ecosystem | Very large (audit, diff, etc.) | Growing |
| Familiarity for Roblox devs | Requires Node.js knowledge | Native to Roblox workflow |

## Alternatives

| Library | Trade-off |
|---------|-----------|
| [[Knit]] | Prescribed framework with auto-networking. More structure, less flexibility. |
| [[Flamework]] | TypeScript-native framework with DI. Requires roblox-ts. |
| Individual Wally packages | Pick specific libs (Trove, GoodSignal, Promise) without Nevermore's loader. |
| Stock Roblox + Rojo | No abstraction, fully manual. |

## Related

- [[Knit]] -- prescribed framework alternative
- [[Flamework]] -- TypeScript framework alternative
- [[framework-comparison]] -- decision guide

## Sources

- [Nevermore README](wiki/raw/community/articles/library-readmes/nevermore-readme.md)
- [Framework Comparison](wiki/raw/community/articles/architecture/framework-comparison.md)
- GitHub: https://github.com/Quenty/NevermoreEngine
- Docs: https://quenty.github.io/NevermoreEngine/
