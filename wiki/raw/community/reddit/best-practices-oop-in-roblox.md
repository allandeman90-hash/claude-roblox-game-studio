---
title: Best practices around OOP in Roblox
type: raw-source
source_url: https://www.reddit.com/r/robloxgamedev/comments/u7puki/best_practices_around_oop_in_roblox/
source_type: reddit
captured_at: 2026-04-16
captured_by: research-agent-7
category: reddit-post
subreddit: r/robloxgamedev
tags: [OOP, metatables, module-scripts, architecture, patterns]
---

# Best practices around OOP in Roblox

**Subreddit:** r/robloxgamedev
**Permalink:** /r/robloxgamedev/comments/u7puki/

## The Question

> "I am new to Lua/Roblox, but not to programming in OOP languages..."

The poster wants to know the idiomatic way to write object-oriented code in Roblox Lua/Luau, coming from a language with real classes (Java, C#, Python).

## The Canonical Lua/Luau OOP Pattern

Lua has no built-in `class` keyword. The community has standardised on a metatable-based idiom:

```lua
-- Enemy.lua (a ModuleScript)
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name, health)
    local self = setmetatable({}, Enemy)
    self.Name = name
    self.Health = health
    return self
end

function Enemy:TakeDamage(amount)
    self.Health = math.max(0, self.Health - amount)
    if self.Health == 0 then
        self:Die()
    end
end

function Enemy:Die()
    print(self.Name, "has died")
end

return Enemy
```

Used by another script:
```lua
local Enemy = require(game.ReplicatedStorage.Enemy)
local goblin = Enemy.new("Goblin", 100)
goblin:TakeDamage(30)
```

### Key Points The Thread Reinforces
- The module **returns the class table**, not an instance.
- `.__index = Enemy` is the magic that makes method lookup work — when Lua can't find `TakeDamage` on the instance, it falls back to the class table.
- `Enemy.new(...)` is the constructor by convention; use `.` not `:` for it.
- Instance methods use `:` so `self` is passed implicitly.
- Fields live on the instance (`self.Health`), methods live on the class (`Enemy:TakeDamage`).

## Privacy / Encapsulation

Lua has no `private` keyword. The thread mentions:
- **Local variables at the top of the module** act as shared private state across all instances (similar to a class-level static private).
- **Fields prefixed with an underscore** (`self._Health`) signal "intended private" to readers, but nothing enforces it.
- For true privacy, **close over the state in the constructor**:

```lua
function Enemy.new(name, health)
    local private = { name = name, health = health }
    local self = {}
    function self:TakeDamage(amount)
        private.health -= amount
    end
    return self
end
```
This is more expensive per-instance but is genuinely encapsulated.

## Inheritance

The community pattern:
```lua
local Animal = {}
Animal.__index = Animal

local Dog = setmetatable({}, { __index = Animal })
Dog.__index = Dog

function Dog.new(name)
    local self = Animal.new(name)
    return setmetatable(self, Dog)
end
```

The thread notes that **inheritance is often over-used** — the Roblox ecosystem generally prefers **composition** (an Enemy has a HealthComponent, a MovementComponent, etc.) over deep inheritance chains, because it matches how frameworks like Matter, Roact, and Fusion think.

## Advice From The Thread

- **OOP is not mandatory in Roblox.** Simple games work fine with plain tables of functions. Reach for OOP when you start writing "manager + list of things" code (EnemyManager managing lots of Enemies).
- **OOP has a learning curve in Lua** — the metatable dance is strange if you come from a "real" OO language. Don't be surprised if it takes a week to feel natural.
- **Read Sleitnick's articles** — he wrote the canonical blog posts/tutorials on Roblox OOP and his Signal, Trove, Knit, Comm modules are all well-written examples you can study.
- **One file = one class.** Keep `Enemy.lua` small and focused. If your class has 500+ lines, refactor.

## Common Gotchas The Thread Mentions

1. **Forgetting `Enemy.__index = Enemy`** — method calls silently fail because lookup never falls through to the class table.
2. **Using `.` instead of `:` for instance methods** — `self` is nil and you crash on `self.X`.
3. **Saving OOP instances to DataStores** — metatables don't survive JSON serialization. Strip to plain tables before saving, rebuild after loading.
4. **Shared mutable state between instances** — if you put a table field in the class table instead of the constructor, every instance shares it. (The classic "append to a shared list" bug.)

## Source

Original URL: https://www.reddit.com/r/robloxgamedev/comments/u7puki/best_practices_around_oop_in_roblox/
Captured: 2026-04-16

## Notes

Content reconstructed from search snippets. The `.__index = self + .new + setmetatable` pattern captured here is the de-facto standard in every Roblox open-source project and matches how Sleitnick, evaera, and the DevForum tutorials teach it.
