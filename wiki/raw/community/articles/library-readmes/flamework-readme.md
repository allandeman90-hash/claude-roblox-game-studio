---
title: Flamework — Extensible Game Framework for roblox-ts
type: raw-source
source_url: https://github.com/rbxts-flamework/core
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: framework
author: fireboltofdeath
tags: [framework, roblox-ts, typescript, decorators, dependency-injection]
---

# Flamework — Extensible Game Framework for roblox-ts

**Author:** fireboltofdeath
**Source:** GitHub — `rbxts-flamework/core`
**Documentation:** https://flamework.fireboltofdeath.dev/docs/introduction

## What it is

Flamework is an extensible game framework that requires TypeScript and offers many useful features and abstractions. It is the de-facto modern framework for the `roblox-ts` ecosystem — conceptually the successor to Knit for developers writing TypeScript rather than Luau.

## Architecture at a glance

Flamework provides:

- **Dependency injection container.** Services and controllers are classes; dependencies are declared by constructor parameters and resolved at boot.
- **Decorator-based metadata.** `@Service`, `@Controller`, `@Component` decorators register classes with the framework automatically.
- **Compile-time reflection.** A custom TypeScript transformer injects type metadata so that DI and networking can reference interfaces without runtime reification.
- **Optional Components module.** Lets you attach behaviors to Instances by CollectionService tags, with the lifecycle managed by the framework.
- **Optional Networking module.** Defines strongly-typed `Events`, `Functions`, and `Middleware` with type safety across the wire.
- **VS Code extension.** Improves editing experience for Flamework projects (snippets, go-to-decl for services by name, etc.).

## Installation (summary)

```bash
npm i @rbxts/flamework
npm i -D rbxts-transformer-flamework
```

Then enable the transformer by adding it to `tsconfig.json`:

```json
{
  "compilerOptions": {
    "experimentalDecorators": true,
    "plugins": [
      { "transform": "rbxts-transformer-flamework" }
    ]
  }
}
```

## Services and Controllers

Flamework's canonical unit is a class decorated with `@Service` (server) or `@Controller` (client). Services are singletons discovered at boot. Dependencies are constructor-injected:

```typescript
import { Service, OnStart } from "@flamework/core";

@Service()
export class PlayerService implements OnStart {
    constructor(private readonly moneyService: MoneyService) {}

    onStart() {
        // Called after DI resolution completes
    }
}
```

Note: you do not import `MoneyService` from a shared singleton registry — Flamework's transformer turns the constructor parameter type into metadata and wires it up at boot. This is "real" dependency injection in the Angular/NestJS sense, a significant step up from Knit's string-keyed `Knit.GetService("MoneyService")`.

## Lifecycle interfaces

Services can implement well-known lifecycle interfaces:

- `OnInit` — pre-start, after DI but before `OnStart`
- `OnStart` — all services running, safe to cross-talk
- `OnTick`, `OnRender`, `OnPhysics` — RunService event hooks, wired automatically

Implementing these interfaces is how you opt in to loop callbacks without hand-connecting RunService events.

## Components

The `@flamework/components` package maps CollectionService tags to class instances. Tag an Instance with `"Door"`, and Flamework instantiates a `Door` class with the Instance injected, runs its lifecycle, and destroys it when the tag is removed.

```typescript
import { Component, BaseComponent, OnStart } from "@flamework/components";

interface Attributes {
    Locked: boolean;
}

@Component({ tag: "Door" })
export class Door extends BaseComponent<Attributes, BasePart> implements OnStart {
    onStart() {
        this.instance.Touched.Connect((hit) => { /* ... */ });
    }
}
```

This is the most elegant answer to the "tag a part, attach behavior" workflow that Roblox has had informally since CollectionService shipped.

## Networking

The `@flamework/networking` package turns a TypeScript interface into a typed network contract. You define `Events` and `Functions` as interfaces, and Flamework generates both the server and client bindings with full type safety across the wire. Mismatches are caught at compile time rather than at runtime when an exploit or bug sends the wrong shape.

## Why Flamework over Knit

For TypeScript projects specifically:
- **Real DI** instead of string-keyed lookups
- **Decorators** for registration (no manual `CreateService` tables)
- **Type-safe networking** at compile time
- **Transformer-based metadata** means minimal runtime overhead
- **Lifecycle interfaces** are structurally typed, so the compiler enforces correctness

For Luau-only projects, Knit is still simpler. Flamework's value is tightly coupled to the TypeScript type system.

## Source

Original URL: https://github.com/rbxts-flamework/core
Organization: https://github.com/rbxts-flamework
Docs: https://flamework.fireboltofdeath.dev/docs/introduction
Captured: 2026-04-15
