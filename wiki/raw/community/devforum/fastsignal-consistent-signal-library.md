---
title: FastSignal - A consistent signal library
type: raw-source
source_url: https://devforum.roblox.com/t/fastsignal-a-consistent-signal-library/1360042
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-resource
author: LucasMZ_RBX
post_date: 2021-07-19
tags: [signal, fastsignal, library, connections, events, community-resource]
---

# FastSignal: A Consistent Signal Library

**Author:** LucasMZ_RBX
**Posted:** July 19, 2021

## Overview

FastSignal is an alternative signal library designed for Roblox development that emphasizes consistency and reliability over pure speed. According to the creator, it takes "a slightly different approach" compared to GoodSignal, incorporating type checking, documentation, and addressing several architectural issues.

## Key Features

**Advantages over GoodSignal:**
- Supports `.Connected` property
- Includes `:Destroy` method to prevent new connections
- Properly calls `:Disconnect` on connections, matching RBXScriptSignal behavior
- Separates connections from linked list nodes to prevent memory leaks
- Includes full type declarations for better IDE support
- Compatible with Janitor and Maid libraries

**FastSignal-Specific Features:**
- `:Once()` method for single-fire connections
- Adaptive version that detects Deferred or Immediate signal behavior
- Multiple implementations: Immediate, Deferred, SimpleDeferred, and Adaptive modes

## API Methods

Key methods include:
- `:Connect(handler)` — connects a handler function
- `:Once(handler)` — connects a handler that fires only once
- `:Fire(...)` — triggers the signal
- `:Disconnect()` — removes a connection
- `:DisconnectAll()` — removes all connections
- `:Destroy()` — destroys the signal entirely

## Resources

- **Download:** Available on Roblox library
- **GitHub:** https://github.com/RBLXUtils/FastSignal
- **Documentation:** https://rblxutils.github.io/FastSignal/
- **Package Manager:** Available on Wally as `lucasmzreal/fastsignal`

## License

Originally released under the Unlicense, later changed to MIT License. The creator states users can use it freely without requiring attribution.

## Source

Original URL: https://devforum.roblox.com/t/fastsignal-a-consistent-signal-library/1360042
Captured: 2026-04-16
