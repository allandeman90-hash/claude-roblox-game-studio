--!strict
-- Main server entry point.
-- Initialize services and connect player lifecycle.

local Players = game:GetService("Players")

local function onPlayerAdded(player: Player)
    print("[Server] Player joined:", player.Name)
    -- TODO: Load player data, acquire session lock
end

local function onPlayerRemoving(player: Player)
    print("[Server] Player leaving:", player.Name)
    -- TODO: Save player data, release session lock
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players who joined before this script ran
for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
    -- TODO: Save all player data with 25-second timeout
    -- See wiki/concepts/bind-to-close.md for the pattern
end)

print("[Server] Main initialized")
