---
title: Luau Sandboxing
type: raw-source
source_url: https://luau.org/sandbox
source_type: luau-spec
captured_at: 2026-04-16
captured_by: research-agent-5
category: luau-spec
subcategory: performance
tags: [luau, sandbox, security, embedding]
---

# Luau Sandboxing

Luau is designed to safely embed untrusted code through a multi-layered approach: removing unsafe standard library functions, implementing VM-level isolation features, and maintaining memory safety through implementation practices and fuzzing.

## Removed/Restricted Libraries

### Completely Removed

- `io` library (file and process access)
- `package` library (file access and native module loading)
- `debug` library (memory safety issues and isolation breaches)
- `dofile` and `loadfile` (filesystem access)
- `string.dump` and `load` (bytecode access)
- `module` (global package overriding)

### Restricted Functions

- `os` library: Only `clock`, `date`, `difftime`, and `time` remain; removed are `execute`, `exit`, and environment access functions
- `collectgarbage`: Works only with `"count"` argument to prevent GC state interference
- `newproxy`: Limited to `true`/`false`/`nil` arguments

### Known Limitations

The documentation notes that `getfenv`/`setfenv` result in additional isolation challenges by allowing globals injection into call stacks, though these remain enabled due to community reliance.

## Environment Isolation

Default globals are protected through readonly table marking:

- All libraries (`string`, `math`, etc.) are readonly
- String metatable is readonly
- Global table itself is readonly

This VM-level write protection prevents monkey-patching through assignments, `rawset`, and `setmetatable`. Per-script isolation is achieved by "creating a new global table for each script, that uses `__index` to point to the builtin global table," allowing local variable assignment while protecting shared builtins.

## Memory Safety: `__gc` Removal

Luau explicitly rejects `__gc` (garbage collector finalizers) because they:

- Degrade garbage collection performance
- Create memory safety vulnerabilities when objects are accessed post-finalization
- Allow arbitrary script code execution during GC
- Remove object identity guarantees needed for trusted code isolation

Tag-based destructors (host-only, not script-accessible) replace this functionality.

## CPU/Memory Limits

The VM provides "a global interrupt mechanism, where the host can setup an interrupt handler at any point, and any Luau code is guaranteed to call this handler eventually." This enables terminating runaway scripts at function calls or loop iterations. Roblox implements this via a watchdog limiting scripts to 10 seconds in Studio and interrupting all scripts 1 second after client shutdown.

No default memory limits are imposed on Luau allocations themselves, though rich host APIs may introduce exhaustion risks.

## Source

- Original URL: https://luau.org/sandbox
- Captured: 2026-04-16
