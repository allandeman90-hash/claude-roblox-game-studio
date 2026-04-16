---
title: Selene Linting
type: studio
category: studio
subcategory: tooling
owner: devops-engineer
status: draft
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/tooling/selene-readme.md
  - wiki/raw/community/articles/tooling/github-actions-roblox-cicd.md
related:
  - "[[stylua-formatting]]"
  - "[[rojo-mapping]]"
  - "[[github-actions-cicd]]"
tags: [studio, tooling, selene, linter, static-analysis]
---

# Selene Linting

> Selene is the canonical Luau linter in the Roblox ecosystem -- a Rust-based static analysis tool that catches probable bugs and idiomatic violations without running the program.

## Summary

Selene inspects Lua/Luau source code and flags likely bugs and non-idiomatic patterns. It is faster than Luacheck (Rust vs. Lua), Luau-aware (type annotations, compound assignment), and ships with a Roblox standard library definition so it knows about `game`, `workspace`, `RunService`, and the rest of the Roblox API surface.

Together with [[stylua-formatting]] (formatter) and [[rojo-mapping]] (sync), Selene forms the "standard trio" of Roblox dev tooling.

## Installation

Via Aftman (recommended):

```toml
# aftman.toml
[tools]
selene = "Kampfkarren/selene@0.27.1"
```

Also available via Cargo (`cargo install selene`), Homebrew, or pre-built binaries from GitHub releases.

## Configuration (`selene.toml`)

```toml
# selene.toml
std = "roblox"
```

Setting `std = "roblox"` loads the Roblox standard library definition so Selene recognizes `game:GetService(...)`, `workspace`, `Players`, etc. Without it, every Roblox global would be flagged as undefined.

Custom globals can be layered via additional `std` files. Custom lints are extensible and sharable.

## Usage

```bash
# Lint a directory
selene src/

# Lint with a specific config
selene --config selene.toml src/

# Output format for CI (minimal, one-line-per-issue)
selene --display-style=quiet src/

# Rich output for local development
selene --display-style=Rich src/
```

Selene exits non-zero if any violation is found, making it a natural CI quality gate.

## What Selene Catches

### Bug prevention

| Lint | What it catches |
|---|---|
| `almost_swapped` | Two assignments that look like a botched variable swap |
| `divide_by_zero` | `1 / 0` (prefer `math.huge`) |
| `incorrect_standard_library_use` | Extra args to `pairs()`, wrong arg types to `table.insert()` |
| `unused_variable` | Locals assigned but never read |
| `deprecated` | Uses of deprecated Roblox APIs |
| `global_usage` | Implicit global reads/writes (likely typos) |

### Idiomatic enforcement

| Lint | What it catches |
|---|---|
| `shadowing` | Locals that shadow an outer scope's name |
| `multiple_statements` | Multiple statements on one line |
| `parenthese_conditions` | Unnecessary parentheses around `if` conditions |
| `empty_if` | `if` blocks with no body |

These are correctness-adjacent, not style-guide bikeshedding. Style formatting is handled by [[stylua-formatting]].

## Example: The Almost-Swapped Bug

```lua
function Player:SwapWeapons()
    self.CurrentWeapon = self.CurrentWeapon  -- bug: should be self.SideWeapon
    self.SideWeapon = self.SideWeapon
end
```

Selene triggers `almost_swapped`: "this looks like you are trying to swap `self.CurrentWeapon` and `self.SideWeapon`." This bug would pass tests (the function runs without error) and only be discovered during gameplay.

## CI Integration (GitHub Actions)

```yaml
- name: Selene lint
  uses: NTBBloodbath/selene-action@v1.0.0
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    args: --display-style=quiet src/
```

Combined with StyLua's `--check` mode, the pair forms a quality gate for PRs. See [[github-actions-cicd]] for the full pipeline.

## Selene vs. Luacheck

| | Selene | Luacheck |
|---|---|---|
| Language | Rust | Lua |
| Speed | Fast | Slower |
| Luau support | Yes (type annotations, compound assignment) | No |
| Roblox standard library | Built-in | Third-party config |
| Custom lints | First-class | Limited |
| Best for | Roblox / Luau projects | Non-Roblox Lua 5.1-5.4 |

For new Roblox projects, Selene is the default choice.

## Pitfalls

- **Missing `std = "roblox"`.** Without it, every `game:GetService(...)` call flags as an undefined global. Always set this for Roblox projects.
- **Noise on legacy code.** Enabling Selene on a large existing codebase may produce hundreds of warnings. Triage by severity; fix `deprecated` and `unused_variable` first.
- **Not a formatter.** Selene catches bugs; [[stylua-formatting]] enforces style. They are complementary, not substitutes.

## Related

- [[stylua-formatting]]
- [[rojo-mapping]]
- [[github-actions-cicd]]

## Sources

- [Selene README](../raw/community/articles/tooling/selene-readme.md) -- GitHub `Kampfkarren/selene`
- [GitHub Actions CI/CD for Roblox](../raw/community/articles/tooling/github-actions-roblox-cicd.md)
- Official docs: https://kampfkarren.github.io/selene/
