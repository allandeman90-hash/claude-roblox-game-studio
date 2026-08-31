--==============================================================
-- CombatClient  (LocalScript)
-- Receives combat data from the server and updates the existing GUI.
-- Never computes damage, HP, EXP, or gold locally.
--==============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Zone system data (decor palette + enemy roster per zone).
local ZoneConfig = require(ReplicatedStorage:WaitForChild("ZoneConfig"))
-- Slug -> rbxassetid map for the generated pixel-art sprites (GENERATED file).
local AssetMap = require(ReplicatedStorage:WaitForChild("AssetMap"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer

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

-- Compact, non-overlapping hero info: reuse the (unused) title as the HP line,
-- then stack 5 full-width rows: LV/XP, PV, Arme, Armr, Pet.
local heroPvLine = heroInfoBox:FindFirstChild("HeroTitle")
do
    local rows = { heroLevel, heroPvLine, heroWeapon, heroArmor, heroPet }
    for i, lbl in ipairs(rows) do
        if lbl then
            lbl.Position = UDim2.new(0, 10, 0.02 + (i - 1) * 0.195, 0)
            lbl.Size = UDim2.new(1, -20, 0.18, 0)
            lbl.TextScaled = false
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
        end
    end
end

-- Combat HP bars: rounded corners, no white outline.
do
    local function styleBar(bar)
        if not bar then return end
        local st = bar:FindFirstChildWhichIsA("UIStroke")
        if st then st:Destroy() end
        local function corner(o)
            if o:IsA("GuiObject") and not o:FindFirstChildWhichIsA("UICorner") then
                local uc = Instance.new("UICorner")
                uc.CornerRadius = UDim.new(0, 3)
                uc.Parent = o
            end
        end
        corner(bar)
        for _, d in ipairs(bar:GetDescendants()) do
            if d:IsA("Frame") then corner(d) end
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
local zoneLabel   = combatZone:FindFirstChild("ZoneLabel")
local statusText  = combatZone:FindFirstChild("StatusText")
local heroSlot    = combatZone:FindFirstChild("HeroSlot")
local enemySlot   = combatZone:FindFirstChild("EnemySlot")
local distLabelCZ = combatZone:FindFirstChild("DistanceLabel")

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
local function paintLayer(layer, tileColor, d)
    if not layer then return end
    for _, tile in ipairs(layer:GetChildren()) do
        if tile:IsA("GuiObject") then
            tile.BackgroundColor3 = tileColor
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
                end
            end
        end
    end
end

local appliedZone = nil
local function applyZoneDecor(zoneId)
    local cfg = ZoneConfig.getZone(zoneId)
    if not (cfg and cfg.decor) then return end
    local d = cfg.decor
    paintLayer(farLayer, d.farSky, d)
    paintLayer(midLayer, d.midSky, d)
    paintLayer(nearLayer, d.ground, d)
end

-- HeroTimeBox: ZONE / DIST + all-time record + this-session XP/min & gold/min.
local timeLabel   = heroTimeBox:FindFirstChild("TimeLabel")
local timeValue   = heroTimeBox:FindFirstChild("TimeValue")
local distLabel   = heroTimeBox:FindFirstChild("DistLabel")
do
    local rows = {
        { timeLabel, timeValue },
        { distLabel, distValue },
    }
    local function mkRow(name, labelText)
        local lbl = heroTimeBox:FindFirstChild(name .. "Label")
        local val = heroTimeBox:FindFirstChild(name .. "Value")
        if not lbl then
            lbl = timeLabel:Clone() ; lbl.Name = name .. "Label" ; lbl.Text = labelText ; lbl.Parent = heroTimeBox
        end
        if not val then
            val = timeValue:Clone() ; val.Name = name .. "Value" ; val.Text = "" ; val.Parent = heroTimeBox
        end
        return { lbl, val }
    end
    rows[3] = mkRow("Record", "RECORD")
    rows[4] = mkRow("Rate", "/MIN")
    for i, pair in ipairs(rows) do
        local y = 0.02 + (i - 1) * 0.245
        if pair[1] then
            pair[1].Position = UDim2.new(0, 14, y, 0)
            pair[1].Size = UDim2.new(0.34, 0, 0.22, 0)
            pair[1].TextSize = 12
        end
        if pair[2] then
            pair[2].Position = UDim2.new(0.36, 0, y, 0)
            pair[2].Size = UDim2.new(0.62, -14, 0.22, 0)
            pair[2].TextSize = 13
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
local BASE_SPRITE_W, BASE_SPRITE_H = 0.55, 0.55   -- ~55px mob
local BOSS_SPRITE_MUL = 1.5
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
                tag.Visible = not enc.cleared
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
    if enemyHpPanel then enemyHpPanel.Visible = (activeIndex ~= nil) end

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
    for i = 1, 10 do ztTicks[i] = ztRail:FindFirstChild("Tick" .. i) end
end

local function updateZoneTrack(data)
    if not zoneTrack then return end
    if ztLabel then
        ztLabel.Text = string.format("ZONE %d \u{00B7} ET.%d/%d",
            data.zone or 1, data.stepIndex or 1, data.stepsPerZone or 10)
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
end

--===== Top HUD (deaths / zone progress / distance+speed) =====
local topSection = background:FindFirstChild("TopSection")
local topDeath = topSection and topSection:FindFirstChild("DeathBox") and topSection.DeathBox:FindFirstChild("Label")
local topRight = topSection and topSection:FindFirstChild("RightBox") and topSection.RightBox:FindFirstChild("Label")

local function updateTopHud(data)
    if topDeath then topDeath.Text = string.format("\u{1F480} %d", data.deaths or 0) end
    if topRight then
        local ws = data.worldSpeed or 1
        topRight.Text = (ws > 1)
            and string.format("%.1f KM   x%.1f", data.pos or 0, ws)
            or string.format("%.1f KM", data.pos or 0)
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
local reviveButton      = gameOverWindow and gameOverWindow:FindFirstChild("ReviveButton")
local reviveProductId   = 0

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
    lowHpActive = (data.playerHp or 0) > 0 and playerRatio <= 0.20 and not (data.gameOver == true)

    -- Enemy HP bar + name
    local enemyRatio = math.clamp(data.enemyHp / math.max(1, data.enemyMaxHp), 0, 1)
    enemyHpFill.Size = UDim2.new(enemyRatio, 0, 1, 0)
    enemyHpText.Text = string.format("%d/%d", data.enemyHp, data.enemyMaxHp)
    enemyName.Text = string.format("%s Lv.%d", data.enemyName, data.enemyLevel)

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

    -- Rebirth button: icone seule (assets/images/rebirthicon, fond detoure),
    -- centree. Pas de texte. Attenuee quand le rebirth n'est pas payable.
    if rebirthButton then
        local ic = rebirthButton:FindFirstChild("Icon")
        if ic then ic.ImageTransparency = data.canRebirth and 0 or 0.5 end
    end

    -- Enemy info panel: only populated during an actual fight (no default mob).
    local inFight = false
    for _, e in ipairs(data.encounters or {}) do
        if e and e.active then inFight = true break end
    end
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
    else
        local diffCol = difficultyColour(data, data.enemyMaxHp, data.enemyAtk, data.enemyDamageType == "magic")
        infoName.Text  = data.enemyName
        infoName.TextColor3 = diffCol
        infoLevel.Text = string.format("Lv %d", data.enemyLevel or 0)
        infoLevel.TextColor3 = diffCol
        infoMaxHp.Text = string.format("PV:  %d / %d", data.enemyHp or 0, data.enemyMaxHp or 0)
        infoExp.Text   = string.format("EXP: %d", data.enemyExp or 0)
        if data.enemyIsBoss and data.enemyAtkSplit then
            local atkPct = math.floor(data.enemyAtkSplit * 100 + 0.5)
            if infoAtk then infoAtk.Text = string.format("ATK: %d%%", atkPct) end
            if infoInt then infoInt.Text = string.format("INT: %d%%", 100 - atkPct) end
            if infoType then infoType.Text = (data.enemyDamageType == "magic") and "TYPE: MAGIQUE" or "TYPE: PHYSIQUE" end
        else
            if infoAtk then infoAtk.Text = "ATK: --" end
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
            statusText.Text = "Walking..."
            statusText.TextColor3 = Color3.fromRGB(100, 200, 100)
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

    -- HeroTimeBox: zone / distance / all-time record / this-session rates.
    if timeValue then timeValue.Text = tostring(data.zone) end
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
combatEvent.OnClientEvent:Connect(function(data)
    if data.type == "update" then
        updateUI(data)
    elseif data.type == "damage" then
        createDamageNumber(data.target, data.amount, data.isCrit)
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
        reviveProductId = data.productId or 0
        if reviveButton then
            reviveButton.Text = string.format("RÉAPPARAÎTRE\n%d ROBUX", data.revivePrice or 0)
        end
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

if reviveButton then
    reviveButton.MouseButton1Click:Connect(function()
        if reviveProductId > 0 then
            MarketplaceService:PromptProductPurchase(player, reviveProductId)
        end
    end)
end

--===== Rebirth button (GAME_SPEC.md 8.1) =====
if rebirthButton then
    rebirthButton.MouseButton1Click:Connect(function()
        combatEvent:FireServer({ type = "rebirth" })
    end)
end

--===== ⚠️ DEV ONLY — REMOVE BEFORE RELEASE : progression reset button =====
local DEV_MODE = true
if DEV_MODE and background then
    local devBtn = Instance.new("TextButton")
    devBtn.Name = "DevReset"
    devBtn.Text = "RESET (DEV)"
    devBtn.Font = Enum.Font.Code
    devBtn.TextSize = 11
    devBtn.TextColor3 = Color3.fromRGB(255, 210, 210)
    devBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
    devBtn.BackgroundTransparency = 0.15
    devBtn.BorderSizePixel = 0
    devBtn.AnchorPoint = Vector2.new(0, 0)
    devBtn.Position = UDim2.new(0, 6, 0, 44)
    devBtn.Size = UDim2.new(0, 94, 0, 20)
    devBtn.ZIndex = 50
    devBtn.Parent = background
    devBtn.MouseButton1Click:Connect(function()
        combatEvent:FireServer({ type = "devReset" })
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
    local menuBtn   = menuPanel and menuPanel:FindFirstChild("MenuButton")
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
        heroSlot.Position = UDim2.new(nx, 0, SCENE_Y + bob, 0)
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
        enemyHpPanel.Position = UDim2.new(enemyHpTargetX, 0, GROUND_Y + 0.02, 0)
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

