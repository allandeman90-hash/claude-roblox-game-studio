---
title: debug Library
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/libraries/debug
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, debug, library, traceback, profiler, stack-trace]
---

# debug Library

The **debug** library provides facilities for inspecting call stacks, producing stack traces, and interacting with the Studio MicroProfiler. It is more restricted than standard Lua's debug library.

> **Note:** This file was captured as a structured summary of the YAML source. Signatures and descriptions are faithful to the Roblox docs but may be slightly more concise than the original. For definitive details, see the source URL.

## Functions

### debug.traceback

```
debug.traceback(message: string = '', level: number = 1): string
debug.traceback(thread: thread, message: string = '', level: number = 1): string
```

Produces a stack trace depicting the current call hierarchy without halting execution. The `level` parameter navigates the call stack, with `1` representing the traceback call itself and incrementing upward through callers.

> **Warning:** The format and precision of the returned trace may vary. Do not parse the result for specific details like script names or line numbers.

### debug.info

```
debug.info(level: number, options: string): Tuple
debug.info(function: function, options: string): Tuple
debug.info(thread: thread, level: number, options: string): Tuple
```

Enables structured inspection of call stacks with guaranteed formatting, comparable to standard Lua's `debug.getinfo`.

The `options` string specifies desired information using characters:

| Option | Meaning |
|---|---|
| `s` | Source identifier |
| `l` | Line number |
| `n` | Function name |
| `a` | Arity (parameter count, vararg flag) |
| `f` | Function reference |

### debug.profilebegin

```
debug.profilebegin(label: string): ()
```

Initiates profiling under a specified MicroProfiler label for performance analysis.

### debug.profileend

```
debug.profileend(): ()
```

Concludes profiling for the most recently opened MicroProfiler label.

### debug.getmemorycategory

```
debug.getmemorycategory(): string
```

Retrieves the active memory classification tag for the current thread.

### debug.setmemorycategory

```
debug.setmemorycategory(tag: string): string
```

Designates a custom memory category tag for the thread and returns its prior designation.

### debug.resetmemorycategory

```
debug.resetmemorycategory(): ()
```

Restores the automatic memory category assignment (typically the script identifier).

### debug.dumpcodesize

```
debug.dumpcodesize(): ()
```

Outputs native code size metrics per function and script. Studio Command Bar only.

## Source

Original URL: https://create.roblox.com/docs/reference/engine/libraries/debug
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/libraries/debug.yaml
Captured: 2026-04-16
