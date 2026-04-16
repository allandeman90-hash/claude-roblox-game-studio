# Wiki Log

Append-only chronological log of wiki operations. Format:

```
## [YYYY-MM-DD] <operation> | <short description>
```

Parse with: `grep "^## \[" wiki/log.md | tail -N`

---

## [2026-04-15] research | Game Mechanics — Simulator, Tycoon, Obby, Tower Defense, Pet System (Genre Mechanics)

Genre-mechanics research agent captured raw sources from DevForum, community wikis, and tutorials, then created 5 complete wiki pattern pages for the major Roblox game genres.

### Raw Sources Captured (12 files in wiki/raw/community/articles/game-mechanics/)

**Simulator/Clicker (4 files):**
- `simulator-clicker-core-loop.md` — Backpack system, clicker tool, pets, rebirth reset mechanic
- `simulator-rebirth-math.md` — Rebirth cost formula (exponential scaling), implementation code
- `multiplier-prestige-systems.md` — Multiplier stacking, prestige layer progression (Rebirth -> Ascension -> Darkness)
- `idle-game-mechanics.md` — GUI-based idle design, AFK handling, offline progress, Cookie Clicker vs Antimatter Dimensions

**Tycoon (2 files):**
- `tycoon-dropper-best-practices.md` — Client-side rendering, single-loop optimization, server-side currency calculation
- `tycoon-button-system.md` — Button structure, purchase logic, dependency chains, progression unlocking

**Obby (1 file):**
- `obby-checkpoint-system.md` — Checkpoint setup, DataStore saving, kill brick scripts, CollectionService approach

**Tower Defense (2 files):**
- `tower-defense-guide.md` — Path/waypoint system, enemy movement, EnemyHandler module, performance notes
- `tower-defense-targeting.md` — Waypoint-based grouping, first-in-path targeting, path-distance optimization

**Pet System (3 files):**
- `pet-hatching-framework.md` — Weighted random selection algorithm, rarity colors, egg configuration, hatching animation
- `pet-system-2025.md` — Full architecture (ReplicatedStorage/Server/Client modules), inventory, equipped system, follow system
- `pet-follow-system.md` — CFrame lerp vs MoveTo, client-side rendering consensus, multi-pet positioning

### Wiki Pages Created (5 complete pattern pages)

- [[simulator-mechanics]] — Click/collect/rebirth formula, multiplier stacking, prestige layers, AFK handling, economy integration
- [[tycoon-mechanics]] — Dropper-conveyor-collector pipeline, button purchases, upgrade tiers, plot ownership, template architecture
- [[obby-mechanics]] — Checkpoint system (DataStore-backed), kill bricks (CollectionService), moving platforms, speedrun timers
- [[tower-defense-mechanics]] — Tower placement, targeting AI (First/Last/Strongest/Closest), wave spawning, upgrade trees, enemy pathing
- [[pet-system]] — Egg hatching (weighted random), pet inventory, follow AI (client-side), leveling, fusion, trading, rarity display

### Web Sources Researched

- DevForum: 10 targeted searches, 15+ threads fetched and extracted
- Community wikis: Power Simulator, Run to Speed Simulator, Grow a Garden (prestige/multiplier data)
- Tutorials: GameDev Academy tycoon guide, Obby Wiki development guide

---

## [2026-04-15] research | Game Mechanics — Combat Systems, Ability Systems, Damage Formulas, Loot Tables, Projectiles

Phase 6 research agent captured raw sources and created wiki pages for five combat/gameplay mechanics topics.

### Raw Sources Captured (8 files in wiki/raw/community/articles/game-mechanics/)

**Combat & Hit Detection (4 files):**
- `server-authority-combat.md` — Server Authority tutorial: rollback netcode, BindToSimulation, InputActionSystem, required workspace settings
- `raycast-hitbox-melee.md` — Raycast Hitbox 4.01: attachment-based raycasting for melee, ShapecastHitbox successor
- `combat-melee-parry.md` — Melee combat patterns: state machine, parry/block, combo chains, i-frames, anti-exploit
- `spatial-queries-overlap.md` — GetPartBoundsInBox/InRadius/GetPartsInPart, OverlapParams, Region3 deprecation

**Projectiles (1 file):**
- `fastcast-projectiles.md` — FastCast/FastCast2/SecureCast: segmented raycast, parallel Luau, bullet drop, 3-stage hit detection

**Ability Systems (1 file):**
- `ability-cooldown-buff-systems.md` — Cooldowns module, ModifierManager, Effectify status effects

**Damage Formulas (1 file):**
- `damage-formulas.md` — ATK/(ATK+DEF) defense formula, damage falloff, community consensus

**Loot Tables (1 file):**
- `loot-tables-rarity.md` — Weighted random selection, rarity tiers, LootPlan/LootR libraries

### Wiki Pages Created (5 pages, all status: complete)

- `wiki/patterns/combat-system.md` — Full server-authoritative combat flow, hit detection comparison table, melee combo system, parry/block/i-frames, client input handler
- `wiki/patterns/ability-system.md` — CooldownManager, ModifierStack, StatusEffectController, AbilityService orchestrator, 5 variants
- `wiki/patterns/damage-formulas.md` — Explicit formula pipeline, ATK/(ATK+DEF) deep dive, type effectiveness 5x5 matrix, three level scaling curves, distance falloff
- `wiki/patterns/loot-tables.md` — LootRoller with weighted selection, pity counters, luck multiplier, 6 rarity tiers with expected drop rates
- `wiki/patterns/projectile-system.md` — HitscanWeapon, ProjectileSimulator (FastCast pattern), ProjectilePool, server reconciliation, hitscan vs physics comparison

### WebFetch calls used: 17

### Index updated
- Patterns section: 34 -> 39 pages (5 new complete)
- Total pages: 157 -> 162
- Status breakdown: complete 51, draft 93, stub 15

---

## [2026-04-15] research | Game Mechanics — RPG Progression, Equipment, Skill Trees, Crafting, Shops

Phase 5 research agent captured raw sources and created wiki pages for five RPG game mechanics topics.

### Raw Sources Captured (11 files in wiki/raw/community/articles/game-mechanics/)

**XP/Leveling (2 files):**
- `level-systems-part1.md` — Linear XP formula, recursive AddExp, progress bar math
- `level-up-system-math.md` — Quadratic formula, inverse XP calculation, constant-time multi-level-up

**Skill Trees (1 file):**
- `creating-basic-skill-tree.md` — Prerequisite chains, GUI structure, community critique on missing server validation

**Crafting (1 file):**
- `crafting-system-minecraft-style.md` — Grid-based recipes, tag matching, CheckRecipes verification code

**Prestige/Rebirth (1 file):**
- `prestige-rebirth-system.md` — Prestige/rebirth terminology, XP scaling per prestige tier, community design debate

**Shop/Currency (2 files):**
- `fullshop-currency-shop.md` — ObjectModule catalog pattern, viewport previews, inventory persistence
- `shop-gui-currency-purchases.md` — Leaderstats currency, RemoteEvent purchase flow, server-side validation

**Equipment/Rarity (1 file):**
- `weighted-rarity-system.md` — Cumulative weight rolling, rarity tier definitions

**DataStore/Inventory (1 file):**
- `datastore-inventory-saving.md` — GUID-based item storage, AddItem pattern, save-on-leave

**Stats/Classes (2 files):**
- `stat-system-design.md` — Module-based stat storage, single DataStore table pattern
- `class-loadout-system.md` — Class config modules, tool assignment, spawning architecture

### Wiki Pages Created (5 complete)

- [[rpg-progression]] — XP curve formulas (linear, quadratic, exponential), level-up stat scaling, prestige/rebirth with permanent multipliers, soft/hard caps, session-friendly milestones
- [[equipment-system]] — Gear slots, rarity tiers (Common-Mythic) with stat multipliers, set bonuses, upgrade paths (+1 to +10 with success rates), equipment comparison UI, server-authoritative equip validation
- [[skill-tree]] — Node graph data structure, prerequisite chains, point allocation with respec, passive vs active skills, server-side unlock validation, UI patterns
- [[crafting-system]] — Recipe registry (config-driven), material requirements check, crafting stations (ProximityPrompt), success/failure rates, discovery vs known recipes
- [[shop-system]] — In-game currency shop, item catalog from config, purchase validation server-side, dynamic pricing, featured/rotating items, comparison with GamePass shop

## [2026-04-15] research | Game Mechanics — NPC AI, Pathfinding, Boss Patterns, Behavior Trees

Phase 5 research agent captured raw sources and created wiki pages for four AI/combat game mechanics topics.

### Raw Sources Captured (12 files)

- `wiki/raw/community/articles/game-mechanics/ai-pathfinding-tutorial.md`
- `wiki/raw/community/articles/game-mechanics/pathfinding-service-2.md`
- `wiki/raw/community/articles/game-mechanics/simplepath-module.md`
- `wiki/raw/community/articles/game-mechanics/combat-npc-tutorial.md`
- `wiki/raw/community/articles/game-mechanics/efficient-aggro-approaches.md`
- `wiki/raw/community/articles/game-mechanics/boss-battle-design.md`
- `wiki/raw/community/articles/game-mechanics/boss-battle-basic.md`
- `wiki/raw/community/articles/game-mechanics/boss-attack-system.md`
- `wiki/raw/community/articles/game-mechanics/behaviour-tree-lua.md`
- `wiki/raw/community/articles/game-mechanics/simple-pathfinding-ai.md`
- `wiki/raw/community/articles/game-mechanics/pathfinding-oop-module.md`
- `wiki/raw/community/articles/game-mechanics/enemy-ai-system-simplepath.md`

### Wiki Pages Created (4 complete)

- `wiki/patterns/npc-ai-system.md` — FSM-based NPC brain with aggro, target selection, leash, deaggro
- `wiki/patterns/pathfinding-system.md` — PathfindingService, agent params, waypoints, SimplePath library
- `wiki/patterns/boss-patterns.md` — Phase-based boss: telegraph-windup-attack-recovery, enrage, adds, safe zones
- `wiki/patterns/behavior-trees.md` — Selector/Sequence/Decorator for complex AI, Luau implementation, FSM comparison

### External Sources Referenced

- DevForum: How You Can Use AI Pathfinding (570721)
- DevForum: PathfindingService 2.0 Tutorial (1857779)
- DevForum: SimplePath Module (1196762)
- DevForum: General Combat NPC Tutorial (1862031)
- DevForum: Efficient Aggro Approaches (501394)
- DevForum: Making Boss Battles Correctly (861910)
- DevForum: Boss Battle Basic (1546546)
- DevForum: Boss Attack System (1940539)
- DevForum: Behaviour Trees In-Depth Tutorial (3326581)
- DevForum: Behavior Trees for NPC (2806049)
- DevForum: Enemy AI System (1839720)
- DevForum: PathfindingService OOP (3671750)
- GitHub: tanema/behaviourtree.lua
- GitHub: seyaidev/behaviortree.rbxlua
- SimplePath Docs: grayzcale.github.io/simplepath

---

## [2026-04-15] research | Game Mechanics — Achievements, Notifications, Placement, Farming

Phase 4 research agent captured raw sources and created wiki pages for four game mechanics topics.

### Raw Sources Captured (12 files in wiki/raw/community/articles/game-mechanics/)

**Achievement System (4 files):**
- `achievementservice-open-source.md` — AchievementService open-source module v1.03: Award API, retry logic, animations
- `custom-badge-system-tutorial.md` — Custom badge system: disable default GUI, RemoteEvent bridge, MarketplaceService metadata
- `badge-module-pattern.md` — Badge module with session caching: pcall-wrapped Fetch, dedup Award, Badges dictionary
- `badgeservice-api-reference.md` — GameDev Academy complete guide: AwardBadge, UserHasBadgeAsync, five use case patterns

**Notification System (2 files):**
- `reactive-notification-system.md` — Fusion 0.3 reactive module: spring animations, progress bar, hover-pause, 6 position presets, signal returns
- `notification-system-basic-tutorial.md` — Basic tutorial: ScreenGui setup, RemoteEvent listener, auto-dismiss, clone-based stacking

**Building/Placement System (4 files):**
- `3d-placement-system-tutorial.md` — 3D placement: keybinds, 0.5-unit grid snap, raycasting, model primary part requirement
- `grid-placement-snapping.md` — Grid math: snap function, mouse hit offset, GetPartBoundsInBox collision, EgoMoose reference
- `interior-building-system-guide.md` — Interior system: FLOOR/WALL/CEILING categories, raycast surface normals, server OnServerInvoke, CFrame serialization
- `plot-based-placement-system.md` — Plot system: boundary detection, surface snapping, all-axis rotation, primary part hitbox

**Farming System (2 files):**
- `farming-system-islands-pattern.md` — Islands-style state machine: seed/water/harvest lifecycle, GrowthTimeLeft, drought timer, OOP recommendation
- `plant-growth-system.md` — Growth function: repeat-until loop, tick()-based check, chunk system for server performance

### Wiki Pages Created (4 pages, all status: complete)
- `wiki/patterns/achievement-system.md` — BadgeService core (AwardBadge, UserHasBadgeAsync), custom progress tracking with DataStore, trigger patterns, retroactive awarding
- `wiki/patterns/notification-system.md` — Queue-based manager: priority types, tween in/out, auto-dismiss, MAX_VISIBLE cap, mobile-safe positioning, clone-based stacking
- `wiki/patterns/building-placement-system.md` — Grid snapping, ghost preview, Mouse raycast, rotation snapping, collision via GetPartBoundsInBox, plot boundary check, server validation, CFrame serialization
- `wiki/patterns/farming-system.md` — Resource node config, hitPoints depletion, tool validation, respawn timers, crop growth state machine, chunk-based tick loop, AFK prevention

### Sources Used
- 8 DevForum threads/tutorials
- 1 Official Roblox Creator Docs (BadgeService API)
- 1 GameDev Academy tutorial
- 1 Community module resource
- ~18 WebFetch calls consumed

### Index updated
- Patterns section: 21 -> 25 pages (4 new complete)
- Total pages: 144 -> 148
- Status breakdown: complete 37, draft 93, stub 15

### Cross-references established
All 4 new pages cross-link to each other and to existing wiki pages (DataStoreService, inventory-pattern, daily-rewards, quest-system, lobby-system, responsive-design). Each page has 4+ related links.

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
