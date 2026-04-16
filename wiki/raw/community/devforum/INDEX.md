---
title: Devforum Scripting Tutorials & Resources Index
type: raw-source-index
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
---

# Roblox Developer Forum - Scripting Tutorials & Resources Index

Curated collection of high-value scripting tutorials, guides, and deep-dives captured from devforum.roblox.com. Files organized by topic area. All content preserves original authorship and source URLs.

## DataStore & Persistence

Session locking, ProfileService-family modules, and data race-condition patterns.

- **[Session Locking Explained (Datastore)](./session-locking-explained-datastore.md)** — ArtFoundation (2020)
  Core tutorial on race conditions, UpdateAsync atomicity, and JobId-based session locking.
- **[ProfileService - DataStore Module](./profileservice-datastore-module.md)** — loleris (2020)
  The classic DataStore wrapper; stable but superseded.
- **[ProfileStore - DataStore Module](./profilestore-datastore-module.md)** — loleris (2024)
  Successor to ProfileService with MessagingService integration, 10x fewer DataStore calls. Used by Grow a Garden and Dead Rails.
- **[Suphi's DataStore Module](./suphis-datastore-module.md)** — 5uphi (2023)
  Event-based datastore with MemoryStore-backed session locking; an alternative to ProfileService family.

## Remotes & Networking

RemoteEvent security, buffer serialization libraries, and bandwidth optimization.

- **[How to Secure Your RemoteEvent and RemoteFunction](./how-to-secure-remoteevent-remotefunction.md)** — Crygen54 (2025)
  Cooldowns, type/sanity checks, task.spawn, multi-usage systems.
- **[Optimizing RemoteEvent Usage](./optimizing-remoteevent-usage.md)** — Curs1der (2025)
  Batching, compression, network ownership.
- **[ByteNet Networking Library](./bytenet-networking-library.md)** — ffrostfall (2023)
  Buffer-serialized, strictly-typed networking library (ByteNet 0.4.3).
- **[BridgeNet2 Networking Library](./bridgenet2-networking-library.md)** — ffrostfall (2023)
  Predecessor to ByteNet (archived). 7-byte header trim and 75-80% packet processing reduction.
- **[Red Networking Library](./red-networking-library.md)** — jackdotink (2023)
  Strict Luau networking with single-RemoteEvent identifier packing.

## Security & Anti-Exploit

Server-authority patterns and exploit detection.

- **[A Guide to Making Proper Anti-Exploits](./a-guide-to-making-proper-anti-exploits.md)** — Reapimus (2021)
  Canonical anti-exploit guide: speed, noclip, fly detection via raycasting; false-positive handling.
- **[Guide to Maximum Game Security](./guide-to-maximum-game-security.md)** — exp_lol123 (2023)
  Client trust boundaries, free model/plugin safety, server-side validation.
- **[How to Protect Your Server from Exploiters](./protect-server-from-exploiters-tutorial.md)** — LifeDigger (2022)
  Basic server-side validation checks with group-rank admin command example.

## OOP & Type Checking

Luau metatable OOP patterns and strict-mode type annotations.

- **[Object Oriented Programming with Luau in 2023](./oop-luau-2023.md)** — laindecat (2023)
  Three-type Impl/Proto class pattern, plus simplified `typeof(Account.new(...))` variant.
- **[Guide to Type-Checking with OOP](./guide-to-type-checking-with-oop.md)** — MagmaBurnsV (2022)
  Refined type-safe class pattern, with inheritance via intersection types.
- **[Type Annotations - A Guide to Writing Luau Code that is Actually Good](./type-annotations-luau-guide.md)** — Maximum_ADHD (2024)
  Comprehensive `--!strict` guide: types, refinement, typecasting, metatable classes.

## Architecture Patterns & Frameworks

Design patterns, game frameworks, and architectural tutorials.

- **[MVC: A Practical Approach Towards Developing Games](./mvc-practical-approach-games.md)** — uatemycookie22 (2024)
  Pragmatic take on mixing OOP/ECS/MVC; argues against dogmatic paradigms.
- **[Writing Clean Code Part 2: SOLID Principles](./writing-clean-code-solid-principles.md)** — samjay22 (2023)
  SRP, OCP, LSP, ISP, DIP applied to Luau with examples.
- **[The Service Registry Design Pattern in Roblox Luau](./service-registry-design-pattern.md)** — samjay22 (2025)
  Advanced typed service registry with dependency injection, lifecycles, diagnostic tooling.
- **[You need to use the Knit Game Framework](./knit-game-framework-template.md)** — Chainreactionist (2021)
  Introduction to Sleitnick's Knit framework and its Service/Controller model.
- **[Roblox-Ts Tutorial: Roblox-Ts and Flamework Introduction](./roblox-ts-flamework-introduction.md)** — Zerxiase (2022)
  Flamework (TypeScript) framework: Singletons, Services, Controllers, Components.
- **[All about Entity Component System](./all-about-entity-component-system.md)** — Ukendio (2022)
  ECS intro using Matter library (composition vs. inheritance).
- **[Jecs - Optimizing declarative scene graphs with ECS](./jecs-ecs-library.md)** — Ukendio (2024)
  Modern high-performance ECS (800K entities @ 60fps), archetype/SoA storage.

## Signals & Event Libraries

Signal/event library comparisons and implementations.

- **[Lua Signal Class Comparison & GoodSignal](./goodsignal-lua-signal-comparison.md)** — stravant (2021)
  Canonical comparison: GoodSignal vs SimpleSignal vs FastSignal vs RobloxSignal.
- **[FastSignal - A consistent signal library](./fastsignal-consistent-signal-library.md)** — LucasMZ_RBX (2021)
  Alternative to GoodSignal with typing, `.Connected` property, Janitor/Maid compatibility.

## Cleanup & Memory Management

Janitor, Trove, Maid patterns and garbage collection.

- **[Using Janitor to Combat Memory Leaks](./using-janitor-memory-leaks.md)** — LucasMZ_RBX (2021)
  Janitor API walkthrough with class-integration pattern.
- **[Best Cleanup Module to Use (Maid vs Trove vs Janitor)](./cleanup-modules-comparison.md)** — soprosostupid (2023)
  Community comparison of the three major cleanup modules.
- **[Garbage Collection and Memory Leaks in Roblox](./garbage-collection-memory-leaks.md)** — Hexcede (2019)
  GC primer: strong/weak references, `__mode`, common leak sources.

## Async & Error Handling

Promises, pcalls, parallel Luau.

- **[Promises and Why You Should Use Them](./promises-and-why-you-should-use-them.md)** — evaera (2019)
  Foundational promise library post: async vs sync, cancellation model, chaining.
- **[Pcalls - When and how to use them](./pcalls-when-how-to-use.md)** — ReturnedTrue (2019)
  pcall/xpcall/ypcall patterns with DataStore retry loop examples.
- **[How to use Parallel Luau](./how-to-use-parallel-luau.md)** — CoderHusk (2021)
  Actors, `ConnectParallel`, `task.synchronize()`, `task.desynchronize()`.

## Character Controllers & Combat

Physics character controllers and hitbox libraries.

- **[How to Actually Use Roblox's Physics Character Controllers](./physics-character-controllers-tutorial.md)** — 04robot48 (2024)
  ControllerManager setup, sensor configuration, the HitFrame slope trap.
- **[Raycast Hitbox 4.01: For all your melee needs](./raycast-hitbox-401.md)** — TeamSwordphin (2019)
  Classic raycast-based melee hitbox library (superseded by ShapecastHitbox).

## UI Frameworks

Fusion and chat system tutorials.

- **[Fusion: possiblyOutlives, Scopes and You](./fusion-possiblyoutlives-scopes.md)** — Elttob (2024)
  Fusion 0.2 scope-based destruction ordering, `possiblyOutlives` warning.
- **[How to make a custom chat system using TextChatService](./textchatservice-custom-chat-tutorial.md)** — cleventa (2025)
  Basic custom chat GUI with TextChatService integration.
- **[Create Custom Chat Channels with TextChatService](./custom-chat-channels-textchatservice.md)** — httpDerpyy (2024)
  TextChannels, TextChatCommands, channel switching.

## Performance & Profiling

MicroProfiler and optimization guides.

- **[Improving Game Performance: Benchmarking, Microprofiler, Developer Stats](./improving-game-performance-microprofiler.md)** — TechSpectrum (2021)
  Performance benchmarking methodology, optimization checklist, dev tools overview.
- **[Using the MicroProfiler & MicroProfiler Documentation](./using-the-microprofiler.md)** — Mullets_Gavin (2021)
  Ctrl+F6 profiler shortcuts and label documentation.

## Code Style & Best Practices

Style guides and general coding principles.

- **[Roblox Lua Style Guide](./roblox-lua-style-guide.md)** — AIasdair (2019)
  File structure, naming, tables, functions, whitespace rules.
- **[Best Practices Handbook](./best-practices-handbook.md)** — CodedJack (2023)
  Naming, guard clauses, DRY, memory management, instance creation order.
- **[Lua Scripting Starter Guide](./lua-scripting-starter-guide.md)** — DarkSinisterPVP (2019)
  Classic beginner Lua reference for Roblox.

## State Machines

FSM patterns and tutorials.

- **[State Machines In-Depth Tutorial](./state-machines-in-depth-tutorial.md)** — Grandpa_Cheese (2024)
  Conceptual FSM guide with combat state example.

---

## Notable Threads Not Fetched (For Future Manual Review)

These threads were found in searches but not captured due to budget constraints:

- **Pulse | Advanced, Modular, Finite State Machine (FSM)** — https://devforum.roblox.com/t/pulse-advanced-modular-finite-state-machine-fsm/4407924
- **RobloxStateMachine - A Simple State Machine implementation** — https://devforum.roblox.com/t/robloxstatemachine-a-simple-state-machine-implementation/2333194
- **Generic StateMachine Module** — https://devforum.roblox.com/t/generic-statemachine-module/3630796
- **Deterministic and non-deterministic finite machines** — https://devforum.roblox.com/t/deterministic-and-non-deterministic-finite-machines/3968847
- **AI Development: Finite State Machines** — https://devforum.roblox.com/t/ai-development-finite-state-machines/606268
- **ShapecastHitbox: Successor to Raycast Hitbox** — https://devforum.roblox.com/t/shapecasthitbox-for-all-your-melee-needs-v025/3624241
- **PhysicsCharacterController | Mover Constraints based** — https://devforum.roblox.com/t/physicscharactercontroller-mover-constraints-based-character-controller/1945222
- **Conserving Momentum in Air (Custom Character Controller)** — https://devforum.roblox.com/t/conserving-momentum-in-air-airstrafing-surfingbad-custom-character-controller/4461502
- **Fluxa - A Custom Runtime Animation Engine** — https://devforum.roblox.com/t/fluxa-a-custom-runtime-animation-engine-for-roblox/4573039
- **Simple Animation Controller Module** — https://devforum.roblox.com/t/simple-animation-controller-module/3184188
- **Roact UI Framework Crash Course (Deprecated)** — https://devforum.roblox.com/t/roact-the-ultimate-ui-framework/796618 — Note: Roact deprecated in favor of react-lua.
- **Using Roblox-ts, Roact and JSX to create and manage UIs** — https://devforum.roblox.com/t/using-roblox-ts-roact-and-jsx-to-create-and-manage-uis/745685
- **Fusion Components - 31 beautiful modern components for Fusion 0.2** — https://devforum.roblox.com/t/fusion-components-31-beautiful-modern-components-for-fusion-02/3103498
- **OnyxUI - Quick, customizable UI components for Fusion** — https://devforum.roblox.com/t/onyxui-quick-customizable-ui-components-for-fusion/3145229
- **MaterialRoblox - Fusion Material Design 3 components** — https://devforum.roblox.com/t/materialroblox-fusion-material-design-3-components-that-actually-look-and-work-like-from-google/3895990
- **How to migrate your Legacy Chat to TextChatService** — https://devforum.roblox.com/t/how-to-migrate-your-legacy-chat-to-textchatservice/3238164
- **A quick guide on how to use and migrate to TextChatService** — https://devforum.roblox.com/t/a-quick-guide-on-how-to-use-and-migrate-to-textchatservice/3243580
- **Luau Bytecode EXPLAINED** — https://devforum.roblox.com/t/luau-bytecode-explained-how-to-read-debug-and-optimize-like-a-hacker/3941941
- **Luau Internals 101** — https://devforum.roblox.com/t/luau-internals-101/3244837
- **Luau, Optimizations and Using them consciously** — https://devforum.roblox.com/t/luau-optimizations-and-using-them-consciously/3631483
- **Luau, Optimizations and Using them consciously: OOP** — https://devforum.roblox.com/t/luau-optimizations-and-using-them-consciously-oop/3637506
- **ECS in Roblox Studio: Why is it better than OOP and how to cook it** — https://devforum.roblox.com/t/ecs-in-roblox-studio-why-is-it-better-than-oop-and-how-to-cook-it/3962745
- **Debugging & Optimizing the Microprofiler for Lighting** — https://devforum.roblox.com/t/debugging-optimizing-the-microprofiler-for-lighting/686109
- **4thAxis' Luau Style Guide** — https://devforum.roblox.com/t/4thaxis-luau-style-guide-for-anyone-who-is-trying-to-improve-their-readability-and-consistency-or-just-want-enlightenment/1200608
- **Aqua's Luau Style Guide** — https://devforum.roblox.com/t/aquas-luau-style-guide-promotes-consistency-and-readability/2523951
- **Writing clean code - A complete guide (Part 1)** — https://devforum.roblox.com/t/writing-clean-code-a-complete-guide/662447
- **Good Coding Practices II - The DRY Principle** — https://devforum.roblox.com/t/good-coding-practices-ii-the-dry-principle/963399
- **How to make an Observer Class** — https://devforum.roblox.com/t/how-to-make-an-observer-class/4552766
- **Prototype-based OOP; A cleaner and simpler way** — https://devforum.roblox.com/t/prototype-based-oop-a-cleaner-and-simpler-way-to-do-oop/3359448
- **My Approach for OOP in Luau** — https://devforum.roblox.com/t/my-approach-for-oop-in-luau/2137281

---

## Patterns/Libraries Recommended Repeatedly

The following patterns emerged as community-consensus recommendations across multiple threads (useful signals for `/wiki-ingest` synthesis):

### DataStore layer
- **ProfileStore** (loleris, 2024) is the current community default, replacing **ProfileService** (2020). Both use UpdateAsync-only and session-locking.
- **Suphi's DataStoreModule** is a MemoryStore-based alternative favored by some for its event-driven API.
- **Session locking is non-negotiable** for any player data — the community consensus is that rolling your own raw DataStoreService calls for player data is a mistake in 2026.

### Networking layer
- **ByteNet** (ffrostfall) is the modern buffer-serialization default, successor to the archived **BridgeNet2**.
- **Red** (jackdotink) is the other major strict-Luau networking library.
- Identifier packing (single RemoteEvent + enum dispatch) is the recurring optimization pattern.

### Event/signal libraries
- **GoodSignal** (stravant) is the canonical pure-Lua signal; **FastSignal** (LucasMZ_RBX) is its closest alternative.
- Most cleanup modules (Janitor/Trove) integrate with these.

### Cleanup modules
- **Janitor**, **Trove**, and **Maid** are all considered production-ready.
- **Trove** is actively maintained with a TypeScript port.
- **Janitor** has richer cleanup-method customization.
- Community opinion: choice is mostly stylistic.

### Frameworks
- **Knit** (Sleitnick) — Services/Controllers for pure Luau projects.
- **Flamework** (rbxts-flamework) — TypeScript-first with dependency injection.
- **Matter** (evaera) and **Jecs** (Ukendio) — ECS alternatives; Jecs is the newer/faster option.

### UI frameworks
- **Fusion 0.2** has a unique scope-based lifecycle model (`doCleanup`, `innerScope`).
- **Roact** is deprecated in favor of **react-lua**.

### Security
- Server-side validation with type checks, cooldowns, and sanity checks is the universal recommendation.
- Client-side anti-exploit is considered insufficient; only raycasting-based speed/noclip/fly detection on the server is trusted.
- Never trust client-supplied position data.

### Architecture
- **Guard clauses** and the **DRY principle** appear in every best-practices guide.
- **Set Parent last** when creating instances (performance).
- **`game:GetService()`** over direct `game.ServiceName` access (robustness).
- **`task.wait()`** replaces deprecated `wait()`.
- **`--!strict`** mode with explicit type annotations is the modern standard.
