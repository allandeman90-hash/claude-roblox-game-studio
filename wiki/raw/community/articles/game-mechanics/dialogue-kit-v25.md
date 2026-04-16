# Dialogue Kit V2.5 — Fast, Easy Interactive Dialogues and Events

**Source:** https://devforum.roblox.com/t/dialogue-kit-v25-fast-easy-interactive-dialogues-and-events/3548230
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Modular NPC dialogue system using layer-based branching architecture. Triggered via `CreateDialogue()` function.

## Branching Choices

Each layer contains reply objects:
- `ReplyText`: displayed option text
- `ReplyLayer`: target layer on selection
- Special reply `_goodbye` ends dialogue

Multiple replies per layer enable complex dialogue trees.

## Configuration

Settings stored in dedicated Config instances:
- Typewriter speed and sound effects
- Background music
- Walk speed controls (with restoration)
- Cinematic bars (optional)
- Camera targeting (lock to BasePart)
- CoreUI toggling
- Death-triggered dialogue closure

## Code Example

```lua
local dialogueKitModule = require(script.Parent.Parent.DialogueKit)
dialogueKitModule.CreateDialogue({
    InitialLayer = "Layer1",
    SkinName = "DefaultDark",
    Config = script.Config,
    Layers = {
        Layer1 = {
            Dialogue = {'Content text here'},
            DialogueSounds = {nil},
            DialogueImage = "rbxassetid://14973462209",
            Title = "DialogueTitle",
            Replies = {
                reply1 = {ReplyText = "Option", ReplyLayer = "Layer2"}
            },
            Exec = {}
        }
    }
})
```

## Exec System (Event Integration)

Executes client-side code at dialogue checkpoints:
- `Function`: custom function to invoke
- `ExecTime`: "Before" (pre-typewriter) or "After" (post-completion)
- `ExecContent`: trigger point — reply name, content number, or `_continue(number)`

Enables quest assignment, NPC animations, badge awards, server communication via fired events.

## Features

- 9 pre-built skins (custom skins creatable)
- Rich text support (color, stroke, transparency, bold)
- Voice acting via per-content sound assignments
- Nodekit plugin for no-code dialogue creation
- Keyboard and gamepad input
- Typewriter acceleration (continue fills text instantly)
