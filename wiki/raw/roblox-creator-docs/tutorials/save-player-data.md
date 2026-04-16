---
title: Save Player Data with Standard Data Stores
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/save-player-data
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, data-stores, persistence, pcall, coroutine, vector3, cframe]
difficulty: intermediate
---

# Save Player Data with Standard Data Stores

**Data stores** are a service you can use to save and load **persistent player data** across different player sessions. They store important information, like a player's progress or inventory, and allow you to retrieve it for the player next time they join your experience. Without data stores, a player would lose all of their progress every time they left the experience.

There are two types of data stores: standard and ordered. This tutorial uses **standard data stores**, which store data like numbers, strings, and tables that don't need to be ranked or sorted.

This tutorial covers:
- Saving and loading the amount of gold a player has collected.
- Updating the UI to display the player's gold inventory.
- Automatically saving the player's gold inventory every 30 seconds.
- Saving the player's position when they leave the experience.
- Restoring the player's position when they join the experience again.

## Steps

### Enable Studio access to API services

Data stores aren't stored locally on your device, so your experience relies on server-to-server communication with Roblox's backend in order to use them. By default, Studio restricts this communication to prevent abuse or accidental use.

To enable Studio access to API services:

1. Open your place in Studio.
2. Publish your experience.
3. Back in Studio, go to **File** ⟩ **Experience Settings** ⟩ **Security**.
4. Turn on **Enable Studio Access to API Services**.
5. Save your changes.

### Create a standard data store

When creating a data store, you should always call the `DataStoreService` from a server-side `Script`. This is important because:

- Roblox blocks all data store access from the client so that only the server has permission to access and modify persistent player data.
- Server-side scripts run in a centralized environment, making sure that the data being read and written to your data store is accurate and valid.
- Since client-side scripts run on the player's device, any player could potentially exploit the experience and steal or overwrite other players' data if the client had access to your data stores.

Give your data store a unique name to keep your data organized:

```lua
local DataStoreService = game:GetService("DataStoreService")
local goldStore = DataStoreService:GetDataStore("PlayerGold")
```

### Save and load player data

Data stores are made up of keys (which identify data) and values (which store data).

| | Key | Value |
|---|---|---|
| **Description** | A unique identifier you can use to access a specific piece of data | The actual data you want to save or load |
| **Allowed formats** | Can only be strings | Numbers, strings, booleans, or tables |
| **Examples** | `"Player_A"`, `"TopScore"` | `100`, `"Level_5"`, `true`, `{gold = 100}` |

In this tutorial, the key is the player's `userId` and the value is the amount of gold they have collected.

1. Add a helper function called **saveGold**:

```lua
local function saveGold(userId, value)
    local success, err = pcall(function()
        goldStore:SetAsync(userId, value)
    end)
    if not success then
        warn("[SAVE ERROR] Could not save gold for", userId, ":", err)
    end
end
```

2. Modify the **onPlayerAdded** event to load the player's gold when they first join:

```lua
local function onPlayerAdded(player)
    local userId = player.UserId
    local success, storedGold = pcall(function()
        return goldStore:GetAsync(userId)
    end)
    if success then
        local currentGold = storedGold or 0
        playerGold[userId] = currentGold
        uiEvent:FireClient(player, {
            gold = currentGold,
            doTween = false,
            showAlert = not success
        })
    else
        uiEvent:FireClient(player, { showAlert = true })
        warn("Could not load gold for", player.Name)
    end
end
```

3. Modify the **onPlayerRemoving** event to call the **saveGold** function:

```lua
local function onPlayerRemoving(player)
    local userId = player.UserId
    if playerGold[userId] then
        saveGold(userId, playerGold[userId])
    end
end
```

### Automatically save player data

Automatically saving a player's data is good practice because it protects the player from losing their data. If you only save the player's data when they leave the experience with `onPlayerRemoving`, you might lose their latest progress if they unexpectedly disconnect.

> Make sure not to autosave too often to avoid throttling errors. A good autosave interval is between 30 to 120 seconds.

```lua
-- This number is in seconds
local AUTOSAVE_INTERVAL = 30

-- Inside onPlayerAdded
coroutine.wrap(function()
    while player.Parent do
        task.wait(AUTOSAVE_INTERVAL)
        if playerGold[userId] then
            print("[AUTOSAVE] Saving", playerGold[userId], "gold for", player.Name)
            saveGold(userId, playerGold[userId])
        end
    end
end)()
```

A coroutine is a function that runs asynchronously; it can pause at certain points, resume where it left off, and run in parallel with other parts of your script without blocking them.

### Save and load player position

To save a player's position, work with their `Character` instead of the `Player` object itself. A player's `Character` represents their physical model in the 3D world.

Because data stores can only save basic data types, you can't directly store complex objects like `Vector3` or `CFrame` values. To save a player's position, split it into three separate numbers (X, Y, Z).

```lua
local DataStoreService = game:GetService("DataStoreService")
local positionStore = DataStoreService:GetDataStore("PlayerPosition")

local function savePosition(player, position)
    local userId = player.UserId
    local success, err = pcall(function()
        positionStore:SetAsync(userId, {position.X, position.Y, position.Z})
    end)
    if not success then
        warn("Could not save position for", player.Name, ":", err)
    end
end

local function loadPosition(player, character)
    local userId = player.UserId
    local success, savedCoords = pcall(function()
        return positionStore:GetAsync(userId)
    end)
    if success and savedCoords then
        local pos = Vector3.new(savedCoords[1], savedCoords[2], savedCoords[3])
        character:PivotTo(CFrame.new(pos))
    elseif not success then
        warn("Could not load position for", player.Name)
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        loadPosition(player, character)
    end)
    player.CharacterRemoving:Connect(function(character)
        local pos = character:GetPivot().Position
        savePosition(player, pos)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

## Key Concepts

- **DataStoreService**: Service for persistent cross-session data
- **Standard data stores**: For data that doesn't need sorting (numbers, strings, tables)
- **Keys must be strings**: User IDs should be converted with `tostring()`
- **Values** can be numbers, strings, booleans, or tables
- **`SetAsync(key, value)`**: Writes data to a data store
- **`GetAsync(key)`**: Reads data from a data store
- **`pcall()`**: Always wrap data store calls in pcall for error handling
- **Server-only access**: Never access data stores from client scripts
- **Autosave coroutines**: Use background loops for periodic saves
- **Vector3/CFrame**: Cannot be saved directly; break into X/Y/Z components

## Code Snippets

### Complete save/load flow

```lua
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local goldStore = DataStoreService:GetDataStore("PlayerGold")

local playerGold = {}
local AUTOSAVE_INTERVAL = 30

local function saveGold(player, value)
    local userId = player.UserId
    local success, err = pcall(function()
        goldStore:SetAsync(userId, value)
    end)
    if not success then
        warn("Could not save gold for", player.Name, ":", err)
    end
end

local function onPlayerAdded(player)
    local userId = player.UserId
    local success, storedGold = pcall(function()
        return goldStore:GetAsync(userId)
    end)
    local currentGold = (success and storedGold) or 0
    playerGold[userId] = currentGold

    coroutine.wrap(function()
        while player.Parent do
            task.wait(AUTOSAVE_INTERVAL)
            if playerGold[userId] then
                saveGold(player, playerGold[userId])
            end
        end
    end)()
end

local function onPlayerRemoving(player)
    local userId = player.UserId
    if playerGold[userId] then
        saveGold(player, playerGold[userId])
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
```

## Notes

- Always enable Studio Access to API Services via Game Settings → Security
- Use `pcall()` for every data store call to handle network errors
- Never access data stores from LocalScripts
- Autosave intervals between 30-120 seconds balance safety vs throttling
- Vector3/CFrame must be decomposed into number tables for storage

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/save-player-data
Captured: 2026-04-16
