---
title: "RFC: Buffer Type"
type: raw-source
source_url: https://github.com/luau-lang/rfcs/blob/master/docs/type-byte-buffer.md
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: rfc
tags: [luau, rfc, buffer, binary]
---

# RFC: Buffer Type

**Status:** Implemented

## Overview

The Luau buffer type is a new built-in data structure providing a mutable byte array with comprehensive read/write capabilities, addressing performance limitations in handling binary data.

## Motivation

> "A binary blob may be represented as an array of numbers 0-255 (idiomatic and reasonably performant, but very space-inefficient"

Strings only support read-only operations. The buffer type solves use cases requiring "efficient binary access" for tasks like compression, hashing, and data format encoding/decoding.

## Design Principles

- **Fixed-size allocation**: Created via `buffer.create(size)` with all bytes initialized to zero
- **Zero-based indexing**: Offsets begin at 0 rather than 1 (aligns with data format specs, improves performance)
- **Immutable metatables**: Metatables cannot be set directly via Luau code
- **Unaligned access support**: Read/write operations work at any offset
- Implemented as a GCObject with a new tag

## Core API Functions

**Creation/Conversion:**
- `buffer.create(size)`
- `buffer.fromstring(str)`
- `buffer.tostring(b)`
- `buffer.len(b)`

**Data Manipulation:**
- `buffer.copy()` — supports overlapping regions
- `buffer.fill()`
- `buffer.readstring()` / `buffer.writestring()`

**Integer Operations:**
- Signed reads: `readi8`, `readi16`, `readi32`
- Unsigned reads: `readu8`, `readu16`, `readu32`
- Matching write functions

**Floating-Point Operations:**
- `readf32` / `writef32` — 32-bit IEEE 754
- `readf64` / `writef64` — 64-bit IEEE 754

## Technical Specifications

- **Byte ordering**: Little-endian for all multi-byte operations
- **Integer representation**: Two's complement for signed values
- **Error handling**: Out-of-bounds access throws errors
- **Floating-point**: NaN values may be reinterpreted as different quiet NaN representations

## C API Integration

- `lua_tobuffer()` — retrieve pointer and size
- `lua_newbuffer()` — create new buffer on stack
- `lua_isbuffer()` — type checking macro
- `luaL_checkbuffer()` — argument validation
- `luaopen_buffer()` — library registration

## Source

- Original URL: https://github.com/luau-lang/rfcs/blob/master/docs/type-byte-buffer.md
- Captured: 2026-04-16
