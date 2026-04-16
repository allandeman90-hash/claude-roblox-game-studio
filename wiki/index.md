---
title: Wiki Index
type: wiki-index
updated: 2026-04-16
page_count: 119
---

# Wiki Index

**Last updated:** 2026-04-16
**Total pages:** 119
**Status:** complete: 33, draft: 25, stub: 59

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

## Concepts (17)

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

## Luau (11)

- [[type-annotations]] — Gradual type system. `luau-systems-programmer` `complete`
- [[task-library]] — Modern concurrency primitives. `luau-systems-programmer` `complete`
- [[strict-vs-nonstrict]] — Type checking modes. `luau-systems-programmer` `stub`
- [[export-type]] — Sharing types across modules. `luau-systems-programmer` `stub`
- [[generic-types]] — Type parameters. `luau-systems-programmer` `stub`
- [[pcall-xpcall]] — Error handling. `luau-systems-programmer` `stub`
- [[coroutines]] — Raw cooperative threads. `luau-systems-programmer` `stub`
- [[table-library]] — Luau-specific table extensions. `luau-systems-programmer` `stub`
- [[string-library]] — String manipulation. `luau-systems-programmer` `stub`
- [[math-library]] — Math with Luau extensions. `luau-systems-programmer` `stub`
- [[buffer-type]] — Binary byte buffers. `luau-systems-programmer` `stub`

## Anti-Patterns (15)

- [[deprecated-wait]] — Use task.wait. `lead-programmer` `complete`
- [[deprecated-spawn]] — Use task.spawn. `lead-programmer` `stub`
- [[deprecated-delay]] — Use task.delay. `lead-programmer` `stub`
- [[client-trust]] — Never trust client values. `exploit-security-specialist` `complete`
- [[unvalidated-remote-args]] — Validate every argument. `remotes-networking-specialist` `complete`
- [[no-rate-limit]] — Missing rate limiter. `remotes-networking-specialist` `stub`
- [[client-to-server-remote-function]] — Server hang risk. `remotes-networking-specialist` `stub`
- [[instance-in-remote]] — Use string IDs. `remotes-networking-specialist` `stub`
- [[no-session-lock]] — Duplication exploit. `datastore-architect` `stub`
- [[no-pcall]] — Unhandled DataStore errors. `lead-programmer` `stub`
- [[player-name-as-key]] — UserId only. `datastore-architect` `stub`
- [[missing-schema-version]] — Unmigrateable data. `datastore-architect` `stub`
- [[magic-numbers]] — Externalize to config. `lead-programmer` `stub`
- [[print-in-production]] — Use logger. `lead-programmer` `stub`
- [[string-concat-in-loop]] — Use table.concat. `performance-analyst` `stub`

## Exploits (9)

- [[speed-hack]] — Move faster than allowed. `exploit-security-specialist` `complete`
- [[item-duplication]] — Cross-server data race. `exploit-security-specialist` `complete`
- [[teleport-hack]] — Arbitrary CFrame jumps. `exploit-security-specialist` `stub`
- [[fly-hack]] — Remove gravity. `exploit-security-specialist` `stub`
- [[noclip]] — Pass through walls. `exploit-security-specialist` `stub`
- [[remote-spam]] — DoS via rate-unlimited remote. `exploit-security-specialist` `stub`
- [[argument-spoofing]] — Invalid types through remote. `exploit-security-specialist` `stub`
- [[transaction-replay]] — Replay DevProduct. `exploit-security-specialist` `stub`
- [[session-hijack]] — Session lock bypass. `exploit-security-specialist` `stub`

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

## Studio (6)

- [[rojo-mapping]] — File-to-instance sync. `devops-engineer` `stub`
- [[wally-packages]] — Package manager. `devops-engineer` `stub`
- [[collection-service-tags]] — Binder pattern. `roblox-studio-specialist` `stub`
- [[attributes]] — Typed key-value on instances. `roblox-studio-specialist` `stub`
- [[open-cloud-api]] — External REST APIs. `devops-engineer` `stub`
- [[play-solo-team-test]] — Studio testing modes. `roblox-studio-specialist` `stub`

## Patterns (6)

- [[daily-rewards]] — Escalating login streaks. `game-designer` `stub`
- [[code-redemption-system]] — Promo code implementation. `live-ops-specialist` `stub`
- [[quest-system]] — Server-authoritative quests. `game-designer` `stub`
- [[inventory-pattern]] — itemId→quantity map. `luau-gameplay-programmer` `stub`
- [[trading-system]] — Atomic player trades. `economy-designer` `stub`
- [[leaderboard-pattern]] — OrderedDataStore + MemoryStore. `luau-gameplay-programmer` `stub`

---

## Raw Sources (424 files)

See `wiki/raw/README.md` for full inventory.

---

## Operations

- `/wiki-ingest <source>` — integrate a raw source
- `/wiki-query <question>` — query the wiki
- `/wiki-lint` — health check
- `/wiki-update <page>` — targeted edit
