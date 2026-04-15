---
name: start
description: Begin a new Roblox game project or onboard to an existing one. Use when starting a fresh session with no context, or when the user says "let's start" or "new project".
disable-model-invocation: true
---

# /start — Project Onboarding

Welcome the user and determine their starting point by asking:

**"Where are you with this project?"**

1. **No idea** — I don't even have a game concept yet
2. **Vague concept** — I have a rough idea but nothing documented
3. **Clear design** — I have a GDD or design docs ready
4. **Existing code** — I have a Roblox project with code already

## Based on their answer:

### If "No idea":
1. Run `/brainstorm` to explore game ideas
2. Guide through genre selection, target audience, core loop definition
3. Help define creative pillars (3-5 words each that describe the experience)
4. Draft a 1-page game concept document
5. Proceed to `/gdd` for the master GDD

### If "Vague concept":
1. Ask them to describe their idea in 2-3 sentences
2. Ask: What Roblox games inspire this? What's the core loop?
3. Help crystallize: genre, setting, core mechanic, target audience
4. Define creative pillars
5. Proceed to `/gdd`

### If "Clear design":
1. Ask them to share or describe their existing design docs
2. Review for completeness against GDD standards
3. Run `/project-stage-detect` to assess readiness
4. Identify gaps and create a plan to fill them
5. Set up the project structure if not already done

### If "Existing code":
1. Ask them to describe the project and share the codebase location
2. Run `/reverse-document` to generate docs from existing code
3. Run `/project-stage-detect` to assess current stage
4. Identify technical debt with `/tech-debt`
5. Create a plan for what's next

## After onboarding, always:
- Confirm the sync tool (Rojo / Argon / Manual Studio)
- Confirm the UI framework preference (Native / Roact / Fusion)
- Set up the `src/` directory structure for Roblox services
- Create `production/review-mode.txt` with the chosen review intensity (full / lean / solo)
- Suggest next steps

## Review Mode Options
- **Full**: Every change gets reviewed by relevant agents before implementation. Best for production work.
- **Lean**: Critical changes reviewed; minor changes proceed with a single approval. Best for solo devs moving fast.
- **Solo**: Minimum review. User makes most decisions directly. Best for prototyping.

Write the selected mode to `production/review-mode.txt`.
