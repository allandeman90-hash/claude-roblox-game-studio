---
title: Rojo Mapping
type: studio
category: studio
subcategory: tooling
owner: devops-engineer
status: complete
created: 2026-04-16
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/tooling/rojo-readme.md
  - wiki/raw/community/reddit/rojo-vscode-workflow.md
  - wiki/raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md
related:
  - "[[client-server-split]]"
  - "[[wally-packages]]"
  - "[[open-cloud-api]]"
  - "[[github-actions-cicd]]"
  - "[[selene-linting]]"
  - "[[stylua-formatting]]"
tags: [studio, tooling, rojo, filesystem-sync, git]
---

# Rojo Mapping

> Rojo syncs a filesystem directory to Roblox Studio's DataModel, turning an opaque place file into a directory of plaintext files suitable for Git.

## Summary

Rojo is the single most important infrastructure tool in the modern Roblox OSS ecosystem. It maps files and directories on disk to Roblox Instances (Scripts, LocalScripts, ModuleScripts, Models) based on naming conventions and a JSON project file. Nearly every framework, testing library, and package manager in the ecosystem assumes a Rojo-driven project layout.

The sync is one-way: filesystem to Studio. Work done inside Studio (models, parts, UI) is exported back to disk via `.rbxmx`/`.rbxm` files or other tools.

## Workflow

### Live sync (development)

1. Run `rojo serve` in the project directory. It starts an HTTP server on `localhost:34872`.
2. Open Roblox Studio, install the Rojo plugin, click **Connect**.
3. Studio pulls the project tree from the server.
4. Every file save on disk is pushed to Studio within milliseconds. Code is edited in VS Code; the in-Studio scripts update live.

### Building a place file (CI/CD)

```bash
rojo build default.project.json -o my-game.rbxlx
```

Produces a standalone `.rbxlx` place file from the current filesystem state. No Studio session required. This is the input for automated deployment via the Open Cloud Place Publishing API (see [[open-cloud-api]]).

## Project File (`default.project.json`)

The project file maps filesystem directories to the DataModel tree:

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

`$path` points at a directory on disk. Rojo walks the directory and builds Roblox instances from file extensions.

## File Extension Mapping

| File extension | Becomes | Notes |
|---|---|---|
| `*.server.luau` / `*.server.lua` | `Script` | Runs on the server |
| `*.client.luau` / `*.client.lua` | `LocalScript` | Runs on the client |
| `*.luau` / `*.lua` | `ModuleScript` | Importable module |
| `*.model.json` | Explicit instance with properties | Manual instance definition |
| `*.rbxmx` / `*.rbxm` | Model file | Binary or XML model import |
| `init.server.luau` | Script (folder becomes the instance) | Similar to Python's `__init__.py` |
| `init.client.luau` | LocalScript (folder becomes the instance) | |
| `init.luau` / `init.lua` | ModuleScript (folder becomes the instance) | |

This is the convention the entire ecosystem builds on. Every tutorial, library, and boilerplate assumes this layout.

## Typical Project Layout

```
game-project/
  default.project.json    -- Rojo project definition
  wally.toml              -- Package manifest (see [[wally-packages]])
  aftman.toml             -- Toolchain versions
  selene.toml             -- Linter config (see [[selene-linting]])
  stylua.toml             -- Formatter config (see [[stylua-formatting]])
  src/
    server/               -- -> ServerScriptService
      init.server.luau
      Services/
    client/               -- -> StarterPlayerScripts
      init.client.luau
      Controllers/
    shared/               -- -> ReplicatedStorage.Shared
      Types.luau
      Config.luau
  Packages/               -- Wally-managed dependencies
  .gitignore
```

## Comparison with Argon

Argon is an alternative sync tool. Both serve the same purpose (filesystem to Studio), but Rojo has wider ecosystem adoption. Every major library (Knit, Matter, Flamework, ProfileStore, TestEZ, Jest-Lua, Wally) assumes Rojo-style project layouts.

## Pitfalls

- **One-way sync.** Changes made in Studio (moving parts, editing terrain, placing UI) are not automatically written back to disk. Models must be exported manually.
- **Team Create conflicts.** Rojo and Team Create can conflict. The recommended pattern is to use Git for code collaboration and reserve Team Create for live world-editing sessions.
- **Instance types not supported by Open Cloud publish.** The Open Cloud Place Publishing API cannot upload `EditableImage`, `EditableMesh`, `PartOperation`, `SurfaceAppearance`, or `BaseWrap`. If your place contains these, publish from Studio when they change; let CI/CD handle script-only updates.

## Related

- [[client-server-split]]
- [[wally-packages]]
- [[open-cloud-api]]
- [[github-actions-cicd]]
- [[selene-linting]]
- [[stylua-formatting]]

## Sources

- [Rojo README](../raw/community/articles/tooling/rojo-readme.md) -- GitHub `rojo-rbx/rojo`
- [Rojo + VS Code workflow (Reddit)](../raw/community/reddit/rojo-vscode-workflow.md)
- [Place Publishing CI/CD](../raw/community/monetization/open-cloud/place-publishing-cicd-github-actions.md)
- Official docs: https://rojo.space/docs
