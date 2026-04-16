--!strict
-- Client entry point.
-- Initialize client-side systems.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

print("[Client] Initializing for", player.Name)

-- TODO: Set up input handling
-- TODO: Set up UI
-- TODO: Connect to server remotes for state updates

print("[Client] Ready")
