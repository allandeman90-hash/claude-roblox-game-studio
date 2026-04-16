---
title: unvalidated-remote-args
type: anti-pattern
category: anti-patterns
subcategory: security
owner: remotes-networking-specialist
status: complete
created: 2026-04-16
updated: 2026-04-16
severity: critical
sources:
  - .claude/rules/remotes.md
  - .claude/agents/remotes-networking-specialist.md
related:
  - "[[RemoteEvent]]"
  - "[[server-authority]]"
  - "[[rate-limiting]]"
  - "[[client-trust]]"
  - "[[argument-spoofing]]"
tags: [anti-pattern, security, critical]
---

# Unvalidated Remote Arguments

> Accepting `RemoteEvent` arguments without type, range, or sanity checks.

**Severity:** Critical

## What It Looks Like

```lua
-- ❌ Bad
Remotes.DealDamage.OnServerEvent:Connect(function(player, target, amount)
    target.Humanoid:TakeDamage(amount)
end)

-- ❌ Bad
Remotes.PurchaseItem.OnServerEvent:Connect(function(player, itemId)
    giveItem(player, itemId)
end)

-- ❌ Bad
Remotes.SetSetting.OnServerEvent:Connect(function(player, key, value)
    PlayerData.get(player).settings[key] = value
end)
```

## Why It's Bad

Every argument from `:FireServer(...)` is attacker-controlled. Without validation:

- **Type confusion**: `amount` may not be a number — may be a table, function, or nil — crashing the handler or producing unexpected behavior.
- **Range abuse**: `amount = 1e308` deals infinite damage.
- **Reference injection**: `target` may be any Instance — another player, your character, a workspace part.
- **Sanity violation**: `itemId = "__proto__"` or `"admin_rank"` accesses unexpected data structure fields.
- **Type coercion surprises**: `typeof("5") ~= typeof(5)` — string "5" won't math-add correctly.

See [[client-trust]] for the broader concept.

## How to Fix It

Every handler validates in this order:

1. **Type check** every argument
2. **Range / size check** for numbers and strings
3. **Sanity check** against config or player state
4. **Rate limit** per [[rate-limiting]]

```lua
-- ✅ Good
Remotes.DealDamage.OnServerEvent:Connect(function(player, targetId, amount)
    -- 1. Type
    if typeof(targetId) ~= "number" then return end
    if typeof(amount) ~= "number" then return end

    -- 2. Range
    if amount <= 0 or amount > MAX_DAMAGE then return end

    -- 3. Sanity
    local target = game.Players:GetPlayerByUserId(targetId)
    if not target or not target.Character then return end
    if not isValidTarget(player, target) then return end  -- team check, range check, etc.

    -- 4. Rate limit
    if isRateLimited(player) then return end

    -- Now safe to use server-authoritative logic
    local finalDamage = computeDamageServerSide(player, target, amount)
    target.Character.Humanoid:TakeDamage(finalDamage)
end)
```

### Type Check Reference

```lua
typeof(x) == "number"
typeof(x) == "string"
typeof(x) == "boolean"
typeof(x) == "table"
typeof(x) == "Vector3"
typeof(x) == "CFrame"
typeof(x) == "Instance"
typeof(x) == "nil"
-- Note: `type(x)` also works but `typeof()` distinguishes Roblox types
```

Avoid trusting `table` arguments until every field is individually validated. Deep table validation is better done with a schema library (or manual walks).

### Never Pass Instance References Through Remotes

Passing `Instance` through a remote is a separate anti-pattern — see [[instance-in-remote]]. Use string IDs or UserIds instead.

## Detection

```bash
# Find every OnServerEvent handler
grep -rn "OnServerEvent:Connect" src/ServerScriptService src/ServerStorage
```

Manual review: for each handler, verify the first lines of the function type-check every parameter.

The `code-reviewer` agent's checklist includes this check explicitly.

## Related

- [[RemoteEvent]] — what this defends
- [[server-authority]] — the concept
- [[rate-limiting]] — the complementary defense
- [[client-trust]] — the parent anti-pattern
- [[argument-spoofing]] — the exploit this prevents
- [[instance-in-remote]] — related anti-pattern
- [Remotes Rules](../../.claude/rules/remotes.md)

## Sources

- [.claude/rules/remotes.md](../../.claude/rules/remotes.md)
- [.claude/agents/remotes-networking-specialist.md](../../.claude/agents/remotes-networking-specialist.md)
