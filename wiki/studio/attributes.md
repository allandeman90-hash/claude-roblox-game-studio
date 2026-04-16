---
title: attributes
type: studio
category: studio
subcategory: patterns
owner: roblox-studio-specialist
status: stub
created: 2026-04-16
updated: 2026-04-16
related:
  - "[[collection-service-tags]]"
tags: [studio, patterns]
---

# Attributes

**Status:** stub

## Summary

Typed key-value pairs on any `Instance`. Replicate from server to client. Great for designer-editable data on Parts without adding Value objects.

```lua
part:SetAttribute("Damage", 50)
part:SetAttribute("IsCritical", true)
local dmg = part:GetAttribute("Damage")
part:GetAttributeChangedSignal("Damage"):Connect(function()
    -- react
end)
```

Types supported: number, string, boolean, Vector3, CFrame, Color3, UDim, UDim2, etc.

## Related

- [[collection-service-tags]]

## Sources

- [.claude/agents/roblox-studio-specialist.md](../../.claude/agents/roblox-studio-specialist.md)
