---
title: Selene — Modern Lua / Luau Linter
type: raw-source
source_url: https://github.com/Kampfkarren/selene
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: tooling
author: Kampfkarren
tags: [selene, linter, tooling, static-analysis]
---

# Selene — Modern Lua / Luau Linter

**Author:** Kampfkarren
**Source:** GitHub — `Kampfkarren/selene`
**Docs:** https://kampfkarren.github.io/selene/
**License:** Mozilla Public License 2.0

## What it is

Selene is a command line tool designed to help write correct and idiomatic Lua code. It is a linter — a static analysis tool that inspects source code to identify probable bugs and style violations without running the program. It's the canonical linter in the modern Roblox OSS ecosystem, used alongside StyLua (formatter) and Rojo (sync) as the "standard trio" of dev tooling.

Selene is written in Rust, specifically targets Lua 5.1 and Luau, and distinguishes itself from older tools (like Luacheck) in two specific ways: it's faster, and its rules are aimed at catching real bugs rather than enforcing style.

## The motivation

From the official motivation doc, Selene exists to address two problems:

### 1. Bug prevention through linting

Lua's permissive nature allows technically correct but logically flawed code to execute without immediate errors. Selene catches these mistakes early. A classic example from the docs is a weapon-swap function that looks like this:

```lua
function Player:SwapWeapons()
    self.CurrentWeapon = self.CurrentWeapon  -- bug: should be self.SideWeapon
    self.SideWeapon = self.SideWeapon
end
```

Selene triggers an `almost_swapped` lint because "this looks like you are trying to swap `self.CurrentWeapon` and `self.SideWeapon`" — two assignments of variables to themselves is almost always a typo of an intended swap. Bugs like this would otherwise pass tests (the function runs without error!) and only be discovered during gameplay testing.

Another example: passing multiple arguments to `pairs()`:

```lua
for k, v in pairs(t, 1) do end  -- `pairs` takes one arg, not two
```

Selene flags this; Lua itself just silently ignores the extra arg.

### 2. Enforcing idiomatic code standards

When teams collaborate or open-source projects, consistency matters. Selene helps maintain uniform coding practices across developers. Example lints in this category:

- `divide_by_zero` — flags `1 / 0` because `math.huge` is clearer
- `unused_variable` — flags locals that are assigned but never read
- `shadowing` — flags locals that shadow an outer scope's name
- `deprecated` — flags uses of deprecated APIs
- `global_usage` — flags implicit global reads/writes

These are not style-guide bikeshedding (StyLua handles formatting) — they're real correctness-adjacent issues.

## Roblox-specific standard library

Selene ships with a standard library definition file for Roblox. You tell Selene "this is a Roblox project" with a config:

```toml
# selene.toml
std = "roblox"
```

...and Selene knows about the global `game`, `workspace`, all `Instance` methods, `RunService`, `Players`, etc. Without this, a lint would flag every `game:GetService(...)` as "undefined global." With it, you get type-aware linting specifically for Roblox code.

You can also layer additional "std" files for your own globals, and you can define custom lints — the tool is extensible because Kampfkarren's philosophy is that good linters let teams codify their own conventions.

## Usage

```bash
# Lint a directory
selene src/

# Lint with a specific config
selene --config selene.toml src/

# Output in a specific format for CI
selene --display-style=Rich src/
```

The CLI is minimal on purpose — Selene is meant to be called by other tools (editors, CI, pre-commit hooks) rather than run interactively most of the time.

## Philosophy vs. Luacheck

Luacheck is the older, Lua-standard linter. It's comprehensive but slow, and its ruleset is focused on Lua 5.1–5.4 rather than Luau. Selene's differentiators:

- **Faster.** Rust-based implementation versus Luacheck's Lua.
- **Luau-aware.** Understands Luau-specific constructs (type annotations, compound assignment operators, etc.).
- **Roblox-aware.** Ships with a Roblox standard library.
- **Extensible.** Custom lints are first-class; users can write their own and share them.
- **Opinionated but humble.** Lints are designed to catch real bugs, not to enforce a specific style.

For new Roblox projects, Selene is the default choice. Luacheck is still fine for non-Roblox Lua 5.1 projects.

## CI integration

A typical GitHub Actions step:

```yaml
- name: Selene lint
  uses: NTBBloodbath/selene-action@v1.0.0
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    args: --display-style=quiet src/
```

Selene exits non-zero if any lint violation is found, so it naturally fails the build. Combined with StyLua's `--check` mode, the pair forms a solid quality gate for PRs.

## Source

Original URL: https://github.com/Kampfkarren/selene
Docs: https://kampfkarren.github.io/selene/
Motivation: https://kampfkarren.github.io/selene/motivation.html
Captured: 2026-04-15
