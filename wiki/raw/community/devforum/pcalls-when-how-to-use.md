---
title: Pcalls - When and how to use them
type: raw-source
source_url: https://devforum.roblox.com/t/pcalls-when-and-how-to-use-them/393687
source_type: devforum
captured_at: 2026-04-16
captured_by: research-agent-6
category: devforum-tutorial
author: ReturnedTrue
post_date: 2019-11-23
tags: [pcall, xpcall, error-handling, datastore, retry]
---

# Pcalls: When and How to Use Them

**Author:** ReturnedTrue (Tr_uth)
**Posted:** November 23, 2019

## Core Concept

Protected calls (pcalls) execute functions while catching errors, returning a success boolean and either an error message or the function's return values.

**Basic Syntax:**
```lua
pcall(f : function, ...args : any)
```

## Primary Use Cases

### 1. DataStore Operations
For GetAsync/SetAsync/UpdateAsync/IncrementAsync operations that may fail due to network issues:

```lua
local DataStore = game:GetService("DataStoreService"):GetDataStore("MyData")
local success, response = pcall(DataStore.GetAsync, DataStore, "key")
```

Note: Use dot notation with self parameter rather than colon syntax inside pcall.

### 2. Retry Logic
Implement retries using while or repeat loops:

```lua
local success, response
while not success do
    if count >= 1 then
        warn("Retrying, count:", count, "\nError:", response)
        wait(7)
    end
    success, response = pcall(DataStore.GetAsync, DataStore, "key")
    count = count + 1
end
```

### 3. Web API Calls
Functions like `GetUserThumbnailAsync`, `GetUserIdFromNameAsync` should be pcall'd due to network dependency.

### 4. StarterGui SetCore
SetCore requires pcalling with retry logic since CoreScripts initialize asynchronously:

```lua
local sg = game:GetService("StarterGui")
while not success do
    success = pcall(sg.SetCore, sg, "TopbarEnabled", false)
    wait(1)
end
```

## Advanced Patterns

**xpcall** — Includes error handler (cannot yield):
```lua
function displayError(err)
    warn("Error:", err)
end
xpcall(sg.SetCore, displayError, sg, "TopbarEnabled", false)
```

**debug.traceback()** — Retrieve stack information for error debugging.

**ypcall** — Legacy yielding pcall (now unnecessary as modern pcalls yield).

## Functions Requiring PCalls

DataStore methods, Players service functions (GetUserThumbnailAsync, GetFriendsAsync, etc.), StarterGui:SetCore()

## Source

Original URL: https://devforum.roblox.com/t/pcalls-when-and-how-to-use-them/393687
Captured: 2026-04-16
