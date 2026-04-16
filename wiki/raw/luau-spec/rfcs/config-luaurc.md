---
title: "RFC: .luaurc Configuration"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/config-luaurc.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, config, tooling]
---

# RFC: .luaurc Configuration

## File Format

`.luaurc` is a JSON5 file (supporting comments and trailing commas) that can be placed in any directory. For a given Lua file, Luau searches the directory ancestry for configuration files, with closer files overriding distant ones.

## Configuration Options

**`languageMode`** — Controls type checking strictness
- Options: `"nocheck"`, `"nonstrict"`, `"strict"`
- Default: `"nonstrict"`

**`lint`** — Enables or disables linting rules
- Maps rule names to boolean values
- Special value `"*"` enables/disables all rules
- Default: A predefined set of lint warnings enabled

**`lintErrors`** — Boolean controlling whether lint issues report as errors or warnings
- Default: `false` (warnings)

**`typeErrors`** — Boolean controlling whether type issues report as errors or warnings
- Default: `true` (errors)

**`globals`** — Array of strings naming globals assumed valid with type `any`
- Useful for test frameworks and external dependencies

## Example Configuration

```json5
{
    "languageMode": "nonstrict",
    "lint": { "*": true, "LocalUnused": false },
    "lintErrors": true,
    "globals": ["expect"]
}
```

This configuration enables all lints except unused locals, treats lints as errors, and assumes `expect` is a valid global.

## Legacy Compatibility

`.robloxrc` files support older formats with `"language"` objects and string values like `"disabled"` / `"enabled"` / `"fatal"` for lint rules, maintained for backward compatibility only.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/config-luaurc.md
- Captured: 2026-04-16
