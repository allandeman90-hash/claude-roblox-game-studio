---
title: Tuples
type: raw-source
source_url: https://create.roblox.com/docs/luau/tuples
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-2
category: luau-language
tags: [luau, tuples, multiple-returns, varargs]
---

# Tuples

A **tuple** is a list of values. Many [methods](./functions.md#methods) and [callbacks](./functions.md#callbacks) in the Roblox Engine API accept and return multiple values, but the API Reference says "Tuple" instead of those values.

## Parameters

If a method or callback accepts a tuple as a parameter, then it accepts multiple values. For example, the API Reference shows that the `BindableFunction:Invoke()` method accepts a "Tuple" as a parameter, so it accepts multiple arguments.

```lua
BindableFunction:Invoke(1, true, "string", Vector3.new(0, 0, 0))
```

## Returns

If a method or callback returns a tuple, then it returns multiple values. For example, the API Reference shows that the `Players:GetUserThumbnailAsync()` method returns a "Tuple", so it returns multiple values. The first return value is a Content URL, and the second is a [boolean](./booleans.md).

```lua
local Players = game:GetService("Players")

local userId = 156 -- builderman
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
print(content, isReady) -- rbxthumb://type=AvatarHeadShot&id=156&w=420&h=420 true
```

## Source

Original URL: https://create.roblox.com/docs/luau/tuples
GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/luau/tuples.md
Captured: 2026-04-16
