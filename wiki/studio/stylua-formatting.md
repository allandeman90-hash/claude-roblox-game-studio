---
title: StyLua Formatting
type: studio
category: studio
subcategory: tooling
owner: devops-engineer
status: draft
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/tooling/stylua-readme.md
  - wiki/raw/community/articles/tooling/github-actions-roblox-cicd.md
related:
  - "[[selene-linting]]"
  - "[[rojo-mapping]]"
  - "[[github-actions-cicd]]"
tags: [studio, tooling, stylua, formatter, code-style]
---

# StyLua Formatting

> StyLua is a deterministic code formatter for Lua/Luau -- the Prettier of the Lua world. It parses code and reprints it from scratch, enforcing a consistent style.

## Summary

StyLua is the standard formatter in nearly every serious Roblox OSS project. It supports Lua 5.1-5.4, LuaJIT, Luau, and CfxLua, built on the full-moon parser. The tool draws inspiration from Prettier and primarily follows the Roblox Lua Style Guide.

Combined with [[selene-linting]] (bug detection) and [[rojo-mapping]] (sync), StyLua completes the canonical tooling trio for professional Roblox development.

## Installation

Via Aftman (recommended):

```toml
# aftman.toml
[tools]
stylua = "JohnnyMorganz/StyLua@0.20.0"
```

Also available via Cargo (`cargo install stylua --features luau`), Homebrew, npm (`@johnnymorganz/stylua-bin`), Docker, or pre-built binaries.

### Editor Integration

- **VS Code:** StyLua extension (format on save)
- **Neovim:** via null-ls or conform.nvim
- **Sublime:** via LSP
- **Zed:** built-in support

## Configuration (`stylua.toml`)

```toml
# stylua.toml -- the Roblox convention
syntax = "Luau"
column_width = 120
indent_type = "Tabs"
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
```

This matches the Roblox Lua Style Guide and is the de-facto standard across the ecosystem.

### All Options

| Setting | Default | Purpose |
|---|---|---|
| `syntax` | `All` | Lua dialect: `Lua51`, `Lua52`, `Lua53`, `Lua54`, `LuaJIT`, `Luau`, `CfxLua` |
| `column_width` | `120` | Soft line wrap target |
| `indent_type` | `Tabs` | `Tabs` or `Spaces` |
| `indent_width` | `4` | Indent size (for spaces mode) |
| `quote_style` | `AutoPreferDouble` | String delimiter rule |
| `call_parentheses` | `Always` | Single-arg call paren rule |
| `space_after_function_names` | `Never` | Space between `function foo` and `()` |

StyLua searches for `stylua.toml` or `.stylua.toml` walking upward from the file being formatted. Also respects `.editorconfig` when no `.stylua.toml` exists.

## Usage

```bash
# Format files in place
stylua src/ foo.lua bar.lua

# Check mode (CI): exit non-zero if changes needed
stylua --check src/

# Verify mode: re-parse output to ensure AST is preserved
stylua --verify src/

# Format from stdin
cat script.lua | stylua -

# Format specific line range (used by editor "Format Selection")
stylua --range-start 10 --range-end 50 script.lua

# Run as LSP server
stylua --lsp
```

## Key Features

### Ignore Directives

```lua
-- stylua: ignore
local data = {
    {"Alice",  100, true },
    {"Bob",    200, false},
    {"Charlie",300, true },
}
```

Use `-- stylua: ignore` before a node to skip formatting. Essential for hand-formatted tables (state machines, config matrices).

File-level ignore via `.styluaignore` (same syntax as `.gitignore`).

### Require Sorting

Optional lexicographic sorting of consecutive `local NAME = require(EXPR)` statements. Keeps import blocks tidy and minimizes merge conflicts.

### Check Mode for CI

```bash
stylua --check src/
```

Exits non-zero if any file would be reformatted. This is the canonical CI guard -- combined with Selene, it forms the quality gate for PRs.

## CI Integration (GitHub Actions)

```yaml
- name: StyLua check
  uses: JohnnyMorganz/stylua-action@v4
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    version: latest
    args: --check src/
```

See [[github-actions-cicd]] for the full pipeline.

## Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/JohnnyMorganz/StyLua
    rev: v0.20.0
    hooks:
      - id: stylua-system
```

Automatically formats every commit so PRs never have style diff noise.

## Pitfalls

- **Not a linter.** StyLua enforces formatting (indentation, line wrapping, quoting). It does not catch bugs -- that is [[selene-linting]]'s job. The two are complementary.
- **Hand-formatted tables.** StyLua will rewrite carefully aligned tables. Use `-- stylua: ignore` before tables that need custom formatting.
- **Tab vs. space disagreements.** The Roblox convention uses Tabs. If your project uses spaces, set `indent_type = "Spaces"` in `stylua.toml` before running StyLua on the codebase.

## Related

- [[selene-linting]]
- [[rojo-mapping]]
- [[github-actions-cicd]]

## Sources

- [StyLua README](../raw/community/articles/tooling/stylua-readme.md) -- GitHub `JohnnyMorganz/StyLua`
- [GitHub Actions CI/CD for Roblox](../raw/community/articles/tooling/github-actions-roblox-cicd.md)
