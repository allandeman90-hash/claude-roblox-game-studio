---
title: obby-mechanics
type: pattern
category: patterns
subcategory: genre-mechanics
owner: game-designer
status: complete
created: 2026-04-15
updated: 2026-04-15
sources:
  - wiki/raw/community/articles/game-mechanics/obby-checkpoint-system.md
related:
  - "[[spawn-respawn-system]]"
  - "[[DataStoreService]]"
  - "[[leaderboard-pattern]]"
  - "[[simulator-mechanics]]"
tags: [pattern, obby, checkpoint, kill-brick, platformer, genre]
---

# Obby Mechanics

> Checkpoint system with sequential stages, kill bricks via Touched events, moving/rotating platforms, and optional speedrun timers. The original Roblox genre and still a strong entry point for new developers.

## Summary

Obby (obstacle course) is one of the oldest and most accessible Roblox genres. Players navigate a series of platforming challenges, with checkpoints saving progress between stages. The genre's simplicity makes it an excellent first project, but top obbies (Tower of Hell, Mega Easy Obby) add depth through difficulty curves, skip-stage GamePasses, speedrun leaderboards, and procedural stage generation. The core technical challenge is a reliable checkpoint/respawn system that persists across sessions via DataStore.

## Core Loop

```
Spawn at Current Checkpoint
       |
       v
Navigate Obstacle (jump, dodge, time movements)
       |
       v
Die (kill brick, fall) --> Respawn at Last Checkpoint
       |
       OR
       v
Reach Next Checkpoint --> Stage Saved
       |
       v
Repeat Until Final Stage
       |
       v
(Optional) Speedrun Timer --> Leaderboard
(Optional) Skip Stage via GamePass
```

## Implementation

### Checkpoint System (DataStore-Backed)

The standard pattern: checkpoints are anchored parts in a numbered folder. A single server script handles all checkpoints -- no per-checkpoint scripts needed.

```lua
-- ServerScriptService/CheckpointSystem.server.lua
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local checkpointStore = DataStoreService:GetDataStore("ObbyCheckpoints")
local checkpoints = workspace.Checkpoints -- Folder with Checkpoint1, Checkpoint2, ...
local playerStages: {[Player]: number} = {}

-- Teleport player to their saved checkpoint
local function goToCheckpoint(player: Player, stage: number)
    local character = player.Character
    if not character then return end

    local checkpoint = checkpoints:FindFirstChild("Checkpoint" .. stage)
    if not checkpoint then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = checkpoint.CFrame + Vector3.new(0, 3, 0)
    end
end

-- Player joins: load stage from DataStore
Players.PlayerAdded:Connect(function(player)
    local stage = 1
    local success, result = pcall(function()
        return checkpointStore:GetAsync("player_" .. player.UserId)
    end)
    if success and result then
        stage = result
    end

    playerStages[player] = stage

    -- Leaderstats for stage display
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local stageValue = Instance.new("IntValue")
    stageValue.Name = "Stage"
    stageValue.Value = stage
    stageValue.Parent = leaderstats

    -- Teleport on spawn and respawn
    player.CharacterAdded:Connect(function()
        task.wait(0.5) -- wait for character to load
        goToCheckpoint(player, playerStages[player])
    end)
end)

-- Player touches a checkpoint
for _, checkpoint in checkpoints:GetChildren() do
    checkpoint.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if not player then return end

        local stageNum = tonumber(checkpoint.Name:match("%d+"))
        if not stageNum then return end

        -- Only advance if it is the next stage (prevent skipping)
        if stageNum ~= playerStages[player] + 1 then return end

        playerStages[player] = stageNum
        player.leaderstats.Stage.Value = stageNum

        -- Save to DataStore
        pcall(function()
            checkpointStore:SetAsync("player_" .. player.UserId, stageNum)
        end)
    end)
end

-- Save on leave
Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        checkpointStore:SetAsync("player_" .. player.UserId, playerStages[player])
    end)
    playerStages[player] = nil
end)
```

### Kill Bricks (CollectionService Approach)

Use a single script with CollectionService tags instead of duplicating scripts inside every kill brick. Tag parts with "KillBrick" in Studio properties.

```lua
-- ServerScriptService/KillBricks.server.lua
local CollectionService = game:GetService("CollectionService")

local function setupKillBrick(brick: BasePart)
    brick.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = 0
        end
    end)
end

-- Handle existing and future tagged parts
for _, brick in CollectionService:GetTagged("KillBrick") do
    setupKillBrick(brick)
end

CollectionService:GetInstanceAddedSignal("KillBrick"):Connect(setupKillBrick)
```

### Speed Bricks and Jump Bricks

Same CollectionService pattern with different effects:

```lua
-- Speed Brick: temporarily boost WalkSpeed
local function setupSpeedBrick(brick: BasePart)
    local BOOST_SPEED = 32 -- default is 16
    local DURATION = 5

    brick.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if not humanoid then return end
        humanoid.WalkSpeed = BOOST_SPEED
        task.delay(DURATION, function()
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = 16
            end
        end)
    end)
end

-- Jump Brick: boost JumpPower
local function setupJumpBrick(brick: BasePart)
    local BOOST_JUMP = 100 -- default is 50
    local DURATION = 5

    brick.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if not humanoid then return end
        humanoid.JumpPower = BOOST_JUMP
        task.delay(DURATION, function()
            if humanoid and humanoid.Parent then
                humanoid.JumpPower = 50
            end
        end)
    end)
end
```

### Moving / Rotating Platforms

TweenService creates smooth, predictable movement for platforms. Anchor the platform and tween its CFrame.

```lua
-- ServerScriptService/MovingPlatforms.server.lua
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local TWEEN_INFO = TweenInfo.new(
    3,                       -- duration (seconds)
    Enum.EasingStyle.Sine,   -- smooth back-and-forth
    Enum.EasingDirection.InOut,
    -1,                      -- repeat forever
    true                     -- reverse on complete
)

for _, platform in CollectionService:GetTagged("MovingPlatform") do
    local startCFrame = platform.CFrame
    local offset = platform:GetAttribute("MoveOffset") or Vector3.new(20, 0, 0)
    local endCFrame = startCFrame + offset

    local tween = TweenService:Create(platform, TWEEN_INFO, {
        CFrame = endCFrame,
    })
    tween:Play()
end

-- Rotating platforms
local ROTATE_INFO = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)

for _, spinner in CollectionService:GetTagged("SpinningPlatform") do
    local speed = spinner:GetAttribute("RotateSpeed") or 90 -- degrees per cycle
    local tween = TweenService:Create(spinner, ROTATE_INFO, {
        CFrame = spinner.CFrame * CFrame.Angles(0, math.rad(speed), 0),
    })
    tween:Play()
end
```

### Speedrun Timer System

```lua
-- ServerScriptService/SpeedrunTimer.server.lua
local timerStart: {[Player]: number} = {}

-- Start timer when player leaves stage 1
local startZone = workspace.Checkpoints.Checkpoint1
startZone.Touched:Connect(function(hit)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if player and not timerStart[player] then
        timerStart[player] = os.clock()
    end
end)

-- Stop timer when player reaches final checkpoint
local FINAL_STAGE = #checkpoints:GetChildren()
-- (In the checkpoint Touched handler, after advancing stage:)
-- if stageNum == FINAL_STAGE and timerStart[player] then
--     local elapsed = os.clock() - timerStart[player]
--     submitToLeaderboard(player, elapsed)
--     timerStart[player] = nil
-- end
```

## Data Schema

```lua
export type ObbyData = {
    currentStage: number,
    highestStage: number,
    totalDeaths: number,
    bestSpeedrunTime: number?, -- seconds, nil if never completed
    skipsUsed: number,
}
```

## Economy Integration

| Revenue Source | Typical GamePass | Price (Robux) |
|----------------|------------------|---------------|
| Skip Stage | Teleport to next checkpoint | 25-75 per use (DevProduct) |
| Double Jump | Extra jump ability | 99-199 |
| Speed Coil | Permanent speed boost | 49-99 |
| Gravity Coil | Reduced gravity | 49-99 |
| VIP Trail | Cosmetic particle trail | 49-149 |

Skip Stage as a repeatable DevProduct is the primary monetization driver for obbies.

## Difficulty Curve

Stage numbering should follow an escalating difficulty pattern:

| Stage Range | Difficulty | Obstacle Types |
|-------------|-----------|----------------|
| 1-10 | Tutorial | Static jumps, wide platforms |
| 11-30 | Easy | Kill bricks (static), small gaps |
| 31-60 | Medium | Moving platforms, narrow paths |
| 61-100 | Hard | Spinning obstacles, timed jumps |
| 100+ | Expert | Combinations, wall jumps, precise timing |

Every 10-20 stages, introduce a new obstacle type to maintain novelty. Place rest areas (safe platforms with no hazards) every 5-10 stages to reduce frustration.

## Pitfalls

- **SpawnLocation interference**: If the default SpawnLocation exists in the workspace, players may spawn there instead of their checkpoint. Remove it or set `SpawnLocation.Enabled = false` and use the custom checkpoint teleport.
- **Checkpoint skip exploit**: Players can exploit physics glitches (fling, noclip) to skip stages. The `stageNum ~= currentStage + 1` check prevents this server-side.
- **Touched event double-fire**: The `Touched` event fires for every body part. Without a debounce or the humanoid check, one step on a kill brick can fire 6+ times. The humanoid health check (`Health > 0`) acts as a natural debounce for kill bricks.
- **DataStore throttling**: Saving on every checkpoint touch can hit rate limits with many players. Batch saves (save on leave + periodic autosave) and only save to DataStore when the stage actually changes.
- **TweenService on unanchored parts**: Moving platforms must be anchored. Unanchored parts with tweens cause unpredictable physics. Players standing on tweened parts may slide off -- set `PlatformStand` to false and ensure the platform is thick enough for the character to register standing on it.

## Related

- [[spawn-respawn-system]] -- general respawn architecture
- [[leaderboard-pattern]] -- speedrun leaderboards
- [[DataStoreService]] -- persisting checkpoint progress
- [[simulator-mechanics]] -- some obbies add simulator currency per stage

## Sources

- [How to create an obby, Part 1: Checkpoints and lava bricks - DevForum](https://devforum.roblox.com/t/how-to-create-an-obby-part-1-checkpoints-system-and-lava-bricks/874825)
- [Obby Checkpoint Tutorial For Noobs - DevForum](https://devforum.roblox.com/t/obby-checkpoint-tutorial-for-noobs/2718472)
- [Savable Obby Checkpoint System - DevForum](https://devforum.roblox.com/t/savable-obby-checkpoint-system/1741290)
- [The CORRECT way to make killbricks in studio - DevForum](https://devforum.roblox.com/t/the-correct-way-to-make-killbricks-in-studio-fixed/3114809)
- [How to script Kill Bricks, Jump Bricks, and Speed Bricks - DevForum](https://devforum.roblox.com/t/how-to-script-kill-bricks-jump-bricks-and-speed-bricks/556207)
- [OBBY Game Checkpoints V2.0 - DevForum](https://devforum.roblox.com/t/obby-game-checkpoints-v20/3957159)
- [Get Started Making An Obby - Obby Wiki](https://obbywiki.com/wiki/Development:Get_Started)
- [Kill Bricks Tutorial - Roblox Wiki](https://roblox.fandom.com/wiki/Tutorial:KillBricks)
