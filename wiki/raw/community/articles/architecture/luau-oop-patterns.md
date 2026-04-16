---
title: OOP Patterns in Luau — Metatables, __index, and Typed Classes
type: raw-source
source_url: https://devforum.roblox.com/t/object-oriented-programming-with-luau-in-2023/2135043
captured_at: 2026-04-15
captured_by: research-agent-8
category: community-article
subcategory: architecture
tags: [oop, metatables, classes, luau, type-checking, __index]
---

# OOP Patterns in Luau — Metatables, __index, and Typed Classes

**Sources:** Roblox DevForum community tutorials on OOP with Luau + Roblox Lua Style Guide

## Context

Luau (and Lua generally) has no native `class` keyword. What the community calls "OOP in Luau" is a convention built on three primitives:

1. A table that holds the class's methods (the "class table")
2. A table for each instance that holds per-object state (the "instance table")
3. A metatable relationship (`__index`) that makes method lookups fall through from instance to class

This is often called "prototype-based OOP" because the class is just another object (not a first-class type). It's similar to how JavaScript worked before ES6 classes.

## The canonical pattern (style-guide form)

The Roblox Lua Style Guide recommends this exact shape:

```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new(property: number): MyClass
    local self = { property = property }
    setmetatable(self, MyClass)
    return self
end

function MyClass:doThing()
    print(self.property)
end

return MyClass
```

Why it works:

- `MyClass.__index = MyClass` — when a method lookup misses on the instance, Lua falls through to the class table.
- `MyClass.new(...)` — a plain function (not a method) that creates and returns an instance.
- `function MyClass:doThing()` — the `:` syntax makes `self` an implicit first arg, both at definition and at call site. `obj:doThing()` is sugar for `obj.doThing(obj)`.

## Typed OOP: the three-type idiom

The challenge with Luau type checking is that the bidirectional relationship between the class and the instance is hard to express in a single type. The community has converged on a three-part pattern:

- **`Impl`** type — defines the class's structure: the constructor and the methods
- **`Proto`** type — defines instance properties
- **The exported type** — wraps both via `setmetatable`

```lua
-- Account.luau

local Account = {}
Account.__index = Account

-- Shape of instance state
type Proto = {
    name: string,
    balance: number,
}

-- Shape of the class table (methods + new)
type Impl = {
    __index: Impl,
    new: (name: string, balance: number) -> Account,
    deposit: (self: Account, credit: number) -> (),
    withdraw: (self: Account, debit: number) -> (),
}

-- Final instance type — Proto with Impl's methods accessible via __index
export type Account = typeof(setmetatable({} :: Proto, {} :: Impl))

function Account.new(name: string, balance: number): Account
    local self = setmetatable({} :: Proto, Account)
    self.name = name
    self.balance = balance
    return self
end

function Account.deposit(self: Account, credit: number)
    self.balance += credit
end

function Account.withdraw(self: Account, debit: number)
    assert(self.balance >= debit, "insufficient funds")
    self.balance -= debit
end

return Account
```

Notes on the typed pattern:

- Methods are written with `function Account.deposit(self: Account, ...)` instead of `function Account:deposit(...)`. The explicit `self: Account` gives Luau the hint it needs to resolve `self.balance`.
- `typeof(setmetatable({} :: Proto, {} :: Impl))` is the trick that makes the Account type carry both the instance fields and the methods via `__index`.
- Consumers write `local acct: Account = Account.new("alice", 100)` and get full autocomplete on `acct.balance`, `acct:deposit(...)`, etc.

## Simpler alternative: infer from `.new`

A shorter form skips the explicit `Impl`/`Proto` split by letting Luau infer the instance type from the constructor:

```lua
local Account = {}
Account.__index = Account

function Account.new(name: string, balance: number)
    local self = setmetatable({}, Account)
    self.name = name
    self.balance = balance
    return self
end

function Account:deposit(credit: number)
    self.balance += credit
end

export type Account = typeof(Account.new(...))
```

The trade-off: `typeof(Account.new(...))` works at top level but is fragile — any time you rearrange `.new`, the inferred type changes. The explicit three-type form is more robust in large codebases.

## Inheritance

The Style Guide does not recommend deep inheritance. When you do need it, the pattern is to make the child's `__index` chain to the parent:

```lua
local Animal = {}
Animal.__index = Animal

function Animal.new(name)
    return setmetatable({name = name}, Animal)
end

function Animal:speak()
    print(self.name .. " makes a sound")
end

local Dog = setmetatable({}, {__index = Animal})
Dog.__index = Dog

function Dog.new(name)
    local self = Animal.new(name)
    setmetatable(self, Dog)
    return self
end

function Dog:speak()
    print(self.name .. " barks")
end
```

The two metatable relationships here are:
1. `Dog` itself has `Animal` as its metatable's `__index`, so class-level lookups (like `Dog.parentMethod`) fall through.
2. Instances still use `Dog.__index = Dog` for method lookup.

Most experienced Roblox devs avoid this and prefer composition — hold an `Animal` instance inside a `Dog` — but the inheritance pattern exists when you need it.

## Anti-patterns

### Forgetting `__index = self`

```lua
local MyClass = {}
-- MISSING: MyClass.__index = MyClass

function MyClass.new() return setmetatable({}, MyClass) end
function MyClass:doThing() print("hi") end

local obj = MyClass.new()
obj:doThing()  -- ERROR: attempt to call nil
```

Without `__index`, the metatable is set but method lookups go nowhere. This is the single most common OOP bug in Luau.

### Using `self` without the colon

```lua
function MyClass.doThing(self)  -- note the dot
    -- ...
end

obj:doThing()  -- works
obj.doThing()  -- ERROR: self is nil
```

Using `.` for definition is fine, but the caller must use `:` (or pass `obj` explicitly).

### Storing shared mutable state on the class table

```lua
function MyClass.new()
    local self = setmetatable({}, MyClass)
    return self
end

MyClass.counter = 0  -- All instances share this!

function MyClass:increment()
    self.counter += 1  -- This actually writes to the *instance*, not the class,
                       -- but only because of first-write semantics. Read before
                       -- write hits the class table.
end
```

Anything declared on the class table (not inside `new`) is shared across instances. This is occasionally what you want (static counters, constants) but is usually a bug.

## Module-as-object alternative

For singletons, many Roblox developers skip OOP entirely and return a plain module table:

```lua
-- PlayerService.luau
local PlayerService = {}

local players = {}

function PlayerService.add(player)
    players[player.UserId] = player
end

function PlayerService.get(userId)
    return players[userId]
end

return PlayerService
```

No metatables, no `self`, no constructor. This is often the right answer for services and managers that only ever have one instance.

## Sources

- https://devforum.roblox.com/t/object-oriented-programming-with-luau-in-2023/2135043
- https://roblox.github.io/lua-style-guide/
- https://devforum.roblox.com/t/guide-to-type-checking-with-oop/1997394
Captured: 2026-04-15
