--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local function getOrCreate(name: string, className: string): Instance
    local existing = ReplicatedStorage:FindFirstChild(name)
    if existing then return existing end
    local remote = Instance.new(className)
    remote.Name = name
    remote.Parent = ReplicatedStorage
    return remote
end

-- Add your remotes here. Example:
-- Remotes.PurchaseItem = getOrCreate("PurchaseItem", "RemoteEvent") :: RemoteEvent

return Remotes
