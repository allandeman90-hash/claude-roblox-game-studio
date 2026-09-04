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

-- left half: logo + hero on the line (02-maquettes SS01)
local logo = label(menu, "QUETE MINUTE", 68, C.TextPrimary)
logo.AnchorPoint = Vector2.new(0, 1)
logo.Position = UDim2.fromScale(0.08, 0.44)
logo.Size = UDim2.fromScale(0.52, 0.14)

local sub = label(menu, "\u{2014} La Descente \u{2014}", 22, C.Accent)
sub.AnchorPoint = Vector2.new(0, 0)
sub.Position = UDim2.fromScale(0.085, 0.45)
sub.Size = UDim2.fromScale(0.5, 0.06)

-- ground line + a small idle hero standing on it
local line = Instance.new("Frame")
line.Name = "Line"
line.AnchorPoint = Vector2.new(0, 0.5)
line.Position = UDim2.fromScale(0.08, 0.66)
line.Size = UDim2.new(0.46, 0, 0, 2)
line.BackgroundColor3 = C.Border
line.BorderSizePixel = 0
line.ZIndex = TZ
line.Parent = menu

local heroOnLine = Instance.new("ImageLabel")
heroOnLine.Name = "HeroOnLine"
heroOnLine.AnchorPoint = Vector2.new(0.5, 1)
heroOnLine.Position = UDim2.fromScale(0.14, 0.665)
heroOnLine.Size = UDim2.fromOffset(150, 190)
heroOnLine.BackgroundTransparency = 1
heroOnLine.ScaleType = Enum.ScaleType.Fit
heroOnLine.Image = AssetMap.hero_warrior or ""
heroOnLine.ZIndex = TZ
heroOnLine.Parent = menu

-- right half: play + resume line + shortcuts
local right = Instance.new("Frame")
right.Name = "Right"
right.AnchorPoint = Vector2.new(1, 0.5)
right.Position = UDim2.fromScale(0.93, 0.5)
right.Size = UDim2.fromScale(0.34, 0)
right.AutomaticSize = Enum.AutomaticSize.Y
right.BackgroundTransparency = 1
right.ZIndex = TZ
right.Parent = menu
do
    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Padding = UDim.new(0, 16)
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

-- Daily reward band (02-maquettes SS01 "RECOMPENSE DU JOUR"). Hidden until the
-- server confirms a day is claimable; pulses gently while it is.
local dailyBand = StyleConstants.makeButton("\u{25C6} RECOMPENSE DU JOUR \u{00B7} A RECLAMER", "Label", "gold")
dailyBand.Size = UDim2.new(1, 0, 0, 34)
dailyBand.LayoutOrder = 2
dailyBand.ZIndex = TZ
dailyBand.Visible = false
dailyBand.Parent = right

local playBtn = StyleConstants.makeButton("\u{25B6}  JOUER", "Heading", "green")
playBtn.Size = UDim2.new(1, 0, 0, 76)
playBtn.LayoutOrder = 3
playBtn.ZIndex = TZ
playBtn.Parent = right

-- 6 raccourcis (02-maquettes SS01). Ceux dont le systeme est absent = grises.
local shortcutRow = Instance.new("Frame")
shortcutRow.Name = "Shortcuts"
shortcutRow.Size = UDim2.new(1, 0, 0, 104)
shortcutRow.BackgroundTransparency = 1
shortcutRow.LayoutOrder = 4
shortcutRow.ZIndex = TZ
shortcutRow.Parent = right
do
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(1/3, -8, 0, 46)
    grid.CellPadding = UDim2.fromOffset(12, 12)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = shortcutRow
end

-- Talents/Codex now wired below (the underlying panels ship in CombatClient's
-- HUD - see the hideAll()-then-open pattern). Sac needs InventoryScreen.open()
-- (a real module, not a raw panel toggle) and Boutique/Rang/Reglages have no
-- backing system yet - still grayed out.
local SHORTCUTS = {
    { key = "talents", text = "Talents",   ready = true },
    { key = "sac",     text = "Sac",       ready = false },
    { key = "boutique", text = "Boutique", ready = false },
    { key = "codex",   text = "Codex",     ready = true },
    { key = "rang",    text = "Rang",      ready = false },
    { key = "reglages", text = "\u{2699}", ready = false },
}
for i, sc in ipairs(SHORTCUTS) do
    local b = StyleConstants.makeButton(sc.text, "Body", "gray")
    b.Name = "Sc_" .. sc.key
    b.LayoutOrder = i
    b.ZIndex = TZ
    b.Active = sc.ready
    b.AutoButtonColor = false
    b.TextTransparency = sc.ready and 0 or 0.45
    b.Parent = shortcutRow
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
-- SURFACE 3 -- recompense quotidienne (daily-reward-gdd.md SS6)
--============================================================
local dailyState = nil   -- last "dailyState" payload from the server

local dailyDim = Instance.new("Frame")
dailyDim.Name = "DailyDim"
dailyDim.Size = UDim2.fromScale(1, 1)
dailyDim.BackgroundColor3 = Color3.new(0, 0, 0)
dailyDim.BackgroundTransparency = 0.5
dailyDim.BorderSizePixel = 0
dailyDim.Visible = false
dailyDim.ZIndex = TZ + 1
dailyDim.Parent = gui

local dailyPanel = Instance.new("Frame")
dailyPanel.Name = "DailyPanel"
dailyPanel.AnchorPoint = Vector2.new(0.5, 0.5)
dailyPanel.Position = UDim2.fromScale(0.5, 0.5)
dailyPanel.Size = UDim2.fromOffset(620, 0)
dailyPanel.AutomaticSize = Enum.AutomaticSize.Y
dailyPanel.BackgroundColor3 = C.Panel
dailyPanel.BorderSizePixel = 0
dailyPanel.Visible = false
dailyPanel.ZIndex = TZ + 2
dailyPanel.Parent = gui
do
    local stroke = StyleConstants.addStroke(dailyPanel, 2, StyleConstants.ButtonVariants.gold.border)
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 24) ; pad.PaddingBottom = UDim.new(0, 24)
    pad.PaddingLeft = UDim.new(0, 28) ; pad.PaddingRight = UDim.new(0, 28)
    pad.Parent = dailyPanel
    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Padding = UDim.new(0, 14)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = dailyPanel
end

local dailyTitle = label(dailyPanel, "", 24, C.Accent)
dailyTitle.Size = UDim2.new(1, 0, 0, 30)
dailyTitle.TextXAlignment = Enum.TextXAlignment.Center
dailyTitle.LayoutOrder = 1
dailyTitle.ZIndex = TZ + 3   -- above the panel's own opaque bg (TZ+2)

-- 7-day grid: a cell per day, current highlighted, past checked, future dim.
local grid = Instance.new("Frame")
grid.Name = "Grid"
grid.Size = UDim2.new(1, 0, 0, 74)
grid.BackgroundTransparency = 1
grid.LayoutOrder = 2
grid.ZIndex = TZ + 2
grid.Parent = dailyPanel
do
    local gl = Instance.new("UIGridLayout")
    gl.CellSize = UDim2.new(1/7, -6, 0, 74)
    gl.CellPadding = UDim2.fromOffset(7, 0)
    gl.SortOrder = Enum.SortOrder.LayoutOrder
    gl.Parent = grid
end
local dayCells = {}
for i = 1, GameConfig.DailyReward.chainLength do
    local cell = Instance.new("Frame")
    cell.Name = "Day" .. i
    cell.LayoutOrder = i
    cell.BackgroundColor3 = C.Slot
    cell.BorderSizePixel = 0
    cell.ZIndex = TZ + 2
    cell.Parent = grid
    StyleConstants.addStroke(cell, 1, C.Border)
    local num = label(cell, "J" .. i, 15, C.TextSecondary)
    num.Position = UDim2.fromOffset(0, 6)
    num.Size = UDim2.new(1, 0, 0, 18)
    num.TextXAlignment = Enum.TextXAlignment.Center
    num.ZIndex = TZ + 3
    local mark = label(cell, "", 22, StyleConstants.ButtonVariants.gold.border)
    mark.Name = "Mark"
    mark.Position = UDim2.fromOffset(0, 28)
    mark.Size = UDim2.new(1, 0, 0, 30)
    mark.TextXAlignment = Enum.TextXAlignment.Center
    mark.ZIndex = TZ + 3
    dayCells[i] = { cell = cell, num = num, mark = mark }
end

local dailyDesc = label(dailyPanel, "", 16, C.TextPrimary)
dailyDesc.Size = UDim2.new(1, 0, 0, 24)
dailyDesc.TextXAlignment = Enum.TextXAlignment.Center
dailyDesc.LayoutOrder = 3
dailyDesc.ZIndex = TZ + 3

local dailyNext = label(dailyPanel, "", 13, C.TextSecondary)
dailyNext.Size = UDim2.new(1, 0, 0, 18)
dailyNext.TextXAlignment = Enum.TextXAlignment.Center
dailyNext.LayoutOrder = 4
dailyNext.ZIndex = TZ + 3

local claimBtn = StyleConstants.makeButton("RECLAMER", "Body", "gold")
claimBtn.Size = UDim2.fromOffset(220, 46)
claimBtn.LayoutOrder = 5
claimBtn.ZIndex = TZ + 2
claimBtn.Parent = dailyPanel

local dailyCloseBtn = StyleConstants.makeButton("Fermer", "Label", "gray")
dailyCloseBtn.Size = UDim2.fromOffset(140, 30)
dailyCloseBtn.LayoutOrder = 6
dailyCloseBtn.ZIndex = TZ + 2
dailyCloseBtn.Parent = dailyPanel

local function renderDaily()
    if not dailyState then return end
    -- `day` = the day to claim now (canClaim) or the day just claimed (cooldown).
    -- Chequered cells: everything before `day` when still claimable, everything
    -- up to and including `day` once it's already been claimed today. A chain
    -- reset wipes the checkmarks (fresh J1).
    local checkedUpTo = dailyState.chainReset and 0
        or (dailyState.canClaim and (dailyState.day - 1) or dailyState.day)
    for i, c in ipairs(dayCells) do
        local isCurrent = (i == dailyState.day)
        local isChecked = (i <= checkedUpTo) and not isCurrent
        local st = c.cell:FindFirstChildWhichIsA("UIStroke")
        if isCurrent then
            c.cell.BackgroundColor3 = Color3.fromRGB(28, 24, 16)
            if st then st.Color = StyleConstants.ButtonVariants.gold.border; st.Thickness = 2 end
            c.mark.Text = dailyState.canClaim and "\u{2726}" or "\u{2713}"
            c.mark.TextColor3 = StyleConstants.ButtonVariants.gold.border
        elseif isChecked then
            c.cell.BackgroundColor3 = C.Slot
            if st then st.Color = C.Border; st.Thickness = 1 end
            c.mark.Text = "\u{2713}"
            c.mark.TextColor3 = StyleConstants.BaseColors.Positive
        else
            c.cell.BackgroundColor3 = C.Slot
            if st then st.Color = C.Border; st.Thickness = 1 end
            c.mark.Text = "?"
            c.mark.TextColor3 = C.TextSecondary
        end
    end
    dailyTitle.Text = string.format("RECOMPENSE DU JOUR %d / %d", dailyState.day, dailyState.chainLength)
    dailyDesc.Text = dailyState.labels and dailyState.labels[dailyState.day] or ""
    if dailyState.canClaim then
        claimBtn.Text = "RECLAMER"
        claimBtn.Active = true
        claimBtn.TextTransparency = 0
        dailyNext.Text = ""
    else
        local nextDay = (dailyState.day % dailyState.chainLength) + 1
        claimBtn.Text = "DEJA RECLAME"
        claimBtn.Active = false
        claimBtn.TextTransparency = 0.5
        dailyNext.Text = "Demain : " .. (dailyState.labels and dailyState.labels[nextDay] or "?")
    end
end

local function showDaily()
    dailyDim.Visible = true
    dailyPanel.Visible = true
    renderDaily()
end
local function hideDaily()
    dailyDim.Visible = false
    dailyPanel.Visible = false
end
do
    -- Frame has no click event: a transparent button over the dim closes on click-outside.
    local clickCatcher = Instance.new("TextButton")
    clickCatcher.BackgroundTransparency = 1
    clickCatcher.Text = ""
    clickCatcher.Size = UDim2.fromScale(1, 1)
    clickCatcher.ZIndex = TZ + 1
    clickCatcher.Parent = dailyDim
    clickCatcher.MouseButton1Click:Connect(hideDaily)
end
dailyCloseBtn.MouseButton1Click:Connect(hideDaily)
dailyBand.MouseButton1Click:Connect(showDaily)
claimBtn.MouseButton1Click:Connect(function()
    if not (dailyState and dailyState.canClaim) then return end
    combatEvent:FireServer({ type = "claimDailyReward" })
end)

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

-- Talents/Codex shortcuts: RpgGui (CombatClient's HUD, incl. TalentsPanel/
-- CodexPanel) is already built and enabled underneath TitleGui at this point
-- (both ScreenGuis Enabled=true simultaneously - TitleGui just sits on top by
-- DisplayOrder) - so hideAll() to reveal it, then open the panel directly,
-- exactly like clicking its HUD footer button mid-run would.
local function openHudPanel(panelName: string, requestType: string?)
    hideAll()
    local rpgBackground = player.PlayerGui:FindFirstChild("RpgGui", true)
        and player.PlayerGui.RpgGui:FindFirstChild("Background")
    local panel = rpgBackground and rpgBackground:FindFirstChild(panelName)
    if panel then
        panel.Visible = true
        if requestType then
            combatEvent:FireServer({ type = requestType })
        end
    end
end

local scTalents = shortcutRow:FindFirstChild("Sc_talents")
if scTalents then
    scTalents.MouseButton1Click:Connect(function()
        if dismissed or needsCreation then return end   -- no hero yet: nothing to show
        openHudPanel("TalentsPanel")
    end)
end

local scCodex = shortcutRow:FindFirstChild("Sc_codex")
if scCodex then
    scCodex.MouseButton1Click:Connect(function()
        if dismissed or needsCreation then return end
        openHudPanel("CodexPanel", "requestCodexState")
    end)
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
            -- the hero on the line reflects a returning player's build
            heroOnLine.Image = AssetMap[data.gearIsMagic and "hero_mage" or "hero_warrior"] or heroOnLine.Image
            heroOnLine.ImageColor3 = GameConfig.Hero.tints[data.heroTint or "acier"] or Color3.new(1, 1, 1)
        end
    elseif data.type == "dailyState" then
        dailyState = data.state
        dailyBand.Visible = (not dismissed) and dailyState ~= nil and dailyState.canClaim == true
        if dailyPanel.Visible then renderDaily() end
    elseif data.type == "dailyRewardClaimed" then
        if data.ok then
            claimBtn.Text = "RECU !"
            dailyDesc.Text = data.label or dailyDesc.Text
            dailyNext.Text = data.nextLabel and ("Demain : " .. data.nextLabel) or ""
            dailyBand.Visible = false
            task.delay(1.4, hideDaily)
        else
            claimBtn.Text = (data.reason == "cooldown") and "DEJA RECLAME" or "ERREUR"
        end
    end
end)

-- Gentle pulse on the daily band while it is waiting to be claimed.
task.spawn(function()
    while true do
        task.wait(1.1)
        if dailyBand.Visible then
            TweenService:Create(dailyBand, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0.35 }):Play()
            task.wait(0.55)
            TweenService:Create(dailyBand, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0 }):Play()
        end
    end
end)

-- Ask the server for the daily state once the connection is up (join already
-- pushes it, but this covers a late listener / reconnect).
combatEvent:FireServer({ type = "requestDailyState" })
