---
title: StyLua — Deterministic Lua / Luau Formatter
type: raw-source
source_url: https://github.com/JohnnyMorganz/StyLua
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: tooling
author: JohnnyMorganz
tags: [stylua, formatter, luau, prettier]
---

# StyLua — Deterministic Lua / Luau Formatter

**Author:** JohnnyMorganz
**Source:** GitHub — `JohnnyMorganz/StyLua`

## What it is

StyLua is a code formatter for Lua. It parses your Lua codebase and prints it back out from scratch, enforcing a consistent code style. It supports multiple Lua variants including Lua 5.1–5.4, LuaJIT, Luau, and CfxLua (FiveM Lua), built on the full-moon parser. It is the Prettier of the Lua world and is the standard formatter in nearly every serious Roblox OSS project.

The tool draws inspiration from Prettier and primarily adheres to the Roblox Lua Style Guide with minor modifications.

## Installation

Multiple installation paths are supported:

- **GitHub Releases** — pre-built binaries with all syntax variants enabled
- **Cargo** — `cargo install stylua`, with optional feature flags for specific Lua versions (`--features luau`, `--features lua54`, etc.)
- **GitHub Actions** — the `JohnnyMorganz/stylua-action` for CI/CD pipelines
- **pre-commit** — `.pre-commit-config.yaml` integration so every git commit auto-formats
- **npm** — `@johnnymorganz/stylua-bin` as a binary wrapper, or a WASM library
- **Docker** — on Docker Hub
- **Homebrew** — `brew install stylua`
- **Editor integrations** — VS Code extension, Sublime, Neovim, Zed

## Core usage

```bash
stylua src/ foo.lua bar.lua
```

The tool accepts files and directories and processes them in place. Passing `-` reads from stdin. Glob patterns filter files during directory traversal using `**/*.lua` by default (or `**/*.luau` when the Luau feature is enabled).

## Key features

### Ignore directives

- Inline: `-- stylua: ignore` (followed by the node to skip)
- File-level: `.styluaignore` similar to `.gitignore`

This is critical for hand-formatted tables (e.g., big state machines) that StyLua would otherwise rewrite.

### Range formatting

`--range-start <line>` and `--range-end <line>` enable formatting specific line ranges. This is what editor "Format Selection" features use under the hood.

### Verification and check mode

- `--check` — validates formatting without modifying files. Exits non-zero if changes would be needed. The canonical CI guard.
- `--verify` — re-parses the formatted output to ensure the formatter did not break the AST (defense in depth).

### Require sorting

Optional lexicographic sorting of consecutive `local NAME = require(EXPR)` statements. Keeps import blocks tidy and minimizes merge conflicts.

### LSP mode

`stylua --lsp` runs StyLua as a Language Server Protocol provider so editors can call it via the standard formatting endpoint.

## Configuration (`stylua.toml`)

StyLua searches for `stylua.toml` or `.stylua.toml` walking upward from the file being formatted. Key options:

| Setting | Default | Purpose |
|---|---|---|
| `syntax` | `All` | Disambiguate Lua dialect (`Lua51`–`Lua54`, `LuaJIT`, `Luau`, `CfxLua`) |
| `column_width` | `120` | Line wrap target (soft) |
| `indent_type` | `Tabs` | `Tabs` or `Spaces` |
| `indent_width` | `4` | Indent size (in spaces, for spaces mode) |
| `quote_style` | `AutoPreferDouble` | String delimiter rule |
| `call_parentheses` | `Always` | Single-arg call paren rule |
| `space_after_function_names` | `Never` | Space between `function foo` and `()` |

The tool also respects `.editorconfig` when no `.stylua.toml` exists, and supports custom paths via `--config-path`.

## The Roblox convention

Roblox OSS projects overwhelmingly use:

```toml
# stylua.toml
syntax = "Luau"
column_width = 120
indent_type = "Tabs"
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
```

This matches the Roblox Lua Style Guide closely and has become the de-facto standard. Running `stylua --check src/` in CI is the universal quality gate that rejects PRs that don't match the project style.

## Why it mattered

Before StyLua, every Roblox project had subtly different indentation, quoting, and line-wrapping rules. Code reviews bikeshedded style. After StyLua, the question is solved: "run the formatter, commit the result." StyLua combined with Selene (linting) and Rojo (sync) is the canonical trio that turns a Roblox place file into a real software project.

## Source

Original URL: https://github.com/JohnnyMorganz/StyLua
Captured: 2026-04-15
