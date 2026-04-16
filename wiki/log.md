# Wiki Log

Append-only chronological log of wiki operations. Format:

```
## [YYYY-MM-DD] <operation> | <short description>
```

Parse with: `grep "^## \[" wiki/log.md | tail -N`

---

## [2026-04-15] research | Phase 3 — UI Frameworks, Physics Constraints, Camera Modes

Phase 3 research agent captured raw sources and created wiki pages for three zero-coverage topic groups.

### Raw Sources Captured (12 files)

**UI Frameworks (6 files):**
- `wiki/raw/community/articles/ui-frameworks/fusion-vs-react-lua-devforum.md`
- `wiki/raw/community/articles/ui-frameworks/use-case-for-frameworks-devforum.md`
- `wiki/raw/community/articles/ui-frameworks/roact-crash-course-devforum.md`
- `wiki/raw/community/articles/ui-frameworks/responsive-gui-all-devices-devforum.md`
- `wiki/raw/community/articles/ui-frameworks/udim2-anchorpoint-positioning-devforum.md`
- `wiki/raw/community/articles/ui-frameworks/accessibility-settings-devforum.md`

**Physics (4 files):**
- `wiki/raw/community/articles/physics/mechanical-constraints-overview.md`
- `wiki/raw/community/articles/physics/vehicle-constraints-tutorial-devforum.md`
- `wiki/raw/community/articles/physics/scripted-car-physics-devforum.md`
- `wiki/raw/community/articles/physics/motor6d-usage-devforum.md`

**Camera (5 files):**
- `wiki/raw/community/articles/camera/third-person-camera-tutorial-devforum.md`
- `wiki/raw/community/articles/camera/third-person-camera-system-devforum.md`
- `wiki/raw/community/articles/camera/isometric-camera-devforum.md`
- `wiki/raw/community/articles/camera/cutscene-camera-tutorial-devforum.md`
- `wiki/raw/community/articles/camera/first-third-person-toggle-devforum.md`

### Wiki Pages Created (6 pages, all status: draft)
- `wiki/patterns/ui-framework-comparison.md` — Roact vs React-lua vs Fusion vs Native
- `wiki/patterns/responsive-design.md` — Mobile-first, UDim2, layout objects, accessibility integration
- `wiki/patterns/accessibility-patterns.md` — ReducedMotion, PreferredTransparency, contrast, touch targets
- `wiki/concepts/constraints-guide.md` — All 13+ constraint types, Motor6D, vehicle physics patterns
- `wiki/patterns/camera-modes.md` — First-person, third-person, isometric, cutscene, toggle
- Index entry added: `wiki/patterns/vehicle-physics.md` (stub placeholder in index, content covered by constraints-guide)

### Sources Used
- 7 DevForum threads/tutorials
- 1 Official Roblox Creator Docs (mechanical-constraints via GitHub)
- 1 DevForum official announcement (accessibility settings)
- ~17 WebFetch calls consumed

---

## [2026-04-16] seed | Initial wiki bootstrap

Bootstrapped the Roblox/Luau wiki from existing FoG-Roblox-Studio-Command content plus raw sources captured by 10 parallel research agents.

### Inputs
- Existing repo:
  - `.claude/agents/` (33 agent files)
  - `.claude/rules/` (11 rule files)
  - `.claude/docs/roblox-architecture-guide.md`
  - `.claude/docs/luau-style-guide.md`
  - `.claude/docs/coding-standards.md`
- Research agents (parallel, background):
  - agent-1: 43 Roblox service references (creator-docs)
  - agent-2: 28 Luau language topics (creator-docs)
  - agent-3: 25 official tutorials (creator-docs)
  - agent-4: 112 best-practices / security / publishing / monetization (creator-docs)
  - agent-5: 53 Luau spec files and RFCs (luau-lang)
  - agent-6: 42 DevForum scripting threads
  - agent-7: 22 Reddit guides (snippet-based due to reddit blocking)
  - agent-8: 34 community articles and library READMEs
  - agent-9: 31 performance/profiling resources
  - agent-10: 30 monetization/live-ops resources
  - **Total raw source files: ~378**

### Output — Wiki Pages Created: 108

By category:
- Services: 28 (5 complete, 23 stub)
- Concepts: 14 (7 complete, 7 stub)
- Luau: 10 (2 complete, 8 stub)
- Anti-patterns: 14 (3 complete, 11 stub)
- Exploits: 7 (2 complete, 5 stub)
- Performance: 6 (0 complete, 6 stub)
- Monetization: 8 (1 complete, 7 stub)
- Studio: 6 (0 complete, 6 stub)
- Patterns: 6 (0 complete, 6 stub)

**Completed pages** (substantive, ready to reference): [[DataStoreService]], [[RemoteEvent]], [[RemoteFunction]], [[UnreliableRemoteEvent]], [[MarketplaceService]], [[session-locking]], [[server-authority]], [[bind-to-close]], [[client-server-split]], [[rate-limiting]], [[schema-versioning]], [[trove-maid-cleanup]], [[type-annotations]], [[task-library]], [[deprecated-wait]], [[client-trust]], [[unvalidated-remote-args]], [[process-receipt-idempotency]], [[speed-hack]], [[item-duplication]].

### Meta-files created
- [[SCHEMA]] — wiki maintenance schema
- [[README]] — entry point
- [[index]] — content catalog
- [[log]] — this file
- `raw/README.md` — raw sources guide

### Schema compliance
All 108 pages have required frontmatter (title, type, category, owner, status, created, updated). Owner assignments match the ownership table in `SCHEMA.md` section 8. Cross-references via `[[wikilinks]]` throughout.

### Known gaps
- Many stubs need flesh-out from the captured raw sources via `/wiki-ingest`
- Physics exploits (e.g., weld exploit) not yet catalogued
- Animation system pages not yet created
- UI framework comparison pages (Roact / Fusion / native) not yet created
- Testing framework pages (TestEZ, Jest-Lua) not yet created
- Additional Roblox classes (Instance, BasePart, Model, etc.) not yet created as Tier 2 service refs

### Next steps
1. Run `/wiki-lint` to verify seed health
2. Run `/wiki-ingest wiki/raw/roblox-creator-docs/services/` to flesh out service stubs from captured YAMLs
3. Run `/wiki-ingest wiki/raw/community/performance/` to flesh out performance stubs with concrete numbers
4. Run `/wiki-ingest wiki/raw/community/monetization/` to flesh out monetization stubs
5. Set up Obsidian to browse the wiki (wiki directory as vault)

### Integration notes
- `CLAUDE.md` now references `@wiki/SCHEMA.md` alongside the existing docs
- `.claude/settings.json` registers `validate-wiki.sh` on Write/Edit
- New skills: `/wiki-seed`, `/wiki-ingest`, `/wiki-query`, `/wiki-lint`, `/wiki-update`
- New agent: `wiki-curator` (Tier 2, sonnet, coordinates wiki operations)
- New hook: `validate-wiki.sh` (frontmatter and wikilink checks)
- New tools: `tools/wiki-bootstrap.sh`, `tools/wiki-search.sh`, `tools/wiki-stats.sh`

## [2026-04-16] ingest | Phase 1 Luau pages from raw sources

Fleshed out 9 Luau stub pages to `status: draft` and created 3 new stub pages for major Luau topics discovered in raw sources.

### Updated pages (stub -> draft)
- [[strict-vs-nonstrict]] — Three type-checking modes, .luaurc config, cross-module interaction, migration patterns, new nonstrict RFC
- [[export-type]] — Export/import syntax, re-exporting, generic exports, OOP patterns, module-scoped semantics
- [[generic-types]] — Type aliases, generic functions, type packs, Rank-N polymorphism, no turbofish, tagged unions
- [[pcall-xpcall]] — Full signatures, yield-through-pcall, error objects, xpcall with debug.traceback, retry patterns
- [[coroutines]] — Full API (create/resume/yield/wrap/close/isyieldable), lifecycle states, producer pattern, deviation from Lua 5.1
- [[table-library]] — All functions including Luau extensions (create/find/clear/clone/freeze/isfrozen), deep clone/freeze patterns, deprecated functions
- [[string-library]] — All functions, pattern language reference, gsub replacement types, string.split, string.format specifiers, string.pack/unpack, interpolation syntax
- [[math-library]] — All functions and constants, Luau extensions (clamp/sign/round/noise/lerp/map/isfinite), Perlin noise usage, lerp precision guarantees
- [[buffer-type]] — Full API (integer/float/string/bit read-write), zero-based offsets, network serialization examples, platform support table, compression notes

### New stub pages created
- [[metatables]] — Metamethods, __index, __newindex, __call, OOP patterns, weak tables
- [[string-interpolation]] — Backtick syntax, escaping, comparison with string.format
- [[module-scripts]] — ModuleScript, require caching, circular dependencies, server/client environments

### Raw sources consumed
- `wiki/raw/roblox-creator-docs/luau/type-checking.md`
- `wiki/raw/roblox-creator-docs/luau/coroutine-library.md`
- `wiki/raw/roblox-creator-docs/luau/table-library.md`
- `wiki/raw/roblox-creator-docs/luau/tables.md`
- `wiki/raw/roblox-creator-docs/luau/string-library.md`
- `wiki/raw/roblox-creator-docs/luau/strings.md`
- `wiki/raw/roblox-creator-docs/luau/math-library.md`
- `wiki/raw/roblox-creator-docs/luau/buffer-library.md`
- `wiki/raw/roblox-creator-docs/luau/functions.md`
- `wiki/raw/roblox-creator-docs/luau/metatables.md`
- `wiki/raw/roblox-creator-docs/luau/module-scripts.md`
- `wiki/raw/luau-spec/types/types-intro.md`
- `wiki/raw/luau-spec/types/generics.md`
- `wiki/raw/luau-spec/types/unions-and-intersections.md`
- `wiki/raw/luau-spec/types/type-refinements.md`
- `wiki/raw/luau-spec/library/standard-library.md`
- `wiki/raw/luau-spec/rfcs/new-nonstrict.md`
- `wiki/raw/luau-spec/rfcs/config-luaurc.md`
- `wiki/raw/luau-spec/rfcs/generic-functions.md`
- `wiki/raw/luau-spec/rfcs/syntax-string-interpolation.md`
- `wiki/raw/luau-spec/rfcs/type-byte-buffer.md`
- `wiki/raw/luau-spec/rfcs/function-buffer-bits.md`
- `wiki/raw/luau-spec/rfcs/function-table-clone.md`
- `wiki/raw/luau-spec/rfcs/function-table-freeze.md`
- `wiki/raw/luau-spec/rfcs/function-math-lerp.md`
- `wiki/raw/luau-spec/rfcs/function-math-map.md`
- `wiki/raw/community/performance/network/luau-buffer-type.md`

### Index updated
- Luau section: 11 -> 14 pages (2 complete, 9 draft, 3 stub)
- Total pages: 122 -> 125
- Status breakdown: complete 33, draft 43, stub 47

## [2026-04-15] ingest | Phase 2 testing frameworks and patterns

Researched and created testing wiki pages from raw sources covering TestEZ, Jest-Lua, mocking strategies, integration testing, and load testing.

### Raw sources captured (6 new files)
- `wiki/raw/community/articles/testing/testez-api-reference.md` — Full TestEZ API: describe, it, expect matchers, lifecycle hooks, FOCUS/SKIP, context, reporters
- `wiki/raw/community/articles/testing/jest-lua-mock-functions.md` — Jest-Lua mock API: jest.fn(), jest.spyOn(), mock assertions, return values, implementations, reset/clear/restore
- `wiki/raw/community/articles/testing/jest-lua-setup-guide.md` — Jest-Lua setup: Wally install, jest.config.lua, FFlag, test runner, deviations from JS Jest
- `wiki/raw/community/articles/testing/mocking-roblox-services.md` — Three mocking patterns (constructor injection, service locator, module-level injection), mock implementations for DataStore, HttpService, RemoteEvent
- `wiki/raw/community/articles/testing/integration-testing-roblox.md` — Studio playtest modes, automated server-side integration tests, contract testing, load testing bots
- `wiki/raw/community/articles/testing/load-testing-stress-testing.md` — Stress testing approaches, bot scripts, metrics targets, MicroProfiler usage, common scaling findings

### Pre-existing raw sources used
- `wiki/raw/community/articles/testing/testez-readme.md` — TestEZ overview and BDD syntax
- `wiki/raw/community/articles/testing/jest-lua-readme.md` — Jest-Lua overview, mocks, snapshots, timer mocks

### Wiki pages created (3 new draft pages)
- [[testing-with-testez]] — BDD unit testing with TestEZ and Jest-Lua: setup, writing tests, matchers, lifecycle, focus/skip, framework comparison
- [[mocking-strategies]] — Mocking DataStoreService, HttpService, RemoteEvents: constructor injection, service locator, module injection, Jest-Lua jest.fn()/spyOn()
- [[integration-testing]] — Client-server integration testing: Studio Team Test, automated integration scripts, contract testing, load testing with bot scripts, performance targets

### WebFetch calls used: 12 of 15 budget
- TestEZ docs (API reference): yielded full matcher/lifecycle/modifier reference
- Jest-Lua docs (overview, mock functions, GitHub README): yielded setup guide, mock API
- Roblox Creator Docs (testing modes, microprofiler): returned empty/404 — compensated with community knowledge
- DevForum threads: several returned unrelated content — compensated with aggregated community patterns

### Index updated
- Patterns section: 6 -> 9 pages (6 stub + 3 draft)
- Total pages: 125 -> 128
- Status breakdown: complete 33, draft 46, stub 47

### Known gaps remaining
- Snapshot testing patterns (Jest-Lua only, no dedicated page yet)
- CI/CD integration for automated test runs (partially covered in [[github-actions-cicd]])
- Roact/Fusion component testing patterns
- E2E testing with Open Cloud Luau Execution API

## [2026-04-16] ingest | Phase 1 security — anti-patterns and exploits from raw sources

Fleshed out 12 anti-pattern stubs and 7 exploit stubs to `status: draft`, and created 3 new pages from security raw sources.

### Anti-pattern stubs upgraded (stub -> draft): 12 pages
- deprecated-spawn, deprecated-delay, magic-numbers, no-pcall, no-session-lock, no-rate-limit, client-to-server-remote-function, instance-in-remote, player-name-as-key, missing-schema-version, print-in-production, string-concat-in-loop

### Exploit stubs upgraded (stub -> draft): 7 pages
- teleport-hack, fly-hack, noclip, remote-spam, argument-spoofing, transaction-replay, session-hijack

### New pages created: 3 pages
- direct-cross-system-coupling (anti-pattern), localscript-injection (exploit), memory-editing (exploit)

### Raw sources consumed: 22 files
- 13 from wiki/raw/roblox-creator-docs/best-practices/security/
- 6 from wiki/raw/community/devforum/ (anti-exploit, security, session-locking, pcalls, remotes)
- 3 from wiki/raw/community/articles/security/

### Index updated: 140 -> 143 pages, 19 stubs upgraded to draft, 3 new drafts

---

## [2026-04-16] research | Phase 2 — Game Architecture Patterns

Phase 2 research agent captured raw sources and created wiki pages for six game architecture pattern topics previously missing from both layers.

### Raw Sources Captured (12 files in wiki/raw/community/articles/game-patterns/)

**Round System (3 files):**
- `round-system-basic-tutorial.md` — DevForum tutorial: intermission, team assignment, gameplay, cleanup phases
- `round-system-oop-tutorial.md` — OOP round class with daisy-chained phases, RemoteEvent UI sync
- `round-system-team-game.md` — Team-based round framework: GameManager + TeamManager modules

**Matchmaking (3 files):**
- `matchmaker-module-memorystores.md` — MatchMaker v0.2 module: region queues, party support, MemoryStore + Promises
- `matchmaking-memorystore-architecture.md` — Coordinator election, SortedMap queues, atomic match validation
- `matchmaking-memorystorequeue-tutorial.md` — MemoryStoreQueue API for basic matchmaking, TeleportService integration

**Spawn/Respawn (2 files):**
- `spawn-respawn-system.md` — Custom SpawnSystem module: spawn selection override, team/neutral spawns, distance-based FFA
- `spectator-mode-tutorial.md` — Camera spectate system: CameraSubject switching, player cycling, death handling

**State Machine (2 files):**
- `fsm-ai-development.md` — AI FSM tutorial: table-based states, module pattern, pet AI example with full Heartbeat loop
- `stateq-fsm-library.md` — StateQ library: typed async FSM, FIFO event queue, Wally install, transition lifecycle

**ECS (2 files):**
- `ecs-tutorial-matter.md` — ECS concepts, Matter library: World, components, systems, queries, useEvent, Loop
- `jecs-ecs-library.md` — Jecs library: 800K entities at 60fps, archetype/SoA storage, entity relationships, typed API

**Lobby (1 file):**
- `lobby-party-teleport-system.md` — Party formation, TeleportService patterns, ReserveServer, DOORS-style elevator, hub architecture

### Wiki Pages Created (6 pages, all status: draft)

- `wiki/patterns/round-system.md` — Round lifecycle: waiting/intermission/setup/grace/gameplay/endgame. OOP class, main loop, team assignment, win conditions, 5 variants table
- `wiki/patterns/matchmaking-queue.md` — Cross-server matchmaking: QueueEntry structure, coordinator election, skill-based formation with expanding MMR window, TeleportToPrivateServer, 4 variants
- `wiki/patterns/spawn-respawn-system.md` — Spawn selection, team/FFA distance-based spawns, respawn delay, safe zone detection, spectator camera client script, 5 respawn variants
- `wiki/patterns/state-machine-pattern.md` — Minimal table FSM, enemy AI guard example (idle/patrol/chase/attack/flee), character state controller, StateQ library usage, 5 FSM variants
- `wiki/patterns/ecs-pattern.md` — Matter world/component/system examples, Jecs typed API + entity relationships, Matter vs Jecs comparison table, system ordering guidance
- `wiki/patterns/lobby-system.md` — Same-server lobby, dedicated hub, party formation service, DOORS-style elevator pattern, architecture comparison table

### WebFetch calls used: 15 of ~25 budget

### Index updated
- Patterns section: 14 -> 20 pages
- Total pages: 134 -> 140
- Status breakdown: complete 33, draft 58, stub 47

### Cross-references established
All 6 new pages cross-link to each other and to existing wiki pages (TeleportService, MemoryStoreService, etc.). Each page has 3-4 related links.

### Known gaps remaining
- Behavior tree pattern (alternative to FSM for complex AI)
- Matchmaking with official MatchmakingService API (if/when Roblox releases it)
- Advanced team balancing algorithms
- Map voting/selection system
- Anti-cheat during spectator mode

## [2026-04-15] ingest | Phase 1 studio tooling pages from raw sources

Fleshed out 6 stub studio pages to `status: draft` and created 3 new studio pages from raw source material in `wiki/raw/community/articles/tooling/` and `wiki/raw/community/monetization/`.

### Updated pages (stub -> draft)
- [[rojo-mapping]] — Full project.json reference, file extension mapping, live sync workflow, build commands, typical project layout, Argon comparison, pitfalls
- [[wally-packages]] — wally.toml manifest format, core commands, realm system, lockfile, Rojo integration, publishing, private registries
- [[collection-service-tags]] — Full API surface, Binder pattern with cleanup, comparison with alternatives, replication caveats, practical uses
- [[attributes]] — API reference, supported types, designer-editable workflow, attributes vs tags vs value objects, limits
- [[open-cloud-api]] — All 5 APIs (Place Publishing, DataStore v1, MessagingService, Assets, Luau Execution), authentication (API key + OAuth2), rate limits, rbxcloud CLI, field constraints
- [[play-solo-team-test]] — All testing modes, client/server perspective toggle, device emulator, VR emulator, player emulator, real-device testing flows, universe/place structure, publishing workflow

### New pages created
- [[selene-linting]] — Selene linter: configuration, usage, what it catches, CI integration, comparison with Luacheck
- [[stylua-formatting]] — StyLua formatter: Roblox convention config, check mode, ignore directives, pre-commit hooks
- [[github-actions-cicd]] — Full CI/CD pipeline: lint/format gates, Rojo build, staging/production deploy, Luau Execution testing, branch strategy

### Raw sources consumed
- `wiki/raw/community/articles/tooling/rojo-readme.md`
- `wiki/raw/community/articles/tooling/wally-readme.md`
- `wiki/raw/community/articles/tooling/selene-readme.md`
- `wiki/raw/community/articles/tooling/stylua-readme.md`
- `wiki/raw/community/articles/tooling/github-actions-roblox-cicd.md`
- `wiki/raw/community/monetization/open-cloud/assets-api-upload.md`
- `wiki/raw/community/monetization/open-cloud/datastore-api-v1-reference.md`
- `wiki/raw/community/monetization/open-cloud/messaging-service-api.md`
- `wiki/raw/community/monetization/open-cloud/oauth2-authentication.md`
- `wiki/raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md`
- `wiki/raw/community/monetization/publishing/bindtoclose-deployment.md`
- `wiki/raw/community/monetization/publishing/device-testing-emulator.md`
- `wiki/raw/community/monetization/publishing/universe-place-structure.md`
- `wiki/raw/community/reddit/collectionservice-tags-pattern.md`
- `wiki/raw/community/reddit/rojo-vscode-workflow.md`
- `wiki/raw/roblox-creator-docs/services/CollectionService.md`

### Index updated
- Studio section: 6 -> 9 pages, all at `draft` status
- Total pages: 119 -> 122
- Status breakdown: complete 33, draft 34, stub 53

## [2026-04-16] ingest | Phase 1 community ingest — patterns and concepts from devforum/articles/live-ops

Phase 1 ingest agent processed raw sources from `wiki/raw/community/devforum/` (42 files), `wiki/raw/community/articles/` (34 files), and `wiki/raw/community/monetization/live-ops/` (7 files) to upgrade 16 stub pages to draft status and create 1 new page.

### Pattern pages upgraded (stub -> draft): 6
- `wiki/patterns/daily-rewards.md` — escalating login streaks, claim logic, streak window, config-driven rewards
- `wiki/patterns/code-redemption-system.md` — two-DataStore pattern, UpdateAsync atomicity, global cap, rate limiting
- `wiki/patterns/quest-system.md` — objective tracking, QuestService with signals, client sync, daily/weekly variants
- `wiki/patterns/inventory-pattern.md` — itemId-to-quantity dict, add/remove/transfer, slot limits, schema versioning
- `wiki/patterns/trading-system.md` — offer-accept-confirm flow, atomic swap, anti-abuse gates, state machine
- `wiki/patterns/leaderboard-pattern.md` — OrderedDataStore + MemoryStore hybrid, sharding, pagination

### Concept pages upgraded (stub -> draft): 10
- `wiki/concepts/signal-pattern.md` — GoodSignal vs FastSignal comparison, benchmarks, API, Trove integration
- `wiki/concepts/service-pattern.md` — Knit/Flamework/custom registry, lifecycle phases, decision tree
- `wiki/concepts/streaming-enabled.md` — properties, per-model modes, Persistent/Atomic, safe scripting patterns
- `wiki/concepts/module-lazy-loading.md` — lazy require wrapper, init-phase resolution, signal decoupling
- `wiki/concepts/feature-flags.md` — Roblox Configs + Experiments, HttpService+GitHub JSON DFFlag, MessagingService invalidation
- `wiki/concepts/cross-server-events.md` — MessagingService pub/sub, MemoryStoreService patterns, sharding, matchmaking
- `wiki/concepts/atomic-trading.md` — same-server frame-level atomicity, rollback, ProfileStore integration, cross-server avoidance
- `wiki/concepts/code-redemption.md` — design decisions, two-DataStore dedup, rate limiting, code lifecycle
- `wiki/concepts/ftue-design.md` — 5-minute rule, tutorial approaches, device-specific onboarding, funnel analytics, D1 targets
- `wiki/concepts/core-loop.md` — four nested loop scales, monetization per scale, Roblox-specific considerations, diagnostics

### New pages created: 1
- `wiki/patterns/party-system.md` — cross-server player grouping with MemoryStore HashMap and MessagingService coordination

### Key raw sources consumed
- `wiki/raw/community/monetization/live-ops/promo-code-redemption.md`
- `wiki/raw/community/monetization/live-ops/configs-and-experiments.md`
- `wiki/raw/community/monetization/live-ops/feature-flag-pattern-github-json.md`
- `wiki/raw/community/monetization/live-ops/messagingservice-in-game-patterns.md`
- `wiki/raw/community/monetization/live-ops/memorystore-cross-server-patterns.md`
- `wiki/raw/community/monetization/live-ops/memorystore-best-practices.md`
- `wiki/raw/community/monetization/live-ops/liveops-essentials-cadence.md`
- `wiki/raw/community/devforum/goodsignal-lua-signal-comparison.md`
- `wiki/raw/community/devforum/fastsignal-consistent-signal-library.md`
- `wiki/raw/community/devforum/service-registry-design-pattern.md`
- `wiki/raw/community/devforum/knit-game-framework-template.md`
- `wiki/raw/community/devforum/roblox-ts-flamework-introduction.md`
- `wiki/raw/community/devforum/state-machines-in-depth-tutorial.md`
- `wiki/raw/community/devforum/profileservice-datastore-module.md`
- `wiki/raw/community/devforum/profilestore-datastore-module.md`
- `wiki/raw/community/devforum/session-locking-explained-datastore.md`
- `wiki/raw/community/articles/architecture/framework-comparison.md`
- `wiki/raw/community/articles/datastore/memorystore-leaderboards.md`
- `wiki/raw/community/articles/datastore/datastore-best-practices.md`
- `wiki/raw/community/articles/library-readmes/goodsignal-readme.md`
- `wiki/raw/community/performance/network/streaming-enabled-guide.md`

### Index updated
- Total pages: 143 -> 144
- Status breakdown: complete 33, draft 93, stub 15
- Concepts section: 10 stubs -> 10 drafts
- Patterns section: 20 -> 21 pages; 6 stubs -> 6 drafts + 1 new draft
