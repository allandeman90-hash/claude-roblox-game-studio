--==============================================================
-- TitleClient  (LocalScript - StarterPlayerScripts)
--
-- The entry point (master-gdd SS3 "Ouvrir -> menu d'accueil"). Own ScreenGui,
-- on top of the game HUD. Two surfaces:
--   1. Menu titre  -- logo + JOUER + 6 raccourcis (grises "bientot" pour ceux
--      dont le systeme n'existe pas encore : Track H) + une ligne de stats de
--      reprise pour un joueur qui revient.
--   2. Creation du heros  -- montree a la place du menu quand le serveur envoie
--      "needHeroCreation" et que le joueur clique JOUER. voie / teinte / nom.
--
-- The game world + combat run underneath the whole time (server-authoritative);
-- JOUER / COMMENCER just dismiss this overlay. FTUE is released server-side once
-- "createHero" lands (CombatServer).
--
-- 02-maquettes.md SS01 + SS02.
--==============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local StyleConstants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StyleConstants"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local AssetMap = require(ReplicatedStorage:WaitForChild("AssetMap"))

local player = Players.LocalPlayer
local combatEvent = ReplicatedStorage:WaitForChild("CombatEvent") :: RemoteEvent
local C = StyleConstants.BaseColors
local TZ = 250   -- above HUD (3-4) and every overlay (< 100)

--===== State =====
local needsCreation = false     -- set by the server "needHeroCreation" message
local dismissed = false         -- JOUER / COMMENCER pressed this session
local lastUpdate = nil          -- last "update" payload (for the resume stats line)

--===== ScreenGui =====
local gui = Instance.new("ScreenGui")
gui.Name = "TitleGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 500
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Enabled = true
gui.Parent = player:WaitForChild("PlayerGui")

local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = C.Background
backdrop.BorderSizePixel = 0
backdrop.ZIndex = TZ
backdrop.Parent = gui

--===== Small builders =====
local function label(parent: Instance, text: string, size: number, colour: Color3): TextLabel
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = StyleConstants.Fonts.Body
    l.RichText = true
    l.Text = text
    l.TextColor3 = colour
    l.TextSize = size
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = TZ
    l.Parent = parent
    return l
end

--============================================================
-- SURFACE 1 -- menu titre
--============================================================
local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.fromScale(1, 1)
menu.BackgroundTransparency = 1
menu.ZIndex = TZ
menu.Parent = gui

-- left half: logo
local logo = label(menu, "QUETE MINUTE", 52, C.TextPrimary)
logo.AnchorPoint = Vector2.new(0, 0.5)
logo.Position = UDim2.fromScale(0.08, 0.40)
logo.Size = UDim2.fromScale(0.5, 0.12)

local sub = label(menu, "-- La Descente --", 20, C.TextSecondary)
sub.AnchorPoint = Vector2.new(0, 0.5)
sub.Position = UDim2.fromScale(0.08, 0.50)
sub.Size = UDim2.fromScale(0.5, 0.06)

-- right half: play + resume line + shortcuts
local right = Instance.new("Frame")
right.Name = "Right"
right.AnchorPoint = Vector2.new(1, 0.5)
right.Position = UDim2.fromScale(0.92, 0.5)
right.Size = UDim2.fromScale(0.36, 0)
right.AutomaticSize = Enum.AutomaticSize.Y
right.BackgroundTransparency = 1
right.ZIndex = TZ
right.Parent = menu
do
    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Padding = UDim.new(0, 12)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = right
end

local resumeLbl = Instance.new("TextLabel")
resumeLbl.Name = "Resume"
resumeLbl.BackgroundTransparency = 1
resumeLbl.Font = StyleConstants.Fonts.Body
resumeLbl.Text = ""
resumeLbl.TextColor3 = C.TextSecondary
resumeLbl.TextSize = 15
resumeLbl.TextXAlignment = Enum.TextXAlignment.Center
resumeLbl.Size = UDim2.new(1, 0, 0, 18)
resumeLbl.LayoutOrder = 1
resumeLbl.ZIndex = TZ
resumeLbl.Parent = right

local playBtn = StyleConstants.makeButton("\u{25B6}  JOUER", "Heading", "green")
playBtn.Size = UDim2.new(1, 0, 0, 64)
playBtn.LayoutOrder = 2
playBtn.ZIndex = TZ
playBtn.Parent = right

-- 6 raccourcis (02-maquettes SS01). Ceux dont le systeme est absent = grises.
local shortcutRow = Instance.new("Frame")
shortcutRow.Name = "Shortcuts"
shortcutRow.Size = UDim2.new(1, 0, 0, 76)
shortcutRow.BackgroundTransparency = 1
shortcutRow.LayoutOrder = 3
shortcutRow.ZIndex = TZ
shortcutRow.Parent = right
do
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(1/3, -6, 0, 34)
    grid.CellPadding = UDim2.fromOffset(9, 8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = shortcutRow
end

local SHORTCUTS = {
    { key = "talents", text = "Talents",   ready = false },
    { key = "sac",     text = "Sac",       ready = false },
    { key = "boutique", text = "Boutique", ready = false },
    { key = "codex",   text = "Codex",     ready = false },
    { key = "rang",    text = "Rang",      ready = false },
    { key = "reglages", text = "\u{2699}", ready = false },
}
for i, sc in ipairs(SHORTCUTS) do
    local b = StyleConstants.makeButton(sc.text, "Label", sc.ready and "gray" or "gray")
    b.Name = "Sc_" .. sc.key
    b.LayoutOrder = i
    b.ZIndex = TZ
    b.Active = sc.ready
    b.TextTransparency = sc.ready and 0 or 0.5
    b.Parent = shortcutRow
    if not sc.ready then
        -- a "bientot" hint on hover would be nice; keep it simple for v0.
        b.Text = sc.text
    end
end

--============================================================
-- SURFACE 2 -- creation du heros
--============================================================
local create = Instance.new("Frame")
create.Name = "Create"
create.Size = UDim2.fromScale(1, 1)
create.BackgroundTransparency = 1
create.Visible = false
create.ZIndex = TZ
create.Parent = gui

local createTitle = label(create, "CREE TON HEROS", 30, C.Accent)
createTitle.AnchorPoint = Vector2.new(0.5, 0)
createTitle.Position = UDim2.fromScale(0.5, 0.08)
createTitle.Size = UDim2.fromScale(0.8, 0.08)
createTitle.TextXAlignment = Enum.TextXAlignment.Center

local selectedVoie = "guerrier"
local selectedTint = "acier"

-- two voie cards
local function voieCard(voie: string, blurb: string, xScale: number): TextButton
    local card = Instance.new("TextButton")
    card.Name = "Voie_" .. voie
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(xScale, 0.46)
    card.Size = UDim2.fromOffset(300, 220)
    card.AutoButtonColor = false
    card.BackgroundColor3 = C.Panel
    card.BorderSizePixel = 0
    card.Font = StyleConstants.Fonts.Body
    card.Text = ""
    card.ZIndex = TZ
    card.Parent = create
    local stroke = StyleConstants.addStroke(card, 2, C.Border)
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    local name = label(card, voie == "guerrier" and "GUERRIER" or "MAGE", 24, C.TextPrimary)
    name.Position = UDim2.fromOffset(20, 20)
    name.Size = UDim2.new(1, -40, 0, 30)
    name.TextXAlignment = Enum.TextXAlignment.Center
    local body = label(card, blurb, 15, C.TextSecondary)
    body.Position = UDim2.fromOffset(20, 66)
    body.Size = UDim2.new(1, -40, 1, -86)
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top
    return card
end

local cardGuerrier = voieCard("guerrier",
    "Force -- degats stables, cadence rapide. Se blinde en DEF via l'armure.", 0.24)
local cardMage = voieCard("mage",
    "Magie -- degats lourds, cadence lente. Resiste en RES via l'armure.", 0.76)

-- live hero preview between the cards (sprite by voie, ImageColor3 by tint)
local preview = Instance.new("ImageLabel")
preview.Name = "Preview"
preview.AnchorPoint = Vector2.new(0.5, 0.5)
preview.Position = UDim2.fromScale(0.5, 0.46)
preview.Size = UDim2.fromOffset(150, 190)
preview.BackgroundTransparency = 1
preview.ScaleType = Enum.ScaleType.Fit
preview.ZIndex = TZ
preview.Parent = create

local function refreshPreview()
    preview.Image = AssetMap[selectedVoie == "mage" and "hero_mage" or "hero_warrior"] or ""
    preview.ImageColor3 = GameConfig.Hero.tints[selectedTint] or Color3.new(1, 1, 1)
end

local function refreshVoie()
    for voie, card in pairs({ guerrier = cardGuerrier, mage = cardMage }) do
        local s = card:FindFirstChildWhichIsA("UIStroke")
        local on = (voie == selectedVoie)
        if s then
            s.Color = on and StyleConstants.ButtonVariants.gold.border or C.Border
            s.Thickness = on and 3 or 2
        end
        card.BackgroundColor3 = on and Color3.fromRGB(24, 24, 20) or C.Panel
    end
    refreshPreview()
end
cardGuerrier.MouseButton1Click:Connect(function() selectedVoie = "guerrier"; refreshVoie() end)
cardMage.MouseButton1Click:Connect(function() selectedVoie = "mage"; refreshVoie() end)
refreshVoie()

-- bottom bar: tint swatches + name + COMMENCER
local bottom = Instance.new("Frame")
bottom.Name = "Bottom"
bottom.AnchorPoint = Vector2.new(0.5, 1)
bottom.Position = UDim2.fromScale(0.5, 0.92)
bottom.Size = UDim2.fromOffset(720, 96)
bottom.BackgroundTransparency = 1
bottom.ZIndex = TZ
bottom.Parent = create

local swatchRow = Instance.new("Frame")
swatchRow.Size = UDim2.fromOffset(4 * 44 + 3 * 10, 40)
swatchRow.Position = UDim2.fromOffset(0, 0)
swatchRow.BackgroundTransparency = 1
swatchRow.ZIndex = TZ
swatchRow.Parent = bottom
do
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Horizontal
    l.Padding = UDim.new(0, 10)
    l.Parent = swatchRow
end
local swatches = {}
for i, key in ipairs(GameConfig.Hero.tintOrder) do
    local sw = Instance.new("TextButton")
    sw.Name = "Tint_" .. key
    sw.Size = UDim2.fromOffset(44, 40)
    sw.LayoutOrder = i
    sw.AutoButtonColor = false
    sw.Text = ""
    sw.BackgroundColor3 = GameConfig.Hero.tints[key]
    sw.BorderSizePixel = 0
    sw.ZIndex = TZ
    sw.Parent = swatchRow
    StyleConstants.addStroke(sw, 2, C.Border)
    swatches[key] = sw
    sw.MouseButton1Click:Connect(function()
        selectedTint = key
        for k, s in pairs(swatches) do
            local st = s:FindFirstChildWhichIsA("UIStroke")
            if st then st.Color = (k == key) and StyleConstants.ButtonVariants.gold.border or C.Border end
        end
        refreshPreview()
    end)
end
do
    local st = swatches.acier:FindFirstChildWhichIsA("UIStroke")
    if st then st.Color = StyleConstants.ButtonVariants.gold.border end
end

local nameBox = Instance.new("TextBox")
nameBox.Name = "NameBox"
nameBox.Position = UDim2.fromOffset(4 * 44 + 3 * 10 + 20, 0)
nameBox.Size = UDim2.fromOffset(280, 40)
nameBox.BackgroundColor3 = C.Slot
nameBox.BorderSizePixel = 0
nameBox.Font = StyleConstants.Fonts.Body
nameBox.PlaceholderText = "Nom du heros"
nameBox.Text = ""
nameBox.TextColor3 = C.TextPrimary
nameBox.TextSize = 16
nameBox.ClearTextOnFocus = false
nameBox.ZIndex = TZ
nameBox.Parent = bottom
StyleConstants.addStroke(nameBox, 1, C.Border)

local startBtn = StyleConstants.makeButton("COMMENCER", "Body", "gold")
startBtn.AnchorPoint = Vector2.new(1, 0)
startBtn.Position = UDim2.fromScale(1, 0)
startBtn.Size = UDim2.fromOffset(180, 40)
startBtn.ZIndex = TZ
startBtn.Parent = bottom

local createHint = label(create, "", 13, StyleConstants.BaseColors.Alert)
createHint.AnchorPoint = Vector2.new(0.5, 1)
createHint.Position = UDim2.fromScale(0.5, 0.97)
createHint.Size = UDim2.fromScale(0.8, 0.04)
createHint.TextXAlignment = Enum.TextXAlignment.Center

--============================================================
-- Flow
--============================================================
local function hideAll()
    dismissed = true
    local t = TweenInfo.new(0.35, Enum.EasingStyle.Quad)
    TweenService:Create(backdrop, t, { BackgroundTransparency = 1 }):Play()
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            TweenService:Create(d, t, { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
        elseif d:IsA("Frame") and d ~= backdrop then
            TweenService:Create(d, t, { BackgroundTransparency = 1 }):Play()
        elseif d:IsA("UIStroke") then
            TweenService:Create(d, t, { Transparency = 1 }):Play()
        end
    end
    task.delay(0.4, function()
        gui.Enabled = false
    end)
end

local function showCreation()
    menu.Visible = false
    create.Visible = true
end

playBtn.MouseButton1Click:Connect(function()
    if dismissed then return end
    if needsCreation then
        showCreation()
    else
        hideAll()
    end
end)

local submitting = false
startBtn.MouseButton1Click:Connect(function()
    if submitting or dismissed then return end
    local nm = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if #nm < GameConfig.Hero.nameMinLen then
        createHint.Text = string.format("Nom : %d caracteres minimum.", GameConfig.Hero.nameMinLen)
        return
    end
    submitting = true
    startBtn.Text = "..."
    combatEvent:FireServer({ type = "createHero", voie = selectedVoie, teinte = selectedTint, name = nm })
end)

--============================================================
-- Server messages
--============================================================
combatEvent.OnClientEvent:Connect(function(data)
    if type(data) ~= "table" then return end
    if data.type == "needHeroCreation" then
        needsCreation = true
    elseif data.type == "heroCreated" then
        if data.ok then
            hideAll()
        else
            submitting = false
            startBtn.Text = "COMMENCER"
            createHint.Text = (data.reason == "voie" and "Choisis une voie.")
                or (data.reason == "already" and "Heros deja cree.")
                or "Nom refuse -- essaie autre chose."
        end
    elseif data.type == "update" then
        lastUpdate = data
        if not dismissed and menu.Visible then
            -- Progress, not the current run position: best km reached + rebirths.
            local km = math.max(data.bestKm or 0, data.checkpointMaxKm or 0, data.distance or 0)
            local rb = data.rebirths or 0
            local zone = math.floor(km / 10) + 1
            resumeLbl.Text = (km > 0 or rb > 0)
                and string.format("COUCHE %d  \u{00B7}  KM %.1f  \u{00B7}  REBIRTH %d", zone, km, rb)
                or ""
        end
    end
end)
