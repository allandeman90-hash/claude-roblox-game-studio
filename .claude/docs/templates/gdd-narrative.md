# Narrative System GDD

**Version**: 1.0
**Last Updated**: YYYY-MM-DD
**Author**: narrative-director + writer
**Parent**: `design/gdd/master-gdd.md`

---

## 1. Overview & Purpose

The story and lore of the game. How the narrative is delivered and how players engage with it.

---

## 2. Story Synopsis

One paragraph elevator pitch of the story.

---

## 3. World

Link to `design/narrative/world-bible.md` for full world documentation.

Quick summary:
- **Setting**: [time period, location]
- **Mood**: [dark / hopeful / whimsical / etc.]
- **Conflict**: [what drives the story]

---

## 4. Main Characters

| Name | Role | Personality | Visual |
|------|------|-------------|--------|
| Player | Protagonist (customizable) | Mute, player-defined | Custom avatar |
| Mentor NPC | Quest-giver | Wise, patient, slightly mysterious | Old human wizard |
| Antagonist | Main threat | Proud, manipulative | Dark sorcerer |

---

## 5. Story Structure

### Three-Act
- **Act 1**: Setup — introduces world, characters, threat. Ends with call to adventure.
- **Act 2**: Confrontation — player journeys, gains power, faces setbacks. Ends with apparent defeat.
- **Act 3**: Resolution — final confrontation, resolution.

### Chapters / Arcs
- Chapter 1: [title, one-line summary, rough level range]
- Chapter 2: [title, one-line summary, rough level range]
- ...

---

## 6. Dialogue System

### Patterns
- **Floating bubbles**: For casual chatter
- **Dialogue panel**: For quest and story dialogue (full screen on mobile)
- **Choice prompts**: Branching dialogue with 2-3 options max

### Constraints
- Max 150 characters per line
- Max 3 sentences per panel
- Skippable (tap to advance, skip button always visible)
- All dynamic text filtered via `TextService:FilterStringAsync`

---

## 7. Quest Delivery

- Quests are accepted from NPCs via ProximityPrompt
- Quest text appears in dialogue panel + quest log
- Objective markers shown on mini-map
- Completion returns player to quest-giver or auto-completes

### Quest Types
- **Main**: Progresses story
- **Side**: Optional content for extra rewards
- **Daily**: Resets every 24 hours
- **Hidden**: Discovered via exploration

---

## 8. Cutscene Approach

Roblox has no native cutscene editor. Approach:
- Set `workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable`
- Use `CFrame` tweens for camera movement
- Pause player input during cutscene
- Show dialogue via standard dialogue system
- Skip button always available

Keep cutscenes SHORT (< 30 seconds) — Roblox players are impatient with cinematics.

---

## 9. Voice & Audio

- Text-only dialogue by default (Roblox audio restrictions)
- Character "voice" conveyed through word choice and writing style
- Sound effect per dialogue line (short chirp/tone) for aliveness

---

## 10. Localization

All dialogue stored in `src/ReplicatedStorage/Shared/Config/Localization/`.

Keys use structured naming:
- `dialogue.<npc_id>.<conversation>.<line_n>`
- Example: `dialogue.mentor.intro.line_1`

---

## Integration Points

### Depends On
- Dialogue UI (ui-programmer)
- Quest system (luau-gameplay-programmer)
- Localization system

### Depended On By
- Quest rewards (economy integration)
- Character unlocks (cosmetics)
- Achievement system

---

## Acceptance Criteria

- [ ] All dialogue is skippable
- [ ] Max line length enforced
- [ ] Filter applied to dynamic text
- [ ] Quest markers appear in mini-map
- [ ] Lore consistent with world bible
- [ ] Age-appropriate language throughout
