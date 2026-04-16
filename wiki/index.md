---
title: Wiki Index
type: wiki-index
updated: 2026-04-16
page_count: 108
---

# Wiki Index

**Last updated:** 2026-04-16
**Total pages:** 108 (plus `SCHEMA.md`, `README.md`, `log.md`, `raw/`)

Content catalog organized by category. Each entry shows `owner` and `status`. Click a `[[page]]` to navigate.

---

## Services (28)

Roblox class / service reference pages.

### Persistence
- [[DataStoreService]] — key-value persistent store. `datastore-architect` `complete`
- [[GlobalDataStore]] — handle returned by `GetDataStore`. `datastore-architect` `stub`
- [[OrderedDataStore]] — sorted numeric variant for leaderboards. `datastore-architect` `stub`
- [[MemoryStoreService]] — short-lived cross-server state. `live-ops-specialist` `stub`

### Networking
- [[RemoteEvent]] — fire-and-forget messaging. `remotes-networking-specialist` `complete`
- [[RemoteFunction]] — request-response (server → client only). `remotes-networking-specialist` `complete`
- [[UnreliableRemoteEvent]] — cosmetic packet-loss-tolerant messaging. `remotes-networking-specialist` `complete`
- [[BindableEvent]] — same-side pub/sub. `luau-systems-programmer` `stub`
- [[MessagingService]] — cross-server pub/sub. `live-ops-specialist` `stub`
- [[TeleportService]] — place-to-place teleportation. `luau-systems-programmer` `stub`
- [[HttpService]] — outbound HTTP and JSON utilities. `luau-systems-programmer` `stub`

### Players
- [[Players]] — player lifecycle service. `luau-gameplay-programmer` `stub`
- [[Player]] — individual player instance. `luau-gameplay-programmer` `stub`
- [[Humanoid]] — character movement and health. `luau-gameplay-programmer` `stub`

### Monetization
- [[MarketplaceService]] — GamePass / DevProduct transactions. `monetization-lead` `complete`

### Architecture containers
- [[ServerScriptService]] — active server scripts. `technical-director` `stub`
- [[ServerStorage]] — server-only data/modules. `technical-director` `stub`
- [[ReplicatedStorage]] — shared modules. `technical-director` `stub`

### Runtime / input / UI / audio / world
- [[RunService]] — frame loop events. `luau-systems-programmer` `stub`
- [[UserInputService]] — raw input events. `ui-programmer` `stub`
- [[ContextActionService]] — cross-input action binding. `ui-programmer` `stub`
- [[ProximityPrompt]] — contextual interaction UI. `luau-gameplay-programmer` `stub`
- [[CollectionService]] — tag-based entity-component pattern. `roblox-studio-specialist` `stub`
- [[TextChatService]] — modern chat system. `ui-programmer` `stub`
- [[TweenService]] — property interpolation. `ui-programmer` `stub`
- [[SoundService]] — global audio config. `sound-designer` `stub`
- [[Sound]] — individual sound instance. `sound-designer` `stub`
- [[SoundGroup]] — sound routing / volume mixing. `sound-designer` `stub`
- [[Workspace]] — the 3D world container. `level-designer` `stub`
- [[Lighting]] — global lighting and effects. `technical-artist` `stub`

---

## Concepts (14)

Architectural patterns and mental models.

- [[server-authority]] — never trust the client. `technical-director` `complete`
- [[client-server-split]] — three-zone architecture. `technical-director` `complete`
- [[session-locking]] — prevents item duplication. `datastore-architect` `complete`
- [[schema-versioning]] — evolve data shape safely. `datastore-architect` `complete`
- [[bind-to-close]] — shutdown-time save handler. `datastore-architect` `complete`
- [[rate-limiting]] — cap per-player remote calls. `remotes-networking-specialist` `complete`
- [[trove-maid-cleanup]] — resource disposal pattern. `luau-systems-programmer` `complete`
- [[signal-pattern]] — custom event/signal libraries. `luau-systems-programmer` `stub`
- [[service-pattern]] — module lifecycle abstraction. `luau-systems-programmer` `stub`
- [[streaming-enabled]] — dynamic workspace streaming. `level-designer` `stub`
- [[module-lazy-loading]] — deferred module requires. `luau-systems-programmer` `stub`
- [[feature-flags]] — runtime-toggleable features. `live-ops-specialist` `stub`
- [[cross-server-events]] — coordinating state across servers. `live-ops-specialist` `stub`
- [[atomic-trading]] — all-or-nothing item exchange. `economy-designer` `stub`
- [[code-redemption]] — server-validated promo codes. `live-ops-specialist` `stub`
- [[ftue-design]] — first-time user experience. `game-designer` `stub`
- [[core-loop]] — 30s / 5min / session / meta loops. `game-designer` `stub`

---

## Luau (10)

Luau language features.

- [[type-annotations]] — gradual type system. `luau-systems-programmer` `complete`
- [[task-library]] — modern concurrency primitives. `luau-systems-programmer` `complete`
- [[export-type]] — sharing types across modules. `luau-systems-programmer` `stub`
- [[generic-types]] — `<T>` parameters. `luau-systems-programmer` `stub`
- [[pcall-xpcall]] — error handling. `luau-systems-programmer` `stub`
- [[coroutines]] — raw cooperative threads. `luau-systems-programmer` `stub`
- [[table-library]] — Luau-specific table extensions. `luau-systems-programmer` `stub`
- [[string-library]] — string manipulation. `luau-systems-programmer` `stub`
- [[math-library]] — math with Luau extensions. `luau-systems-programmer` `stub`
- [[buffer-type]] — binary byte buffers. `luau-systems-programmer` `stub`

---

## Anti-Patterns (14)

Things NOT to do, with fixes.

### Deprecated APIs
- [[deprecated-wait]] — use `task.wait`. `lead-programmer` `complete`
- [[deprecated-spawn]] — use `task.spawn`. `lead-programmer` `stub`
- [[deprecated-delay]] — use `task.delay`. `lead-programmer` `stub`

### Security
- [[client-trust]] — never trust client values. `exploit-security-specialist` `complete`
- [[unvalidated-remote-args]] — validate every argument. `remotes-networking-specialist` `complete`
- [[no-rate-limit]] — missing rate limiter on remotes. `remotes-networking-specialist` `stub`
- [[client-to-server-remote-function]] — server hang risk. `remotes-networking-specialist` `stub`
- [[instance-in-remote]] — use string IDs. `remotes-networking-specialist` `stub`

### Persistence
- [[no-session-lock]] — duplication exploit. `datastore-architect` `stub`
- [[no-pcall]] — unhandled DataStore errors. `lead-programmer` `stub`
- [[player-name-as-key]] — UserId-keyed only. `datastore-architect` `stub`
- [[missing-schema-version]] — un-migrateable data. `datastore-architect` `stub`

### Code quality / performance
- [[magic-numbers]] — externalize to config. `lead-programmer` `stub`
- [[print-in-production]] — use logger. `lead-programmer` `stub`
- [[string-concat-in-loop]] — use `table.concat`. `performance-analyst` `stub`

---

## Exploits (7)

Roblox attack catalog.

### Movement
- [[speed-hack]] — move faster than allowed. `exploit-security-specialist` `complete`
- [[teleport-hack]] — arbitrary CFrame jumps. `exploit-security-specialist` `stub`
- [[fly-hack]] — remove gravity/collision. `exploit-security-specialist` `stub`
- [[noclip]] — pass through walls. `exploit-security-specialist` `stub`

### Economy
- [[item-duplication]] — cross-server data race. `exploit-security-specialist` `complete`
- [[transaction-replay]] — replay DevProduct. `exploit-security-specialist` `stub`

### Remote
- [[remote-spam]] — DoS via rate-unlimited remote. `exploit-security-specialist` `stub`
- [[argument-spoofing]] — invalid types through remote. `exploit-security-specialist` `stub`

---

## Performance (6)

Budgets, profiling, optimization patterns.

- [[heartbeat-budget]] — 16.67 ms frame target. `performance-analyst` `stub`
- [[microprofiler]] — built-in profiler tool. `performance-analyst` `stub`
- [[server-memory-budget]] — ~6.4 GB base + per-player. `performance-analyst` `stub`
- [[bandwidth-budget]] — 50 KB/s per player. `performance-analyst` `stub`
- [[object-pooling]] — reuse Instances. `performance-analyst` `stub`
- [[draw-call-optimization]] — < 500 draw calls. `technical-artist` `stub`

---

## Monetization (8)

GamePass, DevProduct, payouts, ethics.

- [[game-pass]] — permanent purchases. `monetization-lead` `stub`
- [[dev-product]] — consumable purchases. `monetization-lead` `stub`
- [[process-receipt-idempotency]] — mission-critical pattern. `monetization-lead` `complete`
- [[premium-benefits]] — Roblox Premium perks. `monetization-lead` `stub`
- [[engagement-based-payouts]] — EBP / Creator Rewards. `monetization-lead` `stub`
- [[robux-price-tiers]] — 80/400/800/1700/4500/10000 tiers. `monetization-lead` `stub`
- [[developer-exchange]] — DevEx conversion rate. `monetization-lead` `stub`
- [[ethical-monetization]] — child-safe design rules. `monetization-lead` `stub`

---

## Studio (6)

Studio workflows, tooling, APIs.

- [[rojo-mapping]] — file-to-instance sync. `devops-engineer` `stub`
- [[wally-packages]] — package manager. `devops-engineer` `stub`
- [[collection-service-tags]] — Binder pattern. `roblox-studio-specialist` `stub`
- [[attributes]] — typed key-value on instances. `roblox-studio-specialist` `stub`
- [[open-cloud-api]] — external REST APIs. `devops-engineer` `stub`
- [[play-solo-team-test]] — Studio testing modes. `roblox-studio-specialist` `stub`

---

## Patterns (6)

Game design patterns implemented in Roblox.

- [[daily-rewards]] — escalating login streaks. `game-designer` `stub`
- [[code-redemption-system]] — promo code implementation. `live-ops-specialist` `stub`
- [[quest-system]] — server-authoritative quest progression. `game-designer` `stub`
- [[inventory-pattern]] — itemId → quantity map. `luau-gameplay-programmer` `stub`
- [[trading-system]] — atomic player-to-player trades. `economy-designer` `stub`
- [[leaderboard-pattern]] — OrderedDataStore + MemoryStore. `luau-gameplay-programmer` `stub`

---

## Raw Sources (378 files)

Captured from:
- **`raw/roblox-creator-docs/services/`** — 43 Roblox class references (agent-1)
- **`raw/roblox-creator-docs/luau/`** — 28 Luau language topics (agent-2)
- **`raw/roblox-creator-docs/tutorials/`** — 25 official tutorials (agent-3)
- **`raw/roblox-creator-docs/best-practices/`** — 112 security/perf/publishing/monetization guides (agent-4)
- **`raw/luau-spec/`** — 53 formal Luau spec files and RFCs (agent-5)
- **`raw/community/devforum/`** — 42 DevForum tutorials and resources (agent-6)
- **`raw/community/reddit/`** — 22 Reddit guides and Q&A (agent-7)
- **`raw/community/articles/`** — 34 Medium articles, blog posts, library READMEs (agent-8)
- **`raw/community/performance/`** — 31 performance/profiling resources (agent-9)
- **`raw/community/monetization/`** — 30 monetization and live-ops resources (agent-10)

See `wiki/raw/README.md` for details.

---

## Status Summary

| Status | Count |
|---|---|
| complete | ~20 |
| stub | ~88 |
| draft | 0 |
| needs-review | 0 |
| superseded | 0 |

Stubs have minimal content and a TODO list. They exist so that `[[wikilinks]]` resolve. Flesh them out via `/wiki-ingest` from raw sources.

---

## Operations

- `/wiki-ingest <source>` — integrate a raw source
- `/wiki-query <question>` — query the wiki
- `/wiki-lint` — health check
- `/wiki-update <page>` — targeted edit
- `/wiki-seed` — (already run — do not re-run)

See [[SCHEMA]] for the full maintenance protocol.
