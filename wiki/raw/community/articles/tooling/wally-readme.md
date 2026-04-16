---
title: Wally — Package Manager for Roblox
type: raw-source
source_url: https://github.com/UpliftGames/wally
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: tooling
author: UpliftGames / LPGhatguy
tags: [wally, package-manager, dependencies, tooling]
---

# Wally — Package Manager for Roblox

**Author:** UpliftGames (maintained by the team that also builds Rojo)
**Source:** GitHub — `UpliftGames/wally`
**License:** Mozilla Public License 2.0

## What it is

Wally is a package manager for Roblox, inspired by Cargo (Rust) and npm (JavaScript). It lets you declare dependencies on open-source Roblox libraries in a `wally.toml` file, and installs them into a `Packages/` directory that Rojo maps into `ReplicatedStorage.Packages`.

It is the standard mechanism by which modern Roblox projects consume third-party code — Knit, ProfileStore, Matter, jecs, Fusion, Trove, Promise, and dozens of others are all published on the Wally registry.

## Architecture

Wally consists of two integrated components:

1. **CLI** — what developers run locally.
2. **Registry server** — hosts published packages.

The default registry is the open-source Git index at https://github.com/UpliftGames/wally-index, mirrored by the API server at https://api.wally.run. You can host your own private registry by cloning the index repo and pointing an API server at it — this is what large studios do for internal shared code.

## Installation

Wally is shipped via several paths:

- **Aftman** (recommended) — a toolchain manager that pins tool versions in a project-level `aftman.toml`. This is the canonical path so everyone on a team uses the same Wally version.
- **Homebrew** — `brew install wally` on macOS/Linux
- **Pre-built binaries** — from the GitHub releases page
- **From source** — `cargo install wally` (requires Rust ≥ 1.80)

## Core commands

| Command | Purpose |
|---|---|
| `wally init` | Scaffold a new package (creates `wally.toml`) |
| `wally install` | Resolve dependencies and populate `Packages/` |
| `wally install --locked` | CI-friendly; fails if `wally.lock` would change |
| `wally update` | Refresh to newest allowed versions |
| `wally update <name>` | Update a single dependency |
| `wally publish` | Upload a package to a registry |
| `wally login` / `logout` | Registry authentication |
| `wally package` | Bundle project as a distributable ZIP |
| `wally search <query>` | Query packages in the configured registry |

## `wally.toml` — the manifest

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

Key concepts in the manifest:

- **`realm`** — one of `shared`, `server`, or `client`. This maps to where the package ends up in the DataModel. Libraries like Matter are `shared`; libraries like ProfileService are `server`.
- **`[dependencies]` / `[server-dependencies]` / `[dev-dependencies]`** — control which realm a dep ends up in, and whether it's only pulled for tests/CI.
- **Version constraints** use SemVer operators (`^`, `~`, exact pins, ranges).

## `wally.lock` — reproducibility

`wally install` produces a lockfile recording exact versions and content hashes of every resolved dep. Committing this file means every teammate and every CI run gets the exact same bytes. `wally install --locked` is the CI mode: it errors out rather than silently updating the lockfile.

## Publishing

Publishing a package requires the manifest, a LICENSE file, and the package contents. The flow is:

1. `wally login` — authenticates against the registry using GitHub OAuth.
2. `wally publish` — uploads a tarball of the package.
3. The registry index repo gets a new commit with the manifest entry.

Once published, `wally search` can find it and any project depending on `<scope>/<name>@<version>` can install it.

## Why it mattered

Before Wally, Roblox library consumption meant copy-pasting ModuleScripts into ReplicatedStorage, or cloning someone's GitHub repo and manually reproducing the build. Upgrading meant remembering you had a fork and checking for changes by hand. Wally brought npm-style dependency management to a platform that had none.

Crucially, Wally was designed to play well with Rojo — the output is a `Packages/` directory that Rojo mounts into the DataModel. The two tools together are what make reproducible, Git-driven Roblox development possible.

## Source

Original URL: https://github.com/UpliftGames/wally
Docs: https://wally.run/
Default registry: https://github.com/UpliftGames/wally-index
Captured: 2026-04-15
