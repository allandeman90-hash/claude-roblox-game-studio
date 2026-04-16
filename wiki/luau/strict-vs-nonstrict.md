---
title: Strict vs Non-Strict Type Checking
type: luau-feature
category: luau
subcategory: type-system
owner: luau-systems-programmer
status: complete
created: 2026-04-16
updated: 2026-04-16
sources:
  - wiki/raw/luau-spec/types/types-intro.md
  - wiki/raw/roblox-creator-docs/luau/type-checking.md
  - wiki/raw/luau-spec/rfcs/new-nonstrict.md
  - wiki/raw/luau-spec/rfcs/config-luaurc.md
related:
  - "[[type-annotations]]"
  - "[[export-type]]"
  - "[[generic-types]]"
tags: [luau, type-system, strict, nonstrict]
---

# Strict vs Non-Strict Type Checking

> Luau provides three file-level type-checking modes controlled by header directives: `--!strict`, `--!nonstrict`, and `--!nocheck`.

## Syntax

Place one of these directives on the **first line** of a script file:

```lua
--!strict
-- All types are inferred and checked aggressively.

--!nonstrict
-- Types are checked only when explicitly annotated (default mode).

--!nocheck
-- Type checking is completely disabled.
```

The directive must appear before any code. Only one directive per file.

### Project-wide defaults via `.luaurc`

A `.luaurc` (JSON5) file in any directory sets the default mode for all scripts below it. Closer files override distant ones in the directory ancestry.

```json5
{
    "languageMode": "strict",
    "lint": { "*": true, "LocalUnused": false },
    "typeErrors": true,
    "globals": ["expect"]
}
```

Valid `languageMode` values: `"nocheck"`, `"nonstrict"`, `"strict"`.

In Roblox Studio, `Workspace.LuauTypeCheckMode` sets the default for all scripts in the experience.

## Semantics

### `--!strict`

The most rigorous mode. The type checker infers types for all variables and validates every assignment, call, and return. Catches errors such as:

- Adding a `string` to a `number`
- Passing wrong argument types to functions
- Returning a value that does not match the declared return type
- Accessing properties that do not exist on a typed table
- Mismatched union/intersection usage

Unannotated locals are inferred from their initializer. If inference fails, the checker reports an error rather than falling back to `any`.

### `--!nonstrict` (default)

A forgiving mode where the type checker infers `any` for variables it cannot determine. Explicit annotations are still checked, but unannotated code passes without complaint even when runtime type mismatches exist.

The checker "only asserts variable types if they are explicitly annotated." Code without annotations silently accepts most operations.

### `--!nocheck`

Type checking is completely disabled. No feedback on types, no warnings, no errors. Useful only for legacy scripts or generated code where type analysis is not helpful.

### Deviation from Lua 5.1

Lua 5.1 has no type system at all. Luau's gradual type system is an entirely new addition. The three-mode approach allows incremental adoption: start with `--!nonstrict`, annotate critical modules, then promote them to `--!strict`.

### Cross-module interaction

When a `--!strict` module requires a `--!nonstrict` module, the type checker uses whatever type information is available from the required module (exported types, inferred return types). Missing annotations in the nonstrict module surface as `any` in the strict consumer, which can suppress errors.

## Examples

### Strict mode catches type mismatches

```lua
--!strict
local function add(a: number, b: number): number
    return a + b
end

add(1, "two") -- Type error: string could not be converted into number
```

### Nonstrict mode passes unannotated code

```lua
--!nonstrict
local function add(a, b)
    return a + b
end

add(1, "two") -- No warning (parameters are inferred as `any`)
```

### Nonstrict mode still checks annotations

```lua
--!nonstrict
local function add(a: number, b: number): number
    return a + b
end

add(1, "two") -- Type error: string could not be converted into number
```

### Migration pattern: annotate then promote

```lua
-- Step 1: Start nonstrict, add annotations to public functions
--!nonstrict
local M = {}

function M.calculate(base: number, modifier: number): number
    return base * modifier
end

return M

-- Step 2: Once all public signatures are annotated, switch to strict
--!strict
```

## Pitfalls

- **Nonstrict gives false confidence.** Code compiles without warnings but crashes at runtime because unannotated parameters accept anything. Prefer `--!strict` for new code.
- **The new nonstrict mode (RFC) is stricter than the old one.** The redesigned nonstrict mode reports high-confidence runtime errors (like `"hi" + 5` or `math.abs("hi")`) even without annotations. This is a breaking change from the original behavior.
- **Cross-module `any` leakage.** A strict module consuming a nonstrict module inherits `any`-typed values, silently disabling type checking for those paths.
- **`.luaurc` discovery is directory-based.** If your project has nested directories with different configs, scripts may unexpectedly use different modes.
- **Type casts bypass checking.** `x :: any` silences all downstream type errors, which can mask real bugs in strict mode.

## Related

- [[type-annotations]]
- [[export-type]]
- [[generic-types]]

## Sources

- [Luau Types Introduction](../raw/luau-spec/types/types-intro.md)
- [Roblox Creator Docs: Type Checking](../raw/roblox-creator-docs/luau/type-checking.md)
- [RFC: New Non-Strict Mode](../raw/luau-spec/rfcs/new-nonstrict.md)
- [RFC: .luaurc Configuration](../raw/luau-spec/rfcs/config-luaurc.md)
