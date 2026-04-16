---
title: Flamework
type: library
category: libraries
owner: luau-systems-programmer
status: draft
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/community/articles/library-readmes/flamework-readme.md
  - wiki/raw/community/devforum/roblox-ts-flamework-introduction.md
  - wiki/raw/community/articles/architecture/framework-comparison.md
related: [[[Knit]], [[framework-comparison]]]
tags: [library, framework, typescript, roblox-ts, dependency-injection]
---

# Flamework

> Extensible game framework for roblox-ts with decorator-based registration, compile-time dependency injection, and type-safe networking.

## Summary

Flamework is the de-facto framework for the roblox-ts ecosystem, created by fireboltofdeath. Conceptually the TypeScript successor to [[Knit]], it provides Services and Controllers as decorated classes with constructor-injected dependencies resolved at boot. A custom TypeScript transformer injects type metadata at compile time, enabling real DI (in the Angular/NestJS sense) rather than string-keyed lookups. Optional packages add tag-based Components (`@flamework/components`) and strongly-typed networking (`@flamework/networking`).

**Maintainer:** fireboltofdeath
**Status:** Active
**Requires:** TypeScript via roblox-ts

## Installation

```bash
npm i @rbxts/flamework
npm i -D rbxts-transformer-flamework
```

Enable the transformer in `tsconfig.json`:

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

A VS Code extension is available for improved DX (snippets, go-to-declaration for services by name).

## Quick Start

```typescript
import { Service, OnStart } from "@flamework/core";

@Service()
export class MoneyService implements OnStart {
    private moneyByUser = new Map<number, number>();

    onStart() {
        // Called after DI resolution completes
    }

    getMoney(userId: number): number {
        return this.moneyByUser.get(userId) ?? 0;
    }
}
```

```typescript
import { Controller, OnStart } from "@flamework/core";

@Controller()
export class MoneyController implements OnStart {
    constructor(private readonly moneyService: MoneyService) {}

    onStart() {
        // moneyService is injected automatically
    }
}
```

## Key API

| Symbol | Description |
|--------|-------------|
| `@Service()` | Decorator that registers a server-side singleton. |
| `@Controller()` | Decorator that registers a client-side singleton. |
| `@Component({ tag })` | Decorator that maps a CollectionService tag to a class (from `@flamework/components`). |
| `OnInit` | Lifecycle interface: runs after DI but before `OnStart`. |
| `OnStart` | Lifecycle interface: all services running, safe to cross-talk. |
| `OnTick` / `OnRender` / `OnPhysics` | Lifecycle interfaces: RunService event hooks, wired automatically. |
| `BaseComponent<Attributes, Instance>` | Base class for tag-based components with typed attributes. |
| `Events` / `Functions` (networking) | TypeScript interfaces that generate typed network contracts. |

## When to Use / When Not to Use

**Use when:**
- The project uses roblox-ts (TypeScript)
- You want real dependency injection, not string-keyed lookups
- You value compile-time type safety across the network boundary
- You prefer decorator-based registration over manual `CreateService` tables

**Do not use when:**
- The project is Luau-only (Flamework requires TypeScript)
- Building a pure ECS game (use [[Matter]] or [[Jecs]])
- The team is unfamiliar with TypeScript and the roblox-ts toolchain

## Alternatives

| Library | Trade-off |
|---------|-----------|
| [[Knit]] | Luau-native, simpler, but string-keyed lookups and archived. |
| [[Matter]] / [[Jecs]] | ECS paradigm. Different mental model entirely. |
| [[Nevermore]] | Library pool without framework contract. Luau-only. |

## Related

- [[Knit]] -- Luau predecessor
- [[framework-comparison]] -- full decision guide

## Sources

- [Flamework README](wiki/raw/community/articles/library-readmes/flamework-readme.md)
- [DevForum: Roblox-Ts and Flamework Introduction](wiki/raw/community/devforum/roblox-ts-flamework-introduction.md)
- [Framework Comparison](wiki/raw/community/articles/architecture/framework-comparison.md)
- GitHub: https://github.com/rbxts-flamework/core
- Docs: https://flamework.fireboltofdeath.dev/docs/introduction
