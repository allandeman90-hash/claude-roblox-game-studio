---
title: Wiki Index
type: wiki-index
updated: 2026-04-16
page_count: 140
---

# Wiki Index

**Last updated:** 2026-04-16
**Total pages:** 143
**Status:** complete: 33, draft: 77, stub: 31

---

## Services (31)

- [[DataStoreService]] — Persistent key-value store. `datastore-architect` `complete`
- [[GlobalDataStore]] — Handle returned by GetDataStore. `datastore-architect` `draft`
- [[OrderedDataStore]] — Sorted numeric variant for leaderboards. `datastore-architect` `draft`
- [[MemoryStoreService]] — Short-lived cross-server state. `live-ops-specialist` `draft`
- [[MessagingService]] — Cross-server pub/sub. `live-ops-specialist` `draft`
- [[RemoteEvent]] — Fire-and-forget messaging. `remotes-networking-specialist` `complete`
- [[RemoteFunction]] — Request-response (server→client only). `remotes-networking-specialist` `complete`
- [[UnreliableRemoteEvent]] — Cosmetic high-frequency messaging. `remotes-networking-specialist` `complete`
- [[BindableEvent]] — Same-side pub/sub. `luau-systems-programmer` `draft`
- [[BindableFunction]] — Same-side request-response. `luau-systems-programmer` `stub`
- [[MarketplaceService]] — GamePass/DevProduct transactions. `monetization-lead` `complete`
- [[Players]] — Player lifecycle service. `luau-gameplay-programmer` `draft`
- [[Player]] — Individual player instance. `luau-gameplay-programmer` `draft`
- [[Humanoid]] — Character movement and health. `luau-gameplay-programmer` `draft`
- [[ProximityPrompt]] — Contextual interaction UI. `luau-gameplay-programmer` `draft`
- [[RunService]] — Frame loop events. `luau-systems-programmer` `draft`
- [[HttpService]] — Outbound HTTP + JSON. `luau-systems-programmer` `draft`
- [[TeleportService]] — Place-to-place teleportation. `luau-systems-programmer` `draft`
- [[TweenService]] — Property interpolation. `ui-programmer` `draft`
- [[UserInputService]] — Raw input events. `ui-programmer` `draft`
- [[ContextActionService]] — Cross-input action binding. `ui-programmer` `draft`
- [[TextChatService]] — Modern chat system. `ui-programmer` `draft`
- [[CollectionService]] — Tag-based entity pattern. `roblox-studio-specialist` `draft`
- [[SoundService]] — Global audio config. `sound-designer` `draft`
- [[Sound]] — Individual sound instance. `sound-designer` `draft`
- [[SoundGroup]] — Sound routing / volume mixing. `sound-designer` `draft`
- [[Workspace]] — The 3D world container. `level-designer` `draft`
- [[Lighting]] — Global lighting and effects. `technical-artist` `draft`
- [[ServerScriptService]] — Active server scripts. `technical-director` `draft`
- [[ServerStorage]] — Server-only data/modules. `technical-director` `draft`
- [[ReplicatedStorage]] — Shared client+server modules. `technical-director` `draft`

## Concepts (18)

- [[constraints-guide]] — Physics constraints: Weld, Motor6D, Hinge, Spring, Rope, vehicle patterns. `luau-gameplay-programmer` `draft`
- [[server-authority]] — Never trust the client. `technical-director` `complete`
- [[client-server-split]] — Three-zone architecture. `technical-director` `complete`
- [[session-locking]] — Prevents item duplication. `datastore-architect` `complete`
- [[schema-versioning]] — Evolve data shape safely. `datastore-architect` `complete`
- [[bind-to-close]] — Shutdown-time save handler. `datastore-architect` `complete`
- [[rate-limiting]] — Cap per-player remote calls. `remotes-networking-specialist` `complete`
- [[trove-maid-cleanup]] — Resource disposal pattern. `luau-systems-programmer` `complete`
- [[signal-pattern]] — Custom event/signal libraries. `luau-systems-programmer` `stub`
- [[service-pattern]] — Module lifecycle abstraction. `luau-systems-programmer` `stub`
- [[streaming-enabled]] — Dynamic workspace streaming. `level-designer` `stub`
- [[module-lazy-loading]] — Deferred module requires. `luau-systems-programmer` `stub`
- [[feature-flags]] — Runtime-toggleable features. `live-ops-specialist` `stub`
- [[cross-server-events]] — Coordinating state across servers. `live-ops-specialist` `stub`
- [[atomic-trading]] — All-or-nothing item exchange. `economy-designer` `stub`
- [[code-redemption]] — Server-validated promo codes. `live-ops-specialist` `stub`
- [[ftue-design]] — First-time user experience. `game-designer` `stub`
- [[core-loop]] — 30s/5min/session/meta loops. `game-designer` `stub`

## Luau (14)

- [[type-annotations]] — Gradual type system. `luau-systems-programmer` `complete`
- [[task-library]] — Modern concurrency primitives. `luau-systems-programmer` `complete`
- [[strict-vs-nonstrict]] — Type checking modes and .luaurc config. `luau-systems-programmer` `draft`
- [[export-type]] — Sharing types across modules. `luau-systems-programmer` `draft`
- [[generic-types]] — Type parameters and polymorphism. `luau-systems-programmer` `draft`
- [[pcall-xpcall]] — Error handling and retry patterns. `luau-systems-programmer` `draft`
- [[coroutines]] — Cooperative threads, yield/resume. `luau-systems-programmer` `draft`
- [[table-library]] — Array/table manipulation with Luau extensions. `luau-systems-programmer` `draft`
- [[string-library]] — String manipulation and pattern matching. `luau-systems-programmer` `draft`
- [[math-library]] — Math functions with Luau extensions (clamp, lerp, noise). `luau-systems-programmer` `draft`
- [[buffer-type]] — Binary byte buffers for serialization. `luau-systems-programmer` `draft`
- [[metatables]] — Metamethods and OOP patterns. `luau-systems-programmer` `stub`
- [[string-interpolation]] — Backtick interpolation syntax. `luau-systems-programmer` `stub`
- [[module-scripts]] — ModuleScript, require, caching. `luau-systems-programmer` `stub`

## Anti-Patterns (16)

- [[deprecated-wait]] — Use task.wait. `lead-programmer` `complete`
- [[deprecated-spawn]] — Use task.spawn. `lead-programmer` `draft`
- [[deprecated-delay]] — Use task.delay. `lead-programmer` `draft`
- [[client-trust]] — Never trust client values. `exploit-security-specialist` `complete`
- [[unvalidated-remote-args]] — Validate every argument. `remotes-networking-specialist` `complete`
- [[no-rate-limit]] — Missing rate limiter. `remotes-networking-specialist` `draft`
- [[client-to-server-remote-function]] — Server hang risk. `remotes-networking-specialist` `draft`
- [[instance-in-remote]] — Use string IDs, not Instance refs. `remotes-networking-specialist` `draft`
- [[no-session-lock]] — Cross-server duplication vector. `datastore-architect` `draft`
- [[no-pcall]] — Unhandled DataStore/HTTP errors. `lead-programmer` `draft`
- [[player-name-as-key]] — UserId only for DataStore keys. `datastore-architect` `draft`
- [[missing-schema-version]] — Unmigrateable persistent data. `datastore-architect` `draft`
- [[magic-numbers]] — Externalize to config modules. `lead-programmer` `draft`
- [[print-in-production]] — Use structured logger. `lead-programmer` `draft`
- [[string-concat-in-loop]] — Use table.concat for O(n). `performance-analyst` `draft`
- [[direct-cross-system-coupling]] — Service boundary violations. `lead-programmer` `draft`

## Exploits (11)

- [[speed-hack]] — Move faster than allowed. `exploit-security-specialist` `complete`
- [[item-duplication]] — Cross-server data race. `exploit-security-specialist` `complete`
- [[teleport-hack]] — Arbitrary CFrame jumps. `exploit-security-specialist` `draft`
- [[fly-hack]] — Remove gravity, sustained flight. `exploit-security-specialist` `draft`
- [[noclip]] — Pass through walls and solid geometry. `exploit-security-specialist` `draft`
- [[remote-spam]] — DoS via rate-unlimited remote fire. `exploit-security-specialist` `draft`
- [[argument-spoofing]] — Invalid types, NaN, spoofed instances through remotes. `exploit-security-specialist` `draft`
- [[transaction-replay]] — Replay DevProduct or trade for duplication. `exploit-security-specialist` `draft`
- [[session-hijack]] — Session lock bypass via rapid server-hop. `exploit-security-specialist` `draft`
- [[localscript-injection]] — Arbitrary Luau code injection into client. `exploit-security-specialist` `draft`
- [[memory-editing]] — Direct process memory manipulation. `exploit-security-specialist` `draft`

## Performance (12)

- [[heartbeat-budget]] — 16.67ms frame target. `performance-analyst` `complete`
- [[microprofiler]] — Built-in profiler. `performance-analyst` `complete`
- [[server-memory-budget]] — 6.4GB base + per-player. `performance-analyst` `complete`
- [[bandwidth-budget]] — 50KB/s per player. `performance-analyst` `complete`
- [[object-pooling]] — Reuse Instances. `performance-analyst` `complete`
- [[draw-call-optimization]] — <500 draw calls. `technical-artist` `complete`
- [[native-codegen]] — --!native directive. `performance-analyst` `complete`
- [[parallel-luau]] — Actors and SharedTable. `performance-analyst` `complete`
- [[texture-memory]] — w*h*4*1.33 formula. `performance-analyst` `complete`
- [[connection-leaks]] — Disconnect prevention. `performance-analyst` `complete`
- [[physics-budget]] — Adaptive timestepping. `performance-analyst` `complete`
- [[bulk-move-to]] — BulkMoveTo threshold. `performance-analyst` `complete`

## Monetization (8)

- [[process-receipt-idempotency]] — Mission-critical pattern. `monetization-lead` `complete`
- [[game-pass]] — Permanent purchases. `monetization-lead` `stub`
- [[dev-product]] — Consumable purchases. `monetization-lead` `stub`
- [[premium-benefits]] — Roblox Premium perks. `monetization-lead` `stub`
- [[engagement-based-payouts]] — EBP/Creator Rewards. `monetization-lead` `stub`
- [[robux-price-tiers]] — 80/400/800/1700/4500/10000. `monetization-lead` `stub`
- [[developer-exchange]] — DevEx conversion. `monetization-lead` `stub`
- [[ethical-monetization]] — Child-safe design. `monetization-lead` `stub`

## Studio (9)

- [[rojo-mapping]] — File-to-instance sync via Rojo project files. `devops-engineer` `draft`
- [[wally-packages]] — Roblox package manager with wally.toml manifests. `devops-engineer` `draft`
- [[collection-service-tags]] — Binder pattern for tag-based behavior. `roblox-studio-specialist` `draft`
- [[attributes]] — Typed key-value pairs on Instances. `roblox-studio-specialist` `draft`
- [[open-cloud-api]] — External REST APIs for publishing, DataStores, messaging, assets. `devops-engineer` `draft`
- [[play-solo-team-test]] — Studio testing modes and device emulators. `roblox-studio-specialist` `draft`
- [[selene-linting]] — Luau linter for bug detection. `devops-engineer` `draft`
- [[stylua-formatting]] — Deterministic Luau code formatter. `devops-engineer` `draft`
- [[github-actions-cicd]] — CI/CD pipeline with Rojo + Open Cloud. `devops-engineer` `draft`

## Patterns (20)

- [[ui-framework-comparison]] — Roact vs React-lua vs Fusion vs Native UI. `ui-programmer` `draft`
- [[responsive-design]] — Mobile-first adaptive layouts, UDim2, accessibility. `ui-programmer` `draft`
- [[accessibility-patterns]] — Reduced motion, transparency, color contrast, touch targets. `accessibility-specialist` `draft`
- [[camera-modes]] — First-person, third-person, isometric, cutscene camera patterns. `luau-gameplay-programmer` `draft`
- [[vehicle-physics]] — Constraint-based and raycast-based vehicle systems. `luau-gameplay-programmer` `draft`
- [[daily-rewards]] — Escalating login streaks. `game-designer` `stub`
- [[code-redemption-system]] — Promo code implementation. `live-ops-specialist` `stub`
- [[quest-system]] — Server-authoritative quests. `game-designer` `stub`
- [[inventory-pattern]] — itemId→quantity map. `luau-gameplay-programmer` `stub`
- [[trading-system]] — Atomic player trades. `economy-designer` `stub`
- [[leaderboard-pattern]] — OrderedDataStore + MemoryStore. `luau-gameplay-programmer` `stub`
- [[round-system]] — Server-driven lobby/intermission/gameplay/endgame loop. `game-designer` `draft`
- [[matchmaking-queue]] — Cross-server skill-based queue with MemoryStoreService. `game-designer` `draft`
- [[spawn-respawn-system]] — Spawn points, respawn delay, safe zones, spectator mode. `game-designer` `draft`
- [[state-machine-pattern]] — FSM for enemy AI, character state, combat phases. `lead-programmer` `draft`
- [[ecs-pattern]] — Entity Component System with Matter and Jecs. `lead-programmer` `draft`
- [[lobby-system]] — Hub world, party formation, game selection, teleport. `game-designer` `draft`
- [[testing-with-testez]] — BDD unit testing with TestEZ and Jest-Lua. `qa-tester` `draft`
- [[mocking-strategies]] — Mocking DataStoreService, HttpService, RemoteEvents. `qa-tester` `draft`
- [[integration-testing]] — Client-server integration and load testing. `qa-tester` `draft`

---

## Raw Sources (424 files)

See `wiki/raw/README.md` for full inventory.

---

## Operations

- `/wiki-ingest <source>` — integrate a raw source
- `/wiki-query <question>` — query the wiki
- `/wiki-lint` — health check
- `/wiki-update <page>` — targeted edit
