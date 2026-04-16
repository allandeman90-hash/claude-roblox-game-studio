---
title: NevermoreEngine — Quenty's ModuleScript Loader and Utility Suite
type: raw-source
source_url: https://github.com/Quenty/NevermoreEngine
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: framework
author: Quenty (James Onnen)
tags: [nevermore, loader, framework, npm, modules]
---

# NevermoreEngine — Quenty's ModuleScript Loader and Utility Suite

**Author:** Quenty (James Onnen)
**Source:** GitHub — `Quenty/NevermoreEngine`
**Docs:** https://quenty.github.io/NevermoreEngine/

## What it is

Nevermore is a portable ModuleScript loader for Roblox, and also the name for the collection of utility libraries that ship with it. As of the current release, Nevermore contains **270 packages** spanning common problems — signals, springs, networking, state management, promises, UI primitives, math utilities, and more. It is used in all of Studio Koi Koi's games and in many other shipped titles.

Where Knit and Flamework are opinionated frameworks that prescribe a Services/Controllers layout, Nevermore is more like a standard library: a huge pool of battle-tested modules you can pick from, plus a loader that handles dependency resolution between them.

## Package management via npm

Nevermore is unusual in the Roblox world: it uses npm (or pnpm) to manage packages rather than Wally. Each package in the 270-module collection is published as an npm scope under `@quenty/<name>`, and a project consumes them by running:

```bash
npm install @quenty/loader @quenty/signal @quenty/promise @quenty/springutils
```

This is a deliberate choice. npm gives Nevermore:
- **Semantic versioning** with npm's well-tested resolver
- **Transitive dependencies** — a package like `@quenty/input` can depend on `@quenty/signal` and npm handles it
- **A mature tooling ecosystem** — diff tools, audit tools, etc.

The trade-off is that Roblox developers coming from the Wally world have to learn a bit of Node tooling to use Nevermore. Installation takes 2–3 minutes if you already have Node.js v14+ and Rojo v7+ installed.

## The loader

At the heart of Nevermore is `@quenty/loader`, a single ModuleScript that walks a directory of modules, resolves dependencies by name, and exposes them through a unified `require`-by-string API:

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local require = require(ServerScriptService:WaitForChild("Nevermore"))

local Signal = require("Signal")
local Promise = require("Promise")
local SpringUtils = require("SpringUtils")
```

Note: `require("Signal")` is not a path — it's a logical name the loader resolves by searching known module locations. This decouples consumer code from physical file location. You can move `Signal.luau` anywhere in your project and `require("Signal")` keeps working.

## Shared language of modules

Nevermore's real value proposition is that it provides "a shared language to build a game with." Instead of every project reinventing `Signal`, `Promise`, `Trove`, `Spring`, and `Maid`, Nevermore ships canonical implementations of each. If you read one Nevermore game's source, another Nevermore game's source looks immediately familiar.

Some notable modules from the 270:

- **`@quenty/maid`** — cleanup tracker similar to Trove/Janitor
- **`@quenty/signal`** — RBXScriptSignal-compatible custom signal
- **`@quenty/promise`** — Promise implementation
- **`@quenty/spring`** — critically damped spring for animation
- **`@quenty/inputkeymaputils`** — input mapping utilities
- **`@quenty/binder`** — tag-based Instance binding (CollectionService helper)
- **`@quenty/servicebag`** — dependency injection container
- **`@quenty/playersservice`** — players tracker with connect-style events
- **`@quenty/ragdoll`** — ragdoll controller
- **`@quenty/rxlua`** — reactive programming primitives (like RxJS)

The Rx port is especially distinctive — few other Roblox libraries offer observable-based async composition at this scale.

## Why it's different from Knit/Flamework

Knit and Flamework are **opinionated frameworks**: you write Services/Controllers, they handle boot and networking, and there's one right way to structure a project. Nevermore is an **unopinionated library pool**: you use whichever pieces solve your current problem and structure the rest however you like.

This makes Nevermore:
- More flexible (pick and choose)
- Less prescriptive (no framework contract)
- Harder for beginners (no hand-holding)
- Easier to gradually adopt in existing codebases (just install one module)

## Who uses it

- All Studio Koi Koi games (Quenty's own studio)
- Many Roblox titles that started before Knit became popular
- Developers who prefer a "standard library" mental model over a "framework" one

The community trend since ~2022 has been toward Knit/Flamework for new projects, but Nevermore's modules are still widely referenced as reference implementations of common patterns.

## Installation notes

1. Install Node.js v14+ and Rojo v7+
2. Run `npm install @quenty/loader` plus whatever other modules you want
3. Configure Rojo to sync the `node_modules/@quenty/*` trees into ReplicatedStorage
4. Require the loader and start using `require("ModuleName")`

The full install doc with boilerplate rojo project JSON is at https://quenty.github.io/NevermoreEngine/docs/install/.

## Source

Original URL: https://github.com/Quenty/NevermoreEngine
Docs: https://quenty.github.io/NevermoreEngine/
Captured: 2026-04-15
