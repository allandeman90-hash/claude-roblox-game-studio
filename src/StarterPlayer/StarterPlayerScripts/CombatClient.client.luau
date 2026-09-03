--==============================================================
-- CombatClient  (LocalScript)
-- Receives combat data from the server and updates the existing GUI.
-- Never computes damage, HP, EXP, or gold locally.
--==============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Zone system data (decor palette + enemy roster per zone).
local ZoneConfig = require(ReplicatedStorage:WaitForChild("ZoneConfig"))
-- Slug -> rbxassetid map for the generated pixel-art sprites (GENERATED file).
local AssetMap = require(ReplicatedStorage:WaitForChild("AssetMap"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer

-- This experience is 100% GUI-driven. Disable Roblox's default 3D thumbstick/
-- jump controls; our own left/right controls below remain active on every device.
task.spawn(function()
    local playerScripts = player:WaitForChild("PlayerScripts")
    local playerModuleScript = playerScripts:WaitForChild("PlayerModule", 5)
    if playerModuleScript then
        local ok, playerModule = pcall(require, playerModuleScript)
        if ok and playerModule then
            local controls = playerModule:GetControls()
            if controls then controls:Disable() end
        end
    end
    local touchGui = player:WaitForChild("PlayerGui"):WaitForChild("TouchGui", 10)
    if touchGui and touchGui:IsA("ScreenGui") then
        local function suppressDefaultTouchControls()
            touchGui.Enabled = false
            local frame = touchGui:FindFirstChild("TouchControlFrame")
            if frame and frame:IsA("GuiObject") then frame.Visible = false end
        end
        suppressDefaultTouchControls()
        touchGui:GetPropertyChangedSignal("Enabled"):Connect(function()
            if touchGui.Enabled then suppressDefaultTouchControls() end
        end)
        touchGui.ChildAdded:Connect(function()
            task.defer(suppressDefaultTouchControls)
        end)
    end
end)

-- Wait for GUI to replicate
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end
local gui = playerGui:WaitForChild("RpgGui", 10)
if not gui then return end

-- Get RemoteEvent
local combatEvent = ReplicatedStorage:WaitForChild("CombatEvent", 10)
if not combatEvent then return end

--===== GUI references (reusing existing structure) =====
local background  = gui:FindFirstChild("Background")
local combatZone  = background:FindFirstChild("CombatZone")
local bottomPanel = background:FindFirstChild("BottomPanel")

local playerHpBar  = combatZone:FindFirstChild("PlayerHpBar")
local playerHpFill = playerHpBar:FindFirstChild("HpFill")
local playerHpText = playerHpBar:FindFirstChild("HpText")

local enemyHpPanel = combatZone:FindFirstChild("EnemyHpPanel")
-- EnemyName now lives directly under CombatZone (above the [ENNEMI] visual).
local enemyName     = combatZone:FindFirstChild("EnemyName")
local enemyHpBar    = enemyHpPanel:FindFirstChild("EnemyHpBar")
local enemyHpFill   = enemyHpBar:FindFirstChild("HpFill")
local enemyHpText   = enemyHpPanel:FindFirstChild("EnemyHpText")

-- The floating combat HP bars are now sprite-sized; the numeric readout would
-- overflow, and current HP reads better from the bar fill during a fight.
if playerHpText then playerHpText.Visible = false end
if enemyHpText then enemyHpText.Visible = false end
if playerHpBar then playerHpBar.Visible = false end

local heroPanel   = bottomPanel:FindFirstChild("HeroPanel")
local heroInfoBox = heroPanel:FindFirstChild("HeroInfoBox")
local heroLevel   = heroInfoBox:FindFirstChild("HeroLevel")
local heroWeapon  = heroInfoBox:FindFirstChild("HeroWeapon")
local heroArmor   = heroInfoBox:FindFirstChild("HeroArmor")
local heroPet     = heroInfoBox:FindFirstChild("HeroPet")
local heroTimeBox = heroPanel:FindFirstChild("HeroTimeBox")
local distValue   = heroTimeBox:FindFirstChild("DistValue")

local menuPanel    = bottomPanel:FindFirstChild("MenuPanel")
local rebirthButton = menuPanel and menuPanel:FindFirstChild("RebirthButton")

local centerPanel  = bottomPanel:FindFirstChild("CenterPanel")
local goldBox      = centerPanel:FindFirstChild("GoldBox")
local goldText     = goldBox:FindFirstChild("GoldText")
local enemyInfoBox = centerPanel:FindFirstChild("EnemyInfoBox")
local infoName     = enemyInfoBox:FindFirstChild("InfoName")
local infoLevel    = enemyInfoBox:FindFirstChild("InfoLevel")
local infoMaxHp    = enemyInfoBox:FindFirstChild("InfoMaxHp")
local infoExp      = enemyInfoBox:FindFirstChild("InfoExp")
-- Stale template label (never updated by code); the enemy has no meaningful SPD.
local infoSpd      = enemyInfoBox:FindFirstChild("InfoSpd")
if infoSpd then infoSpd.Visible = false end

--===== "La Descente" landscape shell =====
local artifactTopDeaths, artifactTopCenter, artifactTopEnemy
local artifactHeroHpText, artifactHeroHpFill
local artifactHeroXpText, artifactHeroXpFill
local artifactEnemyHpLabel, artifactEnemyHpText, artifactEnemyHpFill
local artifactHeroLevelCard, artifactHeroWeaponCard, artifactHeroArmorCard, artifactHeroPetCard, artifactHeroStatsCard, artifactHeroGoldCard
local artifactEnemyNameCard, artifactEnemyPvCard, artifactEnemyGoldCard, artifactEnemyAtkCard
local artifactProgressText, artifactProgressFill
local artifactMenuButton

-- The old prototype panels are not part of the final visual language. Keep
-- their objects alive for legacy overlay wiring, but render a brand-new HUD.
do
    local BG = Color3.fromRGB(14, 15, 19)
    local PANEL = Color3.fromRGB(18, 19, 24)
    local BORDER = Color3.fromRGB(198, 196, 188)
    local TEXT = Color3.fromRGB(242, 239, 226)
    local MUTED = Color3.fromRGB(154, 149, 132)
    local ACCENT = Color3.fromRGB(255, 220, 70)
    local XP = Color3.fromRGB(170, 105, 235)
    local GREEN = Color3.fromRGB(83, 190, 96)
    local RED = Color3.fromRGB(224, 78, 70)

    heroPanel.Visible = false
    centerPanel.Visible = false
    menuPanel.Visible = false

    gui.IgnoreGuiInset = true
    if gui:IsA("ScreenGui") then
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    end
    background.BackgroundColor3 = BG
    background.BackgroundTransparency = 0
    background.BorderSizePixel = 1
    background.BorderColor3 = BORDER
    local topInset = GuiService:GetGuiInset().Y
    local function fitBackgroundToViewport()
        background.Position = UDim2.fromOffset(0, 0)
        background.Size = UDim2.fromScale(1, 1)
    end
    fitBackgroundToViewport()
    local camera = workspace.CurrentCamera
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitBackgroundToViewport)
    end

    local topSection = background:FindFirstChild("TopSection")
    if topSection and topSection:IsA("GuiObject") then
        topSection.Position = UDim2.new(0, 4, 0, topInset + 4)
        topSection.Size = UDim2.new(1, -8, 0, 72)
        topSection.BackgroundColor3 = BG
        topSection.BackgroundTransparency = 0
        topSection.BorderColor3 = BORDER
        topSection.BorderSizePixel = 1
        for _, child in ipairs(topSection:GetChildren()) do
            if child:IsA("GuiObject") then child.Visible = false end
        end

        artifactTopDeaths = topSection:FindFirstChild("ArtifactDeaths") :: TextLabel?
        if not artifactTopDeaths then
            artifactTopDeaths = Instance.new("TextLabel")
            artifactTopDeaths.Name = "ArtifactDeaths"
            artifactTopDeaths.Parent = topSection
        end
        artifactTopDeaths.Position = UDim2.new(0, 0, 0, 0)
        artifactTopDeaths.Size = UDim2.new(0.15, 0, 1, 0)
        artifactTopDeaths.BackgroundTransparency = 1
        artifactTopDeaths.BorderSizePixel = 0
        artifactTopDeaths.Font = Enum.Font.Code
        artifactTopDeaths.Text = ""
        artifactTopDeaths.TextColor3 = MUTED
        artifactTopDeaths.TextSize = 13
        artifactTopDeaths.TextScaled = false
        artifactTopDeaths.TextXAlignment = Enum.TextXAlignment.Center
        artifactTopDeaths.TextYAlignment = Enum.TextYAlignment.Center
        artifactTopDeaths.TextWrapped = true
        artifactTopDeaths.Visible = true
        artifactTopDeaths.ZIndex = 20

        artifactTopCenter = topSection:FindFirstChild("ArtifactCenter") :: TextLabel?
        if not artifactTopCenter then
            artifactTopCenter = Instance.new("TextLabel")
            artifactTopCenter.Name = "ArtifactCenter"
            artifactTopCenter.Parent = topSection
        end
        artifactTopCenter.Position = UDim2.new(0.15, 0, 0, 0)
        artifactTopCenter.Size = UDim2.new(0.62, 0, 1, 0)
        artifactTopCenter.BackgroundTransparency = 1
        artifactTopCenter.BorderSizePixel = 0
        artifactTopCenter.Font = Enum.Font.Code
        artifactTopCenter.Text = "☠  0  ·  COUCHE 1  ·  0.0 KM"
        artifactTopCenter.TextColor3 = TEXT
        artifactTopCenter.TextSize = 20
        artifactTopCenter.TextScaled = false
        artifactTopCenter.TextXAlignment = Enum.TextXAlignment.Center
        artifactTopCenter.Visible = true
        artifactTopCenter.ZIndex = 20

        artifactTopEnemy = topSection:FindFirstChild("ArtifactEnemy") :: TextLabel?
        if not artifactTopEnemy then
            artifactTopEnemy = Instance.new("TextLabel")
            artifactTopEnemy.Name = "ArtifactEnemy"
            artifactTopEnemy.Parent = topSection
        end
        artifactTopEnemy.Position = UDim2.new(0.77, 0, 0, 0)
        artifactTopEnemy.Size = UDim2.new(0.23, 0, 1, 0)
        artifactTopEnemy.BackgroundTransparency = 1
        artifactTopEnemy.BorderSizePixel = 0
        artifactTopEnemy.Font = Enum.Font.Code
        artifactTopEnemy.Text = "EXPLORATION"
        artifactTopEnemy.TextColor3 = ACCENT
        artifactTopEnemy.TextSize = 18
        artifactTopEnemy.TextScaled = false
        artifactTopEnemy.TextXAlignment = Enum.TextXAlignment.Center
        artifactTopEnemy.Visible = true
        artifactTopEnemy.ZIndex = 20

        for i, x in ipairs({ 0.15, 0.77 }) do
            local divider = topSection:FindFirstChild("ReferenceDivider" .. i) or Instance.new("Frame")
            divider.Name = "ReferenceDivider" .. i
            divider.Position = UDim2.new(x, 0, 0, 0)
            divider.Size = UDim2.new(0, 1, 1, 0)
            divider.BackgroundColor3 = BORDER
            divider.BackgroundTransparency = 0.15
            divider.BorderSizePixel = 0
            divider.Visible = true
            divider.ZIndex = 19
            divider.Parent = topSection
        end
    end

    bottomPanel.Position = UDim2.new(0, 4, 0, topInset + 78)
    bottomPanel.Size = UDim2.new(1, -8, 1, -(topInset + 122))
    bottomPanel.BackgroundColor3 = BG
    bottomPanel.BackgroundTransparency = 0
    bottomPanel.BorderColor3 = BORDER
    bottomPanel.BorderSizePixel = 1

    local function panel(name, position, size)
        local frame = bottomPanel:FindFirstChild(name) or Instance.new("Frame")
        frame.Name = name
        frame.Position = position
        frame.Size = size
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = false
        frame.Visible = true
        frame.Parent = bottomPanel
        return frame
    end

    local function card(parent, name, text, y, height, color)
        local item = parent:FindFirstChild(name) or Instance.new("TextLabel")
        item.Name = name
        item.Position = UDim2.new(0.04, 0, y, 0)
        item.Size = UDim2.new(0.92, 0, height, 0)
        item.BackgroundColor3 = PANEL
        item.BackgroundTransparency = 0
        item.BorderColor3 = BORDER
        item.BorderSizePixel = 1
        item.Font = Enum.Font.Code
        item.Text = text
        item.TextColor3 = color or TEXT
        item.TextSize = 16
        item.TextScaled = false
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.TextYAlignment = Enum.TextYAlignment.Center
        item.ZIndex = 20
        item.TextTruncate = Enum.TextTruncate.AtEnd
        item.Visible = true
        item.Parent = parent
        return item
    end

    local function freshHp(parent, color)
        local title = card(parent, "HpText", "PV", 0.015, 0.07)
        title.BackgroundTransparency = 1
        title.BorderSizePixel = 0
        title.ZIndex = 24
        title.TextSize = 16
        title.Size = UDim2.new(0.09, 0, 0.07, 0)
        local bar = parent:FindFirstChild("HpBar") or Instance.new("Frame")
        bar.Name = "HpBar"
        bar.Position = UDim2.new(0.095, 0, 0.044, 0)
        bar.Size = UDim2.new(0.65, 0, 0.026, 0)
        bar.BackgroundColor3 = Color3.fromRGB(20, 21, 24)
        bar.BorderColor3 = BORDER
        bar.BorderSizePixel = 1
        bar.ZIndex = 21
        bar.Parent = parent
        local fill = bar:FindFirstChild("Fill") or Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.fromScale(1, 1)
        fill.BackgroundColor3 = color
        fill.BorderSizePixel = 0
        fill.ZIndex = 22
        fill.Parent = bar
        local value = parent:FindFirstChild("HpValue") or Instance.new("TextLabel")
        value.Name = "HpValue"
        value.Position = UDim2.new(0.765, 0, 0.015, 0)
        value.Size = UDim2.new(0.20, 0, 0.07, 0)
        value.BackgroundTransparency = 1
        value.BorderSizePixel = 0
        value.Font = Enum.Font.Code
        value.Text = "0/0"
        value.TextColor3 = TEXT
        value.TextSize = 16
        value.TextScaled = false
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.ZIndex = 24
        value.Visible = true
        value.Parent = parent
        return title, value, fill
    end

    local function xpBar(parent)
        local root = parent:FindFirstChild("XpBar") or Instance.new("Frame")
        root.Name = "XpBar"
        root.Position = UDim2.new(0.04, 0, 0.175, 0)
        root.Size = UDim2.new(0.92, 0, 0.052, 0)
        root.BackgroundColor3 = Color3.fromRGB(20, 21, 24)
        root.BackgroundTransparency = 0
        root.BorderColor3 = BORDER
        root.BorderSizePixel = 1
        root.ClipsDescendants = true
        root.ZIndex = 20
        root.Visible = true
        root.Parent = parent

        local fill = root:FindFirstChild("Fill") or Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.fromScale(0, 1)
        fill.BackgroundColor3 = XP
        fill.BorderSizePixel = 0
        fill.ZIndex = 21
        fill.Parent = root

        local value = root:FindFirstChild("Value") or Instance.new("TextLabel")
        value.Name = "Value"
        value.Size = UDim2.fromScale(1, 1)
        value.BackgroundTransparency = 1
        value.BorderSizePixel = 0
        value.Font = Enum.Font.Code
        value.Text = "XP 0 / 0  -  0.0%"
        value.TextColor3 = TEXT
        value.TextStrokeColor3 = Color3.fromRGB(25, 18, 38)
        value.TextStrokeTransparency = 0.55
        value.TextScaled = true
        value.TextXAlignment = Enum.TextXAlignment.Center
        value.ZIndex = 22
        value.Parent = root
        local textConstraint = value:FindFirstChildOfClass("UITextSizeConstraint") or Instance.new("UITextSizeConstraint")
        textConstraint.MinTextSize = 9
        textConstraint.MaxTextSize = 13
        textConstraint.Parent = value
        return value, fill
    end

    local left = panel("DescenteLeft", UDim2.new(0.018, 0, 0.02, 0), UDim2.new(0.225, 0, 0.90, 0))
    local right = panel("DescenteRight", UDim2.new(0.757, 0, 0.02, 0), UDim2.new(0.225, 0, 0.90, 0))

    combatZone.Parent = bottomPanel
    combatZone.Position = UDim2.new(0.255, 0, 0.11, 0)
    combatZone.Size = UDim2.new(0.49, 0, 0.775, 0)
    combatZone.BackgroundColor3 = BG
    combatZone.BackgroundTransparency = 0
    combatZone.BorderColor3 = BORDER
    combatZone.BorderSizePixel = 1
    combatZone.ClipsDescendants = true

    local _, heroHpText, heroHpFill = freshHp(left, GREEN)
    artifactHeroHpText, artifactHeroHpFill = heroHpText, heroHpFill
    artifactHeroLevelCard = card(left, "LevelCard", "LV 1", 0.108, 0.068)
    artifactHeroXpText, artifactHeroXpFill = xpBar(left)
    artifactHeroWeaponCard = card(left, "WeaponCard", "Arme  -", 0.255, 0.068)
    artifactHeroArmorCard = card(left, "ArmorCard", "Armr  -", 0.335, 0.068)
    artifactHeroPetCard = card(left, "PetCard", "Pets  -", 0.415, 0.068)
    artifactHeroStatsCard = card(left, "StatsCard", "ATK 0  ·  DEF 0\nRES 0  ·  CRIT 0%", 0.50, 0.105)
    artifactHeroStatsCard.TextWrapped = true
    artifactHeroGoldCard = card(left, "GoldCard", "OR  0", 0.625, 0.068, ACCENT)

    local talents = card(left, "Talents", "T A L E N T S", 0.875, 0.09, ACCENT)
    talents.TextXAlignment = Enum.TextXAlignment.Center
    talents.BorderColor3 = ACCENT

    artifactEnemyHpLabel, artifactEnemyHpText, artifactEnemyHpFill = freshHp(right, RED)
    artifactEnemyNameCard = card(right, "EnemyCard", "Exploration", 0.108, 0.068, ACCENT)
    artifactEnemyPvCard = card(right, "EnemyPvCard", "PV  -", 0.188, 0.068)
    artifactEnemyGoldCard = card(right, "GoldCard", "OR  0", 0.268, 0.068, ACCENT)
    artifactEnemyAtkCard = card(right, "AtkCard", "ATK 100%  ·  PHYS.", 0.348, 0.068)
    if artifactEnemyHpLabel then artifactEnemyHpLabel.Visible = false end
    if artifactEnemyHpText then artifactEnemyHpText.Visible = false end
    if artifactEnemyHpFill and artifactEnemyHpFill.Parent then artifactEnemyHpFill.Parent.Visible = false end
    artifactEnemyNameCard.Visible = false
    artifactEnemyPvCard.Visible = false
    artifactEnemyGoldCard.Visible = false
    artifactEnemyAtkCard.Visible = false

    local inventory = card(right, "Inventory", "INVENTAIRE", 0.765, 0.09, ACCENT)
    inventory.TextXAlignment = Enum.TextXAlignment.Center
    inventory.BorderColor3 = ACCENT

    local menu = card(right, "Menu", "MENU", 0.875, 0.09, ACCENT)
    menu.TextXAlignment = Enum.TextXAlignment.Center
    menu.BorderColor3 = ACCENT
    artifactMenuButton = Instance.new("TextButton")
    artifactMenuButton.Name = "Click"
    artifactMenuButton.Size = UDim2.fromScale(1, 1)
    artifactMenuButton.BackgroundTransparency = 1
    artifactMenuButton.Text = ""
    artifactMenuButton.Active = true
    artifactMenuButton.AutoButtonColor = false
    artifactMenuButton.ZIndex = 21
    artifactMenuButton.Parent = menu

    local abilityBar = bottomPanel:FindFirstChild("ArtifactAbilities")
    if abilityBar and abilityBar:IsA("GuiObject") then
        abilityBar.Visible = false
    end

    local zoneTrack = background:FindFirstChild("ZoneTrack")
    if zoneTrack then
        zoneTrack.Position = UDim2.new(0, 4, 1, -42)
        zoneTrack.Size = UDim2.new(1, -8, 0, 38)
        zoneTrack.BackgroundColor3 = BG
        zoneTrack.BackgroundTransparency = 0
        zoneTrack.BorderColor3 = BORDER
        zoneTrack.BorderSizePixel = 1
        for _, child in ipairs(zoneTrack:GetChildren()) do
            if child:IsA("GuiObject") then child.Visible = false end
        end
        artifactProgressText = card(zoneTrack, "DescenteText", "COUCHE 1 - PLAINE DE L'AUBE  ·  ETAPE 1/10  ·  PROCHAIN : BOSS",
            0.05, 0.90)
        artifactProgressText.Position = UDim2.new(0.02, 0, 0.05, 0)
        artifactProgressText.Size = UDim2.new(0.44, 0, 0.90, 0)
        artifactProgressText.BackgroundTransparency = 1
        artifactProgressText.BorderSizePixel = 0
        artifactProgressText.TextSize = 13
        local rail = Instance.new("Frame")
        rail.Name = "DescenteRail"
        rail.Position = UDim2.new(0.48, 0, 0.35, 0)
        rail.Size = UDim2.new(0.36, 0, 0.30, 0)
        rail.BackgroundColor3 = Color3.fromRGB(20, 21, 24)
        rail.BorderColor3 = BORDER
        rail.BorderSizePixel = 1
        rail.ZIndex = 20
        rail.Parent = zoneTrack
        artifactProgressFill = Instance.new("Frame")
        artifactProgressFill.Name = "Fill"
        artifactProgressFill.Size = UDim2.fromScale(0, 1)
        artifactProgressFill.BackgroundColor3 = XP
        artifactProgressFill.BorderSizePixel = 0
        artifactProgressFill.ZIndex = 21
        artifactProgressFill.Parent = rail
        local boss = card(zoneTrack, "Boss", "BOSS", 0.05, 0.90, ACCENT)
        boss.Position = UDim2.new(0.855, 0, 0.05, 0)
        boss.Size = UDim2.new(0.08, 0, 0.90, 0)
        boss.BackgroundTransparency = 1
        boss.BorderSizePixel = 0
        boss.TextXAlignment = Enum.TextXAlignment.Right
    end
end

-- Artifact cards: LV, weapon, armor, pets. HP has its dedicated bar above.
local heroPvLine = heroInfoBox:FindFirstChild("HeroTitle")
do
    if heroPvLine then heroPvLine.Visible = false end
    local rows = { heroLevel, heroWeapon, heroArmor, heroPet }
    for i, lbl in ipairs(rows) do
        if lbl then
            lbl.Position = UDim2.new(0, 10, 0.02 + (i - 1) * 0.245, 0)
            lbl.Size = UDim2.new(1, -20, 0.22, 0)
            lbl.TextScaled = false
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.BackgroundTransparency = 0
            lbl.BackgroundColor3 = Color3.fromRGB(13, 14, 18)
            lbl.BorderColor3 = Color3.fromRGB(185, 185, 185)
        end
    end
end

-- Combat HP bars keep the same sharp, flat language as the reference HUD.
do
    local function styleBar(bar)
        if not bar then return end
        local st = bar:FindFirstChildWhichIsA("UIStroke")
        if st then st:Destroy() end
        local function removeCorner(o)
            if o:IsA("GuiObject") then
                local corner = o:FindFirstChildWhichIsA("UICorner")
                if corner then corner:Destroy() end
            end
        end
        removeCorner(bar)
        for _, d in ipairs(bar:GetDescendants()) do
            if d:IsA("Frame") then removeCorner(d) end
        end
    end
    styleBar(playerHpBar)
    styleBar(enemyHpPanel)
end

-- Scroll background references
local scrollBg    = combatZone:FindFirstChild("ScrollBackground")
local farLayer    = scrollBg and scrollBg:FindFirstChild("FarLayer")
local midLayer    = scrollBg and scrollBg:FindFirstChild("MidLayer")
local nearLayer   = scrollBg and scrollBg:FindFirstChild("NearLayer")

-- Per-couche painted backdrop (bg_zone1..12), fixed behind the parallax layers.
-- The scene is the centre column, so this fills CombatZone and is cropped.
local zoneBackdrop = combatZone:FindFirstChild("ZoneBackdrop")
if zoneBackdrop and not zoneBackdrop:IsA("ImageLabel") then
    zoneBackdrop:Destroy()
    zoneBackdrop = nil
end
if not zoneBackdrop then
    zoneBackdrop = Instance.new("ImageLabel")
    zoneBackdrop.Name = "ZoneBackdrop"
    zoneBackdrop.Size = UDim2.fromScale(1, 1)
    zoneBackdrop.BackgroundTransparency = 1
    zoneBackdrop.BorderSizePixel = 0
    zoneBackdrop.ScaleType = Enum.ScaleType.Crop
    -- RpgGui uses ZIndexBehavior.Global, so a child at ZIndex 0 renders BEHIND
    -- the opaque ancestor frames (Background). ZIndex 1 = tied with the parallax
    -- layers but, being a deeper sibling added after them, still draws behind
    -- MidLayer (z2) / NearLayer (z3) / the sprites.
    zoneBackdrop.ZIndex = 1
    zoneBackdrop.Parent = combatZone
end
local zoneLabel   = combatZone:FindFirstChild("ZoneLabel")
local statusText  = combatZone:FindFirstChild("StatusText")
local heroSlot    = combatZone:FindFirstChild("HeroSlot")
local enemySlot   = combatZone:FindFirstChild("EnemySlot")
local distLabelCZ = combatZone:FindFirstChild("DistanceLabel")
if zoneLabel then zoneLabel.Visible = false end
if distLabelCZ then distLabelCZ.Visible = false end
if statusText then
    statusText.AnchorPoint = Vector2.new(0.5, 1)
    statusText.Position = UDim2.new(0.5, 0, 0.985, 0)
    statusText.Size = UDim2.new(0.80, 0, 0.065, 0)
    statusText.BackgroundTransparency = 1
    statusText.TextScaled = false
    statusText.TextSize = 14
    statusText.ZIndex = 10
end

-- Milestone 2D decor (shown only while stopped at a palier).
local milestoneDecor = combatZone:FindFirstChild("MilestoneDecor")
local campfireDecor  = milestoneDecor and milestoneDecor:FindFirstChild("Campfire")
local shopDecor      = milestoneDecor and milestoneDecor:FindFirstChild("Shop")
local bossDecor      = milestoneDecor and milestoneDecor:FindFirstChild("Boss")
local campfireStayBtn     = campfireDecor and campfireDecor:FindFirstChild("RestBtn", true)
local campfireContinueBtn = campfireDecor and campfireDecor:FindFirstChild("ContinueBtn", true)

--===== Zone decor =====
-- A zone transition only restyles the existing ScrollBackground layers
-- (sky / hills / ground / trees / rocks). No other UI is touched.
-- `hide` = a painted backdrop is doing this layer's job, so make its tiles and
-- every prop invisible instead of tinting them (avoids the flat-colour parallax
-- clashing with the detailed art).
local function paintLayer(layer, tileColor, d, hide)
    if not layer then return end
    local t = hide and 1 or 0
    for _, tile in ipairs(layer:GetChildren()) do
        if tile:IsA("GuiObject") then
            tile.BackgroundColor3 = tileColor
            tile.BackgroundTransparency = t
            for _, prop in ipairs(tile:GetChildren()) do
                if prop:IsA("GuiObject") then
                    local n = prop.Name
                    if string.match(n, "^Star") then
                        prop.BackgroundColor3 = d.star
                    elseif string.match(n, "^Hill") then
                        prop.BackgroundColor3 = d.hill
                    elseif string.match(n, "^Tree") then
                        prop.BackgroundColor3 = d.tree
                    elseif string.match(n, "^Rock") then
                        prop.BackgroundColor3 = d.rock
                    end
                    prop.BackgroundTransparency = t
                end
            end
        end
    end
end

local appliedZone = nil
local function applyZoneDecor(zoneId)
    -- Painted backdrop for this couche (falls back to the tinted parallax if
    -- the art is missing / not yet uploaded).
    local backdrop = AssetMap["bg_zone" .. tostring(zoneId)]
    local hasArt = backdrop ~= nil
    if zoneBackdrop then
        zoneBackdrop.Image = backdrop or ""
        zoneBackdrop.Visible = hasArt
    end
    -- The painted backdrop becomes the scene fill; drop the black CombatZone bg.
    combatZone.BackgroundTransparency = hasArt and 1 or 0

    local cfg = ZoneConfig.getZone(zoneId)
    if not (cfg and cfg.decor) then return end
    local d = cfg.decor
    -- With a painted backdrop, the whole flat-colour parallax is hidden and the
    -- sprites stand directly on the art. Without art, the tinted parallax is
    -- the background (original behaviour).
    paintLayer(farLayer, d.farSky, d, hasArt)
    paintLayer(midLayer, d.midSky, d, hasArt)
    paintLayer(nearLayer, d.ground, d, hasArt)
end

-- HeroTimeBox: ZONE / DIST + all-time record + this-session XP/min & gold/min.
local timeLabel   = heroTimeBox:FindFirstChild("TimeLabel")
local timeValue   = heroTimeBox:FindFirstChild("TimeValue")
local distLabel   = heroTimeBox:FindFirstChild("DistLabel")
do
    -- B6b: the HeroTimeBox in RpgGui fits ~2 lines; 4 crammed rows were illegible.
    -- Drop the ZONE row (zone is already on the zone track + top HUD) -> 3 rows:
    -- DIST / RECORD / /MIN.
    local function mkRow(name, labelText)
        local lbl = heroTimeBox:FindFirstChild(name .. "Label")
        local val = heroTimeBox:FindFirstChild(name .. "Value")
        if not lbl then
            lbl = timeLabel:Clone() ; lbl.Name = name .. "Label" ; lbl.Parent = heroTimeBox
        end
        lbl.Text = labelText
        if not val then
            val = timeValue:Clone() ; val.Name = name .. "Value" ; val.Text = "" ; val.Parent = heroTimeBox
        end
        return { lbl, val }
    end

    if distLabel then distLabel.Text = "DIST" end
    local rows = {
        { distLabel, distValue },
        mkRow("Record", "RECORD"),
        mkRow("Rate", "/MIN"),
    }

    -- ZONE row is retired from this box.
    if timeLabel then timeLabel.Visible = false end
    if timeValue then timeValue.Visible = false end

    for i, pair in ipairs(rows) do
        local y = 0.08 + (i - 1) * 0.30
        if pair[1] then
            pair[1].Position = UDim2.new(0, 14, y, 0)
            pair[1].Size = UDim2.new(0.30, 0, 0.26, 0)
            pair[1].TextSize = 13
        end
        if pair[2] then
            pair[2].Position = UDim2.new(0.32, 0, y, 0)
            pair[2].Size = UDim2.new(0.66, -14, 0.26, 0)
            pair[2].TextSize = 14
        end
    end
end
local recordValue = heroTimeBox:FindFirstChild("RecordValue")
local rateValue   = heroTimeBox:FindFirstChild("RateValue")

-- This-session income rates (reset on rejoin). Track gross gains only so
-- shop / rebirth spending doesn't drag the gold rate negative.
local sessionT0, lastXp, lastGold = os.clock(), nil, nil
local xpGained, goldGained = 0, 0

--===== Scene (world traversal) =====
-- Static backdrop; the HERO moves. ONE linear layout, NO mirror: the same
-- km->screen function places the hero AND both mobs, so nothing can ever dash.
--   e1 & e2 fixed at their step fraction ; hero walks WALK_LO (step start / left)
--   .. WALK_HI (wall / right). Forward you traverse left->right, backward right->left.
local enemyStep1 = combatZone:FindFirstChild("EnemyStep1")
local enemyStep2 = combatZone:FindFirstChild("EnemyStep2")
local ENC_FRAC    = { 0.5, 0.95 }     -- fallback ; the server sends enc.rel per mob
local WALK_LO, WALK_HI = 0.15, 0.88   -- hero's walkable band (portals sit just outside it)
local PORTAL_L, PORTAL_R = 0.05, 0.95 -- blue (go back) / red (go forward)
local WALL_LEAN   = 0.10              -- lean a touch further against the km-0 boundary
local SCENE_Y     = 0.62              -- vertical centre of the slot Frames
local SLOT_H      = 0.40              -- slot Frame height (CombatZone fraction; matches RpgGui)
local GROUND_Y    = 0.86              -- CombatZone Y where a combatant's feet rest (top of the drawn ground)
local SPRITE_FEET_R = (GROUND_Y - (SCENE_Y - SLOT_H / 2)) / SLOT_H  -- GROUND_Y as a slot-relative Y
local FIGHT_NUDGE = 0.06              -- hero stops just short of the enemy block
local heroTargetX    = WALK_LO
local enemyHpTargetX = WALK_HI
local sceneLastStepKey = nil          -- floor(km) of the step the hero is currently in
local sceneFacing    = "right"        -- set ONLY when crossing into a new step
local NAMETAG_VERSION = 8

local function stepXtoScreen(frac)
    return WALK_LO + math.clamp(frac or 0, 0, 1) * (WALK_HI - WALK_LO)
end

-- Fight-difficulty colour from MY effective stats vs. the enemy's HP/ATK:
-- roughly (seconds for me to kill it) / (seconds for it to kill me).
-- 6 tiers: grey trivial, green easy, yellow medium, orange hard, red very hard, purple extreme.
local DIFF_COLOURS = {
    Color3.fromRGB(150, 150, 155),
    Color3.fromRGB(105, 205, 105),
    Color3.fromRGB(220, 210, 90),
    Color3.fromRGB(240, 155, 70),
    Color3.fromRGB(230, 80, 80),
    Color3.fromRGB(200, 90, 220),
}
local function difficultyColour(data, enemyHp, enemyAtk, enemyMagic)
    local myAtk = math.max(1, data.playerAtk or 1)
    local myHp  = math.max(1, data.playerMaxHp or 1)
    local resist = enemyMagic and (data.playerRes or 0) or (data.playerDef or 0)
    local mit = 100 / (100 + math.max(0, resist))
    local C = GameConfig.Combat
    local myInterval = math.max(C.minAttackInterval,
        C.playerAttackInterval / (1 + math.max(0, (data.statSpd or 1) - 1) * C.spdCadenceCoef))
    local ttk = math.max(1, enemyHp or 1) / (myAtk / myInterval)                       -- kill it
    local ttd = myHp / math.max(0.1, math.max(0, enemyAtk or 0) / C.enemyAttackInterval * mit)  -- it kills me
    local r = ttk / ttd
    local tier =
        (r <= 0.12 and 1) or (r <= 0.30 and 2) or (r <= 0.70 and 3)
        or (r <= 1.40 and 4) or (r <= 3.00 and 5) or 6
    return DIFF_COLOURS[tier]
end

--===== Combatant sprites (hero / enemy / pet) ==========================
-- AssetMap holds "<slug>" and "<slug>_flip" (a horizontal mirror). Base art
-- faces slightly left; the mirror faces right. A combatant always faces its
-- opponent, so the pick follows sceneFacing:
--   forward (hero on the LEFT)  -> hero faces right, enemy faces left
--   back    (hero on the RIGHT) -> hero faces left,  enemy faces right
-- Sprite size as a fraction of its (roughly square, in px) slot Frame.
local BASE_SPRITE_W, BASE_SPRITE_H = 1.15, 1.15   -- prominent combatants, matching the reference scene
local BOSS_SPRITE_MUL = 1.45
local HPBAR_W, HPBAR_H = 0.077, 0.026             -- floating HP bar, matched to a sprite's width

local function spriteFor(slug, faceRight)
    if not slug then return nil end
    if faceRight then
        return AssetMap[slug .. "_flip"] or AssetMap[slug]
    end
    return AssetMap[slug]
end

-- One reusable ImageLabel per slot Frame (created like the portals / nametags).
local function ensureSprite(slot)
    local img = slot:FindFirstChild("Sprite")
    if not img then
        img = Instance.new("ImageLabel")
        img.Name = "Sprite"
        img.BackgroundTransparency = 1
        img.BorderSizePixel = 0
        img.AnchorPoint = Vector2.new(0.5, 1)                -- bottom-centre = the creature's feet
        img.Position = UDim2.new(0.5, 0, SPRITE_FEET_R, 0)   -- feet on the ground line
        img.Size = UDim2.new(BASE_SPRITE_W, 0, BASE_SPRITE_H, 0)
        img.ScaleType = Enum.ScaleType.Fit
        img.ResampleMode = Enum.ResamplerMode.Pixelated
        img.ZIndex = 4
        img.Parent = slot
    end
    return img
end

-- Paint <slug> on a slot (mirrored per faceRight). No matching asset -> the
-- sprite hides and the slot's text label + box stay (discreet fallback, no
-- emoji, no coloured placeholder frame).
local function paintCombatant(slot, slug, faceRight, active, boss)
    if not slot then return end
    local img = ensureSprite(slot)
    local asset = spriteFor(slug, faceRight)
    local want = asset or ""
    if img.Image ~= want then img.Image = want end   -- avoid redundant writes each update
    img.Visible = asset ~= nil
    local mul = boss and BOSS_SPRITE_MUL or 1
    img.Size = UDim2.new(BASE_SPRITE_W * mul, 0, BASE_SPRITE_H * mul, 0)
    img.ImageColor3 = (active ~= false) and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
    slot.BackgroundTransparency = asset and 1 or 0
    local sk = slot:FindFirstChildWhichIsA("UIStroke")
    if sk then sk.Enabled = asset == nil end   -- the outline box is only for the text fallback
    local lbl = slot:FindFirstChild("EnemyLabel") or slot:FindFirstChild("HeroLabel")
    if lbl then lbl.Visible = asset == nil end
end

--===== Pet companion (real pixel-art sprite; follows the hero, lunges on hit) =====
-- Was a coloured Frame + emoji tag; now an ImageLabel driven by AssetMap.
local petSprite = combatZone:FindFirstChild("PetSprite")
if petSprite and not petSprite:IsA("ImageLabel") then
    petSprite:Destroy()   -- drop the old placeholder Frame if a prior build left one
    petSprite = nil
end
if not petSprite then
    petSprite = Instance.new("ImageLabel")
    petSprite.Name = "PetSprite"
    petSprite.AnchorPoint = Vector2.new(0.5, 1)          -- feet on the ground line
    petSprite.Size = UDim2.new(0.052, 0, 0.15, 0)        -- smaller than the hero (a companion)
    petSprite.BackgroundTransparency = 1
    petSprite.BorderSizePixel = 0
    petSprite.ScaleType = Enum.ScaleType.Fit
    petSprite.ResampleMode = Enum.ResamplerMode.Pixelated
    petSprite.ZIndex = 4
    petSprite.Visible = false
    petSprite.Parent = combatZone
end
local petLungeUntil = 0
local heroAttackUntil, enemyAttackUntil = 0, 0
local petRole = nil   -- "dps"|"tank"|"heal"|nil ; mirrors data.petRole for the RenderStepped follow

--===== Step crossing transition =====
-- The only step-boundary feedback the player wants is a brief crossing wipe
-- (playStepTransition). The old pulsing edge "portals" are kept as hidden stubs
-- so the rest of the code can still reference them without nil-checks.
local function makePortal(name, col)
    local p = combatZone:FindFirstChild(name)
    if p then return p end
    p = Instance.new("Frame")
    p.Name = name
    p.AnchorPoint = Vector2.new(0.5, 0.5)
    p.Size = UDim2.new(0, 13, 0.64, 0)
    p.BackgroundColor3 = col
    p.BorderSizePixel = 0
    p.ZIndex = 3
    local uc = Instance.new("UICorner", p) ; uc.CornerRadius = UDim.new(1, 0)
    local ust = Instance.new("UIStroke", p)
    ust.Color = Color3.new(1, 1, 1) ; ust.Thickness = 2 ; ust.Transparency = 0.35
    local ugr = Instance.new("UIGradient", p)
    ugr.Rotation = 90
    ugr.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.55),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.55),
    })
    p.Parent = combatZone
    return p
end
local bluePortal = makePortal("BluePortal", Color3.fromRGB(70, 150, 255))
local redPortal  = makePortal("RedPortal",  Color3.fromRGB(255, 70, 70))
bluePortal.Position = UDim2.new(PORTAL_L, 0, SCENE_Y, 0)
redPortal.Position  = UDim2.new(PORTAL_R, 0, SCENE_Y, 0)
bluePortal.Visible = false   -- removed per design: no edge markers, only the crossing wipe
redPortal.Visible  = false

local stepTransition = combatZone:FindFirstChild("StepTransition")
if not stepTransition then
    stepTransition = Instance.new("Frame")
    stepTransition.Name = "StepTransition"
    stepTransition.Size = UDim2.new(1, 0, 1, 0)
    stepTransition.Position = UDim2.new(0, 0, 0, 0)
    stepTransition.BackgroundTransparency = 1
    stepTransition.BorderSizePixel = 0
    stepTransition.ZIndex = 20
    stepTransition.Visible = false
    stepTransition.Parent = combatZone
end
-- Brief, soft crossing wipe - a gentle light veil, NOT an alarm flash. A cool
-- tint going back, a warm tint going forward; barely-there peak opacity.
local function playStepTransition(goingBack)
    stepTransition.BackgroundColor3 = goingBack and Color3.fromRGB(205, 225, 255) or Color3.fromRGB(255, 240, 220)
    stepTransition.Visible = true
    stepTransition.BackgroundTransparency = 1
    local tin = TweenService:Create(stepTransition, TweenInfo.new(0.10, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.80 })
    tin.Completed:Connect(function()
        local tout = TweenService:Create(stepTransition, TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
        tout.Completed:Connect(function() stepTransition.Visible = false end)
        tout:Play()
    end)
    tin:Play()
end

-- Low-HP screen flash: the ONLY red screen effect. A UNIFORM full-screen red
-- pulse while the player is alive and under 20% HP - no gradient, so there is no
-- red bar at the top edge / above the death counter. Clears at / above 20%.
local lowHpVignette = background:FindFirstChild("LowHpVignette")
if not lowHpVignette then
    lowHpVignette = Instance.new("Frame")
    lowHpVignette.Name = "LowHpVignette"
    lowHpVignette.Parent = background
end
lowHpVignette.Size = UDim2.new(1, 0, 1, 0)
lowHpVignette.Position = UDim2.new(0, 0, 0, 0)
lowHpVignette.BackgroundColor3 = Color3.fromRGB(200, 25, 25)
lowHpVignette.BackgroundTransparency = 1
lowHpVignette.BorderSizePixel = 0
lowHpVignette.ZIndex = 8              -- above the scene, below GameOver / overlays / HUD text
lowHpVignette.Visible = false
lowHpVignette.Active = false
local _oldGrad = lowHpVignette:FindFirstChildOfClass("UIGradient")
if _oldGrad then _oldGrad:Destroy() end   -- drop the old edge-band gradient if present
local lowHpActive = false   -- set by updateUI, pulsed by RenderStepped

-- Persistent name+level plate for each enemy block. One tight line just ABOVE
-- the block (the HP bar takes the spot under it, mirroring the hero).
local function ensureNameTag(slot)
    local tag = slot:FindFirstChild("NameTag")
    if tag and tag:GetAttribute("v") ~= NAMETAG_VERSION then tag:Destroy() ; tag = nil end
    if not tag then
        tag = Instance.new("TextLabel")
        tag.Name = "NameTag"
        tag:SetAttribute("v", NAMETAG_VERSION)
        tag.BackgroundTransparency = 1
        tag.BorderSizePixel = 0
        tag.Font = Enum.Font.GothamBold
        tag.TextScaled = false
        tag.TextSize = 14
        tag.TextWrapped = false
        tag.TextTruncate = Enum.TextTruncate.AtEnd
        tag.TextYAlignment = Enum.TextYAlignment.Bottom
        tag.TextStrokeTransparency = 0.3
        tag.AnchorPoint = Vector2.new(0.5, 1)
        tag.Size = UDim2.new(3.2, 0, 0.30, 0)
        tag.Position = UDim2.new(0.5, 0, 0.62, 0)   -- just above the ground-standing sprite
        tag.ZIndex = 6
        tag.Parent = slot
    end
    return tag
end

local function updateScene(data)
    local encs = data.encounters or {}
    local slots = { enemyStep1, enemyStep2 }

    -- Facing follows the last real travel direction (sticky): a reversal flips the
    -- hero / enemy / pet sprites even though combat clears data.moveDir the instant
    -- an encounter starts on a step edge. Enemy LAYOUT still only changes on a
    -- crossing (enc positions come from enc.rel), so nothing reshuffles mid-step.
    local stepKey = math.floor(data.pos or 0)
    local crossed = (stepKey ~= sceneLastStepKey)
    if data.moveDir == "left" or data.moveDir == "right" then
        sceneFacing = data.moveDir
    end
    if crossed then
        if sceneLastStepKey ~= nil then playStepTransition(data.moveDir == "left") end   -- real crossing, not spawn
        sceneLastStepKey = stepKey
    end

    local back = (sceneFacing == "left")
    -- Edge portals removed; the step crossing wipe is the only boundary cue.
    redPortal.Visible = false
    bluePortal.Visible = false

    local activeIndex, activeFrac
    for i, e in ipairs(encs) do if e and e.active then activeIndex = i end end
    for i, slot in ipairs(slots) do
        local enc = encs[i]
        local tag = slot and ensureNameTag(slot)
        if slot and enc then
            local frac = enc.rel or ENC_FRAC[i] or (i == 1 and 0.5 or 0.95)
            slot.Visible = not enc.cleared
            slot.Position = UDim2.new(stepXtoScreen(frac), 0, SCENE_Y, 0)
            if enc.active then activeFrac = frac end
            local lbl = slot:FindFirstChild("EnemyLabel")
            if lbl then
                lbl.Text = (enc.kind == "boss") and "[ BOSS ]" or "[ ENNEMI ]"
                lbl.TextColor3 = enc.active and Color3.fromRGB(255, 110, 110)
                    or (enc.kind == "boss") and Color3.fromRGB(255, 180, 90)
                    or Color3.fromRGB(225, 225, 225)
            end
            local sk = slot:FindFirstChildWhichIsA("UIStroke")
            if sk then sk.Color = enc.active and Color3.fromRGB(255, 80, 80) or Color3.new(1, 1, 1) end
            -- Enemy faces the hero: forward -> hero on its left -> enemy faces left.
            paintCombatant(slot, enc.id, back, enc.active, enc.kind == "boss")
            if tag then
                -- Keep the scene readable: the right card identifies the current
                -- target, while queued enemies remain visible without stacked text.
                tag.Visible = enc.active and not enc.cleared
                tag.Text = string.format("%s  \u{00B7}  Lv.%d", enc.name or "???", enc.level or 0)
                tag.TextColor3 = difficultyColour(data, enc.hp, enc.atk, enc.magic)
                -- The boss sprite is BOSS_SPRITE_MUL taller; lift its plate by the
                -- extra height so it clears the head like a mob's, not the chest.
                local rise = (enc.kind == "boss") and (BASE_SPRITE_H * (BOSS_SPRITE_MUL - 1)) or 0
                tag.Position = UDim2.new(0.5, 0, 0.62 - rise, 0)
            end
        elseif slot then
            slot.Visible = false
            if tag then tag.Visible = false end
        end
    end

    -- The single floating name is superseded by the per-enemy plates.
    if enemyName then enemyName.Visible = false end
    if enemyHpPanel then enemyHpPanel.Visible = false end

    -- Hero X = his real step progress on the SAME scale as the mobs -> he is
    -- already where the fight is when it starts. Never a dash.
    local p = math.clamp(data.posRelStep or 0, 0, 1)
    heroTargetX = stepXtoScreen(p)
    if activeIndex then
        local ex = stepXtoScreen(activeFrac or 0.5)
        enemyHpTargetX = ex
        heroTargetX = ex + (back and FIGHT_NUDGE or -FIGHT_NUDGE)
    elseif data.moveDir == "left" and (data.pos or 0) <= 0.02 then
        heroTargetX = WALL_LEAN   -- grinding the km-0 wall: lean a touch further left
    end
    if crossed and heroSlot then
        heroSlot.Position = UDim2.new(heroTargetX, 0, SCENE_Y, 0)
    end
end

--===== Zone track (compact progress line to the end of the zone) =====
local zoneTrack   = background:FindFirstChild("ZoneTrack") or combatZone:FindFirstChild("ZoneTrack")
local ztLabel     = zoneTrack and zoneTrack:FindFirstChild("Label")
local ztRail      = zoneTrack and zoneTrack:FindFirstChild("Rail")
local ztDot       = ztRail and ztRail:FindFirstChild("Dot")
local ztTicks     = {}
if ztRail then
    for i = 1, 10 do
        local tick = ztRail:FindFirstChild("Tick" .. i)
        ztTicks[i] = tick
        if tick then
            -- B6c: evenly space the 10 ticks by code (the hand-placed 9/10 gap
            -- was wrong). Set once, not per frame; keep Size / AnchorPoint.
            tick.Position = UDim2.new((i - 1) / 10, 0, 0.5, 0)
        end
    end
end

local function updateZoneTrack(data)
    if not zoneTrack then return end
    if ztLabel then
        local z = ZoneConfig.getZone(data.zone or 1)
        ztLabel.Text = string.format("COUCHE %d - %s  \u{00B7}  ETAPE %d/%d",
            data.zone or 1, (z and z.name) or "?", data.stepIndex or 1, data.stepsPerZone or 10)
    end
    if ztDot then
        ztDot.Position = UDim2.new(math.clamp(data.posRelZone or 0, 0, 1), 0, 0.5, 0)
        ztDot.BackgroundColor3 = data.isMoving and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(120, 200, 120)
    end
    local step = data.stepIndex or 1
    for i, tick in ipairs(ztTicks) do
        if tick then
            tick.BackgroundColor3 =
                (i < step) and Color3.fromRGB(70, 120, 70)      -- passed
                or (i == step) and Color3.fromRGB(120, 255, 120) -- current
                or Color3.fromRGB(110, 110, 110)                 -- ahead
        end
    end
    if artifactProgressText then
        local z = ZoneConfig.getZone(data.zone or 1)
        artifactProgressText.Text = string.format("COUCHE %d - %s  ·  ETAPE %d/%d  ·  PROCHAIN : BOSS",
            data.zone or 1, (z and string.upper(z.name)) or "?", data.stepIndex or 1, data.stepsPerZone or 10)
    end
    if artifactProgressFill then
        artifactProgressFill.Size = UDim2.new(math.clamp(data.posRelZone or 0, 0, 1), 0, 1, 0)
    end
end

--===== Top HUD (deaths / zone progress / distance+speed) =====
local topSection = background:FindFirstChild("TopSection")
local topDeath = topSection and topSection:FindFirstChild("DeathBox") and topSection.DeathBox:FindFirstChild("Label")
local topRight = topSection and topSection:FindFirstChild("RightBox") and topSection.RightBox:FindFirstChild("Label")

local function updateTopHud(data)
    if topDeath then topDeath.Text = string.format("\u{1F480} %d", data.deaths or 0) end
    if topRight then topRight.Text = string.format("%.1f KM", data.pos or 0) end
    if artifactTopDeaths then
        artifactTopDeaths.Text = ""
    end
    if artifactTopCenter then
        artifactTopCenter.Text = string.format("☠  %d   \u{00B7}   COUCHE %d   \u{00B7}   %.1f KM",
            data.deaths or 0, data.zone or 1, data.pos or 0)
    end
    if artifactTopEnemy then
        local inFight = false
        for _, e in ipairs(data.encounters or {}) do
            if e and e.active then inFight = true break end
        end
        artifactTopEnemy.Text = (inFight and data.enemyName)
            and string.format("%s  \u{00B7}  NIV.%d", data.enemyName, data.enemyLevel or 1)
            or ""
    end
end

-- Scroll state tracking
local scrollProgress = 0
local isMovingState  = true
local moveDirState   = nil
local currentZone    = 1
local stepInZone     = 0
local stepsPerZone   = 50
local SCROLL_SCALE   = 0.02  -- near layer scroll speed per step

-- Stat panel references
local heroStatsBox       = heroPanel:FindFirstChild("HeroStatsBox")
local availablePointsLabel = heroStatsBox and heroStatsBox:FindFirstChild("AvailablePoints")

-- Stat allocation buttons. Wired HERE (early) so the first click after joining
-- isn't lost while the rest of this long script is still executing.
for _, statName in ipairs({ "POW", "INT", "VIT", "SPD", "LUK" }) do
    local btn = heroStatsBox and heroStatsBox:FindFirstChild("Btn" .. statName)
    if btn then
        btn.MouseButton1Click:Connect(function()
            combatEvent:FireServer({ type = "allocateStat", stat = statName })
        end)
    end
end

-- Game Over window references
local gameOverWindow    = background:FindFirstChild("GameOverWindow")
local gameOverDistText  = gameOverWindow and gameOverWindow:FindFirstChild("DistanceText")
local restartButton     = gameOverWindow and gameOverWindow:FindFirstChild("RestartButton")

--===== Helpers =====
local function formatNumber(n)
    n = math.floor(n)
    if n >= 1e12 then return string.format("%.1fT", n / 1e12)
    elseif n >= 1e9 then return string.format("%.1fMd", n / 1e9)
    elseif n >= 1e6 then return string.format("%.1fM", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
    else return tostring(n) end
end

--===== UI update from server data =====
local function updateUI(data)
    -- Player HP bar: fill + colour (green > 50%, yellow > 20%, red below).
    local playerRatio = math.clamp(data.playerHp / math.max(1, data.playerMaxHp), 0, 1)
    playerHpFill.Size = UDim2.new(playerRatio, -4, 1, -4)
    playerHpFill.BackgroundColor3 =
        (playerRatio <= 0.20) and Color3.fromRGB(220, 60, 60)
        or (playerRatio <= 0.50) and Color3.fromRGB(230, 200, 60)
        or Color3.fromRGB(80, 210, 90)
    playerHpText.Text = string.format("%d/%d", data.playerHp, data.playerMaxHp)
    if artifactHeroHpText then artifactHeroHpText.Text = string.format("%d/%d", data.playerHp, data.playerMaxHp) end
    if artifactHeroHpFill then artifactHeroHpFill.Size = UDim2.new(playerRatio, 0, 1, 0) end
    lowHpActive = (data.playerHp or 0) > 0 and playerRatio <= 0.20 and not (data.gameOver == true)

    local inFight = false
    for _, e in ipairs(data.encounters or {}) do
        if e and e.active then inFight = true break end
    end

    -- Enemy HP bar + name
    local enemyRatio = math.clamp(data.enemyHp / math.max(1, data.enemyMaxHp), 0, 1)
    enemyHpFill.Size = UDim2.new(enemyRatio, 0, 1, 0)
    enemyHpText.Text = string.format("%d/%d", data.enemyHp, data.enemyMaxHp)
    enemyName.Text = string.format("%s Lv.%d", data.enemyName, data.enemyLevel)
    if artifactEnemyHpText then artifactEnemyHpText.Text = string.format("%d/%d", data.enemyHp, data.enemyMaxHp) end
    if artifactEnemyHpFill then artifactEnemyHpFill.Size = UDim2.new(enemyRatio, 0, 1, 0) end

    -- Hero panel: LV (+ Rebirth count) + XP, then HP, then the 3 equipment lines.
    local rbTag = (data.rebirths and data.rebirths > 0) and string.format("  R%d", data.rebirths) or ""
    heroLevel.Text  = string.format("LV: %d%s   XP: %d/%d", data.playerLevel, rbTag, data.playerExp or 0, data.playerExpToNext or 0)
    if heroPvLine then
        heroPvLine.Text = string.format("PV: %d / %d", data.playerHp or 0, data.playerMaxHp or 0)
    end
    heroWeapon.Text = string.format("Arme: %s", data.equipWeapon or "—")
    heroArmor.Text  = string.format("Armr: %s", data.equipArmor or "—")
    if heroPet then
        heroPet.Text = string.format("Pet: %s", data.equipPet or "—")
    end
    if artifactHeroLevelCard then
        artifactHeroLevelCard.Text = string.format("  LV %d%s", data.playerLevel or 1, rbTag)
    end
    if artifactHeroXpText and artifactHeroXpFill then
        local currentXp = math.max(0, data.playerExp or 0)
        local neededXp = math.max(1, data.playerExpToNext or 1)
        local xpRatio = math.clamp(currentXp / neededXp, 0, 1)
        artifactHeroXpFill.Size = UDim2.new(xpRatio, 0, 1, 0)
        artifactHeroXpText.Text = string.format("XP %s / %s  -  %.1f%%",
            formatNumber(currentXp), formatNumber(neededXp), xpRatio * 100)
    end
    if artifactHeroWeaponCard then artifactHeroWeaponCard.Text = string.format("  Arme  %s", data.equipWeapon or "—") end
    if artifactHeroArmorCard then artifactHeroArmorCard.Text = string.format("  Armr  %s", data.equipArmor or "—") end
    if artifactHeroPetCard then artifactHeroPetCard.Text = string.format("  Pets  %s", data.equipPet or "—") end
    if artifactHeroStatsCard then
        artifactHeroStatsCard.Text = string.format("  ATK %s  ·  DEF %s\n  RES %s  ·  CRIT %.1f%%",
            formatNumber(data.playerAtk or 0), formatNumber(data.playerDef or 0), formatNumber(data.playerRes or 0),
            math.min(100, (data.statLuk or 0) / 25))
    end

    -- Pet sprite is painted just below, beside the hero (needs the fresh facing).

    -- Stats display in HeroStatsBox
    if availablePointsLabel then
        local def, res = math.floor(data.playerDef or 0), math.floor(data.playerRes or 0)
        local arm = (def > 0 or res > 0) and string.format("   ARM  DEF %d \u{00B7} RES %d", def, res) or ""
        availablePointsLabel.Text = string.format("PTS: %d%s", data.statPoints or 0, arm)
    end
    if heroStatsBox then
        local statFields = {
            POW = data.statPow or 0,
            INT = data.statInt or 0,
            VIT = data.statVit or 0,
            SPD = data.statSpd or 0,
            LUK = data.statLuk or 0,
        }
        for statName, value in pairs(statFields) do
            local label = heroStatsBox:FindFirstChild("Stat" .. statName)
            if label then
                -- "(+n)" = equipment contribution converted to points of that stat.
                local gear = 0
                if statName == "VIT" then gear = data.gearHpPoints or 0
                elseif statName == "POW" and not data.gearIsMagic then gear = data.gearAtkPoints or 0
                elseif statName == "INT" and data.gearIsMagic then gear = data.gearAtkPoints or 0 end
                label.Text = (gear > 0)
                    and string.format("%s: %d (+%d)", statName, value, gear)
                    or  string.format("%s: %d", statName, value)
            end
        end
        -- SPD is capped (spdMax) and each 10th point costs 2x: reflect on its row + button.
        local spdLabel = heroStatsBox:FindFirstChild("StatSPD")
        local spdBtn   = heroStatsBox:FindFirstChild("BtnSPD")
        if spdLabel then
            spdLabel.Text = data.spdAtMax
                and string.format("SPD: %d (MAX)", data.statSpd or 0)
                or  string.format("SPD: %d", data.statSpd or 0)
        end
        if spdBtn then
            if data.spdAtMax then
                spdBtn.Text = "MAX"
                spdBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
            else
                local c = data.spdNextCost or 1
                spdBtn.Text = (c > 1) and string.format("[+%d]", c) or "[+]"
                spdBtn.TextColor3 = ((data.statPoints or 0) >= c)
                    and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            end
        end
    end

    -- Gold
    goldText.Text = string.format("G  %s", formatNumber(data.gold))
    if artifactHeroGoldCard then
        artifactHeroGoldCard.Text = string.format("OR  %s", formatNumber(data.gold or 0))
    end

    -- Rebirth button: icone seule (assets/images/rebirthicon, fond detoure),
    -- centree. Pas de texte. Attenuee quand le rebirth n'est pas payable.
    if rebirthButton then
        local ic = rebirthButton:FindFirstChild("Icon")
        if ic then ic.ImageTransparency = data.canRebirth and 0 or 0.5 end
    end

    -- Enemy info panel: only populated during an actual fight (no default mob).
    local infoAtk  = enemyInfoBox:FindFirstChild("InfoAtk")
    local infoInt  = enemyInfoBox:FindFirstChild("InfoInt")
    local infoType = enemyInfoBox:FindFirstChild("InfoType")
    if not inFight then
        infoName.Text  = data.isMoving and "Exploration..." or "\u{2014}"
        infoName.TextColor3 = Color3.fromRGB(180, 180, 185)
        infoLevel.Text = ""
        infoMaxHp.Text = ""
        infoExp.Text   = ""
        if infoAtk  then infoAtk.Text  = "" end
        if infoInt  then infoInt.Text  = "" end
        if infoType then infoType.Text = "" end
        if artifactEnemyHpLabel then artifactEnemyHpLabel.Visible = false end
        if artifactEnemyHpText then artifactEnemyHpText.Visible = false end
        if artifactEnemyHpFill and artifactEnemyHpFill.Parent then artifactEnemyHpFill.Parent.Visible = false end
        if artifactEnemyNameCard then artifactEnemyNameCard.Visible = false end
        if artifactEnemyPvCard then artifactEnemyPvCard.Visible = false end
        if artifactEnemyAtkCard then artifactEnemyAtkCard.Visible = false end
        if artifactEnemyGoldCard then artifactEnemyGoldCard.Visible = false end
    else
        local diffCol = difficultyColour(data, data.enemyMaxHp, data.enemyAtk, data.enemyDamageType == "magic")
        infoName.Text  = data.enemyName or "?"
        infoName.TextColor3 = diffCol
        infoLevel.Text = string.format("Lv %d", data.enemyLevel or 0)
        infoLevel.TextColor3 = diffCol
        infoMaxHp.Text = string.format("PV:  %d / %d", data.enemyHp or 0, data.enemyMaxHp or 0)
        infoExp.Text   = string.format("EXP: %d", data.enemyExp or 0)
        if artifactEnemyHpLabel then artifactEnemyHpLabel.Visible = true end
        if artifactEnemyHpText then artifactEnemyHpText.Visible = true end
        if artifactEnemyHpFill and artifactEnemyHpFill.Parent then artifactEnemyHpFill.Parent.Visible = true end
        if artifactEnemyNameCard then
            artifactEnemyNameCard.Visible = true
            artifactEnemyNameCard.Text = string.format("  %s  N%d", data.enemyName or "?", data.enemyLevel or 1)
        end
        if artifactEnemyPvCard then
            artifactEnemyPvCard.Visible = true
            artifactEnemyPvCard.Text = string.format("  PV  %d / %d", data.enemyHp or 0, data.enemyMaxHp or 0)
        end
        if artifactEnemyAtkCard then
            artifactEnemyAtkCard.Visible = true
            artifactEnemyAtkCard.Text = string.format("  ATK 100%%  ·  %s",
                (data.enemyDamageType == "magic") and "MAG." or "PHYS.")
        end
        if artifactEnemyGoldCard then
            artifactEnemyGoldCard.Visible = true
            artifactEnemyGoldCard.Text = string.format("  XP +%s  ·  OR +%s",
                formatNumber(data.enemyExp or 0), formatNumber(data.enemyGold or 0))
        end
        if data.enemyIsBoss and data.enemyAtkSplit then
            local atkPct = math.floor(data.enemyAtkSplit * 100 + 0.5)
            if infoAtk then infoAtk.Text = string.format("ATK %d%%  ·  %s", atkPct,
                (data.enemyDamageType == "magic") and "MAG." or "PHYS.") end
            if infoInt then infoInt.Text = string.format("INT: %d%%", 100 - atkPct) end
            if infoType then infoType.Text = (data.enemyDamageType == "magic") and "TYPE: MAGIQUE" or "TYPE: PHYSIQUE" end
        else
            if infoAtk then infoAtk.Text = "ATK 100%  ·  PHYS." end
            if infoInt then infoInt.Text = "INT: --" end
            if infoType then infoType.Text = "TYPE: PHYSIQUE" end
        end
    end

    -- Zone & progress info
    if zoneLabel then
        zoneLabel.Text = string.format("Zone %d", data.zone)
    end

    -- Swap decor when the zone changes.
    if data.zone ~= appliedZone then
        applyZoneDecor(data.zone)
        appliedZone = data.zone
    end

    -- Milestone decor. The 50 km rest stop is the "campfire" milestone (regen +
    -- shop combined); the shop opens via the ShopService hook. Its full-screen
    -- decor stays hidden until the real shop UI exists (later etape).
    if campfireDecor then campfireDecor.Visible = (data.milestone == "campfire") end
    if shopDecor     then shopDecor.Visible     = false end
    if bossDecor     then bossDecor.Visible     = false end   -- boss fight uses the normal scene
    if statusText then
        if data.milestone == "campfire" then
            statusText.Text = "Feu de camp"
            statusText.TextColor3 = Color3.fromRGB(255, 170, 80)
        elseif data.milestone == "boss" then
            statusText.Text = data.enemyIsBigBoss and ">>> BIG BOSS <<<" or "BOSS"
            statusText.TextColor3 = data.enemyIsBigBoss and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 90, 60)
        elseif data.isMoving then
            local boss = ZoneConfig.bossTheme(data.zone or 1)
            local remain = math.max(0, (data.zone or 1) * ZoneConfig.KM_PER_ZONE - (data.pos or 0))
            statusText.Text = string.format("-> BOSS : %s  ·  %.1f KM", boss.name, remain)
            statusText.TextColor3 = Color3.fromRGB(245, 245, 245)
        else
            statusText.Text = "Combat!"
            statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end

    -- Speed tag / fast-mode toggle
    if speedTag then
        local ws = data.worldSpeed or 1
        if data.fastModeAvailable then
            speedTag.Visible = true
            speedTag:SetAttribute("fast", data.fastMode == true)
            speedTag.Text = string.format("x2 : %s", data.fastMode and "ON" or "OFF")
        elseif ws > 1 then
            speedTag.Visible = true
            speedTag.Text = string.format("VITESSE x%.1f", ws)
        else
            speedTag.Visible = false
        end
    end

    updateScene(data)

    -- Hero + pet sprites. sceneFacing is fresh (updateScene just set it).
    local heroFaceRight = (sceneFacing ~= "left")
    paintCombatant(heroSlot, data.gearIsMagic and "hero_mage" or "hero_warrior", heroFaceRight, true, false)
    if petSprite then
        petRole = data.petRole
        local petAsset = data.petRole and spriteFor("pet_" .. data.petRole, heroFaceRight) or nil
        if petSprite.Image ~= (petAsset or "") then petSprite.Image = petAsset or "" end
        petSprite.Visible = petAsset ~= nil
    end

    updateZoneTrack(data)
    updateTopHud(data)

    -- Update scroll state
    scrollProgress = data.progress
    isMovingState  = data.isMoving
    moveDirState   = data.moveDir
    currentZone    = data.zone
    stepInZone     = data.stepInZone or 0
    stepsPerZone   = data.stepsPerZone or 50

    -- Enemy visuals are driven by updateScene (2 enemies per step, positioned).
    if enemySlot then enemySlot.Visible = false end

    -- HeroTimeBox: distance / all-time record / this-session rates (B6b: no ZONE row).
    if distValue then distValue.Text = string.format("%.1f km", data.distance or 0) end
    if recordValue then
        recordValue.Text = string.format("%.1f km", math.max(data.bestKm or 0, data.distance or 0))
    end
    do
        local xp, gold = data.exp or 0, data.gold or 0
        if lastXp then
            if xp > lastXp then xpGained += xp - lastXp end
            if gold > lastGold then goldGained += gold - lastGold end
        end
        lastXp, lastGold = xp, gold
        local mins = math.max(1 / 60, (os.clock() - sessionT0) / 60)
        if rateValue then
            rateValue.Text = string.format("%s xp  \u{00B7}  %s or",
                formatNumber(xpGained / mins), formatNumber(goldGained / mins))
        end
    end

    -- Prominent distance display in the combat zone
    if distLabelCZ then
        distLabelCZ.Text = string.format("%.1f KM", data.distance or 0)
    end

    -- Game Over state
    if data.gameOver then
        if gameOverWindow then
            gameOverWindow.Visible = true
            if gameOverDistText then
                gameOverDistText.Text = string.format("Distance: %.1f KM", data.distance or 0)
            end
        end
    else
        if gameOverWindow then
            gameOverWindow.Visible = false
        end
    end
end

--===== Floating damage numbers =====
local function createDamageNumber(target, amount, isCrit)
    local label = Instance.new("TextLabel")
    label.Font = Enum.Font.Code
    label.TextSize = isCrit and 22 or 18
    label.TextColor3 = isCrit and Color3.new(1, 0.2, 0.2) or Color3.new(1, 1, 0)
    label.Text = string.format("-%d", amount)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.ZIndex = 5

    -- Anchor the number to the ACTUAL combatant: the enemy currently being
    -- fought (its slot X) or the hero (his live slot X) - never a fixed spot.
    local xPos
    if target == "enemy" then
        xPos = enemyHpTargetX
    elseif target == "pet" then
        xPos = (heroSlot and heroSlot.Position.X.Scale or WALK_LO) - 0.10
        label.TextColor3 = Color3.fromRGB(120, 230, 255)
        label.TextSize = 13
    else
        xPos = heroSlot and heroSlot.Position.X.Scale or WALK_LO
    end
    xPos = xPos + math.random(-2, 2) / 1000
    local yPos = GROUND_Y - 0.26   -- floats up from just above the fighter's head

    label.Position = UDim2.new(xPos, 0, yPos, 0)
    label.Size = UDim2.new(0.15, 0, 0.08, 0)
    label.Parent = combatZone

    -- Animate: float up + fade out
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(label, tweenInfo, {
        Position = UDim2.new(xPos, 0, yPos - 0.15, 0),
        TextTransparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function()
        label:Destroy()
    end)
end

--===== Loot toast (GAME_SPEC.md 4.3 - rarity announced on drop) =====
local RARITY_COLOR = {
    commun     = Color3.fromRGB(200, 200, 200),
    rare       = Color3.fromRGB(90, 160, 255),
    epique     = Color3.fromRGB(190, 110, 255),
    legendaire = Color3.fromRGB(255, 170, 60),
    mythique   = Color3.fromRGB(255, 70, 70),
}
local RARITY_NAME = {
    commun = "COMMUN", rare = "RARE", epique = "EPIQUE",
    legendaire = "LEGENDAIRE", mythique = "MYTHIQUE",
}
local lootToastY = 0
local function showLootToast(item, fromBoss)
    local col = RARITY_COLOR[item.rarete] or RARITY_COLOR.commun
    local label = Instance.new("TextLabel")
    label.Font = Enum.Font.Code
    label.TextSize = 16
    label.TextColor3 = col
    label.TextStrokeTransparency = 0.3
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.ZIndex = 8
    label.Text = string.format("%s %s%s", (item.slot == "pet" and "PET" or (RARITY_NAME[item.rarete] or "?")),
        item.nom or item.id or "?", fromBoss and "  (boss)" or "")
    lootToastY = (lootToastY + 1) % 5
    label.Position = UDim2.new(0.30, 0, 0.30 + lootToastY * 0.05, 0)
    label.Size = UDim2.new(0.68, 0, 0.05, 0)
    label.Parent = combatZone
    local tween = TweenService:Create(label, TweenInfo.new(2.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.30, 0, 0.30 + lootToastY * 0.05 - 0.12, 0),
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function() label:Destroy() end)
end

--===== Event handler =====
local function triggerCombatantAnimation(target)
    local deadline = tick() + 0.24
    if target == "enemy" then
        heroAttackUntil = deadline
    elseif target == "player" then
        enemyAttackUntil = deadline
    end
end

combatEvent.OnClientEvent:Connect(function(data)
    if data.type == "update" then
        updateUI(data)
    elseif data.type == "damage" then
        createDamageNumber(data.target, data.amount, data.isCrit)
        triggerCombatantAnimation(data.target)
        if data.target == "enemy" or data.target == "pet" then
            petLungeUntil = tick() + 0.16
        end
    elseif data.type == "loot" and data.item then
        showLootToast(data.item, data.fromBoss)
    elseif data.type == "rebirthDone" then
        if statusText then
            statusText.Text = string.format("REBIRTH %d !", data.rebirths or 0)
            statusText.TextColor3 = Color3.fromRGB(120, 255, 120)
        end
    elseif data.type == "rebirthDenied" then
        if statusText then
            statusText.Text = string.format("Rebirth : %s or requis", formatNumber(data.cost or 0))
            statusText.TextColor3 = Color3.fromRGB(255, 120, 120)
        end
    elseif data.type == "gameOver" then
        if gameOverWindow then
            gameOverWindow.Visible = true
            if gameOverDistText then
                gameOverDistText.Text = string.format("Distance: %.1f KM", data.distance or 0)
            end
        end
    end
end)

--===== Campfire choices =====
if campfireContinueBtn then
    campfireContinueBtn.MouseButton1Click:Connect(function()
        combatEvent:FireServer({ type = "campfireContinue" })
    end)
end
if campfireStayBtn then
    campfireStayBtn.MouseButton1Click:Connect(function()
        -- RESTER : la regeneration serveur continue d'elle-meme, rien a envoyer.
    end)
end

--===== Game Over buttons =====
if restartButton then
    restartButton.MouseButton1Click:Connect(function()
        combatEvent:FireServer({type = "restart"})
    end)
end

--===== Rebirth button (GAME_SPEC.md 8.1) =====
if rebirthButton then
    rebirthButton.MouseButton1Click:Connect(function()
        combatEvent:FireServer({ type = "rebirth" })
    end)
end


--===== Equipment overlay (GAME_SPEC.md 1.1 selectors / 1.2 inventory) =====
local equipOverlay = background:FindFirstChild("EquipOverlay")
if equipOverlay then
    local itemList   = equipOverlay:FindFirstChild("ItemList")
    local rowTemplate = equipOverlay:FindFirstChild("RowTemplate")
    local tabs       = equipOverlay:FindFirstChild("Tabs")
    local closeBtn   = equipOverlay:FindFirstChild("CloseBtn")
    local titleLbl   = equipOverlay:FindFirstChild("Title")
    local summaryLbl = equipOverlay:FindFirstChild("Summary")
    local filterBar  = equipOverlay:FindFirstChild("FilterBar")
    local SLOT_LABELS = { arme = "ARME", casque = "CASQUE", plastron = "PLASTRON",
        jambieres = "JAMBIERES", bottes = "BOTTES", pet = "PET" }
    local RAR_CYCLE = { "commun", "rare", "epique", "legendaire", "mythique" }
    local RAR_SHORT = { commun = "TOUT", rare = "RARE+", epique = "EPIQUE+", legendaire = "LEGEND+", mythique = "MYTH" }
    local currentSlot = "arme"
    local cache = {}  -- slot -> item list
    local invFilters = { rareteMin = "commun", guerrier = true, mage = true }

    local function refreshFilterBar()
        if not filterBar then return end
        local fr = filterBar:FindFirstChild("FilterRarete")
        local fg = filterBar:FindFirstChild("FilterGuerrier")
        local fm = filterBar:FindFirstChild("FilterMage")
        if fr then fr.Text = "RAR: " .. (RAR_SHORT[invFilters.rareteMin] or "TOUT") end
        if fg then
            fg.Text = "GUERRIER: " .. (invFilters.guerrier and "ON" or "OFF")
            fg.TextColor3 = invFilters.guerrier and Color3.fromRGB(255, 220, 120) or Color3.fromRGB(120, 120, 120)
        end
        if fm then
            fm.Text = "MAGE: " .. (invFilters.mage and "ON" or "OFF")
            fm.TextColor3 = invFilters.mage and Color3.fromRGB(255, 220, 120) or Color3.fromRGB(120, 120, 120)
        end
    end

    local function renderList(slot)
        currentSlot = slot
        if titleLbl then titleLbl.Text = "EQUIPEMENT - " .. (SLOT_LABELS[slot] or slot) end
        for _, c in ipairs(itemList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local items = cache[slot] or {}
        if #items == 0 then
            local empty = rowTemplate:Clone()
            empty.Name = "Row" ; empty.Visible = true ; empty.Parent = itemList
            empty.Info.Text = "  (aucun objet pour cet emplacement)"
            empty.EquipBtn.Visible = false
            if empty:FindFirstChild("FuseBtn") then empty.FuseBtn.Visible = false end
            return
        end
        for _, it in ipairs(items) do
            local r = rowTemplate:Clone()
            r.Name = "Row" ; r.Visible = true ; r.Parent = itemList
            local powTxt = (slot == "pet") and "" or ("  pw " .. tostring(it.power))
            local qty = (it.count and it.count > 1) and ("  x" .. it.count) or ""
            local lockTxt = it.locked and "  [V]" or ""
            r.Info.Text = string.format("  %s%s%s\n  %s . Z%d%s", it.nom, qty, lockTxt,
                it.rareteLabel or it.rarete, it.zone or 1, powTxt)
            if it.equipped then
                r.EquipBtn.Text = "EQUIPE"
                r.EquipBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            else
                r.EquipBtn.Text = "EQUIPER"
                r.EquipBtn.TextColor3 = Color3.fromRGB(120, 255, 120)
                r.EquipBtn.MouseButton1Click:Connect(function()
                    combatEvent:FireServer({ type = "equipItem", slot = slot,
                        id = it.id, rarete = it.rarete, zone = it.zone })
                end)
            end
            local fuseBtn = r:FindFirstChild("FuseBtn")
            if fuseBtn then
                fuseBtn.Visible = it.fuseReady == true
                if it.fuseReady then
                    fuseBtn.MouseButton1Click:Connect(function()
                        combatEvent:FireServer({ type = "fuseItem", slot = slot,
                            id = it.id, rarete = it.rarete, zone = it.zone })
                    end)
                end
            end
        end
    end

    local function openOverlay(slot)
        equipOverlay.Visible = true
        combatEvent:FireServer({ type = "requestInventory" })
        renderList(slot or currentSlot)
    end

    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function() equipOverlay.Visible = false end)
    end
    if tabs then
        for _, tb in ipairs(tabs:GetChildren()) do
            if tb:IsA("TextButton") then
                local slot = tb.Name:gsub("^Tab_", "")
                tb.MouseButton1Click:Connect(function() renderList(slot) end)
            end
        end
    end
    if filterBar then
        local fr = filterBar:FindFirstChild("FilterRarete")
        local fg = filterBar:FindFirstChild("FilterGuerrier")
        local fm = filterBar:FindFirstChild("FilterMage")
        if fr then fr.MouseButton1Click:Connect(function()
            local i = (table.find(RAR_CYCLE, invFilters.rareteMin) or 1) % #RAR_CYCLE + 1
            combatEvent:FireServer({ type = "setFilters", rareteMin = RAR_CYCLE[i] })
        end) end
        if fg then fg.MouseButton1Click:Connect(function()
            combatEvent:FireServer({ type = "setFilters", guerrier = not invFilters.guerrier })
        end) end
        if fm then fm.MouseButton1Click:Connect(function()
            combatEvent:FireServer({ type = "setFilters", mage = not invFilters.mage })
        end) end
    end

    -- Hero-panel line clicks (transparent ClickBtn added to each label).
    local function wireLine(label, slot)
        local b = label and label:FindFirstChild("ClickBtn")
        if b then b.MouseButton1Click:Connect(function() openOverlay(slot) end) end
    end
    wireLine(heroWeapon, "arme")
    wireLine(heroArmor, "casque")
    wireLine(heroPet, "pet")

    -- Server pushes inventory (on request + after any change).
    combatEvent.OnClientEvent:Connect(function(data)
        if type(data) ~= "table" or data.type ~= "inventory" then return end
        if data.slots then
            for slot, list in pairs(data.slots) do cache[slot] = list end
        end
        if data.summary and summaryLbl then
            summaryLbl.Text = string.format("INV %d/%d", data.summary.used or 0, data.summary.max or 100)
        end
        if data.filters then
            invFilters = data.filters
            refreshFilterBar()
            -- a filter change can affect which items exist: re-request the open slot
            if equipOverlay.Visible then
                combatEvent:FireServer({ type = "requestInventory", slot = currentSlot })
            end
        end
        if equipOverlay.Visible and cache[currentSlot] then
            renderList(currentSlot)
        end
    end)
end

--===== Castle overlay (GAME_SPEC.md 1.3 / 8) =====
local chateauOverlay = background:FindFirstChild("ChateauOverlay")
if chateauOverlay then
    local menuBtn   = artifactMenuButton or (menuPanel and menuPanel:FindFirstChild("MenuButton"))
    local cClose    = chateauOverlay:FindFirstChild("CloseBtn")
    local cpList    = chateauOverlay:FindFirstChild("CheckpointList")
    local cpTmpl    = chateauOverlay:FindFirstChild("CpTemplate")
    local rPanel    = chateauOverlay:FindFirstChild("RebirthPanel")
    local rInfo     = rPanel and rPanel:FindFirstChild("Info")
    local doRebirth = rPanel and rPanel:FindFirstChild("DoRebirthBtn")
    local cState = { maxKm = 0, selected = 0, rebirths = 0, cost = 10000, canRebirth = false, dmg = 0, xp = 0 }

    local function renderCastle()
        chateauOverlay.Title.Text = string.format("CHATEAU  -  max %d km", cState.maxKm)
        if rInfo then
            rInfo.Text = string.format("REBIRTH R%d\nBonus actuel : +%d%% efficacite skills, +%d%% XP\nProchain : R%d pour %s or",
                cState.rebirths, cState.dmg, cState.xp, cState.rebirths + 1, formatNumber(cState.cost))
        end
        if doRebirth then
            doRebirth.TextColor3 = cState.canRebirth and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(120, 120, 120)
        end
        for _, c in ipairs(cpList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for km = 0, cState.maxKm, 10 do
            local b = cpTmpl:Clone()
            b.Name = "Cp" .. km ; b.Visible = true ; b.Parent = cpList
            b.Text = (km == 0) and "DEPART" or ("km " .. km)
            local isSel = (km == cState.selected)
            b.BackgroundColor3 = isSel and Color3.fromRGB(40, 70, 40) or Color3.new(0, 0, 0)
            b.TextColor3 = isSel and Color3.fromRGB(150, 255, 150) or Color3.new(1, 1, 1)
            b.MouseButton1Click:Connect(function()
                combatEvent:FireServer({ type = "setCheckpoint", km = km })
            end)
        end
    end

    if menuBtn then
        menuBtn.MouseButton1Click:Connect(function()
            chateauOverlay.Visible = not chateauOverlay.Visible
            if chateauOverlay.Visible then renderCastle() end
        end)
    end
    if cClose then cClose.MouseButton1Click:Connect(function() chateauOverlay.Visible = false end) end
    if doRebirth then doRebirth.MouseButton1Click:Connect(function() combatEvent:FireServer({ type = "rebirth" }) end) end

    combatEvent.OnClientEvent:Connect(function(data)
        if type(data) ~= "table" or data.type ~= "update" then return end
        cState.maxKm      = data.checkpointMaxKm or 0
        cState.selected   = data.selectedCheckpoint or 0
        cState.rebirths   = data.rebirths or 0
        cState.cost       = data.rebirthCost or 10000
        cState.canRebirth = data.canRebirth or false
        cState.dmg        = data.rebirthSkillPct or 0
        cState.xp         = data.rebirthXpBonus or 0
        if chateauOverlay.Visible then renderCastle() end
    end)
end

--===== Shop overlay (GAME_SPEC.md 7.4) =====
local shopOverlay = background:FindFirstChild("ShopOverlay")
local shopEvent = ReplicatedStorage:FindFirstChild("ShopEvent")
if shopOverlay then
    local sList     = shopOverlay:FindFirstChild("ItemList")
    local sRowTmpl  = shopOverlay:FindFirstChild("RowTemplate")
    local sClose    = shopOverlay:FindFirstChild("CloseBtn")
    local sGoldLbl  = shopOverlay:FindFirstChild("GoldText")
    local sTitle    = shopOverlay:FindFirstChild("Title")
    local shopStock = {}
    local playerGold = 0

    local RAR_LABEL = { commun = "Commun", rare = "Rare", epique = "Epique", legendaire = "Legendaire", mythique = "Mythique" }
    local SLOT_LABEL = { arme = "Arme", casque = "Casque", plastron = "Plastron", jambieres = "Jambieres", bottes = "Bottes" }

    local function renderShop()
        for _, c in ipairs(sList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        if sGoldLbl then sGoldLbl.Text = "G " .. formatNumber(playerGold) end
        if #shopStock == 0 then
            local r = sRowTmpl:Clone()
            r.Name = "Row" ; r.Visible = true ; r.Parent = sList
            r.Info.Text = "  (rien en vente ici)" ; r.BuyBtn.Visible = false
            return
        end
        for _, it in ipairs(shopStock) do
            local r = sRowTmpl:Clone()
            r.Name = "Row" ; r.Visible = true ; r.Parent = sList
            r.Info.Text = string.format("  %s\n  %s . %s . %s . Z%d",
                it.nom, SLOT_LABEL[it.slot] or it.slot, it.voie or "?",
                RAR_LABEL[it.rarete] or it.rarete, it.zone or 1)
            local afford = playerGold >= (it.price or 0)
            r.BuyBtn.Text = formatNumber(it.price or 0) .. " or"
            r.BuyBtn.TextColor3 = afford and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(140, 140, 140)
            r.BuyBtn.MouseButton1Click:Connect(function()
                combatEvent:FireServer({ type = "buyEquipment", itemId = it.id, rarete = it.rarete, slot = it.slot })
            end)
        end
    end

    if sClose then
        sClose.MouseButton1Click:Connect(function() shopOverlay.Visible = false end)
    end

    -- Server opens the shop (campfire milestone) -> stock arrives here.
    if shopEvent then
        shopEvent.OnClientEvent:Connect(function(payload)
            if type(payload) ~= "table" then return end
            if payload.type == "open" and payload.equipment then
                shopStock = payload.equipment
                if sTitle then sTitle.Text = string.format("BOUTIQUE - Zone %d", payload.zone or 1) end
                if shopOverlay.Visible then renderShop() end
            end
        end)
    end

    -- "BOUTIQUE" button on the campfire.
    local shopBtn = combatZone:FindFirstChild("MilestoneDecor")
        and combatZone.MilestoneDecor:FindFirstChild("Campfire")
        and combatZone.MilestoneDecor.Campfire:FindFirstChild("Choices")
        and combatZone.MilestoneDecor.Campfire.Choices:FindFirstChild("ShopBtn")
    if shopBtn then
        shopBtn.MouseButton1Click:Connect(function()
            shopOverlay.Visible = true
            renderShop()
        end)
    end

    -- Keep gold current + re-render on purchase / error.
    combatEvent.OnClientEvent:Connect(function(data)
        if type(data) ~= "table" then return end
        if data.type == "update" and data.gold ~= nil then
            playerGold = data.gold
            if shopOverlay.Visible then renderShop() end
        elseif data.type == "shopError" and sTitle then
            sTitle.Text = "BOUTIQUE - " .. tostring(data.reason)
        end
    end)
end

--===== Movement (GAME_SPEC.md 2 - hold a key to walk) =====
-- LEFT  : Left arrow, Q (AZERTY), A (QWERTY)
-- RIGHT : Right arrow, D
local UserInputService = game:GetService("UserInputService")
local speedTag = combatZone:FindFirstChild("SpeedTag")
local LEFT_KEYS  = { [Enum.KeyCode.Left] = true, [Enum.KeyCode.Q] = true, [Enum.KeyCode.A] = true }
local RIGHT_KEYS = { [Enum.KeyCode.Right] = true, [Enum.KeyCode.D] = true }
local heldLeft, heldRight = false, false
local sentDir = nil
local function resolveDir()
    local dir = nil
    if heldRight and not heldLeft then dir = "right"
    elseif heldLeft and not heldRight then dir = "left" end
    if dir ~= sentDir then
        sentDir = dir
        combatEvent:FireServer({ type = "move", dir = dir or "stop" })
    end
end

-- Invisible touch halves. The tutorial teaches them; the permanent HUD stays
-- identical to the La Descente artifact with no movement arrows or labels.
local function makeTouchHalf(name, x)
    local button = combatZone:FindFirstChild(name) or Instance.new("TextButton")
    button.Name = name
    button.Position = UDim2.new(x, 0, 0, 0)
    button.Size = UDim2.fromScale(0.5, 1)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = ""
    button.ZIndex = 6
    button.Parent = combatZone
    return button
end

local function wireTouchHalf(button, isLeft)
    button.MouseButton1Down:Connect(function()
        if isLeft then heldLeft = true else heldRight = true end
        resolveDir()
    end)
    button.MouseButton1Up:Connect(function()
        if isLeft then heldLeft = false else heldRight = false end
        resolveDir()
    end)
    button.MouseLeave:Connect(function()
        if isLeft then heldLeft = false else heldRight = false end
        resolveDir()
    end)
end
wireTouchHalf(makeTouchHalf("MoveLeftTouch", 0), true)
wireTouchHalf(makeTouchHalf("MoveRightTouch", 0.5), false)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if LEFT_KEYS[input.KeyCode] then heldLeft = true ; resolveDir()
    elseif RIGHT_KEYS[input.KeyCode] then heldRight = true ; resolveDir() end
end)
UserInputService.InputEnded:Connect(function(input)
    if LEFT_KEYS[input.KeyCode] then heldLeft = false ; resolveDir()
    elseif RIGHT_KEYS[input.KeyCode] then heldRight = false ; resolveDir() end
end)
-- safety: if the window loses focus, stop.
UserInputService.WindowFocusReleased:Connect(function()
    heldLeft, heldRight = false, false ; resolveDir()
end)
if speedTag then
    speedTag.MouseButton1Click:Connect(function()
        combatEvent:FireServer({ type = "setFastMode", on = not speedTag:GetAttribute("fast") })
    end)
end

-- Combat is auto-attack only - no tap-to-attack input.

--===== Static backdrop (no parallax scroll - the HERO moves, not the decor) =====
local function pinBackdrop(layer)
    if not layer then return end
    local t0 = layer:FindFirstChild("Tile0")
    local t1 = layer:FindFirstChild("Tile1")
    if t0 then t0.Position = UDim2.new(0, 0, 0, 0) end
    if t1 then t1.Position = UDim2.new(1, 0, 0, 0) end   -- parked off-screen, unused
end
pinBackdrop(farLayer) ; pinBackdrop(midLayer) ; pinBackdrop(nearLayer)

RunService.RenderStepped:Connect(function()
    -- Hero slides toward its target x; bob + lean while moving.
    if heroSlot then
        local cur = heroSlot.Position.X.Scale
        local nx  = cur + (heroTargetX - cur) * 0.16
        local bob = isMovingState and (math.sin(tick() * 11) * 0.009) or 0
        local attackT = math.max(0, heroAttackUntil - tick())
        local attackOffset = attackT > 0 and math.sin((0.24 - attackT) / 0.24 * math.pi) * 0.055 or 0
        local faceSign = (sceneFacing == "left") and -1 or 1
        heroSlot.Position = UDim2.new(nx + faceSign * attackOffset, 0, SCENE_Y + bob, 0)
        heroSlot.Rotation = isMovingState and ((moveDirState == "left") and -4 or 4) or 0
        -- Small HP bar sits on the ground just under the hero (scaled to a sprite's width).
        if playerHpBar then
            playerHpBar.AnchorPoint = Vector2.new(0.5, 0)
            playerHpBar.Size = UDim2.new(HPBAR_W, 0, HPBAR_H, 0)
            playerHpBar.Position = UDim2.new(nx, 0, GROUND_Y + 0.02, 0)
        end
    end

    -- Enemy HP bar rides on the ground under the enemy being fought.
    if enemyHpPanel and enemyHpPanel.Visible then
        enemyHpPanel.AnchorPoint = Vector2.new(0.5, 0)
        enemyHpPanel.Size = UDim2.new(HPBAR_W, 0, HPBAR_H, 0)
        local attackT = math.max(0, enemyAttackUntil - tick())
        local attackOffset = attackT > 0 and math.sin((0.24 - attackT) / 0.24 * math.pi) * 0.045 or 0
        local faceSign = (sceneFacing == "left") and -1 or 1
        enemyHpPanel.Position = UDim2.new(enemyHpTargetX - faceSign * attackOffset, 0, GROUND_Y + 0.02, 0)
    end

    -- Low-HP red screen flash (uniform, whole screen).
    if lowHpVignette then
        if lowHpActive then
            lowHpVignette.Visible = true
            lowHpVignette.BackgroundTransparency = 0.58 + math.abs(math.sin(tick() * 7)) * 0.30
        elseif lowHpVignette.Visible then
            lowHpVignette.Visible = false
        end
    end

    -- Pet follows the hero. The TANK fairy guards the FRONT (toward the enemy);
    -- DPS / HEAL fairies hover BEHIND. All lunge toward the enemy on each hit.
    if petSprite and petSprite.Visible and heroSlot then
        local hx = heroSlot.Position.X.Scale
        local faceSign = (sceneFacing == "left") and -1 or 1   -- +1 = enemy is to the hero's right
        local sideSign = (petRole == "tank") and 1 or -1        -- +1 = front (toward enemy), -1 = behind
        local lunge = (tick() < petLungeUntil) and 0.05 or 0
        local bob = isMovingState and (math.sin(tick() * 13) * 0.010) or 0
        -- hero<->pet separation halved (0.09 -> 0.045) so the fairy hugs the hero.
        local px = math.clamp(hx + faceSign * (sideSign * 0.045 + lunge), 0.04, 0.92)
        petSprite.Position = UDim2.new(px, 0, GROUND_Y + bob, 0)
    end
end)

