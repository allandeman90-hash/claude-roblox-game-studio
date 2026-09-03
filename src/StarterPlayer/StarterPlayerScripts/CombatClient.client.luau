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
local artifactTalentsButton

-- The old prototype panels are not part of the final visual language. Keep
-- their objects alive for legacy overlay wiring, but render a brand-new HUD.
do
    -- ==== palette (matches Reference/mon ui final.png) =========================
    local BG      = Color3.fromRGB(14, 15, 19)     -- screen ground
    local BAR_BG  = Color3.fromRGB(23, 24, 29)     -- top / bottom bars, bar tracks
    local CARD_BG = Color3.fromRGB(19, 20, 25)     -- stat cards
    local LINE    = Color3.fromRGB(70, 71, 77)     -- thin dim borders (no bright white)
    local TEXT    = Color3.fromRGB(228, 224, 212)  -- values
    local LABEL   = Color3.fromRGB(120, 120, 125)  -- field labels
    local ACCENT  = Color3.fromRGB(201, 168, 120)  -- muted amber (no optical bloom)
    local XP      = Color3.fromRGB(150, 120, 214)
    local GREEN   = Color3.fromRGB(96, 176, 96)
    local RED     = Color3.fromRGB(198, 88, 78)
    local FONT    = Enum.Font.Code                  -- the reference HUD is monospace
    local ZH      = 3                               -- HUD draw layer (overlays sit at 20+)

    -- Layout bands (offset px, IgnoreGuiInset = true so the top bar is flush).
    local TOP_H, PV_H, BOT_H, GAP = 46, 15, 30, 6
    local MID_TOP = TOP_H + GAP + PV_H + GAP
    local COL_W = 0.238

    heroPanel.Visible = false
    centerPanel.Visible = false
    menuPanel.Visible = false

    gui.IgnoreGuiInset = true
    if gui:IsA("ScreenGui") then
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    end
    background.BackgroundColor3 = BG
    background.BackgroundTransparency = 0
    background.BorderSizePixel = 0
    local function fitBackgroundToViewport()
        background.Position = UDim2.fromOffset(0, 0)
        background.Size = UDim2.fromScale(1, 1)
    end
    fitBackgroundToViewport()
    local camera = workspace.CurrentCamera
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitBackgroundToViewport)
    end

    -- ---- small builders -----------------------------------------------------
    local function strip(inst) -- kill stray UIStroke / UICorner left by old builds
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("UIStroke") or d:IsA("UICorner") then d:Destroy() end
        end
    end

    -- A framed value card. Uses RichText so a grey label + light value share one line.
    local function card(parent, name, y, h, opts)
        opts = opts or {}
        local item = parent:FindFirstChild(name) or Instance.new("TextLabel")
        item.Name = name
        item.Position = UDim2.new(0, 0, y, 0)
        item.Size = UDim2.new(1, 0, h, 0)
        item.BackgroundColor3 = opts.bare and BG or CARD_BG
        item.BackgroundTransparency = opts.bare and 1 or 0
        item.BorderColor3 = LINE
        item.BorderSizePixel = opts.bare and 0 or 1
        item.Font = FONT
        item.RichText = true
        item.Text = opts.text or ""
        item.TextColor3 = opts.color or TEXT
        item.TextSize = opts.size or 14
        item.TextScaled = false
        item.TextWrapped = opts.wrap or false
        item.TextXAlignment = opts.align or Enum.TextXAlignment.Left
        item.TextYAlignment = Enum.TextYAlignment.Center
        item.TextTruncate = Enum.TextTruncate.AtEnd
        item.ZIndex = ZH
        item.Visible = true
        item.Parent = parent
        strip(item)
        local pad = item:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, opts.align == Enum.TextXAlignment.Center and 0 or 12)
        pad.PaddingRight = UDim.new(0, opts.align == Enum.TextXAlignment.Center and 0 or 10)
        pad.Parent = item
        return item
    end

    -- "TALENTS" / "MENU" style footer button (amber outline, transparent hit area).
    local function footerButton(parent, name, text, y, h)
        local b = card(parent, name, y, h, { text = text, color = ACCENT, size = 14,
            align = Enum.TextXAlignment.Center })
        b.BorderColor3 = ACCENT
        local hit = b:FindFirstChild("Click") or Instance.new("TextButton")
        hit.Name = "Click"
        hit.Size = UDim2.fromScale(1, 1)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.Active = true
        hit.AutoButtonColor = false
        hit.ZIndex = ZH + 1
        hit.Parent = b
        return b, hit
    end

    -- Labelled HP bar for the PV band: [PV] [====== track ======] [cur/max]
    local function hpBar(parent, name, color)
        local root = parent:FindFirstChild(name) or Instance.new("Frame")
        root.Name = name
        root.BackgroundTransparency = 1
        root.BorderSizePixel = 0
        root.ZIndex = ZH
        root.Parent = parent

        local lbl = root:FindFirstChild("Label") or Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.Size = UDim2.new(0, 26, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = FONT
        lbl.Text = "PV"
        lbl.TextColor3 = LABEL
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = ZH
        lbl.Parent = root

        local track = root:FindFirstChild("Track") or Instance.new("Frame")
        track.Name = "Track"
        track.Position = UDim2.new(0, 30, 0.5, -5)
        track.Size = UDim2.new(1, -84, 0, 10)
        track.BackgroundColor3 = BAR_BG
        track.BorderColor3 = LINE
        track.BorderSizePixel = 1
        track.ClipsDescendants = true
        track.ZIndex = ZH
        track.Parent = root

        local fill = track:FindFirstChild("Fill") or Instance.new("Frame")
        fill.Name = "Fill"
        fill.Position = UDim2.new(0, 0, 0, 0)
        fill.Size = UDim2.fromScale(1, 1)
        fill.BackgroundColor3 = color
        fill.BorderSizePixel = 0
        fill.ZIndex = ZH + 1
        fill.Parent = track

        local val = root:FindFirstChild("Value") or Instance.new("TextLabel")
        val.Name = "Value"
        val.AnchorPoint = Vector2.new(1, 0)
        val.Position = UDim2.new(1, 0, 0, 0)
        val.Size = UDim2.new(0, 50, 1, 0)
        val.BackgroundTransparency = 1
        val.Font = FONT
        val.Text = "0/0"
        val.TextColor3 = TEXT
        val.TextSize = 12
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.ZIndex = ZH
        val.Parent = root
        strip(root)
        return lbl, val, fill
    end

    -- ---- top bar ----------------------------------------------------------------
    local topSection = background:FindFirstChild("TopSection")
    if topSection and topSection:IsA("GuiObject") then
        topSection.Position = UDim2.new(0, 0, 0, 0)
        topSection.Size = UDim2.new(1, 0, 0, TOP_H)
        topSection.BackgroundColor3 = BAR_BG
        topSection.BackgroundTransparency = 0
        topSection.BorderColor3 = LINE
        topSection.BorderSizePixel = 1
        topSection.ZIndex = ZH
        for _, child in ipairs(topSection:GetChildren()) do
            if child:IsA("GuiObject") then child.Visible = false end
        end
        strip(topSection)

        local function topLabel(fieldName, x, w, align, colour, size)
            local l = topSection:FindFirstChild(fieldName) or Instance.new("TextLabel")
            l.Name = fieldName
            l.Position = UDim2.new(x, align == Enum.TextXAlignment.Left and 14 or 0, 0, 0)
            l.Size = UDim2.new(w, align == Enum.TextXAlignment.Left and -14 or (align == Enum.TextXAlignment.Right and -14 or 0), 1, 0)
            l.BackgroundTransparency = 1
            l.BorderSizePixel = 0
            l.Font = FONT
            l.TextColor3 = colour
            l.TextSize = size
            l.TextXAlignment = align
            l.TextYAlignment = Enum.TextYAlignment.Center
            l.ZIndex = ZH
            l.Visible = true
            l.Parent = topSection
            return l
        end

        local function topDivider(x)
            local d = topSection:FindFirstChild("Div" .. tostring(x)) or Instance.new("Frame")
            d.Name = "Div" .. tostring(x)
            d.Position = UDim2.new(x, 0, 0.2, 0)
            d.Size = UDim2.new(0, 1, 0.6, 0)
            d.BackgroundColor3 = LINE
            d.BorderSizePixel = 0
            d.ZIndex = ZH
            d.Visible = true
            d.Parent = topSection
        end

        local oldMenu = topSection:FindFirstChild("ArtifactMenu")
        if oldMenu then oldMenu:Destroy() end
        local oldDiv = topSection:FindFirstChild("Div0.16")
        if oldDiv then oldDiv:Destroy() end

        artifactTopCenter = topLabel("ArtifactCenter", 0, 0.78, Enum.TextXAlignment.Center, TEXT, 17)
        artifactTopCenter.Text = "\u{1F480} 0   \u{00B7}   Couche 1   \u{00B7}   0.0 km"
        topDivider(0.78)
        artifactTopEnemy = topLabel("ArtifactEnemy", 0.78, 0.22, Enum.TextXAlignment.Right, ACCENT, 14)
        artifactTopEnemy.Text = "EXPLORATION"
    end

    -- ---- PV band (two bars, aligned over their columns) -----------------------
    local pvBand = background:FindFirstChild("PvBand") or Instance.new("Frame")
    pvBand.Name = "PvBand"
    pvBand.Position = UDim2.new(0, 0, 0, TOP_H + GAP)
    pvBand.Size = UDim2.new(1, 0, 0, PV_H)
    pvBand.BackgroundTransparency = 1
    pvBand.BorderSizePixel = 0
    pvBand.ZIndex = ZH
    pvBand.Parent = background

    local _, heroHpVal, heroHpFill = hpBar(pvBand, "HeroHp", GREEN)
    local hh = pvBand:FindFirstChild("HeroHp")
    hh.Position = UDim2.new(0, 6, 0, 0)
    hh.Size = UDim2.new(COL_W, 0, 1, 0)
    artifactHeroHpText, artifactHeroHpFill = heroHpVal, heroHpFill

    local enemyHpLbl, enemyHpVal, enemyHpFill = hpBar(pvBand, "EnemyHp", RED)
    local eh = pvBand:FindFirstChild("EnemyHp")
    eh.Position = UDim2.new(1 - COL_W - 0.004, 0, 0, 0)
    eh.Size = UDim2.new(COL_W, 0, 1, 0)
    artifactEnemyHpLabel, artifactEnemyHpText, artifactEnemyHpFill = enemyHpLbl, enemyHpVal, enemyHpFill
    eh.Visible = false

    -- ---- middle area: left column | scene | right column ---------------------
    bottomPanel.Position = UDim2.new(0, 0, 0, MID_TOP)
    bottomPanel.Size = UDim2.new(1, 0, 1, -(MID_TOP + BOT_H + GAP))
    bottomPanel.BackgroundColor3 = BG
    bottomPanel.BackgroundTransparency = 0
    bottomPanel.BorderSizePixel = 0
    strip(bottomPanel)

    local function column(name, x)
        local frame = bottomPanel:FindFirstChild(name) or Instance.new("Frame")
        frame.Name = name
        frame.Position = UDim2.new(x, x < 0.5 and 6 or 0, 0, 0)
        frame.Size = UDim2.new(COL_W, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = false
        frame.ZIndex = ZH
        frame.Visible = true
        frame.Parent = bottomPanel
        strip(frame)
        return frame
    end
    local left = column("DescenteLeft", 0)
    local right = column("DescenteRight", 1 - COL_W - 0.004)

    combatZone.Parent = bottomPanel
    combatZone.Position = UDim2.new(COL_W + 0.012, 0, 0, 0)
    combatZone.Size = UDim2.new(1 - 2 * (COL_W + 0.012), 0, 1, 0)
    combatZone.BackgroundColor3 = Color3.fromRGB(9, 10, 13)
    combatZone.BackgroundTransparency = 0
    combatZone.BorderSizePixel = 0
    combatZone.ClipsDescendants = true
    combatZone.ZIndex = ZH
    -- the template CombatZone was reparented AFTER strip(bottomPanel); kill its
    -- own leftover UIStroke (the "white border" around the scene) here.
    strip(combatZone)

    -- slim XP bar tucked under the level card
    local function xpBar(parent, y)
        local root = parent:FindFirstChild("XpBar") or Instance.new("Frame")
        root.Name = "XpBar"
        root.Position = UDim2.new(0, 0, y, 0)
        root.Size = UDim2.new(1, 0, 0, 5)
        root.BackgroundColor3 = BAR_BG
        root.BorderColor3 = LINE
        root.BorderSizePixel = 1
        root.ClipsDescendants = true
        root.ZIndex = ZH
        root.Visible = true
        root.Parent = parent
        local fill = root:FindFirstChild("Fill") or Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.fromScale(0, 1)
        fill.BackgroundColor3 = XP
        fill.BorderSizePixel = 0
        fill.ZIndex = ZH + 1
        fill.Parent = root
        local value = parent:FindFirstChild("XpText") or Instance.new("TextLabel")
        value.Name = "XpText"
        value.Position = UDim2.new(0, 0, y, 8)
        value.Size = UDim2.new(1, 0, 0, 12)
        value.BackgroundTransparency = 1
        value.BorderSizePixel = 0
        value.Font = FONT
        value.Text = "XP 0 / 0"
        value.TextColor3 = LABEL
        value.TextSize = 11
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.ZIndex = ZH
        value.Parent = parent
        local pad = value:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 12)
        pad.Parent = value
        strip(root)
        return value, fill
    end

    -- left column: LV / XP / Arme / Armr / Pets / stat block ... TALENTS (footer)
    artifactHeroLevelCard = card(left, "LevelCard", 0.00, 0.072, { text = "LV 1" })
    artifactHeroXpText, artifactHeroXpFill = xpBar(left, 0.078)
    artifactHeroWeaponCard = card(left, "WeaponCard", 0.135, 0.072, { text = "Arme  \u{2014}" })
    artifactHeroArmorCard = card(left, "ArmorCard", 0.218, 0.072, { text = "Armr  \u{2014}" })
    artifactHeroPetCard = card(left, "PetCard", 0.301, 0.072, { text = "Pets  \u{2014}" })
    artifactHeroStatsCard = card(left, "StatsCard", 0.384, 0.12,
        { text = "ATK 0 \u{00B7} DEF 0\nRES 0 \u{00B7} CRIT 0%", wrap = true })
    _, artifactTalentsButton = footerButton(left, "Talents", "TALENTS", 0.905, 0.08)

    -- right column: enemy name / enemy PV / your OR / enemy ATK ... INVENTAIRE + MENU
    artifactEnemyNameCard = card(right, "EnemyCard", 0.00, 0.072, { text = "\u{2014}", color = LABEL })
    artifactEnemyPvCard = card(right, "EnemyPvCard", 0.083, 0.072, { text = "PV  \u{2014}" })
    artifactHeroGoldCard = card(right, "GoldCard", 0.166, 0.072, { text = "OR  0" })
    artifactEnemyAtkCard = card(right, "AtkCard", 0.249, 0.072, { text = "ATK \u{2014}" })
    footerButton(right, "Inventory", "INVENTAIRE", 0.815, 0.08)   -- InventoryClient wires .Click
    _, artifactMenuButton = footerButton(right, "Menu", "MENU", 0.905, 0.08)
    artifactEnemyPvCard.Visible = false
    artifactEnemyAtkCard.Visible = false

    local abilityBar = bottomPanel:FindFirstChild("ArtifactAbilities")
    if abilityBar and abilityBar:IsA("GuiObject") then abilityBar.Visible = false end

    -- ---- bottom bar (zone progress) ----------------------------------------
    local zoneTrack = background:FindFirstChild("ZoneTrack")
    if zoneTrack then
        zoneTrack.Position = UDim2.new(0, 0, 1, -BOT_H)
        zoneTrack.Size = UDim2.new(1, 0, 0, BOT_H)
        zoneTrack.BackgroundColor3 = BAR_BG
        zoneTrack.BackgroundTransparency = 0
        zoneTrack.BorderColor3 = LINE
        zoneTrack.BorderSizePixel = 1
        zoneTrack.ZIndex = ZH
        for _, child in ipairs(zoneTrack:GetChildren()) do
            if child:IsA("GuiObject") then child.Visible = false end
        end
        strip(zoneTrack)

        artifactProgressText = Instance.new("TextLabel")
        artifactProgressText.Name = "DescenteText"
        artifactProgressText.Position = UDim2.new(0, 14, 0, 0)
        artifactProgressText.Size = UDim2.new(0.52, 0, 1, 0)
        artifactProgressText.BackgroundTransparency = 1
        artifactProgressText.Font = FONT
        artifactProgressText.Text = "Couche 1 \u{2014} Plaine de l'Aube  \u{00B7}  Etape 1/10  \u{00B7}  prochain : BOSS"
        artifactProgressText.TextColor3 = LABEL
        artifactProgressText.TextSize = 12
        artifactProgressText.TextXAlignment = Enum.TextXAlignment.Left
        artifactProgressText.ZIndex = ZH
        artifactProgressText.Parent = zoneTrack

        local rail = Instance.new("Frame")
        rail.Name = "DescenteRail"
        rail.AnchorPoint = Vector2.new(1, 0.5)
        rail.Position = UDim2.new(1, -14, 0.5, 0)
        rail.Size = UDim2.new(0.34, 0, 0, 8)
        rail.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
        rail.BorderColor3 = LINE
        rail.BorderSizePixel = 1
        rail.ClipsDescendants = true
        rail.ZIndex = ZH
        rail.Parent = zoneTrack
        artifactProgressFill = Instance.new("Frame")
        artifactProgressFill.Name = "Fill"
        artifactProgressFill.Size = UDim2.fromScale(0, 1)
        artifactProgressFill.BackgroundColor3 = XP
        artifactProgressFill.BorderSizePixel = 0
        artifactProgressFill.ZIndex = ZH + 1
        artifactProgressFill.Parent = rail
    end
end

-- The HUD now draws on layer 3-4; every full-screen overlay must sit above it.
-- (Global ZIndexBehavior means these compete with the HUD regardless of parent.)
-- Bump each overlay subtree by a fixed offset so its internal order is preserved.
for name, base in pairs({
    GameOverWindow = 90, EquipOverlay = 22, ShopOverlay = 26, ChateauOverlay = 24,
    BagFullPrompt = 93, AccessibilityScreen = 28,
}) do
    local ov = background:FindFirstChild(name)
    if ov and ov:IsA("GuiObject") then
        local offset = base - ov.ZIndex
        if offset > 0 then
            ov.ZIndex += offset
            for _, d in ipairs(ov:GetDescendants()) do
                if d:IsA("GuiObject") then d.ZIndex += offset end
            end
        end
    end
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
-- squash/stretch scale for the hero's attack swing (no forward charge)
local heroScale = heroSlot and (heroSlot:FindFirstChildOfClass("UIScale") or Instance.new("UIScale"))
if heroScale then heroScale.Parent = heroSlot end
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

--===== Scene (world traversal) =====
-- Static backdrop; the HERO moves. ONE linear layout, NO mirror: the same
-- km->screen function places the hero AND both mobs, so nothing can ever dash.
--   e1 & e2 fixed at their step fraction ; hero walks WALK_LO (step start / left)
--   .. WALK_HI (wall / right). Forward you traverse left->right, backward right->left.
local enemyStep1 = combatZone:FindFirstChild("EnemyStep1")
local enemyStep2 = combatZone:FindFirstChild("EnemyStep2")
local ENC_FRAC    = { 0.5, 0.95 }     -- fallback ; the server sends enc.rel per mob
local WALK_LO, WALK_HI = 0.15, 0.88   -- enemy slot placement band (stepXtoScreen range)
local HERO_EXPLORE_X = 0.30           -- the hero holds here while exploring (no per-step traversal)
local PORTAL_L, PORTAL_R = 0.05, 0.95 -- blue (go back) / red (go forward)
local WALL_LEAN   = 0.10              -- lean a touch further against the km-0 boundary
local SCENE_Y     = 0.70              -- vertical centre of the slot Frames
local SLOT_H      = 0.40              -- slot Frame height (CombatZone fraction; matches RpgGui)
-- The combatant art has ~12% transparent canvas below the feet; GROUND_Y is the
-- ImageLabel's bottom edge, tuned so the DRAWN feet land on the dirt path.
local GROUND_Y    = 0.99
local SPRITE_FEET_R = (GROUND_Y - (SCENE_Y - SLOT_H / 2)) / SLOT_H  -- GROUND_Y as a slot-relative Y
local FIGHT_NUDGE = 0.06              -- hero fights just off the enemy (opening hit lands here)
local heroTargetX    = HERO_EXPLORE_X
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
local BASE_SPRITE_W, BASE_SPRITE_H = 0.95, 0.95   -- combatants sized so they never overlap when fighting
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
local activeEnemySlot = nil     -- the slot Frame of the enemy currently being fought
local activeEnemyBaseX = 0      -- its resting X (RenderStepped adds a hit-flinch offset)
local heroWalkAmt = 0           -- 0..1 smoothed "is the hero walking" (drives bob/lean)
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
-- Crossing wipe. Snaps to a soft cover INSTANTLY (so the hero's reset to the
-- left edge of the next step is never seen mid-slide), then fades out.
local function playStepTransition(goingBack)
    stepTransition.BackgroundColor3 = goingBack and Color3.fromRGB(18, 22, 32) or Color3.fromRGB(24, 20, 14)
    stepTransition.Visible = true
    stepTransition.BackgroundTransparency = 0.2   -- instant partial cover, no fade-in
    local tout = TweenService:Create(stepTransition,
        TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { BackgroundTransparency = 1 })
    tout.Completed:Connect(function() stepTransition.Visible = false end)
    tout:Play()
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
    activeEnemySlot = nil
    for i, slot in ipairs(slots) do
        local enc = encs[i]
        local tag = slot and ensureNameTag(slot)
        if slot and enc then
            local frac = enc.rel or ENC_FRAC[i] or (i == 1 and 0.5 or 0.95)
            slot.Visible = not enc.cleared
            slot.Position = UDim2.new(stepXtoScreen(frac), 0, SCENE_Y, 0)
            if enc.active then
                activeFrac = frac ; activeEnemySlot = slot ; activeEnemyBaseX = stepXtoScreen(frac)
            else
                slot.Rotation = 0
            end
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

    -- Hero X follows his real km progress on the SAME scale the mobs are placed
    -- on, so he arrives ON the enemy exactly as the fight starts (the server
    -- only engages within encounterRangeKm = ~0.06). No cap, no pre-stop.
    local p = math.clamp(data.posRelStep or 0, 0, 1)
    heroTargetX = stepXtoScreen(p)
    if activeIndex then
        local ex = stepXtoScreen(activeFrac or 0.5)
        enemyHpTargetX = ex
        heroTargetX = ex + (back and FIGHT_NUDGE or -FIGHT_NUDGE)
    elseif data.moveDir == "left" and (data.pos or 0) <= 0.02 then
        heroTargetX = WALL_LEAN
    end
    if crossed and heroSlot then
        heroSlot.Position = UDim2.new(heroTargetX, 0, SCENE_Y, 0)   -- snap, hidden by the wipe
    end
end

--===== Zone track (compact progress line to the end of the zone) =====
local zoneTrack   = background:FindFirstChild("ZoneTrack") or combatZone:FindFirstChild("ZoneTrack")

local function updateZoneTrack(data)
    if not zoneTrack then return end
    if artifactProgressText then
        local z = ZoneConfig.getZone(data.zone or 1)
        artifactProgressText.Text = string.format("Couche %d \u{2014} %s  \u{00B7}  Etape %d/%d  \u{00B7}  prochain : BOSS",
            data.zone or 1, (z and z.name) or "?", data.stepIndex or 1, data.stepsPerZone or 10)
    end
    if artifactProgressFill then
        artifactProgressFill.Size = UDim2.new(math.clamp(data.posRelZone or 0, 0, 1), 0, 1, 0)
    end
end

--===== Top HUD (deaths / zone progress / distance+speed) =====
local topSection = background:FindFirstChild("TopSection")

local function updateTopHud(data)
    if artifactTopCenter then
        artifactTopCenter.Text = string.format("\u{1F480} %d   \u{00B7}   Couche %d   \u{00B7}   %.1f km",
            data.deaths or 0, data.zone or 1, data.pos or 0)
    end
    if artifactTopEnemy then
        local inFight = false
        for _, e in ipairs(data.encounters or {}) do
            if e and e.active then inFight = true break end
        end
        artifactTopEnemy.Text = (inFight and data.enemyName)
            and string.format("%s  \u{00B7}  Niv.%d", data.enemyName, data.enemyLevel or 1)
            or (data.milestone == "campfire" and "FEU DE CAMP")
            or "EXPLORATION"
        artifactTopEnemy.TextColor3 = (inFight and data.enemyName)
            and Color3.fromRGB(206, 120, 108) or Color3.fromRGB(201, 168, 120)
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

--===== Talents / stat allocation panel =====
-- Opened from the DescenteLeft "TALENTS" footer button. Replaces the old
-- HeroStatsBox (which lived on a permanently-hidden panel). Reads the stat
-- fields already present on every "update" payload; writes go through the
-- unchanged server "allocateStat" handler.
local TALENT_BG     = Color3.fromRGB(16, 17, 21)
local TALENT_BORDER = Color3.fromRGB(150, 150, 155)
local TALENT_ACCENT = Color3.fromRGB(224, 196, 128)
local TALENT_TEXT   = Color3.fromRGB(242, 239, 226)
local TALENT_MUTED  = Color3.fromRGB(150, 150, 155)
local STAT_ORDER = { "POW", "INT", "VIT", "SPD", "LUK" }
local STAT_DESC = {
    POW = "Puissance \u{2014} d\u{00E9}g\u{00E2}ts physiques",
    INT = "Intellect \u{2014} d\u{00E9}g\u{00E2}ts magiques",
    VIT = "Vitalit\u{00E9} \u{2014} points de vie",
    SPD = "Vitesse \u{2014} cadence d'attaque",
    LUK = "Chance \u{2014} taux de critique",
}

local talentsPointsLabel
local talentsRows = {}   -- statName -> { value = TextLabel, btn = TextButton }

do
    local panel = Instance.new("Frame")
    panel.Name = "TalentsPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromOffset(360, 360)
    panel.BackgroundColor3 = TALENT_BG
    panel.BorderColor3 = TALENT_BORDER
    panel.BorderSizePixel = 1
    panel.Visible = false
    panel.ZIndex = 60
    panel.Parent = background

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Position = UDim2.fromOffset(16, 12)
    title.Size = UDim2.new(1, -32, 0, 24)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamMedium
    title.Text = "TALENTS"
    title.TextColor3 = TALENT_ACCENT
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 61
    title.Parent = panel

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.Size = UDim2.fromOffset(32, 28)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.Text = "X"
    closeBtn.TextColor3 = TALENT_MUTED
    closeBtn.TextSize = 16
    closeBtn.ZIndex = 61
    closeBtn.Parent = panel
    closeBtn.MouseButton1Click:Connect(function() panel.Visible = false end)

    talentsPointsLabel = Instance.new("TextLabel")
    talentsPointsLabel.Name = "Points"
    talentsPointsLabel.Position = UDim2.fromOffset(16, 40)
    talentsPointsLabel.Size = UDim2.new(1, -32, 0, 20)
    talentsPointsLabel.BackgroundTransparency = 1
    talentsPointsLabel.Font = Enum.Font.Gotham
    talentsPointsLabel.Text = "Points \u{00E0} r\u{00E9}partir : 0"
    talentsPointsLabel.TextColor3 = TALENT_TEXT
    talentsPointsLabel.TextSize = 13
    talentsPointsLabel.TextXAlignment = Enum.TextXAlignment.Left
    talentsPointsLabel.ZIndex = 61
    talentsPointsLabel.Parent = panel

    for i, statName in ipairs(STAT_ORDER) do
        local y = 70 + (i - 1) * 52
        local row = Instance.new("Frame")
        row.Name = "Row" .. statName
        row.Position = UDim2.fromOffset(16, y)
        row.Size = UDim2.new(1, -32, 0, 46)
        row.BackgroundColor3 = Color3.fromRGB(21, 22, 27)
        row.BorderColor3 = TALENT_BORDER
        row.BorderSizePixel = 1
        row.ZIndex = 61
        row.Parent = panel

        local value = Instance.new("TextLabel")
        value.Name = "Value"
        value.Position = UDim2.fromOffset(10, 0)
        value.Size = UDim2.new(1, -80, 1, 0)
        value.BackgroundTransparency = 1
        value.Font = Enum.Font.Gotham
        value.Text = string.format("%s  0", statName)
        value.TextColor3 = TALENT_TEXT
        value.TextSize = 13
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.TextWrapped = true
        value.ZIndex = 62
        value.Parent = row

        local btn = Instance.new("TextButton")
        btn.Name = "Add"
        btn.AnchorPoint = Vector2.new(1, 0.5)
        btn.Position = UDim2.new(1, -8, 0.5, 0)
        btn.Size = UDim2.fromOffset(52, 30)
        btn.BackgroundColor3 = Color3.fromRGB(11, 12, 16)
        btn.BorderColor3 = TALENT_ACCENT
        btn.BorderSizePixel = 1
        btn.AutoButtonColor = false
        btn.Font = Enum.Font.GothamMedium
        btn.Text = "+"
        btn.TextColor3 = TALENT_ACCENT
        btn.TextSize = 15
        btn.ZIndex = 62
        btn.Parent = row
        btn.MouseButton1Click:Connect(function()
            combatEvent:FireServer({ type = "allocateStat", stat = statName })
        end)

        talentsRows[statName] = { value = value, btn = btn }
    end
end

local function updateTalentsPanel(data)
    if talentsPointsLabel then
        local def, res = math.floor(data.playerDef or 0), math.floor(data.playerRes or 0)
        local arm = (def > 0 or res > 0) and string.format("      armure : DEF %d \u{00B7} RES %d", def, res) or ""
        talentsPointsLabel.Text = string.format("Points \u{00E0} r\u{00E9}partir : %d%s", data.statPoints or 0, arm)
    end
    local statFields = {
        POW = data.statPow or 0, INT = data.statInt or 0, VIT = data.statVit or 0,
        SPD = data.statSpd or 0, LUK = data.statLuk or 0,
    }
    local points = data.statPoints or 0
    for _, statName in ipairs(STAT_ORDER) do
        local row = talentsRows[statName]
        if row then
            local base = statFields[statName]
            local gear = 0
            if statName == "VIT" then gear = data.gearHpPoints or 0
            elseif statName == "POW" and not data.gearIsMagic then gear = data.gearAtkPoints or 0
            elseif statName == "INT" and data.gearIsMagic then gear = data.gearAtkPoints or 0 end
            local head = (gear > 0)
                and string.format("%s  %d  (+%d \u{00E9}quip.)", statName, base, gear)
                or  string.format("%s  %d", statName, base)
            if statName == "SPD" and data.spdAtMax then head = string.format("%s  %d  (MAX)", statName, base) end
            row.value.Text = head .. "\n" .. (STAT_DESC[statName] or "")

            if statName == "SPD" and data.spdAtMax then
                row.btn.Text = "MAX"
                row.btn.TextColor3 = TALENT_MUTED
                row.btn.BorderColor3 = TALENT_BORDER
            else
                local cost = (statName == "SPD") and (data.spdNextCost or 1) or 1
                row.btn.Text = (cost > 1) and ("+" .. cost) or "+"
                local affordable = points >= cost
                row.btn.TextColor3 = affordable and TALENT_ACCENT or TALENT_MUTED
                row.btn.BorderColor3 = affordable and TALENT_ACCENT or TALENT_BORDER
            end
        end
    end
end

if artifactTalentsButton then
    artifactTalentsButton.MouseButton1Click:Connect(function()
        local p = background:FindFirstChild("TalentsPanel")
        if p then p.Visible = not p.Visible end
    end)
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
    -- Player HP: the visible bar is artifactHeroHpFill in DescenteLeft.
    local playerRatio = math.clamp(data.playerHp / math.max(1, data.playerMaxHp), 0, 1)
    if artifactHeroHpText then artifactHeroHpText.Text = string.format("%d/%d", data.playerHp, data.playerMaxHp) end
    if artifactHeroHpFill then
        artifactHeroHpFill.Size = UDim2.new(playerRatio, 0, 1, 0)
        artifactHeroHpFill.BackgroundColor3 =
            (playerRatio <= 0.20) and Color3.fromRGB(220, 60, 60)
            or (playerRatio <= 0.50) and Color3.fromRGB(230, 200, 60)
            or Color3.fromRGB(80, 210, 90)
    end
    lowHpActive = (data.playerHp or 0) > 0 and playerRatio <= 0.20 and not (data.gameOver == true)

    local inFight = false
    for _, e in ipairs(data.encounters or {}) do
        if e and e.active then inFight = true break end
    end

    -- Enemy HP: the visible bar is artifactEnemyHpFill in DescenteRight.
    local enemyRatio = math.clamp(data.enemyHp / math.max(1, data.enemyMaxHp), 0, 1)
    if artifactEnemyHpText then artifactEnemyHpText.Text = string.format("%d/%d", data.enemyHp, data.enemyMaxHp) end
    if artifactEnemyHpFill then artifactEnemyHpFill.Size = UDim2.new(enemyRatio, 0, 1, 0) end

    -- Hero cards (DescenteLeft): grey field label + light value, one line each.
    local function fld(label, value)
        return string.format('<font color="#78787d">%s</font>  %s', label, value)
    end
    local rbTag = (data.rebirths and data.rebirths > 0) and string.format("  \u{00B7}  R%d", data.rebirths) or ""
    if artifactHeroLevelCard then
        artifactHeroLevelCard.Text = fld("LV", tostring(data.playerLevel or 1) .. rbTag)
    end
    if artifactHeroXpText and artifactHeroXpFill then
        local currentXp = math.max(0, data.playerExp or 0)
        local neededXp = math.max(1, data.playerExpToNext or 1)
        local xpRatio = math.clamp(currentXp / neededXp, 0, 1)
        artifactHeroXpFill.Size = UDim2.new(xpRatio, 0, 1, 0)
        artifactHeroXpText.Text = string.format("XP %s / %s", formatNumber(currentXp), formatNumber(neededXp))
    end
    if artifactHeroWeaponCard then artifactHeroWeaponCard.Text = fld("Arme", data.equipWeapon or "\u{2014}") end
    if artifactHeroArmorCard then artifactHeroArmorCard.Text = fld("Armr", data.equipArmor or "\u{2014}") end
    if artifactHeroPetCard then artifactHeroPetCard.Text = fld("Pets", data.equipPet or "\u{2014}") end
    if artifactHeroStatsCard then
        artifactHeroStatsCard.Text = string.format(
            '<font color="#78787d">ATK</font> %s  <font color="#78787d">DEF</font> %s\n<font color="#78787d">RES</font> %s  <font color="#78787d">CRIT</font> %.1f%%',
            formatNumber(data.playerAtk or 0), formatNumber(data.playerDef or 0), formatNumber(data.playerRes or 0),
            math.min(100, (data.statLuk or 0) / 25))
    end

    -- Pet sprite is painted just below, beside the hero (needs the fresh facing).

    -- Talents panel (stat allocation) - refreshed whether open or not so it's
    -- current the instant the player opens it.
    updateTalentsPanel(data)

    -- Gold (sits in the right column, matching the reference)
    if artifactHeroGoldCard then
        artifactHeroGoldCard.Text = fld("OR", formatNumber(data.gold or 0))
    end

    -- Rebirth button: icone seule (assets/images/rebirthicon, fond detoure),
    -- centree. Pas de texte. Attenuee quand le rebirth n'est pas payable.
    if rebirthButton then
        local ic = rebirthButton:FindFirstChild("Icon")
        if ic then ic.ImageTransparency = data.canRebirth and 0 or 0.5 end
    end

    -- Enemy readout (DescenteRight cards): only populated during an actual fight.
    local enemyHpRoot = artifactEnemyHpLabel and artifactEnemyHpLabel.Parent
    if not inFight then
        if enemyHpRoot then enemyHpRoot.Visible = false end
        if artifactEnemyNameCard then
            artifactEnemyNameCard.Visible = true
            artifactEnemyNameCard.Text = data.isMoving and "exploration\u{2026}" or "aucun ennemi"
            artifactEnemyNameCard.TextColor3 = Color3.fromRGB(120, 120, 125)
        end
        if artifactEnemyPvCard then artifactEnemyPvCard.Visible = false end
        if artifactEnemyAtkCard then artifactEnemyAtkCard.Visible = false end
    else
        if enemyHpRoot then enemyHpRoot.Visible = true end
        if artifactEnemyNameCard then
            artifactEnemyNameCard.Visible = true
            artifactEnemyNameCard.Text = string.format("%s  N%d", data.enemyName or "?", data.enemyLevel or 1)
            artifactEnemyNameCard.TextColor3 = difficultyColour(data, data.enemyMaxHp, data.enemyAtk, data.enemyDamageType == "magic")
        end
        if artifactEnemyPvCard then
            artifactEnemyPvCard.Visible = true
            artifactEnemyPvCard.Text = fld("PV", string.format("%d / %d", data.enemyHp or 0, data.enemyMaxHp or 0))
        end
        if artifactEnemyAtkCard then
            artifactEnemyAtkCard.Visible = true
            local atkPct = (data.enemyIsBoss and data.enemyAtkSplit)
                and math.floor(data.enemyAtkSplit * 100 + 0.5) or 100
            artifactEnemyAtkCard.Text = fld("ATK", string.format("%d%%  \u{00B7}  %s", atkPct,
                (data.enemyDamageType == "magic") and "mag." or "phys."))
        end
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
    -- muted tones (the old pure red / pure yellow bloomed on the dark scene)
    label.TextColor3 = isCrit and Color3.fromRGB(206, 70, 58) or Color3.fromRGB(220, 178, 108)
    label.Text = isCrit and string.format("-%d!", amount) or string.format("-%d", amount)
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
    elseif target == "heal" or target == "revive" then
        xPos = heroSlot and heroSlot.Position.X.Scale or WALK_LO
        label.TextColor3 = Color3.fromRGB(110, 205, 120)
        label.Text = (target == "revive") and string.format("REVIVE +%d", amount) or string.format("+%d", amount)
        label.TextSize = (target == "revive") and 20 or 15
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
    elseif data.type == "petRevive" then
        if statusText then
            statusText.Text = "Sauvé par le familier !"
            statusText.TextColor3 = Color3.fromRGB(110, 205, 120)
        end
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
    -- Hero slides toward its target x; the walk bob/lean is driven by ACTUAL
    -- translation (not the server's isMoving), so it stops the instant he
    -- reaches his spot - no "fake walking" while blocked at a mob.
    if heroSlot then
        local cur = heroSlot.Position.X.Scale
        local gap = heroTargetX - cur
        local nx = cur + gap * 0.16                        -- ONE smooth rate, no branching
        if math.abs(heroTargetX - nx) < 0.0015 then nx = heroTargetX end
        -- walk amount eases in/out so the bob never snaps on/off (no twitch)
        local target = (not activeEnemySlot) and math.abs(gap) > 0.003 and 1 or 0
        heroWalkAmt = heroWalkAmt + (target - heroWalkAmt) * 0.15
        local bob = heroWalkAmt * math.sin(tick() * 11) * 0.008
        local faceSign = (sceneFacing == "left") and -1 or 1
        -- Attack = a weapon SWING: lean in + squash/stretch, no forward charge.
        local attackT = math.max(0, heroAttackUntil - tick())
        local swing = 0
        if attackT > 0 then
            local arc = math.sin((0.24 - attackT) / 0.24 * math.pi)
            swing = faceSign * arc * 13
            if heroScale then heroScale.Scale = 1 + arc * 0.05 end
        elseif heroScale and heroScale.Scale ~= 1 then
            heroScale.Scale = 1
        end
        heroSlot.Position = UDim2.new(nx, 0, SCENE_Y + bob, 0)
        heroSlot.Rotation = swing + heroWalkAmt * ((moveDirState == "left") and -4 or 4)
        -- Small HP bar sits on the ground just under the hero (scaled to a sprite's width).
        if playerHpBar then
            playerHpBar.AnchorPoint = Vector2.new(0.5, 0)
            playerHpBar.Size = UDim2.new(HPBAR_W, 0, HPBAR_H, 0)
            playerHpBar.Position = UDim2.new(nx, 0, GROUND_Y + 0.02, 0)
        end
    end

    -- Enemy hit-flinch: the struck enemy recoils away from the hero + a quick
    -- rock, then settles. This carries the "impact" so the hero doesn't have to.
    if activeEnemySlot then
        local faceSign = (sceneFacing == "left") and -1 or 1
        local hitT = math.max(0, heroAttackUntil - tick())
        local arc = hitT > 0 and math.sin((0.24 - hitT) / 0.24 * math.pi) or 0
        activeEnemySlot.Position = UDim2.new(activeEnemyBaseX + faceSign * arc * 0.018, 0, SCENE_Y, 0)
        activeEnemySlot.Rotation = -faceSign * arc * 7
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
        -- the fairy hovers a little above the ground line the hero stands on
        petSprite.Position = UDim2.new(px, 0, GROUND_Y - 0.05 + bob, 0)
    end
end)

