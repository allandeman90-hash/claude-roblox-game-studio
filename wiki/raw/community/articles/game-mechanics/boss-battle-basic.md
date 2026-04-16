---
title: "How to Make a Boss Battle (Basic)"
source_url: "https://devforum.roblox.com/t/how-to-make-a-boss-battle-basic-not-multi-staged/1546546"
source_type: devforum-tutorial
captured_at: 2026-04-15
captured_by: mechanics-ai
---

# Boss Battle Creation - Basic

Teaches basic non-multi-staged boss system using randomized decision-making.

## Core Pattern
Main function as "brain" randomly selects from 4 behaviors:

```lua
decide = math.random(1,4)

if decide == 1 then
    pcall(avoid)
elseif decide == 2 then
    pcall(attack01)
elseif decide == 3 then
    pcall(swing02)
elseif decide == 4 then
    pcall(charge)
end
```

## Face Player
```lua
BossRoot.CFrame = CFrame.new(BossRoot.Position, Vector3.new(
    char.Torso.Position.X, BossRoot.Position.Y, char.Torso.Position.Z))
```

## Attack with Healing
```lua
function attack01()
    BossHum:MoveTo(Vector3.new(char.Torso.Position.X, char.Torso.Position.Y, char.Torso.Position.Z))
    BossHum.MoveToFinished:Wait()
    swing01Track:Play()
    Boss.SwordOfDarkness.Handle.Touched:Connect(function(hit)
        if hit.Parent == char then
            hit.Parent.Humanoid.Health -= 10
            BossHum.Health += 10
        end
    end)
    pcall(main)
end
```

## Vulnerability Window
```lua
function swing02()
    local ableToBeStunned = true
    Boss.Vulnerable:Play()
    -- If boss takes enough damage during window, it gets stunned
    -- Otherwise executes high-damage counter-attack
end
```

## Charge Attack with Telegraph
```lua
function charge()
    BossHum.WalkSpeed = 32
    Boss.ChargeWarning:Play()  -- 3.108-second warning audio
    wait(3.108)
    BossHum:MoveTo(...)
    -- On hit: heal boss, slow player for 2 seconds
end
```

## Evasion
```lua
function avoid()
    local dashDecide = math.random(1,2)
    if dashDecide == 1 then
        BossHum:Move(Vector3.new(math.random(-15,15), 0, 0))
        wait(2)
    end
    pcall(main)
end
```

## Setup Notes
- Use R6 rigs (not R15)
- Requires Animate script in boss + Animator in Humanoid
- Boss should never be anchored
- Health: BossHum.MaxHealth = 500, BossHum.Health = 500
