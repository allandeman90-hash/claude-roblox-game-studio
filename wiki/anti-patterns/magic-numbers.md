---
title: magic-numbers
type: anti-pattern
category: anti-patterns
subcategory: code-quality
owner: lead-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: low
related:
  - "[[client-server-split]]"
tags: [anti-pattern, code-quality]
---

# Magic Numbers

**Severity:** Low
**Status:** stub

Hardcoded numeric constants in gameplay code without explanation. Replace with named config values in a `Config` module so designers can tune them without editing code.

## Fix

```lua
-- ❌
if player.Gold >= 100 then ... end

-- ✅
local Config = require(ReplicatedStorage.Shared.Config.Economy)
if player.Gold >= Config.SWORD_PRICE then ... end
```

## Related

- [Gameplay Systems Rules](../../.claude/rules/gameplay-systems.md)
- [Config Data Rules](../../.claude/rules/config-data.md)
