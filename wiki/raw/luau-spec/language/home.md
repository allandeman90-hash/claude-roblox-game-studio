---
title: Luau Home / Why Luau
type: raw-source
source_url: https://luau.org/
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: language
tags: [luau, overview]
---

# Luau Programming Language

> "Luau is a small, fast, and embeddable programming language based on Lua with a gradual type system."

The language emphasizes performance through a fast bytecode compiler and JIT support, safety via an advanced type system with type refinements, and accessibility through straightforward syntax.

## Origin and Context

Luau emerged from Roblox's evolution. The platform began using Lua 5.1 around 2006 but faced mounting challenges as their codebase and user base expanded. As the company consolidated development efforts across player-facing applications, in-game UI, and editor tools, they needed a language that could support both novice developers and professional studios with better performance and code quality.

## Core Design Philosophy

> "Having grown a substantial internal codebase that needed to be correct and performant...there was a need to improve performance and quality of the code we were writing."

Rather than adopting existing faster Lua implementations, the team prioritized three factors that alternatives couldn't meet: portability, ease of modification, and support for writing robust code at scale.

## Key Features

Luau focuses on making the language "more performant and feature-rich, and make it easier to write robust code through a combination of linting and type checking using a gradual type system."

- Backwards compatible with Lua 5.1 (with sandboxing-motivated exclusions)
- Gradual type annotations with state-of-the-art type inference
- Heavily optimized runtime based on modified Lua 5.1
- Sandboxed execution environments
- Lua 5.x API compatibility with minor deviations

## Technical Architecture

The compiler and analysis tools were rebuilt from scratch with a multi-pass architecture instead of Lua's single-pass design. This enables complex semantic analysis and better bytecode optimizations. The runtime interpreter was similarly rewritten, incorporating techniques from LuaJIT while maintaining C implementation. Later developments added optional native code generation for x64 and arm64 platforms.

The garbage collector and core libraries retained Lua 5.1 as a baseline but underwent incremental modernization.

## Current Adoption

Originally developed for Roblox game developers, Luau has expanded to commercial titles including Alan Wake 2, Farming Simulator 2025, Second Life, and Warframe.

## Command-Line Tools

- **luau** — A REPL and script runner (sandboxed without filesystem access except module loading)
- **luau-analyze** — A type checker and linter configurable via file comments or `.luaurc` configuration files

## Installation

- Download binaries from https://github.com/luau-lang/luau/releases
- Package managers: Homebrew (macOS), pacman (Arch), apk (Alpine), emerge (Gentoo)

Building from source requires CMake with C++17 support (gcc-7, clang-7, or MSVC 2017+).

## License

MIT License with attribution requested for integrated projects.

## Source

- Original URL: https://luau.org/
- GitHub: https://github.com/luau-lang/luau
- Captured: 2026-04-16
