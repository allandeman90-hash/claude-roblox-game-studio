--==============================================================
-- BootScreen  (LocalScript - ReplicatedFirst)
--
-- The first thing a player sees. Runs before anything replicates, so it
-- hardcodes its palette instead of requiring StyleConstants (which may not
-- exist yet). Two jobs:
--   1. Kill the Core GUI a full-GUI game with no character does not need
--      (PlayerList, Backpack, Health) so the top-right corner is free.
--      The imposed top-left (menu + chat) is LEFT ON.
--   2. Show "QUETE MINUTE / -- La Descente --" + a progress bar, then fade
--      out once the client is loaded (min 1.2 s, hard cap 8 s).
--
-- maquettes 02-maquettes.md 01 -- "Le chargement (ReplicatedFirst) montre le
-- meme bloc [logo + heros sur la ligne] avec une barre de progression."
--==============================================================

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

--===== Core GUI: no character -> free the top-right corner =====
-- (00-maquettes: PlayerList + Backpack off; chat and the imposed menu stay.)
local function setCore(coreType: Enum.CoreGuiType, enabled: boolean)
    pcall(StarterGui.SetCoreGuiEnabled, StarterGui, coreType, enabled)
end
setCore(Enum.CoreGuiType.PlayerList, false)
setCore(Enum.CoreGuiType.Backpack, false)
setCore(Enum.CoreGuiType.Health, false)

--===== Palette (hardcoded - StyleConstants may not have replicated yet) =====
local BG      = Color3.fromRGB(14, 15, 19)
local LINE    = Color3.fromRGB(96, 96, 101)
local TEXT    = Color3.fromRGB(248, 246, 238)
local DIM     = Color3.fromRGB(162, 154, 132)
local ACCENT  = Color3.fromRGB(201, 168, 120)
local FONT    = Enum.Font.Code

local MIN_SECONDS = 1.2
local MAX_SECONDS = 8
local FAKE_FILL_SECONDS = 2.2   -- the bar creeps to ~92% over this, then snaps

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "BootScreen"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100000
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = BG
backdrop.BorderSizePixel = 0
backdrop.ZIndex = 1
backdrop.Parent = gui

local block = Instance.new("Frame")
block.Name = "Block"
block.AnchorPoint = Vector2.new(0.5, 0.5)
block.Position = UDim2.fromScale(0.5, 0.5)
block.Size = UDim2.fromOffset(520, 0)
block.AutomaticSize = Enum.AutomaticSize.Y
block.BackgroundTransparency = 1
block.ZIndex = 2
block.Parent = gui
do
    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = block
end

local function label(text: string, size: number, colour: Color3, order: number): TextLabel
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, size + 8)
    l.Font = FONT
    l.Text = text
    l.TextColor3 = colour
    l.TextSize = size
    l.TextXAlignment = Enum.TextXAlignment.Center
    l.ZIndex = 2
    l.LayoutOrder = order
    l.Parent = block
    return l
end

label("QUETE MINUTE", 40, TEXT, 1)
label("-- La Descente --", 18, DIM, 2)

local spacer = Instance.new("Frame")
spacer.Size = UDim2.fromOffset(1, 18)
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = 3
spacer.Parent = block

local track = Instance.new("Frame")
track.Name = "Track"
track.Size = UDim2.new(1, 0, 0, 6)
track.BackgroundColor3 = Color3.fromRGB(23, 24, 29)
track.BorderColor3 = LINE
track.BorderSizePixel = 1
track.ClipsDescendants = true
track.ZIndex = 2
track.LayoutOrder = 4
track.Parent = block

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = ACCENT
fill.BorderSizePixel = 0
fill.ZIndex = 3
fill.Parent = track

local hint = label("Chargement...", 13, DIM, 5)

--===== Progress: creep to 92%, then snap when loaded + min time elapsed =====
local start = os.clock()

task.spawn(function()
    while os.clock() - start < FAKE_FILL_SECONDS do
        local r = (os.clock() - start) / FAKE_FILL_SECONDS
        fill.Size = UDim2.fromScale(0.92 * (1 - (1 - r) * (1 - r)), 1)  -- ease-out
        RunService.RenderStepped:Wait()
    end
end)

local function loaded(): boolean
    return game:IsLoaded()
end

while not (loaded() and os.clock() - start >= MIN_SECONDS) do
    if os.clock() - start >= MAX_SECONDS then break end
    task.wait(0.1)
end

hint.Text = "Prete."
TweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = UDim2.fromScale(1, 1) }):Play()
task.wait(0.3)

local fade = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
TweenService:Create(backdrop, fade, { BackgroundTransparency = 1 }):Play()
for _, d in ipairs(gui:GetDescendants()) do
    if d:IsA("TextLabel") then
        TweenService:Create(d, fade, { TextTransparency = 1 }):Play()
    elseif d:IsA("Frame") and d ~= backdrop then
        TweenService:Create(d, fade, { BackgroundTransparency = 1 }):Play()
    end
end
task.wait(0.5)
gui:Destroy()
