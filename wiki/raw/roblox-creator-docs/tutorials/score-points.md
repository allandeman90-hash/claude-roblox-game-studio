---
title: Score Points
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/basic-scripting/score-points
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, scripting, leaderstats, players, humanoid, attributes, intvalue, services]
difficulty: beginner
---

# Score Points

In previous tutorials, you made a variety of experience features including fading platforms and deadly lava. This tutorial ties these together into a playable experience where users see who can stay alive the longest. Every second they stay alive, a point will be added to their score.

## Steps

### Set up

First up, you'll need to set the scene for your experience. Duplicate the fading platforms you made in the previous tutorial and let users compete to stay on the board of platforms for as long as possible.

You can also use deadly lava to kill users when they fall off the platforms, or just let them fall to their doom. Make sure you place a **SpawnLocation** somewhere where users can jump onto the platforms to start playing.

### Player points

Roblox has a built-in **Leaderboard** for showing user stats. When you set player points through the leaderboard, they show up on the right side of the screen in the experience.

It's best to put scripts which set up experience state into **ServerScriptService** because they will automatically run when the experience starts. In **ServerScriptService**, create a script called **SetupPoints**.

### Listen for players

In Roblox, a **service** is an object which performs a range of useful functions. The `Players` service has an event called `PlayerAdded` that you can use to set up points for each user who joins the experience.

You can access services with the `GetService` function in the `game` object. `game` is a variable accessible from anywhere which contains everything in your experience.

```lua
local Players = game:GetService("Players")

local function onPlayerAdded(player)

end

Players.PlayerAdded:Connect(onPlayerAdded)
```

> When declaring a variable to contain a service, it's best to name it with the exact name of the service (`"Players"`), even though this means breaking usual naming conventions for variables.

### Create a stats folder

To make a user's points display in the leaderboard, all you need to do is create a new `Folder` in their `Player` object called `"leaderstats"` and put their points in there. New objects can be created from within a script via the `Instance.new()` function.

```lua
local function onPlayerAdded(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
end
```

> **Warning:** Make sure you name the folder **exactly** as it is shown here (`"leaderstats"`) or it will not work!

### Create the points

The leaderboard system reads any values in the `leaderstats` folder and displays whatever it finds.

To add a stat which will track a player's points, a new `IntValue` object can be parented to the `leaderstats` folder. The name of the value object will be displayed alongside its current value.

```lua
local Players = game:GetService("Players")

local function onPlayerAdded(player)
  local leaderstats = Instance.new("Folder")
  leaderstats.Name = "leaderstats"
  leaderstats.Parent = player

  local points = Instance.new("IntValue")
  points.Name = "Points"
  points.Value = 0
  points.Parent = leaderstats
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

### Count time

Each user should earn a point for each second they are alive. A `while` loop and the `task.wait()` function can be used to update the value of points every second.

```lua
Players.PlayerAdded:Connect(onPlayerAdded)

while true do
  task.wait(1)
end
```

### Player list

To run code for every user in the experience, you need to iterate through the **array** of users returned by the `Players:GetPlayers()` function.

An array is a list of items stored in order. Each item can be accessed by its **index** position, starting from `1`. You can get the length of an array by prefixing it with `#`.

```lua
while true do
  task.wait(1)
  local playerList = Players:GetPlayers()
  for currentPlayer = 1, #playerList do
    -- Add your logic here for each player in the playerList
  end
end
```

### Award points

Objects stored in an array are accessed using **square brackets** — for instance, the first item in the `playerList` array can be accessed with `playerList[1]`.

```lua
while true do
  task.wait(1)
  local playerList = Players:GetPlayers()
  for currentPlayer = 1, #playerList do
    local player = playerList[currentPlayer]
    local points = player.leaderstats.Points
    points.Value += 1
  end
end
```

### Listen for characters

The goal of the experience is to see who can stay alive the longest, so users who die will need to have their points reset to 0.

You'll need to get the **Character** model for the user in order to detect when they have died. This model is only added to the experience _after_ the `Player` object has been loaded and you can use the `CharacterAdded` event to listen for when the character is ready to use.

```lua
local function onCharacterAdded(character, player)

end

local function onPlayerAdded(player)
  -- ...
  player.CharacterAdded:Connect(function(character)
    onCharacterAdded(character, player)
  end)
end
```

Although you included user in the `onCharacterAdded` function's parameters, the actual `CharacterAdded` event only returns the character, not the associated user. To pass the `player` object as well, use an **anonymous function** for the event connection.

### Reset points

When a user dies, their `Humanoid` automatically fires a `Died` event. You can use this event to find out when to reset their points.

The Humanoid is found inside the Character model, but the contents of that model are only assembled as the user spawns. To make your code safely wait for the Humanoid object to load, use the `WaitForChild()` function.

```lua
local function onCharacterAdded(character, player)
  local humanoid = character:WaitForChild("Humanoid")

  humanoid.Died:Connect(function()
    local points = player.leaderstats.Points
    points.Value = 0
  end)
end
```

### Check the player

If users keep earning points even when dead, it's hardly in the spirit of the experience. The code needs to check if users are alive before awarding a point.

Attributes allow you to customize objects in Roblox with your own data. An attribute consists of a name and a value. You can create one on any object using the `SetAttribute()` function.

```lua
local function onPlayerAdded(player)
  -- ... leaderstats setup ...
  player:SetAttribute("IsAlive", false)
  player.CharacterAdded:Connect(function(character)
    onCharacterAdded(character, player)
  end)
end

local function onCharacterAdded(character, player)
  player:SetAttribute("IsAlive", true)
  local humanoid = character:WaitForChild("Humanoid")
  humanoid.Died:Connect(function()
    local points = player.leaderstats.Points
    points.Value = 0
    player:SetAttribute("IsAlive", false)
  end)
end
```

Finally, `IsAlive` should be **checked** before any point is awarded in the `while` loop:

```lua
while true do
  task.wait(1)
  local playerList = Players:GetPlayers()
  for currentPlayer = 1, #playerList do
    local player = playerList[currentPlayer]
    if player:GetAttribute("IsAlive") then
      local points = player.leaderstats.Points
      points.Value += 1
    end
  end
end
```

## Key Concepts

- **Services**: Access with `game:GetService("Players")`
- **leaderstats folder**: Magic name that populates built-in leaderboard
- **IntValue**: Wraps a number for use in leaderstats
- **`Instance.new()`**: Creates new objects programmatically
- **PlayerAdded / CharacterAdded / Died events**: Lifecycle events
- **Anonymous functions**: Inline functions for single-use callbacks
- **`WaitForChild()`**: Safely wait for an object to load
- **Attributes**: Custom data attached to any Instance via `SetAttribute`/`GetAttribute`
- **Arrays**: 1-indexed; use `#array` for length; access with `[]`

## Code Snippets

### Final code

```lua
local Players = game:GetService("Players")

local function onCharacterAdded(character, player)
  player:SetAttribute("IsAlive", true)
  local humanoid = character:WaitForChild("Humanoid")

  humanoid.Died:Connect(function()
    local points = player.leaderstats.Points
    points.Value = 0
    player:SetAttribute("IsAlive", false)
  end)
end

local function onPlayerAdded(player)
  local leaderstats = Instance.new("Folder")
  leaderstats.Name = "leaderstats"
  leaderstats.Parent = player

  local points = Instance.new("IntValue")
  points.Name = "Points"
  points.Value = 0
  points.Parent = leaderstats

  player:SetAttribute("IsAlive", false)

  player.CharacterAdded:Connect(function(character)
    onCharacterAdded(character, player)
  end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

while true do
  task.wait(1)
  local playerList = Players:GetPlayers()
  for i = 1, #playerList do
    local player = playerList[i]
    if player:GetAttribute("IsAlive") then
      local points = player.leaderstats.Points
      points.Value += 1
    end
  end
end
```

## Notes

- Folder MUST be named exactly `"leaderstats"`
- Use `WaitForChild` for children that may load later (e.g., Humanoid in Character)
- Prefer `SetAttribute`/`GetAttribute` over bare variables for per-player state
- Leaderstats IntValue names appear as column headers in the leaderboard

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/basic-scripting/score-points
Captured: 2026-04-16
