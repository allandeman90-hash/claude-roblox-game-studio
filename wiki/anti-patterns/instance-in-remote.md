---
title: instance-in-remote
type: anti-pattern
category: anti-patterns
subcategory: security
owner: remotes-networking-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: medium
related:
  - "[[RemoteEvent]]"
  - "[[unvalidated-remote-args]]"
tags: [anti-pattern, security]
---

# Instance Reference in Remote

**Severity:** Medium
**Status:** stub

Passing `Instance` references as RemoteEvent arguments. The client can pass any Instance (another player, a workspace part, a secret ServerStorage model if it's somehow replicated). Use string IDs or UserIds instead.

## Fix

```lua
-- ❌
remote:FireServer(workspace.SomePart)

-- ✅
remote:FireServer("SomePart")  -- server resolves by name/ID
```

## Related

- [[RemoteEvent]]
- [[unvalidated-remote-args]]
