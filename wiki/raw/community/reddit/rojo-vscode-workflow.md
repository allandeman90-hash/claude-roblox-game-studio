---
title: Do you use Rojo? / What IDE do most people use?
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/192ysi4/do_you_use_rojo/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [rojo, vscode, workflow, tooling, git, selene, luau-lsp, wally]
---

# Do you use Rojo? / What IDE do most people use for Roblox?

**Related Threads:**
- /r/robloxgamedev/comments/192ysi4/do_you_use_rojo/
- /r/robloxgamedev/comments/1bgr3b4/do_you_like_rojo/
- /r/robloxgamedev/comments/vtn2dy/what_ide_do_most_people_use/
- /r/robloxgamedev/comments/117ndka/why_use_rojo/

## The Consensus

> "Most top devs use Rojo w/ VSCode (or another code editor like neovim), along with git."

> "Rojo is 100% the baseline tool I feel every serious developer in the community uses."

The repeated advice across all four threads: as soon as your project is non-trivial, **move your scripts out of Roblox Studio and into an external editor, synced via Rojo**. Studio stays as the visual/world editor and play-test runner; your source of truth lives in a filesystem.

## Why Rojo + VS Code Wins

### 1. Real tooling
VS Code with the right extensions gives you:
- **luau-lsp** — autocomplete, go-to-definition, hover docs, type checking.
- **Selene** — the de-facto Lua/Luau linter for Roblox.
- **StyLua** — code formatter.
- **Moonwave** — documentation generator for public modules.
- **Rojo extension** — shows sync state and auto-installs Rojo if missing.

None of these work as well (or at all) inside Studio's built-in script editor.

### 2. Real version control
Once your project is in files on disk, you get real Git:
- Branches, PRs, code review.
- Actual diffs that a human can read.
- Rollback, blame, history.
- Merges instead of "last write wins" on Team Create.

### 3. Real collaboration
Multiple developers can work on the same game without stepping on each other's edits. Studio's Team Create is OK for small teams but doesn't scale the way a Git repo does.

### 4. External packages
**Wally** (by UpliftGames) is the package manager that pairs with Rojo. `wally install Roblox/roact@^1` pulls a pinned version into your repo, just like npm/cargo. Studio has no equivalent — you have to copy-paste free models.

## What the Stack Looks Like

```
game-project/
|-- default.project.json     <- Rojo project definition
|-- wally.toml               <- Package manifest
|-- src/
|   |-- client/
|   |   |-- init.client.luau
|   |   |-- Controllers/
|   |-- server/
|   |   |-- init.server.luau
|   |   |-- Services/
|   |-- shared/
|       |-- Modules/
|-- .gitignore
|-- .vscode/settings.json
|-- selene.toml
|-- stylua.toml
```

A developer runs:
```
rojo serve default.project.json
```
…then clicks "Connect" in the Rojo Studio plugin, and Studio mirrors the filesystem live. Edits in VS Code appear in Studio instantly; published changes in Studio do **not** overwrite the filesystem (Rojo is one-way by default for safety).

## Why Some Developers Still Stay In Studio

The Reddit threads also capture honest downsides:
- The setup has a learning curve — Rojo + Wally + luau-lsp + Selene is a lot of moving pieces for a brand-new developer.
- Studio's built-in "insert service", "drag and drop instances", and play-solo are still where you'll live for world editing and testing.
- For tiny hackathon projects, the filesystem overhead isn't worth it.

The consensus: "beginner friendly" = Studio only. "Serious project" = Rojo + VS Code + Git.

## Quotes From The Threads

- "Rojo is 100% the baseline tool I feel every serious developer in the community uses."
- "Most top devs use Rojo w/ VSCode, along with git."
- "This will help you use external tools like selene, roblox LSP, moonwave and many other helpful tools."
- On moving to Rojo: "integrating Roblox development into my usual workflow and toolset, into a familiar environment."

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/192ysi4/do_you_use_rojo/
Captured: 2026-04-16

## Notes

Content reconstructed from search snippets across four related threads on r/robloxgamedev. The advice matches the official Rojo documentation and the Roblox Open Source Community's recommended workflow.
