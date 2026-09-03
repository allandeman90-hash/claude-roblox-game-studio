--!strict
--==============================================================
-- FtueClient  (LocalScript - StarterPlayerScripts)
--
-- Renders the FTUE coach-marks the server tells it to show
-- (onboarding-gdd.md). The server owns the flow; this script only draws what
-- it is told and reports "Compris" / auto-dismiss back as an ack.
--
-- Transport: multiplexed over ReplicatedStorage.CombatEvent, same as
-- CombatClient. Adds its OWN OnClientEvent connection (multiple listeners on
-- one RemoteEvent is fine) and its OWN ScreenGui so it never depends on the
-- hand-built RpgGui tree.
--
-- Messages in:  { type="ftueState", ftue=... }
--               { type="ftueStep",  stepId="move"|"equip"|"warning" }
--               { type="ftueGift",  petId="fee" }
-- Messages out: { type="ftueAck",   stepId="move"|"warning" }
--               { type="requestInventory" }   (the "equip" step's CTA)
--==============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local StyleConstants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StyleConstants"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local AssetMap = require(ReplicatedStorage:WaitForChild("AssetMap"))

local player = Players.LocalPlayer
local combatEvent = ReplicatedStorage:WaitForChild("CombatEvent") :: RemoteEvent

-- Client-side UI bus (InventoryClient creates it). Used so the "ouvre ton
-- inventaire" coach-mark can open the bag directly.
local function openBag()
    local bus = ReplicatedStorage:FindFirstChild("UiBus")
    if bus then
        (bus :: BindableEvent):Fire("openInventory")
    end
    combatEvent:FireServer({ type = "requestInventory" })
end

local function closeBag()
    local bus = ReplicatedStorage:FindFirstChild("UiBus")
    if bus then
        (bus :: BindableEvent):Fire("closeInventory")
    end
end

local C = StyleConstants.BaseColors
local FTUE_Z = StyleConstants.ZIndexLayers.FTUE_OVERLAY
local AUTO_DISMISS = GameConfig.Ftue.coachMarkAutoDismissSeconds
local MIN_SHOW = GameConfig.Ftue.coachMarkMinDisplaySeconds

--===== Copy (fr, chat-filter-safe) ============================================
local COACH = {
    move = {
        body = "Tiens ◀ / ▶ pour avancer et reculer. Marche vers un monstre pour l'affronter.",
        cta  = "Compris",
    },
    equip = {
        body = "Tu as reçu l'Épée en bois. Ouvre ton <font color=\"#C9A878\"><b>inventaire</b></font> et équipe-la.",
        cta  = "Ouvrir l'inventaire",
    },
    warning = {
        title = "Ce monde ne te fera pas de cadeau",
        body  = table.concat({
            "Tu vas mourir vite, et souvent. C'est normal : à chaque mort tu repars du début — mais tu gardes tout ce que tu as gagné.",
            "",
            "Tu deviens plus fort de 4 façons :",
            "• Niveau — chaque monstre tué te fait monter (plus de PV, plus d'ATK)",
            "• Équipement — arme, armure et familiers tombent en combat ou s'achètent au feu de camp",
            "• Forge — améliore une pièce que tu aimes pour la garder plus longtemps",
            "• Familiers — ils frappent, encaissent ou te soignent selon leur rôle",
            "",
            "Plus tu descends dans les Couches, plus le butin est puissant.",
        }, "\n"),
        align = Enum.TextXAlignment.Left,
        cta   = "Je suis prêt",
    },
}
-- End-of-tutorial: the player picks ONE of three eggs (Pokémon-starter style).
local EGG_CHOICE = {
    title = "Choisis ton premier familier",
    intro = table.concat({
        "Un familier combat avec toi en permanence — un bonus passif toujours actif.",
        "Tu pourras changer son rôle plus tard au feu de camp.",
    }, "\n"),
    -- order = display order (left -> right)
    order = { "heal", "dps", "tank" },
    eggs = {
        heal = {
            eggColor = Color3.fromRGB(96, 182, 104),   -- vert
            name = "Lutin", label = "SOIN",
            blurb = "Te régénère régulièrement. À haut rang, purge les malus / l'étourdissement ; un familier mythique te ressuscite une fois.",
        },
        dps = {
            eggColor = Color3.fromRGB(214, 96, 84),     -- rouge
            name = "Fée", label = "DPS",
            blurb = "Ajoute un pourcentage de tes dégâts à chaque coup.",
        },
        tank = {
            eggColor = Color3.fromRGB(86, 148, 232),    -- bleu
            name = "Golem", label = "TANK",
            blurb = "Augmente tes PV max et ta DÉF.",
        },
    },
    footer = "Plus son rang est élevé, plus l'effet est fort. En trouver d'autres : ~1% sur un monstre, ~0,1% sur un boss, ou au feu de camp.",
}

-- Per-role text for the card shown after the egg hatches.
local function petCardCopy(role)
    local e = EGG_CHOICE.eggs[role] or EGG_CHOICE.eggs.dps
    return {
        title = string.format("Ton familier — <font color=\"#C9A878\">%s · %s · Commun</font>", e.name, e.label),
        body  = table.concat({
            e.blurb,
            "",
            "Rôle changeable au feu de camp. Plus la rareté est haute et la Couche profonde, plus il est puissant.",
        }, "\n"),
        cta   = "Commencer l'aventure",
    }
end

--===== ScreenGui =============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FtueGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false          -- keeps clear of the reserved top bar
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 50
gui.Enabled = true
gui.Parent = player:WaitForChild("PlayerGui")

--===== Small builders =======================================================
local function panel(size: UDim2, pos: UDim2, anchor: Vector2): Frame
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.AnchorPoint = anchor
    f.BackgroundColor3 = C.Panel
    f.BorderSizePixel = 0
    f.ZIndex = FTUE_Z
    f.Visible = false
    f.Parent = gui
    StyleConstants.addCorner(f, 0)
    local s = StyleConstants.addStroke(f, 2, C.Border)
    s.LineJoinMode = Enum.LineJoinMode.Miter
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 14) ; pad.PaddingBottom = UDim.new(0, 14)
    pad.PaddingLeft = UDim.new(0, 16) ; pad.PaddingRight = UDim.new(0, 16)
    pad.Parent = f
    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.VerticalAlignment = Enum.VerticalAlignment.Center
    list.Padding = UDim.new(0, 10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = f
    return f
end

local function label(parent: Frame, text: string, level: string, color: Color3, order: number): TextLabel
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.Font = StyleConstants.Fonts.Body
    l.RichText = true
    l.Text = text
    l.TextColor3 = color
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Center
    l.ZIndex = FTUE_Z
    l.LayoutOrder = order
    l.Parent = parent
    StyleConstants.applyTypography(l, level)
    return l
end

--===== Dim backdrop (warning + gift only; move/equip stay non-modal) =========
local dim = Instance.new("Frame")
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 0.45
dim.BorderSizePixel = 0
dim.ZIndex = FTUE_Z - 1
dim.Visible = false
dim.Parent = gui

--===== The two surfaces =====================================================
-- Coach-mark bubble (move / equip): small, near an edge, non-modal.
local bubble = panel(UDim2.fromOffset(360, 0), UDim2.fromScale(0.5, 0.82), Vector2.new(0.5, 1))
bubble.AutomaticSize = Enum.AutomaticSize.Y
-- Body is a TextButton so the "inventaire" word in the sentence is itself clickable.
local bubbleBody = Instance.new("TextButton")
bubbleBody.BackgroundTransparency = 1
bubbleBody.AutoButtonColor = false
bubbleBody.Size = UDim2.new(1, 0, 0, 0)
bubbleBody.AutomaticSize = Enum.AutomaticSize.Y
bubbleBody.Font = StyleConstants.Fonts.Body
bubbleBody.RichText = true
bubbleBody.Text = ""
bubbleBody.TextColor3 = C.TextPrimary
bubbleBody.TextWrapped = true
bubbleBody.TextXAlignment = Enum.TextXAlignment.Center
bubbleBody.ZIndex = FTUE_Z
bubbleBody.LayoutOrder = 1
bubbleBody.Parent = bubble
StyleConstants.applyTypography(bubbleBody, "Body")
local bubbleBtn = StyleConstants.makeButton("", "Body", "gold")
bubbleBtn.Size = UDim2.fromOffset(220, 40)
bubbleBtn.LayoutOrder = 2
bubbleBtn.ZIndex = FTUE_Z
bubbleBtn.Parent = bubble

-- Modal card (warning / gift): centered, dimmed behind.
local card = panel(UDim2.fromOffset(520, 0), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
card.AutomaticSize = Enum.AutomaticSize.Y
local cardTitle = label(card, "", "Heading", C.Accent, 1)
local cardBody = label(card, "", "Body", C.TextPrimary, 2)
local cardBtn = StyleConstants.makeButton("", "Body", "gold")
cardBtn.Size = UDim2.fromOffset(240, 44)
cardBtn.LayoutOrder = 3
cardBtn.ZIndex = FTUE_Z
cardBtn.Parent = card

-- Pop-in scale for the modal card (the pet card slides/fades in after the hatch).
local cardScale = Instance.new("UIScale")
cardScale.Scale = 1
cardScale.Parent = card

--===== Egg hatch stage =====================================================
-- A full-screen transparent layer that plays the "egg wobbles, cracks open,
-- pet pops out" sequence before the pet briefing card appears.
local hatchStage = Instance.new("Frame")
hatchStage.Name = "HatchStage"
hatchStage.Size = UDim2.fromScale(1, 1)
hatchStage.BackgroundTransparency = 1
hatchStage.BorderSizePixel = 0
hatchStage.ZIndex = FTUE_Z
hatchStage.Visible = false
hatchStage.Parent = gui

local function newFrame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.ZIndex = FTUE_Z
    for k, v in pairs(props) do
        (f :: any)[k] = v
    end
    f.Parent = parent
    return f
end

-- The egg (built from primitives - no uploaded asset needed).
local egg = newFrame(hatchStage, {
    Name = "Egg",
    Position = UDim2.fromScale(0.5, 0.42),
    Size = UDim2.fromOffset(78, 100),
    BackgroundColor3 = Color3.fromRGB(236, 226, 198),
})
do
    local c = Instance.new("UICorner") ; c.CornerRadius = UDim.new(1, 0) ; c.Parent = egg
    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(246, 238, 214)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 196, 158)),
    })
    g.Parent = egg
    local hi = newFrame(egg, {
        Name = "Hi", Position = UDim2.fromScale(0.36, 0.3), Size = UDim2.fromOffset(20, 26),
        BackgroundColor3 = Color3.fromRGB(252, 248, 234), BackgroundTransparency = 0.25,
    })
    local hc = Instance.new("UICorner") ; hc.CornerRadius = UDim.new(1, 0) ; hc.Parent = hi
    for i, p in ipairs({ { 0.6, 0.4 }, { 0.4, 0.62 }, { 0.62, 0.72 } }) do
        local s = newFrame(egg, {
            Name = "Speck" .. i, Position = UDim2.fromScale(p[1], p[2]), Size = UDim2.fromOffset(7, 7),
            BackgroundColor3 = Color3.fromRGB(196, 180, 138),
        })
        local sc = Instance.new("UICorner") ; sc.CornerRadius = UDim.new(1, 0) ; sc.Parent = s
    end
end
local eggScale = Instance.new("UIScale") ; eggScale.Parent = egg

-- White flash + golden burst ring, reused across the sequence.
local flash = newFrame(hatchStage, {
    Name = "Flash", Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(260, 260),
    BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
})
do local fc = Instance.new("UICorner") ; fc.CornerRadius = UDim.new(1, 0) ; fc.Parent = flash end

local ring = newFrame(hatchStage, {
    Name = "Ring", Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(120, 120),
    BackgroundTransparency = 1,
})
do
    local rc = Instance.new("UICorner") ; rc.CornerRadius = UDim.new(1, 0) ; rc.Parent = ring
    local rs = Instance.new("UIStroke") ; rs.Thickness = 3 ; rs.Color = C.Accent ; rs.Parent = ring
end

local petImg = Instance.new("ImageLabel")
petImg.Name = "PetSprite"
petImg.AnchorPoint = Vector2.new(0.5, 0.5)
petImg.Position = UDim2.fromScale(0.5, 0.42)
petImg.Size = UDim2.fromOffset(140, 140)
petImg.BackgroundTransparency = 1
petImg.ResampleMode = Enum.ResamplerMode.Pixelated
petImg.ImageTransparency = 1
petImg.ZIndex = FTUE_Z + 1
petImg.Parent = hatchStage

local TS = TweenService
local petHovering = false
local function tw(inst, time, style, dir, goal)
    local t = TS:Create(inst, TweenInfo.new(time, style, dir), goal)
    t:Play()
    return t
end

local function playEggHatch(role, onDone)
    role = role or "dps"
    local eggInfo = EGG_CHOICE.eggs[role] or EGG_CHOICE.eggs.dps
    hatchStage.Visible = true
    dim.Visible = true
    -- reset + tint the egg to the chosen colour
    egg.Visible = true
    egg.Rotation = 0
    egg.BackgroundColor3 = eggInfo.eggColor:Lerp(Color3.new(1, 1, 1), 0.55)
    eggScale.Scale = 0
    flash.BackgroundTransparency = 1
    flash.Size = UDim2.fromOffset(260, 260)
    ring.Size = UDim2.fromOffset(120, 120)
    local rs = ring:FindFirstChildOfClass("UIStroke") ; if rs then rs.Transparency = 1 end
    petImg.ImageTransparency = 1
    petImg.Image = AssetMap["pet_" .. role] or AssetMap.pet_dps or ""
    petImg.Size = UDim2.fromOffset(140, 140)
    petImg.Position = UDim2.fromScale(0.5, 0.42)

    task.spawn(function()
        -- 1. egg drops in
        tw(eggScale, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
        task.wait(0.42)
        -- 2. wobble, three accelerating cycles
        for _, ang in ipairs({ 11, -11, 9, -9, 6, -6, 0 }) do
            tw(egg, 0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, { Rotation = ang })
            task.wait(0.1)
        end
        task.wait(0.12)
        -- 3. anticipation squash then stretch
        tw(eggScale, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Scale = 0.88 })
        task.wait(0.14)
        tw(eggScale, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Scale = 1.12 })
        task.wait(0.1)
        -- 4. crack: flash + egg bursts into shell fragments
        flash.BackgroundTransparency = 0.15
        tw(flash, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { BackgroundTransparency = 1 })
        egg.Visible = false
        local shardColor = eggInfo.eggColor:Lerp(Color3.new(1, 1, 1), 0.45)
        for i = 1, 8 do
            local a = (i / 8) * math.pi * 2
            local shard = newFrame(hatchStage, {
                Name = "Shard", Position = UDim2.fromScale(0.5, 0.42),
                Size = UDim2.fromOffset(math.random(10, 18), math.random(8, 14)),
                BackgroundColor3 = shardColor, Rotation = math.random(0, 360),
            })
            local dist = math.random(120, 220)
            tw(shard, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                Position = UDim2.new(0.5, math.cos(a) * dist, 0.42, math.sin(a) * dist * 0.7 + 120),
                Rotation = shard.Rotation + math.random(-260, 260),
                BackgroundTransparency = 1,
            })
            task.delay(0.65, function() shard:Destroy() end)
        end
        -- ring burst
        if rs then rs.Transparency = 0.05 end
        tw(ring, 0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Size = UDim2.fromOffset(520, 520) })
        if rs then tw(rs, 0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Transparency = 1 }) end
        -- 5. pet pops out, rises, overshoots, settles
        petImg.ImageTransparency = 0
        petImg.Size = UDim2.fromOffset(0, 0)
        tw(petImg, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
            Size = UDim2.fromOffset(140, 140),
            Position = UDim2.fromScale(0.5, 0.28),
        })
        task.wait(0.35)
        if onDone then onDone() end
        -- 6. keep hovering under the card until the beat is dismissed
        petHovering = true
        task.spawn(function()
            local up = true
            while petHovering and petImg.ImageTransparency < 1 do
                tw(petImg, 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut,
                    { Position = UDim2.fromScale(0.5, up and 0.26 or 0.28) })
                up = not up
                task.wait(0.6)
            end
        end)
    end)
end

local function hideHatchStage()
    petHovering = false
    hatchStage.Visible = false
    petImg.ImageTransparency = 1
end

--===== State ================================================================
local currentStep: string? = nil
local shownAt = 0
local autoThread: thread? = nil

--===== Egg-choice stage (Pokémon-starter style) ============================
local choiceStage = Instance.new("Frame")
choiceStage.Name = "EggChoice"
choiceStage.AnchorPoint = Vector2.new(0.5, 0.5)
choiceStage.Position = UDim2.fromScale(0.5, 0.5)
choiceStage.Size = UDim2.fromOffset(720, 452)
choiceStage.BackgroundColor3 = Color3.fromRGB(16, 17, 21)
choiceStage.BorderSizePixel = 0
choiceStage.ZIndex = FTUE_Z
choiceStage.Visible = false
choiceStage.Parent = gui
local choiceScale = Instance.new("UIScale") ; choiceScale.Parent = choiceStage
do
    local s = StyleConstants.addStroke(choiceStage, 1, C.Border)
    s.LineJoinMode = Enum.LineJoinMode.Miter
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 18) ; pad.PaddingBottom = UDim.new(0, 16)
    pad.PaddingLeft = UDim.new(0, 24) ; pad.PaddingRight = UDim.new(0, 24)
    pad.Parent = choiceStage
end

do
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Size = UDim2.new(1, 0, 0, 26)
    t.Font = StyleConstants.Fonts.Heading
    t.Text = EGG_CHOICE.title
    t.TextColor3 = C.Accent
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = FTUE_Z
    t.Parent = choiceStage
    StyleConstants.applyTypography(t, "Heading")

    local intro = Instance.new("TextLabel")
    intro.BackgroundTransparency = 1
    intro.Position = UDim2.fromOffset(0, 30)
    intro.Size = UDim2.new(1, 0, 0, 38)
    intro.Font = StyleConstants.Fonts.Body
    intro.RichText = true
    intro.Text = EGG_CHOICE.intro
    intro.TextColor3 = C.TextPrimary
    intro.TextWrapped = true
    intro.TextXAlignment = Enum.TextXAlignment.Left
    intro.TextYAlignment = Enum.TextYAlignment.Top
    intro.ZIndex = FTUE_Z
    intro.Parent = choiceStage
    StyleConstants.applyTypography(intro, "Label")

    local foot = Instance.new("TextLabel")
    foot.AnchorPoint = Vector2.new(0, 1)
    foot.BackgroundTransparency = 1
    foot.Position = UDim2.new(0, 0, 1, 0)
    foot.Size = UDim2.new(1, 0, 0, 30)
    foot.Font = StyleConstants.Fonts.Body
    foot.Text = EGG_CHOICE.footer
    foot.TextColor3 = C.TextSecondary
    foot.TextWrapped = true
    foot.TextXAlignment = Enum.TextXAlignment.Left
    foot.TextYAlignment = Enum.TextYAlignment.Bottom
    foot.ZIndex = FTUE_Z
    foot.Parent = choiceStage
    StyleConstants.applyTypography(foot, "Label")
end

-- forward-declared; the egg buttons call it
local onEggChosen

-- Builds one decorated egg (glow + shaded shell + shine + speckles) inside `col`.
-- Returns the egg frame, its UIScale, and a fn to (re)start its idle bob/rock.
local function buildEgg(col, color)
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.5, 0, 0, 70)
    glow.Size = UDim2.fromOffset(120, 120)
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = 0.82
    glow.BorderSizePixel = 0
    glow.ZIndex = FTUE_Z
    glow.Parent = col
    local gc = Instance.new("UICorner") ; gc.CornerRadius = UDim.new(1, 0) ; gc.Parent = glow

    local egg = Instance.new("Frame")
    egg.Name = "Egg"
    egg.AnchorPoint = Vector2.new(0.5, 0.5)
    egg.Position = UDim2.new(0.5, 0, 0, 70)
    egg.Size = UDim2.fromOffset(72, 92)
    egg.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.35)
    egg.BorderSizePixel = 0
    egg.ZIndex = FTUE_Z + 1
    egg.Parent = col
    local eScale = Instance.new("UIScale") ; eScale.Parent = egg
    local ecn = Instance.new("UICorner") ; ecn.CornerRadius = UDim.new(0.48, 0) ; ecn.Parent = egg
    local est = Instance.new("UIStroke")
    est.Thickness = 2 ; est.Color = color:Lerp(Color3.new(0, 0, 0), 0.35) ; est.Transparency = 0.2
    est.Parent = egg
    local eg = Instance.new("UIGradient")
    eg.Rotation = 90
    eg.Color = ColorSequence.new(
        color:Lerp(Color3.new(1, 1, 1), 0.65),
        color:Lerp(Color3.new(0, 0, 0), 0.22)
    )
    eg.Parent = egg
    -- shine
    local shine = Instance.new("Frame")
    shine.AnchorPoint = Vector2.new(0.5, 0.5)
    shine.Position = UDim2.fromScale(0.36, 0.3)
    shine.Size = UDim2.fromOffset(18, 26)
    shine.BackgroundColor3 = Color3.new(1, 1, 1)
    shine.BackgroundTransparency = 0.35
    shine.BorderSizePixel = 0
    shine.ZIndex = FTUE_Z + 2
    shine.Rotation = -18
    shine.Parent = egg
    local shc = Instance.new("UICorner") ; shc.CornerRadius = UDim.new(1, 0) ; shc.Parent = shine
    -- speckles
    for _, p in ipairs({ { 0.62, 0.44 }, { 0.4, 0.66 }, { 0.66, 0.74 }, { 0.3, 0.4 } }) do
        local sp = Instance.new("Frame")
        sp.AnchorPoint = Vector2.new(0.5, 0.5)
        sp.Position = UDim2.fromScale(p[1], p[2])
        sp.Size = UDim2.fromOffset(7, 7)
        sp.BackgroundColor3 = color:Lerp(Color3.new(0, 0, 0), 0.3)
        sp.BackgroundTransparency = 0.15
        sp.BorderSizePixel = 0
        sp.ZIndex = FTUE_Z + 2
        sp.Parent = egg
        local spc = Instance.new("UICorner") ; spc.CornerRadius = UDim.new(1, 0) ; spc.Parent = sp
    end
    return egg, eScale, glow
end

local choiceEggs = {}   -- {egg, glow, phase} — animated by ONE shared loop below

for i, role in ipairs(EGG_CHOICE.order) do
    local info = EGG_CHOICE.eggs[role]
    local col = Instance.new("TextButton")
    col.Name = "Egg_" .. role
    col.AutoButtonColor = false
    col.BackgroundColor3 = C.Slot
    col.BackgroundTransparency = 0.25
    col.BorderSizePixel = 0
    col.Text = ""
    col.Position = UDim2.new((i - 1) / 3, 8, 0, 80)
    col.Size = UDim2.new(1 / 3, -16, 1, -122)
    col.ZIndex = FTUE_Z
    col.Parent = choiceStage
    local ccn = Instance.new("UICorner") ; ccn.CornerRadius = UDim.new(0, 4) ; ccn.Parent = col
    local cs = Instance.new("UIStroke")
    cs.Thickness = 1 ; cs.Color = C.Border ; cs.Transparency = 0.1 ; cs.LineJoinMode = Enum.LineJoinMode.Miter
    cs.Parent = col

    local egg, eScale, glow = buildEgg(col, info.eggColor)

    -- role pill
    local pill = Instance.new("Frame")
    pill.AnchorPoint = Vector2.new(0.5, 0)
    pill.Position = UDim2.new(0.5, 0, 0, 128)
    pill.Size = UDim2.fromOffset(96, 22)
    pill.BackgroundColor3 = info.eggColor
    pill.BackgroundTransparency = 0.8
    pill.BorderSizePixel = 0
    pill.ZIndex = FTUE_Z + 1
    pill.Parent = col
    local pc = Instance.new("UICorner") ; pc.CornerRadius = UDim.new(1, 0) ; pc.Parent = pill
    local ps = Instance.new("UIStroke") ; ps.Color = info.eggColor ; ps.Transparency = 0.3 ; ps.Parent = pill
    local roleLbl = Instance.new("TextLabel")
    roleLbl.BackgroundTransparency = 1
    roleLbl.Size = UDim2.fromScale(1, 1)
    roleLbl.Font = StyleConstants.Fonts.Heading
    roleLbl.Text = info.label
    roleLbl.TextColor3 = info.eggColor:Lerp(Color3.new(1, 1, 1), 0.25)
    roleLbl.ZIndex = FTUE_Z + 2
    roleLbl.Parent = pill
    StyleConstants.applyTypography(roleLbl, "Label")

    local blurb = Instance.new("TextLabel")
    blurb.BackgroundTransparency = 1
    blurb.Position = UDim2.fromOffset(12, 158)
    blurb.Size = UDim2.new(1, -24, 1, -168)
    blurb.Font = StyleConstants.Fonts.Body
    blurb.Text = info.blurb
    blurb.TextColor3 = C.TextPrimary
    blurb.TextWrapped = true
    blurb.TextXAlignment = Enum.TextXAlignment.Center
    blurb.TextYAlignment = Enum.TextYAlignment.Top
    blurb.ZIndex = FTUE_Z + 1
    blurb.Parent = col
    StyleConstants.applyTypography(blurb, "Label")

    choiceEggs[#choiceEggs + 1] = { egg = egg, glow = glow, phase = i * 0.7 }

    local function setHover(on)
        cs.Color = on and info.eggColor or C.Border
        cs.Transparency = on and 0 or 0.1
        col.BackgroundTransparency = on and 0.08 or 0.25
        TweenService:Create(eScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Scale = on and 1.1 or 1 }):Play()
        TweenService:Create(glow, TweenInfo.new(0.15), { BackgroundTransparency = on and 0.62 or 0.82 }):Play()
    end
    col.MouseEnter:Connect(function() setHover(true) end)
    col.MouseLeave:Connect(function() setHover(false) end)
    col.Activated:Connect(function()
        if onEggChosen then onEggChosen(role) end
    end)
end

local eggIdleRunning = false
local function showEggChoice()
    choiceStage.Visible = true
    dim.Visible = true
    choiceScale.Scale = 0.9
    TweenService:Create(choiceScale, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    currentStep = "pet"
    shownAt = os.clock()
    -- ONE idle loop for all three eggs; exits for good once the screen closes.
    if not eggIdleRunning then
        eggIdleRunning = true
        task.spawn(function()
            while choiceStage.Visible do
                local now = os.clock()
                for _, e in ipairs(choiceEggs) do
                    local t = now + e.phase
                    e.egg.Position = UDim2.new(0.5, 0, 0, 70 + math.sin(t * 1.6) * 5)
                    e.egg.Rotation = math.sin(t * 1.1) * 3
                    e.glow.BackgroundTransparency = 0.82 + math.sin(t * 2) * 0.06
                end
                task.wait(1 / 30)
            end
            eggIdleRunning = false
        end)
    end
end

local function hideEggChoice()
    choiceStage.Visible = false
end

local function clearAuto()
    if autoThread then
        task.cancel(autoThread)
        autoThread = nil
    end
end

local function hideAll()
    clearAuto()
    bubble.Visible = false
    card.Visible = false
    dim.Visible = false
    hideHatchStage()
    hideEggChoice()
    currentStep = nil
end

local function ack(stepId: string)
    -- honour the minimum display time so a fast auto-dismiss never feels abrupt
    local remaining = MIN_SHOW - (os.clock() - shownAt)
    if remaining > 0 then task.wait(remaining) end
    combatEvent:FireServer({ type = "ftueAck", stepId = stepId })
end

local function armAutoDismiss(stepId: string)
    clearAuto()
    autoThread = task.delay(AUTO_DISMISS, function()
        autoThread = nil
        if currentStep == stepId then
            hideAll()
            ack(stepId)
        end
    end)
end

--===== Step rendering ======================================================
local function showStep(stepId: string)
    if currentStep == stepId then return end
    hideAll()
    currentStep = stepId
    shownAt = os.clock()

    if stepId == "move" then
        bubbleBody.Text = COACH.move.body
        bubbleBtn.Text = COACH.move.cta
        bubble.Visible = true
        armAutoDismiss("move")

    elseif stepId == "equip" then
        bubbleBody.Text = COACH.equip.body
        bubbleBtn.Text = COACH.equip.cta
        bubble.Visible = true
        -- no auto-dismiss: the server advances this beat when a weapon is equipped

    elseif stepId == "warning" then
        cardTitle.Text = COACH.warning.title
        cardBody.Text = COACH.warning.body
        cardBody.TextXAlignment = COACH.warning.align or Enum.TextXAlignment.Center
        cardBtn.Text = COACH.warning.cta
        card.AnchorPoint = Vector2.new(0.5, 0.5)
        card.Position = UDim2.fromScale(0.5, 0.5)
        cardScale.Scale = 1
        dim.Visible = true
        card.Visible = true
        -- no auto-dismiss: this panel carries the "how to get stronger" briefing,
        -- the player reads it and clicks. (The tutorial only completes on the ack.)
    end
end

-- The pet briefing card, shown AFTER the hatch (pet still hovering above it).
local function showPetCard(role)
    local copy = petCardCopy(role or "dps")
    cardBody.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Text = copy.title
    cardBody.Text = copy.body
    cardBtn.Text = copy.cta
    card.AnchorPoint = Vector2.new(0.5, 0)
    card.Position = UDim2.fromScale(0.5, 0.46)
    dim.Visible = true
    card.Visible = true
    cardScale.Scale = 0.9
    TweenService:Create(cardScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Scale = 1 }):Play()
    currentStep = "pet"
    shownAt = os.clock()
end

-- ftueGift beat: close the bag so the reveal is visible, then show the 3 eggs.
-- Re-entrant guarded: the server re-pushes ftueGift on every respawn /
-- ftueRequestState while the step is still "pet", so ignore it if the reveal
-- (choice / hatch / pet card) is already on screen or has been completed.
local petRevealDone = false
local function startPetReveal()
    if petRevealDone then return end
    if choiceStage.Visible or hatchStage.Visible then return end
    if currentStep == "pet" and card.Visible then return end
    closeBag()
    hideAll()
    showEggChoice()
end

-- egg clicked: tell the server, hatch that egg, then show its briefing card.
onEggChosen = function(role)
    if petRevealDone then return end
    petRevealDone = true
    combatEvent:FireServer({ type = "ftueChoosePet", role = role })
    hideEggChoice()
    playEggHatch(role, function() showPetCard(role) end)
end

--===== Button handlers =====================================================
local function onBubbleActivated()
    local step = currentStep
    if step == "move" then
        hideAll()
        ack("move")
    elseif step == "equip" then
        -- opens the bag directly; the coach-mark stays until the server confirms an equip
        openBag()
    end
end
bubbleBtn.Activated:Connect(onBubbleActivated)
bubbleBody.Activated:Connect(function()
    -- clicking the sentence itself only does something on the "equip" beat
    if currentStep == "equip" then openBag() end
end)

cardBtn.Activated:Connect(function()
    local step = currentStep
    hideAll()
    if step == "pet" then
        -- acking "pet" makes the server push the closing "warning" panel
        ack("pet")
    elseif step == "warning" then
        ack("warning")
    end
end)

--===== Server messages =====================================================
combatEvent.OnClientEvent:Connect(function(data)
    if type(data) ~= "table" then return end
    local t = data.type

    if t == "ftueState" then
        if data.ftue and data.ftue.completed then
            hideAll()
        end
    elseif t == "ftueStep" then
        if type(data.stepId) == "string" then
            showStep(data.stepId)
        end
    elseif t == "ftueGift" then
        startPetReveal()
    end
end)

-- The server's onSpawn push can land before this listener is connected (the
-- server's startCombat runs on PlayerAdded, which can beat the client's
-- require chain). Ask for the state now that we are ready.
combatEvent:FireServer({ type = "ftueRequestState" })
