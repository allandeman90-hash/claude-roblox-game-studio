# SimpleDialogue — A Dialogue Module

**Source:** https://devforum.roblox.com/t/simpledialogue-a-dialogue-module/3631857
**Captured:** 2026-04-15
**captured_by:** mechanics-movement

## Overview

Module simplifying NPC dialogues using a tree structure for configuration. Supports branching conversations from simple to complex.

## Core Components

- **Nodes**: individual dialogue prompts with NPC text
- **Options**: player response choices triggering callbacks or navigating to other nodes
- **Conditions**: dynamic logic showing/hiding options based on game state

## API

```lua
local dialogue = SimpleDialogue.new(npc)
dialogue:SetDialogueTree(dialogueTree)
```

- `SimpleDialogue.CreateNode(text, {options})` — create dialogue node
- `SimpleDialogue.CreateOption(text, callback, nodeIndex)` — create player choice
- `SimpleDialogue.CreateCondition(function, option)` — conditional option visibility
- `SimpleDialogue.CreateAutoNode(text, function)` — auto-progression node

## Version History

- 0.1.7: Fixed proximity prompt interference and callback issues
- 0.1.8: Experimental 2D ScreenGui support via `useScreenGui`
- 0.2.0: Conditional logic for dynamic branching

## Resources

- Documentation: crabzzai.github.io/SimpleDialogue
- GitHub: Crabzzai/SimpleDialogue
