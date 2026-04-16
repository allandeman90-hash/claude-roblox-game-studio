---
title: "How to Manipulate the Camera for 3rd Person Games"
source_type: devforum-tutorial
url: https://devforum.roblox.com/t/how-to-manipulate-the-camera-for-3rd-person-games3rd-person-camera/1156374
captured: 2026-04-15
tags: [camera, third-person, CFrame, RunService, UserInputService, scriptable-camera]
---

# 3rd Person Camera Tutorial

## Setup
- LocalScript in StarterGUI
- Services: RunService, UserInputService, Players

## Core Variables
```lua
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Camera = workspace.Camera
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local CameraAngleX, CameraAngleY = 0, 0
local CameraOffset = Vector3.new(1, 3, 9.5)
```

## Implementation Steps

### 1. Set Camera to Scriptable
Inside RenderStepped loop, set `Camera.CameraType = Enum.CameraType.Scriptable`.

### 2. Calculate Camera Position
- Create StartCFrame using HumanoidRootPart position with angle rotations
- Apply CameraOffset via ToWorldSpace
- Set CameraFocus point at distance

### 3. Update Each Frame
```lua
Camera.CFrame = CFrame.new(CameraCFrame.Position, CameraFocus.Position)
```

### 4. Handle Mouse Input
```lua
UserInputService.InputChanged:Connect(function(InputObject)
    if InputObject.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = InputObject.Delta
        CameraAngleX = CameraAngleX - Delta.X
        CameraAngleY = math.clamp(CameraAngleY - Delta.Y, -75, 75)
    end
end)
```

## Notable Limitations
- No collision handling (camera clips through walls)
- Production implementations should add raycasting for obstruction detection
- Character rotation sync with camera is optional (commented out by default)
