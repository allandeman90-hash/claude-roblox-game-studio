---
title: Luau Syntax Grammar
type: raw-source
source_url: https://luau.org/grammar
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: language
tags: [luau, grammar, ebnf]
---

# Luau Syntax Grammar (EBNF Overview)

The complete Luau grammar is specified in EBNF format on the official grammar page. Key rules covered:

## Core Structure

- **chunk** / **block** — program structure with statements and optional final return
- **stat** — assignments, function calls, control flow (`while`, `repeat`, `if`), loops, declarations
- **laststat** — `return`, `break`, `continue`

## Expressions

Expression grammar is organized through operator precedence:
- **binop** — arithmetic, comparison, logical
- **unop** — negation, logical not (`not`), length (`#`)

## Functions

Function definitions support:
- Generic type parameters
- Parameter lists with variadic arguments (`...`)
- Optional return type annotations
- Defined via **funcbody** rule

## Type Grammar

- **SimpleType** — primitives, named types, `typeof` expressions, table types, function types
- **Union** / **Intersection** — combines with `|` and `&`
- **GenericTypeList** / **GenericTypeListWithDefaults** — parameterized types
- **TableType** / **FunctionType** — specialized type definitions

## Tables

Table constructors support mixed field syntax:
- `[exp] = exp`
- `NAME = exp`
- positional values

The specification also includes complete rules for:
- Attributes (`@native`, `@deprecated`, etc.)
- Compound assignment operators (`+=`, `-=`, etc.)
- String interpolation syntax (backtick literals)

## Source

- Original URL: https://luau.org/grammar
- Captured: 2026-04-16
