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

local StyleConstants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("StyleConstants"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer
local combatEvent = ReplicatedStorage:WaitForChild("CombatEvent") :: RemoteEvent

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
        body = "Tu as reçu l'Épée en bois. Ouvre ton inventaire et équipe-la.",
        cta  = "Ouvrir l'inventaire",
    },
    warning = {
        title = "Ce monde est impitoyable",
        body  = "Tu vas mourir. Souvent, et vite. C'est normal — chaque tentative te rend plus fort. On recommence, encore et encore.",
        cta   = "Compris",
    },
}
local GIFT = {
    title = "Ton premier familier",
    body  = "La Fée te rejoint et augmente tes dégâts. Tu pourras changer son rôle au feu de camp.",
    cta   = "Continuer",
}

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
local bubbleBody = label(bubble, "", "Body", C.TextPrimary, 1)
local bubbleBtn = StyleConstants.makeButton("", "Body", "gold")
bubbleBtn.Size = UDim2.fromOffset(220, 40)
bubbleBtn.LayoutOrder = 2
bubbleBtn.ZIndex = FTUE_Z
bubbleBtn.Parent = bubble

-- Modal card (warning / gift): centered, dimmed behind.
local card = panel(UDim2.fromOffset(440, 0), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
card.AutomaticSize = Enum.AutomaticSize.Y
local cardTitle = label(card, "", "Heading", C.Accent, 1)
local cardBody = label(card, "", "Body", C.TextPrimary, 2)
local cardBtn = StyleConstants.makeButton("", "Body", "gold")
cardBtn.Size = UDim2.fromOffset(240, 44)
cardBtn.LayoutOrder = 3
cardBtn.ZIndex = FTUE_Z
cardBtn.Parent = card

--===== State ================================================================
local currentStep: string? = nil
local shownAt = 0
local autoThread: thread? = nil

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
        cardBtn.Text = COACH.warning.cta
        dim.Visible = true
        card.Visible = true
        armAutoDismiss("warning")
    end
end

local function showGift()
    hideAll()
    cardTitle.Text = GIFT.title
    cardBody.Text = GIFT.body
    cardBtn.Text = GIFT.cta
    dim.Visible = true
    card.Visible = true
    currentStep = "gift"
    shownAt = os.clock()
end

--===== Button handlers =====================================================
bubbleBtn.Activated:Connect(function()
    local step = currentStep
    if step == "move" then
        hideAll()
        ack("move")
    elseif step == "equip" then
        -- CTA opens the bag; the coach-mark stays until the server confirms an equip
        combatEvent:FireServer({ type = "requestInventory" })
    end
end)

cardBtn.Activated:Connect(function()
    local step = currentStep
    hideAll()
    if step == "warning" then
        ack("warning")
    end
    -- "gift" needs no ack: the server already completed the tutorial
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
        showGift()
    end
end)

-- The server's onSpawn push can land before this listener is connected (the
-- server's startCombat runs on PlayerAdded, which can beat the client's
-- require chain). Ask for the state now that we are ready.
combatEvent:FireServer({ type = "ftueRequestState" })
