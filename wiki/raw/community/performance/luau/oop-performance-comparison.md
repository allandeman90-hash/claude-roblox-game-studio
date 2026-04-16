---
title: OOP Approaches in Luau - Performance Comparison
type: raw-source
source_url: https://devforum.roblox.com/t/3-different-oop-approaches-performance-memory-consumption-and-aesthetics/1601163
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-9
category: performance
subcategory: luau
tags: [oop, metatables, closures, memory, benchmark]
---

# OOP Approaches in Luau - Performance Comparison

Three common OOP approaches benchmarked: metatable-based, closure-based, and table-with-methods.

## Instantiation Speed (per 100,000 objects)

| Approach | Time |
|----------|------|
| **Metatable-based** | **0.016 s** (fastest) |
| Table-with-methods | 0.018 s |
| Closure-based | 0.033 s |

Metatables are ~2x faster to instantiate than closures.

## Method Invocation Speed (per 2,000,000 calls)

| Approach | Time |
|----------|------|
| **Closure-based** | **0.063 s** (fastest) |
| Table-with-methods | 0.067 s |
| Metatable-based | 0.079 s |

Closures are slightly faster at calling, due to direct local lookup vs metatable chain.

## Memory Consumption (per 1,000,000 objects)

| Approach | Memory |
|----------|--------|
| **Metatable-based** | **195,312 kB** (lowest) |
| Table-with-methods | 320,312 kB |
| Closure-based | 421,875 kB |

Metatables use **2.2x less memory** than closures (all methods share one metatable).

## Conclusion

"The metatable approach is undoubtedly the most efficient and optimal one" for most use cases.

- **Metatables**: Best memory, fastest instantiation, slightly slower calls
- **Closures**: Fastest calls but heaviest memory, slowest instantiation (true privacy)
- **Table-with-methods**: No advantages, worst-of-both

## The __call Constructor

Using `__call` metamethod for nicer syntax incurs no performance penalty:

```lua
local Car = {}
Car.__index = Car

setmetatable(Car, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Car:init(color)
    self.color = color
end

function Car:honk()
    print(self.color, "car honks!")
end

-- Use like a constructor:
local myCar = Car("red")
myCar:honk()
```

This is **0.016 s for 100k instantiations** - negligible overhead.

## Canonical Metatable OOP Pattern

```lua
local Foo = {}
Foo.__index = Foo

function Foo.new(x, y)
    local self = setmetatable({}, Foo)
    self.x = x
    self.y = y
    return self
end

function Foo:sum()
    return self.x + self.y
end

return Foo
```

This is the canonical, optimal pattern in Luau.

## Measurements / Numbers

| Metric | Value |
|--------|-------|
| Metatable instantiation | 0.016 s / 100k |
| Closure instantiation | 0.033 s / 100k |
| Metatable memory | 195 MB / 1M |
| Closure memory | 422 MB / 1M |
| Metatable call speed | 0.079 s / 2M |
| Closure call speed | 0.063 s / 2M |

## Source

Original URL: https://devforum.roblox.com/t/3-different-oop-approaches-performance-memory-consumption-and-aesthetics/1601163
Captured: 2026-04-16
