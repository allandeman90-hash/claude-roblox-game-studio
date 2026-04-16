---
title: Luau Linter
type: raw-source
source_url: https://luau.org/lint
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: language
tags: [luau, lint, tooling]
---

# Luau Linter

Luau includes linting passes to help ensure code correctness and consistency. Unlike the type checker, the linter produces opinionated warnings that can often be safely ignored. Many warnings are enabled by default but can be suppressed with `--!nolint NAME` declarations at the file's top level.

## Disabling Lints

- **Individual warnings**: `--!nolint NAME` at file start
- **All warnings**: `--!nolint` at file start (type checker remains active)
- **Unused variables**: Prefix with `_` to silence specific warnings

## Complete Lint Rules (28 Total)

| # | Name | Detection |
|---|------|-----------|
| 1 | **UnknownGlobal** | Variables not in builtin table or explicitly defined; catches typos in identifiers |
| 2 | **DeprecatedGlobal** | Use of discouraged global names (primarily Roblox compatibility globals) |
| 3 | **GlobalUsedAsLocal** | Globals assigned/used in single function; suggests converting to local variables |
| 4 | **LocalShadow** | Local variables shadowing other locals or globals in same scope |
| 5 | **SameLineStatement** | Multiple statements on single line without semicolons as visual separators |
| 6 | **MultiLineStatement** | Statements spanning multiple lines with poor indentation |
| 7 | **LocalUnused** | Local variable declarations never referenced in code |
| 8 | **FunctionUnused** | Functions defined but never called |
| 9 | **ImportUnused** | `require` results assigned but never used |
| 10 | **BuiltinGlobalWrite** | Reassigning builtin globals (creates shadowing; locals recommended) |
| 11 | **PlaceholderRead** | Reading from `_` placeholder variable instead of writing to it |
| 12 | **UnreachableCode** | Code that never executes due to prior exit statements |
| 13 | **UnknownType** | Incorrect type names in `type()`, `typeof()` calls or Roblox APIs |
| 14 | **ForRange** | Numeric for loops with 0-1 iterations or uneven step division |
| 15 | **UnbalancedAssignment** | Assignment statements with mismatched variable/value counts (unless right side returns multiple values) |
| 16 | **ImplicitReturn** | Functions implicitly returning no values while others explicitly return results |
| 17 | **DuplicateLocal** | Same name used for multiple function parameters or locals in single statement |
| 18 | **FormatString** | Incorrect format strings in `string.format`, `string.pack/unpack`, pattern functions, or `os.date` |
| 19 | **TableLiteral** | Duplicate keys in table literals |
| 20 | **UninitializedLocal** | Using local variables before assignment |
| 21 | **DuplicateFunction** | Multiple functions with same name in identical scope |
| 22 | **DeprecatedApi** | Accessing methods/fields marked deprecated |
| 23 | **TableOperations** | Incorrect table library function usage or `#`/`ipairs` on non-numeric tables |
| 24 | **DuplicateCondition** | Redundant conditions in `and/or` chains or `if/elseif` statements |
| 25 | **MisleadingAndOr** | Using `a and b or c` pattern where `b` is `false`/`nil` (should use `if a then b else c`) |
| 26 | **CommentDirective** | Unrecognized or misspelled directives like `--!nostrict` |
| 27 | **IntegerParsing** | Hexadecimal/binary literals exceeding 2^64 or losing precision above 2^53 |
| 28 | **ComparisonPrecedence** | Conditions like `not X == Y` or consecutive comparisons without parentheses |

## Key Notes

- The linter operates independently from the type checker
- **UnknownGlobal** is only active in `nocheck` mode; the type checker handles it in `nonstrict`/`strict` modes
- **FormatString** warnings only apply to library function calls, not method calls (e.g., prefer `string.match()` over `:match()`)

## Source

- Original URL: https://luau.org/lint
- Captured: 2026-04-16
