---
title: "RFC: Function Inlining"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/function-inlining.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, performance, inlining]
---

# RFC: Function Inlining (Not Adopted)

## Overview

This document explains why Luau does **not** support user-controlled function inlining, favoring automatic compiler optimizations instead.

## Motivation

Developers prioritize automatic inlining at optimization level `-O2` and higher because manually specified inlining could introduce significant performance risks — preventing developers from creating unbounded bytecode expansion through careless inlining directives.

## Key Problems Identified

**Recursive Functions:** "Inlining a recursive function would mean either the bytecode size is infinite, or the generated code is effectively the same as a loop" through tail call optimization.

**Mutable Table Exports:** When modules export mutable tables, the compiler cannot guarantee that function implementations haven't changed between module boundaries, making safe inlining impossible.

**Object-Oriented Patterns:** Classes using metatables can have methods overloaded at runtime. Instances could modify inherited methods, preventing reliable inlining.

**Metamethods:** Dynamic dispatch mechanisms prevent statically linking operators (like `+`) to their metamethod implementations (`__add`).

## Design Rationale

Rather than expose inlining to user control, developers should submit GitHub issues with performance-critical code samples. The Luau team will use legitimate cases to improve automatic compiler optimizations.

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/function-inlining.md
- Captured: 2026-04-16
