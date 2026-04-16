---
title: Rojo — Filesystem Sync for Roblox
type: raw-source
source_url: https://github.com/rojo-rbx/rojo
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: tooling
author: LPGhatguy and the rojo-rbx organization
tags: [rojo, tooling, git, workflow, filesystem-sync]
---

# Rojo — Filesystem Sync for Roblox

**Author:** LPGhatguy and the `rojo-rbx` organization
**Source:** GitHub — `rojo-rbx/rojo`
**License:** Mozilla Public License 2.0

## What it is

Rojo is a tool designed to enable Roblox developers to use professional-grade software engineering tools. It is the single most important piece of infrastructure in the modern Roblox OSS ecosystem — nearly every framework, testing library, and package manager assumes a Rojo-driven project layout.

With Rojo, developers can edit scripts and models in real filesystem files using VS Code (or any editor), commit them to Git, and sync them live into a running Roblox Studio session via a Studio plugin. It turns a Roblox place file from an opaque binary blob into a directory of plaintext files.

## What Rojo enables

- **Editing scripts and models using filesystem-based workflows** in your preferred editor (VS Code is the de-facto choice).
- **Version control integration through Git** or any other VCS — real diffs on real files.
- **Real-time model streaming** of `.rbxmx` and `.rbxm` files into the in-Studio project during development.
- **Command-line deployment and packaging** to roblox.com for CI/CD scenarios.

## Project layout (`default.project.json`)

A Rojo project is defined by a JSON file that maps filesystem directories to a DataModel tree:

```json
{
    "name": "my-game",
    "tree": {
        "$className": "DataModel",
        "ReplicatedStorage": {
            "$className": "ReplicatedStorage",
            "Shared": { "$path": "src/shared" },
            "Packages": { "$path": "Packages" }
        },
        "ServerScriptService": {
            "$className": "ServerScriptService",
            "Server": { "$path": "src/server" }
        },
        "StarterPlayer": {
            "$className": "StarterPlayer",
            "StarterPlayerScripts": {
                "$className": "StarterPlayerScripts",
                "Client": { "$path": "src/client" }
            }
        }
    }
}
```

`$path` points at a directory on disk; Rojo walks the directory and builds Roblox instances from file extensions:

| File extension | Becomes |
|---|---|
| `*.server.luau` / `*.server.lua` | `Script` |
| `*.client.luau` / `*.client.lua` | `LocalScript` |
| `*.luau` / `*.lua` | `ModuleScript` |
| `*.model.json` | Explicit instance with properties |
| `init.server.luau` etc. | The containing folder becomes a Script (similar to `__init__.py`) |

This is the convention the entire ecosystem builds on — every tutorial, every library, every boilerplate assumes this layout.

## Live sync workflow

1. Run `rojo serve` in the project directory. It starts an HTTP server on `localhost:34872`.
2. Open Roblox Studio, install the Rojo plugin, click Connect.
3. Studio pulls the project tree from the server.
4. Every save on disk is pushed to Studio within milliseconds — you write code in VS Code, the in-Studio scripts update live.

The sync is one-way from filesystem → Studio. Work done inside Studio (models, parts, UI) is expected to be exported back to disk via other tools or by editing `.rbxmx`/`.rbxm` files directly.

## Building to a place file

For CI and production deploys:

```bash
rojo build default.project.json -o my-game.rbxlx
```

Produces a standalone `.rbxlx` place file from the current filesystem state — no Studio needed. Paired with GitHub Actions + the Roblox Open Cloud API, this is the path to fully automated deployment.

## Why it mattered

Before Rojo, Roblox development was "open the place file in Studio and edit scripts." Merges happened by hand. History was meaningless. Testing frameworks had to live inside Studio. Rojo rewrote this by treating the project as source, not as a binary.

Every modern library in the Roblox OSS world — Knit, Matter, Flamework, ProfileStore, TestEZ, Jest-Lua, Wally — assumes Rojo-style project layouts. You can't meaningfully use any of them without Rojo.

## Source

Original URL: https://github.com/rojo-rbx/rojo
Documentation: https://rojo.space/docs
Captured: 2026-04-15
