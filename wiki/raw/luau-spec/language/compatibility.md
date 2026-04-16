---
title: Luau Compatibility with Lua 5.1/5.2/5.3/5.4
type: raw-source
source_url: https://luau.org/compatibility
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: language
tags: [luau, lua, compatibility]
---

# Luau Compatibility with Lua

## Lua 5.1 Support

Luau is built on Lua 5.1 and includes all its features except those removed for sandboxing.

**Removed features:**
- `io`, `os`, `package`, and `debug` libraries (with some exceptions)
- `loadfile`, `dofile` (no direct file access)
- `loadstring` bytecode and `string.dump` (security risks)
- `newproxy` flexibility (sandboxing constraints)

## Lua 5.2 Features

**Supported:**
- Yieldable pcall/xpcall
- Tables honoring `__len` metamethod
- Hex and `\z` escapes in strings
- Frontier patterns, `%g` in patterns, `\0` in patterns
- `bit32` library
- Stricter `string.gsub` handling
- NaN keys in tables with `__newindex`

**Not supported:**
- Yieldable xpcall error handlers
- Yieldable metamethods
- Ephemeron tables
- `goto` statements
- Finalizers for tables
- `__pairs`/`__ipairs` (replaced by `__iter`)

**Compatibility blocked:**
- Removal of `fenv` for threads/functions
- Light C functions

## Lua 5.3 Features

**Supported:**
- `\u` escapes in strings
- Basic UTF-8 support (`utf8` library)
- `string.pack/unpack/packsize`
- Floor division (`//`)
- `table.move`
- `collectgarbage("count")` returning one result
- `coroutine.isyieldable`

**Not supported:**
- 64-bit integers
- Bitwise operators (covered by `bit32`)
- Metamethod changes for `__eq`

**Compatibility blocked:**
- Stricter error checking for `table.insert`/`table.remove`

## Lua 5.4 Features

**Supported:**
- New `math.random` implementation (PCG-based)
- `lua_resetthread` and `coroutine.close`
- `print` calling `__tostring`
- UTF-8 library decoding improvements

**Not supported:**
- To-be-closed variables
- `const` variables (implemented differently as `const var = value`)
- `__lt` metamethod emulation of `__le`
- `__gc` metamethods

**Uncertain:**
- Generational GC mode
- `string.gmatch` init argument
- `string.format` `%p`
- Extended UTF-8 codepoints

## Lua 5.5 Features

**Supported:**
- Floats printed in decimal with sufficient precision

**Not supported:**
- Global variable declarations
- Read-only for-loop variables
- `table.create` signature change
- External strings

**Uncertain:**
- Named vararg tables
- `utf8.offset` enhancements
- C API functions

## Intentional Deviations from Lua

Luau differs from standard Lua in several ways:

- **Tail calls disabled:** Simplifies implementation and debugging; enhances security validation
- **Table assignment order:** Follows program order in mixed tables (unlike some Lua 5.x behavior)
- **Equality comparisons:** Call `__eq` even for rawequal objects
- **Closure reuse:** May reuse previously created closures for efficiency
- **UTC timestamps:** `os.time` returns UTC consistently

## Source

- Original URL: https://luau.org/compatibility
- Captured: 2026-04-16
