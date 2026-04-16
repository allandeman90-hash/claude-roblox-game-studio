---
title: Wally Package Manager
type: studio
category: studio
subcategory: tooling
owner: devops-engineer
status: complete
created: 2026-04-16
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/tooling/wally-readme.md
  - wiki/raw/community/reddit/rojo-vscode-workflow.md
related:
  - "[[rojo-mapping]]"
  - "[[open-cloud-api]]"
  - "[[github-actions-cicd]]"
tags: [studio, tooling, wally, package-manager, dependencies]
---

# Wally Package Manager

> Wally is the standard package manager for Roblox, letting you declare dependencies in `wally.toml` and install them into a `Packages/` directory that Rojo maps into the DataModel.

## Summary

Wally (by UpliftGames, the team behind Rojo) brings npm/Cargo-style dependency management to Roblox. Community libraries -- Knit, ProfileStore, Matter, jecs, Fusion, Trove, Promise, and dozens more -- are published on the Wally registry. Before Wally, library consumption meant copy-pasting ModuleScripts; upgrading meant checking for changes by hand.

Wally is designed to integrate with Rojo. The output is a `Packages/` directory that Rojo mounts into the DataModel (typically at `ReplicatedStorage.Packages`).

## Installation

Install Wally via Aftman (recommended for reproducible team setups):

```toml
# aftman.toml
[tools]
wally = "UpliftGames/wally@0.3.2"
```

Other paths: Homebrew (`brew install wally`), pre-built binaries from GitHub releases, or from source (`cargo install wally`).

## Core Commands

| Command | Purpose |
|---|---|
| `wally init` | Scaffold a new package (creates `wally.toml`) |
| `wally install` | Resolve dependencies and populate `Packages/` |
| `wally install --locked` | CI-friendly: fails if `wally.lock` would change |
| `wally update` | Refresh to newest allowed versions |
| `wally update <name>` | Update a single dependency |
| `wally publish` | Upload a package to a registry |
| `wally login` / `logout` | Registry authentication (GitHub OAuth) |
| `wally search <query>` | Query packages in the configured registry |

## The Manifest (`wally.toml`)

```toml
[package]
name = "my-scope/my-game"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
Knit = "sleitnick/knit@^1.6"
ProfileStore = "madstudioroblox/profile-store@^1.0"
Matter = "matter-ecs/matter@^0.8"

[server-dependencies]
ProfileService = "madstudioroblox/profile-service@^1.4"

[dev-dependencies]
TestEZ = "roblox/testez@^0.4"
```

### Key concepts

- **`realm`** -- one of `shared`, `server`, or `client`. Controls where the package ends up in the DataModel. Libraries like Matter are `shared`; libraries like ProfileService are `server`.
- **`[dependencies]`** -- installed for all realms.
- **`[server-dependencies]`** -- installed only for server realm.
- **`[dev-dependencies]`** -- installed only for tests/CI.
- **Version constraints** use SemVer operators: `^` (compatible), `~` (patch-level), exact pins, ranges.

## The Lockfile (`wally.lock`)

`wally install` produces a lockfile recording exact versions and content hashes of every resolved dependency. Commit this file so every teammate and every CI run gets the exact same bytes.

`wally install --locked` is the CI mode: it errors out rather than silently updating the lockfile.

## Rojo Integration

Map the `Packages/` directory in `default.project.json`:

```json
{
    "ReplicatedStorage": {
        "$className": "ReplicatedStorage",
        "Packages": { "$path": "Packages" }
    }
}
```

Then require packages in Luau:

```lua
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Matter = require(game.ReplicatedStorage.Packages.Matter)
```

## Publishing a Package

1. `wally login` -- authenticates against the registry using GitHub OAuth.
2. Ensure the manifest has a `name`, `version`, and `LICENSE` file.
3. `wally publish` -- uploads a tarball to the registry.
4. The registry index repo gets a new commit with the manifest entry.

Once published, `wally search <scope>/<name>` can find it.

## Private Registries

Large studios can host a private registry by cloning the index repo (`UpliftGames/wally-index`) and pointing an API server at it. Configure in `wally.toml`:

```toml
registry = "https://github.com/my-studio/private-wally-index"
```

## Pitfalls

- **Packages/ must be in .gitignore.** The installed packages are derived from the lockfile; committing them bloats the repo.
- **Realm mismatch.** A `server` dependency required from a `shared` or `client` script will fail. Match the realm to where the code runs.
- **Lockfile drift in CI.** Always use `wally install --locked` in CI workflows so builds fail if the lockfile is stale.

## Related

- [[rojo-mapping]]
- [[open-cloud-api]]
- [[github-actions-cicd]]

## Sources

- [Wally README](../raw/community/articles/tooling/wally-readme.md) -- GitHub `UpliftGames/wally`
- [Rojo + VS Code workflow (Reddit)](../raw/community/reddit/rojo-vscode-workflow.md)
- Wally registry: https://wally.run/
- Default index: https://github.com/UpliftGames/wally-index
