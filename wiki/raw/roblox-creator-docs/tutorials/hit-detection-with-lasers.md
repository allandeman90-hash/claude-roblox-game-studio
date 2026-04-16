---
title: Hit Detection with Lasers
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/intermediate-scripting/hit-detection-with-lasers
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, scripting, raycasting, remoteevent, networking, client-server, hit-detection, laser, weapons]
difficulty: intermediate
---

# Hit Detection with Lasers

This tutorial teaches raycasting mechanics for creating a functional laser blaster weapon system in multiplayer games. It extends the Blaster tool from Create Player Tools.

## Steps

### Core Concepts

**Raycasting** creates invisible rays from a starting point in a specified direction. If the ray collides with objects or terrain in its path, it returns information on the collision such as the position and the object it collided with.

The implementation uses three main raycasts:
1. From camera through mouse position to find player aim target
2. From weapon to determine laser endpoint
3. Server-side validation raycast to prevent exploits

### Convert mouse to 3D position

Use `Camera:ViewportPointToRay()` to convert 2D mouse coordinates to a 3D world ray:

```lua
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local function getMouseTarget()
    local mousePosition = UserInputService:GetMouseLocation()
    local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    return result
end
```

### Create visual laser beam

After determining hit position, create a Neon part to visualize the laser:

```lua
local function createLaserBeam(startPos, endPos)
    local laser = Instance.new("Part")
    laser.Material = Enum.Material.Neon
    laser.Color = Color3.new(1, 0, 0)
    laser.Anchored = true
    laser.CanCollide = false
    laser.Size = Vector3.new(0.2, 0.2, (endPos - startPos).Magnitude)
    laser.CFrame = CFrame.lookAt((startPos + endPos) / 2, endPos)
    laser.Parent = workspace
    
    game:GetService("Debris"):AddItem(laser, 0.1)
end
```

### Fire rate limiting

Use `tick()` to enforce fire rate limits:

```lua
local lastFired = 0
local FIRE_RATE = 0.5

local function canFire()
    if tick() - lastFired < FIRE_RATE then
        return false
    end
    lastFired = tick()
    return true
end
```

### Client-server communication

Use `RemoteEvent` objects to communicate between client and server:
- **DamageCharacter** event: Client notifies server of hits
- **LaserFired** event: Server broadcasts visual laser beams to all players

```lua
-- Client (on fire)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local damageEvent = ReplicatedStorage:WaitForChild("DamageCharacter")

damageEvent:FireServer(hitCharacter, hitPosition)
```

```lua
-- Server (damage handler with validation)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local damageEvent = ReplicatedStorage:WaitForChild("DamageCharacter")

local MAX_DISTANCE = 500
local DAMAGE = 20

damageEvent.OnServerEvent:Connect(function(player, targetCharacter, hitPosition)
    -- Validate: hit position must be close to target
    if not targetCharacter or not targetCharacter:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local distance = (hitPosition - targetCharacter.HumanoidRootPart.Position).Magnitude
    if distance > 10 then
        return -- Likely an exploit
    end
    
    -- Validate: player is within range of target
    if not player.Character then return end
    local shooterDistance = (player.Character.HumanoidRootPart.Position - hitPosition).Magnitude
    if shooterDistance > MAX_DISTANCE then
        return
    end
    
    -- Apply damage
    local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:TakeDamage(DAMAGE)
    end
end)
```

### Search for hit humanoid

Use `FindFirstAncestorOfClass` to walk up the parent chain:

```lua
local function findHumanoid(part)
    local character = part:FindFirstAncestorOfClass("Model")
    if character then
        return character:FindFirstChildOfClass("Humanoid"), character
    end
    return nil, nil
end
```

## Key Concepts

- **Raycasting**: Invisible rays that detect collisions
- **`workspace:Raycast(origin, direction, params)`**: Modern raycast API
- **`RaycastParams`**: Filters for ignoring certain objects
- **`ViewportPointToRay(x, y)`**: 2D screen to 3D world ray
- **`RaycastResult`**: Contains `.Position`, `.Instance`, `.Material`, `.Normal`
- **Neon parts**: Emissive, used for visual laser beams
- **`Debris:AddItem(instance, seconds)`**: Schedule instance for destruction
- **RemoteEvent**: One-way client↔server messaging
- **`FireServer()` / `OnServerEvent`**: Client-to-server flow
- **`FireClient()` / `OnClientEvent`**: Server-to-client flow
- **Server validation**: ALWAYS validate client-supplied data on the server
- **`tick()`**: Current time in seconds for rate limiting
- **`FindFirstAncestorOfClass()`**: Walks up parent chain by class
- **`Humanoid:TakeDamage()`**: Applies damage respecting ForceField

## Notes

- Always validate client-supplied positions on the server
- Use `FilterDescendantsInstances` to exclude shooter's character from raycast
- Client renders laser immediately (no lag); server broadcasts to others
- Use `Debris` service for auto-destroying visual effects
- `TakeDamage` respects ForceField; `.Health = x` does not
- Distance checks prevent wall-hacking and teleport exploits

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/intermediate-scripting/hit-detection-with-lasers
Captured: 2026-04-16
