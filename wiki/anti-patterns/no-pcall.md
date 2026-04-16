---
title: no-pcall
type: anti-pattern
category: anti-patterns
subcategory: error-handling
owner: lead-programmer
status: stub
created: 2026-04-16
updated: 2026-04-16
severity: high
related:
  - "[[pcall-xpcall]]"
  - "[[DataStoreService]]"
tags: [anti-pattern, error-handling]
---

# Missing `pcall`

**Severity:** High
**Status:** stub

Calling DataStoreService / HttpService / MarketplaceService without wrapping in `pcall`. These services can fail at any time — an unhandled error crashes your script.

## Fix

```lua
-- ❌
local data = store:GetAsync(key)

-- ✅
local ok, data = pcall(function()
    return store:GetAsync(key)
end)
if not ok then
    warn("DataStore GetAsync failed: " .. tostring(data))
    data = getDefaultData()
end
```

## Related

- [[pcall-xpcall]]
- [[DataStoreService]]
