---
title: Community Articles Index
type: index
captured_at: 2026-04-15
captured_by: research-agent-8
---

# Community Articles Index

Curated capture of the canonical community resources that define how Roblox / Luau developers actually work in 2026. Sources include GitHub READMEs of major libraries, DevForum community tutorials, official documentation pages, and the Roblox Lua Style Guide. All content is organized by subcategory below and is written as research notes rather than verbatim mirrors — each article synthesizes the authoritative content with explanatory context.

**Total articles:** 32

## datastore/

Deep dives on persistence libraries and DataStore patterns.

- **[datastore2-deep-dive.md](datastore/datastore2-deep-dive.md)** — Kampfkarren's DataStore2: caching, backup mode, combining stores, differences from ProfileService
- **[datastore-best-practices.md](datastore/datastore-best-practices.md)** — pcall, exponential backoff, request budget management, `SetAsync` vs `UpdateAsync`, `BindToClose` saves
- **[memorystore-leaderboards.md](datastore/memorystore-leaderboards.md)** — MemoryStoreService sorted maps, queues, hash maps, sharding strategies, leaderboard patterns, DataStore-vs-MemoryStore trade-offs

## networking/

Library READMEs and comparison guides for Roblox networking.

- **[bytenet-readme.md](networking/bytenet-readme.md)** — ffrostfall/ByteNet: buffer-serialized networking, strict-typed schemas, performance vs BridgeNet2
- **[bridgenet2-readme.md](networking/bridgenet2-readme.md)** — ffrostfall/BridgeNet2: single-RemoteEvent dispatch, one-arg payload constraint, superseded by ByteNet
- **[red-readme.md](networking/red-readme.md)** — red-blox/Red: compressed single-remote with namespaces, strict Luau, up to 75% bandwidth reduction
- **[networking-library-comparison.md](networking/networking-library-comparison.md)** — Decision guide: stock RemoteEvents vs Knit vs Red vs BridgeNet2 vs ByteNet, perf rankings, when to pick which

## security/

Server-authoritative patterns, RemoteEvent hardening, anti-cheat fundamentals.

- **[remote-event-security.md](security/remote-event-security.md)** — Rate limiting, type validation, sanity checks, async processing, the "intent vs outcome" rule, NaN handling
- **[anti-exploit-fundamentals.md](security/anti-exploit-fundamentals.md)** — Server-side speed/noclip/flight detection, rollback over ban, margin of error, combat validation, `time()` vs `tick()`
- **[anticheat-bad-practices.md](security/anticheat-bad-practices.md)** — What exploiters can do, why client-side detection fails, handshake systems, RemoteFunction vs RemoteEvent for signals

## frameworks/

Framework READMEs are in `library-readmes/`; the comparison is in `architecture/`. This subdirectory is currently empty — frameworks are grouped with other library READMEs because they follow the same capture template. See:

- `library-readmes/knit-readme.md`
- `library-readmes/flamework-readme.md`
- `library-readmes/matter-ecs-readme.md`
- `library-readmes/jecs-readme.md`
- `library-readmes/nevermore-readme.md`

## architecture/

Cross-cutting design patterns — OOP, FP, style, types, framework selection.

- **[luau-oop-patterns.md](architecture/luau-oop-patterns.md)** — Metatable-based classes, `__index`, typed `Impl`/`Proto` pattern, inheritance, module-as-object alternative
- **[luau-functional-programming.md](architecture/luau-functional-programming.md)** — Cryo, Sift, Freeze, Llama immutable data libraries; reducer patterns; when FP helps in Luau
- **[luau-type-annotations.md](architecture/luau-type-annotations.md)** — `--!strict`, primitives, optional types, unions, generics, `typeof(setmetatable(...))` pattern, `unknown` vs `any`
- **[roblox-lua-style-guide.md](architecture/roblox-lua-style-guide.md)** — Roblox's canonical Lua style guide: file structure, naming, `success, result` error pattern, classes
- **[framework-comparison.md](architecture/framework-comparison.md)** — Knit / Flamework / Matter / Jecs / Nevermore decision tree, paradigm split, framework combinations

## testing/

- **[testez-readme.md](testing/testez-readme.md)** — Roblox's BDD-style testing framework: describe/it/expect, chained assertions, reporters, `.spec.luau` discovery
- **[jest-lua-readme.md](testing/jest-lua-readme.md)** — jsdotlua's Jest port: matchers, mocks and spies, snapshot testing, timer mocks, Jest API parity

## tooling/

Build, deploy, lint, format.

- **[rojo-readme.md](tooling/rojo-readme.md)** — Filesystem sync for Roblox: project JSON, live sync, `rojo build`, the foundation of modern OSS tooling
- **[wally-readme.md](tooling/wally-readme.md)** — Package manager: wally.toml, lockfiles, realms, registries, the dep system that makes libraries installable
- **[stylua-readme.md](tooling/stylua-readme.md)** — Deterministic Luau formatter: configuration, ignore directives, `--check` mode, editor integration
- **[selene-readme.md](tooling/selene-readme.md)** — Modern Luau linter: Rust-based, Roblox standard library, custom lints, bug-catching philosophy
- **[github-actions-roblox-cicd.md](tooling/github-actions-roblox-cicd.md)** — End-to-end CI/CD: Rojo build → Open Cloud publish → Luau Execution API tests → production branch deploy

## library-readmes/

Foundational library documentation — the canonical set every modern Roblox project references.

### Data persistence
- **[profileservice-readme.md](library-readmes/profileservice-readme.md)** — loleris's session-locked profile API: `:LoadProfileAsync`, `:Reconcile`, `GlobalUpdates`, MetaTags
- **[profilestore-readme.md](library-readmes/profilestore-readme.md)** — Successor to ProfileService: 300 s auto-save, MessagingService handoff, `LastSavedData`, `MessageAsync`

### Frameworks
- **[knit-readme.md](library-readmes/knit-readme.md)** — Sleitnick's Services/Controllers framework (archived but widely used)
- **[flamework-readme.md](library-readmes/flamework-readme.md)** — Decorator-based DI framework for roblox-ts
- **[matter-ecs-readme.md](library-readmes/matter-ecs-readme.md)** — Modern ECS with archetype storage, topological hooks, built-in debugger
- **[jecs-readme.md](library-readmes/jecs-readme.md)** — Stupidly fast pure-Luau ECS with first-class entity relationships
- **[nevermore-readme.md](library-readmes/nevermore-readme.md)** — Quenty's 270-module library pool with npm-based dep management

### UI
- **[fusion-readme.md](library-readmes/fusion-readme.md)** — Reactive UI library: scopes, Values, Computeds, `New()`, Hydrate, ForValues, Springs, Tweens

### Utilities
- **[trove-readme.md](library-readmes/trove-readme.md)** — Sleitnick's cleanup task tracker: Add, Connect, Extend, AttachToInstance
- **[promise-readme.md](library-readmes/promise-readme.md)** — evaera's Promise/A+ implementation: chaining, composition, cancellation, `:promisify`
- **[goodsignal-readme.md](library-readmes/goodsignal-readme.md)** — stravant's leak-free pure-Lua signal with RBXScriptSignal API parity

## Notable recurring patterns

Across the captured articles, a few patterns show up everywhere and are worth surfacing:

### ProfileService/ProfileStore is universally recommended for player data

Every guide, every library comparison, every best-practices post eventually points to ProfileService or its successor ProfileStore as the default answer. The only DataStore alternatives that get serious consideration are DataStore2 (for games without trading) and raw DataStores (for very simple games or very specific patterns). Rolling your own session-locking implementation is explicitly discouraged.

### The Rojo + Wally + StyLua + Selene quartet is the modern OSS baseline

These four tools together are what separate "a Roblox project" from "a modern software project." Every framework, every library, every tutorial in the 2026 ecosystem assumes this foundation. A project that doesn't use Rojo (filesystem sync) is effectively locked out of installing community libraries via Wally, can't be formatted with StyLua, can't be linted with Selene, and can't be CI-tested.

### Server-authoritative everything

Every security article lands on the same answer: the server must derive every important outcome from its own authoritative state, and the client is only allowed to express *intent*. Client-side anticheat is explicitly described as a deterrent against script consumers rather than a real security boundary.

### Single-RemoteEvent dispatch for performance

All three modern networking libraries (Red, BridgeNet2, ByteNet) share the same core trick: one physical RemoteEvent, numeric event IDs, dispatch in user-space. The specific encoding of the payload varies (Red uses compressed tables, ByteNet uses declared buffers) but the architectural idea is universal.

### Knit is archived but still widely used

The most culturally interesting observation: Knit's archive notice is prominent but has not actually killed its adoption. The API is stable enough that "unmaintained" doesn't mean "unusable," and community momentum behind Knit's service/controller pattern is too strong to displace. Flamework wins for new TypeScript projects; Knit remains the default for Luau-only projects that don't want ECS.

### Trove > Janitor > BindableEvent-wrapped signal

The Roblox community has converged on Trove (or an equivalent cleanup-tracker primitive) as the default lifetime management tool, replacing the older Janitor/Maid patterns. Similarly, custom signals have converged on GoodSignal's API as the canonical shape, displacing BindableEvent wrappers.

## Articles not captured that would be valuable

A few resources I attempted to fetch but got thin or redirected results from — useful follow-ups for deeper coverage:

- **Full `rbxts-flamework/core` README** — the public README is very terse (it just points to the external docs site). The docs site at https://flamework.fireboltofdeath.dev/docs/introduction has the substantive content.
- **BenchmarkLabs** — independent perf comparisons between networking libraries and ECS implementations. Most exist only on Twitter/Discord and are hard to cite.
- **Specific Medium posts by named authors** — Medium's search indexes Roblox content poorly, and most prolific Roblox bloggers have moved to DevForum community tutorials (which agent 6 covers). The "Medium-native" Roblox writing I found duplicated material already captured from canonical sources.
- **Roact2 / react-lua** — Roblox's successor to Roact. Listed in search results but the README is terse; the proper place to link developers is still-evolving.
- **Quenty's Rx library (@quenty/rxlua)** — mentioned in the Nevermore article but warrants its own deep dive. Not captured here.
- **DataStore2 full API reference** — the docs site is comprehensive but I captured only the high-level usage patterns. A dedicated API reference article could be valuable for teams maintaining DataStore2 codebases.
- **Open Cloud Luau Execution API full walkthrough** — the CI/CD demo covers this at a high level; an end-to-end tutorial with real example scripts would be valuable.

---

**Captured by:** research-agent-8 of 10 for the FoG-Roblox-Studio-Command wiki
**Base path:** `wiki/raw/community/articles/`
**Date:** 2026-04-15
