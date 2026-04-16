---
title: Create a Custom Leaderboard with Ordered Data Stores
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/create-leaderboard
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, data-stores, ordered-data-store, leaderboard, remotefunction, modulescript, pcall]
difficulty: intermediate
---

# Create a Custom Leaderboard with Ordered Data Stores

**Data stores** are a service you can use to save and load **persistent player data** across different player sessions. There are two types of data stores: standard and ordered. This tutorial uses **ordered data stores**, which store data that you can rank and sort numerically and retrieve in ascending or descending order based on the stored numerical values.

This tutorial covers:
- Storing gold scores in an ordered data store.
- Fetching and sorting the top scores globally across all servers.
- Displaying the top scores in a custom leaderboard in the UI.
- Automatically refreshing the custom leaderboard every few seconds.

## Steps

### Enable Studio access to API services

1. Open your place in Studio.
2. Publish your experience.
3. Go to **File** ⟩ **Experience Settings** ⟩ **Security**.
4. Turn on **Enable Studio Access to API Services**.

### Create an ordered data store

When creating a data store, always call `DataStoreService` from a server-side Script. Give your data store a unique name.

```lua
local leaderboardStore = DataStoreService:GetOrderedDataStore("GlobalLeaderboard")
```

### Send player data to the leaderboard

Data stores are made up of keys (which identify data) and values (which store data). Unlike standard data stores, ordered data stores let you sort data by **value**.

| | Key | Value |
|---|---|---|
| **Description** | A unique string identifier like a user ID | The numeric data like a player's score |
| **Allowed formats** | Only strings (use `tostring()` for numbers) | Only numbers |
| **Examples** | `"Player_A"`, `"123456"` | `100`, `3.14`, `0`, `-25` |

Update the existing `saveGold` function to also send the player's score to the leaderboard:

```lua
local function saveGold(player, value)
    local userId = player.UserId
    local success, err = pcall(function()
        goldStore:SetAsync(userId, value)
        leaderboardStore:SetAsync(tostring(userId), value)
    end)
    if not success then
        warn("Could not save gold for", player.Name, ":", err)
    end
end
```

### Fetch the leaderboard scores

To fetch the leaderboard scores, use a `ModuleScript`. Module scripts let you organize and reuse your code across multiple scripts.

Your custom leaderboard uses these ordered data store methods to share data across servers:
- `SetAsync` to send player scores to the data store
- `GetSortedAsync` (exclusive to ordered data stores) to fetch the top scores from all servers

1. Under **ServerScriptService**, create a `ModuleScript` called **LeaderboardManager**.
2. Create the module:

```lua
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local leaderboardStore = DataStoreService:GetOrderedDataStore("GlobalLeaderboard")

local leaderboardManager = {}

function leaderboardManager.GetTopScores(limit)
    local success, pages = pcall(function()
        -- false = descending (highest scores first)
        return leaderboardStore:GetSortedAsync(false, limit)
    end)

    if not success or not pages then
        warn("Failed to get leaderboard data")
        return {}
    end

    local topPlayers = {}
    for _, entry in ipairs(pages:GetCurrentPage()) do
        local userId = tonumber(entry.key)
        local score = entry.value
        local username = "Unknown"

        local ok, name = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        if ok then
            username = name
        end

        table.insert(topPlayers, {
            Username = username,
            Score = score
        })
    end

    return topPlayers
end

return leaderboardManager
```

### Request leaderboard data from the server

In order for the client UI to display the leaderboard scores, the server has to respond when the client asks for data. A `RemoteFunction` allows the client to request information from the server and wait for a reply.

1. Under **ReplicatedStorage**, insert a **RemoteFunction** called **LeaderboardRemote**.
2. Under **ServerScriptService**, create a script called **LeaderboardRemoteHandler**:

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local leaderboardRemote = ReplicatedStorage:WaitForChild("LeaderboardRemote")
local leaderboardManager = require(ServerScriptService:WaitForChild("LeaderboardManager"))

leaderboardRemote.OnServerInvoke = function(player)
    return leaderboardManager.GetTopScores(3)
end
```

### Display data in the custom leaderboard UI

> Because of backend caching, the scores in your custom leaderboard can take a few extra seconds to update. To get instant, real-time updates across servers, you can use memory stores.

After setting up the server-side scripts, create a local script to fetch the top 3 players every 3 seconds:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local leaderboardRemote = ReplicatedStorage:WaitForChild("LeaderboardRemote")

local gui = script.Parent
local leaderboardFrame = gui:WaitForChild("LeaderboardFrame")
local entriesFrame = leaderboardFrame:WaitForChild("EntriesFrame")
local template = entriesFrame:WaitForChild("LeaderboardEntry")

local function clearEntries()
    for _, child in ipairs(entriesFrame:GetChildren()) do
        if child:IsA("TextLabel") and child.Name:match("^Row%d+$") then
            child:Destroy()
        end
    end
end

local function renderLeaderboard(data)
    clearEntries()
    for i, entry in ipairs(data) do
        local row = template:Clone()
        row.Name = "Row" .. i
        row.Visible = true
        row.LayoutOrder = i
        row.Text = string.format("%d%s place: %s - %d",
            i,
            i == 1 and "st" or i == 2 and "nd" or i == 3 and "rd" or "th",
            entry.Username,
            entry.Score
        )
        row.Parent = entriesFrame
    end
end

while true do
    local success, data = pcall(function()
        return leaderboardRemote:InvokeServer()
    end)
    if success and data then
        renderLeaderboard(data)
    else
        warn("Failed to fetch leaderboard data")
    end
    task.wait(3)
end
```

## Key Concepts

- **OrderedDataStore**: Special data store that sorts by value
- **`GetSortedAsync(ascending, pageSize)`**: Returns sorted pages of entries
- **`Pages:GetCurrentPage()`**: Gets entries on current page as a table
- **`GetNameFromUserIdAsync(userId)`**: Converts user IDs to usernames
- **ModuleScript**: Share code between scripts via `require()`
- **RemoteFunction**: Client-server request/response pattern
- **`OnServerInvoke`**: Server-side handler for client calls
- **`InvokeServer()`**: Client calls to trigger server handler
- **Global leaderboard**: Data spans all servers via shared data store

## Notes

- `OrderedDataStore` values must be numbers only
- Keys must be strings — use `tostring(userId)`
- Wrap all async data store calls in `pcall()`
- Leaderboard updates can lag a few seconds due to backend caching
- Use MemoryStoreService for real-time cross-server state instead
- Never expose data store access to the client

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/create-leaderboard
Captured: 2026-04-16
