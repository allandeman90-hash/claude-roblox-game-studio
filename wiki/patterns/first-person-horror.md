---
title: First-Person Horror
type: pattern
category: patterns
subcategory: gameplay
owner: luau-gameplay-programmer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/first-person-horror-design.md
  - wiki/raw/community/articles/game-mechanics/flashlight-systems.md
  - wiki/raw/community/articles/game-mechanics/first-person-mode-system.md
  - wiki/raw/community/articles/game-mechanics/interaction-proximityprompt-vs-custom.md
related:
  - "[[first-person-framework]]"
  - "[[viewmodel-system]]"
  - "[[first-person-interaction]]"
  - "[[npc-ai-system]]"
  - "[[notification-system]]"
tags: [pattern, horror, first-person, flashlight, jumpscare, atmosphere, fog, sanity, hiding, enemy-ai]
---

# First-Person Horror

> Horror-specific first-person patterns: limited visibility via fog and lighting, flashlight with battery drain, jumpscare system, enemy AI that reacts to player light and sound, sanity/fear meter, environmental storytelling, and hiding mechanics.

## Summary

First-person horror on Roblox leverages the inherent limitations of the first-person perspective -- the player cannot see behind them, peripheral vision is restricted, and the camera occupies the character's eye position -- to create psychological tension. The core loop is: explore with limited visibility (flashlight, darkness) -> encounter threat (enemy, event) -> react (hide, run) -> recover (find safe space, restore sanity). Every system serves atmosphere: fog controls draw distance, lighting manipulation creates dread, audio drives uncertainty, and the camera itself becomes a tool for jump scares when temporarily stolen from the player.

## Architecture

```
Client Systems                           Server Systems
  |                                        |
  | Atmosphere Controller                  | World State
  |   - Fog (FogEnd, FogStart, FogColor)  |   - Enemy positions
  |   - Ambient light                      |   - Door/item states
  |   - Post-processing effects            |   - Player sanity values
  |                                        |
  | Flashlight Controller                  | Enemy AI Controller
  |   - SpotLight toggle                   |   - Pathfinding (PathfindingService)
  |   - Battery drain                      |   - Detection (sight, sound, light)
  |   - Smooth camera follow               |   - State: patrol/chase/search/return
  |                                        |
  | Jumpscare Controller                   | Event System
  |   - Camera lock                        |   - Scripted triggers
  |   - Forced animation                   |   - Random ambient events
  |   - Sound burst                        |   - Environmental storytelling
  |                                        |
  | Sanity/Fear HUD                        | Hiding Spot Manager
  |   - Meter display                      |   - Region detection
  |   - Visual distortion                  |   - Enemy search logic
```

## Implementation

### 1. Limited Visibility (Fog and Lighting)

Fog is the primary tool for controlling how far the player can see. The `Lighting` service properties drive the atmosphere:

```lua
-- Server or Client: atmosphere setup
local Lighting = game:GetService("Lighting")

-- Base horror atmosphere
Lighting.Ambient = Color3.fromRGB(15, 15, 20)
Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 15)
Lighting.Brightness = 0.2
Lighting.ClockTime = 0       -- midnight
Lighting.FogEnd = 80         -- visible range in studs
Lighting.FogStart = 10       -- fog begins close
Lighting.FogColor = Color3.fromRGB(5, 5, 10)

-- ColorCorrectionEffect for desaturation
local cc = Instance.new("ColorCorrectionEffect")
cc.Saturation = -0.4         -- desaturated, bleak
cc.Contrast = 0.15
cc.TintColor = Color3.fromRGB(200, 200, 220)
cc.Parent = Lighting

-- BloomEffect for flashlight glow bleed
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.3
bloom.Size = 24
bloom.Threshold = 0.8
bloom.Parent = Lighting
```

Dynamic fog changes create tension shifts:

```lua
-- Client: tighten fog when danger is near
local TweenService = game:GetService("TweenService")

local function setDangerLevel(level: number) -- 0.0 to 1.0
    local fogEnd = 80 - (level * 50) -- 80 studs -> 30 studs
    local fogStart = 10 - (level * 8) -- 10 -> 2
    local ambient = Color3.fromRGB(
        15 - level * 10,
        15 - level * 10,
        20 - level * 10
    )

    TweenService:Create(Lighting, TweenInfo.new(2, Enum.EasingStyle.Sine), {
        FogEnd = fogEnd,
        FogStart = fogStart,
        Ambient = ambient,
    }):Play()
end
```

### 2. Flashlight with Battery Drain

The flashlight extends the [[first-person-interaction]] flashlight pattern with a battery system:

```lua
-- Client: FlashlightController.client.lua
local MAX_BATTERY = 100
local DRAIN_RATE = 2         -- units per second when on
local RECHARGE_RATE = 0.5    -- units per second when off
local FLICKER_THRESHOLD = 15 -- battery level where flickering starts

local battery = MAX_BATTERY
local flashlightOn = false
local spotLight: SpotLight = nil -- setup as in first-person-interaction

local function updateBattery(dt: number)
    if flashlightOn then
        battery = math.max(0, battery - DRAIN_RATE * dt)

        -- Flicker when low
        if battery < FLICKER_THRESHOLD then
            local flickerChance = 1 - (battery / FLICKER_THRESHOLD)
            if math.random() < flickerChance * 0.1 then
                spotLight.Enabled = false
                task.delay(0.05 + math.random() * 0.1, function()
                    if flashlightOn and battery > 0 then
                        spotLight.Enabled = true
                    end
                end)
            end
        end

        -- Die when empty
        if battery <= 0 then
            flashlightOn = false
            spotLight.Enabled = false
        end

        -- Brightness fades with battery
        spotLight.Brightness = 3 * (battery / MAX_BATTERY)
    else
        -- Slow recharge when off (optional mechanic)
        battery = math.min(MAX_BATTERY, battery + RECHARGE_RATE * dt)
    end
end

RunService.Heartbeat:Connect(updateBattery)
```

Battery pickups restore charge:

```lua
-- Server: battery pickup
Remotes.PickupBattery.OnServerEvent:Connect(function(player: Player, batteryPart: BasePart)
    if typeof(batteryPart) ~= "Instance" then return end
    if not batteryPart:GetAttribute("IsBattery") then return end

    -- Distance check
    local character = player.Character
    if not character or not character.PrimaryPart then return end
    if (character.PrimaryPart.Position - batteryPart.Position).Magnitude > 8 then return end

    local rechargeAmount = batteryPart:GetAttribute("ChargeAmount") or 30
    Remotes.BatteryCollected:FireClient(player, rechargeAmount)
    batteryPart:Destroy()
end)
```

### 3. Jumpscare System

A jumpscare temporarily takes control of the camera, plays forced audio and visual effects, then returns control:

```lua
-- Client: JumpscareController.client.lua
local function playJumpscare(config: {
    duration: number,        -- seconds
    image: string?,          -- decal ID for full-screen flash
    sound: Sound,
    cameraShake: number,     -- intensity
    fovPunch: number,        -- FOV increase on scare
})
    local savedCameraType = camera.CameraType
    local savedFOV = camera.FieldOfView

    -- Lock camera
    camera.CameraType = Enum.CameraType.Scriptable

    -- Flash image (full-screen)
    if config.image then
        local flash = Instance.new("ImageLabel")
        flash.Image = config.image
        flash.Size = UDim2.fromScale(1, 1)
        flash.BackgroundTransparency = 1
        flash.Parent = player.PlayerGui:FindFirstChild("JumpscareGui")

        task.delay(config.duration * 0.3, function()
            TweenService:Create(flash, TweenInfo.new(config.duration * 0.7), {
                ImageTransparency = 1,
            }):Play()
            task.delay(config.duration * 0.7, function()
                flash:Destroy()
            end)
        end)
    end

    -- Play scare sound
    config.sound:Play()

    -- FOV punch
    TweenService:Create(camera, TweenInfo.new(0.1), {
        FieldOfView = savedFOV + config.fovPunch,
    }):Play()
    task.delay(0.1, function()
        TweenService:Create(camera, TweenInfo.new(config.duration - 0.1), {
            FieldOfView = savedFOV,
        }):Play()
    end)

    -- Camera shake
    local shakeStart = tick()
    local shakeConn
    shakeConn = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - shakeStart
        if elapsed > config.duration then
            shakeConn:Disconnect()
            camera.CameraType = savedCameraType
            return
        end
        local intensity = config.cameraShake * (1 - elapsed / config.duration)
        camera.CFrame = camera.CFrame * CFrame.Angles(
            (math.random() - 0.5) * intensity * 0.05,
            (math.random() - 0.5) * intensity * 0.05,
            (math.random() - 0.5) * intensity * 0.02
        )
    end)
end
```

### 4. Enemy AI (Reacts to Flashlight and Sound)

Enemy NPCs use a detection model based on sight, sound, and flashlight exposure:

```lua
-- Server: EnemyAI module (simplified)
export type EnemyState = "patrol" | "investigate" | "chase" | "search" | "return"

local SIGHT_RANGE = 40      -- studs
local SIGHT_ANGLE = 60      -- degrees (half-cone)
local SOUND_RANGE = 25      -- studs (running triggers this)
local LIGHT_RANGE = 50      -- studs (flashlight aggros from further)
local CHASE_SPEED = 22      -- studs/s
local PATROL_SPEED = 8

local function canSeePlayer(enemy: Model, playerChar: Model): boolean
    local enemyHead = enemy:FindFirstChild("Head")
    local playerHRP = playerChar:FindFirstChild("HumanoidRootPart")
    if not enemyHead or not playerHRP then return false end

    local toPlayer = (playerHRP.Position - enemyHead.Position)
    local distance = toPlayer.Magnitude
    if distance > SIGHT_RANGE then return false end

    -- Check angle
    local lookDir = enemyHead.CFrame.LookVector
    local angle = math.deg(math.acos(lookDir:Dot(toPlayer.Unit)))
    if angle > SIGHT_ANGLE then return false end

    -- Line of sight check
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { enemy }
    local result = workspace:Raycast(enemyHead.Position, toPlayer, params)
    if result and result.Instance:IsDescendantOf(playerChar) then
        return true
    end

    return false
end

local function isPlayerLit(enemy: Model, playerChar: Model): boolean
    -- Check if player's flashlight is pointing near the enemy
    -- Server receives flashlight state via periodic remote
    local flashlightDir = playerFlashlightData[playerChar]
    if not flashlightDir then return false end

    local toEnemy = (enemy.PrimaryPart.Position - playerChar.PrimaryPart.Position)
    if toEnemy.Magnitude > LIGHT_RANGE then return false end

    local angle = math.deg(math.acos(flashlightDir:Dot(toEnemy.Unit)))
    return angle < 30 -- flashlight cone
end

local function getPlayerNoise(playerChar: Model): number
    local humanoid = playerChar:FindFirstChildOfClass("Humanoid")
    if not humanoid then return 0 end
    local speed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed
    if speed > 14 then return SOUND_RANGE end       -- running
    if speed > 1 then return SOUND_RANGE * 0.4 end  -- walking
    return 0                                          -- standing
end
```

### 5. Sanity / Fear Meter

A numeric fear value that increases near enemies or in darkness, and triggers visual distortions:

```lua
-- Server: authoritative sanity tracking
local playerSanity: {[Player]: number} = {} -- 0 = insane, 100 = calm

local function updateSanity(player: Player, dt: number)
    local sanity = playerSanity[player] or 100
    local character = player.Character
    if not character then return end

    -- Fear sources
    local nearEnemy = isEnemyNearby(character, 30) -- within 30 studs
    local inDarkness = isInDarkness(character)       -- no light sources nearby
    local hasFlashlight = playerFlashlightState[player]

    local drainRate = 0
    if nearEnemy then drainRate += 8 end
    if inDarkness and not hasFlashlight then drainRate += 3 end

    -- Recovery
    local recoveryRate = 2 -- per second in safe conditions
    if not nearEnemy and hasFlashlight then recoveryRate = 5 end

    sanity = math.clamp(sanity + (recoveryRate - drainRate) * dt, 0, 100)
    playerSanity[player] = sanity

    -- Notify client for visual effects
    if sanity < 50 then
        Remotes.SanityUpdate:FireClient(player, sanity)
    end
end
```

```lua
-- Client: sanity visual effects
Remotes.SanityUpdate.OnClientEvent:Connect(function(sanity: number)
    local cc = Lighting:FindFirstChild("SanityCC") :: ColorCorrectionEffect
    if not cc then return end

    -- Desaturation and vignette increase as sanity drops
    local insanityLevel = 1 - (sanity / 100)
    cc.Saturation = -0.4 - (insanityLevel * 0.5)   -- goes to -0.9
    cc.Contrast = 0.15 + (insanityLevel * 0.3)

    -- Camera distortion at very low sanity
    if sanity < 20 then
        -- Subtle wavering via sine offset
        local waver = math.sin(tick() * 3) * insanityLevel * 0.01
        camera.CFrame = camera.CFrame * CFrame.Angles(waver, waver * 0.5, 0)
    end

    -- Auditory hallucination: faint whispers
    if sanity < 30 and not whispersPlaying then
        whisperSound:Play()
        whispersPlaying = true
    elseif sanity >= 30 and whispersPlaying then
        whisperSound:Stop()
        whispersPlaying = false
    end
end)
```

### 6. Environmental Storytelling

Notes, audio logs, and environmental cues deliver narrative without cutscenes:

```lua
-- Collectible note system
-- Each note is a Part with attributes: NoteTitle, NoteContent, NoteAudioId

Remotes.ReadNote.OnServerEvent:Connect(function(player: Player, notePart: BasePart)
    if typeof(notePart) ~= "Instance" then return end
    if not notePart:GetAttribute("NoteTitle") then return end

    -- Distance check
    local character = player.Character
    if not character or not character.PrimaryPart then return end
    if (character.PrimaryPart.Position - notePart.Position).Magnitude > 8 then return end

    -- Mark as collected for this player
    local collectedStore = playerCollectedNotes[player] or {}
    local noteId = notePart:GetAttribute("NoteId")
    if collectedStore[noteId] then return end -- already read
    collectedStore[noteId] = true
    playerCollectedNotes[player] = collectedStore

    Remotes.ShowNote:FireClient(player, {
        title = notePart:GetAttribute("NoteTitle"),
        content = notePart:GetAttribute("NoteContent"),
        audioId = notePart:GetAttribute("NoteAudioId"),
    })
end)
```

### 7. Hiding Spots

Players can hide in designated areas (closets, under beds). The server tracks whether the player is hidden and modifies enemy detection:

```lua
-- Server: hiding spot detection
local hidingSpots: {[BasePart]: {occupied: boolean, player: Player?}} = {}

-- Using Touched/TouchEnded with a trigger volume
local function setupHidingSpot(triggerPart: BasePart)
    hidingSpots[triggerPart] = { occupied = false, player = nil }

    triggerPart.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        -- Player must press E to hide (not auto-hide on touch)
        -- The touch just marks them as "near hiding spot"
        playerNearHidingSpot[player] = triggerPart
    end)

    triggerPart.TouchEnded:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if player then
            playerNearHidingSpot[player] = nil
        end
    end)
end

Remotes.HideInSpot.OnServerEvent:Connect(function(player: Player)
    local spot = playerNearHidingSpot[player]
    if not spot then return end
    if hidingSpots[spot].occupied then return end

    hidingSpots[spot] = { occupied = true, player = player }
    playerIsHidden[player] = true

    -- Lock camera to hiding spot viewpoint
    Remotes.EnterHidingSpot:FireClient(player, spot:GetAttribute("ViewCFrame"))

    -- Disable movement
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end)
```

Enemy AI skips hidden players unless the enemy is specifically searching that spot:

```lua
-- In enemy AI update:
local function shouldDetectPlayer(enemy, player): boolean
    if playerIsHidden[player] then
        -- Only detect if enemy is investigating this specific hiding spot
        return enemy:GetAttribute("SearchingSpot") == getPlayerHidingSpot(player)
    end
    return canSeePlayer(enemy, player.Character)
end
```

## Server vs Client Split

| Component | Side | Notes |
|---|---|---|
| Fog, Lighting, post-processing | Client | Visual atmosphere |
| Flashlight visual (SpotLight) | Client | Camera-space light |
| Battery level | Client (gameplay), Server (if competitive) | Single-player: client OK |
| Jumpscare trigger | Server -> Client | Server decides when to scare |
| Jumpscare execution (camera, audio) | Client | Visual/audio only |
| Enemy AI pathfinding | Server | Authoritative movement |
| Enemy detection (sight/sound) | Server | Cannot be spoofed |
| Sanity value | Server | Authoritative gameplay value |
| Sanity visual effects | Client | Rendering based on server value |
| Hiding state | Server | Enemy AI reads server state |
| Note collection | Server | Persistent across sessions |

## Performance Notes

- **Fog is free**: FogEnd/FogStart are engine-level; they reduce draw calls by culling distant geometry. Lower FogEnd improves client FPS -- a natural benefit for horror games.
- **SpotLight performance**: Each SpotLight has shadow map cost. Limit to one active flashlight per player. Use `Lighting.Technology = Enum.Technology.Future` for best quality but profile on low-end devices.
- **Enemy AI tick rate**: Run AI update at 5-10 Hz (not 60 Hz). Pathfinding is expensive; cache paths and recompute only when the target moves significantly (> 5 studs).
- **Jumpscare ImageLabel**: Full-screen ImageLabels are cheap. Avoid creating and destroying them each scare; pre-create hidden and toggle visibility.
- **Sanity effects**: Camera CFrame manipulation in RenderStepped must be minimal. A single sine offset is negligible; complex shader-like effects via post-processing (BlurEffect, DepthOfFieldEffect) are more expensive.

## Pitfalls

1. **Over-relying on jumpscares** -- Frequent jumpscares desensitize the player. Use atmosphere and anticipation; reserve jumpscares for pivotal moments.
2. **Forgetting to restore camera after jumpscare** -- If the player dies during a jumpscare, the camera remains Scriptable. Always restore CameraType in a finally-style cleanup.
3. **Flashlight visible to all players** -- A camera-parented SpotLight is local-only. For multiplayer horror where players should see each other's flashlights, replicate a separate light attached to the character.
4. **Enemy AI in single-thread** -- Pathfinding for multiple enemies on Heartbeat can spike server frame time. Stagger AI updates across frames using a round-robin scheduler.
5. **Sanity drain without feedback** -- If the player's sanity drains but the visual effects are too subtle, the mechanic feels invisible. Use audio cues (heartbeat, whispers) alongside visual distortion.
6. **Hiding spot collision** -- The trigger volume for hiding spots must not interfere with normal character collision. Use `CanCollide = false, CanTouch = true` on the trigger.

## Related

- [[first-person-framework]] -- overall FP architecture
- [[viewmodel-system]] -- arms and weapon rendering
- [[first-person-interaction]] -- general interaction patterns
- [[npc-ai-system]] -- broader NPC AI patterns
- [[notification-system]] -- HUD notifications for notes/objectives

## Sources

- [1st Person Only Horror? (DevForum)](https://devforum.roblox.com/t/1st-person-only-horror/652817)
- [Realistic First Person System in Horror Game (DevForum)](https://devforum.roblox.com/t/how-to-make-a-realistic-first-person-system-in-a-horror-game/762698)
- [DOORS-Style First Person Camera (DevForum)](https://devforum.roblox.com/t/how-would-i-go-about-making-a-smooth-custom-first-person-camera-system-like-doors/2200738)
- [Advanced Flashlight Module (DevForum)](https://devforum.roblox.com/t/advanced-flashlight-horror-game/1972508)
- [IK Flashlight for Horror (DevForum)](https://devforum.roblox.com/t/inverse-kinematics-flashlight-horror-game-feedback/2624202)
- [First Person Flashlight Discussion (DevForum)](https://devforum.roblox.com/t/first-person-flashlight/805153)
- [Midnight Hours Horror Game (DevForum)](https://devforum.roblox.com/t/midnight-hours-new-first-person-horror-game/1896564)
- [ProximityPrompts vs Custom Interaction (DevForum)](https://devforum.roblox.com/t/proximityprompts-vs-custom-interaction-mechanic/2400536)
