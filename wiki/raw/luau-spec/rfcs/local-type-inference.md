---
title: "RFC: Local Type Inference (New Type Solver)"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/local-type-inference.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, types, type-inference, type-solver]
---

# RFC: Local Type Inference

## Overview

Luau is transitioning from its current type solver to one based on Benjamin Pierce's Local Type Inference algorithm, which separates type inference from type checking.

## Motivation

The existing solver has two main limitations:

1. **Inefficient for nonstrict mode**: Type inference runs twice — once for error feedback and once for autocomplete — because inference results weren't suitable for autocomplete in permissive mode.

2. **Inaccurate type narrowing**: The current solver "jumps to conclusions a little bit too quickly." For example, it incorrectly infers that a search function returning either a number or nil must have type `number` for both return statements.

## Core Algorithm Changes

### Bounds-Based Type Tracking

The new approach represents free types through upper and lower bounds:

- **Lower bounds**: Values a binding might receive (from assignments, returns, uses)
- **Upper bounds**: Constraints from annotations and operations

All free types start as `never <: 't <: unknown`, representing unrestricted values.

### Constraint Dispatch Rules

When processing constraints:
- `T <: 't` expands the lower bound
- `'t <: T` narrows the upper bound

This allows bounds to gradually refine throughout inference.

### Generalization Strategy

During function signature analysis, unconstrained types become generics. Types appearing only in covariant positions adopt their lower bounds; contravariant-only types use upper bounds.

## Practical Impact

The `index_of` function example: rather than forcing both return statements to share a type, the new solver correctly infers `number | nil` by unioning the lower bounds.

## Trade-offs

The algorithm is more permissive, allowing constructs like reassigning variables to entirely different types without annotations. However, this enables better autocomplete for untyped code while maintaining strict mode accuracy.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/local-type-inference.md
- Captured: 2026-04-16
