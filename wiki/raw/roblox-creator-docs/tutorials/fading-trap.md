---
title: Fading Trap
type: raw-source
source_url: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/basic-scripting/fading-trap
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-3
category: tutorial
tags: [tutorial, scripting, for-loops, debounce, booleans, touched, transparency]
difficulty: beginner
---

# Fading Trap

In Deadly Lava, you learned how to trigger code based on user behavior. This tutorial shows you how to make a platform which fades away when a user steps on it.

## Steps

### Set up

If you followed Deadly Lava, you can place your fading platform above the lava floor that users can't jump across.

1. Insert a part and move it into place in your world. Name it `FadingPlatform`.
2. Resize it so a user can jump on it.
3. Make sure it's **Anchored**.
4. Insert a **Script** into the part, rename it to **FadeOnTouch**, and remove the default code.
5. Create a variable for the platform and an empty function connected to the platform's `Touched` event.

```lua
local platform = script.Parent

local function fade()

end

platform.Touched:Connect(fade)
```

### Fade the platform

Having the platform vanish in an instant would be no fun at all as users would find it impossible to get across the gap. Instead, the platform should **fade away** before users fall through it to give them a chance to jump off.

You could change the `Transparency` property and wait a very short time over and over again to get this effect, but a gradual fade would require at least 10 changes between 0 and 1. That's 20 lines of very repetitive code.

This can be achieved much more effectively using a **for** loop which repeats code a specific number of times. Each loop of the code is known as an **iteration**. A for loop is defined with three things, separated by commas:

- **Control variable** - The variable created and used to count the loops. In this example, it's `count` and the starting value is 1.
- **End value** - The value it has to get to for the loop to stop. In this example, it's 10.
- **Step increment** (optional) - Determines what to add to the control variable each loop. If left out, it defaults to 1.

```lua
local platform = script.Parent

local function fade()
    for count = 1, 10 do
        platform.Transparency = count / 10
        task.wait(0.1)
    end
end

platform.Touched:Connect(fade)
```

When the loop runs, count increases by 1 with each iteration. This means that the platform's `Transparency` will increase by 0.1 every 0.1 seconds, reaching full transparency after 1 second.

### Reappear

After the platform has vanished, users should fall through it. The platform should also come back a few seconds after it fades — otherwise, users would never get to try the jump again if they failed. The CanCollide property controls whether users can fall through a part.

1. Set the `CanCollide` property of the platform to `false` after the for loop.
2. Wait for a few seconds using the `task.wait()` function.
3. Set the `CanCollide` property back to `true`.
4. Set the `Transparency` property back to `0`.

```lua
local platform = script.Parent

local function fade()
   for count = 1, 10 do
      platform.Transparency = count / 10
      task.wait(0.1)
   end
   platform.CanCollide = false
   task.wait(3)
   platform.CanCollide = true
   platform.Transparency = 0
end

platform.Touched:Connect(fade)
```

### Debounce variable

In Deadly Lava, you learned that the `Touched` event runs each time a user's body part comes into contact with the part. This behavior causes issues when a user runs across the fading platform: the function will run multiple times, resetting the loop each time.

For the code to work properly, the function should only run once when the user touches the platform for the first time. Ensuring that an action is only triggered once when it would otherwise be triggered multiple times is known as **debouncing**.

To debounce a function, a **boolean** variable can be used to keep track of when the platform has already been touched. Booleans can only contain **true** and **false** values.

```lua
local platform = script.Parent

local isTouched = false

local function fade()
    for count = 1, 10 do
        platform.Transparency = count / 10
        task.wait(0.1)
    end
    platform.CanCollide = false
    task.wait(3)
    platform.CanCollide = true
    platform.Transparency = 0
end

platform.Touched:Connect(fade)
```

### Check the variable

```lua
local platform = script.Parent

local isTouched = false

local function fade()
    if not isTouched then
        for count = 1, 10 do
            platform.Transparency = count / 10
            task.wait(0.1)
        end
        platform.CanCollide = false
        task.wait(3)
        platform.CanCollide = true
        platform.Transparency = 0
    end
end

platform.Touched:Connect(fade)
```

The Luau `not` operator reverses the value of whatever follows it. In conditional terms, these are equivalent:

```lua
if not isTouched then
end
if isTouched == false then
end
if isTouched == nil then
end
```

### Toggle the debounce

Currently, the code in the `fade` function will always run because `isTouched` is false and `not isTouched` evaluates to true. To complete the debounce routine, you'll need to toggle the variable's value in two places.

1. Set `isTouched` to `true` inside the `if` statement, before the platform begins to fade.
2. Set it back to `false` once the platform has reappeared.

```lua
local function fade()
  if not isTouched then
    isTouched = true
    for count = 1, 10 do
      platform.Transparency = count / 10
      task.wait(0.1)
    end
    platform.CanCollide = false
    task.wait(3)
    platform.CanCollide = true
    platform.Transparency = 0
    isTouched = false
  end
end

platform.Touched:Connect(fade)
```

## Key Concepts

- **for loops**: Repeat code a specific number of times with control variable, end value, step
- **Iteration**: A single pass through a loop
- **Debouncing**: Using a flag to prevent a function from running multiple times in quick succession
- **Booleans**: `true` / `false` values
- **`not` operator**: Reverses a boolean value
- **Touched event fires multiple times**: Body parts touch individually, so debouncing is essential

## Code Snippets

### Final code

```lua
local platform = script.Parent

local isTouched = false

local function fade()
    if not isTouched then
        isTouched = true
        for count = 1, 10 do
            platform.Transparency = count / 10
            task.wait(0.1)
        end
        platform.CanCollide = false
        task.wait(3)
        platform.CanCollide = true
        platform.Transparency = 0
        isTouched = false
    end
end

platform.Touched:Connect(fade)
```

## Notes

- Touched events fire multiple times as different body parts make contact
- Debouncing is a fundamental pattern for Touched-based logic
- Try varying the fade speed to tune difficulty

## Source

Original URL: https://create.roblox.com/docs/tutorials/use-case-tutorials/scripting/basic-scripting/fading-trap
Captured: 2026-04-16
